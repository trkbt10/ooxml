// Whitebox tests for the §20.1.8.37/.57 line-end marker emission.

///|
/// Serialise a structured marker attribute list by threading it onto
/// a `<g>` SVG element and serialising through `@markup.serialize_svg`
/// — the same writer the renderer uses, so the test inspects exactly
/// the markup that would be emitted.  Empty when the list is empty.
fn marker_attrs_markup(attrs : Array[@xml.Attribute]) -> String {
  if attrs.length() == 0 {
    return ""
  }
  match @markup.elem_ns("g", @markup.svg_ns, attrs, []) {
    @xml.Node::Element(g) => @markup.serialize_svg(g)
    _ => ""
  }
}

///|
fn build_ln(ln_xml : String) -> @xml.Element raise {
  let src = "<p:wrap xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\">" +
    ln_xml +
    "</p:wrap>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  // Drill to the single <a:ln> child.
  match first_child_named(doc.root, "ln") {
    Some(e) => e
    None => abort("expected <a:ln> child")
  }
}

///|
test "triangle headEnd → marker-start url + polygon defs" {
  let line = build_ln(
    "<a:ln><a:headEnd type=\"triangle\" w=\"med\" len=\"med\"/></a:ln>",
  )
  let defs = SvgDefsCollector::new()
  let result = build_line_marker_attrs(line, 1.0, "#000000", defs)
  assert_true(
    marker_attrs_markup(result.marker_start_attrs).contains(
      "marker-start=\"url(#marker-head-triangle-med-med-000000)\"",
    ),
  )
  inspect(result.marker_end_attrs.length(), content="0")
  let defs_str = defs.to_defs_element()
  assert_true(
    defs_str.contains("<marker id=\"marker-head-triangle-med-med-000000\""),
  )
  assert_true(defs_str.contains("<polygon"))
}

///|
test "stealth tailEnd lg/lg → marker-end and 5x size" {
  let line = build_ln(
    "<a:ln><a:tailEnd type=\"stealth\" w=\"lg\" len=\"lg\"/></a:ln>",
  )
  let defs = SvgDefsCollector::new()
  let result = build_line_marker_attrs(line, 2.0, "#FF0000", defs)
  inspect(result.marker_start_attrs.length(), content="0")
  assert_true(
    marker_attrs_markup(result.marker_end_attrs).contains(
      "marker-end=\"url(#marker-tail-stealth-lg-lg-FF0000)\"",
    ),
  )
  let defs_str = defs.to_defs_element()
  // markerWidth = stroke_width 2.0 * 5.0 = 10
  assert_true(defs_str.contains("markerWidth=\"10\""))
  // refX = markerWidth (tail position)
  assert_true(defs_str.contains("refX=\"10\""))
}

///|
test "oval emits <ellipse> body" {
  let line = build_ln("<a:ln><a:tailEnd type=\"oval\"/></a:ln>")
  let defs = SvgDefsCollector::new()
  let _ = build_line_marker_attrs(line, 1.0, "#00FF00", defs)
  assert_true(defs.to_defs_element().contains("<ellipse"))
}

///|
test "arrow emits open polyline (fill=none)" {
  let line = build_ln("<a:ln><a:tailEnd type=\"arrow\"/></a:ln>")
  let defs = SvgDefsCollector::new()
  let _ = build_line_marker_attrs(line, 2.0, "#0000FF", defs)
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<polyline"))
  assert_true(defs_str.contains("fill=\"none\""))
}

///|
test "none type → no attrs, no defs" {
  let line = build_ln("<a:ln><a:headEnd type=\"none\"/></a:ln>")
  let defs = SvgDefsCollector::new()
  let result = build_line_marker_attrs(line, 1.0, "#000000", defs)
  inspect(result.marker_start_attrs.length(), content="0")
  inspect(result.marker_end_attrs.length(), content="0")
  inspect(defs.to_defs_element(), content="")
}

///|
test "missing type defaults to none" {
  let line = build_ln("<a:ln><a:headEnd/></a:ln>")
  let defs = SvgDefsCollector::new()
  let result = build_line_marker_attrs(line, 1.0, "#000000", defs)
  inspect(result.marker_start_attrs.length(), content="0")
}

///|
test "default w/len are med (3x stroke)" {
  let line = build_ln("<a:ln><a:tailEnd type=\"triangle\"/></a:ln>")
  let defs = SvgDefsCollector::new()
  let _ = build_line_marker_attrs(line, 1.0, "#000000", defs)
  // markerWidth = 1.0 * 3.0 = 3
  assert_true(defs.to_defs_element().contains("markerWidth=\"3\""))
}

///|
test "both headEnd and tailEnd emit two markers" {
  let line = build_ln(
    "<a:ln><a:headEnd type=\"triangle\"/><a:tailEnd type=\"diamond\"/></a:ln>",
  )
  let defs = SvgDefsCollector::new()
  let result = build_line_marker_attrs(line, 1.0, "#000000", defs)
  assert_true(
    marker_attrs_markup(result.marker_start_attrs).contains("triangle"),
  )
  assert_true(marker_attrs_markup(result.marker_end_attrs).contains("diamond"))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("marker-head-triangle"))
  assert_true(defs_str.contains("marker-tail-diamond"))
}
