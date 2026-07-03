# audit1_signal_config.md — Audit 1 実行設定(v1.2確認・追加情報)

registered: 2026-07-03
status: CONFIG_FROZEN_AWAITING_BUNDLE(extraction_bundle_v1未着のため未実行)
上位: Analysis & Judgment Spec v1.0 §1 / audit_v1_spec_registration.md

## 1. カバレッジと分母

- total basket: **526**
- snapshot対象(scoped): **513**
- 欠損(除外): **13**(除外リストあり)
- **分母は 513(scoped)。除外13件は Audit 1 の分母から明示的に除く。**
  除外uidは extraction_bundle_v1 の exclusions リスト(exclusions.csv または
  extraction_report.txt 記載)から取得する。除外リストが無い場合はAudit1を
  進めず Codex へ差し戻す(捏造・推測補完はしない)。

## 2. SIG-MA / SIG-RD 発火・重複(報告値、bundleで再検証)

| 区分 | 発火basket数 |
|---|---|
| SIG-MA(合計) | 33 |
| SIG-RD(合計) | 106 |
| 両方(SIG-MA ∩ SIG-RD) | 24 |
| SIG-MAのみ | 9 |
| SIG-RDのみ | 82 |

整合式: SIG-MAのみ(9) + 両方(24) = 33、SIG-RDのみ(82) + 両方(24) = 106。整合。
エンジンは signals.csv からこの5値を再計算し、報告値と一致するか §0.5 で照合する
(不一致は抽出不備として差し戻し)。

## 3. Audit 1 出力(3グループを分けて出す)

各グループ別に precision / recall / lead_time / S / C / p* / precision_margin を算出:

1. **SIG-MA 単独**(SIG-MAが発火した scoped basket 全体 = 33)
2. **SIG-RD 単独**(SIG-RDが発火した scoped basket 全体 = 106)
3. **SIG-MA ∩ SIG-RD**(両方発火 = 24)

定義(Spec §1準拠):
- fired_g = グループgが発火した scoped basket 集合
- TP = fired_g ∩ HardStop(scoped)
- recall(g) = |TP| / |HardStop(scoped)|
- precision(g) = |TP| / |fired_g|
- lead_time = hs_time − first_fire_time。**「両方」グループの first_fire_time は
  SIG-MAとSIG-RDの発火時刻の早い方(min)** を用いる。
- S(g) = mean(hs_loss − basket_pl_at_fire)(TPのみ、グループの初回発火時点)
- C(g) = mean(final_pl)(FP=非HardStopで発火、close_reason別内訳)
- p*(g) = C/(C+S)、precision_margin(g) = precision − p*

## 4. LOW_N(個別適用)

- 各グループについて **真陽性 n < 10 で LOW_N タグを個別付与**。
- LOW_N のグループは単独では優先順位判定に使わない(記述のみ)。
- 予備見込み(報告発火数より): SIG-MAのみ関連やSIG-MA∩RDはfired自体が小さく、
  TP(HardStop交差)は更に小さいため LOW_N になる可能性が高い。ただし確定は
  bundleのHardStop交差計算後。

## 5. SIG-SLP の扱い

- **記述統計のみ**(発火数、basket_pl_at_fire分布 等)。
- precision/recall・p*・閾値再テストは**禁止**(既存指示のとおり)。
- 0.05/min等の閾値をこのbundleで再最適化しない。

## 6. 固定条項(継承)

- 全出力 in-sample diagnostic only。採用判断・OOS効果・実装後利益を主張しない。
- July W2条件に影響を与えない。実装系フラグ全て false。「15万円なら勝てる」禁止。
- 複合条件(SIG-MA∩SIG-RD)は観測項目候補としての算出であり、閾値変更・新規最適化はしない。
