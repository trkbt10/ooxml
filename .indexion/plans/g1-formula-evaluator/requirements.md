# G1.3 SpreadsheetML Formula Evaluator Requirements

## Scope

Implement ECMA-376 Part 1 §18.17 formula evaluation over the existing G1.2
`FormulaAst`. This phase adds value/error types, scalar coercion, reference
resolution, tree walking, and an empty function registry skeleton only.

## Requirements

- Add the public `FormulaError` and `FormulaValue` types for §18.17.5 errors
  and §18.17.2 evaluated results.
- Add `EvalContext` to carry current sheet/cell, SST, date system, function
  registry, cell lookup, and defined-name lookup.
- Add `FunctionRegistry` and `FunctionDef` with eager and lazy function forms.
  The registry must start empty and be filled by callers.
- Implement `evaluate(ast, ctx)` as a non-raising tree walk that returns
  `VError` for formula failures.
- Implement arithmetic, concatenation, comparison, range, intersection, and
  union semantics for §18.17.2.2 operators.
- Implement `coerce_to_number`, `coerce_to_text`, and `coerce_to_bool` for
  implicit conversion used by formula operators and later functions.
- Implement `resolve_reference` using `@address` A1 parsing and caller-provided
  `ctx.resolve_cell`, with defined-name fallback through `ctx.resolve_name`.
- Add white-box coverage for literals, arithmetic, coercion, comparison, error
  propagation, references/ranges, eager/lazy registry dispatch, unknown
  functions, and defined names.

## Verification

- Run native check/test and strict SpreadsheetML drift gate.
- Run `moon info && moon fmt` and review generated interface drift.
- Run `moon test` on native, wasm-gc, wasm, and js.
- Run final strict drift gate before commit.
