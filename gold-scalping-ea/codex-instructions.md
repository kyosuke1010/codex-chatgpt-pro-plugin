# 指示書: XAUUSD M1 スキャルピングEA「GoldScalperPro」の実装

あなたはMQL5のエキスパートです。以下の仕様を**全て**満たすMT5用EAを、
単一の `.mq5` ファイルとして実装してください。仕様にない機能を勝手に
追加しないこと。特に「禁止事項」(§10)は絶対に守ること。

## 1. 目的と設計原則

- 対象: XAUUSD(ゴールド)、判定タイムフレームは M1 固定(チャートの時間足に依存しない)。
- 戦略: M1 平均回帰スキャルピング。エッジは「エントリーの巧さ」ではなく「悪条件で撃たないこと」と資金管理にあるという前提で、多層フィルタを実装する。
- **全ての売買判定は確定バー(shift=1)の値のみ**を使う。フォーミング中のバー(shift=0)を判定に使うと先読みバイアスが生じるため禁止。エントリーは条件成立後の新バー寄付での成行注文。
- 新規バー検出は `iTime(_Symbol, PERIOD_M1, 0)` の変化で行う。シグナル処理は新バー時のみ、ポジション管理(§7)は毎ティック実行。
- 同時ポジションは最大1。全ポジションに発注時点で必ずハードSLを付ける。SLが設定できない状況なら発注しない。
- `CTrade`(`<Trade/Trade.mqh>`)を使用。マジックナンバーとシンボルで自分のポジション・約定のみを操作対象にする。

## 2. 入力パラメータ(デフォルト値込みで全て `input` 定義)

### 識別
| 名前 | 型 | デフォルト |
|---|---|---|
| Magic | long | 20260715 |
| Comment | string | "GSP" |

### リスク
| 名前 | 型 | デフォルト | 意味 |
|---|---|---|---|
| RiskPct | double | 0.30 | 1トレードのリスク(残高比%)。0より大きく2.0以下でなければ `OnInit` で `INIT_PARAMETERS_INCORRECT` |
| DailyLossLimitPct | double | 2.0 | 日次損失がこの%に達したら当日の新規停止 |
| MaxTradesPerDay | int | 6 | 1日の最大エントリー数 |
| MaxConsecLosses | int | 3 | この連敗数でクールダウン開始 |
| CooldownMinutes | int | 90 | クールダウン時間(分) |

### シグナル
| 名前 | 型 | デフォルト | 意味 |
|---|---|---|---|
| BbPeriod / BbDev | int / double | 20 / 2.0 | M1ボリンジャーバンド |
| RsiPeriod | int | 3 | M1 RSI |
| RsiOversold / RsiOverbought | double | 15 / 85 | RSI極値の閾値 |
| MinStretchAtr | double | 1.0 | ミッドバンドからの最小乖離(ATR倍) |
| TrendFilter | enum | WITH | OFF=なし / WITH=M5 EMA(200)の上ならロングのみ・下ならショートのみ / AGAINST=その逆 |
| EntryConfirm | enum | REENTRY | NONE / REENTRY / REVERSAL_BAR(§5参照) |
| ConfirmTimeoutBars | int | 5 | 戻り確認の待機上限バー数 |

### エグジット
| 名前 | 型 | デフォルト | 意味 |
|---|---|---|---|
| SlAtrMult | double | 1.5 | SL距離 = ATR(14, M1) × この値 |
| TpRR | double | 1.2 | TP = SL距離 × この値(固定RR) |
| BeTriggerRR | double | 0.7 | 含み益がこのR倍に達したらSLを建値へ |
| BeOffsetPoints | double | 5 | 建値移動時のオフセット(point) |
| MaxHoldMinutes | int | 20 | タイムストップ(分)。0で無効 |

### レジームゲート
| 名前 | 型 | デフォルト | 意味 |
|---|---|---|---|
| MaxSpreadPoints | int | 35 | スプレッド上限(point) |
| MinAtrPoints / MaxAtrPoints | double | 15 / 120 | ATR(14, M1)の許容レンジ(point換算) |
| Session1 / Session2 | string | "10:00-13:00" / "15:30-19:00" | 稼働時間帯(サーバー時刻)。空文字は無効。両方無効なら `OnInit` 失敗 |
| Blackout | string | "" | "HH:MM-HH:MM,HH:MM-HH:MM,..." 形式の停止時間帯(指標対策)。不正な要素は警告して無視 |
| FridayLastHour | int | 18 | 金曜この時以降は新規なし |
| TradeMonday | bool | true | 月曜稼働の可否 |

時間帯文字列は `OnInit` で「その日の分(minute-of-day)の範囲」にパースして
保持する。範囲判定は `from <= 現在分 < to`。

## 3. インジケータ

`OnInit` でハンドルを作成し、`OnDeinit` で解放する:
- `iBands(M1, BbPeriod, 0, BbDev, PRICE_CLOSE)` — バッファは BASE_LINE=0, UPPER_BAND=1, LOWER_BAND=2
- `iRSI(M1, RsiPeriod, PRICE_CLOSE)`
- `iATR(M1, 14)`
- `iMA(M5, 200, 0, MODE_EMA, PRICE_CLOSE)`

ハンドル作成失敗時は `INIT_FAILED`。値の取得は全て `CopyBuffer(handle, buf, 1, 1, arr)`
(shift=1 の確定バー)で行い、戻り値が 1 でなければその処理をスキップする。

## 4. レジームゲート(新規エントリー許可条件、全て AND)

1. 曜日: 土日不可。金曜は `FridayLastHour` 以降不可。月曜は `TradeMonday` に従う。
2. セッション: 現在時刻(サーバー時刻)が Session1 または Session2 の範囲内。
3. ブラックアウト: どの Blackout 範囲にも入っていない。
4. スプレッド: `SYMBOL_SPREAD` ≤ MaxSpreadPoints。
5. ボラティリティ: ATR(14, M1) を point 換算した値が [MinAtrPoints, MaxAtrPoints] 内。
6. 日次損失ガード: 当日開始エクイティからのドローダウンが DailyLossLimitPct 未満。到達したら当日中フラグで停止し、ログ出力。
7. 当日エントリー数 < MaxTradesPerDay。
8. クールダウン中でない(§8)。

日次カウンタ(開始エクイティ・エントリー数・停止フラグ)はサーバー日付の
変わり目で毎ティック検知してリセットする。

## 5. シグナルとエントリー確認(最重要仕様)

### 5.1 セットアップ(極値)検出 — 確定バー(shift=1)で判定

ロング条件(ショートは完全対称):
- 終値 < ボリンジャーバンド下限
- RSI < RsiOversold
- |終値 − ミッドバンド| ≥ MinStretchAtr × ATR
- TrendFilter=WITH の場合: 終値 ≥ M5 EMA(200) であること(ロング)

### 5.2 エントリー確認ステートマシン

極値バーを検出しても**即エントリーしない**(EntryConfirm=NONE を除く)。
「戻りを確認してから入る」ための状態遷移を実装する:

- 状態変数: `pendingDir`(0=なし / +1=ロング待機 / −1=ショート待機)、`pendingBars`(待機経過バー数)。
- **アーム**: pendingDir==0 で極値検出、かつレジームゲート通過時 → EntryConfirm=NONE なら即エントリー、それ以外なら pendingDir にセットし pendingBars=0。
- **待機中の新バーごとの処理**(この順で評価):
  1. pendingBars をインクリメント。
  2. 同方向の極値が再出現 → pendingBars=0 にリセット(セットアップ延命)。
  3. 逆方向の極値が出現 → pendingDir を反転し pendingBars=0。
  4. それ以外で**確認成立**(下記) → レジームゲートを**この時点で再判定**し、通過ならエントリー、不通過ならセットアップ破棄(エントリーしない)。
  5. pendingBars ≥ ConfirmTimeoutBars → セットアップ破棄。
- **確認成立の定義**(確定バー shift=1):
  - REENTRY: ロングなら終値がバンド下限より**上**で引けた(バンド内へ回帰)。
  - REVERSAL_BAR: REENTRY の条件に加え、バー自体が反転方向(ロングなら 終値 > 始値 の陽線)。
- ポジション保有中は pendingDir を強制的に 0 にする(セットアップを裏に溜めない)。
- 1本のバーで複数回エントリーしないこと(エントリーしたバー時刻を記録して抑止)。

## 6. ロット計算と発注

- SL距離 = SlAtrMult × ATR(14, M1)。ただしブローカーの `SYMBOL_TRADE_STOPS_LEVEL` + 2point を下回る場合はそこまで広げる。
- ロット = (残高 × RiskPct / 100) ÷ (SL距離 / `SYMBOL_TRADE_TICK_SIZE` × `SYMBOL_TRADE_TICK_VALUE`)。
- `SYMBOL_VOLUME_STEP` で切り捨て正規化。`SYMBOL_VOLUME_MIN` 未満になったら**エントリーしない**(最小ロットに切り上げるとリスク上限を破るため。ログを出す)。`SYMBOL_VOLUME_MAX` で上限クリップ。
- 発注: 成行(`CTrade::Buy/Sell`)、スリッページ許容20point、SL/TP同時指定。価格は `SYMBOL_TRADE_TICK_SIZE` の倍数に丸めてから `NormalizeDouble(…, _Digits)`。
- TP = エントリー価格 ± TpRR × SL距離。
- 失敗時は `ResultRetcodeDescription()` をログ。

## 7. ポジション管理(毎ティック)

自分のポジション(シンボル+マジック一致)に対して:
1. **タイムストップ**: 保有時間が MaxHoldMinutes 分に達したら成行クローズ。「回帰しないスキャルは負けの前兆」という思想。
2. **ブレークイーブン**: 含み益 ≥ BeTriggerRR × リスク距離(|建値−SL|)で、SLを 建値±BeOffsetPoints へ移動(有利方向にのみ更新。既にそれより有利なら何もしない)。

## 8. 決済監視(`OnTradeTransaction`)

`TRADE_TRANSACTION_DEAL_ADD` のうち、自分の `DEAL_ENTRY_OUT` の約定について
損益(profit + commission + swap)を判定:
- 負なら連敗カウント++。MaxConsecLosses 到達で `現在時刻 + CooldownMinutes` までクールダウンし、カウントをリセット、ログ出力。
- 正またはゼロなら連敗カウントをリセット。

## 9. その他の実装要件

- `OnInit` でシンボル名に "XAU"/"GOLD" を含まない場合は警告ログ(停止はしない)。チャートがM1以外でも警告のみ。
- `CTrade::SetTypeFillingBySymbol(_Symbol)` を呼ぶこと。
- コンパイル警告ゼロを目標。`#property strict`。
- コメントは英語または日本語で、各モジュール境界(ゲート/シグナル/確認/サイジング/管理)が分かるように。

## 10. 禁止事項(絶対)

- ナンピン、マーチンゲール、グリッド、両建て、SLなしポジション、SLの不利方向への移動。
- shift=0(未確定バー)の値による売買判定。
- 最小ロットへの「切り上げ」によるリスク上限超過。
- 経済指標カレンダーAPIへの依存(テスターで再現性がないため。指標回避は Blackout 入力の手動指定で行う)。

## 11. 納品後の検証手順(コードと一緒にREADMEへ記載すること)

1. MT5ストラテジーテスター「全ティック(リアルティック)」+ 実スプレッドで最低2年。
2. In-Sample 70% でのみ最適化(対象は RsiOversold/Overbought, MinStretchAtr, SlAtrMult, TpRR, EntryConfirm の3モード比較に限定)。Out-of-Sample 30% で PF > 1.15 を確認。
3. ウォークフォワード: 6ヶ月最適化→2ヶ月検証を転がし、全窓合算が右肩上がりであること。
4. ストレステスト: スプレッド+50%でも期待値が正であること。
5. デモフォワード1〜2ヶ月 → 最小ロット実弾。ここを通過するまで「利益が出るEA」とは呼ばない。
