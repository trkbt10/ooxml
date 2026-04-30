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
/// XSD complex type CT_AnchorClientData from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_AnchorClientData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ShapeNonVisual from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_ShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Shape from dml-spreadsheetDrawing.xsd.
/// Schema dml-spreadsheetDrawing.xsd complex type CT_Shape.
/// Domain type CT_Shape preserves nvSpPr, spPr, style, txBody, and attributes.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_ConnectorNonVisual from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_ConnectorNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Connector from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_Connector {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_PictureNonVisual from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_PictureNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Picture from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_Picture {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GraphicalObjectFrameNonVisual from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_GraphicalObjectFrameNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GraphicalObjectFrame from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_GraphicalObjectFrame {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShapeNonVisual from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_GroupShapeNonVisual {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_GroupShape from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_GroupShape {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Rel from dml-spreadsheetDrawing.xsd.
/// Schema dml-spreadsheetDrawing.xsd complex type CT_Rel.
/// Domain type CT_Rel preserves relationship-backed contentPart entries.
pub(all) struct CT_Rel {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Marker from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_Marker {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_TwoCellAnchor from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_TwoCellAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_OneCellAnchor from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_OneCellAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_AbsoluteAnchor from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_AbsoluteAnchor {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Drawing from dml-spreadsheetDrawing.xsd.
pub(all) struct CT_Drawing {
  element : @xml.Element
} derive(Eq, Debug)

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
/// XSD complex type CT_ClientData from vml-spreadsheetDrawing.xsd.
pub(all) struct CT_ClientData {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD element ClientData in vml-spreadsheetDrawing.xsd.
pub type ClientData = CT_ClientData

///|
/// Read top-level XSD element from as CT_Marker.
pub fn read_from(bytes : Bytes) -> From raise {
  let root = @xml.parse(bytes).root
  require_local(root, "from", "from", "dml-spreadsheetDrawing.xsd")
  validate_marker(root, "from")
  { element: root }
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
  validate_marker(root, "to")
  { element: root }
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
  { element: root }
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
  match attr(root, "ObjectType") {
    Some(value) => ST_ObjectType::new(value) |> ignore
    None => ()
  }
  { element: root }
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
fn validate_marker(element : @xml.Element, path : String) -> Unit raise {
  let col = required_child_text(element, "col", path + "/col")
  ST_ColID::new(col) |> ignore
  required_child_text(element, "colOff", path + "/colOff") |> ignore
  let row = required_child_text(element, "row", path + "/row")
  ST_RowID::new(row) |> ignore
  required_child_text(element, "rowOff", path + "/rowOff") |> ignore
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
