# implementation_not_allowed_statement.md — 実装不許可宣言

date: 2026-07-02
scope: 本宣言は次回の明示的な設計レビューで解除されるまで有効。

## 現時点で実装を許可しないもの

1. **TA9実決済** — Post-Hedge圧縮候補に留まる。単独では左裾根本対策に不足
   (既知判断)。one-step診断のみで実決済化する根拠がない。
2. **M15逆クロスExit** — in-sample one-step Basket診断(rescue +63,961円等)は
   実装後利益でもOOS効果でもない。full EA counterfactual
   (救済後の後続Basket連鎖)は主張不能。prospective/OOS検証前の実装を禁止。
3. **MA Cross Entry** — Entry側の検証は未着手。禁止。
4. **Event Stop** — Event Windowは観測段階。EA NewsBlockとの突合すら未完。禁止。
5. **Hedge Gate / Pre-Hedge Exit / Hedge Unwind** — Hedged HardStopの
   giveback vs 遅延の切り分け(Phase B充填)が未完。禁止。
6. **Runtime MA telemetry**(iMA / CopyBuffer / PerfCopyBuffer / CopyRatesの
   EA内新規呼び出し)— indicator cache汚染リスク。OFFLINE_OVERLAY_ONLYが確定。
7. **既存ロジックの削除・変更** — BasketClose / RecoveryClose / RecoveryLossCut /
   HardStop / DefenseHedge / HTE / News / DXY / VIX / MaxPosition すべて不可侵。
8. **実口座 / live / demo forward への移行** — いかなる形でも不可。

## 許可されているもの

- Offline Overlay pipeline(EA外)の実装
- 既存Phase 1 Shadow Loggingの継続(無変更)
- 本設計Freeze群(契約・スキーマ・規則文書)の維持管理
- 入力成果物再配置後のPhase B/F/G CSV充填(分析のみ)

## 解除条件

実Exit系の実装検討を再開するには、最低限:

1. Phase B/F/G CSVの充填完了(in-sample)
2. prospective期間のShadow観測データが十分量(左裾イベントを含む)
3. prospective期間でのrescue/harm/kill/truncationがin-sample診断と整合
4. OOSまたはfuture native tick検証の合格
5. ma_existing_close_protection_contract.md の全項目維持の機械検証

を満たし、新たな設計レビューで文書化された承認を得ること。

## 免責

本研究のいかなる数値も将来の利益を保証しない。すべての効果値は
in-sample one-step診断であり、commission NA・スリッページ未考慮である。
