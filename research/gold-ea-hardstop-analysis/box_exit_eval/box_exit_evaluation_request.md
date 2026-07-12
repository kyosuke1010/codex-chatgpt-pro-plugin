# box_exit_evaluation_request.md — Codex向け BOX Exit 評価実装依頼書

registered: 2026-07-12
根拠: box_size_analysis_summary.md(分離帯: 勝ちp90逆行1,440円 vs HS最小逆行2,040円。
overlay評価で D=2,000円 がピーク、1,600〜2,400円がロバスト帯)
性格: **評価専用variant**。本番EA昇格の判断ではない(それはW2 OOS確認後の別決定)。

## 0. スコープと保護(最重要)

- ✅ **variant コピーを新規作成**: `KOUCHA_GOLD_KIWAMI_BOX_EVAL.mq5`
  (現行W3版 `C1DBE51A` のコピーから作る)
- ❌ **本番 `KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.mq5` / EX5 / W3Telemetry.mqh は無変更**
  (納品時に本番3ファイルのSHA不変を manifest で証明すること)
- ❌ rapid_drop 0.05 変更禁止(SIG-RD系はtelemetryのまま)
- ❌ July期間の実行・接触禁止(W2はOOSとして温存。BOXの最終判定はW2で行う)
- ❌ **グリッド外の微調整禁止**: BOX_DOWN_YEN は下記の事前登録3点のみ。
  optimizer・追加値・上側capの変更は行わない(過適合防止)

## 1. variant 仕様

現行ロジックに **BOX下限即切り** をオーバーレイする(他は一切変えない):

```
input double BOX_DOWN_YEN = 2000.0;   // 事前登録グリッド: 1600 / 2000 / 2400
// OnTickの既存basket状態更新後(W3挿入点I1と同位置)に判定:
// basket net floating loss >= BOX_DOWN_YEN
//   -> basket全ポジションを即時成行クローズ
//   -> close reason = "BOX_EXIT"(新しい理由文字列。既存理由と重複させない)
```

- 上側は**現行のまま**(+400円 BasketClose)。BOX = [+400 / −BOX_DOWN_YEN]。
- DefenseHedge / HardStop / HTE / RecoveryClose のコードは**削除しない**
  (バックストップとして残す。BOX_DOWN_YEN≤2400 なら hedge発動(≈−6,200)前に
  BOXが先に切れるはず — 「hedge発動回数0」自体が検証項目)。
- W3 telemetry は variant でも ON(CLOSE_ANCHOR に BOX_EXIT が載ること)。
- News/DXY/VIX/MaxPosition 等その他の制御は無変更。

## 2. 実行マトリクス(事前登録)

8設定(in-sample 6 + June 2)× BOX_DOWN_YEN 3点 = **24 run**。
ベースライン比較は既存 extraction_bundle_w3(W3 ON)を使用(再実行不要)。

## 3. 納品物

`input_artifacts/extraction_bundle_v1/extraction_bundle_box_eval.zip` + SHA256 manifest:

1. trade exports(24 run分)+ PERFORMANCE_STATS
2. W3 telemetry CSV(24 run分)
3. box_eval_manifest.csv: run × BOX_DOWN_YEN × (basket数 / BOX_EXIT数 / HardStop数 /
   hedge発動数 / final balance)
4. **本番ファイルSHA不変証明**(SURVIVAL_TICK.mq5 = C1DBE51A、W3Telemetry.mqh =
   36FC7066、本番EX5 = 1652AA38 が変わっていないこと)
5. variant source(BOX_EVAL.mq5)+ そのSHA256 + compile log(0 errors)
6. extraction_report_box_eval.txt(July混入0の確認を含む)

push後「**box eval push完了**」と合図。

## 4. code側の検収・判定基準(事前登録 — 後から動かさない)

primary = D2000。以下を**in6・June両方**で評価:

| # | 基準 | 合格条件 |
|---|---|---|
| S1 | HardStop発生数 | ベースライン39 → **0**(全てBOX_EXITに置換) |
| S2 | hedge発動数 | → **0**(BOXが先制している証明) |
| S3 | 期待値/basket | ベースライン比で**改善**(overlay予測: −118→+61。path効果でズレは想定内。悪化なら仮説棄却) |
| S4 | 最悪単一basket損失 | ≈ −(D+slip) に上界化(−2,100円前後。大幅超過はロジック欠陥) |
| S5 | MaxDD | ベースライン比で縮小 |
| S6 | 勝ちbasket残存率 | overlay予測 ≈96%。大幅低下(<90%)なら path効果の副作用を精査 |

- S1〜S6 が in6/June 双方で合格 → **BOX_EXIT_CANDIDATE_CONFIRMED_IN_SAMPLE**
  → July W2 完結後に OOS判定(それまで本番昇格しない)。
- 不合格 → 原因分析へ(仮説棄却も結果として記録する)。

## 5. 明記事項

- 本依頼は「もっとも勝てる」を**仮説として検証**するもの。結果が overlay 予測を
  下回る可能性(path効果・再エントリ挙動の変化)は明示的に想定内。
- 全結果は in-sample+June 診断。OOS効果・実装後利益は主張しない。
- 本番実装フラグは全て false のまま(variant はテスター評価専用)。

## 6. 追補(2026-07-12、「BOX上限抜けの損失」レビューを受けて)

方向の定義を明確化する: BOXはP/L空間([+400円 / −BOX_DOWN_YEN])であり、
**SELL basket の「価格BOX上限抜け(踏み上げ)」は adverse側として当初から計測対象**
(overlay実績: HS 39件中 SELL上抜け死 25件、D=2000のbreach 57件中 SELL 35件)。
P/L上限側は利確辺であり損失は発生しない。ただし以下2リスクを検収に追加する:

| # | 追加基準 | 内容 |
|---|---|---|
| S7 | **床貫通ギャップ滑り** | BOX_EXIT毎に trigger時想定価格と約定価格の差を記録(box_eval_manifestに slippage列)。overlayでは gap-open貫通 0/57 だったが、閉場中にbreachした場合は再開後約定になるため、**gap超過分の分布**を実測すること。S4(最悪損失 ≈ −(D+slip))の検証を兼ねる |
| S8 | **連続切り(whipsaw)蓄積** | BOX_EXIT の日次/週次最大回数と連続発生数を報告。overlayでは57回×−2,040=総コスト−116k(tail節約+124kで正味+86k)。チョップ相場で切りが倍増すると正味が反転し得るため、run内の切り集中度を可視化する |

S7/S8 は不合格基準ではなく**報告義務**(S1〜S6が判定基準のまま)。

## 7. 追補2(2026-07-12、「トレンド転換で負ける」レビューを受けて)

事実確認: 本サンプルは4ヶ月全て下降(3月−12%/4月−1.1%/5月−1.8%/6月−11.4%、
計−24%)であり、**上昇レジームのデータが存在しない**。BOX deltaは全月・両方向で
正であり分離帯も方向別に成立(BUY p90=16.1u vs HS min 35.0u / SELL 12.9u vs 20.4u)
だが、上昇トレンドでの検証ゼロという限界は消えない。以下を追加する:

### 7.1 BOX_EXIT の cooldown 仕様(whipsaw出血の一次防壁 — 実装必須)

- BOX_EXIT は**損失クローズとして扱う**: 既存の AFTER_CLOSE_COOLDOWN を適用し、
  ConsecutiveLosses にカウントする(既存の損失クローズと同一の扱い。
  新しい cooldown 値は導入しない=チューニング禁止の範囲内)。
- box_eval_manifest に「BOX_EXIT後の再エントリーまでの中央値/最小値(分)」と
  「同一方向への再エントリー率」を報告列として追加。

### 7.2 W4 上昇レジーム・ストレス窓(事前登録 — 結果を見る前に窓を固定)

- 選定規則(固定): MT5で利用可能な過去データのうち、**2026-03より前で直近の、
  GOLD累計変動 ≥ +8% の連続3ヶ月窓**。該当なしの場合は正方向変動が最大の3ヶ月窓。
  窓の選定根拠(候補窓と変動率の一覧)を extraction_report に記載してから実行する。
- 実行: その窓で **(a) 現行EA(W3 ON, BOX無し)** と **(b) BOX variant D=2000** の
  両方を実走(50k/100k 各1本、計4run追加)。
- 判定(S9, 事前登録): 上昇窓において
  - (b)の最悪単一損失・MaxDD が (a) より**悪化しないこと**(BOXの本義=転換耐性)
  - (b)のBOX_EXIT頻度と正味P/L を報告(頻度増幅で正味が(a)を下回るかを直接観測)
  - side-mix((a)(b)共通のエントリーエンジンが上昇窓でBUY側へ適応するか)を報告
- W4はストレス試験であり「上昇でも勝てる」の主張には使わない。目的は
  **「転換時にBOXが現行より悪化しないか」**の一点。

### 7.3 明記

「レンジ取りがもっとも勝てる」仮説の成立範囲は、現時点では**下降レジームの
in-sample+June に限定**される。W4(上昇ストレス)と July W2(OOS)の両方を
通過するまで、レジーム一般化を主張しない。
