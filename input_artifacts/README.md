# input_artifacts/ — GOLD EA 入力成果物の受け入れ場所

## 状況

Claude Codeのこのセッションは**リモートコンテナ**で動作しており、
Windowsローカル(`C:\Users\user\Documents\New project` /
`C:\Users\user\AppData\Roaming\MetaQuotes\...`)には直接アクセスできない。
コンテナ内にはGitHubからcloneしたこのrepoしか存在しない。

したがって、入力成果物は**このフォルダにコミットしてpush**する必要がある。

## Windows側での手順(PowerShell)

```powershell
cd <このrepoのローカルclone>
git fetch origin
git checkout claude/gold-ea-hardstop-analysis-9aee82

# ZIPをコピー
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_MULTILAYER_PHASE1_SHADOW_FIX_AUDIT.zip" input_artifacts\
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_MA_CROSS_10EMA20SMA_AUDIT.zip" input_artifacts\
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_PHASE1_RUNTIME_MA_CROSS_OVERLAY_AUDIT.zip" input_artifacts\
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_M15_REVERSE_CROSS_SHADOW_DESIGN_AUDIT.zip" input_artifacts\
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_CURRENT_EA_BASKET_PAYOFF_STRUCTURE_AUDIT.zip" input_artifacts\
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_HARDSTOP_ROOT_CAUSE_MULTI_LOGIC_AUDIT.zip" input_artifacts\
Copy-Item "C:\Users\user\Documents\New project\KOUCHA_GOLD_EVENT_BLACKOUT_WINDOW_AUDIT.zip" input_artifacts\

# EA source / EX5(読み取り専用として扱う。変更禁止)
Copy-Item "C:\Users\user\AppData\Roaming\MetaQuotes\Terminal\2FA8A7E69CED7DC259B1AD86A247F675\MQL5\Experts\KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.mq5" input_artifacts\
Copy-Item "C:\Users\user\AppData\Roaming\MetaQuotes\Terminal\2FA8A7E69CED7DC259B1AD86A247F675\MQL5\Experts\KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.ex5" input_artifacts\

git add input_artifacts
git commit -m "Add GOLD EA input artifacts for hardstop analysis"
git push origin claude/gold-ea-hardstop-analysis-9aee82
```

push完了後、Claude Codeセッションで「input_artifacts を取り込んで再実行」と
指示すれば、下記の検証→再発見→充填が自動で走る。

## 注意

- **GitHubは1ファイル100MBを超えるとpushを拒否する**(50MB超で警告)。
  超える場合は `Compress-Archive` で分割するか、CSVを個別ZIP化して分ける。
- ZIPファイル名は上記のまま変更しないこと(検証スクリプトが名前で照合する)。
- `.ex5` はバイナリのままで良い(SHA記録と保管のみ。実行はしない)。
- **EA source / EX5 は読み取り専用。本repo上でも一切変更しない。**

## 期待ZIP一覧(manifest ART対応)

| ZIP | manifest |
|---|---|
| KOUCHA_GOLD_MULTILAYER_PHASE1_SHADOW_FIX_AUDIT.zip | ART03(+ART04候補) |
| KOUCHA_GOLD_MA_CROSS_10EMA20SMA_AUDIT.zip | ART06 |
| KOUCHA_GOLD_PHASE1_RUNTIME_MA_CROSS_OVERLAY_AUDIT.zip | ART04/ART06結合 |
| KOUCHA_GOLD_M15_REVERSE_CROSS_SHADOW_DESIGN_AUDIT.zip | 設計監査 |
| KOUCHA_GOLD_CURRENT_EA_BASKET_PAYOFF_STRUCTURE_AUDIT.zip | ART05/ART08 |
| KOUCHA_GOLD_HARDSTOP_ROOT_CAUSE_MULTI_LOGIC_AUDIT.zip | ART09 |
| KOUCHA_GOLD_EVENT_BLACKOUT_WINDOW_AUDIT.zip | ART07 |
| KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.mq5 | ART01 |
| KOUCHA_GOLD_KIWAMI_SURVIVAL_TICK.ex5 | ART02 |

## 到着後にコンテナ側で走る処理

`research/gold-ea-hardstop-analysis/ingest_verify.py` が以下を行う:

1. 各ZIPのSHA256記録・展開(`input_artifacts/extracted/` へ)
2. 全CSVの再発見: ヘッダ・行数・キー列候補(basket_uid等)を目録化
3. 期待値照合: Runtime Snapshot 169,305行 / Basket Summary 442件 /
   HardStop 37件(不一致は充填を停止して報告)
4. 目録 `artifact_discovery_report.md` を生成

その後、目録で確認した実スキーマに基づき、前回ゼロ行だった
Phase B/F/G CSV(hardstop_root_cause_rebuild 等)を充填する。
