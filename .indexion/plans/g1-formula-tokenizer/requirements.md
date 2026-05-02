# G1.1 SpreadsheetML Formula Tokenizer Requirements

## Scope

Implement ECMA-376 Part 1 §18.17.2 formula tokenization for SpreadsheetML.
This phase emits tokens only. Parser, AST, address parsing, evaluator, and
function-library behavior are out of scope.

## Requirements

- Add a self-contained `src/ecma376/spreadsheet_ml/formula` package importing
  only `trkbt10/ooxml/ecma376/opc/errors` as `@opc_errors`.
- Provide `FormulaToken` variants for constants, operators, references,
  function names, and punctuators named by §18.17.2.
- Provide `Token { kind, start, end }` with byte offsets into the source.
- Implement `tokenize(source)` raising `@opc_errors.SchemaViolation` for
  malformed numeric literals, unterminated strings, malformed reference
  fragments, unknown error constants, and unknown characters.
- Parse unsigned number constants. Leading `+` and `-` are separate operator
  tokens.
- Parse string constants with doubled quote escaping.
- Emit `TRUE` and `FALSE` as booleans case-insensitively.
- Recognize the eight §18.17.2.1 error constants exactly.
- Emit `RangeColon` separately so the parser can compose range references.
- Emit `FunctionName` only when the reference-like name is immediately
  followed by `(` with no intervening U+0020.
- Consume U+0020 as separator whitespace, then insert `SpaceOp` only when it
  separated adjacent reference-like tokens.

## Verification

- Add white-box tests for constants, operators, references, function calls,
  punctuators, whitespace/intersection behavior, spans, and invalid input.
- Run native check/test and strict SpreadsheetML drift gate.
- Run `moon test` on native, wasm-gc, wasm, and js.
- Run final strict drift gate.
