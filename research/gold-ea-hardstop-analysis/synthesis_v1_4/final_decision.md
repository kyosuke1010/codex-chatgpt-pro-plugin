# final_decision.md — Multi-Audit Judgment Synthesis v1.4 最終判定

date: 2026-07-11
性格: 実装判断ではない。全Audit統合の判定合成(次に何を測るべきかの確定)。

## 最終判定(候補5件すべてに判定を付す)

| 判定候補 | 判定 | 根拠(要約) |
|---|---|---|
| **EXIT_IMPLEMENTATION_NOT_READY** | **確定(ゲート判定・最上位)** | 主因はM1/M2/M3に絞れたが、timing/閾値挙動がP2 telemetry欠損で未確定。この状態でのExit実装はwinner殺しリスク(SIG-RD precision 0.256、winner 59.6%が380–420円帯)を定量できない |
| **CAPITAL_BUFFER_PLUS_LOSS_CONTROL_REQUIRED** | **支持(継続)** | bufferの効果は**HardStop連続耐久**(150k: worst連続16.6件)に限定。margin不足対策ではない(margin非拘束はrow-levelで確定)。期待値−147円/Basketはbufferで不変 → 左裾の損失制御(M3閾値側)が別途必須 |
| **PREHEDGE_DAMAGE_CONTROL_TELEMETRY_REQUIRED** | **支持** | M1(hedge時点で既に−3,169が支配的)・M2(38分で単脚HS)ともpre-hedge段階の経路データ(worst_floating_pl / distance系)がなければ損傷制御設計を審査できない |
| **HEDGE_TIMING_TELEMETRY_REQUIRED** | **支持** | hedge_too_late(M1)とhedge不発(M2)はdistance_to_hs_price欠損で判定不能。hedgeが「損失を縮めず凍結する」ことはposition-levelで確定済みのため、残る設計変数はtimingのみ |
| **WINNER_EXTENSION_DATA_REQUIRED** | **支持** | cap 420円・59.6%集中は確定。延長可否はpost_close_move全MISSINGでUNDETERMINED。左裾縮小と対になる右裾改善の判定材料として必要 |

## 判定の構造(1行要約)

**棄却**: 積み増し増幅・lot増幅・margin不足(いずれも観測上不存在/非拘束)。
**残存**: M1 hedged長期drift(74%)+ M2 non-hedged高速逆行(26%)+ M3 閾値/確定タイミング(横断)。
**不足**: distance_to_hs_price / worst_floating_pl / post_close_move / threshold-gap の4 telemetry。
**次工程**: W3 Non-Intervening Telemetry Logging(非介入確認再実施つき)→ その後に実Exit設計審査。

## 有効範囲と制約

- 全判定は in-sample(+June post-sample)診断に基づく。OOS効果・実装後利益を主張しない。
- 「15万円なら勝てる」とは記述しない(capital bufferは耐久文脈のみ)。
- 棄却判定は現行設定(MaxNetPositions=1運用・lot 0.01)の観測に基づく。設定変更時は再検証。
- July W2 は本合成の影響を受けない(事前登録条件のまま、無接触)。
- 実装系フラグ全 false 維持。EA / mq5 / mqh / EX5 無変更。rapid_drop 0.05 FROZEN。
