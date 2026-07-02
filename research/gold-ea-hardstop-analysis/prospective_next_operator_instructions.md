# prospective_next_operator_instructions.md — MT5オペレータ手順

対象: Windows + MT5 のユーザー。目的は June-2026 locked post-sample window の
Shadow収集を **EA無変更** で実行し、ZIP を本ブランチへ push すること。

## 0. 大前提

- EA source / EX5 は **変更しない**(SHA一致が受け入れ条件)。
- 期間・symbol・timeframe・model・deposit は下記固定値から**変えない**。
- 収集後に結果を見て条件を調整しない。

## 1. 実行する4run(2 arm × 2 capital)

| run_label | Shadow | Deposit | From | To |
|---|---|---|---|---|
| ML_B_SHADOW_OFF_50000_JUN_M5_20260601_20260630 | OFF | 50000 | 2026.06.01 | 2026.06.30 |
| ML_B_SHADOW_OFF_100000_JUN_M5_20260601_20260630 | OFF | 100000 | 2026.06.01 | 2026.06.30 |
| ML_C_SHADOW_ON_50000_JUN_M5_20260601_20260630 | ON | 50000 | 2026.06.01 | 2026.06.30 |
| ML_C_SHADOW_ON_100000_JUN_M5_20260601_20260630 | ON | 100000 | 2026.06.01 | 2026.06.30 |

共通(in-sample Phase 1と同一): Expert=KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.ex5,
Symbol=GOLD, Period=M5, Model=0(every tick), Currency=JPY, Leverage=1:888,
Optimization=0, ForwardMode=0。

既存の `ML_C_SHADOW_ON_100000_MAY_M5_...ini` を複製し、FromDate/ToDate/Deposit/
Report名だけを上記に変更するのが安全(他項目は触らない)。

## 2. 各runで保存する成果物(prospective_expected_artifact_manifest.csv)

- Root Snapshot CSV(Shadow ON、shadow_logs)
- Basket Summary CSV(MULTILAYER_BASKET_SUMMARY または basket_master_table)
- Run Summary CSV
- Trade Events CSV(**OFF と ON の両方**。非介入突合に必須)
- Tester report .htm / agent・expert ログ / 使用した .ini
- EA source(.mq5)と EX5(.ex5)を1部ずつ(SHA同一性確認用)

## 3. push手順(PowerShell)

```powershell
$Repo = "C:\path\to\claude-code-repo"
Set-Location $Repo
git fetch origin
git checkout claude/gold-ea-hardstop-analysis-9aee82
git pull origin claude/gold-ea-hardstop-analysis-9aee82

New-Item -ItemType Directory -Force -Path ".\input_artifacts\prospective" | Out-Null

# 4run分のZIP(名前は run_label に合わせる)
Copy-Item "C:\Users\user\Documents\New project\<JUNE_BUNDLE>\*.zip" ".\input_artifacts\prospective\"
# EA source / EX5(読み取り専用。変更しない)
Copy-Item "C:\Users\user\AppData\Roaming\MetaQuotes\Terminal\2FA8A7E69CED7DC259B1AD86A247F675\MQL5\Experts\KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.mq5" ".\input_artifacts\prospective\"
Copy-Item "C:\Users\user\AppData\Roaming\MetaQuotes\Terminal\2FA8A7E69CED7DC259B1AD86A247F675\MQL5\Experts\KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.ex5" ".\input_artifacts\prospective\"

Get-ChildItem ".\input_artifacts\prospective" -File |
  Select-Object Name,Length,@{N="SHA256";E={(Get-FileHash $_.FullName -Algorithm SHA256).Hash}} |
  Export-Csv ".\input_artifacts\prospective\prospective_sha256_manifest.csv" -NoTypeInformation -Encoding UTF8

# 100MB超チェック(GitHub制限)
Get-ChildItem ".\input_artifacts\prospective" -File | ? { $_.Length -gt 95MB } |
  % { Write-Warning "over 100MB risk: $($_.Name)" }

git add -f input_artifacts/prospective
git commit -m "Add June 2026 locked post-sample validation bundle"
git push origin claude/gold-ea-hardstop-analysis-9aee82
```

## 4. push後

このセッション(または新セッション)に「**June bundle push完了、取り込み実行**」と
送ってください。`prospective_ingestion_pipeline.py` が19ステップを自動実行し、
検証(同一性・窓・スキーマ)→ pre-hedge feature導出 → Q1〜Q6 → 十分性 → 判定
を行います。行数が合わない・SHA不一致等は充填せず停止して報告します。

## 5. 注意

- OFF arm を忘れると非介入検証が不能になり、判定は DATA_PENDING のまま。
- June bundle は input_artifacts/prospective/ に置くこと(in-sampleの
  input_artifacts/ 直下と混ぜない。extracted/ は自動再生成・gitignore)。
