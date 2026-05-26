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
test "outerShdw + glow compose into a single multi-primitive filter" {
  // §20.1.8.27 effectLst child elements compose in document order.
  // The previous priority-chain implementation dropped the glow
  // when an outerShdw was present; now both must contribute
  // primitives to the same <filter>.
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
  // Both effects must contribute primitives: feOffset is unique to
  // the shadow path, and the glow's result id (`eff1_glow`) must
  // appear in the final merge.
  assert_true(defs_str.contains("feOffset"))
  assert_true(defs_str.contains("eff1_glow"))
  assert_true(defs_str.contains("eff0_out"))
  // The final <feMerge> stacks both effects under the source.
  assert_true(defs_str.contains("feMerge"))
}

///|
test "fillOverlay emits feFlood + feComposite + feBlend" {
  // §20.1.8.29 fillOverlay — blend a solid colour over the source.
  let sp_pr = build_sp_pr_with_effect(
    "<a:fillOverlay blend=\"mult\"><a:solidFill><a:srgbClr val=\"FF0000\"><a:alpha val=\"50000\"/></a:srgbClr></a:solidFill></a:fillOverlay>",
  )
  let defs = SvgDefsCollector::new()
  let attr = render_effects_filter_attr(
    sp_pr,
    "fo",
    ColorResolveContext::empty(),
    defs,
  )
  assert_true(attrs_markup(attr).contains("filter=\"url(#effect-fo)\""))
  let defs_str = defs.to_defs_element()
  assert_true(defs_str.contains("feFlood"))
  assert_true(defs_str.contains("flood-color=\"rgb(255, 0, 0)\""))
  // §20.1.8.29 @blend="mult" maps to SVG feBlend mode="multiply".
  assert_true(defs_str.contains("feBlend"))
  assert_true(defs_str.contains("mode=\"multiply\""))
}

///|
test "reflection emits a mirrored <g> clone outside the filter" {
  // §20.1.8.50 reflection — SVG filter primitives cannot mirror
  // the source, so the renderer emits a sibling <g> clone of the
  // shape with a y-axis flip transform.  The clone carries
  // `data-ooxml-effect="reflection"` so consumers can identify it.
  let sp_pr = build_sp_pr_with_effect(
    "<a:reflection blurRad=\"6350\" stA=\"50000\" endA=\"300\" dist=\"0\" dir=\"5400000\" sx=\"100000\" sy=\"100000\" algn=\"bl\"/>",
  )
  let dummy_path = @markup.elem_ns("path", @markup.svg_ns, [], [])
  let nodes = reflection_extra_nodes(sp_pr, dummy_path, 100.0)
  inspect(nodes.length(), content="1")
  match nodes[0] {
    @xml.Node::Element(e) => {
      let xml_str = @markup.serialize_svg(e)
      assert_true(xml_str.contains("data-ooxml-effect=\"reflection\""))
      assert_true(xml_str.contains("matrix(1 0 0 -1 0 200)"))
    }
    _ => fail("expected element node")
  }
}

///|
test "blur grow=\"true\" expands the viewport vs grow=\"false\"" {
  // §20.1.8.15 @grow — xsd:boolean default=true.  When true the
  // blur halo extends past the bounding box; the filter viewport
  // must widen so the halo isn't clipped.  When false the
  // viewport stays tight.
  let sp_pr_grow = build_sp_pr_with_effect(
    "<a:blur rad=\"100000\" grow=\"1\"/>",
  )
  let defs_grow = SvgDefsCollector::new()
  let _ = render_effects_filter_attr(
    sp_pr_grow,
    "bg",
    ColorResolveContext::empty(),
    defs_grow,
  )
  let str_grow = defs_grow.to_defs_element()

  let sp_pr_no = build_sp_pr_with_effect("<a:blur rad=\"100000\" grow=\"0\"/>")
  let defs_no = SvgDefsCollector::new()
  let _ = render_effects_filter_attr(
    sp_pr_no,
    "bn",
    ColorResolveContext::empty(),
    defs_no,
  )
  let str_no = defs_no.to_defs_element()
  // grow=false uses the tight viewport (-10%, -10%, 120%, 120%).
  assert_true(str_no.contains("x=\"-10%\""))
  // grow=true widens the viewport.  We don't pin an exact %
  // because the heuristic depends on the rad — just assert it
  // differs from the tight one.
  assert_true(!str_grow.contains("x=\"-10%\""))
}
