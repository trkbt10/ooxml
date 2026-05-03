///|
fn shared_cell(value : String) -> @address.CellAddress {
  try! @address.CellAddress::parse_a1(value)
}

///|
fn assert_shared_text(
  master : String,
  source : String,
  dependent : String,
  expected : FormulaAst,
) -> Unit raise {
  assert_true(
    expand_shared_formula_text(
      shared_cell(master),
      source,
      shared_cell(dependent),
    ) ==
    expected,
  )
}

///|
test "§18.3.1.40 shared formula shifts relative cell references" {
  assert_shared_text(
    "A1",
    "A1+B1",
    "A2",
    Binary(Add, Reference("A2"), Reference("B2")),
  )
}

///|
test "§18.3.1.40 shared formula preserves absolute columns" {
  assert_shared_text(
    "A1",
    "$A1+B1",
    "A2",
    Binary(Add, Reference("$A2"), Reference("B2")),
  )
}

///|
test "§18.3.1.40 shared formula preserves absolute rows" {
  assert_shared_text(
    "A1",
    "A$1+B1",
    "A2",
    Binary(Add, Reference("A$1"), Reference("B2")),
  )
}

///|
test "§18.3.1.40 shared formula preserves fully absolute references" {
  assert_shared_text(
    "A1",
    "$A$1+B1",
    "A2",
    Binary(Add, Reference("$A$1"), Reference("B2")),
  )
}

///|
test "§18.3.1.40 shared formula shifts range endpoints" {
  assert_shared_text(
    "A1",
    "SUM(A1:A5)",
    "A2",
    Function("SUM", [Binary(Range, Reference("A2"), Reference("A6"))]),
  )
}

///|
test "§18.3.1.40 shared formula preserves absolute range endpoints" {
  assert_shared_text(
    "A1",
    "SUM($A$1:$A$5)",
    "A2",
    Function("SUM", [Binary(Range, Reference("$A$1"), Reference("$A$5"))]),
  )
}

///|
test "§18.3.1.40 shared formula leaves defined names unchanged" {
  assert_shared_text(
    "A1",
    "MyName+1",
    "A2",
    Binary(Add, Reference("MyName"), Literal(LitNumber(1.0))),
  )
}

///|
test "§18.3.1.40 shared formula preserves sheet qualifiers" {
  assert_shared_text(
    "A1",
    "Sheet2!A1+1",
    "A2",
    Binary(Add, Reference("Sheet2!A2"), Literal(LitNumber(1.0))),
  )
}

///|
test "§18.3.1.40 shared formula shifts function arguments" {
  assert_shared_text(
    "A1",
    "IF(A1>0,B1,C1)",
    "A2",
    Function("IF", [
      Binary(Gt, Reference("A2"), Literal(LitNumber(0.0))),
      Reference("B2"),
      Reference("C2"),
    ]),
  )
}

///|
test "§18.3.1.40 shared formula shifts nested subtrees" {
  assert_shared_text(
    "A1",
    "SUM(A1:A5)+IF(B1=0,1,2)",
    "A3",
    Binary(
      Add,
      Function("SUM", [Binary(Range, Reference("A3"), Reference("A7"))]),
      Function("IF", [
        Binary(Eq, Reference("B3"), Literal(LitNumber(0.0))),
        Literal(LitNumber(1.0)),
        Literal(LitNumber(2.0)),
      ]),
    ),
  )
}

///|
test "§18.3.1.40 shared formula text expands and evaluates" {
  let ast = expand_shared_formula_text(
    shared_cell("A1"),
    "A1&B1",
    shared_cell("A2"),
  )
  assert_true(ast == Binary(Concat, Reference("A2"), Reference("B2")))
  let ctx = eval_test_context()
  assert_true(evaluate(ast, ctx) == VString("southTRUE"))
}

///|
test "§18.3.1.40 shared formula supports multi-axis offsets" {
  assert_true(
    expand_shared_formula(
      shared_cell("C5"),
      try! parse_formula("A1+B$2+$C3"),
      shared_cell("D7"),
    ) ==
    Binary(
      Add,
      Binary(Add, Reference("B3"), Reference("C$2")),
      Reference("$C5"),
    ),
  )
}

///|
test "§18.3.1.40 shared formula shifts raw range reference lexemes" {
  assert_true(shift_ast(Reference("A1:A5"), 1, 0) == Reference("A2:A6"))
}

///|
test "§18.3.1.40 shared formula shifts array constant references" {
  assert_true(
    shift_ast(Array2D([[Reference("A1"), Reference("$B1")]]), 2, 1) ==
    Array2D([[Reference("B3"), Reference("$B3")]]),
  )
}
