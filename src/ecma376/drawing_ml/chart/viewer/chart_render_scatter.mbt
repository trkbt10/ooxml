// =============================================================================
// §21.2.2.176 CT_ScatterChart — XY point renderer with optional line.
// Reads each `<c:ser>` and pulls X values from `<c:xVal>` and Y values
// from `<c:yVal>`. The `scatterStyle` attribute decides whether
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
  defs : SvgDefsCollector,
  disp_blanks_as? : @chart.ST_DispBlanksAs = @chart.ST_DispBlanksAs::DispBlanksAsZero,
) -> Array[@xml.Node] {
  let chart_style = style
  let style = match first_child_named(elem, "scatterStyle") {
    Some(s) => attr_or(s, "val", "marker")
    None => "marker"
  }
  let ser_elems = child_elements_named(elem, "ser")
  if !xy_series_has_rendered_points(ser_elems, disp_blanks_as) {
    return []
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let max_x = effective_axis_max(
    xy_series_axis_max(ser_elems, "xVal", disp_blanks_as),
    axes,
  )
  let max_y = effective_axis_max(
    xy_series_axis_max(ser_elems, "yVal", disp_blanks_as),
    axes,
  )
  // §21.2.2.170 — axis origin defaults to 0 for scatter/bubble.
  let min_x = effective_axis_min(axes)
  let min_y = effective_axis_min(axes)
  // §21.2.2.170 CT_Scaling / orientation — the scatter chart has two
  // INDEPENDENT value axes; resolve the horizontal (X) and vertical (Y)
  // reversal flags separately by axPos.
  let val_x_rev = axes.val_x_reversed()
  let val_y_rev = axes.val_y_reversed()
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
        reversed=val_y_rev,
      ) {
      nodes.push(tick)
    }
  }
  // §21.2.2.176 — a scatter chart has TWO value axes (both <c:valAx>,
  // no <c:catAx>), so the X axis is gated on the value-axis deletion
  // flag, NOT cat_deleted() (which is always true here because no
  // category axis exists).  Previously the renderer drew only the Y
  // axis, leaving the X axis with no ticks or scale.
  if !axes.val_deleted() {
    for
      tick in x_axis_ticks(
        px,
        py,
        pw,
        ph,
        max_x,
        fh,
        axes.val_major(),
        style=Some(chart_style),
        reversed=val_x_rev,
      ) {
      nodes.push(tick)
    }
  }
  let span_x = if max_x > min_x { max_x - min_x } else { 1.0 }
  let span_y = if max_y > min_y { max_y - min_y } else { 1.0 }
  // §21.2.2.170 — map a data (x, y) to pixels, flipping each axis's
  // fraction independently when its orientation is maxMin so markers
  // and the per-axis ticks reverse together.
  let to_xy = fn(xi : Double, yi : Double) -> (Double, Double) {
    let fx = span_axis_fraction(xi, min_x, span_x, val_x_rev)
    let fy = span_axis_fraction(yi, min_y, span_y, val_y_rev)
    let x = px + fx * pw
    let y = py + ph - fy * ph
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
  for si in 0..<ser_elems.length() {
    let ser = ser_elems[si]
    let xs = read_axis_number_slots(ser, "xVal")
    let ys = read_axis_number_slots(ser, "yVal")
    if min_len(xs.length(), ys.length()) == 0 {
      continue
    }
    let series_color = resolve_series_color(ser, si, ctx, defs)
    let segments = chart_xy_segments(xs, ys, disp_blanks_as)
    if draw_line && smooth_line {
      for segment in segments {
        let pts : Array[(Double, Double)] = []
        for point in segment {
          let (_, xv, yv) = point
          pts.push(to_xy(xv, yv))
        }
        if pts.length() < 2 {
          continue
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
      }
    } else if draw_line {
      for segment in segments {
        if segment.length() < 2 {
          continue
        }
        let buf = StringBuilder::new()
        let mut first = true
        for point in segment {
          let (_, xv, yv) = point
          let (x, y) = to_xy(xv, yv)
          if !first {
            buf.write_string(" ")
          }
          buf.write_string(format_double(x))
          buf.write_string(",")
          buf.write_string(format_double(y))
          first = false
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
    }
    // §21.2.2.181 scatterStyle val="none" — neither line nor markers are
    // drawn (per ECMA-376 the scatter plot shows only the underlying
    // axes/gridlines).  All other styles emit markers.
    let draw_markers = style != "none"
    if draw_markers {
      let marker_r = h * 0.012
      for point in chart_xy_rendered_points(xs, ys, disp_blanks_as) {
        let (_, xv, yv) = point
        let (x, y) = to_xy(xv, yv)
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
      }
    }
  }
  nodes
}

///|
fn xy_series_has_rendered_points(
  ser_elems : Array[@xml.Element],
  disp_blanks_as : @chart.ST_DispBlanksAs,
) -> Bool {
  for ser in ser_elems {
    let xs = read_axis_number_slots(ser, "xVal")
    let ys = read_axis_number_slots(ser, "yVal")
    if chart_xy_rendered_points(xs, ys, disp_blanks_as).length() > 0 {
      return true
    }
  }
  false
}

///|
fn xy_series_axis_max(
  ser_elems : Array[@xml.Element],
  child_name : String,
  disp_blanks_as : @chart.ST_DispBlanksAs,
) -> Double {
  let mut max_value = 0.0
  for ser in ser_elems {
    let values = read_axis_number_slots(ser, child_name)
    let series_max = max_positive_slots(values, disp_blanks_as)
    if series_max > max_value {
      max_value = series_max
    }
  }
  max_value
}
