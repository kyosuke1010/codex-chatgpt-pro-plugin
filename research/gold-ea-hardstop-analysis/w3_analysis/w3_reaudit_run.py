#!/usr/bin/env python3
"""W3 telemetry re-audits: Audit3 timing / M3 threshold gap / Audit5 winner extension.

Inputs: scratchpad w3_key_events.csv (streamed from extraction_bundle_w3 w3_logs),
price_m5.csv (v1.1, 2026-03-02..06-30) for the offline post-close join.
Baseline tags: JUNE runs = V1_IDENTICAL; ML runs = V1_MOSTLY (55-106/119) except
ML_C_SHADOW_ON_50000_MAR_MAY = NEW_BASELINE (19/119 outcome match).
No profit claims; descriptive statistics only.
"""

import csv
import statistics as st
from bisect import bisect_left
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
SCRATCH = Path("/tmp/claude-0/-home-user-codex-chatgpt-pro-plugin/1504312d-7f69-5102-a9eb-b9c15a08239c/scratchpad")
OUT = Path(__file__).resolve().parent
PRICE = REPO / "input_artifacts" / "extraction_bundle_v1" / "extracted" / "extraction_bundle_v1_1" / "price_m5.csv"

NEW_BASELINE = {"W3_ON_ML_C_SHADOW_ON_50000_MAR_MAY_M5_20260301_20260529"}


def num(v):
    v = str(v).strip()
    if v in ("", "MISSING", "NA"):
        return None
    try:
        return float(v)
    except ValueError:
        return None


def pt(s):
    s = (s or "").strip().replace("T", " ").replace(".", "-", 2)[:19]
    try:
        return datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        return None


def baseline_tag(run_id):
    return "NEW_BASELINE" if run_id in NEW_BASELINE else (
        "V1_IDENTICAL" if "JUNE" in run_id else "V1_MOSTLY_IDENTICAL")


rows = list(csv.DictReader((SCRATCH / "w3_key_events.csv").open(encoding="utf-8")))
by_type = defaultdict(list)
for r in rows:
    by_type[r["event_type"]].append(r)

open_time = {}
for r in by_type["BASKET_OPEN"]:
    open_time.setdefault((r["run_id"], r["basket_uid"]), pt(r["server_time"]))
anchor = {}
for r in by_type["CLOSE_ANCHOR"]:
    anchor[(r["run_id"], r["basket_uid"])] = r
side_at_open = {}
for r in by_type["BASKET_OPEN"]:
    side_at_open.setdefault((r["run_id"], r["basket_uid"]), r["main_side"])
RMAP = {"basket close": "BASKET_CLOSE", "hard stop emergency close": "HARDSTOP",
        "Hedged basket time exit": "HTE", "Hedged basket danger time exit": "HTE_DANGER"}

# HS requests per basket (retry-loop evidence)
req = defaultdict(list)
for r in by_type["HARDSTOP_CLOSE_REQUEST"]:
    req[(r["run_id"], r["basket_uid"])].append(pt(r["server_time"]))

# ---------------------------------------------------------------- A. hedge timing
ht_rows = []
for r in by_type["HEDGE_TIMING"]:
    k = (r["run_id"], r["basket_uid"])
    a = anchor.get(k, {})
    ot = open_time.get(k)
    t = pt(r["server_time"])
    thr = num(r["hardstop_threshold_yen"])
    d = num(r["distance_to_hs_yen"])
    ht_rows.append({
        "run_id": r["run_id"], "basket_uid": r["basket_uid"],
        "baseline_tag": baseline_tag(r["run_id"]),
        "hedge_time": r["server_time"],
        "floating_at_hedge": r["basket_floating_pl"],
        "threshold_yen": r["hardstop_threshold_yen"],
        "distance_to_hs_yen": r["distance_to_hs_yen"],
        "pct_threshold_consumed": f"{(1 - d / thr) * 100:.1f}" if (d is not None and thr) else "NA",
        "worst_prehedge_at_hedge": r["worst_floating_prehedge"],
        "min_to_hedge_from_open": f"{(t - ot).total_seconds() / 60:.1f}" if (t and ot) else "NA",
        "final_close_reason": a.get("close_reason", "NO_ANCHOR"),
        "final_worst_lifecycle": a.get("worst_floating_lifecycle", "NA"),
    })
with (OUT / "w3_hedge_timing_analysis.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(ht_rows[0].keys()))
    w.writeheader(); w.writerows(ht_rows)

# ---------------------------------------------------------------- B. threshold gap
gap_rows = []
for r in by_type["HARDSTOP_CONDITION_TRUE"]:
    k = (r["run_id"], r["basket_uid"])
    a = anchor.get(k, {})
    det, clo = pt(r["server_time"]), pt(a.get("server_time", ""))
    reqs = sorted(x for x in req.get(k, []) if x)
    gap = num(a.get("threshold_gap_yen"))
    thr = num(r["hardstop_threshold_yen"])
    gap_rows.append({
        "run_id": r["run_id"], "basket_uid": r["basket_uid"],
        "baseline_tag": baseline_tag(r["run_id"]),
        "detect_time": r["server_time"],
        "detect_floating": r["basket_floating_pl"],
        "threshold_yen": r["hardstop_threshold_yen"],
        "detect_overshoot_yen": f"{num(r['basket_floating_pl']) + thr:.0f}" if (num(r["basket_floating_pl"]) is not None and thr) else "NA",
        "close_time": a.get("server_time", "NO_ANCHOR"),
        "detect_to_close_min": f"{(clo - det).total_seconds() / 60:.1f}" if (det and clo) else "NA",
        "close_request_count": len(reqs),
        "first_request_time": reqs[0].isoformat() if reqs else "NA",
        "request_span_min": f"{(reqs[-1] - reqs[0]).total_seconds() / 60:.1f}" if len(reqs) > 1 else "0",
        "threshold_gap_yen_at_close": a.get("threshold_gap_yen", "NA"),
        "final_pl_anchor": a.get("basket_floating_pl", "NA"),
        "close_reason": a.get("close_reason", "NA"),
    })
with (OUT / "w3_threshold_gap_analysis.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(gap_rows[0].keys()))
    w.writeheader(); w.writerows(gap_rows)

# ---------------------------------------------------------------- C. worst-floating profile
wf_rows = []
for (rid, uid), a in anchor.items():
    wl = num(a["worst_floating_lifecycle"])
    fin = num(a["basket_floating_pl"])
    wf_rows.append({
        "run_id": rid, "basket_uid": uid, "baseline_tag": baseline_tag(rid),
        "close_reason": a["close_reason"],
        "final_pl_anchor": a["basket_floating_pl"],
        "worst_prehedge": a["worst_floating_prehedge"],
        "worst_posthedge": a["worst_floating_posthedge"],
        "worst_lifecycle": a["worst_floating_lifecycle"],
        "recovery_from_worst": f"{fin - wl:.0f}" if (fin is not None and wl is not None) else "NA",
    })
with (OUT / "w3_worst_floating_profile.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(wf_rows[0].keys()))
    w.writeheader(); w.writerows(wf_rows)

# ---------------------------------------------------------------- D. post-close move (offline join)
bars = []
with PRICE.open(encoding="utf-8-sig") as f:
    for b in csv.DictReader(f):
        t = pt(b["time"])
        if t:
            bars.append((t, float(b["open"]), float(b["high"]), float(b["low"]), float(b["close"])))
bars.sort()
times = [b[0] for b in bars]

WINDOWS = {"1h": 12, "4h": 48, "24h": 288}
pcm_rows = []
for (rid, uid), a in anchor.items():
    ct = pt(a["server_time"])
    if not ct:
        continue
    bid, ask = num(a["bid"]), num(a["ask"])
    side = side_at_open.get((rid, uid), a["main_side"])
    start = bisect_left(times, ct + timedelta(seconds=1))
    row = {"run_id": rid, "basket_uid": uid, "baseline_tag": baseline_tag(rid),
           "close_reason": a["close_reason"], "close_time": a["server_time"],
           "main_side": side, "final_pl_anchor": a["basket_floating_pl"]}
    for wname, nbars in WINDOWS.items():
        seg = bars[start:start + nbars]
        exp_end = ct + timedelta(minutes=5 * nbars)
        seg = [b for b in seg if b[0] <= exp_end]
        cov = len(seg) / nbars
        if cov < 0.8 or bid is None or ask is None or side not in ("BUY", "SELL"):
            row[f"move_fav_max_{wname}"] = "MISSING"
            row[f"move_adv_max_{wname}"] = "MISSING"
            row[f"coverage_{wname}"] = f"{cov:.2f}"
            continue
        hi = max(b[2] for b in seg); lo = min(b[3] for b in seg)
        if side == "BUY":
            fav, adv = hi - ask, ask - lo
        else:
            fav, adv = bid - lo, hi - bid
        row[f"move_fav_max_{wname}"] = f"{fav:.2f}"
        row[f"move_adv_max_{wname}"] = f"{adv:.2f}"
        row[f"coverage_{wname}"] = f"{cov:.2f}"
    pcm_rows.append(row)
hdr = list(pcm_rows[0].keys())
with (OUT / "post_close_move_w3.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=hdr, extrasaction="ignore")
    w.writeheader(); w.writerows(pcm_rows)

# ---------------------------------------------------------------- console summaries
def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None

print(f"A. HEDGE_TIMING n={len(ht_rows)}")
cons = [num(r["pct_threshold_consumed"]) for r in ht_rows]
d_ = [num(r["distance_to_hs_yen"]) for r in ht_rows]
print(f"   pct_threshold_consumed at hedge: med={med(cons):.1f}% min={min(x for x in cons if x is not None):.1f} max={max(x for x in cons if x is not None):.1f}")
print(f"   distance_to_hs_yen at hedge: med={med(d_):.0f}")
hs_after = [r for r in ht_rows if RMAP.get(r["final_close_reason"]) == "HARDSTOP"]
print(f"   hedge->final HARDSTOP: {len(hs_after)}/{len(ht_rows)} | reasons: "
      f"{sorted(set(r['final_close_reason'] for r in ht_rows))}")

print(f"\nB. HS threshold gap n={len(gap_rows)}")
osz = [num(r["detect_overshoot_yen"]) for r in gap_rows]
d2c = [num(r["detect_to_close_min"]) for r in gap_rows]
gz = [num(r["threshold_gap_yen_at_close"]) for r in gap_rows]
rq = [r["close_request_count"] for r in gap_rows]
print(f"   detect overshoot (floating+thr at detect): med={med(osz):.0f} min={min(x for x in osz if x is not None):.0f}")
print(f"   detect->close min: med={med(d2c)} max={max(x for x in d2c if x is not None):.0f}")
print(f"   close_request_count: med={st.median(rq)} max={max(rq)}")
print(f"   threshold_gap_yen at close: med={med(gz)} min={min((x for x in gz if x is not None), default=None)}")

print(f"\nC. worst-floating anchors n={len(wf_rows)} by reason:")
for reason in sorted(set(r["close_reason"] for r in wf_rows)):
    grp = [r for r in wf_rows if RMAP.get(r["close_reason"], r["close_reason"]) == reason]
    print(f"   {reason:<22} n={len(grp):>3} worst_life_med={med([num(r['worst_lifecycle']) for r in grp])} "
          f"recovery_med={med([num(r['recovery_from_worst']) for r in grp])}")

print(f"\nD. post-close move n={len(pcm_rows)}")
for reason in ("BASKET_CLOSE", "HARDSTOP"):
    grp = [r for r in pcm_rows if RMAP.get(r["close_reason"]) == reason]
    for wname in ("1h", "4h", "24h"):
        fav = [num(r[f"move_fav_max_{wname}"]) for r in grp]
        favv = [x for x in fav if x is not None]
        miss = sum(1 for x in fav if x is None)
        if favv:
            print(f"   {reason:<13} {wname:>3}: fav_max med={st.median(favv):.2f} p90={sorted(favv)[int(0.9*len(favv))]:.2f} (n={len(favv)}, MISSING={miss})")
