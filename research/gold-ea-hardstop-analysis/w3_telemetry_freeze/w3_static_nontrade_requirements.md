# w3_static_nontrade_requirements.md — W3 静的非取引要件

date: 2026-07-11(Design Freeze同梱)
目的: W3コードが**構造的に**取引不能・状態不干渉であることを、実行前に
ソースレベルで機械検証できる形で規定する。

## 1. モジュール分離要件

- W3コードは専用ファイル(例: `W3Telemetry.mqh`)に隔離する。
  既存EA本体への変更は「W3関数呼出の挿入(w3_insertion_map.csv の5点)+
  #include + input スイッチ1個(W3_LOGGING_ENABLED、default=false)」のみ。
- W3モジュールは既存グローバル状態を **const参照/値渡しで読むだけ**。
  EA側変数への代入・ポインタ経由の書換を持たない。

## 2. 禁止シンボル(静的grepゲート — W3モジュール内で出現0であること)

```
OrderSend / OrderSendAsync / PositionClose / PositionModify / PositionOpen
OrderDelete / OrderModify / trade.Buy / trade.Sell / trade.PositionClose
CTrade / MqlTradeRequest / OrderCheck / SendNotification / WebRequest
Sleep / ExpertRemove / ChartClose / GlobalVariableSet
```

判定コマンド(納品時に結果添付):
`grep -nE "(OrderSend|PositionClose|PositionModify|PositionOpen|OrderDelete|OrderModify|CTrade|MqlTradeRequest|Sleep|ExpertRemove|GlobalVariableSet|WebRequest)" W3Telemetry.mqh`
→ **ヒット0行** が合格条件。

## 3. 状態不干渉要件

- W3モジュールが保持してよい内部状態は telemetry専用に限る:
  running-min(worst)、DETECT転記バッファ、前回EVAL値、失敗カウンタ、
  ファイルハンドル。いずれも EA判定から参照されないこと
  (EA本体→W3 の一方向依存。逆依存 #include を持たない)。
- 乱数・時刻取得は記録目的のみ(判定系列に影響する副作用API不使用)。
- インジケータハンドル新規作成は禁止(既存計算値の転記のみ。
  CopyBuffer等の追加呼出が既存系列の再計算を誘発する経路を作らない)。

## 4. I/O要件

- 出力は専用ファイル `KOUCHA_W3_TELEMETRY_<run>.csv` のみ。
  既存 Trade Events / Shadow snapshot ファイルへの書込・追記・open禁止。
- 書込は FileWrite 系のみ・同期・行単位。失敗時: 例外/returnエラーを握り、
  logger_fail_count++ のみ(次回成功行に記録)。**売買経路へ伝播させない。**
- OnDeinit で flush + W3_LOGGER_STATUS 1行(総行数・総失敗数・スキーマ版)。

## 5. データ規律

- MISSING は literal `MISSING`(0埋め・空文字の多義使用禁止)。
- 三値(TRUE/FALSE/UNKNOWN)は文字列のまま保存。UNKNOWN→false 変換禁止。
- 999999 等の既存センチネルを新規列で使わない。
- rapid_drop 0.05 を含む既存閾値・判定定数の参照は**読み取りのみ**
  (W3内で再定義・再計算・再チューニングしない)。

## 6. 合否

上記 §1〜§5 の全充足 + grep ゲート0ヒット = 静的合格。
静的合格後にのみ非介入回帰(w3_nonintervention_regression_plan.md)へ進む。
