# audit1_results_summary.md — Audit 1 結果(v1.3 authoritative, 3スコープ)

date: 2026-07-03
source: extraction_bundle_v1_3(SIG-RD/SIG-SLP は v1.3 snapshot、SIG-MA は v1.1 barclose)
status: **V1_3_AUTHORITATIVE**(前回の PROVISIONAL_PENDING_V1_3 を本結果で置換)
scope decision: 3系統分割(in6run / june_post / pooled) — ユーザー判断
tag: in6run のみ in-sample diagnostic only。june_post/pooled は post-sample を含む。
全数値は診断用であり、採用判断・OOS効果・実装後利益・「15万円なら勝てる」を主張しない。
MISSING は EVIDENCE_UNAVAILABLE として記録し補完しない。実装系フラグ全 false。

## §0.5 再検証(v1.3、全PASS)

v1.3 report と実測突合(すべて一致):

| 項目 | 報告値(v1.3 report) | code側実測 | 判定 |
|---|---|---|---|
| coverage(pre-hedge snapshot) | 526/526(in6run 442/442, june_post 84/84) | 526/526 | ✅ |
| uncovered baskets | none | 0 | ✅ |
| SIG-MA baskets(v1.1) | 33 | 33 | ✅ |
| SIG-RD baskets | 148 | 148 | ✅ |
| SIG-SLP baskets | 526 | 526 | ✅ |
| SIG-MA ∩ SIG-RD | 24 | 24 | ✅ |
| July混入(≥2026-07-01) | 0 | 0(report) | ✅ |

- **linkage修正の効果**: v1.3 は basket_uid ベース(GOLD#start_token#sequence)で
  SELL_NET#1(pre-hedge)と HEDGED#2 のsnapshotを**同一 basket_id** に結合。
  これで前回の「除外13件(HardStop の pre-hedge snapshot欠損)」が解消し、
  **Uncovered HardStop = 0/43**(前回 in6run 7 + june_post 6 = 13 → 0)。
- SIG-LSB: 定義不明のため未実装(v1.3 report も同旨)。3シグナルで実行。

## Pre/Post-Hedge 層別(fidelity check = PASS)

fire_time を hedges.csv の hedge_time と突合。**never-hedged basket は全 fire を
pre-hedge 扱い**。

| group | pre-hedge fired baskets | post-hedge fired baskets |
|---|---|---|
| SIG-MA(pooled) | 33 | **0** |
| SIG-RD(pooled) | 148 | **0** |

- **SIG-RD 106→148 の増加は全て PRE-hedge fire**。SIG-RD を持つ hedged basket 42件を
  精査 → **42件すべて fire_time < hedge_time(post-hedge fire = 0)**。
  よって増加分は「hedged-phase の新規発火」ではなく、
  **linkage修正で正しく結合された pre-hedge fire**。元の「pre-hedge slope」定義に
  忠実であることを確認(新条件の追加ではない)。
- main計算は **PRE_HEDGE_ONLY** で実施(post-hedge=0 のため実質全fire)。

## Audit 1 主要結果(PRE-HEDGE only、分母=全HardStop 43)

HardStop分母(全件): in6run=37 / june_post=6 / pooled=43。

| scope | group | fired | TP | recall | precision | precision_margin | LOW_N |
|---|---|---|---|---|---|---|---|
| in6run | SIG-MA | 29 | 3 | 0.081 | 0.103 | +0.229 | LOW_N |
| in6run | **SIG-RD** | 133 | **34** | **0.919** | 0.256 | +0.243 | — |
| in6run | SIG-MA∩SIG-RD | 20 | 3 | 0.081 | 0.150 | +0.257 | LOW_N |
| june_post | SIG-MA | 4 | 0 | 0.000 | 0.000 | NA | LOW_N |
| june_post | **SIG-RD** | 15 | **4** | **0.667** | 0.267 | +0.290 | LOW_N |
| june_post | SIG-MA∩SIG-RD | 4 | 0 | 0.000 | 0.000 | NA | LOW_N |
| pooled | SIG-MA | 33 | 3 | 0.070 | 0.091 | +0.216 | LOW_N |
| pooled | **SIG-RD** | 148 | **38** | **0.884** | 0.257 | +0.247 | — |
| pooled | SIG-MA∩SIG-RD | 24 | 3 | 0.070 | 0.125 | +0.232 | LOW_N |

- fires/hour(滞留時間正規化, median): SIG-RD ≈ 0.012/h(=約3.6日に1発火の低頻度で
  basket寿命を通じ広く分布)、SIG-MA ≈ 0.485/h、複合 ≈ 0.970/h。
- lead(earliest pre-hedge fire → hs_time, median): SIG-RD ≈ **5,227分(≈3.6日)**、
  SIG-MA ≈ 94分。→ SIG-RD は「HardStop直前の tight precursor」ではなく
  **early warning**(basket寿命の早期に発火し、その後HSまで長時間)。
- SIG-SLP: 記述統計のみ(526 basket、precision/recall・閾値0.05再テストなし=FROZEN)。

## 読み取り(診断のみ)

1. **linkage修正で SIG-RD の recall が劇的に上昇**(in6run 0.367 → **0.919**、
   pooled → **0.884**)。前回の低recallは除外13件(HardStop欠損)の産物で、
   linkage修正後は **43 HardStop 中 38件が pre-hedge SIG-RD を先行**。
   → SIG-RD は HardStop の「網羅的 early warning」として機能している。
2. **precision は依然低い(0.256)**。148 basketで発火し 110件は非HardStop。
   「Exit条件ではなく警告」という本プロジェクトの一貫所見と整合。高recall・低precision。
3. **june_post も HardStop 4/6 を捕捉**(recall 0.667)。前回は linkage破損で 0 だったが
   v1.3 で **june HardStop precision/recall が算出可能**に。ただし TP=4 で LOW_N。
4. **precision_margin は全群で正(+0.22〜+0.29)** だが、これは p*(=C/(C+S))が
   ほぼ0/負であることに起因する break-even 診断にすぎない。S=hs_loss−pl_at_fire は
   **理論的な全デリスク上限**であって実際の Close-Priority/Hedge 反実仮想ではない。
   → margin>0 を「採用可」と読まない。あくまで診断。
5. **SIG-MA / 複合は LOW_N(TP=3)** — 単独では優先順位判定に使わない(§1規定)。

## 判定入力(Spec §6候補への寄与)

- **PRECURSOR_EXISTS(SIG-RD)**: 支持。pooled recall 0.884 / june 0.667 で HardStop を
  広く先行。ただし **precision 0.26・lead 中央値3.6日** のため「tight exit trigger」ではなく
  **早期警告**。Exit直結ではなく、監視・段階的デリスクのトリガ候補。
- **HIGH_RECALL_LOW_PRECISION**: 支持(発火の3/4は非HardStop)。単独Exit化は
  winner殺し(prec 0.26)リスク大 → 他条件との合成が前提。
- **margin>0 は break-even診断のみ**(S=理論上限、反実仮想ではない)。採用根拠にしない。
- june_post 系は TP=4 で LOW_N。方向は in6run と整合(recall高/prec低)。

## 未実施 / 保留

- Audit 2(Exposure Amplification): **依然ブロック**。v1.3 は signals_derived_v1_3.csv と
  report のみのデルタ配信で entries.csv を再配信していないため、
  entries.position_pl_final は **全MISSING(0/526)のまま**。position単位P/Lが必要な
  exposure増幅の定量は EVIDENCE_UNAVAILABLE。basket単位(max_positions/total_entries/
  max_lot_sum)での代替記述は可能 → 次段で判断。
- 本結果は in-sample診断(june_post/pooled は post-sample含む)であり、
  実Exit設計審査・July W2 条件に影響を与えない。固定フラグ全 false。
