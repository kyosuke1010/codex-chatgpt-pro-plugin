# current_ea_risk_summary.md

データ出典: INGESTED_RECOMPUTED_20260702(input_artifacts/ 取り込み後にBasket単位で
独立再計算済み。Hedged 26/-130,403円・Non-Hedged 11/-54,275円は報告値と完全一致)。
本文書は「本番期待利益」をいかなる意味でも主張しない。

## 1. 現行EAがなぜ負けているか(構造)

- Basket勝率は89.07%と高いが、payoff ratio 0.0836(平均勝ち+352.27円 vs 平均負け-4,211.94円)。
- expectancy = -146.78円/Basket。勝率でpayoffの崩壊を補えていない。
- net profit -64,436円 / gross loss -202,173円。

損失の集中構造:

| セグメント | Basket数 | 損失額 | gross loss比 |
|---|---|---|---|
| HardStop全体 | 37 | -184,678円 | 91.35% |
| うち Hedged HardStop | 26 | -130,403円 | 64.5% |
| うち Non-Hedged HardStop | 11 | 約-54,275円 | 26.8% |
| 非HardStop負け | 11 | 約-17,495円 | 8.65% |

結論: **負けの原因はほぼ単一で、HardStop左裾である。**
非HardStopの負けは全体の1割未満であり、現段階の研究資源をそこへ割く根拠はない。

## 2. HardStop左裾の内訳と含意

- **確定(Phase B充填済み)**: Hedged HardStop 26件は全件
  LOSS_DOMINANT_BEFORE_HEDGE(|loss_before_hedge| >= |loss_after_hedge|)。
  「Hedge後giveback」ではなく、**Hedge発動前の損傷が主因**。
  したがってレバーの本丸はPre-Hedge Damage Control。
- Non-Hedged HardStop 11件はHedgeに入る前に終わっている(M15単独の事前Signalは3/11、
  いずれかのTFで7/11、M5は5/11)。
- 警告なし急落型4件 / -29,439円(gross lossの14.6%)は全候補・全TFで事前Signalなし、
  全件Event Window外。closed-bar MA系では構造的に救えない残余。

## 3. TA9だけでは足りない理由

TA9はPost-Hedge損失圧縮候補であり、対象はHedged HardStopのHedge後部分に限られる。

- Non-Hedged HardStop 11件(約-54,275円)には原理的に届かない。
- Hedged HardStop 26件についても、Hedge時点で既に損失が支配的なBasket
  (loss already dominant before hedge)にはPost-Hedge圧縮の効果が薄い。
- したがってTA9は左裾対策の一部品であり、単独では根本対策として不足
  (既知判断と整合)。

## 4. MA観測の現状評価(再計算済み・全候補)

ma_candidate_comparison.csv と本repo再計算(ma_one_step_effect_rebuild.csv 364行、
one-step恒等式違反0件)より:

| 候補 | coverage | rescue | BC Kill | 合計 | harm/gross | 正run |
|---|---|---|---|---|---|---|
| M15素 | 29/37 | +63,961 | **-56,597** | +17,141 | 0.768 | 4/6 |
| M15+M30 adverse | 26/37 | +28,087 | -7,874 | +25,560 | 0.236 | 6/6 |
| combo(M30+M15+M5) | 26/37 | +27,895 | -1,527 | +29,585 | 0.049 | 6/6 |
| M15+M5 proxy | 27/37 | +39,097 | -19,000 | +28,274 | 0.402 | 4/6 |
| M5単独 | 31/37 | +85,598 | -122,326 | **-16,778** | 1.159 | 3/6 |
| M30 entry mismatch | 2/37 | +6,172 | -14,802 | -8,630 | 2.398 | 1/6 |

- 「rescue +63,961円」はM15素の救済側のみの値であり、同じ条件でBasketClose勝ち
  (平均+400円前後×26件)を大量に切るため、**素のM15 Exitは成立しない**。
- combo(+29,585円はcensored込み、censored除外では+26,395円)が唯一
  harm/gross 5%未満かつ6/6run正だが、**post-hedge only比率0.94**であり
  Pre-Hedge損傷制御には使えない。
- 「Winner truncation 0件」の定義は「Signal時点で含み益だった勝ちBasketの切り捨てが0件」。
  Signal時点は含み損でその後回復して勝ったBasketのkillは26件(M15素)存在し、
  それがBC Kill -56,597円の実体である。
- HTE Kill 1件/-20円はHTE_BECAME_ELIGIBLE_LATER型(hte_kill_trace.md)。
- ただしこれらはすべて **in-sample one-step Basket診断** であり、実装後利益でも
  OOS効果でもない。full EA counterfactualは主張できない。

## 5. リスク上の注意

- unresolved 3 BasketはCENSOREDとして扱い、勝ち負けどちらにも算入しない。
- commissionは不明のためNA(0扱い禁止)。one-step効果はすべてex-commission。
- run 6本 / capital群のin-sample診断であり、run別・capital別依存の再確認は
  入力成果物の再配置後に行う。
