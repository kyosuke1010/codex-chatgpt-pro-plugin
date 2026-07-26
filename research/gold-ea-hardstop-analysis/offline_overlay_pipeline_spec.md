# offline_overlay_pipeline_spec.md — Offline Overlay Pipeline仕様

version: 1.0.0(ma_signal_contract.md v1.0.0 に従属)

## 入力

| 入力 | 必須 | 現状 |
|---|---|---|
| Runtime Snapshot CSV(ART04) | 必須 | MISSING_IN_WORKSPACE |
| Basket Summary CSV(ART05) | 必須 | MISSING_IN_WORKSPACE |
| M5/M15/M30 closed bar OHLC(ART12) | 必須 | MISSING_IN_WORKSPACE |
| Event Blackout Audit(ART07) | 任意(event列充填用) | MISSING_IN_WORKSPACE |

## ステージ

### Stage 0: 入力監査
- 各入力のSHA256を記録し manifest に追記。
- Snapshot行数・Basket件数を期待値(169,305 / 442)と照合。不一致は停止。
- 時刻系の単一性確認(TIME_BASE_UNKNOWN検出時は結合保留)。
- 2024 M1データをreal tick由来と誤表示していないかソース種別を確認。
  外部TickとBroker-native tickを別列で区別し、混同を禁止。

### Stage 1: バー整合性チェック
- 単調増加時刻、重複バー、欠損区間を検出。欠損区間はWARMUP_UNKNOWN降格
  (補間禁止、ma_closed_bar_availability_spec.md 規則6)。

### Stage 2: MA計算
- EMA10(seed=先頭10本SMA)/ SMA20。closed barのみ。warmup 50本。
- 決定性: 同一入力→バイト同一出力。浮動小数点は倍精度固定、並列化しない。

### Stage 3: クロス検出
- ma_signal_contract.md セクション3の定義そのまま。
- 出力: (TF, bar_open, bar_close, cross_type) の全履歴。

### Stage 4: Availability結合
- 各crossに対し、bar_close以降最初のRuntime Snapshotを二分探索で割当て。
- available_time / availability_lag_sec / SIGNAL_CENSORED判定。
- 監査: available_time < bar_close の行0件を機械的に検証。

### Stage 5: Basket結合
- Snapshot→basket_uid経由でBasketへ結合。期待442/442。
- direction / hedge_state を ma_direction_mapping.csv で解決。
- adverse判定、First Signal latch、persistence(1/2/3 bars)、recross、
  M30 regime、M5 proxyを状態機械どおり付与。

### Stage 6: 分類・効果計算
- reason_code付与(ma_shadow_reason_dictionary.csv 限定)。
- one-step効果: candidate_profit_swap_yen − actual_final_profit_swap_yen
  (Phase G定義)。commissionはNA、列名はex_commission。
- 出力: ma_shadow_observation_schema.csv 準拠の観測行、
  ma_one_step_effect_rebuild.csv、rescue/harm/truncation/kill各CSV。

### Stage 7: 出力manifest
- 全出力のSHA256、行数、契約バージョン、入力SHAを1つのrun manifestに記録。
  再現性の正本とする。

## 禁止事項(pipeline内)

- forming bar使用 / signal backdating
- 欠損補間・UNKNOWNの暗黙false化
- 既存6run結果に合わせた閾値の事後調整
- 出力を「実装後利益」「OOS効果」と表記すること
