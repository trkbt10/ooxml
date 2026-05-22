// vml-spreadsheetDrawing.xsd typed CT projections — Part 4 §A.6.x.
// Target namespace: urn:schemas-microsoft-com:office:excel (`x:` prefix).
//
// XSD top-level element `x:ClientData` (CT_ClientData) carries the
// legacy form-control state for embedded Excel objects (button,
// checkbox, listbox, etc.).

///|
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
fn x_attr(element : @xml.Element, name : String) -> String? {
  for attribute in element.attributes {
    if attribute.name.local_name == name {
      return Some(attribute.value)
    }
  }
  None
}

///|
fn x_require_attr(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> String raise SchemaViolation {
  match x_attr(element, local_name) {
    Some(value) => value
    None =>
      raise SchemaViolation(
        schema="vml-spreadsheetDrawing.xsd",
        path~,
        reason="required attribute missing",
      )
  }
}

///|
fn x_element_text(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for node in element.children {
    match node {
      @xml.Node::Text(value) | @xml.Node::CData(value) => out.write_string(value)
      _ => ()
    }
  }
  out.to_string()
}

///|
fn write_element(element : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: element })
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      schema="vml-spreadsheetDrawing.xsd",
      path=local_name,
      reason="unexpected element name " + element.name.local_name,
    )
  }
}

///|
/// XSD simple type ST_CF from vml-spreadsheetDrawing.xsd. The legacy
/// `<x:CF>` payload type — preserved as a plain string carrier.
pub struct ST_CF {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_CF::new(s : String) -> ST_CF {
  { value: s }
}

///|
pub fn ST_CF::to_string(self : ST_CF) -> String {
  self.value
}

///|
/// XSD simple type ST_ObjectType from vml-spreadsheetDrawing.xsd.
/// Enumerates the legacy form-control kinds that a `<x:ClientData>`
/// element may decorate.
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
/// Per-child entry of `<x:ClientData>`. CT_ClientData's choice list
/// has 67 arms (Annex A.6 vml-spreadsheetDrawing.xsd); each entry
/// preserves the local name and the lexical text payload so the leaf
/// type (s:ST_TrueFalseBlank / xsd:integer / xsd:string / ST_CF) can
/// be resolved by the consumer.
pub(all) enum ClientDataChild {
  /// Known VML form-control child element keyed by local name.
  Known(name~ : String, text~ : String)
  /// Unknown / xsd:any extension child — preserved verbatim.
  Unknown(String, String)
} derive(Eq, Debug)

///|
fn is_client_data_child_name(name : String) -> Bool {
  match name {
    "MoveWithCells"
    | "SizeWithCells"
    | "Anchor"
    | "Locked"
    | "DefaultSize"
    | "PrintObject"
    | "Disabled"
    | "AutoFill"
    | "AutoLine"
    | "AutoPict"
    | "FmlaMacro"
    | "TextHAlign"
    | "TextVAlign"
    | "LockText"
    | "JustLastX"
    | "SecretEdit"
    | "Default"
    | "Help"
    | "Cancel"
    | "Dismiss"
    | "Accel"
    | "Accel2"
    | "Row"
    | "Column"
    | "Visible"
    | "RowHidden"
    | "ColHidden"
    | "VTEdit"
    | "MultiLine"
    | "VScroll"
    | "ValidIds"
    | "FmlaRange"
    | "WidthMin"
    | "Sel"
    | "NoThreeD2"
    | "SelType"
    | "MultiSel"
    | "LCT"
    | "ListItem"
    | "DropStyle"
    | "Colored"
    | "DropLines"
    | "Checked"
    | "FmlaLink"
    | "FmlaPict"
    | "NoThreeD"
    | "FirstButton"
    | "FmlaGroup"
    | "Val"
    | "Min"
    | "Max"
    | "Inc"
    | "Page"
    | "Horiz"
    | "Dx"
    | "MapOCX"
    | "CF"
    | "Camera"
    | "RecalcAlways"
    | "AutoScale"
    | "DDE"
    | "UIObj"
    | "ScriptText"
    | "ScriptExtended"
    | "ScriptLanguage"
    | "ScriptLocation"
    | "FmlaTxbx" => true
    _ => false
  }
}

///|
/// XSD complex type CT_ClientData — vml-spreadsheetDrawing.xsd.
pub(all) struct CT_ClientData {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @ObjectType (ST_ObjectType) — required.
  object_type : ST_ObjectType
  /// VML legacy control-state children in document order.
  children : Array[ClientDataChild]
} derive(Eq, Debug)

///|
pub fn CT_ClientData::new(
  element : @xml.Element,
) -> CT_ClientData raise SchemaViolation {
  let object_type_value = x_require_attr(
    element, "ObjectType", "CT_ClientData/@ObjectType",
  )
  let object_type = ST_ObjectType::new(object_type_value)
  let children : Array[ClientDataChild] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      let name = child_element.name.local_name
      let value = x_element_text(child_element)
      if is_client_data_child_name(name) {
        children.push(Known(name~, text=value))
      } else {
        children.push(Unknown(name, value))
      }
    }
  }
  { element, object_type, children }
}

///|
pub fn CT_ClientData::to_element(self : CT_ClientData) -> @xml.Element {
  self.element
}

///|
/// XSD element alias `<x:ClientData>` → CT_ClientData.
pub type ClientData = CT_ClientData

///|
pub fn read_client_data(bytes : Bytes) -> ClientData raise {
  let root = @xml.parse(bytes).root
  require_local(root, "ClientData")
  CT_ClientData::new(root)
}

///|
pub fn write_client_data(value : ClientData) -> Bytes {
  write_element(value.element)
}
