# next_decision.md — 次工程判定(Synthesis v1.4)

date: 2026-07-11
性格: 実装判断ではない。「次に何を測るか」の決定。

## 次工程 = W3 Non-Intervening Telemetry Logging

### 対象項目(p2_telemetry_gap_register.csv の4件)

1. distance_to_hs_price @hedge(hedge_too_late 判定用)
2. worst_floating_pl(basket生涯最悪含み損)
3. post_close_move_1h/4h/24h(winner延長判定用)
4. threshold到達→約定確定の3点ログ(時刻・約定時刻・約定価格。M3ギャップ解明用)

### 実施条件(順序固定)

1. **ログ追記のみ**(売買判定・Exit・Hedge・rapid_drop 0.05 に非接触)。
2. 追記後、**非介入確認を再実施**: Shadow OFF vs ON の trade events **byte一致**。
   一致確認前の収集データは使用しない。
3. 収集runは in-sample 期間の再走(Mar–May / June)+ W3窓。**July W2 には触れない**
   (W2 は 2026-08-01 以降に完結分のみ、事前登録条件のまま評価)。
4. 納品は既存契約どおり: ZIP + SHA256 manifest + extraction_report、
   push後に合図 → code側で SHA照合 → 同一性ゲート → 再審査。

### W3完了後に開く審査(この順)

1. **Audit 3 timing 再審査**: hedge_too_late 判定(M1)、hedge不発分析(M2)。
2. **M3 閾値挙動審査**: threshold→実現損失の乖離分解(滑り/ギャップ/確定遅延)。
3. **Audit 5 winner extension 判定**: post_close_move による延長可否
   (cap 420円 × 59.6% 集中の機会損失定量)。
4. 上記3つが出そろって初めて **実Exit設計審査**(それでも実装ではなく設計審査)。

### 実Exit設計審査の前提条件(ゲート)

- M1/M2 の timing 証拠が揃っていること(1・2完了)。
- winner殺しリスクの定量が可能なこと(SIG-RD precision 0.256 の実弾化影響を
  winner分布に対して評価できること)。
- 期待値 −147円/Basket の改善経路が「左裾の縮小」で説明できること
  (「15万円なら勝てる」型の資金論では説明しない)。

## やらないこと(このフェーズで)

- EA/mq5/mqh/EX5 の売買ロジック変更、Exit/Hedge/MA Exit/Event Stop/Pre-Hedge Exit 実装
- rapid_drop 0.05 の再調整・再テスト
- July W2 への接触、W2条件の変更
- OOS効果・実装後利益・資金額での勝敗の主張
