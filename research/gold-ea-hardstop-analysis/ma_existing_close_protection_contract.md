# ma_existing_close_protection_contract.md — 既存Close経路保護契約(FROZEN)

## 目的

MA Shadow観測(および将来のいかなる候補実装)が、既存の勝ち筋・防御機構を
壊さないことを契約として固定する。

## 保護対象(削除・迂回・優先度変更を禁止)

1. **HardStop** — 最終防衛。HardStopNow=trueの局面でShadow/候補ロジックが
   いかなる形でも先回り・遅延・抑止をしない。
2. **DefenseHedge** — Hedge発動条件を変更しない。
3. **RecoveryClose / RecoveryLossCut** — 回復経路を奪わない。
4. **BasketClose** — 通常クローズ経路を奪わない。
5. **HTE** — Winner側の伸長経路を奪わない(HTE Kill報告値: 1件/-20円。
   これを増やす方向の変更は不可)。
6. **Winner Basket** — truncation報告値0件を維持する
   (ma_winner_truncation.csv で継続監査)。
7. **News / DXY / VIX / MaxPosition 制御** — 変更しない。

## Shadow段階の不変条件

- Shadow由来のorder / deal / close: **0 / 0 / 0** を維持。
- Shadow OFF/ON/A_REFERENCEの3系統回帰: 全PASSを維持
  (Phase 1実績 6/6 PASS ×3系統と同水準)。
- ロギング失敗はEA動作へ波及させない(logger error / dropped row 0を目標、
  発生時もトレードロジックへの影響ゼロを保証)。

## 将来Exit候補化の際の優先順位契約

仮に将来、いずれかのSignalがExit候補へ昇格しても、実行優先順位は:

HardStop > 既存pending close > BasketClose/Recovery/HTEのeligible成立 > 候補Exit

すなわち候補Exitは、ma_exit_candidate_safety_rules.md の全ゲート
(HardStopNow=false、ClosePriorityOK=true、pending close=false、
HTE/Recovery/BasketClose eligibility=false **かつ** known、等)を通過した
局面でのみ検討対象になる。UNKNOWNは常にブロック側に倒す
(=候補Exitを発火させない。falseと解釈しない)。

## 違反時の扱い

回帰スイートで本契約の違反が1件でも検出された場合、当該変更は
IMPLEMENTATION_BLOCKEDとしてrevertし、原因監査を成果物化するまで
再実装を禁止する。
