# prospective_acceptance_checklist.md — 受け入れチェックリスト

pipeline: prospective_ingestion_pipeline.py が各項目を自動判定し
prospective_pipeline_run_log.csv に PASS/FAIL/AWAITING を出力する。

## 到着前(pre-registration。本セッションで完了済み)

- [x] locked window を結果確認前に固定(2026-06-01〜2026-06-30、half-open)
- [x] selection_time / selection_rule を記録(2026-07-02)
- [x] symbol / timeframe / model / deposits / leverage / currency を記録
- [x] EA source SHA / EX5 SHA を記録(同一性ガードの基準)
- [x] 観測トリガ 0.05/min を固定(Exit条件ではない)
- [x] contamination ledger を作成
- [x] 受け入れ pipeline を実装し no-data で健全動作を確認

## 到着後(データ到着時に pipeline が判定)

- [ ] Step1 SHA256 記録・破損なし
- [ ] Step2 ZIP展開成功
- [ ] Step3-6 Snapshot / BasketSummary / RunSummary / TradeEvents 再発見
- [ ] Step7 root_snapshot スキーマ必須列すべて存在
- [ ] Step8 EA source/EX5 SHA が基準と一致(不一致=汚染)
- [ ] Step9 window 一致(FromDate/ToDate + half-open membership)
- [ ] Step10 deposit/symbol/tf/model 一致
- [ ] Step11-14 pre-hedge feature 生成 / slope 1・3・5min / shrink / trigger
- [ ] Step15 MA overlay 結合(overlay bars 提供時)
- [ ] Step16 event window 層別
- [ ] Step17 Q1〜Q6(outcome 結合後)
- [ ] Step18 十分性: HardStop≥15 / Non-Hedged≥2 / Hedged≥2 / BasketClose≥5 /
      slope欠損率≤0.30 / OFF+ON両arm
- [ ] Step19 最終判定
- [ ] 非介入: OFF vs ON の deal/order fingerprint 完全一致

## 判定分岐

| 状態 | decision |
|---|---|
| データ未到着 | PROSPECTIVE_INGESTION_PIPELINE_READY_WITH_DATA_PENDING |
| 同一性/窓 違反 | PROSPECTIVE_WINDOW_CONTAMINATED |
| スキーマ欠落 | PROSPECTIVE_INPUT_SCHEMA_INCOMPLETE |
| 十分性未達 | PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED |
| 全通過 | SUFFICIENT_PROCEED_TO_Q_ANALYSIS_REPORT(→ Q1〜Q6 で個別仮説判定) |
