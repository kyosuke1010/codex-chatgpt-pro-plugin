#!/usr/bin/env python3
"""Fill Phase B/F/G CSVs from ingested audit artifacts.

決定性・非補間・UNKNOWN保持。既存6runへの合わせ込みなし。
入力: input_artifacts/extracted/ 配下の監査CSV(改変しない)
出力: research/gold-ea-hardstop-analysis/ の既存スキーマCSVを充填
"""

import csv
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
EX = REPO / "input_artifacts" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis"

OV = EX / "KOUCHA_GOLD_PHASE1_RUNTIME_MA_CROSS_OVERLAY_AUDIT"
HS = EX / "KOUCHA_GOLD_HARDSTOP_ROOT_CAUSE_MULTI_LOGIC_AUDIT"
EV_DIR = EX / "KOUCHA_GOLD_EVENT_BLACKOUT_WINDOW_AUDIT"
SH = EX / "KOUCHA_GOLD_MULTILAYER_PHASE1_SHADOW_FIX_AUDIT"

CONTRACT_VERSION = "1.1.0"
DATA_SOURCE = "OFFLINE_OVERLAY_INGESTED_20260702"

CANDIDATE_TO_REASON = {
    "M15_REVERSE_CROSS": "M15_REVERSE_CONFIRMED",
    "M15_REVERSE_CROSS_WITH_M30_ADVERSE_REGIME": "M15_REVERSE_WITH_M30_ADVERSE",
    "M15_REVERSE_CROSS_THEN_M5_RETEST_FAILURE": "M15_REVERSE_WITH_M5_PROXY",
    "M5_REVERSE_CROSS_WARNING": "M5_REVERSE_WARNING",
    "M30_REGIME_MISMATCH_AT_ENTRY": "M30_ENTRY_REGIME_MISMATCH",
    "M30_REGIME_PLUS_M15_CROSS_PLUS_M5_PULLBACK": "M15_REVERSE_M30_M5_COMBO",
}


def read_csv(path):
    with path.open(encoding="utf-8-sig", errors="replace", newline="") as f:
        return list(csv.DictReader(f))


def find(dirpath, name_suffix):
    hits = [p for p in dirpath.rglob("*") if p.is_file()
            and p.name.replace("\\", "/").endswith(name_suffix)]
    if len(hits) != 1:
        sys.exit(f"expected exactly 1 file *{name_suffix} under {dirpath}, got {hits}")
    return hits[0]


def run_meta(label):
    cap = re.search(r"_(\d{5,6})_", label)
    per = re.search(r"_(MAR_MAY|APR_MAY|MAY)_M5", label)
    if not cap or not per:
        sys.exit(f"cannot parse run label: {label}")
    return cap.group(1), per.group(1)


def norm_time(t):
    return t.replace("-", ".").strip() if t and t != "NA" else "NA"


def write_rows(filename, rows):
    """既存スキーマCSVのヘッダを正とし、行を充填する。"""
    path = OUT / filename
    with path.open(encoding="utf-8", newline="") as f:
        header = next(csv.reader(f))
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=header, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "UNKNOWN") for k in header})
    print(f"wrote {filename}: {len(rows)} rows")


# ---------- load sources ----------
one_step = read_csv(find(OV, "ma_one_step_basket_effect.csv"))
hs_master = read_csv(find(HS, "hardstop_path_master.csv"))
hs_event = read_csv(find(EV_DIR, "hardstop_event_overlap.csv"))
overlay_master = read_csv(find(OV, "basket_overlay_master.csv"))
assert len(hs_master) == 37 and len(overlay_master) == 442

# consistency: one_step effect must equal candidate - actual (両方数値の行)
bad = 0
for r in one_step:
    try:
        c, a, e = (float(r["current_pl_at_signal_yen"]),
                   float(r["actual_final_pl_yen"]),
                   float(r["one_step_effect_ex_commission_yen"]))
        if abs((c - a) - e) > 0.01:
            bad += 1
    except ValueError:
        pass
print(f"one_step effect identity violations: {bad}")
if bad:
    sys.exit("one-step identity check failed; stopping (no fabrication)")

# ---------- snapshot join for close-priority gates ----------
need_ids = {r["first_signal_root_snapshot_id"] for r in one_step
            if r["first_signal_root_snapshot_id"] not in ("", "NA")}
snap = {}
shadow_files = [p for p in SH.rglob("*MLSHADOW*.csv")
                if "shadow_logs" in p.name.replace("\\", "/")]
assert len(shadow_files) == 6, shadow_files
for p in shadow_files:
    with p.open(encoding="utf-8-sig", errors="replace", newline="") as f:
        for row in csv.DictReader(f):
            rid = row.get("root_snapshot_id", "")
            if rid in need_ids and rid not in snap:
                snap[rid] = {
                    "close_priority_ok": row.get("close_priority_ok", "UNKNOWN"),
                    "close_priority_blocked": row.get("close_priority_blocked", "UNKNOWN"),
                    "pending_close_state": row.get("pending_close_state", "UNKNOWN"),
                    "market_state": row.get("market_state", "UNKNOWN"),
                }
print(f"snapshot join: matched {len(snap)}/{len(need_ids)} signal snapshot ids")

# ---------- Phase G: ma_one_step_effect_rebuild + derived tables ----------
TRUE = ("true", "TRUE", "True")


def g(v):  # gate truthiness with UNKNOWN preserved
    s = (v or "").strip()
    if s.lower() in ("true", "false"):
        return s.lower()
    return "UNKNOWN"


rebuild, rescue_harm, truncation, kills, gates_tbl = [], [], [], [], []
for r in one_step:
    cap, per = run_meta(r["run_label"])
    sn = snap.get(r["first_signal_root_snapshot_id"], {})
    actual_pl = r["actual_final_pl_yen"]
    try:
        actual_pl_f = float(actual_pl)
    except ValueError:
        actual_pl_f = None
    try:
        eff_f = float(r["one_step_effect_ex_commission_yen"])
    except ValueError:
        eff_f = None
    censored = r["kill_harm_class"] == "UNRESOLVED_CENSORED"
    winner_trunc = (actual_pl_f is not None and eff_f is not None
                    and actual_pl_f > 0 and eff_f < 0)
    reason = CANDIDATE_TO_REASON[r["candidate_name"]]
    hedge_phase = ("PRE_HEDGE" if r["signal_phase"] in ("PRE_HEDGE", "NEVER_HEDGED")
                   else "POST_HEDGE" if r["signal_phase"] == "POST_HEDGE"
                   else "UNKNOWN")
    ev = r["event_window_state_at_signal"]
    ev_state = ("IN_WINDOW" if ev in TRUE else
                "OUT_OF_WINDOW" if ev.upper() == "FALSE" else "UNKNOWN")

    # gates (G1-G14)
    gates = {
        "gate_m15_reverse_confirmed": "true" if reason.startswith("M15_REVERSE") else "false",
        "gate_closed_bar_signal": "true" if r["alignment_status"] == "FIRST_RUNTIME_SNAPSHOT_AFTER_CLOSED_BAR" else "false",
        "gate_hardstop_now_false": "true" if g(r["hardstop_now_at_signal"]) == "false" else ("false" if g(r["hardstop_now_at_signal"]) == "true" else "UNKNOWN"),
        "gate_close_priority_ok_true": "true" if g(sn.get("close_priority_ok")) == "true" else ("false" if g(sn.get("close_priority_ok")) == "false" else "UNKNOWN"),
        "gate_close_priority_blocked_false": "true" if g(sn.get("close_priority_blocked")) == "false" else ("false" if g(sn.get("close_priority_blocked")) == "true" else "UNKNOWN"),
        "gate_pending_close_false": "true" if (sn.get("pending_close_state", "UNKNOWN") in ("NONE", "false", "FALSE")) else ("UNKNOWN" if sn.get("pending_close_state") in (None, "", "UNKNOWN") else "false"),
        "gate_market_state_valid": "true" if sn.get("market_state") in ("VALID", "NORMAL", "OK", "TRADEABLE") else ("UNKNOWN" if sn.get("market_state") in (None, "", "UNKNOWN") else sn.get("market_state")),
        "gate_hte_eligible_false_and_known": "true" if g(r["HTE_eligibility_at_signal"]) == "false" else ("false" if g(r["HTE_eligibility_at_signal"]) == "true" else "UNKNOWN"),
        "gate_recovery_eligible_false_and_known": "true" if g(r["Recovery_eligibility_at_signal"]) == "false" else ("false" if g(r["Recovery_eligibility_at_signal"]) == "true" else "UNKNOWN"),
        "gate_basketclose_eligible_false_and_known": "true" if g(r["BasketClose_eligibility_at_signal"]) == "false" else ("false" if g(r["BasketClose_eligibility_at_signal"]) == "true" else "UNKNOWN"),
        "gate_event_state_not_unknown_if_used": "true" if ev_state != "UNKNOWN" else "false",
        "gate_direction_known": "true" if r["basket_direction"] in ("BUY", "SELL") else "false",
        "gate_first_eligible_signal": "true",  # source file is first-signal-per-family
        "commission_treatment": "NA_NOT_ZERO_FILLED",
    }
    hard_gates = [v for k, v in gates.items() if k.startswith("gate_")]
    all_pass = ("true" if all(v == "true" for v in hard_gates)
                else "false" if any(v == "false" for v in hard_gates) else "UNKNOWN")
    blocking = ";".join(k for k, v in gates.items()
                        if k.startswith("gate_") and v != "true")

    common = {
        "basket_uid": r["canonical_basket_key"],
        "run_id": r["run_label"], "capital_group": cap,
        "reason_code": reason,
        "source_candidate_name": r["candidate_name"],
        "is_primary_signal": "true",
        "signal_time": r["first_signal_time"],
        "available_time": r["signal_available_time"],
        "candidate_profit_swap_yen": r["current_pl_at_signal_yen"],
        "actual_final_profit_swap_yen": actual_pl,
        "one_step_effect_ex_commission_yen": r["one_step_effect_ex_commission_yen"],
        "effect_class": r["kill_harm_class"],
        "actual_final_reason": r["actual_class"],
        "hedge_phase_at_signal": hedge_phase,
        "m30_regime": r["m30_state_at_signal"] or "UNKNOWN",
        "m5_proxy_state": r["m5_state_at_signal"] or "UNKNOWN",
        "event_window_state": ev_state,
        "censored_flag": str(censored).lower(),
        "all_gates_pass": all_pass,
        "contract_version": CONTRACT_VERSION, "data_source": DATA_SOURCE,
    }
    rebuild.append(common)
    if r["actual_class"] == "HARDSTOP":
        rescue_harm.append({**common,
            "effect_class": r["kill_harm_class"],
            "pl_at_signal_yen": r["current_pl_at_signal_yen"],
            "final_loss_yen": actual_pl,
            "signal_to_hardstop_lead_sec":
                str(round(float(r["signal_to_hardstop_minutes"]) * 60))
                if r["signal_to_hardstop_minutes"] not in ("NA", "") else "NA",
        })
    if winner_trunc:
        truncation.append({**common,
            "pl_at_signal_yen": r["current_pl_at_signal_yen"],
            "truncation_loss_yen": r["one_step_effect_ex_commission_yen"]})
    if r["kill_harm_class"] in ("HTE_KILL", "RECOVERY_KILL", "BASKETCLOSE_KILL"):
        kills.append({**common,
            "kill_type": r["kill_harm_class"],
            "pl_at_signal_yen": r["current_pl_at_signal_yen"],
            "kill_cost_yen": r["one_step_effect_ex_commission_yen"],
            "eligibility_state_at_signal":
                f"HTE={r['HTE_eligibility_at_signal']};REC={r['Recovery_eligibility_at_signal']};BC={r['BasketClose_eligibility_at_signal']}",
            "blocking_gate_that_would_prevent": blocking or "NONE_GATES_ALL_PASS"})
    gates_tbl.append({"observation_id": f"{r['canonical_basket_key']}|{r['candidate_name']}",
                      "basket_uid": r["canonical_basket_key"], "reason_code": reason,
                      **gates, "all_gates_pass": all_pass,
                      "future_executable_candidate": all_pass,
                      "blocking_gates": blocking or "NONE",
                      "data_source": DATA_SOURCE})

write_rows("ma_one_step_effect_rebuild.csv", rebuild)
write_rows("ma_hardstop_rescue_vs_harm.csv", rescue_harm)
write_rows("ma_winner_truncation.csv", truncation)
write_rows("ma_hte_recovery_basketclose_kill.csv", kills)
write_rows("future_candidate_decision_table.csv", gates_tbl)

# ---------- Phase B: hardstop_root_cause_rebuild ----------
# join key: (capital, period, basket開始時刻)。uid形式がaudit間で異なるため
# 時刻キーで結合する(同一(capital,period)内でstart_timeは一意であることをassert)
m15_by_key = {}
for r in one_step:
    if r["candidate_name"] != "M15_REVERSE_CROSS" or r["actual_class"] != "HARDSTOP":
        continue
    cap, per = run_meta(r["run_label"])
    key = (cap, per, norm_time(r["basket_start_time"]))
    assert key not in m15_by_key, f"duplicate M15 hardstop key {key}"
    m15_by_key[key] = r

# 全candidateでのHardStopカバー(NO_MA_WARNING判定用)
any_cand_hs_keys = set()
for r in one_step:
    if r["actual_class"] == "HARDSTOP":
        cap, per = run_meta(r["run_label"])
        any_cand_hs_keys.add((cap, per, norm_time(r["basket_start_time"])))

ev_by_key = {}
for r in hs_event:
    cap, per = run_meta(r["run_id"])
    ev_by_key[(r["capital"], per, norm_time(r["first_entry_time"]))] = r

hs_rows = []
m15_hits = 0
no_warn_any = 0
for r in hs_master:
    cap, per = run_meta(r["run_id"])
    key = (r["capital"], per, norm_time(r["basket_start_time"]))
    sig = m15_by_key.get(key)
    evr = ev_by_key.get(key)
    if key not in any_cand_hs_keys:
        no_warn_any += 1
    hedged = r["never_hedged_or_hedged"] != "NEVER_HEDGED"

    # root_cause_class: 排他優先則(hardstop_research_priority.md)。
    # RECOVERY_THEN_GIVEBACKはpost-hedge回復系列が本監査に無いため判定不能(降格しない)
    if not hedged:
        rc = "NON_HEDGED_HARDSTOP"
    else:
        try:
            before = abs(float(r["loss_before_hedge"]))
            after = abs(float(r["loss_after_hedge"]))
            rc = ("LOSS_DOMINANT_BEFORE_HEDGE" if before >= after
                  else "LOSS_ACCUMULATED_AFTER_HEDGE")
        except ValueError:
            rc = "HEDGED_SPLIT_UNKNOWN"

    sig_time = sig["first_signal_time"] if sig else "NA"
    lead_hs = (sig["signal_to_hardstop_minutes"] if sig else "NA")
    hs_rows.append({
        "basket_uid": r["basket_uid"], "run_id": r["run_id"],
        "capital_group": r["capital"], "direction": r["entry_direction"],
        "entry_time": r["first_entry_time"],
        "hedge_time": r["first_hedge_time"],
        "hardstop_time": r["final_hardstop_time"],
        "hedged_flag": str(hedged).lower(),
        "root_cause_class": rc,
        "first_warning_signal_time": sig_time,
        "first_warning_signal_family": "M15_REVERSE_CONFIRMED" if sig else "NO_M15_WARNING",
        "signal_to_hedge_lead_sec": "NA",  # 下で計算
        "signal_to_hardstop_lead_sec":
            str(round(float(lead_hs) * 60)) if lead_hs not in ("NA", "") else "NA",
        "pl_at_signal_yen": sig["current_pl_at_signal_yen"] if sig else "NA",
        "distance_to_hardstop_at_signal_yen":
            sig["distance_to_hardstop_at_signal_yen"] if sig else "NA",
        "pl_at_hedge_yen": r["pl_at_first_hedge"],
        "post_hedge_best_recovery_yen": "NOT_IN_SOURCE_AUDIT",
        "giveback_after_recovery_yen": "NOT_IN_SOURCE_AUDIT",
        "final_loss_yen": r["final_pl"],
        "event_window_state":
            (evr.get("hardstop_pm60_overlap", "UNKNOWN") if evr else "UNKNOWN"),
        "m15_reverse_before_hardstop": "true" if sig else "false",
        "m30_regime_at_signal": sig["m30_state_at_signal"] if sig else "NA",
        "m5_proxy_state_at_signal": sig["m5_state_at_signal"] if sig else "NA",
        "hte_eligible_at_signal": sig["HTE_eligibility_at_signal"] if sig else "NA",
        "recovery_eligible_at_signal": sig["Recovery_eligibility_at_signal"] if sig else "NA",
        "basketclose_eligible_at_signal": sig["BasketClose_eligibility_at_signal"] if sig else "NA",
        "close_priority_ok_at_signal":
            snap.get(sig["first_signal_root_snapshot_id"], {}).get("close_priority_ok", "UNKNOWN") if sig else "NA",
        "pending_close_at_signal":
            snap.get(sig["first_signal_root_snapshot_id"], {}).get("pending_close_state", "UNKNOWN") if sig else "NA",
        "no_ma_warning_flag": "false" if key in any_cand_hs_keys else "true",
        "source_root_cause_classes": r.get("root_cause_classes", ""),
        "data_source": DATA_SOURCE,
    })
    if sig:
        m15_hits += 1
        # signal→hedge lead(hedge後にsignalならNEGATIVE_POST_HEDGE)
        import datetime as dt

        def parse(t):
            t = norm_time(t)
            if t == "NA":
                return None
            return dt.datetime.strptime(t, "%Y.%m.%d %H:%M:%S")
        st, ht = parse(sig_time), parse(r["first_hedge_time"])
        if st and ht:
            hs_rows[-1]["signal_to_hedge_lead_sec"] = str(int((ht - st).total_seconds()))

print(f"hardstop M15 join: {m15_hits}/37 baskets with M15 signal (期待29)")
print(f"hardstop with NO warning from ANY candidate: {no_warn_any}/37")
ev_hits = sum(1 for row in hs_rows if row["event_window_state"] != "UNKNOWN")
print(f"hardstop event join: {ev_hits}/37")
from collections import Counter as _C
print("root_cause_class:", dict(_C(row["root_cause_class"] for row in hs_rows)))
write_rows("hardstop_root_cause_rebuild.csv", hs_rows)

# ---------- summary for verification vs SESSION_REPORTED_AGGREGATE ----------
from collections import Counter, defaultdict
m15 = [r for r in one_step if r["candidate_name"] == "M15_REVERSE_CROSS"]
m15_hs = [r for r in m15 if r["actual_class"] == "HARDSTOP"]
rescue = [r for r in m15_hs if r["kill_harm_class"] == "HARDSTOP_RESCUE"]
print("\n=== M15_REVERSE_CROSS verification vs reported ===")
print(f"HardStop coverage: {len(m15_hs)} (期待29)")
print(f"HARDSTOP_RESCUE: {len(rescue)}件 / {sum(float(r['one_step_effect_ex_commission_yen']) for r in rescue):+.0f}円 (期待29件/+63961円)")
hte = [r for r in m15 if r["kill_harm_class"] == "HTE_KILL"]
print(f"HTE_KILL: {len(hte)}件 / {sum(float(r['one_step_effect_ex_commission_yen']) for r in hte):+.0f}円 (期待1件/-20円)")
wt = [r for r in m15 if r["actual_class"] != "UNRESOLVED" and r["actual_final_pl_yen"] not in ('NA','') and float(r["actual_final_pl_yen"]) > 0 and float(r["one_step_effect_ex_commission_yen"]) < 0]
print(f"Winner truncation (M15): {len(wt)}件 (期待0)")
combo = [r for r in one_step if r["candidate_name"] == "M30_REGIME_PLUS_M15_CROSS_PLUS_M5_PULLBACK"]
tot = sum(float(r["one_step_effect_ex_commission_yen"]) for r in combo if r["kill_harm_class"] != "UNRESOLVED_CENSORED")
print(f"best combo one-step total: {tot:+.0f}円 (期待+29585円)")
print("\nkill_harm_class by candidate:")
by_cand = defaultdict(Counter)
for r in one_step:
    by_cand[r["candidate_name"]][r["kill_harm_class"]] += 1
for cn, c in sorted(by_cand.items()):
    print(f"  {cn}: {dict(c)}")
