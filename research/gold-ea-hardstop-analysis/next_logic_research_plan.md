# next_logic_research_plan.md — 次期研究計画

## 全体方針(段階契約)

1. **第一段階**: HardStop左裾の観測強化。Pre-Hedge警告(Non-Hedged 11件系)と
   Hedged HardStopのgiveback(26件系)を、Exitを実装せずにShadowで層別する。
2. **第二段階**: M15逆クロスを「危険状態のShadow Signal」として蓄積する
   (Exitではない)。M30 regime文脈・M5 proxy・persistence・recrossを併記。
3. **第三段階**: HTE / Recovery / BasketClose / Winner保護ゲート
   (ma_exit_candidate_safety_rules.md G1〜G14)の通過率と
   blocking_gates分布を監査し、保護条件を固める。
4. **第四段階**: prospective(future)データ蓄積とOOS / future native tick検証。
5. **第五段階**: そこで初めて Pre-Hedge Exit / Hedge Unwind / TA9 / MA Exit の
   実装候補選定を行う。

**既存6runのin-sample診断だけで実Exit実装へ進まない**(絶対条件)。

## Phase G effect_class 定義(充填時に使用)

one_step_effect_ex_commission_yen = candidate_profit_swap_yen − actual_final_profit_swap_yen

| effect_class | 条件 |
|---|---|
| HARDSTOP_RESCUE | actual=HARDSTOPかつeffect > 0 |
| HARDSTOP_NO_BENEFIT | actual=HARDSTOPかつeffect <= 0 |
| HTE_KILL | actual=HTEかつeffect < 0 |
| RECOVERY_KILL | actual=RECOVERY_CLOSEかつeffect < 0 |
| BASKETCLOSE_KILL | actual=BASKET_CLOSEかつeffect < 0 |
| WINNER_TRUNCATION | actual final P/L > 0 かつ candidate P/L < actual(勝ちの切り捨て) |
| NON_HARDSTOP_HARM | 上記以外でeffect < 0 |
| NON_HARDSTOP_BENEFIT | 上記以外でeffect > 0 |
| UNRESOLVED_CENSORED | unresolved 3件およびSIGNAL_CENSORED |

## 直近のブロッカーと解除順序

1. **入力成果物の再配置**(input_artifact_manifest.csv ART01〜ART12)
   → Phase B/F/GのCSV充填、HTE Kill 1件のトレース、run別/capital別依存の再確認。
2. **Offline Overlay pipelineの実装**(offline_overlay_pipeline_spec.md準拠)
   → Stage 0〜7、決定性・監査項目込み。
3. **Shadow Phase 2 prospective収集**(selected_next_design_freeze.md準拠)
   → EA変更なし。将来期間のSnapshot+バーデータに同一pipelineを適用。
4. **OOS判定**: in-sample(既存6run)とprospective期間を厳密に分離。
   prospective期間のharm/gross benefit、HardStop coverage、
   winner truncation、kill件数がin-sample診断と整合するかを判定。
5. 整合した場合のみ、Phase Iの次の設計Freeze(Exit候補の実装設計)へ進む。

## 明示的にやらないこと(この計画の期間中)

- TA9実決済 / M15逆クロスExit / MA Cross Entry / Event Stop / Hedge Gate /
  Pre-Hedge Exit の実装
- 既存Close経路(HardStop / DefenseHedge / Recovery / BasketClose / HTE)への変更
- 実口座 / live / demo forward への移行
- 条件・閾値の既存6runへの合わせ込み
