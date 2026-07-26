# final_research_decision.md — 最終研究判定(INGESTED版・改訂2)

date: 2026-07-02(input_artifacts取り込み・Basket単位再計算後に改訂)
branch: claude/gold-ea-hardstop-analysis-9aee82

## 判定

**decision_class: M15_REVERSE_CROSS_EXIT_NOT_READY_SHADOW_ONLY**

副判定: **PREHEDGE_DAMAGE_CONTROL_SHADOW_READY**
(Phase B充填により、Hedged HardStop 26件全件がLOSS_DOMINANT_BEFORE_HEDGEと
確定。Pre-Hedge観測は既存Snapshotフィールドのみで開始可能)

- workspace_data_status: **INGESTED_VERIFIED**(9成果物SHA照合OK、
  Snapshot 169,305 / Basket 442 / RunSummary 6 / HardStop 37 すべて期待値一致)
- 再計算整合: rescue 29件/+63,961円、HTE Kill 1件/-20円、Hedged -130,403円、
  Non-Hedged -54,275円 — 報告値と完全一致。one-step恒等式違反0件。
- 選定候補: M15 Reverse Cross Shadow Phase 2(実Exitなし・Offline Overlay継続)。
  Pre-Hedge層別クエリを第一級の分析対象として含める。
- 実装許可: なし(implementation_not_allowed_statement.md 継続有効)

## 判定根拠(必須15項目・データ確定版)

### 1. 現行EAがなぜ負けているか
勝率89.07%に対しpayoff ratio 0.0836。expectancy -146.78円/Basket。
gross loss -202,173円の91.35%がHardStop 37件に集中(再計算一致)。

### 2. HardStop左裾の主因(確定)
Basket単位充填の結果: **Hedged 26件は全件、損失の過半がHedge発動前に成立**
(LOSS_DOMINANT_BEFORE_HEDGE 26/26)。Non-Hedged 11件はHedge前に終了。
つまり左裾の主因は「Hedge後のgiveback」ではなく**Pre-Hedge損傷**。
残余として警告なし急落型4件/-29,439円(全件Event外、entry→HardStop 14〜105分)。

### 3. TA9だけでは足りない理由(強化)
TA9はPost-Hedge圧縮だが、Phase B確定によりHedged 26件ですら損失の過半が
Hedge前に成立している。Non-Hedged 11件には原理的に届かない。
TA9の可動域は従来想定よりさらに小さい。

### 4. M15逆クロスが有望な理由(限定付き)
coverage 29/37、rescue +63,961円。二峰性のリードタイム(median 8,446分/最短54.8分)
で長期滞留型の初期警告として機能。6run中のHardStopに対する observability は高い。

### 5. M15逆クロスを即Exitにできない理由(データで確定)
素のM15はBasketClose Kill -56,597円を伴い、純効果+17,141円、harm/gross 0.768、
正run 4/6。「救うより壊す方が大きい局面」が明確に存在する。
harm/gross 0.049はM30+M5併用combo限定であり、そのcomboはpost-hedge only 0.94で
Pre-Hedge目的に転用不能。さらに全数値はin-sample one-step診断であり
full EA counterfactualを主張できない。

### 6. HTE Kill 1件の扱い(訂正済み)
実体はHTE_BECAME_ELIGIBLE_LATER(Signal時点はeligibility=false→約2時間後にHTE成立、
-20円)。**ゲートG8では防げない型**であることをトレースで確定し、
旧記述(G8でゼロ化)を撤回。残余リスクとしてprospective監査対象に変更
(hte_kill_trace.md)。

### 7. Winner truncationの有無(定義明確化)
「Signal時点で含み益の勝ちの切り捨て」= 0件(ソース定義・全候補)。
ただし「Signal時点は含み損→回復して勝ったBasketのkill」はM15素で26件/-56,597円
存在し、これが実質的なharmの本体。両定義を成果物で分離した
(ma_winner_truncation.csv はeventual-winner kill 176行を収録)。

### 8. M30 regimeの使い方
文脈フィルタとして有効性がデータで確定: M15素のBC Kill -56,597円→M30併用で
-7,874円、combo で-1,527円まで低減し、6/6run正・LOO最小+19,508〜21,050円。
ただしpost-hedge帯に選択が偏る副作用(0.88〜0.94)を必ず併記する。

### 9. M5 retest proxyの限界(データで確定)
M5単独は合計-16,778円(BC Kill -122,326円)で失格。M15+M5 proxyもharm/gross 0.402で
M30文脈に劣後。ただしM5はcoverage 31/37・pre-hedge率0.18と観測面では最広で、
「警告としてのみ」価値が残る。

### 10. Event Windowとの関係(降格)
HardStop±60分のevent重なりは2/37(-5,931円)。警告なし4件も全件Event外。
Event単独レバーは左裾の主因ではないとデータで確定。NewsBlock整合監査のみ継続。

### 11. Offline Overlayを第一候補にする理由
EA無変更で今回の全再計算が成立した事実そのものが実証。バーデータ(ART12)も
ART06内に確認済みで、同一pipelineをprospectiveへ延長可能。

### 12. Runtime MA telemetryを避ける理由
必要な値はすべてオフラインで取得できた(snapshot join 333/333成立)。
indicator cache汚染リスクを負う便益がゼロ。

### 13. 次に実装するなら何をShadow化するか
M15 Reverse Cross Shadow Phase 2(選定済み)に、Phase Bで確定した
Pre-Hedge層別クエリを追加: (a) Pre-Hedge帯限定のharm再計算、
(b) loss_slope / adverse_movement_speed による急落型4件系の観測、
(c) persistence条件がHTE後発eligible型killと入れ違いを減らすかの検証。

### 14. まだ実Exitを実装しない理由
素のM15は純効果が正でもharm構造が大きく(0.768)、combo はPre-Hedge本丸に
届かない。左裾の主レバー(Pre-Hedge Damage Control)の設計材料が
prospectiveデータ待ちである以上、どのExitも時期尚早。

### 15. OOS / future native tick検証が必要な理由
全効果値はin-sample 6runのone-step診断。BasketClose Killの規模が
候補条件に敏感(M15素-56,597円 vs combo-1,527円)であり、この感度は
overfitの典型的兆候。prospective期間での再現確認なしに実装根拠にならない。

## 次のアクション(順序固定)

1. ~~入力成果物の配置~~ 完了(SHA照合OK)
2. ~~Phase B/F/G CSV充填・HTE Killトレース~~ 完了(本コミット)
3. Shadow Phase 2 prospective収集開始(EA無変更・Offline Overlay延長)
4. Pre-Hedge層別harm再計算 + 急落型slope観測の分析クエリ実装
5. prospective整合確認後、OOS/native tick検証 → 初めてExit候補の実装設計へ

## 免責

本文書のいかなる数値・判定も将来の利益を保証しない。
全効果値はex-commission(commission NA、0埋めなし)。
