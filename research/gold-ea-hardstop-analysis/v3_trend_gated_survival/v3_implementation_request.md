# v3_implementation_request.md — Codex向け v3 TREND_GATED_SURVIVAL 実装依頼書

registered: 2026-07-14
根拠: v3_gate_spec_freeze.md(凍結仕様)+ completion_path_decision.md(ユーザー承認済み経路)
性格: **実装・compile・静的確認まで。実行は一切しない。**
初回実行は 2026-08-01 以降に July W2 データで行う(別途合図する)。

## 0. スコープと保護

- ✅ variant v3 新規作成: `KOUCHA_GOLD_KIWAMI_TGS_V3.mq5`
  (**v2 variant `8B95EA45` のコピー**から。v2の box床/HS同格事後機構/hedge無効config は無変更継承)
- ❌ 本番3ファイル無変更(SHA証明: `C1DBE51A` / `36FC7066` / `1652AA38`)
- ❌ **Strategy Tester 実行禁止(全期間)**。in-sample・June・W4・July いずれも走らせない。
  compile 確認のみ。July W2 の初回接触は 8/1 以降の指示待ち
- ❌ rapid_drop 0.05 変更禁止 / 新パラメータ・新指標・新閾値の追加禁止
  (許可される追加inputは `V3_TREND_GATE_ENABLED`(default=false)の1個のみ)

## 1. 実装内容(凍結仕様の転写)

### 1-A. エントリーゲート(新規basketの初回エントリーのみ)

```
既存の全エントリー判定(score・block群)通過後の最終段で:
  BUY:  HTFState == bullish  AND  MaTrendDirection ∈ {bullish, strong bullish}
  SELL: HTFState == bearish  AND  MaTrendDirection ∈ {bearish, strong bearish}
  上記以外(neutral / 不一致 / 空・UNKNOWN)→ エントリーしない
```

- 判定は**EAが既に保持している同一の内部状態値**を参照する(trade eventsに
  出力している HTFState / MaTrendDirection の元変数。再計算・新規ハンドル禁止)。
- UNKNOWN/空は遮断するが、理由コードは `V3_TREND_GATE_BLOCKED_UNKNOWN` として
  通常の不一致(`V3_TREND_GATE_BLOCKED`)と区別する。
- Exit / BOX / HardStop backstop / クローズ系・保有中の玉には一切作用させない。
- 既存block群(News/DXY/VIX/MaxPosition/cooldown)はそのまま(AND追加のみ)。

### 1-B. ログ

- trade events: ブロック時 `V3_GATE_BLOCK` 1行(方向・HTFState・MaTrendDirection)。
  同一bar内の連続ブロックは初回のみ。
- W3: BASKET_OPEN の detail に htf/ma 値を転記。

## 2. 納品物(実行なしのため軽量)

`input_artifacts/extraction_bundle_v1/extraction_bundle_v3_impl.zip` + SHA256 manifest:

1. `KOUCHA_GOLD_KIWAMI_TGS_V3.mq5` + SHA256 + compile log(**0 errors / 0 warnings**)
2. v3 EX5 + SHA256
3. **v2→v3 diff**(変更ブロック一覧。ゲート追加+スイッチ1個+ログ以外の差分が
   ないことを示す)
4. 本番3ファイル SHA不変証明
5. 静的確認: ゲートコードが Exit/クローズ系関数を呼ばないこと(grep結果添付:
   ゲート関数内に CloseAllEaPositions / trade系呼出が無いこと)
6. July W2 実行用 config テンプレート(**作成のみ。実行しない。**
   期間 2026-07-01〜07-31、50k/100k、V3_TREND_GATE_ENABLED=true。
   併走用ベースライン config(現行EA W3 ON、July)も同梱)
7. extraction_report_v3_impl.txt(Tester実行0回の明記を含む)

push後「**v3 impl push完了**」と合図。

## 3. 8/1 以降の実行(参考。本依頼の範囲外)

W2完結後に別途「v3 W2実行」を依頼する。実行は July データで1回のみ:
v3(50k/100k)+ ベースライン(50k/100k)= 4 run。判定基準 V1〜V4 は
v3_gate_spec_freeze.md §4 で凍結済み(後から動かさない)。

## 4. 明記

- 本依頼は実装のみであり、いかなる期間のバックテストも含まない
  (「compileが通る」以外の性能情報を本依頼で生成しない=事前登録の純度維持)。
- 実装フラグ全 false 維持。variant は評価専用。利益主張なし。
