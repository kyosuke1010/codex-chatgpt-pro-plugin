# prospective_preregistration_protocol.md — Locked Post-Sample Validation 事前登録プロトコル

status: PRE_REGISTERED / FROZEN
selection_time: 2026-07-02
authored_before_any_prospective_result: true

## 1. 用語の正確化(重要)

対象期間 2026-06-01〜2026-06-30 は、選定時点(2026-07-02)で**完結済みの過去期間**である。
したがって live prospective ではなく、

**locked post-sample validation window(prospective-style locked post-sample window)**

として扱う。この文書は「将来のライブ運用成績」を主張しない。目的は、
in-sample(2026-03〜2026-05)で得た Pre-Hedge 損傷仮説を、**結果を見る前に固定した
別期間**で検証することに限定する。

## 2. なぜこの窓か(selection_rule)

`selection_rule = 「in-sample cutoff(2026-05-29 / 境界2026-05-30)より後で、
選定日時点で完結している最初の暦月(2026-06)」`

- in-sample最終 ToDate = 2026.05.29(6run中の最遅)。
- 2026-06は in-sample より厳密に後。
- 2026-07-02時点で完結済み → MT5側で決定論的に再現収集可能。
- 既存6runのテスター条件(GOLD / M5 / Model=0 / JPY / 1:888)をそのまま適用可能。
- 選定に prospective 結果を一切使っていない(結果は未取得)。

## 3. 固定事項(結果確認後の変更を禁止)

| 項目 | 固定値 |
|---|---|
| selected_window | 2026-06-01 00:00:00 〜 2026-06-30 23:59:59 |
| half_open_window | [2026-06-01 00:00:00, 2026-07-01 00:00:00) |
| selection_time | 2026-07-02 |
| in_sample_cutoff | 2026-05-29(inclusive)/ 境界 2026-05-30 |
| symbol | GOLD(exact broker symbol。config Symbol=GOLD) |
| timeframe | M5 |
| tester_model | 0(every tick。in-sample Phase 1と同一) |
| deposits | 50,000 / 100,000(両方維持) |
| shadow_arms | ML_B_SHADOW_OFF(非介入参照)+ ML_C_SHADOW_ON(観測) |
| leverage / currency | 1:888 / JPY |
| EA source SHA256 | e57be0039e54fa605adafe582b4b273381059166c9964000ffbfc033de40f03a |
| EX5 SHA256 | 49b3140292f614723d37fb8b8af3dabaa83ad4a61c15fd328e9a201d7c9a6cdb |
| observation_trigger(FROZEN) | normalized_3min_loss_slope >= 0.05/min(Exit条件ではない) |

## 4. 禁止事項(このプロトコルの拘束)

- 窓の後からの差し替え(2026-06以外への変更)
- 2026-06の結果を見た条件・閾値の調整(optimization / parameter tuning)
- OOS効果・本番期待利益の主張
- 実Exit実装 / Pre-Hedge Exit / M15 Exit / MA Cross Exit / Hedge Gate / Event Stop
- EA source / EX5 の変更
- full EA counterfactual の主張

## 5. 将来用途の限定

`future_use = VALIDATION_ONLY`。本窓のデータは、in-sample仮説
(急落型slope分離 / Pre-Hedge MA warning harm過多 / BC Kill型とHardStop型の差)の
**再現確認のみ**に使う。実装可否の最終審査は、この検証が整合した後に
別途開始する(本プロトコルでは開始しない)。

## 6. 固定フラグ(継続)

P1_implementation_allowed=false / real_exit_implementation_allowed=false /
prehedge_exit_implementation_allowed=false / ma_cross_logic_implementation_allowed=false /
hedge_gate_implementation_allowed=false / event_stop_implementation_allowed=false
