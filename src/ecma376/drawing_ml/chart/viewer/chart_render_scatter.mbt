// =============================================================================
// §21.2.2.176 CT_ScatterChart — XY point renderer with optional line.
// Reads the first `<c:ser>` and pulls X values from `<c:xVal>` and Y
// values from `<c:yVal>`. The `scatterStyle` attribute decides whether
// to connect points with a line (`lineMarker` / `smoothMarker`) or
// only draw markers (`marker`).
// =============================================================================

///|
fn render_scatter_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : ChartAxesInfo,
  style : ChartStyleDefaults,
) -> Array[@xml.Node] {
  let chart_style = style
  let style = match first_child_named(elem, "scatterStyle") {
    Some(s) => attr_or(s, "val", "marker")
    None => "marker"
  }
  let ser = match first_child_named(elem, "ser") {
    Some(s) => s
    None => return []
  }
  let xs = read_axis_numbers(ser, "xVal")
  let ys = read_axis_numbers(ser, "yVal")
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n == 0 {
    return []
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let max_x = effective_axis_max(max_positive(xs), axes)
  let max_y = effective_axis_max(max_positive(ys), axes)
  // §21.2.2.170 — axis origin defaults to 0 for scatter/bubble.
  let min_x = effective_axis_min(axes)
  let min_y = effective_axis_min(axes)
  let series_color = resolve_series_color(ser, 0, ctx)
  let nodes : Array[@xml.Node] = []
  nodes.push(plot_axes_rect(px, py, pw, ph, style=Some(chart_style)))
  if !axes.val_deleted() {
    for
      tick in y_axis_ticks(
        px,
        py,
        ph,
        max_y,
        pw,
        fw,
        axes.val_major(),
        style=Some(chart_style),
        draw_minor_gridlines=axes.val_minor_gridlines(),
        num_fmt=axes.val_num_fmt(),
        tick_lbl_pos=axes.val_tick_lbl_pos(),
        log_base=axes.val_log_base(),
      ) {
      nodes.push(tick)
    }
  }
  let span_x = if max_x > min_x { max_x - min_x } else { 1.0 }
  let span_y = if max_y > min_y { max_y - min_y } else { 1.0 }
  let to_xy = fn(xi : Double, yi : Double) -> (Double, Double) {
    let x = px + (xi - min_x) / span_x * pw
    let y = py + ph - (yi - min_y) / span_y * ph
    (x, y)
  }
  let draw_line = style == "lineMarker" ||
    style == "smoothMarker" ||
    style == "line" ||
    style == "smooth"
  // §21.2.2.181 ST_ScatterStyle — "smooth"/"smoothMarker" connect the
  // points with a smoothed spline (same Catmull-Rom curve as a line
  // chart's `<c:smooth>`); "line"/"lineMarker" use straight segments.
  let smooth_line = style == "smoothMarker" || style == "smooth"
  if draw_line && smooth_line && n >= 2 {
    let pts : Array[(Double, Double)] = []
    let mut i = 0
    while i < n {
      pts.push(to_xy(xs[i], ys[i]))
      i = i + 1
    }
    nodes.push(
      @markup.elem_ns(
        "path",
        @markup.svg_ns,
        [
          @markup.attr("d", catmull_rom_path(pts)),
          @markup.attr("fill", "none"),
          @markup.attr("stroke", series_color),
          @markup.attr("stroke-width", format_double(h * 0.005)),
          @markup.attr("stroke-linejoin", "round"),
        ],
        [],
      ),
    )
  } else if draw_line {
    let buf = StringBuilder::new()
    let mut first = true
    let mut i = 0
    while i < n {
      let (x, y) = to_xy(xs[i], ys[i])
      if !first {
        buf.write_string(" ")
      }
      buf.write_string(format_double(x))
      buf.write_string(",")
      buf.write_string(format_double(y))
      first = false
      i = i + 1
    }
    nodes.push(
      @markup.elem_ns(
        "polyline",
        @markup.svg_ns,
        [
          @markup.attr("points", buf.to_string()),
          @markup.attr("fill", "none"),
          @markup.attr("stroke", series_color),
          @markup.attr("stroke-width", format_double(h * 0.005)),
          @markup.attr("stroke-linejoin", "round"),
        ],
        [],
      ),
    )
  }
  // §21.2.2.181 scatterStyle val="none" — neither line nor markers are
  // drawn (per ECMA-376 the scatter plot shows only the underlying
  // axes/gridlines).  All other styles emit markers.
  let draw_markers = style != "none"
  if draw_markers {
    let marker_r = h * 0.012
    let mut j = 0
    while j < n {
      let (x, y) = to_xy(xs[j], ys[j])
      nodes.push(
        @markup.elem_ns(
          "circle",
          @markup.svg_ns,
          [
            @markup.attr("cx", format_double(x)),
            @markup.attr("cy", format_double(y)),
            @markup.attr("r", format_double(marker_r)),
            @markup.attr("fill", series_color),
          ],
          [],
        ),
      )
      j = j + 1
    }
  }
  nodes
}
