// =============================================================================
// §21.2.2.188 CT_StockChart — stock (OHLC / HLC) chart renderer.
// The standard stock chart carries 3 or 4 series representing
// Open / High / Low / Close (or just High / Low / Close). Each
// category (date) is drawn as a vertical line from High to Low with
// horizontal tick marks for Open (left) and Close (right).
// =============================================================================

///|
fn render_stock_chart(
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
  // §21.2.2.188 — the series order is fixed by convention:
  // 4 series = Open, High, Low, Close
  // 3 series = High, Low, Close
  let all_series : Array[(Array[String], Array[Double?])] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_axis_labels(se, axes)
          let values = read_val_number_slots(se)
          all_series.push((labels, values))
        }
      _ => ()
    }
  }
  let s_count = all_series.length()
  if s_count < 3 {
    return []
  }
  // Determine series indices based on count.
  let (open_idx, high_idx, low_idx, close_idx) = if s_count >= 4 {
    (Some(0), 1, 2, 3)
  } else {
    (None, 0, 1, 2)
  }
  let (labels, _) = all_series[high_idx]
  let cat_serials = if high_idx < s_count {
    let ser = {
      let mut found : @xml.Element? = None
      let mut idx = 0
      for ch in elem.children {
        match ch {
          @xml.Node::Element(se) =>
            if se.name.local_name == "ser" {
              if idx == high_idx {
                found = Some(se)
                break
              }
              idx = idx + 1
            }
          _ => ()
        }
      }
      found
    }
    match ser {
      Some(se) => read_cat_number_slots(se)
      None => []
    }
  } else {
    []
  }
  let (_, high_vals) = all_series[high_idx]
  let (_, low_vals) = all_series[low_idx]
  let (_, close_vals) = all_series[close_idx]
  let open_vals : Array[Double?] = match open_idx {
    Some(oi) => {
      let (_, v) = all_series[oi]
      v
    }
    None => []
  }
  let n = if high_vals.length() < low_vals.length() {
    high_vals.length()
  } else {
    low_vals.length()
  }
  if n == 0 {
    return []
  }
  // Compute the overall data max/min across all price series.
  let mut data_max = 0.0
  let mut data_min = 1.0e18
  for s in all_series {
    let (_, values) = s
    for point in chart_rendered_points(values, disp_blanks_as) {
      let (_, v) = point
      if v > data_max {
        data_max = v
      }
      if v < data_min {
        data_min = v
      }
    }
  }
  if data_min > data_max {
    data_min = 0.0
  }
  let max_v = effective_axis_max(data_max, axes)
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
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
  // §21.2.2.219 upDownBars — when present, draw filled rectangles
  // between open and close: green (up) when close > open, red (down)
  // when close < open.
  let has_up_down = match first_child_named(elem, "upDownBars") {
    Some(_) => true
    None => false
  }
  let band = category_axis_slot_span_for_cross(pw, n, cat_cross)
  let tick_w = band * 0.25
  let stroke_w = format_double(h * 0.003)
  let series_color = chart_series_color(ctx, 0)
  let mut i = 0
  while i < n {
    let x = date_axis_position_for_index(
      px, pw, n, i, cat_rev, cat_cross, axes, cat_serials,
    )
    let hi = match chart_slot_value_at(high_vals, i, disp_blanks_as) {
      Some(v) => v
      None => {
        i = i + 1
        continue
      }
    }
    let lo = match chart_slot_value_at(low_vals, i, disp_blanks_as) {
      Some(v) => v
      None => {
        i = i + 1
        continue
      }
    }
    let y_hi = value_axis_y(hi, max_v, py, ph, val_rev)
    let y_lo = value_axis_y(lo, max_v, py, ph, val_rev)
    // Vertical line High → Low.
    nodes.push(
      @markup.elem_ns(
        "line",
        @markup.svg_ns,
        [
          @markup.attr("x1", format_double(x)),
          @markup.attr("y1", format_double(y_hi)),
          @markup.attr("x2", format_double(x)),
          @markup.attr("y2", format_double(y_lo)),
          @markup.attr("stroke", series_color),
          @markup.attr("stroke-width", stroke_w),
        ],
        [],
      ),
    )
    // Open tick (left side).
    match chart_slot_value_at(open_vals, i, disp_blanks_as) {
      Some(ov) => {
        let y_o = value_axis_y(ov, max_v, py, ph, val_rev)
        nodes.push(
          @markup.elem_ns(
            "line",
            @markup.svg_ns,
            [
              @markup.attr("x1", format_double(x - tick_w)),
              @markup.attr("y1", format_double(y_o)),
              @markup.attr("x2", format_double(x)),
              @markup.attr("y2", format_double(y_o)),
              @markup.attr("stroke", series_color),
              @markup.attr("stroke-width", stroke_w),
            ],
            [],
          ),
        )
      }
      None => ()
    }
    // Close tick (right side) or upDownBar rectangle.
    match chart_slot_value_at(close_vals, i, disp_blanks_as) {
      Some(cv) => {
        let y_c = value_axis_y(cv, max_v, py, ph, val_rev)
        let open_for_bar = chart_slot_value_at(open_vals, i, disp_blanks_as)
        if has_up_down && open_for_bar is Some(_) {
          // §21.2.2.219 — filled rectangle from open to close.
          let ov = match open_for_bar {
            Some(v) => v
            None => 0.0
          }
          let y_o = value_axis_y(ov, max_v, py, ph, val_rev)
          let fill = if cv >= ov {
            chart_stock_up_color
          } else {
            chart_stock_down_color
          }
          let y_top = if y_o < y_c { y_o } else { y_c }
          let bar_height = if y_o < y_c { y_c - y_o } else { y_o - y_c }
          let bar_w = band * 0.3
          nodes.push(
            @markup.elem_ns(
              "rect",
              @markup.svg_ns,
              [
                @markup.attr("x", format_double(x - bar_w / 2.0)),
                @markup.attr("y", format_double(y_top)),
                @markup.attr("width", format_double(bar_w)),
                @markup.attr("height", format_double(bar_height)),
                @markup.attr("fill", fill),
                @markup.attr("stroke", series_color),
                @markup.attr("stroke-width", stroke_w),
              ],
              [],
            ),
          )
        } else {
          nodes.push(
            @markup.elem_ns(
              "line",
              @markup.svg_ns,
              [
                @markup.attr("x1", format_double(x)),
                @markup.attr("y1", format_double(y_c)),
                @markup.attr("x2", format_double(x + tick_w)),
                @markup.attr("y2", format_double(y_c)),
                @markup.attr("stroke", series_color),
                @markup.attr("stroke-width", stroke_w),
              ],
              [],
            ),
          )
        }
      }
      None => ()
    }
    i = i + 1
  }
  // Category labels along the bottom.
  if !axes.cat_deleted() && axes.cat_tick_lbl_pos() != "none" {
    let label_side = axes.cat_tick_lbl_pos()
    let label_offset = category_horizontal_label_offset(fh, axes)
    let anchor = category_label_anchor(axes)
    for i2, label in labels {
      if i2 >= n {
        break
      }
      if !date_axis_label_should_render(axes, cat_serials, i2) {
        continue
      }
      let bx = date_axis_position_for_index(
        px, pw, n, i2, cat_rev, cat_cross, axes, cat_serials,
      )
      let (by, baseline) = category_horizontal_label_y(
        py, category_axis_y, label_side, label_offset,
      )
      nodes.push(
        chart_text(label, bx, by, w, h, anchor~, baseline~, style=Some(style)),
      )
    }
  }
  nodes
}
