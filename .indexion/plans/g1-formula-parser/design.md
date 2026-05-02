# G1.2 SpreadsheetML Formula Parser Design

## Package

The parser lives in `src/ecma376/spreadsheet_ml/formula` beside the tokenizer.
The package still imports only `@opc_errors`; parser input is `Array[Token]`,
and `parse_formula` delegates to the existing tokenizer.

## AST

`FormulaAst` models the §18.17.2 expression categories:

- constants as `Literal(LiteralValue)`;
- cell references and names as `Reference(String)`;
- function calls as `Function(String, Array[FormulaAst])`;
- unary and binary operators as typed operator enums;
- array constants as `Array2D(Array[Array[FormulaAst]])`.

References stay raw to preserve the phase boundary. Address validation and
resolution belong to the evaluator phase.

## Parser

The implementation is a recursive-descent precedence parser with one method per
precedence level:

```text
comparison
concat
additive
multiplicative
exponent
postfix
prefix
union
intersection
range
primary
```

Most binary operators associate left-to-right. Exponentiation is parsed
right-associatively to match spreadsheet behavior and the G1.2 acceptance
case.

## Comma Disambiguation

The parser carries a `union_allowed` flag. Top-level expressions and grouped
expressions allow comma as the reference union operator. Function arguments and
array constant rows parse with union disabled so comma remains a punctuator
separator in those positions. This supports `SUM(A1,B1)` as two arguments and
`SUM((A1,B1))` as one union reference argument.

## Array Constants

`parse_array_constant` follows §18.17.2.1:

- braces delimit the array;
- semicolon separates rows;
- comma separates columns;
- values are constants only;
- nested array constants are rejected;
- all rows must have the same width;
- prefix `+` or `-` may immediately precede numerical constants.

## Errors

All parser failures raise `@opc_errors.SchemaViolation` with section
`Part 1 §18.17.2`, the formula path used by the tokenizer, and token position
metadata when available.
