# G1 Formula E2E Requirements

## Scope

- Provide a SpreadsheetML §18.3 worksheet snapshot entry point for the §18.17 formula engine.
- Evaluate literal cells through the existing cell-value decoder and formula cells through tokenizer, parser, built-in function registry, and evaluator.
- Resolve shared formulas using the existing G1.9 shared-formula expansion.
- Resolve formula references recursively from the snapshot cell map with cycle detection.

## Non-Goals

- Array-formula result expansion is out of scope; single formula text evaluates normally.
- Defined names are out of scope and resolve as missing names.
- External workbook references are out of scope.
