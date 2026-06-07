// §21.2.2.192 CT_Shape — bar / bar3D data-marker shape wiring.

///|
fn bs_c(
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
fn bs_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(bs_c(tag, attrs, kids))
}

///|
fn bs_numval(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      bs_cn("pt", [("idx", i.to_string())], [
        bs_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  bs_cn("val", [], [bs_cn("numLit", [], pts)])
}

///|
fn bs_style() -> ChartStyleDefaults {
  ChartStyleDefaults::{
    text_color: "#000000",
    font_family: "sans-serif",
    axis_color: "#333333",
    grid_color: "#cccccc",
  }
}

///|
fn bs_bar_chart(
  tag : String,
  chart_shape : String?,
  ser_shape : String?,
  bar_dir : String,
) -> @xml.Element {
  let ser_kids : Array[@xml.Node] = []
  match ser_shape {
    Some(v) => ser_kids.push(bs_cn("shape", [("val", v)], []))
    None => ()
  }
  ser_kids.push(bs_numval(["10", "20", "30"]))
  let kids : Array[@xml.Node] = [bs_cn("barDir", [("val", bar_dir)], [])]
  kids.push(bs_cn("ser", [], ser_kids))
  match chart_shape {
    Some(v) => kids.push(bs_cn("shape", [("val", v)], []))
    None => ()
  }
  bs_c(tag, [], kids)
}

///|
fn bs_bar3d_gap_depth_chart(gap_depth : String) -> @xml.Element {
  let ser_a = bs_cn("ser", [], [
    bs_cn("idx", [("val", "0")], []),
    bs_cn("order", [("val", "0")], []),
    bs_numval(["10", "20", "30"]),
  ])
  let ser_b = bs_cn("ser", [], [
    bs_cn("idx", [("val", "1")], []),
    bs_cn("order", [("val", "1")], []),
    bs_numval(["15", "25", "35"]),
  ])
  bs_c("bar3DChart", [], [
    bs_cn("barDir", [("val", "col")], []),
    bs_cn("grouping", [("val", "clustered")], []),
    ser_a,
    ser_b,
    bs_cn("gapDepth", [("val", gap_depth)], []),
  ])
}

///|
fn bs_bar_series_order_chart(
  order_a : String,
  order_b : String,
) -> @xml.Element {
  let ser_a = bs_cn("ser", [], [
    bs_cn("idx", [("val", "0")], []),
    bs_cn("order", [("val", order_a)], []),
    bs_numval(["10", "20", "30"]),
  ])
  let ser_b = bs_cn("ser", [], [
    bs_cn("idx", [("val", "1")], []),
    bs_cn("order", [("val", order_b)], []),
    bs_numval(["30", "20", "10"]),
  ])
  bs_c("barChart", [], [
    bs_cn("barDir", [("val", "col")], []),
    bs_cn("grouping", [("val", "clustered")], []),
    ser_a,
    ser_b,
  ])
}

///|
fn bs_render(chart : @xml.Element) -> String {
  let plot_area = bs_c("plotArea", [], [])
  let axes = collect_axes_info(plot_area)
  let nodes = render_bar_chart(
    chart,
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    bs_style(),
    SvgDefsCollector::new(),
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  sb.to_string()
}

///|
fn bs_bar_vary_colors_chart(value : String) -> @xml.Element {
  let ser = bs_cn("ser", [], [
    bs_cn("idx", [("val", "0")], []),
    bs_cn("order", [("val", "0")], []),
    bs_numval(["10", "20", "30"]),
  ])
  bs_c("barChart", [], [
    bs_cn("barDir", [("val", "col")], []),
    bs_cn("grouping", [("val", "clustered")], []),
    bs_cn("varyColors", [("val", value)], []),
    ser,
  ])
}

///|
fn bs_pie_vary_colors_chart(value : String) -> @xml.Element {
  let ser = bs_cn("ser", [], [
    bs_cn("idx", [("val", "0")], []),
    bs_cn("order", [("val", "0")], []),
    bs_numval(["10", "20", "30"]),
  ])
  bs_c("pieChart", [], [bs_cn("varyColors", [("val", value)], []), ser])
}

///|
fn bs_render_pie(chart : @xml.Element) -> String {
  let nodes = render_pie_chart(
    chart,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
    hole_percent=None,
  )
  let sb = StringBuilder::new()
  for nd in nodes {
    match nd {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  sb.to_string()
}

///|
test "bar shape default box keeps the legacy rect output" {
  let svg = bs_render(bs_bar_chart("bar3DChart", None, None, "col"))
  assert_true(svg.contains("<rect"))
  assert_true(!svg.contains("data-ooxml=\"chart-bar-shape\""))
}

///|
test "bar3D gapDepth changes flattened series spacing" {
  let tight = bs_render(bs_bar3d_gap_depth_chart("0%"))
  let wide = bs_render(bs_bar3d_gap_depth_chart("400%"))
  assert_true(tight.contains("<rect"))
  assert_true(wide.contains("<rect"))
  assert_true(tight != wide)
}

///|
test "bar series order controls clustered plot order" {
  let normal = bs_render(bs_bar_series_order_chart("0", "1"))
  let reversed = bs_render(bs_bar_series_order_chart("1", "0"))
  assert_true(normal.contains("<rect"))
  assert_true(reversed.contains("<rect"))
  assert_true(normal != reversed)
}

///|
test "bar3D chart-level cylinder shape reaches SVG" {
  let svg = bs_render(bs_bar_chart("bar3DChart", Some("cylinder"), None, "col"))
  assert_true(svg.contains("data-ooxml=\"chart-bar-shape\""))
  assert_true(svg.contains("data-ooxml-shape=\"cylinder\""))
  assert_true(svg.contains("<ellipse"))
  assert_true(svg.contains("fill=\"#4472c4\""))
}

///|
test "series-level bar shape overrides the chart-level shape" {
  let svg = bs_render(
    bs_bar_chart("bar3DChart", Some("pyramid"), Some("cylinder"), "col"),
  )
  assert_true(svg.contains("data-ooxml-shape=\"cylinder\""))
  assert_true(!svg.contains("data-ooxml-shape=\"pyramid\""))
}

///|
test "all ST_Shape non-box values render distinct SVG silhouettes" {
  let cylinder = bs_render(
    bs_bar_chart("bar3DChart", Some("cylinder"), None, "col"),
  )
  let cone = bs_render(bs_bar_chart("bar3DChart", Some("cone"), None, "col"))
  let cone_to_max = bs_render(
    bs_bar_chart("bar3DChart", Some("coneToMax"), None, "bar"),
  )
  let pyramid = bs_render(
    bs_bar_chart("bar3DChart", Some("pyramid"), None, "col"),
  )
  let pyramid_to_max = bs_render(
    bs_bar_chart("bar3DChart", Some("pyramidToMax"), None, "bar"),
  )

  assert_true(cylinder.contains("data-ooxml-shape=\"cylinder\""))
  assert_true(cylinder.contains("<ellipse"))
  assert_true(cone.contains("data-ooxml-shape=\"cone\""))
  assert_true(cone.contains("<polygon"))
  assert_true(cone.contains("<ellipse"))
  assert_true(cone_to_max.contains("data-ooxml-shape=\"coneToMax\""))
  assert_true(cone_to_max.contains("<polygon"))
  assert_true(cone_to_max.contains("<ellipse"))
  assert_true(pyramid.contains("data-ooxml-shape=\"pyramid\""))
  assert_true(pyramid.contains("<polygon"))
  assert_true(pyramid_to_max.contains("data-ooxml-shape=\"pyramidToMax\""))
  assert_true(pyramid_to_max.contains("<polygon"))
}

///|
test "bar varyColors controls single-series point fills" {
  let one_color = bs_render(bs_bar_vary_colors_chart("0"))
  let varied = bs_render(bs_bar_vary_colors_chart("1"))

  assert_true(one_color.contains("fill=\"#4472c4\""))
  assert_true(!one_color.contains("fill=\"#ed7d31\""))
  assert_true(!one_color.contains("fill=\"#a5a5a5\""))
  assert_true(varied.contains("fill=\"#4472c4\""))
  assert_true(varied.contains("fill=\"#ed7d31\""))
  assert_true(varied.contains("fill=\"#a5a5a5\""))
}

///|
test "pie varyColors false keeps one resolved series fill" {
  let one_color = bs_render_pie(bs_pie_vary_colors_chart("0"))
  let varied = bs_render_pie(bs_pie_vary_colors_chart("1"))

  assert_true(one_color.contains("fill=\"#4472c4\""))
  assert_true(!one_color.contains("fill=\"#ed7d31\""))
  assert_true(!one_color.contains("fill=\"#a5a5a5\""))
  assert_true(varied.contains("fill=\"#4472c4\""))
  assert_true(varied.contains("fill=\"#ed7d31\""))
  assert_true(varied.contains("fill=\"#a5a5a5\""))
}
