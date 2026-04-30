///|
/// OMML domain → XML builder.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/builder"
}

///|
/// Write top-level XSD element oMath from CT_OMath (§22.1).
pub fn write_o_math(value : @domain.CT_OMath) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element oMathPara from CT_OMathPara (§22.1).
pub fn write_o_math_para(value : @domain.CT_OMathPara) -> Bytes {
  write_element(value.element)
}

///|
/// Write top-level XSD element mathPr from CT_MathPr (§22.1).
pub fn write_math_pr(value : @domain.CT_MathPr) -> Bytes {
  write_element(value.element)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}
