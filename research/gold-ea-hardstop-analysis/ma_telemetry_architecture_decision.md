# ma_telemetry_architecture_decision.md — MA計測アーキテクチャ決定(ADR)

decision: **OFFLINE_OVERLAY_ONLY**
status: ACCEPTED / FROZEN
date: 2026-07-02

## 決定

MA(EMA10/SMA20 × M5/M15/M30)の計算・クロス判定・Signal分類は、
**EAの外(オフラインpipeline)でのみ**行う。EA内で新規に
iMA / CopyBuffer / PerfCopyBuffer / CopyRates を呼ぶ変更を行わない。

## 理由

1. **EA変更ゼロ** — 現行EAと検証済みEX5をそのまま維持できる。
   非介入性(A_REFERENCE vs Shadow OFF/ON 6/6 PASS)の再検証コストが発生しない。
2. **indicator cache汚染の再発防止** — 過去にShadowがRuntime indicator cacheを
   汚染した事故原因を構造的に排除する(indicator_cache_contamination_risk.md)。
3. **結合実績** — Phase 1 Runtime Snapshot(169,305行)と外部MAで
   442/442 Basket結合済み(報告値)。オフライン側のavailability結合は実証済み。
4. **将来データへの同一pipeline適用** — prospective data / OOS / future native tick
   にも同じオフラインpipelineをそのまま適用でき、in-sampleとOOSの計算系が一致する。

## 却下・保留した代替案

| 案 | 判定 | 理由 |
|---|---|---|
| POST_RUNTIME_READONLY_HANDOFF | 条件付き保留 | 既存Runtimeが**同一定義**のMA(EMA10/SMA20, close, 同TF)を既に計算している場合のみ候補。現行EAにその計算が存在するかはEA source不在のためUNKNOWN。UNKNOWNのまま採用しない |
| DEDICATED_HANDLE_AFTER_RUNTIME | 却下 | EA内での新規handle作成はindicator cacheの状態を変え、テスター内の計算順序・メモリ状態に影響し得る。非介入性保証を失う |
| COPYRATES_AND_LOCAL_MA_AFTER_RUNTIME | 却下 | CopyRatesのseries同期(未確定バー混入・reindex)リスク。closed-bar契約の保証がEA内では困難 |

## 帰結

- Shadow Phase 2で新たに必要な観測フィールドは、**既存Phase 1 Snapshotに
  既に含まれる値**(P/L、lifecycle、eligibility、ClosePriority等)に限定する。
  含まれない値が必要になった場合は、EA変更ではなく「取得不能=UNKNOWN」として
  スキーマに残し、次期Snapshot拡張の要件リストに積む。
- 本ADRの変更(Runtime MA導入)には、Shadow OFF/ON 6/6 PASS同等の
  非介入回帰スイート再走行を必須条件とする。
