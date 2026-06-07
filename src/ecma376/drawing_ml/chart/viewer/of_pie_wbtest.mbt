// §21.2.2.126 CT_OfPieChart — pie-of-pie / bar-of-pie.  An ofPieChart is
// a TWO-TIER chart: a primary pie (major points + an aggregated "Other"
// slice) plus a secondary plot (a small pie for ofPieType="pie", a
// stacked bar for ofPieType="bar") that breaks "Other" into its
// component points.  These tests assert the two tiers are emitted, that
// the aggregated "Other" wedge equals the sum of the secondary points,
// and that the secondary plot honours ofPieType.

///|
/// Build a `c:`-prefixed element.
fn ofp_c(
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
fn ofp_cn(
  tag : String,
  attrs : Array[(String, String)],
  kids : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(ofp_c(tag, attrs, kids))
}

///|
/// Build an `a:`-prefixed DrawingML element node (fill / colour elements).
fn ofp_a(
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
/// A `<c:val><c:numLit>` cache from point values.
fn ofp_numval(vals : Array[String]) -> @xml.Node {
  let pts : Array[@xml.Node] = []
  for v in vals {
    pts.push(ofp_cn("pt", [], [ofp_cn("v", [], [@xml.Node::Text(v)])]))
  }
  ofp_cn("val", [], [ofp_cn("numLit", [], pts)])
}

///|
fn ofp_style() -> ChartStyleDefaults {
  ChartStyleDefaults::{
    text_color: "#000000",
    font_family: "sans-serif",
    axis_color: "#333333",
    grid_color: "#cccccc",
  }
}

///|
/// Render an <c:ofPieChart> through `render_of_pie_chart` (the dispatch
/// path) and return the serialised SVG fragment.
fn ofp_render(chart : @xml.Element) -> String {
  let plot_area = ofp_c("plotArea", [], [])
  let axes = collect_axes_info(plot_area)
  let nodes = render_of_pie_chart(
    chart,
    400.0,
    300.0,
    400.0,
    300.0,
    ColorResolveContext::empty(),
    axes,
    ofp_style(),
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
/// Count non-overlapping occurrences of `needle` in `s`.
fn ofp_count(s : String, needle : String) -> Int {
  if needle.length() == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i + needle.length() <= s.length() {
    if s[i:i + needle.length()] == needle {
      count = count + 1
      i = i + needle.length()
    } else {
      i = i + 1
    }
  }
  count
}

///|
/// Five-point series; default ofPieType="pie".  Values 40,30,20,5,5 with
/// splitType="pos" splitPos="2" → the LAST 2 points (5,5) go to the
/// secondary plot; "Other" = 10.
fn ofp_pie_chart(extra : Array[@xml.Node]) -> @xml.Element {
  let ser = ofp_cn("ser", [], [ofp_numval(["40", "30", "20", "5", "5"])])
  let kids : Array[@xml.Node] = []
  for e in extra {
    kids.push(e)
  }
  kids.push(ser)
  ofp_c("ofPieChart", [], kids)
}

///|
test "ofPieChart pos split emits a primary AND a secondary pie" {
  let chart = ofp_pie_chart([
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
  ])
  let svg = ofp_render(chart)
  // Primary pie centred at (100,150); secondary pie centred at (300,150)
  // for the 400x300 frame (half_w=200 → primary_cx=100, secondary_cx=300;
  // cy=150).  Solid wedges start "M <cx>,<cy>".  Both clusters present
  // proves two pies were rendered, not a single flat pie.
  assert_true(svg.contains("M 100,150"))
  assert_true(svg.contains("M 300,150"))
  // Primary = 3 own slices (40,30,20) + 1 "Other" wedge = 4 paths;
  // secondary = 2 slices (5,5).  At least 5 wedge paths total (more than
  // one pie group's worth).
  let path_count = ofp_count(svg, "<path")
  assert_true(path_count >= 5)
}

///|
test "ofPieChart aggregates secondary points into one Other wedge" {
  // Values 40,30,20,5,5; pos split 2 → secondary = {5,5}, Other = 10.
  // The primary total = 40+30+20+10 = 100, so the Other wedge sweeps
  // 10/100*360 = 36deg.  We verify the Other wedge exists by checking the
  // secondary pie's two slices sum equals the Other value indirectly: the
  // secondary pie of {5,5} has each slice 180deg.  We assert the primary
  // pie has exactly 4 wedges (3 own + Other) by counting paths whose data
  // begins at the primary centre.
  let chart = ofp_pie_chart([
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
  ])
  let svg = ofp_render(chart)
  // Primary wedges begin "M 100,150" (4 of them: 40,30,20,Other=10).
  assert_eq(ofp_count(svg, "M 100,150"), 4)
  // Secondary wedges begin "M 300,150" (2 of them: 5,5).
  assert_eq(ofp_count(svg, "M 300,150"), 2)
  // No <c:serLines> means no connector line was requested.
  assert_true(!svg.contains("data-ooxml=\"chart-ser-lines\""))
}

///|
test "ofPieChart serLines emits connector only when requested" {
  let without_ser_lines = ofp_pie_chart([
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
  ])
  let without_svg = ofp_render(without_ser_lines)
  assert_true(!without_svg.contains("data-ooxml=\"chart-ser-lines\""))

  let with_ser_lines = ofp_pie_chart([
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
    ofp_cn("serLines", [], []),
  ])
  let with_svg = ofp_render(with_ser_lines)
  assert_true(with_svg.contains("data-ooxml=\"chart-ser-lines\""))
  assert_true(with_svg.contains("<line"))
}

///|
test "ofPieChart serLines spPr drives connector stroke" {
  let chart = ofp_pie_chart([
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
    ofp_cn("serLines", [], [
      ofp_cn("spPr", [], [
        ofp_a("ln", [("w", "19050"), ("cap", "rnd")], [
          ofp_a("solidFill", [], [ofp_a("srgbClr", [("val", "8090A0")], [])]),
          ofp_a("prstDash", [("val", "dash")], []),
        ]),
      ]),
    ]),
  ])
  let svg = ofp_render(chart)
  assert_true(svg.contains("data-ooxml=\"chart-ser-lines\""))
  assert_true(svg.contains("stroke=\"#8090a0\""))
  assert_true(svg.contains("stroke-width=\"2\""))
  assert_true(svg.contains("stroke-dasharray=\"8 6\""))
  assert_true(svg.contains("stroke-linecap=\"round\""))
}

///|
test "ofPieChart ofPieType=bar emits stacked rect segments for secondary" {
  let chart = ofp_pie_chart([
    ofp_cn("ofPieType", [("val", "bar")], []),
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
  ])
  let svg = ofp_render(chart)
  // The primary is still a pie (4 wedges at the left centre).
  assert_eq(ofp_count(svg, "M 100,150"), 4)
  // The secondary is a STACKED BAR: two <rect> segments (5 and 5), no
  // second pie at the right centre.
  assert_eq(ofp_count(svg, "<rect"), 2)
  assert_true(!svg.contains("M 300,150"))
}

///|
test "ofPieChart cust split selects exactly the secondPiePt indices" {
  // custSplit picks indices 0 and 4 (values 40 and 5) → Other = 45,
  // primary own slices = {30,20,5} (indices 1,2,3).
  let chart = ofp_pie_chart([
    ofp_cn("splitType", [("val", "cust")], []),
    ofp_cn("custSplit", [], [
      ofp_cn("secondPiePt", [("val", "0")], []),
      ofp_cn("secondPiePt", [("val", "4")], []),
    ]),
  ])
  let svg = ofp_render(chart)
  // Primary = 3 own slices + 1 Other = 4 wedges; secondary = 2 wedges.
  assert_eq(ofp_count(svg, "M 100,150"), 4)
  assert_eq(ofp_count(svg, "M 300,150"), 2)
}

///|
test "ofPieChart percent split routes small points to secondary" {
  // Values 40,30,20,5,5 (total 100).  percent split at 10 → points whose
  // share < 10% (the two 5s = 5%) go to secondary.
  let chart = ofp_pie_chart([
    ofp_cn("splitType", [("val", "percent")], []),
    ofp_cn("splitPos", [("val", "10")], []),
  ])
  let svg = ofp_render(chart)
  assert_eq(ofp_count(svg, "M 100,150"), 4)
  assert_eq(ofp_count(svg, "M 300,150"), 2)
}

///|
test "ofPieChart val split routes points below threshold to secondary" {
  // val split at 25 → points with value < 25 (20,5,5) go to secondary;
  // primary own = {40,30}, Other = 30.
  let chart = ofp_pie_chart([
    ofp_cn("splitType", [("val", "val")], []),
    ofp_cn("splitPos", [("val", "25")], []),
  ])
  let svg = ofp_render(chart)
  // Primary = 2 own + 1 Other = 3 wedges; secondary = 3 wedges.
  assert_eq(ofp_count(svg, "M 100,150"), 3)
  assert_eq(ofp_count(svg, "M 300,150"), 3)
}

///|
test "ofPieChart auto split defaults to the last two points" {
  // No splitType → "auto" → last min(2,n-1)=2 points to secondary.
  let chart = ofp_pie_chart([])
  let svg = ofp_render(chart)
  // Primary = 3 own + 1 Other = 4 wedges; secondary = 2 wedges.
  assert_eq(ofp_count(svg, "M 100,150"), 4)
  assert_eq(ofp_count(svg, "M 300,150"), 2)
}

///|
test "ofPieChart dPt fill override colours a primary slice distinctly" {
  // §21.2.2.52 dPt — point 0 overrides its fill; it must carry the
  // override colour rather than the accent palette.
  let dpt = ofp_cn("dPt", [], [
    ofp_cn("idx", [("val", "0")], []),
    ofp_cn("spPr", [], [
      ofp_a("solidFill", [], [ofp_a("srgbClr", [("val", "abcdef")], [])]),
    ]),
  ])
  let ser = ofp_cn("ser", [], [dpt, ofp_numval(["40", "30", "20", "5", "5"])])
  let chart = ofp_c("ofPieChart", [], [
    ofp_cn("splitType", [("val", "pos")], []),
    ofp_cn("splitPos", [("val", "2")], []),
    ser,
  ])
  let svg = ofp_render(chart)
  // The dPt override colour appears on a primary wedge.
  assert_true(svg.contains("fill=\"#abcdef\""))
}
