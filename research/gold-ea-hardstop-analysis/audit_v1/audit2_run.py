#!/usr/bin/env python3
"""Audit 2 (Exposure Amplification) — BASKET-LEVEL PROXY ONLY.

position-level exposure amplification は EVIDENCE_UNAVAILABLE として固定
(entries.position_pl_final = 0/526)。未取得値を0扱いしない。

さらにこの bundle では、basket-level の直接 exposure 列も MISSING:
  baskets.csv: max_positions / total_entries / max_lot_sum = 0/526
  hardstops.csv: positions_at_hs / lot_sum_at_hs = 0/43
そして snapshot 由来の positions_at_fire / lot_sum_at_fire / hedge_lot は
DEGENERATE CONSTANT(全て 1 / 0.01。SHADOW は SELL_NET#1 root のみ記録し
grid を集約しない)→ grid/lot 増幅の識別力は 0。

したがって「add-entry / lot amplification」の直接指標は算出不能。
本 Audit は、実変動が残る列だけで **構造的偏り** を診断する:
  final_pl / hs_loss / basket duration / hedge_fired / hedged_flag /
  basket_pl_at_hedge / margin_level_at_hedge / post_hedge_max_recovery_pl /
  SIG-RD fire有無・lead / scope(june|in6run)。
個別 entry が損失を増幅した、とは断定しない。
"""

import csv
import statistics as st
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
EXT = REPO / "input_artifacts" / "extraction_bundle_v1" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis" / "audit_v1" / "audit_v1_deliverable_skeletons"
OUT.mkdir(parents=True, exist_ok=True)


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


def desc(xs):
    xs = [x for x in xs if x is not None]
    if not xs:
        return {"n": 0, "median": None, "mean": None, "min": None, "max": None}
    s = sorted(xs)
    return {"n": len(xs), "median": st.median(s), "mean": st.mean(s),
            "min": s[0], "max": s[-1]}


def f(x, d=1):
    return f"{x:.{d}f}" if x is not None else "NA"


baskets = L("baskets.csv")
b_by_id = {r["basket_id"]: r for r in baskets}
hs_by_id = {r["basket_id"]: r for r in L("hardstops.csv")}
hedges = {r["basket_id"]: r for r in L("hedges.csv")}
v3 = L("signals_derived_v1_3.csv")
rd_ids = {r["basket_id"] for r in v3 if r["signal_id"] == "SIG-RD"}
rd_fire = {}
for r in v3:
    if r["signal_id"] != "SIG-RD":
        continue
    t = pt(r["fire_time"])
    k = r["basket_id"]
    if k not in rd_fire or (t and rd_fire[k] and t < rd_fire[k]):
        rd_fire[k] = t


def dur_h(bid):
    b = b_by_id[bid]
    o, c = pt(b.get("open_time")), pt(b.get("close_time"))
    return (c - o).total_seconds() / 3600.0 if (o and c and c > o) else None


SCOPES = {"in6run": {"in6run"}, "june_post": {"june_post"}, "pooled": {"in6run", "june_post"}}
MISSING_DIRECT = ["max_positions", "total_entries", "max_lot_sum",
                  "positions_at_hs", "lot_sum_at_hs", "position_pl_final"]

# ---------------------------------------------------------------------------
# 1) HardStop vs Non-HardStop structural comparison (per scope)
# ---------------------------------------------------------------------------
proxy_rows = []
for scope, sts in SCOPES.items():
    ids = [bid for bid, b in b_by_id.items() if b["sample_type"] in sts]
    hs = [bid for bid in ids if b_by_id[bid]["close_reason"] == "HardStop"]
    nhs = [bid for bid in ids if b_by_id[bid]["close_reason"] != "HardStop"]
    for label, grp in (("HardStop", hs), ("Non_HardStop", nhs)):
        finals = [num(b_by_id[i]["final_pl"]) for i in grp]
        durs = [dur_h(i) for i in grp]
        hedged = sum(1 for i in grp if b_by_id[i].get("hedge_fired") == "1"
                     or i in hedges)
        rd_cnt = sum(1 for i in grp if i in rd_ids)
        fd, dd = desc(finals), desc(durs)
        proxy_rows.append({
            "scope": scope, "group": label, "n": len(grp),
            "final_pl_median": f(fd["median"]), "final_pl_mean": f(fd["mean"]),
            "final_pl_min": f(fd["min"]), "final_pl_max": f(fd["max"]),
            "duration_h_median": f(dd["median"], 2), "duration_h_max": f(dd["max"], 2),
            "hedged_n": hedged, "hedged_rate": f(hedged / len(grp), 3) if grp else "NA",
            "sig_rd_n": rd_cnt, "sig_rd_rate": f(rd_cnt / len(grp), 3) if grp else "NA",
            "note": "basket-level structural proxy; NOT position/lot exposure"})

# ---------------------------------------------------------------------------
# 2) Hedged HardStop vs Non-Hedged HardStop
# ---------------------------------------------------------------------------
hedge_rows = []
for scope, sts in SCOPES.items():
    hs = [bid for bid, b in b_by_id.items()
          if b["sample_type"] in sts and b["close_reason"] == "HardStop"]
    for label, cond in (("Hedged_HS", True), ("NonHedged_HS", False)):
        grp = [i for i in hs if (i in hedges) == cond]
        hs_losses = [num((hs_by_id.get(i) or {}).get("hs_loss")) for i in grp]
        durs = [dur_h(i) for i in grp]
        pl_at_hedge = [num((hedges.get(i) or {}).get("basket_pl_at_hedge")) for i in grp]
        # margin_level_at_hedge is a literal 0.00 placeholder for all 48 rows
        # (impossible real margin) -> treat as EVIDENCE_UNAVAILABLE, never as 0%.
        marg = [m for m in (num((hedges.get(i) or {}).get("margin_level_at_hedge")) for i in grp)
                if m not in (None, 0.0)]
        rec = [num((hedges.get(i) or {}).get("post_hedge_max_recovery_pl")) for i in grp]
        rd_cnt = sum(1 for i in grp if i in rd_ids)
        hl, dd = desc(hs_losses), desc(durs)
        ph, mg, rc = desc(pl_at_hedge), desc(marg), desc(rec)
        hedge_rows.append({
            "scope": scope, "group": label, "n": len(grp),
            "hs_loss_median": f(hl["median"]), "hs_loss_min": f(hl["min"]),
            "duration_h_median": f(dd["median"], 2),
            "basket_pl_at_hedge_median": f(ph["median"]) if ph["n"] else "NA_no_hedge_row",
            "margin_at_hedge_median": f(mg["median"]) if mg["n"] else "NA_PLACEHOLDER_0.00",
            "post_hedge_max_recovery_median": f(rc["median"]) if rc["n"] else "NA_no_hedge_row",
            "sig_rd_n": rd_cnt, "sig_rd_rate": f(rd_cnt / len(grp), 3) if grp else "NA",
            "low_n_flag": "LOW_N" if len(grp) < 10 else "",
            "note": "hedge fields present; distance_to_hs_price MISSING -> timing NOT_COMPUTABLE"})

# ---------------------------------------------------------------------------
# 3) SIG-RD present vs absent — structural proxy diff
# ---------------------------------------------------------------------------
sigrd_rows = []
for scope, sts in SCOPES.items():
    ids = [bid for bid, b in b_by_id.items() if b["sample_type"] in sts]
    for label, cond in (("SIG-RD_present", True), ("SIG-RD_absent", False)):
        grp = [i for i in ids if (i in rd_ids) == cond]
        finals = [num(b_by_id[i]["final_pl"]) for i in grp]
        durs = [dur_h(i) for i in grp]
        hs_rate = sum(1 for i in grp if b_by_id[i]["close_reason"] == "HardStop")
        leads = []
        for i in grp:
            ft = rd_fire.get(i)
            hst = pt((hs_by_id.get(i) or {}).get("hs_time"))
            if ft and hst:
                leads.append((hst - ft).total_seconds() / 60.0)
        fd, dd, ld = desc(finals), desc(durs), desc(leads)
        sigrd_rows.append({
            "scope": scope, "group": label, "n": len(grp),
            "final_pl_median": f(fd["median"]), "final_pl_min": f(fd["min"]),
            "duration_h_median": f(dd["median"], 2), "duration_h_max": f(dd["max"], 2),
            "hardstop_n": hs_rate, "hardstop_rate": f(hs_rate / len(grp), 3) if grp else "NA",
            "sig_rd_to_hs_lead_min_median": f(ld["median"]) if ld["n"] else "NA",
            "note": "duration = exposure-time proxy; SIG-RD baskets stay open longer?"})

# ---------------------------------------------------------------------------
# write CSV (all proxy tables stacked with a table_id column)
# ---------------------------------------------------------------------------
hdr = ["table_id", "scope", "group", "n", "final_pl_median", "final_pl_mean",
       "final_pl_min", "final_pl_max", "duration_h_median", "duration_h_max",
       "hedged_n", "hedged_rate", "sig_rd_n", "sig_rd_rate",
       "hs_loss_median", "hs_loss_min", "basket_pl_at_hedge_median",
       "margin_at_hedge_median", "post_hedge_max_recovery_median",
       "hardstop_n", "hardstop_rate", "sig_rd_to_hs_lead_min_median",
       "low_n_flag", "note"]
allrows = ([dict(r, table_id="1_HS_vs_NonHS") for r in proxy_rows] +
           [dict(r, table_id="2_Hedged_vs_NonHedged_HS") for r in hedge_rows] +
           [dict(r, table_id="3_SIGRD_present_vs_absent") for r in sigrd_rows])
with (OUT / "audit2_basket_level_exposure_proxy.csv").open("w", encoding="utf-8", newline="") as fh:
    wr = csv.DictWriter(fh, fieldnames=hdr, extrasaction="ignore")
    wr.writeheader()
    for r in allrows:
        wr.writerow({k: r.get(k, "") for k in hdr})
print(f"wrote audit2_basket_level_exposure_proxy.csv: {len(allrows)} rows")

# EVIDENCE_UNAVAILABLE ledger
print("\n=== DIRECT exposure columns (EVIDENCE_UNAVAILABLE) ===")
for c in MISSING_DIRECT:
    src = "baskets.csv" if c in ("max_positions", "total_entries", "max_lot_sum") else \
          "hardstops.csv" if "_at_hs" in c else "entries.csv"
    rows = L(src)
    p = sum(1 for r in rows if str(r.get(c, "")).strip() not in ("", "MISSING"))
    print(f"  {c} ({src}): present {p}/{len(rows)} -> EVIDENCE_UNAVAILABLE")
print("  positions_at_fire/lot_sum_at_fire/hedge_lot: DEGENERATE CONSTANT (1 / 0.01)")

print("\n=== Table 1: HardStop vs Non-HardStop ===")
for r in proxy_rows:
    print(f"  [{r['scope']:>9}] {r['group']:<13} n={r['n']:>3} "
          f"final_pl_med={r['final_pl_median']:>8} dur_h_med={r['duration_h_median']:>7} "
          f"hedged={r['hedged_rate']:>5} sig_rd={r['sig_rd_rate']:>5}")
print("\n=== Table 2: Hedged vs Non-Hedged HardStop ===")
for r in hedge_rows:
    print(f"  [{r['scope']:>9}] {r['group']:<13} n={r['n']:>2} hs_loss_med={r['hs_loss_median']:>8} "
          f"dur_h_med={r['duration_h_median']:>7} pl@hedge_med={r['basket_pl_at_hedge_median']:>10} "
          f"marg@hedge={r['margin_at_hedge_median']:>8} sig_rd={r['sig_rd_rate']:>5} {r['low_n_flag']}")
print("\n=== Table 3: SIG-RD present vs absent ===")
for r in sigrd_rows:
    print(f"  [{r['scope']:>9}] {r['group']:<15} n={r['n']:>3} final_pl_med={r['final_pl_median']:>8} "
          f"dur_h_med={r['duration_h_median']:>7} dur_h_max={r['duration_h_max']:>8} "
          f"hs_rate={r['hardstop_rate']:>5}")
