# hardstop_research_priority.md

出典: SESSION_REPORTED_AGGREGATE。Basket単位の切り分け(root_cause_class充填)は
入力成果物(ART04/ART05/ART06)の再配置後に実施する。

## 優先順位

### P0: Hedged HardStop 26件 / -130,403円
最大の損失源。研究レバーは2系統あり、どちらが支配的かは未確定(UNKNOWN):

- **Hedge too late / loss already dominant before hedge**
  → Pre-Hedge Damage Control系(Signal→Hedgeのlead time、Signal時P/L、HardStop距離)
- **Recovery then giveback**
  → Hedge Transition / Unwind系(post-hedge best recovery、giveback額、
    HTE/Recovery eligibilityとの時間関係)

M15逆クロスのPre-Hedge Signalは26件中20件で存在(報告値)。
つまりHedge発動前に警告が出ていたケースが多数派であり、
「Hedgeに入る前の損傷制御」の観測価値が高い。

### P1: Non-Hedged HardStop 11件 / 約-54,275円
Hedgeに入る前にHardStopへ到達する系。11件中7件でM15事前Signalあり。
TA9(Post-Hedge)では原理的に届かないため、Pre-Hedge警告観測が唯一のレバー。

### P2: MA警告なしHardStop 4件
37件中、どの逆クロス警告も先行しなかった4件。金額内訳UNKNOWN。
急変(イベント/ギャップ)型の可能性があり、Event Window観測との突合が必要。
M15逆クロス系の候補では構造的に救えない残余として明示的に扱う。

### P3: 非HardStop負け 11件 / 約-17,495円
gross lossの8.65%。現段階では着手しない。

### P4: Winner Extension
平均勝ち+352.27円 / max +420円の頭打ちは確認済み(報告値)。
ただし優先は左裾圧縮であり、HardStop損失削減の成果が出るまで凍結。

## 充填時の分類規則(root_cause_class)

hardstop_root_cause_rebuild.csv の root_cause_class は以下の排他的優先順で付与:

1. NON_HEDGED_HARDSTOP(hedge_time = NA)
2. HEDGE_TOO_LATE(signal_to_hedge_lead_sec > 閾値かつ pl_at_hedge が損失支配的)
3. LOSS_DOMINANT_BEFORE_HEDGE(pl_at_hedge <= final_loss の X%、Xは充填時に固定)
4. RECOVERY_THEN_GIVEBACK(post_hedge_best_recovery > 0 かつ giveback_after_recovery が最終損失の主因)
5. LOSS_ACCUMULATED_AFTER_HEDGE(上記以外でHedge後に損失が拡大)

付帯フラグ(非排他): event_window_overlap / m15_reverse_before_hardstop / no_ma_warning。
閾値は充填前に固定し、既存6runへの合わせ込み(事後最適化)を禁止する。
