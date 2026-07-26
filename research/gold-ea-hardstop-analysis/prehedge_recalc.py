#!/usr/bin/env python3
"""Pre-Hedge band recalculation + rapid-drop case extraction (design audit).

EA無変更・観測のみ。UNKNOWN保持・合わせ込みなし。
出力:
- prehedge_harm_recalculation_plan.csv(Pre-Hedge帯限定の候補別再計算)
- rapid_drop_no_warning_cases.csv(警告なし急落型4件のSnapshot系列特性)
"""

import csv
import re
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
EX = REPO / "input_artifacts" / "extracted"
OUT = REPO / "research" / "gold-ea-hardstop-analysis"
OV = EX / "KOUCHA_GOLD_PHASE1_RUNTIME_MA_CROSS_OVERLAY_AUDIT"
SH = EX / "KOUCHA_GOLD_MULTILAYER_PHASE1_SHADOW_FIX_AUDIT"

PRE = ("PRE_HEDGE", "NEVER_HEDGED")


def read_csv(p):
    with p.open(encoding="utf-8-sig", errors="replace", newline="") as f:
        return list(csv.DictReader(f))


def find(d, suffix):
    hits = [p for p in d.rglob("*") if p.is_file()
            and p.name.replace("\\", "/").endswith(suffix)]
    assert len(hits) == 1, (suffix, hits)
    return hits[0]


one_step = read_csv(find(OV, "ma_one_step_basket_effect.csv"))
hs_rebuild = read_csv(OUT / "hardstop_root_cause_rebuild.csv")

# ---------- 1) Pre-Hedge band per-candidate recalculation ----------
rows_out = []
for cand in sorted({r["candidate_name"] for r in one_step}):
    band = [r for r in one_step
            if r["candidate_name"] == cand and r["signal_phase"] in PRE]
    full = [r for r in one_step if r["candidate_name"] == cand]

    def f(v):
        try:
            return float(v)
        except ValueError:
            return None

    resc = [r for r in band if r["kill_harm_class"] == "HARDSTOP_RESCUE"]
    hs = [r for r in band if r["actual_class"] == "HARDSTOP"]
    kills = defaultdict(list)
    for r in band:
        if r["kill_harm_class"] in ("HTE_KILL", "RECOVERY_KILL", "BASKETCLOSE_KILL"):
            kills[r["kill_harm_class"]].append(f(r["one_step_effect_ex_commission_yen"]) or 0)
    # in-profit truncation(Signal時点で含み益の勝ち切り捨て)
    trunc = [r for r in band
             if (f(r["current_pl_at_signal_yen"]) or 0) > 0
             and (f(r["one_step_effect_ex_commission_yen"]) or 0) < 0
             and r["kill_harm_class"] != "UNRESOLVED_CENSORED"]
    ok = [r for r in band if r["kill_harm_class"] != "UNRESOLVED_CENSORED"]
    total = sum(f(r["one_step_effect_ex_commission_yen"]) or 0 for r in ok)
    harm = -sum(min(0.0, f(r["one_step_effect_ex_commission_yen"]) or 0) for r in ok)
    benefit = sum(max(0.0, f(r["one_step_effect_ex_commission_yen"]) or 0) for r in ok)
    leads = sorted(f(r["signal_to_hardstop_minutes"]) for r in hs
                   if f(r["signal_to_hardstop_minutes"]) is not None)
    rows_out.append({
        "candidate_name": cand,
        "band": "PRE_HEDGE_OR_NEVER_HEDGED_SIGNALS_ONLY",
        "band_signal_count": len(band),
        "full_signal_count": len(full),
        "band_share": f"{len(band)/len(full):.3f}" if full else "NA",
        "hardstop_signal_count": len(hs),
        "hardstop_rescue_count": len(resc),
        "hardstop_rescue_yen": f"{sum(f(r['one_step_effect_ex_commission_yen']) or 0 for r in resc):.0f}",
        "hte_kill_count": len(kills["HTE_KILL"]),
        "hte_kill_yen": f"{sum(kills['HTE_KILL']):.0f}",
        "recovery_kill_count": len(kills["RECOVERY_KILL"]),
        "recovery_kill_yen": f"{sum(kills['RECOVERY_KILL']):.0f}",
        "basketclose_kill_count": len(kills["BASKETCLOSE_KILL"]),
        "basketclose_kill_yen": f"{sum(kills['BASKETCLOSE_KILL']):.0f}",
        "in_profit_winner_truncation_count": len(trunc),
        "one_step_total_ex_censored_yen": f"{total:.0f}",
        "harm_over_gross_benefit": f"{harm/benefit:.4f}" if benefit > 0 else "NA_NO_BENEFIT",
        "median_lead_to_hardstop_min": f"{leads[len(leads)//2]:.1f}" if leads else "NA",
        "min_lead_to_hardstop_min": f"{leads[0]:.1f}" if leads else "NA",
        "censored_count": sum(1 for r in band if r["kill_harm_class"] == "UNRESOLVED_CENSORED"),
        "data_source": "OFFLINE_OVERLAY_INGESTED_20260702_PREHEDGE_BAND",
        "note": "one-step local diagnostic; NOT implemented profit; NOT OOS",
    })

with (OUT / "prehedge_harm_recalculation_plan.csv").open("w", encoding="utf-8", newline="") as fo:
    w = csv.DictWriter(fo, fieldnames=list(rows_out[0].keys()))
    w.writeheader()
    w.writerows(rows_out)
print("prehedge band recalculation:")
for r in rows_out:
    print(f"  {r['candidate_name']}: band {r['band_signal_count']}/{r['full_signal_count']}"
          f" rescue {r['hardstop_rescue_count']}/{r['hardstop_rescue_yen']}円"
          f" BCkill {r['basketclose_kill_count']}/{r['basketclose_kill_yen']}円"
          f" total {r['one_step_total_ex_censored_yen']}円 h/g {r['harm_over_gross_benefit']}")

# M15 warning before hedge (from filled Phase B table)
hedged = [r for r in hs_rebuild if r["hedged_flag"] == "true"]
pre_warn = [r for r in hedged if r["signal_to_hedge_lead_sec"] not in ("NA", "")
            and int(r["signal_to_hedge_lead_sec"]) > 0]
nonh = [r for r in hs_rebuild if r["hedged_flag"] == "false"]
nonh_warn = [r for r in nonh if r["m15_reverse_before_hardstop"] == "true"]
print(f"\nM15 warning BEFORE hedge (hedged 26): {len(pre_warn)}")
print(f"M15 warning on non-hedged (11): {len(nonh_warn)}")

# ---------- 2) rapid-drop no-warning cases: snapshot series characterization ----------
targets = [r for r in hs_rebuild if r["no_ma_warning_flag"] == "true"]
assert len(targets) == 4, len(targets)


def norm(t):
    return t.replace("-", ".").strip()


def cap_per(label):
    cap = re.search(r"_(\d{5,6})_", label).group(1)
    per = re.search(r"_(MAR_MAY|APR_MAY|MAY)_M5", label).group(1)
    return cap, per


tkeys = {}
for t in targets:
    tkeys[(t["capital_group"], cap_per(t["run_id"])[1], norm(t["entry_time"]))] = t
series = defaultdict(list)

shadow_files = [p for p in SH.rglob("*MLSHADOW*.csv")
                if "shadow_logs" in p.name.replace("\\", "/")]
for p in shadow_files:
    cap, per = cap_per(p.name)  # run_id列はMLSHADOW識別子のためファイル名から取得
    with p.open(encoding="utf-8-sig", errors="replace", newline="") as f:
        for row in csv.DictReader(f):
            if row.get("event_type") != "MULTILAYER_ROOT_SNAPSHOT":
                continue
            # basket_uid like GOLD#2026.04.02T03:51:04#N#DIR#k -> start time
            m = re.match(r"GOLD#(\d{4}\.\d{2}\.\d{2})T(\d{2}:\d{2}:\d{2})", row.get("basket_uid", ""))
            if not m:
                continue
            key = (cap, per, f"{m.group(1)} {m.group(2)}")
            if key in tkeys:
                series[key].append(row)

out_rows = []
for key, t in tkeys.items():
    snaps = sorted(series.get(key, []), key=lambda r: int(r["event_sequence"]))
    n = len(snaps)

    def col(name):
        return [s.get(name, "") for s in snaps]

    def fl(vals):
        out = []
        for v in vals:
            try:
                out.append(float(v))
            except ValueError:
                pass
        return out

    fl_loss = fl(col("floating_loss_yen"))
    dist = fl(col("distance_to_hardstop_yen"))
    spread = fl(col("spread_points"))
    lc = col("large_candle_state")
    ages = fl(col("basket_age_seconds"))

    # runtime slope列は全行NA(Phase 1未実装)のためオフライン導出:
    # (floating_loss(t) - floating_loss(t-W)) / W分。時刻はserver_time_msc。
    ts, losses, dists = [], [], []
    for s in snaps:
        try:
            ts.append(int(s["server_time_msc"]) / 1000.0)
            losses.append(float(s["floating_loss_yen"]))
            dists.append(float(s["distance_to_hardstop_yen"]))
        except (ValueError, KeyError):
            pass

    def max_slope(vals, win_sec):
        best, j = None, 0
        for i in range(len(ts)):
            while ts[i] - ts[j] > win_sec:
                j += 1
            if j < i and ts[i] - ts[j] >= win_sec * 0.5:
                sl = (vals[i] - vals[j]) / ((ts[i] - ts[j]) / 60.0)
                best = sl if best is None else max(best, sl)
        return f"{best:.0f}" if best is not None else "UNDERIVABLE_SPARSE"

    d_slope1 = max_slope(losses, 60)
    d_slope3 = max_slope(losses, 180)
    d_slope5 = max_slope(losses, 300)
    shrink = max_slope([-d for d in dists], 180)  # distance縮小速度(円/分)
    out_rows.append({
        "basket_uid": t["basket_uid"], "run_id": t["run_id"],
        "capital_group": t["capital_group"], "direction": t["direction"],
        "entry_time": t["entry_time"], "hardstop_time": t["hardstop_time"],
        "entry_to_hardstop_min": f"{(ages[-1]/60):.1f}" if ages else "UNKNOWN",
        "final_loss_yen": t["final_loss_yen"],
        "event_window_state": t["event_window_state"],
        "snapshot_count": n,
        "observability_ok": "true" if n >= 10 else "false",
        "max_floating_loss_yen": f"{max(fl_loss):.0f}" if fl_loss else "UNKNOWN",
        "min_distance_to_hardstop_yen": f"{min(dist):.0f}" if dist else "UNKNOWN",
        "runtime_loss_slope_fields": "NA_ALL_ROWS_PHASE1_NOT_POPULATED",
        "derived_max_loss_slope_1min_yen_per_min": d_slope1,
        "derived_max_loss_slope_3min_yen_per_min": d_slope3,
        "derived_max_loss_slope_5min_yen_per_min": d_slope5,
        "derived_max_distance_shrink_rate_yen_per_min": shrink,
        "snapshot_density_per_min": f"{(n / (ages[-1]/60)):.2f}" if ages and ages[-1] > 0 else "UNKNOWN",
        "max_spread_points": f"{max(spread):.1f}" if spread else "UNKNOWN",
        "large_candle_states_seen": ";".join(sorted(set(lc))) if lc else "UNKNOWN",
        "m15_state": "NO_WARNING_ALL_TF_CONFIRMED",
        "m5_state": "NO_WARNING_ALL_TF_CONFIRMED",
        "no_warning_rapid_loss_class": "RAPID_DROP_NO_CLOSED_BAR_WARNING",
        "data_source": "PHASE1_ROOT_SNAPSHOT_SERIES_INGESTED_20260702",
    })
    print(f"\nrapid-drop {key}: snapshots={n} "
          f"slope1m={out_rows[-1]['derived_max_loss_slope_1min_yen_per_min']} "
          f"slope3m={out_rows[-1]['derived_max_loss_slope_3min_yen_per_min']} "
          f"shrink3m={out_rows[-1]['derived_max_distance_shrink_rate_yen_per_min']} "
          f"density={out_rows[-1]['snapshot_density_per_min']}/min "
          f"max_spread={out_rows[-1]['max_spread_points']}")

with (OUT / "rapid_drop_no_warning_cases.csv").open("w", encoding="utf-8", newline="") as fo:
    w = csv.DictWriter(fo, fieldnames=list(out_rows[0].keys()))
    w.writeheader()
    w.writerows(out_rows)
print(f"\nwrote rapid_drop_no_warning_cases.csv: {len(out_rows)} rows")
