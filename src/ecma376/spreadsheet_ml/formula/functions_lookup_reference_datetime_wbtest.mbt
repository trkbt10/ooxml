///|
fn g17_test_context() -> EvalContext {
  let registry = FunctionRegistry::new()
  register_builtin_functions(registry)
  {
    current_sheet: "Sheet1",
    current_cell: try! @address.CellAddress::parse_a1("C5"),
    sst: None,
    date_system: @date_serial.DateSystem::Serial1900,
    registry,
    resolve_cell: fn(address) {
      match (address.sheet, address.col_zero_based, address.row_zero_based) {
        (Some("Sheet2"), 1, 1) => VNumber(222.0)
        (_, 0, 0) => VNumber(11.0)
        (_, 1, 0) => VNumber(12.0)
        (_, 2, 0) => VNumber(13.0)
        (_, 0, 1) => VNumber(21.0)
        (_, 1, 1) => VNumber(22.0)
        (_, 2, 1) => VNumber(23.0)
        (_, 0, 2) => VNumber(31.0)
        (_, 1, 2) => VNumber(32.0)
        (_, 2, 2) => VNumber(33.0)
        _ => VEmpty
      }
    },
    resolve_name: fn(_) { None },
  }
}

///|
fn g17_eval(source : String) -> FormulaValue {
  evaluate(try! parse_formula(source), g17_test_context())
}

///|
fn g17_assert_eval(source : String, expected : FormulaValue) -> Unit raise {
  assert_true(g17_eval(source) == expected)
}

///|
fn g17_assert_close(source : String, expected : Double) -> Unit raise {
  match g17_eval(source) {
    VNumber(actual) => assert_true((actual - expected).abs() < 0.000000001)
    _ => assert_true(false)
  }
}

///|
fn g17_serial(year : Int, month : Int, day : Int) -> Double {
  try! @date_serial.date_time_to_serial(
    { year, month, day, hour: 0, minute: 0, second: 0, millisecond: 0 },
    @date_serial.DateSystem::Serial1900,
  )
}

///|
test "§18.17.7 lookup VLOOKUP HLOOKUP and LOOKUP" {
  g17_assert_eval("VLOOKUP(2,{1,\"a\";2,\"b\";3,\"c\"},2,FALSE)", VString("b"))
  g17_assert_eval("VLOOKUP(2.5,{1,10;2,20;3,30},2,TRUE)", VNumber(20.0))
  g17_assert_eval(
    "HLOOKUP(\"q\",{\"p\",\"q\",\"r\";10,20,30},2,FALSE)",
    VNumber(20.0),
  )
  g17_assert_eval("HLOOKUP(2.5,{1,2,3;10,20,30},2,TRUE)", VNumber(20.0))
  g17_assert_eval("LOOKUP(2.5,{1,2,3},{10,20,30})", VNumber(20.0))
  g17_assert_eval("LOOKUP(0,{1,2,3},{10,20,30})", VError(NotApplicable))
}

///|
test "§18.17.7 lookup MATCH INDEX and CHOOSE" {
  g17_assert_eval("MATCH(\"b\",{\"a\",\"b\",\"c\"},0)", VNumber(2.0))
  g17_assert_eval("MATCH(2.5,{1,2,3},1)", VNumber(2.0))
  g17_assert_eval("MATCH(2.5,{3,2,1},-1)", VNumber(1.0))
  g17_assert_eval("INDEX({1,2;3,4},2,1)", VNumber(3.0))
  g17_assert_eval(
    "INDEX({1,2;3,4},0,2)",
    VArray([[VNumber(2.0)], [VNumber(4.0)]]),
  )
  g17_assert_eval("CHOOSE(2,\"a\",\"b\",\"c\")", VString("b"))
  g17_assert_eval("CHOOSE(4,\"a\",\"b\",\"c\")", VError(Value))
}

///|
test "§18.17.7 lookup OFFSET and INDIRECT" {
  g17_assert_eval("OFFSET(A1,1,1)", VNumber(22.0))
  g17_assert_eval(
    "OFFSET(C3,-2,-2,2,2)",
    VArray([[VNumber(11.0), VNumber(12.0)], [VNumber(21.0), VNumber(22.0)]]),
  )
  g17_assert_eval("INDIRECT(\"A1\")", VNumber(11.0))
  g17_assert_eval("INDIRECT(\"Sheet2!B2\")", VNumber(222.0))
  g17_assert_eval("INDIRECT(\"bad\")", VError(Ref))
}

///|
test "§18.17.7 reference ROW COLUMN ROWS COLUMNS ADDRESS AREAS" {
  g17_assert_eval("ROW()", VNumber(5.0))
  g17_assert_eval("COLUMN()", VNumber(3.0))
  g17_assert_eval("ROW(B2)", VNumber(2.0))
  g17_assert_eval("COLUMN(B2)", VNumber(2.0))
  g17_assert_eval("ROWS(A1:B3)", VNumber(3.0))
  g17_assert_eval("COLUMNS(A1:B3)", VNumber(2.0))
  g17_assert_eval("ADDRESS(2,3)", VString("$C$2"))
  g17_assert_eval("ADDRESS(2,3,4,TRUE,\"Sheet 1\")", VString("'Sheet 1'!C2"))
  g17_assert_eval("AREAS(A1:B2)", VNumber(1.0))
}

///|
test "§18.17.7 datetime DATE TIME field extraction and WEEKDAY" {
  let serial = g17_serial(2024, 12, 31)
  g17_assert_eval("DATE(2024,12,31)", VNumber(serial))
  g17_assert_eval("YEAR(DATE(2024,12,31))", VNumber(2024.0))
  g17_assert_eval("MONTH(DATE(2024,12,31))", VNumber(12.0))
  g17_assert_eval("DAY(DATE(2024,12,31))", VNumber(31.0))
  g17_assert_close("TIME(12,30,45)", 0.5213541666666667)
  g17_assert_eval("HOUR(TIME(12,30,45))", VNumber(12.0))
  g17_assert_eval("MINUTE(TIME(12,30,45))", VNumber(30.0))
  g17_assert_eval("SECOND(TIME(12,30,45))", VNumber(45.0))
  g17_assert_eval("WEEKDAY(DATE(2024,12,31),1)", VNumber(3.0))
  g17_assert_eval("WEEKDAY(DATE(2024,12,31),2)", VNumber(2.0))
  g17_assert_eval("WEEKDAY(DATE(2024,12,31),3)", VNumber(1.0))
}

///|
test "§18.17.7 datetime NOW TODAY parsing and date arithmetic" {
  g17_assert_eval("NOW()", VNumber(0.0))
  g17_assert_eval("TODAY()", VNumber(0.0))
  g17_assert_eval(
    "DATEVALUE(\"2024-12-31\")",
    VNumber(g17_serial(2024, 12, 31)),
  )
  g17_assert_eval("DATEVALUE(\"not-a-date\")", VError(Value))
  g17_assert_eval("TIMEVALUE(\"12:00:00\")", VNumber(0.5))
  g17_assert_eval("DAYS(DATE(2024,12,31),DATE(2024,12,1))", VNumber(30.0))
  g17_assert_eval("EDATE(DATE(2024,1,31),1)", VNumber(g17_serial(2024, 2, 29)))
  g17_assert_eval(
    "EOMONTH(DATE(2024,1,15),1)",
    VNumber(g17_serial(2024, 2, 29)),
  )
}

///|
test "§18.17.7.VLOOKUP exact match" {
  g17_assert_eval("VLOOKUP(3,{1,10;2,20;3,30},2,FALSE)", VNumber(30.0))
}

///|
test "§18.17.7.VLOOKUP approximate match" {
  g17_assert_eval("VLOOKUP(2.7,{1,10;2,20;3,30},2)", VNumber(20.0))
}

///|
test "§18.17.7.HLOOKUP exact match" {
  g17_assert_eval("HLOOKUP(3,{1,2,3;10,20,30},2,FALSE)", VNumber(30.0))
}

///|
test "§18.17.7.HLOOKUP approximate match" {
  g17_assert_eval("HLOOKUP(2.7,{1,2,3;10,20,30},2)", VNumber(20.0))
}

///|
test "§18.17.7.LOOKUP paired vector" {
  g17_assert_eval("LOOKUP(3,{1,2,3},{10,20,30})", VNumber(30.0))
}

///|
test "§18.17.7.MATCH exact position" {
  g17_assert_eval("MATCH(22,B1:B3,0)", VNumber(2.0))
}

///|
test "§18.17.7.MATCH ascending approximate position" {
  g17_assert_eval("MATCH(23,{10,20,30},1)", VNumber(2.0))
}

///|
test "§18.17.7.MATCH descending approximate position" {
  g17_assert_eval("MATCH(23,{30,20,10},-1)", VNumber(1.0))
}

///|
test "§18.17.7.INDEX scalar access" {
  g17_assert_eval("INDEX(A1:C3,3,2)", VNumber(32.0))
}

///|
test "§18.17.7.INDEX whole column access" {
  g17_assert_eval(
    "INDEX(A1:C3,0,1)",
    VArray([[VNumber(11.0)], [VNumber(21.0)], [VNumber(31.0)]]),
  )
}

///|
test "§18.17.7.CHOOSE selected value" {
  g17_assert_eval("CHOOSE(1,10,20,30)", VNumber(10.0))
}

///|
test "§18.17.7.CHOOSE range error" {
  g17_assert_eval("CHOOSE(0,10,20,30)", VError(Value))
}

///|
test "§18.17.7.OFFSET positive shift" {
  g17_assert_eval("OFFSET(A1,2,2)", VNumber(33.0))
}

///|
test "§18.17.7.OFFSET sized range" {
  g17_assert_eval(
    "OFFSET(B2,-1,-1,2,2)",
    VArray([[VNumber(11.0), VNumber(12.0)], [VNumber(21.0), VNumber(22.0)]]),
  )
}

///|
test "§18.17.7.INDIRECT A1 reference" {
  g17_assert_eval("INDIRECT(\"B2\")", VNumber(22.0))
}

///|
test "§18.17.7.INDIRECT rejects bad text" {
  g17_assert_eval("INDIRECT(\"not ref\")", VError(Ref))
}

///|
test "§18.17.7.ROW current cell" {
  g17_assert_eval("ROW()", VNumber(5.0))
}

///|
test "§18.17.7.COLUMN current cell" {
  g17_assert_eval("COLUMN()", VNumber(3.0))
}

///|
test "§18.17.7.ROWS array height" {
  g17_assert_eval("ROWS({1,2;3,4;5,6})", VNumber(3.0))
}

///|
test "§18.17.7.COLUMNS array width" {
  g17_assert_eval("COLUMNS({1,2,3;4,5,6})", VNumber(3.0))
}

///|
test "§18.17.7.ADDRESS absolute A1" {
  g17_assert_eval("ADDRESS(10,27,1)", VString("$AA$10"))
}

///|
test "§18.17.7.DATE serial" {
  g17_assert_eval("DATE(2025,1,15)", VNumber(g17_serial(2025, 1, 15)))
}

///|
test "§18.17.7.TIME fraction" {
  g17_assert_eval("TIME(6,0,0)", VNumber(0.25))
}

///|
test "§18.17.7.DATEVALUE ISO date" {
  g17_assert_eval("DATEVALUE(\"2025-01-15\")", VNumber(g17_serial(2025, 1, 15)))
}

///|
test "§18.17.7.TIMEVALUE clock text" {
  g17_assert_eval("TIMEVALUE(\"06:00:00\")", VNumber(0.25))
}

///|
test "§18.17.7.EDATE month end clamp" {
  g17_assert_eval("EDATE(DATE(2023,1,31),1)", VNumber(g17_serial(2023, 2, 28)))
}

///|
test "§18.17.7.EOMONTH month end" {
  g17_assert_eval("EOMONTH(DATE(2023,2,1),0)", VNumber(g17_serial(2023, 2, 28)))
}
