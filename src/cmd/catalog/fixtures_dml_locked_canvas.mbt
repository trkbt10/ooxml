// DrawingML locked canvas fixtures - ECMA-376 Part 1 section 20.3.

///|
const NS_DML_LOCKED_CANVAS : String = "http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas"

///|
const LOCKED_CANVAS_URI : String = "http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas"

///|
fn locked_canvas_root() -> @xml.Element {
  xep("lc", NS_DML_LOCKED_CANVAS, "lockedCanvas", [], [
    Element(
      xe(NS_A, "nvGrpSpPr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "1"), xa("name", "Locked Canvas")], []),
        ),
        Element(xe(NS_A, "cNvGrpSpPr", [], [])),
      ]),
    ),
    Element(xe(NS_A, "grpSpPr", [], [])),
  ])
}

///|
fn locked_canvas_xfrm(
  x : String,
  y : String,
  cx : String,
  cy : String,
) -> @xml.Element {
  xe(NS_A, "xfrm", [], [
    Element(xe(NS_A, "off", [xa("x", x), xa("y", y)], [])),
    Element(xe(NS_A, "ext", [xa("cx", cx), xa("cy", cy)], [])),
  ])
}

///|
fn locked_canvas_group_xfrm() -> @xml.Element {
  xe(NS_A, "xfrm", [], [
    Element(xe(NS_A, "off", [xa("x", "0"), xa("y", "0")], [])),
    Element(xe(NS_A, "ext", [xa("cx", "5486400"), xa("cy", "2743200")], [])),
    Element(xe(NS_A, "chOff", [xa("x", "0"), xa("y", "0")], [])),
    Element(xe(NS_A, "chExt", [xa("cx", "5486400"), xa("cy", "2743200")], [])),
  ])
}

///|
fn locked_canvas_shape_props(
  x : String,
  y : String,
  cx : String,
  cy : String,
  hex : String,
) -> @xml.Element {
  xe(NS_A, "spPr", [], [
    Element(locked_canvas_xfrm(x, y, cx, cy)),
    Element(
      xe(NS_A, "prstGeom", [xa("prst", "rect")], [
        Element(xe(NS_A, "avLst", [], [])),
      ]),
    ),
    Element(solid_fill(hex)),
    Element(dml_main_theme_line()),
  ])
}

///|
fn locked_canvas_text_shape() -> @xml.Element {
  xe(NS_A, "sp", [], [
    Element(
      xe(NS_A, "nvSpPr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "2"), xa("name", "GVML Shape")], []),
        ),
        Element(xe(NS_A, "cNvSpPr", [xa("txBox", "1")], [])),
      ]),
    ),
    Element(locked_canvas_shape_props("0", "0", "1371600", "914400", "D9EAF7")),
    Element(
      xe(NS_A, "txSp", [], [
        Element(
          xe(NS_A, "txBody", [], [
            Element(xe(NS_A, "bodyPr", [], [])),
            Element(xe(NS_A, "p", [], [Element(dml_main_plain_run("GVML"))])),
          ]),
        ),
        Element(xe(NS_A, "useSpRect", [], [])),
      ]),
    ),
  ])
}

///|
fn locked_canvas_connector() -> @xml.Element {
  xe(NS_A, "cxnSp", [], [
    Element(
      xe(NS_A, "nvCxnSpPr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "3"), xa("name", "GVML Connector")], []),
        ),
        Element(
          xe(NS_A, "cNvCxnSpPr", [], [
            Element(xe(NS_A, "cxnSpLocks", [xa("noMove", "1")], [])),
            Element(xe(NS_A, "stCxn", [xa("id", "2"), xa("idx", "0")], [])),
            Element(xe(NS_A, "endCxn", [xa("id", "4"), xa("idx", "0")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      locked_canvas_shape_props("1371600", "0", "1371600", "914400", "FFFFFF"),
    ),
  ])
}

///|
fn locked_canvas_picture() -> @xml.Element {
  xe(NS_A, "pic", [], [
    Element(
      xe(NS_A, "nvPicPr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "4"), xa("name", "GVML Picture")], []),
        ),
        Element(
          xe(NS_A, "cNvPicPr", [], [
            Element(xe(NS_A, "picLocks", [xa("noChangeAspect", "1")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_A, "blipFill", [], [
        Element(xe(NS_A, "blip", [], [])),
        Element(xe(NS_A, "srcRect", [xa("l", "5000"), xa("t", "5000")], [])),
        Element(
          xe(
            NS_A,
            "tile",
            [xa("sx", "50000"), xa("sy", "50000"), xa("algn", "ctr")],
            [],
          ),
        ),
      ]),
    ),
    Element(
      locked_canvas_shape_props("2743200", "0", "1371600", "914400", "E2F0D9"),
    ),
  ])
}

///|
fn locked_canvas_graphical_object_frame() -> @xml.Element {
  xe(NS_A, "graphicFrame", [], [
    Element(
      xe(NS_A, "nvGraphicFramePr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "5"), xa("name", "GVML Graphic Frame")], []),
        ),
        Element(
          xe(NS_A, "cNvGraphicFramePr", [], [
            Element(xe(NS_A, "graphicFrameLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xe(NS_A, "graphic", [], [
        Element(
          xe(NS_A, "graphicData", [xa("uri", DML_MAIN_TABLE_URI)], [
            Element(dml_main_table_style_list_root()),
          ]),
        ),
      ]),
    ),
    Element(locked_canvas_xfrm("4114800", "0", "1371600", "914400")),
  ])
}

///|
fn locked_canvas_nested_group() -> @xml.Element {
  xe(NS_A, "grpSp", [], [
    Element(
      xe(NS_A, "nvGrpSpPr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "6"), xa("name", "GVML Nested Group")], []),
        ),
        Element(
          xe(NS_A, "cNvGrpSpPr", [], [
            Element(xe(NS_A, "grpSpLocks", [xa("noUngrp", "1")], [])),
          ]),
        ),
      ]),
    ),
    Element(xe(NS_A, "grpSpPr", [], [Element(locked_canvas_group_xfrm())])),
  ])
}

///|
fn locked_canvas_rich_root() -> @xml.Element {
  xep("lc", NS_DML_LOCKED_CANVAS, "lockedCanvas", [], [
    Element(
      xe(NS_A, "nvGrpSpPr", [], [
        Element(
          xe(NS_A, "cNvPr", [xa("id", "1"), xa("name", "Rich Locked Canvas")], []),
        ),
        Element(
          xe(NS_A, "cNvGrpSpPr", [], [
            Element(xe(NS_A, "grpSpLocks", [xa("noGrp", "1")], [])),
          ]),
        ),
      ]),
    ),
    Element(xe(NS_A, "grpSpPr", [], [Element(locked_canvas_group_xfrm())])),
    Element(locked_canvas_text_shape()),
    Element(locked_canvas_connector()),
    Element(locked_canvas_picture()),
    Element(locked_canvas_graphical_object_frame()),
    Element(locked_canvas_nested_group()),
  ])
}

///|
fn locked_canvas_graphic_frame(root : @xml.Element) -> @xml.Element {
  xe(NS_PML, "graphicFrame", [], [
    Element(
      xe(NS_PML, "nvGraphicFramePr", [], [
        Element(
          xe(
            NS_PML,
            "cNvPr",
            [xa("id", "2"), xa("name", "Locked Canvas Frame")],
            [],
          ),
        ),
        Element(xe(NS_PML, "cNvGraphicFramePr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "xfrm", [], [
        Element(xe(NS_A, "off", [xa("x", "1828800"), xa("y", "1371600")], [])),
        Element(xe(NS_A, "ext", [xa("cx", "2743200"), xa("cy", "1371600")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "graphic", [], [
        Element(
          xe(NS_A, "graphicData", [xa("uri", LOCKED_CANVAS_URI)], [
            Element(root),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn extras_dml_locked_canvas(cases : Array[VisualCase]) -> Unit {
  cases.push({
    id: "locked-canvas-graphic-data",
    format: "pptx",
    category: "drawing/locked-canvas",
    content: sp_tree([locked_canvas_graphic_frame(locked_canvas_root())]),
  })
  cases.push({
    id: "locked-canvas-gvml-rich",
    format: "pptx",
    category: "drawing/locked-canvas",
    content: sp_tree([locked_canvas_graphic_frame(locked_canvas_rich_root())]),
  })
}
