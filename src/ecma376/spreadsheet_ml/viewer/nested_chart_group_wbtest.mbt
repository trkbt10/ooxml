// §20.5.2.17 grpSp containing a §21.2 chart graphicFrame — a chart
// nested inside a grouped shape must render through the same chart
// bridge as a top-level graphicFrame chart, not collapse to the
// "GraphicFrame" placeholder.

///|
/// Build an element with a bare local name (namespaces are matched by
/// local name throughout the drawing parsers).
fn xe(
  local : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: name(k), value: v })
  }
  { name: name(local), attributes: a, children: kids }
}

///|
fn xek(local : String, kids : Array[@xml.Node]) -> @xml.Node {
  @xml.Node::Element(xe(local, [], kids))
}

///|
/// A grpSp holding one chart graphicFrame (`<c:chart r:id="rId1"/>`
/// under a chart-URI graphicData).
fn chart_group_element() -> @xml.Element {
  let nv_grp = xek("nvGrpSpPr", [
    @xml.Node::Element(xe("cNvPr", [("id", "1"), ("name", "Group 1")], [])),
    xek("cNvGrpSpPr", []),
  ])
  let grp_sp_pr = xek("grpSpPr", [
    xek("xfrm", [
      @xml.Node::Element(xe("chOff", [("x", "0"), ("y", "0")], [])),
      @xml.Node::Element(xe("chExt", [("cx", "1828800"), ("cy", "1371600")], [])),
    ]),
  ])
  let graphic_frame = xek("graphicFrame", [
    xek("nvGraphicFramePr", [
      @xml.Node::Element(xe("cNvPr", [("id", "2"), ("name", "Chart 1")], [])),
      xek("cNvGraphicFramePr", []),
    ]),
    xek("xfrm", [
      @xml.Node::Element(xe("off", [("x", "0"), ("y", "0")], [])),
      @xml.Node::Element(xe("ext", [("cx", "1828800"), ("cy", "1371600")], [])),
    ]),
    xek("graphic", [
      @xml.Node::Element(
        xe(
          "graphicData",
          [("uri", "http://schemas.openxmlformats.org/drawingml/2006/chart")],
          [@xml.Node::Element(xe("chart", [("id", "rId1")], []))],
        ),
      ),
    ]),
  ])
  xe("grpSp", [], [nv_grp, grp_sp_pr, graphic_frame])
}

///|
test "chart nested in a grouped shape renders via the chart bridge" {
  let grp = @drawing.CT_GroupShape::new(chart_group_element())
  // Resolver returns a (minimal) chartSpace for the frame's rId; the
  // chart renderer always yields one <g>, so the frame must NOT fall
  // back to the GraphicFrame placeholder.
  let part_resolver = fn(rid : String) -> @xml.Element? {
    if rid == "rId1" {
      Some(xe("chartSpace", [], [xek("chart", [xek("plotArea", [])])]))
    } else {
      None
    }
  }
  let bounds : DrawingBounds = { x: 0.0, y: 0.0, width: 200.0, height: 150.0 }
  let node = render_drawing_group(
    grp,
    bounds,
    fn(_s) { None },
    SmlThemeColorMap::empty(),
    part_resolver,
  )
  let svg = match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  // The chart bridge wraps its output in <g class="chart">.
  assert_true(svg.contains("class=\"chart\""))
  // …and the labelled-placeholder text must NOT appear for the frame.
  assert_true(!svg.contains(">GraphicFrame<"))
}

///|
test "non-chart graphic frame in a group keeps the placeholder" {
  // A graphicFrame whose graphicData URI is NOT a chart → placeholder.
  let nv_grp = xek("nvGrpSpPr", [
    @xml.Node::Element(xe("cNvPr", [("id", "1"), ("name", "G")], [])),
    xek("cNvGrpSpPr", []),
  ])
  let grp_sp_pr = xek("grpSpPr", [])
  let gframe = xek("graphicFrame", [
    xek("nvGraphicFramePr", [
      @xml.Node::Element(xe("cNvPr", [("id", "2"), ("name", "Tbl")], [])),
      xek("cNvGraphicFramePr", []),
    ]),
    xek("xfrm", []),
    xek("graphic", [
      @xml.Node::Element(
        xe(
          "graphicData",
          [("uri", "http://schemas.openxmlformats.org/drawingml/2006/table")],
          [],
        ),
      ),
    ]),
  ])
  let grp = @drawing.CT_GroupShape::new(
    xe("grpSp", [], [nv_grp, grp_sp_pr, gframe]),
  )
  let bounds : DrawingBounds = { x: 0.0, y: 0.0, width: 200.0, height: 150.0 }
  let node = render_drawing_group(
    grp,
    bounds,
    fn(_s) { None },
    SmlThemeColorMap::empty(),
    fn(_s) { None },
  )
  let svg = match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(svg.contains("GraphicFrame"))
}
