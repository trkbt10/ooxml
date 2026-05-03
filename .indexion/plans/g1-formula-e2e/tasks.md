# G1 Formula E2E Tasks

- Add `WorksheetSnapshot` and worksheet/cell map population helpers.
- Convert literal `CellValue` results into `FormulaValue`.
- Build `EvalContext` with recursive cell resolution and no defined-name resolver.
- Resolve normal, array-as-normal, and shared formula cells.
- Add XML fixture tests for literals, ranges, SST, chains, conditionals, lookup,
  dates, shared formulas, cycles, empty cells, errors, sheet evaluation, and a
  composite worksheet formula.
- Run native, wasm-gc, wasm, and js tests plus drift gates before committing.
