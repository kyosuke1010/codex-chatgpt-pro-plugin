# audit_v1_spec_registration.md — Analysis & Judgment Spec v1.0 登録と状態

registered: 2026-07-03
spec_source: uploads/9883bc5a-Analysis_Judgment_Spec_v1_Claude.md
上位: Capital Buffer × Pre-Hedge Loss-Tail Structural Design Audit v1.0
役割: Claude=分析・判定担当。Codex納品の extraction_bundle_v1 を入力に Audit 1〜5 を実行。

## 現状

**decision_class: AWAITING_EXTRACTION_BUNDLE_V1**

- 入力 extraction_bundle_v1 は**未着**（uploadsにはSpec本体のみ）。
- §0.5(入力検証)は extraction_report.txt の MISSING 確認・July混入検査・
  close_reason分布のベースライン照合を**分析開始前の必須ゲート**と規定。
  bundleが無いためこれらを実行できず、Audit 1〜5 は開始しない（捏造しない）。

## 固定条項の継承(Spec §0)

- 全結果は in-sample diagnostic only。採用判断・OOS効果主張・実装後利益主張に使わない。
- July W2条件に一切影響を与えない（本トラックは独立）。
- 実装系フラグは全て false。
- 「15万円なら勝てる」と記述しない。資金増加は期待値 −147円/Basket を変えない旨を出力に明記。

## 用意済み(bundle到着時に即実行)

| 成果物 | 役割 |
|---|---|
| audit_v1_expected_bundle_manifest.csv | Codex納品物の必須ファイル・必須列の契約 |
| audit_v1_input_schema_contract.csv | 各CSVの列・型・キー |
| audit_v1_analysis.py | §0.5ゲート + Audit 4→1→2→3→5(実行順) を実装。bundle未着ならAWAITING出力 |
| audit_v1_deliverable_skeletons/*.csv | 各Auditの出力スキーマ(0行) |

## bundle到着後の流れ

1. Codexが extraction_bundle_v1 を input_artifacts/extraction_bundle_v1/ にpush
   （baskets/signals/entries/hedges/hardstops/basketclose_winners/equity_curve
   + extraction_report.txt を同梱）。
2. 合図「extraction_bundle_v1 push完了、Audit v1実行」。
3. audit_v1_analysis.py が §0.5検証 → Audit 4→1→2→3→5 → 判定合成を実行。
4. §0.5でclose_reason分布がベースライン(win rate ~89% / HardStop比率)から
   大きく乖離、またはJuly混入検出時は、**分析を進めずCodexへ差し戻し**。

## SIG-LSB の扱い(§0.5.4)

signals.csv の SIG-LSB 定義ソースが extraction_report で不明な場合、
SIG-LSB は Audit 1 から除外し **3シグナル(SIG-SLP / SIG-RD / 残り1)** で実行する。
定義が明示されていれば4シグナルで実行。エンジンは定義有無を自動判定する。
