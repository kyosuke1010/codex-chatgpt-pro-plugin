# current_ea_risk_summary.md

データ出典: SESSION_REPORTED_AGGREGATE(タスク指示 セクション0)。
本workspaceでの独立再計算は入力成果物不在のため未実施。数値は報告値の転記であり、
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

- Hedged HardStop 26件が最大の損失源。Hedgeが発動してもなおHardStopへ到達している。
  つまり「Hedgeが遅い」「Hedge後にgivebackが発生する」のいずれか(または両方)が疑われるが、
  その切り分けはBasket単位の時系列(hedge time / P/L at hedge / post-hedge best recovery)が
  必要であり、本workspaceでは再計算不能(hardstop_root_cause_rebuild.csv スキーマ参照)。
- Non-Hedged HardStop 11件はHedgeに入る前に終わっている。Pre-Hedge警告
  (M15逆クロスは11件中7件で事前Signalあり)の活用余地がある。

## 3. TA9だけでは足りない理由

TA9はPost-Hedge損失圧縮候補であり、対象はHedged HardStopのHedge後部分に限られる。

- Non-Hedged HardStop 11件(約-54,275円)には原理的に届かない。
- Hedged HardStop 26件についても、Hedge時点で既に損失が支配的なBasket
  (loss already dominant before hedge)にはPost-Hedge圧縮の効果が薄い。
- したがってTA9は左裾対策の一部品であり、単独では根本対策として不足
  (既知判断と整合)。

## 4. MA観測の現状評価(既報告値)

- M15逆クロスはHardStop 37件中29件を事前カバー(coverage 78.4%)。
- rescue local diagnostic +63,961円 vs HTE Kill -20円(1件)、Winner truncation 0件。
- best overlay候補(M30 regime + M15 cross + M5 pullback)one-step効果 +29,585円、
  harm/gross benefit 0.049。
- ただしこれは **in-sample one-step Basket診断** であり、実装後利益でもOOS効果でもない。
  full EA counterfactual(そのBasketを消した後の後続Basket連鎖の変化)は主張できない。

## 5. リスク上の注意

- unresolved 3 BasketはCENSOREDとして扱い、勝ち負けどちらにも算入しない。
- commissionは不明のためNA(0扱い禁止)。one-step効果はすべてex-commission。
- run 6本 / capital群のin-sample診断であり、run別・capital別依存の再確認は
  入力成果物の再配置後に行う。
