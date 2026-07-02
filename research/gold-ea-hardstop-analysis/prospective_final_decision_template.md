# prospective_final_decision_template.md — 最終判定テンプレート

> **注記(2026-07-03)**: June-2026 bundle が到着・取り込み済み。確定した判定は
> **prospective_final_decision.md**(decision_class = PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED)
> を正とする。本テンプレートは手順の記録として保持する。

## (旧)データ到着前の判定(2026-07-02、参考)

**decision_class: PROSPECTIVE_INGESTION_PIPELINE_READY_WITH_DATA_PENDING**

根拠:
- pre-registration 完了(locked window 2026-06-01〜2026-06-30 を結果確認前に固定、
  selection_time 2026-07-02、contamination ledger 記録済み)。
- 受け入れ pipeline(19ステップ)実装済み・no-data で健全動作を確認。
- June の MT5 実データ(Root Snapshot / Basket Summary / Run Summary /
  Trade Events / OFF+ON両arm)が未到着のため、Q1〜Q6 と十分性は未評価。

補足で確定している事実(いずれも設計・pre-registrationレベル):
- PROSPECTIVE_PREREGISTRATION_READY: 満たす(locked window固定済み)。
- PROSPECTIVE_INGESTION_PIPELINE_READY: 満たす(pipeline稼働確認済み)。
- PROSPECTIVE_COLLECTION_BLOCKED_WAITING_FOR_MT5_DATA: 収集そのものは
  ユーザー側MT5で実行可能であり構造的BLOCKではないため**該当しない**。
  正確な状態は「pipeline ready / data pending」。

固定フラグ(継続): P1=false / real_exit=false / prehedge_exit=false /
ma_cross_logic=false / hedge_gate=false / event_stop=false。

いかなるOOS効果・本番期待利益も主張しない。実Exit設計審査へ進まない。

---

## データ到着後の判定テンプレート(pipeline出力で埋める)

> 以下は prospective_ingestion_pipeline.py 実行後に確定値へ置換する。
> 数値は commit された CSV から転記し、手入力で合わせ込みしない。

### 1. 同一性・窓・スキーマ
- EA source/EX5 SHA一致: {PASS/FAIL}
- window half-open 一致: {PASS/FAIL} / deposit・symbol・tf・model: {PASS/FAIL}
- root_snapshot スキーマ: {PASS/FAIL}
→ いずれか FAIL なら decision = PROSPECTIVE_WINDOW_CONTAMINATED
  または PROSPECTIVE_INPUT_SCHEMA_INCOMPLETE。

### 2. 非介入
- OFF vs ON deal/order fingerprint: {一致/不一致}({PASS/棄却})

### 3. 十分性(prospective_sufficiency_check.csv)
- HardStop {n}(要≥15) / Non-Hedged {n}(≥2) / Hedged {n}(≥2) /
  BasketClose {n}(≥5) / slope欠損率 {r}(≤0.30)
→ 未達なら decision = PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED。

### 4. Q1〜Q6(prospective_q1_q6_results.csv)
| Q | 仮説 | in-sample | prospective | verdict |
|---|---|---|---|---|
| Q1 | 急落型slope分離 | HS_p50 0.145 / OTHER_p50 0.021 | {値} | {SUPPORTED/NOT} |
| Q2 | Pre-Hedge MA warning harm過多 | M15 -10,258 / M5 -41,538円 | {値} | {SUPPORTED/NOT} |
| Q3 | slope+shrinkで浅/深逆行分離 | ~7x median gap | {値} | {SUPPORTED/NOT} |
| Q4 | BC Kill型 vs HardStop型 | BC-kill(pre-hedge M15) 26 | {値} | {…} |
| Q5 | HTE後発eligible化の観測 | 1件/-20円 | {値} | {…} |
| Q6 | Event Window補助のみ | hs±60 2/37 | {値} | {SUPPORTED/NOT} |

### 5. 総合判定(候補)
- PREHEDGE_SLOPE_SIGNAL_PROSPECTIVE_SUPPORTED
  (Q1 & Q3 が prospective で再現、非介入PASS、十分性達成)
- PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED
- PREHEDGE_SLOPE_SIGNAL_NOT_SUPPORTED
- MA_WARNING_ONLY_CONFIRMED(Q2再現・slope分離せず)
- EVENT_NOT_PRIMARY_CONFIRMED(Q6再現)
- SHADOW_COLLECTION_BLOCKED

### 6. 次段(SUPPORTED時のみ)
実Exit設計審査の**開始可否**のみを述べる(実装ではない)。
in-sample と prospective の整合レポートを添付する。
