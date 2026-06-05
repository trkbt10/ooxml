// Legacy VML Spreadsheet Drawing fixtures.
//
// The payload targets vml-spreadsheetDrawing.xsd through an xlsx
// worksheet `<legacyDrawing r:id>` relationship.  This is fixture
// occurrence/XSD coverage for the deprecated VML compatibility surface,
// not a claim that modern Excel form-control behaviour is implemented.

///|
const NS_VML : String = "urn:schemas-microsoft-com:vml"

///|
const NS_VML_EXCEL : String = "urn:schemas-microsoft-com:office:excel"

///|
fn vml_drawing_root(children : Array[@xml.Node]) -> @xml.Element {
  {
    name: { prefix: None, local_name: "xml", ns: None },
    attributes: [],
    children,
  }
}

///|
fn excel_vml_child(name : String, value : String) -> @xml.Element {
  xep("x", NS_VML_EXCEL, name, [], [Text(value)])
}

///|
fn excel_vml_bool_child(name : String) -> @xml.Element {
  excel_vml_child(name, "t")
}

///|
fn excel_vml_integer_child(name : String) -> @xml.Element {
  excel_vml_child(name, "1")
}

///|
fn excel_vml_text_child(name : String) -> @xml.Element {
  excel_vml_child(name, "x")
}

///|
fn excel_vml_client_data_all_children() -> @xml.Element {
  xep("x", NS_VML_EXCEL, "ClientData", [xa("ObjectType", "Button")], [
    Element(excel_vml_bool_child("MoveWithCells")),
    Element(excel_vml_bool_child("SizeWithCells")),
    Element(excel_vml_text_child("Anchor")),
    Element(excel_vml_bool_child("Locked")),
    Element(excel_vml_bool_child("DefaultSize")),
    Element(excel_vml_bool_child("PrintObject")),
    Element(excel_vml_bool_child("Disabled")),
    Element(excel_vml_bool_child("AutoFill")),
    Element(excel_vml_bool_child("AutoLine")),
    Element(excel_vml_bool_child("AutoPict")),
    Element(excel_vml_text_child("FmlaMacro")),
    Element(excel_vml_text_child("TextHAlign")),
    Element(excel_vml_text_child("TextVAlign")),
    Element(excel_vml_bool_child("LockText")),
    Element(excel_vml_bool_child("JustLastX")),
    Element(excel_vml_bool_child("SecretEdit")),
    Element(excel_vml_bool_child("Default")),
    Element(excel_vml_bool_child("Help")),
    Element(excel_vml_bool_child("Cancel")),
    Element(excel_vml_bool_child("Dismiss")),
    Element(excel_vml_integer_child("Accel")),
    Element(excel_vml_integer_child("Accel2")),
    Element(excel_vml_integer_child("Row")),
    Element(excel_vml_integer_child("Column")),
    Element(excel_vml_bool_child("Visible")),
    Element(excel_vml_bool_child("RowHidden")),
    Element(excel_vml_bool_child("ColHidden")),
    Element(excel_vml_integer_child("VTEdit")),
    Element(excel_vml_bool_child("MultiLine")),
    Element(excel_vml_bool_child("VScroll")),
    Element(excel_vml_bool_child("ValidIds")),
    Element(excel_vml_text_child("FmlaRange")),
    Element(excel_vml_integer_child("WidthMin")),
    Element(excel_vml_integer_child("Sel")),
    Element(excel_vml_bool_child("NoThreeD2")),
    Element(excel_vml_text_child("SelType")),
    Element(excel_vml_text_child("MultiSel")),
    Element(excel_vml_text_child("LCT")),
    Element(excel_vml_text_child("ListItem")),
    Element(excel_vml_text_child("DropStyle")),
    Element(excel_vml_bool_child("Colored")),
    Element(excel_vml_integer_child("DropLines")),
    Element(excel_vml_integer_child("Checked")),
    Element(excel_vml_text_child("FmlaLink")),
    Element(excel_vml_text_child("FmlaPict")),
    Element(excel_vml_bool_child("NoThreeD")),
    Element(excel_vml_bool_child("FirstButton")),
    Element(excel_vml_text_child("FmlaGroup")),
    Element(excel_vml_integer_child("Val")),
    Element(excel_vml_integer_child("Min")),
    Element(excel_vml_integer_child("Max")),
    Element(excel_vml_integer_child("Inc")),
    Element(excel_vml_integer_child("Page")),
    Element(excel_vml_bool_child("Horiz")),
    Element(excel_vml_integer_child("Dx")),
    Element(excel_vml_bool_child("MapOCX")),
    Element(excel_vml_text_child("CF")),
    Element(excel_vml_bool_child("Camera")),
    Element(excel_vml_bool_child("RecalcAlways")),
    Element(excel_vml_bool_child("AutoScale")),
    Element(excel_vml_bool_child("DDE")),
    Element(excel_vml_bool_child("UIObj")),
    Element(excel_vml_text_child("ScriptText")),
    Element(excel_vml_text_child("ScriptExtended")),
    Element(excel_vml_integer_child("ScriptLanguage")),
    Element(excel_vml_integer_child("ScriptLocation")),
    Element(excel_vml_text_child("FmlaTxbx")),
  ])
}

///|
fn excel_vml_shape_with_client_data() -> @xml.Element {
  xep(
    "v",
    NS_VML,
    "shape",
    [
      xa("id", "_x0000_s1025"),
      xa(
        "style", "position:absolute;margin-left:0;margin-top:0;width:72pt;height:18pt",
      ),
    ],
    [Element(excel_vml_client_data_all_children())],
  )
}

///|
fn excel_vml_client_data_drawing() -> @xml.Element {
  vml_drawing_root([Element(excel_vml_shape_with_client_data())])
}

///|
fn extras_vml_spreadsheet_drawing(cases : Array[VmlDrawingCase]) -> Unit {
  cases.push({
    id: "vml-spreadsheet-client-data-all-children",
    format: "xlsx",
    category: "vml-spreadsheet-drawing",
    content: xe(NS_S, "sheetData", [], []),
    vml_drawing: excel_vml_client_data_drawing(),
  })
}
