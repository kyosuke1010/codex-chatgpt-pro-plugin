# prehedge_damage_shadow_phase2_summary.md — 設計監査サマリ

date: 2026-07-02
scope: Pre-Hedge Damage Control Shadow Phase 2 Prospective Collection Design Audit
mode: DESIGN_ONLY(EA変更ゼロ・実装ゼロ)

## 1. なぜPre-Hedgeか(確定済み根拠)

- Hedged HardStop 26件全件が LOSS_DOMINANT_BEFORE_HEDGE(-130,403円)
- Non-Hedged HardStop 11件(-54,275円)はHedge前に終了
- 合計37件 = gross lossの91.35%の主戦場がPre-Hedge帯

## 2. 本監査で新たに確定した事実

### 2.1 Pre-Hedge帯ではMA候補は全滅(one-step再計算)
prehedge_harm_recalculation_plan.csv(in-sample・local diagnostic):

| 候補 | 帯内signal | rescue | BC Kill | 合計 | harm/gross |
|---|---|---|---|---|---|
| M15素 | 40/68 | 12件/+46,339円 | 26件/-56,597円 | **-10,258円** | 1.221 |
| M15+M5proxy | 14/48 | 3件/+12,064円 | 10件/-19,000円 | -6,936円 | 1.575 |
| M15+M30 | 4/34 | 0件 | 3件/-7,874円 | -7,874円 | benefit無し |
| combo | 2/31 | 0件 | 1件/-1,527円 | -1,527円 | benefit無し |
| M5単独 | 133/147 | 22件/+76,878円 | 102件/-122,326円 | -41,538円 | 1.514 |
| M30 entry | 36/36 | 2件/+6,172円 | 34件/-14,802円 | -8,630円 | 2.398 |

**含意**: BC Kill(全26件がM15のPre-Hedge帯に集中)の正体は「Hedgeにすら
至らず回復してBasketCloseで勝つ浅い逆行」であり、Pre-Hedge帯の
MAクロスは深い逆行と浅い逆行を区別できない。combo/M30文脈の好成績は
post-hedge帯(0.88〜0.94)の産物で、Pre-Hedge本丸には輸送不能。
→ **Pre-Hedge対策は単変量MA Exitでは構造的に成立しない。多変量の
損傷状態観測(slope/distance/spread/MA文脈の複合)が必須。**

### 2.2 Runtime slopeフィールドは未実装(重大ギャップ)
`loss_slope_short` / `loss_slope_mid` / `adverse_movement_speed` は
Phase 1全行NA。ただし `floating_loss_yen` + `server_time_msc` から
**オフライン導出で完全代替可能**(EA変更不要)。

### 2.3 急落型4件はslope系で観測可能(実測)
snapshot密度2.1〜3.3本/分、derived 1分slope最大1,258〜3,111円/分。
正規化3分slope: HardStop系 p50 0.145 vs その他 p50 0.021(約7倍分離)。
ただし4件全捕捉の閾値では誤検知約10% → **観測専用が妥当**。

### 2.4 market_stateの値域欠陥
`OPEN_OR_UNKNOWN` はOPENとUNKNOWNを区別不能。G7ゲートはUNKNOWN扱いに
固定(validと解釈しない)。candidate_possibleが常にUNKNOWN側へ倒れるのは
安全側の既知制約として受容。

### 2.5 後発eligible化はゲートで防げない
HTE Kill -20円型(後からeligible化)はG8では構造的に防げず、
BC Kill 26件も同型。persistence/recross診断(H1〜H4)で層別し、
残余リスクとして監査する設計に変更。

## 3. 設計成果物一覧

| 成果物 | 状態 |
|---|---|
| prehedge_signal_contract.md | FROZEN v1.0.0 |
| prehedge_runtime_schema.csv | 全必須フィールドの取得経路確定(EXISTS/DERIVED/JOIN) |
| prehedge_harm_recalculation_plan.csv | **実データで再計算済み**(planではなく結果を収録) |
| loss_slope_observation_contract.md | FROZEN v1.0.0(記録トリガ0.05/min固定) |
| rapid_drop_no_warning_cases.csv | 4件全件の系列特性を実測収録 |
| m15_persistence_recross_diagnostic_spec.md | 診断項目+仮説H1〜H4確定 |
| existing_close_protection_gate.csv | G3〜G10+GX1(UNKNOWN非強制) |
| phase2_shadow_collection_plan.md | 収集構成・主要クエリQ1〜Q6・十分性基準 |
| implementation_not_allowed_statement.md | 固定フラグ6種を追記・継続有効 |

## 4. 判定

prehedge_damage_shadow_phase2_final_decision.md を参照。
