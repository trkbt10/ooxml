///|
/// XSD complex type CT_CTName (§21.4): attributes lang, val; children no local child elements.
pub(all) struct CT_CTName {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_CTName domain holder for dml-diagram.xsd.
pub fn CT_CTName::new(element : @xml.Element) -> CT_CTName {
  { element, }
}

///|
/// XSD complex type CT_CTDescription (§21.4): attributes lang, val; children no local child elements.
pub(all) struct CT_CTDescription {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_CTDescription domain holder for dml-diagram.xsd.
pub fn CT_CTDescription::new(element : @xml.Element) -> CT_CTDescription {
  { element, }
}

///|
/// XSD complex type CT_CTCategory (§21.4): attributes type, pri; children no local child elements.
pub(all) struct CT_CTCategory {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_CTCategory domain holder for dml-diagram.xsd.
pub fn CT_CTCategory::new(element : @xml.Element) -> CT_CTCategory {
  { element, }
}

///|
/// XSD complex type CT_CTCategories (§21.4): attributes no local attributes; children cat.
pub(all) struct CT_CTCategories {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_CTCategories domain holder for dml-diagram.xsd.
pub fn CT_CTCategories::new(element : @xml.Element) -> CT_CTCategories {
  { element, }
}

///|
/// XSD complex type CT_Colors (§21.4): attributes meth, hueDir; children no local child elements.
pub(all) struct CT_Colors {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Colors domain holder for dml-diagram.xsd.
pub fn CT_Colors::new(element : @xml.Element) -> CT_Colors {
  { element, }
}

///|
/// XSD complex type CT_CTStyleLabel (§21.4): attributes name; children fillClrLst, linClrLst, effectClrLst, txLinClrLst, txFillClrLst, txEffectClrLst, extLst.
pub(all) struct CT_CTStyleLabel {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_CTStyleLabel domain holder for dml-diagram.xsd.
pub fn CT_CTStyleLabel::new(element : @xml.Element) -> CT_CTStyleLabel {
  { element, }
}

///|
/// XSD complex type CT_ColorTransform (§21.4): attributes uniqueId, minVer; children title, desc, catLst, styleLbl, extLst.
pub(all) struct CT_ColorTransform {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ColorTransform domain holder for dml-diagram.xsd.
pub fn CT_ColorTransform::new(element : @xml.Element) -> CT_ColorTransform {
  { element, }
}

///|
/// XSD complex type CT_ColorTransformHeader (§21.4): attributes uniqueId, minVer, resId; children title, desc, catLst, extLst.
pub(all) struct CT_ColorTransformHeader {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ColorTransformHeader domain holder for dml-diagram.xsd.
pub fn CT_ColorTransformHeader::new(
  element : @xml.Element,
) -> CT_ColorTransformHeader {
  { element, }
}

///|
/// XSD complex type CT_ColorTransformHeaderLst (§21.4): attributes no local attributes; children colorsDefHdr.
pub(all) struct CT_ColorTransformHeaderLst {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ColorTransformHeaderLst domain holder for dml-diagram.xsd.
pub fn CT_ColorTransformHeaderLst::new(
  element : @xml.Element,
) -> CT_ColorTransformHeaderLst {
  { element, }
}

///|
/// XSD complex type CT_Pt (§21.4): diagram point with modelId, type, cxnId attributes and prSet, spPr, t, extLst children.
pub(all) struct CT_Pt {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Pt domain holder for dml-diagram.xsd.
pub fn CT_Pt::new(element : @xml.Element) -> CT_Pt {
  { element, }
}

///|
/// XSD complex type CT_PtList (§21.4): attributes no local attributes; children pt.
pub(all) struct CT_PtList {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_PtList domain holder for dml-diagram.xsd.
pub fn CT_PtList::new(element : @xml.Element) -> CT_PtList {
  { element, }
}

///|
/// XSD complex type CT_Cxn (§21.4): diagram connection with modelId, type, srcId, destId, srcOrd, destOrd, parTransId, sibTransId, presId attributes and extLst child.
pub(all) struct CT_Cxn {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Cxn domain holder for dml-diagram.xsd.
pub fn CT_Cxn::new(element : @xml.Element) -> CT_Cxn {
  { element, }
}

///|
/// XSD complex type CT_CxnList (§21.4): attributes no local attributes; children cxn.
pub(all) struct CT_CxnList {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_CxnList domain holder for dml-diagram.xsd.
pub fn CT_CxnList::new(element : @xml.Element) -> CT_CxnList {
  { element, }
}

///|
/// XSD complex type CT_DataModel (§21.4): attributes no local attributes; children ptLst, cxnLst, bg, whole, extLst.
pub(all) struct CT_DataModel {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_DataModel domain holder for dml-diagram.xsd.
pub fn CT_DataModel::new(element : @xml.Element) -> CT_DataModel {
  { element, }
}

///|
/// XSD complex type CT_Constraint (§21.4): attributes op, val, fact; children extLst.
pub(all) struct CT_Constraint {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Constraint domain holder for dml-diagram.xsd.
pub fn CT_Constraint::new(element : @xml.Element) -> CT_Constraint {
  { element, }
}

///|
/// XSD complex type CT_Constraints (§21.4): attributes no local attributes; children constr.
pub(all) struct CT_Constraints {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Constraints domain holder for dml-diagram.xsd.
pub fn CT_Constraints::new(element : @xml.Element) -> CT_Constraints {
  { element, }
}

///|
/// XSD complex type CT_NumericRule (§21.4): attributes val, fact, max; children extLst.
pub(all) struct CT_NumericRule {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_NumericRule domain holder for dml-diagram.xsd.
pub fn CT_NumericRule::new(element : @xml.Element) -> CT_NumericRule {
  { element, }
}

///|
/// XSD complex type CT_Rules (§21.4): attributes no local attributes; children rule.
pub(all) struct CT_Rules {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Rules domain holder for dml-diagram.xsd.
pub fn CT_Rules::new(element : @xml.Element) -> CT_Rules {
  { element, }
}

///|
/// XSD complex type CT_PresentationOf (§21.4): attributes no local attributes; children extLst.
pub(all) struct CT_PresentationOf {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_PresentationOf domain holder for dml-diagram.xsd.
pub fn CT_PresentationOf::new(element : @xml.Element) -> CT_PresentationOf {
  { element, }
}

///|
/// XSD complex type CT_Adj (§21.4): adjustment entry with idx and val attributes.
pub(all) struct CT_Adj {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Adj domain holder for dml-diagram.xsd.
pub fn CT_Adj::new(element : @xml.Element) -> CT_Adj {
  { element, }
}

///|
/// XSD complex type CT_AdjLst (§21.4): attributes no local attributes; children adj.
pub(all) struct CT_AdjLst {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_AdjLst domain holder for dml-diagram.xsd.
pub fn CT_AdjLst::new(element : @xml.Element) -> CT_AdjLst {
  { element, }
}

///|
/// XSD complex type CT_Shape (§21.4): attributes rot, type, zOrderOff, hideGeom, lkTxEntry, blipPhldr; children adjLst, extLst.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Shape domain holder for dml-diagram.xsd.
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape {
  { element, }
}

///|
/// XSD complex type CT_Parameter (§21.4): attributes type, val; children no local child elements.
pub(all) struct CT_Parameter {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Parameter domain holder for dml-diagram.xsd.
pub fn CT_Parameter::new(element : @xml.Element) -> CT_Parameter {
  { element, }
}

///|
/// XSD complex type CT_Algorithm (§21.4): attributes type, rev; children param, extLst.
pub(all) struct CT_Algorithm {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Algorithm domain holder for dml-diagram.xsd.
pub fn CT_Algorithm::new(element : @xml.Element) -> CT_Algorithm {
  { element, }
}

///|
/// XSD complex type CT_LayoutNode (§21.4): attributes name, styleLbl, chOrder, moveWith; children alg, shape, presOf, constrLst, ruleLst, varLst, forEach, layoutNode, choose, extLst.
pub(all) struct CT_LayoutNode {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_LayoutNode domain holder for dml-diagram.xsd.
pub fn CT_LayoutNode::new(element : @xml.Element) -> CT_LayoutNode {
  { element, }
}

///|
/// XSD complex type CT_ForEach (§21.4): attributes name, ref; children alg, shape, presOf, constrLst, ruleLst, forEach, layoutNode, choose, extLst.
pub(all) struct CT_ForEach {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ForEach domain holder for dml-diagram.xsd.
pub fn CT_ForEach::new(element : @xml.Element) -> CT_ForEach {
  { element, }
}

///|
/// XSD complex type CT_When (§21.4): choose branch condition with name, func, arg, op, val attributes and layout children.
pub(all) struct CT_When {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_When domain holder for dml-diagram.xsd.
pub fn CT_When::new(element : @xml.Element) -> CT_When {
  { element, }
}

///|
/// XSD complex type CT_Otherwise (§21.4): attributes name; children alg, shape, presOf, constrLst, ruleLst, forEach, layoutNode, choose, extLst.
pub(all) struct CT_Otherwise {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Otherwise domain holder for dml-diagram.xsd.
pub fn CT_Otherwise::new(element : @xml.Element) -> CT_Otherwise {
  { element, }
}

///|
/// XSD complex type CT_Choose (§21.4): attributes name; children if, else.
pub(all) struct CT_Choose {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Choose domain holder for dml-diagram.xsd.
pub fn CT_Choose::new(element : @xml.Element) -> CT_Choose {
  { element, }
}

///|
/// XSD complex type CT_SampleData (§21.4): attributes useDef; children dataModel.
pub(all) struct CT_SampleData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_SampleData domain holder for dml-diagram.xsd.
pub fn CT_SampleData::new(element : @xml.Element) -> CT_SampleData {
  { element, }
}

///|
/// XSD complex type CT_Category (§21.4): attributes type, pri; children no local child elements.
pub(all) struct CT_Category {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Category domain holder for dml-diagram.xsd.
pub fn CT_Category::new(element : @xml.Element) -> CT_Category {
  { element, }
}

///|
/// XSD complex type CT_Categories (§21.4): attributes no local attributes; children cat.
pub(all) struct CT_Categories {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Categories domain holder for dml-diagram.xsd.
pub fn CT_Categories::new(element : @xml.Element) -> CT_Categories {
  { element, }
}

///|
/// XSD complex type CT_Name (§21.4): localized diagram name carrying lang and val attributes.
pub(all) struct CT_Name {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Name domain holder for dml-diagram.xsd.
pub fn CT_Name::new(element : @xml.Element) -> CT_Name {
  { element, }
}

///|
/// XSD complex type CT_Description (§21.4): attributes lang, val; children no local child elements.
pub(all) struct CT_Description {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Description domain holder for dml-diagram.xsd.
pub fn CT_Description::new(element : @xml.Element) -> CT_Description {
  { element, }
}

///|
/// XSD complex type CT_DiagramDefinition (§21.4): attributes uniqueId, minVer, defStyle; children title, desc, catLst, sampData, styleData, clrData, layoutNode, extLst.
pub(all) struct CT_DiagramDefinition {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_DiagramDefinition domain holder for dml-diagram.xsd.
pub fn CT_DiagramDefinition::new(
  element : @xml.Element,
) -> CT_DiagramDefinition {
  { element, }
}

///|
/// XSD complex type CT_DiagramDefinitionHeader (§21.4): attributes uniqueId, minVer, defStyle, resId; children title, desc, catLst, extLst.
pub(all) struct CT_DiagramDefinitionHeader {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_DiagramDefinitionHeader domain holder for dml-diagram.xsd.
pub fn CT_DiagramDefinitionHeader::new(
  element : @xml.Element,
) -> CT_DiagramDefinitionHeader {
  { element, }
}

///|
/// XSD complex type CT_DiagramDefinitionHeaderLst (§21.4): attributes no local attributes; children layoutDefHdr.
pub(all) struct CT_DiagramDefinitionHeaderLst {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_DiagramDefinitionHeaderLst domain holder for dml-diagram.xsd.
pub fn CT_DiagramDefinitionHeaderLst::new(
  element : @xml.Element,
) -> CT_DiagramDefinitionHeaderLst {
  { element, }
}

///|
/// XSD complex type CT_RelIds (§21.4): attributes no local attributes; children no local child elements.
pub(all) struct CT_RelIds {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_RelIds domain holder for dml-diagram.xsd.
pub fn CT_RelIds::new(element : @xml.Element) -> CT_RelIds {
  { element, }
}

///|
/// XSD complex type CT_ElemPropSet (§21.4): attributes presAssocID, presName, presStyleLbl, presStyleIdx, presStyleCnt, loTypeId, loCatId, qsTypeId, qsCatId, csTypeId, csCatId, coherent3DOff, phldrT, phldr, custAng, custFlipVert, custFlipHor, custSzX, custSzY, custScaleX, custScaleY, custT, custLinFactX, custLinFactY, custLinFactNeighborX, custLinFactNeighborY, custRadScaleRad, custRadScaleInc; children presLayoutVars, style.
pub(all) struct CT_ElemPropSet {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ElemPropSet domain holder for dml-diagram.xsd.
pub fn CT_ElemPropSet::new(element : @xml.Element) -> CT_ElemPropSet {
  { element, }
}

///|
/// XSD complex type CT_OrgChart (§21.4): attributes val; children no local child elements.
pub(all) struct CT_OrgChart {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_OrgChart domain holder for dml-diagram.xsd.
pub fn CT_OrgChart::new(element : @xml.Element) -> CT_OrgChart {
  { element, }
}

///|
/// XSD complex type CT_ChildMax (§21.4): attributes val; children no local child elements.
pub(all) struct CT_ChildMax {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ChildMax domain holder for dml-diagram.xsd.
pub fn CT_ChildMax::new(element : @xml.Element) -> CT_ChildMax {
  { element, }
}

///|
/// XSD complex type CT_ChildPref (§21.4): attributes val; children no local child elements.
pub(all) struct CT_ChildPref {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ChildPref domain holder for dml-diagram.xsd.
pub fn CT_ChildPref::new(element : @xml.Element) -> CT_ChildPref {
  { element, }
}

///|
/// XSD complex type CT_BulletEnabled (§21.4): attributes val; children no local child elements.
pub(all) struct CT_BulletEnabled {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_BulletEnabled domain holder for dml-diagram.xsd.
pub fn CT_BulletEnabled::new(element : @xml.Element) -> CT_BulletEnabled {
  { element, }
}

///|
/// XSD complex type CT_Direction (§21.4): attributes val; children no local child elements.
pub(all) struct CT_Direction {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_Direction domain holder for dml-diagram.xsd.
pub fn CT_Direction::new(element : @xml.Element) -> CT_Direction {
  { element, }
}

///|
/// XSD complex type CT_HierBranchStyle (§21.4): attributes val; children no local child elements.
pub(all) struct CT_HierBranchStyle {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_HierBranchStyle domain holder for dml-diagram.xsd.
pub fn CT_HierBranchStyle::new(element : @xml.Element) -> CT_HierBranchStyle {
  { element, }
}

///|
/// XSD complex type CT_AnimOne (§21.4): attributes val; children no local child elements.
pub(all) struct CT_AnimOne {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_AnimOne domain holder for dml-diagram.xsd.
pub fn CT_AnimOne::new(element : @xml.Element) -> CT_AnimOne {
  { element, }
}

///|
/// XSD complex type CT_AnimLvl (§21.4): attributes val; children no local child elements.
pub(all) struct CT_AnimLvl {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_AnimLvl domain holder for dml-diagram.xsd.
pub fn CT_AnimLvl::new(element : @xml.Element) -> CT_AnimLvl {
  { element, }
}

///|
/// XSD complex type CT_ResizeHandles (§21.4): attributes val; children no local child elements.
pub(all) struct CT_ResizeHandles {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_ResizeHandles domain holder for dml-diagram.xsd.
pub fn CT_ResizeHandles::new(element : @xml.Element) -> CT_ResizeHandles {
  { element, }
}

///|
/// XSD complex type CT_LayoutVariablePropertySet (§21.4): attributes no local attributes; children orgChart, chMax, chPref, bulletEnabled, dir, hierBranch, animOne, animLvl, resizeHandles.
pub(all) struct CT_LayoutVariablePropertySet {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_LayoutVariablePropertySet domain holder for dml-diagram.xsd.
pub fn CT_LayoutVariablePropertySet::new(
  element : @xml.Element,
) -> CT_LayoutVariablePropertySet {
  { element, }
}

///|
/// XSD complex type CT_SDName (§21.4): attributes lang, val; children no local child elements.
pub(all) struct CT_SDName {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_SDName domain holder for dml-diagram.xsd.
pub fn CT_SDName::new(element : @xml.Element) -> CT_SDName {
  { element, }
}

///|
/// XSD complex type CT_SDDescription (§21.4): attributes lang, val; children no local child elements.
pub(all) struct CT_SDDescription {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_SDDescription domain holder for dml-diagram.xsd.
pub fn CT_SDDescription::new(element : @xml.Element) -> CT_SDDescription {
  { element, }
}

///|
/// XSD complex type CT_SDCategory (§21.4): attributes type, pri; children no local child elements.
pub(all) struct CT_SDCategory {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_SDCategory domain holder for dml-diagram.xsd.
pub fn CT_SDCategory::new(element : @xml.Element) -> CT_SDCategory {
  { element, }
}

///|
/// XSD complex type CT_SDCategories (§21.4): attributes no local attributes; children cat.
pub(all) struct CT_SDCategories {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_SDCategories domain holder for dml-diagram.xsd.
pub fn CT_SDCategories::new(element : @xml.Element) -> CT_SDCategories {
  { element, }
}

///|
/// XSD complex type CT_TextProps (§21.4): attributes no local attributes; children no local child elements.
pub(all) struct CT_TextProps {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_TextProps domain holder for dml-diagram.xsd.
pub fn CT_TextProps::new(element : @xml.Element) -> CT_TextProps {
  { element, }
}

///|
/// XSD complex type CT_StyleLabel (§21.4): attributes name; children scene3d, sp3d, txPr, style, extLst.
pub(all) struct CT_StyleLabel {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_StyleLabel domain holder for dml-diagram.xsd.
pub fn CT_StyleLabel::new(element : @xml.Element) -> CT_StyleLabel {
  { element, }
}

///|
/// XSD complex type CT_StyleDefinition (§21.4): attributes uniqueId, minVer; children title, desc, catLst, scene3d, styleLbl, extLst.
pub(all) struct CT_StyleDefinition {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_StyleDefinition domain holder for dml-diagram.xsd.
pub fn CT_StyleDefinition::new(element : @xml.Element) -> CT_StyleDefinition {
  { element, }
}

///|
/// XSD complex type CT_StyleDefinitionHeader (§21.4): attributes uniqueId, minVer, resId; children title, desc, catLst, extLst.
pub(all) struct CT_StyleDefinitionHeader {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_StyleDefinitionHeader domain holder for dml-diagram.xsd.
pub fn CT_StyleDefinitionHeader::new(
  element : @xml.Element,
) -> CT_StyleDefinitionHeader {
  { element, }
}

///|
/// XSD complex type CT_StyleDefinitionHeaderLst (§21.4): attributes no local attributes; children styleDefHdr.
pub(all) struct CT_StyleDefinitionHeaderLst {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct the CT_StyleDefinitionHeaderLst domain holder for dml-diagram.xsd.
pub fn CT_StyleDefinitionHeaderLst::new(
  element : @xml.Element,
) -> CT_StyleDefinitionHeaderLst {
  { element, }
}

///|
/// XSD attribute group AG_IteratorAttributes (§21.4): iterator axis, ptType, hideLastTrans, st, cnt, and step attributes for layout traversal.
pub(all) struct AG_IteratorAttributes {
  axis : String?
  pt_type : String?
  hide_last_trans : String?
  st : String?
  cnt : String?
  step : String?
} derive(Eq, Debug)

///|
/// Construct an empty AG_IteratorAttributes attribute-group value.
pub fn AG_IteratorAttributes::empty() -> AG_IteratorAttributes {
  {
    axis: None,
    pt_type: None,
    hide_last_trans: None,
    st: None,
    cnt: None,
    step: None,
  }
}

///|
/// XSD attribute group AG_ConstraintAttributes (§21.4): type, for, forName, ptType.
pub(all) struct AG_ConstraintAttributes {
  type_ : String?
  for_ : String?
  for_name : String?
  pt_type : String?
} derive(Eq, Debug)

///|
/// Construct an empty AG_ConstraintAttributes attribute-group value.
pub fn AG_ConstraintAttributes::empty() -> AG_ConstraintAttributes {
  { type_: None, for_: None, for_name: None, pt_type: None }
}

///|
/// XSD attribute group AG_ConstraintRefAttributes (§21.4): refType, refFor, refForName, refPtType.
pub(all) struct AG_ConstraintRefAttributes {
  ref_type : String?
  ref_for : String?
  ref_for_name : String?
  ref_pt_type : String?
} derive(Eq, Debug)

///|
/// Construct an empty AG_ConstraintRefAttributes attribute-group value.
pub fn AG_ConstraintRefAttributes::empty() -> AG_ConstraintRefAttributes {
  { ref_type: None, ref_for: None, ref_for_name: None, ref_pt_type: None }
}

///|
/// XSD element colorsDef in dml-diagram.xsd (§21.4).
pub type ColorsDef = CT_ColorTransform

///|
/// Construct a preserved XML holder for XSD element colorsDef.
pub fn new_colors_def(element : @xml.Element) -> ColorsDef {
  { element, }
}

///|
/// XSD element colorsDefHdr in dml-diagram.xsd (§21.4).
pub type ColorsDefHdr = CT_ColorTransformHeader

///|
/// Construct a preserved XML holder for XSD element colorsDefHdr.
pub fn new_colors_def_hdr(element : @xml.Element) -> ColorsDefHdr {
  { element, }
}

///|
/// XSD element colorsDefHdrLst in dml-diagram.xsd (§21.4).
pub type ColorsDefHdrLst = CT_ColorTransformHeaderLst

///|
/// Construct a preserved XML holder for XSD element colorsDefHdrLst.
pub fn new_colors_def_hdr_lst(element : @xml.Element) -> ColorsDefHdrLst {
  { element, }
}

///|
/// XSD element dataModel in dml-diagram.xsd (§21.4).
pub type DataModel = CT_DataModel

///|
/// Construct a preserved XML holder for XSD element dataModel.
pub fn new_data_model(element : @xml.Element) -> DataModel {
  { element, }
}

///|
/// XSD element layoutDef in dml-diagram.xsd (§21.4).
pub type LayoutDef = CT_DiagramDefinition

///|
/// Construct a preserved XML holder for XSD element layoutDef.
pub fn new_layout_def(element : @xml.Element) -> LayoutDef {
  { element, }
}

///|
/// XSD element layoutDefHdr in dml-diagram.xsd (§21.4).
pub type LayoutDefHdr = CT_DiagramDefinitionHeader

///|
/// Construct a preserved XML holder for XSD element layoutDefHdr.
pub fn new_layout_def_hdr(element : @xml.Element) -> LayoutDefHdr {
  { element, }
}

///|
/// XSD element layoutDefHdrLst in dml-diagram.xsd (§21.4).
pub type LayoutDefHdrLst = CT_DiagramDefinitionHeaderLst

///|
/// Construct a preserved XML holder for XSD element layoutDefHdrLst.
pub fn new_layout_def_hdr_lst(element : @xml.Element) -> LayoutDefHdrLst {
  { element, }
}

///|
/// XSD element relIds in dml-diagram.xsd (§21.4).
pub type RelIds = CT_RelIds

///|
/// Construct a preserved XML holder for XSD element relIds.
pub fn new_rel_ids(element : @xml.Element) -> RelIds {
  { element, }
}

///|
/// XSD element styleDef in dml-diagram.xsd (§21.4).
pub type StyleDef = CT_StyleDefinition

///|
/// Construct a preserved XML holder for XSD element styleDef.
pub fn new_style_def(element : @xml.Element) -> StyleDef {
  { element, }
}

///|
/// XSD element styleDefHdr in dml-diagram.xsd (§21.4).
pub type StyleDefHdr = CT_StyleDefinitionHeader

///|
/// Construct a preserved XML holder for XSD element styleDefHdr.
pub fn new_style_def_hdr(element : @xml.Element) -> StyleDefHdr {
  { element, }
}

///|
/// XSD element styleDefHdrLst in dml-diagram.xsd (§21.4).
pub type StyleDefHdrLst = CT_StyleDefinitionHeaderLst

///|
/// Construct a preserved XML holder for XSD element styleDefHdrLst.
pub fn new_style_def_hdr_lst(element : @xml.Element) -> StyleDefHdrLst {
  { element, }
}

///|
/// Return the idx attribute from CT_Adj when present.
pub fn CT_Adj::idx(self : CT_Adj) -> String? {
  diagram_attr(self.element, "idx")
}

///|
/// Return the modelId attribute from CT_Cxn when present.
pub fn CT_Cxn::model_id(self : CT_Cxn) -> String? {
  diagram_attr(self.element, "modelId")
}

///|
/// Return the val attribute from CT_Name when present.
pub fn CT_Name::val(self : CT_Name) -> String? {
  diagram_attr(self.element, "val")
}

///|
/// Return the modelId attribute from CT_Pt when present.
pub fn CT_Pt::model_id(self : CT_Pt) -> String? {
  diagram_attr(self.element, "modelId")
}

///|
/// Return the func attribute from CT_When when present.
pub fn CT_When::func(self : CT_When) -> String? {
  diagram_attr(self.element, "func")
}

///|
fn diagram_attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// Construct CT_Adj from a preserved XML element.
pub fn new_ct_adj(element : @xml.Element) -> CT_Adj {
  CT_Adj::new(element)
}

///|
/// Construct CT_Cxn from a preserved XML element.
pub fn new_ct_cxn(element : @xml.Element) -> CT_Cxn {
  CT_Cxn::new(element)
}

///|
/// Construct CT_Pt from a preserved XML element.
pub fn new_ct_pt(element : @xml.Element) -> CT_Pt {
  CT_Pt::new(element)
}

///|
/// Construct CT_When from a preserved XML element.
pub fn new_ct_when(element : @xml.Element) -> CT_When {
  CT_When::new(element)
}

///|
/// Construct AG_IteratorAttributes with no iterator attributes set.
pub fn new_ag_iterator_attributes() -> AG_IteratorAttributes {
  AG_IteratorAttributes::empty()
}
