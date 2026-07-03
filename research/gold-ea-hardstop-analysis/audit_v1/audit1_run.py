#!/usr/bin/env python3
"""Audit 1 (Precursor Precision / Break-even) — bundle-specific runner.

Per Analysis & Judgment Spec v1.0 §1 + audit1_signal_config.md (v1.2), and the
user decision to output THREE scopes: in6run (in-sample), june_post, pooled.

Bundle actual layout (SHA-verified, all 3 zips match pins):
  v1   : baskets/entries/hedges/hardstops/basketclose_winners/equity_curve + report
  v1.1 : signals_derived.csv (SIG-MA, offline_recompute_barclose) + price_m5
  v1.2 : signals_derived_v1_2.csv (SIG-RD, SIG-SLP, offline_recompute_snapshot)
Columns: signal_id / basket_id / fire_time / basket_pl_at_fire / sample_type.

Scope denominator = SIG-SLP-covered baskets (513); the 13 excluded baskets are
exactly the 13 HardStops without pre-hedge snapshot coverage (in6run 7 + june 6),
removed from the denominator per config. All outputs tagged per-scope; only the
in6run scope is 'in-sample diagnostic only'. No OOS/live/150k claim. EA untouched.
"""

import csv
import statistics as st
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
EXT = REPO / "input_artifacts" / "extraction_bundle_v1" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis" / "audit_v1"
LOW_N = 10


def load(name):
    hits = [p for p in EXT.rglob(name) if p.is_file()]
    if not hits:
        raise SystemExit(f"missing {name}")
    return list(csv.DictReader(hits[0].open(encoding="utf-8-sig", errors="replace")))


def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def pt(s):
    s = (s or "").strip().replace("T", " ").replace(".", "-", 2)[:19]
    for f in ("%Y-%m-%d %H:%M:%S",):
        try:
            return datetime.strptime(s, f)
        except ValueError:
            pass
    return None


def pctl(xs, q):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(q * len(xs)))] if xs else None


baskets = load("baskets.csv")
hardstops = load("hardstops.csv")
sig_ma = [r for r in load("signals_derived.csv") if r["signal_id"] == "SIG-MA"]
sig_v2 = load("signals_derived_v1_2.csv")
sig_rd = [r for r in sig_v2 if r["signal_id"] == "SIG-RD"]
sig_slp = [r for r in sig_v2 if r["signal_id"] == "SIG-SLP"]

basket = {r["basket_id"]: r for r in baskets}
hs_by_id = {r["basket_id"]: r for r in hardstops}
slp_ids = {r["basket_id"] for r in sig_slp}  # scoped = 513


def earliest_fire(rows):
    """{basket_id: (fire_time, basket_pl_at_fire)} earliest per basket."""
    out = {}
    for r in rows:
        t = pt(r["fire_time"])
        k = r["basket_id"]
        if k not in out or (t and out[k][0] and t < out[k][0]):
            out[k] = (t, num(r["basket_pl_at_fire"]))
    return out


ma_fire, rd_fire = earliest_fire(sig_ma), earliest_fire(sig_rd)
ma_ids = {r["basket_id"] for r in sig_ma}
rd_ids = {r["basket_id"] for r in sig_rd}

SCOPES = {"in6run": {"in6run"}, "june_post": {"june_post"},
          "pooled": {"in6run", "june_post"}}
GROUPS = {"SIG-MA": ("ma",), "SIG-RD": ("rd",), "SIG-MA_AND_SIG-RD": ("ma", "rd")}
TAG = {"in6run": "in-sample diagnostic only", "june_post": "june post-sample (NOT in-sample)",
       "pooled": "in-sample + june post-sample pooled (NOT in-sample only)"}

rows_out = []
for scope, sts in SCOPES.items():
    scope_ids = {b["basket_id"] for b in baskets if b["sample_type"] in sts}
    scoped = scope_ids & slp_ids                      # exclude the coverage-missing 13
    hs_scoped = {i for i in scoped if basket[i]["close_reason"] == "HardStop"}
    n_hs = len(hs_scoped)
    for gname, parts in GROUPS.items():
        members = set()
        if "ma" in parts and "rd" in parts:
            members = (ma_ids & rd_ids)
        elif "ma" in parts:
            members = set(ma_ids)
        else:
            members = set(rd_ids)
        members &= scoped
        tp = members & hs_scoped
        fp = members - hs_scoped
        recall = len(tp) / n_hs if n_hs else None
        precision = len(tp) / len(members) if members else None
        leads, S_terms = [], []
        for i in tp:
            fires = [f for f in (ma_fire.get(i) if "ma" in parts else None,
                                 rd_fire.get(i) if "rd" in parts else None) if f and f[0]]
            if not fires:
                continue
            ft, pl = min(fires, key=lambda x: x[0])
            hst = pt((hs_by_id.get(i) or {}).get("hs_time"))
            hsl = num((hs_by_id.get(i) or {}).get("hs_loss"))
            if ft and hst:
                leads.append((hst - ft).total_seconds() / 60.0)
            if hsl is not None and pl is not None:
                S_terms.append(hsl - pl)
        by_reason = {"BasketClose": [], "HTE": [], "RecoveryClose": []}
        C_terms = []
        for i in fp:
            fpl = num(basket[i].get("final_pl"))
            if fpl is None:
                continue
            C_terms.append(fpl)
            r = basket[i].get("close_reason", "")
            if r in by_reason:
                by_reason[r].append(fpl)
        S = st.mean(S_terms) if S_terms else None
        C = st.mean(C_terms) if C_terms else None
        p_star = (C / (C + S)) if (S is not None and C is not None and (C + S) != 0) else None
        margin = (precision - p_star) if (precision is not None and p_star is not None) else None
        rows_out.append({
            "scope": scope, "signal_group": gname,
            "fired_scoped_n": len(members), "tp_n": len(tp), "fp_n": len(fp),
            "hardstop_scoped_denom": n_hs,
            "recall": f"{recall:.4f}" if recall is not None else "NA",
            "precision": f"{precision:.4f}" if precision is not None else "NA",
            "lead_min_min": f"{min(leads):.1f}" if leads else "NA",
            "lead_p25": f"{pctl(leads,0.25):.1f}" if leads else "NA",
            "lead_median": f"{pctl(leads,0.5):.1f}" if leads else "NA",
            "lead_p75": f"{pctl(leads,0.75):.1f}" if leads else "NA",
            "lead_max": f"{max(leads):.1f}" if leads else "NA",
            "S_mean_derisk_upperbound": f"{S:.1f}" if S is not None else "NA",
            "C_mean_fp_final_pl": f"{C:.1f}" if C is not None else "NA",
            "C_by_BasketClose": f"{st.mean(by_reason['BasketClose']):.1f}" if by_reason["BasketClose"] else "NA",
            "C_by_HTE": f"{st.mean(by_reason['HTE']):.1f}" if by_reason["HTE"] else "NA",
            "C_by_RecoveryClose": f"{st.mean(by_reason['RecoveryClose']):.1f}" if by_reason["RecoveryClose"] else "NA",
            "p_star": f"{p_star:.4f}" if p_star is not None else "NA",
            "precision_margin": f"{margin:.4f}" if margin is not None else "NA",
            "low_n_flag": "LOW_N" if len(tp) < LOW_N else "",
            "S_note": "S=theoretical full-derisk upper bound at first fire; NOT a Close-Priority/Hedge counterfactual",
            "scope_tag": TAG[scope]})
    # SIG-SLP descriptive-only per scope
    slp_scope = [r for r in sig_slp if r["basket_id"] in scoped]
    slp_pl = [num(r["basket_pl_at_fire"]) for r in slp_scope if num(r["basket_pl_at_fire"]) is not None]
    rows_out.append({
        "scope": scope, "signal_group": "SIG-SLP_DESCRIPTIVE_ONLY",
        "fired_scoped_n": len({r["basket_id"] for r in slp_scope}),
        "tp_n": "NA", "fp_n": "NA", "hardstop_scoped_denom": n_hs,
        "recall": "NA_DESCRIPTIVE_ONLY", "precision": "NA_DESCRIPTIVE_ONLY",
        "lead_median": f"{pctl(slp_pl,0.5):.1f}" if slp_pl else "NA",
        "S_note": "descriptive stats only; threshold re-test forbidden (0.05/min frozen)",
        "scope_tag": TAG[scope]})

hdr = ["scope", "signal_group", "fired_scoped_n", "tp_n", "fp_n", "hardstop_scoped_denom",
       "recall", "precision", "lead_min_min", "lead_p25", "lead_median", "lead_p75",
       "lead_max", "S_mean_derisk_upperbound", "C_mean_fp_final_pl", "C_by_BasketClose",
       "C_by_HTE", "C_by_RecoveryClose", "p_star", "precision_margin", "low_n_flag",
       "S_note", "scope_tag"]
(OUT / "audit_v1_deliverable_skeletons").mkdir(parents=True, exist_ok=True)
with (OUT / "audit_v1_deliverable_skeletons" / "audit1_precursor_precision.csv").open("w", encoding="utf-8", newline="") as f:
    wr = csv.DictWriter(f, fieldnames=hdr, extrasaction="ignore")
    wr.writeheader()
    for r in rows_out:
        wr.writerow({k: r.get(k, "") for k in hdr})

print("Audit 1 (3 scopes x 3 groups + SIG-SLP descriptive):")
for r in rows_out:
    if r["signal_group"] == "SIG-SLP_DESCRIPTIVE_ONLY":
        continue
    print(f"  [{r['scope']:>9}] {r['signal_group']:<18} fired={r['fired_scoped_n']:>3} "
          f"tp={r['tp_n']:>2}/{r['hardstop_scoped_denom']:<2} recall={r['recall']:>7} "
          f"prec={r['precision']:>7} p*={r['p_star']:>8} margin={r['precision_margin']:>8} {r['low_n_flag']}")
