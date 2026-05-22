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
