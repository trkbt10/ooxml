///|
fn eval_test_context() -> EvalContext {
  {
    current_sheet: "Sheet1",
    current_cell: try! @address.CellAddress::parse_a1("A1"),
    sst: None,
    date_system: @date_serial.DateSystem::Serial1900,
    registry: FunctionRegistry::new(),
    resolve_cell: fn(address) {
      match (address.col_zero_based, address.row_zero_based) {
        (0, 0) => VNumber(42.0)
        (1, 0) => VNumber(7.0)
        (0, 1) => VString("south")
        (1, 1) => VBool(true)
        _ => VEmpty
      }
    },
    resolve_name: fn(name) {
      match name {
        "NamedAnswer" => Some(Literal(LitNumber(99.0)))
        _ => None
      }
    },
  }
}

///|
fn assert_eval(source : String, expected : FormulaValue) -> Unit raise {
  assert_true(
    evaluate(try! parse_formula(source), eval_test_context()) == expected,
  )
}

///|
test "§18.17.2 evaluator literal constants" {
  assert_eval("1.5", VNumber(1.5))
  assert_eval("\"hi\"", VString("hi"))
  assert_eval("TRUE", VBool(true))
  assert_eval("#VALUE!", VError(Value))
}

///|
test "§18.17.2.2 evaluator arithmetic operators" {
  assert_eval("1+2", VNumber(3.0))
  assert_eval("10/0", VError(DivZero))
  assert_eval("2^10", VNumber(1024.0))
  assert_eval("\"5\"+3", VNumber(8.0))
  assert_eval("TRUE+1", VNumber(2.0))
}

///|
test "§18.17.2.2 evaluator concatenation operator" {
  assert_eval("\"a\"&\"b\"", VString("ab"))
  assert_eval("1&2", VString("12"))
  assert_eval("TRUE&\"x\"", VString("TRUEx"))
}

///|
test "§18.17.2.2 evaluator comparison operators" {
  assert_eval("1=1", VBool(true))
  assert_eval("\"a\"<\"b\"", VBool(true))
  assert_eval("1<\"a\"", VBool(true))
  assert_eval("TRUE>FALSE", VBool(true))
}

///|
test "§18.17.5 evaluator error propagation" {
  assert_eval("#REF!+1", VError(Ref))
  assert_eval("1/0+5", VError(DivZero))
}

///|
test "§18.17.2.3 evaluator resolves single cell reference" {
  assert_eval("A1", VNumber(42.0))
}

///|
test "§18.17.2.3 evaluator resolves range reference as array" {
  assert_eval(
    "A1:B2",
    VArray([[VNumber(42.0), VNumber(7.0)], [VString("south"), VBool(true)]]),
  )
}

///|
test "§18.17.2.4 evaluator dispatches eager function registry entries" {
  let ctx = eval_test_context()
  ctx.registry.register(
    "ADD",
    Eager(fn(args, _ctx) {
      match (args.get(0), args.get(1)) {
        (Some(VNumber(a)), Some(VNumber(b))) => VNumber(a + b)
        _ => VError(Value)
      }
    }),
  )
  assert_true(evaluate(try! parse_formula("ADD(1,2)"), ctx) == VNumber(3.0))
}

///|
test "§18.17.2.4 evaluator dispatches lazy function registry entries" {
  let ctx = eval_test_context()
  ctx.registry.register(
    "IFRAW",
    Lazy(fn(asts, fn_ctx) {
      match (asts.get(0), asts.get(1), asts.get(2)) {
        (Some(cond), Some(yes_ast), Some(no_ast)) =>
          match coerce_to_bool(evaluate(cond, fn_ctx)) {
            VBool(true) => evaluate(yes_ast, fn_ctx)
            VBool(false) => evaluate(no_ast, fn_ctx)
            VError(err) => VError(err)
            _ => VError(Value)
          }
        _ => VError(Value)
      }
    }),
  )
  assert_true(
    evaluate(try! parse_formula("IFRAW(TRUE,1,1/0)"), ctx) == VNumber(1.0),
  )
}

///|
test "§18.17.2.4 evaluator unknown function returns name error" {
  assert_eval("SOMETHING(1)", VError(Name))
}

///|
test "§18.17.2.5 evaluator resolves defined names" {
  assert_eval("NamedAnswer", VNumber(99.0))
}

///|
test "§18.17.4 evaluator numeric coercion" {
  assert_true(
    coerce_to_number(VString("3.14"), @date_serial.DateSystem::Serial1900) ==
    VNumber(3.14),
  )
  assert_true(
    coerce_to_number(VString("abc"), @date_serial.DateSystem::Serial1900) ==
    VError(Value),
  )
}

///|
test "§18.17.4 evaluator text coercion" {
  assert_true(coerce_to_text(VNumber(1.5)) == VString("1.5"))
  assert_true(coerce_to_text(VBool(true)) == VString("TRUE"))
}

///|
test "§18.17.4 evaluator logical coercion" {
  assert_true(coerce_to_bool(VNumber(0.0)) == VBool(false))
  assert_true(coerce_to_bool(VNumber(1.0)) == VBool(true))
  assert_true(coerce_to_bool(VString("TRUE")) == VBool(true))
}
