# G1.3 SpreadsheetML Formula Evaluator Design

## Package

The evaluator lives in `src/ecma376/spreadsheet_ml/formula`, beside the G1.1
tokenizer and G1.2 parser. The package imports `@address`, `@date_serial`,
`@domain`, `@hashmap`, `@math`, `@strconv`, and existing `@opc_errors`
support, but does not depend on docx, xlsx, or pptx facades.

## Values And Errors

`FormulaError` models the seven §18.17.5 error values plus `#GETTING_DATA`.
`FormulaValue` carries numbers, strings, booleans, errors, empty cells, and
2-D arrays. Shared-string indices are intentionally absent because callers
resolve cells into evaluator-ready values through `EvalContext.resolve_cell`.

## Context Boundary

`EvalContext` is the boundary between pure formula semantics and workbook
state. The evaluator receives:

- the current sheet and cell;
- optional shared string table;
- §18.17.4 date system;
- function registry;
- a cell resolver;
- a defined-name resolver.

This keeps the formula package reusable across the reader, builder, and future
viewer code without importing SpreadsheetML facade packages.

## Evaluation

`evaluate` pattern matches the AST:

- literals map directly to `FormulaValue`;
- references call `resolve_reference`;
- functions dispatch through `FunctionRegistry`;
- unary and binary operators apply §18.17.2.2 semantics;
- array constants evaluate each element into a 2-D `VArray`.

Errors are values, not exceptions. Operators return the first encountered
`VError` unless the operator itself produces a more specific error such as
`#DIV/0!`, `#NUM!`, or `#NULL!`.

## Function Registry

The registry is a mutable hashmap keyed by uppercased names. `Eager` functions
receive evaluated `FormulaValue` arguments. `Lazy` functions receive raw
`FormulaAst` arguments plus `EvalContext`, allowing later IF/AND/OR-style
short-circuit functions without evaluator changes. No built-ins are registered
in this phase.

## References

`resolve_reference` first parses the lexeme as an A1 cell or rectangular
range. Single cells return `ctx.resolve_cell(address)`. Rectangles materialize
as row-major arrays by calling the resolver for each cell. If parsing fails,
the lexeme is treated as a defined name; unresolved address-like lexemes map to
`#REF!`, and unresolved names map to `#NAME?`.

## Coercion

Numeric coercion maps booleans to 1/0, empty to 0, finite numeric text to
numbers, errors to themselves, and unsupported text/arrays to `#VALUE!`. Text
coercion maps booleans to `TRUE`/`FALSE`, errors to literals, empty to `""`,
and finite numbers to `Double::to_string()`. Logical coercion accepts numeric
zero/non-zero and case-insensitive `TRUE`/`FALSE` text.
