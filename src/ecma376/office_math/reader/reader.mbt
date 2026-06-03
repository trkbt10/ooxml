///|
/// OMML XML → domain reader.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/reader"
}

///|
/// Read top-level XSD element oMath as CT_OMath (§22.1).
pub fn read_o_math(bytes : Bytes) -> @domain.CT_OMath raise {
  let root = @xml.parse(bytes).root
  require_local(root, "oMath")
  @domain.o_math(root)
}

///|
/// Read top-level XSD element oMathPara as CT_OMathPara (§22.1).
pub fn read_o_math_para(bytes : Bytes) -> @domain.CT_OMathPara raise {
  let root = @xml.parse(bytes).root
  require_local(root, "oMathPara")
  @domain.CT_OMathPara::new(root)
}

///|
/// Read top-level XSD element mathPr as CT_MathPr (§22.1).
pub fn read_math_pr(bytes : Bytes) -> @domain.CT_MathPr raise {
  let root = @xml.parse(bytes).root
  require_local(root, "mathPr")
  @domain.CT_MathPr::new(root)
}

///|
fn require_local(element : @xml.Element, expected : String) -> Unit raise {
  if element.name.local_name != expected {
    raise @domain.SchemaViolation(
      type_name="shared-math.xsd top-level element",
      value=element.name.local_name,
    )
  }
}
