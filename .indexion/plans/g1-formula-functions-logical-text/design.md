# G1 Formula Functions Logical Text Design

## Package Boundary

All code lives in `src/ecma376/spreadsheet_ml/formula/`, matching the existing G1.5 aggregate and math function modules.

## Dispatch

The existing `FunctionDef` enum supplies `Eager` and `Lazy` function shapes. Logical functions that need short-circuiting register as `Lazy` and call `evaluate` only for selected arguments. `NOT`, `XOR`, `TRUE`, and `FALSE` register as `Eager`.

Eager dispatch evaluates all arguments and passes `VError` values through to the function implementation. This is required for information functions such as `ISERROR`, `ISNA`, `ISERR`, and `TYPE` to observe errors as values.

## Text Helpers

Text functions use local scalar coercion helpers over `coerce_to_text`, flatten ranges only for `CONCAT`, and reject multi-cell arrays for `CONCATENATE`. Search uses direct substring matching for `FIND` and recursive wildcard matching for `SEARCH`.

`TEXT` intentionally implements only the required formats: `0`, `0.00`, `#,##0`, `0%`, and `yyyy-mm-dd`. Unsupported formats fall back to text coercion.

## Info Helpers

Information functions inspect `FormulaValue::first_scalar` except `TYPE`, which returns array type code `64` for array values. `N` propagates errors and maps non-numeric text/empty values to zero.
