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
          let labels = read_cat_labels(se)
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
  let band = pw / n.to_double()
  let tick_w = band * 0.25
  let stroke_w = format_double(h * 0.003)
  let series_color = chart_series_color(ctx, 0)
  let mut i = 0
  while i < n {
    let x = px + (i.to_double() + 0.5) * band
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
    let y_hi = if max_v > 0.0 { py + ph - hi / max_v * ph } else { py + ph }
    let y_lo = if max_v > 0.0 { py + ph - lo / max_v * ph } else { py + ph }
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
        let y_o = if max_v > 0.0 { py + ph - ov / max_v * ph } else { py + ph }
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
        let y_c = if max_v > 0.0 { py + ph - cv / max_v * ph } else { py + ph }
        let open_for_bar = chart_slot_value_at(open_vals, i, disp_blanks_as)
        if has_up_down && open_for_bar is Some(_) {
          // §21.2.2.219 — filled rectangle from open to close.
          let ov = match open_for_bar {
            Some(v) => v
            None => 0.0
          }
          let y_o = if max_v > 0.0 {
            py + ph - ov / max_v * ph
          } else {
            py + ph
          }
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
  for i2, label in labels {
    if i2 >= n {
      break
    }
    let bx = px + (i2.to_double() + 0.5) * band
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
  nodes
}
