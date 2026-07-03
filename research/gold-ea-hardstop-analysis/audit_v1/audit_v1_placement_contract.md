# audit_v1_placement_contract.md — extraction_bundle_v1 配置契約

registered: 2026-07-03
状態: 受け皿完成・中身待ち(code側は正しくAWAITINGで待機中)

## 1. 状態整理(矛盾ではない)

- code側 `AWAITING_EXTRACTION_BUNDLE_V1` は正常。理由: ZIPはまだ code側リポジトリの
  `input_artifacts/extraction_bundle_v1/` に **配置(push)されていない**。
- CodexはZIPを生成済み・SHA検証済み。存在場所はローカル
  (C:\Users\user\Documents\New project\)。これを配置先へ移す作業が残っている。
- code側(リモートコンテナ)はローカルのファイル移動・git pushができないため、
  配置は Codex(またはユーザーのローカル操作)が担当する。

## 2. 配置先とファイル名(この名前で置くこと)

すべて `input_artifacts/extraction_bundle_v1/` 直下に置く(サブフォルダ不要):

| ZIP ファイル名(この名前で) | SHA256 | 役割 |
|---|---|---|
| extraction_bundle_v1_2.zip | 5FE9B038A16E95550F0968A012A003F7C25A629F008733FDCB846CD8F996DF46 | **authoritative(最新v1.2)** |
| extraction_bundle_v1_1.zip | DA8B945E3DA0E7AAE18FB6A7B1BC8BBA7A0E470DFC73931D7962FBCB8DE506D6 | provenance(旧v1.1) |
| extraction_bundle_v1.zip | F9F12E6999462EF283E9E2FA511CC511E46FE12F87789ACAE0822CF5E8DDFB29 | provenance(旧v1) |

- code側は v1.2 を**正本(authoritative)**として component CSV を読む。v1/v1.1 は
  来歴記録のみ(analysisには使わない)。3つ全部でなく **v1.2 のみでも解析は可能**。
- 各ZIPの中身は audit_v1_expected_bundle_manifest.csv の必須ファイル
  (baskets.csv / signals.csv / entries.csv / hedges.csv / hardstops.csv /
  basketclose_winners.csv / equity_curve.csv / extraction_report.txt /
  exclusions.csv)を含むこと。ZIP名だけ上記に合わせ、中身のCSV名は契約どおり。

## 3. SHA自動照合(code側)

audit_v1_analysis.py は Stage 0 で:
1. 置かれたZIPのSHA256を計算し、上記ピン値と照合(audit_v1_zip_sha_report.csv 出力)。
2. 一致した最上位(v1.2 > v1.1 > v1)を authoritative として展開。
3. 不一致は FAIL_SHA_MISMATCH として記録し、その版を正本にしない。
4. その後 §0.5(除外13・SIG-MA/RD重複照合・close_reason基準・July混入)→ Audit 1。

SHAピンはコードに焼き込み済み(EXPECTED_ZIP_SHA)。転送破損・版取り違えを機械検出する。

## 4. 禁止

- EA / mq5 / mqh / EX5 は変更しない。配置とpushのみ。
- ZIP名を変えない(code側の照合キーになる)。

## 5. 配置後の合図

「extraction_bundle_v1 push完了、Audit v1実行」と伝える。
code側が SHA照合 → 展開 → §0.5 → Audit 1(SIG-MA/SIG-RD/両方 + SIG-SLP記述) を実行する。
