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
fn locked_canvas_graphic_frame() -> @xml.Element {
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
            Element(locked_canvas_root()),
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
    content: sp_tree([locked_canvas_graphic_frame()]),
  })
}
