# w3_risk_register.md — W3 Telemetry リスク登録簿

date: 2026-07-11(Design Freeze同梱)

| ID | リスク | 影響 | 発生源 | 軽減策(設計内) | 残余リスク処置 |
|---|---|---|---|---|---|
| R1 | ログ量爆発でテスター実行が劣化/ディスク枯渇 | run失敗・収集不能 | tick毎のW3_HS_DETECT誤設計・EVAL/WORST乱発 | DETECTは初回超過のみ1行。WORSTは250円悪化刻み。EVALは条件変化+500円刻み。snapshot全tick記録はしない | run_source_manifestに行数上限目安を記録し超過runは要調査 |
| R2 | ログ書込失敗がEA実行を停止させる | 売買挙動への介入(最悪) | ファイルI/O例外 | failure isolation(握って継続+fail_count)。G8故障注入試験で機械検証 | G8 FAILなら収集禁止 |
| R3 | W3コードが共有状態を書き換え売買が変わる | 非介入違反 | 実装ミス | 静的要件(一方向依存・const読み・禁止シンボルgrep 0)+G1〜G6差分0ゲート | 回帰FAILで全量破棄 |
| R4 | W3計算(yen→price換算等)が重くtick処理を遅延させ、テスター内の約定タイミングが変わる | 微妙な挙動差 | I1挿入点の計算量 | W3計算は加減乗除のみ・インジケータ新規ハンドル禁止。テスターは仮想時刻のため実時間遅延は原則非介入だが、G2ハッシュ一致で最終確認 | ハッシュ不一致なら計算をSUMMARY行へ後置 |
| R5 | スキーマドリフト(実装が凍結スキーマとずれる) | 下流解析破損 | 実装裁量 | w3_schema_version=W3.1固定。納品時にヘッダ行を凍結CSVと機械照合 | 不一致列はMISSING扱い+report記載 |
| R6 | detect定義の曖昧さ(閾値「初回超過」がリトライ/再超過で複数回発生) | M3分析の歪み | 相場の往復 | DETECTはbasket毎に最初の1回のみ。再超過はSUMMARYのmarket_closed_retry_count等で捕捉 | 複数DETECTが必要と判明したらW3.2で拡張 |
| R7 | post_close_move結合のTZ/カレンダー不整合 | Audit 5誤判定 | offline結合 | 同一サーバ時刻系のみ結合可・不一致はJOIN_TZ_MISMATCHで全行MISSING・coverage<0.8はMISSING | 結合率をreportで開示 |
| R8 | hedged 2-legのleg帰属曖昧(FILL行の突合ミス) | gross/net分解の誤り | 実装 | FILL行にticket・direction・leg損益を持たせv1.4 deals形式と同型で突合可能にする | 突合不能legはMISSING |
| R9 | W3収集runがJuly W2評価を汚染する | 事前登録違反 | 期間設定ミス | 回帰・収集ともMar–May/June限定を計画に明記。July期間指定を納品前チェックリスト化 | July混入行は即時全量破棄 |
| R10 | 「W3データで実装判断まで飛ぶ」運用リスク | プロセス違反 | 人的 | 本凍結の性格=計測設計のみ。実装系フラグ全false維持。W3完了後も「実Exit設計審査」であって実装ではない | next_decision.mdの承認ゲートで拘束 |
