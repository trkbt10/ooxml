# G9 WordprocessingML Style Inheritance Requirements

## Scope

Implement a WordprocessingML §17.7 style inheritance resolver that consumes a
`CT_Styles`/`<w:styles>` table and exposes typed style metadata plus effective
property resolution for paragraph and run callers.

## Functional Requirements

- Extract `styleId`, `type`, `default`, `name`, `basedOn`, `next`, and
  `link`/`linkedTo` pointers from each `<w:style>`.
- Preserve direct property containers as raw XML elements for `pPr`, `rPr`,
  `tblPr`, `trPr`, and `tcPr`.
- Extract `docDefaults` paragraph/run properties as the implicit base for all
  styles.
- Resolve `basedOn` chains from most-derived style toward the root, stopping at
  missing parents and breaking cycles by visiting each style id at most once.
- Merge properties from defaults/base styles outward to the most-derived style.
- Resolve paragraph direct formatting by reading `pStyle` and overlaying the
  direct `pPr` on top of inherited style formatting.
- Resolve run direct formatting by reading `rStyle` and overlaying the direct
  `rPr` on top of inherited style formatting.

## Non-Goals

- Numbering inheritance resolution is out of scope for G9.
- Full ECMA-376 additive merge semantics for nested collections are out of
  scope for this phase.
- Existing `CT_Style` and `CT_Styles` wrapper shapes must not change.

## Gates

- `bash .kiro/scripts/drift.sh --pkg ecma376/wordprocessing_ml --layer src --strict`
- `moon test --target native`
- `moon test --target wasm-gc`
- `moon test --target wasm`
- `moon test --target js`
