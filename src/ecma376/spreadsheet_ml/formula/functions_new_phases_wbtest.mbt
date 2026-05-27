// Phase 2-9 function result verification tests.
// Every expected value is cross-checked with Excel/LibreOffice.

///|
test "§18.17.7 GAMMALN" {
  // Excel: GAMMALN(5) = ln(4!) = ln(24) ≈ 3.178054
  assert_builtin_near("GAMMALN(5)", 3.1780538303479458, 1.0e-6)
  // GAMMALN(1) = ln(0!) = ln(1) = 0
  assert_builtin_near("GAMMALN(1)", 0.0, 1.0e-10)
  assert_builtin_eval("GAMMALN(0)", VError(Num))
}

///|
test "§18.17.7 ERF/ERFC" {
  // Excel: ERF(1) ≈ 0.84270079295
  assert_builtin_near("ERF(1)", 0.8427007929497149, 1.0e-6)
  assert_builtin_near("ERF(0)", 0.0, 1.0e-10)
  // ERFC(0) = 1
  assert_builtin_near("ERFC(0)", 1.0, 1.0e-10)
  assert_builtin_near("ERFC(1)", 0.1572992070502851, 1.0e-6)
}

///|
test "§18.17.7 NORMSDIST/NORMSINV" {
  // Excel: NORMSDIST(0) = 0.5
  assert_builtin_near("NORMSDIST(0)", 0.5, 1.0e-10)
  // Excel: NORMSDIST(1.96) ≈ 0.975
  assert_builtin_near("NORMSDIST(1.96)", 0.9750021048517796, 1.0e-5)
  // Excel: NORMSINV(0.975) ≈ 1.96
  assert_builtin_near("NORMSINV(0.975)", 1.959963984540054, 1.0e-4)
  assert_builtin_near("NORMSINV(0.5)", 0.0, 1.0e-8)
}

///|
test "§18.17.7 NORMDIST/NORMINV" {
  // Excel: NORMDIST(1,0,1,TRUE) ≈ 0.8413
  assert_builtin_near("NORMDIST(1,0,1,TRUE)", 0.8413447460685429, 1.0e-5)
  // PDF: NORMDIST(0,0,1,FALSE) = 1/sqrt(2*pi) ≈ 0.3989
  assert_builtin_near("NORMDIST(0,0,1,FALSE)", 0.3989422804014327, 1.0e-6)
  assert_builtin_near("NORMINV(0.5,0,1)", 0.0, 1.0e-6)
}

///|
test "§18.17.7 BINOMDIST" {
  let ctx = builtin_test_context()
  let result = evaluate(try! parse_formula("BINOMDIST(6,10,0.5,0)"), ctx)
  // Verify it returns a VNumber (not error/empty)
  match result {
    VNumber(n) => assert_true!((n - 0.205078125).abs() < 0.1)
    VError(_) => assert_true!(false)
    _ => assert_true!(false)
  }
}

///|
test "§18.17.7 POISSON" {
  let ctx = builtin_test_context()
  // PMF: POISSON(2,5,0) ≈ 0.0842
  let pmf = evaluate(try! parse_formula("POISSON(2,5,0)"), ctx)
  match pmf {
    VNumber(n) => assert_true!((n - 0.08422433748856833).abs() < 0.01)
    _ => assert_true!(false)
  }
  // PMF for k=0: POISSON(0,1,0) = exp(-1) ≈ 0.3679
  let pmf0 = evaluate(try! parse_formula("POISSON(0,1,0)"), ctx)
  match pmf0 {
    VNumber(n) => assert_true!((n - 0.36787944117144233).abs() < 0.001)
    _ => assert_true!(false)
  }
}

///|
test "§18.17.7 EXPONDIST" {
  // Excel: EXPONDIST(1,10,TRUE) ≈ 0.99995
  assert_builtin_near("EXPONDIST(1,10,TRUE)", 0.9999546000702375, 1.0e-6)
  // PDF: EXPONDIST(0.2,10,FALSE) = 10*exp(-2) ≈ 1.3534
  assert_builtin_near("EXPONDIST(0.2,10,FALSE)", 1.353352832366127, 1.0e-5)
}

///|
test "§18.17.7 FISHER/FISHERINV" {
  // Excel: FISHER(0.75) ≈ 0.97296
  assert_builtin_near("FISHER(0.75)", 0.9729550745276566, 1.0e-6)
  assert_builtin_near("FISHERINV(0.9729550745276566)", 0.75, 1.0e-6)
  assert_builtin_eval("FISHER(1)", VError(Num))
  assert_builtin_eval("FISHER(-1)", VError(Num))
}

///|
test "§18.17.7 CONFIDENCE" {
  // Excel: CONFIDENCE(0.05,2.5,50) ≈ 0.6929519
  assert_builtin_near("CONFIDENCE(0.05,2.5,50)", 0.6929519121748391, 1.0e-4)
}

///|
test "§18.17.7 STANDARDIZE" {
  // Excel: STANDARDIZE(42,40,1.5) = (42-40)/1.5 ≈ 1.333
  assert_builtin_near("STANDARDIZE(42,40,1.5)", 1.3333333333333333, 1.0e-10)
  assert_builtin_eval("STANDARDIZE(1,0,0)", VError(Num))
}

///|
test "§18.17.7 WEIBULL" {
  // Excel: WEIBULL(105,20,100,TRUE) ≈ 0.92959
  assert_builtin_near("WEIBULL(105,20,100,TRUE)", 0.92958138716899, 1.0e-3)
}

///|
test "§18.17.7 AVERAGEA/MAXA/MINA" {
  assert_builtin_eval("AVERAGEA(1,2,3)", VNumber(2.0))
  assert_builtin_eval("MAXA(1,2,3)", VNumber(3.0))
  assert_builtin_eval("MINA(1,2,3)", VNumber(1.0))
}

///|
test "§18.17.7 ERROR.TYPE/ISEVEN/ISODD/ISNONTEXT" {
  assert_builtin_eval("ERROR.TYPE(#NULL!)", VNumber(1.0))
  assert_builtin_eval("ERROR.TYPE(#DIV/0!)", VNumber(2.0))
  assert_builtin_eval("ERROR.TYPE(#VALUE!)", VNumber(3.0))
  assert_builtin_eval("ERROR.TYPE(#REF!)", VNumber(4.0))
  assert_builtin_eval("ERROR.TYPE(#NAME?)", VNumber(5.0))
  assert_builtin_eval("ERROR.TYPE(#NUM!)", VNumber(6.0))
  assert_builtin_eval("ERROR.TYPE(#N/A)", VNumber(7.0))
  assert_builtin_eval("ISEVEN(4)", VBool(true))
  assert_builtin_eval("ISEVEN(3)", VBool(false))
  assert_builtin_eval("ISODD(3)", VBool(true))
  assert_builtin_eval("ISODD(4)", VBool(false))
  assert_builtin_eval("ISNONTEXT(1)", VBool(true))
  assert_builtin_eval("ISNONTEXT(\"hi\")", VBool(false))
}

///|
test "§18.17.7 engineering — DELTA/GESTEP" {
  assert_builtin_eval("DELTA(5,5)", VNumber(1.0))
  assert_builtin_eval("DELTA(5,4)", VNumber(0.0))
  assert_builtin_eval("GESTEP(5,4)", VNumber(1.0))
  assert_builtin_eval("GESTEP(3,4)", VNumber(0.0))
}

///|
test "§18.17.7 engineering — base conversion" {
  // BIN2DEC("1100100") = 100
  assert_builtin_eval("BIN2DEC(\"1100100\")", VNumber(100.0))
  // DEC2BIN(100) = "1100100"
  assert_builtin_eval("DEC2BIN(100)", VString("1100100"))
  // DEC2HEX(255) = "FF"
  assert_builtin_eval("DEC2HEX(255)", VString("FF"))
  // HEX2DEC("FF") = 255
  assert_builtin_eval("HEX2DEC(\"FF\")", VNumber(255.0))
  // OCT2DEC("77") = 63
  assert_builtin_eval("OCT2DEC(\"77\")", VNumber(63.0))
  // DEC2OCT(63) = "77"
  assert_builtin_eval("DEC2OCT(63)", VString("77"))
}

///|
test "§18.17.7 engineering — COMPLEX/IMABS/IMREAL/IMAGINARY" {
  assert_builtin_eval("COMPLEX(3,4)", VString("3+4i"))
  assert_builtin_near("IMABS(\"3+4i\")", 5.0, 1.0e-10)
  assert_builtin_eval("IMREAL(\"3+4i\")", VNumber(3.0))
  assert_builtin_eval("IMAGINARY(\"3+4i\")", VNumber(4.0))
}

///|
test "§18.17.7 text extended — CLEAN/ASC/JIS" {
  // CLEAN removes chars 0-31
  assert_builtin_eval("LEN(CLEAN(\"test\"))", VNumber(4.0))
  // ASC("Ａ") → "A"  (fullwidth A is U+FF21)
  assert_builtin_eval("ASC(\"\u{FF21}\")", VString("A"))
  // JIS("A") → "Ａ" (U+FF21)
  assert_builtin_eval("JIS(\"A\")", VString("\u{FF21}"))
}

///|
test "§18.17.7 financial — FVSCHEDULE" {
  // Excel: FVSCHEDULE(1,{0.09,0.11,0.1}) = 1*1.09*1.11*1.1 = 1.33089
  assert_builtin_near("FVSCHEDULE(1,{0.09,0.11,0.1})", 1.33089, 1.0e-5)
}

///|
test "§18.17.7 financial — DOLLARDE/DOLLARFR" {
  // Excel: DOLLARDE(1.02,16) = 1.125
  assert_builtin_near("DOLLARDE(1.02,16)", 1.125, 1.0e-6)
  // Excel: DOLLARFR(1.125,16) = 1.02
  assert_builtin_near("DOLLARFR(1.125,16)", 1.02, 1.0e-6)
}

///|
test "§18.17.7 financial — ISPMT" {
  // Excel: ISPMT(0.1/12,1,36,8000000) ≈ -64814.81
  assert_builtin_near("ISPMT(0.1/12,1,36,8000000)", -64814.81481481482, 0.01)
}

///|
test "§18.17.7 TRANSPOSE" {
  // TRANSPOSE({1,2;3,4}) = {1,3;2,4}
  let ctx = builtin_test_context()
  let result = evaluate(try! parse_formula("TRANSPOSE({1,2;3,4})"), ctx)
  match result {
    VArray(rows) => {
      assert_true!(rows.length() == 2)
      assert_true!(rows[0].length() == 2)
      assert_true!(rows[0][0] == VNumber(1.0))
      assert_true!(rows[0][1] == VNumber(3.0))
      assert_true!(rows[1][0] == VNumber(2.0))
      assert_true!(rows[1][1] == VNumber(4.0))
    }
    _ => assert_true!(false)
  }
}

///|
test "§18.17.7 FREQUENCY" {
  let ctx = builtin_test_context()
  let result = evaluate(
    try! parse_formula("FREQUENCY({1,2,3,4,5},{2,4})"), ctx,
  )
  match result {
    VArray(rows) => {
      assert_true!(rows.length() == 3)
      assert_true!(rows[0][0] == VNumber(2.0))
      assert_true!(rows[1][0] == VNumber(2.0))
      assert_true!(rows[2][0] == VNumber(1.0))
    }
    _ => assert_true!(false)
  }
}

///|
test "§18.17.7 cube functions return #N/A" {
  assert_builtin_eval("CUBEVALUE(\"conn\",\"member\")", VError(NotApplicable))
  assert_builtin_eval(
    "CUBEMEMBER(\"conn\",\"member\")", VError(NotApplicable),
  )
}

///|
test "§18.17.7 HYPERLINK returns display text" {
  assert_builtin_eval(
    "HYPERLINK(\"http://example.com\",\"Click\")", VString("Click"),
  )
  assert_builtin_eval(
    "HYPERLINK(\"http://example.com\")", VString("http://example.com"),
  )
}
