// §21.2.2.101 / §21.2.2.107 — value-axis majorTickMark /
// minorTickMark.  The chart renderer defaults to cross-style ticks,
// but `val="none"` suppresses the tick mark line segments.

///|
fn axis_tick_svg(nodes : Array[@xml.Node]) -> String {
  let sb = StringBuilder::new()
  for node in nodes {
    match node {
      @xml.Node::Element(e) => sb.write_string(@markup.serialize_svg(e))
      _ => ()
    }
  }
  sb.to_string()
}

///|
fn axis_tick_count(s : String, needle : String) -> Int {
  let mut count = 0
  let mut idx = 0
  let nlen = needle.length()
  while idx + nlen <= s.length() {
    if s[idx:idx + nlen].to_owned() == needle {
      count = count + 1
      idx = idx + nlen
    } else {
      idx = idx + 1
    }
  }
  count
}

///|
fn atm_line_fragment(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
) -> String {
  "<line x1=\"" +
  format_double(x1) +
  "\" y1=\"" +
  format_double(y1) +
  "\" x2=\"" +
  format_double(x2) +
  "\" y2=\"" +
  format_double(y2) +
  "\""
}

///|
fn atm_text_attr_for_label(
  svg : String,
  label : String,
  attr_name : String,
) -> String? {
  let marker = ">" + label + "<"
  let label_pos = match svg.find(marker) {
    Some(pos) => pos
    None => return None
  }
  let open = "<text "
  let mut text_start = 0
  let mut scan = 0
  while scan + open.length() <= label_pos {
    if svg[scan:scan + open.length()].to_owned() == open {
      text_start = scan
    }
    scan = scan + 1
  }
  let key = attr_name + "=\""
  let mut i = text_start
  while i + key.length() <= label_pos {
    if svg[i:i + key.length()].to_owned() == key {
      let value_start = i + key.length()
      let mut j = value_start
      while j < label_pos {
        if svg[j:j + 1].to_owned() == "\"" {
          return Some(svg[value_start:j].to_owned())
        }
        j = j + 1
      }
    }
    i = i + 1
  }
  None
}

///|
fn atm_elem(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Element {
  let a : Array[@xml.Attribute] = []
  for kv in attrs {
    let (k, v) = kv
    a.push({ name: { prefix: Some("c"), local_name: k, ns: None }, value: v })
  }
  {
    name: { prefix: Some("c"), local_name: tag, ns: None },
    attributes: a,
    children: kids,
  }
}

///|
fn atm_node(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(atm_elem(tag, attrs, kids))
}

///|
fn atm_num_val(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, v in vals {
    pts.push(
      atm_node("pt", [("idx", i.to_string())], [
        atm_node("v", [], [@xml.Node::Text(v)]),
      ]),
    )
  }
  atm_node("val", [], [atm_node("numLit", [], pts)])
}

///|
fn atm_cat(labels : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, label in labels {
    pts.push(
      atm_node("pt", [("idx", i.to_string())], [
        atm_node("v", [], [@xml.Node::Text(label)]),
      ]),
    )
  }
  atm_node("cat", [], [atm_node("strLit", [], pts)])
}

///|
fn atm_date_cat(serials : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for i, serial in serials {
    pts.push(
      atm_node("pt", [("idx", i.to_string())], [
        atm_node("v", [], [@xml.Node::Text(serial)]),
      ]),
    )
  }
  atm_node("cat", [], [atm_node("numLit", [], pts)])
}

///|
fn atm_style() -> ChartStyleDefaults {
  ChartStyleDefaults::{
    text_color: "#000000",
    font_family: "sans-serif",
    axis_color: "#333333",
    grid_color: "#cccccc",
  }
}

///|
fn atm_plot_area_with_val(
  cat_kids : Array[@xml.Node],
  val_kids : Array[@xml.Node],
) -> @xml.Element {
  atm_elem("plotArea", [], [
    atm_node("catAx", [], cat_kids),
    atm_node("valAx", [], val_kids),
  ])
}

///|
fn atm_plot_area(cat_kids : Array[@xml.Node]) -> @xml.Element {
  atm_plot_area_with_val(cat_kids, [atm_node("delete", [("val", "1")], [])])
}

///|
fn atm_date_plot_area(date_kids : Array[@xml.Node]) -> @xml.Element {
  atm_elem("plotArea", [], [
    atm_node("dateAx", [], date_kids),
    atm_node("valAx", [], [atm_node("delete", [("val", "1")], [])]),
  ])
}

///|
fn atm_render_line(plot_area : @xml.Element) -> String {
  atm_render_line_values(plot_area, ["10", "20", "30"])
}

///|
fn atm_render_date_line(date_kids : Array[@xml.Node]) -> String {
  let plot_area = atm_date_plot_area(date_kids)
  let axes = collect_axes_info(plot_area)
  let ser = atm_node("ser", [], [
    atm_date_cat(["45292", "45306", "45323"]),
    atm_num_val(["10", "20", "30"]),
  ])
  let nodes = render_line_chart(
    atm_elem("lineChart", [], [ser]),
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    atm_style(),
    SvgDefsCollector::new(),
  )
  axis_tick_svg(nodes)
}

///|
fn atm_render_line_values(
  plot_area : @xml.Element,
  values : Array[String],
) -> String {
  let axes = collect_axes_info(plot_area)
  let ser = atm_node("ser", [], [
    atm_cat(["Q1", "Q2", "Q3"]),
    atm_num_val(values),
  ])
  let nodes = render_line_chart(
    atm_elem("lineChart", [], [ser]),
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    atm_style(),
    SvgDefsCollector::new(),
  )
  axis_tick_svg(nodes)
}

///|
fn atm_render_horizontal_bar(plot_area : @xml.Element) -> String {
  let axes = collect_axes_info(plot_area)
  let ser = atm_node("ser", [], [
    atm_cat(["North", "South"]),
    atm_num_val(["10", "20"]),
  ])
  let nodes = render_bar_chart(
    atm_elem("barChart", [], [atm_node("barDir", [("val", "bar")], []), ser]),
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    atm_style(),
    SvgDefsCollector::new(),
  )
  axis_tick_svg(nodes)
}

///|
fn atm_render_chart_space_line(
  cat_kids : Array[@xml.Node],
  val_kids : Array[@xml.Node],
  values : Array[String],
) -> String {
  let ser = atm_node("ser", [], [
    atm_cat(["Q1", "Q2", "Q3"]),
    atm_num_val(values),
  ])
  let chart_space = atm_elem("chartSpace", [], [
    atm_node("chart", [], [
      atm_node("plotArea", [], [
        atm_node("lineChart", [], [ser]),
        atm_node("catAx", [], cat_kids),
        atm_node("valAx", [], val_kids),
      ]),
    ]),
  ])
  let node = render_chart_space(
    chart_space,
    (0.0, 0.0, 400.0, 300.0),
    ColorResolveContext::empty(),
    SvgDefsCollector::new(),
  )
  axis_tick_svg([node])
}

///|
test "§21.2.2.101 value-axis majorTickMark none suppresses vertical-axis ticks" {
  let normal = axis_tick_svg(
    y_axis_ticks(
      20.0,
      10.0,
      100.0,
      20.0,
      160.0,
      240.0,
      false,
      tick_lbl_pos="none",
    ),
  )
  let none = axis_tick_svg(
    y_axis_ticks(
      20.0,
      10.0,
      100.0,
      20.0,
      160.0,
      240.0,
      false,
      tick_lbl_pos="none",
      major_tick_mark="none",
      minor_tick_mark="none",
    ),
  )
  assert_true(axis_tick_count(normal, "<line ") > 0)
  assert_eq(axis_tick_count(none, "<line "), 0)
}

///|
test "§21.2.2.101 category-axis majorTickMark none suppresses bottom-axis ticks" {
  let normal = axis_tick_svg(
    category_axis_ticks_bottom(20.0, 10.0, 160.0, 100.0, 240.0, 3),
  )
  let none = axis_tick_svg(
    category_axis_ticks_bottom(
      20.0,
      10.0,
      160.0,
      100.0,
      240.0,
      3,
      major_tick_mark="none",
    ),
  )
  assert_true(axis_tick_count(normal, "<line ") > 0)
  assert_eq(axis_tick_count(none, "<line "), 0)
}

///|
test "§21.2.2.101 category-axis majorTickMark none suppresses left-axis ticks" {
  let normal = axis_tick_svg(
    category_axis_ticks_left(20.0, 10.0, 160.0, 100.0, 240.0, 3),
  )
  let none = axis_tick_svg(
    category_axis_ticks_left(
      20.0,
      10.0,
      160.0,
      100.0,
      240.0,
      3,
      major_tick_mark="none",
    ),
  )
  assert_true(axis_tick_count(normal, "<line ") > 0)
  assert_eq(axis_tick_count(none, "<line "), 0)
}

///|
test "§21.2.2.207 category-axis tickMarkSkip skips bottom-axis ticks" {
  let normal = axis_tick_svg(
    category_axis_ticks_bottom(20.0, 10.0, 160.0, 100.0, 240.0, 4),
  )
  let skipped = axis_tick_svg(
    category_axis_ticks_bottom(
      20.0,
      10.0,
      160.0,
      100.0,
      240.0,
      4,
      tick_mark_skip=2,
    ),
  )
  assert_eq(axis_tick_count(normal, "<line "), 5)
  assert_eq(axis_tick_count(skipped, "<line "), 3)
}

///|
test "§21.2.2.101 category-axis majorTickMark none reaches line renderer" {
  let normal = atm_render_line(atm_plot_area([]))
  let none = atm_render_line(
    atm_plot_area([atm_node("majorTickMark", [("val", "none")], [])]),
  )
  assert_true(
    axis_tick_count(normal, "<line ") > axis_tick_count(none, "<line "),
  )
}

///|
test "§21.2.2.107 category-axis minorTickMark none suppresses horizontal-bar center ticks" {
  let major_none : Array[@xml.Node] = [
    atm_node("majorTickMark", [("val", "none")], []),
  ]
  let minor_none : Array[@xml.Node] = [
    atm_node("majorTickMark", [("val", "none")], []),
    atm_node("minorTickMark", [("val", "none")], []),
  ]
  let normal = atm_render_horizontal_bar(atm_plot_area(major_none))
  let none = atm_render_horizontal_bar(atm_plot_area(minor_none))
  assert_true(
    axis_tick_count(normal, "<line ") > axis_tick_count(none, "<line "),
  )
}

///|
test "§21.2.2.101 and §21.2.2.107 category-axis tickMark values are read" {
  let axes = collect_axes_info(
    atm_plot_area([
      atm_node("majorTickMark", [("val", "none")], []),
      atm_node("minorTickMark", [("val", "none")], []),
    ]),
  )
  assert_eq(axes.cat_major_tick_mark(), "none")
  assert_eq(axes.cat_minor_tick_mark(), "none")
}

///|
test "§21.2.2.207 category-axis tickMarkSkip is read and reaches line renderer" {
  let axes = collect_axes_info(
    atm_plot_area([atm_node("tickMarkSkip", [("val", "2")], [])]),
  )
  assert_eq(axes.cat_tick_mark_skip(), 2)
  let normal = atm_render_line(atm_plot_area([]))
  let skipped = atm_render_line(
    atm_plot_area([atm_node("tickMarkSkip", [("val", "2")], [])]),
  )
  assert_true(
    axis_tick_count(normal, "<line ") > axis_tick_count(skipped, "<line "),
  )
}

///|
test "§21.2.2.14 date-axis baseTimeUnit changes serial coordinate scale" {
  let serials : Array[Double?] = [Some(45292.0), Some(45306.0), Some(45323.0)]
  let axes_days = collect_axes_info(atm_date_plot_area([]))
  let axes_months = collect_axes_info(
    atm_date_plot_area([atm_node("baseTimeUnit", [("val", "months")], [])]),
  )
  let x_days = date_axis_position_for_index(
    20.0, 160.0, 3, 1, false, "midCat", axes_days, serials,
  )
  let x_months = date_axis_position_for_index(
    20.0, 160.0, 3, 1, false, "midCat", axes_months, serials,
  )
  assert_true(x_days != x_months)
}

///|
test "§21.2.2.116 date-axis majorTimeUnit changes rendered labels" {
  let by_month = atm_render_date_line([
    atm_node("baseTimeUnit", [("val", "months")], []),
  ])
  let by_year = atm_render_date_line([
    atm_node("baseTimeUnit", [("val", "months")], []),
    atm_node("majorTimeUnit", [("val", "years")], []),
  ])
  assert_true(by_month.contains(">2024-01<"))
  assert_true(by_month.contains(">2024-02<"))
  assert_true(by_year.contains(">2024<"))
  assert_true(!by_year.contains(">2024-02<"))
}

///|
test "chart axId filters plot-area axes for a chart payload" {
  let chart = atm_elem("lineChart", [], [
    atm_node("axId", [("val", "111111111")], []),
    atm_node("axId", [("val", "222222222")], []),
  ])
  let plot_area = atm_elem("plotArea", [], [
    atm_node("catAx", [], [
      atm_node("axId", [("val", "111111111")], []),
      atm_node("axPos", [("val", "b")], []),
      atm_node("crossAx", [("val", "222222222")], []),
    ]),
    atm_node("valAx", [], [
      atm_node("axId", [("val", "333333333")], []),
      atm_node("scaling", [], [atm_node("max", [("val", "400")], [])]),
      atm_node("axPos", [("val", "l")], []),
      atm_node("crossAx", [("val", "111111111")], []),
    ]),
    atm_node("valAx", [], [
      atm_node("axId", [("val", "222222222")], []),
      atm_node("scaling", [], [atm_node("max", [("val", "40")], [])]),
      atm_node("axPos", [("val", "l")], []),
      atm_node("crossAx", [("val", "111111111")], []),
    ]),
  ])
  let axes = collect_axes_info(plot_area).for_chart(chart)
  match axes.val_y_scaling_max() {
    Some(v) => assert_eq(v, 40.0)
    None => abort("missing filtered value-axis max")
  }
}

///|
test "crossAx pulls the declared perpendicular axis into chart axes" {
  let chart = atm_elem("lineChart", [], [
    atm_node("axId", [("val", "111111111")], []),
    atm_node("axId", [("val", "222222222")], []),
  ])
  let plot_area = atm_elem("plotArea", [], [
    atm_node("catAx", [], [
      atm_node("axId", [("val", "111111111")], []),
      atm_node("axPos", [("val", "b")], []),
      atm_node("crossAx", [("val", "333333333")], []),
    ]),
    atm_node("valAx", [], [
      atm_node("axId", [("val", "333333333")], []),
      atm_node("scaling", [], [atm_node("max", [("val", "400")], [])]),
      atm_node("axPos", [("val", "l")], []),
      atm_node("crossAx", [("val", "111111111")], []),
    ]),
    atm_node("valAx", [], [
      atm_node("axId", [("val", "222222222")], []),
      atm_node("scaling", [], [atm_node("max", [("val", "40")], [])]),
      atm_node("axPos", [("val", "l")], []),
      atm_node("crossAx", [("val", "111111111")], []),
    ]),
  ])
  let axes = collect_axes_info(plot_area).for_chart(chart)
  match axes.val_y_scaling_max() {
    Some(v) => assert_eq(v, 400.0)
    None => abort("missing crossAx value-axis max")
  }
}

///|
test "catAx auto uses numeric category data as date labels" {
  let cat_base = [
    atm_node("axId", [("val", "111111111")], []),
    atm_node("axPos", [("val", "b")], []),
    atm_node("crossAx", [("val", "222222222")], []),
  ]
  let cat_auto = [
    atm_node("axId", [("val", "111111111")], []),
    atm_node("axPos", [("val", "b")], []),
    atm_node("crossAx", [("val", "222222222")], []),
    atm_node("auto", [("val", "1")], []),
  ]
  let val_axis = [
    atm_node("axId", [("val", "222222222")], []),
    atm_node("delete", [("val", "1")], []),
    atm_node("axPos", [("val", "l")], []),
    atm_node("crossAx", [("val", "111111111")], []),
  ]
  let ser = atm_node("ser", [], [
    atm_date_cat(["45292", "45306", "45323"]),
    atm_num_val(["10", "20", "30"]),
  ])
  let plain_axes = collect_axes_info(atm_plot_area_with_val(cat_base, val_axis))
  let auto_axes = collect_axes_info(atm_plot_area_with_val(cat_auto, val_axis))
  let plain_nodes = render_line_chart(
    atm_elem("lineChart", [], [ser]),
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    plain_axes,
    atm_style(),
    SvgDefsCollector::new(),
  )
  let auto_nodes = render_line_chart(
    atm_elem("lineChart", [], [ser]),
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    auto_axes,
    atm_style(),
    SvgDefsCollector::new(),
  )
  let plain = axis_tick_svg(plain_nodes)
  let auto = axis_tick_svg(auto_nodes)
  assert_true(auto.contains(">2024-01-01<"))
  assert_true(plain != auto)
}

///|
test "§21.2.2.123 date-axis minorTimeUnit changes minor tick buckets" {
  let serials : Array[Double?] = [Some(45292.0), Some(45306.0), Some(45323.0)]
  let month_minor_axes = collect_axes_info(
    atm_date_plot_area([
      atm_node("baseTimeUnit", [("val", "months")], []),
      atm_node("majorTimeUnit", [("val", "years")], []),
    ]),
  )
  let day_minor_axes = collect_axes_info(
    atm_date_plot_area([
      atm_node("baseTimeUnit", [("val", "months")], []),
      atm_node("majorTimeUnit", [("val", "years")], []),
      atm_node("minorTimeUnit", [("val", "days")], []),
    ]),
  )
  let month_minor = axis_tick_svg(
    date_axis_ticks_bottom(
      20.0, 10.0, 160.0, 100.0, 240.0, 3, month_minor_axes, serials,
    ),
  )
  let day_minor = axis_tick_svg(
    date_axis_ticks_bottom(
      20.0, 10.0, 160.0, 100.0, 240.0, 3, day_minor_axes, serials,
    ),
  )
  assert_true(
    axis_tick_count(day_minor, "<line ") >
    axis_tick_count(month_minor, "<line "),
  )
}

///|
test "§21.2.2.209 category-axis tickLblPos none suppresses line labels" {
  let normal = atm_render_line(atm_plot_area([]))
  let none = atm_render_line(
    atm_plot_area([atm_node("tickLblPos", [("val", "none")], [])]),
  )
  assert_true(normal.contains(">Q1<"))
  assert_true(!none.contains(">Q1<"))
}

///|
test "§21.2.2.209 category-axis tickLblPos none suppresses bar labels" {
  let normal = atm_render_horizontal_bar(atm_plot_area([]))
  let none = atm_render_horizontal_bar(
    atm_plot_area([atm_node("tickLblPos", [("val", "none")], [])]),
  )
  assert_true(normal.contains(">North<"))
  assert_true(!none.contains(">North<"))
}

///|
test "§21.2.2.209 category-axis tickLblPos high moves line labels above plot" {
  let normal = atm_render_line(atm_plot_area([]))
  let high = atm_render_line(
    atm_plot_area([atm_node("tickLblPos", [("val", "high")], [])]),
  )
  assert_true(normal.contains("dominant-baseline=\"hanging\""))
  assert_true(high.contains("dominant-baseline=\"auto\""))
}

///|
test "§21.2.2.209 category-axis tickLblPos high moves bar labels to far side" {
  let normal = atm_render_horizontal_bar(atm_plot_area([]))
  let high = atm_render_horizontal_bar(
    atm_plot_area([atm_node("tickLblPos", [("val", "high")], [])]),
  )
  assert_true(normal.contains("text-anchor=\"end\""))
  assert_true(high.contains("text-anchor=\"start\""))
}

///|
test "§21.2.2.175 category-axis tickLblSkip skips line labels" {
  let skipped = atm_render_line(
    atm_plot_area([atm_node("tickLblSkip", [("val", "2")], [])]),
  )
  assert_true(skipped.contains(">Q1<"))
  assert_true(!skipped.contains(">Q2<"))
  assert_true(skipped.contains(">Q3<"))
}

///|
test "§21.2.2.175 category-axis tickLblSkip skips horizontal-bar labels" {
  let skipped = atm_render_horizontal_bar(
    atm_plot_area([atm_node("tickLblSkip", [("val", "2")], [])]),
  )
  assert_true(skipped.contains(">North<"))
  assert_true(!skipped.contains(">South<"))
}

///|
test "§21.2.2.88 category-axis lblAlgn controls line-label anchor" {
  let left = atm_render_line(
    atm_plot_area([atm_node("lblAlgn", [("val", "l")], [])]),
  )
  let right = atm_render_line(
    atm_plot_area([atm_node("lblAlgn", [("val", "r")], [])]),
  )
  assert_true(left.contains("text-anchor=\"start\""))
  assert_true(right.contains("text-anchor=\"end\""))
}

///|
test "§21.2.2.96 category-axis lblOffset changes line-label position" {
  let normal = atm_render_line(atm_plot_area([]))
  let shifted = atm_render_line(
    atm_plot_area([atm_node("lblOffset", [("val", "200")], [])]),
  )
  let normal_y = atm_text_attr_for_label(normal, "Q1", "y").unwrap_or("")
  let shifted_y = atm_text_attr_for_label(shifted, "Q1", "y").unwrap_or("")
  assert_true(normal_y != "")
  assert_true(shifted_y != "")
  assert_true(normal_y != shifted_y)
}

///|
test "§21.2.2.34 crossBetween positions line categories between tick marks" {
  let plot_between = atm_plot_area_with_val([], [
    atm_node("delete", [("val", "1")], []),
    atm_node("crossBetween", [("val", "between")], []),
  ])
  let axes_between = collect_axes_info(plot_between)
  let (px, _, pw, _) = chart_plot_inset(
    400.0,
    300.0,
    400.0,
    300.0,
    axes=Some(axes_between),
  )
  let svg_between = atm_render_line(plot_between)
  let q1_x = atm_text_attr_for_label(svg_between, "Q1", "x").unwrap_or("")
  assert_eq(q1_x, format_double(px + pw / 6.0))
}

///|
test "§21.2.2.34 crossBetween midCat positions line categories on tick marks" {
  let plot_mid = atm_plot_area_with_val([], [
    atm_node("delete", [("val", "1")], []),
    atm_node("crossBetween", [("val", "midCat")], []),
  ])
  let axes_mid = collect_axes_info(plot_mid)
  let (px, _, _, _) = chart_plot_inset(
    400.0,
    300.0,
    400.0,
    300.0,
    axes=Some(axes_mid),
  )
  let svg_mid = atm_render_line(plot_mid)
  let q1_x = atm_text_attr_for_label(svg_mid, "Q1", "x").unwrap_or("")
  assert_eq(q1_x, format_double(px))
}

///|
test "§21.2.2.35 catAx crosses max moves value axis to maximum category edge" {
  let plot = atm_plot_area_with_val(
    [atm_node("crosses", [("val", "max")], [])],
    [atm_node("delete", [("val", "1")], [])],
  )
  let axes = collect_axes_info(plot)
  let (px, py, pw, ph) = chart_plot_inset(
    400.0,
    300.0,
    400.0,
    300.0,
    axes=Some(axes),
  )
  let svg = atm_render_line(plot)
  assert_true(svg.contains(atm_line_fragment(px + pw, py, px + pw, py + ph)))
}

///|
test "§21.2.2.35 valAx crosses max moves category axis to value-axis maximum" {
  let plot = atm_plot_area_with_val([], [
    atm_node("crosses", [("val", "max")], []),
  ])
  let axes = collect_axes_info(plot)
  let (px, py, pw, _) = chart_plot_inset(
    400.0,
    300.0,
    400.0,
    300.0,
    axes=Some(axes),
  )
  let svg = atm_render_line(plot)
  assert_true(svg.contains(atm_line_fragment(px, py, px + pw, py)))
}

///|
test "§21.2.2.36 valAx crossesAt moves category axis to explicit value" {
  let plot = atm_plot_area_with_val([], [
    atm_node("crossesAt", [("val", "15")], []),
  ])
  let axes = collect_axes_info(plot)
  assert_eq(axes.val_crosses_at().unwrap_or(0.0), 15.0)
  let (px, py, pw, ph) = chart_plot_inset(
    400.0,
    300.0,
    400.0,
    300.0,
    axes=Some(axes),
  )
  let max_v = effective_axis_max(30.0, axes)
  let y = value_axis_cross_y(
    py,
    ph,
    0.0,
    max_v,
    false,
    axes.val_y_crosses(),
    axes.val_y_crosses_at(),
  )
  let svg = atm_render_line(plot)
  assert_true(svg.contains(atm_line_fragment(px, y, px + pw, y)))
}

///|
test "§21.2.2.107 value-axis minorTickMark none suppresses horizontal-axis ticks" {
  let normal = axis_tick_svg(
    x_axis_ticks(
      20.0,
      10.0,
      160.0,
      100.0,
      20.0,
      240.0,
      false,
      tick_lbl_pos="none",
    ),
  )
  let none = axis_tick_svg(
    x_axis_ticks(
      20.0,
      10.0,
      160.0,
      100.0,
      20.0,
      240.0,
      false,
      tick_lbl_pos="none",
      major_tick_mark="none",
      minor_tick_mark="none",
    ),
  )
  assert_true(axis_tick_count(normal, "<line ") > 0)
  assert_eq(axis_tick_count(none, "<line "), 0)
}

///|
test "§21.2.2.100 value-axis majorUnit controls major tick interval" {
  let normal = axis_tick_svg(
    y_axis_ticks(
      20.0,
      10.0,
      100.0,
      40.0,
      160.0,
      240.0,
      false,
      tick_lbl_pos="none",
      minor_tick_mark="none",
    ),
  )
  let explicit = axis_tick_svg(
    y_axis_ticks(
      20.0,
      10.0,
      100.0,
      40.0,
      160.0,
      240.0,
      false,
      tick_lbl_pos="none",
      minor_tick_mark="none",
      major_unit=Some(20.0),
    ),
  )
  assert_true(
    axis_tick_count(normal, "<line ") > axis_tick_count(explicit, "<line "),
  )
  assert_eq(axis_tick_count(explicit, "<line "), 3)
}

///|
test "§21.2.2.106 value-axis minorUnit controls minor tick interval" {
  let explicit = axis_tick_svg(
    y_axis_ticks(
      20.0,
      10.0,
      100.0,
      40.0,
      160.0,
      240.0,
      false,
      tick_lbl_pos="none",
      major_tick_mark="none",
      minor_unit=Some(20.0),
    ),
  )
  assert_eq(axis_tick_count(explicit, "<line "), 3)
}

///|
test "§21.2.2.100 and §21.2.2.106 value-axis units are read" {
  let axes = collect_axes_info(
    atm_plot_area_with_val([], [
      atm_node("majorUnit", [("val", "20")], []),
      atm_node("minorUnit", [("val", "10")], []),
    ]),
  )
  assert_eq(axes.val_major_unit().unwrap_or(0.0), 20.0)
  assert_eq(axes.val_minor_unit().unwrap_or(0.0), 10.0)
}

///|
test "§21.2.2.47 dispUnits builtInUnit scales value-axis tick labels" {
  let scaled = axis_tick_svg(
    y_axis_ticks(
      20.0,
      10.0,
      100.0,
      4000.0,
      160.0,
      240.0,
      false,
      tick_lbl_pos="nextTo",
      major_tick_mark="none",
      minor_tick_mark="none",
      major_unit=Some(2000.0),
      display_unit_factor=Some(1000.0),
    ),
  )
  assert_true(scaled.contains(">2<"))
  assert_true(scaled.contains(">4<"))
  assert_true(!scaled.contains(">2000<"))
}

///|
test "§21.2.2.47 dispUnits reaches line renderer value-axis labels" {
  let plot = atm_plot_area_with_val([], [
    atm_node("dispUnits", [], [
      atm_node("builtInUnit", [("val", "thousands")], []),
    ]),
    atm_node("majorUnit", [("val", "1000")], []),
  ])
  let svg = atm_render_line_values(plot, ["1000", "2000", "3000"])
  assert_true(svg.contains(">1<"))
  assert_true(svg.contains(">2<"))
  assert_true(!svg.contains(">1000<"))
}

///|
test "§21.2.2.47 dispUnits factors are read from builtInUnit and custUnit" {
  let built_in = collect_axes_info(
    atm_plot_area_with_val([], [
      atm_node("dispUnits", [], [
        atm_node("builtInUnit", [("val", "millions")], []),
      ]),
    ]),
  )
  let custom = collect_axes_info(
    atm_plot_area_with_val([], [
      atm_node("dispUnits", [], [atm_node("custUnit", [("val", "500")], [])]),
    ]),
  )
  assert_eq(built_in.val_disp_unit_factor().unwrap_or(0.0), 1000000.0)
  assert_eq(custom.val_disp_unit_factor().unwrap_or(0.0), 500.0)
  assert_eq(custom.val_disp_units().unwrap_or(""), "custom")
}

///|
test "§21.2.2.56 dispUnitsLbl tx overrides display-unit label text" {
  let svg = atm_render_chart_space_line(
    [],
    [
      atm_node("dispUnits", [], [
        atm_node("builtInUnit", [("val", "thousands")], []),
        atm_node("dispUnitsLbl", [], [
          atm_node("tx", [], [
            atm_node("rich", [], [
              atm_node("p", [], [
                atm_node("r", [], [
                  atm_node("t", [], [@xml.Node::Text("Axis units")]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ],
    ["1000", "2000", "3000"],
  )
  assert_true(svg.contains(">Axis units<"))
  assert_true(!svg.contains(">×1,000<"))
}

///|
test "§21.2.2.56 dispUnitsLbl manualLayout positions display-unit label" {
  let svg = atm_render_chart_space_line(
    [],
    [
      atm_node("dispUnits", [], [
        atm_node("builtInUnit", [("val", "thousands")], []),
        atm_node("dispUnitsLbl", [], [
          atm_node("layout", [], [
            atm_node("manualLayout", [], [
              atm_node("x", [("val", "0.25")], []),
              atm_node("y", [("val", "0.20")], []),
            ]),
          ]),
        ]),
      ]),
    ],
    ["1000", "2000", "3000"],
  )
  assert_eq(atm_text_attr_for_label(svg, "×1,000", "x").unwrap_or(""), "100")
  assert_eq(atm_text_attr_for_label(svg, "×1,000", "y").unwrap_or(""), "60")
}
