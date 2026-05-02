# G5 Cell Coercion Requirements

## Scope

Implement semantic SpreadsheetML cell value decoding for `CT_Cell` according to ECMA-376 Part 1 §18.18.11 `ST_CellType` and §18.3.1.4 `c (Cell)`.

## Requirements

- Decode all seven `ST_CellType` discriminator values: `b`, `d`, `e`, `inlineStr`, `n`, `s`, and `str`.
- Treat missing `@t` with a present `<v>` as numeric `n`.
- Treat missing `@t` and no `<v>` as a distinct empty cell.
- Resolve `@t="s"` through `CT_Sst::lookup` only when an SST is supplied; otherwise preserve the shared string index.
- Raise `@opc_errors.SchemaViolation` for unknown `@t`, missing required payloads, malformed booleans, dates, errors, numbers, or indices, and out-of-range SST lookups.
- Parse `@t="d"` values as XSD-like `dateTime` lexical forms `YYYY-MM-DDTHH:MM:SS[.fff][Z]`, rejecting numeric timezone offsets.
- Provide display-text and numeric coercion helpers for downstream formula, filter, formatting, and pivot code.

