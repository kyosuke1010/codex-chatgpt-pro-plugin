#!/usr/bin/env python3
"""Audit 2 axis A (position/lot exposure amplification) — v1.4 deal-level resolution.

v1.4 = existing KOUCHA_GOLD_KIWAMI_TRADE_EVENTS rows with v1-basket interval
assignment (no Tester rerun; EA untouched). Identity gate: close_time/final_pl
MATCH 521/526 + 5 DEINIT-expected; open_time exact ENTRY 400/526 (126 baskets
assigned by interval only — documented limitation, aggregates for those baskets
use interval-assigned rows).

Axis A questions now answerable at position level:
  1. Did the EA ever ADD entries to a basket (grid amplification)?
     -> MainDirectionPositions / DefenseHedgePositions maxima over ALL events.
  2. Was lot size ever scaled up? -> OrderLots distribution.
  3. Per-leg P/L decomposition of HardStop baskets (profit-offset structure):
     gross leg magnitudes vs basket net at HARDSTOP_CLOSE.
  4. Real MarginLevel at HEDGE / HARDSTOP events (replaces 0.00 placeholder).

Cross-check: sum of final-close leg ProfitYen vs v1 baskets.final_pl.
No zero-fill; UNASSIGNED rows are excluded from per-basket aggregates but
included in global maxima (they still bound EA-wide position counts).
"""

import csv
import statistics as st
from collections import Counter, defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
EXT = REPO / "input_artifacts" / "extraction_bundle_v1" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis" / "audit_v1" / "audit_v1_deliverable_skeletons"
OUT.mkdir(parents=True, exist_ok=True)


def L(n):
    return list(csv.DictReader(list(EXT.rglob(n))[0].open(encoding="utf-8-sig", errors="replace")))


def num(v):
    v = str(v).strip()
    if v in ("", "MISSING", "NA"):
        return None
    try:
        return float(v)
    except ValueError:
        return None


deals = L("deals_v1_4.csv")
baskets = {r["basket_id"]: r for r in L("baskets.csv")}
hs_ids = {bid for bid, b in baskets.items() if b["close_reason"] == "HardStop"}
assigned = [r for r in deals if r["basket_assignment_status"].startswith("ASSIGNED")]

# ---- 1) global position-count maxima (ALL 3,498 events, incl. STATE/DIAG) ----
md_max = max(int(float(r["MainDirectionPositions"])) for r in deals if num(r["MainDirectionPositions"]) is not None)
dh_max = max(int(float(r["DefenseHedgePositions"])) for r in deals if num(r["DefenseHedgePositions"]) is not None)
tot_max = max(int(float(r["MainDirectionPositions"])) + int(float(r["DefenseHedgePositions"]))
              for r in deals
              if num(r["MainDirectionPositions"]) is not None and num(r["DefenseHedgePositions"]) is not None)

# ---- 2) lot distribution on order events ----
ehc = [r for r in deals if r["event_role"] in ("ENTRY", "HEDGE", "CLOSE")]
lots = sorted({float(r["OrderLots"]) for r in ehc if num(r["OrderLots"]) is not None})

# ---- 3) per-basket aggregates ----
by_b = defaultdict(list)
for r in assigned:
    by_b[r["basket_id"]].append(r)

agg_rows = []
pl_match = pl_mismatch = 0
for bid, b in baskets.items():
    rows = by_b.get(bid, [])
    ent = [r for r in rows if r["event_role"] == "ENTRY"]
    hed = [r for r in rows if r["event_role"] == "HEDGE"]
    clo = [r for r in rows if r["event_role"] == "CLOSE"]
    mp = max((int(float(r["MainDirectionPositions"])) + int(float(r["DefenseHedgePositions"]))
              for r in rows if num(r["MainDirectionPositions"]) is not None), default=None)
    legs = [num(r["ProfitYen"]) for r in clo]
    legs = [x for x in legs if x is not None]
    leg_sum = sum(legs) if legs else None
    fpl = num(b["final_pl"])
    if leg_sum is not None and fpl is not None:
        if abs(leg_sum - fpl) < 1.0:
            pl_match += 1
        else:
            pl_mismatch += 1
    gross = sum(abs(x) for x in legs) if legs else None
    hs_margins = [num(r["MarginLevel"]) for r in clo if r["EventType"] == "HARDSTOP_CLOSE"]
    hs_margins = [m for m in hs_margins if m is not None and m < 999999]
    hedge_margins = [num(r["MarginLevel"]) for r in hed]
    hedge_margins = [m for m in hedge_margins if m is not None and m < 999999]
    agg_rows.append({
        "basket_id": bid, "sample_type": b["sample_type"], "close_reason": b["close_reason"],
        "final_pl": b["final_pl"],
        "entry_rows": len(ent), "hedge_rows": len(hed), "close_rows": len(clo),
        "max_concurrent_positions": mp if mp is not None else "NA_NO_ASSIGNED_ROWS",
        "leg_pl_sum": f"{leg_sum:.0f}" if leg_sum is not None else "NA",
        "gross_leg_abs_sum": f"{gross:.0f}" if gross is not None else "NA",
        "gross_to_net_ratio": f"{gross/abs(fpl):.2f}" if (gross and fpl) else "NA",
        "margin_at_hs_min": f"{min(hs_margins):.1f}" if hs_margins else "NA",
        "margin_at_hedge_min": f"{min(hedge_margins):.1f}" if hedge_margins else "NA",
        "open_time_gate": "EXACT" if len(ent) == 1 else "INTERVAL_ONLY"})
with (OUT / "audit2_axisA_position_level.csv").open("w", encoding="utf-8", newline="") as fh:
    hdr = list(agg_rows[0].keys())
    wr = csv.DictWriter(fh, fieldnames=hdr)
    wr.writeheader()
    wr.writerows(agg_rows)
print(f"wrote audit2_axisA_position_level.csv: {len(agg_rows)} rows")
print(f"leg-sum vs final_pl: match={pl_match} mismatch={pl_mismatch} "
      f"(no-close/DEINIT etc: {len(agg_rows)-pl_match-pl_mismatch})")

# ---- 4) HardStop profit-offset decomposition ----
print(f"\nGlobal maxima over ALL {len(deals)} events: "
      f"MainDirectionPositions={md_max}, DefenseHedgePositions={dh_max}, combined={tot_max}")
print(f"OrderLots distinct values on ENTRY/HEDGE/CLOSE: {lots}")

hs_rows = [r for r in agg_rows if r["close_reason"] == "HardStop"]
hedged_hs = [r for r in hs_rows if r["hedge_rows"] != 0 or r["close_rows"] == 2]
nonhedged_hs = [r for r in hs_rows if r not in hedged_hs]
def med(rows, k):
    xs = [num(r[k]) for r in rows]
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None
print(f"\nHardStop decomposition (n={len(hs_rows)}):")
for lbl, grp in (("hedged", hedged_hs), ("non-hedged", nonhedged_hs)):
    g, n_, m = med(grp, "gross_leg_abs_sum"), med(grp, "final_pl"), med(grp, "margin_at_hs_min")
    r_ = med(grp, "gross_to_net_ratio")
    print(f"  {lbl:>10} n={len(grp)}: gross_leg_med={g and round(g)} net_med={n_ and round(n_)} "
          f"gross/net_med={r_ and round(r_,1)} margin@HS_med={m and round(m)}")

marg_all = [num(r["MarginLevel"]) for r in deals]
marg_all = [m for m in marg_all if m is not None and m < 999999]
print(f"\nReal MarginLevel (all events, excl. 999999 no-position sentinel): "
      f"n={len(marg_all)} min={min(marg_all):.1f}% median={st.median(marg_all):.0f}%")
