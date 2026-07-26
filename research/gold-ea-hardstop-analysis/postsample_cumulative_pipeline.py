#!/usr/bin/env python3
"""Cumulative locked post-sample pipeline (multi-window) — EA無変更・観測のみ.

Reads postsample_windows_registry.csv, processes every window whose bundle is
present (June=W1 ingested; July=W2 pending), using the SAME frozen definitions:
canonical-key basket extraction, pre-hedge normalized-3min slope, rapid_drop
trigger 0.05/min, non-intervention (OFF vs ON trade events byte-identical),
EA identity via shadow-log source_before_sha256, half-open window membership.

Cumulative sufficiency (across all ingested windows):
  HardStop >= 15, non-hedged HardStop >= 2, slope-missing-rate (HardStop) <= 0.30.
Until met -> PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED.

MA bars (M5/M15/M30) enable Q2/Q4 (EMA10/SMA20 closed-bar warnings). When a
window ships them they are loaded and cross events listed; otherwise Q2/Q4 stay
PENDING_OVERLAY_INPUT. Nothing here changes the EA or any threshold.
"""

import csv
import hashlib
import re
import statistics as st
import zipfile
from collections import defaultdict
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
OUT = REPO / "research" / "gold-ea-hardstop-analysis"
REG = OUT / "postsample_windows_registry.csv"

EXPECT_SRC = "1353718f46d727db775827aaf30f86ec790056cb59ce46eb00d5bad563ef1de3"
NORM3_TRIGGER = 0.05                      # FROZEN
DEPOSITS = {"50000", "100000"}
SUFF = {"min_hardstop": 15, "min_nonhedged": 2, "max_slope_missing_rate": 0.30}
BASE = {"rapid_norm3_hs_p50": 0.145, "norm3_other_p50": 0.021}


def sha256(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def canon(uid):
    m = re.match(r"(GOLD#\d{4}\.\d{2}\.\d{2}T\d{2}:\d{2}:\d{2}#\d+)", uid or "")
    return m.group(1) if m else None


def max_norm_slope(series, win, idx):
    s = sorted(series)
    best, j = None, 0
    for i in range(len(s)):
        while s[i][0] - s[j][0] > win:
            j += 1
        if j < i and s[i][0] - s[j][0] >= win * 0.5:
            v = (s[i][idx] - s[j][idx]) / ((s[i][0] - s[j][0]) / 60.0) / s[i][2]
            best = v if best is None else max(best, v)
    return best


def w(name, header, rows):
    with (OUT / name).open("w", encoding="utf-8", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=header, extrasaction="ignore")
        wr.writeheader()
        for r in rows:
            wr.writerow({k: r.get(k, "UNKNOWN") for k in header})
    print(f"  wrote {name}: {len(rows)} rows")


def process_window(win):
    """Return dict of stats + per-basket rows for one window if bundle present."""
    wd = REPO / win["bundle_dir"]
    res = {"window_id": win["window_id"], "label": win["window_label"],
           "status": "AWAITING_BUNDLE", "baskets": [], "checks": {}}
    zips = list(wd.glob("*.zip")) if wd.is_dir() else []
    if not zips:
        return res
    ext = wd / "extracted"
    ext.mkdir(parents=True, exist_ok=True)
    for zp in zips:
        try:
            with zipfile.ZipFile(zp) as zf:
                if zf.testzip() is None:
                    zf.extractall(ext / zp.stem)
        except zipfile.BadZipFile:
            res["checks"]["extract"] = "FAIL"
            return res
    start = datetime.strptime(win["half_open_start"], "%Y-%m-%d %H:%M:%S")
    end_excl = datetime.strptime(win["half_open_end_excl"], "%Y-%m-%d %H:%M:%S")

    shadow_on, trade_events, inis, bars = [], [], [], []
    for p in ext.rglob("*"):
        if not p.is_file():
            continue
        nm = p.name.replace("\\", "/")
        if p.suffix.lower() == ".csv" and "SHADOW_ON" in nm and "MLSHADOW" in nm and "shadow_logs" in nm:
            shadow_on.append(p)
        elif "TRADE_EVENTS" in nm.upper():
            trade_events.append(p)
        elif p.suffix.lower() == ".ini":
            inis.append(p)
        elif re.search(r"gold_rates_M(5|15|30)", nm, re.I):
            bars.append(p)

    # EA identity via source_before_sha256
    src_vals = set()
    for p in shadow_on:
        for row in csv.DictReader(p.open(encoding="utf-8-sig", errors="replace")):
            src_vals.add((row.get("source_before_sha256", "") or "").lower())
            break
    res["checks"]["ea_identity"] = "PASS" if src_vals == {EXPECT_SRC} else f"FAIL:{src_vals}"

    # window bounds from ini
    win_ok = True
    for p in inis:
        raw = p.read_bytes()
        txt = raw.decode("utf-16", "ignore") if b"\x00" in raw[:64] else raw.decode("utf-8", "ignore")
        d = dict(l.split("=", 1) for l in txt.splitlines() if "=" in l and "||" not in l)
        if d.get("FromDate", "").strip() != win["from_date"] or d.get("ToDate", "").strip() != win["to_date"]:
            win_ok = False
    res["checks"]["window_match"] = "PASS" if (inis and win_ok) else ("AWAITING" if not inis else "FAIL")

    # non-intervention OFF vs ON
    def te(arm, cap):
        h = [p for p in trade_events if f"{arm}_{cap}" in p.name]
        return h[0] if h else None
    ni = True
    for cap in DEPOSITS:
        off, on = te("SHADOW_OFF", cap), te("SHADOW_ON", cap)
        if not off or not on or off.read_bytes() != on.read_bytes():
            ni = False
    res["checks"]["non_intervention"] = "PASS" if (trade_events and ni) else "FAIL_OR_MISSING"

    # basket extraction (canonical key) + pre-hedge slope
    outcome, hedged_tag, pre = {}, {}, defaultdict(list)
    for p in shadow_on:
        cap = next((c for c in DEPOSITS if c in p.name), "UNKNOWN")
        for row in csv.DictReader(p.open(encoding="utf-8-sig", errors="replace")):
            k = canon(row.get("basket_uid", ""))
            if not k:
                continue
            key = (cap, k)
            if "HEDGED" in row.get("basket_uid", ""):
                hedged_tag[key] = True
            et = row["event_type"]
            if et == "MULTILAYER_BASKET_SUMMARY":
                m = re.search(r"final_close_reason=([^|]+)", row.get("detail", ""))
                reason = (m.group(1) if m else row.get("summary_reason", "")).strip()
                try:
                    pl = float(row["current_basket_net_pl"])
                except ValueError:
                    pl = None
                if key not in outcome or "hard" in reason.lower():
                    outcome[key] = (reason, pl)
            elif et == "MULTILAYER_ROOT_SNAPSHOT":
                stx = row.get("server_time", "").replace(".", "-")[:19]
                try:
                    t = datetime.strptime(stx, "%Y-%m-%d %H:%M:%S")
                    if not (start <= t < end_excl):
                        continue
                except ValueError:
                    pass
                if not (row.get("is_pre_hedge", "").lower() in ("true", "1")
                        or row.get("is_never_hedged", "").lower() in ("true", "1")):
                    continue
                try:
                    ts = int(row["server_time_msc"]) / 1000.0
                    loss = float(row["floating_loss_yen"])
                    thr = float(row["hardstop_threshold_yen"])
                except (ValueError, KeyError):
                    continue
                if thr > 0:
                    pre[key].append((ts, loss, thr))

    for key, (reason, pl) in outcome.items():
        cap, k = key
        n3 = max_norm_slope(pre.get(key, []), 180, 1)
        is_hs = "hard" in reason.lower()
        res["baskets"].append({
            "window_id": win["window_id"], "capital": cap, "canonical_basket": k,
            "final_close_reason": reason, "net_pl_yen": pl,
            "hedged": str(hedged_tag.get(key, False)).lower(),
            "actual_class": "HARDSTOP" if is_hs else ("DEINIT_OPEN" if "deinit" in reason.lower() else "BASKET_CLOSE_OR_OTHER"),
            "norm_loss_slope_3min": f"{n3:.4f}" if n3 is not None else "UNDERIVABLE_SPARSE",
            "rapid_drop_trigger": str(n3 is not None and n3 >= NORM3_TRIGGER).lower(),
        })
    res["status"] = "INGESTED"
    res["ma_bars_present"] = bool(bars)
    res["n_bars_files"] = len(bars)
    return res


# ================= run =================
windows = list(csv.DictReader(REG.open(encoding="utf-8-sig")))
per_window_status, all_baskets = [], []
for win in windows:
    r = process_window(win)
    hs = [b for b in r["baskets"] if b["actual_class"] == "HARDSTOP"]
    per_window_status.append({
        "window_id": r["window_id"], "label": r["label"], "status": r["status"],
        "baskets": len(r["baskets"]), "hardstop": len(hs),
        "hardstop_hedged": sum(1 for b in hs if b["hedged"] == "true"),
        "hardstop_nonhedged": sum(1 for b in hs if b["hedged"] != "true"),
        "ma_bars_present": r.get("ma_bars_present", False),
        "ea_identity": r["checks"].get("ea_identity", "NA"),
        "window_match": r["checks"].get("window_match", "NA"),
        "non_intervention": r["checks"].get("non_intervention", "NA"),
    })
    all_baskets.extend(r["baskets"])

w("postsample_window_status.csv",
  ["window_id", "label", "status", "baskets", "hardstop", "hardstop_hedged",
   "hardstop_nonhedged", "ma_bars_present", "ea_identity", "window_match", "non_intervention"],
  per_window_status)
w("postsample_cumulative_baskets.csv",
  ["window_id", "capital", "canonical_basket", "final_close_reason", "net_pl_yen",
   "hedged", "actual_class", "norm_loss_slope_3min", "rapid_drop_trigger"], all_baskets)

# cumulative sufficiency
hs_all = [b for b in all_baskets if b["actual_class"] == "HARDSTOP"]
hs_hed = [b for b in hs_all if b["hedged"] == "true"]
hs_non = [b for b in hs_all if b["hedged"] != "true"]
hs_slopes = [float(b["norm_loss_slope_3min"]) for b in hs_all if b["norm_loss_slope_3min"] != "UNDERIVABLE_SPARSE"]
oth_slopes = [float(b["norm_loss_slope_3min"]) for b in all_baskets
              if b["actual_class"] != "HARDSTOP" and b["norm_loss_slope_3min"] != "UNDERIVABLE_SPARSE"]
slope_missing = (sum(1 for b in hs_all if b["norm_loss_slope_3min"] == "UNDERIVABLE_SPARSE") / len(hs_all)) if hs_all else None
ni_all = all(s["non_intervention"] in ("PASS", "NA") for s in per_window_status
             if s["status"] == "INGESTED")

suff = [
    {"criterion": "cumulative_hardstop", "required": f">={SUFF['min_hardstop']}", "observed": len(hs_all),
     "met": len(hs_all) >= SUFF["min_hardstop"]},
    {"criterion": "cumulative_nonhedged_hardstop", "required": f">={SUFF['min_nonhedged']}",
     "observed": len(hs_non), "met": len(hs_non) >= SUFF["min_nonhedged"]},
    {"criterion": "hardstop_slope_missing_rate", "required": f"<={SUFF['max_slope_missing_rate']}",
     "observed": f"{slope_missing:.3f}" if slope_missing is not None else "NA",
     "met": slope_missing is not None and slope_missing <= SUFF["max_slope_missing_rate"]},
    {"criterion": "non_intervention_all_windows", "required": "PASS", "observed": ni_all, "met": ni_all},
]
w("postsample_cumulative_sufficiency.csv", ["criterion", "required", "observed", "met"], suff)

ingested = [s for s in per_window_status if s["status"] == "INGESTED"]
awaiting = [s for s in per_window_status if s["status"] != "INGESTED"]
core_met = all(r["met"] for r in suff[:3])
if not core_met:
    decision = "PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED"
elif not ni_all:
    decision = "PROSPECTIVE_WINDOW_CONTAMINATED"
else:
    decision = "CUMULATIVE_SUFFICIENT_PROCEED_TO_INTEGRATION_REPORT"

print("\n=== CUMULATIVE POST-SAMPLE STATUS ===")
for s in per_window_status:
    print(f"  {s['window_id']} {s['label']}: {s['status']} baskets={s['baskets']} "
          f"hardstop={s['hardstop']}(hed={s['hardstop_hedged']},non={s['hardstop_nonhedged']}) "
          f"ma_bars={s['ma_bars_present']} NI={s['non_intervention']}")
print(f"\ncumulative HardStop={len(hs_all)} (hedged={len(hs_hed)}, nonhedged={len(hs_non)}) "
      f"need>=15 & nonhedged>=2")
if hs_slopes and oth_slopes:
    print(f"cumulative slope sep: HS p50={st.median(hs_slopes):.4f} OTHER p50={st.median(oth_slopes):.4f} "
          f"(in-sample HS {BASE['rapid_norm3_hs_p50']} / OTHER {BASE['norm3_other_p50']})")
print(f"windows ingested={len(ingested)} awaiting={[s['window_id'] for s in awaiting]}")
print("=== DECISION:", decision, "===")

# write cumulative decision summary line for downstream docs
w("postsample_cumulative_decision.csv",
  ["decision", "cumulative_hardstop", "cumulative_nonhedged", "slope_missing_rate",
   "windows_ingested", "windows_awaiting"],
  [{"decision": decision, "cumulative_hardstop": len(hs_all),
    "cumulative_nonhedged": len(hs_non),
    "slope_missing_rate": f"{slope_missing:.3f}" if slope_missing is not None else "NA",
    "windows_ingested": ";".join(s["window_id"] for s in ingested),
    "windows_awaiting": ";".join(s["window_id"] for s in awaiting)}])
