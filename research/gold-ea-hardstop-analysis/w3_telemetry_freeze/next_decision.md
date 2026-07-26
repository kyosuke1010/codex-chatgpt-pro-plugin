# next_decision.md — W3 Design Freeze 後の次工程

date: 2026-07-11
状態: 設計凍結完了(W3_TELEMETRY_DESIGN_READY)。**EAコードは本工程で無変更。**

## 次の意思決定(ユーザー承認事項)

**W3_LOGGING_IMPLEMENTATION_AUTHORIZATION**: **承認済み(2026-07-11、ユーザー承認)**。
承認範囲は「凍結スキーマ W3.1 どおりのログ追記のみ」。売買ロジック・Exit・Hedge・
HardStop・rapid_drop 0.05 への変更は承認に含まれない。
実装系フラグ(P1/Exit/Hedge gate/HardStop変更)は false のまま。
Codex向け実装依頼書: w3_implementation_request.md。

## 承認後の工程(順序固定、担当: Codex=MT5側 / Claude=検収・解析側)

1. **実装**(Codex): W3Telemetry.mqh 新規作成 + 5挿入点の呼出追加 +
   input W3_LOGGING_ENABLED(default false)。凍結スキーマ(W3.1)厳守。
2. **静的ゲート**(Codex実行・結果添付): 禁止シンボル grep 0ヒット
   (w3_static_nontrade_requirements.md §2 のコマンドと出力を納品に含める)。
3. **非介入回帰**(Codex): G1〜G9(w3_nonintervention_regression_plan.md)。
   Shadow OFF / W3 OFF / W3 ON + 故障注入 C'。結果 w3_regression_results.csv。
   **全PASSまで収集run禁止。**
4. **W3収集run**(Codex): in-sample(Mar–May)6設定 + June 2設定の再走
   (W3 ON)。price_m5_w3.csv(offline結合用の同形式価格データ)を同梱。
   **July期間は指定禁止**(納品前チェックリスト項目)。
5. **納品**: extraction_bundle_w3.zip + SHA256 manifest + extraction_report_w3.txt
   (行数・失敗カウンタ・スキーマ照合結果)。push後「w3 push完了」と合図。
6. **検収・解析**(Claude): SHA照合 → スキーマ照合 → 回帰結果確認 →
   offline結合(post_close_move)→ 再審査3件:
   a. Audit 3 timing 再審査(hedge_too_late / hedge不発、M1/M2)
   b. M3 閾値挙動審査(threshold_gap_yen 分解)
   c. Audit 5 winner extension 判定(post_close_move)
7. 3審査完了後に**実Exit設計審査**(実装ではない)を開始できる状態になる。

## 並行して変わらないこと

- July W2: 無接触のまま進行。2026-08-01 以降に完結分のみ、事前登録条件で評価。
  W3の回帰・収集はW2と独立(期間もバイナリ運用も分離)。
- 全結果は in-sample diagnostic。OOS効果・実装後利益・「15万円なら勝てる」不記載。

## ブロック条件(いずれかで工程停止)

- 静的ゲートFAIL / 回帰G1〜G9いずれかFAIL / 故障注入で伝播確認
- W3収集データにJuly混入
- スキーマ照合不一致(W3.1と異なるヘッダ)
→ いずれも修正後、静的ゲートからやり直し。FAILしたバイナリの収集データは全量破棄。
