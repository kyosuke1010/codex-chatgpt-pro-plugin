# hte_kill_trace.md — HTE Kill 1件の扱い

## 既知事実(SESSION_REPORTED_AGGREGATE)

- M15逆クロス one-step診断における HTE Kill: **1件 / -20円**
- 同診断の HardStop rescue: 29件 / +63,961円
- harm / gross benefit(best候補): 0.049081

## 解釈(現段階で言えること)

1. 規模として、HTE Kill -20円はrescue総額の0.03%程度であり、
   in-sample one-step診断上は許容範囲内。
2. ただし「1件しか観測されていない」こと自体が問題である。HTEに到達する
   Basketが少ないサンプルでのkill率推定は分散が大きく、
   **この1件をもってHTE安全と結論しない。**
3. 安全側の設計対応は既に契約化済み: ma_exit_candidate_safety_rules.md の
   G8(HTE eligibility = false かつ known)により、HTEがeligibleな局面では
   候補Exitは構造的に発火しない。つまり将来実装では、この種のkillは
   ゲートで**ゼロ化する設計**であり、-20円の許容ではなく発生自体を防ぐ。

## トレース手順(入力成果物再配置後に実施)

対象1件について以下を成果物化する:

1. basket_uid、run_id、capital_group の特定
2. Signal時点: signal_time / available_time / pl_at_signal_yen /
   hte_eligible の値と、その時点でG8がUNKNOWNだったか false だったか
3. 実際のHTE発動時刻と最終P/L(actual_final_reason=HTE)
4. one-step効果 -20円 の再現計算(candidate P/L − actual final P/L)
5. G8ゲート適用後の再分類: このSignalが future_executable_candidate から
   除外されること(blocking_gates に G8 が記録されること)の確認

## 受け入れ基準(将来の全候補共通)

- ゲート適用後の HTE Kill 期待件数: **0件**(設計上の要求)
- 回帰監査で HTE到達Basketに対する候補Signal発火が1件でも検出された場合、
  当該候補は IMPLEMENTATION_BLOCKED。

現状ステータス: 入力成果物不在のためトレース未実施(BLOCKED_ON_ARTIFACTS)。
