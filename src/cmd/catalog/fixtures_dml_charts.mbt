// DrawingML CHART fixtures — ECMA-376 Part 1 §21.2 (dml-chart.xsd).
//
// Each fixture is a `.pptx` carrying a single slide with one
// `<p:graphicFrame>` whose `<a:graphicData uri="…/chart">` payload
// is a `<c:chart r:id="rId2"/>` reference; the slide's relationship
// part (built by `pptx_package_with_chart` in verify.mbt) maps
// `rId2` to `ppt/charts/chart1.xml`, which carries the
// `<c:chartSpace>` root tree this file builds.
//
// What this file covers (chart fixtures covering 9 top-level chart
// types in §21.2.2 plus grouping / formatting variants):
//
//   * `chart-bar-basic`     — §21.2.2.16 CT_BarChart (clustered bar)
//   * `chart-bar-with-legend` — §21.2.2.16 CT_BarChart (2 series + legend)
//   * `chart-bar-stacked`   — §21.2.2.76 grouping="stacked"
//   * `chart-bar-stacked-dpt-fill` — §21.2.2.52 dPt fill on stacked bar
//   * `chart-bar-percent-stacked` — §21.2.2.76 grouping="percentStacked"
//   * `chart-line-basic`    — §21.2.2.97 CT_LineChart
//   * `chart-line-with-title-and-legend` — §21.2.2.97 + title + legend
//   * `chart-pie-basic`     — §21.2.2.137 CT_PieChart
//   * `chart-doughnut-basic`— §21.2.2.50 CT_DoughnutChart
//   * `chart-scatter-basic` — §21.2.2.166 CT_ScatterChart (line w/ markers)
//   * `chart-area-basic`    — §21.2.2.4 CT_AreaChart
//   * `chart-bubble-basic`  — §21.2.2.21 CT_BubbleChart
//   * `chart-radar-basic`   — §21.2.2.150 CT_RadarChart
//   * `chart-stock-basic`   — §21.2.2.188 CT_StockChart (HLC)
//
// Each chart payload carries a minimal but schema-valid
// `<c:plotArea>` with one numeric series of four points, so the
// renderer (when implemented) has real data to plot.  All trees
// are built as `@xml.Element` values — never via string assembly,
// per AGENTS.md.
//
// =========================================================================
// RENDERING STATUS — §21.2 chart rendering.
// =========================================================================
// The PML viewer's `render_graphic_frame_svg` dispatches chart
// frames to `chart_render.mbt` which renders bar, line, pie,
// doughnut, scatter, area, bubble, radar, stock, ofPie, and flattened
// 3-D/surface chart variants.  Bar fixtures include clustered,
// stacked, and percentStacked grouping coverage.
//
// Remaining approximations for full §21.2 visual fidelity:
//   * 3-D chart variants render as their closest 2-D equivalent.
//   * Surface charts (§21.2.2.205 CT_SurfaceChart) render as area charts.
//   * Smart axis tick spacing (currently uses nice_axis_step heuristic)

// ---- file-local helpers ---------------------------------------------------

///|
/// DrawingML chart namespace (`c:` prefix per ECMA-376 §21.2).
const NS_C : String = "http://schemas.openxmlformats.org/drawingml/2006/chart"

///|
/// DrawingML chart graphicData URI — §15.2 well-known URI registry.
const CHART_URI : String = "http://schemas.openxmlformats.org/drawingml/2006/chart"

///|
/// Build a prefixed `<c:NAME …>…</c:NAME>` element for the
/// chartSpace tree.  The `xmlns:c` declaration is emitted
/// automatically by `@xml.write` at the root.
fn c_elem(
  tag : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: { prefix: Some("c"), local_name: tag, ns: Some(NS_C) },
    attributes: attrs,
    children: kids,
  }
}

///|
/// `<c:NAME val="…"/>` shorthand — every chart-side simple-typed
/// element uses the `val` attribute (CT_Boolean / CT_UnsignedInt /
/// CT_BarDir / …).
fn c_val(tag : String, value : String) -> @xml.Element {
  c_elem(tag, [xa("val", value)], [])
}

///|
/// `<c:numCache>` containing a `formatCode` + `ptCount` + N
/// `<c:pt idx="i"><c:v>…</c:v></c:pt>` entries.  Used as the
/// cached evaluated value of a `<c:numRef>` (numeric reference).
fn c_num_cache(values : Array[String]) -> @xml.Element {
  let kids : Array[@xml.Node] = [
    Element(c_elem("formatCode", [], [Text("General")])),
    Element(c_val("ptCount", values.length().to_string())),
  ]
  for i, v in values {
    kids.push(
      Element(
        c_elem("pt", [xa("idx", i.to_string())], [
          Element(c_elem("v", [], [Text(v)])),
        ]),
      ),
    )
  }
  c_elem("numCache", [], kids)
}

///|
/// `<c:strCache>` mirror of `c_num_cache` for string axis labels.
fn c_str_cache(values : Array[String]) -> @xml.Element {
  let kids : Array[@xml.Node] = [
    Element(c_val("ptCount", values.length().to_string())),
  ]
  for i, v in values {
    kids.push(
      Element(
        c_elem("pt", [xa("idx", i.to_string())], [
          Element(c_elem("v", [], [Text(v)])),
        ]),
      ),
    )
  }
  c_elem("strCache", [], kids)
}

///|
/// `<c:numRef>` carrying a `<c:f>` formula + cached `<c:numCache>`.
/// Used inside `<c:val>` for series numeric data.
fn c_num_ref(formula : String, values : Array[String]) -> @xml.Element {
  c_elem("numRef", [], [
    Element(c_elem("f", [], [Text(formula)])),
    Element(c_num_cache(values)),
  ])
}

///|
/// `<c:strRef>` carrying a `<c:f>` formula + cached `<c:strCache>`.
/// Used inside `<c:cat>` for category-axis labels.
fn c_str_ref(formula : String, values : Array[String]) -> @xml.Element {
  c_elem("strRef", [], [
    Element(c_elem("f", [], [Text(formula)])),
    Element(c_str_cache(values)),
  ])
}

///|
/// `<c:tx>` with a strRef wrapping a single literal title string.
fn c_series_tx(title : String) -> @xml.Element {
  c_elem("tx", [], [Element(c_str_ref("Sheet1!$A$1", [title]))])
}

///|
/// `<c:cat>` containing a string reference to category labels.
fn c_cat(labels : Array[String]) -> @xml.Element {
  c_elem("cat", [], [Element(c_str_ref("Sheet1!$A$2:$A$5", labels))])
}

///|
/// `<c:val>` containing a numeric reference to series values.
fn c_val_ref(values : Array[String]) -> @xml.Element {
  c_elem("val", [], [Element(c_num_ref("Sheet1!$B$2:$B$5", values))])
}

///|
/// §21.2.2.52 `<c:dPt>` carrying a chart shape property override.
/// The fill payload stays in DrawingML main (`a:`); the chart element
/// only owns the `<c:dPt>/<c:spPr>` carrier.
fn c_dpt_solid_fill(idx : Int, hex : String) -> @xml.Element {
  c_elem("dPt", [], [
    Element(c_val("idx", idx.to_string())),
    Element(
      c_elem("spPr", [], [
        Element(
          xe(NS_A, "solidFill", [], [
            Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
/// `<c:catAx>` / `<c:valAx>` pair builder shared across bar / line /
/// scatter charts.  Axis ids `crossAx`-link the two as required by
/// §21.2.2.18 / §21.2.2.20.
fn c_axes() -> Array[@xml.Element] {
  let cat_ax = c_elem("catAx", [], [
    Element(c_val("axId", "111111111")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "b")),
    Element(c_val("crossAx", "222222222")),
  ])
  let val_ax = c_elem("valAx", [], [
    Element(c_val("axId", "222222222")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "l")),
    Element(c_val("crossAx", "111111111")),
  ])
  [cat_ax, val_ax]
}

///|
/// §21.2.2.76 — axes for percentStacked charts with explicit
/// scaling (0–100) and "0%" numFmt to eliminate implementation-
/// defined axis layout ambiguity.
fn c_axes_percent() -> Array[@xml.Element] {
  // §21.2.2.42 delete — value axis hidden to exercise the delete
  // feature while category axis remains visible.
  let cat_ax = c_elem("catAx", [], [
    Element(c_val("axId", "111111111")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "b")),
    Element(c_val("crossAx", "222222222")),
  ])
  let val_ax = c_elem("valAx", [], [
    Element(c_val("axId", "222222222")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "1")),
    Element(c_val("axPos", "l")),
    Element(c_val("crossAx", "111111111")),
  ])
  [cat_ax, val_ax]
}

///|
/// Numeric value-axis pair for scatter (both axes are numeric).
fn c_axes_num() -> Array[@xml.Element] {
  let x_ax = c_elem("valAx", [], [
    Element(c_val("axId", "111111111")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "b")),
    Element(c_val("crossAx", "222222222")),
  ])
  let y_ax = c_elem("valAx", [], [
    Element(c_val("axId", "222222222")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "l")),
    Element(c_val("crossAx", "111111111")),
  ])
  [x_ax, y_ax]
}

///|
/// Wrap a chart-type-specific element (`<c:barChart>` /
/// `<c:lineChart>` / …) in the surrounding `<c:chartSpace>` /
/// `<c:chart>` / `<c:plotArea>` boilerplate.
///
/// The plot area carries:
///   * a `<c:layout/>` (auto layout)
///   * the chart-type element (one only — `<c:barChart>`, …)
///   * a pair of axis elements (`<c:catAx>` + `<c:valAx>` for
///     category-driven charts; two `<c:valAx>` for scatter).
fn wrap_chart_space(
  chart_payload : @xml.Element,
  axes : Array[@xml.Element],
) -> @xml.Element {
  wrap_chart_space_with_decor(chart_payload, axes, None, None)
}

///|
/// Same as `wrap_chart_space` but accepts an optional `<c:title>`
/// and `<c:legend>`. The schema ordering inside `<c:chart>` is
/// `title? / autoTitleDeleted? / pivotFmts? / view3D? / floor? /
/// sideWall? / backWall? / plotArea / plotVisOnly? / dispBlanksAs? /
/// showDLblsOverMax? / extLst?` (§21.2.2.27 CT_Chart) and the legend
/// lives between plotArea and plotVisOnly. We honour the canonical
/// ordering so the typed projection in `@chart.CT_Chart` can round-
/// trip the value losslessly.
fn wrap_chart_space_with_decor(
  chart_payload : @xml.Element,
  axes : Array[@xml.Element],
  title : @xml.Element?,
  legend : @xml.Element?,
) -> @xml.Element {
  let plot_area_kids : Array[@xml.Node] = [
    Element(c_elem("layout", [], [])),
    Element(chart_payload),
  ]
  for ax in axes {
    plot_area_kids.push(Element(ax))
  }
  let plot_area = c_elem("plotArea", [], plot_area_kids)
  let chart_kids : Array[@xml.Node] = []
  match title {
    Some(t) => chart_kids.push(Element(t))
    None => ()
  }
  chart_kids.push(Element(plot_area))
  match legend {
    Some(l) => chart_kids.push(Element(l))
    None => ()
  }
  chart_kids.push(Element(c_val("plotVisOnly", "1")))
  chart_kids.push(Element(c_val("dispBlanksAs", "gap")))
  let chart = c_elem("chart", [], chart_kids)
  c_elem("chartSpace", [], [Element(chart)])
}

///|
/// Build a `<c:title>` carrying a `<c:tx>/<c:rich>` body — the rich
/// body is a DrawingML text body (`<a:p>/<a:r>/<a:t>text</a:t>...`).
/// Required §21.2.2.213 children inside `<c:rich>` are `<a:bodyPr/>`,
/// `<a:lstStyle/>`, then one or more `<a:p>`. We add a final
/// `<c:overlay val="0"/>` so the title participates in the chart's
/// layout (i.e. the plot area shrinks to make room).
fn c_chart_title(text : String) -> @xml.Element {
  let rich = c_elem("rich", [], [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
    Element(
      xe(NS_A, "p", [], [
        Element(
          xe(NS_A, "r", [], [
            Element(xe(NS_A, "rPr", [xa("lang", "en-US"), xa("b", "1")], [])),
            Element(xe(NS_A, "t", [], [Text(text)])),
          ]),
        ),
      ]),
    ),
  ])
  c_elem("title", [], [
    Element(c_elem("tx", [], [Element(rich)])),
    Element(c_val("overlay", "0")),
  ])
}

///|
/// Build a `<c:legend>` carrying a `<c:legendPos val="…"/>`. The
/// `pos` argument must be one of `"r"` / `"t"` / `"b"` / `"l"` /
/// `"tr"` per §21.2.2.94 ST_LegendPos.
fn c_chart_legend(pos : String) -> @xml.Element {
  c_elem("legend", [], [
    Element(c_val("legendPos", pos)),
    Element(c_val("overlay", "0")),
  ])
}

///|
/// Build a `<p:graphicFrame>` that anchors a chart to the slide and
/// points its `<a:graphicData>` at `r:id="rId2"` — the rel the
/// builder writes for the chart part. The frame is positioned at a
/// fixed offset and given a 6 in × 4.5 in (5486400 × 4114800 EMU)
/// extent so the rendered chart has the same geometry during
/// OPC-loop verification.
fn chart_graphic_frame(id_ : String, name : String) -> @xml.Element {
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xe(NS_PML, "graphicFrame", [], [
    Element(
      xe(NS_PML, "nvGraphicFramePr", [], [
        Element(xe(NS_PML, "cNvPr", [xa("id", id_), xa("name", name)], [])),
        Element(xe(NS_PML, "cNvGraphicFramePr", [], [])),
        Element(xe(NS_PML, "nvPr", [], [])),
      ]),
    ),
    Element(
      xe(NS_PML, "xfrm", [], [
        Element(xe(NS_A, "off", [xa("x", "1828800"), xa("y", "1371600")], [])),
        Element(xe(NS_A, "ext", [xa("cx", "5486400"), xa("cy", "4114800")], [])),
      ]),
    ),
    Element(
      xe(NS_A, "graphic", [], [
        Element(
          xe(NS_A, "graphicData", [xa("uri", CHART_URI)], [
            // `<c:chart r:id="rId2"/>` — note `r:id` is a typed
            // qname so the writer auto-declares `xmlns:r` for us.
            Element({
              name: { prefix: Some("c"), local_name: "chart", ns: Some(NS_C) },
              attributes: [
                {
                  name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                  value: "rId2",
                },
              ],
              children: [],
            }),
          ]),
        ),
      ]),
    ),
  ])
}

// ---- chart-type-specific payloads ----------------------------------------

///|
/// §21.2.2.16 CT_BarChart — clustered bar with one series.
fn bar_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Sales")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["10", "30", "20", "40"])),
  ])
  c_elem("barChart", [], [
    Element(c_val("barDir", "bar")),
    Element(c_val("grouping", "clustered")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.97 CT_LineChart — standard grouping with markers off.
fn line_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Trend")),
    Element(c_cat(["Jan", "Feb", "Mar", "Apr"])),
    Element(c_val_ref(["5", "15", "10", "25"])),
    Element(c_val("smooth", "0")),
  ])
  c_elem("lineChart", [], [
    Element(c_val("grouping", "standard")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_val("marker", "1")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.137 CT_PieChart — single series, no axes.
fn pie_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Mix")),
    Element(c_cat(["A", "B", "C", "D"])),
    Element(c_val_ref(["35", "25", "20", "20"])),
  ])
  c_elem("pieChart", [], [
    Element(c_val("varyColors", "1")),
    Element(ser),
    Element(c_val("firstSliceAng", "0")),
  ])
}

///|
/// §21.2.2.50 CT_DoughnutChart — pie with hole; `holeSize` percent.
fn doughnut_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Mix")),
    Element(c_cat(["A", "B", "C", "D"])),
    Element(c_val_ref(["35", "25", "20", "20"])),
  ])
  c_elem("doughnutChart", [], [
    Element(c_val("varyColors", "1")),
    Element(ser),
    Element(c_val("firstSliceAng", "0")),
    Element(c_val("holeSize", "50")),
  ])
}

///|
/// §21.2.2.166 CT_ScatterChart — `scatterStyle="lineMarker"` with
/// numeric X + Y refs.  `<c:xVal>` carries the X axis values and
/// `<c:yVal>` the Y values (both as `<c:numRef>`).
fn scatter_chart_payload() -> @xml.Element {
  let x_ref = c_elem("xVal", [], [
    Element(c_num_ref("Sheet1!$A$2:$A$5", ["1", "2", "3", "4"])),
  ])
  let y_ref = c_elem("yVal", [], [
    Element(c_num_ref("Sheet1!$B$2:$B$5", ["3", "5", "4", "8"])),
  ])
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Pts")),
    Element(x_ref),
    Element(y_ref),
    Element(c_val("smooth", "0")),
  ])
  c_elem("scatterChart", [], [
    Element(c_val("scatterStyle", "lineMarker")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.166 CT_ScatterChart — two independent `<c:ser>`
/// sequences.  The chart schema permits `ser*`; this fixture ensures
/// the renderer draws every series and derives axis extents from the
/// full series set, not only the first series.
fn scatter_chart_two_series_payload() -> @xml.Element {
  let ser_a = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Plan")),
    Element(
      c_elem("xVal", [], [
        Element(c_num_ref("Sheet1!$A$2:$A$5", ["1", "2", "3", "4"])),
      ]),
    ),
    Element(
      c_elem("yVal", [], [
        Element(c_num_ref("Sheet1!$B$2:$B$5", ["2", "5", "4", "7"])),
      ]),
    ),
    Element(c_val("smooth", "0")),
  ])
  let ser_b = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("Actual")),
    Element(
      c_elem("xVal", [], [
        Element(c_num_ref("Sheet1!$C$2:$C$5", ["1.5", "2.5", "3.5", "4.5"])),
      ]),
    ),
    Element(
      c_elem("yVal", [], [
        Element(c_num_ref("Sheet1!$D$2:$D$5", ["3", "6", "8", "10"])),
      ]),
    ),
    Element(c_val("smooth", "0")),
  ])
  c_elem("scatterChart", [], [
    Element(c_val("scatterStyle", "lineMarker")),
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

// ---- ChartedCase extender -------------------------------------------------

///|
/// §21.2 DrawingML chart fixtures (chart-type, grouping, and
/// formatting variants). Each fixture is a single-slide PPTX whose
/// lone `<p:graphicFrame>` references the chart part the
/// `pptx_package_with_chart` builder writes.
///
/// Category folder: `chart` — fixtures land under
/// `.snapshots/fixtures/pptx/chart/<id>.pptx`.
fn extras_dml_charts(ccases : Array[ChartedCase]) -> Unit {
  // ---- bar charts (§21.2.2.16) -----------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar Chart 1")]),
    chart_space: wrap_chart_space(bar_chart_payload(), c_axes()),
  })
  ccases.push({
    id: "with-legend",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar With Legend")]),
    chart_space: wrap_chart_space_with_decor(
      bar_chart_two_series_payload(),
      c_axes(),
      None,
      Some(c_chart_legend("r")),
    ),
  })
  ccases.push({
    id: "stacked",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar Stacked")]),
    chart_space: wrap_chart_space(bar_chart_stacked_payload(), c_axes()),
  })
  ccases.push({
    id: "stacked-dpt-fill",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar Stacked Dpt Fill")]),
    chart_space: wrap_chart_space(bar_chart_stacked_dpt_payload(), c_axes()),
  })
  ccases.push({
    id: "percent-stacked",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar Percent Stacked")]),
    chart_space: wrap_chart_space(
      bar_chart_percent_stacked_payload(),
      c_axes_percent(),
    ),
  })

  // ---- line charts (§21.2.2.97) ---------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/line",
    content: sp_tree([chart_graphic_frame("2", "Line Chart 1")]),
    chart_space: wrap_chart_space(line_chart_payload(), c_axes()),
  })
  ccases.push({
    id: "with-title-and-legend",
    format: "pptx",
    category: "chart/line",
    content: sp_tree([chart_graphic_frame("2", "Line With Title And Legend")]),
    chart_space: wrap_chart_space_with_decor(
      line_chart_payload(),
      c_axes(),
      Some(c_chart_title("Monthly Trend")),
      Some(c_chart_legend("b")),
    ),
  })

  // ---- pie chart (§21.2.2.137) ----------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/pie",
    content: sp_tree([chart_graphic_frame("2", "Pie Chart 1")]),
    chart_space: wrap_chart_space(pie_chart_payload(), []),
  })

  // ---- doughnut chart (§21.2.2.50) ------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/doughnut",
    content: sp_tree([chart_graphic_frame("2", "Doughnut Chart 1")]),
    chart_space: wrap_chart_space(doughnut_chart_payload(), []),
  })

  // ---- scatter chart (§21.2.2.166) ------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/scatter",
    content: sp_tree([chart_graphic_frame("2", "Scatter Chart 1")]),
    chart_space: wrap_chart_space(scatter_chart_payload(), c_axes_num()),
  })
  ccases.push({
    id: "two-series",
    format: "pptx",
    category: "chart/scatter",
    content: sp_tree([chart_graphic_frame("2", "Scatter Two Series")]),
    chart_space: wrap_chart_space(
      scatter_chart_two_series_payload(),
      c_axes_num(),
    ),
  })

  // ---- area chart (§21.2.2.4) -----------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/area",
    content: sp_tree([chart_graphic_frame("2", "Area Chart 1")]),
    chart_space: wrap_chart_space(area_chart_payload(), c_axes()),
  })

  // ---- bubble chart (§21.2.2.21) --------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/bubble",
    content: sp_tree([chart_graphic_frame("2", "Bubble Chart 1")]),
    chart_space: wrap_chart_space(bubble_chart_payload(), c_axes_num()),
  })
  ccases.push({
    id: "two-series",
    format: "pptx",
    category: "chart/bubble",
    content: sp_tree([chart_graphic_frame("2", "Bubble Two Series")]),
    chart_space: wrap_chart_space(
      bubble_chart_two_series_payload(),
      c_axes_num(),
    ),
  })

  // ---- radar chart (§21.2.2.150) --------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/radar",
    content: sp_tree([chart_graphic_frame("2", "Radar Chart 1")]),
    chart_space: wrap_chart_space(radar_chart_payload(), c_axes()),
  })

  // ---- stock chart (§21.2.2.188) --------------------------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/stock",
    content: sp_tree([chart_graphic_frame("2", "Stock Chart 1")]),
    chart_space: wrap_chart_space(stock_chart_payload(), c_axes()),
  })
}

///|
/// Two-series clustered vertical bar payload — same fixture shape as
/// `bar_chart_payload` but adds a second series so the legend has
/// two distinct entries. `barDir="col"` (the default) draws vertical
/// columns side by side per category.
fn bar_chart_two_series_payload() -> @xml.Element {
  let ser_a = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Plan")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["10", "30", "20", "40"])),
  ])
  let ser_b = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("Actual")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["15", "25", "30", "35"])),
  ])
  c_elem("barChart", [], [
    Element(c_val("barDir", "col")),
    Element(c_val("grouping", "clustered")),
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.4 CT_AreaChart — standard grouping, single series. The
/// area chart fills the region between the polyline and the category
/// axis baseline.
fn area_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Revenue")),
    Element(c_cat(["Jan", "Feb", "Mar", "Apr"])),
    Element(c_val_ref(["12", "18", "15", "22"])),
  ])
  c_elem("areaChart", [], [
    Element(c_val("grouping", "standard")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.21 CT_BubbleChart — XY bubble with `<c:bubbleSize>` per
/// point. The bubble radius encodes a third dimension.
fn bubble_chart_payload() -> @xml.Element {
  let x_ref = c_elem("xVal", [], [
    Element(c_num_ref("Sheet1!$A$2:$A$5", ["1", "3", "5", "7"])),
  ])
  let y_ref = c_elem("yVal", [], [
    Element(c_num_ref("Sheet1!$B$2:$B$5", ["4", "8", "3", "6"])),
  ])
  let b_ref = c_elem("bubbleSize", [], [
    Element(c_num_ref("Sheet1!$C$2:$C$5", ["10", "25", "15", "30"])),
  ])
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Population")),
    Element(x_ref),
    Element(y_ref),
    Element(b_ref),
  ])
  c_elem("bubbleChart", [], [
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_val("bubbleScale", "100")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.21 CT_BubbleChart — two `<c:ser>` payloads.  The second
/// series carries the largest bubble sizes so axis and radius
/// normalisation must consider the full `ser*` collection.
fn bubble_chart_two_series_payload() -> @xml.Element {
  let ser_a = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("North")),
    Element(
      c_elem("xVal", [], [
        Element(c_num_ref("Sheet1!$A$2:$A$4", ["1", "3", "5"])),
      ]),
    ),
    Element(
      c_elem("yVal", [], [
        Element(c_num_ref("Sheet1!$B$2:$B$4", ["4", "8", "3"])),
      ]),
    ),
    Element(
      c_elem("bubbleSize", [], [
        Element(c_num_ref("Sheet1!$C$2:$C$4", ["10", "20", "15"])),
      ]),
    ),
  ])
  let ser_b = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("South")),
    Element(
      c_elem("xVal", [], [
        Element(c_num_ref("Sheet1!$D$2:$D$4", ["2", "4", "7"])),
      ]),
    ),
    Element(
      c_elem("yVal", [], [
        Element(c_num_ref("Sheet1!$E$2:$E$4", ["6", "5", "9"])),
      ]),
    ),
    Element(
      c_elem("bubbleSize", [], [
        Element(c_num_ref("Sheet1!$F$2:$F$4", ["25", "35", "45"])),
      ]),
    ),
  ])
  c_elem("bubbleChart", [], [
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    Element(c_val("bubbleScale", "100")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.150 CT_RadarChart — radar with filled style. Each spoke
/// maps to a category; value determines the distance from centre.
fn radar_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Skills")),
    Element(c_cat(["Speed", "Power", "Tech", "Stamina", "Defense"])),
    Element(c_val_ref(["8", "6", "9", "5", "7"])),
  ])
  c_elem("radarChart", [], [
    Element(c_val("radarStyle", "filled")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.188 CT_StockChart — High-Low-Close stock chart (3 series).
/// The series carry daily OHLC data for 4 trading days.
fn stock_chart_payload() -> @xml.Element {
  let ser_high = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("High")),
    Element(c_cat(["Day 1", "Day 2", "Day 3", "Day 4"])),
    Element(c_val_ref(["45", "48", "42", "50"])),
  ])
  let ser_low = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("Low")),
    Element(c_cat(["Day 1", "Day 2", "Day 3", "Day 4"])),
    Element(c_val_ref(["38", "40", "35", "43"])),
  ])
  let ser_close = c_elem("ser", [], [
    Element(c_val("idx", "2")),
    Element(c_val("order", "2")),
    Element(c_series_tx("Close")),
    Element(c_cat(["Day 1", "Day 2", "Day 3", "Day 4"])),
    Element(c_val_ref(["42", "44", "40", "47"])),
  ])
  c_elem("stockChart", [], [
    Element(ser_high),
    Element(ser_low),
    Element(ser_close),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.76 CT_BarChart with grouping="stacked" — two series
/// stacked on top of each other per category.
fn bar_chart_stacked_payload() -> @xml.Element {
  let ser_a = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Budget")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["20", "25", "30", "35"])),
  ])
  let ser_b = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("Actual")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["15", "20", "25", "30"])),
  ])
  c_elem("barChart", [], [
    Element(c_val("barDir", "col")),
    Element(c_val("grouping", "stacked")),
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    Element(c_val("gapWidth", "0")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.52 dPt + §21.2.2.76 stacked bar — a point-level shape
/// fill override on a stacked segment.
fn bar_chart_stacked_dpt_payload() -> @xml.Element {
  let ser_a = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Budget")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["20", "25", "30", "35"])),
  ])
  let ser_b = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("Actual")),
    Element(c_dpt_solid_fill(1, "00FF99")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["15", "20", "25", "30"])),
  ])
  c_elem("barChart", [], [
    Element(c_val("barDir", "col")),
    Element(c_val("grouping", "stacked")),
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    Element(c_val("gapWidth", "0")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}

///|
/// §21.2.2.76 CT_BarChart with grouping="percentStacked" — two series
/// normalized to 100% per category.
fn bar_chart_percent_stacked_payload() -> @xml.Element {
  let ser_a = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Yes")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["60", "70", "45", "80"])),
  ])
  let ser_b = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("No")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["40", "30", "55", "20"])),
  ])
  c_elem("barChart", [], [
    Element(c_val("barDir", "col")),
    Element(c_val("grouping", "percentStacked")),
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    // §21.2.2.74 gapWidth=0 — bars fill the full category band,
    // eliminating implementation-defined default width ambiguity.
    Element(c_val("gapWidth", "0")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
  ])
}
