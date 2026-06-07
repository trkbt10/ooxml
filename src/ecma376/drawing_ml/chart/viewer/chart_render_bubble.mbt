// =============================================================================
// §21.2.2.21 CT_BubbleChart — bubble chart renderer.
// Like a scatter chart but each data point carries a third dimension
// (`<c:bubbleSize>`) that controls the circle radius. When `bubbleSize`
// is absent, all points render at a uniform default size.
// =============================================================================

///|
fn render_bubble_chart(
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
) -> Array[@xml.Node] {
  let ser_elems = child_elements_named(elem, "ser")
  if !xy_series_has_rendered_points(ser_elems, disp_blanks_as) {
    return []
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let max_x = effective_axis_max_from_scaling(
    xy_series_axis_max(ser_elems, "xVal", disp_blanks_as),
    axes.val_x_scaling_max(),
  )
  let max_y = effective_axis_max_from_scaling(
    xy_series_axis_max(ser_elems, "yVal", disp_blanks_as),
    axes.val_y_scaling_max(),
  )
  // §21.2.2.170 — axis origin defaults to 0 for scatter/bubble.
  let min_x = effective_axis_min_from_scaling(axes.val_x_scaling_min())
  let min_y = effective_axis_min_from_scaling(axes.val_y_scaling_min())
  // §21.2.2.170 CT_Scaling / orientation — two INDEPENDENT value axes.
  let val_x_rev = axes.val_x_reversed()
  let val_y_rev = axes.val_y_reversed()
  let vertical_axis_x = value_axis_cross_x(
    px,
    pw,
    min_x,
    max_x,
    val_x_rev,
    axes.val_x_crosses(),
    axes.val_x_crosses_at(),
  )
  let horizontal_axis_y = value_axis_cross_y(
    py,
    ph,
    min_y,
    max_y,
    val_y_rev,
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
      vertical_axis_x=Some(vertical_axis_x),
      horizontal_axis_y=Some(horizontal_axis_y),
    ),
  )
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
        reversed=val_y_rev,
        axis_x=Some(vertical_axis_x),
        display_unit_factor=axes.val_y_disp_unit_factor(),
      ) {
      nodes.push(tick)
    }
  }
  // §21.2.2.20 / §21.2.2.21 — a bubble chart has TWO value axes
  // (both <c:valAx>, no <c:catAx>), so the X axis is gated on the
  // value-axis deletion flag, not cat_deleted().
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
        style=Some(style),
        major_gridlines_element=axes.val_major_gridlines_element(),
        ctx=Some(ctx),
        defs=Some(defs),
        major_tick_mark=axes.val_major_tick_mark(),
        minor_tick_mark=axes.val_minor_tick_mark(),
        major_unit=axes.val_x_major_unit(),
        minor_unit=axes.val_x_minor_unit(),
        reversed=val_x_rev,
        axis_y=Some(horizontal_axis_y),
        display_unit_factor=axes.val_x_disp_unit_factor(),
      ) {
      nodes.push(tick)
    }
  }
  let span_x = if max_x > min_x { max_x - min_x } else { 1.0 }
  let span_y = if max_y > min_y { max_y - min_y } else { 1.0 }
  // Determine the maximum bubble size for normalisation. The spec
  // (§21.2.2.22 CT_BubbleSer) defines bubbleSize as proportional to
  // §21.2.2.181 sizeRepresents — "area" (default) or "w" (width).
  // Area mode uses sqrt scaling; width mode uses linear scaling.
  let size_represents = match first_child_named(elem, "sizeRepresents") {
    Some(e) => attr_or(e, "val", "area")
    None => "area"
  }
  // §21.2.2.23 bubbleScale — scale factor (default 100%).
  let bubble_scale = match first_child_named(elem, "bubbleScale") {
    Some(e) => {
      let v = parse_int_lenient(attr_or(e, "val", "100"))
      if v > 0 && v <= 300 {
        v
      } else {
        100
      }
    }
    None => 100
  }
  // §21.2.2.22 bubble3D — when val="true", render bubbles with a
  // highlight overlay simulating a 3D shine.  Default is false.
  let is_3d = match first_child_named(elem, "bubble3D") {
    Some(e) => chart_bool_default_true(e)
    None => false
  }
  // §21.2.2.21 showNegBubbles — an explicit false suppresses
  // negative bubble-size points.  When shown, the radius uses the
  // magnitude of the negative value while the X/Y position remains
  // unchanged.
  let show_negative_bubbles = match first_child_named(elem, "showNegBubbles") {
    Some(e) => chart_bool_default_true(e)
    None => true
  }
  let max_bs = max_bubble_size_series(
    ser_elems, disp_blanks_as, show_negative_bubbles,
  )
  // §21.2.2.23 — largest bubble radius. The spec leaves the base
  // size implementation-defined; at bubbleScale=100 the largest
  // diameter is ≈ 18% of the shorter plot dimension → radius ≈ 9%.
  let base_r = (if pw < ph { pw } else { ph }) * 0.09
  let max_r = base_r * bubble_scale.to_double() / 100.0
  let dlbl_config = read_data_labels(elem)
  for si in 0..<ser_elems.length() {
    let ser = ser_elems[si]
    let xs = read_axis_number_slots(ser, "xVal")
    let ys = read_axis_number_slots(ser, "yVal")
    let bs = read_axis_number_slots(ser, "bubbleSize")
    if min_len(xs.length(), ys.length()) == 0 {
      continue
    }
    let series_color = resolve_series_color(ser, si, ctx, defs)
    let ser_name = match read_series_name(ser) {
      Some(nm) => nm
      None => ""
    }
    let value_num_fmt = read_axis_number_format(ser, "yVal")
    let bubble_size_num_fmt = read_axis_number_format(ser, "bubbleSize")
    let label_points : Array[DataLabelPoint] = []
    let total = sum_positive_slots(ys, disp_blanks_as)
    for point in chart_xy_rendered_points(xs, ys, disp_blanks_as) {
      let (j, xv, yv) = point
      // §21.2.2.170 — flip each axis's fraction independently under maxMin.
      let x = px + span_axis_fraction(xv, min_x, span_x, val_x_rev) * pw
      let y = py + ph - span_axis_fraction(yv, min_y, span_y, val_y_rev) * ph
      let raw_bval = if j < bs.length() {
        match bs[j] {
          Some(v) => v
          None =>
            if disp_blanks_as_is_zero(disp_blanks_as) {
              0.0
            } else {
              continue
            }
        }
      } else {
        max_bs
      }
      if raw_bval < 0.0 && !show_negative_bubbles {
        continue
      }
      let bval = if raw_bval < 0.0 { -raw_bval } else { raw_bval }
      let ratio = if max_bs > 0.0 { bval / max_bs } else { 1.0 }
      // §21.2.2.181 — area mode uses sqrt; width mode uses linear.
      let r = if size_represents == "w" {
        (if ratio > 0.0 { ratio } else { 0.0 }) * max_r
      } else {
        (if ratio > 0.0 { ratio } else { 0.0 }).sqrt() * max_r
      }
      let r_safe = if r < h * 0.005 { h * 0.005 } else { r }
      nodes.push(
        @markup.elem_ns(
          "circle",
          @markup.svg_ns,
          [
            @markup.attr("cx", format_double(x)),
            @markup.attr("cy", format_double(y)),
            @markup.attr("r", format_double(r_safe)),
            @markup.attr("fill", series_color),
            @markup.attr("stroke", series_color),
            @markup.attr("stroke-width", format_double(h * 0.002)),
          ],
          [],
        ),
      )
      // §21.2.2.22 bubble3D — highlight ellipse simulating a 3D shine
      // at the top-left of each bubble.  Adds one extra `<ellipse>`
      // node per data point, so pruning `<c:bubble3D>` removes the
      // highlights and the SVG skeleton differs.
      if is_3d {
        nodes.push(
          @markup.elem_ns(
            "ellipse",
            @markup.svg_ns,
            [
              @markup.attr("cx", format_double(x - r_safe * 0.35)),
              @markup.attr("cy", format_double(y - r_safe * 0.4)),
              @markup.attr("rx", format_double(r_safe * 0.3)),
              @markup.attr("ry", format_double(r_safe * 0.2)),
              @markup.attr("fill", "#ffffff"),
              @markup.attr("fill-opacity", "0.6"),
            ],
            [],
          ),
        )
      }
      match dlbl_config {
        Some(_) => {
          let cat_name = (j + 1).to_string()
          label_points.push({
            idx: j,
            x,
            y,
            value: yv,
            cat_name,
            bubble_size: Some(raw_bval),
          })
        }
        None => ()
      }
    }
    match dlbl_config {
      Some(cfg) =>
        for
          nd in render_data_labels(
            cfg,
            label_points,
            ser_name,
            total,
            w,
            h,
            -(h * 0.02),
            style,
            legend_key_color=Some(series_color),
            value_num_fmt~,
            bubble_size_num_fmt~,
            show_over_max=show_dlbls_over_max,
            max_value=axes.val_y_scaling_max(),
          ) {
          nodes.push(nd)
        }
      None => ()
    }
  }
  nodes
}

///|
fn max_bubble_size_series(
  ser_elems : Array[@xml.Element],
  disp_blanks_as : @chart.ST_DispBlanksAs,
  show_negative_bubbles : Bool,
) -> Double {
  let mut saw_sizes = false
  let mut max_value = 0.0
  for ser in ser_elems {
    let sizes = read_axis_number_slots(ser, "bubbleSize")
    if sizes.length() > 0 {
      saw_sizes = true
      let series_max = max_bubble_size_slots(
        sizes, disp_blanks_as, show_negative_bubbles,
      )
      if series_max > max_value {
        max_value = series_max
      }
    }
  }
  if !saw_sizes || max_value <= 0.0 {
    1.0
  } else {
    max_value
  }
}

///|
fn max_bubble_size_slots(
  values : Array[Double?],
  disp_blanks_as : @chart.ST_DispBlanksAs,
  show_negative_bubbles : Bool,
) -> Double {
  let mut m = 0.0
  for slot in values {
    let value = match slot {
      Some(v) => v
      None =>
        if disp_blanks_as_is_zero(disp_blanks_as) {
          0.0
        } else {
          continue
        }
    }
    let magnitude = if value < 0.0 {
      if show_negative_bubbles {
        -value
      } else {
        0.0
      }
    } else {
      value
    }
    if magnitude > m {
      m = magnitude
    }
  }
  m
}
