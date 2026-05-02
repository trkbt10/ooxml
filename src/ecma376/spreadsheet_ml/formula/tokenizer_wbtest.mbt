///|
fn assert_tokens(source : String, expected : Array[FormulaToken]) -> Unit raise {
  let tokens = try! tokenize(source)
  assert_true(tokens.map(fn(token) { token.kind }) == expected)
}

///|
fn assert_token_spans(source : String, expected : Array[Token]) -> Unit raise {
  assert_true((try! tokenize(source)) == expected)
}

///|
fn assert_tokenize_error(source : String) -> Unit raise {
  assert_true((try? tokenize(source)) is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "§18.17.2 empty formula tokenizes to empty stream" {
  assert_tokens("", [])
}

///|
test "§18.17.2.1 numeric constants" {
  assert_tokens("1", [Number(1.0)])
  assert_tokens("1.5", [Number(1.5)])
  assert_tokens(".5", [Number(0.5)])
  assert_tokens("1.", [Number(1.0)])
  assert_tokens("1e10", [Number(10000000000.0)])
  assert_tokens("1.5e-3", [Number(0.0015)])
  assert_tokens("1.5E+3", [Number(1500.0)])
}

///|
test "§18.17.2.1 string constants" {
  assert_tokens("\"hello\"", [StringConstant("hello")])
  assert_tokens("\"a\"\"b\"", [StringConstant("a\"b")])
}

///|
test "§18.17.2.1 boolean constants are case-insensitive" {
  assert_tokens("TRUE", [Boolean(true)])
  assert_tokens("false", [Boolean(false)])
}

///|
test "§18.17.2.1 error constants" {
  assert_tokens("#N/A", [ErrorConst("#N/A")])
  assert_tokens("#REF!", [ErrorConst("#REF!")])
  assert_tokens("#DIV/0!", [ErrorConst("#DIV/0!")])
  assert_tokens("#VALUE!", [ErrorConst("#VALUE!")])
  assert_tokens("#NAME?", [ErrorConst("#NAME?")])
  assert_tokens("#NULL!", [ErrorConst("#NULL!")])
  assert_tokens("#NUM!", [ErrorConst("#NUM!")])
  assert_tokens("#GETTING_DATA", [ErrorConst("#GETTING_DATA")])
}

///|
test "§18.17.2.2 operators" {
  assert_tokens("+", [Plus])
  assert_tokens("-", [Minus])
  assert_tokens("*", [Star])
  assert_tokens("/", [Slash])
  assert_tokens("^", [Caret])
  assert_tokens("&", [Ampersand])
  assert_tokens("=", [Equal])
  assert_tokens("<>", [NotEqual])
  assert_tokens("<", [Less])
  assert_tokens(">", [Greater])
  assert_tokens("<=", [LessEqual])
  assert_tokens(">=", [GreaterEqual])
  assert_tokens("%", [Percent])
}

///|
test "§18.17.2.3 cell references and names are captured as references" {
  assert_tokens("A1", [Reference("A1")])
  assert_tokens("$A$1", [Reference("$A$1")])
  assert_tokens("Sheet1!B2", [Reference("Sheet1!B2")])
  assert_tokens("'Bob''s sheet'!A1", [Reference("'Bob''s sheet'!A1")])
  assert_tokens("A1:B10", [Reference("A1"), RangeColon, Reference("B10")])
  assert_tokens("MyName", [Reference("MyName")])
}

///|
test "§18.17.2.4 function call name requires immediate left parenthesis" {
  assert_tokens("SUM(A1,B2)", [
    FunctionName("SUM"),
    LParen,
    Reference("A1"),
    Comma,
    Reference("B2"),
    RParen,
  ])
  assert_tokens("SUM (A1)", [Reference("SUM"), LParen, Reference("A1"), RParen])
}

///|
test "§18.17.2 formula token sequences leave precedence to parser" {
  assert_tokens("IF(A1>0,1,-1)", [
    FunctionName("IF"),
    LParen,
    Reference("A1"),
    Greater,
    Number(0.0),
    Comma,
    Number(1.0),
    Comma,
    Minus,
    Number(1.0),
    RParen,
  ])
  assert_tokens("1+2*3", [Number(1.0), Plus, Number(2.0), Star, Number(3.0)])
  assert_tokens("(1+2)", [LParen, Number(1.0), Plus, Number(2.0), RParen])
}

///|
test "§18.17.2 punctuators include array-constant delimiters" {
  assert_tokens("{1,2;3,4}", [
    LBrace,
    Number(1.0),
    Comma,
    Number(2.0),
    Semicolon,
    Number(3.0),
    Comma,
    Number(4.0),
    RBrace,
  ])
}

///|
test "§18.17.2.2 U+0020 becomes intersection only between references" {
  assert_tokens("A1:A10 B1:B10", [
    Reference("A1"),
    RangeColon,
    Reference("A10"),
    SpaceOp,
    Reference("B1"),
    RangeColon,
    Reference("B10"),
  ])
  assert_tokens("  1  +  2  ", [Number(1.0), Plus, Number(2.0)])
}

///|
test "§18.17.2 token spans use byte offsets" {
  assert_token_spans(" A1 B2", [
    { kind: Reference("A1"), start: 1, end: 3 },
    { kind: SpaceOp, start: 3, end: 4 },
    { kind: Reference("B2"), start: 4, end: 6 },
  ])
}

///|
test "§18.17.2 malformed lexical input raises SchemaViolation" {
  assert_tokenize_error("\"abc")
  assert_tokenize_error("1.2.3")
  assert_tokenize_error("@")
  assert_tokenize_error("#BAD!")
  assert_tokenize_error("'Sheet'!")
}
