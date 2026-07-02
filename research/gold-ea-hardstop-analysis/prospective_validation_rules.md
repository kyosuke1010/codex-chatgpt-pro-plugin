# prospective_validation_rules.md — 受け入れ検証ルール

対象: input_artifacts/prospective/ に到着する June-2026 locked post-sample bundle。
実装: prospective_ingestion_pipeline.py(19ステップ)。ルール違反はBLOCKし、
充填(feature生成・Q解析)へ進まない。捏造・補間・合わせ込みを一切しない。

## A. 完全性(BLOCK on fail)

1. SHA256: 全到着ファイルを記録(prospective_input_sha_manifest.csv)。
   ユーザー同梱manifestとの突合で転送破損を検出。
2. 必須成果物(prospective_expected_artifact_manifest.csv PX01〜PX10, PX12):
   欠落は `PROSPECTIVE_INPUT_SCHEMA_INCOMPLETE`。
3. Shadow ON と Shadow OFF の**両arm**が揃うこと(非介入検証の前提)。

## B. 同一性(BLOCK on fail → `PROSPECTIVE_WINDOW_CONTAMINATED`)

4. EA source SHA == e57be003… / EX5 SHA == 49b31402…。不一致は
   「in-sampleと別EA」= 汚染。
5. input_set: Symbol=GOLD, Period=M5, Model=0, Deposit∈{50000,100000}。
6. window: FromDate=2026.06.01 かつ ToDate=2026.06.30。
   さらに全Snapshotの server_time が half-open [2026-06-01, 2026-07-01) に入ること。
   窓外Snapshotは feature計算から除外(補間しない)。

## C. スキーマ(BLOCK on fail → `PROSPECTIVE_INPUT_SCHEMA_INCOMPLETE`)

7. root_snapshot必須列(prospective_schema_contract.csv REQ_SNAP)が全て存在。
8. basket_summary の final_close_reason / net_profit / hedged / first_hedge_time 存在。
9. run_summary が各runに1行。

## D. 導出の健全性(観測専用・行動なし)

10. slope導出は後方窓のみ(closed-bar/backward)。窓内基準Snapshotが
    実経過 W/2 未満なら `UNDERIVABLE_SPARSE`(外挿・前値埋め禁止)。
11. 正規化は loss_slope / hardstop_threshold(capital横断比較はこの正規化値のみ)。
12. rapid_drop_observation_trigger = (norm3 >= 0.05/min)。**この閾値は固定**。
    June結果を見て変更した場合、その結果は無効(contamination CL03)。
13. eligibility(HTE/Recovery/BasketClose)と market_state の UNKNOWN を
    false/true に丸めない。market_state=OPEN_OR_UNKNOWN は UNKNOWN 扱い。
14. commission は NA(0埋め禁止)。効果はすべて ex-commission。

## E. 非介入(観測の大前提)

15. ML_B(OFF) と ML_C(ON) の Trade Events を突合し、deal/order fingerprint が
    完全一致すること(Shadow由来の売買が0/0/0)。不一致は観測の妥当性を
    失うため、当該runを棄却し原因監査を要求。

## F. 統計の分離(汚染防止)

16. in-sample baseline は読み取り専用定数。June結果を in-sample テーブルへ
    マージしない。Q1〜Q6は「in-sample参照 vs prospective実測」の並置のみ。
17. selection に June の結果を使わない(既に selection_time=2026-07-02 で固定済み)。
