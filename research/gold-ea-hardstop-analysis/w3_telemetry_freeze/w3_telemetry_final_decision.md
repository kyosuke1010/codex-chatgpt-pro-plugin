# w3_telemetry_final_decision.md — W3 Design Freeze 最終判定

date: 2026-07-11

## 判定: **W3_TELEMETRY_DESIGN_READY**

4系統すべての設計凍結が完了し、ブロッカーなし:

| 設計対象 | 状態 | 凍結物 |
|---|---|---|
| HEDGE_TIMING_TELEMETRY(T1) | READY | hedge_timing_telemetry_schema.csv(HEDGE_TIMING+HEDGE_EVAL、distance_to_hs_yen/price、M2 hedge不発の観測含む) |
| HARDSTOP_THRESHOLD_GAP_TELEMETRY(T2) | READY | hardstop_threshold_gap_schema.csv(DETECT/SEND/FILL 3点+SUMMARY、threshold_gap_yen 直接計測) |
| WORST_FLOATING_PL_TELEMETRY(T3) | READY | worst_floating_pl_schema.csv(running-min、250円刻み更新、phase付き、close時recovery定量) |
| POST_CLOSE_MOVE_REFERENCE(T4) | READY | post_close_move_offline_join_contract.md(**Runtime未来参照ゼロ**=closeアンカーのみ、price_m5 offline結合。価格データ実在確認済) |

## READY 判定の根拠

1. **非介入性が構造で担保される設計**: 別ファイル出力(既存ログbyte不変)、
   read-only参照、failure isolation、禁止シンボル静的ゲート、
   9ゲート回帰計画(G1〜G9)+故障注入試験。
2. **4 telemetry すべてに M1/M2/M3 との対応がある**(gap register との1:1対応。
   計測して使い道のない列を持たない)。
3. **T4 の未来参照問題は offline結合で解消**(結合対象 price_m5.csv の
   実在・期間・粒度を確認済み。欠損・TZ・週末の処理規則も凍結)。
4. 行数制御(DETECT1回/WORST 250円刻み/EVAL条件変化+500円刻み)により
   テスター負荷リスク(R1)が設計内で抑制されている。

## PARTIAL / BLOCKED としなかった理由

- 全4系統に未決事項なし。distance_to_hs_price の yen→price換算は換算不能時
  MISSINGで逃がす設計のため、契約仕様の不確定性が凍結の障害にならない。

## 本判定が意味しないこと

- **実装承認ではない**。EA(mq5/mqh/EX5)は本工程で無変更。実装は
  next_decision.md の承認ゲートを経て Codex が行う(ログ追記のみ)。
- Exit/Hedge/HardStop/rapid_drop 0.05 の変更をいかなる形でも含まない。
- OOS効果・実装後利益の主張を含まない。全telemetryは計測であって改善ではない。

## 固定フラグ(変更なし)

P1_implementation_allowed=false / real_exit_implementation_allowed=false /
prehedge_exit_implementation_allowed=false / hedge_gate_implementation_allowed=false /
hardstop_change_allowed=false / oos_effect_claim_allowed=false
