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
  // The bevel group is present (the default `relaxedInset` profile
  // also carries a softened `opacity`, so match the class attribute
  // without pinning the full tag).
  assert_true(bv.contains("class=\"bevel-effect\""))
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
    if s[i:i + n] == needle {
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

///|
test "sp3d contourW renders a coloured silhouette outline (§20.1.5.12)" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:sp3d contourW=\"19050\"><a:contourClr><a:srgbClr val=\"FF0000\"/></a:contourClr></a:sp3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0 L 100,50 Z", "x", 100.0, 50.0)
  let svg = effects3d_node_markup(e.contour)
  assert_true(svg.contains("class=\"contour-effect\""))
  assert_true(svg.contains("stroke=\"#ff0000\""))
  assert_true(svg.contains("fill=\"none\""))
  // 19050 EMU / 9525 = 2 px.
  assert_true(svg.contains("stroke-width=\"2"))
  assert_true(has_3d_effects(sp_pr))
}

///|
test "sp3d without contourW renders no contour" {
  let sp_pr = parse_sp_pr("<p:spPr><a:sp3d extrusionH=\"100000\"/></p:spPr>")
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  inspect(effects3d_node_markup(e.contour), content="")
}

///|
test "bevelT @prst differentiates rounded vs angular profiles (§20.1.10.27)" {
  // Rounded profile → softened bevel group opacity.
  let rounded = parse_sp_pr(
    "<p:spPr><a:sp3d><a:bevelT w=\"76200\" h=\"76200\" prst=\"circle\"/></a:sp3d></p:spPr>",
  )
  let r_svg = effects3d_node_markup(
    render_3d_effects(rounded, "M 0,0 L 100,0", "x", 100.0, 50.0).bevel,
  )
  assert_true(r_svg.contains("class=\"bevel-effect\""))
  assert_true(r_svg.contains("opacity="))
  // Angular profile → no opacity softening (full-strength edge).
  let angular = parse_sp_pr(
    "<p:spPr><a:sp3d><a:bevelT w=\"76200\" h=\"76200\" prst=\"angle\"/></a:sp3d></p:spPr>",
  )
  let a_svg = effects3d_node_markup(
    render_3d_effects(angular, "M 0,0 L 100,0", "x", 100.0, 50.0).bevel,
  )
  assert_true(a_svg.contains("class=\"bevel-effect\""))
  assert_true(!a_svg.contains("opacity="))
}

///|
test "camera @zoom scales and <a:rot @rev> rolls the transform (§20.1.5.5)" {
  // orthographicFront + zoom 200% + roll 45° (45*60000 = 2700000).
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:camera prst=\"orthographicFront\" zoom=\"200000\"><a:rot lat=\"0\" lon=\"0\" rev=\"2700000\"/></a:camera></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  let svg = effects3d_transform_markup(e)
  // roll → rotate(45); zoom 200% → scale(2, 2).
  assert_true(svg.contains("rotate(45)"))
  assert_true(svg.contains("scale(2, 2)"))
  // even with the orthographic (front) preset, zoom/rot make it 3D.
  assert_true(has_3d_effects(sp_pr))
}

///|
test "isometric preset composes with camera zoom" {
  // isometricTopUp (skewX -30 skewY 30) + zoom 50%.
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:scene3d><a:camera prst=\"isometricTopUp\" zoom=\"50000\"/></a:scene3d></p:spPr>",
  )
  let e = render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0)
  let svg = effects3d_transform_markup(e)
  assert_true(svg.contains("skewX(-30)"))
  assert_true(svg.contains("skewY(30)"))
  assert_true(svg.contains("scale(0.5, 0.5)"))
}

///|
test "bevelB renders a dimmed inverted-lighting back bevel (§20.1.5.3)" {
  // bevelT + bevelB → outer bevel-effect group wrapping a front group
  // (class bevel-effect) and a back group (class bevel-effect-back).
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:sp3d><a:bevelT w=\"76200\" h=\"76200\" prst=\"angle\"/><a:bevelB w=\"76200\" h=\"76200\" prst=\"angle\"/></a:sp3d></p:spPr>",
  )
  let bv = effects3d_node_markup(
    render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0).bevel,
  )
  assert_true(bv.contains("class=\"bevel-effect-back\""))
  assert_true(bv.contains("class=\"bevel-effect\""))
  // 8 paths total (4 front + 4 back).
  assert_eq(count_substring(bv, "<path d="), 8)
  // The back group is dimmed (opacity_scale 0.5 on an angular preset).
  assert_true(bv.contains("opacity=\"0.5\""))
}

///|
test "bevelB alone renders the back bevel group" {
  let sp_pr = parse_sp_pr(
    "<p:spPr><a:sp3d><a:bevelB w=\"76200\" h=\"76200\" prst=\"angle\"/></a:sp3d></p:spPr>",
  )
  let bv = effects3d_node_markup(
    render_3d_effects(sp_pr, "M 0,0 L 100,0", "x", 100.0, 50.0).bevel,
  )
  assert_true(bv.contains("class=\"bevel-effect-back\""))
  assert_eq(count_substring(bv, "<path d="), 4)
}
