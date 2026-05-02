///|
/// §18.17.2 — typed AST for SpreadsheetML formulas. The parser consumes
/// tokens from `tokenize` and constructs this tree.
pub(all) enum FormulaAst {
  /// §18.17.2.1 Constants.
  Literal(LiteralValue)
  /// §18.17.2.3 Cell references and §18.17.2.5 names, kept as raw lexemes.
  Reference(String)
  /// §18.17.2.4 Function call with positional arguments.
  Function(String, Array[FormulaAst])
  /// §18.17.2.2 Unary operator expression.
  Unary(UnaryOp, FormulaAst)
  /// §18.17.2.2 Binary operator expression.
  Binary(BinaryOp, FormulaAst, FormulaAst)
  /// §18.17.2.1 Array constant organized as rows and columns.
  Array2D(Array[Array[FormulaAst]])
} derive(Eq, Debug)

///|
/// §18.17.2.1 — literal formula constants.
pub(all) enum LiteralValue {
  LitNumber(Double)
  LitString(String)
  LitBool(Bool)
  LitError(String)
} derive(Eq, Debug)

///|
/// §18.17.2.2 — unary prefix and postfix operators.
pub(all) enum UnaryOp {
  PrefixPlus
  PrefixMinus
  PostfixPercent
} derive(Eq, Debug)

///|
/// §18.17.2.2 — binary arithmetic, text, comparison, and reference operators.
pub(all) enum BinaryOp {
  Add
  Sub
  Mul
  Div
  Pow
  Concat
  Eq
  Neq
  Lt
  Gt
  Le
  Ge
  Range
  Intersect
  Union
} derive(Eq, Debug)
