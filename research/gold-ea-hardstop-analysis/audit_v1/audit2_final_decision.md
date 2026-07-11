# audit2_final_decision.md — Audit 2 判定

date: 2026-07-11
scope: in6run(in-sample diagnostic only)を主。june_post/pooled は参照。
入力: audit2_basket_level_exposure_proxy.csv / audit2_basket_level_exposure_summary.md /
audit2_evidence_limitation_statement.md

## 判定(2軸に分離)

exposure amplification は「何を測るか」で証拠状態が分かれるため、単一判定ではなく
**次元別に確定**する。

### 軸A: position/lot exposure amplification(add-entry・grid・lot 積み増しによる損失増幅)
**判定 = `AUDIT2_POSITION_LEVEL_DATA_REQUIRED`**

- 根拠: 必要列(position_pl_final / max_positions / total_entries / max_lot_sum /
  positions_at_hs / lot_sum_at_hs)が **全MISSING**。snapshot の positions/lot は
  **degenerate定数(1 / 0.01)** で識別力ゼロ。
- したがって「エントリ/ロットの積み増しが損失を増幅した」は
  **定量・定性ともに証拠不能**。0 代替も外挿もしない。
- 解消には W3/v1.4 で当該列の実値ログ追加が必要(実装ではなく記録)。

### 軸B: basket-level 構造的偏り(滞留時間・hedge関与・SIG-RD選別・損失規模)
**判定 = `AUDIT2_BASKET_LEVEL_PROXY_SUPPORTED`**(構造偏りのみ、position寄与は主張しない)

- 根拠(in6run、実変動列):
  - HardStop の duration 中央 **91.8h** vs Non-HardStop **0.09h**(約900倍)。
  - HardStop の hedged率 **0.703** / SIG-RD率 **0.919** vs Non-HardStop 0.035 / 0.244。
  - SIG-RD present の HardStop率 **0.256** vs absent **0.010**(約25倍)。
  - 構造分離は大 n(37 vs 405)で明確、LOW_N ではない。
- **ただし SUPPORTED の対象は「時間/構造の偏り」に限定**。これは
  exposure-TIME(滞留)と hedge/SIG-RD 選別の偏りであって、
  **position本数・lot の増幅ではない**(それは軸A=DATA_REQUIRED)。

## 補足所見(判定を強めも弱めもしないが記録)

- HardStop の 2 原型: **長期 giveback 型(~141h, hedge時 -2,985)** と
  **高速 blowup 型(~0.63h, 非hedge, 11件)**。最終 hs_loss は両型とも ~-3,800 で同規模。
  → **「長く抱えるほど損失が大きい」という単純な time-amplification は否定される**
  (高速型も同規模)。損失規模は滞留時間で説明できず、別の(観測不能な)要因に依存。
  この点は「exposure-time が損失を増幅する」という素朴仮説への **反証** として重要。

## プロジェクト全体判定への寄与(Spec §6候補)

- **CAPITAL_BUFFER_PLUS_LOSS_CONTROL_REQUIRED**: 補強。損失は滞留時間でも
  position数でも単純説明できず(軸B反証 + 軸A証拠不能)、資金buffer単独では
  左裾を制御できない(Audit 4 と整合)。
- **EXPOSURE_AMPLIFICATION_AS_HARDSTOP_DRIVER**: **保留(UNDETERMINED)**。
  position/lot 増幅が driver か否かは軸A=DATA_REQUIRED のため確定できない。
  観測できるのは「HardStop は長期・hedged・SIG-RD の構造群」という選別だけ。
- SIG-RD の役割(Audit 1 と一致): 長期化・HardStop化リスク群の **early warning**。
  Exit条件ではない(present群でも 74% は勝って終わる)。

## 固定事項

- position-level exposure amplification は **EVIDENCE_UNAVAILABLE のまま**。
- 個別 entry が損失を増幅した、とは断定しない。
- 全結果は in-sample diagnostic(june_post/pooled は post-sample含む)。
  実 Exit 設計審査・July W2 条件に影響しない。実装系フラグ全 false。
- rapid_drop 0.05 不変更。「15万円なら勝てる」不記載。
