# hardstop_research_priority.md(INGESTED / Basket単位再計算済み)

出典: hardstop_root_cause_rebuild.csv(37行充填済み)、hardstop_path_master.csv、
hardstop_event_overlap.csv、ma_candidate_comparison.csv。
旧版(SESSION_REPORTED_AGGREGATEベース)を実データで置換。

## 確定した根本原因分布(37件)

| root_cause_class | 件数 | 損失 |
|---|---|---|
| LOSS_DOMINANT_BEFORE_HEDGE(Hedged) | 26 | -130,403円 |
| NON_HEDGED_HARDSTOP | 11 | -54,275円 |
| RECOVERY_THEN_GIVEBACK | 0(判定可能な範囲で) | — |

**最重要の確定事実: Hedged HardStop 26件は全件、|loss_before_hedge| >= |loss_after_hedge|。**
損失の過半はHedge発動前に既に成立しており、「Hedge後のgiveback」仮説は
主因ではなかった。post-hedge回復系列(best recovery→giveback)は本監査群に
含まれないため厳密なgiveback額はNOT_IN_SOURCE_AUDITだが、before/after分解だけで
Pre-Hedge支配が確定する。

## 優先順位(改訂)

### P0: Pre-Hedge Damage Control観測(対象37件全部)
- Hedged 26件: 損失の過半がHedge前 → Hedge発動「前」の損傷制御が本丸。
- Non-Hedged 11件: そもそもHedge前に終わる。
- 警告リードタイム(M15、rescue行): median約8,446分は長期滞留Basket由来で、
  最短54.8分の急落型も存在(ma_candidate_comparison)。リードタイム分布は二峰性
  であり、「長い滞留の初期警告」と「急落の直前警告」を分けて設計すること。

### P1: M15系Shadow Signal蓄積(coverage 29/37)
- ただし素のM15はBasketClose Kill -56,597円 / harm/gross 0.77 / positive 4/6run。
  Exitではなく危険状態ラベルとしてのみ蓄積。
- M30文脈併用(rescue26/harm3、6/6run正)とcombo(harm/gross 0.049)は
  post-hedge only比率 0.88〜0.94 → **Pre-Hedge目的にはほぼ使えない**。
  Pre-Hedge警告のカバーはM5(pre-hedge率0.18、coverage 31/37)とM15素
  (pre-hedge率0.16)が担うが、両者はharmが大きい。
  → 「Pre-Hedge帯に限定した条件でのharm再計算」がShadow Phase 2の主要クエリ。

### P2: 警告なし急落型 4件 / -29,439円
- 全候補で事前Signalなし、全件Event Window(±60分)外。
- entry→HardStopが14〜105分の急落。closed-bar M15(最短15分遅延)では
  構造的に間に合わない。loss_slope / adverse_movement_speed(Snapshotに既存)
  ベースの観測が唯一の候補。
- gross lossの14.6%を占める残余として明示的に受容するか、
  slope系Shadow分類を追加するかはPhase 2データで判断。

### P3: Event Window(降格)
- HardStop±60分のevent重なりは37件中2件(-5,931円)のみ。
- Event単独レバーは左裾に対して弱いことがデータで確定。
  EA NewsBlock突合(ea_newsblock_vs_calendar_compare.csv 442行)は
  整合性監査として継続するが、優先度は下げる。

### P4: Winner Extension(凍結継続)

## 分類規則の適用記録

- HEDGE_TOO_LATE / RECOVERY_THEN_GIVEBACK は今回の判定対象外
  (post-hedge回復系列がソース監査に無いため。UNKNOWNのまま保持し、
  Shadow Phase 2のSnapshot系列から再構成する)。
- LOSS_DOMINANT_BEFORE_HEDGE判定は |loss_before_hedge| >= |loss_after_hedge| の
  単純比較のみ。閾値チューニングは行っていない(合わせ込み禁止の遵守)。
- signal_to_hedge_lead_sec の符号規約: 正 = SignalがHedgeに先行(Pre-Hedge警告)、
  負 = Hedge後にSignal成立(Post-Hedge観測)。
