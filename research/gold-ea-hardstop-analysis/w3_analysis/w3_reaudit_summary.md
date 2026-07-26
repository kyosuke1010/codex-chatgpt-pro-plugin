# w3_reaudit_summary.md — W3 telemetry 再審査結果(3件)

date: 2026-07-12
inputs: extraction_bundle_w3(検収済み、w3_acceptance_report.md)。
全結果は診断であり、採用判断・OOS効果・実装後利益・「15万円なら勝てる」を主張しない。
baseline_tag: JUNE=V1_IDENTICAL / ML 5run=V1_MOSTLY_IDENTICAL / 50k MAR_MAY=NEW_BASELINE。
出力CSV: w3_hedge_timing_analysis / w3_threshold_gap_analysis /
w3_worst_floating_profile / post_close_move_w3。

## 再審査1: Audit 3 timing — **HEDGE_TOO_LATE を確定**

HEDGE_TIMING 42件(全run):

| 指標 | 値 |
|---|---|
| hedge発動時の閾値消費率 | 中央 **77.7%**(min 75.8 / max 90.4) |
| hedge発動時の残余距離 | 中央 **≈800円**(閾値≈8,000-8,500に対し) |
| hedge後の最終行き先 | **HARDSTOP 29 / HTE 7 / DEINIT等 6 / BasketClose勝ち 0** |

1. **hedge は常に「閾値の3/4を失ってから」発動する**。消費率の分布が 75.8–90.4% に
   密集 = 発動条件が実質「深い損失」そのものであり、早い/遅いのバラツキすらない。
2. **hedge後に勝ちで終わった basket は 0/42**。hedge は敗退確定の通過点
   (HARDSTOP 69% か時間切れ退出 17%)であり、回復装置として機能していない。
   → v1.4 の「hedgeは凍結するだけ」所見を、発動タイミングの側から完結させた。
3. M2(hedge不発の高速型): W3ベースラインの non-hedged HS は検知時点で既に
   閾値到達しており、hedge評価が深度に達する前に終わる(38分型)。
   → 不発は「ブロックされた」のではなく「間に合う設計になっていない」。

**判定更新: HEDGE_TIMING_TELEMETRY_REQUIRED → 解消。
hedge_too_late = CONFIRMED(構造的。個別の遅延ではなく発動条件の深さが原因)。**

## 再審査2: M3 threshold gap — **滑り・ギャップは小、遅延テールは実在**

HARDSTOP 39件(detect→close 3点計測):

| 指標 | 値 |
|---|---|
| detect時の閾値超過 | 中央 −48円(最大 −314円) |
| close時 threshold_gap_yen | **中央 0円、範囲 [−54, +141]** |
| detect→close 時間 | 中央 **5分**。ただし **>60分が4件、最大1,504分(25時間)** |
| close request 回数 | 中央 618回、最大 **21,442回**(市場閉場リトライループ) |

1. **閾値を超えてからの「深掘れ」はほぼゼロ**(gap中央0円)。v1で見えた
   最悪 −9,019 は滑りではなく、**残高別の閾値差(50k/100kで閾値自体が異なる)**
   の範囲内。→ 左裾の深さは threshold 設定そのもので決まっている。
2. ただし**確定遅延のテールが実在**: 市場閉場を跨ぐと close request が
   数千〜2万回リトライされ、確定まで最大25時間。今回の観測では reopen時の
   ギャップ被害は小さかった(gap≤141円)が、**構造としては閉場跨ぎの
   無防備な露出窓**であり、テール条件(週末大ギャップ)では拡大し得る。

**判定更新: M3 = threshold設定が左裾を直接支配(滑り要因は小)。
閉場跨ぎ確定遅延はリスク登録簿へ(観測4/39、実害は今回小)。**

## 再審査3: Audit 5 winner extension — **データ到着、UNDETERMINED解消**

post_close_move(offline結合、price単位。0.01 lotでは 1 price ≈ 100円):

| close_reason | 窓 | favorable中央 | p90 | adverse中央 | n(有効) |
|---|---|---|---|---|---|
| BasketClose勝ち | 1h | **10.1**(≈1,000円) | 33.2 | 7.9 | 435 |
| BasketClose勝ち | 4h | 24.0 | 58.6 | 14.2 | 409 |
| BasketClose勝ち | 24h | 51.7 | 132.9 | 48.6 | 341 |
| HardStop | 1h | 14.0 | 40.9 | 24.3 | 10(29 MISSING=閉場跨ぎ) |

1. **勝ちクローズ後1時間の順行 中央≈1,000円相当 — 勝ち確定額(+400円cap)の約2.5倍**
   が、クローズ直後に同方向へ動いている。右裾を cap が切っている事実は
   post-close実測で裏付けられた。
2. ただし adverse も 1h中央 ≈790円相当あり、「延長すれば取れた」とは**言えない**
   (往復の中でどこで降りるかの設計問題。反実仮想利益は主張しない)。
3. HardStop後は有効n=10(閉場跨ぎクローズが多くMISSING 29)で LOW_N。
   参考: 24h adverse中央77(≈7,700円) > favorable 49 — HS方向へさらに逝く傾向。

**判定更新: WINNER_EXTENSION_DATA_REQUIRED → データ充足。
延長可否の判定は実Exit設計審査の議題へ(このデータで審査可能)。**

## 付帯: worst-floating プロファイル(481 basket)

| 群 | n | worst生涯中央 | worstからの回復中央 |
|---|---|---|---|
| BasketClose勝ち | 435 | **−362円** | +706円 |
| HardStop | 39 | −4,005円 | **+4円** |
| HTE系 | 7 | −1,700円前後 | +16〜83円 |

- **勝ちは浅く、負けは戻らない**: 勝ち basket の96%は生涯 −1,000円より深く沈まない
  …ではなく、120/435(28%)は −1,000超まで沈み、**18/435 は −3,000 超まで沈んでから
  勝ち切っている**。一方 HS 39件の worst_pre 中央は −3,548。
- → **−3,000 近辺は「勝ち18 vs 負け39」の混在帯**。単純な深度カットは winner を
  殺す(この定量が実Exit設計審査の中心材料になる)。

## 総括(判定の現在地)

| 判定 | 状態 |
|---|---|
| HEDGE_TIMING_TELEMETRY_REQUIRED | **解消 → hedge_too_late CONFIRMED** |
| PREHEDGE_DAMAGE_CONTROL_TELEMETRY_REQUIRED | **解消**(worst_floating 全basket取得) |
| WINNER_EXTENSION_DATA_REQUIRED | **解消**(post_close_move 実測) |
| M3 threshold/timing | **確定**(閾値支配・滑り小・閉場跨ぎ遅延テールあり) |
| EXIT_IMPLEMENTATION_NOT_READY | **維持** — ただし理由が「データ不足」から「設計審査未実施」に変わった。3審査の材料は揃った |

次: 実Exit設計審査(実装ではない)を開始できる状態。G8故障注入と
1353718F→C1DBE51A 差分証明は並行残課題。
