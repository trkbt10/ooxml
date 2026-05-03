# G7 SpreadsheetML AutoFilter Evaluation Requirements

- Implement ECMA-376 Part 1 §18.3.2 AutoFilter row visibility in `src/ecma376/spreadsheet_ml/autofilter/`.
- Expose typed `AutoFilter`, `FilterColumn`, rule enums, and row APIs over `@formula.FormulaValue` rows.
- Parse a typed `AutoFilter` from an OOXML `autoFilter` XML element.
- Evaluate literal filters, date group filters, custom operators with `*` and `?` wildcards, deterministic dynamic date filters, average filters, Top10 filters, and documented Color/Icon stubs.
- Preserve chapter layering inside SpreadsheetML and avoid edits to `.kiro/specs/ecma376/` or existing `_wbtest.mbt` fixture bodies.
- Pass drift checks and `moon test` on native, wasm-gc, wasm, and js.
