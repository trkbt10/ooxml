# G1.9 Shared Formula Expander Requirements

## Scope

Implement SpreadsheetML shared formula expansion for `f` elements with
`t="shared"` and `si` per ECMA-376 Part 1 §18.3.1.40. This sub-phase only
materializes a dependent formula AST by shifting references from the master
formula's base cell to the dependent cell.

## Functional Requirements

1. `shift_ast(ast, delta_row, delta_col)` shall walk a `FormulaAst` and return
   a new AST with every cell or range reference shifted by the supplied offset.
2. Shifting shall respect §18.18.7 absolute markers: absolute columns do not
   shift by `delta_col`, and absolute rows do not shift by `delta_row`.
3. Range references shall shift both endpoints while preserving sheet
   qualifiers.
4. Defined names shall not be shifted.
5. `expand_shared_formula(master_address, master_ast, dependent_address)` shall
   compute `(dependent.row - master.row, dependent.col - master.col)` and call
   `shift_ast`.
6. `expand_shared_formula_text(master_address, master_formula,
   dependent_address)` shall parse the master formula text and expand it,
   raising `SchemaViolation` only when parsing the master formula fails.

## Non-Goals

- No formula evaluation is added here.
- No array formula or data table expansion is added here.
- No worksheet XML integration is added here; G1.10 owns e2e integration.

## Gates

- `bash .kiro/scripts/drift.sh --pkg ecma376/spreadsheet_ml --layer src --strict`
- `moon test --target native`
- `moon test --target wasm-gc`
- `moon test --target wasm`
- `moon test --target js`
