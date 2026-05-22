// Whitebox tests for the §20.1.5 3D effect renderer.

///|
/// Serialise the `transform` attribute list of an `Effects3d` by
/// threading it onto a `<g>` SVG element and serialising through
/// `@markup.serialize_svg`.  Empty when the camera preset is the
/// identity (no `transform` attribute).
fn effects3d_transform_markup(e : Effects3d) -> String {
  if e.transform_attrs.length() == 0 {
    return ""
  }
  match @markup.elem_ns("g", @markup.svg_ns, e.transform_attrs, []) {
    @xml.Node::Element(g) => @markup.serialize_svg(g)
    _ => ""
  }
}

///|
/// Serialise an optional `Effects3d` node (extrusion / bevel /
/// gradient) by threading it into an outer `<g>` SVG element and
/// serialising through `@markup.serialize_svg`.  The wrapping `<g>`
/// carries the single `xmlns` declaration so the inspected node
/// appears as a plain child element — exactly as it would inside the
/// real slide `<svg>` / `<defs>` tree.  Empty when the node is absent.
fn effects3d_node_markup(node : @xml.Node?) -> String {
  match node {
    Some(n) =>
      match @markup.elem_ns("g", @markup.svg_ns, [], [n]) {
        @xml.Node::Element(g) => @markup.serialize_svg(g)
        _ => ""
      }
    None => ""
  }
}

///|
fn parse_sp_pr(sp_pr_xml : String) -> @xml.Element raise {
  let src = "<wrap xmlns=\"urn:test\" xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\">" +
    sp_pr_xml +
    "</wrap>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  match first_child_named(doc.root, "spPr") {
    Some(e) => e
    None => abort("expected <p:spPr> child")
  }
}

///|
test "no scene3d and no sp3d → all-empty result" {
  let sp_pr = parse_sp_pr("<p:spPr/>")
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  inspect(effects3d_transform_markup(e), content="")
  inspect(effects3d_node_markup(e.extrusion), content="")
  inspect(effects3d_node_markup(e.bevel), content="")
  inspect(effects3d_node_markup(e.gradient_def), content="")
  assert_false(has_3d_effects(sp_pr))
}

///|
test "isometricTopUp camera → skewX(-30) skewY(30) transform" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:camera prst=\"isometricTopUp\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  let t = effects3d_transform_markup(e)
  assert_true(t.contains("skewX(-30)"))
  assert_true(t.contains("skewY(30)"))
  assert_true(has_3d_effects(sp_pr))
}

///|
test "orthographicFront → empty transform (identity)" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:camera prst=\"orthographicFront\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  inspect(effects3d_transform_markup(e), content="")
  assert_false(has_3d_effects(sp_pr))
}

///|
test "lightRig harsh → linearGradient with 0.4 opacities" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:lightRig rig=\"harsh\" dir=\"tl\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "L1", 100.0, 50.0)
  let gd = effects3d_node_markup(e.gradient_def)
  assert_true(gd.contains("<linearGradient id=\"lighting-L1\""))
  assert_true(gd.contains("stop-opacity=\"0.4\""))
}

///|
test "lightRig dir=br → coords (100,100) → (0,0)" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:lightRig rig=\"threePt\" dir=\"br\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  let gd = effects3d_node_markup(e.gradient_def)
  assert_true(gd.contains("x1=\"100%\""))
  assert_true(gd.contains("y1=\"100%\""))
  assert_true(gd.contains("x2=\"0%\""))
  assert_true(gd.contains("y2=\"0%\""))
}

///|
test "sp3d/@extrusionH > 0 emits extrusion layers" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:sp3d extrusionH=\"190500\"/></p:spPr>", // 20 px
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 10,0", "x", 10.0, 10.0)
  let ex = effects3d_node_markup(e.extrusion)
  assert_true(ex.contains("<g class=\"extrusion-effect\">"))
  assert_true(ex.contains("transform=\"translate("))
  assert_true(has_3d_effects(sp_pr))
}

///|
test "sp3d/@extrusionH = 0 emits no extrusion" {
  let sp_pr = parse_sp_pr("<p:spPr><a:sp3d extrusionH=\"0\"/></p:spPr>")
  let e = render_3d_effects(sp_pr, "M 0,0 L 10,0", "x", 10.0, 10.0)
  inspect(effects3d_node_markup(e.extrusion), content="")
}

///|
test "sp3d/bevelT emits four bevel paths" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:sp3d><a:bevelT w=\"76200\" h=\"76200\"/></a:sp3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  let bv = effects3d_node_markup(e.bevel)
  assert_true(bv.contains("<g class=\"bevel-effect\">"))
  // Four bevel paths.
  let path_count = count_substring(bv, "<path d=")
  assert_eq(path_count, 4)
  assert_true(has_3d_effects(sp_pr))
}

///|
fn count_substring(s : String, needle : String) -> Int {
  let n = needle.length()
  if n == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i + n <= s.length() {
    if s.substring(start=i, end=i + n) == needle {
      count = count + 1
      i = i + n
    } else {
      i = i + 1
    }
  }
  count
}

///|
test "obliqueTopLeft camera → skewX(-15) skewY(-15) transform" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:camera prst=\"obliqueTopLeft\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0", "x", 100.0, 50.0)
  let t = effects3d_transform_markup(e)
  assert_true(t.contains("skewX(-15)"))
  assert_true(t.contains("skewY(-15)"))
}

///|
test "perspectiveAbove camera combines skew and scale" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:camera prst=\"perspectiveAbove\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0", "x", 100.0, 50.0)
  let t = effects3d_transform_markup(e)
  assert_true(t.contains("skewY(-10)"))
  assert_true(t.contains("scale(1, 0.85)"))
}
