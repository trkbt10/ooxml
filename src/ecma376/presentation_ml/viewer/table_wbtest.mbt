// Whitebox tests for §21.1.3 DrawingML table → SVG renderer.

///|
/// Serialise the table node list by wrapping it in a single `<g>` SVG
/// element and serialising through `@markup.serialize_svg` — the same
/// writer the renderer uses, so the test inspects exactly the markup
/// that would be embedded.  Empty when the node list is empty.
fn table_nodes_markup(nodes : Array[@xml.Node]) -> String {
  if nodes.length() == 0 {
    return ""
  }
  match @markup.elem_ns("g", @markup.svg_ns, [], nodes) {
    @xml.Node::Element(g) => @markup.serialize_svg(g)
    _ => ""
  }
}

///|
fn parse_graphic_frame(inner : String) -> @xml.Element raise {
  let src = "<p:graphicFrame xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\">" +
    inner +
    "</p:graphicFrame>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  doc.root
}

///|
test "2x2 table emits four rects" {
  // tblGrid widths 9525 each = 1px scaled; we let the frame size scale
  // them to 100/100.
  let frame = parse_graphic_frame(
    "<a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">" +
    "<a:tbl>" +
    "<a:tblGrid><a:gridCol w=\"914400\"/><a:gridCol w=\"914400\"/></a:tblGrid>" +
    "<a:tr h=\"914400\"><a:tc/><a:tc/></a:tr>" +
    "<a:tr h=\"914400\"><a:tc/><a:tc/></a:tr>" +
    "</a:tbl>" +
    "</a:graphicData></a:graphic>",
  )
  let defs = SvgDefsCollector::new()
  let svg = table_nodes_markup(
    render_graphic_frame_table_svg(
      frame,
      200.0,
      100.0,
      ColorResolveContext::empty(),
      defs,
    ),
  )
  assert_true(svg.contains("<g class=\"tbl\">"))
  // Four cells = four <rect>.
  assert_eq(count_substring(svg, "<rect "), 4)
}

///|
test "gridSpan=2 collapses two cells into one wide rect" {
  let frame = parse_graphic_frame(
    "<a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">" +
    "<a:tbl>" +
    "<a:tblGrid><a:gridCol w=\"914400\"/><a:gridCol w=\"914400\"/></a:tblGrid>" +
    "<a:tr h=\"914400\"><a:tc gridSpan=\"2\"/></a:tr>" +
    "</a:tbl>" +
    "</a:graphicData></a:graphic>",
  )
  let defs = SvgDefsCollector::new()
  let svg = table_nodes_markup(
    render_graphic_frame_table_svg(
      frame,
      200.0,
      100.0,
      ColorResolveContext::empty(),
      defs,
    ),
  )
  // One rect only, spanning full width = 200.
  assert_eq(count_substring(svg, "<rect "), 1)
  assert_true(svg.contains("width=\"200\""))
}

///|
test "hMerge / vMerge skip ghost cell rect emission" {
  let frame = parse_graphic_frame(
    "<a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">" +
    "<a:tbl>" +
    "<a:tblGrid><a:gridCol w=\"914400\"/><a:gridCol w=\"914400\"/></a:tblGrid>" +
    "<a:tr h=\"914400\"><a:tc/><a:tc hMerge=\"1\"/></a:tr>" +
    "</a:tbl>" +
    "</a:graphicData></a:graphic>",
  )
  let defs = SvgDefsCollector::new()
  let svg = table_nodes_markup(
    render_graphic_frame_table_svg(
      frame,
      200.0,
      100.0,
      ColorResolveContext::empty(),
      defs,
    ),
  )
  assert_eq(count_substring(svg, "<rect "), 1)
}

///|
test "tcPr/solidFill emits cell rect fill" {
  let frame = parse_graphic_frame(
    "<a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">" +
    "<a:tbl>" +
    "<a:tblGrid><a:gridCol w=\"914400\"/></a:tblGrid>" +
    "<a:tr h=\"914400\"><a:tc><a:tcPr><a:solidFill><a:srgbClr val=\"FF0000\"/></a:solidFill></a:tcPr></a:tc></a:tr>" +
    "</a:tbl>" +
    "</a:graphicData></a:graphic>",
  )
  let defs = SvgDefsCollector::new()
  let svg = table_nodes_markup(
    render_graphic_frame_table_svg(
      frame,
      100.0,
      100.0,
      ColorResolveContext::empty(),
      defs,
    ),
  )
  // The resolver lowercases scheme palette values but preserves
  // srgbClr's exact-hex casing — accept either via case-insensitive
  // contains.
  let lower_svg = svg.to_lower()
  assert_true(lower_svg.contains("fill=\"#ff0000\""))
}

///|
test "tcPr/lnB emits a bottom border <line>" {
  let frame = parse_graphic_frame(
    "<a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">" +
    "<a:tbl>" +
    "<a:tblGrid><a:gridCol w=\"914400\"/></a:tblGrid>" +
    "<a:tr h=\"914400\"><a:tc><a:tcPr><a:lnB w=\"19050\"><a:solidFill><a:srgbClr val=\"000000\"/></a:solidFill></a:lnB></a:tcPr></a:tc></a:tr>" +
    "</a:tbl>" +
    "</a:graphicData></a:graphic>",
  )
  let defs = SvgDefsCollector::new()
  let svg = table_nodes_markup(
    render_graphic_frame_table_svg(
      frame,
      100.0,
      100.0,
      ColorResolveContext::empty(),
      defs,
    ),
  )
  assert_true(svg.contains("<line "))
  assert_true(svg.contains("stroke=\"#000000\""))
  assert_true(svg.contains("stroke-width=\"19050\""))
}

///|
test "no <a:tbl> returns empty string" {
  let frame = parse_graphic_frame(
    "<a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/chart\"/></a:graphic>",
  )
  let defs = SvgDefsCollector::new()
  let nodes = render_graphic_frame_table_svg(
    frame,
    100.0,
    100.0,
    ColorResolveContext::empty(),
    defs,
  )
  inspect(nodes.length(), content="0")
}
