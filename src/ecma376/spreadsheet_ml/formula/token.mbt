///|
/// §18.17.2 token categories for SpreadsheetML formulas: constants,
/// operators, cell references, function names, names, and punctuators.
pub(all) enum FormulaToken {
  Number(Double)
  StringConstant(String)
  Boolean(Bool)
  ErrorConst(String)
  Plus
  Minus
  Star
  Slash
  Caret
  Ampersand
  Equal
  NotEqual
  Less
  Greater
  LessEqual
  GreaterEqual
  Percent
  RangeColon
  SpaceOp
  Comma
  Reference(String)
  FunctionName(String)
  LParen
  RParen
  LBrace
  RBrace
  Semicolon
} derive(Eq, Debug)

///|
/// §18.17.2 formula token with byte offsets into the source formula string.
pub(all) struct Token {
  kind : FormulaToken
  start : Int
  end : Int
} derive(Eq, Debug)
