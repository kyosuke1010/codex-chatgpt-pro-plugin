# ma_signal_state_machine.md — Signal状態機械(Shadow観測専用)

対象: Basket × Signal family(M5 / M15 / M30 それぞれ独立)。
すべての遷移はconfirmed closed barとRuntime Snapshotのみで駆動される。

## 状態一覧

| 状態 | 意味 |
|---|---|
| S0_NO_SIGNAL | adverse cross未発生(warmup完了後の初期状態) |
| S0_WARMUP | MA warmup未完了。判定不能(UNKNOWN) |
| S0_DIRECTION_UNKNOWN | Basket方向不明。adverse判定を行わない終端保留状態 |
| S1_CROSS_DETECTED | adverse crossがclosed barで成立(まだSnapshot未到達=観測不能) |
| S2_SIGNAL_AVAILABLE | bar close後の最初のRuntime Snapshotに到達。ここが唯一のeligible点 |
| S3_PRIMARY_LATCHED | familyの最初のeligible Signalとしてlatch(以後このfamilyのprimaryは不変) |
| S4_PERSISTED_1 / _2 / _3 | latch後、adverse状態がclosed bar 1/2/3本継続 |
| S5_RECROSSED | original方向へのrecross成立(chop診断へ) |
| S6_SUBSEQUENT_SIGNAL | primary latch後の同family再Signal(chop/recross診断系) |
| S7_CENSORED | Signal available前(またはpersistence確認前)にBasketが終了 |

## 遷移規則

1. S0_WARMUP → S0_NO_SIGNAL: 両MAのwarmup完了(50 closed bars)。
2. S0_NO_SIGNAL → S1_CROSS_DETECTED: closed barでadverse cross成立。
3. S1 → S2_SIGNAL_AVAILABLE: bar close時刻以降の最初のRuntime Snapshot出現。
   Snapshotが1件も来ずBasket終了 → S7_CENSORED(SIGNAL_CENSORED)。
4. S2 → S3_PRIMARY_LATCHED: 当該familyでprimary未latchの場合のみ。
   既にlatch済みなら S6_SUBSEQUENT_SIGNAL。
5. S3 → S4_PERSISTED_n: 後続closed barでEMA10とSMA20の関係がadverse側を維持
   (BUY basketならEMA10 < SMA20継続)するごとにn++(n=1,2,3で打ち切り記録)。
6. S3/S4 → S5_RECROSSED: original方向へのcross成立
   (RECROSS_TO_ORIGINAL_DIRECTIONを記録)。
7. 任意状態 → S7_CENSORED: Basket close(HardStop含む)により観測打ち切り。
   打ち切り時点の状態を併記して保存する。

## 不変条件

- S2への到達判定にforming barを使わない。
- S3のlatchはBasket×familyで高々1回。
- DIRECTION_UNKNOWNからS1以降へ遷移しない。
- 状態機械はいかなるorder/deal/close操作もトリガしない(Shadow専用)。
- UNKNOWN(warmup / regime欠損 / direction不明)を他状態に丸めない。

## 出力

各遷移イベントを ma_shadow_observation_schema.csv のスキーマで1行として記録。
reason_codeは ma_shadow_reason_dictionary.csv に限定(自由文字列禁止)。
