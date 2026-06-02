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

## Font measurement (no pre-computed values, ECMA-376 chain)

`src/util/glyph` is **TTF-only**. Every glyph advance, kerning
pair, ascender, descender, and line-gap value is read at runtime
from a TrueType file the `FontResolver` returns. The repository
ships **no bundled production fonts** — production measurements read
bytes from embedded OOXML fonts, the host OS, or an operator-supplied
directory. Tests and catalog verification may inject explicit fixture
TTF bytes through `FontResolver::in_memory`; those fixtures are test
inputs, not ECMA-376 defaults.

- **Never** add a hard-coded char-width table, ascender table, or
  per-font em-ratio map. Any "measurement constant" living in code
  is a false SoT — `mizchi/font::TTFont` is the only allowed
  source of advance / hmtx / hhea / OS_2 values.
- **Never** name a specific renderer's font-substitution table as
  the source of truth. Office binaries (Word, PowerPoint, Excel,
  alternative office suites) all apply their own substitution
  chains; the renderer follows ECMA-376 §17.8.3.1 / §20.1.4.2.1
  instead.
- If you need a metric, call `@glyph.measure_text_width(text,
  font_size_pt~, letter_spacing_px~, family~, weight~, italic~)`
  (or the per-glyph / detailed variants). Every entry point raises
  `@glyph.FontUnresolvedError` when the resolver chain cannot
  satisfy the request; callers retry through the substitution
  chain or surface the failure at the document boundary.

### Resolution chain

The renderer turns a document-side font reference into a
`@glyph.FontResolutionRequest` carrying the primary family name
plus every disambiguating hint the document supplied
(`<w:altName>`, `<w:panose1>`, `<w:family>`, embedded-font bytes).
`@glyph.build_font_face_request` walks them in spec order — primary
→ altName → PANOSE-derived generic → typed `<w:family>` generic —
into a `FontFaceRequest` the resolver consumes.

`@glyph.create_host_font_resolver()` composes the project resolver
chain:

  1. `FontResolver::env_dir` — scans `$OOXML_FONT_DIR` directories.
  2. `FontResolver::host` — walks the OS-canonical font dirs
     (`/System/Library/Fonts`, `/usr/share/fonts`, `%SYSTEMROOT%\Fonts`,
     …) using `trkbt10/osenv` for platform detection.

Tests inject `FontResolver::in_memory` through
`@glyph.set_default_font_set(...)` to drive deterministic
fixture-backed measurements without filesystem dependence.

### Snapshot harness

`scripts/snapshot.sh` requires `OOXML_FONT_DIR` to point at the
test font fixture cache populated by `scripts/setup-test-fonts.sh`.
Both the renderer and the reference office binary read the same test
inputs — without that, metrics drift between pipelines and RMSE
values become meaningless. This cache is a snapshot-test fixture,
not an OOXML-defined requirement or default.

## Spec-Driven Development

Real implementation is gated on running the `indexion-skills:indexion-sdd`
flow against ECMA-376 / OOXML by Codex. Do not implement parsers/builders
ad hoc — wait for the SDD pass to produce specs per chapter, then satisfy
them.
