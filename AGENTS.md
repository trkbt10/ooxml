# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project implementing
Office Open XML (ECMA-376) for `.docx`, `.xlsx`, and `.pptx`.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Architecture (must read before edits)

The pipeline is

```
reader -> context -> (builder | viewer)
```

Each ECMA-376 ML chapter (DrawingML §20, OfficeMath §22.1,
WordprocessingML §17, SpreadsheetML §18, PresentationML §19) is a
**self-contained unit** owning its own `domain / reader / context /
builder / viewer` subpackages. Cross-chapter dependencies flow through
`domain` types only.

Top-level layout — see README for details:

- `src/xml`, `src/zip`, `src/cfb` — upstream standards (W3C, PKWARE, MS-CFB).
  Outside `ecma376/` because they are not part of ECMA-376.
- `src/ecma376/opc` — Part 2 Open Packaging Conventions.
- `src/ecma376/{simple_types,variant_types,custom_xml_properties,bibliography,additional_characteristics}` — Part 1 §22 ancillary chapters, each self-contained.
- `src/ecma376/drawing_ml` — §20, sub-divided by sub-domain (color/font/theme/shape/picture/chart/diagram/viewer).
- `src/ecma376/office_math` — §22.1 OMML.
- `src/ecma376/wordprocessing_ml`, `src/ecma376/spreadsheet_ml`, `src/ecma376/presentation_ml` — §17, §18, §19.
- `src/docx`, `src/xlsx`, `src/pptx` — public facades. They **drive** the
  pipeline (open/save/to_html), they do not re-export.
- `src/cmd/ooxml_cli` — native CLI build target.
- `src/cmd/{docx,xlsx,pptx}_wasm` — wasm-gc build targets, per format,
  declaring `link.wasm-gc.exports` for the npm-side core bundle.

### Naming rules

- No `base/`, `common/`, `shared/`, `util/`, `misc/`. Every directory
  name must say what is inside, ideally tied to a spec section.
- ML chapter names match ECMA-376 chapter names (e.g.
  `wordprocessing_ml`, not `word`).

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).
- The toplevel `moon.mod.json` lists module metadata and sets `source: "src"`.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.
- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` formats code.
- `moon ide` provides project navigation (`peek-def`, `outline`,
  `find-references`).
- `moon info` regenerates `pkg.generated.mbti` interface files.
- `moon check` is the primary green-bar; run `moon check --target native`
  and `moon check --target wasm-gc` before publishing.
- In the last step, run `moon info && moon fmt` to update interfaces and
  format. Inspect `pkg.generated.mbti` diffs to verify intent.
- `moon test` runs tests; `moon test --update` refreshes snapshots.
- Prefer `assert_eq` or `assert_true(x is Pattern(..))` for stable
  results, snapshot tests for current behaviour, assertions for solid
  spec-defined results. Use `moon coverage analyze > uncovered.log` to
  find untested code.

## Build targets

```bash
moon check --target native          # CLI / server / desktop
moon check --target wasm-gc         # core wasm bundle for npm
moon run src/cmd/ooxml_cli          # run native CLI
```

## Font measurement (no pre-computed values)

`src/util/glyph` is **TTF-only**. Every glyph advance, kerning
pair, ascender, descender, and line-gap value is read at runtime
from a bundled TrueType file in `src/util/glyph/fonts/` via
`mizchi/font::TTFont`.

- **Never** add a hard-coded char-width table, ascender table, or
  per-font em-ratio map. The previous `fonts.mbt` /
  `liberation_sans.mbt` / `calibri.mbt` / `common.mbt` / `font_metrics.mbt`
  were deleted for exactly this reason — they were a false source
  of truth that diverged from what LibreOffice actually
  rasterises, and they kept leading subagents into "tune the
  number" fixes instead of "measure the font".
- If you need a metric, call `@glyph.measure_text_width(...)`,
  `@glyph.get_ascender_ratio(...)`, `@glyph.calculate_char_width(...)`,
  or load a `FontMeasurer` via `@glyph.default_font_set()`.
- LibreOffice substitutes Calibri → Carlito for `.docx` and
  Calibri → Liberation Sans for `.pptx`; the registry mirrors that
  split (`FontSet::measurer_for` vs `FontSet::measurer_for_pptx_family`).
  Match the format you are rendering.
- New fonts are added by dropping a TTF into `src/util/glyph/fonts/`
  and extending the `FontFace` enum + `resolve_face` mapping in
  `font_registry.mbt`. No measurement values get committed.

## Spec-Driven Development

Real implementation is gated on running the `indexion-skills:indexion-sdd`
flow against ECMA-376 / OOXML by Codex. Do not implement parsers/builders
ad hoc — wait for the SDD pass to produce specs per chapter, then satisfy
them.
