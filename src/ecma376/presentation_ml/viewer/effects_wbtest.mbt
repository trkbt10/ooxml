// Whitebox tests for the §20.1.8 effect → SVG filter emission.

///|
/// Serialise a structured attribute list by threading it onto a `<g>`
/// SVG element and serialising through `@markup.serialize_svg`, so the
/// test introspects exactly the markup the writer would emit — no
/// hand-assembled fragment.  The `<g …/>` tag and the `xmlns`
/// declaration on the (standalone) root are stable and irrelevant to
/// the `contains` assertions below.
fn attrs_markup(attrs : Array[@xml.Attribute]) -> String {
  match @markup.elem_ns("g", @markup.svg_ns, attrs, []) {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
fn build_sp_pr_with_effect(effect_xml : String) -> @xml.Element raise {
  // Wrap the supplied <a:...> element in an <a:effectLst> inside an
  // <a:spPr> so we can drive `render_effects_filter_attr` from a real
  // parsed XML element.
  let src = "<p:spPr xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"><a:effectLst>" +
    effect_xml +
    "</a:effectLst></p:spPr>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  doc.root
}

///|
test "outerShdw emits a filter with feGaussianBlur+feOffset+feColorMatrix+feMerge" {
  let sp_pr = build_sp_pr_with_effect(
    "<a:outerShdw blurRad=\"50800\" dist=\"38100\" dir=\"2700000\"><a:srgbClr val=\"000000\"/></a:outerShdw>",
  )
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    sp_pr,
    "42",
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(attrs_markup(attr).contains("filter=\"url(#effect-42)\""))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<filter id=\"effect-42\""))
  assert_true(defs_str.contains("feGaussianBlur"))
  assert_true(defs_str.contains("feOffset"))
  assert_true(defs_str.contains("feColorMatrix"))
  assert_true(defs_str.contains("feMerge"))
}

///|
test "innerShdw emits a filter with a clipping feComposite operator=\"in\"" {
  let sp_pr = build_sp_pr_with_effect(
    "<a:innerShdw blurRad=\"40000\" dist=\"30000\" dir=\"5400000\"><a:srgbClr val=\"000000\"/></a:innerShdw>",
  )
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    sp_pr,
    "7",
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(attrs_markup(attr).contains("filter=\"url(#effect-7)\""))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<filter id=\"effect-7\""))
  assert_true(defs_str.contains("feComposite"))
  assert_true(defs_str.contains("operator=\"in\""))
}

///|
test "glow emits a coloured-blur filter merged under the source" {
  let sp_pr = build_sp_pr_with_effect(
    "<a:glow rad=\"63500\"><a:srgbClr val=\"FF0000\"/></a:glow>",
  )
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    sp_pr,
    "11",
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(attrs_markup(attr).contains("filter=\"url(#effect-11)\""))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<filter id=\"effect-11\""))
  assert_true(defs_str.contains("feGaussianBlur"))
  assert_true(defs_str.contains("feColorMatrix"))
}

///|
test "softEdge emits a tight-viewport feather filter" {
  let sp_pr = build_sp_pr_with_effect("<a:softEdge rad=\"25400\"/>")
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    sp_pr,
    "soft",
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(attrs_markup(attr).contains("filter=\"url(#effect-soft)\""))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("x=\"-10%\""))
  assert_true(defs_str.contains("feGaussianBlur"))
  assert_true(defs_str.contains("operator=\"in\""))
}

///|
test "blur emits a plain Gaussian blur filter" {
  let sp_pr = build_sp_pr_with_effect("<a:blur rad=\"20000\"/>")
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    sp_pr,
    "b",
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(attrs_markup(attr).contains("filter=\"url(#effect-b)\""))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("<filter id=\"effect-b\""))
  assert_true(defs_str.contains("feGaussianBlur"))
}

///|
test "no effectLst → empty filter attribute and no defs" {
  let src = "<p:spPr xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\"/>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    doc.root,
    "x",
    ColorResolveContext::empty(),
    defs,
  )
  inspect(attr.length(), content="0")
  inspect(defs.to_defs_element(), content="")
}

///|
test "priority: outerShdw wins over glow when both are present" {
  let sp_pr = build_sp_pr_with_effect(
    "<a:outerShdw blurRad=\"50000\" dist=\"30000\" dir=\"2700000\"><a:srgbClr val=\"000000\"/></a:outerShdw><a:glow rad=\"30000\"><a:srgbClr val=\"FF0000\"/></a:glow>",
  )
  let defs = SvgDefsCollector::new()
  let _ = render_effects_filter_attr(
    sp_pr,
    "prio",
    ColorResolveContext::empty(),
    defs,
  )
  let defs_str = defs.to_defs_element()
  // outerShdw is the only one rendered → feOffset must appear
  // (only the shadow filter uses feOffset).
  assert_true(defs_str.contains("feOffset"))
}
