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
/// Fixture-only extension payload namespace used under chart `<c:ext>`.
const CHART_FIXTURE_EXT_NS : String = "urn:ooxml:fixture:chart-ext"

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
/// `<c:extLst>` with one lax extension payload.  This keeps chart
/// extension-list coverage schema-valid without creating an Office
/// relationship or relying on a vendor extension schema.
fn c_ext_lst() -> @xml.Element {
  c_elem("extLst", [], [
    Element(
      c_elem("ext", [xa("uri", "{B70EFC72-6FA0-4E4B-A9E8-00AA00BB00CC}")], [
        Element(xep("fx", CHART_FIXTURE_EXT_NS, "covered", [], [])),
      ]),
    ),
  ])
}

///|
/// DrawingML text body for chart-side `<c:txPr>` and `<c:rich>`
/// carriers.  Chart schema owns the wrapper element name; DrawingML
/// owns the bodyPr/lstStyle/p/r/t payload shape.
fn c_text_body(text : String) -> Array[@xml.Node] {
  [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
    Element(
      xe(NS_A, "p", [], [
        Element(
          xe(NS_A, "r", [], [
            Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
            Element(xe(NS_A, "t", [], [Text(text)])),
          ]),
        ),
      ]),
    ),
  ]
}

///|
/// `<c:rich>` typed as a DrawingML text body.
fn c_rich_text(text : String) -> @xml.Element {
  c_elem("rich", [], c_text_body(text))
}

///|
/// Chart-side `<c:txPr>` typed as a DrawingML text body.
fn c_tx_pr(text : String) -> @xml.Element {
  c_elem("txPr", [], c_text_body(text))
}

///|
/// Chart-space `<c:txPr>` whose DrawingML body carries the default run
/// properties the chart renderer consumes for title / axis / label text.
fn c_tx_pr_defaults(
  child : @xml.Element,
  hex : String,
  typeface : String,
) -> @xml.Element {
  catalog_chart_force_children(child, [
    Element(xe(NS_A, "bodyPr", [], [])),
    Element(xe(NS_A, "lstStyle", [], [])),
    Element(
      xe(NS_A, "p", [], [
        Element(
          xe(NS_A, "pPr", [], [
            Element(
              xe(NS_A, "defRPr", [], [
                Element(
                  xe(NS_A, "solidFill", [], [
                    Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
                  ]),
                ),
                Element(xe(NS_A, "latin", [xa("typeface", typeface)], [])),
              ]),
            ),
          ]),
        ),
        Element(
          xe(NS_A, "r", [], [
            Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
            Element(xe(NS_A, "t", [], [Text("Chart defaults")])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
/// Chart-side shape properties with a solid DrawingML fill.
fn c_sp_pr_solid(hex : String) -> @xml.Element {
  c_elem("spPr", [], [
    Element(
      xe(NS_A, "solidFill", [], [
        Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
      ]),
    ),
  ])
}

///|
/// `<c:marker>` with explicit marker symbol and size.
fn c_marker(symbol : String, size : String, hex : String) -> @xml.Element {
  c_elem("marker", [], [
    Element(c_val("symbol", symbol)),
    Element(c_val("size", size)),
    Element(c_sp_pr_solid(hex)),
  ])
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
/// `<c:numLit>` literal numeric cache.  Unlike `<c:numCache>`, this
/// is an inline data-source branch and has no worksheet formula.
fn c_num_lit(values : Array[String]) -> @xml.Element {
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
  c_elem("numLit", [], kids)
}

///|
/// `<c:strLit>` literal string cache.
fn c_str_lit(values : Array[String]) -> @xml.Element {
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
  c_elem("strLit", [], kids)
}

///|
/// `<c:cat>` using a multi-level string reference/cache.
fn c_cat_multi_level() -> @xml.Element {
  c_elem("cat", [], [
    Element(
      c_elem("multiLvlStrRef", [], [
        Element(c_elem("f", [], [Text("Sheet1!$A$2:$B$5")])),
        Element(
          c_elem("multiLvlStrCache", [], [
            Element(c_val("ptCount", "4")),
            Element(
              c_elem("lvl", [], [
                Element(
                  c_elem("pt", [xa("idx", "0")], [
                    Element(c_elem("v", [], [Text("North")])),
                  ]),
                ),
                Element(
                  c_elem("pt", [xa("idx", "1")], [
                    Element(c_elem("v", [], [Text("North")])),
                  ]),
                ),
                Element(
                  c_elem("pt", [xa("idx", "2")], [
                    Element(c_elem("v", [], [Text("South")])),
                  ]),
                ),
                Element(
                  c_elem("pt", [xa("idx", "3")], [
                    Element(c_elem("v", [], [Text("South")])),
                  ]),
                ),
              ]),
            ),
            Element(
              c_elem("lvl", [], [
                Element(
                  c_elem("pt", [xa("idx", "0")], [
                    Element(c_elem("v", [], [Text("Q1")])),
                  ]),
                ),
                Element(
                  c_elem("pt", [xa("idx", "1")], [
                    Element(c_elem("v", [], [Text("Q2")])),
                  ]),
                ),
                Element(
                  c_elem("pt", [xa("idx", "2")], [
                    Element(c_elem("v", [], [Text("Q1")])),
                  ]),
                ),
                Element(
                  c_elem("pt", [xa("idx", "3")], [
                    Element(c_elem("v", [], [Text("Q2")])),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
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
/// Chart-line carrier with a visible DrawingML line property.
fn c_chart_lines(tag : String) -> @xml.Element {
  c_elem(tag, [], [
    Element(
      c_elem("spPr", [], [
        Element(
          xe(NS_A, "ln", [xa("w", "9525")], [
            Element(
              xe(NS_A, "solidFill", [], [
                Element(xe(NS_A, "srgbClr", [xa("val", "8090A0")], [])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
/// §21.2.2.45 display units on a value axis.
fn c_disp_units() -> @xml.Element {
  c_elem("dispUnits", [], [
    Element(c_val("builtInUnit", "thousands")),
    Element(c_elem("dispUnitsLbl", [], [Element(c_manual_layout())])),
  ])
}

///|
/// Axis pair with optional branches that ordinary baseline chart
/// fixtures do not carry.  Kept separate from `c_axes()` so the
/// simple visual fixtures retain their small, canonical chart trees.
fn c_axes_rich() -> Array[@xml.Element] {
  let cat_ax = c_elem("catAx", [], [
    Element(c_val("axId", "111111111")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "b")),
    Element(c_chart_lines("majorGridlines")),
    Element(c_chart_lines("minorGridlines")),
    Element(
      c_elem("numFmt", [xa("formatCode", "General"), xa("sourceLinked", "1")], []),
    ),
    Element(c_val("majorTickMark", "out")),
    Element(c_val("minorTickMark", "in")),
    Element(c_val("tickLblPos", "nextTo")),
    Element(c_val("crossAx", "222222222")),
    Element(c_val("crosses", "autoZero")),
    Element(c_val("auto", "1")),
    Element(c_val("lblAlgn", "ctr")),
    Element(c_val("lblOffset", "100%")),
    Element(c_val("tickMarkSkip", "2")),
    Element(c_val("noMultiLvlLbl", "0")),
  ])
  let val_ax = c_elem("valAx", [], [
    Element(c_val("axId", "222222222")),
    Element(
      c_elem("scaling", [], [
        Element(c_val("logBase", "10")),
        Element(c_val("orientation", "minMax")),
        Element(c_val("max", "50")),
        Element(c_val("min", "0")),
      ]),
    ),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "l")),
    Element(c_chart_lines("majorGridlines")),
    Element(c_chart_lines("minorGridlines")),
    Element(
      c_elem("numFmt", [xa("formatCode", "#,##0"), xa("sourceLinked", "0")], []),
    ),
    Element(c_val("majorTickMark", "out")),
    Element(c_val("minorTickMark", "in")),
    Element(c_val("tickLblPos", "nextTo")),
    Element(c_val("crossAx", "111111111")),
    Element(c_val("crossBetween", "between")),
    Element(c_val("majorUnit", "10")),
    Element(c_val("minorUnit", "5")),
    Element(c_disp_units()),
  ])
  [cat_ax, val_ax]
}

///|
/// Axis trio used by 3-D and surface chart fixtures: a date/category
/// axis, a value axis, and a series/depth axis.  It covers the
/// date-axis time-unit branches, `crossesAt`, custom display units,
/// and series-axis tick skipping.
fn c_axes_date_value_series() -> Array[@xml.Element] {
  let date_ax = c_elem("dateAx", [], [
    Element(c_val("axId", "111111111")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "b")),
    Element(c_chart_lines("majorGridlines")),
    Element(
      c_elem("numFmt", [xa("formatCode", "m/d/yy"), xa("sourceLinked", "0")], []),
    ),
    Element(c_val("majorTickMark", "out")),
    Element(c_val("minorTickMark", "in")),
    Element(c_val("tickLblPos", "nextTo")),
    Element(c_val("crossAx", "222222222")),
    Element(c_val("crossesAt", "0")),
    Element(c_val("auto", "1")),
    Element(c_val("lblOffset", "100%")),
    Element(c_val("baseTimeUnit", "months")),
    Element(c_val("majorUnit", "1")),
    Element(c_val("majorTimeUnit", "months")),
    Element(c_val("minorUnit", "1")),
    Element(c_val("minorTimeUnit", "days")),
  ])
  let val_ax = c_elem("valAx", [], [
    Element(c_val("axId", "222222222")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "l")),
    Element(c_chart_lines("majorGridlines")),
    Element(
      c_elem("numFmt", [xa("formatCode", "#,##0"), xa("sourceLinked", "0")], []),
    ),
    Element(c_val("majorTickMark", "out")),
    Element(c_val("minorTickMark", "in")),
    Element(c_val("tickLblPos", "nextTo")),
    Element(c_val("crossAx", "111111111")),
    Element(c_val("crossesAt", "0")),
    Element(c_val("crossBetween", "between")),
    Element(c_val("majorUnit", "10")),
    Element(c_val("minorUnit", "5")),
    Element(
      c_elem("dispUnits", [], [
        Element(c_val("custUnit", "1000")),
        Element(c_elem("dispUnitsLbl", [], [Element(c_tx_pr("Thousands"))])),
      ]),
    ),
  ])
  let ser_ax = c_elem("serAx", [], [
    Element(c_val("axId", "333333333")),
    Element(c_elem("scaling", [], [Element(c_val("orientation", "minMax"))])),
    Element(c_val("delete", "0")),
    Element(c_val("axPos", "r")),
    Element(c_val("majorTickMark", "out")),
    Element(c_val("minorTickMark", "none")),
    Element(c_val("tickLblPos", "nextTo")),
    Element(c_val("crossAx", "222222222")),
    Element(c_val("crosses", "autoZero")),
    Element(c_val("tickLblSkip", "1")),
    Element(c_val("tickMarkSkip", "1")),
  ])
  [date_ax, val_ax, ser_ax]
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
/// §21.2.2.88 / §21.2.2.105 — explicit plot-area positioning.
/// This exercises the CT_ManualLayout children that ordinary Office-
/// generated chart fixtures often omit when automatic layout is used.
fn c_manual_layout() -> @xml.Element {
  c_elem("layout", [], [
    Element(
      c_elem("manualLayout", [], [
        Element(c_val("layoutTarget", "inner")),
        Element(c_val("xMode", "factor")),
        Element(c_val("yMode", "factor")),
        Element(c_val("wMode", "factor")),
        Element(c_val("hMode", "factor")),
        Element(c_val("x", "0.08")),
        Element(c_val("y", "0.10")),
        Element(c_val("w", "0.82")),
        Element(c_val("h", "0.72")),
      ]),
    ),
  ])
}

///|
/// §21.2.2.37 / §21.2.2.39 / §21.2.2.40 — chart walls and floor.
/// The `<c:pictureOptions>` branch covers front / side / end
/// application flags without needing an embedded image relationship.
fn c_chart_surface(tag : String, hex : String) -> @xml.Element {
  c_elem(tag, [], [
    Element(c_val("thickness", "25%")),
    Element(
      c_elem("spPr", [], [
        Element(
          xe(NS_A, "solidFill", [], [
            Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
          ]),
        ),
      ]),
    ),
    Element(
      c_elem("pictureOptions", [], [
        Element(c_val("applyToFront", "1")),
        Element(c_val("applyToSides", "1")),
        Element(c_val("applyToEnd", "0")),
        Element(c_val("pictureFormat", "stretch")),
        Element(c_val("pictureStackUnit", "1")),
      ]),
    ),
  ])
}

///|
/// §21.2.2.216 — 3-D view parameters.  Values use Strict-compatible
/// percent lexical forms where ECMA-376 Strict requires the `%`
/// suffix and Transitional also accepts it.
fn c_view3d() -> @xml.Element {
  c_elem("view3D", [], [
    Element(c_val("rotX", "20")),
    Element(c_val("hPercent", "120%")),
    Element(c_val("rotY", "30")),
    Element(c_val("depthPercent", "150%")),
    Element(c_val("rAngAx", "1")),
    Element(c_val("perspective", "30")),
  ])
}

///|
/// §21.2.2.49 data-table options under `<c:plotArea>`.
fn c_data_table() -> @xml.Element {
  c_elem("dTable", [], [
    Element(c_val("showHorzBorder", "1")),
    Element(c_val("showVertBorder", "1")),
    Element(c_val("showOutline", "1")),
    Element(c_val("showKeys", "1")),
  ])
}

///|
/// §21.2.2.50 / §21.2.2.51 — chart data labels, including both an
/// item-level `<c:dLbl>` and group-level display switches.
fn c_data_labels() -> @xml.Element {
  c_elem("dLbls", [], [
    Element(
      c_elem("dLbl", [], [
        Element(c_val("idx", "0")),
        Element(c_manual_layout()),
        Element(
          c_elem("numFmt", [xa("formatCode", "0"), xa("sourceLinked", "0")], []),
        ),
        Element(c_val("dLblPos", "outEnd")),
        Element(c_val("showLegendKey", "1")),
        Element(c_val("showVal", "1")),
        Element(c_val("showCatName", "1")),
        Element(c_val("showSerName", "1")),
        Element(c_val("showPercent", "0")),
        Element(c_val("showBubbleSize", "0")),
        Element(c_elem("separator", [], [Text(", ")])),
      ]),
    ),
    Element(
      c_elem("numFmt", [xa("formatCode", "0"), xa("sourceLinked", "0")], []),
    ),
    Element(c_val("dLblPos", "outEnd")),
    Element(c_val("showLegendKey", "1")),
    Element(c_val("showVal", "1")),
    Element(c_val("showCatName", "1")),
    Element(c_val("showSerName", "1")),
    Element(c_val("showPercent", "0")),
    Element(c_val("showBubbleSize", "0")),
    Element(c_elem("separator", [], [Text(", ")])),
    Element(c_val("showLeaderLines", "1")),
    Element(c_chart_lines("leaderLines")),
  ])
}

///|
/// Data labels with explicit chart-side text properties.
fn c_data_labels_with_text() -> @xml.Element {
  c_elem("dLbls", [], [
    Element(
      c_elem("dLbl", [], [
        Element(c_val("idx", "0")),
        Element(c_manual_layout()),
        Element(c_elem("tx", [], [Element(c_rich_text("Label 0"))])),
        Element(
          c_elem("numFmt", [xa("formatCode", "0.0"), xa("sourceLinked", "0")], []),
        ),
        Element(c_sp_pr_solid("FFF2CC")),
        Element(c_tx_pr("Data label")),
        Element(c_val("dLblPos", "outEnd")),
        Element(c_val("showLegendKey", "1")),
        Element(c_val("showVal", "1")),
        Element(c_val("showCatName", "1")),
        Element(c_val("showSerName", "1")),
        Element(c_val("showPercent", "0")),
        Element(c_val("showBubbleSize", "0")),
        Element(c_elem("separator", [], [Text(" / ")])),
        Element(c_ext_lst()),
      ]),
    ),
    Element(
      c_elem("numFmt", [xa("formatCode", "0.0"), xa("sourceLinked", "0")], []),
    ),
    Element(c_tx_pr("Data labels")),
    Element(c_val("dLblPos", "outEnd")),
    Element(c_val("showLegendKey", "1")),
    Element(c_val("showVal", "1")),
    Element(c_val("showCatName", "1")),
    Element(c_val("showSerName", "1")),
    Element(c_val("showPercent", "0")),
    Element(c_val("showBubbleSize", "0")),
    Element(c_elem("separator", [], [Text(" / ")])),
    Element(c_val("showLeaderLines", "1")),
    Element(c_chart_lines("leaderLines")),
    Element(c_ext_lst()),
  ])
}

///|
/// Full trendline branch used by rare-series fixtures.
fn c_trendline_rich() -> @xml.Element {
  c_elem("trendline", [], [
    Element(c_elem("name", [], [Text("Linear forecast")])),
    Element(c_sp_pr_solid("DDEBF7")),
    Element(c_val("trendlineType", "linear")),
    Element(c_val("order", "2")),
    Element(c_val("period", "2")),
    Element(c_val("forward", "1.5")),
    Element(c_val("backward", "0.5")),
    Element(c_val("intercept", "0")),
    Element(c_val("dispRSqr", "1")),
    Element(c_val("dispEq", "1")),
    Element(
      c_elem("trendlineLbl", [], [
        Element(c_manual_layout()),
        Element(c_elem("tx", [], [Element(c_rich_text("y = ax + b"))])),
        Element(
          c_elem(
            "numFmt",
            [xa("formatCode", "0.00"), xa("sourceLinked", "0")],
            [],
          ),
        ),
        Element(c_sp_pr_solid("E2F0D9")),
        Element(c_tx_pr("Trendline label")),
        Element(c_ext_lst()),
      ]),
    ),
    Element(c_ext_lst()),
  ])
}

///|
/// Custom positive/negative error bars with literal data sources.
fn c_err_bars_custom(dir : String) -> @xml.Element {
  c_elem("errBars", [], [
    Element(c_val("errDir", dir)),
    Element(c_val("errBarType", "both")),
    Element(c_val("errValType", "cust")),
    Element(c_val("noEndCap", "0")),
    Element(c_elem("plus", [], [Element(c_num_lit(["1", "2", "1", "3"]))])),
    Element(c_elem("minus", [], [Element(c_num_lit(["1", "1", "2", "1"]))])),
    Element(c_val("val", "1.5")),
    Element(c_sp_pr_solid("F8CBAD")),
    Element(c_ext_lst()),
  ])
}

///|
/// Up/down bars with explicit up/down shape properties.
fn c_up_down_bars() -> @xml.Element {
  c_elem("upDownBars", [], [
    Element(c_val("gapWidth", "150%")),
    Element(c_elem("upBars", [], [Element(c_sp_pr_solid("FFFFFF"))])),
    Element(c_elem("downBars", [], [Element(c_sp_pr_solid("404040"))])),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.26 CT_ChartSpace optional metadata that does not require
/// an additional relationship part.
fn c_chart_space_prefix_options() -> Array[@xml.Node] {
  [
    Element(c_val("date1904", "0")),
    Element(c_val("lang", "en-US")),
    Element(c_val("roundedCorners", "1")),
    Element(c_val("style", "10")),
    Element(
      c_elem(
        "clrMapOvr",
        [
          xa("bg1", "lt1"),
          xa("tx1", "dk1"),
          xa("bg2", "lt2"),
          xa("tx2", "dk2"),
          xa("accent1", "accent1"),
          xa("accent2", "accent2"),
          xa("accent3", "accent3"),
          xa("accent4", "accent4"),
          xa("accent5", "accent5"),
          xa("accent6", "accent6"),
          xa("hlink", "hlink"),
          xa("folHlink", "folHlink"),
        ],
        [],
      ),
    ),
    Element(
      c_elem("protection", [], [
        Element(c_val("chartObject", "0")),
        Element(c_val("data", "0")),
        Element(c_val("formatting", "0")),
        Element(c_val("selection", "0")),
        Element(c_val("userInterface", "0")),
      ]),
    ),
  ]
}

///|
/// §21.2.2.144 print settings for the chart part.
fn c_print_settings() -> @xml.Element {
  c_elem("printSettings", [], [
    Element(
      c_elem(
        "headerFooter",
        [
          xa("alignWithMargins", "1"),
          xa("differentOddEven", "1"),
          xa("differentFirst", "1"),
        ],
        [
          Element(c_elem("oddHeader", [], [Text("&CChart")])),
          Element(c_elem("oddFooter", [], [Text("&P")])),
          Element(c_elem("evenHeader", [], [Text("&LEven")])),
          Element(c_elem("evenFooter", [], [Text("&RFooter")])),
          Element(c_elem("firstHeader", [], [Text("&FFirst")])),
          Element(c_elem("firstFooter", [], [Text("&CFirst footer")])),
        ],
      ),
    ),
    Element(
      c_elem(
        "pageMargins",
        [
          xa("l", "0.7"),
          xa("r", "0.7"),
          xa("t", "0.75"),
          xa("b", "0.75"),
          xa("header", "0.3"),
          xa("footer", "0.3"),
        ],
        [],
      ),
    ),
    Element(
      c_elem(
        "pageSetup",
        [
          xa("paperSize", "1"),
          xa("orientation", "landscape"),
          xa("horizontalDpi", "600"),
          xa("verticalDpi", "600"),
          xa("copies", "1"),
        ],
        [],
      ),
    ),
  ])
}

///|
/// ChartSpace wrapper for coverage-driven fixtures that need the
/// optional chart-level and chartSpace-level branches in canonical
/// XSD order.
fn wrap_chart_space_with_rich_options(
  chart_payload : @xml.Element,
  axes : Array[@xml.Element],
) -> @xml.Element {
  let plot_area_kids : Array[@xml.Node] = [
    Element(c_manual_layout()),
    Element(chart_payload),
  ]
  for ax in axes {
    plot_area_kids.push(Element(ax))
  }
  plot_area_kids.push(Element(c_data_table()))
  let chart_kids : Array[@xml.Node] = [
    Element(c_val("autoTitleDeleted", "0")),
    Element(c_view3d()),
    Element(c_chart_surface("floor", "F4F1EA")),
    Element(c_chart_surface("sideWall", "E8EDF4")),
    Element(c_chart_surface("backWall", "F2F7EE")),
    Element(c_elem("plotArea", [], plot_area_kids)),
    Element(c_chart_legend_with_entry("r")),
    Element(c_val("plotVisOnly", "1")),
    Element(c_val("dispBlanksAs", "gap")),
    Element(c_val("showDLblsOverMax", "1")),
  ]
  let chart = c_elem("chart", [], chart_kids)
  let chart_space_kids = c_chart_space_prefix_options()
  chart_space_kids.push(Element(chart))
  chart_space_kids.push(Element(c_print_settings()))
  c_elem("chartSpace", [], chart_space_kids)
}

///|
/// Rich wrapper that also carries pivot-chart metadata in canonical
/// chartSpace/chart order.  The metadata is self-contained: no
/// external pivot-cache relationship is required by the chart schema.
fn wrap_chart_space_with_pivot_options(
  chart_payload : @xml.Element,
  axes : Array[@xml.Element],
) -> @xml.Element {
  let plot_area_kids : Array[@xml.Node] = [
    Element(c_manual_layout()),
    Element(chart_payload),
  ]
  for ax in axes {
    plot_area_kids.push(Element(ax))
  }
  plot_area_kids.push(Element(c_data_table()))
  plot_area_kids.push(Element(c_sp_pr_solid("F9FAFB")))
  let pivot_fmt = c_elem("pivotFmt", [], [
    Element(c_val("idx", "0")),
    Element(c_sp_pr_solid("EEF4FF")),
    Element(c_tx_pr("Pivot point")),
    Element(c_marker("diamond", "7", "2F80ED")),
    Element(
      c_elem("dLbl", [], [
        Element(c_val("idx", "0")),
        Element(c_val("delete", "0")),
      ]),
    ),
  ])
  let chart_kids : Array[@xml.Node] = [
    Element(c_val("autoTitleDeleted", "0")),
    Element(c_elem("pivotFmts", [], [Element(pivot_fmt)])),
    Element(c_view3d()),
    Element(c_chart_surface("floor", "F4F1EA")),
    Element(c_chart_surface("sideWall", "E8EDF4")),
    Element(c_chart_surface("backWall", "F2F7EE")),
    Element(c_elem("plotArea", [], plot_area_kids)),
    Element(c_chart_legend_with_entry("r")),
    Element(c_val("plotVisOnly", "1")),
    Element(c_val("dispBlanksAs", "gap")),
    Element(c_val("showDLblsOverMax", "1")),
    Element(c_ext_lst()),
  ]
  let chart = c_elem("chart", [], chart_kids)
  let chart_space_kids = c_chart_space_prefix_options()
  chart_space_kids.insert(
    5,
    Element(
      c_elem("pivotSource", [], [
        Element(c_elem("name", [], [Text("PivotTable1")])),
        Element(c_val("fmtId", "0")),
      ]),
    ),
  )
  chart_space_kids.push(Element(chart))
  chart_space_kids.push(Element(c_sp_pr_solid("FFFFFF")))
  chart_space_kids.push(Element(c_tx_pr("Chart space text")))
  chart_space_kids.push(Element(c_print_settings()))
  c_elem("chartSpace", [], chart_space_kids)
}

///|
/// Legend variant covering the repeated `<c:legendEntry>` child.
fn c_chart_legend_with_entry(pos : String) -> @xml.Element {
  c_elem("legend", [], [
    Element(c_val("legendPos", pos)),
    Element(
      c_elem("legendEntry", [], [
        Element(c_val("idx", "0")),
        Element(c_val("delete", "0")),
      ]),
    ),
    Element(c_manual_layout()),
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
/// Catalog host for §21.2.2.92 `<c:leaderLines>`.  Leader lines are
/// consumed only by pie/doughnut external data labels, so the generic
/// chartSpace ancestry can parse without exercising the render path.
fn catalog_chart_leader_lines_root(leader_lines : @xml.Element) -> @xml.Element {
  let ns_c = leader_lines.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Mix")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D"]))])),
    Element(ce("val", [], [Element(num_lit(["35", "25", "20", "20"]))])),
  ])
  let dlbls = ce("dLbls", [], [
    Element(cv("dLblPos", "outEnd")),
    Element(cv("showVal", "1")),
    Element(leader_lines),
  ])
  let pie_chart = ce("pieChart", [], [
    Element(cv("varyColors", "1")),
    Element(ser),
    Element(dlbls),
    Element(cv("firstSliceAng", "0")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(pie_chart),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
fn catalog_chart_marker_force_val(
  element : @xml.Element,
  value : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  let mut saw = false
  for attr in element.attributes {
    if attr.name.local_name == "val" {
      saw = true
      attrs.push({ name: attr.name, value })
    } else {
      attrs.push(attr)
    }
  }
  if !saw {
    attrs.push(xa("val", value))
  }
  { name: element.name, attributes: attrs, children: element.children }
}

///|
fn catalog_chart_force_attr(
  element : @xml.Element,
  attr_name : String,
  value : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  let mut saw = false
  for attr in element.attributes {
    if attr.name.local_name == attr_name {
      saw = true
      attrs.push({ name: attr.name, value })
    } else {
      attrs.push(attr)
    }
  }
  if !saw {
    attrs.push(xa(attr_name, value))
  }
  { name: element.name, attributes: attrs, children: element.children }
}

///|
fn catalog_chart_force_children(
  element : @xml.Element,
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: element.name, attributes: element.attributes, children }
}

///|
/// Catalog host for §21.2.2.227 `<c:varyColors>`. The target is placed
/// on a single-series clustered bar chart, where the renderer consumes it
/// as point-by-point accent palette selection. Pruning the target returns
/// to one resolved series fill for every bar.
fn catalog_chart_vary_colors_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let bar_chart = ce("barChart", [], [
    Element(cv("barDir", "col")),
    Element(cv("grouping", "clustered")),
    Element(catalog_chart_marker_force_val(child, "1")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bar_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Shared catalog host for §21.2.2.103 `<c:marker>` and its
/// `<c:symbol>` / `<c:size>` children.  Scatter series consume marker
/// glyphs directly; using a non-default symbol and size makes pruning
/// the target change the rendered SVG without adding debug paint.
fn catalog_chart_marker_scatter_root(
  ns_c : String,
  marker : @xml.Element,
) -> @xml.Element {
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Pts")]))])),
    Element(ce("xVal", [], [Element(num_lit(["1", "2", "3"]))])),
    Element(ce("yVal", [], [Element(num_lit(["10", "20", "30"]))])),
    Element(marker),
  ])
  let scatter_chart = ce("scatterChart", [], [
    Element(cv("scatterStyle", "marker")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let x_axis = ce("valAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let y_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "l")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(scatter_chart),
    Element(x_axis),
    Element(y_axis),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
fn catalog_chart_marker_root(marker : @xml.Element) -> @xml.Element {
  let ns_c = marker.name.ns.unwrap_or(NS_C)
  let children : Array[@xml.Node] = [
    Element(xep("c", ns_c, "symbol", [xa("val", "x")], [])),
    Element(xep("c", ns_c, "size", [xa("val", "12")], [])),
  ]
  let marker : @xml.Element = {
    name: marker.name,
    attributes: marker.attributes,
    children,
  }
  catalog_chart_marker_scatter_root(ns_c, marker)
}

///|
fn catalog_chart_marker_child_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let marker_kids : Array[@xml.Node] = []
  match child.name.local_name {
    "symbol" => {
      marker_kids.push(Element(catalog_chart_marker_force_val(child, "x")))
      marker_kids.push(Element(xep("c", ns_c, "size", [xa("val", "12")], [])))
    }
    "size" => {
      marker_kids.push(Element(xep("c", ns_c, "symbol", [xa("val", "x")], [])))
      marker_kids.push(Element(catalog_chart_marker_force_val(child, "12")))
    }
    _ => marker_kids.push(Element(child))
  }
  let marker = xep("c", ns_c, "marker", [], marker_kids)
  catalog_chart_marker_scatter_root(ns_c, marker)
}

///|
/// Host for §21.2.2.102 `<c:marker>` (CT_Boolean) on line charts.
/// `val="0"` is intentionally visible: pruning the target restores the
/// renderer's default marker glyphs.
fn catalog_chart_line_marker_flag_root(marker : @xml.Element) -> @xml.Element {
  let ns_c = marker.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Trend")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(cv("varyColors", "0")),
    Element(ser),
    Element(catalog_chart_marker_force_val(marker, "0")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "l")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
/// Host for §21.2.2.181 `<c:scatterStyle>`.  `val="none"` suppresses
/// both scatter lines and point markers; pruning restores the default
/// marker style.
fn catalog_chart_scatter_style_root(style : @xml.Element) -> @xml.Element {
  let ns_c = style.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Pts")]))])),
    Element(ce("xVal", [], [Element(num_lit(["1", "2", "3"]))])),
    Element(ce("yVal", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let scatter_chart = ce("scatterChart", [], [
    Element(catalog_chart_marker_force_val(style, "none")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let x_axis = ce("valAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let y_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "l")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(scatter_chart),
    Element(x_axis),
    Element(y_axis),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
/// Host for §21.2.2.153 `<c:radarStyle>`.  `standard` draws the
/// series polygon without marker circles; pruning restores the default
/// marker style.
fn catalog_chart_radar_style_root(style : @xml.Element) -> @xml.Element {
  let ns_c = style.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Radar")]))])),
    Element(ce("cat", [], [Element(str_lit(["N", "E", "S", "W"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30", "15"]))])),
  ])
  let radar_chart = ce("radarChart", [], [
    Element(catalog_chart_marker_force_val(style, "standard")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(cv("axPos", "b")),
    Element(cv("crossAx", "222222222")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(cv("axPos", "l")),
    Element(cv("crossAx", "111111111")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(radar_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
fn catalog_chart_of_pie_host(
  ns_c : String,
  option_kids : Array[@xml.Node],
) -> @xml.Element {
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("OfPie")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D", "E"]))])),
    Element(ce("val", [], [Element(num_lit(["40", "30", "20", "5", "5"]))])),
  ])
  let kids : Array[@xml.Node] = []
  let mut inserted_ser = false
  for opt in option_kids {
    match opt {
      Element(e) =>
        if e.name.local_name == "ser" {
          kids.push(Element(e))
          inserted_ser = true
        } else {
          kids.push(Element(e))
        }
      _ => kids.push(opt)
    }
  }
  if !inserted_ser {
    let with_ser : Array[@xml.Node] = []
    let mut ser_done = false
    for opt in kids {
      match opt {
        Element(e) =>
          if !ser_done &&
            (
              e.name.local_name == "splitType" ||
              e.name.local_name == "splitPos" ||
              e.name.local_name == "custSplit" ||
              e.name.local_name == "secondPieSize" ||
              e.name.local_name == "serLines"
            ) {
            with_ser.push(Element(ser))
            with_ser.push(Element(e))
            ser_done = true
          } else {
            with_ser.push(Element(e))
          }
        _ => with_ser.push(opt)
      }
    }
    if !ser_done {
      with_ser.push(Element(ser))
    }
    kids.clear()
    for opt in with_ser {
      kids.push(opt)
    }
  }
  let of_pie_chart = ce("ofPieChart", [], kids)
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(of_pie_chart),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
fn catalog_chart_of_pie_child_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let cv = fn(tag : String, value : String) -> @xml.Element {
    xep("c", ns_c, tag, [xa("val", value)], [])
  }
  match child.name.local_name {
    "ofPieType" =>
      catalog_chart_of_pie_host(ns_c, [
        Element(catalog_chart_marker_force_val(child, "bar")),
        Element(cv("varyColors", "1")),
        Element(cv("splitType", "pos")),
        Element(cv("splitPos", "2")),
      ])
    "splitType" =>
      catalog_chart_of_pie_host(ns_c, [
        Element(cv("ofPieType", "pie")),
        Element(cv("varyColors", "1")),
        Element(catalog_chart_marker_force_val(child, "cust")),
        Element(
          xep("c", ns_c, "custSplit", [], [
            Element(cv("secondPiePt", "0")),
            Element(cv("secondPiePt", "4")),
          ]),
        ),
      ])
    "splitPos" =>
      catalog_chart_of_pie_host(ns_c, [
        Element(cv("ofPieType", "pie")),
        Element(cv("varyColors", "1")),
        Element(cv("splitType", "pos")),
        Element(catalog_chart_marker_force_val(child, "2")),
      ])
    "custSplit" => {
      let cust_split : @xml.Element = {
        name: child.name,
        attributes: child.attributes,
        children: [
          Element(cv("secondPiePt", "0")),
          Element(cv("secondPiePt", "4")),
        ],
      }
      catalog_chart_of_pie_host(ns_c, [
        Element(cv("ofPieType", "pie")),
        Element(cv("varyColors", "1")),
        Element(cv("splitType", "cust")),
        Element(cust_split),
      ])
    }
    "secondPiePt" => {
      let target = catalog_chart_marker_force_val(child, "0")
      catalog_chart_of_pie_host(ns_c, [
        Element(cv("ofPieType", "pie")),
        Element(cv("varyColors", "1")),
        Element(cv("splitType", "cust")),
        Element(
          xep("c", ns_c, "custSplit", [], [
            Element(target),
            Element(cv("secondPiePt", "4")),
          ]),
        ),
      ])
    }
    _ => catalog_chart_of_pie_host(ns_c, [Element(child)])
  }
}

///|
fn catalog_chart_bubble_option_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let target = match child.name.local_name {
    "bubble3D" => catalog_chart_marker_force_val(child, "1")
    "bubbleScale" => catalog_chart_marker_force_val(child, "200")
    "showNegBubbles" => catalog_chart_marker_force_val(child, "0")
    "sizeRepresents" => catalog_chart_marker_force_val(child, "w")
    _ => child
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Bubble")]))])),
    Element(ce("xVal", [], [Element(num_lit(["1", "2", "3"]))])),
    Element(ce("yVal", [], [Element(num_lit(["10", "20", "30"]))])),
    Element(ce("bubbleSize", [], [Element(num_lit(["-9", "4", "9"]))])),
  ])
  let kids : Array[@xml.Node] = [Element(cv("varyColors", "0")), Element(ser)]
  match child.name.local_name {
    "bubble3D" => kids.push(Element(target))
    "bubbleScale" => kids.push(Element(target))
    "showNegBubbles" => kids.push(Element(target))
    "sizeRepresents" => kids.push(Element(target))
    _ => kids.push(Element(target))
  }
  kids.push(Element(cv("axId", "111111111")))
  kids.push(Element(cv("axId", "222222222")))
  let bubble_chart = ce("bubbleChart", [], kids)
  let x_axis = ce("valAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let y_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "l")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bubble_chart),
    Element(x_axis),
    Element(y_axis),
  ])
  let chart = ce("chart", [], [
    Element(plot_area),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  ce("chartSpace", [], [Element(chart)])
}

///|
fn catalog_chart_data_label_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let line_ser = fn() -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", "0")),
      Element(cv("order", "0")),
      Element(ce("tx", [], [Element(ce("v", [], [Text("Series A")]))])),
      Element(ce("cat", [], [Element(str_lit(["Alpha", "Beta", "Gamma"]))])),
      Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
    ])
  }
  let bubble_ser = fn() -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", "0")),
      Element(cv("order", "0")),
      Element(ce("tx", [], [Element(ce("v", [], [Text("Bubbles")]))])),
      Element(ce("xVal", [], [Element(num_lit(["1", "2", "3"]))])),
      Element(ce("yVal", [], [Element(num_lit(["10", "20", "30"]))])),
      Element(ce("bubbleSize", [], [Element(num_lit(["7", "11", "13"]))])),
    ])
  }
  let pie_ser = fn() -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", "0")),
      Element(cv("order", "0")),
      Element(ce("tx", [], [Element(ce("v", [], [Text("Mix")]))])),
      Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
      Element(ce("val", [], [Element(num_lit(["30", "50", "20"]))])),
    ])
  }
  let cat_val_axes = fn() -> Array[@xml.Node] {
    [
      Element(
        ce("catAx", [], [
          Element(cv("axId", "111111111")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "b")),
          Element(cv("crossAx", "222222222")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
      Element(
        ce("valAx", [], [
          Element(cv("axId", "222222222")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "l")),
          Element(cv("crossAx", "111111111")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
    ]
  }
  let value_axes = fn() -> Array[@xml.Node] {
    [
      Element(
        ce("valAx", [], [
          Element(cv("axId", "111111111")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "b")),
          Element(cv("crossAx", "222222222")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
      Element(
        ce("valAx", [], [
          Element(cv("axId", "222222222")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "l")),
          Element(cv("crossAx", "111111111")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
    ]
  }
  let line_root = fn(dlbls : @xml.Element) -> @xml.Element {
    let chart_type = ce("lineChart", [], [
      Element(cv("grouping", "standard")),
      Element(line_ser()),
      Element(dlbls),
      Element(cv("marker", "1")),
      Element(cv("axId", "111111111")),
      Element(cv("axId", "222222222")),
    ])
    let plot_area = ce("plotArea", [], [
      Element(ce("layout", [], [])),
      Element(chart_type),
    ])
    for axis in cat_val_axes() {
      plot_area.children.push(axis)
    }
    ce("chartSpace", [], [
      Element(
        ce("chart", [], [
          Element(plot_area),
          Element(cv("plotVisOnly", "1")),
          Element(cv("dispBlanksAs", "gap")),
        ]),
      ),
    ])
  }
  let bubble_root = fn(dlbls : @xml.Element) -> @xml.Element {
    let chart_type = ce("bubbleChart", [], [
      Element(bubble_ser()),
      Element(dlbls),
      Element(cv("bubbleScale", "100")),
      Element(cv("showNegBubbles", "1")),
      Element(cv("sizeRepresents", "area")),
      Element(cv("axId", "111111111")),
      Element(cv("axId", "222222222")),
    ])
    let plot_area = ce("plotArea", [], [
      Element(ce("layout", [], [])),
      Element(chart_type),
    ])
    for axis in value_axes() {
      plot_area.children.push(axis)
    }
    ce("chartSpace", [], [
      Element(
        ce("chart", [], [
          Element(plot_area),
          Element(cv("plotVisOnly", "1")),
          Element(cv("dispBlanksAs", "gap")),
        ]),
      ),
    ])
  }
  let pie_root = fn(dlbls : @xml.Element) -> @xml.Element {
    let chart_type = ce("pieChart", [], [
      Element(cv("varyColors", "1")),
      Element(pie_ser()),
      Element(dlbls),
      Element(cv("firstSliceAng", "0")),
    ])
    let plot_area = ce("plotArea", [], [
      Element(ce("layout", [], [])),
      Element(chart_type),
    ])
    ce("chartSpace", [], [
      Element(
        ce("chart", [], [
          Element(plot_area),
          Element(cv("plotVisOnly", "1")),
          Element(cv("dispBlanksAs", "gap")),
        ]),
      ),
    ])
  }
  match child.name.local_name {
    "dLbls" => {
      let dlbls = catalog_chart_force_children(child, [
        Element(cv("showVal", "1")),
        Element(cv("showCatName", "1")),
      ])
      line_root(dlbls)
    }
    "dLbl" => {
      let dlbl = catalog_chart_force_children(child, [
        Element(cv("idx", "1")),
        Element(cv("showSerName", "1")),
      ])
      line_root(ce("dLbls", [], [Element(dlbl)]))
    }
    "numFmt" => {
      let fmt = catalog_chart_force_attr(
        catalog_chart_force_attr(child, "formatCode", "0.00"),
        "sourceLinked",
        "0",
      )
      line_root(ce("dLbls", [], [Element(fmt), Element(cv("showVal", "1"))]))
    }
    "dLblPos" => {
      let pos = catalog_chart_marker_force_val(child, "outEnd")
      pie_root(
        ce("dLbls", [], [
          Element(cv("showVal", "1")),
          Element(pos),
          Element(ce("leaderLines", [], [])),
        ]),
      )
    }
    "showLeaderLines" => {
      let show = catalog_chart_marker_force_val(child, "0")
      pie_root(
        ce("dLbls", [], [
          Element(cv("showVal", "1")),
          Element(cv("dLblPos", "outEnd")),
          Element(show),
          Element(ce("leaderLines", [], [])),
        ]),
      )
    }
    "showCatName" => {
      let show = catalog_chart_marker_force_val(child, "1")
      line_root(ce("dLbls", [], [Element(show)]))
    }
    "showBubbleSize" => {
      let show = catalog_chart_marker_force_val(child, "1")
      bubble_root(ce("dLbls", [], [Element(show)]))
    }
    "showLegendKey" => {
      let show = catalog_chart_marker_force_val(child, "1")
      line_root(ce("dLbls", [], [Element(cv("showVal", "1")), Element(show)]))
    }
    "showVal" | "showSerName" | "showPercent" => {
      let show = catalog_chart_marker_force_val(child, "1")
      pie_root(ce("dLbls", [], [Element(show)]))
    }
    "separator" => {
      let sep = if child.children.length() == 0 {
        catalog_chart_force_children(child, [Text(" / ")])
      } else {
        child
      }
      pie_root(
        ce("dLbls", [], [
          Element(cv("showVal", "1")),
          Element(cv("showPercent", "1")),
          Element(sep),
        ]),
      )
    }
    _ =>
      line_root(ce("dLbls", [], [Element(child), Element(cv("showVal", "1"))]))
  }
}

///|
/// Shared catalog host for §21.2.2.54 `<c:dTable>` and its border/key
/// flags.  The chart renderer consumes this only under `<c:plotArea>`, so
/// the host builds a minimal line chart with axes and places the target in
/// the data-table branch.
fn catalog_chart_data_table_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_cache = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strCache", [], kids)
  }
  let num_cache = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numCache", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(
      ce("tx", [], [
        Element(
          ce("strRef", [], [
            Element(ce("f", [], [Text("Sheet1!$A$1")])),
            Element(str_cache(["Data Table"])),
          ]),
        ),
      ]),
    ),
    Element(
      ce("cat", [], [
        Element(
          ce("strRef", [], [
            Element(ce("f", [], [Text("Sheet1!$A$2:$A$4")])),
            Element(str_cache(["Alpha", "Beta", "Gamma"])),
          ]),
        ),
      ]),
    ),
    Element(
      ce("val", [], [
        Element(
          ce("numRef", [], [
            Element(ce("f", [], [Text("Sheet1!$B$2:$B$4")])),
            Element(num_cache(["10", "20", "30"])),
          ]),
        ),
      ]),
    ),
  ])
  let dtable = match child.name.local_name {
    "dTable" =>
      catalog_chart_force_children(child, [
        Element(cv("showHorzBorder", "0")),
        Element(cv("showVertBorder", "0")),
        Element(cv("showOutline", "0")),
        Element(cv("showKeys", "1")),
      ])
    "showHorzBorder" | "showVertBorder" | "showOutline" =>
      ce("dTable", [], [
        Element(catalog_chart_marker_force_val(child, "0")),
        Element(cv("showKeys", "1")),
      ])
    "showKeys" =>
      ce("dTable", [], [Element(catalog_chart_marker_force_val(child, "1"))])
    _ => ce("dTable", [], [Element(child)])
  }
  let chart_type = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(chart_type),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
    Element(dtable),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Shared catalog host for chart data-source/cache elements.  These
/// elements are only "rendered" when they are placed on a consumed chart
/// path: series text, category labels, numeric values, bubble geometry, or
/// chart title text.  External formulas (`c:f`) are intentionally excluded
/// from this host because the renderer consumes cached OOXML values and does
/// not evaluate workbook references yet.
fn catalog_chart_data_source_root(
  child : @xml.Element,
  type_local : String,
) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_pt = fn(idx : String, value : String) -> @xml.Element {
    ce("pt", [xa("idx", idx)], [Element(ce("v", [], [Text(value)]))])
  }
  let str_pt = fn(idx : String, value : String) -> @xml.Element {
    ce("pt", [xa("idx", idx)], [Element(ce("v", [], [Text(value)]))])
  }
  let num_lit = fn(values : Array[String], fmt : String) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text(fmt)])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(Element(num_pt(i.to_string(), v)))
    }
    ce("numLit", [], kids)
  }
  let str_cache = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(Element(str_pt(i.to_string(), v)))
    }
    ce("strCache", [], kids)
  }
  let num_ref = fn(cache : @xml.Element) -> @xml.Element {
    ce("numRef", [], [
      Element(ce("f", [], [Text("Sheet1!$B$2:$B$4")])),
      Element(cache),
    ])
  }
  let str_ref = fn(cache : @xml.Element) -> @xml.Element {
    ce("strRef", [], [
      Element(ce("f", [], [Text("Sheet1!$A$2:$A$4")])),
      Element(cache),
    ])
  }
  let multi_lvl_cache = fn() -> @xml.Element {
    ce("multiLvlStrCache", [], [
      Element(cv("ptCount", "3")),
      Element(
        ce("lvl", [], [
          Element(str_pt("0", "North")),
          Element(str_pt("1", "North")),
          Element(str_pt("2", "South")),
        ]),
      ),
      Element(
        ce("lvl", [], [
          Element(str_pt("0", "Q1")),
          Element(str_pt("1", "Q2")),
          Element(str_pt("2", "Q3")),
        ]),
      ),
    ])
  }
  let multi_lvl_ref = fn(cache : @xml.Element) -> @xml.Element {
    ce("multiLvlStrRef", [], [
      Element(ce("f", [], [Text("Sheet1!$A$2:$B$4")])),
      Element(cache),
    ])
  }
  let line_ser = fn(
    tx : @xml.Element,
    cat : @xml.Element,
    val : @xml.Element,
  ) -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", "0")),
      Element(cv("order", "0")),
      Element(tx),
      Element(cat),
      Element(val),
    ])
  }
  let cat_val_axes = fn() -> Array[@xml.Node] {
    [
      Element(
        ce("catAx", [], [
          Element(cv("axId", "111111111")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "b")),
          Element(cv("crossAx", "222222222")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
      Element(
        ce("valAx", [], [
          Element(cv("axId", "222222222")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "l")),
          Element(cv("crossAx", "111111111")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
    ]
  }
  let value_axes = fn() -> Array[@xml.Node] {
    [
      Element(
        ce("valAx", [], [
          Element(cv("axId", "111111111")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "b")),
          Element(cv("crossAx", "222222222")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
      Element(
        ce("valAx", [], [
          Element(cv("axId", "222222222")),
          Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
          Element(cv("axPos", "l")),
          Element(cv("crossAx", "111111111")),
          Element(cv("crosses", "autoZero")),
        ]),
      ),
    ]
  }
  let line_root = fn(
    ser : @xml.Element,
    title : @xml.Element?,
  ) -> @xml.Element {
    let chart_type = ce("lineChart", [], [
      Element(cv("grouping", "standard")),
      Element(ser),
      Element(
        ce("dLbls", [], [
          Element(cv("showVal", "1")),
          Element(cv("showCatName", "1")),
          Element(cv("showSerName", "1")),
        ]),
      ),
      Element(cv("marker", "1")),
      Element(cv("axId", "111111111")),
      Element(cv("axId", "222222222")),
    ])
    let plot_area = ce("plotArea", [], [
      Element(ce("layout", [], [])),
      Element(chart_type),
    ])
    for axis in cat_val_axes() {
      plot_area.children.push(axis)
    }
    let chart_kids : Array[@xml.Node] = []
    match title {
      Some(t) => chart_kids.push(Element(t))
      None => ()
    }
    chart_kids.push(Element(plot_area))
    chart_kids.push(Element(cv("plotVisOnly", "1")))
    chart_kids.push(Element(cv("dispBlanksAs", "gap")))
    ce("chartSpace", [], [Element(ce("chart", [], chart_kids))])
  }
  let bubble_root = fn(ser : @xml.Element) -> @xml.Element {
    let chart_type = ce("bubbleChart", [], [
      Element(ser),
      Element(
        ce("dLbls", [], [
          Element(cv("showVal", "1")),
          Element(cv("showBubbleSize", "1")),
        ]),
      ),
      Element(cv("bubbleScale", "100")),
      Element(cv("showNegBubbles", "1")),
      Element(cv("sizeRepresents", "area")),
      Element(cv("axId", "111111111")),
      Element(cv("axId", "222222222")),
    ])
    let plot_area = ce("plotArea", [], [
      Element(ce("layout", [], [])),
      Element(chart_type),
    ])
    for axis in value_axes() {
      plot_area.children.push(axis)
    }
    ce("chartSpace", [], [
      Element(
        ce("chart", [], [
          Element(plot_area),
          Element(cv("plotVisOnly", "1")),
          Element(cv("dispBlanksAs", "gap")),
        ]),
      ),
    ])
  }
  let base_tx = ce("tx", [], [Element(str_ref(str_cache(["Series Source"])))])
  let base_cat = ce("cat", [], [
    Element(str_ref(str_cache(["Alpha", "Beta", "Gamma"]))),
  ])
  let base_val = ce("val", [], [Element(num_lit(["10", "20", "30"], "General"))])
  let line_with = fn(cat : @xml.Element, val : @xml.Element) -> @xml.Element {
    line_root(line_ser(base_tx, cat, val), None)
  }
  let line_with_tx = fn(tx : @xml.Element) -> @xml.Element {
    line_root(line_ser(tx, base_cat, base_val), None)
  }
  let bubble_ser = fn(
    x_val : @xml.Element,
    bubble_size : @xml.Element,
  ) -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", "0")),
      Element(cv("order", "0")),
      Element(base_tx),
      Element(x_val),
      Element(ce("yVal", [], [Element(num_lit(["10", "20", "30"], "General"))])),
      Element(bubble_size),
    ])
  }
  match child.name.local_name {
    "formatCode" => {
      let fmt = catalog_chart_force_children(child, [Text("0.00")])
      let val = ce("val", [], [
        Element(
          ce("numLit", [], [
            Element(fmt),
            Element(cv("ptCount", "3")),
            Element(num_pt("0", "10")),
            Element(num_pt("1", "20")),
            Element(num_pt("2", "30")),
          ]),
        ),
      ])
      line_with(base_cat, val)
    }
    "ptCount" => {
      let pt_count = catalog_chart_marker_force_val(child, "2")
      let val = ce("val", [], [
        Element(
          ce("numLit", [], [
            Element(ce("formatCode", [], [Text("General")])),
            Element(pt_count),
            Element(num_pt("0", "10")),
            Element(num_pt("1", "20")),
            Element(num_pt("2", "30")),
          ]),
        ),
      ])
      line_with(base_cat, val)
    }
    "pt" => {
      let pt = catalog_chart_force_children(
        catalog_chart_force_attr(child, "idx", "1"),
        [Element(ce("v", [], [Text("88")]))],
      )
      let val = ce("val", [], [
        Element(
          ce("numLit", [], [
            Element(ce("formatCode", [], [Text("General")])),
            Element(cv("ptCount", "3")),
            Element(num_pt("0", "10")),
            Element(pt),
            Element(num_pt("2", "30")),
          ]),
        ),
      ])
      line_with(base_cat, val)
    }
    "numCache" => {
      let cache = catalog_chart_force_children(child, [
        Element(ce("formatCode", [], [Text("0.00")])),
        Element(cv("ptCount", "3")),
        Element(num_pt("0", "10")),
        Element(num_pt("1", "20")),
        Element(num_pt("2", "30")),
      ])
      line_with(base_cat, ce("val", [], [Element(num_ref(cache))]))
    }
    "strRef" => {
      let sr = catalog_chart_force_children(child, [
        Element(ce("f", [], [Text("Sheet1!$A$2:$A$4")])),
        Element(str_cache(["North", "Central", "South"])),
      ])
      line_with(ce("cat", [], [Element(sr)]), base_val)
    }
    "strCache" => {
      let sc = catalog_chart_force_children(child, [
        Element(cv("ptCount", "3")),
        Element(str_pt("0", "North")),
        Element(str_pt("1", "Central")),
        Element(str_pt("2", "South")),
      ])
      line_with(ce("cat", [], [Element(str_ref(sc))]), base_val)
    }
    "strLit" => {
      let sl = catalog_chart_force_children(child, [
        Element(cv("ptCount", "3")),
        Element(str_pt("0", "North")),
        Element(str_pt("1", "Central")),
        Element(str_pt("2", "South")),
      ])
      line_with(ce("cat", [], [Element(sl)]), base_val)
    }
    "multiLvlStrRef" => {
      let mr = catalog_chart_force_children(child, [
        Element(ce("f", [], [Text("Sheet1!$A$2:$B$4")])),
        Element(multi_lvl_cache()),
      ])
      line_with(ce("cat", [], [Element(mr)]), base_val)
    }
    "multiLvlStrCache" => {
      let mc = catalog_chart_force_children(child, [
        Element(cv("ptCount", "3")),
        Element(
          ce("lvl", [], [
            Element(str_pt("0", "North")),
            Element(str_pt("1", "North")),
            Element(str_pt("2", "South")),
          ]),
        ),
      ])
      line_with(ce("cat", [], [Element(multi_lvl_ref(mc))]), base_val)
    }
    "lvl" => {
      let lvl = catalog_chart_force_children(child, [
        Element(str_pt("0", "North")),
        Element(str_pt("1", "North")),
        Element(str_pt("2", "South")),
      ])
      let mc = ce("multiLvlStrCache", [], [
        Element(cv("ptCount", "3")),
        Element(lvl),
        Element(
          ce("lvl", [], [
            Element(str_pt("0", "Q1")),
            Element(str_pt("1", "Q2")),
            Element(str_pt("2", "Q3")),
          ]),
        ),
      ])
      line_with(ce("cat", [], [Element(multi_lvl_ref(mc))]), base_val)
    }
    "xVal" => {
      let xv = catalog_chart_force_children(child, [
        Element(num_lit(["1", "2", "3"], "General")),
      ])
      let bs = ce("bubbleSize", [], [Element(num_lit(["4", "9", "16"], "0.00"))])
      bubble_root(bubble_ser(xv, bs))
    }
    "bubbleSize" => {
      let bs = catalog_chart_force_children(child, [
        Element(num_lit(["4", "9", "16"], "0.00")),
      ])
      let xv = ce("xVal", [], [Element(num_lit(["1", "2", "3"], "General"))])
      bubble_root(bubble_ser(xv, bs))
    }
    "tx" =>
      if type_local == "CT_Tx" {
        let tx = catalog_chart_force_children(child, [
          Element(ce("rich", [], c_text_body("Chart Source Title"))),
        ])
        line_root(
          line_ser(base_tx, base_cat, base_val),
          Some(ce("title", [], [Element(tx)])),
        )
      } else {
        let tx = catalog_chart_force_children(child, [
          Element(str_ref(str_cache(["Series Source"]))),
        ])
        line_with_tx(tx)
      }
    "rich" => {
      let rich = catalog_chart_force_children(
        child,
        c_text_body("Rich Source Title"),
      )
      let tx = ce("tx", [], [Element(rich)])
      line_root(
        line_ser(base_tx, base_cat, base_val),
        Some(ce("title", [], [Element(tx)])),
      )
    }
    _ => line_with(base_cat, base_val)
  }
}

///|
/// Catalog host for chart-space `<c:txPr>`. The target carries the
/// DrawingML default run properties consumed by `read_chart_style_defaults`;
/// pruning it returns title / axis / data-label text to theme/default
/// styling, giving a real visible diff without drawing debug marks.
fn catalog_chart_tx_pr_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_pt = fn(idx : String, value : String) -> @xml.Element {
    ce("pt", [xa("idx", idx)], [Element(ce("v", [], [Text(value)]))])
  }
  let num_pt = fn(idx : String, value : String) -> @xml.Element {
    ce("pt", [xa("idx", idx)], [Element(ce("v", [], [Text(value)]))])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(Element(str_pt(i.to_string(), v)))
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(Element(num_pt(i.to_string(), v)))
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Styled Series")]))])),
    Element(ce("cat", [], [Element(str_lit(["North", "Central", "South"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "25", "18"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(
      ce("dLbls", [], [
        Element(cv("showVal", "1")),
        Element(cv("showCatName", "1")),
      ]),
    ),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
  ])
  let title = ce("title", [], [
    Element(ce("tx", [], [Element(c_rich_text("Styled Chart"))])),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(title),
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
    Element(c_tx_pr_defaults(child, "C00000", "Catalog Chart Face")),
  ])
}

///|
/// Catalog host for chart-space `<c:clrMapOvr>`. The target remaps
/// `accent1` to `accent2`; the chart's default first-series colour is
/// resolved through that same paint context, so pruning the target
/// returns the series stroke/fill to `accent1`.
fn catalog_chart_color_map_override_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let target_attrs : Array[@xml.Attribute] = []
  let mut saw_bg1 = false
  let mut saw_tx1 = false
  let mut saw_bg2 = false
  let mut saw_tx2 = false
  let mut saw_accent1 = false
  let mut saw_accent2 = false
  let mut saw_accent3 = false
  let mut saw_accent4 = false
  let mut saw_accent5 = false
  let mut saw_accent6 = false
  let mut saw_hlink = false
  let mut saw_fol_hlink = false
  for attr in child.attributes {
    match attr.name.local_name {
      "bg1" => {
        saw_bg1 = true
        target_attrs.push({ name: attr.name, value: "lt1" })
      }
      "tx1" => {
        saw_tx1 = true
        target_attrs.push({ name: attr.name, value: "dk1" })
      }
      "bg2" => {
        saw_bg2 = true
        target_attrs.push({ name: attr.name, value: "lt2" })
      }
      "tx2" => {
        saw_tx2 = true
        target_attrs.push({ name: attr.name, value: "dk2" })
      }
      "accent1" => {
        saw_accent1 = true
        target_attrs.push({ name: attr.name, value: "accent2" })
      }
      "accent2" => {
        saw_accent2 = true
        target_attrs.push({ name: attr.name, value: "accent2" })
      }
      "accent3" => {
        saw_accent3 = true
        target_attrs.push({ name: attr.name, value: "accent3" })
      }
      "accent4" => {
        saw_accent4 = true
        target_attrs.push({ name: attr.name, value: "accent4" })
      }
      "accent5" => {
        saw_accent5 = true
        target_attrs.push({ name: attr.name, value: "accent5" })
      }
      "accent6" => {
        saw_accent6 = true
        target_attrs.push({ name: attr.name, value: "accent6" })
      }
      "hlink" => {
        saw_hlink = true
        target_attrs.push({ name: attr.name, value: "hlink" })
      }
      "folHlink" => {
        saw_fol_hlink = true
        target_attrs.push({ name: attr.name, value: "folHlink" })
      }
      _ => target_attrs.push(attr)
    }
  }
  if !saw_bg1 {
    target_attrs.push(xa("bg1", "lt1"))
  }
  if !saw_tx1 {
    target_attrs.push(xa("tx1", "dk1"))
  }
  if !saw_bg2 {
    target_attrs.push(xa("bg2", "lt2"))
  }
  if !saw_tx2 {
    target_attrs.push(xa("tx2", "dk2"))
  }
  if !saw_accent1 {
    target_attrs.push(xa("accent1", "accent2"))
  }
  if !saw_accent2 {
    target_attrs.push(xa("accent2", "accent2"))
  }
  if !saw_accent3 {
    target_attrs.push(xa("accent3", "accent3"))
  }
  if !saw_accent4 {
    target_attrs.push(xa("accent4", "accent4"))
  }
  if !saw_accent5 {
    target_attrs.push(xa("accent5", "accent5"))
  }
  if !saw_accent6 {
    target_attrs.push(xa("accent6", "accent6"))
  }
  if !saw_hlink {
    target_attrs.push(xa("hlink", "hlink"))
  }
  if !saw_fol_hlink {
    target_attrs.push(xa("folHlink", "folHlink"))
  }
  let target : @xml.Element = {
    name: child.name,
    attributes: target_attrs,
    children: child.children,
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "30", "20"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(target),
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for trendline options that are consumed by the chart
/// renderer.  The target is placed under a line-series `<c:trendline>`
/// so pruning it changes the fitted polyline or the equation label.
fn catalog_chart_trendline_option_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let trendline = match child.name.local_name {
    "trendline" =>
      catalog_chart_force_children(child, [
        Element(cv("trendlineType", "poly")),
        Element(cv("order", "3")),
        Element(cv("dispEq", "1")),
      ])
    "trendlineType" =>
      ce("trendline", [], [
        Element(catalog_chart_marker_force_val(child, "movingAvg")),
        Element(cv("period", "3")),
      ])
    "order" =>
      ce("trendline", [], [
        Element(cv("trendlineType", "poly")),
        Element(catalog_chart_marker_force_val(child, "3")),
      ])
    "period" =>
      ce("trendline", [], [
        Element(cv("trendlineType", "movingAvg")),
        Element(catalog_chart_marker_force_val(child, "3")),
      ])
    "forward" =>
      ce("trendline", [], [
        Element(cv("trendlineType", "linear")),
        Element(catalog_chart_marker_force_val(child, "1.5")),
      ])
    "backward" =>
      ce("trendline", [], [
        Element(cv("trendlineType", "linear")),
        Element(catalog_chart_marker_force_val(child, "0.5")),
      ])
    "intercept" =>
      ce("trendline", [], [
        Element(cv("trendlineType", "linear")),
        Element(catalog_chart_marker_force_val(child, "0")),
      ])
    "dispEq" | "dispRSqr" =>
      ce("trendline", [], [
        Element(cv("trendlineType", "poly")),
        Element(cv("order", "3")),
        Element(catalog_chart_marker_force_val(child, "1")),
      ])
    _ => ce("trendline", [], [Element(child)])
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Trendline")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D", "E"]))])),
    Element(ce("val", [], [Element(num_lit(["4", "9", "15", "25", "38"]))])),
    Element(trendline),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for CT_ErrBars and its consumed children.  The chart
/// renderer reads direction, bar type, value type, noEndCap, plus,
/// minus, and val from this exact series branch.
fn catalog_chart_error_bars_option_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let custom_source = fn(values : Array[String]) -> @xml.Element {
    ce("numLit", [], num_lit(values).children)
  }
  let err_bars = match child.name.local_name {
    "errBars" =>
      catalog_chart_force_children(child, [
        Element(cv("errDir", "y")),
        Element(cv("errBarType", "plus")),
        Element(cv("errValType", "fixedVal")),
        Element(cv("val", "8")),
      ])
    "errDir" =>
      ce("errBars", [], [
        Element(catalog_chart_marker_force_val(child, "x")),
        Element(cv("errBarType", "both")),
        Element(cv("errValType", "fixedVal")),
        Element(cv("val", "8")),
      ])
    "errBarType" =>
      ce("errBars", [], [
        Element(cv("errDir", "y")),
        Element(catalog_chart_marker_force_val(child, "plus")),
        Element(cv("errValType", "fixedVal")),
        Element(cv("val", "8")),
      ])
    "errValType" =>
      ce("errBars", [], [
        Element(cv("errDir", "y")),
        Element(cv("errBarType", "both")),
        Element(catalog_chart_marker_force_val(child, "percentage")),
        Element(cv("val", "40")),
      ])
    "noEndCap" =>
      ce("errBars", [], [
        Element(cv("errDir", "y")),
        Element(cv("errBarType", "both")),
        Element(cv("errValType", "fixedVal")),
        Element(catalog_chart_marker_force_val(child, "1")),
        Element(cv("val", "8")),
      ])
    "plus" =>
      ce("errBars", [], [
        Element(cv("errDir", "y")),
        Element(cv("errBarType", "both")),
        Element(cv("errValType", "cust")),
        Element(
          catalog_chart_force_children(child, [
            Element(custom_source(["8", "4", "12"])),
          ]),
        ),
        Element(cv("val", "3")),
      ])
    "minus" =>
      ce("errBars", [], [
        Element(cv("errDir", "y")),
        Element(cv("errBarType", "both")),
        Element(cv("errValType", "cust")),
        Element(
          catalog_chart_force_children(child, [
            Element(custom_source(["5", "9", "4"])),
          ]),
        ),
        Element(cv("val", "3")),
      ])
    "val" =>
      ce("errBars", [], [
        Element(cv("errDir", "y")),
        Element(cv("errBarType", "both")),
        Element(cv("errValType", "fixedVal")),
        Element(catalog_chart_marker_force_val(child, "8")),
      ])
    _ => ce("errBars", [], [Element(child)])
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Error bars")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
    Element(err_bars),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for CT_UpDownBars and its consumed children.  The
/// target sits in the canonical lineChart position after `ser*` and
/// before marker/axId, where `render_up_down_bars` reads it.
fn catalog_chart_up_down_bars_option_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let sp_pr_solid = fn(hex : String) -> @xml.Element {
    ce("spPr", [], [
      Element(
        xe(NS_A, "solidFill", [], [
          Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
        ]),
      ),
    ])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let up_bars = match child.name.local_name {
    "upBars" =>
      catalog_chart_force_children(child, [Element(sp_pr_solid("00B050"))])
    _ => ce("upBars", [], [Element(sp_pr_solid("00B050"))])
  }
  let down_bars = match child.name.local_name {
    "downBars" =>
      catalog_chart_force_children(child, [Element(sp_pr_solid("C00000"))])
    _ => ce("downBars", [], [Element(sp_pr_solid("C00000"))])
  }
  let gap_width = match child.name.local_name {
    "gapWidth" => catalog_chart_marker_force_val(child, "25%")
    _ => cv("gapWidth", "25%")
  }
  let up_down_bars = match child.name.local_name {
    "upDownBars" =>
      catalog_chart_force_children(child, [
        Element(gap_width),
        Element(up_bars),
        Element(down_bars),
      ])
    "gapWidth" | "upBars" | "downBars" =>
      ce("upDownBars", [], [
        Element(gap_width),
        Element(up_bars),
        Element(down_bars),
      ])
    _ => ce("upDownBars", [], [Element(child)])
  }
  let ser = fn(
    idx : String,
    name : String,
    values : Array[String],
  ) -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", idx)),
      Element(cv("order", idx)),
      Element(ce("tx", [], [Element(ce("v", [], [Text(name)]))])),
      Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
      Element(ce("val", [], [Element(num_lit(values))])),
    ])
  }
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser("0", "Open", ["10", "22", "18"])),
    Element(ser("1", "Close", ["15", "16", "30"])),
    Element(up_down_bars),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
        Element(cv("crosses", "autoZero")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for chart-level CT_Title.  The renderer consumes the
/// title text directly under `<c:chart>/<c:title>`.
fn catalog_chart_title_root(title : @xml.Element) -> @xml.Element {
  let ns_c = title.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let rich = ce("rich", [], c_text_body("Catalog Chart Title"))
  let target = catalog_chart_force_children(title, [
    Element(ce("tx", [], [Element(rich)])),
    Element(cv("overlay", "0")),
  ])
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let bar_chart = ce("barChart", [], [
    Element(cv("barDir", "col")),
    Element(cv("grouping", "clustered")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bar_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(target),
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.7 autoTitleDeleted. The renderer consumes
/// this boolean while resolving chart title text; pruning the target
/// restores the title strip and title text.
fn catalog_chart_auto_title_deleted_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let title = ce("title", [], [
    Element(ce("tx", [], [Element(c_rich_text("Deleted Title"))])),
    Element(cv("overlay", "0")),
  ])
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let bar_chart = ce("barChart", [], [
    Element(cv("barDir", "col")),
    Element(cv("grouping", "clustered")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bar_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(title),
        Element(catalog_chart_marker_force_val(child, "1")),
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.206 showDLblsOverMax. The fixture gives
/// the value axis an explicit max below one data point; pruning the
/// target returns the absent/default-false behaviour and suppresses
/// that point's value label.
fn catalog_chart_show_data_labels_over_max_root(
  child : @xml.Element,
) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["Low", "Over", "Mid"]))])),
    Element(ce("val", [], [Element(num_lit(["20", "60", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(
      ce("dLbls", [], [
        Element(cv("showVal", "1")),
        Element(cv("showCatName", "0")),
        Element(cv("showSerName", "0")),
      ]),
    ),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(
          ce("scaling", [], [
            Element(cv("max", "40")),
            Element(cv("orientation", "minMax")),
          ]),
        ),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
        Element(catalog_chart_marker_force_val(child, "1")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.46 dispBlanksAs.  A sparse numeric cache
/// makes `gap` visibly different from the default zero fill.
fn catalog_chart_disp_blanks_root(disp : @xml.Element) -> @xml.Element {
  let ns_c = disp.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let sparse_num_lit = fn() -> @xml.Element {
    ce("numLit", [], [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", "3")),
      Element(ce("pt", [xa("idx", "0")], [Element(ce("v", [], [Text("10")]))])),
      Element(ce("pt", [xa("idx", "2")], [Element(ce("v", [], [Text("30")]))])),
    ])
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(sparse_num_lit())])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(catalog_chart_marker_force_val(disp, "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.104 plotArea `<c:manualLayout>` and its
/// layoutTarget / mode / coordinate children.  Values are deliberately
/// chosen so pruning any target changes the rendered plot rectangle:
/// `layoutTarget="outer"` plus `edge` modes resolves against the full
/// chart frame, while missing modes fall back to factor semantics.
fn catalog_chart_manual_layout_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let title_rich = fn(text : String) -> @xml.Element {
    ce("rich", [], [
      Element(xe(NS_A, "bodyPr", [], [])),
      Element(xe(NS_A, "lstStyle", [], [])),
      Element(
        xe(NS_A, "p", [], [
          Element(
            xe(NS_A, "r", [], [
              Element(xe(NS_A, "rPr", [xa("lang", "en-US")], [])),
              Element(xe(NS_A, "t", [], [Text(text)])),
            ]),
          ),
        ]),
      ),
    ])
  }
  let layout_child = fn(tag : String, value : String) -> @xml.Element {
    if child.name.local_name == tag {
      catalog_chart_marker_force_val(child, value)
    } else {
      cv(tag, value)
    }
  }
  let manual_children : Array[@xml.Node] = [
    Element(layout_child("layoutTarget", "outer")),
    Element(layout_child("xMode", "edge")),
    Element(layout_child("yMode", "edge")),
    Element(layout_child("wMode", "edge")),
    Element(layout_child("hMode", "edge")),
    Element(layout_child("x", "0.12")),
    Element(layout_child("y", "0.18")),
    Element(layout_child("w", "0.76")),
    Element(layout_child("h", "0.82")),
  ]
  let manual : @xml.Element = if child.name.local_name == "manualLayout" {
    {
      name: child.name,
      attributes: child.attributes,
      children: manual_children,
    }
  } else {
    ce("manualLayout", [], manual_children)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Manual Layout")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30", "40"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "l")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [Element(manual)])),
    Element(line_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(
          ce("title", [], [
            Element(ce("tx", [], [Element(title_rich("Manual"))])),
            Element(cv("overlay", "0")),
          ]),
        ),
        Element(plot_area),
        Element(
          ce("legend", [], [
            Element(cv("legendPos", "r")),
            Element(cv("overlay", "0")),
          ]),
        ),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.170 `<c:min>` on a real value-axis scale.
/// Scatter/bubble charts own two independent `<c:valAx>` elements, so
/// placing the target on the horizontal axis makes pruning the minimum
/// visibly change point coordinates instead of only parsing the axis.
fn catalog_chart_value_axis_min_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("xVal", [], [Element(num_lit(["1", "2", "3", "4"]))])),
    Element(ce("yVal", [], [Element(num_lit(["10", "20", "30", "40"]))])),
  ])
  let scatter_chart = ce("scatterChart", [], [
    Element(cv("scatterStyle", "lineMarker")),
    Element(cv("varyColors", "0")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let x_axis = ce("valAx", [], [
    Element(cv("axId", "111111111")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(catalog_chart_marker_force_val(child, "1")),
      ]),
    ),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
    Element(cv("majorUnit", "1")),
  ])
  let y_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
    Element(cv("majorUnit", "10")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(scatter_chart),
    Element(x_axis),
    Element(y_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.14 `<c:axPos>` on a scatter chart's
/// vertical value axis. Scatter/bubble charts have two `<c:valAx>`
/// elements, and the renderer uses `axPos` as the source of truth for
/// which one is the horizontal X scale and which one is the vertical
/// Y scale. Pruning the target makes the second axis default to
/// `b`, so its explicit Y scale no longer belongs to the vertical
/// axis and point coordinates visibly change.
fn catalog_chart_axis_position_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("xVal", [], [Element(num_lit(["1", "2", "3", "4"]))])),
    Element(ce("yVal", [], [Element(num_lit(["10", "20", "30", "40"]))])),
  ])
  let scatter_chart = ce("scatterChart", [], [
    Element(cv("scatterStyle", "lineMarker")),
    Element(cv("varyColors", "0")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let x_axis = ce("valAx", [], [
    Element(cv("axId", "111111111")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "4")),
      ]),
    ),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
    Element(cv("majorUnit", "1")),
  ])
  let y_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(catalog_chart_marker_force_val(child, "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
    Element(cv("majorUnit", "10")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(scatter_chart),
    Element(x_axis),
    Element(y_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.9 `<c:axId>` on a chart type.  The
/// chart renderer filters plot-area axes through this chart-local
/// reference list; pruning the target drops the value axis from the
/// line chart's resolved axis set.
fn catalog_chart_axis_id_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(catalog_chart_marker_force_val(child, "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "333333333")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.31 `<c:crossAx>`.  The target catAxis
/// crosses an alternate value axis with a different scale.  Pruning
/// the target returns the chart to the value axis named by the chart
/// type's `<c:axId>` list.
fn catalog_chart_axis_cross_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(catalog_chart_marker_force_val(child, "333333333")),
    Element(cv("crosses", "autoZero")),
  ])
  let alt_val_axis = ce("valAx", [], [
    Element(cv("axId", "333333333")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "400")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(cat_axis),
    Element(alt_val_axis),
    Element(val_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.6 `<c:auto>` (Automatic Category Axis).
/// A category axis with numeric category data and `auto=true` follows
/// the date-label path; pruning it leaves the same numeric cache as
/// literal category labels.
fn catalog_chart_axis_auto_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(num_lit(["45292", "45306", "45323"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
    Element(catalog_chart_marker_force_val(child, "1")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for date-axis units and chartSpace date system. The
/// renderer consumes these through `ChartAxesInfo` and
/// `chart_space_date_system`; pruning the target changes date labels,
/// tick buckets, or serial coordinates.
fn catalog_chart_date_axis_unit_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let num_lit = fn(values : Array[String], fmt : String) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text(fmt)])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let serials = match child.name.local_name {
    "minorTimeUnit" => ["45292", "45306", "45323"]
    "date1904" => ["1", "32", "60"]
    _ => ["45292", "45306", "45323"]
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(num_lit(serials, "m/d/yyyy"))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"], "General"))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let mut base_time_unit = cv("baseTimeUnit", "days")
  let mut major_time_unit : @xml.Element? = None
  let mut minor_time_unit : @xml.Element? = None
  match child.name.local_name {
    "baseTimeUnit" =>
      base_time_unit = catalog_chart_marker_force_val(child, "months")
    "majorTimeUnit" => {
      base_time_unit = cv("baseTimeUnit", "months")
      major_time_unit = Some(catalog_chart_marker_force_val(child, "years"))
    }
    "minorTimeUnit" => {
      base_time_unit = cv("baseTimeUnit", "months")
      major_time_unit = Some(cv("majorTimeUnit", "years"))
      minor_time_unit = Some(catalog_chart_marker_force_val(child, "days"))
    }
    _ => ()
  }
  let date_axis_kids : Array[@xml.Node] = [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("minorTickMark", "in")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
    Element(base_time_unit),
  ]
  match major_time_unit {
    Some(e) => date_axis_kids.push(Element(e))
    None => ()
  }
  match minor_time_unit {
    Some(e) => date_axis_kids.push(Element(e))
    None => ()
  }
  let date_axis = ce("dateAx", [], date_axis_kids)
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let chart = ce("chart", [], [
    Element(
      ce("plotArea", [], [
        Element(ce("layout", [], [])),
        Element(line_chart),
        Element(date_axis),
        Element(val_axis),
      ]),
    ),
    Element(cv("plotVisOnly", "1")),
    Element(cv("dispBlanksAs", "gap")),
  ])
  let kids : Array[@xml.Node] = []
  if child.name.local_name == "date1904" {
    kids.push(Element(catalog_chart_marker_force_val(child, "1")))
  }
  kids.push(Element(chart))
  ce("chartSpace", [], kids)
}

///|
/// Catalog host for §21.2.2.119 noMultiLvlLbl. A multi-level category
/// cache renders hierarchical labels by default; the target collapses
/// labels to the final level.
fn catalog_chart_no_multi_level_labels_root(
  child : @xml.Element,
) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_pt = fn(idx : String, value : String) -> @xml.Element {
    ce("pt", [xa("idx", idx)], [Element(ce("v", [], [Text(value)]))])
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let multi_level = ce("multiLvlStrRef", [], [
    Element(ce("f", [], [Text("Sheet1!$A$2:$B$4")])),
    Element(
      ce("multiLvlStrCache", [], [
        Element(cv("ptCount", "3")),
        Element(
          ce("lvl", [], [
            Element(str_pt("0", "North")),
            Element(str_pt("1", "North")),
            Element(str_pt("2", "South")),
          ]),
        ),
        Element(
          ce("lvl", [], [
            Element(str_pt("0", "Q1")),
            Element(str_pt("1", "Q2")),
            Element(str_pt("2", "Q3")),
          ]),
        ),
      ]),
    ),
  ])
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(multi_level)])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
    Element(catalog_chart_marker_force_val(child, "1")),
  ])
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(
          ce("plotArea", [], [
            Element(ce("layout", [], [])),
            Element(line_chart),
            Element(cat_axis),
            Element(val_axis),
          ]),
        ),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.99 / §21.2.2.105 value-axis gridlines.
/// The renderer emits concrete SVG line elements only when the axis
/// carries the corresponding CT_ChartLines child.
fn catalog_chart_axis_gridlines_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cv("majorTickMark", "out")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_axis_kids : Array[@xml.Node] = [
    Element(cv("axId", "222222222")),
    Element(
      ce("scaling", [], [
        Element(cv("orientation", "minMax")),
        Element(cv("max", "40")),
      ]),
    ),
    Element(cv("axPos", "l")),
    Element(cv("majorTickMark", "out")),
    Element(cv("minorTickMark", "none")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
    Element(cv("majorUnit", "10")),
    Element(cv("minorUnit", "5")),
  ]
  match child.name.local_name {
    "majorGridlines" => val_axis_kids.insert(2, Element(child))
    "minorGridlines" => val_axis_kids.insert(2, Element(child))
    _ => val_axis_kids.insert(2, Element(child))
  }
  let val_axis = ce("valAx", [], val_axis_kids)
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for axis options already consumed by the chart axis
/// renderer.  The target is placed on the axis kind where that option
/// changes labels, tick marks, crossing, or scaling.
fn catalog_chart_axis_option_root(child : @xml.Element) -> @xml.Element {
  if child.name.local_name == "min" {
    return catalog_chart_value_axis_min_root(child)
  }
  if child.name.local_name == "axPos" {
    return catalog_chart_axis_position_root(child)
  }
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let cat_major = match child.name.local_name {
    "majorTickMark" => catalog_chart_marker_force_val(child, "none")
    _ => cv("majorTickMark", "out")
  }
  let cat_minor = match child.name.local_name {
    _ => cv("minorTickMark", "none")
  }
  let cat_tick_skip = match child.name.local_name {
    "tickLblSkip" => catalog_chart_marker_force_val(child, "2")
    _ => cv("tickLblSkip", "1")
  }
  let cat_mark_skip = match child.name.local_name {
    "tickMarkSkip" => catalog_chart_marker_force_val(child, "2")
    _ => cv("tickMarkSkip", "1")
  }
  let cat_lbl_algn = match child.name.local_name {
    "lblAlgn" => catalog_chart_marker_force_val(child, "l")
    _ => cv("lblAlgn", "ctr")
  }
  let cat_lbl_offset = match child.name.local_name {
    "lblOffset" => catalog_chart_marker_force_val(child, "200")
    _ => cv("lblOffset", "100")
  }
  let val_crosses = match child.name.local_name {
    "crosses" => catalog_chart_marker_force_val(child, "max")
    _ => cv("crosses", "autoZero")
  }
  let val_cross_between = match child.name.local_name {
    "crossBetween" => catalog_chart_marker_force_val(child, "midCat")
    _ => cv("crossBetween", "between")
  }
  let val_minor = match child.name.local_name {
    "minorTickMark" => catalog_chart_marker_force_val(child, "none")
    "minorUnit" => cv("minorTickMark", "in")
    _ => cv("minorTickMark", "none")
  }
  let val_major_unit = match child.name.local_name {
    "majorUnit" => catalog_chart_marker_force_val(child, "20")
    _ => cv("majorUnit", "10")
  }
  let val_minor_unit = match child.name.local_name {
    "minorUnit" => catalog_chart_marker_force_val(child, "20")
    _ => cv("minorUnit", "5")
  }
  let val_scaling_kids : Array[@xml.Node] = [
    Element(cv("orientation", "minMax")),
  ]
  if child.name.local_name == "min" {
    val_scaling_kids.push(Element(catalog_chart_marker_force_val(child, "5")))
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30", "40"]))])),
  ])
  let line_chart = ce("lineChart", [], [
    Element(cv("grouping", "standard")),
    Element(ser),
    Element(cv("marker", "1")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let cat_axis = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("axPos", "b")),
    Element(cat_major),
    Element(cat_minor),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
    Element(cat_lbl_algn),
    Element(cat_lbl_offset),
    Element(cat_tick_skip),
    Element(cat_mark_skip),
  ])
  let val_ax_pos = match child.name.local_name {
    "axPos" => catalog_chart_marker_force_val(child, "l")
    _ => cv("axPos", "l")
  }
  let val_axis = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], val_scaling_kids)),
    Element(val_ax_pos),
    Element(cv("majorTickMark", "out")),
    Element(val_minor),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(val_crosses),
    Element(val_cross_between),
    Element(val_major_unit),
    Element(val_minor_unit),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(line_chart),
    Element(cat_axis),
    Element(val_axis),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for bar-series visual options consumed by
/// render_bar_chart: grouping, overlap, invertIfNegative, and
/// per-point dPt fill.
fn catalog_chart_bar_series_option_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let sp_pr_solid = fn(hex : String) -> @xml.Element {
    ce("spPr", [], [
      Element(
        xe(NS_A, "solidFill", [], [
          Element(xe(NS_A, "srgbClr", [xa("val", hex)], [])),
        ]),
      ),
    ])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let dpt = match child.name.local_name {
    "dPt" =>
      catalog_chart_force_children(child, [
        Element(cv("idx", "1")),
        Element(sp_pr_solid("FF0000")),
      ])
    _ =>
      ce("dPt", [], [Element(cv("idx", "1")), Element(sp_pr_solid("FF0000"))])
  }
  let ser = fn(
    idx : String,
    values : Array[String],
    with_dpt : Bool,
  ) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("idx", idx)),
      Element(cv("order", idx)),
      Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
      Element(ce("val", [], [Element(num_lit(values))])),
    ]
    if child.name.local_name == "invertIfNegative" && idx == "0" {
      kids.insert(2, Element(sp_pr_solid("112233")))
      kids.insert(3, Element(catalog_chart_marker_force_val(child, "1")))
    }
    if with_dpt {
      kids.insert(2, Element(dpt))
    }
    ce("ser", [], kids)
  }
  let grouping = match child.name.local_name {
    "grouping" => catalog_chart_marker_force_val(child, "stacked")
    _ => cv("grouping", "clustered")
  }
  let overlap = match child.name.local_name {
    "overlap" => catalog_chart_marker_force_val(child, "100%")
    _ => cv("overlap", "0%")
  }
  let first_values = match child.name.local_name {
    "invertIfNegative" => ["10", "-5", "15"]
    _ => ["10", "20", "30"]
  }
  let bar_chart = ce("barChart", [], [
    Element(cv("barDir", "col")),
    Element(grouping),
    Element(ser("0", first_values, child.name.local_name == "dPt")),
    Element(ser("1", ["8", "12", "16"], false)),
    Element(cv("gapWidth", "150%")),
    Element(overlap),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bar_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.75 `<c:gapDepth>` on bar3DChart. The
/// flattened bar3D renderer consumes it as in-cluster series spacing.
fn catalog_chart_bar3d_gap_depth_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = fn(idx : String, values : Array[String]) -> @xml.Element {
    ce("ser", [], [
      Element(cv("idx", idx)),
      Element(cv("order", idx)),
      Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
      Element(ce("val", [], [Element(num_lit(values))])),
    ])
  }
  let bar_chart = ce("bar3DChart", [], [
    Element(cv("barDir", "col")),
    Element(cv("grouping", "clustered")),
    Element(ser("0", ["10", "20", "30"])),
    Element(ser("1", ["15", "25", "35"])),
    Element(catalog_chart_marker_force_val(child, "400%")),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bar_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.128 `<c:order>` on chart series. The bar
/// renderer sorts series by this value before plotting clustered bars.
fn catalog_chart_bar_series_order_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser_a = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(catalog_chart_marker_force_val(child, "1")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["10", "20", "30"]))])),
  ])
  let ser_b = ce("ser", [], [
    Element(cv("idx", "1")),
    Element(cv("order", "0")),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C"]))])),
    Element(ce("val", [], [Element(num_lit(["30", "20", "10"]))])),
  ])
  let bar_chart = ce("barChart", [], [
    Element(cv("barDir", "col")),
    Element(cv("grouping", "clustered")),
    Element(ser_a),
    Element(ser_b),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(bar_chart),
    Element(
      ce("catAx", [], [
        Element(cv("axId", "111111111")),
        Element(cv("axPos", "b")),
        Element(cv("crossAx", "222222222")),
      ]),
    ),
    Element(
      ce("valAx", [], [
        Element(cv("axId", "222222222")),
        Element(cv("axPos", "l")),
        Element(cv("crossAx", "111111111")),
      ]),
    ),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
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
  ccases.push({
    id: "rich-options-3d",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar 3D Rich Options")]),
    chart_space: wrap_chart_space_with_rich_options(
      bar3d_chart_rich_payload(),
      c_axes_rich(),
    ),
  })
  ccases.push({
    id: "rare-series-options",
    format: "pptx",
    category: "chart/bar",
    content: sp_tree([chart_graphic_frame("2", "Bar Rare Series Options")]),
    chart_space: wrap_chart_space(bar_chart_rare_payload(), c_axes()),
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
  ccases.push({
    id: "rare-options",
    format: "pptx",
    category: "chart/line",
    content: sp_tree([chart_graphic_frame("2", "Line Rare Options")]),
    chart_space: wrap_chart_space_with_pivot_options(
      line_chart_rare_payload(),
      c_axes_date_value_series(),
    ),
  })
  ccases.push({
    id: "3d",
    format: "pptx",
    category: "chart/line",
    content: sp_tree([chart_graphic_frame("2", "Line 3D")]),
    chart_space: wrap_chart_space(
      line3d_chart_payload(),
      c_axes_date_value_series(),
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
  ccases.push({
    id: "3d",
    format: "pptx",
    category: "chart/pie",
    content: sp_tree([chart_graphic_frame("2", "Pie 3D")]),
    chart_space: wrap_chart_space(pie3d_chart_payload(), []),
  })
  ccases.push({
    id: "of-pie-rare",
    format: "pptx",
    category: "chart/pie",
    content: sp_tree([chart_graphic_frame("2", "Of Pie Rare")]),
    chart_space: wrap_chart_space(of_pie_chart_rare_payload(), []),
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
  ccases.push({
    id: "3d",
    format: "pptx",
    category: "chart/area",
    content: sp_tree([chart_graphic_frame("2", "Area 3D")]),
    chart_space: wrap_chart_space(
      area3d_chart_payload(),
      c_axes_date_value_series(),
    ),
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
  ccases.push({
    id: "rich-options",
    format: "pptx",
    category: "chart/bubble",
    content: sp_tree([chart_graphic_frame("2", "Bubble Rich Options")]),
    chart_space: wrap_chart_space(bubble_chart_rich_payload(), c_axes_num()),
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

  // ---- surface charts (§21.2.2.205 / §21.2.2.206) --------------
  ccases.push({
    id: "basic",
    format: "pptx",
    category: "chart/surface",
    content: sp_tree([chart_graphic_frame("2", "Surface Chart")]),
    chart_space: wrap_chart_space(
      surface_chart_payload("surfaceChart"),
      c_axes_date_value_series(),
    ),
  })
  ccases.push({
    id: "3d",
    format: "pptx",
    category: "chart/surface",
    content: sp_tree([chart_graphic_frame("2", "Surface 3D Chart")]),
    chart_space: wrap_chart_space(
      surface_chart_payload("surface3DChart"),
      c_axes_date_value_series(),
    ),
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
/// §21.2.2.15 CT_Bar3DChart — coverage-oriented fixture that
/// combines 3-D bar chart structure with optional data labels,
/// shape, gap depth, and rich chart/axis options from
/// `wrap_chart_space_with_rich_options`.
fn bar3d_chart_rich_payload() -> @xml.Element {
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
  c_elem("bar3DChart", [], [
    Element(c_val("barDir", "col")),
    Element(c_val("grouping", "clustered")),
    Element(c_val("varyColors", "0")),
    Element(ser_a),
    Element(ser_b),
    Element(c_data_labels()),
    Element(c_val("gapWidth", "120%")),
    Element(c_val("gapDepth", "80%")),
    Element(c_val("shape", "box")),
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
/// §21.2.2.97 — line chart variant carrying rare series-side
/// branches plus high-low and up/down bars.
fn line_chart_rare_payload() -> @xml.Element {
  let ser_plan = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Plan")),
    Element(c_sp_pr_solid("D9EAF7")),
    Element(c_marker("circle", "6", "4472C4")),
    Element(c_dpt_solid_fill(1, "A9D18E")),
    Element(c_data_labels_with_text()),
    Element(c_trendline_rich()),
    Element(c_err_bars_custom("y")),
    Element(c_cat_multi_level()),
    Element(c_elem("val", [], [Element(c_num_lit(["10", "16", "14", "22"]))])),
    Element(c_val("smooth", "1")),
    Element(c_ext_lst()),
  ])
  let ser_actual = c_elem("ser", [], [
    Element(c_val("idx", "1")),
    Element(c_val("order", "1")),
    Element(c_series_tx("Actual")),
    Element(c_marker("square", "6", "ED7D31")),
    Element(c_cat(["Q1", "Q2", "Q3", "Q4"])),
    Element(c_val_ref(["12", "18", "15", "25"])),
    Element(c_val("smooth", "0")),
  ])
  c_elem("lineChart", [], [
    Element(c_val("grouping", "standard")),
    Element(c_val("varyColors", "0")),
    Element(ser_plan),
    Element(ser_actual),
    Element(c_data_labels_with_text()),
    Element(c_chart_lines("dropLines")),
    Element(c_chart_lines("hiLowLines")),
    Element(c_up_down_bars()),
    Element(c_val("marker", "1")),
    Element(c_val("smooth", "0")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.98 CT_Line3DChart — 3-D line with depth axis.
fn line3d_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("3D Trend")),
    Element(c_sp_pr_solid("D9EAF7")),
    Element(c_marker("triangle", "6", "70AD47")),
    Element(c_data_labels_with_text()),
    Element(c_trendline_rich()),
    Element(c_err_bars_custom("y")),
    Element(c_cat_multi_level()),
    Element(c_elem("val", [], [Element(c_num_lit(["10", "16", "14", "22"]))])),
    Element(c_val("smooth", "0")),
  ])
  c_elem("line3DChart", [], [
    Element(c_val("grouping", "standard")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_data_labels_with_text()),
    Element(c_chart_lines("dropLines")),
    Element(c_val("gapDepth", "80%")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
    Element(c_val("axId", "333333333")),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.5 CT_Area3DChart — 3-D area with a depth axis.
fn area3d_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Revenue")),
    Element(c_sp_pr_solid("BDD7EE")),
    Element(c_data_labels_with_text()),
    Element(c_trendline_rich()),
    Element(c_err_bars_custom("y")),
    Element(c_cat_multi_level()),
    Element(c_elem("val", [], [Element(c_num_lit(["12", "18", "15", "22"]))])),
  ])
  c_elem("area3DChart", [], [
    Element(c_val("grouping", "standard")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_data_labels_with_text()),
    Element(c_chart_lines("dropLines")),
    Element(c_val("gapDepth", "90%")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
    Element(c_val("axId", "333333333")),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.126 CT_OfPieChart — pie-of-pie/bar-of-pie branches.
fn of_pie_chart_rare_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Mix")),
    Element(c_sp_pr_solid("FCE4D6")),
    Element(c_val("explosion", "8")),
    Element(c_dpt_solid_fill(2, "FFD966")),
    Element(c_data_labels_with_text()),
    Element(c_elem("cat", [], [Element(c_str_lit(["A", "B", "C", "D"]))])),
    Element(c_elem("val", [], [Element(c_num_lit(["35", "25", "20", "20"]))])),
    Element(c_ext_lst()),
  ])
  c_elem("ofPieChart", [], [
    Element(c_val("ofPieType", "bar")),
    Element(c_val("varyColors", "1")),
    Element(ser),
    Element(c_data_labels_with_text()),
    Element(c_val("gapWidth", "120%")),
    Element(c_val("splitType", "cust")),
    Element(c_val("splitPos", "2")),
    Element(
      c_elem("custSplit", [], [
        Element(c_val("secondPiePt", "2")),
        Element(c_val("secondPiePt", "3")),
      ]),
    ),
    Element(c_val("secondPieSize", "80%")),
    Element(c_chart_lines("serLines")),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.138 CT_Pie3DChart — 3-D pie sibling of ordinary pie.
fn pie3d_chart_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Mix 3D")),
    Element(c_val("explosion", "6")),
    Element(c_elem("cat", [], [Element(c_str_lit(["A", "B", "C", "D"]))])),
    Element(c_elem("val", [], [Element(c_num_lit(["30", "30", "25", "15"]))])),
  ])
  c_elem("pie3DChart", [], [
    Element(c_val("varyColors", "1")),
    Element(ser),
    Element(c_data_labels_with_text()),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.205 / §21.2.2.206 surface chart payload. The caller
/// chooses `surfaceChart` or `surface3DChart`; both share wireframe,
/// surface series, and band-format branches.
fn surface_chart_payload(tag : String) -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Surface")),
    Element(c_sp_pr_solid("E2F0D9")),
    Element(c_cat_multi_level()),
    Element(c_elem("val", [], [Element(c_num_lit(["5", "9", "7", "12"]))])),
    Element(c_ext_lst()),
  ])
  c_elem(tag, [], [
    Element(c_val("wireframe", "0")),
    Element(ser),
    Element(
      c_elem("bandFmts", [], [
        Element(
          c_elem("bandFmt", [], [
            Element(c_val("idx", "0")),
            Element(c_sp_pr_solid("DDEBF7")),
          ]),
        ),
        Element(
          c_elem("bandFmt", [], [
            Element(c_val("idx", "1")),
            Element(c_sp_pr_solid("FCE4D6")),
          ]),
        ),
      ]),
    ),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
    Element(c_val("axId", "333333333")),
    Element(c_ext_lst()),
  ])
}

///|
/// Catalog host for §21.2.2.223 `<c:wireframe>` on surface charts.
/// The surface renderer consumes it as line-only area geometry; pruning
/// the target restores the filled surface polygons.
fn catalog_chart_surface_wireframe_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Surface")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D"]))])),
    Element(ce("val", [], [Element(num_lit(["5", "9", "7", "12"]))])),
  ])
  let surface_chart = ce("surfaceChart", [], [
    Element(catalog_chart_marker_force_val(child, "1")),
    Element(ser),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
    Element(cv("axId", "333333333")),
  ])
  let cat_ax = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("delete", "0")),
    Element(cv("axPos", "b")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_ax = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("delete", "0")),
    Element(cv("axPos", "l")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let ser_ax = ce("serAx", [], [
    Element(cv("axId", "333333333")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("delete", "0")),
    Element(cv("axPos", "r")),
    Element(cv("tickLblPos", "none")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(surface_chart),
    Element(cat_ax),
    Element(val_ax),
    Element(ser_ax),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// Catalog host for §21.2.2.15 `<c:bandFmt>` and §21.2.2.16
/// `<c:bandFmts>`. Surface band paints resolve through chart spPr fill
/// SoT; pruning the target removes the explicit band fill.
fn catalog_chart_surface_band_format_root(child : @xml.Element) -> @xml.Element {
  let ns_c = child.name.ns.unwrap_or(NS_C)
  let ns_a = if ns_c == "http://purl.oclc.org/ooxml/drawingml/chart" {
    "http://purl.oclc.org/ooxml/drawingml/main"
  } else {
    NS_A
  }
  let ce = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("c", ns_c, tag, attrs, kids)
  }
  let ae = fn(
    tag : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("a", ns_a, tag, attrs, kids)
  }
  let cv = fn(tag : String, value : String) -> @xml.Element {
    ce(tag, [xa("val", value)], [])
  }
  let str_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("strLit", [], kids)
  }
  let num_lit = fn(values : Array[String]) -> @xml.Element {
    let kids : Array[@xml.Node] = [
      Element(ce("formatCode", [], [Text("General")])),
      Element(cv("ptCount", values.length().to_string())),
    ]
    for i, v in values {
      kids.push(
        Element(
          ce("pt", [xa("idx", i.to_string())], [Element(ce("v", [], [Text(v)]))]),
        ),
      )
    }
    ce("numLit", [], kids)
  }
  let sp_pr = ce("spPr", [], [
    Element(
      ae("solidFill", [], [Element(ae("srgbClr", [xa("val", "C00000")], []))]),
    ),
  ])
  let band_fmt = match child.name.local_name {
    "bandFmt" =>
      catalog_chart_force_children(child, [
        Element(cv("idx", "0")),
        Element(sp_pr),
      ])
    _ => ce("bandFmt", [], [Element(cv("idx", "0")), Element(sp_pr)])
  }
  let band_fmts = match child.name.local_name {
    "bandFmts" => catalog_chart_force_children(child, [Element(band_fmt)])
    _ => ce("bandFmts", [], [Element(band_fmt)])
  }
  let ser = ce("ser", [], [
    Element(cv("idx", "0")),
    Element(cv("order", "0")),
    Element(ce("tx", [], [Element(ce("v", [], [Text("Surface")]))])),
    Element(ce("cat", [], [Element(str_lit(["A", "B", "C", "D"]))])),
    Element(ce("val", [], [Element(num_lit(["5", "9", "7", "12"]))])),
  ])
  let surface_chart = ce("surfaceChart", [], [
    Element(cv("wireframe", "0")),
    Element(ser),
    Element(band_fmts),
    Element(cv("axId", "111111111")),
    Element(cv("axId", "222222222")),
    Element(cv("axId", "333333333")),
  ])
  let cat_ax = ce("catAx", [], [
    Element(cv("axId", "111111111")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("delete", "0")),
    Element(cv("axPos", "b")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let val_ax = ce("valAx", [], [
    Element(cv("axId", "222222222")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("delete", "0")),
    Element(cv("axPos", "l")),
    Element(cv("tickLblPos", "nextTo")),
    Element(cv("crossAx", "111111111")),
    Element(cv("crosses", "autoZero")),
  ])
  let ser_ax = ce("serAx", [], [
    Element(cv("axId", "333333333")),
    Element(ce("scaling", [], [Element(cv("orientation", "minMax"))])),
    Element(cv("delete", "0")),
    Element(cv("axPos", "r")),
    Element(cv("tickLblPos", "none")),
    Element(cv("crossAx", "222222222")),
    Element(cv("crosses", "autoZero")),
  ])
  let plot_area = ce("plotArea", [], [
    Element(ce("layout", [], [])),
    Element(surface_chart),
    Element(cat_ax),
    Element(val_ax),
    Element(ser_ax),
  ])
  ce("chartSpace", [], [
    Element(
      ce("chart", [], [
        Element(plot_area),
        Element(cv("plotVisOnly", "1")),
        Element(cv("dispBlanksAs", "gap")),
      ]),
    ),
  ])
}

///|
/// §21.2.2.20 CT_BubbleChart — rich option branches omitted from the
/// canonical bubble fixtures.
fn bubble_chart_rich_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Population")),
    Element(c_val("invertIfNegative", "0")),
    Element(c_dpt_solid_fill(0, "9DC3E6")),
    Element(c_data_labels_with_text()),
    Element(c_trendline_rich()),
    Element(c_err_bars_custom("x")),
    Element(c_elem("xVal", [], [Element(c_num_lit(["1", "3", "5", "7"]))])),
    Element(c_elem("yVal", [], [Element(c_num_lit(["4", "8", "3", "6"]))])),
    Element(
      c_elem("bubbleSize", [], [Element(c_num_lit(["10", "25", "15", "30"]))]),
    ),
    Element(c_val("bubble3D", "1")),
    Element(c_ext_lst()),
  ])
  c_elem("bubbleChart", [], [
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_data_labels_with_text()),
    Element(c_val("bubble3D", "1")),
    Element(c_val("bubbleScale", "120")),
    Element(c_val("showNegBubbles", "1")),
    Element(c_val("sizeRepresents", "w")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
    Element(c_ext_lst()),
  ])
}

///|
/// §21.2.2.16 CT_BarChart — series-side and chart-side rare branches
/// not present in the simple bar fixtures.
fn bar_chart_rare_payload() -> @xml.Element {
  let ser = c_elem("ser", [], [
    Element(c_val("idx", "0")),
    Element(c_val("order", "0")),
    Element(c_series_tx("Variance")),
    Element(c_sp_pr_solid("DDEBF7")),
    Element(c_val("invertIfNegative", "1")),
    Element(
      c_elem("pictureOptions", [], [
        Element(c_val("applyToFront", "1")),
        Element(c_val("applyToSides", "0")),
        Element(c_val("applyToEnd", "0")),
        Element(c_val("pictureFormat", "stretch")),
      ]),
    ),
    Element(c_dpt_solid_fill(2, "FF0000")),
    Element(c_data_labels_with_text()),
    Element(c_trendline_rich()),
    Element(c_err_bars_custom("y")),
    Element(c_elem("cat", [], [Element(c_str_lit(["Q1", "Q2", "Q3", "Q4"]))])),
    Element(c_elem("val", [], [Element(c_num_lit(["10", "-5", "15", "-3"]))])),
    Element(c_val("shape", "cylinder")),
    Element(c_ext_lst()),
  ])
  c_elem("barChart", [], [
    Element(c_val("barDir", "col")),
    Element(c_val("grouping", "clustered")),
    Element(c_val("varyColors", "0")),
    Element(ser),
    Element(c_data_labels_with_text()),
    Element(c_val("gapWidth", "80%")),
    Element(c_val("overlap", "-20")),
    Element(c_chart_lines("serLines")),
    Element(c_val("axId", "111111111")),
    Element(c_val("axId", "222222222")),
    Element(c_ext_lst()),
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
