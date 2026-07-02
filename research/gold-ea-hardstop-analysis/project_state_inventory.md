# project_state_inventory.md

作成日: 2026-07-02
ブランチ: claude/gold-ea-hardstop-analysis-9aee82
リポジトリ HEAD SHA: 0cc5c5509ebaccfc7dad45b9e02a0f86407c817c

## 1. 棚卸し結果(最重要事実)

本workspace(`codex-chatgpt-pro-plugin` リポジトリ)を全走査した結果、
**GOLD EA関連の入力成果物は一切存在しない。**

検索方法:
- `find` による拡張子走査(*.mq5 / *.ex5 / *.mqh / *.csv)
- ファイル名キーワード走査(basket / hardstop / shadow / gold / xau、大文字小文字無視)
- `git ls-files` による全トラックファイル確認
- main / origin/claude/gold-ea-hardstop-analysis-9aee82 のdiff確認(差分ゼロ)

結果: 該当ファイル 0件。本リポジトリの内容はCodex ChatGPT Proプラグイン
(Node.js / ブラウザ自動化)のソースのみであり、MT5/MQL5成果物は含まれない。

## 2. SHA記録

| 対象 | SHA | 状態 |
|---|---|---|
| リポジトリ HEAD | 0cc5c5509ebaccfc7dad45b9e02a0f86407c817c | 記録済み |
| EA source (.mq5) SHA | NOT_AVAILABLE_IN_WORKSPACE | ファイル不在 |
| EX5 SHA | NOT_AVAILABLE_IN_WORKSPACE | ファイル不在 |

EA source SHA / EX5 SHA は、当該ファイルがworkspaceに存在しないため記録不能。
UNKNOWNはUNKNOWNのまま扱う(false/0扱いしない)。

## 3. 前提データの出典区分

本研究セッションで使用する数値は、すべてタスク指示に含まれる
**SESSION_REPORTED_AGGREGATE**(過去セッションで検証済みと報告された集計値)である。
本workspaceでの独立再計算は入力成果物不在のため不可能。

主要な前提(出典: タスク指示 セクション0):

- total Basket 442 / closed 439 / unresolved 3
- Basket win rate 89.07% / average win +352.27円 / average loss -4,211.94円
- payoff ratio 0.0836 / expectancy -146.78円/Basket / net -64,436円
- gross loss -202,173円
- HardStop 37 Basket / -184,678円(gross lossの91.35%)
- Hedged HardStop 26 / -130,403円、Non-Hedged HardStop 11 / 約-54,275円
- Phase 1 Multilayer Shadow: 非介入 6/6 PASS ×3系統、Shadow由来order/deal/close 0/0/0、
  root snapshots 169,305、schema violation 0
- MA Cross Overlay: M15逆クロスHardStop coverage 29/37、
  rescue local diagnostic +63,961円、HTE Kill 1件/-20円、Winner truncation 0件、
  best candidate M30_REGIME_PLUS_M15_CROSS_PLUS_M5_PULLBACK one-step +29,585円、
  harm/gross benefit 0.049081

## 4. 本セッションの成果物区分

| 区分 | 内容 | 状態 |
|---|---|---|
| 設計・契約文書(Phase C/D/E/F/H/I) | Signal契約、状態機械、Overlay仕様、保護契約、安全規則、優先順位、設計Freeze | 完全作成 |
| 集計ベース文書 | current_ea_risk_summary、hardstop_priority_matrix(セグメント粒度)、implementation_priority_matrix | SESSION_REPORTED_AGGREGATE明記の上で作成 |
| Basket単位再計算CSV(Phase B/F/G) | hardstop_root_cause_rebuild、future_candidate_decision_table、ma_one_step_effect_rebuild ほか | **スキーマ契約のみ(データ行ゼロ)**。入力成果物到着後に充填 |

Basket単位の行データを本workspaceで生成することは捏造にあたるため行わない。
これはタスクの禁止事項(in-sample結果の偽装、UNKNOWNのfalse扱い)の遵守である。

## 4.5. 更新(2026-07-02 追記): 成果物の所在確認

ユーザーより、全入力成果物がWindowsローカル
(`C:\Users\user\Documents\New project` および MetaQuotes Experts フォルダ)に
存在することが確認された。ステータスを MISSING_IN_WORKSPACE から
**CONFIRMED_ON_USER_MACHINE_AWAITING_PUSH** へ更新。

ただし本セッションはリモートコンテナで動作しており、Windowsローカルへの
直接アクセス手段は存在しない(ファイルシステム全域検索で確認済み)。
取り込みには `input_artifacts/README.md` の手順でZIP群を本ブランチへ
pushする必要がある。到着後は `ingest_verify.py` で検証・再発見を行い、
Phase B/F/G CSVの充填へ進む。

## 5. 再計算のブロック解除条件

以下の成果物が本リポジトリ(または参照可能なパス)に配置された時点で、
Phase B/F/GのCSVをスキーマどおりに充填する:

1. EA source(.mq5)と対応EX5(SHA照合可能な形で)
2. Phase 1 Runtime Snapshot CSV(期待 169,305行)
3. Basket Summary CSV(期待 442行)
4. MA Cross Audit CSV
5. Event Blackout Audit
6. Basket Payoff Structure Audit
7. Phase 1 Shadow Fix Audit(非介入検証記録)

詳細は input_artifact_manifest.csv を参照。
