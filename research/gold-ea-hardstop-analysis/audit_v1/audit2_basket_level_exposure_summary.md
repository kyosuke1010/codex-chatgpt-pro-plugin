# audit2_basket_level_exposure_summary.md — Audit 2(Basket単位 exposure proxy)

date: 2026-07-11
source: extraction_bundle_v1(core CSV)+ v1.3 signals(SIG-RD)
scope: 3系統(in6run / june_post / pooled)。in6run のみ in-sample diagnostic only。
status: **BASKET-LEVEL PROXY ONLY**。position-level exposure amplification は
EVIDENCE_UNAVAILABLE(固定)。個別 entry の損失増幅は断定しない。
全数値は診断用。採用判断・OOS効果・実装後利益・「15万円なら勝てる」を主張しない。

## 前提(データ制約の確定)

本 bundle で **直接 exposure 列は全て取得不能**:

| 列 | ソース | 充足 | 扱い |
|---|---|---|---|
| position_pl_final | entries.csv | 0/526 | EVIDENCE_UNAVAILABLE |
| max_positions | baskets.csv | 0/526 | EVIDENCE_UNAVAILABLE |
| total_entries | baskets.csv | 0/526 | EVIDENCE_UNAVAILABLE |
| max_lot_sum | baskets.csv | 0/526 | EVIDENCE_UNAVAILABLE |
| positions_at_hs | hardstops.csv | 0/43 | EVIDENCE_UNAVAILABLE |
| lot_sum_at_hs | hardstops.csv | 0/43 | EVIDENCE_UNAVAILABLE |
| positions_at_fire / lot_sum_at_fire / hedge_lot | snapshots | **DEGENERATE定数** (全て 1 / 0.01) | 識別力なし |
| margin_level_at_hedge | hedges.csv | 48/48 だが全て **0.00 placeholder** | EVIDENCE_UNAVAILABLE |

→ **grid本数・lot積み増しの増幅** は本 bundle では算出不能。
実変動が残る列(final_pl / hs_loss / duration / hedge_fired / basket_pl_at_hedge /
post_hedge_max_recovery_pl / SIG-RD fire / scope)だけで **構造的偏り** を診断する。

## Table 1: HardStop vs Non-HardStop(構造分離)

| scope | group | n | final_pl中央値 | duration中央値(h) | hedged率 | SIG-RD率 |
|---|---|---|---|---|---|---|
| in6run | HardStop | 37 | **-3,755** | **91.8** | 0.703 | 0.919 |
| in6run | Non-HardStop | 405 | +401 | **0.09** | 0.035 | 0.244 |
| june_post | HardStop | 6 | -4,344 | 91.1 | 1.000 | 0.667 |
| june_post | Non-HardStop | 78 | +400 | 0.13 | 0.026 | 0.141 |
| pooled | HardStop | 43 | -3,917 | 91.8 | 0.744 | 0.884 |
| pooled | Non-HardStop | 483 | +400 | 0.10 | 0.033 | 0.228 |

- **duration が最強の構造判別子**: HardStop basket は Non-HardStop の
  約 **900倍** 長く市場に滞留(91.8h ≈ 3.8日 vs 0.10h ≈ 6分)。
  → 見えているのは **exposure-TIME(滞留時間)の偏り** であって、
  position本数・lot の増幅ではない(そちらは EVIDENCE_UNAVAILABLE)。
- HardStop は高確率で **hedged(74%)かつ SIG-RD発火(88%)**。
  Non-HardStop は hedged 3% / SIG-RD 23%。構造分離は明確。

## Table 2: Hedged HardStop vs Non-Hedged HardStop(2つの原型)

| scope | group | n | hs_loss中央値 | duration中央値(h) | pl@hedge中央値 | SIG-RD率 |
|---|---|---|---|---|---|---|
| in6run | Hedged_HS | 26 | -3,746 | **141.7** | -2,985 | 0.885 |
| in6run | NonHedged_HS | 11 | -3,825 | **0.63** | (hedge行なし) | 1.000 |
| pooled | Hedged_HS | 32 | -4,018 | 140.9 | -3,169 | 0.844 |
| pooled | NonHedged_HS | 11 | -3,825 | 0.63 | (hedge行なし) | 1.000 |

- **2つの HardStop 原型が明確に分離**:
  1. **Hedged 型(長期 giveback)**: 中央 ~141h(≈6日)滞留。hedge時点で既に
     floating ≈ -3,000。hedge後も回復しきれず最終 hs_loss ≈ -3,746。
  2. **Non-Hedged 型(高速 blowup)**: 中央 **0.63h(≈38分)** で HardStop 到達。
     hedge を挟まず一気に -3,825。11件全て SIG-RD 発火(rapid drop)。
- **両型とも最終 hs_loss はほぼ同規模(~-3,800)** だが exposure-time 経路は正反対。
  → 「長く持つほど損が大きい」という単純な time-amplification は **成立しない**
  (高速型も同規模損失)。損失規模は滞留時間ではなく別要因に支配される可能性。
- margin_level_at_hedge は 0.00 placeholder のため hedge時 margin は EVIDENCE_UNAVAILABLE
  (Audit 4 の equity-series 推定 min≈2,700% と別ソース。row値は使わない)。
- distance_to_hs_price 全MISSING → hedge timing は **NOT_COMPUTABLE**(Audit 3 と同じ制約)。

## Table 3: SIG-RD present vs absent(exposure-time proxy)

| scope | group | n | final_pl中央値 | duration中央値(h) | HardStop率 |
|---|---|---|---|---|---|
| in6run | SIG-RD present | 133 | +302 | **1.43** | **0.256** |
| in6run | SIG-RD absent | 309 | +401 | 0.05 | 0.010 |
| pooled | SIG-RD present | 148 | +302 | 1.46 | 0.257 |
| pooled | SIG-RD absent | 378 | +400 | 0.06 | 0.013 |

- **SIG-RD 発火 basket は滞留時間が桁違いに長く(1.46h vs 0.06h)、
  HardStop率が ~20倍(25.7% vs 1.3%)**。SIG-RD は「早期に損側へ滑り、
  その後長く抱える basket」を選別している(Audit 1 の high-recall/low-precision と整合)。
- ただし SIG-RD present でも最終的に 74% は BasketClose 勝ち(+302中央)。
  → SIG-RD は「長期化・HardStop化リスクの高い群」を示すが、
  大半はまだ勝って終わる = **警告であって Exit条件ではない**。

## 構造診断のまとめ(position-level を主張しない範囲)

1. HardStop は **長期滞留 × hedged × SIG-RD発火** の basket に強く偏る(構造分離は明確)。
2. HardStop には **長期 giveback 型** と **高速 blowup 型** の2原型があり、
   最終損失は同規模。滞留時間だけでは損失規模を説明できない。
3. **position本数・lot 積み増しが損失を増幅したか** は、直接列が全MISSING/degenerate の
   ため **判定不能(EVIDENCE_UNAVAILABLE)**。本 Audit は time/構造の偏りまでしか見えない。
