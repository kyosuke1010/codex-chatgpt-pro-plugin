# loss_slope_observation_contract.md — Loss Slope / Rapid Drop観測契約(FROZEN v1.0.0)

status: OBSERVATION_ONLY — Exitトリガとしての使用を禁止。

## 1. 対象と根拠

警告なし急落型HardStop 4件 / -29,439円(gross lossの14.6%)は、
全MA候補・全TFのclosed-bar警告なし、全件Event Window(±60分)外。
closed-bar M15(最短15分遅延)では構造的に間に合わない。
rapid_drop_no_warning_cases.csv で4件全件のSnapshot系列特性を実測済み:

| 指標 | 実測(4件) |
|---|---|
| entry→HardStop | 約14〜105分 |
| snapshot密度 | 2.1〜3.3本/分 → **観測可能性OK** |
| derived max 1分slope | 1,258〜3,111円/分 |
| derived max 3分slope | 1,619〜2,041円/分 |
| 正規化3分slope(HardStop閾値比/分) | 0.112 / 0.218 / 0.227 / 0.405 |
| max spread | 50〜53 points |

## 2. 重大な前提(Phase 1ログの欠損)

runtime列 `loss_slope_short` / `loss_slope_mid` / `adverse_movement_speed` は
**Phase 1全行でNA(未実装)**。本契約はこれらを使用せず、既存の
`floating_loss_yen` + `distance_to_hardstop_yen` + `server_time_msc` 系列から
**すべてオフラインで導出**する。runtime側への実装はEA変更にあたるため
本Phaseでは禁止(将来Phase 3候補として非介入回帰込みで別途審査)。

## 3. 導出定義

- `loss_slope_W(t)` = (floating_loss(t) − floating_loss(t−W)) / (W/60) [円/分]
  W ∈ {60s, 180s, 300s}。窓内の基準Snapshotは「t−W以前で最も新しいSnapshot」
  とし、実経過がW/2未満なら `UNDERIVABLE_SPARSE`(補間・外挿禁止)。
- `adverse_move_points_per_min` = 価格系列(bid/ask)の逆行速度。同窓規則。
- `distance_to_hardstop_shrink_rate` = −Δdistance_to_hardstop_yen / Δt [円/分]。
- `normalized_slope_frac_per_min` = loss_slope_W / hardstop_threshold_yen。
  **capital横断の比較・閾値定義はこの正規化値のみで行う。**
- `spread_spike_proxy` = spread_points / rolling median(spread_points, 30min)。
- `large_candle_proxy` = large_candle_state ≠ FALSE の2値化(元文字列も保持)。

## 4. In-sample予備判別(参考値・最適化禁止)

Pre-Hedge帯で正規化3分slopeの最大値をBasket別に導出した結果(in-sample):

- HardStop系(導出可能11件): p50 = 0.145
- その他(243件): p50 = 0.021 / p90 = 0.111 / max = 0.224
- 4件全部を捕まえる最小閾値 0.112 では、その他Basketの24/243(約10%)が
  誤検知になる。

**解釈**: 分布は約7倍分離するが、単一閾値でのExit化は誤検知コストが
未定義のため不可。これは「slope系は観測特徴量として有効、行動条件としては
未成熟」という設計判断の根拠であり、閾値をin-sampleで調整することを禁止する。
記録トリガは 0.05/min 固定(prehedge_signal_contract.md セクション5)。
判別性能の本評価はprospectiveデータでのみ行う。

## 5. no_warning_rapid_loss_class の付与規則

HardStop到達Basketに対し、事後(オフライン)に:

- 全MA候補の事前Signalなし かつ entry→HardStop < 120分
  → `RAPID_DROP_NO_CLOSED_BAR_WARNING`
- 事前Signalなし かつ 120分以上 → `SLOW_BLEED_NO_WARNING`(新観測クラス)
- 事前Signalあり → 対象外(MA系観測へ)

## 6. 出力

Pre-Hedge Damage Shadowレコード(prehedge_runtime_schema.csv)に
導出列として同居させる。独立したログ経路・EA変更は発生しない。
