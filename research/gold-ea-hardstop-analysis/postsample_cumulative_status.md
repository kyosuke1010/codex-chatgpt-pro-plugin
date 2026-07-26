# postsample_cumulative_status.md — 累積 locked post-sample 状況と判定

date: 2026-07-03
engine: postsample_cumulative_pipeline.py(registry駆動・多窓累積)

## 判定

**decision_class: PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED(継続)**

理由は累積十分性の未達のみ。条件・閾値・EA は一切変更していない。

## 窓レジストリ(postsample_windows_registry.csv)

| 窓 | 期間(half-open) | 状態 | Basket | HardStop(hed/non) | MAバー | 非介入 |
|---|---|---|---|---|---|---|
| W1 JUNE_2026 | [06-01, 07-01) | INGESTED | 84 | 6(6/0) | なし | PASS |
| W2 JULY_2026 | [07-01, 08-01) | PRE_REGISTERED_AWAITING | — | — | 必須(次回) | — |

## 累積十分性(postsample_cumulative_sufficiency.csv)

| 基準 | 要件 | 累積実測 | 達成 |
|---|---|---|---|
| HardStop累積 | ≥15 | 6 | ✗ |
| 非Hedged HardStop累積 | ≥2 | 0 | ✗ |
| slope欠損率(HardStop) | ≤0.30 | 0.000 | ✓ |
| 非介入(全窓) | PASS | PASS | ✓ |

累積slope分離(参考・非最適化): HardStop p50=0.106 vs OTHER p50=0.005
(in-sample HS 0.145 / OTHER 0.021)。方向は一貫。

## W2で条件を変えない担保

- rapid_drop 0.05/min・slope定義・十分性閾値・窓判定・分類・成功基準は
  postsample_cumulative_pipeline.py と registry に固定値としてハードコードされ、
  W2でも同じコードで処理される(窓ごとに別基準を使わない)。
- W1で使ったのと同じ EA 内部ソースハッシュ 1353718F… を W2 でも同一性チェックする。
- W2の唯一の追加は MA バー同梱(観測入力の追加であり条件変更ではない)。

## 次アクション

1. July(W2)完結後、prospective_july_preregistration.md の固定条件で 4run 実行、
   **M5/M15/M30 バーを同梱**して `input_artifacts/prospective_july/` へ push。
2. 「July bundle push完了、取り込み実行」で累積パイプラインを再実行。
3. 累積 HardStop ≥15 かつ 非Hedged ≥2 かつ slope欠損率 ≤0.30 を満たすまで
   MORE_DATA_REQUIRED を継続(必要なら W3=August… を同手順で追加)。
4. 満たした時点で初めて、in-sample vs post-sample 整合レポートを作成し、
   実Exit設計審査の開始可否を別工程で判断する(本工程では判断しない)。

## 固定フラグ(継続)

P1=false / real_exit=false / prehedge_exit=false / ma_cross_logic=false /
hedge_gate=false / event_stop=false。OOS効果・本番期待利益は主張しない。
