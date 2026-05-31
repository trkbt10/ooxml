///|
/// ECMA-376 Part 1 §20.5 Spreadsheet drawings.
/// Spreadsheet drawing package for DML xdr anchors and legacy VML ClientData.
/// Schema dml-spreadsheetDrawing.xsd bundle strict/transitional, target
/// namespace http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing.
/// Schema vml-spreadsheetDrawing.xsd bundle transitional, target namespace
/// urn:schemas-microsoft-com:office:excel.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/drawing"
}

///|
/// Spreadsheet drawing schema validation error for DML/VML drawing entries.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// XSD simple type ST_ColID from dml-spreadsheetDrawing.xsd (§20.5).
pub struct ST_ColID {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_ColID and enforce the xsd:int lexical constraint.
pub fn ST_ColID::new(s : String) -> ST_ColID raise SchemaViolation {
  require_int("dml-spreadsheetDrawing.xsd", "ST_ColID", s)
  { value: s }
}

///|
/// Return the lexical ST_ColID value.
pub fn ST_ColID::to_string(self : ST_ColID) -> String {
  self.value
}

///|
/// XSD simple type ST_RowID from dml-spreadsheetDrawing.xsd (§20.5).
/// Schema dml-spreadsheetDrawing.xsd simple type ST_RowID uses xsd:int.
/// Public value type ST_RowID validates row marker identifiers.
pub struct ST_RowID {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_RowID and enforce the xsd:int lexical constraint.
/// Schema dml-spreadsheetDrawing.xsd simple type ST_RowID.
pub fn ST_RowID::new(s : String) -> ST_RowID raise SchemaViolation {
  require_int("dml-spreadsheetDrawing.xsd", "ST_RowID", s)
  { value: s }
}

///|
/// Return the lexical ST_RowID value.
pub fn ST_RowID::to_string(self : ST_RowID) -> String {
  self.value
}

///|
/// XSD simple type ST_EditAs from dml-spreadsheetDrawing.xsd (§20.5).
pub(all) enum ST_EditAs {
  TwoCell
  OneCell
  Absolute
} derive(Eq, Debug)

///|
/// Construct ST_EditAs from its schema enumeration value.
pub fn ST_EditAs::new(s : String) -> ST_EditAs raise SchemaViolation {
  match s {
    "twoCell" => TwoCell
    "oneCell" => OneCell
    "absolute" => Absolute
    _ =>
      raise SchemaViolation(
        schema="dml-spreadsheetDrawing.xsd",
        path="ST_EditAs",
        reason="invalid enumeration value",
      )
  }
}

///|
/// Return the lexical ST_EditAs value.
pub fn ST_EditAs::to_string(self : ST_EditAs) -> String {
  match self {
    TwoCell => "twoCell"
    OneCell => "oneCell"
    Absolute => "absolute"
  }
}

///|
/// XSD simple type ST_CF from vml-spreadsheetDrawing.xsd.
/// VML spreadsheet-drawing primitives (`x:ClientData`, ST_ObjectType,
/// ST_CF, ClientDataChild) moved to the dedicated
/// `trkbt10/ooxml/ecma376/drawing_ml/vml_excel` package, since they
/// belong to vml-spreadsheetDrawing.xsd not dml-spreadsheetDrawing.xsd.
/// Re-exported here through type aliases so existing consumers of
/// this module keep compiling unchanged.
pub using @vml_excel {type ST_CF}

///|
pub using @vml_excel {type ST_ObjectType}

///|
/// XSD complex type CT_AnchorClientData — Part 1 §20.5.2.3. Optional
/// attributes `fLocksWithSheet` and `fPrintsWithSheet` (xsd:boolean, default
/// "true"); element has no children.
pub(all) struct CT_AnchorClientData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @fLocksWithSheet (xsd:boolean) — optional, default "true".
  f_locks_with_sheet : String?
  /// @fPrintsWithSheet (xsd:boolean) — optional, default "true".
  f_prints_with_sheet : String?
} derive(Eq, Debug)

///|
/// Construct CT_AnchorClientData from its source XML element.
pub fn CT_AnchorClientData::new(element : @xml.Element) -> CT_AnchorClientData {
  {
    element,
    f_locks_with_sheet: attr(element, "fLocksWithSheet"),
    f_prints_with_sheet: attr(element, "fPrintsWithSheet"),
  }
}

///|
/// XSD complex type CT_ShapeNonVisual — Part 1 §20.5.2.30. Required children
/// `<cNvPr>` (a:CT_NonVisualDrawingProps) and `<cNvSpPr>`
/// (a:CT_NonVisualDrawingShapeProps).
pub(all) struct CT_ShapeNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required.
  c_nv_pr : @a.CT_NonVisualDrawingProps
  /// <cNvSpPr> (a:CT_NonVisualDrawingShapeProps) — required.
  c_nv_sp_pr : @a.CT_NonVisualDrawingShapeProps
} derive(Eq, Debug)

///|
/// Construct CT_ShapeNonVisual from its source XML element.
pub fn CT_ShapeNonVisual::new(
  element : @xml.Element,
) -> CT_ShapeNonVisual raise SchemaViolation {
  let c_nv_pr_el = required_child(element, "cNvPr", "CT_ShapeNonVisual/cNvPr")
  let c_nv_sp_pr_el = required_child(
    element, "cNvSpPr", "CT_ShapeNonVisual/cNvSpPr",
  )
  let c_nv_pr = wrap_a_violation(
    () => @a.CT_NonVisualDrawingProps::new(c_nv_pr_el),
    "CT_ShapeNonVisual/cNvPr",
  )
  let c_nv_sp_pr = wrap_a_violation(
    () => @a.CT_NonVisualDrawingShapeProps::new(c_nv_sp_pr_el),
    "CT_ShapeNonVisual/cNvSpPr",
  )
  { element, c_nv_pr, c_nv_sp_pr }
}

///|
/// XSD complex type CT_Shape — Part 1 §20.5.2.29. Required children `nvSpPr`
/// (CT_ShapeNonVisual) and `spPr` (a:CT_ShapeProperties); optional `style`
/// (a:CT_ShapeStyle) and `txBody` (a:CT_TextBody). Optional attributes
/// `macro` (xsd:string), `textlink` (xsd:string), `fLocksText` (xsd:boolean,
/// default "true"), `fPublished` (xsd:boolean, default "false").
pub(all) struct CT_Shape {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvSpPr> (CT_ShapeNonVisual) — required.
  nv_sp_pr : CT_ShapeNonVisual
  /// <spPr> (a:CT_ShapeProperties) — required.
  sp_pr : @a.CT_ShapeProperties
  /// <style> (a:CT_ShapeStyle) — optional.
  style : @a.CT_ShapeStyle?
  /// <txBody> (a:CT_TextBody) — optional.
  tx_body : @a.CT_TextBody?
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @textlink (xsd:string) — optional.
  textlink : String?
  /// @fLocksText (xsd:boolean) — optional, default "true".
  f_locks_text : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_Shape from its source XML element.
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape raise SchemaViolation {
  let nv_sp_pr_el = required_child(element, "nvSpPr", "CT_Shape/nvSpPr")
  let sp_pr_el = required_child(element, "spPr", "CT_Shape/spPr")
  let nv_sp_pr = CT_ShapeNonVisual::new(nv_sp_pr_el)
  let sp_pr = wrap_a_violation(
    () => @a.CT_ShapeProperties::new(sp_pr_el),
    "CT_Shape/spPr",
  )
  let style = match optional_child(element, "style") {
    None => None
    Some(e) =>
      Some(wrap_a_violation(() => @a.CT_ShapeStyle::new(e), "CT_Shape/style"))
  }
  let tx_body = match optional_child(element, "txBody") {
    None => None
    Some(e) =>
      Some(wrap_a_violation(() => @a.CT_TextBody::new(e), "CT_Shape/txBody"))
  }
  {
    element,
    nv_sp_pr,
    sp_pr,
    style,
    tx_body,
    macro_: attr(element, "macro"),
    textlink: attr(element, "textlink"),
    f_locks_text: attr(element, "fLocksText"),
    f_published: attr(element, "fPublished"),
  }
}

///|
/// XSD complex type CT_ConnectorNonVisual — Part 1 §20.5.2.8. Required
/// children `<cNvPr>` (a:CT_NonVisualDrawingProps) and `<cNvCxnSpPr>`
/// (a:CT_NonVisualConnectorProperties).
pub(all) struct CT_ConnectorNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required.
  c_nv_pr : @a.CT_NonVisualDrawingProps
  /// <cNvCxnSpPr> (a:CT_NonVisualConnectorProperties) — required.
  c_nv_cxn_sp_pr : @a.CT_NonVisualConnectorProperties
} derive(Eq, Debug)

///|
/// Construct CT_ConnectorNonVisual from its source XML element.
pub fn CT_ConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_ConnectorNonVisual raise SchemaViolation {
  let c_nv_pr_el = required_child(
    element, "cNvPr", "CT_ConnectorNonVisual/cNvPr",
  )
  let c_nv_cxn_sp_pr_el = required_child(
    element, "cNvCxnSpPr", "CT_ConnectorNonVisual/cNvCxnSpPr",
  )
  let c_nv_pr = wrap_a_violation(
    () => @a.CT_NonVisualDrawingProps::new(c_nv_pr_el),
    "CT_ConnectorNonVisual/cNvPr",
  )
  let c_nv_cxn_sp_pr = wrap_a_violation(
    () => @a.CT_NonVisualConnectorProperties::new(c_nv_cxn_sp_pr_el),
    "CT_ConnectorNonVisual/cNvCxnSpPr",
  )
  { element, c_nv_pr, c_nv_cxn_sp_pr }
}

///|
/// XSD complex type CT_Connector — Part 1 §20.5.2.7. Required children
/// `nvCxnSpPr` (CT_ConnectorNonVisual) and `spPr` (a:CT_ShapeProperties);
/// optional `style` (a:CT_ShapeStyle). Optional attributes `macro`
/// (xsd:string) and `fPublished` (xsd:boolean, default "false").
pub(all) struct CT_Connector {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvCxnSpPr> (CT_ConnectorNonVisual) — required.
  nv_cxn_sp_pr : CT_ConnectorNonVisual
  /// <spPr> (a:CT_ShapeProperties) — required.
  sp_pr : @a.CT_ShapeProperties
  /// <style> (a:CT_ShapeStyle) — optional.
  style : @a.CT_ShapeStyle?
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_Connector from its source XML element.
pub fn CT_Connector::new(
  element : @xml.Element,
) -> CT_Connector raise SchemaViolation {
  let nv_el = required_child(element, "nvCxnSpPr", "CT_Connector/nvCxnSpPr")
  let sp_pr_el = required_child(element, "spPr", "CT_Connector/spPr")
  let nv_cxn_sp_pr = CT_ConnectorNonVisual::new(nv_el)
  let sp_pr = wrap_a_violation(
    () => @a.CT_ShapeProperties::new(sp_pr_el),
    "CT_Connector/spPr",
  )
  let style = match optional_child(element, "style") {
    None => None
    Some(e) =>
      Some(
        wrap_a_violation(() => @a.CT_ShapeStyle::new(e), "CT_Connector/style"),
      )
  }
  {
    element,
    nv_cxn_sp_pr,
    sp_pr,
    style,
    macro_: attr(element, "macro"),
    f_published: attr(element, "fPublished"),
  }
}

///|
/// XSD complex type CT_PictureNonVisual — Part 1 §20.5.2.24. Required children
/// `<cNvPr>` (a:CT_NonVisualDrawingProps) and `<cNvPicPr>`
/// (a:CT_NonVisualPictureProperties).
pub(all) struct CT_PictureNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required.
  c_nv_pr : @a.CT_NonVisualDrawingProps
  /// <cNvPicPr> (a:CT_NonVisualPictureProperties) — required.
  c_nv_pic_pr : @a.CT_NonVisualPictureProperties
} derive(Eq, Debug)

///|
/// Construct CT_PictureNonVisual from its source XML element.
pub fn CT_PictureNonVisual::new(
  element : @xml.Element,
) -> CT_PictureNonVisual raise SchemaViolation {
  let c_nv_pr_el = required_child(element, "cNvPr", "CT_PictureNonVisual/cNvPr")
  let c_nv_pic_pr_el = required_child(
    element, "cNvPicPr", "CT_PictureNonVisual/cNvPicPr",
  )
  let c_nv_pr = wrap_a_violation(
    () => @a.CT_NonVisualDrawingProps::new(c_nv_pr_el),
    "CT_PictureNonVisual/cNvPr",
  )
  let c_nv_pic_pr = wrap_a_violation(
    () => @a.CT_NonVisualPictureProperties::new(c_nv_pic_pr_el),
    "CT_PictureNonVisual/cNvPicPr",
  )
  { element, c_nv_pr, c_nv_pic_pr }
}

///|
/// XSD complex type CT_Picture — Part 1 §20.5.2.25. Required children
/// `nvPicPr` (CT_PictureNonVisual), `blipFill` (a:CT_BlipFillProperties),
/// `spPr` (a:CT_ShapeProperties); optional `style` (a:CT_ShapeStyle).
/// Optional attributes `macro` (xsd:string, default "") and `fPublished`
/// (xsd:boolean, default "false").
pub(all) struct CT_Picture {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvPicPr> (CT_PictureNonVisual) — required.
  nv_pic_pr : CT_PictureNonVisual
  /// <blipFill> (a:CT_BlipFillProperties) — required.
  blip_fill : @a.CT_BlipFillProperties
  /// <spPr> (a:CT_ShapeProperties) — required.
  sp_pr : @a.CT_ShapeProperties
  /// <style> (a:CT_ShapeStyle) — optional.
  style : @a.CT_ShapeStyle?
  /// @macro (xsd:string) — optional, default "".
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_Picture from its source XML element.
pub fn CT_Picture::new(
  element : @xml.Element,
) -> CT_Picture raise SchemaViolation {
  let nv_el = required_child(element, "nvPicPr", "CT_Picture/nvPicPr")
  let blip_el = required_child(element, "blipFill", "CT_Picture/blipFill")
  let sp_pr_el = required_child(element, "spPr", "CT_Picture/spPr")
  let nv_pic_pr = CT_PictureNonVisual::new(nv_el)
  let blip_fill = wrap_a_violation(
    () => @a.CT_BlipFillProperties::new(blip_el),
    "CT_Picture/blipFill",
  )
  let sp_pr = wrap_a_violation(
    () => @a.CT_ShapeProperties::new(sp_pr_el),
    "CT_Picture/spPr",
  )
  let style = match optional_child(element, "style") {
    None => None
    Some(e) =>
      Some(wrap_a_violation(() => @a.CT_ShapeStyle::new(e), "CT_Picture/style"))
  }
  {
    element,
    nv_pic_pr,
    blip_fill,
    sp_pr,
    style,
    macro_: attr(element, "macro"),
    f_published: attr(element, "fPublished"),
  }
}

///|
/// XSD complex type CT_GraphicalObjectFrameNonVisual — Part 1 §20.5.2.20.
/// Required children `<cNvPr>` and `<cNvGraphicFramePr>`.
pub(all) struct CT_GraphicalObjectFrameNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required.
  c_nv_pr : @a.CT_NonVisualDrawingProps
  /// <cNvGraphicFramePr> (a:CT_NonVisualGraphicFrameProperties) — required.
  c_nv_graphic_frame_pr : @a.CT_NonVisualGraphicFrameProperties
} derive(Eq, Debug)

///|
/// Construct CT_GraphicalObjectFrameNonVisual from its source XML element.
pub fn CT_GraphicalObjectFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual raise SchemaViolation {
  let c_nv_pr_el = required_child(
    element, "cNvPr", "CT_GraphicalObjectFrameNonVisual/cNvPr",
  )
  let c_nv_graphic_frame_pr_el = required_child(
    element, "cNvGraphicFramePr", "CT_GraphicalObjectFrameNonVisual/cNvGraphicFramePr",
  )
  let c_nv_pr = wrap_a_violation(
    () => @a.CT_NonVisualDrawingProps::new(c_nv_pr_el),
    "CT_GraphicalObjectFrameNonVisual/cNvPr",
  )
  let c_nv_graphic_frame_pr = wrap_a_violation(
    () => @a.CT_NonVisualGraphicFrameProperties::new(c_nv_graphic_frame_pr_el),
    "CT_GraphicalObjectFrameNonVisual/cNvGraphicFramePr",
  )
  { element, c_nv_pr, c_nv_graphic_frame_pr }
}

///|
/// XSD complex type CT_GraphicalObjectFrame — Part 1 §20.5.2.19. Required
/// children `nvGraphicFramePr` (CT_GraphicalObjectFrameNonVisual), `xfrm`
/// (a:CT_Transform2D), and `a:graphic`. Optional attributes `macro`
/// (xsd:string) and `fPublished` (xsd:boolean, default "false").
pub(all) struct CT_GraphicalObjectFrame {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvGraphicFramePr> (CT_GraphicalObjectFrameNonVisual) — required.
  nv_graphic_frame_pr : CT_GraphicalObjectFrameNonVisual
  /// <xfrm> (a:CT_Transform2D) — required.
  xfrm : @a.CT_Transform2D
  /// <a:graphic> — required.
  graphic : @a.CT_GraphicalObject
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_GraphicalObjectFrame from its source XML element.
pub fn CT_GraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame raise SchemaViolation {
  let nv_el = required_child(
    element, "nvGraphicFramePr", "CT_GraphicalObjectFrame/nvGraphicFramePr",
  )
  let xfrm_el = required_child(element, "xfrm", "CT_GraphicalObjectFrame/xfrm")
  let graphic_el = required_child(
    element, "graphic", "CT_GraphicalObjectFrame/graphic",
  )
  let nv_graphic_frame_pr = CT_GraphicalObjectFrameNonVisual::new(nv_el)
  let xfrm = wrap_a_violation(
    () => @a.CT_Transform2D::new(xfrm_el),
    "CT_GraphicalObjectFrame/xfrm",
  )
  let graphic = wrap_a_violation(
    () => @a.CT_GraphicalObject::new(graphic_el),
    "CT_GraphicalObjectFrame/graphic",
  )
  {
    element,
    nv_graphic_frame_pr,
    xfrm,
    graphic,
    macro_: attr(element, "macro"),
    f_published: attr(element, "fPublished"),
  }
}

///|
/// XSD complex type CT_GroupShapeNonVisual — Part 1 §20.5.2.18. Required
/// children `<cNvPr>` (a:CT_NonVisualDrawingProps) and `<cNvGrpSpPr>`
/// (a:CT_NonVisualGroupDrawingShapeProps).
pub(all) struct CT_GroupShapeNonVisual {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <cNvPr> (a:CT_NonVisualDrawingProps) — required.
  c_nv_pr : @a.CT_NonVisualDrawingProps
  /// <cNvGrpSpPr> (a:CT_NonVisualGroupDrawingShapeProps) — required.
  c_nv_grp_sp_pr : @a.CT_NonVisualGroupDrawingShapeProps
} derive(Eq, Debug)

///|
/// Construct CT_GroupShapeNonVisual from its source XML element.
pub fn CT_GroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual raise SchemaViolation {
  let c_nv_pr_el = required_child(
    element, "cNvPr", "CT_GroupShapeNonVisual/cNvPr",
  )
  let c_nv_grp_sp_pr_el = required_child(
    element, "cNvGrpSpPr", "CT_GroupShapeNonVisual/cNvGrpSpPr",
  )
  let c_nv_pr = wrap_a_violation(
    () => @a.CT_NonVisualDrawingProps::new(c_nv_pr_el),
    "CT_GroupShapeNonVisual/cNvPr",
  )
  let c_nv_grp_sp_pr = wrap_a_violation(
    () => @a.CT_NonVisualGroupDrawingShapeProps::new(c_nv_grp_sp_pr_el),
    "CT_GroupShapeNonVisual/cNvGrpSpPr",
  )
  { element, c_nv_pr, c_nv_grp_sp_pr }
}

///|
/// XSD complex type CT_GroupShape — Part 1 §20.5.2.17. Required children
/// `nvGrpSpPr` (CT_GroupShapeNonVisual) and `grpSpPr` (a:CT_GroupShapeProperties);
/// optional unbounded choice of `sp`/`grpSp`/`graphicFrame`/`cxnSp`/`pic`.
pub(all) struct CT_GroupShape {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvGrpSpPr> (CT_GroupShapeNonVisual) — required.
  nv_grp_sp_pr : CT_GroupShapeNonVisual
  /// <grpSpPr> (a:CT_GroupShapeProperties) — required.
  grp_sp_pr : @a.CT_GroupShapeProperties
  /// EG_ObjectChoices children in document order — the §20.5.2.17
  /// unbounded shape choice (sp / grpSp / graphicFrame / cxnSp / pic).
  shapes : Array[EG_ObjectChoices]
} derive(Eq, Debug)

///|
/// Construct CT_GroupShape from its source XML element.
pub fn CT_GroupShape::new(
  element : @xml.Element,
) -> CT_GroupShape raise SchemaViolation {
  let nv_el = required_child(element, "nvGrpSpPr", "CT_GroupShape/nvGrpSpPr")
  let grp_el = required_child(element, "grpSpPr", "CT_GroupShape/grpSpPr")
  let nv_grp_sp_pr = CT_GroupShapeNonVisual::new(nv_el)
  let grp_sp_pr = wrap_a_violation(
    () => @a.CT_GroupShapeProperties::new(grp_el),
    "CT_GroupShape/grpSpPr",
  )
  let shapes : Array[EG_ObjectChoices] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "sp" => shapes.push(Sp(CT_Shape::new(child_element)))
        "grpSp" => shapes.push(GrpSp(CT_GroupShape::new(child_element)))
        "graphicFrame" =>
          shapes.push(GraphicFrame(CT_GraphicalObjectFrame::new(child_element)))
        "cxnSp" => shapes.push(CxnSp(CT_Connector::new(child_element)))
        "pic" => shapes.push(Pic(CT_Picture::new(child_element)))
        _ => ()
      }
    }
  }
  { element, nv_grp_sp_pr, grp_sp_pr, shapes }
}

///|
/// XSD complex type CT_Rel — Part 1 §20.5.2.27. Required `r:id` attribute
/// referencing the related part.
pub(all) struct CT_Rel {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required.
  r_id : String
} derive(Eq, Debug)

///|
/// Construct CT_Rel from its source XML element.
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel raise SchemaViolation {
  let r_id = require_attr_with_ns(element, "id", "CT_Rel/@r:id")
  { element, r_id }
}

///|
/// XSD complex type CT_Marker — Part 1 §20.5.2.21. Required ordered children
/// `col` (ST_ColID), `colOff` (a:ST_Coordinate), `row` (ST_RowID), and
/// `rowOff` (a:ST_Coordinate).
pub(all) struct CT_Marker {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <col> (ST_ColID) — required.
  col : String
  /// <colOff> (a:ST_Coordinate) — required.
  col_off : String
  /// <row> (ST_RowID) — required.
  row : String
  /// <rowOff> (a:ST_Coordinate) — required.
  row_off : String
} derive(Eq, Debug)

///|
/// Construct CT_Marker by parsing required cell-anchor children.
pub fn CT_Marker::new(
  element : @xml.Element,
) -> CT_Marker raise SchemaViolation {
  let path = element.name.local_name
  let col = required_child_text(element, "col", path + "/col")
  ST_ColID::new(col) |> ignore
  let col_off = required_child_text(element, "colOff", path + "/colOff")
  let row = required_child_text(element, "row", path + "/row")
  ST_RowID::new(row) |> ignore
  let row_off = required_child_text(element, "rowOff", path + "/rowOff")
  { element, col, col_off, row, row_off }
}

///|
/// XSD complex type CT_TwoCellAnchor — Part 1 §20.5.2.34. Required ordered
/// children `from` (CT_Marker), `to` (CT_Marker), EG_ObjectChoices group, and
/// `clientData` (CT_AnchorClientData); optional `editAs` attribute
/// (ST_EditAs, default "twoCell").
pub(all) struct CT_TwoCellAnchor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <from> (CT_Marker) — required.
  from : CT_Marker
  /// <to> (CT_Marker) — required.
  to : CT_Marker
  /// EG_ObjectChoices group child (sp / grpSp / graphicFrame / cxnSp /
  /// pic / contentPart). Per §20.5.2.34 the choice is required.
  object_choice : EG_ObjectChoices
  /// <clientData> (CT_AnchorClientData) — required.
  client_data : CT_AnchorClientData
  /// @editAs (ST_EditAs) — optional, default "twoCell".
  edit_as : ST_EditAs?
} derive(Eq, Debug)

///|
/// Construct CT_TwoCellAnchor from its source XML element.
pub fn CT_TwoCellAnchor::new(
  element : @xml.Element,
) -> CT_TwoCellAnchor raise SchemaViolation {
  let from_el = required_child(element, "from", "CT_TwoCellAnchor/from")
  let to_el = required_child(element, "to", "CT_TwoCellAnchor/to")
  let client_el = required_child(
    element, "clientData", "CT_TwoCellAnchor/clientData",
  )
  let from = CT_Marker::new(from_el)
  let to = CT_Marker::new(to_el)
  let client_data = CT_AnchorClientData::new(client_el)
  let object_choice = read_object_choice(element, "CT_TwoCellAnchor")
  let edit_as = match attr(element, "editAs") {
    None => None
    Some(v) => Some(ST_EditAs::new(v))
  }
  { element, from, to, object_choice, client_data, edit_as }
}

///|
/// XSD complex type CT_OneCellAnchor — Part 1 §20.5.2.23. Required ordered
/// children `from` (CT_Marker), `ext` (a:CT_PositiveSize2D), EG_ObjectChoices
/// group, and `clientData` (CT_AnchorClientData).
pub(all) struct CT_OneCellAnchor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <from> (CT_Marker) — required.
  from : CT_Marker
  /// <ext> (a:CT_PositiveSize2D) — required.
  ext : @a.CT_PositiveSize2D
  /// EG_ObjectChoices group child.
  object_choice : EG_ObjectChoices
  /// <clientData> (CT_AnchorClientData) — required.
  client_data : CT_AnchorClientData
} derive(Eq, Debug)

///|
/// Construct CT_OneCellAnchor from its source XML element.
pub fn CT_OneCellAnchor::new(
  element : @xml.Element,
) -> CT_OneCellAnchor raise SchemaViolation {
  let from_el = required_child(element, "from", "CT_OneCellAnchor/from")
  let ext_el = required_child(element, "ext", "CT_OneCellAnchor/ext")
  let client_el = required_child(
    element, "clientData", "CT_OneCellAnchor/clientData",
  )
  let from = CT_Marker::new(from_el)
  let ext = wrap_a_violation(
    () => @a.CT_PositiveSize2D::new(ext_el),
    "CT_OneCellAnchor/ext",
  )
  let client_data = CT_AnchorClientData::new(client_el)
  let object_choice = read_object_choice(element, "CT_OneCellAnchor")
  { element, from, ext, object_choice, client_data }
}

///|
/// XSD complex type CT_AbsoluteAnchor — Part 1 §20.5.2.1. Required ordered
/// children `pos` (a:CT_Point2D), `ext` (a:CT_PositiveSize2D),
/// EG_ObjectChoices group, and `clientData` (CT_AnchorClientData).
pub(all) struct CT_AbsoluteAnchor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pos> (a:CT_Point2D) — required.
  pos : @a.CT_Point2D
  /// <ext> (a:CT_PositiveSize2D) — required.
  ext : @a.CT_PositiveSize2D
  /// EG_ObjectChoices group child.
  object_choice : EG_ObjectChoices
  /// <clientData> (CT_AnchorClientData) — required.
  client_data : CT_AnchorClientData
} derive(Eq, Debug)

///|
/// Construct CT_AbsoluteAnchor from its source XML element.
pub fn CT_AbsoluteAnchor::new(
  element : @xml.Element,
) -> CT_AbsoluteAnchor raise SchemaViolation {
  let pos_el = required_child(element, "pos", "CT_AbsoluteAnchor/pos")
  let ext_el = required_child(element, "ext", "CT_AbsoluteAnchor/ext")
  let client_el = required_child(
    element, "clientData", "CT_AbsoluteAnchor/clientData",
  )
  let pos = wrap_a_violation(
    () => @a.CT_Point2D::new(pos_el),
    "CT_AbsoluteAnchor/pos",
  )
  let ext = wrap_a_violation(
    () => @a.CT_PositiveSize2D::new(ext_el),
    "CT_AbsoluteAnchor/ext",
  )
  let client_data = CT_AnchorClientData::new(client_el)
  let object_choice = read_object_choice(element, "CT_AbsoluteAnchor")
  { element, pos, ext, object_choice, client_data }
}

///|
/// XSD complex type CT_Drawing — Part 1 §20.5.2.35. Optional unbounded
/// EG_Anchor group sequence: `twoCellAnchor` (CT_TwoCellAnchor),
/// `oneCellAnchor` (CT_OneCellAnchor), `absoluteAnchor` (CT_AbsoluteAnchor).
pub(all) struct CT_Drawing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// EG_Anchor children in document order — twoCellAnchor /
  /// oneCellAnchor / absoluteAnchor per §20.5.2.35.
  anchors : Array[EG_Anchor]
} derive(Eq, Debug)

///|
/// Construct CT_Drawing from its source XML element.
pub fn CT_Drawing::new(
  element : @xml.Element,
) -> CT_Drawing raise SchemaViolation {
  let anchors : Array[EG_Anchor] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "twoCellAnchor" =>
          anchors.push(TwoCellAnchor(CT_TwoCellAnchor::new(child_element)))
        "oneCellAnchor" =>
          anchors.push(OneCellAnchor(CT_OneCellAnchor::new(child_element)))
        "absoluteAnchor" =>
          anchors.push(AbsoluteAnchor(CT_AbsoluteAnchor::new(child_element)))
        _ => ()
      }
    }
  }
  { element, anchors }
}

///|
/// XSD model group EG_ObjectChoices from dml-spreadsheetDrawing.xsd.
pub(all) enum EG_ObjectChoices {
  Sp(CT_Shape)
  GrpSp(CT_GroupShape)
  GraphicFrame(CT_GraphicalObjectFrame)
  CxnSp(CT_Connector)
  Pic(CT_Picture)
  ContentPart(CT_Rel)
} derive(Eq, Debug)

///|
/// XSD model group EG_Anchor from dml-spreadsheetDrawing.xsd.
pub(all) enum EG_Anchor {
  TwoCellAnchor(CT_TwoCellAnchor)
  OneCellAnchor(CT_OneCellAnchor)
  AbsoluteAnchor(CT_AbsoluteAnchor)
} derive(Eq, Debug)

///|
/// XSD element from in dml-spreadsheetDrawing.xsd.
pub type From = CT_Marker

///|
/// XSD element to in dml-spreadsheetDrawing.xsd.
pub type To = CT_Marker

///|
/// XSD element wsDr in dml-spreadsheetDrawing.xsd.
pub type WsDr = CT_Drawing

///|
/// VML CT_ClientData / ClientDataChild / ClientData live in the
/// vml-spreadsheetDrawing.xsd schema, which is owned by the dedicated
/// `drawing_ml/vml_excel` package. Aliased here so consumers don't
/// need to re-import.
pub using @vml_excel {type ClientDataChild}

///|
pub using @vml_excel {type CT_ClientData}

///|
pub using @vml_excel {type ClientData}

///|
/// Read top-level XSD element from as CT_Marker.
pub fn read_from(bytes : Bytes) -> From raise {
  let root = @xml.parse(bytes).root
  require_local(root, "from", "from", "dml-spreadsheetDrawing.xsd")
  CT_Marker::new(root)
}

///|
/// Write top-level XSD element from.
pub fn write_from(value : From) -> Bytes {
  write_element(value.element)
}

///|
/// Read top-level XSD element to as CT_Marker.
pub fn read_to(bytes : Bytes) -> To raise {
  let root = @xml.parse(bytes).root
  require_local(root, "to", "to", "dml-spreadsheetDrawing.xsd")
  CT_Marker::new(root)
}

///|
/// Write top-level XSD element to.
pub fn write_to(value : To) -> Bytes {
  write_element(value.element)
}

///|
/// Read top-level XSD element wsDr as CT_Drawing.
pub fn read_ws_dr(bytes : Bytes) -> WsDr raise {
  let root = @xml.parse(bytes).root
  require_local(root, "wsDr", "wsDr", "dml-spreadsheetDrawing.xsd")
  CT_Drawing::new(root)
}

///|
/// Write top-level XSD element wsDr.
pub fn write_ws_dr(value : WsDr) -> Bytes {
  write_element(value.element)
}

///|
/// Read top-level XSD element ClientData as CT_ClientData.
///
/// Delegates to the dedicated vml-spreadsheetDrawing.xsd reader in
/// `drawing_ml/vml_excel`.
pub fn read_client_data(bytes : Bytes) -> ClientData raise {
  @vml_excel.read_client_data(bytes)
}

///|
/// Write top-level XSD element ClientData.
pub fn write_client_data(value : ClientData) -> Bytes {
  @vml_excel.write_client_data(value)
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}

///|
fn required_child_text(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return text(child_element)
        }
      _ => ()
    }
  }
  raise SchemaViolation(
    schema="dml-spreadsheetDrawing.xsd",
    path~,
    reason="required child element is missing",
  )
}

///|
fn text(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Node::Text(value) | @xml.Node::CData(value) =>
        out.write_string(value)
      _ => ()
    }
  }
  out.to_string()
}

///|
fn attr(element : @xml.Element, local_name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == local_name {
      return Some(attribute.value)
    }
  }
  None
}

///|
fn require_attr_with_ns(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  match attr(element, local_name) {
    Some(value) => value
    None =>
      raise SchemaViolation(
        schema="dml-spreadsheetDrawing.xsd",
        path~,
        reason="required relationship attribute missing",
      )
  }
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
  schema : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(schema~, path~, reason="unexpected element name")
  }
}

///|
/// Locate a required child element by local name. Mirrors the
/// `required_child_text` helper but returns the element itself so
/// callers can hand it to the typed @a.CT_*::new constructors.
fn required_child(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> @xml.Element raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return child_element
        }
      _ => ()
    }
  }
  raise SchemaViolation(
    schema="dml-spreadsheetDrawing.xsd",
    path~,
    reason="required child element is missing",
  )
}

///|
/// Locate an optional child element by local name.
fn optional_child(element : @xml.Element, local_name : String) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return Some(child_element)
        }
      _ => ()
    }
  }
  None
}

///|
/// Read the EG_ObjectChoices group child (§20.5 — the required
/// sp/grpSp/graphicFrame/cxnSp/pic/contentPart choice that appears
/// inside each anchor). Returns the typed projection.
fn read_object_choice(
  element : @xml.Element,
  path_prefix : String,
) -> EG_ObjectChoices raise SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "sp" => return Sp(CT_Shape::new(child_element))
        "grpSp" => return GrpSp(CT_GroupShape::new(child_element))
        "graphicFrame" =>
          return GraphicFrame(CT_GraphicalObjectFrame::new(child_element))
        "cxnSp" => return CxnSp(CT_Connector::new(child_element))
        "pic" => return Pic(CT_Picture::new(child_element))
        "contentPart" => return ContentPart(CT_Rel::new(child_element))
        _ => ()
      }
    }
  }
  raise SchemaViolation(
    schema="dml-spreadsheetDrawing.xsd",
    path=path_prefix + "/EG_ObjectChoices",
    reason="required object choice child element is missing",
  )
}

///|
/// Run a callable that produces an `@a.CT_*` projection, mapping the
/// drawing_ml package's SchemaViolation into our own so the
/// spreadsheet_ml drawing reader stays self-contained at the public
/// API.
fn[T] wrap_a_violation(
  body : () -> T raise @a.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @a.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        schema="dml-spreadsheetDrawing.xsd",
        path=path + " (" + p + ")",
        reason~,
      )
  }
}

///|
fn require_int(
  schema : String,
  path : String,
  value : String,
) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(schema~, path~, reason="empty xsd:int value")
  }
  let mut start = 0
  if value[0:1] == "-" || value[0:1] == "+" {
    start = 1
  }
  if start == value.length() {
    raise SchemaViolation(schema~, path~, reason="invalid xsd:int value")
  }
  for i in start..<value.length() {
    let ch = value[i:i + 1]
    if ch < "0" || ch > "9" {
      raise SchemaViolation(schema~, path~, reason="invalid xsd:int value")
    }
  }
}
