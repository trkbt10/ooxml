// DrawingML Spreadsheet Drawing fixtures - ECMA-376 Part 1 section 20.5
// (dml-spreadsheetDrawing.xsd).
//
// The fixture is a `.xlsx` whose worksheet has `<drawing r:id="rIdD1">`
// and a real `xl/drawings/drawing1.xml` part.  The package builder
// (`xlsx_with_drawing_root_package` in verify.mbt) owns the worksheet
// relationship, drawing content type, and the drawing-side `customXml`
// relationship used by `<xdr:contentPart r:id="svg1"/>`.

///|
const NS_XDR : String = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"

///|
const XDR_FIXTURE_NS : String = "urn:ooxml:fixture:spreadsheet-drawing"

///|
fn xdr_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: { prefix: Some("xdr"), local_name: tag, ns: Some(NS_XDR) },
    attributes: attrs,
    children: kids,
  }
}

///|
fn xdr_rel_id(id : String) -> @xml.Attribute {
  {
    name: { prefix: Some("r"), local_name: "id", ns: Some(NS_OFFICE_REL) },
    value: id,
  }
}

///|
fn xdr_marker(tag : String, col : String, row : String) -> @xml.Element {
  xdr_elem(tag, [], [
    Element(xdr_elem("col", [], [Text(col)])),
    Element(xdr_elem("colOff", [], [Text("0")])),
    Element(xdr_elem("row", [], [Text(row)])),
    Element(xdr_elem("rowOff", [], [Text("0")])),
  ])
}

///|
fn xdr_size(cx : String, cy : String) -> @xml.Element {
  xdr_elem("ext", [xa("cx", cx), xa("cy", cy)], [])
}

///|
fn xdr_pos(x : String, y : String) -> @xml.Element {
  xdr_elem("pos", [xa("x", x), xa("y", y)], [])
}

///|
fn xdr_client_data() -> @xml.Element {
  xdr_elem(
    "clientData",
    [xa("fLocksWithSheet", "1"), xa("fPrintsWithSheet", "1")],
    [],
  )
}

///|
fn xdr_shape_props(prst : String, color : String) -> @xml.Element {
  xdr_elem("spPr", [], [
    Element(
      xe(NS_A, "prstGeom", [xa("prst", prst)], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(
      xe(NS_A, "solidFill", [], [
        Element(xe(NS_A, "srgbClr", [xa("val", color)], [])),
      ]),
    ),
  ])
}

///|
fn xdr_shape_style() -> @xml.Element {
  let ref_color = fn(val : String) -> @xml.Element {
    xe(NS_A, "schemeClr", [xa("val", val)], [])
  }
  xdr_elem("style", [], [
    Element(
      xe(NS_A, "lnRef", [xa("idx", "1")], [Element(ref_color("accent1"))]),
    ),
    Element(
      xe(NS_A, "fillRef", [xa("idx", "1")], [Element(ref_color("accent2"))]),
    ),
    Element(
      xe(NS_A, "effectRef", [xa("idx", "1")], [Element(ref_color("accent3"))]),
    ),
    Element(
      xe(NS_A, "fontRef", [xa("idx", "minor")], [Element(ref_color("tx1"))]),
    ),
  ])
}

///|
fn xdr_text_body(text : String) -> @xml.Element {
  xdr_elem("txBody", [], [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
    Element(
      xe(NS_A, "p", [], [
        Element(
          xe(NS_A, "r", [], [
            Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
            Element(xe(NS_A, "t", [], [Text(text)])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn xdr_shape(id : String, name : String, color : String) -> @xml.Element {
  xdr_elem("sp", [xa("macro", ""), xa("textlink", ""), xa("fLocksText", "0")], [
    Element(
      xdr_elem("nvSpPr", [], [
        Element(xdr_elem("cNvPr", [xa("id", id), xa("name", name)], [])),
        Element(xdr_elem("cNvSpPr", [], [])),
      ]),
    ),
    Element(xdr_shape_props("rect", color)),
    Element(xdr_shape_style()),
    Element(xdr_text_body(name)),
  ])
}

///|
fn xdr_connector(id : String, name : String) -> @xml.Element {
  xdr_elem("cxnSp", [], [
    Element(
      xdr_elem("nvCxnSpPr", [], [
        Element(xdr_elem("cNvPr", [xa("id", id), xa("name", name)], [])),
        Element(xdr_elem("cNvCxnSpPr", [], [])),
      ]),
    ),
    Element(xdr_shape_props("line", "C00000")),
  ])
}

///|
fn xdr_picture(id : String, name : String) -> @xml.Element {
  xdr_elem("pic", [], [
    Element(
      xdr_elem("nvPicPr", [], [
        Element(xdr_elem("cNvPr", [xa("id", id), xa("name", name)], [])),
        Element(xdr_elem("cNvPicPr", [], [])),
      ]),
    ),
    Element(
      xdr_elem("blipFill", [], [
        Element(
          xe(NS_A, "stretch", [], [Element(xe(NS_A, "fillRect", [], []))]),
        ),
      ]),
    ),
    Element(xdr_shape_props("rect", "70AD47")),
  ])
}

///|
fn xdr_graphic_frame(id : String, name : String) -> @xml.Element {
  xdr_elem("graphicFrame", [], [
    Element(
      xdr_elem("nvGraphicFramePr", [], [
        Element(xdr_elem("cNvPr", [xa("id", id), xa("name", name)], [])),
        Element(xdr_elem("cNvGraphicFramePr", [], [])),
      ]),
    ),
    Element(
      xdr_elem("xfrm", [], [
        Element(xe(NS_A, "off", [xa("x", "0"), xa("y", "0")], [])),
        Element(xe(NS_A, "ext", [xa("cx", "914400"), xa("cy", "457200")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "graphic", [], [
        Element(xe(NS_A, "graphicData", [xa("uri", XDR_FIXTURE_NS)], [])),
      ]),
    ),
  ])
}

///|
fn xdr_group_shape(id : String, name : String) -> @xml.Element {
  xdr_elem("grpSp", [], [
    Element(
      xdr_elem("nvGrpSpPr", [], [
        Element(xdr_elem("cNvPr", [xa("id", id), xa("name", name)], [])),
        Element(xdr_elem("cNvGrpSpPr", [], [])),
      ]),
    ),
    Element(
      xdr_elem("grpSpPr", [], [
        Element(
          xe(NS_A, "xfrm", [], [
            Element(xe(NS_A, "off", [xa("x", "0"), xa("y", "0")], [])),
            Element(
              xe(NS_A, "ext", [xa("cx", "914400"), xa("cy", "457200")], []),
            ),
            Element(xe(NS_A, "chOff", [xa("x", "0"), xa("y", "0")], [])),
            Element(
              xe(NS_A, "chExt", [xa("cx", "914400"), xa("cy", "457200")], []),
            ),
          ]),
        ),
      ]),
    ),
    Element(xdr_shape("31", "Nested Shape", "F4B183")),
  ])
}

///|
fn xdr_content_part() -> @xml.Element {
  xdr_elem("contentPart", [xdr_rel_id("svg1")], [])
}

///|
fn xdr_two_cell_anchor(
  from_col : String,
  from_row : String,
  to_col : String,
  to_row : String,
  object : @xml.Element,
) -> @xml.Element {
  xdr_elem("twoCellAnchor", [xa("editAs", "twoCell")], [
    Element(xdr_marker("from", from_col, from_row)),
    Element(xdr_marker("to", to_col, to_row)),
    Element(object),
    Element(xdr_client_data()),
  ])
}

///|
fn xdr_one_cell_anchor(
  from_col : String,
  from_row : String,
  object : @xml.Element,
) -> @xml.Element {
  xdr_elem("oneCellAnchor", [], [
    Element(xdr_marker("from", from_col, from_row)),
    Element(xdr_size("914400", "457200")),
    Element(object),
    Element(xdr_client_data()),
  ])
}

///|
fn xdr_absolute_anchor(
  x : String,
  y : String,
  object : @xml.Element,
) -> @xml.Element {
  xdr_elem("absoluteAnchor", [], [
    Element(xdr_pos(x, y)),
    Element(xdr_size("914400", "457200")),
    Element(object),
    Element(xdr_client_data()),
  ])
}

///|
fn spreadsheet_drawing_rich_root() -> @xml.Element {
  xdr_elem("wsDr", [], [
    Element(
      xdr_two_cell_anchor(
        "0",
        "0",
        "3",
        "4",
        xdr_shape("2", "Two Cell Shape", "4472C4"),
      ),
    ),
    Element(
      xdr_one_cell_anchor("4", "0", xdr_group_shape("3", "Grouped Shapes")),
    ),
    Element(
      xdr_absolute_anchor(
        "0",
        "914400",
        xdr_graphic_frame("4", "Graphic Frame"),
      ),
    ),
    Element(
      xdr_two_cell_anchor("0", "6", "3", "8", xdr_connector("5", "Connector")),
    ),
    Element(xdr_one_cell_anchor("4", "6", xdr_picture("6", "Picture Choice"))),
    Element(xdr_absolute_anchor("1828800", "914400", xdr_content_part())),
  ])
}

///|
fn extras_dml_spreadsheet_drawing(
  xdcases : Array[SpreadsheetDrawingCase],
) -> Unit {
  xdcases.push({
    id: "spreadsheet-drawing-rich-anchors",
    format: "xlsx",
    category: "drawing",
    drawing: spreadsheet_drawing_rich_root(),
  })
}
