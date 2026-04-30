///|
/// OMML domain types: m:oMath, m:f, m:rad, m:nary, …
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math/domain"
}

///|
/// XSD complex type CT_Integer255 (§22.1.x).
/// OMML integer property constrained by ST_Integer255.
pub(all) struct CT_Integer255 {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Integer255 from its OMML XML element.
pub fn CT_Integer255::new(element : @xml.Element) -> CT_Integer255 {
  { element, }
}

///|
/// XSD complex type CT_Integer2 (§22.1.x).
/// OMML integer property constrained by ST_Integer2.
pub(all) struct CT_Integer2 {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Integer2 from its OMML XML element.
pub fn CT_Integer2::new(element : @xml.Element) -> CT_Integer2 {
  { element, }
}

///|
/// XSD complex type CT_SpacingRule (§22.1.x).
/// OMML spacing-rule property.
pub(all) struct CT_SpacingRule {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SpacingRule from its OMML XML element.
pub fn CT_SpacingRule::new(element : @xml.Element) -> CT_SpacingRule {
  { element, }
}

///|
/// XSD complex type CT_UnSignedInteger (§22.1.x).
/// OMML unsigned integer property.
pub(all) struct CT_UnSignedInteger {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_UnSignedInteger from its OMML XML element.
pub fn CT_UnSignedInteger::new(element : @xml.Element) -> CT_UnSignedInteger {
  { element, }
}

///|
/// XSD complex type CT_Char (§22.1.x).
/// OMML character property.
pub(all) struct CT_Char {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Char from its OMML XML element.
pub fn CT_Char::new(element : @xml.Element) -> CT_Char {
  { element, }
}

///|
/// XSD complex type CT_OnOff (§22.1.x).
/// OMML on/off property.
pub(all) struct CT_OnOff {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OnOff from its OMML XML element.
pub fn CT_OnOff::new(element : @xml.Element) -> CT_OnOff {
  { element, }
}

///|
/// XSD complex type CT_String (§22.1.x).
/// OMML string property.
pub(all) struct CT_String {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_String from its OMML XML element.
pub fn CT_String::new(element : @xml.Element) -> CT_String {
  { element, }
}

///|
/// XSD complex type CT_XAlign (§22.1.x).
/// OMML horizontal alignment property.
pub(all) struct CT_XAlign {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_XAlign from its OMML XML element.
pub fn CT_XAlign::new(element : @xml.Element) -> CT_XAlign {
  { element, }
}

///|
/// XSD complex type CT_YAlign (§22.1.x).
/// OMML vertical alignment property.
pub(all) struct CT_YAlign {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_YAlign from its OMML XML element.
pub fn CT_YAlign::new(element : @xml.Element) -> CT_YAlign {
  { element, }
}

///|
/// XSD complex type CT_Shp (§22.1.x).
/// OMML delimiter shape property.
pub(all) struct CT_Shp {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Shp from its OMML XML element.
pub fn CT_Shp::new(element : @xml.Element) -> CT_Shp {
  { element, }
}

///|
/// XSD complex type CT_FType (§22.1.x).
/// OMML fraction type property.
pub(all) struct CT_FType {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_FType from its OMML XML element.
pub fn CT_FType::new(element : @xml.Element) -> CT_FType {
  { element, }
}

///|
/// XSD complex type CT_LimLoc (§22.1.x).
/// OMML limit-location property.
pub(all) struct CT_LimLoc {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLoc from its OMML XML element.
pub fn CT_LimLoc::new(element : @xml.Element) -> CT_LimLoc {
  { element, }
}

///|
/// XSD complex type CT_TopBot (§22.1.x).
/// OMML top-or-bottom position property.
pub(all) struct CT_TopBot {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_TopBot from its OMML XML element.
pub fn CT_TopBot::new(element : @xml.Element) -> CT_TopBot {
  { element, }
}

///|
/// XSD complex type CT_Script (§22.1.x).
/// OMML script style property.
pub(all) struct CT_Script {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Script from its OMML XML element.
pub fn CT_Script::new(element : @xml.Element) -> CT_Script {
  { element, }
}

///|
/// XSD complex type CT_Style (§22.1.x).
/// OMML math text style property.
pub(all) struct CT_Style {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Style from its OMML XML element.
pub fn CT_Style::new(element : @xml.Element) -> CT_Style {
  { element, }
}

///|
/// XSD complex type CT_ManualBreak (§22.1.x).
/// OMML manual line break property.
pub(all) struct CT_ManualBreak {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_ManualBreak from its OMML XML element.
pub fn CT_ManualBreak::new(element : @xml.Element) -> CT_ManualBreak {
  { element, }
}

///|
/// XSD complex type CT_RPR with lit, nor, brk, and aln children (§22.1.x).
/// OMML run property set with lit, nor, brk, aln, scr, and sty children.
pub(all) struct CT_RPR {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_RPR from its OMML XML element.
pub fn CT_RPR::new(element : @xml.Element) -> CT_RPR {
  { element, }
}

///|
/// XSD complex type CT_Text (§22.1.x).
/// OMML run text content.
pub(all) struct CT_Text {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Text from its OMML XML element.
pub fn CT_Text::new(element : @xml.Element) -> CT_Text {
  { element, }
}

///|
/// XSD complex type CT_R with rPr CT_RPR and t CT_Text children (§22.1.x).
/// OMML math run with rPr and t children.
pub(all) struct CT_R {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_R from its OMML XML element.
pub fn CT_R::new(element : @xml.Element) -> CT_R {
  { element, }
}

///|
/// XSD complex type CT_CtrlPr (§22.1.x).
/// OMML control properties.
pub(all) struct CT_CtrlPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_CtrlPr from its OMML XML element.
pub fn CT_CtrlPr::new(element : @xml.Element) -> CT_CtrlPr {
  { element, }
}

///|
/// XSD complex type CT_AccPr with chr CT_Char and ctrlPr CT_CtrlPr children (§22.1.x).
/// OMML accent properties with chr and ctrlPr children.
pub(all) struct CT_AccPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_AccPr from its OMML XML element.
pub fn CT_AccPr::new(element : @xml.Element) -> CT_AccPr {
  { element, }
}

///|
/// XSD complex type CT_Acc (§22.1.x).
/// OMML accent object.
pub(all) struct CT_Acc {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Acc from its OMML XML element.
pub fn CT_Acc::new(element : @xml.Element) -> CT_Acc {
  { element, }
}

///|
/// XSD complex type CT_BarPr with pos CT_TopBot and ctrlPr CT_CtrlPr children (§22.1.x).
/// OMML bar properties with pos and ctrlPr children.
pub(all) struct CT_BarPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BarPr from its OMML XML element.
pub fn CT_BarPr::new(element : @xml.Element) -> CT_BarPr {
  { element, }
}

///|
/// XSD complex type CT_Bar with barPr CT_BarPr and e CT_OMathArg children (§22.1.x).
/// OMML bar object with barPr and e children.
pub(all) struct CT_Bar {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Bar from its OMML XML element.
pub fn CT_Bar::new(element : @xml.Element) -> CT_Bar {
  { element, }
}

///|
/// XSD complex type CT_BoxPr with opEmu, noBreak, diff, brk, aln, and ctrlPr children (§22.1.x).
/// OMML box properties with opEmu, noBreak, diff, brk, aln, and ctrlPr children.
pub(all) struct CT_BoxPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BoxPr from its OMML XML element.
pub fn CT_BoxPr::new(element : @xml.Element) -> CT_BoxPr {
  { element, }
}

///|
/// XSD complex type CT_Box with boxPr CT_BoxPr and e CT_OMathArg children (§22.1.x).
/// OMML box object.
pub(all) struct CT_Box {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Box from its OMML XML element.
pub fn CT_Box::new(element : @xml.Element) -> CT_Box {
  { element, }
}

///|
/// XSD complex type CT_BorderBoxPr (§22.1.x).
/// OMML border box properties.
pub(all) struct CT_BorderBoxPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BorderBoxPr from its OMML XML element.
pub fn CT_BorderBoxPr::new(element : @xml.Element) -> CT_BorderBoxPr {
  { element, }
}

///|
/// XSD complex type CT_BorderBox (§22.1.x).
/// OMML border box object.
pub(all) struct CT_BorderBox {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BorderBox from its OMML XML element.
pub fn CT_BorderBox::new(element : @xml.Element) -> CT_BorderBox {
  { element, }
}

///|
/// XSD complex type CT_DPr with begChr, sepChr, endChr, grow, shp, and ctrlPr children (§22.1.x).
/// OMML delimiter properties with begChr, sepChr, endChr, grow, shp, and ctrlPr children.
pub(all) struct CT_DPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_DPr from its OMML XML element.
pub fn CT_DPr::new(element : @xml.Element) -> CT_DPr {
  { element, }
}

///|
/// XSD complex type CT_D with dPr CT_DPr and e CT_OMathArg children (§22.1.x).
/// OMML delimiter object with dPr and e children.
pub(all) struct CT_D {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_D from its OMML XML element.
pub fn CT_D::new(element : @xml.Element) -> CT_D {
  { element, }
}

///|
/// XSD complex type CT_EqArrPr (§22.1.x).
/// OMML equation array properties.
pub(all) struct CT_EqArrPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_EqArrPr from its OMML XML element.
pub fn CT_EqArrPr::new(element : @xml.Element) -> CT_EqArrPr {
  { element, }
}

///|
/// XSD complex type CT_EqArr (§22.1.x).
/// OMML equation array object.
pub(all) struct CT_EqArr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_EqArr from its OMML XML element.
pub fn CT_EqArr::new(element : @xml.Element) -> CT_EqArr {
  { element, }
}

///|
/// XSD complex type CT_FPr (§22.1.x).
/// OMML fraction properties with type and ctrlPr children.
pub(all) struct CT_FPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_FPr from its OMML XML element.
pub fn CT_FPr::new(element : @xml.Element) -> CT_FPr {
  { element, }
}

///|
/// XSD complex type CT_F with fPr CT_FPr, num CT_OMathArg, and den CT_OMathArg children (§22.1.x).
/// OMML fraction object with fPr, num, and den children.
pub(all) struct CT_F {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_F from its OMML XML element.
pub fn CT_F::new(element : @xml.Element) -> CT_F {
  { element, }
}

///|
/// XSD complex type CT_FuncPr (§22.1.x).
/// OMML function properties.
pub(all) struct CT_FuncPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_FuncPr from its OMML XML element.
pub fn CT_FuncPr::new(element : @xml.Element) -> CT_FuncPr {
  { element, }
}

///|
/// XSD complex type CT_Func with funcPr CT_FuncPr, fName CT_OMathArg, and e CT_OMathArg children (§22.1.x).
/// OMML function object.
pub(all) struct CT_Func {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Func from its OMML XML element.
pub fn CT_Func::new(element : @xml.Element) -> CT_Func {
  { element, }
}

///|
/// XSD complex type CT_GroupChrPr (§22.1.x).
/// OMML group character properties.
pub(all) struct CT_GroupChrPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_GroupChrPr from its OMML XML element.
pub fn CT_GroupChrPr::new(element : @xml.Element) -> CT_GroupChrPr {
  { element, }
}

///|
/// XSD complex type CT_GroupChr (§22.1.x).
/// OMML group character object.
pub(all) struct CT_GroupChr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_GroupChr from its OMML XML element.
pub fn CT_GroupChr::new(element : @xml.Element) -> CT_GroupChr {
  { element, }
}

///|
/// XSD complex type CT_LimLowPr (§22.1.x).
/// OMML lower-limit properties.
pub(all) struct CT_LimLowPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLowPr from its OMML XML element.
pub fn CT_LimLowPr::new(element : @xml.Element) -> CT_LimLowPr {
  { element, }
}

///|
/// XSD complex type CT_LimLow (§22.1.x).
/// OMML lower-limit object.
pub(all) struct CT_LimLow {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimLow from its OMML XML element.
pub fn CT_LimLow::new(element : @xml.Element) -> CT_LimLow {
  { element, }
}

///|
/// XSD complex type CT_LimUppPr (§22.1.x).
/// OMML upper-limit properties.
pub(all) struct CT_LimUppPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimUppPr from its OMML XML element.
pub fn CT_LimUppPr::new(element : @xml.Element) -> CT_LimUppPr {
  { element, }
}

///|
/// XSD complex type CT_LimUpp (§22.1.x).
/// OMML upper-limit object.
pub(all) struct CT_LimUpp {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_LimUpp from its OMML XML element.
pub fn CT_LimUpp::new(element : @xml.Element) -> CT_LimUpp {
  { element, }
}

///|
/// XSD complex type CT_MCPr with count CT_Integer255 and mcJc CT_XAlign children (§22.1.x).
/// OMML matrix column properties with count and mcJc children.
pub(all) struct CT_MCPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MCPr from its OMML XML element.
pub fn CT_MCPr::new(element : @xml.Element) -> CT_MCPr {
  { element, }
}

///|
/// XSD complex type CT_MC with mcPr CT_MCPr child (§22.1.x).
/// OMML matrix column.
pub(all) struct CT_MC {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MC from its OMML XML element.
pub fn CT_MC::new(element : @xml.Element) -> CT_MC {
  { element, }
}

///|
/// XSD complex type CT_MCS (§22.1.x).
/// OMML matrix column set with mc children.
pub(all) struct CT_MCS {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MCS from its OMML XML element.
pub fn CT_MCS::new(element : @xml.Element) -> CT_MCS {
  { element, }
}

///|
/// XSD complex type CT_MPr with baseJc, plcHide, spacing, mcs, and ctrlPr children (§22.1.x).
/// OMML matrix properties with baseJc, plcHide, spacing, mcs, and ctrlPr children.
pub(all) struct CT_MPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MPr from its OMML XML element.
pub fn CT_MPr::new(element : @xml.Element) -> CT_MPr {
  { element, }
}

///|
/// XSD complex type CT_MR with e CT_OMathArg matrix row children (§22.1.x).
/// OMML matrix row.
pub(all) struct CT_MR {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MR from its OMML XML element.
pub fn CT_MR::new(element : @xml.Element) -> CT_MR {
  { element, }
}

///|
/// XSD complex type CT_M with mPr CT_MPr and mr CT_MR children (§22.1.x).
/// OMML matrix object with mPr and mr children.
pub(all) struct CT_M {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_M from its OMML XML element.
pub fn CT_M::new(element : @xml.Element) -> CT_M {
  { element, }
}

///|
/// XSD complex type CT_NaryPr (§22.1.x).
/// OMML n-ary operator properties.
pub(all) struct CT_NaryPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_NaryPr from its OMML XML element.
pub fn CT_NaryPr::new(element : @xml.Element) -> CT_NaryPr {
  { element, }
}

///|
/// XSD complex type CT_Nary (§22.1.x).
/// OMML n-ary operator object with naryPr, sub, sup, and e children.
pub(all) struct CT_Nary {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Nary from its OMML XML element.
pub fn CT_Nary::new(element : @xml.Element) -> CT_Nary {
  { element, }
}

///|
/// XSD complex type CT_PhantPr (§22.1.x).
/// OMML phantom properties.
pub(all) struct CT_PhantPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_PhantPr from its OMML XML element.
pub fn CT_PhantPr::new(element : @xml.Element) -> CT_PhantPr {
  { element, }
}

///|
/// XSD complex type CT_Phant (§22.1.x).
/// OMML phantom object.
pub(all) struct CT_Phant {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Phant from its OMML XML element.
pub fn CT_Phant::new(element : @xml.Element) -> CT_Phant {
  { element, }
}

///|
/// XSD complex type CT_RadPr with degHide CT_OnOff and ctrlPr CT_CtrlPr children (§22.1.x).
/// OMML radical properties with degHide and ctrlPr children.
pub(all) struct CT_RadPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_RadPr from its OMML XML element.
pub fn CT_RadPr::new(element : @xml.Element) -> CT_RadPr {
  { element, }
}

///|
/// XSD complex type CT_Rad (§22.1.x).
/// OMML radical object with radPr, deg, and e children.
pub(all) struct CT_Rad {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_Rad from its OMML XML element.
pub fn CT_Rad::new(element : @xml.Element) -> CT_Rad {
  { element, }
}

///|
/// XSD complex type CT_SPrePr (§22.1.x).
/// OMML prescript properties.
pub(all) struct CT_SPrePr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SPrePr from its OMML XML element.
pub fn CT_SPrePr::new(element : @xml.Element) -> CT_SPrePr {
  { element, }
}

///|
/// XSD complex type CT_SPre (§22.1.x).
/// OMML prescript object with sPrePr, sub, sup, and e children.
pub(all) struct CT_SPre {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SPre from its OMML XML element.
pub fn CT_SPre::new(element : @xml.Element) -> CT_SPre {
  { element, }
}

///|
/// XSD complex type CT_SSubPr (§22.1.x).
/// OMML subscript properties.
pub(all) struct CT_SSubPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubPr from its OMML XML element.
pub fn CT_SSubPr::new(element : @xml.Element) -> CT_SSubPr {
  { element, }
}

///|
/// XSD complex type CT_SSub (§22.1.x).
/// OMML subscript object with sSubPr, e, and sub children.
pub(all) struct CT_SSub {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSub from its OMML XML element.
pub fn CT_SSub::new(element : @xml.Element) -> CT_SSub {
  { element, }
}

///|
/// XSD complex type CT_SSubSupPr (§22.1.x).
/// OMML sub-superscript properties.
pub(all) struct CT_SSubSupPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubSupPr from its OMML XML element.
pub fn CT_SSubSupPr::new(element : @xml.Element) -> CT_SSubSupPr {
  { element, }
}

///|
/// XSD complex type CT_SSubSup (§22.1.x).
/// OMML sub-superscript object.
pub(all) struct CT_SSubSup {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSubSup from its OMML XML element.
pub fn CT_SSubSup::new(element : @xml.Element) -> CT_SSubSup {
  { element, }
}

///|
/// XSD complex type CT_SSupPr (§22.1.x).
/// OMML superscript properties.
pub(all) struct CT_SSupPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSupPr from its OMML XML element.
pub fn CT_SSupPr::new(element : @xml.Element) -> CT_SSupPr {
  { element, }
}

///|
/// XSD complex type CT_SSup (§22.1.x).
/// OMML superscript object with sSupPr, e, and sup children.
pub(all) struct CT_SSup {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_SSup from its OMML XML element.
pub fn CT_SSup::new(element : @xml.Element) -> CT_SSup {
  { element, }
}

///|
/// XSD complex type CT_OMathArgPr (§22.1.x).
/// OMML math argument properties.
pub(all) struct CT_OMathArgPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathArgPr from its OMML XML element.
pub fn CT_OMathArgPr::new(element : @xml.Element) -> CT_OMathArgPr {
  { element, }
}

///|
/// XSD complex type CT_OMathArg (§22.1.x).
/// OMML math argument.
pub(all) struct CT_OMathArg {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathArg from its OMML XML element.
pub fn CT_OMathArg::new(element : @xml.Element) -> CT_OMathArg {
  { element, }
}

///|
/// XSD complex type CT_OMathJc (§22.1.x).
/// OMML math justification property.
pub(all) struct CT_OMathJc {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathJc from its OMML XML element.
pub fn CT_OMathJc::new(element : @xml.Element) -> CT_OMathJc {
  { element, }
}

///|
/// XSD complex type CT_OMathParaPr (§22.1.x).
/// OMML math paragraph properties.
pub(all) struct CT_OMathParaPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathParaPr from its OMML XML element.
pub fn CT_OMathParaPr::new(element : @xml.Element) -> CT_OMathParaPr {
  { element, }
}

///|
/// XSD complex type CT_TwipsMeasure (§22.1.x).
/// OMML twips measure property.
pub(all) struct CT_TwipsMeasure {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_TwipsMeasure from its OMML XML element.
pub fn CT_TwipsMeasure::new(element : @xml.Element) -> CT_TwipsMeasure {
  { element, }
}

///|
/// XSD complex type CT_BreakBin (§22.1.x).
/// OMML binary operator break property.
pub(all) struct CT_BreakBin {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BreakBin from its OMML XML element.
pub fn CT_BreakBin::new(element : @xml.Element) -> CT_BreakBin {
  { element, }
}

///|
/// XSD complex type CT_BreakBinSub (§22.1.x).
/// OMML binary subtraction break property.
pub(all) struct CT_BreakBinSub {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_BreakBinSub from its OMML XML element.
pub fn CT_BreakBinSub::new(element : @xml.Element) -> CT_BreakBinSub {
  { element, }
}

///|
/// XSD complex type CT_MathPr with mathFont, brkBin, brkBinSub, margins, spacing, and limit children (§22.1.x).
/// OMML document math properties with mathFont, margins, spacing, defaults, intLim, and naryLim children.
pub(all) struct CT_MathPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_MathPr from its OMML XML element.
pub fn CT_MathPr::new(element : @xml.Element) -> CT_MathPr {
  { element, }
}

///|
/// XSD complex type CT_OMathPara (§22.1.x).
/// OMML math paragraph containing one or more math zones.
pub(all) struct CT_OMathPara {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMathPara from its OMML XML element.
pub fn CT_OMathPara::new(element : @xml.Element) -> CT_OMathPara {
  { element, }
}

///|
/// XSD complex type CT_OMath with EG_OMathElements children for top-level oMath (§22.1.x).
/// OMML inline or display math zone containing EG_OMathElements children.
pub(all) struct CT_OMath {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct CT_OMath from its OMML XML element.
pub fn CT_OMath::new(element : @xml.Element) -> CT_OMath {
  { element, }
}

///|
/// Return child elements selected through EG_OMathElements for this oMath zone.
pub fn CT_OMath::children(self : CT_OMath) -> Array[EG_OMathElements] {
  let children : Array[EG_OMathElements] = []
  for child in self.element.children {
    match child {
      Element(element) => children.push(EG_OMathElements::new(element))
      _ => ()
    }
  }
  children
}

///|
/// Construct top-level XSD element oMath as CT_OMath (§22.1).
pub fn o_math(element : @xml.Element) -> CT_OMath {
  CT_OMath::new(element)
}

///|
/// Construct top-level XSD element oMathPara as CT_OMathPara (§22.1).
pub fn o_math_para(element : @xml.Element) -> CT_OMathPara {
  CT_OMathPara::new(element)
}

///|
/// Construct top-level XSD element mathPr as CT_MathPr (§22.1).
pub fn math_pr(element : @xml.Element) -> CT_MathPr {
  CT_MathPr::new(element)
}

///|
/// Return CT_AccPr child names for chr CT_Char and ctrlPr CT_CtrlPr.
pub fn CT_AccPr::child_names(self : CT_AccPr) -> Array[String] {
  omml_child_names(self.element, ["chr", "ctrlPr"])
}

///|
/// Return CT_BarPr child names for pos CT_TopBot and ctrlPr CT_CtrlPr.
pub fn CT_BarPr::child_names(self : CT_BarPr) -> Array[String] {
  omml_child_names(self.element, ["pos", "ctrlPr"])
}

///|
/// Return CT_BoxPr child names for opEmu, noBreak, diff, brk, aln, and ctrlPr.
pub fn CT_BoxPr::child_names(self : CT_BoxPr) -> Array[String] {
  omml_child_names(self.element, [
    "opEmu", "noBreak", "diff", "brk", "aln", "ctrlPr",
  ])
}

///|
/// Return CT_DPr child names for begChr, sepChr, endChr, grow, shp, and ctrlPr.
pub fn CT_DPr::child_names(self : CT_DPr) -> Array[String] {
  omml_child_names(self.element, [
    "begChr", "sepChr", "endChr", "grow", "shp", "ctrlPr",
  ])
}

///|
/// Return CT_F child names for fPr CT_FPr, num CT_OMathArg, and den CT_OMathArg.
pub fn CT_F::child_names(self : CT_F) -> Array[String] {
  omml_child_names(self.element, ["fPr", "num", "den"])
}

///|
/// Return CT_Func child names for funcPr CT_FuncPr, fName CT_OMathArg, and e CT_OMathArg.
pub fn CT_Func::child_names(self : CT_Func) -> Array[String] {
  omml_child_names(self.element, ["funcPr", "fName", "e"])
}

///|
/// Return CT_M child names for mPr CT_MPr and mr CT_MR.
pub fn CT_M::child_names(self : CT_M) -> Array[String] {
  omml_child_names(self.element, ["mPr", "mr"])
}

///|
/// Return CT_MCPr child names for count CT_Integer255 and mcJc CT_XAlign.
pub fn CT_MCPr::child_names(self : CT_MCPr) -> Array[String] {
  omml_child_names(self.element, ["count", "mcJc"])
}

///|
/// Return CT_MPr child names for matrix alignment, spacing, column set, and ctrlPr.
pub fn CT_MPr::child_names(self : CT_MPr) -> Array[String] {
  omml_child_names(self.element, [
    "baseJc", "plcHide", "rSpRule", "cGpRule", "rSp", "cSp", "cGp", "mcs", "ctrlPr",
  ])
}

///|
/// Return CT_MathPr child names for mathFont, break settings, margins, spacing, and limits.
pub fn CT_MathPr::child_names(self : CT_MathPr) -> Array[String] {
  omml_child_names(self.element, [
    "mathFont", "brkBin", "brkBinSub", "smallFrac", "dispDef", "lMargin", "rMargin",
    "defJc", "preSp", "postSp", "interSp", "intraSp", "wrapIndent", "wrapRight",
    "intLim", "naryLim",
  ])
}

///|
/// Return CT_RPR child names for lit, nor, brk, and aln run properties.
pub fn CT_RPR::child_names(self : CT_RPR) -> Array[String] {
  omml_child_names(self.element, ["lit", "nor", "brk", "aln"])
}

///|
/// Return CT_RadPr child names for degHide CT_OnOff and ctrlPr CT_CtrlPr.
pub fn CT_RadPr::child_names(self : CT_RadPr) -> Array[String] {
  omml_child_names(self.element, ["degHide", "ctrlPr"])
}

///|
fn omml_child_names(
  element : @xml.Element,
  allowed : Array[String],
) -> Array[String] {
  let names : Array[String] = []
  for child in element.children {
    match child {
      Element(child_element) =>
        if omml_name_allowed(allowed, child_element.name.local_name) {
          names.push(child_element.name.local_name)
        }
      _ => ()
    }
  }
  names
}

///|
fn omml_name_allowed(allowed : Array[String], name : String) -> Bool {
  for allowed_name in allowed {
    if allowed_name == name {
      return true
    }
  }
  false
}
