# 次セッション初手の手順

このリポジトリは「viewer (SVG renderer) を web-pptx に忠実移植する」
作業を継続するために、状態を凍結した上で引き継がれています。

## 最初に読むファイル
1. **`docs/HANDOFF.md`** — 引き継ぎ全文。受け入れ基準・参照地図・
   推奨作業順序・移植時の規律。
2. **`docs/CRUD_MATRIX.md`** — A 層/B 層対応表。viewer 行が事実上
   placeholder のままなので更新対象。

## 起動コマンド
```bash
cd /Users/terukichi/Workspaces/moonbit/ooxml
moon check --target native      # 0 errors を確認
moon check --target wasm-gc     # 0 errors を確認
moon test --target native       # 845 / 845 PASS を確認
```

すべて green の状態から作業を始めてください。

## 作業対象ファイル (現状の恣意的 renderer)
- `src/ecma376/presentation_ml/viewer/viewer.mbt`
- `src/ecma376/spreadsheet_ml/viewer/viewer.mbt`
- `src/ecma376/wordprocessing_ml/viewer/viewer.mbt`

## 移植元
`/Users/terukichi/Workspaces/trkbt10/web-pptx/packages/@aurochs-renderer/`
配下 (HANDOFF.md の「参照地図」と「未読リスト」を参照)。

## TaskList
旧セッションで作成されたタスク #74 〜 #83 が登録済。
- #74, #75 完了 (facade 削除)
- #76 in_progress (web-pptx pptx renderer 読解 — `slide-shapes.ts:340` 以降未読)
- #77〜#83 pending

次セッションは #76 の続きから始めてください。
