///|
test "§18.17.7 trig — SIN/COS/TAN" {
  // Excel: SIN(0) = 0, SIN(PI()/6) = 0.5, SIN(PI()/2) = 1
  assert_builtin_near("SIN(0)", 0.0, 1.0e-10)
  assert_builtin_near("SIN(PI()/6)", 0.5, 1.0e-10)
  assert_builtin_near("SIN(PI()/2)", 1.0, 1.0e-10)
  assert_builtin_near("SIN(PI())", 0.0, 1.0e-10)
  // Excel: COS(0) = 1, COS(PI()/3) = 0.5, COS(PI()) = -1
  assert_builtin_near("COS(0)", 1.0, 1.0e-10)
  assert_builtin_near("COS(PI()/3)", 0.5, 1.0e-10)
  assert_builtin_near("COS(PI())", -1.0, 1.0e-10)
  // Excel: TAN(0) = 0, TAN(PI()/4) = 1
  assert_builtin_near("TAN(0)", 0.0, 1.0e-10)
  assert_builtin_near("TAN(PI()/4)", 1.0, 1.0e-10)
}

///|
test "§18.17.7 inverse trig — ASIN/ACOS/ATAN/ATAN2" {
  // Excel: ASIN(0.5) = PI()/6 ≈ 0.5235987756
  assert_builtin_near("ASIN(0.5)", 0.5235987755982988, 1.0e-8)
  assert_builtin_near("ACOS(0.5)", 1.0471975511965976, 1.0e-8)
  assert_builtin_near("ATAN(1)", 0.7853981633974483, 1.0e-8)
  // Excel: ATAN2(1,1) = PI()/4 (note: Excel ATAN2(x,y), not (y,x))
  assert_builtin_near("ATAN2(1,1)", 0.7853981633974483, 1.0e-8)
  // Error cases
  assert_builtin_eval("ASIN(2)", VError(Num))
  assert_builtin_eval("ACOS(-1.5)", VError(Num))
  assert_builtin_eval("ATAN2(0,0)", VError(DivZero))
}

///|
test "§18.17.7 hyperbolic — SINH/COSH/TANH/ASINH/ACOSH/ATANH" {
  assert_builtin_near("SINH(0)", 0.0, 1.0e-10)
  assert_builtin_near("SINH(1)", 1.1752011936438014, 1.0e-8)
  assert_builtin_near("COSH(0)", 1.0, 1.0e-10)
  assert_builtin_near("COSH(1)", 1.5430806348152437, 1.0e-8)
  assert_builtin_near("TANH(0)", 0.0, 1.0e-10)
  assert_builtin_near("TANH(1)", 0.7615941559557649, 1.0e-8)
  assert_builtin_near("ASINH(0)", 0.0, 1.0e-10)
  assert_builtin_near("ACOSH(1)", 0.0, 1.0e-10)
  assert_builtin_near("ATANH(0)", 0.0, 1.0e-10)
  assert_builtin_eval("ACOSH(0.5)", VError(Num))
  assert_builtin_eval("ATANH(1)", VError(Num))
}

///|
test "§18.17.7 DEGREES/RADIANS" {
  assert_builtin_near("DEGREES(PI())", 180.0, 1.0e-8)
  assert_builtin_near("RADIANS(180)", 3.14159265358979, 1.0e-8)
}

///|
test "§18.17.7 COMBIN/PERMUT" {
  // Excel: COMBIN(10,3) = 120
  assert_builtin_eval("COMBIN(10,3)", VNumber(120.0))
  assert_builtin_eval("COMBIN(5,0)", VNumber(1.0))
  assert_builtin_eval("COMBIN(5,5)", VNumber(1.0))
  assert_builtin_eval("COMBIN(-1,2)", VError(Num))
  // Excel: PERMUT(10,3) = 720
  assert_builtin_eval("PERMUT(10,3)", VNumber(720.0))
}

///|
test "§18.17.7 EVEN/ODD" {
  // Excel: EVEN(1.5)=2, EVEN(3)=4, EVEN(-1)=-2, EVEN(0)=0
  assert_builtin_eval("EVEN(1.5)", VNumber(2.0))
  assert_builtin_eval("EVEN(3)", VNumber(4.0))
  assert_builtin_eval("EVEN(-1)", VNumber(-2.0))
  assert_builtin_eval("EVEN(0)", VNumber(0.0))
  // Excel: ODD(1.5)=3, ODD(3)=3, ODD(-1)=-1, ODD(0)=1
  assert_builtin_eval("ODD(1.5)", VNumber(3.0))
  assert_builtin_eval("ODD(3)", VNumber(3.0))
  assert_builtin_eval("ODD(-1)", VNumber(-1.0))
  assert_builtin_eval("ODD(0)", VNumber(1.0))
}

///|
test "§18.17.7 FACT/FACTDOUBLE" {
  assert_builtin_eval("FACT(0)", VNumber(1.0))
  assert_builtin_eval("FACT(5)", VNumber(120.0))
  assert_builtin_eval("FACT(10)", VNumber(3628800.0))
  assert_builtin_eval("FACT(-1)", VError(Num))
  // Excel: FACTDOUBLE(6) = 6*4*2 = 48
  assert_builtin_eval("FACTDOUBLE(6)", VNumber(48.0))
  assert_builtin_eval("FACTDOUBLE(7)", VNumber(105.0))
}

///|
test "§18.17.7 GCD/LCM" {
  assert_builtin_eval("GCD(12,8)", VNumber(4.0))
  assert_builtin_eval("GCD(5,0)", VNumber(5.0))
  assert_builtin_eval("LCM(4,6)", VNumber(12.0))
  assert_builtin_eval("LCM(5,0)", VNumber(0.0))
}

///|
test "§18.17.7 MROUND/QUOTIENT" {
  // Excel: MROUND(10,3)=9, MROUND(7.5,3)=9
  assert_builtin_eval("MROUND(10,3)", VNumber(9.0))
  assert_builtin_eval("QUOTIENT(7,2)", VNumber(3.0))
  assert_builtin_eval("QUOTIENT(-7,2)", VNumber(-3.0))
  assert_builtin_eval("QUOTIENT(7,0)", VError(DivZero))
}

///|
test "§18.17.7 ROMAN" {
  assert_builtin_eval("ROMAN(499)", VString("CDXCIX"))
  assert_builtin_eval("ROMAN(2024)", VString("MMXXIV"))
  assert_builtin_eval("ROMAN(0)", VString(""))
  assert_builtin_eval("ROMAN(4000)", VError(Value))
}

///|
test "§18.17.7 SQRTPI" {
  // Excel: SQRTPI(1) = SQRT(PI()) ≈ 1.7724538509
  assert_builtin_near("SQRTPI(1)", 1.7724538509055159, 1.0e-8)
  assert_builtin_near("SQRTPI(2)", 2.5066282746310002, 1.0e-8)
  assert_builtin_eval("SQRTPI(-1)", VError(Num))
}

///|
test "§18.17.7 SUMSQ/SUMX2MY2/SUMX2PY2/SUMXMY2" {
  assert_builtin_eval("SUMSQ(3,4)", VNumber(25.0))
}

///|
test "§18.17.7 matrix — MDETERM/MMULT" {
  // Excel: MDETERM({1,2;3,4}) = 1*4-2*3 = -2
  assert_builtin_near("MDETERM({1,2;3,4})", -2.0, 1.0e-10)
  // Identity matrix determinant = 1
  assert_builtin_near("MDETERM({1,0;0,1})", 1.0, 1.0e-10)
}

///|
test "§18.17.7 SERIESSUM" {
  // SERIESSUM(x,n,m,coefficients): Σ c_i * x^(n+m*i)
  // SERIESSUM(2,1,1,{1,2,3}) = 1*2^1 + 2*2^2 + 3*2^3 = 2+8+24 = 34
  assert_builtin_eval("SERIESSUM(2,1,1,{1,2,3})", VNumber(34.0))
}

///|
test "§18.17.7 ISO.CEILING/ECMA.CEILING" {
  assert_builtin_eval("ISO.CEILING(4.3)", VNumber(5.0))
  assert_builtin_eval("ISO.CEILING(-4.3)", VNumber(-4.0))
  assert_builtin_eval("ISO.CEILING(4.3,2)", VNumber(6.0))
}
