# indicator_cache_contamination_risk.md — Runtime MA telemetryを避ける理由

## 事故前提

過去のShadow実装で、Runtime indicator cacheの汚染が非介入性を破った経緯がある
(SESSION_REPORTED: Phase 1修正で解消し、現在は6/6 PASS)。本文書はその再発を
構造的に防ぐためのリスク記録である。

## リスク機構

1. **handle作成の副作用**: EA内で新規 `iMA()` を呼ぶと、テスターは当該
   indicator計算をチャート/シンボル単位のcacheに載せる。既存EAが同種
   indicatorを別パラメータで持つ場合、計算順序・cacheヒット状況が変わり、
   OnTick内の処理時間・タイミングが変化し得る。
2. **CopyBuffer/CopyRatesの同期副作用**: 呼び出しが履歴データの
   ロード/再同期をトリガーし、テスターのイベント順序に影響する可能性がある。
   また未確定バーの混入・series方向のreindexにより、closed-bar契約を
   EA内で保証するのは検証コストが高い。
3. **見かけ上read-onlyでも安全でない**: 「値を読むだけ」の呼び出しでも、
   cacheの初期化・拡張という状態変更を伴う。非介入性の証明対象が
   「order/deal/close 0件」から「indicator計算状態の完全一致」へ拡大し、
   現行の回帰スイート(A_REFERENCE比較)では検出粒度が不足する恐れがある。
4. **失うものの大きさ**: 現在の資産は「Shadow OFF/ON/A_REFERENCE 6/6 PASS」
   という非介入性の実証。Runtime MA追加はこの実証を無効化し、
   全回帰の再走行と再監査を要求する。得られるのはオフラインで既に
   取得できている値(442/442結合済み)にすぎない。

## 結論

- Runtime MA telemetryは**便益ゼロ・リスク正**であり、採用しない。
- 採用を再検討してよい唯一の条件: prospective運用でSnapshot頻度が粗く、
  availability_lagが診断を破壊するとデータで示された場合。その際も
  POST_RUNTIME_READONLY_HANDOFF(既存計算の読み出しのみ)を先に検討し、
  非介入回帰スイートの完全再走行を必須とする。
