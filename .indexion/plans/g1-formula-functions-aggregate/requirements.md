# G1.5 Formula Functions Aggregate/Math Requirements

## Scope

Implement the first built-in SpreadsheetML formula function batch from ECMA-376 Part 1 §18.17.7 in `src/ecma376/spreadsheet_ml/formula/`.

## Requirements

- Add a public `register_builtin_functions(registry : FunctionRegistry)` entry point that registers only this phase's aggregate and basic math functions.
- Implement aggregate functions: `SUM`, `AVERAGE`, `COUNT`, `COUNTA`, `COUNTBLANK`, `MIN`, `MAX`, `PRODUCT`, and `SUMPRODUCT`.
- Implement math functions: `ABS`, `INT`, `ROUND`, `ROUNDUP`, `ROUNDDOWN`, `SQRT`, `POWER`, `MOD`, `SIGN`, `CEILING`, `FLOOR`, `EXP`, `LN`, `LOG`, `LOG10`, `PI`, `RAND`, and `TRUNC`.
- Preserve §18.17.7 scalar-vs-reference coercion rules: direct numeric text is accepted where the function reference says so, while numeric text/logical/empty values inside arrays and references are ignored by aggregate functions unless the function explicitly counts empties.
- Propagate formula errors, including errors nested in array/range arguments.
- Return SpreadsheetML error values for invalid arity, invalid numeric domains, mismatched `SUMPRODUCT` dimensions, and division-by-zero cases.
- Keep implementation package-local except for the registration entry point and do not add logical, text, lookup, datetime, financial, or statistical functions.
- Add white-box tests covering direct calls, registered formula evaluation, ranges, arrays, edge cases, and numeric-domain failures.

## Verification

- `moon check --target native`
- `moon test --target native`
- `bash .kiro/scripts/drift.sh --pkg ecma376/spreadsheet_ml --layer src --strict`
- `moon test --target native`
- `moon test --target wasm-gc`
- `moon test --target wasm`
- `moon test --target js`
- `bash .kiro/scripts/drift.sh --strict`
