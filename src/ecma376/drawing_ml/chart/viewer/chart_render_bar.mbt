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
  let ser_elems : Array[@xml.Element] = []
  let series : Array[(Array[String], Array[Double?])] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_labels(se)
          let values = read_val_number_slots(se)
          if values.length() > 0 {
            ser_elems.push(se)
            series.push((labels, values))
          }
        }
      _ => ()
    }
  }
  if series.length() == 0 {
    return []
  }
  let (labels, _) = series[0]
  // §21.2.2.170 — compute axis range respecting explicit min/max.
  let mut data_max = 0.0
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
    }
  }
  // §21.2.2.76 — percentStacked ceiling is always 100 (no overshoot).
  let max_v = if grouping == "percentStacked" {
    100.0
  } else {
    effective_axis_max(data_max, axes)
  }
  let is_percent = grouping == "percentStacked"
  // §21.2.2.170 CT_Scaling / orientation — maxMin reverses the axis.
  // `val_rev` flips the value axis (column grows DOWNWARD from the
  // top / horizontal bar grows LEFTWARD from the right); `cat_rev`
  // flips the category band order.
  let val_rev = axes.val_reversed()
  let cat_rev = axes.cat_reversed()
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let nodes : Array[@xml.Node] = []
  if !axes.val_deleted() || !axes.cat_deleted() {
    nodes.push(plot_axes_rect(px, py, pw, ph, style=Some(style)))
  }
  let cat_count = {
    let (l0, v0) = series[0]
    if l0.length() > v0.length() {
      v0.length()
    } else {
      v0.length()
    }
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
  let dpt_overrides_by_series : Array[Array[(Int, String)]] = []
  for si, se in ser_elems {
    dpt_overrides_by_series.push(
      collect_dpt_colors(se, ctx, defs, "ser" + si.to_string()),
    )
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
          reversed=val_rev,
        ) {
        nodes.push(n)
      }
    }
    if !axes.cat_deleted() {
      for n in category_axis_ticks_left(px, py, pw, ph, fw, cat_count) {
        nodes.push(n)
      }
      if cat_count > 0 {
        let band_h = ph / cat_count.to_double()
        let minor_half = fw * 0.0056
        let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
        let mut i = 0
        while i < cat_count {
          let yc = py + (i.to_double() + 0.5) * band_h
          nodes.push(
            axis_tick_h_line(
              px - minor_half,
              px + minor_half,
              yc,
              chart_default_axis_color,
              tick_stroke,
            ),
          )
          i = i + 1
        }
      }
    }
    let band = ph / cat_count.to_double()
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
        let band_idx = if cat_rev { i_idx } else { cat_count - 1 - i_idx }
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
          let (x_start, len) = if val_rev {
            let x_lo = value_axis_x(accum, max_v, px, pw, true)
            let x_hi = value_axis_x(accum + norm_v, max_v, px, pw, true)
            let xs = if x_lo < x_hi { x_lo } else { x_hi }
            let ln = if x_lo < x_hi { x_hi - x_lo } else { x_lo - x_hi }
            (xs, ln)
          } else {
            let ln = if max_v > 0.0 { norm_v / max_v * pw } else { 0.0 }
            let xs = if max_v > 0.0 { px + accum / max_v * pw } else { px }
            (xs, ln)
          }
          let by = py + band_idx.to_double() * band + sub_pad
          let color = resolve_series_color(ser_elems[si], si, ctx, defs)
          let fill = match dpt_color_for(dpt_overrides_by_series[si], i_idx) {
            Some(c) => c
            None => color
          }
          nodes.push(
            @markup.elem_ns(
              "rect",
              @markup.svg_ns,
              [
                @markup.attr("x", format_double(x_start)),
                @markup.attr("y", format_double(by)),
                @markup.attr("width", format_double(len)),
                @markup.attr("height", format_double(sub_h)),
                @markup.attr("fill", fill),
              ],
              [],
            ),
          )
          accum = accum + norm_v
        }
      }
    } else {
      // Clustered bars with §21.2.2.131 overlap support.
      let sub_band = band * cluster_ratio
      let sub_pad = (band - sub_band) / 2.0
      // overlap_pct > 0 means bars overlap; each bar is wider than
      // sub_band/n and positioned to overlap by that percentage.
      let raw_bar_h = sub_band / s_count.to_double()
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
          let (bar_x, len) = if val_rev {
            let x_v = value_axis_x(v, max_v, px, pw, true)
            (x_v, px + pw - x_v)
          } else {
            (px, if max_v > 0.0 { v / max_v * pw } else { 0.0 })
          }
          // Horizontal bars plot Q1 at the bottom by convention; catAx
          // maxMin un-reverses that ordering.
          let band_idx = if cat_rev { i } else { cat_count - 1 - i }
          let by = py +
            band_idx.to_double() * band +
            sub_pad +
            si.to_double() * bar_h
          let fill = match dpt_color_for(dpt_overrides, i) {
            Some(c) => c
            None => color
          }
          nodes.push(
            @markup.elem_ns(
              "rect",
              @markup.svg_ns,
              [
                @markup.attr("x", format_double(bar_x)),
                @markup.attr("y", format_double(by)),
                @markup.attr("width", format_double(len)),
                @markup.attr("height", format_double(bar_h)),
                @markup.attr("fill", fill),
              ],
              [],
            ),
          )
        }
      }
    }
    if !axes.cat_deleted() {
      for i, label in labels {
        if i >= cat_count {
          break
        }
        // Label band must track the bar band under catAx maxMin.
        let band_idx = if cat_rev { i } else { cat_count - 1 - i }
        let by = py + band_idx.to_double() * band + band / 2.0
        nodes.push(
          chart_text(
            label,
            px - fw * 0.006,
            by,
            w,
            h,
            anchor="end",
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
          num_fmt=axes.val_num_fmt(),
          tick_lbl_pos=axes.val_tick_lbl_pos(),
          log_base=log_b,
          reversed=val_rev,
        ) {
        nodes.push(n)
      }
    }
    if !axes.cat_deleted() {
      for n in category_axis_ticks_bottom(px, py, pw, ph, fh, cat_count) {
        nodes.push(n)
      }
    }
    let band = pw / cat_count.to_double()
    if grouping == "stacked" || grouping == "percentStacked" {
      // §21.2.2.76 stacked / percentStacked vertical columns.
      // Default gapWidth=150 → col_ratio = 1/(1+1.5) ≈ 0.4.
      let col_w = band * cluster_ratio
      let pad = (band - col_w) / 2.0
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
          let (rect_y, hgt) = if val_rev {
            let y_lo = value_axis_y(accum, max_v, py, ph, true)
            let y_hi = value_axis_y(accum + norm_v, max_v, py, ph, true)
            let yt = if y_lo < y_hi { y_lo } else { y_hi }
            let hh = if y_lo < y_hi { y_hi - y_lo } else { y_lo - y_hi }
            (yt, hh)
          } else {
            let hh = if max_v > 0.0 { norm_v / max_v * ph } else { 0.0 }
            let y_base = if max_v > 0.0 {
              py + ph - accum / max_v * ph
            } else {
              py + ph
            }
            (y_base - hh, hh)
          }
          // catAx maxMin reverses the category band order along X.
          let cat_pos = category_index(i_idx, cat_count, cat_rev)
          let bx = px + cat_pos.to_double() * band + pad
          let color = resolve_series_color(ser_elems[si], si, ctx, defs)
          let fill = match dpt_color_for(dpt_overrides_by_series[si], i_idx) {
            Some(c) => c
            None => color
          }
          nodes.push(
            @markup.elem_ns(
              "rect",
              @markup.svg_ns,
              [
                @markup.attr("x", format_double(bx)),
                @markup.attr("y", format_double(rect_y)),
                @markup.attr("width", format_double(col_w)),
                @markup.attr("height", format_double(hgt)),
                @markup.attr("fill", fill),
              ],
              [],
            ),
          )
          accum = accum + norm_v
        }
      }
    } else {
      // Clustered columns with §21.2.2.131 overlap.
      let cluster_w = band * cluster_ratio
      let pad = (band - cluster_w) / 2.0
      let raw_bar_w = cluster_w / s_count.to_double()
      let overlap_frac2 = overlap_pct.to_double() / 100.0
      let bar_w = raw_bar_w *
        (1.0 + overlap_frac2 * (s_count - 1).to_double() / s_count.to_double())
      // §21.2.2.221 varyColors — when true and there is only one
      // series, each bar gets the next accent colour so the cluster
      // visually distinguishes categories.
      let vary_colors = match first_child_named(elem, "varyColors") {
        Some(e) => chart_bool_default_true(e)
        None => false
      }
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
          let (by, hgt) = if val_rev {
            let y0 = value_axis_y(0.0, max_v, py, ph, true)
            let yv = value_axis_y(v, max_v, py, ph, true)
            let yt = if y0 < yv { y0 } else { yv }
            let hh = if y0 < yv { yv - y0 } else { y0 - yv }
            (yt, hh)
          } else {
            let hh = if max_v > 0.0 { v / max_v * ph } else { 0.0 }
            (py + ph - hh, hh)
          }
          // catAx maxMin reverses the category band order along X.
          let cat_pos = category_index(i, cat_count, cat_rev)
          let bx = px +
            cat_pos.to_double() * band +
            pad +
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
          nodes.push(
            @markup.elem_ns(
              "rect",
              @markup.svg_ns,
              [
                @markup.attr("x", format_double(bx)),
                @markup.attr("y", format_double(by)),
                @markup.attr("width", format_double(bar_w)),
                @markup.attr("height", format_double(hgt)),
                @markup.attr("fill", fill),
              ],
              [],
            ),
          )
        }
      }
    }
    if !axes.cat_deleted() {
      // §21.2.2.175 tickLblSkip — show every Nth label; 0 / 1 = all.
      let lbl_skip = axes.cat_tick_lbl_skip()
      let skip = if lbl_skip <= 1 { 1 } else { lbl_skip }
      let lbl_offset_frac = axes.cat_lbl_offset().to_double() / 100.0
      for i, label in labels {
        if i >= cat_count {
          break
        }
        if i % skip != 0 {
          continue
        }
        // catAx maxMin reverses the category label position to match
        // the reversed column bands.
        let cat_pos = category_index(i, cat_count, cat_rev)
        let bx = px + cat_pos.to_double() * band + band / 2.0
        let by = py + ph + fh * 0.018 + fh * 0.05 * lbl_offset_frac
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
    }
  }
  // §21.2.2.49 dLbls — render data labels above each bar.
  match dlbl_config {
    Some(cfg) => {
      let label_offset = -(fh * 0.012)
      for si, s in series {
        let (labels_s, values) = s
        let ser_name = match read_series_name(ser_elems[si]) {
          Some(n) => n
          None => ""
        }
        let total = sum_positive_slots(values, disp_blanks_as)
        let points : Array[(Double, Double, Double, String)] = []
        if bar_dir == "bar" {
          // Horizontal: label at the value (far) end of the bar — the
          // right end for minMax, the left end for maxMin.  Tracks the
          // same band/value mapping the bar geometry uses.
          for point in chart_rendered_points(values, disp_blanks_as) {
            let (i, v) = point
            if i >= cat_count {
              break
            }
            let band2 = ph / cat_count.to_double()
            let band_idx = if cat_rev { i } else { cat_count - 1 - i }
            let by = py + band_idx.to_double() * band2 + band2 / 2.0
            let x_v = value_axis_x(v, max_v, px, pw, val_rev)
            let lbl_x = if val_rev {
              x_v - fw * 0.008
            } else {
              x_v + fw * 0.008
            }
            let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
            points.push((lbl_x, by, v, cat_name))
          }
        } else {
          // Vertical: label at the value (far) end of the column — above
          // the column for minMax, below for maxMin.
          let band2 = pw / cat_count.to_double()
          for point in chart_rendered_points(values, disp_blanks_as) {
            let (i, v) = point
            if i >= cat_count {
              break
            }
            let cat_pos = category_index(i, cat_count, cat_rev)
            let bx = px + cat_pos.to_double() * band2 + band2 / 2.0
            let by = value_axis_y(v, max_v, py, ph, val_rev)
            let cat_name = if i < labels_s.length() { labels_s[i] } else { "" }
            points.push((bx, by, v, cat_name))
          }
        }
        for
          n in render_data_labels(
            cfg, points, ser_name, total, w, h, label_offset, style,
          ) {
          nodes.push(n)
        }
      }
    }
    None => ()
  }
  nodes
}
