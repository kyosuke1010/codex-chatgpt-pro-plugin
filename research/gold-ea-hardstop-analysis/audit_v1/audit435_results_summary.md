# audit435_results_summary.md — Audit 4 / 3 / 5 結果(v1.0データ先行実行)

date: 2026-07-03
source: extraction_bundle_v1 (v1 core CSVs)。snapshotカバレッジ非依存のため v1.3 を待たず実行。
scope: primary = in6run(in-sample diagnostic only)。
全数値は診断用。採用判断・OOS効果・実装後利益・「15万円なら勝てる」を主張しない。
MISSINGは EVIDENCE_UNAVAILABLE として記録し補完しない。

## Audit 4: Capital Buffer / 150k Survival(最初に確定=資金の位置づけ)

| 指標 | 値 |
|---|---|
| mean HardStop loss | -4,991円(in6run 37件) |
| worst HardStop loss | -9,019円 |
| worst basket final_pl | -9,019円 |
| **MaxDD(実測, equity_curve)** | 50k: **30,410円 = 元本の60.8%** / 100k: 32,613円 = 32.6% |
| 150k MaxDD | NA(150k実走なし。EAロットが資金比例なら外挿不可) |
| max consecutive HardStop / 24h | 3 |
| survival_est_150k(worst HS連続) | 16.6件で150k equityゼロ |
| survival_est_150k(mean HS連続) | 30.1件で150k equityゼロ |
| **margin_constraint_evidence @HardStop** | row field **MISSING 43/43**。equity-series margin @HS: n=37, **min≈2,701%**, 200%割れ **0件** |
| **margin_constraint_evidence @Hedge** | row field **MISSING 48/48**。equity-series margin @hedge: min≈2,708%, 200%割れ 0件 |
| expectancy statement | **資金増加は期待値 −147円/Basket を変えない** |

### 15万円資金の位置づけ(Audit 4の含意)

1. **維持率(margin)は拘束条件ではない**。HS/Hedge時点の観測margin最小≈2,700%で
   200%を全く割らない。HardStopはEAのfloating-loss閾値で発火しており、margin-callではない。
   ただし row-level margin_level は全MISSINGのため、**at-event精密値は EVIDENCE_UNAVAILABLE**。
2. **資金buffer効果は「破綻回避」に限定**。50kではMaxDDが元本の60.8%に達し破綻近傍。
   100kで32.6%、150kならさらに余裕(worst-HS 16.6連続まで耐える)。
   → 15万円は**生存余裕を広げる**が、
3. **期待値は不変(−147円/Basket)**。資金増はHardStop左裾の発生率も1件あたり損失も変えない。
   → **CAPITAL_BUFFER_ONLY_NOT_SUFFICIENT** を支持する証拠(左裾の損失制御が別途必要)。
- 提案(実装ではなくログ項目): v1.3/W3 Shadow Loggingに **margin_level_at_hs /
  at_hedge の実値** を追加すれば margin証拠が row-level で確定できる。

## Audit 3: Hedge層別(2層フォールバック, Non-Hedged n=11)

| group | n | hs_loss median |
|---|---|---|
| HEDGED(全体) | 26 | -3,746円 |
| NON_HEDGED(全体) | 11 | -3,825円 |
| HEDGED SHALLOW(pl@hedge≥median) | (2層, LOW_N可能性) | 表 audit3参照 |
| HEDGED DEEP(pl@hedge<median) | 同上 | 同上 |

- **Hedged と Non-Hedged の HS損失中央値はほぼ同等**(-3,746 vs -3,825)。
  Hedgeしても最終HS損失規模を下げられていない(本プロジェクトの
  LOSS_DOMINANT_BEFORE_HEDGE 所見と整合)。
- **層化変数の制約**: worst_floating_pl が全MISSING → 代替に basket_pl_at_hedge を使用
  (Non-Hedgedにはhedge行が無く同一軸で層化不可)。
- **timing**: hedge_too_late は distance_to_hs_price 全MISSINGのため **NOT_COMPUTABLE**。
  post_hedge_max_recovery_pl 基準では recovery_room=26 / no_recovery=0(全件で
  hedge後に多少の回復余地はあったが最終的にHS=giveback型を示唆。ただし
  distance欠損のため timing 判定は限定的)。
- **Mann-Whitney: MW_SKIPPED_NO_SCIPY**(中央値のみ報告)。Non-Hedged n=11 は
  層内でLOW_N(<5)になり得るため、2層フォールバックでも結論は限定。

## Audit 5: Winner Extension

| 指標 | 値 |
|---|---|
| winner数(in6run) | 391 |
| final_pl p50 / p90 / max | 401 / 407 / **420** |
| cap集中(380–420円) | **233/391 = 59.6%** |
| post_close_favorable_move 1h/4h/24h | **EVIDENCE_UNAVAILABLE**(post_close_move_* 全MISSING 467/467) |
| winner_kill_risk | 構造記述のみ(定量反実仮想なし) |

- **勝ちは +400〜420円で明確に頭打ち**(max 420、約6割が380–420帯)。
  Winner ceiling は実データで確認。
- **延長可否は判定不能**: favorable_move が全MISSINGのため
  「延長で追加利益が取れるか」を評価できない。→ WINNER_EXTENSION は
  **UNDETERMINED**(v1.3+で post_close_move_* を入れれば判定可能)。

## 判定入力(Spec §6候補への寄与)

- **CAPITAL_BUFFER_ONLY_NOT_SUFFICIENT**: 支持(margin非拘束・期待値不変・buffer効果は生存のみ)
- **CAPITAL_BUFFER_PLUS_LOSS_CONTROL_REQUIRED**: 支持(左裾損失制御が別途必要)
- Audit 3: Hedge限界効果あり(H≈N損失)→ HEDGE_TIMING_OR_COVERAGE_REVIEW は
  distance欠損のため保留(v1.3後に timing 再評価)
- Audit 5: WINNER_EXTENSION_SECONDARY は favorable_move 到着まで UNDETERMINED

## 未実施 / 保留

- Audit 2(Exposure Amplification): entries.position_pl_final 全MISSING → **v1.3待ち**。
- Audit 1: PROVISIONAL_PENDING_V1_3(除外13=HardStop欠損のためlinkage修正版で再計算)。
  再実行時に fires/hour(滞留時間正規化)と Uncovered HardStop Profile を追加予定。
- 本結果は in-sample診断であり、実Exit設計審査・July W2 に影響しない。固定フラグ全 false。
