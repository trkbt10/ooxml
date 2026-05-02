# G1 Formula Functions Logical Text Requirements

## Scope

Implement ECMA-376 Part 1 §18.17.7 logical, text, and information formula functions in `src/ecma376/spreadsheet_ml/formula/`.

## Requirements

- Register the new built-ins from `register_builtin_functions`.
- Logical branch functions use lazy dispatch where short-circuit semantics require unevaluated AST arguments.
- Text and information functions use eager dispatch and decide error propagation inside the function body.
- Keep implementation inside the SpreadsheetML formula package.
- Do not implement lookup, datetime, financial, or statistical families in this phase.
- Preserve ECMA-376 error values as `FormulaValue::VError`.
- Validate with native check, native test, all backend tests, and drift gates.

## Acceptance

- `IF`, `IFERROR`, `IFNA`, `AND`, and `OR` avoid evaluating unused branches.
- Text functions cover concatenation, slicing, casing, search, replacement, repetition, minimal `TEXT`, `VALUE`, `EXACT`, `CHAR`, and `CODE`.
- Information functions cover type predicates, `TYPE`, `NA`, `N`, and `T`.
- All new function doc comments cite §18.17.7 by function name.
