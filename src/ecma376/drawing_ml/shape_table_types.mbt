// ECMA-376 Part 1 §20.1.2.2 / §20.1.4 / §20.1.5 / §20.1.3 DrawingML
// shape, non-visual, hyperlink, locking, graphical-object, and table
// complex types. XSD definitions live in Annex A.4.1 dml-main.xsd at
// the following line ranges:
//
//   CT_Hyperlink                          lines  710..723
//   CT_ConnectorLocking                   lines  739..744
//   CT_ShapeLocking                       lines  745..751
//   CT_PictureLocking                     lines  752..758
//   CT_GroupLocking                       lines  759..770
//   CT_GraphicalObjectFrameLocking        lines  771..781
//   CT_ContentPartLocking                 lines  782..787
//   CT_NonVisualDrawingProps              lines  788..799
//   CT_NonVisualDrawingShapeProps         lines  800..806
//   CT_NonVisualConnectorProperties       lines  807..814
//   CT_NonVisualPictureProperties         lines  815..821
//   CT_NonVisualGroupDrawingShapeProps    lines  822..827
//   CT_NonVisualGraphicFrameProperties    lines  828..834
//   CT_GraphicalObjectData                lines  842..847
//   CT_GraphicalObject                    lines  848..852
//   CT_ShapeProperties                    lines 2223..2235
//   CT_GroupShapeProperties               lines 2236..2245
//   CT_TableCellProperties                lines 2347..2369
//   CT_TableCol                           lines 2375..2380
//   CT_TableGrid                          lines 2381..2385
//   CT_TableCell                          lines 2386..2397
//   CT_TableRow                           lines 2398..2404
//   CT_TableProperties                    lines 2405..2422
//   CT_Table                              lines 2423..2429
//   CT_TableStyleTextStyle                lines 2471..2479
//   CT_TableCellBorderStyle               lines 2480..2492
//   CT_TableBackgroundStyle               lines 2493..2498
//   CT_TableStyleCellStyle                lines 2499..2505
//   CT_TablePartStyle                     lines 2506..2511
//   CT_TableStyle                         lines 2512..2532
//   CT_TableStyleList                     lines 2533..2538
//
// Per the ct-typing protocol each CT_X is projected as a typed struct
// with explicit attribute / child-element fields decoded from the
// source `@xml.Element`. The element is preserved so the builder can
// round-trip unmodelled content (the `to_element` writer returns the
// captured element verbatim).

// ---------------------------------------------------------------------
// §20.1.5 Shape properties (EG_ShapeProperties / EG_GroupShapeProperties)
// ---------------------------------------------------------------------

///|
/// XSD complex type CT_GroupShapeProperties — Part 1 §20.1.2.2.22
/// grpSpPr (Group Shape Properties). Annex A.4.1 lines 2236..2245.
/// Sequence: `xfrm` (CT_GroupTransform2D, optional),
/// EG_FillProperties choice (optional), EG_EffectProperties choice
/// (optional), `scene3d` (CT_Scene3D, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Attribute `bwMode`
/// (ST_BlackWhiteMode, optional).
pub(all) struct CT_GroupShapeProperties {
  /// <xfrm> (CT_GroupTransform2D) — optional.
  xfrm : CT_GroupTransform2D?
  /// <noFill> (CT_NoFillProperties) — EG_FillProperties choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) — EG_FillProperties arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) — EG_FillProperties arm.
  grad_fill : CT_GradientFillProperties?
  /// <blipFill> (CT_BlipFillProperties) — EG_FillProperties arm.
  blip_fill : CT_BlipFillProperties?
  /// <pattFill> (CT_PatternFillProperties) — EG_FillProperties arm.
  patt_fill : CT_PatternFillProperties?
  /// <grpFill> (CT_GroupFillProperties) — EG_FillProperties arm.
  grp_fill : CT_GroupFillProperties?
  /// <effectLst> (CT_EffectList) — EG_EffectProperties choice arm.
  effect_lst : CT_EffectList?
  /// <effectDag> (CT_EffectContainer) — EG_EffectProperties choice arm.
  effect_dag : CT_EffectContainer?
  /// <scene3d> (CT_Scene3D) — optional.
  scene3d : CT_Scene3D?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @bwMode — ST_BlackWhiteMode (optional).
  bw_mode : ST_BlackWhiteMode?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupShapeProperties::new(
  element : @xml.Element,
) -> CT_GroupShapeProperties raise SchemaViolation {
  let xfrm = ct_first_child(element, "xfrm").map(CT_GroupTransform2D::new)
  let no_fill = match ct_first_child(element, "noFill") {
    Some(c) => Some(CT_NoFillProperties::new(c))
    None => None
  }
  let solid_fill = match ct_first_child(element, "solidFill") {
    Some(c) => Some(CT_SolidColorFillProperties::new(c))
    None => None
  }
  let grad_fill = match ct_first_child(element, "gradFill") {
    Some(c) => Some(CT_GradientFillProperties::new(c))
    None => None
  }
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => Some(CT_BlipFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let grp_fill = match ct_first_child(element, "grpFill") {
    Some(c) => Some(CT_GroupFillProperties::new(c))
    None => None
  }
  let effect_lst = match ct_first_child(element, "effectLst") {
    Some(c) => Some(CT_EffectList::new(c))
    None => None
  }
  let effect_dag = match ct_first_child(element, "effectDag") {
    Some(c) => Some(CT_EffectContainer::new(c))
    None => None
  }
  let scene3d = ct_first_child(element, "scene3d").map(CT_Scene3D::new)
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let bw_mode = match ct_attr(element, "bwMode") {
    Some(v) => Some(ST_BlackWhiteMode::parse(v))
    None => None
  }
  {
    xfrm,
    no_fill,
    solid_fill,
    grad_fill,
    blip_fill,
    patt_fill,
    grp_fill,
    effect_lst,
    effect_dag,
    scene3d,
    ext_lst,
    bw_mode,
    element,
  }
}

///|
pub fn CT_GroupShapeProperties::to_element(
  self : CT_GroupShapeProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeProperties — Part 1 §20.1.2.2.35 spPr (Shape
/// Properties). Annex A.4.1 lines 2223..2235. Sequence: `xfrm`
/// (CT_Transform2D, optional), EG_Geometry choice (`custGeom`
/// CT_CustomGeometry2D | `prstGeom` CT_PresetGeometry2D, optional),
/// EG_FillProperties choice (optional), `ln` (CT_LineProperties,
/// optional), EG_EffectProperties choice (optional), `scene3d`
/// (CT_Scene3D, optional), `sp3d` (CT_Shape3D, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Attribute `bwMode`
/// (ST_BlackWhiteMode, optional).
pub(all) struct CT_ShapeProperties {
  /// <xfrm> (CT_Transform2D) — optional.
  xfrm : CT_Transform2D?
  /// <custGeom> (CT_CustomGeometry2D) — EG_Geometry choice arm.
  cust_geom : CT_CustomGeometry2D?
  /// <prstGeom> (CT_PresetGeometry2D) — EG_Geometry choice arm.
  prst_geom : CT_PresetGeometry2D?
  /// <noFill> (CT_NoFillProperties) — EG_FillProperties choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) — EG_FillProperties arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) — EG_FillProperties arm.
  grad_fill : CT_GradientFillProperties?
  /// <blipFill> (CT_BlipFillProperties) — EG_FillProperties arm.
  blip_fill : CT_BlipFillProperties?
  /// <pattFill> (CT_PatternFillProperties) — EG_FillProperties arm.
  patt_fill : CT_PatternFillProperties?
  /// <grpFill> (CT_GroupFillProperties) — EG_FillProperties arm.
  grp_fill : CT_GroupFillProperties?
  /// <ln> (CT_LineProperties) — optional.
  ln : CT_LineProperties?
  /// <effectLst> (CT_EffectList) — EG_EffectProperties choice arm.
  effect_lst : CT_EffectList?
  /// <effectDag> (CT_EffectContainer) — EG_EffectProperties choice arm.
  effect_dag : CT_EffectContainer?
  /// <scene3d> (CT_Scene3D) — optional.
  scene3d : CT_Scene3D?
  /// <sp3d> (CT_Shape3D) — optional.
  sp3d : CT_Shape3D?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @bwMode — ST_BlackWhiteMode (optional).
  bw_mode : ST_BlackWhiteMode?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeProperties::new(
  element : @xml.Element,
) -> CT_ShapeProperties raise SchemaViolation {
  let xfrm = ct_first_child(element, "xfrm").map(CT_Transform2D::new)
  let cust_geom = match ct_first_child(element, "custGeom") {
    Some(c) => Some(CT_CustomGeometry2D::new(c))
    None => None
  }
  let prst_geom = match ct_first_child(element, "prstGeom") {
    Some(c) => Some(CT_PresetGeometry2D::new(c))
    None => None
  }
  let no_fill = match ct_first_child(element, "noFill") {
    Some(c) => Some(CT_NoFillProperties::new(c))
    None => None
  }
  let solid_fill = match ct_first_child(element, "solidFill") {
    Some(c) => Some(CT_SolidColorFillProperties::new(c))
    None => None
  }
  let grad_fill = match ct_first_child(element, "gradFill") {
    Some(c) => Some(CT_GradientFillProperties::new(c))
    None => None
  }
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => Some(CT_BlipFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let grp_fill = match ct_first_child(element, "grpFill") {
    Some(c) => Some(CT_GroupFillProperties::new(c))
    None => None
  }
  let ln = match ct_first_child(element, "ln") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let effect_lst = match ct_first_child(element, "effectLst") {
    Some(c) => Some(CT_EffectList::new(c))
    None => None
  }
  let effect_dag = match ct_first_child(element, "effectDag") {
    Some(c) => Some(CT_EffectContainer::new(c))
    None => None
  }
  let scene3d = ct_first_child(element, "scene3d").map(CT_Scene3D::new)
  let sp3d = ct_first_child(element, "sp3d").map(CT_Shape3D::new)
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let bw_mode = match ct_attr(element, "bwMode") {
    Some(v) => Some(ST_BlackWhiteMode::parse(v))
    None => None
  }
  {
    xfrm,
    cust_geom,
    prst_geom,
    no_fill,
    solid_fill,
    grad_fill,
    blip_fill,
    patt_fill,
    grp_fill,
    ln,
    effect_lst,
    effect_dag,
    scene3d,
    sp3d,
    ext_lst,
    bw_mode,
    element,
  }
}

///|
pub fn CT_ShapeProperties::to_element(
  self : CT_ShapeProperties,
) -> @xml.Element {
  self.element
}

// ---------------------------------------------------------------------
// §20.1.2.2 Non-visual property containers
// ---------------------------------------------------------------------

///|
/// XSD complex type CT_NonVisualDrawingProps — Part 1 §20.1.2.2.8 cNvPr
/// (Common Non-Visual Drawing Properties). Annex A.4.1 lines 788..799.
/// Sequence: `hlinkClick` (CT_Hyperlink, optional), `hlinkHover`
/// (CT_Hyperlink, optional), `extLst` (CT_OfficeArtExtensionList,
/// optional). Required `id` (ST_DrawingElementId / xsd:unsignedInt),
/// required `name` (xsd:string); optional `descr` / `title` (xsd:string,
/// default `""`), `hidden` (xsd:boolean, default false).
pub(all) struct CT_NonVisualDrawingProps {
  /// <hlinkClick> (CT_Hyperlink) — optional.
  hlink_click : CT_Hyperlink?
  /// <hlinkHover> (CT_Hyperlink) — optional.
  hlink_hover : CT_Hyperlink?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @id — ST_DrawingElementId (xsd:unsignedInt, required).
  id : UInt
  /// @name — xsd:string (required).
  name : String
  /// @descr — xsd:string (optional, default "").
  descr : String
  /// @hidden — xsd:boolean (optional, default false).
  hidden : Bool
  /// @title — xsd:string (optional, default "").
  title : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualDrawingProps::new(
  element : @xml.Element,
) -> CT_NonVisualDrawingProps raise SchemaViolation {
  let hlink_click = match ct_first_child(element, "hlinkClick") {
    Some(c) => Some(CT_Hyperlink::new(c))
    None => None
  }
  let hlink_hover = match ct_first_child(element, "hlinkHover") {
    Some(c) => Some(CT_Hyperlink::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let id_lex = ct_required_string(element, "id", "CT_NonVisualDrawingProps/@id")
  let id = ct_parse_uint_lex(id_lex, "CT_NonVisualDrawingProps/@id")
  let name = ct_required_string(
    element, "name", "CT_NonVisualDrawingProps/@name",
  )
  let descr = ct_optional_string(element, "descr", default="")
  let hidden = ct_optional_bool(
    element,
    "hidden",
    default=false,
    "CT_NonVisualDrawingProps/@hidden",
  )
  let title = ct_optional_string(element, "title", default="")
  { hlink_click, hlink_hover, ext_lst, id, name, descr, hidden, title, element }
}

///|
pub fn CT_NonVisualDrawingProps::to_element(
  self : CT_NonVisualDrawingProps,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NonVisualDrawingShapeProps — Part 1 §20.1.2.2.9
/// cNvSpPr (Non-Visual Drawing Properties for a Shape). Annex A.4.1
/// lines 800..806. Sequence: `spLocks` (CT_ShapeLocking, optional),
/// `extLst` (CT_OfficeArtExtensionList, optional). Optional `txBox`
/// (xsd:boolean, default false) — whether the shape is a text box.
pub(all) struct CT_NonVisualDrawingShapeProps {
  /// <spLocks> (CT_ShapeLocking) — optional.
  sp_locks : CT_ShapeLocking?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @txBox — xsd:boolean (optional, default false).
  tx_box : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualDrawingShapeProps::new(
  element : @xml.Element,
) -> CT_NonVisualDrawingShapeProps raise SchemaViolation {
  let sp_locks = match ct_first_child(element, "spLocks") {
    Some(c) => Some(CT_ShapeLocking::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let tx_box = ct_optional_bool(
    element,
    "txBox",
    default=false,
    "CT_NonVisualDrawingShapeProps/@txBox",
  )
  { sp_locks, ext_lst, tx_box, element }
}

///|
pub fn CT_NonVisualDrawingShapeProps::to_element(
  self : CT_NonVisualDrawingShapeProps,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NonVisualConnectorProperties — Part 1
/// §20.1.2.2.4 cNvCxnSpPr (Non-Visual Connection Shape Properties).
/// Annex A.4.1 lines 807..814. Sequence: `cxnSpLocks`
/// (CT_ConnectorLocking, optional), `stCxn` (CT_Connection, optional),
/// `endCxn` (CT_Connection, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). No attributes.
pub(all) struct CT_NonVisualConnectorProperties {
  /// <cxnSpLocks> (CT_ConnectorLocking) — optional.
  cxn_sp_locks : CT_ConnectorLocking?
  /// <stCxn> (CT_Connection) — optional.
  st_cxn : CT_Connection?
  /// <endCxn> (CT_Connection) — optional.
  end_cxn : CT_Connection?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualConnectorProperties::new(
  element : @xml.Element,
) -> CT_NonVisualConnectorProperties raise SchemaViolation {
  let cxn_sp_locks = match ct_first_child(element, "cxnSpLocks") {
    Some(c) => Some(CT_ConnectorLocking::new(c))
    None => None
  }
  let st_cxn = ct_first_child(element, "stCxn").map(CT_Connection::new)
  let end_cxn = ct_first_child(element, "endCxn").map(CT_Connection::new)
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { cxn_sp_locks, st_cxn, end_cxn, ext_lst, element }
}

///|
pub fn CT_NonVisualConnectorProperties::to_element(
  self : CT_NonVisualConnectorProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NonVisualGraphicFrameProperties — Part 1
/// §20.1.2.2.5 cNvGraphicFramePr (Non-Visual Graphic Frame Properties).
/// Annex A.4.1 lines 828..834. Sequence: `graphicFrameLocks`
/// (CT_GraphicalObjectFrameLocking, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). No attributes.
pub(all) struct CT_NonVisualGraphicFrameProperties {
  /// <graphicFrameLocks> (CT_GraphicalObjectFrameLocking) — optional.
  graphic_frame_locks : CT_GraphicalObjectFrameLocking?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualGraphicFrameProperties::new(
  element : @xml.Element,
) -> CT_NonVisualGraphicFrameProperties raise SchemaViolation {
  let graphic_frame_locks = match ct_first_child(element, "graphicFrameLocks") {
    Some(c) => Some(CT_GraphicalObjectFrameLocking::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { graphic_frame_locks, ext_lst, element }
}

///|
pub fn CT_NonVisualGraphicFrameProperties::to_element(
  self : CT_NonVisualGraphicFrameProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NonVisualGroupDrawingShapeProps — Part 1
/// §20.1.2.2.6 cNvGrpSpPr (Non-Visual Group Drawing Shape Properties).
/// Annex A.4.1 lines 822..827. Sequence: `grpSpLocks` (CT_GroupLocking,
/// optional), `extLst` (CT_OfficeArtExtensionList, optional). No
/// attributes.
pub(all) struct CT_NonVisualGroupDrawingShapeProps {
  /// <grpSpLocks> (CT_GroupLocking) — optional.
  grp_sp_locks : CT_GroupLocking?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualGroupDrawingShapeProps::new(
  element : @xml.Element,
) -> CT_NonVisualGroupDrawingShapeProps raise SchemaViolation {
  let grp_sp_locks = match ct_first_child(element, "grpSpLocks") {
    Some(c) => Some(CT_GroupLocking::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  { grp_sp_locks, ext_lst, element }
}

///|
pub fn CT_NonVisualGroupDrawingShapeProps::to_element(
  self : CT_NonVisualGroupDrawingShapeProps,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NonVisualPictureProperties — Part 1 §20.1.2.2.7
/// cNvPicPr (Non-Visual Picture Properties). Annex A.4.1 lines
/// 815..821. Sequence: `picLocks` (CT_PictureLocking, optional),
/// `extLst` (CT_OfficeArtExtensionList, optional). Optional
/// `preferRelativeResize` (xsd:boolean, default true).
pub(all) struct CT_NonVisualPictureProperties {
  /// <picLocks> (CT_PictureLocking) — optional.
  pic_locks : CT_PictureLocking?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @preferRelativeResize — xsd:boolean (optional, default true).
  prefer_relative_resize : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NonVisualPictureProperties::new(
  element : @xml.Element,
) -> CT_NonVisualPictureProperties raise SchemaViolation {
  let pic_locks = match ct_first_child(element, "picLocks") {
    Some(c) => Some(CT_PictureLocking::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let prefer_relative_resize = ct_optional_bool(
    element,
    "preferRelativeResize",
    default=true,
    "CT_NonVisualPictureProperties/@preferRelativeResize",
  )
  { pic_locks, ext_lst, prefer_relative_resize, element }
}

///|
pub fn CT_NonVisualPictureProperties::to_element(
  self : CT_NonVisualPictureProperties,
) -> @xml.Element {
  self.element
}

// ---------------------------------------------------------------------
// §20.1.2.2 Graphical objects
// ---------------------------------------------------------------------

///|
/// XSD complex type CT_GraphicalObject — Part 1 §20.1.2.2.16 graphic
/// (Graphical Object). Annex A.4.1 lines 848..852. Sequence: `graphicData`
/// (CT_GraphicalObjectData) — exactly one (sole child).
pub(all) struct CT_GraphicalObject {
  /// <graphicData> (CT_GraphicalObjectData) — required.
  graphic_data : CT_GraphicalObjectData
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObject::new(
  element : @xml.Element,
) -> CT_GraphicalObject raise SchemaViolation {
  let graphic_data = match ct_first_child(element, "graphicData") {
    Some(c) => CT_GraphicalObjectData::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_GraphicalObject/graphicData",
        reason="missing required graphicData child element",
      )
  }
  { graphic_data, element }
}

///|
pub fn CT_GraphicalObject::to_element(
  self : CT_GraphicalObject,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GraphicalObjectData — Part 1 §20.1.2.2.17
/// graphicData (Graphical Object Data). Annex A.4.1 lines 842..847.
/// Sequence: open content (`xsd:any` 0..unbounded, processContents
/// strict). Required attribute `uri` (xsd:token) — namespace URI of
/// the embedded data payload.
pub(all) struct CT_GraphicalObjectData {
  /// @uri — xsd:token (required).
  uri : String
  /// Preserved source element so callers retain the strict-namespace
  /// `xsd:any` content for downstream interpretation.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectData::new(
  element : @xml.Element,
) -> CT_GraphicalObjectData raise SchemaViolation {
  let uri = ct_required_string(element, "uri", "CT_GraphicalObjectData/@uri")
  { uri, element }
}

///|
pub fn CT_GraphicalObjectData::to_element(
  self : CT_GraphicalObjectData,
) -> @xml.Element {
  self.element
}

// ---------------------------------------------------------------------
// §20.1.2.2 / §20.1.4 Locking complex types
// ---------------------------------------------------------------------

///|
/// XSD complex type CT_GraphicalObjectFrameLocking — Part 1 §20.1.2.2.19
/// graphicFrameLocks (Graphical Object Frame Locks). Annex A.4.1 lines
/// 771..781. Sequence: `extLst` (CT_OfficeArtExtensionList, optional).
/// Six optional boolean lock attributes (`noGrp`, `noDrilldown`,
/// `noSelect`, `noChangeAspect`, `noMove`, `noResize`) — all default
/// false.
pub(all) struct CT_GraphicalObjectFrameLocking {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @noGrp — xsd:boolean (optional, default false).
  no_grp : Bool
  /// @noDrilldown — xsd:boolean (optional, default false).
  no_drilldown : Bool
  /// @noSelect — xsd:boolean (optional, default false).
  no_select : Bool
  /// @noChangeAspect — xsd:boolean (optional, default false).
  no_change_aspect : Bool
  /// @noMove — xsd:boolean (optional, default false).
  no_move : Bool
  /// @noResize — xsd:boolean (optional, default false).
  no_resize : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GraphicalObjectFrameLocking::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameLocking raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let no_grp = ct_optional_bool(
    element,
    "noGrp",
    default=false,
    "CT_GraphicalObjectFrameLocking/@noGrp",
  )
  let no_drilldown = ct_optional_bool(
    element,
    "noDrilldown",
    default=false,
    "CT_GraphicalObjectFrameLocking/@noDrilldown",
  )
  let no_select = ct_optional_bool(
    element,
    "noSelect",
    default=false,
    "CT_GraphicalObjectFrameLocking/@noSelect",
  )
  let no_change_aspect = ct_optional_bool(
    element,
    "noChangeAspect",
    default=false,
    "CT_GraphicalObjectFrameLocking/@noChangeAspect",
  )
  let no_move = ct_optional_bool(
    element,
    "noMove",
    default=false,
    "CT_GraphicalObjectFrameLocking/@noMove",
  )
  let no_resize = ct_optional_bool(
    element,
    "noResize",
    default=false,
    "CT_GraphicalObjectFrameLocking/@noResize",
  )
  {
    ext_lst,
    no_grp,
    no_drilldown,
    no_select,
    no_change_aspect,
    no_move,
    no_resize,
    element,
  }
}

///|
pub fn CT_GraphicalObjectFrameLocking::to_element(
  self : CT_GraphicalObjectFrameLocking,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_GroupLocking — Part 1 §20.1.2.2.21 grpSpLocks
/// (Group Shape Locks). Annex A.4.1 lines 759..770. Sequence: `extLst`
/// (CT_OfficeArtExtensionList, optional). Seven optional boolean lock
/// attributes (`noGrp`, `noUngrp`, `noSelect`, `noRot`,
/// `noChangeAspect`, `noMove`, `noResize`) — all default false.
pub(all) struct CT_GroupLocking {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @noGrp — xsd:boolean (optional, default false).
  no_grp : Bool
  /// @noUngrp — xsd:boolean (optional, default false).
  no_ungrp : Bool
  /// @noSelect — xsd:boolean (optional, default false).
  no_select : Bool
  /// @noRot — xsd:boolean (optional, default false).
  no_rot : Bool
  /// @noChangeAspect — xsd:boolean (optional, default false).
  no_change_aspect : Bool
  /// @noMove — xsd:boolean (optional, default false).
  no_move : Bool
  /// @noResize — xsd:boolean (optional, default false).
  no_resize : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_GroupLocking::new(
  element : @xml.Element,
) -> CT_GroupLocking raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let no_grp = ct_optional_bool(
    element,
    "noGrp",
    default=false,
    "CT_GroupLocking/@noGrp",
  )
  let no_ungrp = ct_optional_bool(
    element,
    "noUngrp",
    default=false,
    "CT_GroupLocking/@noUngrp",
  )
  let no_select = ct_optional_bool(
    element,
    "noSelect",
    default=false,
    "CT_GroupLocking/@noSelect",
  )
  let no_rot = ct_optional_bool(
    element,
    "noRot",
    default=false,
    "CT_GroupLocking/@noRot",
  )
  let no_change_aspect = ct_optional_bool(
    element,
    "noChangeAspect",
    default=false,
    "CT_GroupLocking/@noChangeAspect",
  )
  let no_move = ct_optional_bool(
    element,
    "noMove",
    default=false,
    "CT_GroupLocking/@noMove",
  )
  let no_resize = ct_optional_bool(
    element,
    "noResize",
    default=false,
    "CT_GroupLocking/@noResize",
  )
  {
    ext_lst,
    no_grp,
    no_ungrp,
    no_select,
    no_rot,
    no_change_aspect,
    no_move,
    no_resize,
    element,
  }
}

///|
pub fn CT_GroupLocking::to_element(self : CT_GroupLocking) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeLocking — Part 1 §20.1.2.2.34 spLocks
/// (Shape Locks). Annex A.4.1 lines 745..751. Sequence: `extLst`
/// (CT_OfficeArtExtensionList, optional). Locking attributes from
/// AG_Locking (ten booleans, all default false) plus `noTextEdit`
/// (xsd:boolean, optional, default false).
pub(all) struct CT_ShapeLocking {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @noGrp — xsd:boolean (optional, default false).
  no_grp : Bool
  /// @noSelect — xsd:boolean (optional, default false).
  no_select : Bool
  /// @noRot — xsd:boolean (optional, default false).
  no_rot : Bool
  /// @noChangeAspect — xsd:boolean (optional, default false).
  no_change_aspect : Bool
  /// @noMove — xsd:boolean (optional, default false).
  no_move : Bool
  /// @noResize — xsd:boolean (optional, default false).
  no_resize : Bool
  /// @noEditPoints — xsd:boolean (optional, default false).
  no_edit_points : Bool
  /// @noAdjustHandles — xsd:boolean (optional, default false).
  no_adjust_handles : Bool
  /// @noChangeArrowheads — xsd:boolean (optional, default false).
  no_change_arrowheads : Bool
  /// @noChangeShapeType — xsd:boolean (optional, default false).
  no_change_shape_type : Bool
  /// @noTextEdit — xsd:boolean (optional, default false).
  no_text_edit : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeLocking::new(
  element : @xml.Element,
) -> CT_ShapeLocking raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let no_grp = ct_optional_bool(
    element,
    "noGrp",
    default=false,
    "CT_ShapeLocking/@noGrp",
  )
  let no_select = ct_optional_bool(
    element,
    "noSelect",
    default=false,
    "CT_ShapeLocking/@noSelect",
  )
  let no_rot = ct_optional_bool(
    element,
    "noRot",
    default=false,
    "CT_ShapeLocking/@noRot",
  )
  let no_change_aspect = ct_optional_bool(
    element,
    "noChangeAspect",
    default=false,
    "CT_ShapeLocking/@noChangeAspect",
  )
  let no_move = ct_optional_bool(
    element,
    "noMove",
    default=false,
    "CT_ShapeLocking/@noMove",
  )
  let no_resize = ct_optional_bool(
    element,
    "noResize",
    default=false,
    "CT_ShapeLocking/@noResize",
  )
  let no_edit_points = ct_optional_bool(
    element,
    "noEditPoints",
    default=false,
    "CT_ShapeLocking/@noEditPoints",
  )
  let no_adjust_handles = ct_optional_bool(
    element,
    "noAdjustHandles",
    default=false,
    "CT_ShapeLocking/@noAdjustHandles",
  )
  let no_change_arrowheads = ct_optional_bool(
    element,
    "noChangeArrowheads",
    default=false,
    "CT_ShapeLocking/@noChangeArrowheads",
  )
  let no_change_shape_type = ct_optional_bool(
    element,
    "noChangeShapeType",
    default=false,
    "CT_ShapeLocking/@noChangeShapeType",
  )
  let no_text_edit = ct_optional_bool(
    element,
    "noTextEdit",
    default=false,
    "CT_ShapeLocking/@noTextEdit",
  )
  {
    ext_lst,
    no_grp,
    no_select,
    no_rot,
    no_change_aspect,
    no_move,
    no_resize,
    no_edit_points,
    no_adjust_handles,
    no_change_arrowheads,
    no_change_shape_type,
    no_text_edit,
    element,
  }
}

///|
pub fn CT_ShapeLocking::to_element(self : CT_ShapeLocking) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ConnectorLocking — Part 1 §20.1.2.2.11
/// cxnSpLocks (Connection Shape Locks). Annex A.4.1 lines 739..744.
/// Sequence: `extLst` (CT_OfficeArtExtensionList, optional). AG_Locking
/// attribute group — ten optional boolean lock attributes (all default
/// false).
pub(all) struct CT_ConnectorLocking {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @noGrp — xsd:boolean (optional, default false).
  no_grp : Bool
  /// @noSelect — xsd:boolean (optional, default false).
  no_select : Bool
  /// @noRot — xsd:boolean (optional, default false).
  no_rot : Bool
  /// @noChangeAspect — xsd:boolean (optional, default false).
  no_change_aspect : Bool
  /// @noMove — xsd:boolean (optional, default false).
  no_move : Bool
  /// @noResize — xsd:boolean (optional, default false).
  no_resize : Bool
  /// @noEditPoints — xsd:boolean (optional, default false).
  no_edit_points : Bool
  /// @noAdjustHandles — xsd:boolean (optional, default false).
  no_adjust_handles : Bool
  /// @noChangeArrowheads — xsd:boolean (optional, default false).
  no_change_arrowheads : Bool
  /// @noChangeShapeType — xsd:boolean (optional, default false).
  no_change_shape_type : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ConnectorLocking::new(
  element : @xml.Element,
) -> CT_ConnectorLocking raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let no_grp = ct_optional_bool(
    element,
    "noGrp",
    default=false,
    "CT_ConnectorLocking/@noGrp",
  )
  let no_select = ct_optional_bool(
    element,
    "noSelect",
    default=false,
    "CT_ConnectorLocking/@noSelect",
  )
  let no_rot = ct_optional_bool(
    element,
    "noRot",
    default=false,
    "CT_ConnectorLocking/@noRot",
  )
  let no_change_aspect = ct_optional_bool(
    element,
    "noChangeAspect",
    default=false,
    "CT_ConnectorLocking/@noChangeAspect",
  )
  let no_move = ct_optional_bool(
    element,
    "noMove",
    default=false,
    "CT_ConnectorLocking/@noMove",
  )
  let no_resize = ct_optional_bool(
    element,
    "noResize",
    default=false,
    "CT_ConnectorLocking/@noResize",
  )
  let no_edit_points = ct_optional_bool(
    element,
    "noEditPoints",
    default=false,
    "CT_ConnectorLocking/@noEditPoints",
  )
  let no_adjust_handles = ct_optional_bool(
    element,
    "noAdjustHandles",
    default=false,
    "CT_ConnectorLocking/@noAdjustHandles",
  )
  let no_change_arrowheads = ct_optional_bool(
    element,
    "noChangeArrowheads",
    default=false,
    "CT_ConnectorLocking/@noChangeArrowheads",
  )
  let no_change_shape_type = ct_optional_bool(
    element,
    "noChangeShapeType",
    default=false,
    "CT_ConnectorLocking/@noChangeShapeType",
  )
  {
    ext_lst,
    no_grp,
    no_select,
    no_rot,
    no_change_aspect,
    no_move,
    no_resize,
    no_edit_points,
    no_adjust_handles,
    no_change_arrowheads,
    no_change_shape_type,
    element,
  }
}

///|
pub fn CT_ConnectorLocking::to_element(
  self : CT_ConnectorLocking,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PictureLocking — Part 1 §20.1.2.2.31 picLocks
/// (Picture Locks). Annex A.4.1 lines 752..758. Sequence: `extLst`
/// (CT_OfficeArtExtensionList, optional). AG_Locking attribute group
/// (ten booleans, all default false) plus `noCrop` (xsd:boolean,
/// optional, default false) — disables cropping.
pub(all) struct CT_PictureLocking {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @noGrp — xsd:boolean (optional, default false).
  no_grp : Bool
  /// @noSelect — xsd:boolean (optional, default false).
  no_select : Bool
  /// @noRot — xsd:boolean (optional, default false).
  no_rot : Bool
  /// @noChangeAspect — xsd:boolean (optional, default false).
  no_change_aspect : Bool
  /// @noMove — xsd:boolean (optional, default false).
  no_move : Bool
  /// @noResize — xsd:boolean (optional, default false).
  no_resize : Bool
  /// @noEditPoints — xsd:boolean (optional, default false).
  no_edit_points : Bool
  /// @noAdjustHandles — xsd:boolean (optional, default false).
  no_adjust_handles : Bool
  /// @noChangeArrowheads — xsd:boolean (optional, default false).
  no_change_arrowheads : Bool
  /// @noChangeShapeType — xsd:boolean (optional, default false).
  no_change_shape_type : Bool
  /// @noCrop — xsd:boolean (optional, default false).
  no_crop : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PictureLocking::new(
  element : @xml.Element,
) -> CT_PictureLocking raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let no_grp = ct_optional_bool(
    element,
    "noGrp",
    default=false,
    "CT_PictureLocking/@noGrp",
  )
  let no_select = ct_optional_bool(
    element,
    "noSelect",
    default=false,
    "CT_PictureLocking/@noSelect",
  )
  let no_rot = ct_optional_bool(
    element,
    "noRot",
    default=false,
    "CT_PictureLocking/@noRot",
  )
  let no_change_aspect = ct_optional_bool(
    element,
    "noChangeAspect",
    default=false,
    "CT_PictureLocking/@noChangeAspect",
  )
  let no_move = ct_optional_bool(
    element,
    "noMove",
    default=false,
    "CT_PictureLocking/@noMove",
  )
  let no_resize = ct_optional_bool(
    element,
    "noResize",
    default=false,
    "CT_PictureLocking/@noResize",
  )
  let no_edit_points = ct_optional_bool(
    element,
    "noEditPoints",
    default=false,
    "CT_PictureLocking/@noEditPoints",
  )
  let no_adjust_handles = ct_optional_bool(
    element,
    "noAdjustHandles",
    default=false,
    "CT_PictureLocking/@noAdjustHandles",
  )
  let no_change_arrowheads = ct_optional_bool(
    element,
    "noChangeArrowheads",
    default=false,
    "CT_PictureLocking/@noChangeArrowheads",
  )
  let no_change_shape_type = ct_optional_bool(
    element,
    "noChangeShapeType",
    default=false,
    "CT_PictureLocking/@noChangeShapeType",
  )
  let no_crop = ct_optional_bool(
    element,
    "noCrop",
    default=false,
    "CT_PictureLocking/@noCrop",
  )
  {
    ext_lst,
    no_grp,
    no_select,
    no_rot,
    no_change_aspect,
    no_move,
    no_resize,
    no_edit_points,
    no_adjust_handles,
    no_change_arrowheads,
    no_change_shape_type,
    no_crop,
    element,
  }
}

///|
pub fn CT_PictureLocking::to_element(self : CT_PictureLocking) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ContentPartLocking — Part 4 §17.x cpLocks
/// (Content Part Locks). Annex A.4.1 lines 782..787. Sequence:
/// `extLst` (CT_OfficeArtExtensionList, optional). AG_Locking attribute
/// group (ten optional booleans, all default false).
pub(all) struct CT_ContentPartLocking {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @noGrp — xsd:boolean (optional, default false).
  no_grp : Bool
  /// @noSelect — xsd:boolean (optional, default false).
  no_select : Bool
  /// @noRot — xsd:boolean (optional, default false).
  no_rot : Bool
  /// @noChangeAspect — xsd:boolean (optional, default false).
  no_change_aspect : Bool
  /// @noMove — xsd:boolean (optional, default false).
  no_move : Bool
  /// @noResize — xsd:boolean (optional, default false).
  no_resize : Bool
  /// @noEditPoints — xsd:boolean (optional, default false).
  no_edit_points : Bool
  /// @noAdjustHandles — xsd:boolean (optional, default false).
  no_adjust_handles : Bool
  /// @noChangeArrowheads — xsd:boolean (optional, default false).
  no_change_arrowheads : Bool
  /// @noChangeShapeType — xsd:boolean (optional, default false).
  no_change_shape_type : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ContentPartLocking::new(
  element : @xml.Element,
) -> CT_ContentPartLocking raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let no_grp = ct_optional_bool(
    element,
    "noGrp",
    default=false,
    "CT_ContentPartLocking/@noGrp",
  )
  let no_select = ct_optional_bool(
    element,
    "noSelect",
    default=false,
    "CT_ContentPartLocking/@noSelect",
  )
  let no_rot = ct_optional_bool(
    element,
    "noRot",
    default=false,
    "CT_ContentPartLocking/@noRot",
  )
  let no_change_aspect = ct_optional_bool(
    element,
    "noChangeAspect",
    default=false,
    "CT_ContentPartLocking/@noChangeAspect",
  )
  let no_move = ct_optional_bool(
    element,
    "noMove",
    default=false,
    "CT_ContentPartLocking/@noMove",
  )
  let no_resize = ct_optional_bool(
    element,
    "noResize",
    default=false,
    "CT_ContentPartLocking/@noResize",
  )
  let no_edit_points = ct_optional_bool(
    element,
    "noEditPoints",
    default=false,
    "CT_ContentPartLocking/@noEditPoints",
  )
  let no_adjust_handles = ct_optional_bool(
    element,
    "noAdjustHandles",
    default=false,
    "CT_ContentPartLocking/@noAdjustHandles",
  )
  let no_change_arrowheads = ct_optional_bool(
    element,
    "noChangeArrowheads",
    default=false,
    "CT_ContentPartLocking/@noChangeArrowheads",
  )
  let no_change_shape_type = ct_optional_bool(
    element,
    "noChangeShapeType",
    default=false,
    "CT_ContentPartLocking/@noChangeShapeType",
  )
  {
    ext_lst,
    no_grp,
    no_select,
    no_rot,
    no_change_aspect,
    no_move,
    no_resize,
    no_edit_points,
    no_adjust_handles,
    no_change_arrowheads,
    no_change_shape_type,
    element,
  }
}

///|
pub fn CT_ContentPartLocking::to_element(
  self : CT_ContentPartLocking,
) -> @xml.Element {
  self.element
}

// ---------------------------------------------------------------------
// §20.1.2.2.23 Hyperlink
// ---------------------------------------------------------------------

///|
/// XSD complex type CT_Hyperlink — Part 1 §20.1.2.2.23 hlinkClick /
/// hlinkHover (Hyperlink). Annex A.4.1 lines 710..723. Sequence: `snd`
/// (CT_EmbeddedWAVAudioFile, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Optional `r:id` (relationship
/// id, xsd:string), `invalidUrl`, `action`, `tgtFrame`, `tooltip`
/// (xsd:string, default `""`); plus booleans `history` (default true),
/// `highlightClick` (default false), `endSnd` (default false).
pub(all) struct CT_Hyperlink {
  /// <snd> (CT_EmbeddedWAVAudioFile) — optional click / hover sound.
  snd : CT_EmbeddedWAVAudioFile?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @r:id — xsd:string (optional, no schema default).
  r_id : String?
  /// @invalidUrl — xsd:string (optional, default "").
  invalid_url : String
  /// @action — xsd:string (optional, default "").
  action : String
  /// @tgtFrame — xsd:string (optional, default "").
  tgt_frame : String
  /// @tooltip — xsd:string (optional, default "").
  tooltip : String
  /// @history — xsd:boolean (optional, default true).
  history : Bool
  /// @highlightClick — xsd:boolean (optional, default false).
  highlight_click : Bool
  /// @endSnd — xsd:boolean (optional, default false).
  end_snd : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Hyperlink::new(
  element : @xml.Element,
) -> CT_Hyperlink raise SchemaViolation {
  let snd = match ct_first_child(element, "snd") {
    Some(c) => Some(CT_EmbeddedWAVAudioFile::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let r_id = ct_attr(element, "id")
  let invalid_url = ct_optional_string(element, "invalidUrl", default="")
  let action = ct_optional_string(element, "action", default="")
  let tgt_frame = ct_optional_string(element, "tgtFrame", default="")
  let tooltip = ct_optional_string(element, "tooltip", default="")
  let history = ct_optional_bool(
    element,
    "history",
    default=true,
    "CT_Hyperlink/@history",
  )
  let highlight_click = ct_optional_bool(
    element,
    "highlightClick",
    default=false,
    "CT_Hyperlink/@highlightClick",
  )
  let end_snd = ct_optional_bool(
    element,
    "endSnd",
    default=false,
    "CT_Hyperlink/@endSnd",
  )
  {
    snd,
    ext_lst,
    r_id,
    invalid_url,
    action,
    tgt_frame,
    tooltip,
    history,
    highlight_click,
    end_snd,
    element,
  }
}

///|
pub fn CT_Hyperlink::to_element(self : CT_Hyperlink) -> @xml.Element {
  self.element
}

// ---------------------------------------------------------------------
// §20.1.3 DrawingML Tables
// ---------------------------------------------------------------------

///|
/// XSD complex type CT_TableCellProperties — Part 1 §20.1.4.2.29 tcPr
/// (Table Cell Properties). Annex A.4.1 lines 2347..2369. Sequence:
/// six optional border line property elements (`lnL`, `lnR`, `lnT`,
/// `lnB`, `lnTlToBr`, `lnBlToTr` — all CT_LineProperties), `cell3D`
/// (CT_Cell3D, optional), EG_FillProperties choice (optional),
/// `headers` (CT_Headers, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Eight optional attributes:
/// `marL` / `marR` / `marT` / `marB` (ST_Coordinate32, defaults
/// 91440/91440/45720/45720), `vert` (ST_TextVerticalType, default
/// horz), `anchor` (ST_TextAnchoringType, default t), `anchorCtr`
/// (xsd:boolean, default false), `horzOverflow`
/// (ST_TextHorzOverflowType, default clip).
pub(all) struct CT_TableCellProperties {
  /// <lnL> (CT_LineProperties) — optional.
  ln_l : CT_LineProperties?
  /// <lnR> (CT_LineProperties) — optional.
  ln_r : CT_LineProperties?
  /// <lnT> (CT_LineProperties) — optional.
  ln_t : CT_LineProperties?
  /// <lnB> (CT_LineProperties) — optional.
  ln_b : CT_LineProperties?
  /// <lnTlToBr> (CT_LineProperties) — optional.
  ln_tl_to_br : CT_LineProperties?
  /// <lnBlToTr> (CT_LineProperties) — optional.
  ln_bl_to_tr : CT_LineProperties?
  /// <cell3D> (CT_Cell3D) — optional.
  cell3d : CT_Cell3D?
  /// <noFill> (CT_NoFillProperties) — EG_FillProperties choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) — EG_FillProperties arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) — EG_FillProperties arm.
  grad_fill : CT_GradientFillProperties?
  /// <blipFill> (CT_BlipFillProperties) — EG_FillProperties arm.
  blip_fill : CT_BlipFillProperties?
  /// <pattFill> (CT_PatternFillProperties) — EG_FillProperties arm.
  patt_fill : CT_PatternFillProperties?
  /// <grpFill> (CT_GroupFillProperties) — EG_FillProperties arm.
  grp_fill : CT_GroupFillProperties?
  /// <headers> (CT_Headers) — optional.
  headers : CT_Headers?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @marL — ST_Coordinate32 (optional, default 91440 EMU).
  mar_l : ST_Coordinate32
  /// @marR — ST_Coordinate32 (optional, default 91440 EMU).
  mar_r : ST_Coordinate32
  /// @marT — ST_Coordinate32 (optional, default 45720 EMU).
  mar_t : ST_Coordinate32
  /// @marB — ST_Coordinate32 (optional, default 45720 EMU).
  mar_b : ST_Coordinate32
  /// @vert — ST_TextVerticalType (optional, default horz).
  vert : ST_TextVerticalType
  /// @anchor — ST_TextAnchoringType (optional, default t).
  anchor : ST_TextAnchoringType
  /// @anchorCtr — xsd:boolean (optional, default false).
  anchor_ctr : Bool
  /// @horzOverflow — ST_TextHorzOverflowType (optional, default clip).
  horz_overflow : ST_TextHorzOverflowType
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCellProperties::new(
  element : @xml.Element,
) -> CT_TableCellProperties raise SchemaViolation {
  let ln_l = match ct_first_child(element, "lnL") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let ln_r = match ct_first_child(element, "lnR") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let ln_t = match ct_first_child(element, "lnT") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let ln_b = match ct_first_child(element, "lnB") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let ln_tl_to_br = match ct_first_child(element, "lnTlToBr") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let ln_bl_to_tr = match ct_first_child(element, "lnBlToTr") {
    Some(c) => Some(CT_LineProperties::new(c))
    None => None
  }
  let cell3d = ct_first_child(element, "cell3D").map(CT_Cell3D::new)
  let no_fill = match ct_first_child(element, "noFill") {
    Some(c) => Some(CT_NoFillProperties::new(c))
    None => None
  }
  let solid_fill = match ct_first_child(element, "solidFill") {
    Some(c) => Some(CT_SolidColorFillProperties::new(c))
    None => None
  }
  let grad_fill = match ct_first_child(element, "gradFill") {
    Some(c) => Some(CT_GradientFillProperties::new(c))
    None => None
  }
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => Some(CT_BlipFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let grp_fill = match ct_first_child(element, "grpFill") {
    Some(c) => Some(CT_GroupFillProperties::new(c))
    None => None
  }
  let headers = ct_first_child(element, "headers").map(CT_Headers::new)
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let mar_l = match ct_attr(element, "marL") {
    Some(v) => ST_Coordinate32::parse(v)
    None => ST_Coordinate32::parse("91440")
  }
  let mar_r = match ct_attr(element, "marR") {
    Some(v) => ST_Coordinate32::parse(v)
    None => ST_Coordinate32::parse("91440")
  }
  let mar_t = match ct_attr(element, "marT") {
    Some(v) => ST_Coordinate32::parse(v)
    None => ST_Coordinate32::parse("45720")
  }
  let mar_b = match ct_attr(element, "marB") {
    Some(v) => ST_Coordinate32::parse(v)
    None => ST_Coordinate32::parse("45720")
  }
  let vert = match ct_attr(element, "vert") {
    Some(v) => ST_TextVerticalType::parse(v)
    None => TextHorz
  }
  let anchor = match ct_attr(element, "anchor") {
    Some(v) => ST_TextAnchoringType::parse(v)
    None => AnchorTop
  }
  let anchor_ctr = ct_optional_bool(
    element,
    "anchorCtr",
    default=false,
    "CT_TableCellProperties/@anchorCtr",
  )
  let horz_overflow = match ct_attr(element, "horzOverflow") {
    Some(v) => ST_TextHorzOverflowType::parse(v)
    None => HorzClip
  }
  {
    ln_l,
    ln_r,
    ln_t,
    ln_b,
    ln_tl_to_br,
    ln_bl_to_tr,
    cell3d,
    no_fill,
    solid_fill,
    grad_fill,
    blip_fill,
    patt_fill,
    grp_fill,
    headers,
    ext_lst,
    mar_l,
    mar_r,
    mar_t,
    mar_b,
    vert,
    anchor,
    anchor_ctr,
    horz_overflow,
    element,
  }
}

///|
pub fn CT_TableCellProperties::to_element(
  self : CT_TableCellProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableCol — Part 1 §20.1.4.2.5 gridCol (Table
/// Grid Column). Annex A.4.1 lines 2375..2380. Sequence: `extLst`
/// (CT_OfficeArtExtensionList, optional). Required `w` (ST_Coordinate)
/// — the column width in EMU.
pub(all) struct CT_TableCol {
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @w — ST_Coordinate (required).
  w : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCol::new(
  element : @xml.Element,
) -> CT_TableCol raise SchemaViolation {
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let w_lex = ct_required_string(element, "w", "CT_TableCol/@w")
  let w = ST_Coordinate::parse(w_lex)
  { ext_lst, w, element }
}

///|
pub fn CT_TableCol::to_element(self : CT_TableCol) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableGrid — Part 1 §20.1.4.2.10 tblGrid (Table
/// Grid). Annex A.4.1 lines 2381..2385. Sequence: `gridCol` (CT_TableCol,
/// zero or more).
pub(all) struct CT_TableGrid {
  /// <gridCol>* (CT_TableCol) — zero or more columns in document order.
  grid_col : Array[CT_TableCol]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableGrid::new(
  element : @xml.Element,
) -> CT_TableGrid raise SchemaViolation {
  let grid_col : Array[CT_TableCol] = []
  for child in ct_children(element, "gridCol") {
    grid_col.push(CT_TableCol::new(child))
  }
  { grid_col, element }
}

///|
pub fn CT_TableGrid::to_element(self : CT_TableGrid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableCell — Part 1 §20.1.4.2.21 tc (Table Cell).
/// Annex A.4.1 lines 2386..2397. Sequence: `txBody` (CT_TextBody,
/// optional), `tcPr` (CT_TableCellProperties, optional), `extLst`
/// (CT_OfficeArtExtensionList, optional). Five optional attributes:
/// `rowSpan` / `gridSpan` (xsd:int, default 1), `hMerge` / `vMerge`
/// (xsd:boolean, default false), `id` (xsd:string, no default).
pub(all) struct CT_TableCell {
  /// <txBody> (CT_TextBody) — optional cell text body.
  tx_body : CT_TextBody?
  /// <tcPr> (CT_TableCellProperties) — optional.
  tc_pr : CT_TableCellProperties?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @rowSpan — xsd:int (optional, default 1).
  row_span : Int
  /// @gridSpan — xsd:int (optional, default 1).
  grid_span : Int
  /// @hMerge — xsd:boolean (optional, default false).
  h_merge : Bool
  /// @vMerge — xsd:boolean (optional, default false).
  v_merge : Bool
  /// @id — xsd:string (optional, no schema default).
  id : String?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCell::new(
  element : @xml.Element,
) -> CT_TableCell raise SchemaViolation {
  let tx_body = ct_first_child(element, "txBody").map(CT_TextBody::new)
  let tc_pr = match ct_first_child(element, "tcPr") {
    Some(c) => Some(CT_TableCellProperties::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let row_span = ct_optional_int(
    element,
    "rowSpan",
    default=1,
    "CT_TableCell/@rowSpan",
  )
  let grid_span = ct_optional_int(
    element,
    "gridSpan",
    default=1,
    "CT_TableCell/@gridSpan",
  )
  let h_merge = ct_optional_bool(
    element,
    "hMerge",
    default=false,
    "CT_TableCell/@hMerge",
  )
  let v_merge = ct_optional_bool(
    element,
    "vMerge",
    default=false,
    "CT_TableCell/@vMerge",
  )
  let id = ct_attr(element, "id")
  {
    tx_body,
    tc_pr,
    ext_lst,
    row_span,
    grid_span,
    h_merge,
    v_merge,
    id,
    element,
  }
}

///|
pub fn CT_TableCell::to_element(self : CT_TableCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableRow — Part 1 §20.1.4.2.22 tr (Table Row).
/// Annex A.4.1 lines 2398..2404. Sequence: `tc` (CT_TableCell, zero or
/// more), `extLst` (CT_OfficeArtExtensionList, optional). Required `h`
/// (ST_Coordinate) — the row height in EMU.
pub(all) struct CT_TableRow {
  /// <tc>* (CT_TableCell) — zero or more cells in document order.
  tc : Array[CT_TableCell]
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @h — ST_Coordinate (required).
  h : ST_Coordinate
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableRow::new(
  element : @xml.Element,
) -> CT_TableRow raise SchemaViolation {
  let tc : Array[CT_TableCell] = []
  for child in ct_children(element, "tc") {
    tc.push(CT_TableCell::new(child))
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let h_lex = ct_required_string(element, "h", "CT_TableRow/@h")
  let h = ST_Coordinate::parse(h_lex)
  { tc, ext_lst, h, element }
}

///|
pub fn CT_TableRow::to_element(self : CT_TableRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableProperties — Part 1 §20.1.4.2.18 tblPr
/// (Table Properties). Annex A.4.1 lines 2405..2422. Sequence:
/// EG_FillProperties choice (optional), EG_EffectProperties choice
/// (optional), choice (`tableStyle` CT_TableStyle | `tableStyleId`
/// s:ST_Guid, optional), `extLst` (CT_OfficeArtExtensionList,
/// optional). Seven optional boolean attributes — `rtl`, `firstRow`,
/// `firstCol`, `lastRow`, `lastCol`, `bandRow`, `bandCol` — all default
/// false.
pub(all) struct CT_TableProperties {
  /// <noFill> (CT_NoFillProperties) — EG_FillProperties choice arm.
  no_fill : CT_NoFillProperties?
  /// <solidFill> (CT_SolidColorFillProperties) — EG_FillProperties arm.
  solid_fill : CT_SolidColorFillProperties?
  /// <gradFill> (CT_GradientFillProperties) — EG_FillProperties arm.
  grad_fill : CT_GradientFillProperties?
  /// <blipFill> (CT_BlipFillProperties) — EG_FillProperties arm.
  blip_fill : CT_BlipFillProperties?
  /// <pattFill> (CT_PatternFillProperties) — EG_FillProperties arm.
  patt_fill : CT_PatternFillProperties?
  /// <grpFill> (CT_GroupFillProperties) — EG_FillProperties arm.
  grp_fill : CT_GroupFillProperties?
  /// <effectLst> (CT_EffectList) — EG_EffectProperties arm.
  effect_lst : CT_EffectList?
  /// <effectDag> (CT_EffectContainer) — EG_EffectProperties arm.
  effect_dag : CT_EffectContainer?
  /// <tableStyle> (CT_TableStyle) — choice arm.
  table_style : CT_TableStyle?
  /// <tableStyleId> (s:ST_Guid encoded as String) — choice arm.
  table_style_id : String?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @rtl — xsd:boolean (optional, default false).
  rtl : Bool
  /// @firstRow — xsd:boolean (optional, default false).
  first_row : Bool
  /// @firstCol — xsd:boolean (optional, default false).
  first_col : Bool
  /// @lastRow — xsd:boolean (optional, default false).
  last_row : Bool
  /// @lastCol — xsd:boolean (optional, default false).
  last_col : Bool
  /// @bandRow — xsd:boolean (optional, default false).
  band_row : Bool
  /// @bandCol — xsd:boolean (optional, default false).
  band_col : Bool
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableProperties::new(
  element : @xml.Element,
) -> CT_TableProperties raise SchemaViolation {
  let no_fill = match ct_first_child(element, "noFill") {
    Some(c) => Some(CT_NoFillProperties::new(c))
    None => None
  }
  let solid_fill = match ct_first_child(element, "solidFill") {
    Some(c) => Some(CT_SolidColorFillProperties::new(c))
    None => None
  }
  let grad_fill = match ct_first_child(element, "gradFill") {
    Some(c) => Some(CT_GradientFillProperties::new(c))
    None => None
  }
  let blip_fill = match ct_first_child(element, "blipFill") {
    Some(c) => Some(CT_BlipFillProperties::new(c))
    None => None
  }
  let patt_fill = match ct_first_child(element, "pattFill") {
    Some(c) => Some(CT_PatternFillProperties::new(c))
    None => None
  }
  let grp_fill = match ct_first_child(element, "grpFill") {
    Some(c) => Some(CT_GroupFillProperties::new(c))
    None => None
  }
  let effect_lst = match ct_first_child(element, "effectLst") {
    Some(c) => Some(CT_EffectList::new(c))
    None => None
  }
  let effect_dag = match ct_first_child(element, "effectDag") {
    Some(c) => Some(CT_EffectContainer::new(c))
    None => None
  }
  let table_style = match ct_first_child(element, "tableStyle") {
    Some(c) => Some(CT_TableStyle::new(c))
    None => None
  }
  let table_style_id = match ct_first_child(element, "tableStyleId") {
    Some(c) => Some(text_content(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let rtl = ct_optional_bool(
    element,
    "rtl",
    default=false,
    "CT_TableProperties/@rtl",
  )
  let first_row = ct_optional_bool(
    element,
    "firstRow",
    default=false,
    "CT_TableProperties/@firstRow",
  )
  let first_col = ct_optional_bool(
    element,
    "firstCol",
    default=false,
    "CT_TableProperties/@firstCol",
  )
  let last_row = ct_optional_bool(
    element,
    "lastRow",
    default=false,
    "CT_TableProperties/@lastRow",
  )
  let last_col = ct_optional_bool(
    element,
    "lastCol",
    default=false,
    "CT_TableProperties/@lastCol",
  )
  let band_row = ct_optional_bool(
    element,
    "bandRow",
    default=false,
    "CT_TableProperties/@bandRow",
  )
  let band_col = ct_optional_bool(
    element,
    "bandCol",
    default=false,
    "CT_TableProperties/@bandCol",
  )
  {
    no_fill,
    solid_fill,
    grad_fill,
    blip_fill,
    patt_fill,
    grp_fill,
    effect_lst,
    effect_dag,
    table_style,
    table_style_id,
    ext_lst,
    rtl,
    first_row,
    first_col,
    last_row,
    last_col,
    band_row,
    band_col,
    element,
  }
}

///|
pub fn CT_TableProperties::to_element(
  self : CT_TableProperties,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Table — Part 1 §20.1.4.2.19 tbl (Table). Annex
/// A.4.1 lines 2423..2429. Sequence: `tblPr` (CT_TableProperties,
/// optional), `tblGrid` (CT_TableGrid, required, exactly one), `tr`
/// (CT_TableRow, zero or more).
pub(all) struct CT_Table {
  /// <tblPr> (CT_TableProperties) — optional.
  tbl_pr : CT_TableProperties?
  /// <tblGrid> (CT_TableGrid) — required.
  tbl_grid : CT_TableGrid
  /// <tr>* (CT_TableRow) — zero or more rows in document order.
  tr : Array[CT_TableRow]
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Table::new(element : @xml.Element) -> CT_Table raise SchemaViolation {
  let tbl_pr = match ct_first_child(element, "tblPr") {
    Some(c) => Some(CT_TableProperties::new(c))
    None => None
  }
  let tbl_grid = match ct_first_child(element, "tblGrid") {
    Some(c) => CT_TableGrid::new(c)
    None =>
      raise SchemaViolation(
        schema="dml-main.xsd",
        path="CT_Table/tblGrid",
        reason="missing required tblGrid child element",
      )
  }
  let tr : Array[CT_TableRow] = []
  for child in ct_children(element, "tr") {
    tr.push(CT_TableRow::new(child))
  }
  { tbl_pr, tbl_grid, tr, element }
}

///|
pub fn CT_Table::to_element(self : CT_Table) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableStyleTextStyle — Part 1 §20.1.4.2.26
/// tcTxStyle (Table Cell Text Style). Annex A.4.1 lines 2471..2479.
/// Sequence: EG_ThemeableFontStyles choice (`font` CT_FontCollection |
/// `fontRef` CT_FontReference, optional), EG_ColorChoice (optional,
/// captured as CT_Color projection), `extLst`
/// (CT_OfficeArtExtensionList, optional). Optional `b` / `i`
/// (ST_OnOffStyleType, default def).
pub(all) struct CT_TableStyleTextStyle {
  /// <font> (CT_FontCollection) — EG_ThemeableFontStyles choice arm.
  font : CT_FontCollection?
  /// <fontRef> (CT_FontReference) — EG_ThemeableFontStyles choice arm.
  font_ref : CT_FontReference?
  /// EG_ColorChoice — optional CT_Color projection over the colour
  /// choice child element (scrgbClr / srgbClr / hslClr / sysClr /
  /// schemeClr / prstClr).
  color : CT_Color?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @b — ST_OnOffStyleType (optional, default def).
  b : ST_OnOffStyleType
  /// @i — ST_OnOffStyleType (optional, default def).
  i : ST_OnOffStyleType
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleTextStyle::new(
  element : @xml.Element,
) -> CT_TableStyleTextStyle raise SchemaViolation {
  let font = match ct_first_child(element, "font") {
    Some(c) => Some(CT_FontCollection::new(c))
    None => None
  }
  let font_ref = match ct_first_child(element, "fontRef") {
    Some(c) => Some(CT_FontReference::new(c))
    None => None
  }
  let color = if has_any_color_choice_child(element) {
    Some(CT_Color::new(element))
  } else {
    None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let b = match ct_attr(element, "b") {
    Some(v) => ST_OnOffStyleType::parse(v)
    None => OnOffStyleDef
  }
  let i = match ct_attr(element, "i") {
    Some(v) => ST_OnOffStyleType::parse(v)
    None => OnOffStyleDef
  }
  { font, font_ref, color, ext_lst, b, i, element }
}

///|
pub fn CT_TableStyleTextStyle::to_element(
  self : CT_TableStyleTextStyle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableCellBorderStyle — Part 1 §20.1.4.2.20
/// tcBdr (Table Cell Border Style). Annex A.4.1 lines 2480..2492.
/// Sequence: eight optional themed-line wrappers (`left`, `right`,
/// `top`, `bottom`, `insideH`, `insideV`, `tl2br`, `tr2bl` — all
/// CT_ThemeableLineStyle), `extLst` (CT_OfficeArtExtensionList,
/// optional). No attributes.
pub(all) struct CT_TableCellBorderStyle {
  /// <left> (CT_ThemeableLineStyle) — optional.
  left : CT_ThemeableLineStyle?
  /// <right> (CT_ThemeableLineStyle) — optional.
  right : CT_ThemeableLineStyle?
  /// <top> (CT_ThemeableLineStyle) — optional.
  top : CT_ThemeableLineStyle?
  /// <bottom> (CT_ThemeableLineStyle) — optional.
  bottom : CT_ThemeableLineStyle?
  /// <insideH> (CT_ThemeableLineStyle) — optional.
  inside_h : CT_ThemeableLineStyle?
  /// <insideV> (CT_ThemeableLineStyle) — optional.
  inside_v : CT_ThemeableLineStyle?
  /// <tl2br> (CT_ThemeableLineStyle) — optional.
  tl2br : CT_ThemeableLineStyle?
  /// <tr2bl> (CT_ThemeableLineStyle) — optional.
  tr2bl : CT_ThemeableLineStyle?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableCellBorderStyle::new(
  element : @xml.Element,
) -> CT_TableCellBorderStyle raise SchemaViolation {
  let left = ct_first_child(element, "left").map(CT_ThemeableLineStyle::new)
  let right = ct_first_child(element, "right").map(CT_ThemeableLineStyle::new)
  let top = ct_first_child(element, "top").map(CT_ThemeableLineStyle::new)
  let bottom = ct_first_child(element, "bottom").map(CT_ThemeableLineStyle::new)
  let inside_h = ct_first_child(element, "insideH").map(
    CT_ThemeableLineStyle::new,
  )
  let inside_v = ct_first_child(element, "insideV").map(
    CT_ThemeableLineStyle::new,
  )
  let tl2br = ct_first_child(element, "tl2br").map(CT_ThemeableLineStyle::new)
  let tr2bl = ct_first_child(element, "tr2bl").map(CT_ThemeableLineStyle::new)
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  {
    left,
    right,
    top,
    bottom,
    inside_h,
    inside_v,
    tl2br,
    tr2bl,
    ext_lst,
    element,
  }
}

///|
pub fn CT_TableCellBorderStyle::to_element(
  self : CT_TableCellBorderStyle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableBackgroundStyle — Part 1 §20.1.4.2.25
/// tblBg (Table Background Style). Annex A.4.1 lines 2493..2498.
/// Sequence: EG_ThemeableFillStyle choice (`fill` CT_FillProperties |
/// `fillRef` CT_StyleMatrixReference, optional), EG_ThemeableEffectStyle
/// choice (`effect` CT_EffectProperties | `effectRef`
/// CT_StyleMatrixReference, optional). No attributes.
pub(all) struct CT_TableBackgroundStyle {
  /// <fill> (CT_FillProperties) — EG_ThemeableFillStyle choice arm.
  fill : CT_FillProperties?
  /// <fillRef> (CT_StyleMatrixReference) — EG_ThemeableFillStyle arm.
  fill_ref : CT_StyleMatrixReference?
  /// <effect> (CT_EffectProperties) — EG_ThemeableEffectStyle arm.
  effect : CT_EffectProperties?
  /// <effectRef> (CT_StyleMatrixReference) — EG_ThemeableEffectStyle arm.
  effect_ref : CT_StyleMatrixReference?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableBackgroundStyle::new(
  element : @xml.Element,
) -> CT_TableBackgroundStyle raise SchemaViolation {
  let fill = match ct_first_child(element, "fill") {
    Some(c) => Some(CT_FillProperties::new(c))
    None => None
  }
  let fill_ref = ct_first_child(element, "fillRef").map(
    CT_StyleMatrixReference::new,
  )
  let effect = match ct_first_child(element, "effect") {
    Some(c) => Some(CT_EffectProperties::new(c))
    None => None
  }
  let effect_ref = ct_first_child(element, "effectRef").map(
    CT_StyleMatrixReference::new,
  )
  { fill, fill_ref, effect, effect_ref, element }
}

///|
pub fn CT_TableBackgroundStyle::to_element(
  self : CT_TableBackgroundStyle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableStyleCellStyle — Part 1 §20.1.4.2.24
/// tcStyle (Table Cell Style). Annex A.4.1 lines 2499..2505. Sequence:
/// `tcBdr` (CT_TableCellBorderStyle, optional), EG_ThemeableFillStyle
/// choice (`fill` CT_FillProperties | `fillRef` CT_StyleMatrixReference,
/// optional), `cell3D` (CT_Cell3D, optional). No attributes.
pub(all) struct CT_TableStyleCellStyle {
  /// <tcBdr> (CT_TableCellBorderStyle) — optional.
  tc_bdr : CT_TableCellBorderStyle?
  /// <fill> (CT_FillProperties) — EG_ThemeableFillStyle choice arm.
  fill : CT_FillProperties?
  /// <fillRef> (CT_StyleMatrixReference) — EG_ThemeableFillStyle arm.
  fill_ref : CT_StyleMatrixReference?
  /// <cell3D> (CT_Cell3D) — optional.
  cell3d : CT_Cell3D?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleCellStyle::new(
  element : @xml.Element,
) -> CT_TableStyleCellStyle raise SchemaViolation {
  let tc_bdr = match ct_first_child(element, "tcBdr") {
    Some(c) => Some(CT_TableCellBorderStyle::new(c))
    None => None
  }
  let fill = match ct_first_child(element, "fill") {
    Some(c) => Some(CT_FillProperties::new(c))
    None => None
  }
  let fill_ref = ct_first_child(element, "fillRef").map(
    CT_StyleMatrixReference::new,
  )
  let cell3d = ct_first_child(element, "cell3D").map(CT_Cell3D::new)
  { tc_bdr, fill, fill_ref, cell3d, element }
}

///|
pub fn CT_TableStyleCellStyle::to_element(
  self : CT_TableStyleCellStyle,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TablePartStyle — Part 1 §20.1.4.2.27 (table
/// part style container reused by `wholeTbl`, `band1H`, etc.). Annex
/// A.4.1 lines 2506..2511. Sequence: `tcTxStyle`
/// (CT_TableStyleTextStyle, optional), `tcStyle` (CT_TableStyleCellStyle,
/// optional). No attributes.
pub(all) struct CT_TablePartStyle {
  /// <tcTxStyle> (CT_TableStyleTextStyle) — optional.
  tc_tx_style : CT_TableStyleTextStyle?
  /// <tcStyle> (CT_TableStyleCellStyle) — optional.
  tc_style : CT_TableStyleCellStyle?
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TablePartStyle::new(
  element : @xml.Element,
) -> CT_TablePartStyle raise SchemaViolation {
  let tc_tx_style = match ct_first_child(element, "tcTxStyle") {
    Some(c) => Some(CT_TableStyleTextStyle::new(c))
    None => None
  }
  let tc_style = match ct_first_child(element, "tcStyle") {
    Some(c) => Some(CT_TableStyleCellStyle::new(c))
    None => None
  }
  { tc_tx_style, tc_style, element }
}

///|
pub fn CT_TablePartStyle::to_element(self : CT_TablePartStyle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableStyle — Part 1 §20.1.4.2.26 tblStyle
/// (Table Style). Annex A.4.1 lines 2512..2532. Sequence: `tblBg`
/// (CT_TableBackgroundStyle, optional) followed by thirteen optional
/// CT_TablePartStyle children — `wholeTbl`, `band1H`, `band2H`,
/// `band1V`, `band2V`, `lastCol`, `firstCol`, `lastRow`, `seCell`,
/// `swCell`, `firstRow`, `neCell`, `nwCell` — and `extLst`
/// (CT_OfficeArtExtensionList, optional). Required `styleId`
/// (s:ST_Guid) and `styleName` (xsd:string).
pub(all) struct CT_TableStyle {
  /// <tblBg> (CT_TableBackgroundStyle) — optional.
  tbl_bg : CT_TableBackgroundStyle?
  /// <wholeTbl> (CT_TablePartStyle) — optional.
  whole_tbl : CT_TablePartStyle?
  /// <band1H> (CT_TablePartStyle) — optional.
  band1h : CT_TablePartStyle?
  /// <band2H> (CT_TablePartStyle) — optional.
  band2h : CT_TablePartStyle?
  /// <band1V> (CT_TablePartStyle) — optional.
  band1v : CT_TablePartStyle?
  /// <band2V> (CT_TablePartStyle) — optional.
  band2v : CT_TablePartStyle?
  /// <lastCol> (CT_TablePartStyle) — optional.
  last_col : CT_TablePartStyle?
  /// <firstCol> (CT_TablePartStyle) — optional.
  first_col : CT_TablePartStyle?
  /// <lastRow> (CT_TablePartStyle) — optional.
  last_row : CT_TablePartStyle?
  /// <seCell> (CT_TablePartStyle) — optional.
  se_cell : CT_TablePartStyle?
  /// <swCell> (CT_TablePartStyle) — optional.
  sw_cell : CT_TablePartStyle?
  /// <firstRow> (CT_TablePartStyle) — optional.
  first_row : CT_TablePartStyle?
  /// <neCell> (CT_TablePartStyle) — optional.
  ne_cell : CT_TablePartStyle?
  /// <nwCell> (CT_TablePartStyle) — optional.
  nw_cell : CT_TablePartStyle?
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : CT_OfficeArtExtensionList?
  /// @styleId — s:ST_Guid (xsd:string lexical form, required).
  style_id : String
  /// @styleName — xsd:string (required).
  style_name : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyle::new(
  element : @xml.Element,
) -> CT_TableStyle raise SchemaViolation {
  let tbl_bg = match ct_first_child(element, "tblBg") {
    Some(c) => Some(CT_TableBackgroundStyle::new(c))
    None => None
  }
  let whole_tbl = match ct_first_child(element, "wholeTbl") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let band1h = match ct_first_child(element, "band1H") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let band2h = match ct_first_child(element, "band2H") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let band1v = match ct_first_child(element, "band1V") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let band2v = match ct_first_child(element, "band2V") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let last_col = match ct_first_child(element, "lastCol") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let first_col = match ct_first_child(element, "firstCol") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let last_row = match ct_first_child(element, "lastRow") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let se_cell = match ct_first_child(element, "seCell") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let sw_cell = match ct_first_child(element, "swCell") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let first_row = match ct_first_child(element, "firstRow") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let ne_cell = match ct_first_child(element, "neCell") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let nw_cell = match ct_first_child(element, "nwCell") {
    Some(c) => Some(CT_TablePartStyle::new(c))
    None => None
  }
  let ext_lst = match ct_first_child(element, "extLst") {
    Some(c) => Some(CT_OfficeArtExtensionList::new(c))
    None => None
  }
  let style_id = ct_required_string(
    element, "styleId", "CT_TableStyle/@styleId",
  )
  let style_name = ct_required_string(
    element, "styleName", "CT_TableStyle/@styleName",
  )
  {
    tbl_bg,
    whole_tbl,
    band1h,
    band2h,
    band1v,
    band2v,
    last_col,
    first_col,
    last_row,
    se_cell,
    sw_cell,
    first_row,
    ne_cell,
    nw_cell,
    ext_lst,
    style_id,
    style_name,
    element,
  }
}

///|
pub fn CT_TableStyle::to_element(self : CT_TableStyle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TableStyleList — Part 1 §20.1.4.2.27
/// tblStyleLst (Table Style List). Annex A.4.1 lines 2533..2538.
/// Sequence: `tblStyle` (CT_TableStyle, zero or more). Required `def`
/// (s:ST_Guid) — the default style id.
pub(all) struct CT_TableStyleList {
  /// <tblStyle>* (CT_TableStyle) — zero or more table styles in
  /// document order.
  tbl_style : Array[CT_TableStyle]
  /// @def — s:ST_Guid (xsd:string lexical form, required).
  def : String
  /// Preserved source element for round-trip writing.
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TableStyleList::new(
  element : @xml.Element,
) -> CT_TableStyleList raise SchemaViolation {
  let tbl_style : Array[CT_TableStyle] = []
  for child in ct_children(element, "tblStyle") {
    tbl_style.push(CT_TableStyle::new(child))
  }
  let def = ct_required_string(element, "def", "CT_TableStyleList/@def")
  { tbl_style, def, element }
}

///|
pub fn CT_TableStyleList::to_element(self : CT_TableStyleList) -> @xml.Element {
  self.element
}

// ---------------------------------------------------------------------
// Public reader / writer entry points
// ---------------------------------------------------------------------

///|
pub fn read_graphical_object(bytes : Bytes) -> CT_GraphicalObject raise {
  CT_GraphicalObject::new(read_main_root(bytes, "graphic"))
}

///|
pub fn write_graphical_object(value : CT_GraphicalObject) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_table(bytes : Bytes) -> CT_Table raise {
  CT_Table::new(read_main_root(bytes, "tbl"))
}

///|
pub fn write_table(value : CT_Table) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_table_style_list(bytes : Bytes) -> CT_TableStyleList raise {
  CT_TableStyleList::new(read_main_root(bytes, "tblStyleLst"))
}

///|
pub fn write_table_style_list(value : CT_TableStyleList) -> Bytes {
  write_element(value.element)
}

///|
/// Concatenate all direct character-data descendants of `element` as
/// the XSD lexical form. Used to decode the `<tableStyleId>` element
/// whose schema type is s:ST_Guid (encoded as text content).
fn text_content(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for node in element.children {
    match node {
      @xml.Text(t) => buf.write_string(t)
      _ => ()
    }
  }
  buf.to_string()
}
