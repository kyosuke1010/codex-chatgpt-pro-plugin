# prospective_july_preregistration.md — July-2026 locked post-sample 事前登録(W2)

status: PRE_REGISTERED / FROZEN
selection_time: 2026-07-03
authored_before_any_july_result: true
parent_protocol: prospective_preregistration_protocol.md(条件は一切変更しない)

## 1. 位置づけ

June(W1)で decision_class = PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED と判定された。
十分性(HardStop累積 ≥15 / 非Hedged ≥2 / slope欠損率 ≤0.30)未達のため、
**同一条件のまま** 次の locked post-sample 窓 July(W2)を追加収集する。

W1と同様、July(2026-07)は選定時点で**まだ完結していない**が、窓は結果確認前に
固定する(pre-registration)。収集は月末完結後にMT5側で実行する。
「live prospective」ではなく **locked post-sample validation window** として扱う。

## 2. 固定事項(W1から一切変更しない)

| 項目 | 固定値 |
|---|---|
| selected_window | 2026-07-01 00:00:00 〜 2026-07-31 23:59:59 |
| half_open_window | [2026-07-01 00:00:00, 2026-08-01 00:00:00) |
| selection_time | 2026-07-03 |
| symbol / timeframe / model | GOLD / M5 / 0(every tick) |
| deposits | 50,000 / 100,000 |
| shadow_arms | ML_B_SHADOW_OFF(非介入参照)+ ML_C_SHADOW_ON(観測) |
| leverage / currency | 1:888 / JPY |
| EA同一性 | shadow log `source_before_sha256` == 1353718F…(in-sample/Juneと同一) |
| rapid_drop トリガ | normalized_3min_loss_slope >= **0.05/min**(固定・不変更) |
| slope定義 / 分類 / 十分性閾値 / 窓判定 | すべてW1と同一(変更禁止) |

## 3. W1からの唯一の追加(条件変更ではない)

- **M5 / M15 / M30 の bar data を bundle に同梱する。**
  これは観測入力の追加であって、EA・閾値・判定条件の変更ではない。
  目的は Q2(Pre-Hedge MA warning harm過多)/ Q4(BC-kill vs HardStop)を
  EMA10/SMA20 契約(ma_signal_contract.md v1.1.0)で評価可能にすること。
  MA warning は**観測のみ**。Exit化・Entry化・Event Stop は実装しない。

## 4. 禁止(継続)

- 窓の後からの差し替え / July結果を見た条件・閾値の調整
- EA / mq5 / mqh / EX5 の変更
- Exit / Entry / Hedge / HardStop / Close Priority の変更
- rapid_drop 0.05・slope条件・判定閾値・分類・成功基準の変更
- MA warning の Exit化、Event Stop 実装
- OOS効果・本番期待利益の主張 / full EA counterfactual
- 実Exit設計審査へ進むこと(十分性達成まで)

## 5. 十分性(累積・W1+W2+…)

以下を**累積**で満たすまで MORE_DATA_REQUIRED を継続:
- HardStop累積 ≥ 15
- 非Hedged HardStop累積 ≥ 2
- slope欠損率(HardStop対象)≤ 0.30

満たした場合のみ、in-sample と post-sample の整合レポートを作成し、
実Exit設計審査の**開始可否**を別工程で判断する(本工程では判断しない)。

## 6. 固定フラグ(継続)

P1=false / real_exit=false / prehedge_exit=false / ma_cross_logic=false /
hedge_gate=false / event_stop=false。
