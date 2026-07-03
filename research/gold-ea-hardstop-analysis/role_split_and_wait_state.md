# role_split_and_wait_state.md — 役割分担と待機状態の固定

date: 2026-07-03
purpose: Claude側 / Codex側 の役割分担と、W2 July待機状態を固定記録する。
本文書は方針記録であり、いかなる評価・実装・先読みも行わない。

## 1. Claude側(このリモートコンテナ)に依頼する範囲

- 事前登録ファイルの維持(prospective_july_preregistration.md ほか)
- registry / pipeline / operator instructions の整備
- bundle受領後の静的検証・集計補助
- リモートコンテナ内で可能なファイル検証(SHA・スキーマ・窓・非介入)
- git上の成果物整理
- 実装しない範囲でのレポート化

### Claude側に依頼しない(不可 or 対象外)

- Windows MT5 Strategy Tester 実行 / Terminal操作 / bundle生成
- EA / mq5 / mqh / EX5 変更
- 未完結Julyデータの分析 / bundle未到着状態での効果検証
- MA Exit / Pre-Hedge Exit / Hedge Gate / Event Stop 実装
- 実Exit設計審査の開始判断

理由: 本セッションはリモートLinuxコンテナで、MT5を実行できない。

## 2. Codex側(Windowsローカル)に依頼する範囲

- MT5 / Terminal / local file / bundle配置の確認
- July完結後の Windows MT5 4run 実行支援
- Shadow OFF / ON 非介入検証
- bundle生成・配置確認(input_artifacts/prospective_july/)
- W1 June + W2 July の累積分析
- HardStop / Non-Hedged / slope / rapid_drop / Event / MA bars の検証
- 十分性判定
- 必要ならW3以降の追加収集判断補助

### Codex側でも禁止

- EA / mq5 / mqh / EX5 変更
- Exit / Entry / Hedge / HardStop / Close Priority 変更
- rapid_drop 0.05 変更 / slope定義・十分性閾値・分類 変更
- 未完結Julyの効果分析 / OOS効果・本番期待利益の主張
- 実装審査への早期移行

## 3. W2 July 現在状態(固定)

- status: PRE_REGISTERED_AWAITING / AWAITING_BUNDLE
- window: half-open [2026-07-01 00:00:00, 2026-08-01 00:00:00)
- Julyは未完結 / bundle未到着
- 評価・取り込み・実装審査は未実施

## 4. bundle到着後の連絡と処理

合図: 「July bundle push完了、取り込み実行」
受領後の検証項目(Claude側で可能な範囲、既存 postsample_cumulative_pipeline.py):
bundle SHA / manifest → source identity(source_before_sha256==1353718F) →
window → OFF vs ON 非介入 → Basket/Run Summary抽出 → Hedged/Non-Hedged分類 →
HardStop累積 → pre-hedge slope分離 → rapid_drop 0.05固定判定 →
Event window → M5/M15/M30 bars同梱確認 → Q2/Q4 MA warning評価 → W1+W2累積判定。

## 5. 十分性(不変)

累積で満たすまで MORE_DATA_REQUIRED を継続:
- HardStop累積 >= 15
- Non-Hedged HardStop累積 >= 2
- slope欠損率 <= 0.30
- OFF vs ON 非介入 PASS

満たさない場合: PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED 継続 / 必要ならW3 August追加。
満たした場合: 即実装せず、in-sample vs post-sample 整合レポート作成 →
実Exit設計審査の開始可否を別工程で判断。

## 6. 固定フラグ(継続)

- P1_implementation_allowed=false
- real_exit_implementation_allowed=false
- prehedge_exit_implementation_allowed=false
- hedge_gate_implementation_allowed=false
- event_stop_implementation_allowed=false
- ma_cross_logic_implementation_allowed=false
- full_EA_counterfactual_claim_allowed=false
- oos_effect_claim_allowed=false

## 7. 現在の累積判定(参考・W1のみ)

decision: PREHEDGE_SLOPE_SIGNAL_MORE_DATA_REQUIRED
cumulative HardStop=6 (hedged 6 / nonhedged 0) — need >=15 and nonhedged >=2。
data未存在の場合は待機、bundle存在時のみ検証・分析を行う。
