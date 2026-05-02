///|
fn assert_parse(source : String, expected : FormulaAst) -> Unit raise {
  assert_true((try! parse_formula(source)) == expected)
}

///|
fn assert_parse_error(source : String) -> Unit raise {
  assert_true(
    (try? parse_formula(source)) is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
fn n(value : Double) -> FormulaAst {
  Literal(LitNumber(value))
}

///|
fn s(value : String) -> FormulaAst {
  Literal(LitString(value))
}

///|
fn b(value : Bool) -> FormulaAst {
  Literal(LitBool(value))
}

///|
fn e(value : String) -> FormulaAst {
  Literal(LitError(value))
}

///|
fn r(value : String) -> FormulaAst {
  Reference(value)
}

///|
test "§18.17.2.1 parser literal constants" {
  assert_parse("1", n(1.0))
  assert_parse("\"hello\"", s("hello"))
  assert_parse("TRUE", b(true))
  assert_parse("#N/A", e("#N/A"))
}

///|
test "§18.17.2.3 parser references and names stay raw" {
  assert_parse("A1", r("A1"))
  assert_parse("$A$1", r("$A$1"))
  assert_parse("Sheet1!B2", r("Sheet1!B2"))
  assert_parse("'Bob''s'!$D$5", r("'Bob''s'!$D$5"))
}

///|
test "§18.17.2.2 parser range operator has highest precedence" {
  assert_parse("A1:B10", Binary(Range, r("A1"), r("B10")))
}

///|
test "§18.17.2.4 parser function calls" {
  assert_parse("NOW()", Function("NOW", []))
  assert_parse("ABS(A1)", Function("ABS", [r("A1")]))
  assert_parse(
    "IF(A1>0,1,-1)",
    Function("IF", [
      Binary(Gt, r("A1"), n(0.0)),
      n(1.0),
      Unary(PrefixMinus, n(1.0)),
    ]),
  )
  assert_parse(
    "SUM(A1,IF(B1,2,3))",
    Function("SUM", [r("A1"), Function("IF", [r("B1"), n(2.0), n(3.0)])]),
  )
}

///|
test "§18.17.2.2 parser arithmetic precedence" {
  assert_parse("1+2*3", Binary(Add, n(1.0), Binary(Mul, n(2.0), n(3.0))))
  assert_parse("2^3^2", Binary(Pow, n(2.0), Binary(Pow, n(3.0), n(2.0))))
  assert_parse("(1+2)*3", Binary(Mul, Binary(Add, n(1.0), n(2.0)), n(3.0)))
}

///|
test "§18.17.2.2 parser unary and postfix operators" {
  assert_parse("-A1", Unary(PrefixMinus, r("A1")))
  assert_parse("+A1", Unary(PrefixPlus, r("A1")))
  assert_parse("A1%", Unary(PostfixPercent, r("A1")))
}

///|
test "§18.17.2.2 parser text and comparison operators" {
  assert_parse("\"a\"&\"b\"", Binary(Concat, s("a"), s("b")))
  assert_parse("A1=B1", Binary(Eq, r("A1"), r("B1")))
  assert_parse("A1<>B1", Binary(Neq, r("A1"), r("B1")))
  assert_parse("A1<=B1", Binary(Le, r("A1"), r("B1")))
  assert_parse("A1>=B1", Binary(Ge, r("A1"), r("B1")))
}

///|
test "§18.17.2.1 parser array constant is two dimensional" {
  assert_parse("{1,2;3,4}", Array2D([[n(1.0), n(2.0)], [n(3.0), n(4.0)]]))
  assert_parse(
    "{-1,+2}",
    Array2D([[Unary(PrefixMinus, n(1.0)), Unary(PrefixPlus, n(2.0))]]),
  )
}

///|
test "§18.17.2.2 parser reference intersection and union operators" {
  assert_parse(
    "A1:A10 B1:B10",
    Binary(
      Intersect,
      Binary(Range, r("A1"), r("A10")),
      Binary(Range, r("B1"), r("B10")),
    ),
  )
  assert_parse(
    "(A1:A2,B1:B2)",
    Binary(
      Union,
      Binary(Range, r("A1"), r("A2")),
      Binary(Range, r("B1"), r("B2")),
    ),
  )
}

///|
test "§18.17.2 parser rejects grammar errors" {
  assert_parse_error("1+")
  assert_parse_error("(1+2")
  assert_parse_error("SUM(")
  assert_parse_error("1)")
  assert_parse_error("1 1")
}

///|
test "§18.17.2.1 parser rejects invalid array constants" {
  assert_parse_error("{1;2,3}")
  assert_parse_error("{A1}")
  assert_parse_error("{{1}}")
}

///|
test "§18.17.2 parse_formula tokenizes then parses" {
  assert_parse(
    "SUM(A1:A10)+B1",
    Binary(Add, Function("SUM", [Binary(Range, r("A1"), r("A10"))]), r("B1")),
  )
}
