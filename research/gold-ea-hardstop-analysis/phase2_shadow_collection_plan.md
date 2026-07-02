# phase2_shadow_collection_plan.md — Shadow Phase 2 Prospective収集計画(v1.0.0)

## 0. 原則

- **EA無変更**: 検証済みEX5(SHA 49b31402…)をそのまま使用。
  Phase 1 Shadow Logging(非介入 6/6 PASS ×3系統)を継続稼働するだけ。
- すべての追加分析はオフライン(ingest_verify.py / fill_phase_bfg.py /
  prehedge_recalc.py 系列の拡張)。
- in-sample(既存6run: 2026-03〜05)とprospective期間を**厳密分離**。
  prospective期間のデータでin-sample閾値・条件を変更しない。

## 1. 収集構成

| 項目 | 内容 |
|---|---|
| 実行形態 | 既存テスター構成(ML_C_SHADOW_ON系ini)を将来期間へ延長 + 可能ならdemoテスター相当の将来native tick |
| capital | 50,000 / 100,000(既存2群を維持) |
| ログ | Phase 1 shadow log(event_type multi-record)そのまま |
| 取り込み | input_artifacts/ へZIP push → ingest_verify.py(期待値照合はprospective用に行数固定なしへ切替) |
| MA Overlay | offline_overlay_pipeline_spec.md v1.0.0 を同一契約で適用 |

## 2. 生成テーブル(prospective側)

1. **prehedge_damage_shadow.csv** — prehedge_runtime_schema.csv 準拠。
   Pre-Hedge帯全Snapshot(または1分間引き)+導出列(slope/shrink/cummax等)。
2. **prehedge_signal_events.csv** — 分類ラベル遷移イベント
   (WATCH→DANGER、RAPID_DROP_CANDIDATE記録トリガ0.05/min到達等)。
3. **m15_persistence_recross.csv** — 診断仕様の全項目。
4. **rapid_drop_class.csv** — HardStop事後分類
   (RAPID_DROP_NO_CLOSED_BAR_WARNING / SLOW_BLEED_NO_WARNING)。
5. **candidate_possible_audit.csv** — existing_close_protection_gate.csv の
   G3〜G10 + GX1判定(UNKNOWN保持)。

## 3. 主要クエリ(prospectiveで答えを出す質問)

- Q1: Pre-Hedge帯の正規化slope分布はin-sample(HardStop p50 0.145 vs
  その他 p50 0.021)を再現するか。
- Q2: 急落型(no-warning rapid drop)の発生率と、記録トリガ0.05/minの
  捕捉率・誤検知率はin-sample予備値(捕捉4/4・FP約10%)からどう動くか。
- Q3: M15 persistence(H1〜H3)はBC Kill回復系とHardStop直行系を分離するか。
- Q4: 後発eligible化(HTE/BC)のminutes_to_later_eligibility分布(H4)。
- Q5: M15警告のPre-Hedge帯リードタイム分布は二峰性を維持するか。
- Q6: pending_close_state にNONE以外が出現するか(Phase 1未観測領域)。

## 4. 十分性基準(次の意思決定に進むための最低量)

- prospective期間でHardStop Basket **≥ 15件**(in-sample 37件の約4割)
  かつ うちPre-Hedge帯slope導出可能 ≥ 10件。
- 急落型クラス ≥ 2件(0件の場合は「急落型は稀少事象」とだけ記録し
  slope設計の判定を保留)。
- M15 first signal ≥ 30件。
- 上記未達のまま3ヶ月相当を経過した場合は
  PREHEDGE_DAMAGE_CONTROL_MORE_DATA_REQUIRED を宣言して収集を継続する。

## 5. 完了時の判定手順

1. in-sample vs prospective の分布比較(Q1〜Q5)を成果物化。
2. 整合する場合のみ、Exit系候補(Pre-Hedge Exit / Hedge Unwind / TA9 / MA Exit)
   の実装設計審査を**開始してよい**(実装ではない)。
3. 不整合の場合、当該候補を棄却し観測を再設計する。

## 6. 変更管理

- 本計画の変更は本ファイルのバージョン更新と差分記録を必須とする。
- 固定フラグ(implementation_not_allowed_statement.md)は本計画の
  完了だけでは解除されない。
