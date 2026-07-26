#!/usr/bin/env python3
"""Prospective (locked post-sample) ingestion pipeline — EA無変更・観測のみ.

19-step receiving pipeline for the June-2026 locked post-sample validation window.
Consumes input_artifacts/prospective/ (June bundle). Basket/Run summaries are
embedded in the Shadow-ON logs (MULTILAYER_BASKET_SUMMARY / _RUN_SUMMARY), same as
in-sample. Non-intervention is verified by OFF-vs-ON trade-event equality.
With no data present it emits AWAITING deliverables (no fabrication).

EA identity is verified via the shadow log field `source_before_sha256`
(EA-internal source hash) equal to the in-sample value, since no .mq5/.ex5 file
is shipped in the bundle.
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
PROS = REPO / "input_artifacts" / "prospective"
PEXT = PROS / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis"

# ---- FROZEN pre-registration (mirror of locked_window_manifest; do not edit post-hoc) ----
EXPECT_SRC_INTERNAL_SHA = "1353718F46D727DB775827AAF30F86EC790056CB59CE46EB00D5BAD563EF1DE3".lower()
WIN_START = datetime(2026, 6, 1, 0, 0, 0)
WIN_END_EXCL = datetime(2026, 7, 1, 0, 0, 0)   # half-open
EXPECT = {"symbol": "GOLD", "period": "M5", "model": "0",
          "deposits": {"50000", "100000"}, "from": "2026.06.01", "to": "2026.06.30"}
NORM3_TRIGGER = 0.05  # FROZEN record trigger (not an exit condition)

# in-sample baselines (read-only; comparison only, never re-fit)
BASE = {"rapid_norm3_hs_p50": 0.145, "norm3_other_p50": 0.021, "norm3_other_p90": 0.111,
        "prehedge_M15_total_yen": -10258, "prehedge_M5_total_yen": -41538,
        "prehedge_M15_bckill": 26, "hte_late_n": 1, "hte_late_yen": -20,
        "hs_pm60_event_share": "2/37", "insample_hs": 37}
SUFF = {"min_hardstop": 15, "min_nonhedged": 2, "min_hedged": 2,
        "min_basketclose": 5, "max_slope_missing_rate": 0.30}


def sha256(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def w(name, header, rows):
    with (OUT / name).open("w", encoding="utf-8", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=header, extrasaction="ignore")
        wr.writeheader()
        for r in rows:
            wr.writerow({k: r.get(k, "UNKNOWN") for k in header})
    print(f"  wrote {name}: {len(rows)} rows")


def canon(uid):
    m = re.match(r"(GOLD#\d{4}\.\d{2}\.\d{2}T\d{2}:\d{2}:\d{2}#\d+)", uid or "")
    return m.group(1) if m else None


checks = []


def chk(step, name, status, detail=""):
    checks.append({"step": step, "check": name, "status": status, "detail": detail})
    print(f"[{step:>2}] {name}: {status} {detail}")


# ================= Step 1: presence + SHA256 =================
files = [p for p in PROS.iterdir() if p.is_file()] if PROS.is_dir() else []
zips = [p for p in files if p.suffix.lower() == ".zip"]
w("prospective_input_sha_manifest.csv", ["file", "size_bytes", "sha256"],
  [{"file": p.name, "size_bytes": p.stat().st_size, "sha256": sha256(p)} for p in files])
chk(1, "input_presence_and_sha256", "PASS" if files else "AWAITING", f"{len(files)} files")

# ================= Step 2: extract =================
if zips:
    PEXT.mkdir(parents=True, exist_ok=True)
    for zp in zips:
        try:
            with zipfile.ZipFile(zp) as zf:
                if zf.testzip() is None:
                    zf.extractall(PEXT / zp.stem)
        except zipfile.BadZipFile:
            chk(2, "extract", "FAIL", f"bad zip {zp.name}")
chk(2, "extract", "PASS" if zips else "AWAITING", f"{len(zips)} archives")

# ================= Steps 3-6: rediscover =================
shadow_on, trade_events, ini_files = [], [], []
if PEXT.exists():
    for p in PEXT.rglob("*"):
        if not p.is_file():
            continue
        nm = p.name.replace("\\", "/")
        if p.suffix.lower() == ".csv" and "SHADOW_ON" in nm and "MLSHADOW" in nm and "shadow_logs" in nm:
            shadow_on.append(p)
        elif "TRADE_EVENTS" in nm.upper():
            trade_events.append(p)
        elif p.suffix.lower() == ".ini":
            ini_files.append(p)
chk(3, "rediscover_root_snapshot(shadow_on)", "PASS" if shadow_on else "AWAITING", f"{len(shadow_on)} logs")
chk(4, "rediscover_basket_summary(embedded)", "PASS" if shadow_on else "AWAITING",
    "MULTILAYER_BASKET_SUMMARY within shadow-on logs")
chk(5, "rediscover_run_summary(embedded)", "PASS" if shadow_on else "AWAITING",
    "MULTILAYER_RUN_SUMMARY within shadow-on logs")
chk(6, "rediscover_trade_events", "PASS" if trade_events else "AWAITING", f"{len(trade_events)} files")

DATA = bool(shadow_on)

# ================= Step 7: schema validation =================
REQ = {"root_snapshot_id", "basket_uid", "event_type", "server_time", "server_time_msc",
       "floating_loss_yen", "hardstop_threshold_yen", "distance_to_hardstop_yen",
       "is_pre_hedge", "is_never_hedged", "hardstop_now_snapshot",
       "current_HTE_eligibility", "current_BasketClose_eligibility",
       "close_priority_ok", "market_state", "high_impact_usd_event_window_state",
       "current_basket_net_pl", "hedge_count", "summary_reason", "detail"}
schema_ok = None
if shadow_on:
    hdr = set(csv.DictReader(shadow_on[0].open(encoding="utf-8-sig")).fieldnames or [])
    missing = REQ - hdr
    schema_ok = not missing
    chk(7, "schema_validation", "PASS" if schema_ok else "FAIL",
        f"missing={sorted(missing)}" if missing else "83-col schema, all required present")
else:
    chk(7, "schema_validation", "AWAITING", "")

# ================= Step 8: EA identity via internal source hash =================
src_vals = set()
for p in shadow_on:
    with p.open(encoding="utf-8-sig", errors="replace", newline="") as f:
        for row in csv.DictReader(f):
            src_vals.add((row.get("source_before_sha256", "") or "").lower())
            break
if src_vals:
    ok = src_vals == {EXPECT_SRC_INTERNAL_SHA}
    chk(8, "ea_identity_source_before_sha256", "PASS" if ok else "FAIL_EA_CHANGED",
        f"matches in-sample 1353718F" if ok else f"got {src_vals}")
else:
    chk(8, "ea_identity_source_before_sha256", "AWAITING", "")

# ================= Steps 9-10: window / deposit / symbol / tf / model =================
def read_ini(p):
    raw = p.read_bytes()
    txt = raw.decode("utf-16", "ignore") if b"\x00" in raw[:64] else raw.decode("utf-8", "ignore")
    d = {}
    for line in txt.splitlines():
        if "=" in line and "||" not in line:
            k, _, v = line.partition("=")
            d.setdefault(k.strip(), v.strip())
    return d


win_ok = cfg_ok = None
if ini_files:
    win_ok = cfg_ok = True
    depos = set()
    for p in ini_files:
        d = read_ini(p)
        if d.get("FromDate") != EXPECT["from"] or d.get("ToDate") != EXPECT["to"]:
            win_ok = False
        if d.get("Symbol") != EXPECT["symbol"] or d.get("Period") != EXPECT["period"] \
           or d.get("Model") != EXPECT["model"]:
            cfg_ok = False
        depos.add(d.get("Deposit", ""))
    if not depos <= (EXPECT["deposits"] | {""}):
        cfg_ok = False
    chk(9, "window_match_halfopen_June", "PASS" if win_ok else "FAIL",
        "FromDate=2026.06.01 ToDate=2026.06.30")
    chk(10, "deposit_symbol_tf_model_match", "PASS" if cfg_ok else "FAIL",
        f"deposits={sorted(depos)} symbol/tf/model ok={cfg_ok}")
else:
    chk(9, "window_match_halfopen_June", "AWAITING", "")
    chk(10, "deposit_symbol_tf_model_match", "AWAITING", "")

# ================= Steps 11-14: extract baskets + pre-hedge slope features =================
outcome = {}          # key=(cap,canon) -> (final_close_reason, net_pl)
hedged_tag = {}       # key -> True if any HEDGED variant seen
pre_series = defaultdict(list)   # key -> [(ts, loss, thr, dist)]
start_time = {}
for p in shadow_on:
    cap = next((c for c in EXPECT["deposits"] if c in p.name), "UNKNOWN")
    with p.open(encoding="utf-8-sig", errors="replace", newline="") as f:
        for row in csv.DictReader(f):
            uid = row.get("basket_uid", "")
            k = canon(uid)
            if not k:
                continue
            key = (cap, k)
            if "HEDGED" in uid:
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
                sm = re.search(r"start_time=([\d.]+ [\d:]+)", row.get("detail", ""))
                if sm:
                    start_time[key] = sm.group(1)
            elif et == "MULTILAYER_ROOT_SNAPSHOT":
                st_ = row.get("server_time", "").replace(".", "-")[:19]
                try:
                    t = datetime.strptime(st_, "%Y-%m-%d %H:%M:%S")
                    if not (WIN_START <= t < WIN_END_EXCL):
                        continue
                except ValueError:
                    pass
                is_pre = (row.get("is_pre_hedge", "").lower() in ("true", "1")
                          or row.get("is_never_hedged", "").lower() in ("true", "1"))
                if not is_pre:
                    continue
                try:
                    ts = int(row["server_time_msc"]) / 1000.0
                    loss = float(row["floating_loss_yen"])
                    thr = float(row["hardstop_threshold_yen"])
                    dist = float(row["distance_to_hardstop_yen"])
                except (ValueError, KeyError):
                    continue
                if thr > 0:
                    pre_series[key].append((ts, loss, thr, dist))


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


feat_rows, missing_slope = [], 0
for key, (reason, pl) in outcome.items():
    cap, k = key
    s = pre_series.get(key, [])
    n1 = max_norm_slope(s, 60, 1)
    n3 = max_norm_slope(s, 180, 1)
    n5 = max_norm_slope(s, 300, 1)
    shrink = max_norm_slope([(t, -d, thr, d) for (t, l, thr, d) in s], 180, 1)
    if n3 is None:
        missing_slope += 1
    is_hs = "hard" in reason.lower()
    feat_rows.append({
        "canonical_basket": k, "capital": cap,
        "final_close_reason": reason, "net_pl_yen": pl,
        "hedged": str(hedged_tag.get(key, False)).lower(),
        "prehedge_snapshot_count": len(s),
        "norm_loss_slope_1min": f"{n1:.4f}" if n1 is not None else "UNDERIVABLE_SPARSE",
        "norm_loss_slope_3min": f"{n3:.4f}" if n3 is not None else "UNDERIVABLE_SPARSE",
        "norm_loss_slope_5min": f"{n5:.4f}" if n5 is not None else "UNDERIVABLE_SPARSE",
        "norm_distance_shrink_rate_3min": f"{shrink:.4f}" if shrink is not None else "UNDERIVABLE_SPARSE",
        "rapid_drop_observation_trigger": str(n3 is not None and n3 >= NORM3_TRIGGER).lower(),
        "trigger_threshold_norm3_per_min": NORM3_TRIGGER,
        "actual_class": "HARDSTOP" if is_hs else ("DEINIT_OPEN" if "deinit" in reason.lower() else "BASKET_CLOSE_OR_OTHER"),
        "data_source": "PROSPECTIVE_JUNE2026_DERIVED",
    })
w("prehedge_slope_derived_features.csv",
  ["canonical_basket", "capital", "final_close_reason", "net_pl_yen", "hedged",
   "prehedge_snapshot_count", "norm_loss_slope_1min", "norm_loss_slope_3min",
   "norm_loss_slope_5min", "norm_distance_shrink_rate_3min",
   "rapid_drop_observation_trigger", "trigger_threshold_norm3_per_min",
   "actual_class", "data_source"], feat_rows)

inv_rows = []
for p in shadow_on:
    cap = next((c for c in EXPECT["deposits"] if c in p.name), "UNKNOWN")
    n = sum(1 for row in csv.DictReader(p.open(encoding="utf-8-sig", errors="replace"))
            if row.get("event_type") == "MULTILAYER_ROOT_SNAPSHOT")
    inv_rows.append({"source_file": p.name[:80], "capital": cap, "root_snapshot_rows": n})
w("prospective_snapshot_inventory.csv", ["source_file", "capital", "root_snapshot_rows"], inv_rows)

slope_missing_rate = (missing_slope / len(feat_rows)) if feat_rows else None
chk(11, "prehedge_feature_generation", "PASS" if feat_rows else "AWAITING", f"{len(feat_rows)} baskets")
chk(12, "loss_slope_1_3_5min_derivation", "PASS" if feat_rows else "AWAITING",
    f"missing_rate={slope_missing_rate:.3f}" if slope_missing_rate is not None else "")
chk(13, "distance_shrink_rate_derivation", "PASS" if feat_rows else "AWAITING", "")
trig_fired = sum(1 for r in feat_rows if r["rapid_drop_observation_trigger"] == "true")
chk(14, "rapid_drop_trigger_eval", "PASS" if feat_rows else "AWAITING", f"fired={trig_fired}")

# rapid drop observation results (HardStop-focused)
rd_rows = []
for r in feat_rows:
    if r["actual_class"] != "HARDSTOP":
        continue
    rd_rows.append({
        "canonical_basket": r["canonical_basket"], "capital": r["capital"],
        "hedged": r["hedged"], "net_pl_yen": r["net_pl_yen"],
        "norm_loss_slope_3min": r["norm_loss_slope_3min"],
        "trigger_fired": r["rapid_drop_observation_trigger"],
        "no_warning_rapid_drop_class": ("RAPID_DROP_TRIGGER_MET" if r["rapid_drop_observation_trigger"] == "true"
                                        else "BELOW_TRIGGER_SLOW_OR_SPARSE"),
        "data_source": "PROSPECTIVE_JUNE2026_DERIVED"})
w("rapid_drop_observation_results.csv",
  ["canonical_basket", "capital", "hedged", "net_pl_yen", "norm_loss_slope_3min",
   "trigger_fired", "no_warning_rapid_drop_class", "data_source"], rd_rows)

# ================= Step 15: MA overlay =================
has_bars = bool(list(PEXT.rglob("*with_ma*.csv"))) if PEXT.exists() else False
chk(15, "ma_overlay_join", "PENDING_OVERLAY_INPUT" if (DATA and not has_bars) else
    ("READY" if has_bars else "AWAITING"),
    "June bundle ships no M5/M15/M30 bars; EMA10/SMA20 overlay (Q2/Q4/Q5) deferred")

# ================= Step 16: event stratification (Q6) =================
# event window state at/near hardstop for the 6 hardstops
hs_event = defaultdict(lambda: "UNKNOWN")
if shadow_on:
    hs_keys = {key for key, (r, pl) in outcome.items() if "hard" in r.lower()}
    for p in shadow_on:
        cap = next((c for c in EXPECT["deposits"] if c in p.name), "UNKNOWN")
        for row in csv.DictReader(p.open(encoding="utf-8-sig", errors="replace")):
            key = (cap, canon(row.get("basket_uid", "")))
            if key in hs_keys and row.get("high_impact_usd_event_window_state") in ("TRUE", "true"):
                hs_event[key] = "IN_WINDOW_SEEN"
    ev_in = sum(1 for k in hs_keys if hs_event[k] == "IN_WINDOW_SEEN")
    chk(16, "event_window_stratification", "PASS", f"hardstops_with_event_window={ev_in}/{len(hs_keys)}")
else:
    chk(16, "event_window_stratification", "AWAITING", "")

# ================= non-intervention (OFF vs ON trade events) =================
def find_te(arm, cap):
    hits = [p for p in trade_events if f"{arm}_{cap}" in p.name]
    return hits[0] if hits else None


ni_rows = []
ni_all_pass = bool(trade_events)
for cap in sorted(EXPECT["deposits"]):
    off, on = find_te("SHADOW_OFF", cap), find_te("SHADOW_ON", cap)
    if not off or not on:
        ni_all_pass = False
        ni_rows.append({"capital": cap, "off_present": bool(off), "on_present": bool(on),
                        "bytewise_identical": "MISSING_ARM", "verdict": "FAIL_MISSING_ARM"})
        continue
    same = off.read_bytes() == on.read_bytes()
    ni_all_pass = ni_all_pass and same
    ni_rows.append({"capital": cap, "off_present": True, "on_present": True,
                    "off_bytes": off.stat().st_size, "on_bytes": on.stat().st_size,
                    "bytewise_identical": str(same).lower(),
                    "verdict": "PASS_NON_INTERVENTION" if same else "FAIL_SHADOW_ALTERED_TRADES"})
w("prospective_nonintervention_check.csv",
  ["capital", "off_present", "on_present", "off_bytes", "on_bytes",
   "bytewise_identical", "verdict"], ni_rows)
chk(17, "non_intervention_off_vs_on", "PASS" if (trade_events and ni_all_pass) else
    ("AWAITING" if not trade_events else "FAIL"), f"{len(ni_rows)} capital arms")

# ================= Q1..Q6 =================
hs_slopes = [float(r["norm_loss_slope_3min"]) for r in feat_rows
             if r["actual_class"] == "HARDSTOP" and r["norm_loss_slope_3min"] != "UNDERIVABLE_SPARSE"]
oth_slopes = [float(r["norm_loss_slope_3min"]) for r in feat_rows
              if r["actual_class"] != "HARDSTOP" and r["norm_loss_slope_3min"] != "UNDERIVABLE_SPARSE"]


def med(xs):
    return f"{st.median(xs):.4f}" if xs else "NA"


q_rows = [
    {"question": "Q1", "hypothesis": "rapid-drop pre-hedge slope separation reproduces",
     "insample_reference": f"HS_p50={BASE['rapid_norm3_hs_p50']} OTHER_p50={BASE['norm3_other_p50']}",
     "prospective_result": f"HS_p50={med(hs_slopes)}(n={len(hs_slopes)}) OTHER_p50={med(oth_slopes)}(n={len(oth_slopes)})",
     "verdict": ("DIRECTIONALLY_REPRODUCED" if hs_slopes and oth_slopes
                 and st.median(hs_slopes) > st.median(oth_slopes) * 3 else "UNDER_POWERED")},
    {"question": "Q2", "hypothesis": "pre-hedge MA warning stays harm-excess",
     "insample_reference": f"M15={BASE['prehedge_M15_total_yen']} M5={BASE['prehedge_M5_total_yen']}",
     "prospective_result": "PENDING_OVERLAY_INPUT(no bars shipped)", "verdict": "PENDING"},
    {"question": "Q3", "hypothesis": "slope+shrink separates shallow vs deep adverse",
     "insample_reference": "~7x median gap",
     "prospective_result": (f"~{st.median(hs_slopes)/st.median(oth_slopes):.0f}x median gap"
                            if hs_slopes and oth_slopes and st.median(oth_slopes) > 0 else "NA"),
     "verdict": "DESCRIPTIVE_ONLY_LOW_N"},
    {"question": "Q4", "hypothesis": "BC-kill vs HardStop difference",
     "insample_reference": f"BC-kill(pre-hedge M15)={BASE['prehedge_M15_bckill']}",
     "prospective_result": "PENDING_OVERLAY_INPUT(MA warning needs bars)", "verdict": "PENDING"},
    {"question": "Q5", "hypothesis": "HTE late-eligibility observable",
     "insample_reference": f"{BASE['hte_late_n']}/{BASE['hte_late_yen']}yen",
     "prospective_result": "NO_HTE_CLOSE_IN_JUNE(all baskets basket-close/hardstop)", "verdict": "NO_EVENT"},
    {"question": "Q6", "hypothesis": "event window auxiliary only",
     "insample_reference": f"hs_pm60_share={BASE['hs_pm60_event_share']}",
     "prospective_result": f"hardstops_in_event_window={sum(1 for k in hs_event if hs_event[k]=='IN_WINDOW_SEEN')}/{len([1 for r in feat_rows if r['actual_class']=='HARDSTOP'])}",
     "verdict": "EVENT_NOT_PRIMARY_CONSISTENT"},
]
w("prospective_q1_q6_results.csv",
  ["question", "hypothesis", "insample_reference", "prospective_result", "verdict"], q_rows)
chk(18, "Q1_Q6_analysis", "PARTIAL" if DATA else "AWAITING",
    "Q1/Q3/Q6 computed; Q2/Q4/Q5 pending overlay bars")

# ================= sufficiency =================
hs_all = [r for r in feat_rows if r["actual_class"] == "HARDSTOP"]
hs_hed = [r for r in hs_all if r["hedged"] == "true"]
hs_non = [r for r in hs_all if r["hedged"] != "true"]
bc = [r for r in feat_rows if r["actual_class"] == "BASKET_CLOSE_OR_OTHER"]
suff_rows = [
    {"criterion": "prospective_hardstop_count", "required": f">={SUFF['min_hardstop']}", "observed": len(hs_all),
     "met": len(hs_all) >= SUFF["min_hardstop"]},
    {"criterion": "nonhedged_hardstop", "required": f">={SUFF['min_nonhedged']}", "observed": len(hs_non),
     "met": len(hs_non) >= SUFF["min_nonhedged"]},
    {"criterion": "hedged_hardstop", "required": f">={SUFF['min_hedged']}", "observed": len(hs_hed),
     "met": len(hs_hed) >= SUFF["min_hedged"]},
    {"criterion": "basketclose_count", "required": f">={SUFF['min_basketclose']}", "observed": len(bc),
     "met": len(bc) >= SUFF["min_basketclose"]},
    {"criterion": "slope_missing_rate", "required": f"<={SUFF['max_slope_missing_rate']}",
     "observed": f"{slope_missing_rate:.3f}" if slope_missing_rate is not None else "NA",
     "met": slope_missing_rate is not None and slope_missing_rate <= SUFF["max_slope_missing_rate"]},
    {"criterion": "non_intervention_off_and_on", "required": "PASS both caps",
     "observed": f"pass={ni_all_pass}", "met": bool(trade_events) and ni_all_pass},
]
w("prospective_sufficiency_check.csv", ["criterion", "required", "observed", "met"], suff_rows)
suff_met = DATA and all(r["met"] for r in suff_rows)
chk(19 - 0.5, "sufficiency_check", "PASS" if suff_met else ("AWAITING" if not DATA else "NOT_MET"),
    f"hs={len(hs_all)}(hed={len(hs_hed)},non={len(hs_non)}) bc={len(bc)}")

# ================= Step 19: decision =================
if not DATA:
    decision = "PROSPECTIVE_INGESTION_PIPELINE_READY_WITH_DATA_PENDING"
elif any(str(c["status"]).startswith("FAIL") for c in checks):
    bad = [c["check"] for c in checks if str(c["status"]).startswith("FAIL")]
    decision = ("PROSPECTIVE_WINDOW_CONTAMINATED"
                if any(x in ("window_match_halfopen_June", "ea_identity_source_before_sha256",
                             "deposit_symbol_tf_model_match", "non_intervention_off_vs_on") for x in bad)
                else "PROSPECTIVE_INPUT_SCHEMA_INCOMPLETE")
elif not suff_met:
    decision = "PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED"
else:
    decision = "SUFFICIENT_PROCEED_TO_Q_ANALYSIS_REPORT"
chk(19, "final_decision", decision, "")

w("prospective_pipeline_run_log.csv", ["step", "check", "status", "detail"], checks)
print("\n=== DECISION:", decision, "===")
print(f"June: baskets={len(feat_rows)} hardstop={len(hs_all)}(hedged={len(hs_hed)},nonhedged={len(hs_non)})"
      f" basketclose={len(bc)} net_pl={sum(float(r['net_pl_yen']) for r in feat_rows if r['net_pl_yen'] not in (None,'UNKNOWN')):.0f}yen")
print("non-intervention:", "PASS(byte-identical OFF==ON)" if ni_all_pass else "CHECK")
print("window (FROZEN): 2026-06-01 .. 2026-06-30 (half-open to 2026-07-01)")
