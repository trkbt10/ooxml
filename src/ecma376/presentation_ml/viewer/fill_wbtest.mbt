// White-box tests for the DrawingML fill renderer.
//
// Builds small XmlElement trees for solidFill / noFill / gradFill /
// blipFill and verifies the produced SVG fill attribute value and
// `<defs>` fragments.

///|
/// Reuse make_elt from color_resolver_wbtest by re-declaring here —
/// MoonBit wbtest files don't share private helpers across files.
fn fill_make_elt(
  local_name : String,
  attrs : Array[(String, String)],
  children : Array[@xml.Element],
) -> @xml.Element {
  let attributes : Array[@xml.Attribute] = []
  for pair in attrs {
    let (k, v) = pair
    attributes.push({
      name: { prefix: Some("a"), local_name: k, ns: None },
      value: v,
    })
  }
  let nodes : Array[@xml.Node] = []
  for c in children {
    nodes.push(Element(c))
  }
  {
    name: { prefix: Some("a"), local_name, ns: None },
    attributes,
    children: nodes,
  }
}

///|
test "noFill returns 'none' with is_no_fill set" {
  let elt = fill_make_elt("noFill", [], [])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(elt, defs, ctx)
  inspect(r.attr_value, content="none")
  inspect(r.is_no_fill, content="true")
  inspect(defs.defs.length(), content="0")
}

///|
test "solidFill srgbClr returns #hex" {
  let inner = fill_make_elt("srgbClr", [("val", "FF00FF")], [])
  let sf = fill_make_elt("solidFill", [], [inner])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(sf, defs, ctx)
  inspect(r.attr_value, content="#ff00ff")
  inspect(r.is_no_fill, content="false")
}

///|
test "gradFill emits linearGradient def and url(#id)" {
  let stop0 = fill_make_elt("gs", [("pos", "0")], [
    fill_make_elt("srgbClr", [("val", "FF0000")], []),
  ])
  let stop100 = fill_make_elt("gs", [("pos", "100000")], [
    fill_make_elt("srgbClr", [("val", "0000FF")], []),
  ])
  let gs_lst = fill_make_elt("gsLst", [], [stop0, stop100])
  let lin = fill_make_elt("lin", [("ang", "0")], [])
  let grad = fill_make_elt("gradFill", [], [gs_lst, lin])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(grad, defs, ctx)
  // Generated id is `shape-grad-0` for the first def.
  inspect(r.attr_value, content="url(#shape-grad-0)")
  inspect(defs.defs.length(), content="1")
  // The `<defs>` element should contain both stop colors.
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("ff0000"))
  assert_true(defs_str.contains("0000ff"))
  assert_true(defs_str.contains("linearGradient"))
}

///|
test "gradFill with path child becomes radialGradient" {
  let stop0 = fill_make_elt("gs", [("pos", "0")], [
    fill_make_elt("srgbClr", [("val", "FFFFFF")], []),
  ])
  let stop100 = fill_make_elt("gs", [("pos", "100000")], [
    fill_make_elt("srgbClr", [("val", "000000")], []),
  ])
  let gs_lst = fill_make_elt("gsLst", [], [stop0, stop100])
  let path = fill_make_elt("path", [("path", "circle")], [])
  let grad = fill_make_elt("gradFill", [], [gs_lst, path])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let _ = render_fill_attr(grad, defs, ctx)
  assert_true(defs.to_defs_element().contains("radialGradient"))
}

///|
/// §20.1.8.46 (a:path) / §20.1.8.30 (a:fillToRect) — a radial shape
/// fill with an off-centre `<a:fillToRect>` must move the gradient
/// centre off the 50%/50% default.  With l=50% t=50% r=0% b=0% the
/// uncovered-area midpoint is (75%, 75%) — a bottom-right highlight.
test "gradFill path fillToRect shifts radial centre off 50/50" {
  let stop0 = fill_make_elt("gs", [("pos", "0")], [
    fill_make_elt("srgbClr", [("val", "FFFFFF")], []),
  ])
  let stop100 = fill_make_elt("gs", [("pos", "100000")], [
    fill_make_elt("srgbClr", [("val", "000000")], []),
  ])
  let gs_lst = fill_make_elt("gsLst", [], [stop0, stop100])
  // fillToRect margins in DrawingML 1000ths-of-percent: l=t=50%, r=b=0%.
  let ftr = fill_make_elt(
    "fillToRect",
    [("l", "50000"), ("t", "50000"), ("r", "0"), ("b", "0")],
    [],
  )
  let path = fill_make_elt("path", [("path", "circle")], [ftr])
  let grad = fill_make_elt("gradFill", [], [gs_lst, path])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let _ = render_fill_attr(grad, defs, ctx)
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("radialGradient"))
  // Centre moved to (75%, 75%), not the default (50%, 50%).
  assert_true(defs_str.contains("cx=\"75"))
  assert_true(defs_str.contains("cy=\"75"))
}

///|
test "blipFill with no resolver returns none" {
  let blip = fill_make_elt("blip", [("embed", "rId1")], [])
  let bf = fill_make_elt("blipFill", [], [blip])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(bf, defs, ctx)
  inspect(r.attr_value, content="none")
}

///|
test "blipFill with resolver emits image pattern def" {
  let blip = fill_make_elt("blip", [("embed", "rId7")], [])
  let bf = fill_make_elt("blipFill", [], [blip])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let resolver : (String) -> ResolvedImage? = (_id : String) => {
    let img : ResolvedImage = { mime_type: "image/png", base64_data: "AAAA" }
    Some(img)
  }
  let r = render_fill_attr(
    bf,
    defs,
    ctx,
    shape_width=100.0,
    shape_height=50.0,
    image_resolver=resolver,
  )
  inspect(r.attr_value, content="url(#img-pattern-0)")
  inspect(defs.defs.length(), content="1")
  assert_true(defs.to_defs_element().contains("data:image/png;base64,AAAA"))
}

///|
/// §20.1.8.47 `<a:pattFill prst="cross">` — a cross-hatch preset
/// builds a `<pattern>` def with the foreground rules and a
/// `url(#id)` fill reference.
test "pattFill cross builds a pattern def with fg rules" {
  let fg = fill_make_elt("fgClr", [], [
    fill_make_elt("srgbClr", [("val", "FF0000")], []),
  ])
  let bg = fill_make_elt("bgClr", [], [
    fill_make_elt("srgbClr", [("val", "FFFFFF")], []),
  ])
  let patt = fill_make_elt("pattFill", [("prst", "cross")], [fg, bg])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(patt, defs, ctx)
  inspect(r.attr_value, content="url(#shape-patt-0)")
  inspect(defs.defs.length(), content="1")
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<pattern"))
  // Cross-hatch is two strokes in the foreground colour.
  assert_true(defs_str.contains("#ff0000"))
  assert_true(defs_str.contains("<line"))
}

///|
/// §20.1.10.51 `<a:pattFill prst="pct25">` — a percentage-density
/// preset renders a centred dot tile.
test "pattFill pct25 builds a dotted pattern def" {
  let fg = fill_make_elt("fgClr", [], [
    fill_make_elt("srgbClr", [("val", "000000")], []),
  ])
  let patt = fill_make_elt("pattFill", [("prst", "pct25")], [fg])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(patt, defs, ctx)
  inspect(r.attr_value, content="url(#shape-patt-0)")
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<pattern"))
  assert_true(defs_str.contains("<circle"))
}

///|
/// §20.1.8.47 — a `<a:pattFill>` whose `@prst` is outside
/// ST_PresetPatternVal (a schema violation) falls back to the
/// foreground colour as a flat fill (no `<pattern>` def) so the shape
/// stays visible.  Every spec-enumerated preset now maps to geometry.
test "pattFill unmapped preset falls back to flat fg colour" {
  let fg = fill_make_elt("fgClr", [], [
    fill_make_elt("srgbClr", [("val", "00FF00")], []),
  ])
  let patt = fill_make_elt("pattFill", [("prst", "notARealPreset")], [fg])
  let defs = SvgDefsCollector::new()
  let ctx = ColorResolveContext::empty()
  let r = render_fill_attr(patt, defs, ctx)
  inspect(r.attr_value, content="#00ff00")
  inspect(defs.defs.length(), content="0")
}
