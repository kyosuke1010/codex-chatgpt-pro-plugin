# ma_closed_bar_availability_spec.md — Closed Bar / Availability仕様(FROZEN)

## 1. 目的

look-ahead bias(未来参照)を構造的に排除する。MA Signalが「その時点のEAに
本当に見えていたか」を、bar close時刻とRuntime Snapshot時刻の順序だけで定義する。

## 2. 定義

- `bar_open_time(TF, i)`: バーiの開始時刻(broker/tester時刻)。
- `bar_close_time(TF, i)`: バーiの終了時刻 = 次バーのopen時刻。
  「confirmed closed」とは、後続バーのopenが観測されたことを意味する。
- `available_time(signal)`: signalのsource barの `bar_close_time` **以降**で
  最初に存在するRuntime Snapshotの時刻。

## 3. 規則

1. **eligible点は1つ**: signalは `available_time` のSnapshot 1点でのみeligible。
   それ以前のSnapshotへの遡及(backdating)禁止。
2. **forming bar禁止**: 現在進行中バーのMA値・クロス判定を使用しない。
   テスターのtick内で「バーが閉じたように見える」中間状態も使用しない。
3. **Snapshot欠落**: bar close後にSnapshotが1件も無いままBasketが終了した場合、
   signalは `SIGNAL_CENSORED`。効果計算(P/L at signal)へ算入しない。
4. **Snapshot遅延**: bar closeからavailable_timeまでの遅延
   `availability_lag_sec` を必ず記録する。遅延が大きいsignalを除外しない
   (除外は事後最適化になる)が、分布として監査する。
5. **時刻系**: すべてbroker/tester server timeで統一。ローカル時刻・UTC混在禁止。
   タイムゾーン不明のデータ列は `TIME_BASE_UNKNOWN` として結合を保留する。
6. **バー欠損**: OHLCデータに欠損バーがある場合、その区間のMA値は
   WARMUP_UNKNOWN相当へ降格し、欠損補間(前値埋め等)を禁止する。
7. **週末/市場閉鎖**: 閉鎖明け最初のバーのcrossは通常どおり判定するが、
   `gap_after_market_close` フラグを付与し、後段診断で層別可能にする。

## 4. P/L at signal の定義

`pl_at_signal_yen` = available_timeのRuntime Snapshotに記録された
Basket P/L(swap込み・commission NA)。バーclose価格からの再計算値ではない。
Snapshotに存在しない値を価格から合成することを禁止する。

## 5. 監査項目

- available_time < bar_close_time の行: **0件であること**(違反はpipeline停止)。
- availability_lag_sec の分布(p50/p95/max)。
- SIGNAL_CENSORED件数とその内訳(HardStop直前打ち切りか否か)。
