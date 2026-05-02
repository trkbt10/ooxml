# G1.5 Formula Functions Aggregate/Math Design

## Integration

The evaluator already supports eager function dispatch through `FunctionRegistry`. This batch registers every function as `Eager`, because none of these functions need lazy or short-circuit AST evaluation.

## Value Handling

Aggregate helpers flatten `VArray` values row-major. Nested `VError` values are returned immediately. For aggregate numeric inclusion, helpers distinguish direct scalar arguments from cells/range elements:

- Direct scalar `VNumber` values are included.
- Direct scalar numeric text is included for functions whose §18.17.7 entry accepts text representations of numbers.
- Range/array elements include only `VNumber`.
- `VEmpty`, non-numeric text, and booleans are ignored for aggregate numeric scans.

Math functions use `coerce_to_number`, matching existing arithmetic operator behavior: empties become `0`, booleans become `1`/`0`, numeric text parses, and errors propagate.

## Rounding

`ROUND` implements §18.17.7.278 round-half-away-from-zero after scaling by `10^digits`. `ROUNDUP` rounds away from zero and `ROUNDDOWN`/`TRUNC` round toward zero. Negative digit counts use reciprocal scaling so positions left of the decimal point are handled by the same helper.

## Numeric Domains

Domain errors return FormulaValue errors rather than raising:

- `AVERAGE` with no numeric values returns `#DIV/0!`.
- `SQRT`, `LN`, `LOG`, and `LOG10` return `#NUM!` for invalid domains.
- `POWER` follows the existing `^` behavior and additionally returns `#DIV/0!` for `0^y` where `y <= 0`.
- `MOD` returns `#DIV/0!` for zero divisor.
- `CEILING` and `FLOOR` return `#NUM!` when value and significance have incompatible signs.
- `SUMPRODUCT` returns `#NUM!` for mismatched array dimensions.

## RAND

`RAND()` is deterministic for testability. It derives a stable fractional value from `EvalContext.current_cell`, so repeated evaluation of the same cell is stable while different cells can produce different values. The result is always in `[0, 1)`.
