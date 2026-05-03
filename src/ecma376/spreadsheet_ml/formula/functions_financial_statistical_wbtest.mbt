///|
fn assert_builtin_near(
  source : String,
  expected : Double,
  tolerance : Double,
) -> Unit raise {
  match evaluate(try! parse_formula(source), builtin_test_context()) {
    VNumber(actual) => assert_true((actual - expected).abs() < tolerance)
    _ => assert_true(false)
  }
}

///|
test "§18.17.7 financial TVM payment family" {
  assert_builtin_near("PMT(0.05/12,360,-100000)", 536.8216230121, 0.000001)
  assert_builtin_near("PV(0.05/12,360,536.8216230121)", -100000.0, 0.01)
  assert_builtin_near("FV(0.05/12,360,-536.8216230121,100000)", 0.0, 0.01)
  assert_builtin_near("NPER(0.05/12,536.8216230121,-100000)", 360.0, 0.001)
  assert_builtin_near(
    "RATE(360,536.8216230121,-100000)",
    0.05 / 12.0,
    0.0000001,
  )
  assert_builtin_eval("PMT(0,0,100)", VError(Num))
  assert_builtin_eval("PV(0,10,-100,0,2)", VError(Num))
  assert_builtin_eval("FV(0,10,-100,0,2)", VError(Num))
  assert_builtin_eval("NPER(0,0,100)", VError(Num))
  assert_builtin_eval("RATE(0,1,-1)", VError(Num))
}

///|
test "§18.17.7 financial cash-flow and payment split functions" {
  assert_builtin_near("NPV(0.1,-1000,500,600)", -45.0788880541, 0.000001)
  assert_builtin_near("IRR({-1000,500,600,700})", 0.3387497097, 0.000001)
  assert_builtin_near(
    "MIRR({-1000,500,600,700},0.1,0.12)", 0.2597530380, 0.000001,
  )
  assert_builtin_near("IPMT(0.05/12,1,360,100000)", -416.6666666667, 0.000001)
  assert_builtin_near("PPMT(0.05/12,1,360,100000)", -120.1549563454, 0.000001)
  assert_builtin_near(
    "CUMIPMT(0.05/12,360,100000,1,12,0)", -4966.4941305782, 0.000001,
  )
  assert_builtin_near(
    "CUMPRINC(0.05/12,360,100000,1,12,0)", -1475.3653455675, 0.000001,
  )
  assert_builtin_eval("IRR({100,200})", VError(Num))
  assert_builtin_eval("MIRR({100,200},0.1,0.1)", VError(Num))
  assert_builtin_eval("CUMIPMT(0,10,100,1,2,0)", VError(Num))
  assert_builtin_eval("CUMPRINC(0.1,10,100,2,1,0)", VError(Num))
}

///|
test "§18.17.7 financial depreciation and interest conversion" {
  assert_builtin_eval("SLN(10000,1000,9)", VNumber(1000.0))
  assert_builtin_near("SYD(10000,1000,9,1)", 1800.0, 0.000001)
  assert_builtin_near("DB(1000000,100000,6,1)", 319000.0, 0.000001)
  assert_builtin_near("DDB(10000,1000,5,1)", 4000.0, 0.000001)
  assert_builtin_near("EFFECT(0.12,12)", 0.1268250301, 0.000001)
  assert_builtin_near("NOMINAL(EFFECT(0.12,12),12)", 0.12, 0.000001)
  assert_builtin_eval("SLN(1,0,0)", VError(DivZero))
  assert_builtin_eval("SYD(1,0,0,1)", VError(Num))
  assert_builtin_eval("DB(0,0,1,1)", VError(Num))
  assert_builtin_eval("DDB(1,0,0,1)", VError(Num))
  assert_builtin_eval("EFFECT(0,12)", VError(Num))
  assert_builtin_eval("NOMINAL(0,12)", VError(Num))
}

///|
test "§18.17.7 statistical dispersion and position functions" {
  assert_builtin_near("STDEV({2,4,4,4,5,5,7,9})", 2.1380899353, 0.000001)
  assert_builtin_near("STDEV.P({2,4,4,4,5,5,7,9})", 2.0, 0.000001)
  assert_builtin_near("VAR({2,4,4,4,5,5,7,9})", 4.5714285714, 0.000001)
  assert_builtin_near("VAR.P({2,4,4,4,5,5,7,9})", 4.0, 0.000001)
  assert_builtin_eval("MEDIAN({1,2,3,4})", VNumber(2.5))
  assert_builtin_eval("MEDIAN({1,2,3})", VNumber(2.0))
  assert_builtin_eval("MODE({1,2,2,3})", VNumber(2.0))
  assert_builtin_eval("STDEV(1)", VError(DivZero))
  assert_builtin_eval("STDEVP()", VError(DivZero))
  assert_builtin_eval("MODE({1,2,3})", VError(NotApplicable))
}

///|
test "§18.17.7 statistical percentile rank and kth functions" {
  assert_builtin_eval("PERCENTILE({1,2,3,4,5},0.5)", VNumber(3.0))
  assert_builtin_eval("PERCENTILE.EXC({1,2,3,4,5},0.5)", VNumber(3.0))
  assert_builtin_eval("QUARTILE({1,2,3,4,5},1)", VNumber(2.0))
  assert_builtin_eval("QUARTILE.EXC({1,2,3,4,5},2)", VNumber(3.0))
  assert_builtin_eval("RANK(3,{1,2,3,4},0)", VNumber(2.0))
  assert_builtin_eval("RANK(3,{1,2,3,4},1)", VNumber(3.0))
  assert_builtin_eval("RANK.AVG(3,{1,2,3,3,4},0)", VNumber(2.5))
  assert_builtin_eval("LARGE({1,2,3,4},2)", VNumber(3.0))
  assert_builtin_eval("SMALL({1,2,3,4},2)", VNumber(2.0))
  assert_builtin_eval("PERCENTILE({1,2},2)", VError(Num))
  assert_builtin_eval("QUARTILE({1,2},5)", VError(Num))
  assert_builtin_eval("RANK(5,{1,2,3})", VError(NotApplicable))
  assert_builtin_eval("LARGE({1,2},0)", VError(Num))
  assert_builtin_eval("SMALL({1,2},3)", VError(Num))
}

///|
test "§18.17.7 statistical paired regression and means" {
  assert_builtin_near("CORREL({1,2,3},{2,4,6})", 1.0, 0.000001)
  assert_builtin_near("COVAR({1,2,3},{2,4,6})", 1.3333333333, 0.000001)
  assert_builtin_near("COVARIANCE.S({1,2,3},{2,4,6})", 2.0, 0.000001)
  assert_builtin_near("SLOPE({2,4,6},{1,2,3})", 2.0, 0.000001)
  assert_builtin_near("INTERCEPT({3,5,7},{1,2,3})", 1.0, 0.000001)
  assert_builtin_near("FORECAST(4,{2,4,6},{1,2,3})", 8.0, 0.000001)
  assert_builtin_eval("TREND({2,4,6},{1,2,3},{4})", VNumber(8.0))
  assert_builtin_near("GROWTH({2,4,8},{1,2,3},{4})", 16.0, 0.000001)
  assert_builtin_near("GEOMEAN(2,8)", 4.0, 0.000001)
  assert_builtin_near("HARMEAN(2,4)", 2.6666666667, 0.000001)
  assert_builtin_near("AVEDEV(1,2,3)", 0.6666666667, 0.000001)
  assert_builtin_eval("DEVSQ(1,2,3)", VNumber(2.0))
  assert_builtin_eval("CORREL({1},{2})", VError(DivZero))
  assert_builtin_eval("COVARIANCE.S({1},{2})", VError(DivZero))
  assert_builtin_eval("SLOPE({1,2},{1,1})", VError(DivZero))
  assert_builtin_eval("GEOMEAN(-1,2)", VError(Num))
  assert_builtin_eval("HARMEAN(0,2)", VError(Num))
}

///|
test "§18.17.7 statistical conditional aggregates" {
  assert_builtin_eval("SUMIF({1,6,7},\">5\")", VNumber(13.0))
  assert_builtin_eval("SUMIF({1,6,7},\">5\",{10,20,30})", VNumber(50.0))
  assert_builtin_eval("COUNTIF({\"x\",\"y\",\"x\"},\"x\")", VNumber(2.0))
  assert_builtin_eval("COUNTIF({1,2,3},\"<>2\")", VNumber(2.0))
  assert_builtin_eval("AVERAGEIF({1,6,7},\">5\")", VNumber(6.5))
  assert_builtin_eval(
    "SUMIFS({10,20,30},{1,2,3},\">1\",{\"a\",\"b\",\"b\"},\"b\")",
    VNumber(50.0),
  )
  assert_builtin_eval(
    "COUNTIFS({1,2,3},\">1\",{\"a\",\"b\",\"b\"},\"b\")",
    VNumber(2.0),
  )
  assert_builtin_eval(
    "AVERAGEIFS({10,20,30},{1,2,3},\">1\",{\"a\",\"b\",\"b\"},\"b\")",
    VNumber(25.0),
  )
  assert_builtin_eval("SUMIF({1,2},\">1\",{10})", VError(Value))
  assert_builtin_eval("AVERAGEIF({1,2},\">5\")", VError(DivZero))
}
