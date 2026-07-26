# audit2_final_decision.md — Audit 2 判定

date: 2026-07-11(v1.4到着により同日改訂。改訂前判定は §旧判定 に保存)
scope: in6run(in-sample diagnostic only)を主。june_post/pooled は参照。
入力: audit2_basket_level_exposure_proxy.csv / audit2_basket_level_exposure_summary.md /
audit2_evidence_limitation_statement.md / **audit2_axisA_position_level.csv(v1.4)**

## 改訂判定(v1.4 deal-level到着後)

### 軸A: position/lot exposure amplification
**判定 = `AUDIT2_BASKET_LEVEL_PROXY_SUPPORTED` を position-level で確定に格上げ:
増幅は「発生していない」(AMPLIFICATION_ABSENT_BY_OBSERVATION)**

v1.4(既存Trade Events 3,498行のbasket割当再構成、Tester再実行なし・EA無変更、
SHA B6B2..4800 一致)により、旧判定 `AUDIT2_POSITION_LEVEL_DATA_REQUIRED` は解消:

| 検証 | 結果 |
|---|---|
| 同一性 | leg損益合計 vs v1 final_pl: **521/521一致**(残5=DEINIT想定内) |
| 積み増し(add-entry) | **全3,498イベントで MainDirectionPositions max=1** — 一度も発生せず |
| 同時ポジション最大 | **2(main 1 + defense hedge 1)** が全runの上限 |
| lot増幅 | **OrderLots 全て 0.01** — スケーリングなし |
| margin実値 | HEDGE時点 min **2,406%**(placeholder 0.00 解消)。200%割れ皆無 |

**結論: 「エントリ/ロット積み増しによる損失増幅」は仮説ごと棄却(観測上不存在)。**
HardStop損失は grid でも lot でもなく、**1+1構成のまま床(HardStop閾値)まで
落ちる**ことで発生している。

### 新たに定量化された本質: 利益相殺(profit-offset)構造

hedged HardStop 32件の leg分解:
- **グロス両脚 中央 ±34,522円 に対しネット −4,018円(gross/net ≈ 7.9倍)**
  (極端例: 片脚 +106,701 / 逆脚相殺でネット −8,759)
- hedge はネット損失を凍結するが、その後も両脚は膨張を続け、
  回復せず HardStop 閾値で確定する(LOSS_DOMINANT_BEFORE_HEDGE と整合)。
- non-hedged 11件は gross=net(中央 −3,825、単脚のまま高速でHS到達)。

→ EA名の由来である「利益相殺生き残り型」の生存メカニズムは position-level で
実証されたが、**同時にその代償(凍結された損失は縮まない)も実証された**。

## 旧判定(v1.4到着前。記録として保存)

### (旧)判定(2軸に分離)

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
