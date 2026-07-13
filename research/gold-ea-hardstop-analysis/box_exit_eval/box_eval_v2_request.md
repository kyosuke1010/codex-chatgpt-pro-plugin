# box_eval_v2_request.md — Codex向け BOX Exit v2 評価実装依頼書

registered: 2026-07-14
authorization: box_architecture_design_audit.md(凍結仕様)をユーザー承認済み。
性格: **凍結仕様の転写のみ。設計裁量ゼロ。** 1仕様・1回限り(グリッドなし)。
評価専用variant。本番昇格判断ではない(最終関門は July W2 OOS)。

## 0. スコープと保護(v1と同一+強化)

- ✅ variant v2 を新規作成: `KOUCHA_GOLD_KIWAMI_BOX_EVAL_V2.mq5`
  (v1 variant `11EBE14B` を出発点に、§1の3変更のみ加える)
- ❌ 本番3ファイル無変更(納品時SHA証明: SURVIVAL_TICK.mq5=`C1DBE51A` /
  W3Telemetry.mqh=`36FC7066` / 本番EX5=`1652AA38`)
- ❌ rapid_drop 0.05 変更禁止 / July期間の実行・接触禁止
- ❌ **パラメータ変更・グリッド・optimizer 全面禁止**: BOX_ABS_CAP_YEN=2000 と
  BOX_HS_FRACTION=0.50 は凍結値。既存スイッチ(HardStopAfterMode /
  HardStopCooldownMinutes / MaxConsecutiveLosses / DailyLoss系)の既定値も変えない
- ❌ 結果を見てからの再修正・再走の禁止(不合格なら停止して報告)

## 1. v2 の変更点(この3つだけ。他は v1 variant のまま)

### 1-A. BOX床のスケール則(R2)

```
input double BOX_ABS_CAP_YEN  = 2000.0;  // 凍結
input double BOX_HS_FRACTION  = 0.50;    // 凍結

box_floor_yen = MathMin(BOX_ABS_CAP_YEN,
                        BOX_HS_FRACTION * GetHardStopThresholdYen());
// 判定: GetFloatingLossYen(ps) >= box_floor_yen -> BOX_EXIT
```

- **毎tick、HS判定と同じ GetHardStopThresholdYen() から再計算**すること
  (初期化時のスナップショット固定は禁止。閾値は残高比例で動くため)。
- box_eval_manifest に「BOX_EXIT時点の box_floor_yen 実値」を列として記録。

### 1-B. BOX_EXIT後は HardStop と完全同格(R1、「切って観察停止」)

BOX_EXIT の成功クローズ直後に、**HardStop成立時と同一の事後処理経路**を通す:

1. `ApplyHardStopAfterMode()` を呼ぶ(LastHardStopTime 等の更新を含む既存関数。
   HardStopAfterMode / HardStopCooldownMinutes は既定値のまま)
2. HardStopOrigin 系エントリーblock(`UseHardStopOriginEntryBlock`)の origin として
   BOX_EXIT の文脈(方向・時刻)を登録する(HS成立時と同じ登録関数を使う)
3. ConsecutiveLosses カウント・日次損失算入は v1 同様(損失クローズ扱い)

- 新しい cooldown 値・新しい block 条件は**作らない**。既存機構への配線のみ。

### 1-C. DefenseHedge 無効化(R3、優先順位契約)

- 実行configで固定: `UseDefenseHedge=false`、
  `UseSinglePositionReactiveDefenseHedge=false`(コード削除はしない)。
- HardStop / HTE / RecoveryClose のコードはそのまま(HSは最終バックストップ)。
- **契約検証**: hedge発動・HTE が1件でも発生したら契約違反として
  extraction_report に個別記載(発生自体が不合格情報)。

## 2. 実行マトリクス(事前登録、10 run)

| 窓 | run |
|---|---|
| in-sample | 6設定(MAR_MAY/APR_MAY/MAY × 50k/100k)× 単一仕様 |
| June | 2設定(50k/100k) |
| W4上昇窓(2026-02-02〜02-27、選定済み再利用) | 2設定(50k/100k)。**W4ベースラインは box_eval bundle 取得済みのため再実行不要** |

比較ベースライン: extraction_bundle_w3(in6+June)/ box_eval bundle の
W4_BASELINE 2本。いずれも再実行不要。

## 3. 納品物

`input_artifacts/extraction_bundle_v1/extraction_bundle_box_eval_v2.zip` + SHA256 manifest:

1. trade exports + PERFORMANCE_STATS(10 run)
2. W3 telemetry CSV(10 run。CLOSE_ANCHOR に BOX_EXIT が載ること)
3. box_eval_v2_manifest.csv: run × (basket数 / BOX_EXIT数 / HardStop数 / hedge数 /
   HTE数 / final balance / **box_floor_yen実値の min-max** / BOX_EXIT毎slippage /
   BOX_EXIT後再エントリー分数の中央値・最小値 / 同方向再エントリー率)
4. 本番3ファイルSHA不変証明 + variant v2 source・SHA・compile log(0 errors)
5. extraction_report_box_eval_v2.txt(July混入0、hedge/HTE契約違反の有無を明記)

push後「**box eval v2 push完了**」と合図。

## 4. 検収基準(事前登録 T1〜T6 — 後から動かさない)

| # | 基準 | 合格条件 |
|---|---|---|
| T1 | hedge発動 / HTE | **0件**(R3契約検証) |
| T2 | 期待値 | **in6・June双方**でベースライン比改善(v1は in6 −131,414 vs −51,673 で不合格だった) |
| T3 | MaxDD | 双方で縮小 |
| T4 | 最悪単一basket | ≥ −(box_floor + slip 100円 + gap許容 300円)。HS backstop発動時はHS値を別掲 |
| T5 | **basket数 ≤ ベースライン×1.5** | 再突入抑制の直接検証(v1のD2000は3〜4倍で失格相当) |
| T6 | W4 | net / MaxDD / 最悪損失が **W4ベースラインより優位を維持**(参考: v1 box は +9,320/+5,540、0 HS) |

- **全合格** → BOX_V2_CONFIRMED_IN_SAMPLE → July W2 完結後(2026-08-01以降)に
  OOS 最終判定。それまで本番昇格なし。
- **1つでも不合格** → BOX路線を一旦停止し判定合成へ戻る。
  **in-sampleでの再修正・再走はしない**(勝つまで回す、の禁止)。

## 5. 明記事項

- 全結果は in-sample+June+W4ストレス診断。OOS効果・実装後利益・
  「レンジ取りがもっとも勝てる」の一般化を主張しない。
- 実装フラグ全 false 維持(variant はテスター評価専用)。
- 本依頼書は box_architecture_design_audit.md の転写であり、両文書が矛盾する場合は
  **design audit(凍結仕様)が優先**。矛盾を発見したら実装前に報告すること。
