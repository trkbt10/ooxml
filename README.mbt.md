# trkbt10/ooxml

Office Open XML (ECMA-376) implementation in [MoonBit](https://docs.moonbitlang.com).
Targets `.docx`, `.xlsx`, and `.pptx` files. Build outputs include native binaries
and a wasm-gc core for npm distribution.

## Architecture

The flow is

```
reader -> context -> (builder | viewer)
```

— each ML chapter (DrawingML, WordprocessingML, SpreadsheetML, PresentationML)
hosts its own self-contained pipeline. The format facades (`docx`, `xlsx`,
`pptx`) drive that pipeline; they are *not* re-exports.

```
src/
├── xml/                              W3C XML 1.0
├── zip/                              PKWARE ZIP
├── cfb/                              MS-CFB (legacy + embedded OLE)
│
├── ecma376/
│   ├── opc/                          Part 2: Open Packaging Conventions
│   │   ├── content_types/            §10.1.2 [Content_Types].xml
│   │   ├── part/                     §9.1.x PackagePart / PartName / PackUri
│   │   └── relationships/            §9.3   .rels
│   ├── markup_compatibility/         Part 3: mc:Ignorable, mc:AlternateContent
│   ├── simple_types/                 §22.9 Shared Simple Types
│   ├── variant_types/                §22.4 vt:
│   ├── custom_xml_properties/        §22.3
│   ├── bibliography/                 §22.6
│   ├── additional_characteristics/   §22.2
│   │
│   ├── drawing_ml/                   §20  DrawingML (self-contained chapter)
│   │   ├── color/                    §20.1.2 / §20.1.4
│   │   ├── font/                     §20.1.10.x
│   │   ├── theme/                    §20.1.6
│   │   ├── shape/                    §20.1.8
│   │   ├── picture/                  §20.1.2.2 pic
│   │   ├── chart/                    §21.2
│   │   ├── diagram/                  §21.4 + §22.7
│   │   └── viewer/                   standalone DrawingML renderer (SVG)
│   │
│   ├── office_math/                  §22.1 OMML
│   │   ├── domain/   reader/   builder/   viewer/
│   │
│   ├── wordprocessing_ml/            §17
│   │   ├── domain/   reader/   context/   builder/   viewer/
│   │
│   ├── spreadsheet_ml/               §18
│   │   ├── domain/   drawing/   reader/   context/   builder/   viewer/
│   │   (drawing/ holds §22.8 xdr: which is only used inside SpreadsheetML)
│   │
│   └── presentation_ml/              §19
│       ├── domain/   reader/   context/   builder/   viewer/
│
├── docx/                             Public facade: open / save / to_html
├── xlsx/                             Public facade
└── pptx/                             Public facade

src/cmd/                              build targets (kept under src/ because
│                                     moonbit's `source` is a single tree)
├── ooxml_cli/                        native CLI build target
├── docx_wasm/                        wasm-gc export bundle for .docx
├── xlsx_wasm/                        wasm-gc export bundle for .xlsx
└── pptx_wasm/                        wasm-gc export bundle for .pptx
```

### Why this layout

- **ML chapters are self-contained units.** Each ECMA-376 §17/§18/§19/§20
  chapter owns its `domain → reader → context → (builder | viewer)` pipeline
  inside its own directory. Cross-chapter dependencies flow only through
  `domain` types, never through internal stages.
- **Facades drive, they don't re-export.** `src/docx`, `src/xlsx`, `src/pptx`
  orchestrate `opc` + the relevant ML chapters: they expose `open(bytes)`,
  `save(...)`, `to_html(...)` etc., which actually run the pipeline.
- **`xml`, `zip`, `cfb` live outside `ecma376/`** because they are upstream
  standards (W3C, PKWARE, MS-CFB), not part of ECMA-376.
- **Build targets live under `cmd/`.** native CLI and per-format wasm bundles
  are sibling packages, symmetric and independently buildable.

## Build

```bash
moon check                          # all packages, default target
moon check --target native          # native build
moon check --target wasm-gc         # core wasm build (for npm bundle)
moon run src/cmd/ooxml_cli          # run the CLI
moon fmt && moon info               # format + regenerate .mbti
```

## Status

Skeleton only. Each package contains a `package_name()` placeholder; real
implementation is gated on the SDD (Spec-Driven Development) pass against
ECMA-376 / OOXML.
