# w3_acceptance_report.md — extraction_bundle_w3 検収報告

date: 2026-07-12
bundle: extraction_bundle_w3.zip(SHA256 `DBD4811F..A174896` 一致、10,537,186 bytes)

## 検収結果: **ACCEPTED_WITH_TAGS**(解析利用可。条件タグ付き)

| ゲート | 結果 | 備考 |
|---|---|---|
| SHA256照合 | ✅ PASS | manifest一致 |
| スキーマ照合 | ✅ PASS | schema_version=W3.1。凍結スキーマの全情報+上位互換の追加列(leg別floating、250s snapshot等)。命名差はマッピング表で吸収 |
| G2(W3 OFF vs ON) | ✅ PASS 8/8 | trade exports byte一致 → **W3ログの非介入性は全runで成立** |
| W3 OFF でのW3 CSV生成 | ✅ 0件 | スイッチ既定false動作確認 |
| logger error / dropped rows | ✅ 0 / 0 | 8run合計 |
| 静的ゲート(code側で実施) | ✅ PASS | 同梱ソースに禁止シンボル0ヒット。SHA一致(`C1DBE51A`/`36FC7066`)。W3_LOGGING_ENABLED default=false 確認 |
| July混入 | ✅ 0 | 全イベント最大時刻 2026.06.29 23:11:40 |
| **v1同一性(basket outcome)** | ⚠️ **部分** | 下記 |
| G1(Shadow OFF vs W3 OFF) | △ 代替成立 | June 2runの W3_OFF trade export SHAが**v1.4原本SHAと完全一致**(`4F2B8792`/`3D20DA6E`)→ 歴史ベースラインとのbyte連続性はJuneで証明。ML 4runは原本と不一致 |
| G8(故障注入) | ❌ 未実施 | 残課題(下記) |

## v1同一性の詳細(事前固定した扱いを適用)

| run | outcome一致 | HS(v1→W3) | タグ |
|---|---|---|---|
| JUNE 100k / 50k | **35/35・47/47(100%)** | 2→2 / 4→4 | **V1_IDENTICAL** |
| ML 100k APR_MAY / MAY | 55/59・14/15 | 4→4 / 1→1 | V1_MOSTLY_IDENTICAL |
| ML 100k MAR_MAY | 106/119 | 8→7 | V1_MOSTLY_IDENTICAL |
| ML 50k APR_MAY / MAY | 64/72・50/55 | 9→8 / 2→2 | V1_MOSTLY_IDENTICAL |
| **ML 50k MAR_MAY** | **19/119** | 13→11 | **NEW_BASELINE** |
| 合計 | 390/521(74.9%) | 43→39 | — |

- 解釈: 現行EA(E57BE003系+W3)は June を完全再現。Mar–May は3月序盤の分岐が
  path依存で複利し、特に 50k MAR_MAY で大きく乖離(git_introduction_review §3 の
  系譜断絶疑いが**Mar–Mayについて実証**された形)。
- 事前固定どおり: 乖離runは **NEW_BASELINE タグ**で解析(v1監査との直結を主張しない)。
  全 W3解析出力に baseline_tag 列を付与済み。
- HardStop構造の再現確認: W3ベースラインでも 2原型(hedged長期 / non-hedged高速)と
  勝ち天井構造は再現(w3_reaudit_summary.md)→ M1/M2/M3 への紐付けは有効。

## 残課題(ブロッカーではない)

1. **G8 故障注入未実施**: W3ログの failure isolation は静的構造+logger_state列で
   担保されているが、動的試験は未了。次回run前に実施推奨(読み取り専用ディレクトリ
   指定での1run)。
2. `1353718F → C1DBE51A` の差分証明が未納品(git_introduction_review §3 依頼分)。
   Mar–May乖離の原因特定(どの変更が3月分岐を生んだか)に必要。
3. price_m5_w3.csv 未同梱 → 既存 v1.1 price_m5.csv(3/2〜6/30)が全収集期間を
   カバーするため offline結合は実施できた(実害なし)。
