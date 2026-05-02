# G1.1 SpreadsheetML Formula Tokenizer Design

## Package

The tokenizer lives in `src/ecma376/spreadsheet_ml/formula`. The package
imports only `@opc_errors`, preserving the phase boundary. It does not depend
on the G16 address parser; all cell references and defined names are captured
as raw `Reference(String)` tokens for the later parser/address phase.

## Token Model

`FormulaToken` mirrors §18.17.2 token categories: constants, operators, cell
references, function names, names, and punctuators. Names intentionally share
the `Reference(String)` token because §18.17.2.5 disambiguation needs parser
context.

`Token` carries a token kind plus byte offsets into the formula source.

## Scanner

The implementation is a single left-to-right scanner over ASCII formula
syntax using `String::code_unit_at` offsets.

- Number scanning accepts unsigned decimal and exponent forms required by
  §18.17.2.1 and computes the `Double` directly, avoiding an extra package
  dependency.
- String scanning consumes quoted strings and treats doubled `""` as a
  literal quote.
- Error scanning matches the eight spec literals exactly.
- Reference scanning captures A1-style fragments, `$` absolute markers,
  plain sheet qualifiers (`Sheet1!A1`), and quoted sheet qualifiers
  (`'Bob''s sheet'!A1`) as raw text.
- Function-name recognition is lexical: a reference-like identifier followed
  immediately by `(` is `FunctionName`; the left parenthesis remains its own
  `LParen` token.

Ranges use explicit colon tokenization:

```text
A1:B10 -> Reference("A1"), RangeColon, Reference("B10")
```

This keeps G1.1 simple and leaves range composition to the parser.

## Space Operator

The first scan consumes U+0020 while recording whether each token had leading
space. A post-pass inserts `SpaceOp` only when that consumed space separated
two reference-like tokens. Separator spaces around numbers, operators,
function arguments, and punctuators are ignored.

External workbook reference forms beyond the lexical fragments listed above
are rejected as `SchemaViolation` in this tokenizer phase instead of being
partially accepted without parser support.
