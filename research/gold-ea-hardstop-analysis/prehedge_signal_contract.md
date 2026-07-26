# prehedge_signal_contract.md — Pre-Hedge Damage Shadow契約(FROZEN v1.0.0)

status: DESIGN_FROZEN — Shadow観測専用。Exit/Entry/Hedge変更を一切許可しない。
親契約: ma_signal_contract.md v1.1.0 / ma_existing_close_protection_contract.md

## 1. 目的と根拠

Phase B充填で確定した事実に基づく:
- Hedged HardStop 26件は全件 LOSS_DOMINANT_BEFORE_HEDGE
- Non-Hedged HardStop 11件はHedge前に終了
→ 左裾の主戦場は**Pre-Hedge帯**である。

さらにPre-Hedge帯限定再計算(prehedge_harm_recalculation_plan.csv)で、
**全MA候補がPre-Hedge帯ではone-step合計マイナス**
(M15素 -10,258円 / harm/gross 1.221、M5 -41,538円 / 1.514)と確定。
したがってPre-Hedge帯では「MAクロス=閉じる」は成立せず、
損傷状態(damage state)そのものの多変量観測が必要。

## 2. Pre-Hedge帯の定義

- `is_pre_hedge = true` または `is_never_hedged = true` のRuntime Snapshot。
- Hedge発動(first_hedge_time)以降のSnapshotは本契約の対象外
  (Persistence/Recross診断は別契約 m15_persistence_recross_diagnostic_spec.md)。
- hedge状態がUNKNOWNのSnapshotは PRE_HEDGE_UNKNOWN として別カウント
  (どちらの帯にも算入しない)。

## 3. 観測レコード(Pre-Hedge Damage Shadow)

フィールド詳細は prehedge_runtime_schema.csv。原則:

1. **EA変更ゼロ**: 全フィールドは (a) Phase 1 Snapshotに既存、
   (b) Snapshot系列からオフライン導出、(c) Offline MA Overlayから結合、
   のいずれかで取得する。ランタイム新規計算を要求しない。
2. **既知の欠損の明示**: runtime `loss_slope_short` / `loss_slope_mid` /
   `adverse_movement_speed` は**Phase 1では全行NA**(未実装)。
   本契約ではこれらを使用せず、オフライン導出slope(loss_slope_observation_contract.md)
   で代替する。runtime実装は禁止(EA変更になるため)。
3. **UNKNOWN保持**: eligibility系(HTE/Recovery/BasketClose)は
   TRUE/FALSE/UNKNOWNの3値。market_stateの `OPEN_OR_UNKNOWN` は
   **UNKNOWN扱い**とし、validと解釈しない。
4. **commission**: NA(0埋め禁止)。

## 4. 導出フィールドの定義(オフライン)

- `max_floating_loss_so_far_yen`: Basket開始からの floating_loss_yen の累積最大。
- `time_since_last_favorable_movement_sec`: current_basket_net_pl が直前観測より
  改善した最後のSnapshotからの経過秒。改善が一度もない場合はbasket age。
- `derived_loss_slope_{1,3,5}min_yen_per_min`: 窓W秒で
  (loss(t) − loss(t−W)) / (W/60)。窓内に基準Snapshotが無い場合は
  `UNDERIVABLE_SPARSE`(補間禁止)。
- `derived_distance_shrink_rate_yen_per_min`: distance_to_hardstop_yen の減少速度。
- `normalized_slope_frac_per_min`: derived_slope / hardstop_threshold_yen。
  capital間比較はこの正規化値のみで行う(円絶対値はcapital依存のため)。

## 5. 分類ラベル(Shadow専用・行動なし)

| label | 定義 |
|---|---|
| PREHEDGE_DAMAGE_WATCH | distance_band ∈ {WATCH, CAUTION} |
| PREHEDGE_DAMAGE_DANGER | distance_band ∈ {DANGER, CRITICAL} |
| PREHEDGE_RAPID_DROP_CANDIDATE | normalized_slope_3min >= 観測記録閾値(後述) |
| PREHEDGE_MA_WARNING_OVERLAY | M15/M30/M5状態をOverlayから併記(warning-only) |
| PREHEDGE_CENSORED | Hedge発動またはBasket終了により観測打ち切り |

RAPID_DROP記録閾値は 0.05/min(in-sample分布のOTHER p90=0.111の約半分)に
固定する。これは**記録のトリガであってExitのトリガではない**。閾値を
in-sample成績が良くなる方向に動かすことを禁止(合わせ込み禁止)。
判別性能の評価はprospectiveデータでのみ行う。

## 6. 禁止事項

- 本契約のいかなるラベル・閾値も、order/deal/close操作に接続しない。
- P1_implementation_allowed=false / real_exit_implementation_allowed=false /
  prehedge_exit_implementation_allowed=false / ma_cross_logic_implementation_allowed=false /
  hedge_gate_implementation_allowed=false / event_stop_implementation_allowed=false
  (固定フラグ。変更には新たな設計レビューが必要)
