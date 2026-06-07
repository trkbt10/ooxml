// ECMA-376 §21.2.2.69 / §21.2.2.11 / §21.2.2.191 CT_Surface.

///|
fn surf_c(
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
fn surf_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(surf_c(tag, attrs, kids))
}

///|
fn surf_a(
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
fn surf_solid(hex : String) -> @xml.Node {
  surf_a("solidFill", [], [surf_a("srgbClr", [("val", hex)], [])])
}

///|
fn surf_sppr(fill_hex : String, stroke_hex : String) -> @xml.Node {
  surf_cn("spPr", [], [
    surf_solid(fill_hex),
    surf_a("ln", [("w", "2"), ("cap", "rnd")], [
      surf_solid(stroke_hex),
      surf_a("prstDash", [("val", "dash")], []),
    ]),
  ])
}

///|
fn surf_picture_options() -> @xml.Node {
  surf_cn("pictureOptions", [], [
    surf_cn("applyToFront", [("val", "1")], []),
    surf_cn("applyToSides", [("val", "1")], []),
    surf_cn("applyToEnd", [("val", "0")], []),
    surf_cn("pictureFormat", [("val", "stretch")], []),
    surf_cn("pictureStackUnit", [("val", "2")], []),
  ])
}

///|
fn surf_surface(
  tag : String,
  fill_hex : String,
  stroke_hex : String,
) -> @xml.Element {
  surf_c(tag, [], [
    surf_cn("thickness", [("val", "25%")], []),
    surf_sppr(fill_hex, stroke_hex),
    surf_picture_options(),
  ])
}

///|
fn surf_num_val(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      surf_cn("pt", [("idx", i.to_string())], [
        surf_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  surf_cn("val", [], [surf_cn("numLit", [], pts)])
}

///|
fn surf_cache_lit(tag : String, vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = [
    surf_cn("ptCount", [("val", vals.length().to_string())], []),
  ]
  for i, v in vals {
    pts.push(
      surf_cn("pt", [("idx", i.to_string())], [
        surf_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  surf_cn(tag, [], pts)
}

///|
fn surf_surface_chart_space(wireframe : String) -> @xml.Element {
  let ser = surf_cn("ser", [], [
    surf_cn("idx", [("val", "0")], []),
    surf_cn("order", [("val", "0")], []),
    surf_cn("cat", [], [surf_cache_lit("strLit", ["A", "B", "C", "D"])]),
    surf_cn("val", [], [surf_cache_lit("numLit", ["5", "9", "7", "12"])]),
  ])
  let surface_chart = surf_cn("surfaceChart", [], [
    surf_cn("wireframe", [("val", wireframe)], []),
    ser,
    surf_cn("axId", [("val", "111111111")], []),
    surf_cn("axId", [("val", "222222222")], []),
    surf_cn("axId", [("val", "333333333")], []),
  ])
  let cat_ax = surf_cn("catAx", [], [
    surf_cn("axId", [("val", "111111111")], []),
    surf_cn("axPos", [("val", "b")], []),
    surf_cn("crossAx", [("val", "222222222")], []),
  ])
  let val_ax = surf_cn("valAx", [], [
    surf_cn("axId", [("val", "222222222")], []),
    surf_cn("axPos", [("val", "l")], []),
    surf_cn("crossAx", [("val", "111111111")], []),
  ])
  let ser_ax = surf_cn("serAx", [], [
    surf_cn("axId", [("val", "333333333")], []),
    surf_cn("axPos", [("val", "r")], []),
    surf_cn("crossAx", [("val", "222222222")], []),
  ])
  surf_c("chartSpace", [], [
    surf_cn("chart", [], [
      surf_cn("plotArea", [], [
        surf_cn("layout", [], []),
        surface_chart,
        cat_ax,
        val_ax,
        ser_ax,
      ]),
    ]),
  ])
}

///|
fn surf_surface_band_chart_space() -> @xml.Element {
  let ser = surf_cn("ser", [], [
    surf_cn("idx", [("val", "0")], []),
    surf_cn("order", [("val", "0")], []),
    surf_cn("cat", [], [surf_cache_lit("strLit", ["A", "B", "C", "D"])]),
    surf_cn("val", [], [surf_cache_lit("numLit", ["5", "9", "7", "12"])]),
  ])
  let band_fmts = surf_cn("bandFmts", [], [
    surf_cn("bandFmt", [], [
      surf_cn("idx", [("val", "0")], []),
      surf_sppr("C00000", "C00000"),
    ]),
  ])
  let surface_chart = surf_cn("surfaceChart", [], [
    surf_cn("wireframe", [("val", "0")], []),
    ser,
    band_fmts,
    surf_cn("axId", [("val", "111111111")], []),
    surf_cn("axId", [("val", "222222222")], []),
    surf_cn("axId", [("val", "333333333")], []),
  ])
  let cat_ax = surf_cn("catAx", [], [
    surf_cn("axId", [("val", "111111111")], []),
    surf_cn("axPos", [("val", "b")], []),
    surf_cn("crossAx", [("val", "222222222")], []),
  ])
  let val_ax = surf_cn("valAx", [], [
    surf_cn("axId", [("val", "222222222")], []),
    surf_cn("axPos", [("val", "l")], []),
    surf_cn("crossAx", [("val", "111111111")], []),
  ])
  let ser_ax = surf_cn("serAx", [], [
    surf_cn("axId", [("val", "333333333")], []),
    surf_cn("axPos", [("val", "r")], []),
    surf_cn("crossAx", [("val", "222222222")], []),
  ])
  surf_c("chartSpace", [], [
    surf_cn("chart", [], [
      surf_cn("plotArea", [], [
        surf_cn("layout", [], []),
        surface_chart,
        cat_ax,
        val_ax,
        ser_ax,
      ]),
    ]),
  ])
}

///|
fn surf_bar_chart() -> @xml.Node {
  surf_cn("barChart", [], [
    surf_cn("barDir", [("val", "col")], []),
    surf_cn("ser", [], [surf_num_val(["10", "20", "30"])]),
  ])
}

///|
fn surf_chart_space() -> @xml.Element {
  surf_c("chartSpace", [], [
    surf_cn("chart", [], [
      @xml.Node::Element(surf_surface("floor", "F4F1EA", "112233")),
      @xml.Node::Element(surf_surface("sideWall", "E8EDF4", "223344")),
      @xml.Node::Element(surf_surface("backWall", "F2F7EE", "334455")),
      surf_cn("plotArea", [], [surf_bar_chart()]),
    ]),
  ])
}

///|
fn surf_svg(node : @xml.Node) -> String {
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
test "surface thickness percentage drives projected geometry" {
  match
    chart_surface_thickness_px(
      surf_surface("floor", "F4F1EA", "112233"),
      120.0,
      80.0,
    ) {
    Some(v) => assert_eq(format_double(v), "20")
    None => fail("expected surface thickness")
  }
}

///|
test "surface spPr fill and line are resolved through chart paint SoT" {
  let defs = SvgDefsCollector::new()
  let node = render_chart_surface_floor(
    surf_surface("floor", "F4F1EA", "112233"),
    10.0,
    20.0,
    120.0,
    80.0,
    ColorResolveContext::empty(),
    defs,
  )
  let svg = match node {
    Some(n) => surf_svg(n)
    None => ""
  }
  assert_true(svg.contains("data-ooxml=\"chart-floor\""))
  assert_true(svg.contains("data-ooxml-thickness=\"25%\""))
  assert_true(svg.contains("fill=\"#f4f1ea\""))
  assert_true(svg.contains("stroke=\"#112233\""))
  assert_true(svg.contains("stroke-width=\"2\""))
  assert_true(svg.contains("stroke-dasharray=\"8 6\""))
  assert_true(svg.contains("stroke-linecap=\"round\""))
  assert_true(svg.contains("data-ooxml-picture-format=\"stretch\""))
  assert_true(svg.contains("data-ooxml-picture-stack-unit=\"2\""))
}

///|
test "chartSpace connects all three chart surfaces" {
  let node = render_chart_space(
    surf_chart_space(),
    (0.0, 0.0, 400.0, 300.0),
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  let svg = surf_svg(node)
  assert_true(svg.contains("data-ooxml=\"chart-floor\""))
  assert_true(svg.contains("data-ooxml=\"chart-side-wall\""))
  assert_true(svg.contains("data-ooxml=\"chart-back-wall\""))
  assert_true(svg.contains("fill=\"#f4f1ea\""))
  assert_true(svg.contains("fill=\"#e8edf4\""))
  assert_true(svg.contains("fill=\"#f2f7ee\""))
}

///|
test "surface chart wireframe renders unfilled polygons" {
  let wire = surf_svg(
    render_chart_space(
      surf_surface_chart_space("1"),
      (0.0, 0.0, 400.0, 300.0),
      ColorResolveContext::empty(),
      SvgDefsCollector::new(),
    ),
  )
  let filled = surf_svg(
    render_chart_space(
      surf_surface_chart_space("0"),
      (0.0, 0.0, 400.0, 300.0),
      ColorResolveContext::empty(),
      SvgDefsCollector::new(),
    ),
  )
  assert_true(wire.contains("<polygon"))
  assert_true(wire.contains("fill=\"none\""))
  assert_true(wire.contains("fill-opacity=\"0\""))
  assert_true(filled.contains("<polygon"))
  assert_true(filled.contains("fill-opacity=\"1\""))
  assert_true(!filled.contains("fill=\"none\" fill-opacity=\"0\""))
}

///|
test "surface chart bandFmt spPr drives polygon fill" {
  let svg = surf_svg(
    render_chart_space(
      surf_surface_band_chart_space(),
      (0.0, 0.0, 400.0, 300.0),
      ColorResolveContext::empty(),
      SvgDefsCollector::new(),
    ),
  )
  assert_true(svg.contains("<polygon"))
  assert_true(svg.contains("fill=\"#c00000\""))
}
