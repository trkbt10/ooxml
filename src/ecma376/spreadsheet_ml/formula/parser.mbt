///|
priv struct Parser {
  tokens : Array[Token]
  mut pos : Int
}

///|
fn Parser::new(tokens : Array[Token]) -> Parser {
  { tokens, pos: 0 }
}

///|
/// §18.17.2 — parse a token stream into a typed SpreadsheetML formula AST.
/// Raises SchemaViolation for grammar errors such as missing operands,
/// unbalanced delimiters, or unexpected tokens.
pub fn parse(
  tokens : Array[Token],
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let parser = Parser::new(tokens)
  let ast = parser.parse_expression(union_allowed=true)
  if !parser.is_eof() {
    parser.error("unexpected token after expression")
  }
  ast
}

///|
/// §18.17.2 — tokenize a SpreadsheetML formula string, then parse it into a
/// typed AST.
pub fn parse_formula(
  source : String,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  parse(tokenize(source))
}

///|
fn Parser::parse_expression(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  self.parse_comparison(union_allowed~)
}

///|
fn Parser::parse_comparison(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_concat(union_allowed~)
  while true {
    match self.peek_kind() {
      Some(Equal) => {
        self.advance()
        left = Binary(Eq, left, self.parse_concat(union_allowed~))
      }
      Some(NotEqual) => {
        self.advance()
        left = Binary(Neq, left, self.parse_concat(union_allowed~))
      }
      Some(Less) => {
        self.advance()
        left = Binary(Lt, left, self.parse_concat(union_allowed~))
      }
      Some(Greater) => {
        self.advance()
        left = Binary(Gt, left, self.parse_concat(union_allowed~))
      }
      Some(LessEqual) => {
        self.advance()
        left = Binary(Le, left, self.parse_concat(union_allowed~))
      }
      Some(GreaterEqual) => {
        self.advance()
        left = Binary(Ge, left, self.parse_concat(union_allowed~))
      }
      _ => return left
    }
  }
  left
}

///|
fn Parser::parse_concat(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_additive(union_allowed~)
  while self.peek_kind() is Some(Ampersand) {
    self.advance()
    left = Binary(Concat, left, self.parse_additive(union_allowed~))
  }
  left
}

///|
fn Parser::parse_additive(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_multiplicative(union_allowed~)
  while true {
    match self.peek_kind() {
      Some(Plus) => {
        self.advance()
        left = Binary(Add, left, self.parse_multiplicative(union_allowed~))
      }
      Some(Minus) => {
        self.advance()
        left = Binary(Sub, left, self.parse_multiplicative(union_allowed~))
      }
      _ => return left
    }
  }
  left
}

///|
fn Parser::parse_multiplicative(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_exponent(union_allowed~)
  while true {
    match self.peek_kind() {
      Some(Star) => {
        self.advance()
        left = Binary(Mul, left, self.parse_exponent(union_allowed~))
      }
      Some(Slash) => {
        self.advance()
        left = Binary(Div, left, self.parse_exponent(union_allowed~))
      }
      _ => return left
    }
  }
  left
}

///|
fn Parser::parse_exponent(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let left = self.parse_postfix(union_allowed~)
  if self.peek_kind() is Some(Caret) {
    self.advance()
    Binary(Pow, left, self.parse_exponent(union_allowed~))
  } else {
    left
  }
}

///|
fn Parser::parse_postfix(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut expr = self.parse_prefix(union_allowed~)
  while self.peek_kind() is Some(Percent) {
    self.advance()
    expr = Unary(PostfixPercent, expr)
  }
  expr
}

///|
fn Parser::parse_prefix(
  self : Parser,
  union_allowed~ : Bool,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(Plus) => {
      self.advance()
      Unary(PrefixPlus, self.parse_prefix(union_allowed~))
    }
    Some(Minus) => {
      self.advance()
      Unary(PrefixMinus, self.parse_prefix(union_allowed~))
    }
    _ =>
      if union_allowed {
        self.parse_union()
      } else {
        self.parse_intersection()
      }
  }
}

///|
fn Parser::parse_union(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_intersection()
  while self.peek_kind() is Some(Comma) {
    self.advance()
    left = Binary(Union, left, self.parse_intersection())
  }
  left
}

///|
fn Parser::parse_intersection(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_range()
  while self.peek_kind() is Some(SpaceOp) {
    self.advance()
    left = Binary(Intersect, left, self.parse_range())
  }
  left
}

///|
fn Parser::parse_range(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  let mut left = self.parse_primary()
  while self.peek_kind() is Some(RangeColon) {
    self.advance()
    left = Binary(Range, left, self.parse_primary())
  }
  left
}

///|
fn Parser::parse_primary(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(Number(value)) => {
      self.advance()
      Literal(LitNumber(value))
    }
    Some(StringConstant(value)) => {
      self.advance()
      Literal(LitString(value))
    }
    Some(Boolean(value)) => {
      self.advance()
      Literal(LitBool(value))
    }
    Some(ErrorConst(value)) => {
      self.advance()
      Literal(LitError(value))
    }
    Some(Reference(value)) => {
      self.advance()
      Reference(value)
    }
    Some(FunctionName(name)) => self.parse_function_call(name)
    Some(LParen) => self.parse_group()
    Some(LBrace) => self.parse_array_constant()
    Some(RParen) => self.error("unexpected right parenthesis")
    Some(RBrace) => self.error("unexpected right brace")
    Some(Comma) => self.error("unexpected comma")
    Some(Semicolon) => self.error("unexpected semicolon")
    Some(_) => self.error("expected expression operand")
    None => self.error("expected expression operand")
  }
}

///|
fn Parser::parse_group(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  self.expect_lparen()
  let expr = self.parse_expression(union_allowed=true)
  self.expect_rparen()
  expr
}

///|
fn Parser::parse_function_call(
  self : Parser,
  name : String,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  self.advance()
  self.expect_lparen()
  let args = Array::new()
  if self.peek_kind() is Some(RParen) {
    self.advance()
    return Function(name, args)
  }
  while true {
    args.push(self.parse_expression(union_allowed=false))
    match self.peek_kind() {
      Some(Comma) => self.advance()
      Some(RParen) => {
        self.advance()
        return Function(name, args)
      }
      _ => self.error("expected comma or right parenthesis in function call")
    }
  }
  Function(name, args)
}

///|
fn Parser::parse_array_constant(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  self.expect_lbrace()
  let rows = Array::new()
  let first_row = self.parse_array_row()
  let width = first_row.length()
  rows.push(first_row)
  while self.peek_kind() is Some(Semicolon) {
    self.advance()
    let row = self.parse_array_row()
    if row.length() != width {
      self.error("array constant rows must have equal length")
    }
    rows.push(row)
  }
  self.expect_rbrace()
  Array2D(rows)
}

///|
fn Parser::parse_array_row(
  self : Parser,
) -> Array[FormulaAst] raise @opc_errors.SchemaViolation {
  let row = Array::new()
  row.push(self.parse_array_constant_value())
  while self.peek_kind() is Some(Comma) {
    self.advance()
    row.push(self.parse_array_constant_value())
  }
  row
}

///|
fn Parser::parse_array_constant_value(
  self : Parser,
) -> FormulaAst raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(Number(value)) => {
      self.advance()
      Literal(LitNumber(value))
    }
    Some(StringConstant(value)) => {
      self.advance()
      Literal(LitString(value))
    }
    Some(Boolean(value)) => {
      self.advance()
      Literal(LitBool(value))
    }
    Some(ErrorConst(value)) => {
      self.advance()
      Literal(LitError(value))
    }
    Some(Plus) => {
      self.advance()
      match self.peek_kind() {
        Some(Number(value)) => {
          self.advance()
          Unary(PrefixPlus, Literal(LitNumber(value)))
        }
        _ => self.error("array constant sign must precede a number")
      }
    }
    Some(Minus) => {
      self.advance()
      match self.peek_kind() {
        Some(Number(value)) => {
          self.advance()
          Unary(PrefixMinus, Literal(LitNumber(value)))
        }
        _ => self.error("array constant sign must precede a number")
      }
    }
    Some(LBrace) => self.error("array constant cannot contain array constant")
    _ => self.error("array constant value must be a constant")
  }
}

///|
fn Parser::peek_kind(self : Parser) -> FormulaToken? {
  if self.pos < self.tokens.length() {
    Some(self.tokens[self.pos].kind)
  } else {
    None
  }
}

///|
fn Parser::advance(self : Parser) -> Unit {
  self.pos += 1
}

///|
fn Parser::is_eof(self : Parser) -> Bool {
  self.pos >= self.tokens.length()
}

///|
fn Parser::expect_lparen(
  self : Parser,
) -> Unit raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(LParen) => self.advance()
    _ => self.error("expected left parenthesis")
  }
}

///|
fn Parser::expect_rparen(
  self : Parser,
) -> Unit raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(RParen) => self.advance()
    _ => self.error("expected right parenthesis")
  }
}

///|
fn Parser::expect_lbrace(
  self : Parser,
) -> Unit raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(LBrace) => self.advance()
    _ => self.error("expected left brace")
  }
}

///|
fn Parser::expect_rbrace(
  self : Parser,
) -> Unit raise @opc_errors.SchemaViolation {
  match self.peek_kind() {
    Some(RBrace) => self.advance()
    _ => self.error("expected right brace")
  }
}

///|
fn[T] Parser::error(
  self : Parser,
  reason : String,
) -> T raise @opc_errors.SchemaViolation {
  let detail = if self.pos < self.tokens.length() {
    let token = self.tokens[self.pos]
    "\{reason} at token \{self.pos} (bytes \{token.start}..\{token.end})"
  } else {
    "\{reason} at end of formula"
  }
  formula_violation(formula_syntax_section, detail)
}
