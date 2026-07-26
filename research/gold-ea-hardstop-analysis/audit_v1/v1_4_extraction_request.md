# v1_4_extraction_request.md — Codex向けデータ抽出依頼(v1.4)

registered: 2026-07-11
担当: Codex(PowerShell / MT5 操作)。Claude側は受け皿・SHA照合・解析を担当。
目的: Audit 2軸A(position/lot exposure)と Audit 3 timing / Audit 5 winner extension の
EVIDENCE_UNAVAILABLE を解消する。**EAロジックは一切変更しない。**

## 大原則(全優先度共通)

- EA / mq5 / mqh / ex5 の**売買ロジックは変更禁止**。P2はログ追記のみ。
- rapid_drop 0.05 は FROZEN(再調整・再テストしない)。
- July実走(W2)には触らない。JuneまでのデータとW2完結後(2026-08-01以降)のJulyのみ。
- 未取得値は MISSING と明記(0埋め・補完禁止)。commission は NA のまま。
- 実装系フラグは全 false のまま。これは**記録の追加**であって実装ではない。

## Priority 1: EA無変更で今すぐ取れる(MT5 Tester標準出力の再抽出)

**根拠**: 欠損している position単位データは、MT5 Strategy Tester の**約定履歴
(Deals/Orders history)に標準で記録されている**。SHADOWログが SELL_NET#1 root しか
記録していなかっただけで、Testerの履歴には全ポジションが残る。EAに触る必要なし。

### 1-A. 対象runの約定履歴エクスポート

対象: 既存8run(in6run 6本 + June 2本)。
- 既存のTesterレポート/履歴キャッシュが残っていればそこからエクスポート。
- 残っていなければ**同一設定・同一ビルド・同一期間で再実行**(Testerは決定的なので
  再現するはず)。ただし下の 1-C 同一性検証を必ず通すこと。

エクスポート内容(deal単位):
| 列 | 用途 |
|---|---|
| deal_time / order_ticket / position_id | basket結合キー |
| type (buy/sell/in/out) / lot / price | exposure再構成 |
| profit / swap / commission(NAならNA) | **position_pl_final** |
| comment / magic | basket_uid / hedge判別 |

### 1-B. 導出列(Codex側で集約 or 生deal提供のどちらでも可)

deal履歴から機械的に導出可能(EA無変更):
- entries.position_pl_final(全526 basket)
- baskets.max_positions / total_entries / max_lot_sum(時系列でポジション数・lot合計を再構成し最大値)
- hardstops.positions_at_hs / lot_sum_at_hs(hs_time時点の断面)
- hedges時点の断面 positions / lot_sum(参考)

**生deal CSVをそのまま提供でも構わない**(deals_v1_4.csv)。導出はClaude側で実施可能。
その場合は run_id と basket結合キー(comment/magic/position_id の対応規則)を
extraction_report に明記すること。

### 1-C. 同一性検証(必須ゲート)

再実行した場合、既存 baskets.csv(526行)と突合し:
- basket数 / open_time / close_time / close_reason / final_pl が**完全一致**すること。
- 1件でも不一致なら DIFFERENT_RUN として不一致リストを添付(そのbundleは正本にしない)。
- 一致確認前のdealデータは解析に使わない。

## Priority 2: ログ追記が必要(v1.4 Shadow Logging、W3向け)

Testerの標準履歴では取れない**イベント時点のEA内部状態**。ログ出力の追記のみ
(判定・売買コードに手を入れない):

| 追加ログ項目 | 解消される欠損 |
|---|---|
| margin_level_at_hedge / at_hs の**実値**(現状0.00 placeholder) | Audit 4 row-level margin |
| hardstop_price / distance_to_hs_price @hedge | Audit 3 hedge_too_late 判定 |
| worst_floating_pl(basket生涯最悪含み損) | Audit 3 層化変数 |
| post_close_move_1h/4h/24h(BasketClose後の価格) | Audit 5 winner extension 判定 |
| snapshot に grid集約 positions / lot_sum(root単体でなく) | 増幅のイベント時系列 |

**必須手順**: 追記後、非介入確認(Shadow OFF vs ON のtrade events byte一致)を
再実施してから収集run開始。非介入確認前のデータは使わない。

## 納品形式

- `input_artifacts/extraction_bundle_v1/extraction_bundle_v1_4.zip`
  - deals_v1_4.csv(P1生deal)or 集約済みCSV群
  - extraction_report_v1_4.txt(結合規則・同一性検証結果・除外事項)
- SHA256 manifest 同梱、push後「v1_4 push完了」と合図。
- Claude側で SHA照合 → 同一性ゲート → Audit 2軸A / Audit 3 timing / Audit 5 を再実行。

## 優先順位の指定

**P1のみで Audit 2軸A(position/lot増幅)は完全解消する。** P2はW3収集設計であり
急がない。まず P1(deal履歴)だけの v1.4 で構わない。
