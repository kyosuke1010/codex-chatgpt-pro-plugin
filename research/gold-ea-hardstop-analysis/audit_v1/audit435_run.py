#!/usr/bin/env python3
"""Audit 4 -> 3 -> 5 on extraction_bundle_v1 (v1 core CSVs).

Per Spec §4/§3/§5. Snapshot-coverage-independent, so runs on v1.0 without v1.3.
Primary scope = in6run (in-sample diagnostic only); pooled shown where the user's
sample-size notes apply. MISSING fields are recorded as EVIDENCE_UNAVAILABLE, never
fabricated. No OOS/live/150k-wins claim. EA untouched. All impl flags false.

Known MISSING in this bundle (recorded, not imputed):
  margin_level_at_hs (43/43), margin_level_at_hedge (48/48), distance_to_hs_price
  (48/48), worst_floating_pl (526/526), min_margin_level (526/526),
  post_close_move_1h/4h/24h (467/467). equity_curve (balance/equity/margin_level)
  is fully populated -> used for MaxDD and margin evidence.
"""

import csv
import statistics as st
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
EXT = REPO / "input_artifacts" / "extraction_bundle_v1" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis" / "audit_v1" / "audit_v1_deliverable_skeletons"
OUT.mkdir(parents=True, exist_ok=True)
EXPECTED_BASKET_YEN = -147  # in-sample expectancy per basket (fixed statement)


def L(n):
    return list(csv.DictReader(list(EXT.rglob(n))[0].open(encoding="utf-8-sig", errors="replace")))


def num(v):
    v = str(v).strip()
    if v in ("", "MISSING"):
        return None
    try:
        return float(v)
    except ValueError:
        return None


def pt(s):
    s = (s or "").strip().replace("T", " ")[:19]
    try:
        return datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        return None


def pctl(xs, q):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(q * len(xs)))] if xs else None


def w(name, hdr, rows):
    with (OUT / name).open("w", encoding="utf-8", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=hdr, extrasaction="ignore")
        wr.writeheader()
        for r in rows:
            wr.writerow({k: r.get(k, "") for k in hdr})
    print(f"  wrote {name}: {len(rows)} rows")


baskets = L("baskets.csv")
hardstops = L("hardstops.csv")
hedges = L("hedges.csv")
winners = L("basketclose_winners.csv")
equity = L("equity_curve.csv")
IN = lambda r: r["sample_type"] == "in6run"

# ===================== AUDIT 4: Capital Buffer / 150k Survival =====================
hs_in = [r for r in hardstops if IN(r)]
hs_loss = [num(r["hs_loss"]) for r in hs_in if num(r["hs_loss"]) is not None]
worst_hs = min(hs_loss)
mean_hs = st.mean(hs_loss)
worst_basket = min(num(b["final_pl"]) for b in baskets if IN(b) and num(b["final_pl"]) is not None)

# MaxDD per run from equity_curve (peak-to-trough of equity)
maxdd = {}
by_run = {}
for r in equity:
    by_run.setdefault(r["run_id"], []).append(r)
for run, rows in by_run.items():
    rows.sort(key=lambda x: pt(x["time"]) or datetime.min)
    peak = None
    dd = 0.0
    for x in rows:
        e = num(x["equity"])
        if e is None:
            continue
        peak = e if peak is None else max(peak, e)
        dd = max(dd, peak - e)
    cap = "50000" if "50000" in run else ("100000" if "100000" in run else "?")
    st_type = rows[0]["sample_type"]
    maxdd.setdefault((st_type, cap), []).append(dd)
maxdd_in_50 = max(maxdd.get(("in6run", "50000"), [0]))
maxdd_in_100 = max(maxdd.get(("in6run", "100000"), [0]))

# consecutive HardStop clusters (in6run, by time)
hs_times = sorted(pt(r["hs_time"]) for r in hs_in if pt(r["hs_time"]))
max_in_24h = 0
for i in range(len(hs_times)):
    j = i
    while j < len(hs_times) and (hs_times[j] - hs_times[i]).total_seconds() <= 24 * 3600:
        j += 1
    max_in_24h = max(max_in_24h, j - i)

# margin evidence from equity_curve time series near hedge/HS times (row-level margin MISSING)
def margin_near(run_id, t):
    if not t:
        return None
    rows = [x for x in by_run.get(run_id, []) if pt(x["time"]) and pt(x["time"]) <= t]
    if not rows:
        return None
    rows.sort(key=lambda x: pt(x["time"]))
    return num(rows[-1]["margin_level"])


hs_margin = [margin_near(r["run_id"], pt(r["hs_time"])) for r in hs_in]
hs_margin = [m for m in hs_margin if m is not None]
hedge_in = [r for r in hedges if IN(r)]
hedge_margin = [margin_near(r["run_id"], pt(r["hedge_time"])) for r in hedge_in]
hedge_margin = [m for m in hedge_margin if m is not None]
LOWMARG = 200.0  # margin_level% threshold for "near constraint" (observed-scale)
a4 = [
    {"metric": "worst_basket_loss_yen", "value_50k_pct": f"{worst_basket/50000*100:.2f}",
     "value_100k_pct": f"{worst_basket/100000*100:.2f}", "value_150k_pct": f"{worst_basket/150000*100:.2f}",
     "raw_yen": f"{worst_basket:.0f}", "note": "single worst basket final_pl (in6run)"},
    {"metric": "mean_hs_loss_yen", "value_50k_pct": f"{mean_hs/50000*100:.2f}",
     "value_100k_pct": f"{mean_hs/100000*100:.2f}", "value_150k_pct": f"{mean_hs/150000*100:.2f}",
     "raw_yen": f"{mean_hs:.0f}", "note": f"mean of {len(hs_loss)} in6run HardStop losses"},
    {"metric": "worst_hs_loss_yen", "value_50k_pct": f"{worst_hs/50000*100:.2f}",
     "value_100k_pct": f"{worst_hs/100000*100:.2f}", "value_150k_pct": f"{worst_hs/150000*100:.2f}",
     "raw_yen": f"{worst_hs:.0f}", "note": "worst single HardStop loss"},
    {"metric": "maxdd_measured_yen", "value_50k_pct": f"{maxdd_in_50/50000*100:.2f}",
     "value_100k_pct": f"{maxdd_in_100/100000*100:.2f}", "value_150k_pct": "NA_NO_150K_RUN",
     "raw_yen": f"50k={maxdd_in_50:.0f};100k={maxdd_in_100:.0f}",
     "note": "equity peak-to-trough; 150k NOT run so not directly measurable"},
    {"metric": "consecutive_hs_max_24h", "value_50k_pct": "NA", "value_100k_pct": "NA",
     "value_150k_pct": "NA", "raw_yen": str(max_in_24h),
     "note": f"max HardStops within any 24h window (in6run, n_hs={len(hs_times)})"},
    {"metric": "survival_est_150k_consecutive_worst_hs", "value_50k_pct": "NA", "value_100k_pct": "NA",
     "value_150k_pct": f"{150000/abs(worst_hs):.1f}", "raw_yen": f"worst_hs={worst_hs:.0f}",
     "note": "consecutive WORST-case HS to zero 150k equity (deposit/|worst_hs|); "
             "true margin-call needs XM Standard GOLD required-margin spec = EVIDENCE_UNAVAILABLE"},
    {"metric": "survival_est_150k_consecutive_mean_hs", "value_50k_pct": "NA", "value_100k_pct": "NA",
     "value_150k_pct": f"{150000/abs(mean_hs):.1f}", "raw_yen": f"mean_hs={mean_hs:.0f}",
     "note": "consecutive MEAN HS to zero 150k equity"},
    {"metric": "margin_constraint_evidence_at_HS", "value_50k_pct": "NA", "value_100k_pct": "NA",
     "value_150k_pct": "NA",
     "raw_yen": f"row_field_MISSING_43of43; equity_series margin@HS n={len(hs_margin)} "
                f"min={min(hs_margin):.0f} below{int(LOWMARG)}%={sum(1 for m in hs_margin if m<LOWMARG)}" if hs_margin else "EVIDENCE_UNAVAILABLE",
     "note": "hardstops.margin_level_at_hs MISSING; used equity_curve margin_level nearest-prior"},
    {"metric": "margin_constraint_evidence_at_HEDGE", "value_50k_pct": "NA", "value_100k_pct": "NA",
     "value_150k_pct": "NA",
     "raw_yen": f"row_field_MISSING_48of48; equity_series margin@hedge n={len(hedge_margin)} "
                f"min={min(hedge_margin):.0f} below{int(LOWMARG)}%={sum(1 for m in hedge_margin if m<LOWMARG)}" if hedge_margin else "EVIDENCE_UNAVAILABLE",
     "note": "hedges.margin_level_at_hedge MISSING; used equity_curve nearest-prior"},
    {"metric": "expectancy_statement", "value_50k_pct": "NA", "value_100k_pct": "NA", "value_150k_pct": "NA",
     "raw_yen": f"{EXPECTED_BASKET_YEN}", "note": "capital increase does NOT change expectancy -147 yen/basket"},
]
w("audit4_capital_buffer.csv",
  ["metric", "value_50k_pct", "value_100k_pct", "value_150k_pct", "raw_yen", "note"], a4)

# ===================== AUDIT 3: Hedge stratified (2-layer fallback) =====================
hedged_hs = [r for r in hs_in if r["hedged_flag"] == "1"]
nonhedged_hs = [r for r in hs_in if r["hedged_flag"] == "0"]
hedge_by_id = {r["basket_id"]: r for r in hedge_in}


def loss_of(r):
    return num(r["hs_loss"])


H_losses = [loss_of(r) for r in hedged_hs if loss_of(r) is not None]
N_losses = [loss_of(r) for r in nonhedged_hs if loss_of(r) is not None]
# stratifier: worst_floating_pl MISSING -> use basket_pl_at_hedge for hedged (2 layers by median)
plh = {bid: num(h["basket_pl_at_hedge"]) for bid, h in hedge_by_id.items() if num(h["basket_pl_at_hedge"]) is not None}
hedged_with_plh = [(r, plh[r["basket_id"]]) for r in hedged_hs if r["basket_id"] in plh]
med_plh = st.median([v for _, v in hedged_with_plh]) if hedged_with_plh else None
a3 = []
if med_plh is not None:
    for layer, cond in (("SHALLOW_at_hedge(pl>=median)", lambda v: v >= med_plh),
                        ("DEEP_at_hedge(pl<median)", lambda v: v < med_plh)):
        grp = [loss_of(r) for r, v in hedged_with_plh if cond(v) and loss_of(r) is not None]
        a3.append({"stratum": layer, "group": "HEDGED", "n": len(grp),
                   "hs_loss_median": f"{st.median(grp):.0f}" if grp else "NA",
                   "stratifier": "basket_pl_at_hedge (worst_floating_pl MISSING)",
                   "low_n_flag": "LOW_N" if len(grp) < 5 else "", "tag": "in-sample diagnostic only"})
# H vs N overall (Non-Hedged has no pl_at_hedge -> cannot stratify same axis; compare distributions)
a3.append({"stratum": "ALL", "group": "HEDGED", "n": len(H_losses),
           "hs_loss_median": f"{st.median(H_losses):.0f}" if H_losses else "NA",
           "stratifier": "NA", "low_n_flag": "LOW_N" if len(H_losses) < 5 else "",
           "tag": "in-sample diagnostic only"})
a3.append({"stratum": "ALL", "group": "NON_HEDGED", "n": len(N_losses),
           "hs_loss_median": f"{st.median(N_losses):.0f}" if N_losses else "NA",
           "stratifier": "NA", "low_n_flag": "LOW_N" if len(N_losses) < 5 else "",
           "tag": "in-sample diagnostic only"})
# timing classification for hedged (distance_to_hs_price MISSING -> hedge_too_late NOT_COMPUTABLE)
rec_room = no_rec = 0
for r in hedged_hs:
    h = hedge_by_id.get(r["basket_id"])
    if not h:
        continue
    plh_v = num(h["basket_pl_at_hedge"])
    best = num(h["post_hedge_max_recovery_pl"])
    if plh_v is None or best is None:
        continue
    if best > plh_v:
        rec_room += 1
    else:
        no_rec += 1
a3.append({"stratum": "TIMING", "group": "HEDGED",
           "n": len(hedged_hs),
           "hs_loss_median": f"recovery_room={rec_room};no_recovery={no_rec};hedge_too_late=NOT_COMPUTABLE(distance_MISSING)",
           "stratifier": "post_hedge_max_recovery_pl vs basket_pl_at_hedge",
           "low_n_flag": "", "tag": "in-sample diagnostic only"})
a3.append({"stratum": "MW_TEST", "group": "H_vs_N",
           "n": f"H={len(H_losses)},N={len(N_losses)}",
           "hs_loss_median": f"H_med={st.median(H_losses):.0f} vs N_med={st.median(N_losses):.0f}",
           "stratifier": "Mann-Whitney: MW_SKIPPED_NO_SCIPY (medians reported)",
           "low_n_flag": "N_LOW_N" if len(N_losses) < 5 else "", "tag": "in-sample diagnostic only"})
w("audit3_hedge_stratified.csv",
  ["stratum", "group", "n", "hs_loss_median", "stratifier", "low_n_flag", "tag"], a3)

# ===================== AUDIT 5: Winner Extension =====================
win_in = [num(r["final_pl"]) for r in winners if IN(r) and num(r["final_pl"]) is not None and num(r["final_pl"]) > 0]
cap_band = sum(1 for v in win_in if 380 <= v <= 420)
a5 = [
    {"metric": "winner_count", "value": len(win_in), "detail": "in6run BasketClose winners final_pl>0"},
    {"metric": "winner_final_pl_p50", "value": f"{pctl(win_in,0.5):.0f}", "detail": ""},
    {"metric": "winner_final_pl_p90", "value": f"{pctl(win_in,0.9):.0f}", "detail": ""},
    {"metric": "winner_final_pl_max", "value": f"{max(win_in):.0f}", "detail": ""},
    {"metric": "cap_concentration_380_420_share", "value": f"{cap_band/len(win_in):.3f}",
     "detail": f"{cap_band}/{len(win_in)} winners in 380-420 yen"},
    {"metric": "post_close_favorable_move_1h/4h/24h", "value": "EVIDENCE_UNAVAILABLE",
     "detail": "post_close_move_* MISSING 467/467 -> favorable move not computable"},
    {"metric": "winner_kill_risk", "value": "STRUCTURAL_ONLY",
     "detail": "no quantitative counterfactual (spec §5)"},
    {"metric": "verdict_input", "value": "FAVORABLE_MOVE_UNAVAILABLE -> extension feasibility undetermined",
     "detail": "needs post_close_move_* in v1.3+ to judge WINNER_EXTENSION_SECONDARY vs reject"},
]
w("audit5_winner_extension.csv", ["metric", "value", "detail"], a5)

print("\n=== Audit 4 headline ===")
print(f"  mean_hs_loss={mean_hs:.0f}yen worst_hs={worst_hs:.0f}yen worst_basket={worst_basket:.0f}yen")
print(f"  MaxDD in6run 50k={maxdd_in_50:.0f} 100k={maxdd_in_100:.0f}; max consecutive HS/24h={max_in_24h}")
print(f"  survival_150k: worst-case {150000/abs(worst_hs):.1f} / mean {150000/abs(mean_hs):.1f} consecutive HS to zero")
print(f"  margin@HS n={len(hs_margin)} (row field MISSING); margin@hedge n={len(hedge_margin)}")
print("=== Audit 3 ===")
print(f"  Hedged HS={len(H_losses)} med={st.median(H_losses):.0f}; NonHedged HS={len(N_losses)} med={st.median(N_losses):.0f}")
print(f"  timing hedged: recovery_room={rec_room} no_recovery={no_rec} hedge_too_late=NOT_COMPUTABLE")
print("=== Audit 5 ===")
print(f"  winners={len(win_in)} p50={pctl(win_in,0.5):.0f} p90={pctl(win_in,0.9):.0f} max={max(win_in):.0f} "
      f"cap380-420={cap_band}/{len(win_in)}; favorable_move=EVIDENCE_UNAVAILABLE")
