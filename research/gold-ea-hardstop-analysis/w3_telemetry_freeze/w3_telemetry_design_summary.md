# w3_telemetry_design_summary.md — W3 Non-Intervening Telemetry Design Freeze

date: 2026-07-11
性格: **設計凍結のみ。本工程でEAコードには一切触れない。**実装可否は別途承認
(next_decision.md)。実装時もログ追記のみで売買ロジック非接触。
固定フラグ: P1_implementation_allowed=false / real_exit_implementation_allowed=false /
prehedge_exit_implementation_allowed=false / hedge_gate_implementation_allowed=false /
hardstop_change_allowed=false / oos_effect_claim_allowed=false。
rapid_drop 0.05 FROZEN。July W2 無接触。OOS効果・実装後利益を主張しない。

## 0. 設計原則(全telemetry共通)

1. **別ファイル出力**: W3 telemetry は既存 KOUCHA_GOLD_KIWAMI_TRADE_EVENTS.csv /
   Shadow snapshot CSV に**書かない**。専用シンク `KOUCHA_W3_TELEMETRY_<run>.csv`
   に書く。既存ログはbyte不変 → 非介入回帰の canonical hash 比較が単純化する。
2. **read-only**: W3 コードは EA状態を読むだけ。トレードAPI呼び出しゼロ、
   売買判定変数への書き込みゼロ(静的ゲートで機械検証、
   w3_static_nontrade_requirements.md)。
3. **failure isolation**: ログ書き込み失敗は握りつぶして継続(失敗カウンタのみ
   加算し次回行に記録)。logger例外を売買経路に伝播させない。
4. **未来参照禁止**: post_close_move は EA Runtime内で計算しない。closeアンカー
   のみ記録し、offline で price_m5 と結合(post_close_move_offline_join_contract.md)。
5. **MISSING規律**: 取得不能値は literal `MISSING`。0埋め禁止。UNKNOWN(三値)を
   false扱いしない。既存 999999 センチネル(no-position margin)は使用しない。
6. **スキーマ凍結**: 全行に w3_schema_version=W3.1。列追加は W3.2 として別凍結。

## 1. 設計対象4系統(スキーマは各CSV参照)

### T1: HEDGE_TIMING_TELEMETRY(→ M1 hedge_too_late / M2 hedge不発)
- 発火点: defense hedge 約定確定直後(既存hedge処理の後、read-only)。
- 中核フィールド: floating_loss_yen_at_hedge / hardstop_threshold_yen_active /
  **distance_to_hs_yen_at_hedge = threshold − |floating_loss|** /
  **distance_to_hs_price_at_hedge**(価格空間換算)/ worst_floating_pl_so_far /
  time_since_open_sec / time_since_worst_sec。
- M2(hedge不発)用に **W3_HEDGE_EVAL** 行も記録: hedge条件が評価されたが発動
  しなかった時点の同フィールド+block理由(既存 DefenseHedgeBlockReason の転記)。
  評価ロジック自体には触れない(結果の観測のみ)。

### T2: HARDSTOP_THRESHOLD_GAP_TELEMETRY(→ M3 閾値/確定タイミング)
- **3点ログ**: (a) W3_HS_DETECT = floating loss が閾値を最初に超えた tick、
  (b) W3_HS_SEND = close order送信直前、(c) W3_HS_FILL = 約定確定後(leg毎)。
- gap分解: detect→send ms / send→fill ms / detect時価格 vs fill価格 /
  **realized_loss − threshold(= 左裾超過分。最悪 −9,019 vs 8,000 の乖離要因)**。
- hedged basket は leg毎に fill行2本+basket集約1本。

### T3: WORST_FLOATING_PL_TELEMETRY(→ M1/M2 経路・pre-hedge損傷制御)
- Runtime内で running-min を保持(メモリ1変数、read-only計算)。
- 記録タイミング: (a) 更新が既録worstから **≥250円悪化**した時のみ W3_WORST_UPDATE
  行(行数制御)、(b) hedge時・close時に最終値を T1/T4 アンカー行へ同載。
- フィールド: worst_floating_pl_yen / worst_time_msc / price_at_worst /
  phase_at_worst(PRE_HEDGE|POST_HEDGE)/ positions_at_worst。

### T4: POST_CLOSE_MOVE_REFERENCE(→ Audit 5 winner extension)
- **Runtime は closeアンカーのみ**: W3_CLOSE_ANCHOR 行に close_time_msc /
  close_bid / close_ask / close_reason / basket_direction / final_pl。
  未来参照・待機・タイマーは一切持たない。
- move_1h/4h/24h は **offline** で price_m5.csv(実在確認済: 2026-03-02〜06-30
  M5 OHLC 23,656行)と結合して算出。結合規則・favorable符号・欠損処理は
  post_close_move_offline_join_contract.md で凍結。

## 2. 挿入点(詳細は w3_insertion_map.csv)

全5挿入点(OnTick末尾 / hedge約定後 / HS検知・送信・約定 / basket close後 /
OnDeinit flush)。いずれも**既存処理の完了後**に read-only で観測する位置。
既存イベント発行順序・既存ログ行は不変。

## 3. 非介入回帰(詳細は w3_nonintervention_regression_plan.md)

3構成比較(Shadow OFF vs W3 OFF vs W3 ON)で order/deal/close・basket outcome・
final balance・close reason の**差分0**、canonical trade-event hash 一致、
W3由来 order/deal/close **0件**、logger failure 非伝播試験を必須ゲートとする。
1項目でも不一致なら W3 データは全量破棄(解析に使わない)。

## 4. 判定

**W3_TELEMETRY_DESIGN_READY**(w3_telemetry_final_decision.md 参照)。
4系統すべて設計凍結完了、ブロッカーなし。実装承認は次工程の別決定。
