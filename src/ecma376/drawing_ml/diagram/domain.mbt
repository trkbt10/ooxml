// trkbt10/ooxml/ecma376/drawing_ml/diagram — typed CT_ projections
//
// XSD complex types CT_* (§21.4 DrawingML Diagrams). Each struct exposes
// the spec attributes and child elements as typed fields and preserves
// the source `@xml.Element` so the builder can round-trip unmodelled
// content.

///|
/// XSD complex type CT_CTName — Part 1 §21.4.4.11 (title, color
/// transform). Attributes: lang (xsd:string, optional default=""),
/// val (xsd:string, required). No child elements.
pub(all) struct CT_CTName {
  /// @lang — xsd:string (optional, default "").
  lang : String
  /// @val — xsd:string (required).
  val : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Decode CT_CTName from its dml-diagram.xsd element. Raises
/// SchemaViolation if the required `val` attribute is missing.
pub fn CT_CTName::new(
  element : @xml.Element,
) -> CT_CTName raise SchemaViolation {
  let lang = optional_string(element, "lang", default="")
  let val = required_string(element, "val", "CT_CTName/@val")
  { lang, val, element }
}

///|
/// Return the preserved CT_CTName element so the builder round-trips
/// unmodelled XML content.
pub fn CT_CTName::to_element(self : CT_CTName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CTDescription — Part 1 §21.4.4.6 (desc, color
/// transform). Attributes: lang (xsd:string, optional default=""),
/// val (xsd:string, required).
pub(all) struct CT_CTDescription {
  /// @lang — xsd:string (optional, default "").
  lang : String
  /// @val — xsd:string (required).
  val : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Decode CT_CTDescription. Raises SchemaViolation if required `val`
/// is missing.
pub fn CT_CTDescription::new(
  element : @xml.Element,
) -> CT_CTDescription raise SchemaViolation {
  let lang = optional_string(element, "lang", default="")
  let val = required_string(element, "val", "CT_CTDescription/@val")
  { lang, val, element }
}

///|
pub fn CT_CTDescription::to_element(self : CT_CTDescription) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CTCategory — Part 1 §21.4.4.1 (cat, color
/// transform). Attributes: type (xsd:anyURI, required), pri
/// (xsd:unsignedInt, required).
pub(all) struct CT_CTCategory {
  /// @type — xsd:anyURI (required).
  type_ : String
  /// @pri — xsd:unsignedInt (required).
  pri : UInt
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CTCategory::new(
  element : @xml.Element,
) -> CT_CTCategory raise SchemaViolation {
  let type_ = required_string(element, "type", "CT_CTCategory/@type")
  let pri = required_uint(element, "pri", "CT_CTCategory/@pri")
  { type_, pri, element }
}

///|
pub fn CT_CTCategory::to_element(self : CT_CTCategory) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CTCategories — Part 1 §21.4.4.2 (catLst, color
/// transform). No attributes. Children: cat (CT_CTCategory*).
pub(all) struct CT_CTCategories {
  /// <cat> children (CT_CTCategory, zero or more).
  cat : Array[CT_CTCategory]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CTCategories::new(
  element : @xml.Element,
) -> CT_CTCategories raise SchemaViolation {
  let cat = decode_children(element, "cat", CT_CTCategory::new)
  { cat, element }
}

///|
pub fn CT_CTCategories::to_element(self : CT_CTCategories) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Colors — Part 1 §21.4.4.7-9, .12-14
/// (fillClrLst, linClrLst, effectClrLst, txLinClrLst, txFillClrLst,
/// txEffectClrLst). Attributes: meth (ST_ClrAppMethod, optional
/// default="span"), hueDir (ST_HueDir, optional default="cw").
/// Children: a:EG_ColorChoice* projected via the typed
/// `@a.EG_ColorChoice` sum from dml-main.
pub(all) struct CT_Colors {
  /// @meth — ST_ClrAppMethod (optional, default span).
  meth : ST_ClrAppMethod
  /// @hueDir — ST_HueDir (optional, default cw).
  hue_dir : ST_HueDir
  /// <a:EG_ColorChoice> children typed via the dml-main projection.
  color_choices : Array[@a.EG_ColorChoice]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Colors::new(
  element : @xml.Element,
) -> CT_Colors raise SchemaViolation {
  let meth = match attr(element, "meth") {
    Some(v) => ST_ClrAppMethod::parse(v)
    None => ClrAppMethodSpan
  }
  let hue_dir = match attr(element, "hueDir") {
    Some(v) => ST_HueDir::parse(v)
    None => HueDirCw
  }
  let color_choices : Array[@a.EG_ColorChoice] = []
  for child in element_children(element) {
    match wrap_a_color_violation(() => @a.parse_color_choice_child(child)) {
      Some(c) => color_choices.push(c)
      None => ()
    }
  }
  { meth, hue_dir, color_choices, element }
}

///|
/// Bridge `@a.SchemaViolation` (DrawingML) into the local diagram
/// SchemaViolation so EG_ColorChoice arms can be constructed without
/// leaking the foreign error type.
fn[T] wrap_a_color_violation(
  body : () -> T raise @a.SchemaViolation,
) -> T raise SchemaViolation {
  body() catch {
    @a.SchemaViolation(_) =>
      raise SchemaViolation(
        schema="dml-diagram.xsd",
        path="CT_Colors/EG_ColorChoice",
        reason="dml-main color choice arm failed validation",
      )
  }
}

///|
pub fn CT_Colors::to_element(self : CT_Colors) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CTStyleLabel — Part 1 §21.4.4.10 (styleLbl,
/// color transform). Attributes: name (xsd:string, required).
/// Children: fillClrLst (CT_Colors?), linClrLst (CT_Colors?),
/// effectClrLst (CT_Colors?), txLinClrLst (CT_Colors?),
/// txFillClrLst (CT_Colors?), txEffectClrLst (CT_Colors?),
/// extLst (a:CT_OfficeArtExtensionList? — preserved raw).
pub(all) struct CT_CTStyleLabel {
  /// @name — xsd:string (required).
  name : String
  /// <fillClrLst> — CT_Colors (optional).
  fill_clr_lst : CT_Colors?
  /// <linClrLst> — CT_Colors (optional).
  lin_clr_lst : CT_Colors?
  /// <effectClrLst> — CT_Colors (optional).
  effect_clr_lst : CT_Colors?
  /// <txLinClrLst> — CT_Colors (optional).
  tx_lin_clr_lst : CT_Colors?
  /// <txFillClrLst> — CT_Colors (optional).
  tx_fill_clr_lst : CT_Colors?
  /// <txEffectClrLst> — CT_Colors (optional).
  tx_effect_clr_lst : CT_Colors?
  /// <extLst> — a:CT_OfficeArtExtensionList preserved as raw element.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CTStyleLabel::new(
  element : @xml.Element,
) -> CT_CTStyleLabel raise SchemaViolation {
  let name = required_string(element, "name", "CT_CTStyleLabel/@name")
  let fill_clr_lst = decode_optional_child(
    element,
    "fillClrLst",
    CT_Colors::new,
  )
  let lin_clr_lst = decode_optional_child(element, "linClrLst", CT_Colors::new)
  let effect_clr_lst = decode_optional_child(
    element,
    "effectClrLst",
    CT_Colors::new,
  )
  let tx_lin_clr_lst = decode_optional_child(
    element,
    "txLinClrLst",
    CT_Colors::new,
  )
  let tx_fill_clr_lst = decode_optional_child(
    element,
    "txFillClrLst",
    CT_Colors::new,
  )
  let tx_effect_clr_lst = decode_optional_child(
    element,
    "txEffectClrLst",
    CT_Colors::new,
  )
  let ext_lst = optional_child_element(element, "extLst")
  {
    name,
    fill_clr_lst,
    lin_clr_lst,
    effect_clr_lst,
    tx_lin_clr_lst,
    tx_fill_clr_lst,
    tx_effect_clr_lst,
    ext_lst,
    element,
  }
}

///|
pub fn CT_CTStyleLabel::to_element(self : CT_CTStyleLabel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorTransform — Part 1 §21.4.4.3 (colorsDef).
/// Attributes: uniqueId (xsd:string, optional default=""), minVer
/// (xsd:string, optional). Children: title (CT_CTName*), desc
/// (CT_CTDescription*), catLst (CT_CTCategories?), styleLbl
/// (CT_CTStyleLabel*), extLst (raw).
#alias(ColorsDef)
pub(all) struct CT_ColorTransform {
  /// @uniqueId — xsd:string (optional, default "").
  unique_id : String
  /// @minVer — xsd:string (optional).
  min_ver : String?
  /// <title>* — CT_CTName (zero or more).
  title : Array[CT_CTName]
  /// <desc>* — CT_CTDescription (zero or more).
  desc : Array[CT_CTDescription]
  /// <catLst>? — CT_CTCategories (optional).
  cat_lst : CT_CTCategories?
  /// <styleLbl>* — CT_CTStyleLabel (zero or more).
  style_lbl : Array[CT_CTStyleLabel]
  /// <extLst>? — preserved raw element.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorTransform::new(
  element : @xml.Element,
) -> CT_ColorTransform raise SchemaViolation {
  let unique_id = optional_string(element, "uniqueId", default="")
  let min_ver = attr(element, "minVer")
  let title = decode_children(element, "title", CT_CTName::new)
  let desc = decode_children(element, "desc", CT_CTDescription::new)
  let cat_lst = decode_optional_child(element, "catLst", CT_CTCategories::new)
  let style_lbl = decode_children(element, "styleLbl", CT_CTStyleLabel::new)
  let ext_lst = optional_child_element(element, "extLst")
  { unique_id, min_ver, title, desc, cat_lst, style_lbl, ext_lst, element }
}

///|
pub fn CT_ColorTransform::to_element(self : CT_ColorTransform) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorTransformHeader — Part 1 §21.4.4.4
/// (colorsDefHdr). Attributes: uniqueId (xsd:string, required),
/// minVer (xsd:string, optional), resId (xsd:int, optional default=0).
/// Children: title (CT_CTName+, minOccurs=1), desc (CT_CTDescription+,
/// minOccurs=1), catLst (CT_CTCategories?), extLst (raw).
#alias(ColorsDefHdr)
pub(all) struct CT_ColorTransformHeader {
  /// @uniqueId — xsd:string (required).
  unique_id : String
  /// @minVer — xsd:string (optional).
  min_ver : String?
  /// @resId — xsd:int (optional, default 0).
  res_id : Int
  /// <title>+ — CT_CTName (one or more).
  title : Array[CT_CTName]
  /// <desc>+ — CT_CTDescription (one or more).
  desc : Array[CT_CTDescription]
  /// <catLst>? — CT_CTCategories (optional).
  cat_lst : CT_CTCategories?
  /// <extLst>? — preserved raw element.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorTransformHeader::new(
  element : @xml.Element,
) -> CT_ColorTransformHeader raise SchemaViolation {
  let unique_id = required_string(
    element, "uniqueId", "CT_ColorTransformHeader/@uniqueId",
  )
  let min_ver = attr(element, "minVer")
  let res_id = optional_int(element, "resId", default=0)
  let title = decode_children(element, "title", CT_CTName::new)
  let desc = decode_children(element, "desc", CT_CTDescription::new)
  let cat_lst = decode_optional_child(element, "catLst", CT_CTCategories::new)
  let ext_lst = optional_child_element(element, "extLst")
  { unique_id, min_ver, res_id, title, desc, cat_lst, ext_lst, element }
}

///|
pub fn CT_ColorTransformHeader::to_element(
  self : CT_ColorTransformHeader,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ColorTransformHeaderLst — Part 1 §21.4.4.5
/// (colorsDefHdrLst). No attributes. Children: colorsDefHdr
/// (CT_ColorTransformHeader*).
#alias(ColorsDefHdrLst)
pub(all) struct CT_ColorTransformHeaderLst {
  /// <colorsDefHdr>* — CT_ColorTransformHeader (zero or more).
  colors_def_hdr : Array[CT_ColorTransformHeader]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorTransformHeaderLst::new(
  element : @xml.Element,
) -> CT_ColorTransformHeaderLst raise SchemaViolation {
  let colors_def_hdr = decode_children(
    element,
    "colorsDefHdr",
    CT_ColorTransformHeader::new,
  )
  { colors_def_hdr, element }
}

///|
pub fn CT_ColorTransformHeaderLst::to_element(
  self : CT_ColorTransformHeaderLst,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Pt — Part 1 §21.4.3.5 (pt). Attributes:
/// modelId (ST_ModelId, required), type (ST_PtType, optional
/// default="node"), cxnId (ST_ModelId, optional default="0").
/// Children: prSet (CT_ElemPropSet?), spPr (a:CT_ShapeProperties?
/// preserved raw), t (a:CT_TextBody? preserved raw), extLst (raw).
pub(all) struct CT_Pt {
  /// @modelId — ST_ModelId (required).
  model_id : ST_ModelId
  /// @type — ST_PtType (optional, default node).
  type_ : ST_PtType
  /// @cxnId — ST_ModelId (optional, default 0).
  cxn_id : ST_ModelId
  /// <prSet>? — CT_ElemPropSet (optional).
  pr_set : CT_ElemPropSet?
  /// <spPr>? — a:CT_ShapeProperties preserved raw.
  sp_pr : @xml.Element?
  /// <t>? — a:CT_TextBody preserved raw.
  t : @xml.Element?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Pt::new(element : @xml.Element) -> CT_Pt raise SchemaViolation {
  let model_id_str = required_string(element, "modelId", "CT_Pt/@modelId")
  let model_id = ST_ModelId::parse(model_id_str)
  let type_ = match attr(element, "type") {
    Some(v) => ST_PtType::parse(v)
    None => PtTypeNode
  }
  let cxn_id = match attr(element, "cxnId") {
    Some(v) => ST_ModelId::parse(v)
    None => ST_ModelId::parse("0")
  }
  let pr_set = decode_optional_child(element, "prSet", CT_ElemPropSet::new)
  let sp_pr = optional_child_element(element, "spPr")
  let t = optional_child_element(element, "t")
  let ext_lst = optional_child_element(element, "extLst")
  { model_id, type_, cxn_id, pr_set, sp_pr, t, ext_lst, element }
}

///|
pub fn CT_Pt::to_element(self : CT_Pt) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PtList — Part 1 §21.4.3.6 (ptLst). No
/// attributes. Children: pt (CT_Pt*).
pub(all) struct CT_PtList {
  /// <pt>* — CT_Pt (zero or more).
  pt : Array[CT_Pt]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PtList::new(
  element : @xml.Element,
) -> CT_PtList raise SchemaViolation {
  let pt = decode_children(element, "pt", CT_Pt::new)
  { pt, element }
}

///|
pub fn CT_PtList::to_element(self : CT_PtList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Cxn — Part 1 §21.4.3.2 (cxn). Attributes:
/// modelId (ST_ModelId, required), type (ST_CxnType, optional
/// default="parOf"), srcId (ST_ModelId, required), destId (ST_ModelId,
/// required), srcOrd (xsd:unsignedInt, required), destOrd
/// (xsd:unsignedInt, required), parTransId (ST_ModelId, optional
/// default="0"), sibTransId (ST_ModelId, optional default="0"),
/// presId (xsd:string, optional default=""). Children: extLst (raw).
pub(all) struct CT_Cxn {
  /// @modelId — ST_ModelId (required).
  model_id : ST_ModelId
  /// @type — ST_CxnType (optional, default parOf).
  type_ : ST_CxnType
  /// @srcId — ST_ModelId (required).
  src_id : ST_ModelId
  /// @destId — ST_ModelId (required).
  dest_id : ST_ModelId
  /// @srcOrd — xsd:unsignedInt (required).
  src_ord : UInt
  /// @destOrd — xsd:unsignedInt (required).
  dest_ord : UInt
  /// @parTransId — ST_ModelId (optional, default 0).
  par_trans_id : ST_ModelId
  /// @sibTransId — ST_ModelId (optional, default 0).
  sib_trans_id : ST_ModelId
  /// @presId — xsd:string (optional, default "").
  pres_id : String
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Cxn::new(element : @xml.Element) -> CT_Cxn raise SchemaViolation {
  let model_id = ST_ModelId::parse(
    required_string(element, "modelId", "CT_Cxn/@modelId"),
  )
  let type_ = match attr(element, "type") {
    Some(v) => ST_CxnType::parse(v)
    None => CxnTypeParOf
  }
  let src_id = ST_ModelId::parse(
    required_string(element, "srcId", "CT_Cxn/@srcId"),
  )
  let dest_id = ST_ModelId::parse(
    required_string(element, "destId", "CT_Cxn/@destId"),
  )
  let src_ord = required_uint(element, "srcOrd", "CT_Cxn/@srcOrd")
  let dest_ord = required_uint(element, "destOrd", "CT_Cxn/@destOrd")
  let par_trans_id = match attr(element, "parTransId") {
    Some(v) => ST_ModelId::parse(v)
    None => ST_ModelId::parse("0")
  }
  let sib_trans_id = match attr(element, "sibTransId") {
    Some(v) => ST_ModelId::parse(v)
    None => ST_ModelId::parse("0")
  }
  let pres_id = optional_string(element, "presId", default="")
  let ext_lst = optional_child_element(element, "extLst")
  {
    model_id,
    type_,
    src_id,
    dest_id,
    src_ord,
    dest_ord,
    par_trans_id,
    sib_trans_id,
    pres_id,
    ext_lst,
    element,
  }
}

///|
pub fn CT_Cxn::to_element(self : CT_Cxn) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CxnList — Part 1 §21.4.3.3 (cxnLst). No
/// attributes. Children: cxn (CT_Cxn*).
pub(all) struct CT_CxnList {
  /// <cxn>* — CT_Cxn (zero or more).
  cxn : Array[CT_Cxn]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CxnList::new(
  element : @xml.Element,
) -> CT_CxnList raise SchemaViolation {
  let cxn = decode_children(element, "cxn", CT_Cxn::new)
  { cxn, element }
}

///|
pub fn CT_CxnList::to_element(self : CT_CxnList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DataModel — Part 1 §21.4.2.10 (dataModel).
/// No attributes. Children: ptLst (CT_PtList, required), cxnLst
/// (CT_CxnList?), bg (a:CT_BackgroundFormatting? preserved raw),
/// whole (a:CT_WholeE2oFormatting? preserved raw), extLst (raw).
#alias(DataModel)
pub(all) struct CT_DataModel {
  /// <ptLst> — CT_PtList (required, minOccurs=1).
  pt_lst : CT_PtList
  /// <cxnLst>? — CT_CxnList (optional).
  cxn_lst : CT_CxnList?
  /// <bg>? — a:CT_BackgroundFormatting preserved raw.
  bg : @xml.Element?
  /// <whole>? — a:CT_WholeE2oFormatting preserved raw.
  whole : @xml.Element?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataModel::new(
  element : @xml.Element,
) -> CT_DataModel raise SchemaViolation {
  let pt_lst = match decode_optional_child(element, "ptLst", CT_PtList::new) {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-diagram.xsd",
        path="CT_DataModel/ptLst",
        reason="missing required child element ptLst",
      )
  }
  let cxn_lst = decode_optional_child(element, "cxnLst", CT_CxnList::new)
  let bg = optional_child_element(element, "bg")
  let whole = optional_child_element(element, "whole")
  let ext_lst = optional_child_element(element, "extLst")
  { pt_lst, cxn_lst, bg, whole, ext_lst, element }
}

///|
pub fn CT_DataModel::to_element(self : CT_DataModel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Constraint — Part 1 §21.4.2.8 (constr).
/// Attributes from AG_ConstraintAttributes (type required, for,
/// forName, ptType) + AG_ConstraintRefAttributes (refType, refFor,
/// refForName, refPtType) + op (ST_BoolOperator, optional
/// default="none"), val (xsd:double, optional default=0), fact
/// (xsd:double, optional default=1). Children: extLst (raw).
pub(all) struct CT_Constraint {
  /// @type — ST_ConstraintType (required).
  type_ : ST_ConstraintType
  /// @for — ST_ConstraintRelationship (optional, default self).
  for_ : ST_ConstraintRelationship
  /// @forName — xsd:string (optional, default "").
  for_name : String
  /// @ptType — ST_ElementType (optional, default all).
  pt_type : ST_ElementType
  /// @refType — ST_ConstraintType (optional, default none).
  ref_type : ST_ConstraintType
  /// @refFor — ST_ConstraintRelationship (optional, default self).
  ref_for : ST_ConstraintRelationship
  /// @refForName — xsd:string (optional, default "").
  ref_for_name : String
  /// @refPtType — ST_ElementType (optional, default all).
  ref_pt_type : ST_ElementType
  /// @op — ST_BoolOperator (optional, default none).
  op : ST_BoolOperator
  /// @val — xsd:double (optional, default 0).
  val : Double
  /// @fact — xsd:double (optional, default 1).
  fact : Double
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Constraint::new(
  element : @xml.Element,
) -> CT_Constraint raise SchemaViolation {
  let type_ = ST_ConstraintType::parse(
    required_string(element, "type", "CT_Constraint/@type"),
  )
  let for_ = match attr(element, "for") {
    Some(v) => ST_ConstraintRelationship::parse(v)
    None => ConstraintRelationshipSelf
  }
  let for_name = optional_string(element, "forName", default="")
  let pt_type = match attr(element, "ptType") {
    Some(v) => ST_ElementType::parse(v)
    None => ElementTypeAll
  }
  let ref_type = match attr(element, "refType") {
    Some(v) => ST_ConstraintType::parse(v)
    None => ConstraintTypeNone
  }
  let ref_for = match attr(element, "refFor") {
    Some(v) => ST_ConstraintRelationship::parse(v)
    None => ConstraintRelationshipSelf
  }
  let ref_for_name = optional_string(element, "refForName", default="")
  let ref_pt_type = match attr(element, "refPtType") {
    Some(v) => ST_ElementType::parse(v)
    None => ElementTypeAll
  }
  let op = match attr(element, "op") {
    Some(v) => ST_BoolOperator::parse(v)
    None => BoolOperatorNone
  }
  let val = optional_double(element, "val", default=0.0)
  let fact = optional_double(element, "fact", default=1.0)
  let ext_lst = optional_child_element(element, "extLst")
  {
    type_,
    for_,
    for_name,
    pt_type,
    ref_type,
    ref_for,
    ref_for_name,
    ref_pt_type,
    op,
    val,
    fact,
    ext_lst,
    element,
  }
}

///|
pub fn CT_Constraint::to_element(self : CT_Constraint) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Constraints — Part 1 §21.4.2.9 (constrLst).
/// No attributes. Children: constr (CT_Constraint*).
pub(all) struct CT_Constraints {
  /// <constr>* — CT_Constraint (zero or more).
  constr : Array[CT_Constraint]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Constraints::new(
  element : @xml.Element,
) -> CT_Constraints raise SchemaViolation {
  let constr = decode_children(element, "constr", CT_Constraint::new)
  { constr, element }
}

///|
pub fn CT_Constraints::to_element(self : CT_Constraints) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NumericRule — Part 1 §21.4.2.24 (rule).
/// Attributes from AG_ConstraintAttributes plus val (xsd:double,
/// optional default=NaN), fact (xsd:double, optional default=NaN),
/// max (xsd:double, optional default=NaN). The XSD default of NaN
/// is modelled here as an Option that is None when the attribute
/// is absent. Children: extLst (raw).
pub(all) struct CT_NumericRule {
  /// @type — ST_ConstraintType (required).
  type_ : ST_ConstraintType
  /// @for — ST_ConstraintRelationship (optional, default self).
  for_ : ST_ConstraintRelationship
  /// @forName — xsd:string (optional, default "").
  for_name : String
  /// @ptType — ST_ElementType (optional, default all).
  pt_type : ST_ElementType
  /// @val — xsd:double (optional, default NaN ⇒ None when absent).
  val : Double?
  /// @fact — xsd:double (optional, default NaN ⇒ None when absent).
  fact : Double?
  /// @max — xsd:double (optional, default NaN ⇒ None when absent).
  max : Double?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NumericRule::new(
  element : @xml.Element,
) -> CT_NumericRule raise SchemaViolation {
  let type_ = ST_ConstraintType::parse(
    required_string(element, "type", "CT_NumericRule/@type"),
  )
  let for_ = match attr(element, "for") {
    Some(v) => ST_ConstraintRelationship::parse(v)
    None => ConstraintRelationshipSelf
  }
  let for_name = optional_string(element, "forName", default="")
  let pt_type = match attr(element, "ptType") {
    Some(v) => ST_ElementType::parse(v)
    None => ElementTypeAll
  }
  let val = optional_double_opt(element, "val")
  let fact = optional_double_opt(element, "fact")
  let max = optional_double_opt(element, "max")
  let ext_lst = optional_child_element(element, "extLst")
  { type_, for_, for_name, pt_type, val, fact, max, ext_lst, element }
}

///|
pub fn CT_NumericRule::to_element(self : CT_NumericRule) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rules — Part 1 §21.4.2.25 (ruleLst). No
/// attributes. Children: rule (CT_NumericRule*).
pub(all) struct CT_Rules {
  /// <rule>* — CT_NumericRule (zero or more).
  rule : Array[CT_NumericRule]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rules::new(element : @xml.Element) -> CT_Rules raise SchemaViolation {
  let rule = decode_children(element, "rule", CT_NumericRule::new)
  { rule, element }
}

///|
pub fn CT_Rules::to_element(self : CT_Rules) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PresentationOf — Part 1 §21.4.2.21 (presOf).
/// Attributes from AG_IteratorAttributes (axis ST_AxisTypes default
/// "none", ptType ST_ElementTypes default "all", hideLastTrans
/// ST_Booleans default "true", st ST_Ints default "1", cnt
/// ST_UnsignedInts default "0", step ST_Ints default "1"). Children:
/// extLst (raw).
pub(all) struct CT_PresentationOf {
  /// @axis — ST_AxisTypes (optional, default "none").
  axis : ST_AxisTypes
  /// @ptType — ST_ElementTypes (optional, default "all").
  pt_type : ST_ElementTypes
  /// @hideLastTrans — ST_Booleans (optional, default "true").
  hide_last_trans : ST_Booleans
  /// @st — ST_Ints (optional, default "1").
  st : ST_Ints
  /// @cnt — ST_UnsignedInts (optional, default "0").
  cnt : ST_UnsignedInts
  /// @step — ST_Ints (optional, default "1").
  step : ST_Ints
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PresentationOf::new(
  element : @xml.Element,
) -> CT_PresentationOf raise SchemaViolation {
  let axis = parse_axis_types(element, "axis", "none")
  let pt_type = parse_element_types(element, "ptType", "all")
  let hide_last_trans = parse_booleans_default(element, "hideLastTrans", "true")
  let st = parse_ints_default(element, "st", "1")
  let cnt = parse_unsigned_ints_default(element, "cnt", "0")
  let step = parse_ints_default(element, "step", "1")
  let ext_lst = optional_child_element(element, "extLst")
  { axis, pt_type, hide_last_trans, st, cnt, step, ext_lst, element }
}

///|
pub fn CT_PresentationOf::to_element(self : CT_PresentationOf) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Adj — Part 1 §21.4.2.1 (adj). Attributes:
/// idx (ST_Index1, required), val (xsd:double, required). No
/// children.
pub(all) struct CT_Adj {
  /// @idx — ST_Index1 (required, >=1).
  idx : ST_Index1
  /// @val — xsd:double (required).
  val : Double
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Adj::new(element : @xml.Element) -> CT_Adj raise SchemaViolation {
  let idx = ST_Index1::parse(required_string(element, "idx", "CT_Adj/@idx"))
  let val = required_double(element, "val", "CT_Adj/@val")
  { idx, val, element }
}

///|
pub fn CT_Adj::to_element(self : CT_Adj) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AdjLst — Part 1 §21.4.2.2 (adjLst). No
/// attributes. Children: adj (CT_Adj*).
pub(all) struct CT_AdjLst {
  /// <adj>* — CT_Adj (zero or more).
  adj : Array[CT_Adj]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AdjLst::new(
  element : @xml.Element,
) -> CT_AdjLst raise SchemaViolation {
  let adj = decode_children(element, "adj", CT_Adj::new)
  { adj, element }
}

///|
pub fn CT_AdjLst::to_element(self : CT_AdjLst) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shape — Part 1 §21.4.2.27 (shape). Attributes:
/// rot (xsd:double, optional default=0), type (ST_LayoutShapeType,
/// optional default="none"), r:blip (xsd:string, optional —
/// relationship id), zOrderOff (xsd:int, optional default=0),
/// hideGeom (xsd:boolean, optional default=false), lkTxEntry
/// (xsd:boolean, optional default=false), blipPhldr (xsd:boolean,
/// optional default=false). Children: adjLst (CT_AdjLst?), extLst
/// (raw).
pub(all) struct CT_Shape {
  /// @rot — xsd:double (optional, default 0).
  rot : Double
  /// @type — ST_LayoutShapeType (optional, default "none").
  type_ : ST_LayoutShapeType
  /// @r:blip — relationship id (optional).
  blip : String?
  /// @zOrderOff — xsd:int (optional, default 0).
  z_order_off : Int
  /// @hideGeom — xsd:boolean (optional, default false).
  hide_geom : Bool
  /// @lkTxEntry — xsd:boolean (optional, default false).
  lk_tx_entry : Bool
  /// @blipPhldr — xsd:boolean (optional, default false).
  blip_phldr : Bool
  /// <adjLst>? — CT_AdjLst (optional).
  adj_lst : CT_AdjLst?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape raise SchemaViolation {
  let rot = optional_double(element, "rot", default=0.0)
  let type_ = match attr(element, "type") {
    Some(v) => ST_LayoutShapeType::parse(v)
    None => LayoutShapeTypeOutput(OutputShapeTypeNone)
  }
  let blip = attr(element, "blip")
  let z_order_off = optional_int(element, "zOrderOff", default=0)
  let hide_geom = optional_bool(element, "hideGeom", default=false)
  let lk_tx_entry = optional_bool(element, "lkTxEntry", default=false)
  let blip_phldr = optional_bool(element, "blipPhldr", default=false)
  let adj_lst = decode_optional_child(element, "adjLst", CT_AdjLst::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    rot,
    type_,
    blip,
    z_order_off,
    hide_geom,
    lk_tx_entry,
    blip_phldr,
    adj_lst,
    ext_lst,
    element,
  }
}

///|
pub fn CT_Shape::to_element(self : CT_Shape) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Parameter — Part 1 §21.4.2.20 (param).
/// Attributes: type (ST_ParameterId, required), val (ST_ParameterVal,
/// required). No children.
pub(all) struct CT_Parameter {
  /// @type — ST_ParameterId (required).
  type_ : ST_ParameterId
  /// @val — ST_ParameterVal (required).
  val : ST_ParameterVal
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Parameter::new(
  element : @xml.Element,
) -> CT_Parameter raise SchemaViolation {
  let type_ = ST_ParameterId::parse(
    required_string(element, "type", "CT_Parameter/@type"),
  )
  let val = ST_ParameterVal::parse(
    required_string(element, "val", "CT_Parameter/@val"),
  )
  { type_, val, element }
}

///|
pub fn CT_Parameter::to_element(self : CT_Parameter) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Algorithm — Part 1 §21.4.2.3 (alg).
/// Attributes: type (ST_AlgorithmType, required), rev
/// (xsd:unsignedInt, optional default=0). Children: param
/// (CT_Parameter*), extLst (raw).
pub(all) struct CT_Algorithm {
  /// @type — ST_AlgorithmType (required).
  type_ : ST_AlgorithmType
  /// @rev — xsd:unsignedInt (optional, default 0).
  rev : UInt
  /// <param>* — CT_Parameter (zero or more).
  param : Array[CT_Parameter]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Algorithm::new(
  element : @xml.Element,
) -> CT_Algorithm raise SchemaViolation {
  let type_ = ST_AlgorithmType::parse(
    required_string(element, "type", "CT_Algorithm/@type"),
  )
  let rev = optional_uint(element, "rev", default=0U)
  let param = decode_children(element, "param", CT_Parameter::new)
  let ext_lst = optional_child_element(element, "extLst")
  { type_, rev, param, ext_lst, element }
}

///|
pub fn CT_Algorithm::to_element(self : CT_Algorithm) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LayoutNode — Part 1 §21.4.2.19 (layoutNode).
/// Attributes: name (xsd:string, optional default=""), styleLbl
/// (xsd:string, optional default=""), chOrder (ST_ChildOrderType,
/// optional default="b"), moveWith (xsd:string, optional default="").
/// Children (xsd:choice unbounded): alg (CT_Algorithm?), shape
/// (CT_Shape?), presOf (CT_PresentationOf?), constrLst
/// (CT_Constraints?), ruleLst (CT_Rules?), varLst
/// (CT_LayoutVariablePropertySet?), forEach (CT_ForEach*), layoutNode
/// (CT_LayoutNode*), choose (CT_Choose*), extLst (raw?).
pub(all) struct CT_LayoutNode {
  /// @name — xsd:string (optional, default "").
  name : String
  /// @styleLbl — xsd:string (optional, default "").
  style_lbl : String
  /// @chOrder — ST_ChildOrderType (optional, default b).
  ch_order : ST_ChildOrderType
  /// @moveWith — xsd:string (optional, default "").
  move_with : String
  /// <alg>? — CT_Algorithm (optional, last wins per spec).
  alg : CT_Algorithm?
  /// <shape>? — CT_Shape (optional).
  shape : CT_Shape?
  /// <presOf>? — CT_PresentationOf (optional).
  pres_of : CT_PresentationOf?
  /// <constrLst>? — CT_Constraints (optional).
  constr_lst : CT_Constraints?
  /// <ruleLst>? — CT_Rules (optional).
  rule_lst : CT_Rules?
  /// <varLst>? — CT_LayoutVariablePropertySet (optional).
  var_lst : CT_LayoutVariablePropertySet?
  /// <forEach>* — CT_ForEach (zero or more).
  for_each : Array[CT_ForEach]
  /// <layoutNode>* — CT_LayoutNode (zero or more, recursive).
  layout_node : Array[CT_LayoutNode]
  /// <choose>* — CT_Choose (zero or more).
  choose : Array[CT_Choose]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LayoutNode::new(
  element : @xml.Element,
) -> CT_LayoutNode raise SchemaViolation {
  let name = optional_string(element, "name", default="")
  let style_lbl = optional_string(element, "styleLbl", default="")
  let ch_order = match attr(element, "chOrder") {
    Some(v) => ST_ChildOrderType::parse(v)
    None => ChildOrderTypeB
  }
  let move_with = optional_string(element, "moveWith", default="")
  let alg = decode_optional_child(element, "alg", CT_Algorithm::new)
  let shape = decode_optional_child(element, "shape", CT_Shape::new)
  let pres_of = decode_optional_child(element, "presOf", CT_PresentationOf::new)
  let constr_lst = decode_optional_child(
    element,
    "constrLst",
    CT_Constraints::new,
  )
  let rule_lst = decode_optional_child(element, "ruleLst", CT_Rules::new)
  let var_lst = decode_optional_child(
    element,
    "varLst",
    CT_LayoutVariablePropertySet::new,
  )
  let for_each = decode_children(element, "forEach", CT_ForEach::new)
  let layout_node = decode_children(element, "layoutNode", CT_LayoutNode::new)
  let choose = decode_children(element, "choose", CT_Choose::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    name,
    style_lbl,
    ch_order,
    move_with,
    alg,
    shape,
    pres_of,
    constr_lst,
    rule_lst,
    var_lst,
    for_each,
    layout_node,
    choose,
    ext_lst,
    element,
  }
}

///|
pub fn CT_LayoutNode::to_element(self : CT_LayoutNode) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ForEach — Part 1 §21.4.2.14 (forEach).
/// Attributes: name (xsd:string, optional default=""), ref
/// (xsd:string, optional default=""), plus AG_IteratorAttributes
/// (axis ST_AxisTypes default "none", ptType ST_ElementTypes default
/// "all", hideLastTrans ST_Booleans default "true", st ST_Ints
/// default "1", cnt ST_UnsignedInts default "0", step ST_Ints
/// default "1"). Children (xsd:choice unbounded): alg, shape, presOf,
/// constrLst, ruleLst, forEach, layoutNode, choose, extLst.
pub(all) struct CT_ForEach {
  /// @name — xsd:string (optional, default "").
  name : String
  /// @ref — xsd:string (optional, default "").
  ref_ : String
  /// @axis — ST_AxisTypes (optional, default "none").
  axis : ST_AxisTypes
  /// @ptType — ST_ElementTypes (optional, default "all").
  pt_type : ST_ElementTypes
  /// @hideLastTrans — ST_Booleans (optional, default "true").
  hide_last_trans : ST_Booleans
  /// @st — ST_Ints (optional, default "1").
  st : ST_Ints
  /// @cnt — ST_UnsignedInts (optional, default "0").
  cnt : ST_UnsignedInts
  /// @step — ST_Ints (optional, default "1").
  step : ST_Ints
  /// <alg>? — CT_Algorithm.
  alg : CT_Algorithm?
  /// <shape>? — CT_Shape.
  shape : CT_Shape?
  /// <presOf>? — CT_PresentationOf.
  pres_of : CT_PresentationOf?
  /// <constrLst>? — CT_Constraints.
  constr_lst : CT_Constraints?
  /// <ruleLst>? — CT_Rules.
  rule_lst : CT_Rules?
  /// <forEach>* — nested CT_ForEach.
  for_each : Array[CT_ForEach]
  /// <layoutNode>* — CT_LayoutNode.
  layout_node : Array[CT_LayoutNode]
  /// <choose>* — CT_Choose.
  choose : Array[CT_Choose]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ForEach::new(
  element : @xml.Element,
) -> CT_ForEach raise SchemaViolation {
  let name = optional_string(element, "name", default="")
  let ref_ = optional_string(element, "ref", default="")
  let axis = parse_axis_types(element, "axis", "none")
  let pt_type = parse_element_types(element, "ptType", "all")
  let hide_last_trans = parse_booleans_default(element, "hideLastTrans", "true")
  let st = parse_ints_default(element, "st", "1")
  let cnt = parse_unsigned_ints_default(element, "cnt", "0")
  let step = parse_ints_default(element, "step", "1")
  let alg = decode_optional_child(element, "alg", CT_Algorithm::new)
  let shape = decode_optional_child(element, "shape", CT_Shape::new)
  let pres_of = decode_optional_child(element, "presOf", CT_PresentationOf::new)
  let constr_lst = decode_optional_child(
    element,
    "constrLst",
    CT_Constraints::new,
  )
  let rule_lst = decode_optional_child(element, "ruleLst", CT_Rules::new)
  let for_each = decode_children(element, "forEach", CT_ForEach::new)
  let layout_node = decode_children(element, "layoutNode", CT_LayoutNode::new)
  let choose = decode_children(element, "choose", CT_Choose::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    name,
    ref_,
    axis,
    pt_type,
    hide_last_trans,
    st,
    cnt,
    step,
    alg,
    shape,
    pres_of,
    constr_lst,
    rule_lst,
    for_each,
    layout_node,
    choose,
    ext_lst,
    element,
  }
}

///|
pub fn CT_ForEach::to_element(self : CT_ForEach) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_When — Part 1 §21.4.2.15 (if). Attributes:
/// name (xsd:string, optional default=""), AG_IteratorAttributes,
/// func (ST_FunctionType, required), arg (ST_FunctionArgument,
/// optional default="none"), op (ST_FunctionOperator, required),
/// val (ST_FunctionValue, required). Children (xsd:choice
/// unbounded): alg, shape, presOf, constrLst, ruleLst, forEach,
/// layoutNode, choose, extLst.
pub(all) struct CT_When {
  /// @name — xsd:string (optional, default "").
  name : String
  /// @axis — ST_AxisTypes (optional, default "none").
  axis : ST_AxisTypes
  /// @ptType — ST_ElementTypes (optional, default "all").
  pt_type : ST_ElementTypes
  /// @hideLastTrans — ST_Booleans (optional, default "true").
  hide_last_trans : ST_Booleans
  /// @st — ST_Ints (optional, default "1").
  st : ST_Ints
  /// @cnt — ST_UnsignedInts (optional, default "0").
  cnt : ST_UnsignedInts
  /// @step — ST_Ints (optional, default "1").
  step : ST_Ints
  /// @func — ST_FunctionType (required).
  func : ST_FunctionType
  /// @arg — ST_FunctionArgument (optional, default "none").
  arg : ST_FunctionArgument?
  /// @op — ST_FunctionOperator (required).
  op : ST_FunctionOperator
  /// @val — ST_FunctionValue (required).
  val : ST_FunctionValue
  /// <alg>? — CT_Algorithm.
  alg : CT_Algorithm?
  /// <shape>? — CT_Shape.
  shape : CT_Shape?
  /// <presOf>? — CT_PresentationOf.
  pres_of : CT_PresentationOf?
  /// <constrLst>? — CT_Constraints.
  constr_lst : CT_Constraints?
  /// <ruleLst>? — CT_Rules.
  rule_lst : CT_Rules?
  /// <forEach>* — CT_ForEach.
  for_each : Array[CT_ForEach]
  /// <layoutNode>* — CT_LayoutNode.
  layout_node : Array[CT_LayoutNode]
  /// <choose>* — CT_Choose.
  choose : Array[CT_Choose]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_When::new(element : @xml.Element) -> CT_When raise SchemaViolation {
  let name = optional_string(element, "name", default="")
  let axis = parse_axis_types(element, "axis", "none")
  let pt_type = parse_element_types(element, "ptType", "all")
  let hide_last_trans = parse_booleans_default(element, "hideLastTrans", "true")
  let st = parse_ints_default(element, "st", "1")
  let cnt = parse_unsigned_ints_default(element, "cnt", "0")
  let step = parse_ints_default(element, "step", "1")
  let func = ST_FunctionType::parse(
    required_string(element, "func", "CT_When/@func"),
  )
  let arg = match attr(element, "arg") {
    Some(v) if v == "none" => None
    Some(v) => Some(ST_FunctionArgument::parse(v))
    None => None
  }
  let op = ST_FunctionOperator::parse(
    required_string(element, "op", "CT_When/@op"),
  )
  let val = ST_FunctionValue::parse(
    required_string(element, "val", "CT_When/@val"),
  )
  let alg = decode_optional_child(element, "alg", CT_Algorithm::new)
  let shape = decode_optional_child(element, "shape", CT_Shape::new)
  let pres_of = decode_optional_child(element, "presOf", CT_PresentationOf::new)
  let constr_lst = decode_optional_child(
    element,
    "constrLst",
    CT_Constraints::new,
  )
  let rule_lst = decode_optional_child(element, "ruleLst", CT_Rules::new)
  let for_each = decode_children(element, "forEach", CT_ForEach::new)
  let layout_node = decode_children(element, "layoutNode", CT_LayoutNode::new)
  let choose = decode_children(element, "choose", CT_Choose::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    name,
    axis,
    pt_type,
    hide_last_trans,
    st,
    cnt,
    step,
    func,
    arg,
    op,
    val,
    alg,
    shape,
    pres_of,
    constr_lst,
    rule_lst,
    for_each,
    layout_node,
    choose,
    ext_lst,
    element,
  }
}

///|
pub fn CT_When::to_element(self : CT_When) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Otherwise — Part 1 §21.4.2.12 (else).
/// Attributes: name (xsd:string, optional default=""). Children
/// (xsd:choice unbounded): alg, shape, presOf, constrLst, ruleLst,
/// forEach, layoutNode, choose, extLst.
pub(all) struct CT_Otherwise {
  /// @name — xsd:string (optional, default "").
  name : String
  /// <alg>? — CT_Algorithm.
  alg : CT_Algorithm?
  /// <shape>? — CT_Shape.
  shape : CT_Shape?
  /// <presOf>? — CT_PresentationOf.
  pres_of : CT_PresentationOf?
  /// <constrLst>? — CT_Constraints.
  constr_lst : CT_Constraints?
  /// <ruleLst>? — CT_Rules.
  rule_lst : CT_Rules?
  /// <forEach>* — CT_ForEach.
  for_each : Array[CT_ForEach]
  /// <layoutNode>* — CT_LayoutNode.
  layout_node : Array[CT_LayoutNode]
  /// <choose>* — CT_Choose.
  choose : Array[CT_Choose]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Otherwise::new(
  element : @xml.Element,
) -> CT_Otherwise raise SchemaViolation {
  let name = optional_string(element, "name", default="")
  let alg = decode_optional_child(element, "alg", CT_Algorithm::new)
  let shape = decode_optional_child(element, "shape", CT_Shape::new)
  let pres_of = decode_optional_child(element, "presOf", CT_PresentationOf::new)
  let constr_lst = decode_optional_child(
    element,
    "constrLst",
    CT_Constraints::new,
  )
  let rule_lst = decode_optional_child(element, "ruleLst", CT_Rules::new)
  let for_each = decode_children(element, "forEach", CT_ForEach::new)
  let layout_node = decode_children(element, "layoutNode", CT_LayoutNode::new)
  let choose = decode_children(element, "choose", CT_Choose::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    name,
    alg,
    shape,
    pres_of,
    constr_lst,
    rule_lst,
    for_each,
    layout_node,
    choose,
    ext_lst,
    element,
  }
}

///|
pub fn CT_Otherwise::to_element(self : CT_Otherwise) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Choose — Part 1 §21.4.2.6 (choose).
/// Attributes: name (xsd:string, optional default=""). Children:
/// if (CT_When+, maxOccurs unbounded), else (CT_Otherwise?).
pub(all) struct CT_Choose {
  /// @name — xsd:string (optional, default "").
  name : String
  /// <if>+ — CT_When (one or more).
  if_ : Array[CT_When]
  /// <else>? — CT_Otherwise (optional).
  else_ : CT_Otherwise?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Choose::new(
  element : @xml.Element,
) -> CT_Choose raise SchemaViolation {
  let name = optional_string(element, "name", default="")
  let if_ = decode_children(element, "if", CT_When::new)
  let else_ = decode_optional_child(element, "else", CT_Otherwise::new)
  { name, if_, else_, element }
}

///|
pub fn CT_Choose::to_element(self : CT_Choose) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SampleData — Part 1 §21.4.2.26 (sampData /
/// styleData / clrData). Attributes: useDef (xsd:boolean, optional
/// default=false). Children: dataModel (CT_DataModel?).
pub(all) struct CT_SampleData {
  /// @useDef — xsd:boolean (optional, default false).
  use_def : Bool
  /// <dataModel>? — CT_DataModel (optional).
  data_model : CT_DataModel?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SampleData::new(
  element : @xml.Element,
) -> CT_SampleData raise SchemaViolation {
  let use_def = optional_bool(element, "useDef", default=false)
  let data_model = decode_optional_child(
    element,
    "dataModel",
    CT_DataModel::new,
  )
  { use_def, data_model, element }
}

///|
pub fn CT_SampleData::to_element(self : CT_SampleData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Category — Part 1 §21.4.5.1 (cat, style).
/// Attributes: type (xsd:anyURI, required), pri (xsd:unsignedInt,
/// required). No children.
pub(all) struct CT_Category {
  /// @type — xsd:anyURI (required).
  type_ : String
  /// @pri — xsd:unsignedInt (required).
  pri : UInt
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Category::new(
  element : @xml.Element,
) -> CT_Category raise SchemaViolation {
  let type_ = required_string(element, "type", "CT_Category/@type")
  let pri = required_uint(element, "pri", "CT_Category/@pri")
  { type_, pri, element }
}

///|
pub fn CT_Category::to_element(self : CT_Category) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Categories — Part 1 §21.4.5.2 (catLst,
/// style). No attributes. Children: cat (CT_Category*).
pub(all) struct CT_Categories {
  /// <cat>* — CT_Category (zero or more).
  cat : Array[CT_Category]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Categories::new(
  element : @xml.Element,
) -> CT_Categories raise SchemaViolation {
  let cat = decode_children(element, "cat", CT_Category::new)
  { cat, element }
}

///|
pub fn CT_Categories::to_element(self : CT_Categories) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Name — Part 1 §21.4.2.30 (title, layout).
/// Attributes: lang (xsd:string, optional default=""), val
/// (xsd:string, required). No children.
pub(all) struct CT_Name {
  /// @lang — xsd:string (optional, default "").
  lang : String
  /// @val — xsd:string (required).
  val : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Name::new(element : @xml.Element) -> CT_Name raise SchemaViolation {
  let lang = optional_string(element, "lang", default="")
  let val = required_string(element, "val", "CT_Name/@val")
  { lang, val, element }
}

///|
pub fn CT_Name::to_element(self : CT_Name) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Description — Part 1 §21.4.2.11 (desc,
/// layout). Attributes: lang (xsd:string, optional default=""),
/// val (xsd:string, required). No children.
pub(all) struct CT_Description {
  /// @lang — xsd:string (optional, default "").
  lang : String
  /// @val — xsd:string (required).
  val : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Description::new(
  element : @xml.Element,
) -> CT_Description raise SchemaViolation {
  let lang = optional_string(element, "lang", default="")
  let val = required_string(element, "val", "CT_Description/@val")
  { lang, val, element }
}

///|
pub fn CT_Description::to_element(self : CT_Description) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DiagramDefinition — Part 1 §21.4.2.16
/// (layoutDef). Attributes: uniqueId (xsd:string, optional
/// default=""), minVer (xsd:string, optional), defStyle (xsd:string,
/// optional default=""). Children: title (CT_Name*), desc
/// (CT_Description*), catLst (CT_Categories?), sampData
/// (CT_SampleData?), styleData (CT_SampleData?), clrData
/// (CT_SampleData?), layoutNode (CT_LayoutNode, required),
/// extLst (raw).
#alias(LayoutDef)
pub(all) struct CT_DiagramDefinition {
  /// @uniqueId — xsd:string (optional, default "").
  unique_id : String
  /// @minVer — xsd:string (optional).
  min_ver : String?
  /// @defStyle — xsd:string (optional, default "").
  def_style : String
  /// <title>* — CT_Name (zero or more).
  title : Array[CT_Name]
  /// <desc>* — CT_Description (zero or more).
  desc : Array[CT_Description]
  /// <catLst>? — CT_Categories.
  cat_lst : CT_Categories?
  /// <sampData>? — CT_SampleData.
  samp_data : CT_SampleData?
  /// <styleData>? — CT_SampleData.
  style_data : CT_SampleData?
  /// <clrData>? — CT_SampleData.
  clr_data : CT_SampleData?
  /// <layoutNode>* — CT_LayoutNode (XSD declares it required, but
  /// pre-existing test fixtures omit it, so the typed field is a
  /// list to mirror dml-diagram.xsd's pragmatic usage. The decoder
  /// rejects only structurally invalid <layoutNode> children, not
  /// absence — `diagram_layout` enforces minOccurs=1 at its own
  /// decoder boundary.).
  layout_node : Array[CT_LayoutNode]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DiagramDefinition::new(
  element : @xml.Element,
) -> CT_DiagramDefinition raise SchemaViolation {
  let unique_id = optional_string(element, "uniqueId", default="")
  let min_ver = attr(element, "minVer")
  let def_style = optional_string(element, "defStyle", default="")
  let title = decode_children(element, "title", CT_Name::new)
  let desc = decode_children(element, "desc", CT_Description::new)
  let cat_lst = decode_optional_child(element, "catLst", CT_Categories::new)
  let samp_data = decode_optional_child(element, "sampData", CT_SampleData::new)
  let style_data = decode_optional_child(
    element,
    "styleData",
    CT_SampleData::new,
  )
  let clr_data = decode_optional_child(element, "clrData", CT_SampleData::new)
  let layout_node = decode_children(element, "layoutNode", CT_LayoutNode::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    unique_id,
    min_ver,
    def_style,
    title,
    desc,
    cat_lst,
    samp_data,
    style_data,
    clr_data,
    layout_node,
    ext_lst,
    element,
  }
}

///|
pub fn CT_DiagramDefinition::to_element(
  self : CT_DiagramDefinition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DiagramDefinitionHeader — Part 1 §21.4.2.17
/// (layoutDefHdr). Attributes: uniqueId (xsd:string, required),
/// minVer (xsd:string, optional), defStyle (xsd:string, optional
/// default=""), resId (xsd:int, optional default=0). Children:
/// title (CT_Name+ — minOccurs=1), desc (CT_Description+ —
/// minOccurs=1), catLst (CT_Categories?), extLst (raw).
#alias(LayoutDefHdr)
pub(all) struct CT_DiagramDefinitionHeader {
  /// @uniqueId — xsd:string (required).
  unique_id : String
  /// @minVer — xsd:string (optional).
  min_ver : String?
  /// @defStyle — xsd:string (optional, default "").
  def_style : String
  /// @resId — xsd:int (optional, default 0).
  res_id : Int
  /// <title>+ — CT_Name (one or more).
  title : Array[CT_Name]
  /// <desc>+ — CT_Description (one or more).
  desc : Array[CT_Description]
  /// <catLst>? — CT_Categories.
  cat_lst : CT_Categories?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DiagramDefinitionHeader::new(
  element : @xml.Element,
) -> CT_DiagramDefinitionHeader raise SchemaViolation {
  let unique_id = required_string(
    element, "uniqueId", "CT_DiagramDefinitionHeader/@uniqueId",
  )
  let min_ver = attr(element, "minVer")
  let def_style = optional_string(element, "defStyle", default="")
  let res_id = optional_int(element, "resId", default=0)
  let title = decode_children(element, "title", CT_Name::new)
  let desc = decode_children(element, "desc", CT_Description::new)
  let cat_lst = decode_optional_child(element, "catLst", CT_Categories::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    unique_id,
    min_ver,
    def_style,
    res_id,
    title,
    desc,
    cat_lst,
    ext_lst,
    element,
  }
}

///|
pub fn CT_DiagramDefinitionHeader::to_element(
  self : CT_DiagramDefinitionHeader,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DiagramDefinitionHeaderLst — Part 1 §21.4.2.18
/// (layoutDefHdrLst). No attributes. Children: layoutDefHdr
/// (CT_DiagramDefinitionHeader*).
#alias(LayoutDefHdrLst)
pub(all) struct CT_DiagramDefinitionHeaderLst {
  /// <layoutDefHdr>* — CT_DiagramDefinitionHeader (zero or more).
  layout_def_hdr : Array[CT_DiagramDefinitionHeader]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DiagramDefinitionHeaderLst::new(
  element : @xml.Element,
) -> CT_DiagramDefinitionHeaderLst raise SchemaViolation {
  let layout_def_hdr = decode_children(
    element,
    "layoutDefHdr",
    CT_DiagramDefinitionHeader::new,
  )
  { layout_def_hdr, element }
}

///|
pub fn CT_DiagramDefinitionHeaderLst::to_element(
  self : CT_DiagramDefinitionHeaderLst,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RelIds — Part 1 §21.4.2.22 (relIds).
/// Attributes (all required, all r: namespace): r:dm, r:lo, r:qs,
/// r:cs (each xsd:string relationship id). No children.
#alias(RelIds)
pub(all) struct CT_RelIds {
  /// @r:dm — relationship id for data model part (required).
  dm : String
  /// @r:lo — relationship id for layout definition part (required).
  lo : String
  /// @r:qs — relationship id for style definition part (required).
  qs : String
  /// @r:cs — relationship id for colors part (required).
  cs : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelIds::new(
  element : @xml.Element,
) -> CT_RelIds raise SchemaViolation {
  let dm = required_string(element, "dm", "CT_RelIds/@r:dm")
  let lo = required_string(element, "lo", "CT_RelIds/@r:lo")
  let qs = required_string(element, "qs", "CT_RelIds/@r:qs")
  let cs = required_string(element, "cs", "CT_RelIds/@r:cs")
  { dm, lo, qs, cs, element }
}

///|
pub fn CT_RelIds::to_element(self : CT_RelIds) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ElemPropSet — Part 1 §21.4.3.4 (prSet).
/// Attributes: presAssocID (ST_ModelId?), presName (xsd:string?),
/// presStyleLbl (xsd:string?), presStyleIdx (xsd:int?), presStyleCnt
/// (xsd:int?), loTypeId (xsd:string?), loCatId (xsd:string?),
/// qsTypeId (xsd:string?), qsCatId (xsd:string?), csTypeId
/// (xsd:string?), csCatId (xsd:string?), coherent3DOff (xsd:boolean?),
/// phldrT (xsd:string?), phldr (xsd:boolean?), custAng (xsd:int?),
/// custFlipVert (xsd:boolean?), custFlipHor (xsd:boolean?), custSzX
/// (xsd:int?), custSzY (xsd:int?), custScaleX (ST_PrSetCustVal?),
/// custScaleY (ST_PrSetCustVal?), custT (xsd:boolean?), custLinFactX
/// (ST_PrSetCustVal?), custLinFactY (ST_PrSetCustVal?),
/// custLinFactNeighborX (ST_PrSetCustVal?), custLinFactNeighborY
/// (ST_PrSetCustVal?), custRadScaleRad (ST_PrSetCustVal?),
/// custRadScaleInc (ST_PrSetCustVal?). Children: presLayoutVars
/// (CT_LayoutVariablePropertySet?), style (a:CT_ShapeStyle?
/// preserved raw).
pub(all) struct CT_ElemPropSet {
  pres_assoc_id : ST_ModelId?
  pres_name : String?
  pres_style_lbl : String?
  pres_style_idx : Int?
  pres_style_cnt : Int?
  lo_type_id : String?
  lo_cat_id : String?
  qs_type_id : String?
  qs_cat_id : String?
  cs_type_id : String?
  cs_cat_id : String?
  coherent3d_off : Bool?
  phldr_t : String?
  phldr : Bool?
  cust_ang : Int?
  cust_flip_vert : Bool?
  cust_flip_hor : Bool?
  cust_sz_x : Int?
  cust_sz_y : Int?
  cust_scale_x : ST_PrSetCustVal?
  cust_scale_y : ST_PrSetCustVal?
  cust_t : Bool?
  cust_lin_fact_x : ST_PrSetCustVal?
  cust_lin_fact_y : ST_PrSetCustVal?
  cust_lin_fact_neighbor_x : ST_PrSetCustVal?
  cust_lin_fact_neighbor_y : ST_PrSetCustVal?
  cust_rad_scale_rad : ST_PrSetCustVal?
  cust_rad_scale_inc : ST_PrSetCustVal?
  /// <presLayoutVars>? — CT_LayoutVariablePropertySet (optional).
  pres_layout_vars : CT_LayoutVariablePropertySet?
  /// <style>? — a:CT_ShapeStyle preserved raw.
  style : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ElemPropSet::new(
  element : @xml.Element,
) -> CT_ElemPropSet raise SchemaViolation {
  let pres_assoc_id = match attr(element, "presAssocID") {
    Some(v) => Some(ST_ModelId::parse(v))
    None => None
  }
  let pres_name = attr(element, "presName")
  let pres_style_lbl = attr(element, "presStyleLbl")
  let pres_style_idx = optional_int_opt(element, "presStyleIdx")
  let pres_style_cnt = optional_int_opt(element, "presStyleCnt")
  let lo_type_id = attr(element, "loTypeId")
  let lo_cat_id = attr(element, "loCatId")
  let qs_type_id = attr(element, "qsTypeId")
  let qs_cat_id = attr(element, "qsCatId")
  let cs_type_id = attr(element, "csTypeId")
  let cs_cat_id = attr(element, "csCatId")
  let coherent3d_off = optional_bool_opt(element, "coherent3DOff")
  let phldr_t = attr(element, "phldrT")
  let phldr = optional_bool_opt(element, "phldr")
  let cust_ang = optional_int_opt(element, "custAng")
  let cust_flip_vert = optional_bool_opt(element, "custFlipVert")
  let cust_flip_hor = optional_bool_opt(element, "custFlipHor")
  let cust_sz_x = optional_int_opt(element, "custSzX")
  let cust_sz_y = optional_int_opt(element, "custSzY")
  let cust_scale_x = optional_prset_custval(element, "custScaleX")
  let cust_scale_y = optional_prset_custval(element, "custScaleY")
  let cust_t = optional_bool_opt(element, "custT")
  let cust_lin_fact_x = optional_prset_custval(element, "custLinFactX")
  let cust_lin_fact_y = optional_prset_custval(element, "custLinFactY")
  let cust_lin_fact_neighbor_x = optional_prset_custval(
    element, "custLinFactNeighborX",
  )
  let cust_lin_fact_neighbor_y = optional_prset_custval(
    element, "custLinFactNeighborY",
  )
  let cust_rad_scale_rad = optional_prset_custval(element, "custRadScaleRad")
  let cust_rad_scale_inc = optional_prset_custval(element, "custRadScaleInc")
  let pres_layout_vars = decode_optional_child(
    element,
    "presLayoutVars",
    CT_LayoutVariablePropertySet::new,
  )
  let style = optional_child_element(element, "style")
  {
    pres_assoc_id,
    pres_name,
    pres_style_lbl,
    pres_style_idx,
    pres_style_cnt,
    lo_type_id,
    lo_cat_id,
    qs_type_id,
    qs_cat_id,
    cs_type_id,
    cs_cat_id,
    coherent3d_off,
    phldr_t,
    phldr,
    cust_ang,
    cust_flip_vert,
    cust_flip_hor,
    cust_sz_x,
    cust_sz_y,
    cust_scale_x,
    cust_scale_y,
    cust_t,
    cust_lin_fact_x,
    cust_lin_fact_y,
    cust_lin_fact_neighbor_x,
    cust_lin_fact_neighbor_y,
    cust_rad_scale_rad,
    cust_rad_scale_inc,
    pres_layout_vars,
    style,
    element,
  }
}

///|
pub fn CT_ElemPropSet::to_element(self : CT_ElemPropSet) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OrgChart — Part 1 §21.4.6.8 (orgChart).
/// Attributes: val (xsd:boolean, optional default=false). No
/// children.
pub(all) struct CT_OrgChart {
  /// @val — xsd:boolean (optional, default false).
  val : Bool
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OrgChart::new(
  element : @xml.Element,
) -> CT_OrgChart raise SchemaViolation {
  let val = optional_bool(element, "val", default=false)
  { val, element }
}

///|
pub fn CT_OrgChart::to_element(self : CT_OrgChart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ChildMax — Part 1 §21.4.6.4 (chMax).
/// Attributes: val (ST_NodeCount, optional default=-1). No children.
pub(all) struct CT_ChildMax {
  /// @val — ST_NodeCount (optional, default -1).
  val : ST_NodeCount
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChildMax::new(
  element : @xml.Element,
) -> CT_ChildMax raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_NodeCount::parse(v)
    None => ST_NodeCount::parse("-1")
  }
  { val, element }
}

///|
pub fn CT_ChildMax::to_element(self : CT_ChildMax) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ChildPref — Part 1 §21.4.6.5 (chPref).
/// Attributes: val (ST_NodeCount, optional default=-1). No children.
pub(all) struct CT_ChildPref {
  /// @val — ST_NodeCount (optional, default -1).
  val : ST_NodeCount
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ChildPref::new(
  element : @xml.Element,
) -> CT_ChildPref raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_NodeCount::parse(v)
    None => ST_NodeCount::parse("-1")
  }
  { val, element }
}

///|
pub fn CT_ChildPref::to_element(self : CT_ChildPref) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BulletEnabled — Part 1 §21.4.6.3
/// (bulletEnabled). Attributes: val (xsd:boolean, optional
/// default=false). No children.
pub(all) struct CT_BulletEnabled {
  /// @val — xsd:boolean (optional, default false).
  val : Bool
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BulletEnabled::new(
  element : @xml.Element,
) -> CT_BulletEnabled raise SchemaViolation {
  let val = optional_bool(element, "val", default=false)
  { val, element }
}

///|
pub fn CT_BulletEnabled::to_element(self : CT_BulletEnabled) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Direction — Part 1 §21.4.6.6 (dir).
/// Attributes: val (ST_Direction, optional default=norm). No
/// children.
pub(all) struct CT_Direction {
  /// @val — ST_Direction (optional, default norm).
  val : ST_Direction
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Direction::new(
  element : @xml.Element,
) -> CT_Direction raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_Direction::parse(v)
    None => DirectionNorm
  }
  { val, element }
}

///|
pub fn CT_Direction::to_element(self : CT_Direction) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HierBranchStyle — Part 1 §21.4.6.7
/// (hierBranch). Attributes: val (ST_HierBranchStyle, optional
/// default=std). No children.
pub(all) struct CT_HierBranchStyle {
  /// @val — ST_HierBranchStyle (optional, default std).
  val : ST_HierBranchStyle
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HierBranchStyle::new(
  element : @xml.Element,
) -> CT_HierBranchStyle raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_HierBranchStyle::parse(v)
    None => HierBranchStyleStd
  }
  { val, element }
}

///|
pub fn CT_HierBranchStyle::to_element(
  self : CT_HierBranchStyle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimOne — Part 1 §21.4.6.2 (animOne).
/// Attributes: val (ST_AnimOneStr, optional default=one). No
/// children.
pub(all) struct CT_AnimOne {
  /// @val — ST_AnimOneStr (optional, default one).
  val : ST_AnimOneStr
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimOne::new(
  element : @xml.Element,
) -> CT_AnimOne raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_AnimOneStr::parse(v)
    None => AnimOneStrOne
  }
  { val, element }
}

///|
pub fn CT_AnimOne::to_element(self : CT_AnimOne) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AnimLvl — Part 1 §21.4.6.1 (animLvl).
/// Attributes: val (ST_AnimLvlStr, optional default=none). No
/// children.
pub(all) struct CT_AnimLvl {
  /// @val — ST_AnimLvlStr (optional, default none).
  val : ST_AnimLvlStr
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AnimLvl::new(
  element : @xml.Element,
) -> CT_AnimLvl raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_AnimLvlStr::parse(v)
    None => AnimLvlStrNone
  }
  { val, element }
}

///|
pub fn CT_AnimLvl::to_element(self : CT_AnimLvl) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ResizeHandles — Part 1 §21.4.2.23
/// (resizeHandles). Attributes: val (ST_ResizeHandlesStr, optional
/// default=rel). No children.
pub(all) struct CT_ResizeHandles {
  /// @val — ST_ResizeHandlesStr (optional, default rel).
  val : ST_ResizeHandlesStr
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ResizeHandles::new(
  element : @xml.Element,
) -> CT_ResizeHandles raise SchemaViolation {
  let val = match attr(element, "val") {
    Some(v) => ST_ResizeHandlesStr::parse(v)
    None => ResizeHandlesStrRel
  }
  { val, element }
}

///|
pub fn CT_ResizeHandles::to_element(self : CT_ResizeHandles) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LayoutVariablePropertySet — Part 1 §21.4.5.4
/// (presLayoutVars) / §21.4.2.31 (varLst). No attributes. Children
/// (all optional, maxOccurs=1): orgChart (CT_OrgChart?), chMax
/// (CT_ChildMax?), chPref (CT_ChildPref?), bulletEnabled
/// (CT_BulletEnabled?), dir (CT_Direction?), hierBranch
/// (CT_HierBranchStyle?), animOne (CT_AnimOne?), animLvl
/// (CT_AnimLvl?), resizeHandles (CT_ResizeHandles?).
pub(all) struct CT_LayoutVariablePropertySet {
  /// <orgChart>? — CT_OrgChart.
  org_chart : CT_OrgChart?
  /// <chMax>? — CT_ChildMax.
  ch_max : CT_ChildMax?
  /// <chPref>? — CT_ChildPref.
  ch_pref : CT_ChildPref?
  /// <bulletEnabled>? — CT_BulletEnabled.
  bullet_enabled : CT_BulletEnabled?
  /// <dir>? — CT_Direction.
  dir : CT_Direction?
  /// <hierBranch>? — CT_HierBranchStyle.
  hier_branch : CT_HierBranchStyle?
  /// <animOne>? — CT_AnimOne.
  anim_one : CT_AnimOne?
  /// <animLvl>? — CT_AnimLvl.
  anim_lvl : CT_AnimLvl?
  /// <resizeHandles>? — CT_ResizeHandles.
  resize_handles : CT_ResizeHandles?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LayoutVariablePropertySet::new(
  element : @xml.Element,
) -> CT_LayoutVariablePropertySet raise SchemaViolation {
  let org_chart = decode_optional_child(element, "orgChart", CT_OrgChart::new)
  let ch_max = decode_optional_child(element, "chMax", CT_ChildMax::new)
  let ch_pref = decode_optional_child(element, "chPref", CT_ChildPref::new)
  let bullet_enabled = decode_optional_child(
    element,
    "bulletEnabled",
    CT_BulletEnabled::new,
  )
  let dir = decode_optional_child(element, "dir", CT_Direction::new)
  let hier_branch = decode_optional_child(
    element,
    "hierBranch",
    CT_HierBranchStyle::new,
  )
  let anim_one = decode_optional_child(element, "animOne", CT_AnimOne::new)
  let anim_lvl = decode_optional_child(element, "animLvl", CT_AnimLvl::new)
  let resize_handles = decode_optional_child(
    element,
    "resizeHandles",
    CT_ResizeHandles::new,
  )
  {
    org_chart,
    ch_max,
    ch_pref,
    bullet_enabled,
    dir,
    hier_branch,
    anim_one,
    anim_lvl,
    resize_handles,
    element,
  }
}

///|
pub fn CT_LayoutVariablePropertySet::to_element(
  self : CT_LayoutVariablePropertySet,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SDName — Part 1 §21.4.5.11 (title, style).
/// Attributes: lang (xsd:string, optional default=""), val
/// (xsd:string, required). No children.
pub(all) struct CT_SDName {
  /// @lang — xsd:string (optional, default "").
  lang : String
  /// @val — xsd:string (required).
  val : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SDName::new(
  element : @xml.Element,
) -> CT_SDName raise SchemaViolation {
  let lang = optional_string(element, "lang", default="")
  let val = required_string(element, "val", "CT_SDName/@val")
  { lang, val, element }
}

///|
pub fn CT_SDName::to_element(self : CT_SDName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SDDescription — Part 1 §21.4.5.3 (desc,
/// style). Attributes: lang (xsd:string, optional default=""), val
/// (xsd:string, required). No children.
pub(all) struct CT_SDDescription {
  /// @lang — xsd:string (optional, default "").
  lang : String
  /// @val — xsd:string (required).
  val : String
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SDDescription::new(
  element : @xml.Element,
) -> CT_SDDescription raise SchemaViolation {
  let lang = optional_string(element, "lang", default="")
  let val = required_string(element, "val", "CT_SDDescription/@val")
  { lang, val, element }
}

///|
pub fn CT_SDDescription::to_element(self : CT_SDDescription) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SDCategory — Part 1 §21.4.5.1 (cat, style).
/// Attributes: type (xsd:anyURI, required), pri (xsd:unsignedInt,
/// required). No children. Distinct from CT_Category to mirror
/// dml-diagram.xsd's separate definition for the style category
/// vocabulary.
pub(all) struct CT_SDCategory {
  /// @type — xsd:anyURI (required).
  type_ : String
  /// @pri — xsd:unsignedInt (required).
  pri : UInt
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SDCategory::new(
  element : @xml.Element,
) -> CT_SDCategory raise SchemaViolation {
  let type_ = required_string(element, "type", "CT_SDCategory/@type")
  let pri = required_uint(element, "pri", "CT_SDCategory/@pri")
  { type_, pri, element }
}

///|
pub fn CT_SDCategory::to_element(self : CT_SDCategory) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SDCategories — Part 1 §21.4.5.2 (catLst,
/// style). No attributes. Children: cat (CT_SDCategory*).
pub(all) struct CT_SDCategories {
  /// <cat>* — CT_SDCategory (zero or more).
  cat : Array[CT_SDCategory]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SDCategories::new(
  element : @xml.Element,
) -> CT_SDCategories raise SchemaViolation {
  let cat = decode_children(element, "cat", CT_SDCategory::new)
  { cat, element }
}

///|
pub fn CT_SDCategories::to_element(self : CT_SDCategories) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextProps — Part 1 §21.4.5.12 (txPr). No
/// attributes. Children: a:EG_Text3D? group (preserved as raw
/// elements — dml-main owns the typed CT_Scene3D/CT_Shape3D pair).
pub(all) struct CT_TextProps {
  /// <a:EG_Text3D> children preserved as raw elements.
  text3d : Array[@xml.Element]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextProps::new(element : @xml.Element) -> CT_TextProps {
  let text3d = element_children(element)
  { text3d, element }
}

///|
pub fn CT_TextProps::to_element(self : CT_TextProps) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleLabel — Part 1 §21.4.5.10 (styleLbl,
/// style). Attributes: name (xsd:string, required). Children:
/// scene3d (a:CT_Scene3D? preserved raw), sp3d (a:CT_Shape3D?
/// preserved raw), txPr (CT_TextProps?), style (a:CT_ShapeStyle?
/// preserved raw), extLst (raw).
pub(all) struct CT_StyleLabel {
  /// @name — xsd:string (required).
  name : String
  /// <scene3d>? — a:CT_Scene3D preserved raw.
  scene3d : @xml.Element?
  /// <sp3d>? — a:CT_Shape3D preserved raw.
  sp3d : @xml.Element?
  /// <txPr>? — CT_TextProps (optional).
  tx_pr : CT_TextProps?
  /// <style>? — a:CT_ShapeStyle preserved raw.
  style : @xml.Element?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleLabel::new(
  element : @xml.Element,
) -> CT_StyleLabel raise SchemaViolation {
  let name = required_string(element, "name", "CT_StyleLabel/@name")
  let scene3d = optional_child_element(element, "scene3d")
  let sp3d = optional_child_element(element, "sp3d")
  let tx_pr = decode_optional_child(element, "txPr", (e) => CT_TextProps::new(e))
  let style = optional_child_element(element, "style")
  let ext_lst = optional_child_element(element, "extLst")
  { name, scene3d, sp3d, tx_pr, style, ext_lst, element }
}

///|
pub fn CT_StyleLabel::to_element(self : CT_StyleLabel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleDefinition — Part 1 §21.4.5.7 (styleDef).
/// Attributes: uniqueId (xsd:string, optional default=""), minVer
/// (xsd:string, optional). Children: title (CT_SDName*), desc
/// (CT_SDDescription*), catLst (CT_SDCategories?), scene3d
/// (a:CT_Scene3D? preserved raw), styleLbl (CT_StyleLabel+ —
/// minOccurs=1), extLst (raw).
#alias(StyleDef)
pub(all) struct CT_StyleDefinition {
  /// @uniqueId — xsd:string (optional, default "").
  unique_id : String
  /// @minVer — xsd:string (optional).
  min_ver : String?
  /// <title>* — CT_SDName.
  title : Array[CT_SDName]
  /// <desc>* — CT_SDDescription.
  desc : Array[CT_SDDescription]
  /// <catLst>? — CT_SDCategories.
  cat_lst : CT_SDCategories?
  /// <scene3d>? — a:CT_Scene3D preserved raw.
  scene3d : @xml.Element?
  /// <styleLbl>+ — CT_StyleLabel (XSD declares minOccurs=1 but
  /// pre-existing wbtests omit it; the typed array tolerates the
  /// fixture practice while preserving order for callers that need
  /// the typed projection).
  style_lbl : Array[CT_StyleLabel]
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleDefinition::new(
  element : @xml.Element,
) -> CT_StyleDefinition raise SchemaViolation {
  let unique_id = optional_string(element, "uniqueId", default="")
  let min_ver = attr(element, "minVer")
  let title = decode_children(element, "title", CT_SDName::new)
  let desc = decode_children(element, "desc", CT_SDDescription::new)
  let cat_lst = decode_optional_child(element, "catLst", CT_SDCategories::new)
  let scene3d = optional_child_element(element, "scene3d")
  let style_lbl = decode_children(element, "styleLbl", CT_StyleLabel::new)
  let ext_lst = optional_child_element(element, "extLst")
  {
    unique_id,
    min_ver,
    title,
    desc,
    cat_lst,
    scene3d,
    style_lbl,
    ext_lst,
    element,
  }
}

///|
pub fn CT_StyleDefinition::to_element(
  self : CT_StyleDefinition,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleDefinitionHeader — Part 1 §21.4.5.8
/// (styleDefHdr). Attributes: uniqueId (xsd:string, required),
/// minVer (xsd:string, optional), resId (xsd:int, optional
/// default=0). Children: title (CT_SDName+ — minOccurs=1), desc
/// (CT_SDDescription+ — minOccurs=1), catLst (CT_SDCategories?),
/// extLst (raw).
#alias(StyleDefHdr)
pub(all) struct CT_StyleDefinitionHeader {
  /// @uniqueId — xsd:string (required).
  unique_id : String
  /// @minVer — xsd:string (optional).
  min_ver : String?
  /// @resId — xsd:int (optional, default 0).
  res_id : Int
  /// <title>+ — CT_SDName.
  title : Array[CT_SDName]
  /// <desc>+ — CT_SDDescription.
  desc : Array[CT_SDDescription]
  /// <catLst>? — CT_SDCategories.
  cat_lst : CT_SDCategories?
  /// <extLst>? — preserved raw.
  ext_lst : @xml.Element?
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleDefinitionHeader::new(
  element : @xml.Element,
) -> CT_StyleDefinitionHeader raise SchemaViolation {
  let unique_id = required_string(
    element, "uniqueId", "CT_StyleDefinitionHeader/@uniqueId",
  )
  let min_ver = attr(element, "minVer")
  let res_id = optional_int(element, "resId", default=0)
  let title = decode_children(element, "title", CT_SDName::new)
  let desc = decode_children(element, "desc", CT_SDDescription::new)
  let cat_lst = decode_optional_child(element, "catLst", CT_SDCategories::new)
  let ext_lst = optional_child_element(element, "extLst")
  { unique_id, min_ver, res_id, title, desc, cat_lst, ext_lst, element }
}

///|
pub fn CT_StyleDefinitionHeader::to_element(
  self : CT_StyleDefinitionHeader,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_StyleDefinitionHeaderLst — Part 1 §21.4.5.9
/// (styleDefHdrLst). No attributes. Children: styleDefHdr
/// (CT_StyleDefinitionHeader*).
#alias(StyleDefHdrLst)
pub(all) struct CT_StyleDefinitionHeaderLst {
  /// <styleDefHdr>* — CT_StyleDefinitionHeader.
  style_def_hdr : Array[CT_StyleDefinitionHeader]
  /// Preserved source element for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StyleDefinitionHeaderLst::new(
  element : @xml.Element,
) -> CT_StyleDefinitionHeaderLst raise SchemaViolation {
  let style_def_hdr = decode_children(
    element,
    "styleDefHdr",
    CT_StyleDefinitionHeader::new,
  )
  { style_def_hdr, element }
}

///|
pub fn CT_StyleDefinitionHeaderLst::to_element(
  self : CT_StyleDefinitionHeaderLst,
) -> @xml.Element {
  self.element
}

// ===========================================================================
// AG_* attribute groups (kept compatible with prior public surface).
// ===========================================================================

///|
/// XSD attribute group AG_ConstraintAttributes — Part 1 §21.4.2.8
/// constraint attribute group (type, for, forName, ptType).
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
/// XSD attribute group AG_ConstraintRefAttributes — Part 1 §21.4.2.8
/// constraint-reference attribute group (refType, refFor, refForName,
/// refPtType).
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

// ===========================================================================
// Top-level XSD element aliases — preserved for builder/reader callers.
// ===========================================================================

///|
/// Construct ColorsDef from a preserved XML element.
pub fn new_colors_def(
  element : @xml.Element,
) -> ColorsDef raise SchemaViolation {
  CT_ColorTransform::new(element)
}

///|
pub fn new_colors_def_hdr(
  element : @xml.Element,
) -> ColorsDefHdr raise SchemaViolation {
  CT_ColorTransformHeader::new(element)
}

///|
pub fn new_colors_def_hdr_lst(
  element : @xml.Element,
) -> ColorsDefHdrLst raise SchemaViolation {
  CT_ColorTransformHeaderLst::new(element)
}

///|
pub fn new_data_model(
  element : @xml.Element,
) -> DataModel raise SchemaViolation {
  CT_DataModel::new(element)
}

///|
pub fn new_layout_def(
  element : @xml.Element,
) -> LayoutDef raise SchemaViolation {
  CT_DiagramDefinition::new(element)
}

///|
pub fn new_layout_def_hdr(
  element : @xml.Element,
) -> LayoutDefHdr raise SchemaViolation {
  CT_DiagramDefinitionHeader::new(element)
}

///|
pub fn new_layout_def_hdr_lst(
  element : @xml.Element,
) -> LayoutDefHdrLst raise SchemaViolation {
  CT_DiagramDefinitionHeaderLst::new(element)
}

///|
pub fn new_rel_ids(element : @xml.Element) -> RelIds raise SchemaViolation {
  CT_RelIds::new(element)
}

///|
pub fn new_style_def(element : @xml.Element) -> StyleDef raise SchemaViolation {
  CT_StyleDefinition::new(element)
}

///|
pub fn new_style_def_hdr(
  element : @xml.Element,
) -> StyleDefHdr raise SchemaViolation {
  CT_StyleDefinitionHeader::new(element)
}

///|
pub fn new_style_def_hdr_lst(
  element : @xml.Element,
) -> StyleDefHdrLst raise SchemaViolation {
  CT_StyleDefinitionHeaderLst::new(element)
}

// ===========================================================================
// Legacy ::new wrappers preserved for outside callers (kept as thin shims).
// Attribute accessors that used to exist on CT_Adj / CT_Cxn / CT_Name /
// CT_Pt / CT_When are now replaced by the typed struct fields with the same
// canonical names (`idx`, `model_id`, `val`, `func`), so callers can read the
// typed value directly without an attribute helper.
// ===========================================================================

///|
pub fn new_ct_adj(element : @xml.Element) -> CT_Adj raise SchemaViolation {
  CT_Adj::new(element)
}

///|
pub fn new_ct_cxn(element : @xml.Element) -> CT_Cxn raise SchemaViolation {
  CT_Cxn::new(element)
}

///|
pub fn new_ct_pt(element : @xml.Element) -> CT_Pt raise SchemaViolation {
  CT_Pt::new(element)
}

///|
pub fn new_ct_when(element : @xml.Element) -> CT_When raise SchemaViolation {
  CT_When::new(element)
}

///|
/// Construct XSD attribute group AG_IteratorAttributes (§21.4) with no
/// iterator attributes set.
pub fn new_ag_iterator_attributes() -> AG_IteratorAttributes {
  AG_IteratorAttributes::empty()
}

// ===========================================================================
// Internal element-walk helpers used by the CT_* decoders above.
// ===========================================================================

///|
/// Look up a single attribute by local name. Returns the first match
/// because attribute order is not significant in XML (§3.1).
fn attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// Read an optional xsd:string attribute and substitute the spec
/// default when the attribute is absent.
fn optional_string(
  element : @xml.Element,
  local_name : String,
  default~ : String,
) -> String {
  match attr(element, local_name) {
    Some(v) => v
    None => default
  }
}

///|
/// Read a required xsd:string attribute. Raises SchemaViolation with
/// the supplied `path` (typically `CT_X/@name`) when the attribute is
/// absent.
fn required_string(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => v
    None =>
      raise SchemaViolation(
        schema="dml-diagram.xsd",
        path~,
        reason="missing required attribute @" + local_name,
      )
  }
}

///|
/// Read a required xsd:unsignedInt attribute. Raises SchemaViolation
/// when missing or when the lexical form is invalid.
fn required_uint(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> UInt raise SchemaViolation {
  let lexical = required_string(element, local_name, path)
  parse_uint_lex(lexical, path)
}

///|
/// Read an optional xsd:unsignedInt attribute, returning the spec
/// default when absent. Lexical validation raises SchemaViolation.
fn optional_uint(
  element : @xml.Element,
  local_name : String,
  default~ : UInt,
) -> UInt raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => parse_uint_lex(v, "CT_/@" + local_name)
    None => default
  }
}

///|
/// Read an optional xsd:int attribute, returning the spec default when
/// absent. Lexical validation raises SchemaViolation.
fn optional_int(
  element : @xml.Element,
  local_name : String,
  default~ : Int,
) -> Int raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => parse_int_lex(v, "CT_/@" + local_name)
    None => default
  }
}

///|
/// Read an optional xsd:int attribute without a default — returns
/// None when absent. Lexical validation raises SchemaViolation.
fn optional_int_opt(
  element : @xml.Element,
  local_name : String,
) -> Int? raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => Some(parse_int_lex(v, "CT_/@" + local_name))
    None => None
  }
}

///|
/// Read a required xsd:double attribute. Raises SchemaViolation when
/// missing or when the lexical form is invalid.
fn required_double(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Double raise SchemaViolation {
  let lexical = required_string(element, local_name, path)
  parse_double_lex(lexical, path)
}

///|
/// Read an optional xsd:double attribute, returning the spec default
/// when absent.
fn optional_double(
  element : @xml.Element,
  local_name : String,
  default~ : Double,
) -> Double raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => parse_double_lex(v, "CT_/@" + local_name)
    None => default
  }
}

///|
/// Read an optional xsd:double attribute without a default — returns
/// None when absent. Spec defaults of `NaN` are modelled this way so
/// callers can distinguish absent attributes from explicit zero values.
fn optional_double_opt(
  element : @xml.Element,
  local_name : String,
) -> Double? raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => Some(parse_double_lex(v, "CT_/@" + local_name))
    None => None
  }
}

///|
/// Read an optional xsd:boolean attribute, returning the spec default
/// when absent. Accepts both `true`/`false` and `1`/`0` per XSD.
fn optional_bool(
  element : @xml.Element,
  local_name : String,
  default~ : Bool,
) -> Bool raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => parse_bool_lex(v, "CT_/@" + local_name)
    None => default
  }
}

///|
/// Read an optional xsd:boolean attribute without a default — returns
/// None when absent.
fn optional_bool_opt(
  element : @xml.Element,
  local_name : String,
) -> Bool? raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => Some(parse_bool_lex(v, "CT_/@" + local_name))
    None => None
  }
}

///|
/// Read an optional ST_PrSetCustVal attribute, returning None when
/// absent. The lexical form is validated by ST_PrSetCustVal::parse.
fn optional_prset_custval(
  element : @xml.Element,
  local_name : String,
) -> ST_PrSetCustVal? raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => Some(ST_PrSetCustVal::parse(v))
    None => None
  }
}

///|
/// Parse an attribute that defaults to a lexical literal when absent.
/// Used by AG_IteratorAttributes-derived `axis` attributes.
fn parse_axis_types(
  element : @xml.Element,
  local_name : String,
  default_lex : String,
) -> ST_AxisTypes raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => ST_AxisTypes::parse(v)
    None => ST_AxisTypes::parse(default_lex)
  }
}

///|
/// Parse an attribute that defaults to a lexical literal when absent.
/// Used by AG_IteratorAttributes-derived `ptType` attributes.
fn parse_element_types(
  element : @xml.Element,
  local_name : String,
  default_lex : String,
) -> ST_ElementTypes raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => ST_ElementTypes::parse(v)
    None => ST_ElementTypes::parse(default_lex)
  }
}

///|
/// Parse an attribute that defaults to a lexical literal when absent.
/// Used by AG_IteratorAttributes-derived `hideLastTrans` attributes.
fn parse_booleans_default(
  element : @xml.Element,
  local_name : String,
  default_lex : String,
) -> ST_Booleans raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => ST_Booleans::parse(v)
    None => ST_Booleans::parse(default_lex)
  }
}

///|
/// Parse an attribute that defaults to a lexical literal when absent.
/// Used by AG_IteratorAttributes-derived `st`/`step` attributes.
fn parse_ints_default(
  element : @xml.Element,
  local_name : String,
  default_lex : String,
) -> ST_Ints raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => ST_Ints::parse(v)
    None => ST_Ints::parse(default_lex)
  }
}

///|
/// Parse an attribute that defaults to a lexical literal when absent.
/// Used by AG_IteratorAttributes-derived `cnt` attributes.
fn parse_unsigned_ints_default(
  element : @xml.Element,
  local_name : String,
  default_lex : String,
) -> ST_UnsignedInts raise SchemaViolation {
  match attr(element, local_name) {
    Some(v) => ST_UnsignedInts::parse(v)
    None => ST_UnsignedInts::parse(default_lex)
  }
}

///|
/// Find the first child element with the supplied local name and
/// return it as a raw `@xml.Element`. Used for children belonging to
/// other namespaces (`a:` dml-main / `r:` relationships) whose typed
/// projection lives outside this package.
fn optional_child_element(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if child.name.local_name == local_name {
          return Some(child)
        }
      _ => ()
    }
  }
  None
}

///|
/// Find the first child element with the supplied local name and
/// project it through the supplied decoder. Returns None when the
/// child is absent.
fn[T] decode_optional_child(
  element : @xml.Element,
  local_name : String,
  decoder : (@xml.Element) -> T raise SchemaViolation,
) -> T? raise SchemaViolation {
  match optional_child_element(element, local_name) {
    Some(child) => Some(decoder(child))
    None => None
  }
}

///|
/// Decode every child element with the supplied local name through
/// `decoder` and return them in document order.
fn[T] decode_children(
  element : @xml.Element,
  local_name : String,
  decoder : (@xml.Element) -> T raise SchemaViolation,
) -> Array[T] raise SchemaViolation {
  let result : Array[T] = []
  for node in element.children {
    match node {
      @xml.Element(child) =>
        if child.name.local_name == local_name {
          result.push(decoder(child))
        }
      _ => ()
    }
  }
  result
}

///|
/// Return every child element of `element` (skipping non-element
/// nodes). Used for CT_Colors and CT_TextProps where the schema
/// references an EG_* group whose typed projection lives in dml-main.
fn element_children(element : @xml.Element) -> Array[@xml.Element] {
  let result : Array[@xml.Element] = []
  for node in element.children {
    match node {
      @xml.Element(child) => result.push(child)
      _ => ()
    }
  }
  result
}

///|
/// Parse an xsd:unsignedInt lexical form. Raises SchemaViolation when
/// the value is signed or contains non-digits.
fn parse_uint_lex(value : String, path : String) -> UInt raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="empty xsd:unsignedInt lexical form",
    )
  }
  let mut acc : UInt = 0U
  for i in 0..<value.length() {
    let code = value.code_unit_at(i).to_int()
    if code < '0'.to_int() || code > '9'.to_int() {
      raise SchemaViolation(
        schema="dml-diagram.xsd",
        path~,
        reason="invalid xsd:unsignedInt lexical form: " + value,
      )
    }
    acc = acc * 10U + (code - '0'.to_int()).reinterpret_as_uint()
  }
  acc
}

///|
/// Parse an xsd:int lexical form. Raises SchemaViolation on invalid
/// values, accepting an optional sign character.
fn parse_int_lex(value : String, path : String) -> Int raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="empty xsd:int lexical form",
    )
  }
  let mut i = 0
  let mut sign = 1
  let first = value.code_unit_at(0).to_int()
  if first == '-'.to_int() {
    sign = -1
    i = 1
  } else if first == '+'.to_int() {
    i = 1
  }
  if i >= value.length() {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="invalid xsd:int lexical form: " + value,
    )
  }
  let mut acc = 0
  while i < value.length() {
    let code = value.code_unit_at(i).to_int()
    if code < '0'.to_int() || code > '9'.to_int() {
      raise SchemaViolation(
        schema="dml-diagram.xsd",
        path~,
        reason="invalid xsd:int lexical form: " + value,
      )
    }
    acc = acc * 10 + (code - '0'.to_int())
    i = i + 1
  }
  acc * sign
}

///|
/// Parse an xsd:double lexical form restricted to the common decimal
/// subset used by DiagramML attributes. Accepts optional sign and an
/// optional fractional part; rejects scientific notation and the
/// special INF / NaN tokens because the schema attributes never carry
/// them.
fn parse_double_lex(
  value : String,
  path : String,
) -> Double raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="empty xsd:double lexical form",
    )
  }
  let mut i = 0
  let mut sign = 1.0
  let first = value.code_unit_at(0).to_int()
  if first == '-'.to_int() {
    sign = -1.0
    i = 1
  } else if first == '+'.to_int() {
    i = 1
  }
  let start = i
  let mut integer_part = 0.0
  while i < value.length() {
    let code = value.code_unit_at(i).to_int()
    if code < '0'.to_int() || code > '9'.to_int() {
      break
    }
    integer_part = integer_part * 10.0 + (code - '0'.to_int()).to_double()
    i = i + 1
  }
  let int_count = i - start
  let mut fraction = 0.0
  let mut fraction_count = 0
  if i < value.length() && value.code_unit_at(i).to_int() == '.'.to_int() {
    i = i + 1
    let frac_start = i
    while i < value.length() {
      let code = value.code_unit_at(i).to_int()
      if code < '0'.to_int() || code > '9'.to_int() {
        break
      }
      fraction = fraction * 10.0 + (code - '0'.to_int()).to_double()
      i = i + 1
    }
    fraction_count = i - frac_start
  }
  if int_count == 0 && fraction_count == 0 {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="invalid xsd:double lexical form: " + value,
    )
  }
  if i != value.length() {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="invalid xsd:double lexical form: " + value,
    )
  }
  let mut divisor = 1.0
  for _ in 0..<fraction_count {
    divisor = divisor * 10.0
  }
  sign * (integer_part + fraction / divisor)
}

///|
/// Parse an xsd:boolean lexical form. Accepts both keyword and digit
/// forms per XSD §3.2.2.
fn parse_bool_lex(value : String, path : String) -> Bool raise SchemaViolation {
  match value {
    "true" | "1" => true
    "false" | "0" => false
    _ =>
      raise SchemaViolation(
        schema="dml-diagram.xsd",
        path~,
        reason="invalid xsd:boolean lexical form: " + value,
      )
  }
}
