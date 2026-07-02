# final_research_decision.md — 最終研究判定

date: 2026-07-02
branch: claude/gold-ea-hardstop-analysis-9aee82

## 判定

**decision_class: M15_REVERSE_CROSS_EXIT_NOT_READY_SHADOW_ONLY**

付帯ステータス:
- workspace_data_status: **INPUT_ARTIFACTS_MISSING_IN_WORKSPACE**
  (Phase B/F/GのBasket単位再計算はMORE_DATA_REQUIRED状態。
  本判定はタスク指示に含まれるSESSION_REPORTED_AGGREGATEを前提とする)
- 選定された最小実装候補: 候補A — M15 Reverse Cross Shadow Phase 2
  (selected_next_design_freeze.md、実Exitなし、Offline Overlay継続)
- 実装許可: なし(implementation_not_allowed_statement.md)

## 判定根拠(必須15項目)

### 1. 現行EAがなぜ負けているか
勝率89.07%に対しpayoff ratio 0.0836(平均勝ち+352.27円 vs 平均負け-4,211.94円)。
expectancy -146.78円/Basket。高勝率でも左裾1本(HardStop)で数十Basket分の
勝ちが消える構造であり、勝率改善ではなく左裾圧縮が唯一の主レバー。

### 2. HardStop左裾の主因
gross loss -202,173円のうちHardStop 37件が-184,678円(91.35%)。
内訳はHedged HardStop 26件/-130,403円が最大で、Hedge発動後もなお
HardStopへ到達している。Non-Hedged 11件/約-54,275円はHedge前に終わる系。
Hedged側の「giveback vs Hedge遅延」の切り分けはBasket単位時系列の充填待ち。

### 3. TA9だけでは足りない理由
TA9はPost-Hedge圧縮であり、(a) Non-Hedged 11件に原理的に届かず、
(b) Hedge前に損失が支配的なBasketにも効果が薄い。左裾の約3割
(Non-Hedged分)と、Hedged側のPre-Hedge部分が構造的に対象外。

### 4. M15逆クロスが有望な理由
HardStop 37件中29件で事前Signal(coverage 78.4%)。Non-Hedged 7/11、
Hedged Pre-Hedge 20/26と、Hedge発動前の警告として機能している。
one-step局所診断でrescue +63,961円に対しHTE Kill -20円・Winner truncation 0件、
best候補(M30文脈併用)でharm/gross benefit 0.049。6run全てで正、
2 capital群で正と、run/capital依存の兆候も現時点では見えない。

### 5. M15逆クロスを即Exitにできない理由
上記はすべて**in-sample one-step Basket診断**であり、(a) 実装後利益ではない、
(b) OOS効果ではない、(c) full EA counterfactual(救済したBasketが後続の
Basket生成・MaxPosition・Hedge連鎖に与える影響)を主張できない、
(d) commission NA、(e) 既存6runへの合わせ込みリスクが排除しきれない。
よってExitではなくShadow Signalとして蓄積する。

### 6. HTE Kill 1件の扱い
-20円/1件は規模として軽微だが、サンプル1件では安全と結論しない。
安全ゲートG8(HTE eligibility=falseかつknown)により将来実装では
発生自体をゼロ化する設計とし、入力成果物再配置後に当該1件を
個別トレースする(hte_kill_trace.md)。

### 7. Winner truncationの有無
報告値0件。ただしこれもin-sample診断であり、prospective期間でも
ma_winner_truncation.csv で継続監査する。0件維持が受け入れ条件。

### 8. M30 regimeの使い方
単独Signalではなく**文脈フィルタ**。M15逆クロスにM30 adverse regimeを
重ねるとrescue 26/harm 3と選択性が向上(M5 proxy併用の27/12より良い)。
BULL/BEAR/FLAT_OR_EQUAL/UNKNOWNの4値で、UNKNOWNをFLAT扱いしない。

### 9. M5 retest proxyの限界
現行M5条件は本物のretest failureではなく、逆行フォロースルーの代理指標。
正式名称をM5_REVERSE_FOLLOWTHROUGH_PROXYに固定し、harm増加傾向
(rescue 27/harm 12)を踏まえ、単独昇格を禁止。M30文脈との併用でのみ評価。

### 10. Event Windowとの関係
MA警告なしHardStop 4件(37-33)の説明候補として観測を継続する。
EA NewsBlockとEvent Blackout Auditの突合が未完のため、Event Stopは
実装せず、event_window_state(IN/OUT/UNKNOWN)の記録に留める。

### 11. Offline Overlayを第一候補にする理由
EA変更ゼロで非介入性の実証(6/6 PASS ×3系統)を維持でき、Snapshot×外部MAで
442/442結合済み。同一pipelineをprospective/OOSデータへ適用でき、
in-sampleとOOSの計算系が一致する。

### 12. Runtime MA telemetryを避ける理由
過去にShadowがindicator cacheを汚染した事故があり、EA内のiMA/CopyBuffer等は
cache状態・イベント順序を変え得る。得られる値はオフラインで既に取得可能
であり、便益ゼロ・リスク正(indicator_cache_contamination_risk.md)。

### 13. 次に実装するなら何をShadow化するか
M15 Reverse Cross Shadow Phase 2(候補A)。観測スキーマがhedge_phase・
pl_at_signal・distance_to_hardstop・eligibility群を含むため、
Pre-Hedge Damage Control(候補B)とHedge Transition(候補C)の観測を
同一データから層別でき、変更面積が最小。

### 14. まだ実Exitを実装しない理由
第5項の理由に加え、保護契約(HTE/Recovery/BasketClose/Winner不可侵)の
機械検証がprospectiveデータで未実施であり、安全ゲートG1〜G14の
通過率・blocking_gates分布も未取得。実Exitはこれらの後。

### 15. OOS / future native tick検証が必要な理由
既存6runはin-sampleであり、診断はそのデータで最良に見えるよう
バイアスされ得る(選択バイアス+one-step近似誤差)。また2024 M1は
real tickではなく、外部Tickはbroker-nativeと約定・スプレッド特性が異なる。
実運用に近い将来native tickでrescue/harm/kill/truncationの整合を
確認するまで、いかなる効果も実装根拠にならない。

## 次のアクション(順序固定)

1. 入力成果物(ART01〜ART12)を本ブランチまたは参照可能なパスへ配置
2. Offline Overlay pipeline実装(spec準拠、決定性・監査込み)
3. Phase B/F/G CSV充填 + HTE Kill 1件トレース + run/capital依存再確認
4. Shadow Phase 2 prospective収集開始(EA無変更)
5. prospective整合確認後、OOS/native tick検証 → 初めてExit候補の実装設計へ

## 免責

本文書のいかなる数値・判定も将来の利益を保証しない。
