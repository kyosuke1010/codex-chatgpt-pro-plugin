# audit1_results_summary.md — Audit 1 結果(3スコープ)

date: 2026-07-03
source: extraction_bundle_v1 (v1+v1.1+v1.2, SHA 3件一致)
scope decision: 3系統分割(in6run / june_post / pooled) — ユーザー判断
tag: in6run のみ in-sample diagnostic only。june_post/pooled は post-sample を含む。
全数値は診断用であり、採用判断・OOS効果・実装後利益・「15万円なら勝てる」を主張しない。

## §0.5 入力検証(全PASS、1点LIMITATION)

- ZIP SHA 3件一致(v1 F9F1.. / v1.1 DA8B.. / v1.2 5FE9..)
- July混入 0(root_snapshot_rows_excluded_at_or_after_2026-07-01=0)
- close_reason基準: in6run win 391/442=0.885、pooled 467/526=0.888(~0.89 整合)
- SIG-MA/SIG-RD重複(pooled): 観測 33/106/24 = 報告値一致
- SIG-LSB: 定義不明のため未実装 → 3シグナルで実行
- scoped分母: SIG-SLPカバレッジ=513。除外13件 = pre-hedge snapshot欠損の
  HardStop 13件そのもの(in6run 7 + june_post 6)
- **LIMITATION**: june_post HardStop 6件は全て除外13に含まれる(hedged変種の
  basket_id linkage)。このbundleでは june_post の HardStop precision/recall は
  計算不能。抽出側で hedged basket_id の結合を直せば解消(実装ではなく抽出修正)。

## Audit 1 主要結果

HardStop分母(scoped): in6run=30、june_post=0、pooled=30。

| scope | group | fired | TP | recall | precision | precision_margin | LOW_N |
|---|---|---|---|---|---|---|---|
| in6run | SIG-MA | 29 | 3 | 0.100 | 0.103 | +0.229 | LOW_N |
| in6run | SIG-RD | 96 | 11 | **0.367** | 0.115 | +0.242 | — |
| in6run | SIG-MA∩SIG-RD | 20 | 3 | 0.100 | 0.150 | +0.257 | LOW_N |
| june_post | (全群) | — | 0 | NA | 0 | NA | LOW_N |
| pooled | SIG-MA | 33 | 3 | 0.100 | 0.091 | +0.216 | LOW_N |
| pooled | SIG-RD | 106 | 11 | 0.367 | 0.104 | +0.231 | — |
| pooled | SIG-MA∩SIG-RD | 24 | 3 | 0.100 | 0.125 | +0.232 | LOW_N |

SIG-SLP: 記述統計のみ(scoped 513、precision/recall・閾値再テストなし)。

## 読み取り(診断のみ)

1. **SIG-RD だけが非LOW_N**(TP=11)。in6run で recall 0.367 だが precision 0.115
   — 30 HardStop中11件を先行する一方、96 basketで発火し大半が非HardStop。
   「Exit条件ではなく警告」という本プロジェクトの一貫した性質と整合。
2. **SIG-MA / 複合は LOW_N(TP=3)** — 単独では優先順位判定に使わない(§1規定)。
3. **precision_margin は全群で正(+0.21〜+0.26)** だが、precision自体が低く、
   p* が負であることに起因する(S=hs_loss−pl_at_fire は理論全デリスク上限で
   実際のClose Priority/Hedge反実仮想ではない)。よって margin>0 を
   「採用可」とは読まない。あくまで break-even 診断。
4. **june_post は HardStop scoped=0** のため HardStop系は評価不能(上記LIMITATION)。

## 次段

- Audit 4→2→3→5 は各設定確定後に同bundleで実行(実行順 Spec §6.2: 4→1→2→3→5)。
- june_post HardStop linkage を使うなら抽出修正版が必要(このbundleでは不可)。
- 本結果は in-sample診断であり、実Exit設計審査・July W2 に影響を与えない。
