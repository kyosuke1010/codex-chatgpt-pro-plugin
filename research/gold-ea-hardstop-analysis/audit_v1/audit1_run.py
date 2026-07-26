#!/usr/bin/env python3
"""Audit 1 (Precursor Precision / Break-even) — v2 (pre/post-hedge split, denom=43).

Per Spec §1 + user refinements:
- HardStop denominator = ALL HardStop baskets (43; in6run 37 / june_post 6 / pooled 43).
- Split fires pre/post-hedge (fire_time vs hedges.hedge_time). Main calc uses
  PRE-hedge fires only (fidelity to the 'pre-hedge slope' definition; not a new
  condition). Post-hedge fires go to a reference table.
- Add fires/hour (dwell-time normalized) and Uncovered HardStop Profile.
- 3 groups (SIG-MA / SIG-RD / both), individual LOW_N, SIG-SLP descriptive-only.
- 3 scopes (in6run / june_post / pooled); only in6run is in-sample.

DATA STATE: v1.3 is now the authoritative snapshot source (extraction_bundle_v1_3).
Its corrected join (basket_uid base GOLD#start_token#sequence) maps SELL_NET#1
pre-hedge AND HEDGED#2 snapshots to the same v1 basket_id. Verified against the
v1.3 report: coverage 526/526 (in6run 442/442, june_post 84/84, zero uncovered),
SIG-RD=148 baskets, SIG-SLP=526 baskets, SIG-MA(v1.1)=33, SIG-MA n SIG-RD=24.
Because HEDGED#2 snapshots now link, a basket can carry BOTH pre- and post-hedge
fires; the pre/post-hedge split (below) keeps the main calc on PRE-hedge fires only
(fidelity to the original 'pre-hedge slope' definition). These results REPLACE the
prior PROVISIONAL_PENDING_V1_3 Audit 1 output.
"""

import csv
import statistics as st
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
EXT = REPO / "input_artifacts" / "extraction_bundle_v1" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis" / "audit_v1" / "audit_v1_deliverable_skeletons"
OUT.mkdir(parents=True, exist_ok=True)
LOW_N = 10


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


baskets = {r["basket_id"]: r for r in L("baskets.csv")}
hardstops = L("hardstops.csv")
hs_by_id = {r["basket_id"]: r for r in hardstops}
hedge_time = {r["basket_id"]: pt(r["hedge_time"]) for r in L("hedges.csv")}
sig_ma = [r for r in L("signals_derived.csv") if r["signal_id"] == "SIG-MA"]
v3 = L("signals_derived_v1_3.csv")   # authoritative snapshot source (corrected join)
sig_rd = [r for r in v3 if r["signal_id"] == "SIG-RD"]
sig_slp = [r for r in v3 if r["signal_id"] == "SIG-SLP"]


def phase(fire_row):
    """pre_hedge if basket never hedged OR fire before hedge_time; else post_hedge."""
    ht = hedge_time.get(fire_row["basket_id"])
    t = pt(fire_row["fire_time"])
    if ht is None:
        return "pre"
    if t is None:
        return "unknown"
    return "pre" if t < ht else "post"


def split_fires(rows):
    pre, post = [], []
    for r in rows:
        (pre if phase(r) == "pre" else post).append(r)
    return pre, post


ma_pre, ma_post = split_fires(sig_ma)
rd_pre, rd_post = split_fires(sig_rd)


def earliest(rows):
    out = {}
    for r in rows:
        t = pt(r["fire_time"])
        k = r["basket_id"]
        if k not in out or (t and out[k][0] and t < out[k][0]):
            out[k] = (t, num(r["basket_pl_at_fire"]))
    return out


ma_fire, rd_fire = earliest(ma_pre), earliest(rd_pre)
ma_ids = {r["basket_id"] for r in ma_pre}
rd_ids = {r["basket_id"] for r in rd_pre}

SCOPES = {"in6run": {"in6run"}, "june_post": {"june_post"}, "pooled": {"in6run", "june_post"}}
GROUPS = ["SIG-MA", "SIG-RD", "SIG-MA_AND_SIG-RD"]
TAG = {"in6run": "in-sample diagnostic only", "june_post": "june post-sample (NOT in-sample)",
       "pooled": "in-sample + june post-sample pooled (NOT in-sample only)"}


def dwell_h(bid):
    b = baskets.get(bid, {})
    o, c = pt(b.get("open_time")), pt(b.get("close_time"))
    if o and c and c > o:
        return (c - o).total_seconds() / 3600.0
    return None


rows_out, post_ref = [], []
for scope, sts in SCOPES.items():
    scope_ids = {bid for bid, b in baskets.items() if b["sample_type"] in sts}
    hs_ids = {bid for bid in scope_ids if baskets[bid]["close_reason"] == "HardStop"}
    n_hs = len(hs_ids)   # denominator = ALL HardStop in scope (43/37/6)
    for g in GROUPS:
        if g == "SIG-MA_AND_SIG-RD":
            members = (ma_ids & rd_ids)
        elif g == "SIG-MA":
            members = set(ma_ids)
        else:
            members = set(rd_ids)
        members &= scope_ids
        tp = members & hs_ids
        fp = members - hs_ids
        recall = len(tp) / n_hs if n_hs else None
        precision = len(tp) / len(members) if members else None
        leads, S_terms, fph = [], [], []
        for i in tp:
            fires = [f for f in (ma_fire.get(i) if "MA" in g else None,
                                 rd_fire.get(i) if "RD" in g else None) if f and f[0]]
            if fires:
                ft, pl = min(fires, key=lambda x: x[0])
                hst = pt((hs_by_id.get(i) or {}).get("hs_time"))
                hsl = num((hs_by_id.get(i) or {}).get("hs_loss"))
                if ft and hst:
                    leads.append((hst - ft).total_seconds() / 60.0)
                if hsl is not None and pl is not None:
                    S_terms.append(hsl - pl)
            dh = dwell_h(i)
            if dh:
                cnt = sum(1 for r in (ma_pre if "MA" in g else []) + (rd_pre if "RD" in g else []) if r["basket_id"] == i)
                fph.append(cnt / dh)
        by_reason = {"BasketClose": [], "HTE": [], "RecoveryClose": []}
        C_terms = []
        for i in fp:
            fpl = num(baskets[i].get("final_pl"))
            if fpl is None:
                continue
            C_terms.append(fpl)
            r = baskets[i].get("close_reason", "")
            if r in by_reason:
                by_reason[r].append(fpl)
        S = st.mean(S_terms) if S_terms else None
        C = st.mean(C_terms) if C_terms else None
        p_star = (C / (C + S)) if (S is not None and C is not None and (C + S) != 0) else None
        margin = (precision - p_star) if (precision is not None and p_star is not None) else None
        rows_out.append({
            "scope": scope, "signal_group": g, "fire_phase": "PRE_HEDGE_ONLY",
            "fired_n": len(members), "tp_n": len(tp), "fp_n": len(fp), "hardstop_denom_all": n_hs,
            "recall": f"{recall:.4f}" if recall is not None else "NA",
            "precision": f"{precision:.4f}" if precision is not None else "NA",
            "fires_per_hour_median": f"{pctl(fph,0.5):.3f}" if fph else "NA",
            "lead_median_min": f"{pctl(leads,0.5):.1f}" if leads else "NA",
            "lead_min_min": f"{min(leads):.1f}" if leads else "NA",
            "lead_max_min": f"{max(leads):.1f}" if leads else "NA",
            "S_mean_derisk_upperbound": f"{S:.1f}" if S is not None else "NA",
            "C_mean_fp_final_pl": f"{C:.1f}" if C is not None else "NA",
            "C_by_BasketClose": f"{st.mean(by_reason['BasketClose']):.1f}" if by_reason["BasketClose"] else "NA",
            "C_by_HTE": f"{st.mean(by_reason['HTE']):.1f}" if by_reason["HTE"] else "NA",
            "p_star": f"{p_star:.4f}" if p_star is not None else "NA",
            "precision_margin": f"{margin:.4f}" if margin is not None else "NA",
            "low_n_flag": "LOW_N" if len(tp) < LOW_N else "",
            "S_note": "S=theoretical full-derisk upper bound; NOT a Close-Priority/Hedge counterfactual",
            "provisional_status": "V1_3_AUTHORITATIVE", "scope_tag": TAG[scope]})
    # SIG-SLP descriptive-only (pre-hedge)
    slp_pre, _ = split_fires([r for r in sig_slp if r["basket_id"] in scope_ids])
    slp_pl = [num(r["basket_pl_at_fire"]) for r in slp_pre if num(r["basket_pl_at_fire"]) is not None]
    rows_out.append({"scope": scope, "signal_group": "SIG-SLP_DESCRIPTIVE_ONLY",
                     "fire_phase": "PRE_HEDGE_ONLY", "fired_n": len({r["basket_id"] for r in slp_pre}),
                     "tp_n": "NA", "fp_n": "NA", "hardstop_denom_all": n_hs,
                     "recall": "NA_DESCRIPTIVE_ONLY", "precision": "NA_DESCRIPTIVE_ONLY",
                     "lead_median_min": f"pl_at_fire_p50={pctl(slp_pl,0.5):.1f}" if slp_pl else "NA",
                     "S_note": "descriptive only; threshold re-test forbidden (0.05/min frozen)",
                     "provisional_status": "V1_3_AUTHORITATIVE", "scope_tag": TAG[scope]})

hdr = ["scope", "signal_group", "fire_phase", "fired_n", "tp_n", "fp_n", "hardstop_denom_all",
       "recall", "precision", "fires_per_hour_median", "lead_median_min", "lead_min_min",
       "lead_max_min", "S_mean_derisk_upperbound", "C_mean_fp_final_pl", "C_by_BasketClose",
       "C_by_HTE", "p_star", "precision_margin", "low_n_flag", "S_note",
       "provisional_status", "scope_tag"]
w("audit1_precursor_precision.csv", hdr, rows_out)

# ---- post-hedge reference table ----
for g, pre, post in (("SIG-MA", ma_pre, ma_post), ("SIG-RD", rd_pre, rd_post)):
    for scope, sts in SCOPES.items():
        sids = {bid for bid, b in baskets.items() if b["sample_type"] in sts}
        pre_n = len({r["basket_id"] for r in pre if r["basket_id"] in sids})
        post_n = len({r["basket_id"] for r in post if r["basket_id"] in sids})
        post_ref.append({"scope": scope, "signal_group": g,
                         "pre_hedge_fired_baskets": pre_n, "post_hedge_fired_baskets": post_n,
                         "note": "post-hedge fires excluded from main calc (fidelity to pre-hedge slope def)"})
w("audit1_posthedge_reference.csv",
  ["scope", "signal_group", "pre_hedge_fired_baskets", "post_hedge_fired_baskets", "note"], post_ref)

# ---- Uncovered HardStop Profile (no pre-hedge SIG-MA/RD/SLP fire) ----
slp_ids = {r["basket_id"] for r in sig_slp}
covered = ma_ids | rd_ids | slp_ids
unc_rows = []
for scope, sts in SCOPES.items():
    hs_ids = {bid for bid, b in baskets.items() if b["sample_type"] in sts and b["close_reason"] == "HardStop"}
    unc = hs_ids - covered
    hed = sum(1 for i in unc if (hs_by_id.get(i) or {}).get("hedged_flag") == "1")
    losses = [num((hs_by_id.get(i) or {}).get("hs_loss")) for i in unc]
    losses = [x for x in losses if x is not None]
    durs = []
    for i in unc:
        o, c = pt(baskets[i].get("open_time")), pt((hs_by_id.get(i) or {}).get("hs_time"))
        if o and c:
            durs.append((c - o).total_seconds() / 60.0)
    unc_rows.append({"scope": scope, "uncovered_hardstops": len(unc), "of_total_hardstops": len(hs_ids),
                     "hedged": hed, "non_hedged": len(unc) - hed,
                     "hs_loss_median": f"{st.median(losses):.0f}" if losses else "NA",
                     "entry_to_hs_min_median": f"{st.median(durs):.1f}" if durs else "NA",
                     "note": "HardStops with no pre-hedge SIG-MA/RD/SLP fire (coverage gap)"})
w("audit1_uncovered_hardstop_profile.csv",
  ["scope", "uncovered_hardstops", "of_total_hardstops", "hedged", "non_hedged",
   "hs_loss_median", "entry_to_hs_min_median", "note"], unc_rows)

print("\n=== Audit 1 v2 (PRE-HEDGE main, denom=ALL HardStop) ===")
for r in rows_out:
    if r["signal_group"] == "SIG-SLP_DESCRIPTIVE_ONLY":
        continue
    print(f"  [{r['scope']:>9}] {r['signal_group']:<18} fired={r['fired_n']:>3} tp={r['tp_n']:>2}/{r['hardstop_denom_all']:<2} "
          f"recall={r['recall']:>7} prec={r['precision']:>7} fph={r['fires_per_hour_median']:>7} {r['low_n_flag']}")
print("Uncovered HardStop Profile:")
for r in unc_rows:
    print(f"  [{r['scope']:>9}] uncovered={r['uncovered_hardstops']}/{r['of_total_hardstops']} "
          f"(hedged={r['hedged']},non={r['non_hedged']}) hs_loss_med={r['hs_loss_median']}")
print("Observed counts (v1.3): SIG-MA=%d SIG-RD_pre=%d both_pre=%d SIG-SLP_baskets=%d | report: RD148/SLP526/MAnRD24/cov526"
      % (len(ma_ids), len(rd_ids), len(ma_ids & rd_ids), len(slp_ids)))
