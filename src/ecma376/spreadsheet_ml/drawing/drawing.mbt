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
/// Schema vml-spreadsheetDrawing.xsd simple type ST_CF uses xsd:string.
/// Public value type ST_CF exposes the legacy string control-format value.
pub struct ST_CF {
  value : String
} derive(Eq, Debug)

///|
/// Construct ST_CF as an xsd:string-compatible legacy VML value.
/// Schema vml-spreadsheetDrawing.xsd simple type ST_CF.
pub fn ST_CF::new(s : String) -> ST_CF {
  { value: s }
}

///|
/// Return the lexical ST_CF value.
pub fn ST_CF::to_string(self : ST_CF) -> String {
  self.value
}

///|
/// XSD simple type ST_ObjectType from vml-spreadsheetDrawing.xsd.
pub(all) enum ST_ObjectType {
  Button
  Checkbox
  Dialog
  Drop
  Edit
  GBox
  Label
  LineA
  List
  Movie
  Note
  Pict
  Radio
  RectA
  Scroll
  Spin
  Shape
  Group
  Rect
} derive(Eq, Debug)

///|
/// Construct ST_ObjectType from its VML spreadsheet drawing enumeration.
pub fn ST_ObjectType::new(s : String) -> ST_ObjectType raise SchemaViolation {
  match s {
    "Button" => Button
    "Checkbox" => Checkbox
    "Dialog" => Dialog
    "Drop" => Drop
    "Edit" => Edit
    "GBox" => GBox
    "Label" => Label
    "LineA" => LineA
    "List" => List
    "Movie" => Movie
    "Note" => Note
    "Pict" => Pict
    "Radio" => Radio
    "RectA" => RectA
    "Scroll" => Scroll
    "Spin" => Spin
    "Shape" => Shape
    "Group" => Group
    "Rect" => Rect
    _ =>
      raise SchemaViolation(
        schema="vml-spreadsheetDrawing.xsd",
        path="ST_ObjectType",
        reason="invalid enumeration value",
      )
  }
}

///|
/// Return the lexical ST_ObjectType value.
pub fn ST_ObjectType::to_string(self : ST_ObjectType) -> String {
  match self {
    Button => "Button"
    Checkbox => "Checkbox"
    Dialog => "Dialog"
    Drop => "Drop"
    Edit => "Edit"
    GBox => "GBox"
    Label => "Label"
    LineA => "LineA"
    List => "List"
    Movie => "Movie"
    Note => "Note"
    Pict => "Pict"
    Radio => "Radio"
    RectA => "RectA"
    Scroll => "Scroll"
    Spin => "Spin"
    Shape => "Shape"
    Group => "Group"
    Rect => "Rect"
  }
}

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
  c_nv_pr_child_name : String
  /// <cNvSpPr> (a:CT_NonVisualDrawingShapeProps) — required.
  c_nv_sp_pr_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_ShapeNonVisual from its source XML element.
pub fn CT_ShapeNonVisual::new(element : @xml.Element) -> CT_ShapeNonVisual {
  let mut cn = ""
  let mut sp = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "cNvPr" => cn = "cNvPr"
        "cNvSpPr" => sp = "cNvSpPr"
        _ => ()
      }
    }
  }
  { element, c_nv_pr_child_name: cn, c_nv_sp_pr_child_name: sp }
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
  nv_sp_pr_child_name : String
  /// <spPr> (a:CT_ShapeProperties) — required.
  sp_pr_child_name : String
  /// <style> (a:CT_ShapeStyle) — optional.
  has_style : Bool
  /// <txBody> (a:CT_TextBody) — optional.
  has_tx_body : Bool
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
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape {
  let mut nv = ""
  let mut sp = ""
  let mut style = false
  let mut tx = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "nvSpPr" => nv = "nvSpPr"
        "spPr" => sp = "spPr"
        "style" => style = true
        "txBody" => tx = true
        _ => ()
      }
    }
  }
  {
    element,
    nv_sp_pr_child_name: nv,
    sp_pr_child_name: sp,
    has_style: style,
    has_tx_body: tx,
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
  c_nv_pr_child_name : String
  /// <cNvCxnSpPr> (a:CT_NonVisualConnectorProperties) — required.
  c_nv_cxn_sp_pr_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_ConnectorNonVisual from its source XML element.
pub fn CT_ConnectorNonVisual::new(
  element : @xml.Element,
) -> CT_ConnectorNonVisual {
  let mut cn = ""
  let mut cxn = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "cNvPr" => cn = "cNvPr"
        "cNvCxnSpPr" => cxn = "cNvCxnSpPr"
        _ => ()
      }
    }
  }
  { element, c_nv_pr_child_name: cn, c_nv_cxn_sp_pr_child_name: cxn }
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
  nv_cxn_sp_pr_child_name : String
  /// <spPr> (a:CT_ShapeProperties) — required.
  sp_pr_child_name : String
  /// <style> (a:CT_ShapeStyle) — optional.
  has_style : Bool
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_Connector from its source XML element.
pub fn CT_Connector::new(element : @xml.Element) -> CT_Connector {
  let mut nv = ""
  let mut sp = ""
  let mut style = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "nvCxnSpPr" => nv = "nvCxnSpPr"
        "spPr" => sp = "spPr"
        "style" => style = true
        _ => ()
      }
    }
  }
  {
    element,
    nv_cxn_sp_pr_child_name: nv,
    sp_pr_child_name: sp,
    has_style: style,
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
  c_nv_pr_child_name : String
  /// <cNvPicPr> (a:CT_NonVisualPictureProperties) — required.
  c_nv_pic_pr_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_PictureNonVisual from its source XML element.
pub fn CT_PictureNonVisual::new(element : @xml.Element) -> CT_PictureNonVisual {
  let mut cn = ""
  let mut pic = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "cNvPr" => cn = "cNvPr"
        "cNvPicPr" => pic = "cNvPicPr"
        _ => ()
      }
    }
  }
  { element, c_nv_pr_child_name: cn, c_nv_pic_pr_child_name: pic }
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
  nv_pic_pr_child_name : String
  /// <blipFill> (a:CT_BlipFillProperties) — required.
  blip_fill_child_name : String
  /// <spPr> (a:CT_ShapeProperties) — required.
  sp_pr_child_name : String
  /// <style> (a:CT_ShapeStyle) — optional.
  has_style : Bool
  /// @macro (xsd:string) — optional, default "".
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_Picture from its source XML element.
pub fn CT_Picture::new(element : @xml.Element) -> CT_Picture {
  let mut nv = ""
  let mut blip = ""
  let mut sp = ""
  let mut style = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "nvPicPr" => nv = "nvPicPr"
        "blipFill" => blip = "blipFill"
        "spPr" => sp = "spPr"
        "style" => style = true
        _ => ()
      }
    }
  }
  {
    element,
    nv_pic_pr_child_name: nv,
    blip_fill_child_name: blip,
    sp_pr_child_name: sp,
    has_style: style,
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
  c_nv_pr_child_name : String
  /// <cNvGraphicFramePr> (a:CT_NonVisualGraphicFrameProperties) — required.
  c_nv_graphic_frame_pr_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_GraphicalObjectFrameNonVisual from its source XML element.
pub fn CT_GraphicalObjectFrameNonVisual::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrameNonVisual {
  let mut cn = ""
  let mut gf = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "cNvPr" => cn = "cNvPr"
        "cNvGraphicFramePr" => gf = "cNvGraphicFramePr"
        _ => ()
      }
    }
  }
  { element, c_nv_pr_child_name: cn, c_nv_graphic_frame_pr_child_name: gf }
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
  nv_graphic_frame_pr_child_name : String
  /// <xfrm> (a:CT_Transform2D) — required.
  xfrm_child_name : String
  /// <a:graphic> — required.
  graphic_child_name : String
  /// @macro (xsd:string) — optional.
  macro_ : String?
  /// @fPublished (xsd:boolean) — optional, default "false".
  f_published : String?
} derive(Eq, Debug)

///|
/// Construct CT_GraphicalObjectFrame from its source XML element.
pub fn CT_GraphicalObjectFrame::new(
  element : @xml.Element,
) -> CT_GraphicalObjectFrame {
  let mut nv = ""
  let mut xfrm = ""
  let mut graphic = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "nvGraphicFramePr" => nv = "nvGraphicFramePr"
        "xfrm" => xfrm = "xfrm"
        "graphic" => graphic = "graphic"
        _ => ()
      }
    }
  }
  {
    element,
    nv_graphic_frame_pr_child_name: nv,
    xfrm_child_name: xfrm,
    graphic_child_name: graphic,
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
  c_nv_pr_child_name : String
  /// <cNvGrpSpPr> (a:CT_NonVisualGroupDrawingShapeProps) — required.
  c_nv_grp_sp_pr_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_GroupShapeNonVisual from its source XML element.
pub fn CT_GroupShapeNonVisual::new(
  element : @xml.Element,
) -> CT_GroupShapeNonVisual {
  let mut cn = ""
  let mut grp = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "cNvPr" => cn = "cNvPr"
        "cNvGrpSpPr" => grp = "cNvGrpSpPr"
        _ => ()
      }
    }
  }
  { element, c_nv_pr_child_name: cn, c_nv_grp_sp_pr_child_name: grp }
}

///|
/// XSD complex type CT_GroupShape — Part 1 §20.5.2.17. Required children
/// `nvGrpSpPr` (CT_GroupShapeNonVisual) and `grpSpPr` (a:CT_GroupShapeProperties);
/// optional unbounded choice of `sp`/`grpSp`/`graphicFrame`/`cxnSp`/`pic`.
pub(all) struct CT_GroupShape {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvGrpSpPr> (CT_GroupShapeNonVisual) — required.
  nv_grp_sp_pr_child_name : String
  /// <grpSpPr> (a:CT_GroupShapeProperties) — required.
  grp_sp_pr_child_name : String
  /// Local names of nested shape-content children in document order.
  shape_child_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_GroupShape from its source XML element.
pub fn CT_GroupShape::new(element : @xml.Element) -> CT_GroupShape {
  let mut nv = ""
  let mut grp = ""
  let names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "nvGrpSpPr" => nv = "nvGrpSpPr"
        "grpSpPr" => grp = "grpSpPr"
        "sp" | "grpSp" | "graphicFrame" | "cxnSp" | "pic" => names.push(name)
        _ => ()
      }
    }
  }
  {
    element,
    nv_grp_sp_pr_child_name: nv,
    grp_sp_pr_child_name: grp,
    shape_child_names: names,
  }
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
  from_child_name : String
  /// <to> (CT_Marker) — required.
  to_child_name : String
  /// Local name of the EG_ObjectChoices child (sp/grpSp/graphicFrame/cxnSp/
  /// pic/contentPart).
  object_choice_child_name : String
  /// <clientData> (CT_AnchorClientData) — required.
  client_data_child_name : String
  /// @editAs (ST_EditAs) — optional, default "twoCell".
  edit_as : String?
} derive(Eq, Debug)

///|
/// Construct CT_TwoCellAnchor from its source XML element.
pub fn CT_TwoCellAnchor::new(element : @xml.Element) -> CT_TwoCellAnchor {
  let mut from = ""
  let mut to = ""
  let mut choice = ""
  let mut client = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "from" => from = "from"
        "to" => to = "to"
        "clientData" => client = "clientData"
        "sp" | "grpSp" | "graphicFrame" | "cxnSp" | "pic" | "contentPart" =>
          choice = name
        _ => ()
      }
    }
  }
  {
    element,
    from_child_name: from,
    to_child_name: to,
    object_choice_child_name: choice,
    client_data_child_name: client,
    edit_as: attr(element, "editAs"),
  }
}

///|
/// XSD complex type CT_OneCellAnchor — Part 1 §20.5.2.23. Required ordered
/// children `from` (CT_Marker), `ext` (a:CT_PositiveSize2D), EG_ObjectChoices
/// group, and `clientData` (CT_AnchorClientData).
pub(all) struct CT_OneCellAnchor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <from> (CT_Marker) — required.
  from_child_name : String
  /// <ext> (a:CT_PositiveSize2D) — required.
  ext_child_name : String
  /// Local name of the EG_ObjectChoices child.
  object_choice_child_name : String
  /// <clientData> (CT_AnchorClientData) — required.
  client_data_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_OneCellAnchor from its source XML element.
pub fn CT_OneCellAnchor::new(element : @xml.Element) -> CT_OneCellAnchor {
  let mut from = ""
  let mut ext = ""
  let mut choice = ""
  let mut client = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "from" => from = "from"
        "ext" => ext = "ext"
        "clientData" => client = "clientData"
        "sp" | "grpSp" | "graphicFrame" | "cxnSp" | "pic" | "contentPart" =>
          choice = name
        _ => ()
      }
    }
  }
  {
    element,
    from_child_name: from,
    ext_child_name: ext,
    object_choice_child_name: choice,
    client_data_child_name: client,
  }
}

///|
/// XSD complex type CT_AbsoluteAnchor — Part 1 §20.5.2.1. Required ordered
/// children `pos` (a:CT_Point2D), `ext` (a:CT_PositiveSize2D),
/// EG_ObjectChoices group, and `clientData` (CT_AnchorClientData).
pub(all) struct CT_AbsoluteAnchor {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <pos> (a:CT_Point2D) — required.
  pos_child_name : String
  /// <ext> (a:CT_PositiveSize2D) — required.
  ext_child_name : String
  /// Local name of the EG_ObjectChoices child.
  object_choice_child_name : String
  /// <clientData> (CT_AnchorClientData) — required.
  client_data_child_name : String
} derive(Eq, Debug)

///|
/// Construct CT_AbsoluteAnchor from its source XML element.
pub fn CT_AbsoluteAnchor::new(element : @xml.Element) -> CT_AbsoluteAnchor {
  let mut pos = ""
  let mut ext = ""
  let mut choice = ""
  let mut client = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "pos" => pos = "pos"
        "ext" => ext = "ext"
        "clientData" => client = "clientData"
        "sp" | "grpSp" | "graphicFrame" | "cxnSp" | "pic" | "contentPart" =>
          choice = name
        _ => ()
      }
    }
  }
  {
    element,
    pos_child_name: pos,
    ext_child_name: ext,
    object_choice_child_name: choice,
    client_data_child_name: client,
  }
}

///|
/// XSD complex type CT_Drawing — Part 1 §20.5.2.35. Optional unbounded
/// EG_Anchor group sequence: `twoCellAnchor` (CT_TwoCellAnchor),
/// `oneCellAnchor` (CT_OneCellAnchor), `absoluteAnchor` (CT_AbsoluteAnchor).
pub(all) struct CT_Drawing {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// Local names of EG_Anchor children in document order.
  anchor_child_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_Drawing from its source XML element.
pub fn CT_Drawing::new(element : @xml.Element) -> CT_Drawing {
  let names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      match name {
        "twoCellAnchor" | "oneCellAnchor" | "absoluteAnchor" => names.push(name)
        _ => ()
      }
    }
  }
  { element, anchor_child_names: names }
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
/// XSD complex type CT_ClientData from vml-spreadsheetDrawing.xsd — Part 4
/// §14.4.2.12. Required `ObjectType` attribute (ST_ObjectType); unbounded
/// choice of legacy VML form-control child elements stored as a raw name list.
pub(all) struct CT_ClientData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ObjectType (ST_ObjectType) — required.
  object_type : String
  /// Local names of VML control-state children in document order.
  child_names : Array[String]
} derive(Eq, Debug)

///|
/// Construct CT_ClientData from its source XML element.
pub fn CT_ClientData::new(
  element : @xml.Element,
) -> CT_ClientData raise SchemaViolation {
  let object_type_value = require_attr(
    element, "ObjectType", "CT_ClientData/@ObjectType",
  )
  ST_ObjectType::new(object_type_value) |> ignore
  let child_names : Array[String] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      child_names.push(child_element.name.local_name)
    }
  }
  { element, object_type: object_type_value, child_names }
}

///|
/// XSD element ClientData in vml-spreadsheetDrawing.xsd.
pub type ClientData = CT_ClientData

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
pub fn read_client_data(bytes : Bytes) -> ClientData raise {
  let root = @xml.parse(bytes).root
  require_local(root, "ClientData", "ClientData", "vml-spreadsheetDrawing.xsd")
  CT_ClientData::new(root)
}

///|
/// Write top-level XSD element ClientData.
pub fn write_client_data(value : ClientData) -> Bytes {
  write_element(value.element)
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
fn require_attr(
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
        reason="required attribute missing",
      )
  }
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
