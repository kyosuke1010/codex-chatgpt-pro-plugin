# ma_signal_contract.md — MA Signal定義契約(FROZEN)

version: 1.0.0
status: FROZEN — 本契約の変更はバージョン更新と差分記録なしに行わない。
本契約はShadow観測専用であり、Exit/Entry実装を許可しない。

## 1. Moving Average定義

| 項目 | Fast MA | Slow MA |
|---|---|---|
| 種別 | EMA | SMA |
| period | 10 | 20 |
| applied price | close | close |
| bar種別 | confirmed closed bar のみ | confirmed closed bar のみ |

- forming bar(現在進行中バー)の値は一切使用しない。
- EMA warmup: 系列先頭から最低 5 × period(=50本)の閉じたバーを経過するまで
  MA値は `WARMUP_UNKNOWN` とし、Signal判定に使用しない。
- EMA seed: 先頭period本のSMAをseedとする(Offline Overlay pipelineで固定)。

## 2. Timeframes

M5 / M15 / M30 の3系統。各系統は独立に計算し、系統間で値を補間しない。

## 3. Cross定義(closed bar 2本による判定)

前提: `prev` = 直前確定バー、`curr` = 最新確定バー。両バーのMA値が
WARMUP_UNKNOWNでないこと。いずれかがUNKNOWNなら判定は `CROSS_UNKNOWN`。

- **Bull cross**: prev: EMA10 <= SMA20 かつ curr: EMA10 > SMA20
- **Bear cross**: prev: EMA10 >= SMA20 かつ curr: EMA10 < SMA20
- どちらでもない: NO_CROSS

等号は「クロス前状態」側に含める(上記定義のとおり)。同一バーで
Bull/Bear両成立はあり得ない(定義上排他)。

## 4. Basket方向へのadverse cross

- BUY Basket: **bear cross** がadverse
- SELL Basket: **bull cross** がadverse
- Hedged Basket: **original basket direction**(Hedge前の方向)を基準とする。
  Hedge建玉の方向でadverse判定を反転させない。
- direction不明: `DIRECTION_UNKNOWN` を付与し、adverse/favorable判定を行わない。
  DIRECTION_UNKNOWNをどちらかに丸めることを禁止する。

詳細マッピングは ma_direction_mapping.csv を参照。

## 5. Signal availability(観測可能時刻)

- Signalがeligibleになるのは、**当該バーclose後の最初のRuntime Snapshot**のみ。
- forming barの使用禁止。
- bar close前の時刻へSignalを遡及させることを禁止(look-ahead禁止)。
- 詳細は ma_closed_bar_availability_spec.md。

## 6. First Signal規則

- Basketごと、Signal familyごと(例: M15_REVERSE_CONFIRMED)に、
  **最初にeligibleになったSignalのみをprimary**とする。
- 後続の同familyのSignalはchop / recross診断系へ回し、
  primary効果計算(one-step診断)には使用しない。

## 7. M30 Regime定義

confirmed closed barのM30系列で:

- EMA10 > SMA20: `BULL_REGIME`
- EMA10 < SMA20: `BEAR_REGIME`
- EMA10 == SMA20: `FLAT_OR_EQUAL`
- MA値欠損/warmup中: `UNKNOWN`

UNKNOWNをFLAT扱い・どちらかのregime扱いすることを禁止。

## 8. M5 Retest Proxyの限界(命名契約)

現行のM5条件は本物のretest failure(サポート/レジスタンス再試験の失敗)を
検出していない。正式名称は **`M5_REVERSE_FOLLOWTHROUGH_PROXY`** とし、
文書・スキーマ・コード内で `EXPLICIT_RETEST_FAILURE` と呼ぶことを禁止する。
proxyであることを常に明示する(rescue 27件 / harm 12件と、M30併用時
(rescue 26 / harm 3)より害が多い報告値もこの限界と整合)。

## 9. commission / fee

commissionは不明であり **NA** のまま扱う。0円と仮定した効果計算を禁止。
すべての効果値は `ex_commission` サフィックスで表記する。
