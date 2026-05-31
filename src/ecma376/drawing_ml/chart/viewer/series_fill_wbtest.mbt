// §21.2 chart series / data-point fills — a series (or `<c:dPt>`)
// `<c:spPr>` carrying a `<a:gradFill>` or `<a:pattFill>` must render a
// real SVG gradient / pattern (a `<defs>` entry + a `url(#…)` fill
// reference), not degrade to a flat accent colour.  A plain `<a:solidFill>`
// or fill-less series must still render an unchanged solid `fill="#…"`.

///|
/// Build a `c:`-prefixed element from local-name + attrs + children.
fn sf_c(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  {
    name: { prefix: Some("c"), local_name: tag, ns: None },
    attributes: a,
    children: kids,
  }
}

///|
fn sf_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(sf_c(tag, attrs, kids))
}

///|
/// Build an `a:`-prefixed element node (DrawingML fill / colour elements).
fn sf_a(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: None, local_name: k, ns: None }, value: v })
  }
  @xml.Node::Element({
    name: { prefix: Some("a"), local_name: tag, ns: None },
    attributes: a,
    children: kids,
  })
}

///|
/// A `<c:val><c:numLit>` cache from a list of point values.
fn sf_numval(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for v in vals {
    pts.push(sf_cn("pt", [], [sf_cn("v", [], [@xml.Node::Text(v)])]))
  }
  sf_cn("val", [], [sf_cn("numLit", [], pts)])
}

///|
/// A single-series column `<c:barChart>` whose series `<c:spPr>` carries
/// the supplied fill element (or none when `sp_pr_kids` is empty).
fn sf_bar_chart(sp_pr_kids : Array[@xml.Node]) -> @xml.Element {
  let ser_kids : Array[@xml.Node] = []
  if sp_pr_kids.length() > 0 {
    ser_kids.push(sf_cn("spPr", [], sp_pr_kids))
  }
  ser_kids.push(sf_numval(["10", "20", "30"]))
  let ser = sf_cn("ser", [], ser_kids)
  sf_c("barChart", [], [sf_cn("barDir", [("val", "col")], []), ser])
}

///|
fn sf_style() -> ChartStyleDefaults {
  ChartStyleDefaults::{
    text_color: "#000000",
    font_family: "sans-serif",
    axis_color: "#333333",
    grid_color: "#cccccc",
  }
}

///|
/// Render a bar chart through `render_bar_chart` and return both the
/// serialised series SVG and the `<defs>` fragment accumulated during the
/// render.
fn sf_render(chart : @xml.Element) -> (String, String) {
  // The empty plot-area has no axes; `collect_axes_info` yields a
  // no-axis ChartAxesInfo, which is fine for inspecting the bar fill.
  let plot_area = sf_c("plotArea", [], [])
  let axes = collect_axes_info(plot_area)
  let defs = SvgDefsCollector::new()
  let nodes = render_bar_chart(
    chart,
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    sf_style(),
    defs,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  (sb.to_string(), defs.to_defs_element())
}

///|
test "series gradFill renders a linearGradient def + url() fill reference" {
  // §20.1.8.33 gradFill with a horizontal two-stop gradient.
  let grad = sf_a("gradFill", [], [
    sf_a("gsLst", [], [
      sf_a("gs", [("pos", "0")], [sf_a("srgbClr", [("val", "ff0000")], [])]),
      sf_a("gs", [("pos", "100000")], [sf_a("srgbClr", [("val", "0000ff")], [])]),
    ]),
    sf_a("lin", [("ang", "0")], []),
  ])
  let (svg, defs) = sf_render(sf_bar_chart([grad]))
  // A <linearGradient> def was registered.
  assert_true(defs.contains("<linearGradient"))
  // Both resolved stop colours appear in the def.
  assert_true(defs.contains("stop-color=\"#ff0000\""))
  assert_true(defs.contains("stop-color=\"#0000ff\""))
  // The bar shape references the gradient by url(#…); it does NOT carry a
  // flat hex fill for the gradient series.
  assert_true(svg.contains("fill=\"url(#ser0-grad-0)\""))
}

///|
test "series radial gradFill renders a radialGradient def" {
  // §20.1.8.46 path → radial gradient.
  let grad = sf_a("gradFill", [], [
    sf_a("gsLst", [], [
      sf_a("gs", [("pos", "0")], [sf_a("srgbClr", [("val", "00ff00")], [])]),
      sf_a("gs", [("pos", "100000")], [sf_a("srgbClr", [("val", "000000")], [])]),
    ]),
    sf_a("path", [("path", "circle")], []),
  ])
  let (svg, defs) = sf_render(sf_bar_chart([grad]))
  assert_true(defs.contains("<radialGradient"))
  assert_true(svg.contains("fill=\"url(#ser0-grad-0)\""))
}

///|
test "series pattFill renders a pattern def + url() fill reference" {
  // §20.1.8.47 pattFill, preset "cross" with fg/bg colours.
  let patt = sf_a("pattFill", [("prst", "cross")], [
    sf_a("fgClr", [], [sf_a("srgbClr", [("val", "112233")], [])]),
    sf_a("bgClr", [], [sf_a("srgbClr", [("val", "ffffff")], [])]),
  ])
  let (svg, defs) = sf_render(sf_bar_chart([patt]))
  // A <pattern> def was registered with the resolved fg/bg colours.
  assert_true(defs.contains("<pattern"))
  assert_true(defs.contains("stroke=\"#112233\""))
  assert_true(defs.contains("fill=\"#ffffff\""))
  // The bar shape references the pattern by url(#…).
  assert_true(svg.contains("fill=\"url(#ser0-patt-0)\""))
}

///|
test "series solidFill renders an unchanged solid hex fill (no defs)" {
  let solid = sf_a("solidFill", [], [sf_a("srgbClr", [("val", "abcdef")], [])])
  let (svg, defs) = sf_render(sf_bar_chart([solid]))
  // No gradient / pattern defs were registered for a solid series.
  assert_eq(defs, "")
  // The bar carries the literal resolved hex fill (legacy behaviour).
  assert_true(svg.contains("fill=\"#abcdef\""))
  assert_true(!svg.contains("url(#"))
}

///|
test "fill-less series falls back to the accent palette (unchanged)" {
  let (svg, defs) = sf_render(sf_bar_chart([]))
  // No defs, and no gradient/pattern reference — the accent palette
  // supplies a flat colour exactly as before.
  assert_eq(defs, "")
  assert_true(!svg.contains("url(#"))
  // accent1 of the baked Office palette is #4472c4.
  assert_true(svg.contains("fill=\"#4472c4\""))
}

///|
test "per-point dPt gradFill renders a gradient def + url() reference" {
  // §21.2.2.52 dPt — point 1 overrides its fill with a gradient; the
  // other points keep the accent palette.
  let dpt = sf_cn("dPt", [], [
    sf_cn("idx", [("val", "1")], []),
    sf_cn("spPr", [], [
      sf_a("gradFill", [], [
        sf_a("gsLst", [], [
          sf_a("gs", [("pos", "0")], [sf_a("srgbClr", [("val", "aa0000")], [])]),
          sf_a("gs", [("pos", "100000")], [
            sf_a("srgbClr", [("val", "0000aa")], []),
          ]),
        ]),
      ]),
    ]),
  ])
  // Build the series with the dPt + values directly.
  let ser = sf_cn("ser", [], [dpt, sf_numval(["10", "20", "30"])])
  let chart = sf_c("barChart", [], [sf_cn("barDir", [("val", "col")], []), ser])
  let (svg, defs) = sf_render(chart)
  // The per-point gradient def is registered with the dPt-seeded id.
  assert_true(defs.contains("<linearGradient"))
  assert_true(svg.contains("fill=\"url(#ser0-dpt1-grad-0)\""))
  // The non-overridden points keep flat accent fills (no url ref for them).
  assert_true(svg.contains("fill=\"#4472c4\""))
}
