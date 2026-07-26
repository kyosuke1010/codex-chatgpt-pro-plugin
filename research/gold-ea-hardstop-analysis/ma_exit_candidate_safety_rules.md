# ma_exit_candidate_safety_rules.md — Future Exit候補の安全判定規則(FROZEN)

## 原則

「Future executable candidate」とは、**将来の**Exit候補として分類してよい
Signalの分類ラベルであり、実装許可ではない。分類には以下の**全ゲート**の
通過が必要。1つでも不成立またはUNKNOWNなら候補化しない。

## 必須ゲート(AND条件)

| # | ゲート | 判定 | UNKNOWN時 |
|---|---|---|---|
| G1 | M15 reverse cross confirmed | reason_code = M15_REVERSE_CONFIRMED系 | ブロック |
| G2 | closed-bar signal | forming bar由来でない(pipeline保証) | ブロック |
| G3 | HardStopNow = false | Signal時点でHardStop条件未成立 | ブロック |
| G4 | ClosePriorityOK = true | close優先順位系が整合 | ブロック |
| G5 | ClosePriorityBlocked = false | 優先度ブロック中でない | ブロック |
| G6 | pending close = false | 既存close要求が保留中でない | ブロック |
| G7 | market state valid | 市場状態が有効(取引可能・価格有効) | ブロック |
| G8 | HTE eligibility = false **かつ** known | HTEが取れる局面を奪わない | ブロック |
| G9 | Recovery eligibility = false **かつ** known | Recoveryが取れる局面を奪わない | ブロック |
| G10 | BasketClose eligibility = false **かつ** known | BasketCloseが取れる局面を奪わない | ブロック |
| G11 | Event state ≠ UNKNOWN(event依存を使う場合のみ) | Event Window状態が既知 | ブロック |
| G12 | Direction known | DIRECTION_UNKNOWNでない | ブロック |
| G13 | First eligible signal | Basket×familyのprimary Signal | ブロック |
| G14 | commission / fee | NAのまま扱う(0仮定の効果計算禁止) | — |

## UNKNOWN取り扱い規則

- **UNKNOWNをfalse扱いしない。** G8〜G10は「falseであることが既知」を要求する。
  eligibility=UNKNOWNは「falseかもしれない」ではなく「候補化不可」。
- ブロックされた行は破棄せず、`blocking_gates` 列に不成立ゲートを列挙して
  future_candidate_decision_table.csv に保存する(どのゲートが候補数を
  削っているかの監査を可能にするため)。

## 禁止事項

- ゲート閾値・条件を既存6runの結果が良くなる方向に事後調整すること。
- all_gates_pass=trueの件数や合計効果を「実装後利益」と表現すること。
- 本規則の通過をもって実Exit実装へ進むこと(設計Freeze→OOS/forward根拠が別途必要)。
