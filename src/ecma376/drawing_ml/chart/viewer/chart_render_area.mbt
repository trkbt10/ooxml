// =============================================================================
// §21.2.2.4 CT_AreaChart — filled area chart renderer.
// Emits one filled `<polygon>` per series describing the area between the
// polyline and the category axis baseline (y = 0). Multi-series areas are
// drawn back-to-front so the first series (index 0) sits on top. Each
// series fills with a semi-transparent accent colour so overlapping
// areas remain distinguishable.
// =============================================================================

///|
fn render_area_chart(
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
  let all_series : Array[(Array[String], Array[Double?])] = []
  let ser_elems : Array[@xml.Element] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_labels(se)
          let values = read_val_number_slots(se)
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
    let mv = max_positive_slots(values, disp_blanks_as)
    if mv > data_max {
      data_max = mv
    }
    if values.length() > n {
      n = values.length()
    }
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let max_v = effective_axis_max(data_max, axes)
  // §21.2.2.170 CT_Scaling / orientation — maxMin reverses the axis.
  let val_rev = axes.val_reversed()
  let cat_rev = axes.cat_reversed()
  let nodes : Array[@xml.Node] = []
  nodes.push(plot_axes_rect(px, py, pw, ph, style=Some(style)))
  if !axes.val_deleted() {
    for
      tick in y_axis_ticks(
        px,
        py,
        ph,
        max_v,
        pw,
        fw,
        axes.val_major(),
        style=Some(style),
        draw_minor_gridlines=axes.val_minor_gridlines(),
        num_fmt=axes.val_num_fmt(),
        tick_lbl_pos=axes.val_tick_lbl_pos(),
        log_base=axes.val_log_base(),
        reversed=val_rev,
      ) {
      nodes.push(tick)
    }
  }
  if n > 0 {
    let axis_color = "#bfbfbf"
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
  // §21.2.2.170 — single source of truth for area's category→x and
  // value→y mapping under axis orientation flips.  The area baseline is
  // the value-0 line: bottom (py+ph) for minMax, top (py) for maxMin.
  let cat_x = fn(i : Int) -> Double {
    px + category_index(i, n, cat_rev).to_double() * step
  }
  let val_y = fn(v : Double) -> Double {
    value_axis_y(v, max_v, py, ph, val_rev)
  }
  let baseline_y = value_axis_y(0.0, max_v, py, ph, val_rev)
  // §21.2.2.78 grouping — draw back-to-front so the first series
  // (index 0) is visually on top.
  let mut si = all_series.length() - 1
  while si >= 0 {
    let (_, values) = all_series[si]
    let series_color = resolve_series_color(ser_elems[si], si, ctx, defs)
    let segments = chart_point_segments(values, disp_blanks_as)
    for segment in segments {
      if segment.length() == 0 {
        continue
      }
      let buf = StringBuilder::new()
      let (first_i, _) = segment[0]
      // Start at the baseline under the first plotted category in this
      // contiguous segment. `gap` creates multiple polygons; `span`
      // keeps one segment and skips the blank vertex.
      buf.write_string(format_double(cat_x(first_i)))
      buf.write_string(",")
      buf.write_string(format_double(baseline_y))
      for point in segment {
        let (i, v) = point
        let x = cat_x(i)
        let y = val_y(v)
        buf.write_string(" ")
        buf.write_string(format_double(x))
        buf.write_string(",")
        buf.write_string(format_double(y))
      }
      // Close back to the baseline under the last plotted category.
      let (last_i, _) = segment[segment.length() - 1]
      buf.write_string(" ")
      buf.write_string(format_double(cat_x(last_i)))
      buf.write_string(",")
      buf.write_string(format_double(baseline_y))
      nodes.push(
        @markup.elem_ns(
          "polygon",
          @markup.svg_ns,
          [
            @markup.attr("points", buf.to_string()),
            @markup.attr("fill", series_color),
            @markup.attr(
              "fill-opacity",
              if all_series.length() > 1 {
                "0.7"
              } else {
                "1"
              },
            ),
            @markup.attr("stroke", series_color),
            @markup.attr("stroke-width", format_double(h * 0.003)),
            @markup.attr("stroke-linejoin", "round"),
          ],
          [],
        ),
      )
    }
    si = si - 1
  }
  for i, label in labels {
    if i >= n {
      break
    }
    let bx = cat_x(i)
    let by = py + ph + fh * 0.018
    nodes.push(
      chart_text(
        label,
        bx,
        by,
        w,
        h,
        anchor="middle",
        baseline="hanging",
        style=Some(style),
      ),
    )
  }
  // §21.2.2.49 dLbls — data labels at each data point.
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
        let total = sum_positive_slots(values, disp_blanks_as)
        let points : Array[(Double, Double, Double, String)] = []
        for point in chart_rendered_points(values, disp_blanks_as) {
          let (i, v) = point
          let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
          points.push((cat_x(i), val_y(v), v, cat_name))
        }
        for
          nd in render_data_labels(
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
