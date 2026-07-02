# prehedge_damage_shadow_phase2_final_decision.md — 最終判定

date: 2026-07-02
audit: Pre-Hedge Damage Control Shadow Phase 2 Prospective Collection Design Audit

## 判定

**decision_class: PREHEDGE_DAMAGE_CONTROL_SHADOW_READY**

確定サブ判定(いずれもデータ根拠つき):
- **M15_REVERSE_WARNING_ONLY** — Pre-Hedge帯限定再計算で全MA候補が
  one-step合計マイナス(M15素 -10,258円 / harm/gross 1.221)。
  M15はExitではなく警告Signalとしてのみ扱う地位が再確定。
- **LOSS_SLOPE_RAPID_DROP_SHADOW_REQUIRED** — 警告なし急落型4件は
  slope系導出でのみ観測可能(実測: 密度2.1〜3.3本/分、正規化slope
  0.112〜0.405)。ただし単一閾値は誤検知約10%のため観測専用。
- **HEDGE_TRANSITION_NOT_PRIMARY** — Hedged 26件全件が
  LOSS_DOMINANT_BEFORE_HEDGE。Hedge遷移・giveback系は主軸ではない。
- **EVENT_RISK_NOT_PRIMARY** — HardStop±60分のevent重なり2/37、
  急落型4件も全件Event外。

## READYの根拠(収集を今すぐ開始できる理由)

1. **EA変更ゼロで全フィールドが揃う**: 必須観測項目はすべて
   (a) Phase 1 Snapshot既存列、(b) 系列からのオフライン導出、
   (c) Offline MA Overlay結合、のいずれかで取得可能と確認済み
   (prehedge_runtime_schema.csv)。runtime slope列の未実装は
   オフライン導出で完全代替できることを4件の実データで実証した。
2. **非介入性は既に実証済み**: Phase 1の6/6 PASS ×3系統・
   Shadow由来order/deal/close 0/0/0 をそのまま継承(EA無変更のため
   再検証不要)。
3. **分析パイプラインが動いている**: ingest→検証→充填→帯別再計算まで
   本セッションで実走済み。prospectiveデータにも同一コードが使える。

## 制約・残余リスク(READYに含まれる但し書き)

- market_state `OPEN_OR_UNKNOWN` によりG7は常にUNKNOWN側
  → candidate_possibleはUNKNOWN保持のまま(安全側で受容)。
- 後発eligible化(HTE Kill -20円型 / BC Kill 26件型)はゲートで防げない
  → persistence/recross診断(H1〜H4)の観測対象。
- 急落型は稀少(6runで4件)。prospectiveで2件未満なら判定保留
  (phase2_shadow_collection_plan.md セクション4)。
- 本監査の全数値はin-sample one-step local diagnostic。
  OOS効果・full EA counterfactual・実装後利益をいずれも主張しない。

## 固定フラグ(変更禁止)

- P1_implementation_allowed = **false**
- real_exit_implementation_allowed = **false**
- prehedge_exit_implementation_allowed = **false**
- ma_cross_logic_implementation_allowed = **false**
- hedge_gate_implementation_allowed = **false**
- event_stop_implementation_allowed = **false**

## 次のアクション

1. Phase 1 Shadow構成のままprospective期間の収集を開始(EA無変更)
2. 到着データに ingest_verify.py → overlay pipeline → prehedge系導出を適用
3. Q1〜Q6(phase2_shadow_collection_plan.md)への回答を成果物化
4. 十分性基準達成後、in-sample vs prospective整合レポート
   → 整合時のみExit系候補の**実装設計審査**(実装ではない)を開始

## 免責

本判定は利益を保証しない。全効果値はex-commission(commission NA)。
