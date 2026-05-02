///|
fn assert_builtin_lti(source : String, expected : FormulaValue) -> Unit raise {
  let actual = evaluate(try! parse_formula(source), builtin_test_context())
  assert_true(actual == expected)
}

///|
test "§18.17.7 logical IF family short-circuits" {
  assert_builtin_lti("IF(TRUE,\"yes\",\"no\")", VString("yes"))
  assert_builtin_lti("IF(FALSE,1/0,99)", VNumber(99.0))
  assert_builtin_lti("IFERROR(1/0,\"err\")", VString("err"))
  assert_builtin_lti("IFNA(NA(),\"na\")", VString("na"))
  assert_builtin_lti("IFNA(1/0,\"na\")", VError(DivZero))
}

///|
test "§18.17.7 logical truth functions" {
  assert_builtin_lti("AND(TRUE,1,\"TRUE\")", VBool(true))
  assert_builtin_lti("AND(TRUE,FALSE,1/0)", VBool(false))
  assert_builtin_lti("OR(FALSE,0,\"TRUE\")", VBool(true))
  assert_builtin_lti("OR(TRUE,1/0)", VBool(true))
  assert_builtin_lti("NOT(FALSE)", VBool(true))
  assert_builtin_lti("XOR(TRUE,FALSE,TRUE)", VBool(false))
  assert_builtin_lti("XOR(TRUE,FALSE,FALSE)", VBool(true))
  assert_builtin_lti("TRUE()", VBool(true))
  assert_builtin_lti("FALSE()", VBool(false))
}

///|
test "§18.17.7 text concat len and slices" {
  assert_builtin_lti("CONCAT(\"a\",\"b\")", VString("ab"))
  assert_builtin_lti("CONCAT(A1:A2)", VString("12"))
  assert_builtin_lti("CONCATENATE(\"a\",\"b\")", VString("ab"))
  assert_builtin_lti("LEN(\"hello\")", VNumber(5.0))
  assert_builtin_lti("LEN(\"\")", VNumber(0.0))
  assert_builtin_lti("LEFT(\"hello\",2)", VString("he"))
  assert_builtin_lti("LEFT(\"hello\")", VString("h"))
  assert_builtin_lti("RIGHT(\"hello\",2)", VString("lo"))
  assert_builtin_lti("MID(\"hello\",2,3)", VString("ell"))
  assert_builtin_lti("MID(\"hello\",4,9)", VString("lo"))
}

///|
test "§18.17.7 text case trim and search" {
  assert_builtin_lti("UPPER(\"Abc\")", VString("ABC"))
  assert_builtin_lti("LOWER(\"AbC\")", VString("abc"))
  assert_builtin_lti("PROPER(\"hello WORLD\")", VString("Hello World"))
  assert_builtin_lti("TRIM(\"  a   b  c  \")", VString("a b c"))
  assert_builtin_lti("FIND(\"A\",\"abc\")", VError(Value))
  assert_builtin_lti("FIND(\"b\",\"abc\")", VNumber(2.0))
  assert_builtin_lti("SEARCH(\"A\",\"abc\")", VNumber(1.0))
  assert_builtin_lti("SEARCH(\"a?c\",\"abc\")", VNumber(1.0))
  assert_builtin_lti("SEARCH(\"a*c\",\"abbbc\")", VNumber(1.0))
}

///|
test "§18.17.7 text replacement repeat format and parse" {
  assert_builtin_lti("SUBSTITUTE(\"a-b-a\",\"a\",\"x\")", VString("x-b-x"))
  assert_builtin_lti("SUBSTITUTE(\"a-b-a\",\"a\",\"x\",2)", VString("a-b-x"))
  assert_builtin_lti("REPLACE(\"abcdef\",2,3,\"X\")", VString("aXef"))
  assert_builtin_lti("REPT(\"ha\",3)", VString("hahaha"))
  assert_builtin_lti("REPT(\"ha\",-1)", VError(Value))
  assert_builtin_lti("TEXT(12.6,\"0\")", VString("13"))
  assert_builtin_lti("TEXT(12.345,\"0.00\")", VString("12.35"))
  assert_builtin_lti("TEXT(12345,\"#,##0\")", VString("12,345"))
  assert_builtin_lti("TEXT(0.125,\"0%\")", VString("13%"))
  assert_builtin_lti("TEXT(45000,\"yyyy-mm-dd\")", VString("2023-03-15"))
  assert_builtin_lti("VALUE(\"3.14\")", VNumber(3.14))
  assert_builtin_lti("VALUE(\"abc\")", VError(Value))
}

///|
test "§18.17.7 text exact char and code" {
  assert_builtin_lti("EXACT(\"abc\",\"abc\")", VBool(true))
  assert_builtin_lti("EXACT(\"abc\",\"ABC\")", VBool(false))
  assert_builtin_lti("CHAR(65)", VString("A"))
  assert_builtin_lti("CODE(\"ABC\")", VNumber(65.0))
}

///|
test "§18.17.7 information predicates" {
  assert_builtin_lti("ISBLANK(A3)", VBool(true))
  assert_builtin_lti("ISNUMBER(1)", VBool(true))
  assert_builtin_lti("ISTEXT(\"x\")", VBool(true))
  assert_builtin_lti("ISLOGICAL(TRUE)", VBool(true))
  assert_builtin_lti("ISERROR(1/0)", VBool(true))
  assert_builtin_lti("ISNA(NA())", VBool(true))
  assert_builtin_lti("ISERR(1/0)", VBool(true))
  assert_builtin_lti("ISERR(NA())", VBool(false))
}

///|
test "§18.17.7 information type coercion and constants" {
  assert_builtin_lti("TYPE(1)", VNumber(1.0))
  assert_builtin_lti("TYPE(\"x\")", VNumber(2.0))
  assert_builtin_lti("TYPE(TRUE)", VNumber(4.0))
  assert_builtin_lti("TYPE(1/0)", VNumber(16.0))
  assert_builtin_lti("TYPE({1,2})", VNumber(64.0))
  assert_builtin_lti("NA()", VError(NotApplicable))
  assert_builtin_lti("N(TRUE)", VNumber(1.0))
  assert_builtin_lti("N(\"abc\")", VNumber(0.0))
  assert_builtin_lti("N(#REF!)", VError(Ref))
  assert_builtin_lti("T(\"hi\")", VString("hi"))
  assert_builtin_lti("T(123)", VString(""))
}
