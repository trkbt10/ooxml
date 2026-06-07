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
  show_dlbls_over_max? : Bool = true,
  wireframe? : Bool = false,
  surface_band_fills? : Array[String] = [],
) -> Array[@xml.Node] {
  let all_series : Array[(Array[String], Array[Double?])] = []
  let ser_elems : Array[@xml.Element] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_axis_labels(se, axes)
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
  let cat_serials = if ser_elems.length() > 0 {
    read_cat_number_slots(ser_elems[0])
  } else {
    []
  }
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
  let cat_cross = axes.val_cross_between()
  let value_axis_x = category_axis_cross_position(
    px,
    pw,
    n,
    cat_rev,
    cat_cross,
    axes.cat_crosses(),
    axes.cat_crosses_at(),
  )
  let category_axis_y = value_axis_cross_y(
    py,
    ph,
    0.0,
    max_v,
    val_rev,
    axes.val_y_crosses(),
    axes.val_y_crosses_at(),
  )
  let nodes : Array[@xml.Node] = []
  nodes.push(
    plot_axes_rect(
      px,
      py,
      pw,
      ph,
      style=Some(style),
      vertical_axis_x=Some(value_axis_x),
      horizontal_axis_y=Some(category_axis_y),
    ),
  )
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
        major_gridlines_element=axes.val_major_gridlines_element(),
        minor_gridlines_element=axes.val_minor_gridlines_element(),
        ctx=Some(ctx),
        defs=Some(defs),
        num_fmt=axes.val_num_fmt(),
        tick_lbl_pos=axes.val_tick_lbl_pos(),
        log_base=axes.val_log_base(),
        major_tick_mark=axes.val_major_tick_mark(),
        minor_tick_mark=axes.val_minor_tick_mark(),
        major_unit=axes.val_y_major_unit(),
        minor_unit=axes.val_y_minor_unit(),
        reversed=val_rev,
        axis_x=Some(value_axis_x),
        display_unit_factor=axes.val_y_disp_unit_factor(),
      ) {
      nodes.push(tick)
    }
  }
  if !axes.cat_deleted() {
    for
      tick in date_axis_ticks_bottom(
        px,
        py,
        pw,
        ph,
        fh,
        n,
        axes,
        cat_serials,
        major_tick_mark=axes.cat_major_tick_mark(),
        minor_tick_mark=axes.cat_minor_tick_mark(),
        cross_between=cat_cross,
        axis_y=Some(category_axis_y),
        tick_mark_skip=axes.cat_tick_mark_skip(),
      ) {
      nodes.push(tick)
    }
  }
  // §21.2.2.170 — single source of truth for area's category→x and
  // value→y mapping under axis orientation flips.  The area baseline is
  // the actual category-axis crossing line.
  let cat_x = fn(i : Int) -> Double {
    date_axis_position_for_index(
      px, pw, n, i, cat_rev, cat_cross, axes, cat_serials,
    )
  }
  let val_y = fn(v : Double) -> Double {
    value_axis_y(v, max_v, py, ph, val_rev)
  }
  let baseline_y = category_axis_y
  // §21.2.2.78 grouping — draw back-to-front so the first series
  // (index 0) is visually on top.
  let mut si = all_series.length() - 1
  while si >= 0 {
    let (_, values) = all_series[si]
    let series_color = if surface_band_fills.length() > 0 {
      surface_band_fills[si % surface_band_fills.length()]
    } else {
      resolve_series_color(ser_elems[si], si, ctx, defs)
    }
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
            @markup.attr("fill", if wireframe { "none" } else { series_color }),
            @markup.attr(
              "fill-opacity",
              if wireframe {
                "0"
              } else if all_series.length() > 1 {
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
  if !axes.cat_deleted() && axes.cat_tick_lbl_pos() != "none" {
    let label_side = axes.cat_tick_lbl_pos()
    let label_offset = category_horizontal_label_offset(fh, axes)
    let anchor = category_label_anchor(axes)
    for i, label in labels {
      if i >= n {
        break
      }
      if !date_axis_label_should_render(axes, cat_serials, i) {
        continue
      }
      let bx = cat_x(i)
      let (by, baseline) = category_horizontal_label_y(
        py, category_axis_y, label_side, label_offset,
      )
      nodes.push(
        chart_text(label, bx, by, w, h, anchor~, baseline~, style=Some(style)),
      )
    }
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
        let value_num_fmt = read_val_number_format(ser_elems[si])
        let total = sum_positive_slots(values, disp_blanks_as)
        let points : Array[DataLabelPoint] = []
        for point in chart_rendered_points(values, disp_blanks_as) {
          let (i, v) = point
          let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
          points.push({
            idx: i,
            x: cat_x(i),
            y: val_y(v),
            value: v,
            cat_name,
            bubble_size: None,
          })
        }
        let series_color = resolve_series_color(ser_elems[si], si, ctx, defs)
        for
          nd in render_data_labels(
            cfg,
            points,
            ser_name,
            total,
            w,
            h,
            label_offset,
            style,
            legend_key_color=Some(series_color),
            value_num_fmt~,
            show_over_max=show_dlbls_over_max,
            max_value=axes.val_y_scaling_max(),
          ) {
          nodes.push(nd)
        }
      }
    }
    None => ()
  }
  nodes
}
