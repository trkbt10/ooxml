///|
fn builtin_test_context() -> EvalContext {
  let registry = FunctionRegistry::new()
  register_builtin_functions(registry)
  {
    current_sheet: "Sheet1",
    current_cell: try! @address.CellAddress::parse_a1("A1"),
    sst: None,
    date_system: @date_serial.DateSystem::Serial1900,
    registry,
    resolve_cell: fn(address) {
      match (address.col_zero_based, address.row_zero_based) {
        (0, 0) => VNumber(1.0)
        (0, 1) => VNumber(2.0)
        (0, 2) => VEmpty
        (0, 3) => VNumber(4.0)
        (1, 0) => VNumber(10.0)
        (1, 1) => VString("x")
        (1, 2) => VBool(true)
        (1, 3) => VNumber(40.0)
        _ => VEmpty
      }
    },
    resolve_name: fn(_) { None },
    resolve_pivot_data: no_pivot_data,
  }
}

///|
fn assert_builtin_eval(source : String, expected : FormulaValue) -> Unit raise {
  let actual = evaluate(try! parse_formula(source), builtin_test_context())
  assert_true(actual == expected)
}

///|
fn assert_builtin_close(source : String, expected : Double) -> Unit raise {
  match evaluate(try! parse_formula(source), builtin_test_context()) {
    VNumber(actual) => assert_true((actual - expected).abs() < 0.000000001)
    _ => assert_true(false)
  }
}

///|
test "§18.17.7 aggregate SUM and AVERAGE" {
  assert_builtin_eval("SUM(1,2,3)", VNumber(6.0))
  assert_builtin_eval("SUM(\"3\",4)", VNumber(7.0))
  assert_builtin_eval("SUM(A1:A4)", VNumber(7.0))
  assert_builtin_eval("SUM(#DIV/0!,1)", VError(DivZero))
  assert_builtin_eval("AVERAGE()", VError(DivZero))
  assert_builtin_eval("AVERAGE(2,4,6)", VNumber(4.0))
  assert_builtin_eval("AVERAGE({1,\"2\",TRUE,4})", VNumber(2.5))
  assert_builtin_eval("AVERAGE(A1:A4)", VNumber(7.0 / 3.0))
}

///|
test "§18.17.7 aggregate counting functions" {
  assert_builtin_eval("COUNT(1,\"x\",TRUE,A3,2)", VNumber(2.0))
  assert_builtin_eval("COUNT({1,2,3},6,\"7\")", VNumber(5.0))
  assert_builtin_eval("COUNTA(1,\"x\",TRUE,A3,2)", VNumber(4.0))
  assert_builtin_eval("COUNTA(A1:B3)", VNumber(5.0))
  assert_builtin_eval("COUNTBLANK(A1:A4)", VNumber(1.0))
  assert_builtin_eval("COUNTBLANK(\"\")", VNumber(1.0))
}

///|
test "§18.17.7 aggregate MIN MAX PRODUCT and SUMPRODUCT" {
  assert_builtin_eval("MIN()", VNumber(0.0))
  assert_builtin_eval("MIN(3,1,2)", VNumber(1.0))
  assert_builtin_eval("MIN({\"ABC\",TRUE})", VNumber(0.0))
  assert_builtin_eval("MAX()", VNumber(0.0))
  assert_builtin_eval("MAX(3,1,2)", VNumber(3.0))
  assert_builtin_eval("MAX({\"ABC\",TRUE})", VNumber(0.0))
  assert_builtin_eval("PRODUCT(2,3,4)", VNumber(24.0))
  assert_builtin_eval("PRODUCT({2,3},4,\"5\")", VNumber(120.0))
  assert_builtin_eval("PRODUCT(\"x\")", VNumber(0.0))
  assert_builtin_eval("SUMPRODUCT({1,2},{3,4})", VNumber(11.0))
  assert_builtin_eval("SUMPRODUCT({2,3},{4,5},{2,2})", VNumber(46.0))
  assert_builtin_eval("SUMPRODUCT({2,3;4,5},{2,2;3,4})", VNumber(42.0))
  assert_builtin_eval("SUMPRODUCT({1,2},{3;4})", VError(Num))
}

///|
test "§18.17.7 SUBTOTAL dispatches population stdev and variance codes" {
  let sample = "{2,4,4,4,5,5,7,9}"
  assert_builtin_close("SUBTOTAL(1," + sample + ")", 5.0)
  assert_builtin_close("SUBTOTAL(9," + sample + ")", 40.0)
  assert_builtin_close("SUBTOTAL(8," + sample + ")", 2.0)
  assert_builtin_close("SUBTOTAL(108," + sample + ")", 2.0)
  assert_builtin_close("SUBTOTAL(11," + sample + ")", 4.0)
  assert_builtin_close("SUBTOTAL(111," + sample + ")", 4.0)
}

///|
test "§18.17.7 math ABS INT TRUNC and rounding" {
  assert_builtin_eval("ABS(-5)", VNumber(5.0))
  assert_builtin_eval("INT(3.7)", VNumber(3.0))
  assert_builtin_eval("INT(-3.7)", VNumber(-4.0))
  assert_builtin_close("TRUNC(3.71,1)", 3.7)
  assert_builtin_eval("TRUNC(-3.71,0)", VNumber(-3.0))
  assert_builtin_eval("ROUND(2.5,0)", VNumber(3.0))
  assert_builtin_eval("ROUND(2.45,1)", VNumber(2.5))
  assert_builtin_eval("ROUND(-1.475,2)", VNumber(-1.48))
  assert_builtin_eval("ROUND(21.5,-1)", VNumber(20.0))
  assert_builtin_eval("ROUNDUP(2.1,0)", VNumber(3.0))
  assert_builtin_eval("ROUNDDOWN(2.9,0)", VNumber(2.0))
}

///|
test "§18.17.7 math powers roots and remainders" {
  assert_builtin_eval("SQRT(9)", VNumber(3.0))
  assert_builtin_eval("SQRT(-1)", VError(Num))
  assert_builtin_eval("POWER(2,10)", VNumber(1024.0))
  assert_builtin_eval("POWER(0,0)", VError(DivZero))
  assert_builtin_eval("POWER(-2,0.5)", VError(Num))
  assert_builtin_eval("MOD(10,3)", VNumber(1.0))
  assert_builtin_eval("MOD(10,0)", VError(DivZero))
  assert_builtin_eval("MOD(-3,2)", VNumber(1.0))
  assert_builtin_eval("MOD(3,-2)", VNumber(-1.0))
}

///|
test "§18.17.7 math sign multiple log pi and rand" {
  assert_builtin_eval("SIGN(-3)", VNumber(-1.0))
  assert_builtin_eval("SIGN(0)", VNumber(0.0))
  assert_builtin_eval("SIGN(5)", VNumber(1.0))
  assert_builtin_eval("CEILING(7.3,0.5)", VNumber(7.5))
  assert_builtin_eval("FLOOR(7.3,0.5)", VNumber(7.0))
  assert_builtin_eval("CEILING(4.3,-2)", VError(Num))
  assert_builtin_eval("FLOOR(-4.3,2)", VError(Num))
  assert_builtin_eval("EXP(0)", VNumber(1.0))
  assert_builtin_close("EXP(1)", 2.718281828459045)
  assert_builtin_eval("LN(1)", VNumber(0.0))
  assert_builtin_eval("LN(-1)", VError(Num))
  assert_builtin_close("LOG(100,10)", 2.0)
  assert_builtin_close("LOG(100)", 2.0)
  assert_builtin_eval("LOG(100,1)", VError(Num))
  assert_builtin_eval("LOG10(100)", VNumber(2.0))
  assert_builtin_close("PI()", 3.14159265358979)
  match evaluate(try! parse_formula("RAND()"), builtin_test_context()) {
    VNumber(n) => assert_true(n >= 0.0 && n < 1.0)
    _ => assert_true(false)
  }
}

///|
test "§18.17.7 registered builtins evaluate ranges end to end" {
  assert_builtin_eval("SUM(A1:A4)", VNumber(7.0))
  assert_builtin_eval("SUM(B1:B4)", VNumber(50.0))
}
