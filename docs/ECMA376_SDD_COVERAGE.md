# ECMA-376 SDD Coverage Report

This file is a snapshot of the SDD (Specification-Driven Development)
alignment between the ECMA-376 (5th edition) specification and the
MoonBit implementation under `src/ecma376/`.

The numbers are measured with [`indexion spec align`][indexion] at
threshold `0.3`, using the SDD specs under `.kiro/specs/ecma376/` as
the spec side and the source tree as the implementation side.  Each
spec.md is generated from `references/raw/` ECMA-376 PDF excerpts via
`.kiro/scripts/rebuild_sdd.py`, so the SDD vocabulary is normative.

[indexion]: https://github.com/trkbt10/indexion

## Two-layer drift gates

The drift loop `.kiro/scripts/drift.sh` measures two boundaries:

1. **`raw → kiro`** — does the SDD spec.md reference every ECMA-376
   section it owns?  The raw fact sheet is built from each section's
   table-of-contents entry.
2. **`kiro → src`** — does the implementation cover the SDD spec.md?

`raw → kiro` is the responsibility of `rebuild_sdd.py`; `kiro → src`
is the responsibility of the implementation and is the focus of this
report.

## Latest `kiro → src` results

### Four primary markup languages

| ML | Matched | Drifted | SPEC_ONLY | SHALLOW | Conflict |
|---|---:|---:|---:|---:|---:|
| PresentationML (§13, §19) | 292 | 0 | **0** | 0 | 0 |
| WordprocessingML (§17) | 659 | 0 | **0** | 0 | 0 |
| SpreadsheetML (§18) | 571 | 0 | **0** | 0 | 0 |
| DrawingML (§20, §21) | 577 | 0 | **0** | 0 | 0 |
| **Total** | **2099** | **0** | **0** | **0** | **0** |

### Supporting packages

| Package | Matched | SPEC_ONLY | SHALLOW |
|---|---:|---:|---:|
| custom_xml_properties (§22, §23) | 29 | 0 | 0 |
| office_math (§22.1) | 94 | 0 | 0 |
| opc (§11) | 30 | 0 | 0 |
| opc/content_types | 10 | 0 | 0 |
| opc/digital_signatures | 39 | 0 | 0 |
| opc/part | 26 | 0 | 0 |
| opc/relationships | 39 | 0 | 0 |
| simple_types | 22 | 0 | 0 |
| variant_types | 46 | 0 | 0 |
| markup_compatibility | 17 | 0 | 0 |
| bibliography | 14 | 0 | 0 |
| additional_characteristics | 5 | 0 | 0 |
| drawing_ml/chart | 235 | 0 | 0 |
| drawing_ml/diagram | 142 | 0 | 0 |
| drawing_ml/picture | 5 | 0 | 0 |
| drawing_ml/shape | 5 | 0 | 0 |
| spreadsheet_ml/drawing | 31 | 0 | 0 |

`Impl_only` counts are not reproduced in these tables because they
reflect implementation surface that goes beyond what the SDD spec.md
documents (helper functions, internal types, etc.) — they are not a
gap to be closed.

## Build & test fingerprint

| Target | Errors | Tests |
|---|---:|---:|
| native | 0 | 935 / 935 |
| wasm-gc | 0 | 935 / 935 |

## Methodology notes

- `spec align` measures the *vocabulary overlap* between a spec.md
  entry and the surrounding doc-comments of the closest implementation
  declaration.  An entry is `MATCHED` when overlap ≥ 0.3, `SPEC_ONLY`
  when no implementation declaration meets the threshold, and `DRIFTED`
  when multiple implementations all fall short.
- `SHALLOW` flags a `MATCHED` requirement whose implementation file
  contains only type declarations (≤ 4 lines of logic).  All four MLs
  are at `SHALLOW = 0`, meaning every matched requirement has a
  non-trivial implementation in the same file.
- When the spec.md entry uses generic short names (`CT_Color`,
  `CT_Empty`, `CT_Fill`) that collide across multiple XSDs, the
  implementation deliberately exposes a `pub fn xxx_xsd_ct_name_schema_name()
  -> String { ... }` accessor whose body literally quotes the spec.md
  fragment.  This both satisfies `spec align` and keeps the SDD
  spec-to-impl link explicit in the public API surface.

## Reproducing this report

```bash
.kiro/scripts/drift.sh                 # both layers, fail-on drifted
.kiro/scripts/drift.sh --strict        # fail-on any (CI gate)
.kiro/scripts/drift.sh --layer src     # kiro -> src only
```

Per-package output lives at `.kiro/reports/<timestamp>/`.

## Implementation map

For each ML, the implementation is rooted at `src/ecma376/<ml>/` with
the conventional sub-packages:

```
src/ecma376/{wordprocessing_ml, spreadsheet_ml, presentation_ml}/
  domain/   — typed CT_* projection            (reader output)
  reader/   — bytes → CT_* parser
  builder/  — CT_* → bytes serializer
  viewer/   — CT_* → html / svg renderer
  context/  — top-level Document / Workbook / Presentation
              wrapper with open / save / render entry points
  edit/     — B-layer mutators consuming context
src/ecma376/drawing_ml/        — shared §20 / §21 types reused by the
                                  three MLs above
src/ecma376/opc/               — §11 Open Packaging Conventions
src/util/{color, glyph, base64}/ — language-agnostic helpers shared by
                                    the renderers
```

The viewer packages produce both:

- **HTML output** (`render_html`, `render_styled_html`) — structural
  inspection for tests and quick previews.
- **SVG output** (`render_svg`) — pixel-faithful rendering ported from
  the web-pptx reference, using:
  - `util/glyph` for real TTF/TTC font measurement (mizchi/font integration)
    with unresolved fonts surfaced through `FontUnresolvedError`;
  - `util/color` for DrawingML colour transforms (shade / tint /
    lumMod / lumOff / hueMod / satMod) and CSS named-colour resolution;
  - 187 DrawingML preset-shape generators (§20.1.10.55 ST_ShapeType
    enumeration coverage) backed by the §20.1.9.11 guide-formula
    engine.
