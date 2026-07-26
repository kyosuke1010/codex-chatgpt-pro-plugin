#!/usr/bin/env python3
"""Audit v1.0 analysis engine (Claude side) — in-sample diagnostic only.

Implements Analysis & Judgment Spec v1.0 (Capital Buffer x Pre-Hedge Loss-Tail).
Input: extraction_bundle_v1 delivered by Codex into
input_artifacts/extraction_bundle_v1/ (baskets/signals/entries/hedges/hardstops/
basketclose_winners/equity_curve + extraction_report.txt).

§0.5 input validation is a hard gate BEFORE any audit. With no bundle present the
engine writes AWAITING skeletons and stops (no fabrication). Execution order when
data present: Audit 4 -> 1 -> 2 -> 3 -> 5.

All outputs are tagged `in-sample diagnostic only`. No OOS/live/150k-wins claim.
Does not touch July W2. All implementation flags remain false.
"""

import csv
import hashlib
import statistics as st
import zipfile
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
BUNDLE = REPO / "input_artifacts" / "extraction_bundle_v1"
EXT = BUNDLE / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis" / "audit_v1"
TAG = "in-sample diagnostic only"

# Pinned bundle-ZIP SHA256 (from Codex delivery). Placement contract:
# operator drops these ZIPs into input_artifacts/extraction_bundle_v1/.
# v1.2 is authoritative (latest revision); v1 / v1.1 kept for provenance only.
EXPECTED_ZIP_SHA = {
    "extraction_bundle_v1.zip":   "f9f12e6999462ef283e9e2fa511cc511e46fe12f87789acae0822cf5e8ddfb29",
    "extraction_bundle_v1_1.zip": "da8b945e3da0e7aae18fb6a7b1bc8bba7a0e470dfc73931d7962fbcb8de506d6",
    "extraction_bundle_v1_2.zip": "5fe9b038a16e95550f0968a012a003f7c25a629f008733fdcb846cd8f996df46",
}
# authoritative revision (component CSVs read from this one; higher = newer)
ZIP_PRECEDENCE = ["extraction_bundle_v1_2.zip", "extraction_bundle_v1_1.zip", "extraction_bundle_v1.zip"]

# baseline for §0.5.3 close_reason sanity (from prior ingested in-sample)
BASELINE = {"win_rate_approx": 0.89, "hardstop_count_insample": 37, "baskets_insample": 442}
JULY_START = datetime(2026, 7, 1)   # any close_time >= this => contamination
LOW_N = 10  # §1 sample sufficiency (TP n<10)
LOW_N_STRATUM = 5  # §3 stratum

# audit1_signal_config.md (v1.2): coverage + reported SIG-MA/SIG-RD overlap
COVERAGE = {"total": 526, "scoped": 513, "excluded": 13}
REPORTED_OVERLAP = {"SIG-MA": 33, "SIG-RD": 106, "both": 24,
                    "SIG-MA_only": 9, "SIG-RD_only": 82}
# Audit 1 signal groups (SIG-SLP is descriptive-only; no precision/recall, no retune)
AUDIT1_GROUPS = ["SIG-MA", "SIG-RD", "SIG-MA_AND_SIG-RD"]


def sha256(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


# Stage 0: verify + extract pinned ZIPs (if any placed). Authoritative subdir
# = highest-precedence ZIP whose SHA matches. Populated when operator drops ZIPs.
_zip_report, _auth_dir = [], None
if BUNDLE.is_dir():
    present = {p.name: p for p in BUNDLE.iterdir() if p.is_file() and p.suffix.lower() == ".zip"}
    for name in ZIP_PRECEDENCE:
        p = present.get(name)
        if not p:
            continue
        got = sha256(p)
        ok = got == EXPECTED_ZIP_SHA.get(name)
        dest = EXT / p.stem
        if ok:
            try:
                with zipfile.ZipFile(p) as zf:
                    if zf.testzip() is None:
                        zf.extractall(dest)
            except zipfile.BadZipFile:
                ok = False
        _zip_report.append({"zip": name, "sha256": got,
                            "sha_match": ok, "role": ("authoritative" if (ok and _auth_dir is None) else "provenance")})
        if ok and _auth_dir is None:
            _auth_dir = dest


def find(name):
    # prefer the authoritative extracted revision, then any extract, then bundle root
    roots = []
    if _auth_dir is not None:
        roots.append(_auth_dir)
    roots += [EXT, BUNDLE]
    for root in roots:
        if root and root.exists():
            hits = [p for p in root.rglob(name) if p.is_file()]
            if hits:
                return hits[0]
    return None


def load(name):
    p = find(name)
    if not p:
        return None
    return list(csv.DictReader(p.open(encoding="utf-8-sig", errors="replace")))


def w(name, header, rows):
    (OUT / "audit_v1_deliverable_skeletons").mkdir(parents=True, exist_ok=True)
    path = OUT / "audit_v1_deliverable_skeletons" / name
    with path.open("w", encoding="utf-8", newline="") as f:
        wr = csv.DictWriter(f, fieldnames=header, extrasaction="ignore")
        wr.writeheader()
        for r in rows:
            wr.writerow({k: r.get(k, "") for k in header})
    print(f"  wrote {name}: {len(rows)} rows")


def pctl(xs, q):
    xs = sorted(xs)
    if not xs:
        return None
    return xs[min(len(xs) - 1, int(q * len(xs)))]


def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


# ================= §0.5 INPUT VALIDATION (hard gate) =================
report = find("extraction_report.txt")
baskets = load("baskets.csv")
gate = {"extraction_report_present": bool(report),
        "baskets_present": bool(baskets)}

if not report or not baskets:
    # Bundle absent -> AWAITING. Write skeletons only.
    decision = "AWAITING_EXTRACTION_BUNDLE_V1"
    print("§0.5: extraction_bundle_v1 not present -> AWAITING (no analysis run)")
    # deliverable skeletons (headers reflect Spec §1-§5 outputs)
    w("audit1_precursor_precision.csv",
      ["signal_group", "fired_scoped_n", "tp_n", "fp_n", "hardstop_scoped_denom",
       "recall", "precision", "lead_min_min", "lead_p25", "lead_median", "lead_p75",
       "lead_max", "S_mean_derisk_upperbound", "C_mean_fp_final_pl", "C_by_BasketClose",
       "C_by_RecoveryClose", "C_by_HTE", "p_star", "precision_margin", "low_n_flag",
       "S_note", "tag"], [])
    w("audit2_exposure_amplification.csv",
      ["signal_code", "amp_ratio_median", "amp_ratio_p25", "amp_ratio_p75",
       "loss_post_signal_sum", "winner_kill_risk_sum", "winner_kill_risk_mean",
       "suppression_candidate", "tag"], [])
    w("audit3_hedge_stratified.csv",
      ["stratum", "group", "n", "hs_loss_median", "H_minus_N_median", "mw_pvalue",
       "too_late_share", "recovery_room_share", "no_recovery_share",
       "low_n_flag", "tag"], [])
    w("audit4_capital_buffer.csv",
      ["metric", "value_50k", "value_100k", "value_150k", "maxdd_measured",
       "consecutive_hs_max", "cluster_kwindow_max", "runs_test_p",
       "survival_est_150k", "margin_constraint_evidence", "tag"], [])
    w("audit5_winner_extension.csv",
      ["metric", "value", "cap_concentration_380_420", "favorable_1h",
       "favorable_4h", "favorable_24h", "verdict_input", "tag"], [])
    zr = _zip_report or [{"zip": n, "sha256": "NOT_PLACED", "sha_match": "AWAITING", "role": "expected"}
                         for n in ZIP_PRECEDENCE]
    w("audit_v1_zip_sha_report.csv", ["zip", "sha256", "sha_match", "role"], zr)
    w("audit_v1_gate_report.csv", ["check", "status", "detail"],
      [{"check": "zip_sha_verification", "status": "AWAITING" if not _zip_report else "SEE_zip_sha_report",
        "detail": f"placed_zips={[r['zip'] for r in _zip_report]}"},
       {"check": "extraction_report_present", "status": "FAIL_AWAITING", "detail": "no component CSVs found"},
       {"check": "baskets_present", "status": "FAIL_AWAITING", "detail": "no component CSVs found"},
       {"check": "july_contamination_scan", "status": "NOT_RUN", "detail": "needs baskets close_time"},
       {"check": "close_reason_baseline_match", "status": "NOT_RUN",
        "detail": f"baseline win~{BASELINE['win_rate_approx']} hs={BASELINE['hardstop_count_insample']}"}])
    print(f"\n=== DECISION: {decision} ===")
    if _zip_report:
        bad = [r for r in _zip_report if r["sha_match"] is not True]
        print("ZIPs placed but component CSVs not found after extraction.",
              "SHA mismatches:" , [r["zip"] for r in bad] if bad else "none (contents unexpected layout)")
    raise SystemExit(0)

# ---- bundle present: run §0.5 checks ----
gate_rows = []
# ZIP SHA verification (provenance + authoritative selection)
w("audit_v1_zip_sha_report.csv", ["zip", "sha256", "sha_match", "role"],
  _zip_report or [{"zip": "NONE_EXTRACTED_CSVS_PRESENT_DIRECTLY", "sha256": "NA",
                   "sha_match": "NA", "role": "direct_csv_placement"}])
if _zip_report:
    bad_sha = [r["zip"] for r in _zip_report if r["sha_match"] is not True]
    gate_rows.append({"check": "zip_sha_verification",
                      "status": "PASS" if not bad_sha else "FAIL_SHA_MISMATCH",
                      "detail": f"authoritative={_auth_dir.name if _auth_dir else None} mismatches={bad_sha}"})
# July contamination
close_times = []
for b in baskets:
    ct = (b.get("close_time") or "").replace(".", "-")[:19]
    try:
        close_times.append(datetime.strptime(ct, "%Y-%m-%d %H:%M:%S"))
    except ValueError:
        pass
july_hits = sum(1 for t in close_times if t >= JULY_START)
gate_rows.append({"check": "july_contamination_scan",
                  "status": "PASS" if july_hits == 0 else "FAIL_JULY_LEAK",
                  "detail": f"{july_hits} baskets close_time >= 2026-07-01"})
# close_reason distribution
n = len(baskets)
wins = sum(1 for b in baskets if "basket close" in (b.get("close_reason", "").lower()))
hs = sum(1 for b in baskets if "hard" in (b.get("close_reason", "").lower()))
wr_obs = wins / n if n else 0
gate_rows.append({"check": "close_reason_baseline_match",
                  "status": "PASS" if abs(wr_obs - BASELINE["win_rate_approx"]) <= 0.10 else "REVIEW_DEVIATION",
                  "detail": f"win_rate_obs={wr_obs:.3f} hs_count={hs} (baseline ~0.89 / 37)"})

signals = load("signals.csv") or []
sig_codes = sorted({s.get("signal_code", "") for s in signals if s.get("signal_code")})
# §0.5.4 SIG-LSB exclusion if definition unknown
report_txt = report.read_text(encoding="utf-8", errors="replace") if report else ""
lsb_defined = "SIG-LSB" in report_txt and "definition" in report_txt.lower()
active_sigs = [c for c in sig_codes if not (c == "SIG-LSB" and not lsb_defined)]
gate_rows.append({"check": "sig_lsb_definition",
                  "status": "DEFINED" if lsb_defined else "UNKNOWN_EXCLUDED",
                  "detail": f"active_signals={active_sigs}"})

# ---- coverage + SIG-MA/SIG-RD overlap cross-check (audit1_signal_config.md) ----
exclusions = load("exclusions.csv")
excluded_uids = {r.get("basket_uid", "") for r in exclusions} if exclusions else set()
scoped = [b for b in baskets if b.get("basket_uid") not in excluded_uids]
gate_rows.append({"check": "coverage_scoped_denominator",
                  "status": "PASS" if (not exclusions or len(excluded_uids) == COVERAGE["excluded"]) else "REVIEW",
                  "detail": f"scoped={len(scoped)} excluded={len(excluded_uids)} "
                            f"(expected scoped={COVERAGE['scoped']} excluded={COVERAGE['excluded']})"})

fired = {}
for code in ("SIG-MA", "SIG-RD", "SIG-SLP"):
    fired[code] = {s.get("basket_uid") for s in signals
                   if s.get("signal_code") == code and s.get("basket_uid") not in excluded_uids}
obs_overlap = {"SIG-MA": len(fired["SIG-MA"]), "SIG-RD": len(fired["SIG-RD"]),
               "both": len(fired["SIG-MA"] & fired["SIG-RD"]),
               "SIG-MA_only": len(fired["SIG-MA"] - fired["SIG-RD"]),
               "SIG-RD_only": len(fired["SIG-RD"] - fired["SIG-MA"])}
overlap_ok = obs_overlap == REPORTED_OVERLAP
gate_rows.append({"check": "sig_ma_rd_overlap_match",
                  "status": "PASS" if overlap_ok else "REVIEW_DEVIATION",
                  "detail": f"observed={obs_overlap} reported={REPORTED_OVERLAP}"})

w("audit_v1_gate_report.csv", ["check", "status", "detail"], gate_rows)
blocked = any(g["status"].startswith("FAIL") for g in gate_rows)
if blocked:
    print("§0.5 GATE FAILED -> returning to Codex; audits not run")
    print("=== DECISION: RETURN_TO_CODEX_EXTRACTION_DEFECT ===")
    raise SystemExit(0)

# ================= Audit 1: Precursor Precision / Break-even (Spec §1) =================
# scoped HardStop set + per-basket earliest fire time / pl_at_fire per signal
hs_rows = {r.get("basket_uid"): r for r in (load("hardstops.csv") or [])
           if r.get("basket_uid") not in excluded_uids}
hardstop_uids = {b.get("basket_uid") for b in scoped if "hard" in (b.get("close_reason", "").lower())}
n_hs = len(hardstop_uids)
basket_by_uid = {b.get("basket_uid"): b for b in scoped}


def parse_t(s):
    s = (s or "").replace(".", "-")[:19]
    try:
        return datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        return None


# per (basket, signal_code): earliest first_fire_time and its basket_pl_at_fire
fire = {}
for s in signals:
    uid, code = s.get("basket_uid"), s.get("signal_code")
    if uid in excluded_uids or code not in ("SIG-MA", "SIG-RD"):
        continue
    t = parse_t(s.get("first_fire_time"))
    key = (uid, code)
    if key not in fire or (t and fire[key][0] and t < fire[key][0]):
        fire[key] = (t, num(s.get("basket_pl_at_fire")))


def group_members(g):
    if g == "SIG-MA":
        return set(fired["SIG-MA"])
    if g == "SIG-RD":
        return set(fired["SIG-RD"])
    return set(fired["SIG-MA"] & fired["SIG-RD"])


def group_fire(uid, g):
    """earliest fire time + pl_at_fire for the group in a basket (min across signals)."""
    cands = []
    for code in (("SIG-MA", "SIG-RD") if g == "SIG-MA_AND_SIG-RD" else (g,)):
        f = fire.get((uid, code))
        if f and f[0]:
            cands.append(f)
    if not cands:
        return (None, None)
    return min(cands, key=lambda x: x[0])


a1_rows = []
for g in AUDIT1_GROUPS:
    members = group_members(g)
    tp = members & hardstop_uids
    fp = members - hardstop_uids
    recall = len(tp) / n_hs if n_hs else None
    precision = len(tp) / len(members) if members else None
    leads = []
    S_terms = []
    for uid in tp:
        ft, pl = group_fire(uid, g)
        hst = parse_t((hs_rows.get(uid) or {}).get("hs_time"))
        hsl = num((hs_rows.get(uid) or {}).get("hs_loss"))
        if ft and hst:
            leads.append((hst - ft).total_seconds() / 60.0)
        if hsl is not None and pl is not None:
            S_terms.append(hsl - pl)
    fp_by_reason = {"BasketClose": [], "RecoveryClose": [], "HTE": []}
    C_terms = []
    for uid in fp:
        b = basket_by_uid.get(uid, {})
        fpl = num(b.get("final_pl"))
        if fpl is None:
            continue
        C_terms.append(fpl)
        r = (b.get("close_reason", "") or "").lower()
        if "basket close" in r:
            fp_by_reason["BasketClose"].append(fpl)
        elif "recovery" in r:
            fp_by_reason["RecoveryClose"].append(fpl)
        elif "hte" in r:
            fp_by_reason["HTE"].append(fpl)
    S = st.mean(S_terms) if S_terms else None
    C = st.mean(C_terms) if C_terms else None
    p_star = (C / (C + S)) if (S is not None and C is not None and (C + S) != 0) else None
    p_margin = (precision - p_star) if (precision is not None and p_star is not None) else None
    a1_rows.append({
        "signal_group": g, "fired_scoped_n": len(members), "tp_n": len(tp), "fp_n": len(fp),
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
        "C_by_BasketClose": f"{st.mean(fp_by_reason['BasketClose']):.1f}" if fp_by_reason["BasketClose"] else "NA",
        "C_by_RecoveryClose": f"{st.mean(fp_by_reason['RecoveryClose']):.1f}" if fp_by_reason["RecoveryClose"] else "NA",
        "C_by_HTE": f"{st.mean(fp_by_reason['HTE']):.1f}" if fp_by_reason["HTE"] else "NA",
        "p_star": f"{p_star:.4f}" if p_star is not None else "NA",
        "precision_margin": f"{p_margin:.4f}" if p_margin is not None else "NA",
        "low_n_flag": "LOW_N" if len(tp) < LOW_N else "",
        "S_note": "S = theoretical full-derisk upper bound at first fire; NOT a Close-Priority/Hedge counterfactual",
        "tag": TAG})

# SIG-SLP descriptive only (no precision/recall, no threshold retest)
slp = fired["SIG-SLP"]
slp_pl = [num(s.get("basket_pl_at_fire")) for s in signals
          if s.get("signal_code") == "SIG-SLP" and s.get("basket_uid") not in excluded_uids
          and num(s.get("basket_pl_at_fire")) is not None]
a1_rows.append({
    "signal_group": "SIG-SLP_DESCRIPTIVE_ONLY", "fired_scoped_n": len(slp),
    "tp_n": "NA", "fp_n": "NA", "hardstop_scoped_denom": n_hs,
    "recall": "NA_DESCRIPTIVE_ONLY", "precision": "NA_DESCRIPTIVE_ONLY",
    "lead_median": f"{pctl(slp_pl,0.5):.1f}" if slp_pl else "NA",
    "S_note": "descriptive stats only; threshold re-test forbidden (0.05/min frozen)",
    "tag": TAG})

w("audit1_precursor_precision.csv",
  ["signal_group", "fired_scoped_n", "tp_n", "fp_n", "hardstop_scoped_denom",
   "recall", "precision", "lead_min_min", "lead_p25", "lead_median", "lead_p75",
   "lead_max", "S_mean_derisk_upperbound", "C_mean_fp_final_pl", "C_by_BasketClose",
   "C_by_RecoveryClose", "C_by_HTE", "p_star", "precision_margin", "low_n_flag",
   "S_note", "tag"], a1_rows)

print("§0.5 passed. Audit 1 computed (SIG-MA / SIG-RD / SIG-MA∩SIG-RD + SIG-SLP descriptive).")
for r in a1_rows:
    print(f"  {r['signal_group']}: fired={r['fired_scoped_n']} tp={r.get('tp_n')} "
          f"recall={r.get('recall')} precision={r.get('precision')} {r.get('low_n_flag','')}")
print("Audit 4/2/3/5 pending (this message specified Audit 1 config only).")
print("=== DECISION: AUDIT1_COMPUTED_REMAINING_AUDITS_PENDING (in-sample diagnostic only) ===")
