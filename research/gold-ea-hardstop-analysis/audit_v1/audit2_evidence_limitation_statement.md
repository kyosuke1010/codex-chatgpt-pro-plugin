# audit2_evidence_limitation_statement.md — Audit 2 証拠制約ステートメント

date: 2026-07-11
**改訂(同日、v1.4到着後)**: 以下の項目は v1.4(deals_v1_4.csv)で解消した —
position_pl_final(CLOSE行 ProfitYen、521/521で final_pl と一致)、
max_positions(全イベント上限 main1+hedge1=2)、lot(全て0.01固定と確定)、
margin_level 実値(HEDGE時点 min 2,406%。0.00 placeholder 解消)。
**残存する制約**: distance_to_hs_price / worst_floating_pl(時系列最悪値)/
post_close_move_1h/4h/24h は依然 EVIDENCE_UNAVAILABLE(P2=W3ログ追記待ち)。
open_time の直接ENTRY照合は 400/526(126件は interval割当。close/final_pl は
521/526一致+5 DEINIT想定内)。以下の本文は v1.4 到着前の記録として保存。
目的: Audit 2(exposure amplification)で **何が証拠不能か** を明示固定し、
未取得値の 0 扱い・過大解釈を防ぐ。

## 1. EVIDENCE_UNAVAILABLE(固定)— position/lot exposure amplification

以下は本 bundle(v1 core + v1.3 signals)で取得できない。**0 で代替しない**:

| 指標 | 必要列 | 本bundleの状態 |
|---|---|---|
| 個別 entry の最終損益 | entries.position_pl_final | 0/526 全MISSING |
| basket内の最大同時ポジション数 | baskets.max_positions | 0/526 全MISSING |
| basket内の総エントリ数 | baskets.total_entries | 0/526 全MISSING |
| basket内の最大合計ロット | baskets.max_lot_sum | 0/526 全MISSING |
| HardStop時のポジション数 | hardstops.positions_at_hs | 0/43 全MISSING |
| HardStop時の合計ロット | hardstops.lot_sum_at_hs | 0/43 全MISSING |

さらに snapshot 由来のポジション/ロット列は **DEGENERATE定数**:
- positions_at_fire = 全て 1、lot_sum_at_fire = 全て 0.01、hedge_lot = 全て 0.01。
- 理由: SHADOW ログは **SELL_NET#1 root スナップショットのみ**を記録し、
  ネットグリッド(複数ポジション)を集約しない。したがって「エントリを積み増して
  exposure を増幅した」という **grid増幅の識別情報は 0**。

**帰結**: 「position数 / lot が増えるほど損失が増幅した」という命題は、
本 bundle では **定量にも定性にも判定できない(EVIDENCE_UNAVAILABLE)**。

## 2. 部分制約(構造診断には使えるが限界あり)

| 列 | 状態 | 制約 |
|---|---|---|
| margin_level_at_hedge | 48/48 だが全て 0.00 | placeholder。実margin不明 → EVIDENCE_UNAVAILABLE 扱い |
| distance_to_hs_price | 0/48 全MISSING | hedge timing(hedge_too_late)NOT_COMPUTABLE |
| worst_floating_pl | 0/526 全MISSING | 最悪含み損の直接比較不可。basket_pl_at_hedge で部分代替 |
| hardstop_price | 0/48 全MISSING | hedge–HS 価格距離の算出不可 |

## 3. 使用可能(実変動あり)— 構造 proxy のみ

final_pl / hs_loss / open_time・close_time(duration)/ close_reason /
hedge_fired・hedged_flag / basket_pl_at_hedge / post_hedge_max_recovery_pl /
SIG-RD fire有無・fire_time(lead)/ sample_type(scope)。

これらで見えるのは **滞留時間・hedge関与・損失規模・SIG-RD選別** の
**構造的偏り** まで。**個別 entry が損失を増幅した、とは断定しない。**

## 4. 主張してよいこと / いけないこと

- ✅ 主張可: 「HardStop は長期滞留・hedged・SIG-RD発火の basket に構造的に偏る」
- ✅ 主張可: 「HardStop には長期giveback型と高速blowup型の2原型がある」
- ❌ 主張不可: 「エントリ積み増し / lot増加が損失を N円増幅した」
- ❌ 主張不可: position単位の寄与分解、grid本数と損失の相関、any lot-scaling効果
- ❌ 主張不可: 「15万円なら勝てる」/ OOS効果 / 実装後利益

## 5. 解消条件(将来の収集で)

以下を W3 / v1.4 Shadow Logging に **ログ項目として追加**(実装ではなく記録)すれば
position-level exposure amplification が判定可能になる:
- entries.position_pl_final(entry単位確定損益)
- baskets.max_positions / total_entries / max_lot_sum(basket集約 exposure)
- hardstops.positions_at_hs / lot_sum_at_hs(HS時点 exposure)
- margin_level_at_hedge の実値(0.00 placeholder の是正)
- distance_to_hs_price(hedge timing 判定用)

これらは rapid_drop 0.05 や EA ロジックを変えない **記録の追加** に限る。
