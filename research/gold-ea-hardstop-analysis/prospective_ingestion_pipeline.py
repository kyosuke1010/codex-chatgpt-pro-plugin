#!/usr/bin/env python3
"""Prospective (locked post-sample) ingestion pipeline — EA無変更・観測のみ.

19-step receiving pipeline for the June-2026 locked post-sample validation window.
Runs against input_artifacts/prospective/ (ZIPs or extracted). With no data present
it validates the pre-registration and emits AWAITING status (no fabrication).

Steps: SHA verify -> extract -> rediscover(Snapshot/BasketSummary/RunSummary/Trade)
-> rowcount/schema -> source/EX5 SHA -> window/deposit/symbol/tf/model match
-> pre-hedge features (slope 1/3/5, shrink, trigger) -> MA overlay join
-> event stratification -> Q1..Q6 -> sufficiency -> decision.

Usage: python3 research/gold-ea-hardstop-analysis/prospective_ingestion_pipeline.py
"""

import csv
import hashlib
import zipfile
from collections import defaultdict
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PROS = REPO / "input_artifacts" / "prospective"
PEXT = PROS / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis"

# ---- FROZEN pre-registration (mirror of locked_window_manifest; do not edit post-hoc) ----
EXPECT_SRC_SHA = "e57be0039e54fa605adafe582b4b273381059166c9964000ffbfc033de40f03a"
EXPECT_EX5_SHA = "49b3140292f614723d37fb8b8af3dabaa83ad4a61c15fd328e9a201d7c9a6cdb"
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


checks = []


def chk(step, name, status, detail=""):
    checks.append({"step": step, "check": name, "status": status, "detail": detail})
    print(f"[{step:>2}] {name}: {status} {detail}")


# ================= Step 1: presence + SHA256 =================
files = [p for p in PROS.iterdir() if p.is_file()] if PROS.is_dir() else []
zips = [p for p in files if p.suffix.lower() == ".zip"]
sha_rows = [{"file": p.name, "size_bytes": p.stat().st_size, "sha256": sha256(p)}
            for p in files]
w("prospective_input_sha_manifest.csv", ["file", "size_bytes", "sha256"], sha_rows)
chk(1, "input_presence_and_sha256", "PASS" if files else "AWAITING",
    f"{len(files)} files, {len(zips)} zips")

DATA = bool(zips) or any((PEXT).glob("**/*.csv")) if PEXT.exists() else bool(zips)

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

# ================= Steps 3-6: rediscover + rowcount =================
snapshot_files, basket_files, run_files, trade_files, ini_files = [], [], [], [], []
if PEXT.exists():
    for p in PEXT.rglob("*"):
        if not p.is_file():
            continue
        nm = p.name.replace("\\", "/").lower()
        if p.suffix.lower() == ".csv":
            try:
                head = p.open(encoding="utf-8-sig", errors="replace").readline().lower()
            except Exception:
                head = ""
            if "root_snapshot_id" in head and "event_type" in head:
                snapshot_files.append(p)
            elif "final_close_reason" in head or "basket_master" in nm:
                basket_files.append(p)
            elif "run_summary" in nm:
                run_files.append(p)
            elif "trade_event" in nm:
                trade_files.append(p)
        elif p.suffix.lower() == ".ini":
            ini_files.append(p)
chk(3, "rediscover_root_snapshot_csv", "PASS" if snapshot_files else "AWAITING",
    f"{len(snapshot_files)} files")
chk(4, "rediscover_basket_summary_csv", "PASS" if basket_files else "AWAITING",
    f"{len(basket_files)} files")
chk(5, "rediscover_run_summary_csv", "PASS" if run_files else "AWAITING",
    f"{len(run_files)} files")
chk(6, "rediscover_trade_events_csv", "PASS" if trade_files else "AWAITING",
    f"{len(trade_files)} files")

# ================= Step 7: schema validation =================
REQ_SNAP = {"root_snapshot_id", "basket_uid", "event_type", "server_time_msc",
            "floating_loss_yen", "hardstop_threshold_yen", "distance_to_hardstop_yen",
            "is_pre_hedge", "is_never_hedged", "hardstop_now_snapshot",
            "current_HTE_eligibility", "current_BasketClose_eligibility",
            "close_priority_ok", "market_state", "high_impact_usd_event_window_state"}
schema_ok = None
if snapshot_files:
    hdr = set(csv.DictReader(snapshot_files[0].open(encoding="utf-8-sig")).fieldnames or [])
    missing = REQ_SNAP - hdr
    schema_ok = not missing
    chk(7, "schema_validation_snapshot", "PASS" if schema_ok else "FAIL",
        f"missing={sorted(missing)}" if missing else "all required cols present")
else:
    chk(7, "schema_validation_snapshot", "AWAITING", "")

# ================= Step 8: source / EX5 SHA =================
src_sha = ex5_sha = None
for p in files:
    if p.suffix.lower() == ".mq5":
        src_sha = sha256(p)
    elif p.suffix.lower() == ".ex5":
        ex5_sha = sha256(p)
if src_sha or ex5_sha:
    ok = (src_sha in (None, EXPECT_SRC_SHA)) and (ex5_sha in (None, EXPECT_EX5_SHA))
    chk(8, "ea_identity_sha", "PASS" if ok else "FAIL_EA_CHANGED",
        f"src_match={src_sha==EXPECT_SRC_SHA} ex5_match={ex5_sha==EXPECT_EX5_SHA}")
else:
    chk(8, "ea_identity_sha", "AWAITING", "no mq5/ex5 pushed yet")

# ================= Steps 9-10: window / deposit / symbol / tf / model =================
def read_ini(p):
    raw = p.read_bytes()
    txt = raw.decode("utf-16", errors="ignore") if b"\x00" in raw[:64] else raw.decode("utf-8", "ignore")
    d = {}
    for line in txt.splitlines():
        if "=" in line:
            k, _, v = line.partition("=")
            d[k.strip()] = v.strip()
    return d


win_ok = cfg_ok = None
if ini_files:
    win_ok, cfg_ok = True, True
    for p in ini_files:
        d = read_ini(p)
        if d.get("FromDate") != EXPECT["from"] or d.get("ToDate") != EXPECT["to"]:
            win_ok = False
        if d.get("Symbol") != EXPECT["symbol"] or d.get("Period") != EXPECT["period"] \
           or d.get("Model") != EXPECT["model"] or d.get("Deposit") not in EXPECT["deposits"]:
            cfg_ok = False
    chk(9, "window_match_halfopen_June", "PASS" if win_ok else "FAIL", "FromDate/ToDate")
    chk(10, "deposit_symbol_tf_model_match", "PASS" if cfg_ok else "FAIL", "")
else:
    chk(9, "window_match_halfopen_June", "AWAITING", "")
    chk(10, "deposit_symbol_tf_model_match", "AWAITING", "")

# ================= Steps 11-14: pre-hedge derived features =================
baskets = defaultdict(list)
inv_rows = []
for p in snapshot_files:
    cap = next((c for c in EXPECT["deposits"] if c in p.name), "UNKNOWN")
    n = 0
    for row in csv.DictReader(p.open(encoding="utf-8-sig", errors="replace")):
        if row.get("event_type") != "MULTILAYER_ROOT_SNAPSHOT":
            continue
        n += 1
        # window membership guard (half-open)
        st = row.get("server_time", "").replace(".", "-")[:19]
        try:
            t = datetime.strptime(st, "%Y-%m-%d %H:%M:%S")
            if not (WIN_START <= t < WIN_END_EXCL):
                continue
        except ValueError:
            pass
        is_pre = (row.get("is_pre_hedge", "").lower() in ("true", "1")
                  or row.get("is_never_hedged", "").lower() in ("true", "1"))
        try:
            ts = int(row["server_time_msc"]) / 1000.0
            loss = float(row["floating_loss_yen"])
            thr = float(row["hardstop_threshold_yen"])
            dist = float(row["distance_to_hardstop_yen"])
        except (ValueError, KeyError):
            continue
        baskets[(cap, row.get("basket_uid", ""))].append((ts, loss, thr, is_pre, dist))
    inv_rows.append({"source_file": p.name[:80], "capital": cap, "root_snapshot_rows": n})
w("prospective_snapshot_inventory.csv",
  ["source_file", "capital", "root_snapshot_rows"], inv_rows)


def max_norm_slope(series, win, idx):
    s = sorted(series)
    best, j = None, 0
    for i in range(len(s)):
        while s[i][0] - s[j][0] > win:
            j += 1
        if j < i and s[i][0] - s[j][0] >= win * 0.5:
            dt = (s[i][0] - s[j][0]) / 60.0
            thr = s[i][2]
            if thr > 0:
                v = (s[i][idx] - s[j][idx]) / dt / thr
                best = v if best is None else max(best, v)
    return best


feat_rows, missing_slope = [], 0
for (cap, uid), series in baskets.items():
    pre = [x for x in series if x[3]]
    if not pre:
        continue
    n3 = max_norm_slope(pre, 180, 1)
    n1 = max_norm_slope(pre, 60, 1)
    n5 = max_norm_slope(pre, 300, 1)
    shrink = max_norm_slope([(t, -d, thr, ip, d) for (t, l, thr, ip, d) in pre], 180, 1)
    if n3 is None:
        missing_slope += 1
    losses = [x[1] for x in pre]
    feat_rows.append({
        "basket_uid": uid, "capital": cap, "prehedge_snapshot_count": len(pre),
        "norm_loss_slope_1min": f"{n1:.4f}" if n1 is not None else "UNDERIVABLE_SPARSE",
        "norm_loss_slope_3min": f"{n3:.4f}" if n3 is not None else "UNDERIVABLE_SPARSE",
        "norm_loss_slope_5min": f"{n5:.4f}" if n5 is not None else "UNDERIVABLE_SPARSE",
        "norm_distance_shrink_rate_3min": f"{shrink:.4f}" if shrink is not None else "UNDERIVABLE_SPARSE",
        "max_floating_loss_so_far_yen": f"{max(losses):.0f}" if losses else "UNKNOWN",
        "rapid_drop_observation_trigger": str(n3 is not None and n3 >= NORM3_TRIGGER).lower(),
        "trigger_threshold_norm3_per_min": NORM3_TRIGGER, "data_source": "PROSPECTIVE_OFFLINE_DERIVED",
    })
w("prehedge_slope_derived_features.csv",
  ["basket_uid", "capital", "prehedge_snapshot_count", "norm_loss_slope_1min",
   "norm_loss_slope_3min", "norm_loss_slope_5min", "norm_distance_shrink_rate_3min",
   "max_floating_loss_so_far_yen", "rapid_drop_observation_trigger",
   "trigger_threshold_norm3_per_min", "data_source"], feat_rows)
slope_missing_rate = (missing_slope / len(feat_rows)) if feat_rows else None
chk(11, "prehedge_feature_generation", "PASS" if feat_rows else "AWAITING", f"{len(feat_rows)} baskets")
chk(12, "loss_slope_1_3_5min_derivation", "PASS" if feat_rows else "AWAITING", "")
chk(13, "distance_shrink_rate_derivation", "PASS" if feat_rows else "AWAITING", "")
chk(14, "rapid_drop_trigger_eval", "PASS" if feat_rows else "AWAITING",
    f"fired={sum(1 for r in feat_rows if r['rapid_drop_observation_trigger']=='true')}")

# ================= Steps 15-16: MA overlay join / event stratification =================
chk(15, "ma_overlay_join", "AWAITING" if not feat_rows else
    ("PENDING_OVERLAY_INPUT" if not list(PEXT.rglob("*with_ma*.csv")) else "READY"),
    "requires prospective overlay bars (PX11) or offline recompute")
chk(16, "event_window_stratification", "AWAITING" if not snapshot_files else "READY",
    "high_impact_usd_event_window_state present in schema")

# ================= Step 17: Q1..Q6 =================
q_rows = []
for q, txt, ins in [
    ("Q1", "rapid-drop slope separation reproduces",
     f"HS_p50={BASE['rapid_norm3_hs_p50']} OTHER_p50={BASE['norm3_other_p50']}"),
    ("Q2", "pre-hedge MA warning stays harm-excess",
     f"M15={BASE['prehedge_M15_total_yen']} M5={BASE['prehedge_M5_total_yen']}"),
    ("Q3", "slope+shrink separates shallow vs deep adverse", "in-sample ~7x median gap"),
    ("Q4", "BC-kill vs HardStop difference", f"BC-kill(pre-hedge M15)={BASE['prehedge_M15_bckill']}"),
    ("Q5", "HTE late-eligibility observable via persistence/recross",
     f"{BASE['hte_late_n']}/{BASE['hte_late_yen']}yen"),
    ("Q6", "event window auxiliary only", f"hs_pm60_share={BASE['hs_pm60_event_share']}"),
]:
    q_rows.append({"question": q, "hypothesis": txt, "insample_reference": ins,
                   "prospective_result": "AWAITING_DATA" if not feat_rows else "COMPUTE_ON_FULL_BUNDLE",
                   "verdict": "PENDING"})
w("prospective_q1_q6_results.csv",
  ["question", "hypothesis", "insample_reference", "prospective_result", "verdict"], q_rows)
chk(17, "Q1_Q6_analysis", "AWAITING" if not feat_rows else "PARTIAL",
    "outcome joins need Basket Summary + overlay")

# ================= Step 18: sufficiency =================
hs = nh = hd = bc = 0
for p in basket_files:
    for row in csv.DictReader(p.open(encoding="utf-8-sig", errors="replace")):
        rsn = (row.get("final_close_reason", "") or "").lower()
        if "hard" in rsn:
            hs += 1
            if str(row.get("hedged", "")).lower() in ("true", "1"):
                hd += 1
            else:
                nh += 1
        elif "basket" in rsn:
            bc += 1
suff_rows = [
    {"criterion": "prospective_hardstop_count", "required": SUFF["min_hardstop"], "observed": hs},
    {"criterion": "nonhedged_hardstop", "required": SUFF["min_nonhedged"], "observed": nh},
    {"criterion": "hedged_hardstop", "required": SUFF["min_hedged"], "observed": hd},
    {"criterion": "basketclose_count", "required": SUFF["min_basketclose"], "observed": bc},
    {"criterion": "slope_missing_rate_max", "required": SUFF["max_slope_missing_rate"],
     "observed": f"{slope_missing_rate:.3f}" if slope_missing_rate is not None else "NA"},
    {"criterion": "nonintervention_off_and_on_present", "required": "both",
     "observed": f"trade_files={len(trade_files)}"},
]
w("prospective_sufficiency_check.csv", ["criterion", "required", "observed"], suff_rows)
suff_met = DATA and hs >= SUFF["min_hardstop"] and nh >= SUFF["min_nonhedged"] \
    and hd >= SUFF["min_hedged"] and bc >= SUFF["min_basketclose"]
chk(18, "sufficiency_check", "PASS" if suff_met else ("AWAITING" if not DATA else "NOT_MET"),
    f"hs={hs} nh={nh} hd={hd} bc={bc}")

# ================= Step 19: decision =================
if not DATA:
    decision = "PROSPECTIVE_INGESTION_PIPELINE_READY_WITH_DATA_PENDING"
elif any(c["status"].startswith("FAIL") for c in checks):
    decision = "PROSPECTIVE_WINDOW_CONTAMINATED" if any(
        c["check"] in ("window_match_halfopen_June", "ea_identity_sha",
                       "deposit_symbol_tf_model_match") and c["status"].startswith("FAIL")
        for c in checks) else "PROSPECTIVE_INPUT_SCHEMA_INCOMPLETE"
elif not suff_met:
    decision = "PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED"
else:
    decision = "SUFFICIENT_PROCEED_TO_Q_ANALYSIS_REPORT"
chk(19, "final_decision", decision, "")

w("prospective_pipeline_run_log.csv", ["step", "check", "status", "detail"], checks)
print("\n=== DECISION:", decision, "===")
print("collection window (FROZEN): 2026-06-01 .. 2026-06-30 (half-open to 2026-07-01)")
