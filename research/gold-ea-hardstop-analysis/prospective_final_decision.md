# prospective_final_decision.md — June-2026 locked post-sample 取り込み後の最終判定

date: 2026-07-03(June bundle 取り込み・オフライン導出後)
bundle: KOUCHA_GOLD_PREHEDGE_PROSPECTIVE_JUNE2026_COLLECTION_BUNDLE.zip
bundle_sha256: 491bb49131c8225da5f02836ec6afe2f5d50c096027a221c29ff1d137f709864(照合OK)

## 判定

**decision_class: PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED**

補助確定(データ根拠つき):
- **MA_WARNING_ONLY_CONFIRMED**(Q2はoverlay bars未同梱で保留だが、方針は不変)
- **EVENT_NOT_PRIMARY_CONFIRMED**(Q6: HardStop 6件のうちevent window内 0件)

非介入・同一性・窓・スキーマはすべてPASS。判定を DATA_REQUIRED にするのは
**十分性未達**が理由であり、パイプラインやデータ品質の問題ではない。

## 1. 取り込み検証(19ステップ、全ゲート結果)

| ゲート | 結果 |
|---|---|
| bundle SHA256 | PASS(manifest一致) |
| ZIP展開 / CSV再発見(Snapshot・埋め込みBasket/Run Summary・Trade Events) | PASS |
| root_snapshot スキーマ(83列必須) | PASS |
| **EA同一性**(shadow log `source_before_sha256`)| PASS(in-sampleと同一 1353718F…)|
| 窓一致(FromDate=2026.06.01 / ToDate=2026.06.30、half-open membership)| PASS |
| deposit/symbol/tf/model(50k+100k / GOLD / M5 / Model=0)| PASS |
| **非介入**(OFF vs ON trade events)| **PASS(両capital byte完全一致)** |

EA source/EX5ファイルはbundleに同梱されなかったが、shadow logの内部ソースハッシュ
`source_before_sha256` が in-sample と完全一致するため、**同一EAでの収集**が確認できた
(ファイルSHAではなくEA内部ハッシュでの同一性確認)。

## 2. June実測サマリ(84 Basket)

| 指標 | 値 |
|---|---|
| Basket総数 | 84(BasketClose 76 / HardStop 6 / DEINIT_open 2) |
| HardStop | 6件 **全てHedged**(非Hedged 0件)、損失合計 -32,891円 |
| BasketClose | 76件 / +27,725円 |
| net P/L | -14,032円 |

**構造はin-sampleと整合**: 高勝率だが左裾(HardStop)が純損を作る。
Juneは非Hedged急落型HardStopが0件で、in-sample(急落型4件/3ヶ月)と併せ
「非Hedged急落は稀少事象」という理解と矛盾しない。

## 3. Q1〜Q6

| Q | in-sample | June実測 | verdict |
|---|---|---|---|
| Q1 slope分離 | HS_p50 0.145 / OTHER 0.021 | HS_p50 0.106(n6) / OTHER 0.005(n48) | **DIRECTIONALLY_REPRODUCED**(約22倍差) |
| Q2 MA warning harm過多 | M15 -10,258 / M5 -41,538 | overlay bars未同梱 | PENDING(要バーデータ) |
| Q3 slope+shrink分離 | ~7倍 | ~22倍(低N) | DESCRIPTIVE_ONLY_LOW_N |
| Q4 BC-kill vs HardStop | BC-kill 26 | MA warning要バー | PENDING |
| Q5 HTE後発eligible | 1件/-20円 | JuneはHTEクローズ0件 | NO_EVENT |
| Q6 Event補助のみ | hs±60 2/37 | HardStop event window内 0/6 | **EVENT_NOT_PRIMARY_CONSISTENT** |

### rapid_drop トリガ(0.05/min、固定・不変更)の挙動
6 HardStop中 **4件が発火**(norm3 0.087〜0.184)、**2件が閾値未満**(0.033/0.042、
いずれも100k・低速ブリード型)。fast-drop型は捕捉、slow-bleed型は取りこぼす
——観測専用の妥当性を裏づける(Exit化しない根拠の再確認)。

## 4. 十分性(未達で DATA_REQUIRED)

| 基準 | 要件 | 実測 | 達成 |
|---|---|---|---|
| HardStop件数 | ≥15 | 6 | ✗ |
| 非Hedged HardStop | ≥2 | 0 | ✗ |
| Hedged HardStop | ≥2 | 6 | ✓ |
| BasketClose件数 | ≥5 | 76 | ✓ |
| slope欠損率 | ≤0.30 | 0.357 | ✗ |
| 非介入 OFF+ON | PASS | PASS | ✓ |

slope欠損率0.357は、BasketClose Basketの多くが短命(3分窓が張れない)ためで、
急落型検出の妨げではない(HardStop側は6/6でslope導出可能)。

## 5. なぜ実装へ進まないか(不変)

- 単月では左裾サンプル(HardStop 6件、うち非Hedged 0件)が不足。
- Q1は方向再現だが n=6 で統計的結論に不十分。トリガは2/6取りこぼし。
- Q2/Q4(MA warning系)はoverlay bars未同梱で未評価。
- したがって Pre-Hedge Exit / M15 Exit / slope Exit のいずれも実装根拠に届かない。

## 6. 固定フラグ(継続)

P1=false / real_exit=false / prehedge_exit=false / ma_cross_logic=false /
hedge_gate=false / event_stop=false。OOS効果・本番期待利益は主張しない。

## 7. 次アクション

1. 追加の locked post-sample 窓(例: 2026-07 完結後)を**同じ事前登録手順**で追加収集し、
   HardStop累積 ≥15・非Hedged ≥2 を満たすまで蓄積(閾値・条件は不変更)。
2. MA overlay bars(M5/M15/M30)を次回bundleに同梱 → Q2/Q4 を評価可能に。
3. 累積十分性達成後にのみ、in-sample vs post-sample 整合レポートを作成し、
   実Exit設計審査の**開始可否**を判断(実装ではない)。
