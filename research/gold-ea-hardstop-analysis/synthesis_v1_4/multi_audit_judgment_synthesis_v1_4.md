# Gold EA HardStop Multi-Audit Judgment Synthesis v1.4

date: 2026-07-11
inputs: Audit 1(v1.3, commit 554edda)/ Audit 2(v1.4 position-level, commit 35260c1)/
Audit 3・4・5(commit 183099d)/ extraction_bundle_v1_4.zip(SHA B6B2..4800)/
baskets.csv 526行 / deals_v1_4.csv 3,498イベント。
性格: **実装判断ではない。「次に何を測るべきか」の判定合成。**
in6run は in-sample diagnostic only。june_post/pooled は post-sample を含む。
禁止事項遵守: EA/Exit/Hedge/MA Exit/Event Stop/Pre-Hedge Exit 実装なし、
rapid_drop 0.05 不変更、July W2 無接触、OOS効果・実装後利益を主張しない。
実装系フラグ全 false。capital buffer は margin不足対策としては扱わない
(margin は非拘束が確定済み)。HardStop閾値/耐久設計の文脈でのみ扱う。

---

## 0. 確定事実(position-level で固定)

| # | 事実 | 出所 |
|---|---|---|
| F1 | MainDirectionPositions 最大 = **1**(全3,498イベント) | v1.4 deals |
| F2 | 同時保有最大 = **2**(main 1 + defense hedge 1) | v1.4 deals |
| F3 | OrderLots **全て 0.01**(スケーリングなし) | v1.4 deals |
| F4 | 積み増し/lot増幅は**観測上不存在** | v1.4 deals |
| F5 | HEDGE時点 MarginLevel 最小 **2,406%** — margin不足ではない | v1.4 deals |
| F6 | Hedged HardStop はグロス両脚(中央±34,522円)が相殺され、ネット損失(中央−4,018円)として残る(gross/net ≈ 7.9倍) | v1.4 leg分解 |
| F7 | hedge は損失を**縮めず、主に凍結**する(hedge後回復せずHS到達) | Audit 2/3 |
| F8 | **LOSS_DOMINANT_BEFORE_HEDGE は position-level で支持** | v1.4 + Audit 3 |
| F9 | leg損益合計 vs v1 final_pl: 521/521 一致(同一性担保) | v1.4 identity gate |

## 1. 棄却された仮説(3件)

| 仮説 | 棄却根拠 | 証拠水準 |
|---|---|---|
| **追加Entry増幅**(gridを積んで損失拡大) | 全イベントで main position 最大1。追加エントリは1回も発生していない | position-level(観測上不存在) |
| **lot増幅**(ロットを増やして損失拡大) | OrderLots 全て 0.01 固定 | position-level(観測上不存在) |
| **margin不足**(証拠金逼迫が破綻経路) | HEDGE時点実margin最小2,406%、全イベント中央6,545%。200%割れ皆無。HardStopはfloating-loss閾値発火でありmargin-callではない | row-level(v1.4で placeholder 0.00 も解消) |

注: 棄却は「本8run・本設定において観測されなかった」の意。設定変更後
(MaxNetPositions>1 等)には再検証が必要。ただし現行EAの左裾の説明因子としては消えた。

## 2. 残る主因(HardStop 43件は2原型+横断要因に完全分解)

### M1: hedged long-duration one-way drift(32/43 = 74%)
- 滞留 中央 **141h(≈6日)**。hedge時点で既に floating 中央 −3,169円
  (LOSS_DOMINANT_BEFORE_HEDGE)。hedge後は F6/F7 のとおり凍結状態で両脚が膨張、
  回復余地はあっても(post_hedge_max_recovery 全件で存在)最終的に giveback して
  HS閾値で確定。net 中央 −4,018円。
- SIG-RD率 0.844。June の HS 6件は全てこの型。
- **未計測**: hedge発動が「遅すぎた」のか(distance_to_hs_price 欠損)、
  hedge前の最悪含み損がどこまで往復したのか(worst_floating_pl 欠損)。

### M2: non-hedged rapid adverse move(11/43 = 26%)
- 滞留 中央 **0.63h(≈38分)**。hedge を挟まず単脚のまま高速で HS 到達。
  gross=net、中央 −3,825円。
- **SIG-RD率 1.000(11/11)** — rapid drop 定義上、この型は必ず事前発火している。
- **未計測**: hedge がなぜ間に合わなかったのか(発動条件と価格経路の関係。
  これも distance/worst_floating 系 telemetry が必要)。

### M3: HardStop threshold/timing(横断要因)
- 両原型とも最終損失は**ほぼ同規模(中央 −3,746 vs −3,825)**。滞留時間が
  900倍違っても損失規模が同じ = **損失の大きさは経路ではなく閾値側で決まっている**。
- 一方で hs_loss は −3,7xx〜**−9,019** まで分布し、snapshot上の
  hardstop_threshold_yen=8,000 との関係(超過分=ギャップ/滑り?)は未計測。
- → 左裾の「深さ」の制御変数は閾値/確定タイミングにある可能性が高いが、
  threshold到達時の距離・経路 telemetry がないため確定できない。

## 3. まだ不足している P2 telemetry(3件)

| 欠損項目 | 判定できないこと | ブロックされる審査 |
|---|---|---|
| distance_to_hs_price(@hedge) | hedge_too_late(M1/M2のtiming判定) | Audit 3 timing、HEDGE_TIMING |
| worst_floating_pl(basket生涯) | hedge前の往復深度、M1の drawdown経路 | Audit 3 層化、Pre-Hedge damage control |
| post_close_move_1h/4h/24h | winner延長の可否(cap 420円の機会損失) | Audit 5、WINNER_EXTENSION |

いずれも**イベント時点のEA内部状態**であり Trade Events 再構成では取得不能。
W3 での**ログ追記(売買ロジック非接触)+ 非介入確認(OFF/ON byte一致)再実施**が必要。

## 4. 判定合成

### 支持される判定(併存)

1. **EXIT_IMPLEMENTATION_NOT_READY**(ゲート判定)
   左裾の主因は M1/M2/M3 に絞れたが、M1/M2 の timing 判定と M3 の閾値挙動が
   P2 telemetry 欠損で未確定。この状態で Exit 実装に進むと、precision 0.256 の
   SIG-RD を実弾化して winner(59.6%が380–420円帯)を殺すリスクを定量できない。
2. **CAPITAL_BUFFER_PLUS_LOSS_CONTROL_REQUIRED**(Audit 4 から継続支持)
   buffer は margin対策ではなく**HardStop連続耐久**の文脈で有効
   (150k: worst連続16.6件耐性)。ただし期待値 −147円/Basket は buffer で変わらず、
   左裾の損失制御(M3閾値側)が別途必要。
3. **PREHEDGE_DAMAGE_CONTROL_TELEMETRY_REQUIRED**(M1/M2 共通)
   worst_floating_pl + distance 系がないと pre-hedge 段階の損傷制御設計は審査不能。
4. **HEDGE_TIMING_TELEMETRY_REQUIRED**(M1 主対象、M2 の hedge不発にも適用)
5. **WINNER_EXTENSION_DATA_REQUIRED**(Audit 5 UNDETERMINED の解消条件)

### 採用しない/保留

- EXPOSURE_AMPLIFICATION_AS_HARDSTOP_DRIVER: **棄却**(§1)。
- SIG-RD の Exit条件化: 判定対象外のまま(警告としての性質は Audit 1 で確定済み。
  recall 0.88–0.92 / precision 0.26 / lead 中央3.6日 = 監視トリガ候補であって
  Exit直結ではない)。

## 5. 次工程(実装ではない)

**W3 Non-Intervening Telemetry Logging** → 完了後に実Exit設計審査。
詳細は next_decision.md。July W2 は本合成の影響を受けない(無接触継続)。
