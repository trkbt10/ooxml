// Legacy VML Drawing fixtures.
//
// The payloads target VML schemas through an xlsx worksheet
// `<legacyDrawing r:id>` relationship.  This is fixture occurrence/XSD
// coverage for the deprecated VML compatibility surface, not a claim
// that legacy VML rendering/editing behaviour is implemented.

///|
const NS_VML : String = "urn:schemas-microsoft-com:vml"

///|
const NS_VML_EXCEL : String = "urn:schemas-microsoft-com:office:excel"

///|
const NS_VML_OFFICE : String = "urn:schemas-microsoft-com:office:office"

///|
const NS_VML_WORD : String = "urn:schemas-microsoft-com:office:word"

///|
const NS_VML_PRESENTATION : String = "urn:schemas-microsoft-com:office:powerpoint"

///|
fn vml_drawing_root(children : Array[@xml.Node]) -> @xml.Element {
  {
    name: { prefix: None, local_name: "xml", ns: None },
    attributes: [],
    children,
  }
}

///|
fn vml_el(
  name : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  xep("v", NS_VML, name, attrs, kids)
}

///|
fn office_vml_el(
  name : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  xep("o", NS_VML_OFFICE, name, attrs, kids)
}

///|
fn word_vml_el(
  name : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  xep("w10", NS_VML_WORD, name, attrs, kids)
}

///|
fn powerpoint_vml_el(
  name : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  xep("pvml", NS_VML_PRESENTATION, name, attrs, kids)
}

///|
fn qualified_vml_attr(
  prefix : String,
  ns : String,
  name : String,
  value : String,
) -> @xml.Attribute {
  { name: { prefix: Some(prefix), local_name: name, ns: Some(ns) }, value }
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
fn vml_path() -> @xml.Element {
  vml_el("path", [], [])
}

///|
fn vml_shape_root(name : String) -> @xml.Element {
  vml_el(name, [], [Element(vml_path())])
}

///|
fn vml_main_roots() -> Array[@xml.Node] {
  let roots : Array[@xml.Node] = [
    Element(vml_shape_root("shape")),
    Element(vml_shape_root("shapetype")),
    Element(vml_shape_root("group")),
    Element(vml_el("background", [], [Element(vml_el("fill", [], []))])),
    Element(vml_el("fill", [], [])),
    Element(vml_el("formulas", [], [Element(vml_el("f", [], []))])),
    Element(vml_el("handles", [], [Element(vml_el("h", [], []))])),
    Element(vml_el("imagedata", [], [])),
    Element(vml_path()),
    Element(vml_el("textbox", [], [])),
    Element(vml_el("shadow", [], [])),
    Element(vml_el("stroke", [], [])),
    Element(vml_el("textpath", [], [])),
  ]
  for
    name in [
      "arc", "curve", "image", "line", "oval", "polyline", "rect", "roundrect",
    ] {
    roots.push(Element(vml_shape_root(name)))
  }
  roots
}

///|
fn office_vml_shape_defaults() -> @xml.Element {
  office_vml_el("shapedefaults", [], [
    Element(office_vml_el("colormru", [], [])),
    Element(office_vml_el("colormenu", [], [])),
  ])
}

///|
fn office_vml_shape_layout() -> @xml.Element {
  office_vml_el("shapelayout", [], [
    Element(office_vml_el("idmap", [], [])),
    Element(
      office_vml_el("regrouptable", [], [
        Element(office_vml_el("entry", [], [])),
      ]),
    ),
    Element(
      office_vml_el("rules", [], [
        Element(
          office_vml_el("r", [xa("id", "r1")], [
            Element(office_vml_el("proxy", [], [])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn office_vml_diagram() -> @xml.Element {
  office_vml_el("diagram", [], [
    Element(
      office_vml_el("relationtable", [], [Element(office_vml_el("rel", [], []))]),
    ),
  ])
}

///|
fn office_vml_ole_object() -> @xml.Element {
  office_vml_el("OLEObject", [xa("Type", "Embed")], [
    Element(office_vml_el("LinkType", [], [Text("link")])),
    Element(office_vml_el("LockedField", [], [Text("f")])),
    Element(office_vml_el("FieldCodes", [], [Text("FIELD")])),
  ])
}

///|
fn office_vml_roots() -> Array[@xml.Node] {
  [
    Element(office_vml_shape_defaults()),
    Element(office_vml_shape_layout()),
    Element(office_vml_el("signatureline", [], [])),
    Element(office_vml_el("ink", [], [])),
    Element(office_vml_diagram()),
    Element(office_vml_el("equationxml", [], [Element(vml_path())])),
    Element(office_vml_el("skew", [], [])),
    Element(office_vml_el("extrusion", [], [])),
    Element(office_vml_el("callout", [], [])),
    Element(office_vml_el("lock", [], [])),
    Element(office_vml_ole_object()),
    Element(office_vml_el("complex", [], [])),
    Element(office_vml_el("left", [], [])),
    Element(office_vml_el("top", [], [])),
    Element(office_vml_el("right", [], [])),
    Element(office_vml_el("bottom", [], [])),
    Element(office_vml_el("column", [], [])),
    Element(
      office_vml_el(
        "clippath",
        [qualified_vml_attr("o", NS_VML_OFFICE, "v", "m 0,0 l 1,1 e")],
        [],
      ),
    ),
    Element(office_vml_el("fill", [], [])),
  ]
}

///|
fn word_vml_roots() -> Array[@xml.Node] {
  [
    Element(
      word_vml_el(
        "bordertop",
        [xa("type", "single"), xa("width", "1"), xa("shadow", "f")],
        [],
      ),
    ),
    Element(
      word_vml_el(
        "borderleft",
        [xa("type", "single"), xa("width", "1"), xa("shadow", "f")],
        [],
      ),
    ),
    Element(
      word_vml_el(
        "borderright",
        [xa("type", "single"), xa("width", "1"), xa("shadow", "f")],
        [],
      ),
    ),
    Element(
      word_vml_el(
        "borderbottom",
        [xa("type", "single"), xa("width", "1"), xa("shadow", "f")],
        [],
      ),
    ),
    Element(
      word_vml_el(
        "wrap",
        [
          xa("type", "square"),
          xa("side", "both"),
          xa("anchorx", "margin"),
          xa("anchory", "page"),
        ],
        [],
      ),
    ),
    Element(word_vml_el("anchorlock", [], [])),
  ]
}

///|
fn powerpoint_vml_roots() -> Array[@xml.Node] {
  [
    Element(powerpoint_vml_el("iscomment", [], [])),
    Element(powerpoint_vml_el("textdata", [xa("id", "rId1")], [])),
  ]
}

///|
fn legacy_vml_root_coverage_drawing() -> @xml.Element {
  let roots : Array[@xml.Node] = []
  for node in vml_main_roots() {
    roots.push(node)
  }
  for node in office_vml_roots() {
    roots.push(node)
  }
  for node in word_vml_roots() {
    roots.push(node)
  }
  for node in powerpoint_vml_roots() {
    roots.push(node)
  }
  vml_drawing_root(roots)
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
  cases.push({
    id: "vml-legacy-root-coverage",
    format: "xlsx",
    category: "vml-office-drawing",
    content: xe(NS_S, "sheetData", [], []),
    vml_drawing: legacy_vml_root_coverage_drawing(),
  })
}
