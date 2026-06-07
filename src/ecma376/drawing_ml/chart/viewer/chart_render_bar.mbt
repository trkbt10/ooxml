// =============================================================================
// §21.2.2.18 CT_BarChart — bar chart renderer.
//
// Reads every `<c:ser>` and emits `<rect>` geometry for clustered,
// stacked, and percentStacked groupings. Category labels come from
// `<c:cat>/<c:strRef>/<c:strCache>` and are painted under/beside the
// category bands; the value axis uses the shared chart axis helpers.
//
// `barDir = "col"` (default) draws vertical columns; `barDir = "bar"`
// draws horizontal bars. The fixtures use "bar" which in OOXML
// terminology means horizontal — both branches are implemented.
// =============================================================================

///|
fn chart_is_hex_char(ch : String) -> Bool {
  (ch >= "0" && ch <= "9") ||
  (ch >= "a" && ch <= "f") ||
  (ch >= "A" && ch <= "F")
}

///|
fn chart_is_svg_hex_fill(fill : String) -> Bool {
  if fill.length() != 7 || fill[0:1] != "#" {
    return false
  }
  let mut i = 1
  while i < fill.length() {
    if !chart_is_hex_char(fill[i:i + 1].to_owned()) {
      return false
    }
    i = i + 1
  }
  true
}

///|
fn chart_inverted_solid_fill(fill : String) -> String? {
  if !chart_is_svg_hex_fill(fill) {
    return None
  }
  let rgb = @color.hex_to_rgb(fill)
  Some("#" + @color.rgb_to_hex(255.0 - rgb.r, 255.0 - rgb.g, 255.0 - rgb.b))
}

///|
fn bar_series_invert_if_negative(ser : @xml.Element) -> Bool {
  match first_child_named(ser, "invertIfNegative") {
    Some(e) => chart_bool_default_true(e)
    None => false
  }
}

///|
fn bar_fill_for_value(fill : String, value : Double, invert : Bool) -> String {
  if value < 0.0 && invert {
    match chart_inverted_solid_fill(fill) {
      Some(v) => return v
      None => ()
    }
  }
  fill
}

///|
/// §21.2.2.75 gapDepth — for 3-D bar charts, the distance between
/// adjacent series along the depth axis. The SVG renderer flattens
/// bar3D into 2-D columns/bars, so the same value narrows or widens the
/// in-cluster series band while leaving ordinary 2-D barChart untouched.
fn bar3d_gap_depth_ratio(elem : @xml.Element, s_count : Int) -> Double {
  if elem.name.local_name != "bar3DChart" || s_count <= 1 {
    return 1.0
  }
  let gap_depth = match first_child_named(elem, "gapDepth") {
    Some(g) => {
      let v = parse_int_lenient(attr_or(g, "val", "150"))
      if v >= 0 && v <= 500 {
        v
      } else {
        150
      }
    }
    None => return 1.0
  }
  let n = s_count.to_double()
  n / (n + gap_depth.to_double() / 100.0)
}

///|
fn chart_series_order_value(ser : @xml.Element, fallback : Int) -> Int {
  match first_child_named(ser, "order") {
    Some(e) => {
      let v = parse_int_lenient(attr_or(e, "val", fallback.to_string()))
      if v >= 0 {
        v
      } else {
        fallback
      }
    }
    None => fallback
  }
}

///|
fn chart_series_order_indices(ser_elems : Array[@xml.Element]) -> Array[Int] {
  let out : Array[Int] = []
  for i in 0..<ser_elems.length() {
    let order_i = chart_series_order_value(ser_elems[i], i)
    let mut pos = 0
    while pos < out.length() {
      let j = out[pos]
      let order_j = chart_series_order_value(ser_elems[j], j)
      if order_i < order_j {
        break
      }
      pos = pos + 1
    }
    out.insert(pos, i)
  }
  out
}

///|
fn render_bar_chart(
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
  let bar_dir = match first_child_named(elem, "barDir") {
    Some(d) => attr_or(d, "val", "col")
    None => "col"
  }
  // §21.2.2.76 grouping — "clustered" (default), "stacked",
  // "percentStacked", "standard".
  let grouping = match first_child_named(elem, "grouping") {
    Some(g) => attr_or(g, "val", "clustered")
    None => "clustered"
  }
  // §21.2.2.171 ser — collect every `<c:ser>` child with its raw
  // element for spPr/dPt access.
  let raw_ser_elems : Array[@xml.Element] = []
  let raw_series : Array[(Array[String], Array[Double?])] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_axis_labels(se, axes)
          let values = read_val_number_slots(se)
          if values.length() > 0 {
            raw_ser_elems.push(se)
            raw_series.push((labels, values))
          }
        }
      _ => ()
    }
  }
  let ser_elems : Array[@xml.Element] = []
  let series : Array[(Array[String], Array[Double?])] = []
  for idx in chart_series_order_indices(raw_ser_elems) {
    ser_elems.push(raw_ser_elems[idx])
    series.push(raw_series[idx])
  }
  if series.length() == 0 {
    return []
  }
  let (labels, _) = series[0]
  let cat_serials = if ser_elems.length() > 0 {
    read_cat_number_slots(ser_elems[0])
  } else {
    []
  }
  // §21.2.2.170 — compute axis range respecting explicit min/max.
  let mut data_max = 0.0
  let mut data_min = 0.0
  if grouping == "stacked" {
    // Stacked: max is the sum of all series at each category.
    let (_, v0) = series[0]
    let mut ci = 0
    while ci < v0.length() {
      let mut stack_sum = 0.0
      for s in series {
        let (_, vals) = s
        match chart_slot_value_at(vals, ci, disp_blanks_as) {
          Some(v) => stack_sum = stack_sum + (if v > 0.0 { v } else { 0.0 })
          None => ()
        }
      }
      if stack_sum > data_max {
        data_max = stack_sum
      }
      ci = ci + 1
    }
  } else if grouping == "percentStacked" {
    data_max = 100.0
    // percentStacked always uses 100% ceiling — no nice_axis_max overshoot.
  } else {
    for s in series {
      let (_, values) = s
      let mv = max_positive_slots(values, disp_blanks_as)
      if mv > data_max {
        data_max = mv
      }
      let mn = min_negative_slots(values, disp_blanks_as)
      if mn < data_min {
        data_min = mn
      }
    }
  }
  // §21.2.2.76 — percentStacked ceiling is always 100 (no overshoot).
  let raw_max_v = if grouping == "percentStacked" {
    100.0
  } else {
    effective_axis_max(data_max, axes)
  }
  let min_v = if grouping == "percentStacked" {
    0.0
  } else {
    effective_axis_min(data_min, axes)
  }
  let max_v = if raw_max_v > min_v { raw_max_v } else { min_v + 1.0 }
  let is_percent = grouping == "percentStacked"
  // §21.2.2.170 CT_Scaling / orientation — maxMin reverses the axis.
  // `val_rev` flips the value axis (column grows DOWNWARD from the
  // top / horizontal bar grows LEFTWARD from the right); `cat_rev`
  // flips the category band order.
  let val_rev = axes.val_reversed()
  let cat_rev = axes.cat_reversed()
  let cat_cross = axes.val_cross_between()
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let cat_count = {
    let (l0, v0) = series[0]
    if l0.length() > v0.length() {
      v0.length()
    } else {
      v0.length()
    }
  }
  let vertical_axis_x = if bar_dir == "bar" {
    value_axis_cross_x(
      px,
      pw,
      min_v,
      max_v,
      val_rev,
      axes.val_x_crosses(),
      axes.val_x_crosses_at(),
    )
  } else {
    category_axis_cross_position(
      px,
      pw,
      cat_count,
      cat_rev,
      cat_cross,
      axes.cat_crosses(),
      axes.cat_crosses_at(),
    )
  }
  let horizontal_axis_y = if bar_dir == "bar" {
    category_axis_cross_position(
      py,
      ph,
      cat_count,
      !cat_rev,
      cat_cross,
      axes.cat_crosses(),
      axes.cat_crosses_at(),
    )
  } else {
    value_axis_cross_y(
      py,
      ph,
      min_v,
      max_v,
      val_rev,
      axes.val_y_crosses(),
      axes.val_y_crosses_at(),
    )
  }
  let nodes : Array[@xml.Node] = []
  if !axes.val_deleted() || !axes.cat_deleted() {
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
  }
  let s_count = series.length()
  // §21.2.2.74 gapWidth — percentage of bar width used as gap between
  // clusters. The ECMA-376 Part 4 default is "150%", but the spec
  // leaves the absent-attribute default to the implementation
  // (§21.2.2.74: "If this element is not included, its value shall
  // be assumed to be the application's default"). Measurement against
  // §21.2.2.74 convention shows stacked/percentStacked charts use an
  // effective default of ≈82%, while clustered defaults to 150%.
  let gap_width = match first_child_named(elem, "gapWidth") {
    Some(g) => {
      let v = parse_int_lenient(attr_or(g, "val", "150"))
      if v >= 0 && v <= 500 {
        v
      } else {
        150
      }
    }
    None => 150
  }
  // §21.2.2.131 overlap — percentage of bar width that adjacent bars
  // within a cluster overlap. Default 0 (no overlap). Positive =
  // overlap, negative = gap between bars.
  let overlap_pct = match first_child_named(elem, "overlap") {
    Some(o) => {
      let v = parse_int_lenient(attr_or(o, "val", "0"))
      if v >= -100 && v <= 100 {
        v
      } else {
        0
      }
    }
    None => 0
  }
  // §21.2.2.74 — cluster_ratio = n / (n + gapWidth/100) where n
  // reflects the visual width: for clustered, each bar is separate
  // so n = s_count; for stacked, bars are stacked into one column
  // so n = 1 (the gap is relative to the stacked column width).
  let effective_n = if grouping == "stacked" || grouping == "percentStacked" {
    1.0
  } else {
    s_count.to_double()
  }
  let cluster_ratio = effective_n /
    (effective_n + gap_width.to_double() / 100.0)
  let gap_depth_ratio = bar3d_gap_depth_ratio(elem, s_count)
  let dpt_overrides_by_series : Array[Array[(Int, String)]] = []
  for si, se in ser_elems {
    dpt_overrides_by_series.push(
      collect_dpt_colors(se, ctx, defs, "ser" + si.to_string()),
    )
  }
  let bar_shapes : Array[ChartBarShape] = []
  for se in ser_elems {
    bar_shapes.push(read_bar_shape(elem, se))
  }
  let invert_negative_by_series : Array[Bool] = []
  for se in ser_elems {
    invert_negative_by_series.push(bar_series_invert_if_negative(se))
  }
  let dlbl_config = read_data_labels(elem)
  if bar_dir == "bar" {
    // Horizontal bars: §21.2.2.15 barDir="bar". The OOXML convention
    // (and PowerPoint's chart renderer) plots categories on the
    // value axis in REVERSE document order — the first `<c:cat>`
    // entry (Q1) lands at the BOTTOM of the band stack, the last
    // (Q4) at the TOP. The value axis runs along the X axis (0
    // on the left, max on the right) and the category labels sit
    // on the LEFT of the plot area.
    //
    // Multi-series stacks clustered bars vertically inside each
    // category band.
    // For horizontal bars the value axis is X; gridlines on it follow
    // the valAx `<c:majorGridlines/>` declaration.
    if !axes.val_deleted() {
      for
        n in x_axis_ticks(
          px,
          py,
          pw,
          ph,
          max_v,
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
          reversed=val_rev,
          axis_y=Some(horizontal_axis_y),
          display_unit_factor=axes.val_x_disp_unit_factor(),
        ) {
        nodes.push(n)
      }
    }
    if !axes.cat_deleted() {
      for
        n in category_axis_ticks_left(
          px,
          py,
          pw,
          ph,
          fw,
          cat_count,
          major_tick_mark=axes.cat_major_tick_mark(),
          cross_between=cat_cross,
          axis_x=Some(vertical_axis_x),
          tick_mark_skip=axes.cat_tick_mark_skip(),
        ) {
        nodes.push(n)
      }
      if cat_count > 0 && axes.cat_minor_tick_mark() != "none" {
        let band_h = ph / cat_count.to_double()
        let minor_half = fw * 0.0056
        let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
        let mut i = 0
        while i < cat_count {
          let yc = py + (i.to_double() + 0.5) * band_h
          nodes.push(
            axis_tick_h_line(
              vertical_axis_x - minor_half,
              vertical_axis_x + minor_half,
              yc,
              chart_default_axis_color,
              tick_stroke,
            ),
          )
          i = i + 1
        }
      }
    }
    let band = category_axis_slot_span_for_cross(ph, cat_count, cat_cross)
    // §21.2.2.74 gapWidth — the clustered bar chart applies an inter-bar
    // gap (default 150 in the spec, but the effective cluster width on a
    // 2-series clustered bar at default settings is band·0.56,
    // corresponding to an effective gapWidth ≈ 75%). For 1 series the
    // gap formula yields band/2.5 = 0.40·band; for 2+ series the
    // cluster widens to 0.56·band. On `chart-bar-with-legend.pptx`:
    // Plan Q1 bar 251–284 + Actual 285–317 = cluster 67px in a 117px
    // band → 67/117 ≈ 0.573.
    if grouping == "stacked" || grouping == "percentStacked" {
      // §21.2.2.76 stacked / percentStacked horizontal bars.
      let sub_h = band * cluster_ratio
      let sub_pad = (band - sub_h) / 2.0
      for i_idx = 0; i_idx < cat_count; i_idx = i_idx + 1 {
        // Horizontal bars plot categories bottom-up (Q1 at the bottom)
        // by convention; §21.2.2.170 catAx maxMin un-reverses that so
        // Q1 sits at the top.
        let cy = category_axis_position_for_cross(
          py,
          ph,
          cat_count,
          i_idx,
          !cat_rev,
          cat_cross,
        )
        let mut cat_total = 0.0
        if grouping == "percentStacked" {
          for s in series {
            let (_, vals) = s
            match chart_slot_value_at(vals, i_idx, disp_blanks_as) {
              Some(v) => if v > 0.0 { cat_total = cat_total + v }
              None => ()
            }
          }
        }
        let mut accum = 0.0
        for si, s in series {
          let (_, values) = s
          let v = match chart_slot_value_at(values, i_idx, disp_blanks_as) {
            Some(v) => v
            None => continue
          }
          let norm_v = if grouping == "percentStacked" && cat_total > 0.0 {
            v / cat_total * 100.0
          } else {
            v
          }
          // §21.2.2.170 — the stacked segment spans value [accum,
          // accum+norm_v].  minMax keeps the exact legacy expression
          // (start at the left, grow right); maxMin maps BOTH ends
          // through `value_axis_x` so the stack grows leftward from the
          // right edge.
          let x_lo = value_axis_x_span(accum, min_v, max_v, px, pw, val_rev)
          let x_hi = value_axis_x_span(
            accum + norm_v,
            min_v,
            max_v,
            px,
            pw,
            val_rev,
          )
          let x_start = if x_lo < x_hi { x_lo } else { x_hi }
          let len = if x_lo < x_hi { x_hi - x_lo } else { x_lo - x_hi }
          let by = cy - band / 2.0 + sub_pad
          let color = resolve_series_color(ser_elems[si], si, ctx, defs)
          let fill = match dpt_color_for(dpt_overrides_by_series[si], i_idx) {
            Some(c) => c
            None => color
          }
          let fill = bar_fill_for_value(fill, v, invert_negative_by_series[si])
          for
            n in render_bar_shape_nodes(
              x_start,
              by,
              len,
              sub_h,
              fill,
              bar_shapes[si],
              true,
              val_rev,
            ) {
            nodes.push(n)
          }
          accum = accum + norm_v
        }
      }
    } else {
      // Clustered bars with §21.2.2.131 overlap support.
      let sub_band = band * cluster_ratio
      let sub_pad = (band - sub_band) / 2.0
      // overlap_pct > 0 means bars overlap; each bar is wider than
      // sub_band/n and positioned to overlap by that percentage.
      let depth_band = sub_band * gap_depth_ratio
      let depth_pad = (sub_band - depth_band) / 2.0
      let raw_bar_h = depth_band / s_count.to_double()
      let overlap_frac = overlap_pct.to_double() / 100.0
      let bar_h = raw_bar_h *
        (1.0 + overlap_frac * (s_count - 1).to_double() / s_count.to_double())
      for si, s in series {
        let (_, values) = s
        let color = resolve_series_color(ser_elems[si], si, ctx, defs)
        let dpt_overrides = dpt_overrides_by_series[si]
        for point in chart_rendered_points(values, disp_blanks_as) {
          let (i, v) = point
          if i >= cat_count {
            break
          }
          // §21.2.2.170 — minMax: bar starts at the left axis (px) and
          // grows right by `len`.  maxMin: value 0 is at the right edge
          // (px+pw) and the bar grows left, so the rect runs from the
          // value's pixel x to the right edge.
          let x0 = value_axis_x_span(0.0, min_v, max_v, px, pw, val_rev)
          let x_v = value_axis_x_span(v, min_v, max_v, px, pw, val_rev)
          let bar_x = if x0 < x_v { x0 } else { x_v }
          let len = if x0 < x_v { x_v - x0 } else { x0 - x_v }
          // Horizontal bars plot Q1 at the bottom by convention; catAx
          // maxMin un-reverses that ordering.
          let cy = category_axis_position_for_cross(
            py,
            ph,
            cat_count,
            i,
            !cat_rev,
            cat_cross,
          )
          let by = cy -
            band / 2.0 +
            sub_pad +
            depth_pad +
            si.to_double() * bar_h
          let fill = match dpt_color_for(dpt_overrides, i) {
            Some(c) => c
            None => color
          }
          let fill = bar_fill_for_value(fill, v, invert_negative_by_series[si])
          for
            n in render_bar_shape_nodes(
              bar_x,
              by,
              len,
              bar_h,
              fill,
              bar_shapes[si],
              true,
              val_rev,
            ) {
            nodes.push(n)
          }
        }
      }
    }
    if !axes.cat_deleted() && axes.cat_tick_lbl_pos() != "none" {
      let label_side = axes.cat_tick_lbl_pos()
      let label_offset = category_vertical_label_offset(fw, axes)
      for i, label in labels {
        if i >= cat_count {
          break
        }
        if !category_label_should_render(axes, i) {
          continue
        }
        // Label band must track the bar band under catAx maxMin.
        let by = category_axis_position_for_cross(
          py,
          ph,
          cat_count,
          i,
          !cat_rev,
          cat_cross,
        )
        let (label_x, anchor) = category_vertical_label_x(
          px, pw, vertical_axis_x, label_side, label_offset,
        )
        nodes.push(
          chart_text(
            label,
            label_x,
            by,
            w,
            h,
            anchor~,
            baseline="middle",
            style=Some(style),
          ),
        )
      }
    }
  } else {
    if !axes.val_deleted() {
      let suffix = if is_percent { "%" } else { "" }
      // §21.2.2.170 logBase — apply only when the data extent (max_v)
      // actually has range above 1.  When `<c:max val="1"/>` collapses
      // the domain, log_scale_frac degenerates to f=0 for every tick
      // and majorGridlines / minorGridlines become indistinguishable
      // from absent (both produce the same lines at y=py+ph).  Bar
      // chart fixtures always carry positive integer data; the guard
      // is conservative: log only when max_v >= 2.
      let log_b = match axes.val_log_base() {
        Some(b) => if max_v >= 2.0 && b >= 2.0 { Some(b) } else { None }
        None => None
      }
      for
        n in y_axis_ticks(
          px,
          py,
          ph,
          max_v,
          pw,
          fw,
          axes.val_major(),
          label_suffix=suffix,
          style=Some(style),
          draw_minor_gridlines=axes.val_minor_gridlines(),
          major_gridlines_element=axes.val_major_gridlines_element(),
          minor_gridlines_element=axes.val_minor_gridlines_element(),
          ctx=Some(ctx),
          defs=Some(defs),
          num_fmt=axes.val_num_fmt(),
          tick_lbl_pos=axes.val_tick_lbl_pos(),
          log_base=log_b,
          major_tick_mark=axes.val_major_tick_mark(),
          minor_tick_mark=axes.val_minor_tick_mark(),
          major_unit=axes.val_y_major_unit(),
          minor_unit=axes.val_y_minor_unit(),
          reversed=val_rev,
          axis_x=Some(vertical_axis_x),
          display_unit_factor=axes.val_y_disp_unit_factor(),
        ) {
        nodes.push(n)
      }
    }
    if !axes.cat_deleted() {
      for
        n in date_axis_ticks_bottom(
          px,
          py,
          pw,
          ph,
          fh,
          cat_count,
          axes,
          cat_serials,
          major_tick_mark=axes.cat_major_tick_mark(),
          minor_tick_mark=axes.cat_minor_tick_mark(),
          cross_between=cat_cross,
          axis_y=Some(horizontal_axis_y),
          tick_mark_skip=axes.cat_tick_mark_skip(),
        ) {
        nodes.push(n)
      }
    }
    let band = category_axis_slot_span_for_cross(pw, cat_count, cat_cross)
    if grouping == "stacked" || grouping == "percentStacked" {
      // §21.2.2.76 stacked / percentStacked vertical columns.
      // Default gapWidth=150 → col_ratio = 1/(1+1.5) ≈ 0.4.
      let col_w = band * cluster_ratio
      for i_idx = 0; i_idx < cat_count; i_idx = i_idx + 1 {
        let mut cat_total = 0.0
        if grouping == "percentStacked" {
          for s in series {
            let (_, vals) = s
            match chart_slot_value_at(vals, i_idx, disp_blanks_as) {
              Some(v) => if v > 0.0 { cat_total = cat_total + v }
              None => ()
            }
          }
        }
        let mut accum = 0.0
        for si, s in series {
          let (_, values) = s
          let v = match chart_slot_value_at(values, i_idx, disp_blanks_as) {
            Some(v) => v
            None => continue
          }
          let norm_v = if grouping == "percentStacked" && cat_total > 0.0 {
            v / cat_total * 100.0
          } else {
            v
          }
          // §21.2.2.170 — the stacked segment spans value [accum,
          // accum+norm_v].  minMax keeps the exact legacy expression
          // (base at the bottom, grow up); maxMin maps BOTH ends through
          // `value_axis_y` so the stack grows DOWNWARD from the top.
          let y_lo = value_axis_y_span(accum, min_v, max_v, py, ph, val_rev)
          let y_hi = value_axis_y_span(
            accum + norm_v,
            min_v,
            max_v,
            py,
            ph,
            val_rev,
          )
          let rect_y = if y_lo < y_hi { y_lo } else { y_hi }
          let hgt = if y_lo < y_hi { y_hi - y_lo } else { y_lo - y_hi }
          // catAx maxMin reverses the category band order along X.
          let bx = date_axis_position_for_index(
              px, pw, cat_count, i_idx, cat_rev, cat_cross, axes, cat_serials,
            ) -
            col_w / 2.0
          let color = resolve_series_color(ser_elems[si], si, ctx, defs)
          let fill = match dpt_color_for(dpt_overrides_by_series[si], i_idx) {
            Some(c) => c
            None => color
          }
          let fill = bar_fill_for_value(fill, v, invert_negative_by_series[si])
          for
            n in render_bar_shape_nodes(
              bx,
              rect_y,
              col_w,
              hgt,
              fill,
              bar_shapes[si],
              false,
              val_rev,
            ) {
            nodes.push(n)
          }
          accum = accum + norm_v
        }
      }
    } else {
      // Clustered columns with §21.2.2.131 overlap.
      let cluster_w = band * cluster_ratio
      let depth_cluster_w = cluster_w * gap_depth_ratio
      let depth_pad_w = (cluster_w - depth_cluster_w) / 2.0
      let raw_bar_w = depth_cluster_w / s_count.to_double()
      let overlap_frac2 = overlap_pct.to_double() / 100.0
      let bar_w = raw_bar_w *
        (1.0 + overlap_frac2 * (s_count - 1).to_double() / s_count.to_double())
      // §21.2.2.221 varyColors — when true and there is only one
      // series, each bar gets the next accent colour so the cluster
      // visually distinguishes categories.
      let vary_colors = chart_vary_colors(elem)
      for si, s in series {
        let (_, values) = s
        let color = resolve_series_color(ser_elems[si], si, ctx, defs)
        let dpt_overrides = dpt_overrides_by_series[si]
        for point in chart_rendered_points(values, disp_blanks_as) {
          let (i, v) = point
          if i >= cat_count {
            break
          }
          // §21.2.2.170 — minMax: column base at the bottom, grows up.
          // maxMin: value 0 sits at the top (py) and the column grows
          // DOWNWARD to the value's pixel y.
          let y0 = value_axis_y_span(0.0, min_v, max_v, py, ph, val_rev)
          let yv = value_axis_y_span(v, min_v, max_v, py, ph, val_rev)
          let by = if y0 < yv { y0 } else { yv }
          let hgt = if y0 < yv { yv - y0 } else { y0 - yv }
          // catAx maxMin reverses the category band order along X.
          let bx = date_axis_position_for_index(
              px, pw, cat_count, i, cat_rev, cat_cross, axes, cat_serials,
            ) -
            cluster_w / 2.0 +
            depth_pad_w +
            si.to_double() * bar_w
          let fill = match dpt_color_for(dpt_overrides, i) {
            Some(c) => c
            None =>
              if vary_colors && s_count == 1 {
                chart_series_color(ctx, i)
              } else {
                color
              }
          }
          let fill = bar_fill_for_value(fill, v, invert_negative_by_series[si])
          for
            n in render_bar_shape_nodes(
              bx,
              by,
              bar_w,
              hgt,
              fill,
              bar_shapes[si],
              false,
              val_rev,
            ) {
            nodes.push(n)
          }
        }
      }
    }
    if !axes.cat_deleted() && axes.cat_tick_lbl_pos() != "none" {
      // §21.2.2.175 tickLblSkip — show every Nth label; 0 / 1 = all.
      let label_side = axes.cat_tick_lbl_pos()
      let anchor = category_label_anchor(axes)
      let lbl_offset_frac = axes.cat_lbl_offset().to_double() / 100.0
      let label_offset = fh * 0.018 + fh * 0.05 * lbl_offset_frac
      for i, label in labels {
        if i >= cat_count {
          break
        }
        if !date_axis_label_should_render(axes, cat_serials, i) {
          continue
        }
        // catAx maxMin reverses the category label position to match
        // the reversed column bands.
        let bx = date_axis_position_for_index(
          px, pw, cat_count, i, cat_rev, cat_cross, axes, cat_serials,
        )
        let (by, baseline) = category_horizontal_label_y(
          py, horizontal_axis_y, label_side, label_offset,
        )
        nodes.push(
          chart_text(label, bx, by, w, h, anchor~, baseline~, style=Some(style)),
        )
      }
    }
  }
  // §21.2.2.49 dLbls — render data labels above each bar.
  match dlbl_config {
    Some(cfg) => {
      let label_offset = -(fh * 0.012)
      let label_axis_max = if bar_dir == "bar" {
        axes.val_x_scaling_max()
      } else {
        axes.val_y_scaling_max()
      }
      for si, s in series {
        let (labels_s, values) = s
        let ser_name = match read_series_name(ser_elems[si]) {
          Some(n) => n
          None => ""
        }
        let value_num_fmt = read_val_number_format(ser_elems[si])
        let series_color = resolve_series_color(ser_elems[si], si, ctx, defs)
        let total = sum_positive_slots(values, disp_blanks_as)
        let points : Array[DataLabelPoint] = []
        if bar_dir == "bar" {
          // Horizontal: label at the value (far) end of the bar — the
          // right end for minMax, the left end for maxMin.  Tracks the
          // same band/value mapping the bar geometry uses.
          for point in chart_rendered_points(values, disp_blanks_as) {
            let (i, v) = point
            if i >= cat_count {
              break
            }
            let by = category_axis_position_for_cross(
              py,
              ph,
              cat_count,
              i,
              !cat_rev,
              cat_cross,
            )
            let x_v = value_axis_x_span(v, min_v, max_v, px, pw, val_rev)
            let lbl_x = if val_rev {
              x_v - fw * 0.008
            } else {
              x_v + fw * 0.008
            }
            let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
            points.push({
              idx: i,
              x: lbl_x,
              y: by,
              value: v,
              cat_name,
              bubble_size: None,
            })
          }
        } else {
          // Vertical: label at the value (far) end of the column — above
          // the column for minMax, below for maxMin.
          for point in chart_rendered_points(values, disp_blanks_as) {
            let (i, v) = point
            if i >= cat_count {
              break
            }
            let bx = date_axis_position_for_index(
              px, pw, cat_count, i, cat_rev, cat_cross, axes, cat_serials,
            )
            let by = value_axis_y_span(v, min_v, max_v, py, ph, val_rev)
            let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
            points.push({
              idx: i,
              x: bx,
              y: by,
              value: v,
              cat_name,
              bubble_size: None,
            })
          }
        }
        for
          n in render_data_labels(
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
            max_value=label_axis_max,
          ) {
          nodes.push(n)
        }
      }
    }
    None => ()
  }
  nodes
}
