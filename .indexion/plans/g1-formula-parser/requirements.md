# G1.2 SpreadsheetML Formula Parser Requirements

## Scope

Implement ECMA-376 Part 1 §18.17.2 formula parsing for SpreadsheetML. This
phase consumes the G1.1 `@formula.tokenize` token stream and emits a typed AST
only. Evaluation, address resolution, function dispatch, and implicit
intersection semantics are out of scope.

## Requirements

- Add `FormulaAst`, `LiteralValue`, `UnaryOp`, and `BinaryOp` to
  `src/ecma376/spreadsheet_ml/formula`.
- Provide `parse(tokens)` raising `@opc_errors.SchemaViolation` for grammar
  errors: missing operands, unexpected tokens, unbalanced delimiters, malformed
  function calls, and malformed array constants.
- Provide `parse_formula(source)` as tokenize-then-parse convenience API.
- Preserve cell references and defined names as raw `String` values. Do not
  depend on `@address`.
- Implement §18.17.2.2 precedence from highest to lowest:
  range, intersection, union, prefix sign, postfix percent, exponentiation,
  multiplication/division, addition/subtraction, text concatenation, comparison.
- Treat comma as a function argument separator in function argument position and
  as the union operator elsewhere.
- Parse array constants as 2-D rows with semicolon row separators and comma
  column separators. Enforce constants only, no nested arrays, and equal row
  width. Signed numeric constants are allowed.
- Add white-box tests for literals, references, function calls, precedence,
  unary/postfix operators, array constants, union/intersection, parser errors,
  and end-to-end tokenize-then-parse behavior.

## Verification

- Run native check/test and strict SpreadsheetML drift gate.
- Run `moon test` on native, wasm-gc, wasm, and js.
- Run final strict drift gate before commit.
