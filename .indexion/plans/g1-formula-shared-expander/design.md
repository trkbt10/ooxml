# G1.9 Shared Formula Expander Design

## Public API

The formula package exposes three functions:

- `shift_ast` recursively transforms `FormulaAst`.
- `expand_shared_formula` computes the dependent offset from master and
  dependent `CellAddress` values.
- `expand_shared_formula_text` combines `parse_formula` and
  `expand_shared_formula`.

Each public doc comment cites §18.3.1.40 and §18.18.7 to keep the SDD anchors
visible in generated interfaces.

## Reference Handling

`Reference(lexeme)` is interpreted in this order:

1. Try `CellAddress::parse_a1`.
2. If the lexeme contains `:`, try `CellRange::parse_a1`.
3. If neither parse succeeds, leave the lexeme unchanged as a defined name or
   another unsupported formula symbol.

Parsed references are shifted per-axis only when that axis is not absolute.
Formatting is package-local so shifted out-of-bounds coordinates can still be
emitted as reference-like lexemes; evaluation remains responsible for turning
invalid references into `VError(Ref)`.

## AST Walk

The transformer copies literals unchanged and recursively maps:

- function arguments
- unary operands
- binary operands, including range/intersection/union operators
- array-constant cells

No evaluation context is required, making the expander deterministic and pure.
