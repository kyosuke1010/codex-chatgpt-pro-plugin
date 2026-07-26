# w3_nonintervention_regression_plan.md — W3 非介入回帰計画

date: 2026-07-11(Design Freeze同梱)
目的: W3ログ追記が売買挙動に**一切**影響しないことを、収集開始前に機械検証する。
1項目でも不一致なら W3収集データは全量破棄(解析入力にしない)。

## 1. 比較3構成

| 構成 | 内容 |
|---|---|
| A: Shadow OFF | 現行EA(W3コードなし)・Shadow logging OFF |
| B: W3 OFF | W3コード組込済みバイナリ・W3ログ無効(スイッチOFF) |
| C: W3 ON | 同バイナリ・W3ログ有効 |

同一期間・同一設定・同一ビルド環境で3構成を実行(最低: in6run 6設定の代表2run
= 50k/100k MAR_MAY + June 2run。全8run実施が望ましい)。

## 2. 必須ゲート(全て差分0/一致が条件)

| # | ゲート | 比較 | 判定方法 |
|---|---|---|---|
| G1 | Shadow OFF vs W3 OFF 一致 | A vs B | canonical trade-event hash 一致 |
| G2 | W3 OFF vs W3 ON 一致 | B vs C | canonical trade-event hash 一致 |
| G3 | order/deal/close 差分 0 | A vs B vs C | ENTRY/HEDGE/CLOSE/ORDER系イベントの行集合完全一致 |
| G4 | basket outcome 差分 0 | 同上 | basket毎の(open_time, close_time, close_reason, final_pl)完全一致 |
| G5 | final balance 差分 0 | 同上 | 最終Balance/Equity一致 |
| G6 | close reason 差分 0 | 同上 | close_reason分布・basket対応完全一致 |
| G7 | W3由来 order/deal/close = 0 | C | W3コードパスからのトレードAPI呼出0(静的+動的) |
| G8 | logger failure 非伝播 | C' (故障注入) | 書込失敗を強制注入しても G3-G6 が C と一致し run が完走 |
| G9 | UNKNOWN非false化 | C | W3出力の三値フィールド(hedge_fired/phase等)に UNKNOWN が保存され false に潰れていない(サンプル検査) |

### canonical trade-event hash の定義(凍結)

- 対象: 既存 KOUCHA_GOLD_KIWAMI_TRADE_EVENTS.csv の全行のうち
  event_role ∈ {ENTRY, HEDGE, CLOSE, ORDER_ERROR} に対応する行
  (W3行は**別ファイル**のため混入し得ないが、定義として明示)。
- 正規化: 列順固定・改行LF・trailing space除去。実行毎に変わり得る
  非決定列(実行時刻スタンプ等のwall-clock列)が存在する場合は事前に列指定で
  除外し、除外列リストを結果に記録する。
- SHA256 を run毎に算出し3構成で比較。

## 3. 故障注入試験(G8詳細)

1. C' 構成: W3ファイルハンドルを意図的に無効化(読み取り専用ディレクトリ指定等、
   **EAコード変更なしで**外部から失敗させる)。
2. 期待: run完走・G3〜G6 が C と完全一致・W3_LOGGER_STATUS の
   logger_fail_count > 0 が記録される(失敗の観測可能性)。
3. 失敗が売買スレッドに例外伝播した場合は設計不合格 → 実装修正まで収集禁止。

## 4. 実行順序と成否処理

1. 静的ゲート(w3_static_nontrade_requirements.md)PASS
2. G1〜G9 実行 → 全PASS で初めて W3収集run開始
3. 任意のゲートFAIL → 当該バイナリでの収集禁止・原因修正後に**G1から**再実行
4. 結果は w3_regression_results.csv(run × gate × PASS/FAIL/hash値)として納品

## 5. スコープ制約

- 本回帰は in-sample期間(Mar–May)+June の再走で行う。**July W2 には触れない**。
- 回帰用再走データは回帰判定のみに使用(解析サンプルに追加しない)。
- 回帰PASS後の W3収集run が解析入力となる。
