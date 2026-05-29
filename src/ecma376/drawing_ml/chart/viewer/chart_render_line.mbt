// =============================================================================
// §21.2.2.96 CT_LineChart — multi-series polyline renderer.
// Emits one `<polyline>` per series connecting the data points in category
// order, stroked with the series accent colour. Per-series markers (filled
// circles) are drawn at every data point so the series remain
// distinguishable at low resolutions.
// =============================================================================

///|
fn render_line_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : ChartAxesInfo,
  style : ChartStyleDefaults,
) -> Array[@xml.Node] {
  let all_series : Array[(Array[String], Array[Double])] = []
  let ser_elems : Array[@xml.Element] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_labels(se)
          let values = read_val_numbers(se)
          if values.length() > 0 {
            ser_elems.push(se)
            all_series.push((labels, values))
          }
        }
      _ => ()
    }
  }
  if all_series.length() == 0 {
    return []
  }
  let (labels, _) = all_series[0]
  let mut data_max = 0.0
  let mut n = 0
  for s in all_series {
    let (_, values) = s
    let mv = max_positive(values)
    if mv > data_max {
      data_max = mv
    }
    if values.length() > n {
      n = values.length()
    }
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let max_v = effective_axis_max(data_max, axes)
  let nodes : Array[@xml.Node] = []
  nodes.push(plot_axes_rect(px, py, pw, ph, style=Some(style)))
  if !axes.val_deleted() {
    for n2 in y_axis_ticks(px, py, ph, max_v, pw, fw, axes.val_major(), style=Some(style), draw_minor_gridlines=axes.val_minor_gridlines(), num_fmt=axes.val_num_fmt(), tick_lbl_pos=axes.val_tick_lbl_pos(), log_base=axes.val_log_base()) {
      nodes.push(n2)
    }
  }
  if !axes.cat_deleted() && n > 0 {
    let axis_color = style.axis_color
    let major_half = fh * 0.0121
    let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
    let xstep = if n > 1 { pw / (n - 1).to_double() } else { 0.0 }
    let mut i = 0
    while i < n {
      let x = px + i.to_double() * xstep
      nodes.push(
        axis_tick_v_line(
          py + ph - major_half,
          py + ph + major_half,
          x,
          axis_color,
          tick_stroke,
        ),
      )
      i = i + 1
    }
  }
  let step = if n > 1 { pw / (n - 1).to_double() } else { 0.0 }
  for si, s in all_series {
    let (_, values) = s
    let series_color = resolve_series_color(ser_elems[si], si, ctx)
    // §21.2.2.196 smooth — when `<c:smooth val="1"/>` is present on
    // the series, render the line as a smooth Catmull-Rom-style
    // curve via cubic Béziers instead of straight polyline
    // segments.  Spec leaves the exact spline form to the
    // implementation; we use a 0.5-tension Catmull-Rom expressed in
    // standard SVG path C commands so pruning `<c:smooth>` produces
    // a visible diff (path vs polyline) the catalog detects.
    let smooth = match first_child_named(ser_elems[si], "smooth") {
      // §22.9.2.7 xsd:boolean accepts both "true"/"false" and
      // "1"/"0" lexical forms; the default when val is absent is
      // "true" (the synth's `<c:smooth/>` carries no val).
      Some(e) => {
        let v = attr_or(e, "val", "true")
        v == "1" || v == "true"
      }
      None => false
    }
    let pts : Array[(Double, Double)] = []
    for i, v in values {
      let x = px + i.to_double() * step
      let y = if max_v > 0.0 { py + ph - v / max_v * ph } else { py + ph }
      pts.push((x, y))
    }
    if smooth && pts.length() >= 2 {
      // Catmull-Rom → cubic Bezier conversion.  For each interior
      // segment (P1 → P2), compute control points from the
      // surrounding points P0 / P3 (clamped to endpoints).
      let path_buf = StringBuilder::new()
      let (x0_init, y0_init) = pts[0]
      path_buf.write_string("M")
      path_buf.write_string(format_double(x0_init))
      path_buf.write_string(",")
      path_buf.write_string(format_double(y0_init))
      let mut i = 0
      while i < pts.length() - 1 {
        let (x_p1, y_p1) = pts[i]
        let (x_p2, y_p2) = pts[i + 1]
        let (x_p0, y_p0) = if i == 0 { pts[i] } else { pts[i - 1] }
        let (x_p3, y_p3) = if i + 2 < pts.length() {
          pts[i + 2]
        } else {
          pts[i + 1]
        }
        let cx1 = x_p1 + (x_p2 - x_p0) / 6.0
        let cy1 = y_p1 + (y_p2 - y_p0) / 6.0
        let cx2 = x_p2 - (x_p3 - x_p1) / 6.0
        let cy2 = y_p2 - (y_p3 - y_p1) / 6.0
        path_buf.write_string(" C")
        path_buf.write_string(format_double(cx1))
        path_buf.write_string(",")
        path_buf.write_string(format_double(cy1))
        path_buf.write_string(" ")
        path_buf.write_string(format_double(cx2))
        path_buf.write_string(",")
        path_buf.write_string(format_double(cy2))
        path_buf.write_string(" ")
        path_buf.write_string(format_double(x_p2))
        path_buf.write_string(",")
        path_buf.write_string(format_double(y_p2))
        i = i + 1
      }
      nodes.push(
        @markup.elem_ns(
          "path",
          @markup.svg_ns,
          [
            @markup.attr("d", path_buf.to_string()),
            @markup.attr("fill", "none"),
            @markup.attr("stroke", series_color),
            @markup.attr("stroke-width", format_double(h * 0.005)),
            @markup.attr("stroke-linejoin", "round"),
          ],
          [],
        ),
      )
    } else {
      let buf = StringBuilder::new()
      let mut first = true
      for pt in pts {
        let (x, y) = pt
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
    let default_r = h * 0.008
    let (marker_sym, marker_r) = read_marker_config(ser_elems[si], default_r)
    for i, v in values {
      let x = px + i.to_double() * step
      let y = if max_v > 0.0 { py + ph - v / max_v * ph } else { py + ph }
      nodes.push(render_marker(x, y, marker_r, marker_sym, series_color))
    }
    // §21.2.2.211 trendline — linear regression overlay.
    match read_trendline(ser_elems[si]) {
      Some(tl_elem) =>
        for tn in render_trendline(
          tl_elem, values, px, py, pw, ph, max_v, step, series_color,
          h * 0.003,
        ) {
          nodes.push(tn)
        }
      None => ()
    }
    // §21.2.2.55 errBars — error bar overlay.
    match read_err_bars(ser_elems[si]) {
      Some(eb_cfg) => {
        let pts : Array[(Double, Double)] = []
        for i, v in values {
          let x = px + i.to_double() * step
          let y = if max_v > 0.0 {
            py + ph - v / max_v * ph
          } else {
            py + ph
          }
          pts.push((x, y))
        }
        for en in render_err_bars(
          eb_cfg, pts, max_v, ph, series_color, h * 0.002,
        ) {
          nodes.push(en)
        }
      }
      None => ()
    }
  }
  if !axes.cat_deleted() {
    for i, label in labels {
      if i >= n {
        break
      }
      let bx = px + i.to_double() * step
      let by = py + ph + fh * 0.018
      nodes.push(
        chart_text(label, bx, by, w, h, anchor="middle", baseline="hanging", style=Some(style)),
      )
    }
  }
  // §21.2.2.49 dLbls — data labels above markers.
  let dlbl_config = read_data_labels(elem)
  match dlbl_config {
    Some(cfg) => {
      let label_offset = -(h * 0.02)
      for si, s in all_series {
        let (labels_s, values) = s
        let ser_name = match read_series_name(ser_elems[si]) {
          Some(nm) => nm
          None => ""
        }
        let total = sum_positive(values)
        let points : Array[(Double, Double, Double, String)] = []
        for i, v in values {
          let x = px + i.to_double() * step
          let y = if max_v > 0.0 { py + ph - v / max_v * ph } else { py + ph }
          let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
          points.push((x, y, v, cat_name))
        }
        for nd in render_data_labels(
          cfg, points, ser_name, total, w, h, label_offset, style,
        ) {
          nodes.push(nd)
        }
      }
    }
    None => ()
  }
  nodes
}
