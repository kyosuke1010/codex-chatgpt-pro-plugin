# w3_implementation_request.md — Codex向け W3 実装依頼書

registered: 2026-07-11
authorization: W3_LOGGING_IMPLEMENTATION_AUTHORIZATION 承認済み(ログ追記のみ)
担当: Codex(MT5/MQL5/PowerShell)。Claude側は検収(SHA・スキーマ・回帰結果)と解析。

## 0. 承認範囲(これ以外はしない)

- ✅ W3Telemetry.mqh の新規作成(専用モジュール)
- ✅ EA本体への変更は3点のみ: `#include`、`input bool W3_LOGGING_ENABLED = false;`、
  5挿入点への W3関数呼出(w3_insertion_map.csv I1〜I5)
- ❌ 売買ロジック・Exit・Hedge・HardStop・rapid_drop 0.05・既存ログ出力の変更
- ❌ July W2 期間の実行・接触
- ❌ パラメータ最適化・閾値再調整

## 1. 実装仕様(すべて凍結済み、w3_telemetry_freeze/ 参照)

| 項目 | 凍結ファイル |
|---|---|
| 共通スキーマ(W3.1、全列・MISSING規律) | w3_runtime_schema.csv |
| T1 hedge timing + hedge eval | hedge_timing_telemetry_schema.csv |
| T2 HS 3点ログ + threshold_gap | hardstop_threshold_gap_schema.csv |
| T3 worst floating(250円刻み) | worst_floating_pl_schema.csv |
| T4 close anchor(未来参照禁止) | post_close_move_offline_join_contract.md §1 |
| 挿入点(5点、既存処理完了後・read-only) | w3_insertion_map.csv |
| 静的要件(禁止シンボル・一方向依存・I/O) | w3_static_nontrade_requirements.md |

要点の再掲:
- 出力は専用ファイル `KOUCHA_W3_TELEMETRY_<run>.csv` のみ。既存ログはbyte不変。
- 書込失敗は握って継続(logger_fail_count++)。売買経路へ例外を伝播させない。
- 取得不能値は literal `MISSING`。UNKNOWN を false に潰さない。0埋め禁止。
- T4 は close アンカー行のみ。move_1h/4h/24h を Runtime で計算しない。

## 2. 実行手順(順序固定。飛ばさない)

1. **実装** → コンパイル成功
2. **静的ゲート**: w3_static_nontrade_requirements.md §2 の grep を実行し
   **0ヒットの出力ログを納品物に含める**
3. **非介入回帰**(w3_nonintervention_regression_plan.md):
   - 3構成(Shadow OFF / W3 OFF / W3 ON)+故障注入 C'
   - 最低: 50k/100k MAR_MAY + June 2run(全8run推奨)
   - G1〜G9 全PASS の w3_regression_results.csv を作成
   - **1つでもFAILしたら収集に進まず、修正して静的ゲートからやり直し**
4. **W3収集run**: in6run 6設定 + June 2設定を W3 ON で再走
   - **July期間を指定しないこと(納品前チェック項目)**
   - offline結合用 price_m5_w3.csv(time,open,high,low,close,tick_volume 形式、
     収集期間全体をカバー)を同梱
5. **納品**:
   - `input_artifacts/extraction_bundle_v1/extraction_bundle_w3.zip`
     - KOUCHA_W3_TELEMETRY_<run>.csv × 8
     - w3_regression_results.csv(G1〜G9 × run × PASS/FAIL/hash)
     - 静的ゲートgrep出力ログ
     - price_m5_w3.csv
     - extraction_report_w3.txt(行数・logger_fail_count合計・スキーマ照合・
       July混入0の確認・W3Telemetry.mqh と挿入diff の SHA256)
   - SHA256 manifest 同梱、push後「**w3 push完了**」と合図

## 3. Claude側の検収(参考: 納品後に実施)

SHA照合 → ヘッダをW3.1凍結スキーマと機械照合 → 回帰結果G1〜G9確認 →
既存run(v1 baskets 526)との同一性確認(W3 ON収集runのbasket outcomeが
v1と一致すること = 回帰G4の収集run版)→ offline結合 → 再審査3件
(Audit 3 timing / M3 threshold gap / Audit 5 winner extension)。

## 4. ブロック条件(w3_risk_register.md / next_decision.md と同一)

静的ゲートFAIL / 回帰FAIL / 故障注入で伝播 / July混入 / スキーマ不一致
→ 当該バイナリの収集データ全量破棄、修正後に静的ゲートから再実行。
