# post_close_move_offline_join_contract.md — Post-Close Move offline結合契約

date: 2026-07-11(W3 Design Freeze同梱)
原則: **EA Runtime は未来を参照しない。** Runtime が書くのは closeアンカーのみ。
move_1h/4h/24h は収集完了後に offline で外部価格データと結合して算出する。

## 1. Runtime側(W3_CLOSE_ANCHOR 行)— これだけ

| 列 | 内容 |
|---|---|
| close_time_msc / tester_time | basket close確定時刻 |
| close_bid / close_ask | close時価格 |
| close_reason | BasketClose / HardStop / HTE / RecoveryClose(既存値の転記) |
| basket_direction | main方向(BUY|SELL)。favorable符号の決定に使用 |
| final_pl / worst_floating_pl_yen / recovery_from_worst_at_close_yen | 同載(T3) |

タイマー・遅延記録・close後の追記は**一切なし**(OnDeinitはflushのみ)。

## 2. Offline側(結合エンジン、code側実装)

### 入力
- W3_CLOSE_ANCHOR 行(上記)
- 価格系列: price_m5.csv 形式(time, open, high, low, close, tick_volume)。
  実在確認済み: extraction_bundle_v1_1/price_m5.csv(2026-03-02T01:00〜06-30T23:55、
  23,656行)。W3収集期間分は同形式で再抽出して同梱すること(price_m5_w3.csv)。

### 結合規則(凍結)
1. **アンカーbar**: close_time_msc を切り上げた**次のM5 bar open**を起点とする
   (close barそのものは含めない=close時点既知情報の混入防止)。
2. **窓**: 起点から 1h=12bar / 4h=48bar / 24h=288bar。
3. **算出値**(各窓、favorable = main方向に有利な側):
   - `move_favorable_max`: BUYなら window内 max(high)−close_ask、
     SELLなら close_bid−window内 min(low)
   - `move_adverse_max`: 逆側の最大逆行
   - `move_net`: window末close − close時mid(方向符号付き)
4. **単位**: price単位で記録し、yen換算は 0.01 lot・現行契約サイズで別列併記
   (換算係数を出力に明記)。
5. **欠損処理**: 窓内barが不足(週末跨ぎ・データ末尾・市場閉場)した場合:
   - 充足率 = 実bar数/期待bar数 を `coverage_1h/4h/24h` に記録。
   - 充足率 < 0.8 の窓は値を **MISSING**(0埋め・部分値の代用禁止)。
   - 週末跨ぎはカレンダー時間のまま(取引時間補正をしない。バイアスは
     coverage列で下流が判断)。
6. **タイムゾーン**: close_time_msc と price bar time は**同一サーバ時刻系**で
   突合(既存 Trade Events / price_m5 と同系)。オフセット補正を入れない。
   系が異なる場合は結合を中止し JOIN_TZ_MISMATCH として全行MISSING。
7. **一意性**: basket_uid で1:1。アンカー重複時は JOIN_DUPLICATE_ANCHOR を記録し
   当該basketはMISSING。

### 出力(post_close_move_v_w3.csv)
basket_uid / close_reason / basket_direction / 各窓の move_favorable_max /
move_adverse_max / move_net / coverage / join_status(OK|MISSING_*|JOIN_*)。

## 3. 禁止

- Runtime での窓計算・価格先読み・close後のログ追記
- coverage不足窓の0埋め・線形補間・部分窓の代用
- 「延長すれば勝てた」等の反実仮想利益主張(算出するのは価格移動の記述統計まで。
  Audit 5 の WINNER_EXTENSION 判定はこのデータを入力に別途審査)
