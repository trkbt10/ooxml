// ECMA-376 21.2.2.228 CT_View3D camera controls.

///|
fn v3d_c(
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
fn v3d_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(v3d_c(tag, attrs, kids))
}

///|
fn v3d_num_val(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      v3d_cn("pt", [("idx", i.to_string())], [
        v3d_cn("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  v3d_cn("val", [], [v3d_cn("numLit", [], pts)])
}

///|
fn v3d_bar_chart() -> @xml.Node {
  v3d_cn("barChart", [], [
    v3d_cn("barDir", [("val", "col")], []),
    v3d_cn("ser", [], [v3d_num_val(["10", "20", "30"])]),
  ])
}

///|
fn v3d_chart_space(view_kids : Array[@xml.Node]) -> @xml.Element {
  v3d_c("chartSpace", [], [
    v3d_cn("chart", [], [
      v3d_cn("view3D", [], view_kids),
      v3d_cn("plotArea", [], [v3d_bar_chart()]),
    ]),
  ])
}

///|
fn v3d_marker(view_kids : Array[@xml.Node]) -> String {
  let node = render_chart_view3d_marker(
    v3d_c("view3D", [], view_kids),
    25.0,
    20.0,
    300.0,
    300.0,
  )
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
fn v3d_render(view_kids : Array[@xml.Node]) -> String {
  let node = render_chart_space(
    v3d_chart_space(view_kids),
    (0.0, 0.0, 400.0, 300.0),
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
}

///|
fn v3d_marker_changes(view_kids : Array[@xml.Node]) -> Bool {
  let base = v3d_marker([])
  let changed = v3d_marker(view_kids)
  changed != base && changed.contains("points=\"")
}

///|
test "view3D reads schema defaults and clamps catalog percentages" {
  let defaults = read_chart_view3d_config(v3d_c("view3D", [], []))
  assert_eq(format_double(defaults.rot_x), "0")
  assert_eq(format_double(defaults.rot_y), "0")
  assert_eq(format_double(defaults.h_percent), "100")
  assert_eq(format_double(defaults.depth_percent), "100")
  assert_eq(defaults.r_ang_ax, false)
  assert_eq(format_double(defaults.perspective), "30")

  let catalog = read_chart_view3d_config(
    v3d_c("view3D", [], [
      v3d_cn("hPercent", [("val", "5%")], []),
      v3d_cn("depthPercent", [("val", "5%")], []),
    ]),
  )
  assert_eq(format_double(catalog.h_percent), "5")
  assert_eq(format_double(catalog.depth_percent), "20")
}

///|
test "view3D child values drive projection geometry" {
  assert_true(v3d_marker_changes([v3d_cn("rotX", [("val", "1")], [])]))
  assert_true(v3d_marker_changes([v3d_cn("hPercent", [("val", "5%")], [])]))
  assert_true(v3d_marker_changes([v3d_cn("rotY", [("val", "1")], [])]))
  assert_true(v3d_marker_changes([v3d_cn("depthPercent", [("val", "5%")], [])]))
  assert_true(v3d_marker_changes([v3d_cn("rAngAx", [], [])]))
  assert_true(v3d_marker_changes([v3d_cn("perspective", [("val", "1")], [])]))
}

///|
test "chartSpace connects view3D projection marker" {
  let svg = v3d_render([v3d_cn("rotY", [("val", "30")], [])])
  assert_true(svg.contains("data-ooxml=\"chart-view3d\""))
  assert_true(svg.contains("data-ooxml=\"chart-view3d-front\""))
  assert_true(svg.contains("data-ooxml=\"chart-view3d-payload\""))
  assert_true(svg.contains("transform=\"matrix("))
}
