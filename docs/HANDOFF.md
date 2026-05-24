# 引き継ぎドキュメント — viewer (SVG renderer) を web-pptx に忠実移植する

このドキュメントは、`trkbt10/ooxml` の viewer (SVG renderer) を
`/Users/terukichi/Workspaces/trkbt10/web-pptx` の `@aurochs-renderer`
実装に**忠実移植**する作業を、現セッションでは完遂できなかったため、
次セッションが直入できるよう状況を完全に記録するものです。

---

## 現在の状態スナップショット (引き継ぎ時点)

### コードベース
- `moon check --target native`: **0 errors** (1051 warnings, 既存)
- `moon check --target wasm-gc`: **0 errors**
- `moon test --target native`: **939 / 939 PASS**
- `moon test --target wasm-gc`: **939 / 939 PASS**
- リポジトリ: `/Users/terukichi/Workspaces/moonbit/ooxml`

### ECMA-376 XSD カバレッジ (公式 Transitional schemas)
- Complex Types (CT_*) : **1431 / 1431 = 100%**
- Simple Types  (ST_*) : **595 / 595 = 100%**
- Top-level Elements   : **174 / 174 = 100%**
- 26 schema 全て 100% (dml-chart, dml-main, pml, sml, wml, shared-*, vml-* 等)
- 詳細: `docs/ECMA376_XSD_COVERAGE.md`
- 監査ツール: `.kiro/scripts/xsd_coverage.py`

### 完了済みの構造リファクタ (撤回不可・前提条件)

**facade 撤廃**: `src/docx/`, `src/xlsx/`, `src/pptx/` は**物理削除**済。
利用者は `@<ml>_context.open(bytes)` を直接呼ぶ:

```
src/ecma376/wordprocessing_ml/{context, edit, builder, reader, viewer, domain, ...}
src/ecma376/spreadsheet_ml   /{context, edit, builder, reader, viewer, domain, ...}
src/ecma376/presentation_ml  /{context, edit, builder, reader, viewer, domain, ...}
src/cmd/{ooxml_cli, docx_wasm, xlsx_wasm, pptx_wasm}
src/edit/         ← A 層 XML primitive (ML 非依存)
src/util/base64/  ← data URI 用 base64 encoder
```

責務分離は明確:
- `domain/` : typed CT_* 構造体 + parse メソッド
- `reader/` : bytes → CT_* (parser)
- `builder/`: CT_* → bytes (serializer)
- `viewer/` : CT_* → html / svg (**renderer — ここが本作業の対象**)
- `context/`: Document / Workbook / Presentation 構造体 + open/save/to_html
              + 純粋 query (style/numbering/field/animation 解決等)
- `edit/`   : B 層 mutator (トップレベル関数, A 層 primitive を消費)

すべてのテストとビルドが通る状態を保ったまま引き継いでいます。

### CRUD/operation の網羅状況 (本作業に関連)
`docs/CRUD_MATRIX.md` に viewer 行が「DONE」と記載されていますが、
**SVG renderer は事実上 placeholder です**。これが本作業の動機です。

---

## 本作業の目的

`web-pptx` (production-grade TypeScript 実装) の renderer を、MoonBit 側の
`src/ecma376/{wordprocessing_ml,spreadsheet_ml,presentation_ml}/viewer/`
に**忠実移植**します。現状の viewer は「ぱっと見動く SVG を出すだけ」で、
placeholder 継承や text-layout を全く反映しておらず、user 視点で renderer
と呼べる品質ではありません。

### 受け入れ基準 (Acceptance criteria)
1. **pml viewer**: 1 枚の slide を web-pptx と**同じ SVG 構造**で出力する
   - `<defs>` (gradient / pattern) を collect する `SvgDefsCollector` 同等のしくみ
   - background / layout shapes / slide shapes を web-pptx と同じ順序で描く
   - `<p:sp>` の transform (`<a:xfrm>/<a:off>`/`<a:ext>`/`<a:chOff>`) を web-pptx と
     **同じ式**で `transform="translate(...) scale(...)"` に落とす
   - `solidFill` / `gradFill` / `blipFill` / `noFill` を区別し、`<a:srgbClr>`,
     `<a:schemeClr>` (色解決), `<a:alpha>` を反映
   - placeholder 継承 (master ← layout ← slide) を `placeholder_resolver` で
     解決し effective shape を描く
   - text は web-pptx の `text-layout/` engine と同等の振る舞いで配置:
     line breaking, bullet (buChar/buAutoNum), pPr 継承 (defRPr ← lstStyle ←
     lvl1pPr ← rPr), bodyPr anchor, font metrics は `mizchi/font` を使う
   - 未サポート機能は `<!-- unimplemented: <feature> -->` SVG コメントとして
     残す (silently skip ではない)
2. **wml viewer**: docx 1 ページを web-pptx の docx renderer に倣って SVG 化
3. **sml viewer**: xlsx 1 sheet を web-pptx の xlsx renderer に倣って SVG 化
4. `docs/CRUD_MATRIX.md` の renderer 行を移植内容に合わせて更新
   (どの ECMA-376 §, どの web-pptx 関数を参照したか)
5. `viewer/*_wbtest.mbt` に「web-pptx 出力と構造が一致するか」を検査する
   テストを追加 (snapshot 形式が現実的)
6. `moon check --target native` / `--target wasm-gc` 0 errors
7. テスト全 PASS

---

## web-pptx renderer の参照地図

すべて `/Users/terukichi/Workspaces/trkbt10/web-pptx/packages/` 配下。

### pml renderer (本作業の中心)
- `@aurochs-renderer/pptx/src/index.ts` — public exports 一覧
- `@aurochs-renderer/pptx/src/render-context.ts` — `CoreRenderContext`
  (slideSize / colorContext / resourceStore / warnings / layoutShapes 等)
- `@aurochs-renderer/pptx/src/render-options.ts` —
  `DEFAULT_RENDER_OPTIONS` / `POWERPOINT_RENDER_OPTIONS` / `LIBREOFFICE_RENDER_OPTIONS`
- `@aurochs-renderer/pptx/src/transform.ts` —
  `extractTransformData` / `buildSvgTransformAttr` (EMU → SVG transform 文字列)
- `@aurochs-renderer/pptx/src/svg/renderer.ts` (190 行) — **`renderSlideSvg`
  本体**. 既に概要を読んだので下に要約を貼る。
- `@aurochs-renderer/pptx/src/svg/slide-utils.ts` —
  `createDefsCollector` / `getShapeTransform` / `isShapeHidden` /
  `buildTransformAttr` / `buildGroupTransformAttr`
- `@aurochs-renderer/pptx/src/svg/slide-background.ts` —
  `renderResolvedBackgroundSvg` / `renderBackgroundSvg`
- `@aurochs-renderer/pptx/src/svg/slide-shapes.ts` (841 行) — shape 分岐:
  sp / pic / grpSp / cxnSp / graphicFrame
- `@aurochs-renderer/pptx/src/svg/slide-text.ts` (612 行) — `renderTextSvg`
  / `getDashArray` (slide-shapes でも使われる)
- `@aurochs-renderer/pptx/src/svg/fill.ts` (287 行) — `renderFillToSvgDef`
  / `renderFillToSvgStyle` / `getResolvedImageFill` /
  `renderImageFillToSvgDef`
- `@aurochs-renderer/pptx/src/svg/geometry.ts` — `renderGeometryPath` /
  `renderGeometryPathWithMarkers` (DrawingML preset/custom geometry → SVG path)
- `@aurochs-renderer/pptx/src/svg/marker.ts` — line end marker (`a:headEnd` /
  `a:tailEnd`)
- `@aurochs-renderer/pptx/src/svg/primitives.ts` — SVG element builders
  (`g`, `rect`, `path`, `text`, `tspan`, `defs`, `linearGradient`, ...)
- `@aurochs-renderer/pptx/src/text-layout/` (engine / measurer /
  line-breaker / auto-number / adapter) — text-layout
- `@aurochs-renderer/svg/` — SVG parsing utilities (`parseSvgString`)
- `@aurochs-renderer/drawing-ml/` — shared DrawingML rendering
  (renderGeometryData / renderTextSvg dependencies)

### docx renderer (`@aurochs-renderer/docx/src/`)
- `builder.ts` / `document.ts` / `paragraph.ts` / `run.ts` / `section.ts` /
  `table.ts` / `styles.ts` / `numbering.ts` / `drawing.ts` / `patcher.ts`
- `roundtrip.spec.ts` がレンダリング契約のリファレンス
- 注意: docx renderer はビルダ寄りの実装 — レンダー版は別ディレクトリにある
  可能性があるので開始時に再調査必要

### xlsx renderer (`@aurochs-renderer/xlsx/src/`)
- 同等のファイル群がある。`@aurochs-builder/xlsx/src/` も参照
  (set_cell_value / merge_cells 等の実装パターン)

### renderSlideSvg の要約 (renderer.ts:91)
```ts
export function renderSlideSvg(slide: Slide, ctx: CoreRenderContext): SvgSlideRenderResult {
  const { width, height } = ctx.slideSize;
  const defsCollector = createDefsCollector();
  const backgroundSvg = renderSlideBackgroundSvg(slide, ctx, defsCollector);
  const layoutShapesSvg = renderLayoutShapesSvg(ctx, defsCollector);
  const contentSvg = renderShapesSvg(slide.shapes, ctx, defsCollector);
  const defs = defsCollector.toDefsElement();
  const svg = `<svg xmlns="..." width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
${defs}
${backgroundSvg}
${layoutShapesSvg}
${contentSvg}
</svg>`;
  return { svg, warnings: ctx.warnings.getAll() };
}
```

MoonBit 移植では `SvgDefsCollector` (Ref[Array[Element]] + ID generator) を
A 層 helper として `src/ecma376/<ml>/viewer/` 配下に作るのが妥当。

### renderShapeSvg (slide-shapes.ts:75) の switch
```ts
switch (shape.type) {
  case "sp":            return renderSpShapeSvg(...)
  case "pic":           return renderPictureSvg(...)
  case "grpSp":         return renderGroupSvg(...)
  case "cxnSp":         return renderConnectorSvg(...)
  case "graphicFrame":  return renderGraphicFrameSvg(...)
}
```

MoonBit 側では `@xml.Element` の `local_name` で分岐 (domain CT は
typed だが viewer は element を歩く方が web-pptx と同型になる)。

---

## MoonBit 側の現状と移植時のすべきこと

### 現状の `pml/viewer/viewer.mbt` (恣意的な実装)
- `render_svg(domain, width_emu, height_emu, image_resolver)` — トップレベル
- `font-size="180000"` を全 text にハードコード ← **撤廃必須**
- 行送り `228600` EMU ハードコード ← **text-layout engine に置換**
- shape 位置は `<a:xfrm>` の `x/y/cx/cy` だけ抽出、`<a:chOff>` (グループ
  オフセット) 無視 ← **`buildSvgTransformAttr` 同等を実装**
- `solidFill` / `gradFill` / `blipFill` の区別なし、`<a:srgbClr>` だけ ←
  **`fill.ts` 同等を実装**
- placeholder 継承無視 ← `placeholder_resolver` を viewer から呼ぶ
- bullet / indent / tabs / bodyPr.anchor 無視 ← text-layout 移植で対応

### 既に存在する MoonBit 側の関連実装
- `src/ecma376/presentation_ml/placeholder_resolver/` —
  `SlideChain::from_parts(master, layout, slide)` /
  `resolve_slide_shapes(chain) -> Array[ResolvedShape]`
  → これを viewer から使えば placeholder 継承は解決可能
- `src/ecma376/presentation_ml/domain/` — CT_Slide / CT_GroupShape /
  CT_Shape (drawing_ml/) / CT_TextBody / 等の typed projection
- `src/util/base64/` — data URI 用 (a:blipFill → `<image href="data:...">`)
- `.mooncakes/mizchi/font/src/` — TTFont.parse_font / glyph_metrics_at /
  scaled_outline / cap_height / x_height — text-layout のメトリクス測定
  に使用

---

## このセッションで読了 / 未読の web-pptx ファイル

### 読了 (内容を本書に要約済)
- `@aurochs-renderer/pptx/src/index.ts` 全 149 行
- `@aurochs-renderer/pptx/src/svg/renderer.ts` 全 190 行
- `@aurochs-renderer/pptx/src/svg/slide-shapes.ts` 1–339 行 (340–841 行未読)

### 部分確認 (`wc -l` / `ls` のみ)
- `@aurochs-renderer/pptx/src/svg/` ディレクトリ構成 (上の参照地図参照)
- `@aurochs-renderer/pptx/src/text-layout/` ディレクトリ構成
- `@aurochs-renderer/{docx,xlsx}/src/` ディレクトリ構成 (本文中)

### 未読 (作業前に必ず Read tool で全行確認)
- `@aurochs-renderer/pptx/src/svg/slide-shapes.ts` 340–841 行
- `@aurochs-renderer/pptx/src/svg/slide-text.ts` 全 612 行
- `@aurochs-renderer/pptx/src/svg/fill.ts` 全 287 行
- `@aurochs-renderer/pptx/src/svg/slide-background.ts`
- `@aurochs-renderer/pptx/src/svg/slide-utils.ts`
- `@aurochs-renderer/pptx/src/svg/geometry.ts` / `gradient-utils.ts` /
  `marker.ts` / `primitives.ts` / `string-utils.ts` / `svg-utils.ts` /
  `table.ts` / `effects.ts` / `effects3d.ts`
- `@aurochs-renderer/pptx/src/svg/context.ts` (CoreRenderContext と
  別の `SvgRenderContext` の関係)
- `@aurochs-renderer/pptx/src/render-context.ts` (CoreRenderContext 定義)
- `@aurochs-renderer/pptx/src/render-options.ts` (RenderOptions /
  RenderDialect)
- `@aurochs-renderer/pptx/src/transform.ts`
- `@aurochs-renderer/pptx/src/text-layout/*.ts` 全部
- `@aurochs-renderer/pptx/src/context/*.ts`
- `@aurochs-renderer/{docx,xlsx}/src/**/*.ts` 全部
- `@aurochs-office/pptx/domain/index.ts` ほか domain 定義 (renderer の
  入力型)
- `@aurochs-office/drawing-ml/domain/{fill,line,geometry}.ts` (renderer
  が import する基本型)
- `@aurochs-office/drawing-ml/domain/units.ts` (`px` 単位変換)

## 推奨される作業順序

1. **読解フェーズ** (Read tool のみで、書き込まない)
   - [ ] `web-pptx/.../svg/slide-utils.ts` — defsCollector / transform 構造
   - [ ] `web-pptx/.../transform.ts` — extractTransformData / buildSvg…
   - [ ] `web-pptx/.../svg/fill.ts` 全行
   - [ ] `web-pptx/.../svg/slide-shapes.ts` 全行 (841 行, 既に上 339 行は
         このセッションで確認済み)
   - [ ] `web-pptx/.../svg/slide-text.ts` 全行
   - [ ] `web-pptx/.../svg/slide-background.ts`
   - [ ] `web-pptx/.../text-layout/engine.ts` + `measurer.ts` +
         `line-breaker.ts` + `auto-number.ts`
   - [ ] `web-pptx/.../svg/geometry.ts` (preset/custom geometry → path)
   - [ ] `web-pptx/.../svg/marker.ts`
   - [ ] `web-pptx/packages/@aurochs-office/pptx/domain/` で
         `Slide`, `SpShape`, `PicShape`, `TextBody` の型定義を確認

2. **A 層追加** (renderer 用 helper を `src/edit` ではなく
   `src/ecma376/presentation_ml/viewer/` 配下に置く)
   - [ ] `defs_collector.mbt` — `SvgDefsCollector` 相当
   - [ ] `transform.mbt` — `extract_transform_data` / `build_svg_transform_attr`
   - [ ] `fill.mbt` — `render_fill_to_svg_def` / `render_fill_to_svg_style`
         / `get_resolved_image_fill`
   - [ ] `color_resolver.mbt` — `<a:srgbClr>` / `<a:schemeClr>` 解決 (theme
         color の lookup)
   - [ ] `geometry.mbt` — preset geometry の `<path d="...">` 生成 (rect,
         ellipse, triangle 等、最初は subset)

3. **B 層書き直し** (`viewer.mbt` の `render_svg` 内容を入れ替え)
   - [ ] `render_slide_svg(slide, ctx) -> {svg, warnings}` を新規実装
   - [ ] 旧 `render_svg` は thin adapter として残す or 削除
   - [ ] `render_shape_svg(shape, ctx, defs_collector)` の switch
   - [ ] `render_sp_shape_svg`, `render_picture_svg`, `render_group_svg`,
         `render_connector_svg`, `render_graphic_frame_svg`
   - [ ] `render_shape_text_svg` (text-layout 統合)

4. **text-layout 移植** (最重要・最大)
   - [ ] `text_engine.mbt` — paragraph / run の継承解決 (defRPr ← lstStyle ←
         lvl1pPr ← rPr)
   - [ ] `text_measurer.mbt` — `mizchi/font` を使った glyph 幅測定
   - [ ] `line_breaker.mbt` — word wrap (空白 / 全角 / 改行)
   - [ ] `auto_number.mbt` — bullet 番号生成 (a:buAutoNum の `type` 値)
   - [ ] `render_text_svg(text_body, ctx, box_w, box_h, defs_collector)`

5. **wml viewer / sml viewer の書き直し**
   - 同様のパターンを `wordprocessing_ml/viewer/` と `spreadsheet_ml/viewer/`
     に適用

6. **CRUD_MATRIX.md と wbtest 更新**
   - 旧 placeholder 実装に対応する記述を「DONE (web-pptx 準拠)」へ
     差し替え、移植元の web-pptx パス + 関数名を明記
   - viewer wbtest: 「正しく `<defs>` 要素を出力する」「placeholder 継承後
     の shape 数が一致する」「rPr 継承で font-size がデフォルトに fallback
     する」等のテストを追加

7. **最終検証**
   - native + wasm-gc 0 errors
   - 全テスト PASS
   - `docs/CRUD_MATRIX.md` の renderer 行が偽りなく "web-pptx 準拠 (file:fn
     参照)" になっている

---

## このセッションで作ったタスク (まだ完了していない)

TaskList 上の状態 (引き継ぎ時):
- `#74` 完了: facade 削除 #1
- `#75` 完了: facade 削除 #2
- `#76` in_progress: web-pptx pptx renderer 全体構造把握 (renderer.ts と
  slide-shapes.ts 冒頭 ~339 行までは読了)
- `#77`–`#81` pending: docx/xlsx 読解、pml/wml/sml viewer 書き直し
- `#82` pending: wbtest 追加 + CRUD_MATRIX 更新
- `#83` pending: 最終検証

次セッションは `#76` の続き (slide-shapes.ts:340 以降 + slide-text.ts +
fill.ts + text-layout/) から始めてください。

---

## 移植時の規律 (絶対遵守)

1. **読まずに書かない**: 関数名や雰囲気から推測で実装しない。`web-pptx` の
   該当ファイルを Read tool で全行確認してから MoonBit を書く。
2. **不明な部分は `// unimplemented: <feature> per web-pptx <file>:<line>`
   コメントで保留**。silently skip は禁止。
3. **`src/{docx,xlsx,pptx}` を復活させない**: facade 撤廃済み。CLI / wbtest
   は `@<ml>_context.open` を直接呼ぶ。
4. **renderer 関数は viewer パッケージのトップレベル fn**: A 層 primitive と
   同じ流儀。`Presentation::render_svg` 等のメソッドは作らない。
5. **EMU の単位変換は web-pptx の式と完全に一致させる**: 914400 EMU/inch,
   12700 EMU/pt 等のマジック値もコメントに ECMA-376 § 番号を添える。
6. **renderer の各関数の docstring に対応する web-pptx ファイル + 関数名 +
   行番号を `@source` として記述**: 将来の差分追跡を可能にする。
7. **A 層 (src/edit/) を増やすときは慎重に**: viewer 専用 helper は viewer
   ディレクトリ内に置く (汎用 XML CRUD と SVG renderer 専用 helper を混ぜ
   ない)。
8. **moon fmt は最後に**: 途中で fmt すると script-rewrite した試行で
   linter が typealias を `using @pkg {type X as X}` に書き換えたりするので、
   コンパイル通す→テスト通す→fmt の順。

---

## 関連ドキュメント
- `docs/CRUD_MATRIX.md` — A 層 / B 層対応表 (viewer 行は要更新)
- `references/spec/part1/sections/` — ECMA-376 Part 1 (§19/§20 が pml/dml)
- `.kiro/specs/` — SDD 仕様

---

## 困ったら見る場所
- pml domain の typed CT は `src/ecma376/presentation_ml/domain/domain.mbt`
  (約 4000 行)
- placeholder 継承の実装は
  `src/ecma376/presentation_ml/placeholder_resolver/placeholder_resolver.mbt`
- mizchi/font API は `.mooncakes/mizchi/font/src/parser.mbt` の `TTFont::*`
- mizchi/svg API は `.mooncakes/mizchi/svg/src/api.mbt`
- A 層 XML primitive は `src/edit/edit.mbt`
- OPC primitive は `src/ecma376/opc/package.mbt`

---

## 引き継ぎ時点のテスト結果
```
moon check --target native:    0 errors  (372 warnings)
moon check --target wasm-gc:   0 errors
moon test --target native:     845 / 845 PASS
```

新セッションがこの状態から始めて作業を行うことを前提とします。
