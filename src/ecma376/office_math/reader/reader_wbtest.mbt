///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "oMath round trips through reader and builder" {
  let value = read_o_math(
    bytes("<m:oMath xmlns:m=\"urn:math\"><m:r><m:t>x</m:t></m:r></m:oMath>"),
  )
  let reparsed = read_o_math(@builder.write_o_math(value))
  assert_eq(reparsed.element.name.local_name, "oMath")
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "oMathPara round trips through reader and builder" {
  let value = read_o_math_para(
    bytes("<m:oMathPara xmlns:m=\"urn:math\"><m:oMath/></m:oMathPara>"),
  )
  let reparsed = read_o_math_para(@builder.write_o_math_para(value))
  assert_eq(reparsed.element.name.local_name, "oMathPara")
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "mathPr round trips through reader and builder" {
  let value = read_math_pr(
    bytes(
      "<m:mathPr xmlns:m=\"urn:math\"><m:mathFont m:val=\"Cambria Math\"/></m:mathPr>",
    ),
  )
  let reparsed = read_math_pr(@builder.write_math_pr(value))
  assert_eq(reparsed.element.name.local_name, "mathPr")
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "OMML top-level readers reject the wrong root element" {
  let invalid = try? read_o_math(bytes("<m:mathPr xmlns:m=\"urn:math\"/>"))
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}

///|
test "mathPr rejects invalid CT_OnOff lexical value" {
  let invalid = try? read_math_pr(
    bytes(
      "<m:mathPr xmlns:m=\"urn:math\"><m:smallFrac m:val=\"maybe\"/></m:mathPr>",
    ),
  )
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}

///|
test "oMath reader rejects malformed nested CT_OnOff values" {
  let invalid = try? read_o_math(
    bytes(
      "<m:oMath xmlns:m=\"urn:math\">" +
      "<m:rad>" +
      "<m:radPr><m:degHide m:val=\"maybe\"/></m:radPr>" +
      "<m:deg/>" +
      "<m:e/>" +
      "</m:rad>" +
      "</m:oMath>",
    ),
  )
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}

///|
test "oMathPara reader rejects malformed nested oMath values" {
  let invalid = try? read_o_math_para(
    bytes(
      "<m:oMathPara xmlns:m=\"urn:math\">" +
      "<m:oMath>" +
      "<m:rad>" +
      "<m:radPr><m:degHide m:val=\"maybe\"/></m:radPr>" +
      "<m:deg/>" +
      "<m:e/>" +
      "</m:rad>" +
      "</m:oMath>" +
      "</m:oMathPara>",
    ),
  )
  assert_true(invalid is Err(@domain.SchemaViolation(_)))
}
