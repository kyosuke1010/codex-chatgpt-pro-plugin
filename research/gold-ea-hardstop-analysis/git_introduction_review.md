# git_introduction_review.md — Private GitHub管理導入レビュー(code側所見)

date: 2026-07-12
入力: Codex読み取り専用監査(CONDITIONAL GO、2026-07-11/12)
性格: code側(解析・レジストリ担当)からの所見と、SHA系譜の正式登録。

## 1. 判定への同意

**CONDITIONAL GO と全条件に同意**。特に以下は研究side の既存原則と完全整合:

- W3実行中は git init / push を開始しない(W3回帰・収集が最優先)
- 初回投入は現行正本 .mq5 / W3Telemetry.mqh / docs / redacted set のみ
- .ex5 / raw Tester report / raw CSV / journal は Git除外(SHA manifest参照のみ)
- .set は redaction 後のみ(Login系フィールドの中リスク判定に同意)
- Source of Truth 文書を先に作る
- Cloudflare ZIP配布は当面 GitHub と切り離す(公開フォルダの最新が
  Multilayer Phase1 Restart系=W3ではない点も、切り離しの根拠として妥当)

役割分担(ChatGPT=方針/PRレビュー、Codex=実ファイル/compile/Tester)にも同意。
本repo(codex-chatgpt-pro-plugin)は解析・レジストリ側として現行のまま。
KOUCHA-GOLD-EA repo は EAソース側の別repoとして分離するのが正しい。

## 2. SHA系譜の正式登録(identity chain)

| 対象 | SHA256(頭8) | 出所 |
|---|---|---|
| **v1解析データを生成したEA**(in6run/June、shadow source_before) | `1353718F` | shadow log(在庫: TA9 Shadow系) |
| W3直前バックアップ | `E57BE003` | Codex監査 |
| **現行W3版 source(.mq5)** | `C1DBE51A` | 作業直下=Terminal 一致 |
| W3Telemetry.mqh | `36FC7066` | 作業直下=Terminal 一致 |
| Terminal EX5(Tester正本) | `1652AA38` | Terminal側 |
| 作業直下 EX5(不一致・非正本) | `4509220F` | 監査注意点どおり |
| compile | 0 errors / 0 warnings | Codex監査 |

## 3. ⚠️ 要確認(監査に埋まっている重大点): SHA系譜の断絶疑い

**W3直前バックアップ = `E57BE003` は、v1解析データを生成したEA `1353718F` と
一致していない。**

これが意味し得ること:
- (a) 単なる非挙動差(コメント・ログ文言・整形)→ 問題なし
- (b) June収集(1353718F)以降に**挙動変更**が入った EA に W3 を実装した
  → **W3収集データは、監査1〜5・判定合成が診断したEAとは別物の観測になる**。
  M1/M2/M3 への telemetry 紐付けが弱まり、閾値ギャップ等の解釈が揺らぐ。

### 対応(実装済みのゲートで機械検出可能)

w3_implementation_request.md の検収に既に含めてある
**「W3 ON収集runのbasket outcome が v1 baskets 526 と一致すること」**が
この断絶を機械検出する。よって手順の追加は不要だが、重要度が上がった:

1. Codexへ追加依頼(軽量): `1353718F` → `C1DBE51A` の**差分証明**を
   extraction_report_w3.txt に含める(変更ファイル・変更блок一覧。
   期待: W3追記+非挙動差のみ。挙動差があるなら列挙)。
2. basket outcome照合がFAILした場合の扱いを事前固定:
   - W3データは「新ベースラインの観測」として**別サンプル扱い**
     (v1監査結果との直結を主張しない)。
   - M1/M2/M3への紐付けは、新ベースラインで HardStop構造(2原型・レッグ相殺)が
     再現するかを先に確認してから。
   - どちらに転んでも W3データ自体は破棄しない(回帰G1-G9がPASSしている限り)。

## 4. §13 ユーザー確認事項への code側推奨

| 事項 | 推奨 |
|---|---|
| 本番/標準 .set の正本 | W3収集で実際に使う .set を正本指定し、SHA manifest化+redacted版をGitへ |
| .ex5 をGitに入れるか | **完全除外**。SHA manifest(compile_manifest.csv)のみ |
| raw backtest CSV | **Git外**(ZIP+SHA)。Gitには summary と manifest のみ(現行bundle運用と同型) |
| Cloudflare配布正本 | 当面 R2/Pages 側のまま(GitHubと切り離し)。W3完了後に別途判断 |
| W3完了後sourceを初回Git正本にするか | **賛成**。ただし §3 の差分証明とセットで(tag: 監査系譜を遡れる形) |
| 過去監査ZIP | **URL/SHA manifestのみ**。repo本体に入れない |

## 5. W3工程への影響

**なし(順序はそのまま)**。現状の読み: W3Telemetry.mqh 実装済み・compile 0/0 まで
到達している。残マイルストーンは w3_implementation_request.md どおり:
静的ゲートgrep出力 → 回帰G1〜G9(w3_regression_results.csv)→ 収集run →
extraction_bundle_w3.zip push。Git導入はその後に開始(監査条件とも一致)。

## 6. 禁止事項(変わらず)

EA売買ロジック変更なし / rapid_drop 0.05 FROZEN / July W2 無接触 /
OOS効果・実装後利益・「15万円なら勝てる」不記載 / 実装系フラグ全 false。
