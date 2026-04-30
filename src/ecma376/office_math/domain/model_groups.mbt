///|
/// XSD model group EG_ScriptStyle (§22.1.x).
/// OMML script style model group with optional scr CT_Script and sty CT_Style children.
pub(all) struct EG_ScriptStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct EG_ScriptStyle from the XML element carrying the group content.
pub fn EG_ScriptStyle::new(element : @xml.Element) -> EG_ScriptStyle {
  { element, }
}

///|
/// Construct XSD model group EG_ScriptStyle (§22.1.x).
pub fn eg_script_style(element : @xml.Element) -> EG_ScriptStyle {
  EG_ScriptStyle::new(element)
}

///|
/// XSD model group EG_OMathMathElements (§22.1.x).
/// OMML math-element model group choice over CT_Acc, CT_Bar, CT_Box,
/// CT_BorderBox, CT_D, CT_EqArr, CT_F, CT_Func, CT_GroupChr, CT_LimLow,
/// CT_LimUpp, CT_M, CT_Nary, CT_Phant, CT_Rad, script objects, and CT_R.
pub(all) struct EG_OMathMathElements {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct EG_OMathMathElements from the XML element selected by the group.
pub fn EG_OMathMathElements::new(
  element : @xml.Element,
) -> EG_OMathMathElements {
  { element, }
}

///|
/// Construct XSD model group EG_OMathMathElements (§22.1.x).
pub fn eg_o_math_math_elements(element : @xml.Element) -> EG_OMathMathElements {
  EG_OMathMathElements::new(element)
}

///|
/// XSD model group EG_OMathElements (§22.1.x).
/// OMML model group combining EG_OMathMathElements and w:EG_PContentMath.
pub(all) struct EG_OMathElements {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct EG_OMathElements from the XML element selected by the group.
pub fn EG_OMathElements::new(element : @xml.Element) -> EG_OMathElements {
  { element, }
}

///|
/// Construct XSD model group EG_OMathElements (§22.1.x).
pub fn eg_o_math_elements(element : @xml.Element) -> EG_OMathElements {
  EG_OMathElements::new(element)
}
