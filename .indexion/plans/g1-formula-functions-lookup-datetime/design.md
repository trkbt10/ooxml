# G1.7 Design

## Function Placement

The implementation is split into focused files in the existing formula package:

- `functions_lookup.mbt` for lookup and selection functions.
- `functions_reference.mbt` for reference metadata and address functions.
- `functions_datetime.mbt` for serial date and time functions.

The package already imports `@address` and `@date_serial`, so no package boundary changes are needed.

## Reference Handling

Most functions are eager and consume evaluated `FormulaValue` arguments. A few functions need the original reference text because evaluated ranges are materialized as `VArray` without origin metadata. `OFFSET`, `ROW(reference)`, and `COLUMN(reference)` therefore use lazy dispatch so they can inspect a reference AST and then use the same address parsing and `ctx.resolve_cell` path as normal formula references.

`INDIRECT` parses text as A1 by default or R1C1 when `a1=FALSE`, then resolves the cell through `ctx.resolve_cell`. Invalid text returns `#REF!`.

## Date And Time

Datetime functions convert through `@date_serial.serial_to_date_time` and `@date_serial.date_time_to_serial` using `EvalContext.date_system`.

`NOW()` and `TODAY()` intentionally return serial `0` in the active date system. This deterministic default keeps formula evaluation reproducible across targets and tests. A future context extension can add caller-provided clock behavior without changing existing deterministic tests.

`DATEVALUE` accepts ISO `YYYY-MM-DD`. `TIMEVALUE` accepts `HH:MM:SS`.
