// DrawingML Chart Drawing fixtures — ECMA-376 Part 1 §21.3.
//
// A Chart Drawing part is reached from a chart part through the
// `chartUserShapes` relationship.  The part root is `c:userShapes`
// from dml-chart.xsd; its content model is `cdr:CT_Drawing`, so the
// visible payload below exercises chartDrawing (`cdr:*`) anchors and
// object choices inside a real `.pptx` package graph.

///|
const NS_CDR : String = "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"

///|
fn cdr_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  xep("cdr", NS_CDR, tag, attrs, kids)
}

///|
fn cdr_marker(name : String, x : String, y : String) -> @xml.Element {
  cdr_elem(name, [], [
    Element(cdr_elem("x", [], [Text(x)])),
    Element(cdr_elem("y", [], [Text(y)])),
  ])
}

///|
fn cdr_nv_drawing_props(id_ : String, name : String) -> @xml.Element {
  cdr_elem("cNvPr", [xa("id", id_), xa("name", name)], [])
}

///|
fn cdr_prst_geom(prst : String) -> @xml.Element {
  xe(NS_A, "prstGeom", [xa("prst", prst)], [Element(xe(NS_A, "avLst", [], []))])
}

///|
fn cdr_shape_props(prst : String, fill : String) -> @xml.Element {
  cdr_elem("spPr", [], [
    Element(cdr_prst_geom(prst)),
    Element(
      xe(NS_A, "solidFill", [], [
        Element(xe(NS_A, "srgbClr", [xa("val", fill)], [])),
      ]),
    ),
  ])
}

///|
fn cdr_shape_style() -> @xml.Element {
  let ref_color = fn(val : String) -> @xml.Element {
    xe(NS_A, "schemeClr", [xa("val", val)], [])
  }
  cdr_elem("style", [], [
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
fn cdr_text_body(text : String) -> @xml.Element {
  cdr_elem("txBody", [], [
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
fn cdr_xfrm2d() -> @xml.Element {
  cdr_elem("xfrm", [], [
    Element(xe(NS_A, "off", [xa("x", "0"), xa("y", "0")], [])),
    Element(xe(NS_A, "ext", [xa("cx", "600000"), xa("cy", "300000")], [])),
  ])
}

///|
fn cdr_shape(id_ : String, name : String, fill : String) -> @xml.Element {
  cdr_elem("sp", [xa("macro", ""), xa("fLocksText", "true")], [
    Element(
      cdr_elem("nvSpPr", [], [
        Element(cdr_nv_drawing_props(id_, name)),
        Element(cdr_elem("cNvSpPr", [], [])),
      ]),
    ),
    Element(cdr_shape_props("rect", fill)),
    Element(cdr_shape_style()),
    Element(cdr_text_body(name)),
  ])
}

///|
fn cdr_connector(id_ : String, name : String) -> @xml.Element {
  cdr_elem("cxnSp", [xa("macro", "")], [
    Element(
      cdr_elem("nvCxnSpPr", [], [
        Element(cdr_nv_drawing_props(id_, name)),
        Element(cdr_elem("cNvCxnSpPr", [], [])),
      ]),
    ),
    Element(cdr_shape_props("straightConnector1", "6b7280")),
  ])
}

///|
fn cdr_picture(id_ : String, name : String) -> @xml.Element {
  cdr_elem("pic", [xa("macro", "")], [
    Element(
      cdr_elem("nvPicPr", [], [
        Element(cdr_nv_drawing_props(id_, name)),
        Element(cdr_elem("cNvPicPr", [], [])),
      ]),
    ),
    Element(
      cdr_elem("blipFill", [], [
        Element(
          xe(NS_A, "stretch", [], [Element(xe(NS_A, "fillRect", [], []))]),
        ),
      ]),
    ),
    Element(cdr_shape_props("rect", "d9ead3")),
  ])
}

///|
fn cdr_graphic_frame(id_ : String, name : String) -> @xml.Element {
  cdr_elem("graphicFrame", [xa("macro", "")], [
    Element(
      cdr_elem("nvGraphicFramePr", [], [
        Element(cdr_nv_drawing_props(id_, name)),
        Element(cdr_elem("cNvGraphicFramePr", [], [])),
      ]),
    ),
    Element(cdr_xfrm2d()),
    Element(
      xe(NS_A, "graphic", [], [
        Element(
          xe(NS_A, "graphicData", [xa("uri", "urn:ooxml:chartDrawing")], []),
        ),
      ]),
    ),
  ])
}

///|
fn cdr_group_shape(id_ : String, name : String) -> @xml.Element {
  cdr_elem("grpSp", [], [
    Element(
      cdr_elem("nvGrpSpPr", [], [
        Element(cdr_nv_drawing_props(id_, name)),
        Element(cdr_elem("cNvGrpSpPr", [], [])),
      ]),
    ),
    Element(cdr_elem("grpSpPr", [], [])),
  ])
}

///|
fn cdr_abs_anchor(x : String, y : String, obj : @xml.Element) -> @xml.Element {
  cdr_elem("absSizeAnchor", [], [
    Element(cdr_marker("from", x, y)),
    Element(cdr_elem("ext", [xa("cx", "1200000"), xa("cy", "650000")], [])),
    Element(obj),
  ])
}

///|
fn cdr_rel_anchor(obj : @xml.Element) -> @xml.Element {
  cdr_elem("relSizeAnchor", [], [
    Element(cdr_marker("from", "0.05", "0.10")),
    Element(cdr_marker("to", "0.30", "0.35")),
    Element(obj),
  ])
}

///|
fn chart_drawing_user_shapes() -> @xml.Element {
  c_elem("userShapes", [], [
    Element(cdr_abs_anchor("0.10", "0.12", cdr_shape("10", "Shape", "dceaff"))),
    Element(cdr_rel_anchor(cdr_connector("11", "Connector"))),
    Element(cdr_abs_anchor("0.42", "0.16", cdr_picture("12", "Picture"))),
    Element(cdr_abs_anchor("0.12", "0.52", cdr_graphic_frame("13", "Graphic"))),
    Element(cdr_abs_anchor("0.52", "0.52", cdr_group_shape("14", "Group"))),
  ])
}

///|
fn extras_dml_chart_drawing(cases : Array[ChartUserShapesCase]) -> Unit {
  cases.push({
    id: "user-shapes-rich",
    format: "pptx",
    category: "chart/user-shapes",
    content: sp_tree([chart_graphic_frame("2", "Chart User Shapes")]),
    chart_space: default_minimal_chart_space_with_userShapes(),
    user_shapes: chart_drawing_user_shapes(),
  })
}
