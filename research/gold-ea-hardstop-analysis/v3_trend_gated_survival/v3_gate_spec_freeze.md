# v3_gate_spec_freeze.md — TREND_GATED_SURVIVAL v3 ゲート仕様凍結

date: 2026-07-14
性格: completion_path_decision.md §1-C の詳細凍結。**July W2 を見る前に固定する。**
本仕様は 2026-08-01 の W2 検証まで変更禁止(変更した場合、W2 は OOS 資格を失う)。

## 0. 構成

```
v3 = box v2(SHA 8B95EA45、無変更で継承) + エントリーゲート(本仕様)
```

v2 から継承(再掲・無変更): 残高比例BOX床 min(2000, 0.50×threshold) 毎tick再計算 /
BOX_EXIT=HardStop同格の事後機構 / DefenseHedge無効(config) / HardStop backstop維持 /
W3 telemetry ON。

## 1. ゲート定義(凍結)

**適用対象: 新規basketの初回エントリーのみ。** Exit/BOX/backstop/クローズ系には
一切作用しない(ゲートは「入らない」だけ。持っている玉の扱いを変えない)。

判定に使う既存フィールド(値域はv2実データで確認済み):
- `HTFState` ∈ {bullish, bearish, neutral}
- `MaTrendDirection` ∈ {strong bullish, bullish, bearish, strong bearish}

```
ゲート通過条件(エントリー方向 dir ∈ {BUY, SELL}):
  BUY:  HTFState == bullish  AND  MaTrendDirection ∈ {bullish, strong bullish}
  SELL: HTFState == bearish  AND  MaTrendDirection ∈ {bearish, strong bearish}

上記以外(neutral / 方向不一致 / 値が空・UNKNOWN)→ エントリー禁止
```

- **強度フィルタは設けない**(strong限定にしない): 選択肢を増やすこと自体が
  チューニングになるため、a priori に最も単純な「方向一致」のみ。
- UNKNOWN/空値は「不一致」として遮断するが、ログ上は `GATE_BLOCKED_UNKNOWN` と
  記録し false(=bearish等)扱いしない。
- 新しい指標・新しい閾値・新しいinputパラメータは**追加しない**
  (ON/OFFスイッチ `V3_TREND_GATE_ENABLED`(default=false)のみ追加可)。
- 既存のブロック群(News/DXY/VIX/MaxPosition/cooldown等)はそのまま。
  ゲートは既存条件への **AND追加**であり、何も緩めない。

## 2. 挿入点

既存のエントリー判定(score判定・block判定群)が全て通過した**最後**に
ゲートを評価する(既存判定の手前に置かない=既存カウンタ・トレース系の
挙動を変えないため)。ブロック時は既存の noEntryReason 系に
`V3_TREND_GATE_BLOCKED(_UNKNOWN)` を記録。

## 3. Telemetry(検証可能性の担保)

- W3ログ: BASKET_OPEN 行の detail にゲート状態(htf/ma値)を転記。
- trade events: ブロック発生時に `V3_GATE_BLOCK` イベント1行
  (方向・HTFState・MaTrendDirection を含む)。ただし同一bar内の連続ブロックは
  初回のみ記録(ログ量制御)。

## 4. 検証(事前登録 — completion_path_decision.md §1-C と同一)

- **in-sample(Mar–June)・W4 では実行しない。**初回実行は 2026-08-01 以降、
  July W2 データで **1回のみ**(50k/100k 各1本+同期間ベースライン比較用に
  現行EA W3 ON も July で実行)。
- 合否(July、双方の資本で):
  - V1: 期待値がベースライン(現行EA July実走)比で改善
  - V2: HardStop = 0(BOX床が機能)
  - V3: MaxDD がベースライン比で縮小
  - V4: basket数がベースライン比 0.5〜1.5倍(ゲートの過剰遮断・過剰取引の両方を検出)
- 合格 → 8月を W5 追加OOSとして続走 → 本番昇格審査。
- 不合格 → **エントリーエンジン再設計を正式議題化**(v3の再調整はしない)。

## 5. 禁止

本番EA無変更 / rapid_drop 0.05 FROZEN / July W2 への 8/1 前の接触禁止 /
ゲート定義・BOX床定数の変更禁止 / in-sample・W4 での v3 実行禁止 /
「15万円なら勝てる」等の利益主張禁止。
