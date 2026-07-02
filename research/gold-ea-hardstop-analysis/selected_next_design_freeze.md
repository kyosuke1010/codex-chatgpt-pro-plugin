# selected_next_design_freeze.md — 最小実装候補の設計Freeze

## 選定結果

**選択: 候補A — M15 Reverse Cross Shadow Phase 2(Offline Overlay継続 / 実Exitなし)**

status: DESIGN_FROZEN(実装はまだ許可されない。implementation_not_allowed_statement.md参照)

## 選定理由

1. **EA変更ゼロ**: RuntimeにMAを入れない(OFFLINE_OVERLAY_ONLY、ADR確定済み)。
   Phase 1で実証済みの非介入性(6/6 PASS ×3系統、Shadow由来order/deal/close 0/0/0)
   をそのまま維持でき、回帰コストが最小。
2. **左裾への直接性**: M15逆クロスはHardStop 37件中29件を事前カバー(報告値)。
   最大の損失源に対する観測レバーとして最有力。
3. **候補B/Cを包含**: 観測スキーマ(ma_shadow_observation_schema.csv)は
   hedge_phase(PRE_HEDGE/POST_HEDGE)、pl_at_signal、distance_to_hardstop、
   eligibility群を含むため、Pre-Hedge Damage Control(候補B)と
   Hedge Transition(候補C)の主要観測は**同一データから層別可能**。
   別実装を立てる必要がなく、変更面積が最小になる。
4. **prospective収集がOOSの前提**: 既存6runはin-sample。第四段階
   (OOS/native tick検証)に進むには将来データの蓄積が必須であり、
   それを開始できるのは本候補だけ。

## スコープ(IN)

- 既存Phase 1 Shadow Loggingの継続稼働(変更なし)
- Offline Overlay pipeline実装(offline_overlay_pipeline_spec.md v1.0.0)
- ma_signal_contract.md v1.0.0 準拠のSignal分類9種の付与
- prospectiveデータへの同一pipeline適用と、in-sample/prospectiveの厳密分離
- Phase B/F/G CSVの充填(入力成果物再配置後)

## スコープ外(OUT — 禁止)

- 実Exit / Entry / Event Stop / Hedge Gate / TA9実決済
- EA source / EX5 の変更(Runtime MA含む)
- 既存Close経路・優先順位の変更
- 実口座 / live / demo forward

## 受け入れ基準(このFreezeの完了条件)

1. pipeline決定性: 同一入力→バイト同一出力(SHA一致)
2. availability違反0件(available_time < bar_close_time)
3. Basket結合 442/442(in-sample)、prospective期間は100%結合
4. SIGNAL_CENSORED件数の明示報告
5. ゲート監査: HTE/Recovery/BasketClose eligible局面での候補分類0件
6. Shadow OFF/ON非介入一致の維持(EA無変更なので構造的に満たされるが、
   run単位でorder/deal/close 0/0/0を機械検証する)

## 凍結項目(変更にはバージョン更新が必要)

- MA定義(EMA10/SMA20, close, closed bar, warmup 50)
- Cross定義・adverse mapping・First Signal規則
- M5の呼称: M5_REVERSE_FOLLOWTHROUGH_PROXY
- effect_class定義(next_logic_research_plan.md)
- 安全ゲートG1〜G14
