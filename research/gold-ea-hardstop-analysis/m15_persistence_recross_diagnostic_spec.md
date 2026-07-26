# m15_persistence_recross_diagnostic_spec.md — M15 Persistence / Recross診断仕様(v1.0.0)

status: DIAGNOSTIC_ONLY — M15逆クロスExitは失格確定
(素: BC Kill -56,597円 / harm/gross 0.768、Pre-Hedge帯限定: 合計-10,258円 / 1.221)。
本仕様はExit条件ではなく、警告Signalの「質」を層別する診断項目を定義する。

## 1. 診断項目(Basket × M15 first signalごと)

| 項目 | 定義 | 取得 |
|---|---|---|
| first_reverse_cross | ma_signal_contract v1.1.0のM15 adverse cross初回 | Offline Overlay |
| recross_to_original | original方向への再クロス成立 | Offline Overlay |
| minutes_to_recross | first signal→recrossの分数(なければCENSORED) | Offline Overlay |
| persisted_1/2/3_bars | latch後、adverse状態がM15確定バーn本継続 | Offline Overlay |
| ma_gap_at_signal | signal時点の EMA10−SMA20 乖離(price単位と閾値比の両方) | Offline Overlay |
| ma_gap_after_1/2/3_bars | 後続確定バーごとの乖離推移(拡大=本物/縮小=chop仮説) | Offline Overlay |
| best_recovery_after_signal_yen | signal後のBasket P/L最良値 − signal時P/L | Snapshot系列 |
| worst_deterioration_after_signal_yen | signal後のBasket P/L最悪値 − signal時P/L | Snapshot系列 |
| hte_became_eligible_later | signal時false→その後true化(HTE Kill -20円型の検出) | Snapshot系列 |
| basketclose_became_eligible_later | 同上(BC Kill 26件型の検出) | Snapshot系列 |
| minutes_to_later_eligibility | signal→後発eligible化までの分数 | Snapshot系列 |

既存データでの裏付け: signal_after_best_recovery_yen /
signal_after_worst_deterioration_yen はOverlay Auditに既存列があり、
後発eligible化はSnapshotのcurrent_*_eligibility系列から導出可能
(HTE Kill 1件は classification=HTE_BECAME_ELIGIBLE_LATER として実証済み)。

## 2. 検証したい仮説(prospectiveで判定・in-sample合わせ込み禁止)

- H1: persisted_2_bars以上のM15 signalは、recrossするsignalより
  HardStop到達率が高い(=chopフィルタとしてのpersistence)。
- H2: ma_gapが後続バーで拡大するsignalはBC Killになりにくい
  (=BasketCloseで済む浅い逆行と、HardStopへ向かう深い逆行の分離)。
- H3: persistence待ちにより、BC Kill 26件のうち回復系
  (best_recovery大)を除外できる一方、rescue 29件のリードタイム
  (median 8,446分)は十分長く、1〜3バー(15〜45分)の遅延では失われない。
- H4: 後発eligible化(HTE/BC)は minutes_to_later_eligibility の分布で
  予見可能な帯があるか(なければ残余リスクとして固定)。

## 3. 明示的な非目標

- persistence n本を「Exit条件」として選定しない。
- H1〜H4の閾値を既存6runの成績で最適化しない。
- M15 warning-onlyの地位(M15_REVERSE_WARNING_ONLY)を変更しない。
