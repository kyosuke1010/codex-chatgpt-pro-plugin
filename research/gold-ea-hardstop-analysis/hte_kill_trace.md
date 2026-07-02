# hte_kill_trace.md — HTE Kill 1件の完全トレース(INGESTED / 再計算済み)

status: TRACED(2026-07-02、入力成果物取り込み後に再計算・照合完了)
sources: ma_m15_hte_kill_design_trace.csv(設計監査)、ma_one_step_basket_effect.csv、
本repoの ma_one_step_effect_rebuild.csv(再計算で -20円 を再現)

## 対象Basket

| 項目 | 値 |
|---|---|
| basket_uid | GOLD#2026.04.21T11:19:59#140#HEDGED#2 |
| run / capital | ML_C_SHADOW_ON_50000_MAR_MAY_M5_20260301_20260529 / 50000 |
| direction | SELL(original) |
| basket start | 2026-04-21 11:19:59 |
| hedge start | 2026-04-21 11:43:30 |
| M15 source bar | 2026-04-21 12:30:00(close 12:45:00) |
| signal available | 2026-04-21 12:45:00(closed-bar後の最初のSnapshot) |
| P/L at signal | -1,501円(distance to HardStop 397.72円) |
| HTE_eligibility_at_signal | **false** |
| 実際のHTE close | 2026-04-21 14:43:30 / **-1,481円** |
| one-step効果 | -1,501 − (-1,481) = **-20円** |
| 分類 | HTE_BECAME_ELIGIBLE_LATER(Signal約2時間後にHTE成立) |

## 重要な訂正(設計への影響)

**旧版の本文書は「ゲートG8によりこの種のkillは発生自体をゼロ化する設計」と
記載していたが、これはデータと矛盾するため撤回する。**

実データでは、Signal時点の HTE_eligibility は false(かつknown)であり、
G8(HTE eligibility=false and known)を**通過する**。killが生じたのは
HTEが**Signalの後で**eligibleになったためである。つまりG8は
「Signal時点でHTEが取れる局面を奪う」ことは防ぐが、
「後からHTEになるBasketを先に閉じてしまう」ことは防げない。

### 正しい整理

1. G8が防ぐもの: Signal時点でHTE eligibleな局面での候補発火(構造的にゼロ化)。
2. G8が防げないもの: 将来eligible化(本件)。これは原理的に事前判定不能であり、
   残余リスクとして扱う。
3. 本件の残余コストは -20円/1件(M15)。M5 proxy併用系で2件/-29円、
   M5単独で3件/-42円(ma_candidate_comparison.csv)。いずれも軽微だが、
   HTE到達Basket自体が33 signal行と少なく、**サンプル不足のため
   「HTE安全」とは結論しない**。
4. 緩和候補(実装はしない・観測のみ): persistence条件(SIGNAL_PERSISTED_n)
   併用での遅延判定が将来eligible化との入れ違いを減らすか、
   Shadow Phase 2のprospectiveデータで検証する。

## 受け入れ基準(改訂)

- Signal時点でHTE eligible(true)な局面での候補分類: **0件**(G8で機械検証)
  → 今回の364行では該当0件を確認済み。
- 将来eligible化によるHTE Kill: ゼロ化は要求しない。prospective期間で
  件数・金額を監査し、rescue総額に対する比率が現行(0.03%)から
  有意に悪化しないことを昇格条件とする。
