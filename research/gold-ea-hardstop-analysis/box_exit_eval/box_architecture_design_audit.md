# box_architecture_design_audit.md — BOX Tail Compression Architecture Design Audit

date: 2026-07-14
性格: **設計監査・仕様凍結。実装ではない。** 実装は本仕様のユーザー承認後、
Codex が variant v2 として1回だけ実施する(§6)。本番EA無変更・July W2無接触は不変。

## 0. 判定登録(ユーザー確定、5件)

| 判定 | 状態 |
|---|---|
| BOX_EXIT_IMPLEMENTATION_NOT_READY | 確定(v1実装形は S1/S2/S3/S5 不合格) |
| BOX_TAIL_COMPRESSION_VALUE_CONFIRMED | 確定(全窓で最悪 −2.4k級 vs −9.1k級) |
| REENTRY_SUPPRESSION_REQUIRED | 確定(in6悪化の主因=再突入頻度増幅) |
| BALANCE_SCALED_BOX_REQUIRED | 確定(固定床×残高比例閾値の混在は構造破綻) |
| HEDGE_PRIORITY_CONTRACT_REQUIRED | 確定(50kでhedgeがboxを追い越しHTE48/HS3漏れ) |

設計原則(本監査の核): **「切って再突入」ではなく「切って観察停止」。**
根拠: D1600の偶発的成功(連敗チョークで in6 をベースライン比+10,400)、
D2000の再突入ループ失敗(basket 3〜4倍・−131k)、HS後24hはadverse優位
(中央77u vs fav 49u — 切った直後の同方向再突入は統計的に不利)。

## 1. R1: 再エントリー抑制 = 「BOX_EXIT を HardStop と完全同格に扱う」

**新しい抑制機構を発明しない。** BOX は「浅い位置で発動する HardStop」なのだから、
事後処理も HardStop の既存機構をそのまま通す(全て実在スイッチ、ソース確認済み):

| 既存機構 | BOX_EXIT での扱い |
|---|---|
| `ApplyHardStopAfterMode()`(mode 0/1/2) | BOX_EXIT 後に**同一関数を呼ぶ**(LastHardStopTime 等も更新) |
| `HardStopCooldownMinutes` | 同一値をそのまま適用(新cooldown値は作らない) |
| `UseHardStopOriginEntryBlock` | BOX_EXIT の発生文脈を origin として**同方向エントリーblock**に載せる |
| ConsecutiveLosses / CONSECUTIVE_LOSS_STOP | 損失としてカウント(v1から継続) |
| DailyLossPercent 系 daily stop | 既存のまま(BOX損失は日次損失に自然に算入) |

- これで「切ったら観察停止」= HardStop後と同じ停止・冷却・方向blockが働く。
  D1600 で偶発的に効いた抑制を、明示的な機構として全D値で成立させる。
- **チューニング禁止**: 上記スイッチの既定値を変えない(mode/分数の再調整は
  W2後の別議題)。変えるのは「BOX_EXITがこの経路を通ること」だけ。

## 2. R2: BOX床のスケール則 = HardStop相対

固定額 2,000円 を廃止し、**HardStop閾値相対**にする:

```
box_floor_yen = min(BOX_ABS_CAP_YEN, BOX_HS_FRACTION × hardstop_threshold_yen)
BOX_ABS_CAP_YEN   = 2000   (分離帯上端。lot固定0.01でP/Lノイズ帯は資金非依存のため)
BOX_HS_FRACTION   = 0.50   (残高減衰時も box < HS の順序を構造保証)
```

- 100k(閾値≈8,400): floor=2,000(v1と同じ、分離帯内)
- 50k(閾値≈4,200): floor=2,000(分離帯内)
- 残高減衰時(例: 閾値2,400まで縮小): floor=1,200 — 分離帯を割るが、
  **生存優先**(小資本では勝ち残存よりも尾部圧縮を優先する。EA名の思想と一致)。
- 順序保証: `box_floor ≤ 0.5×threshold < threshold(HS)` が**全残高で恒真**。
  v1 の追い越し破綻(hedge 0.78×threshold が固定2,000を下回る)は §3 で根絶。

## 3. R3: Hedge優先順位契約

**BOX有効時、DefenseHedge は無効化する**(`UseDefenseHedge=false` +
`UseSinglePositionReactiveDefenseHedge=false` を variant 設定で固定):

| 質問(ユーザー提示) | 契約 |
|---|---|
| BOX先か / Hedge先か | **BOXのみ**。hedgeは発動させない(box 0.5×thr が hedge 0.78×thr より常に先) |
| Hedge済みBasketではBOX無効か | **Hedge済みbasketは発生しない**(hedge無効化により質問自体を消す) |
| HardStopは? | **バックストップとして維持**(閾値=残高比例のまま。box失敗・ギャップ貫通時の最終防衛) |
| HTE/RecoveryClose | コード削除しない。hedge無効化により実質不発(発生したら契約違反として報告) |

根拠: hedge は position-level で「損失を縮めず凍結するだけ」(Audit 2 v1.4)、
hedge後勝ち 0/42(W3)。box が浅い床で置換する以上、hedge の存在意義は消える。
凍結trapが box を回避する v1 の漏れ(HTE48)も構造的に消滅する。

## 4. R4: 「切って観察停止」の構造(本監査の中心論点)

BOX_EXIT 後の状態遷移を明文化する:

```
BOX_EXIT発生
 → ApplyHardStopAfterMode()(既存: 停止/冷却モード遷移)
 → HardStopCooldownMinutes 経過まで新規エントリーなし(観察のみ。W3ログは継続)
 → cooldown明け: UseHardStopOriginEntryBlock により
   「BOX_EXIT origin と同方向」のエントリーは既存block条件が解除されるまで不可
 → ConsecutiveLosses が MaxConsecutiveLosses 到達なら CONSECUTIVE_LOSS_STOP(既存)
 → DailyLoss 超過なら日次停止(既存)
```

- 「観察停止」中も W3 telemetry は記録継続(停止品質の事後検証のため、
  停止中の価格経路で「入っていたらどうなったか」は**計算しない** — 反実仮想禁止)。

## 5. 事前登録: 検証は1仕様・1回のみ

- variant v2: `KOUCHA_GOLD_KIWAMI_BOX_EVAL_V2.mq5`(v1 variantから改修。本番無変更)
- 固定仕様: §1〜§4 の全て。**グリッドなし・単一設定**
  (BOX_ABS_CAP=2000 / BOX_HS_FRACTION=0.50 は本監査で凍結、実行時変更禁止)
- run: in6 6 + June 2 + W4 2(W4窓 2026-02-02〜27 再利用、baseline取得済み)= 10 run
- 合否(事前登録、後から動かさない):

| # | 基準 | 合格条件 |
|---|---|---|
| T1 | hedge発動 / HTE | **0件**(契約検証) |
| T2 | 期待値 | in6 と June の**双方**でベースライン比改善(v1は in6 で2.5倍悪化) |
| T3 | MaxDD | 双方で縮小 |
| T4 | 最悪単一basket | ≥ −(floor+slip 100円+gap許容 300円)(HS backstop発動時はHS値で別掲) |
| T5 | **basket数 ≤ ベースライン×1.5** | 再突入抑制の直接検証(v1は3〜4倍) |
| T6 | W4 | net/MaxDD/最悪が W4ベースラインより優位を維持 |

- T1〜T6 全合格 → **July W2(OOS、無接触維持)で最終判定**。
- 不合格 → **BOX路線を一旦停止**し判定合成へ戻る(in-sampleでの再修正・再走は
  しない。「勝つまで回す」の禁止)。

## 6. 実行ゲート

- 本仕様の**ユーザー承認**を待って Codex へ v2 実装依頼を発行する
  (依頼書は承認後に作成。「BOXを直して実装」ではなく本凍結仕様の転写のみ)。
- 固定フラグ全 false 維持 / rapid_drop 0.05 FROZEN / July W2 無接触 /
  「もっとも勝てる」等の利益主張なし。
