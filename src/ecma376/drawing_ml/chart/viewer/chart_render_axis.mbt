// =============================================================================
// Shared axis helpers.
// =============================================================================

///|
/// Axis lines for the plot area.
/// Stroke colour uses the §21.2 implementation default mid-grey axis
/// colour (`#bfbfbf`).
fn plot_axes_rect(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
  style? : ChartStyleDefaults? = None,
  vertical_axis_x? : Double? = None,
  horizontal_axis_y? : Double? = None,
) -> @xml.Node {
  let axis_color = match style {
    Some(s) => s.axis_color
    None => chart_default_axis_color
  }
  let vx = vertical_axis_x.unwrap_or(px)
  let hy = horizontal_axis_y.unwrap_or(py + ph)
  let stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let group_kids : Array[@xml.Node] = [
    // Vertical axis line.
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", format_double(vx)),
        @markup.attr("y1", format_double(py)),
        @markup.attr("x2", format_double(vx)),
        @markup.attr("y2", format_double(py + ph)),
        @markup.attr("stroke", axis_color),
        @markup.attr("stroke-width", stroke),
      ],
      [],
    ),
    // Horizontal axis line.
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", format_double(px)),
        @markup.attr("y1", format_double(hy)),
        @markup.attr("x2", format_double(px + pw)),
        @markup.attr("y2", format_double(hy)),
        @markup.attr("stroke", axis_color),
        @markup.attr("stroke-width", stroke),
      ],
      [],
    ),
  ]
  @markup.elem_ns("g", @markup.svg_ns, [], group_kids)
}

///|
/// §21.2.2.170 CT_Scaling / orientation — the single source of truth
/// for mapping a value-axis VALUE to its normalised position fraction
/// in `[0, 1]` along the axis, where `0` is the origin (axis line) end
/// and `1` is the far end.
///
/// `f0` is the natural (minMax) fraction — `v / max_v` for the common
/// zero-based value axes, or the logarithmic fraction from
/// `log_scale_frac`, or `(v - min) / span` for scatter/bubble.  When
/// `reversed` (orientation="maxMin") the fraction is flipped to
/// `1 - f0` so a HIGH value lands near the origin end (bottom of a
/// vertical axis / left of a horizontal one) and a LOW value lands at
/// the far end.
///
/// BOTH the data-point path and the tick/gridline/label path call this
/// helper with the SAME `reversed` flag, so data and ticks can never
/// diverge.  When `reversed` is false the result is `f0` unchanged —
/// the identity — keeping the default (minMax) output byte-identical.
fn axis_fraction(f0 : Double, reversed : Bool) -> Double {
  if reversed {
    1.0 - f0
  } else {
    f0
  }
}

///|
/// §21.2.2.170 — value→fraction for the common zero-based value axis.
/// Returns `v / max_v` (clamped to a defined value when `max_v <= 0`)
/// then applies the orientation flip via `axis_fraction`.
fn value_axis_fraction(v : Double, max_v : Double, reversed : Bool) -> Double {
  let f0 = if max_v > 0.0 { v / max_v } else { 0.0 }
  axis_fraction(f0, reversed)
}

///|
/// §21.2.2.170 — value→fraction for a value axis with an explicit,
/// possibly non-zero, origin (scatter / bubble).  `span` is
/// `max - min`; the caller guarantees `span > 0`.
fn span_axis_fraction(
  v : Double,
  min_v : Double,
  span : Double,
  reversed : Bool,
) -> Double {
  let f0 = (v - min_v) / span
  axis_fraction(f0, reversed)
}

///|
/// §21.2.2.170 — map a value to a VERTICAL pixel y inside the plot
/// rectangle `[py, py + ph]`.  At fraction 0 (axis-line end) the y is
/// `py + ph` (bottom); at fraction 1 it is `py` (top).  Routing every
/// vertical value→pixel mapping through this keeps the column/line/
/// area data and the y-axis ticks aligned under orientation flips.
fn value_axis_y(
  v : Double,
  max_v : Double,
  py : Double,
  ph : Double,
  reversed : Bool,
) -> Double {
  let f = value_axis_fraction(v, max_v, reversed)
  py + ph - f * ph
}

///|
/// §21.2.2.170 — map a value to vertical pixel y for an arbitrary
/// axis domain `[min_v, max_v]`.  This is the signed-domain companion
/// to `value_axis_y`; bar/column charts use it when negative values
/// make the zero line fall inside the plot rectangle.
fn value_axis_y_span(
  v : Double,
  min_v : Double,
  max_v : Double,
  py : Double,
  ph : Double,
  reversed : Bool,
) -> Double {
  let span = max_v - min_v
  let f = if span > 0.0 {
    span_axis_fraction(v, min_v, span, reversed)
  } else {
    0.0
  }
  py + ph - f * ph
}

///|
/// §21.2.2.170 — map a value to a HORIZONTAL pixel x inside the plot
/// rectangle `[px, px + pw]`.  At fraction 0 (axis-line end) the x is
/// `px` (left); at fraction 1 it is `px + pw` (right).  Used by the
/// horizontal (barDir="bar") value axis so bars and the x-axis value
/// ticks flip together.
fn value_axis_x(
  v : Double,
  max_v : Double,
  px : Double,
  pw : Double,
  reversed : Bool,
) -> Double {
  let f = value_axis_fraction(v, max_v, reversed)
  px + f * pw
}

///|
/// §21.2.2.170 — map a value to horizontal pixel x for an arbitrary
/// axis domain `[min_v, max_v]`.
fn value_axis_x_span(
  v : Double,
  min_v : Double,
  max_v : Double,
  px : Double,
  pw : Double,
  reversed : Bool,
) -> Double {
  let span = max_v - min_v
  let f = if span > 0.0 {
    span_axis_fraction(v, min_v, span, reversed)
  } else {
    0.0
  }
  px + f * pw
}

///|
/// Clamp an axis crossing value into the rendered axis range.
fn clamp_axis_cross_value(v : Double, min_v : Double, max_v : Double) -> Double {
  if v < min_v {
    min_v
  } else if v > max_v {
    max_v
  } else {
    v
  }
}

///|
/// §21.2.2.35 / §21.2.2.36 — resolve crosses/crossesAt on a VALUE
/// axis into the numeric value where the perpendicular axis is drawn.
/// `crossesAt` is an explicit axis value; otherwise "max" and "min"
/// select the corresponding range edge, and "autoZero" selects zero
/// when it is inside the range or the nearest visible edge when not.
fn value_axis_cross_value(
  min_v : Double,
  max_v : Double,
  crosses : String,
  crosses_at : Double?,
) -> Double {
  match crosses_at {
    Some(v) => return clamp_axis_cross_value(v, min_v, max_v)
    None => ()
  }
  if crosses == "max" {
    max_v
  } else if crosses == "min" {
    min_v
  } else if min_v <= 0.0 && 0.0 <= max_v {
    0.0
  } else if 0.0 < min_v {
    min_v
  } else {
    max_v
  }
}

///|
/// §21.2.2.35 / §21.2.2.36 — y position where a horizontal axis
/// crosses a vertical value axis.
fn value_axis_cross_y(
  py : Double,
  ph : Double,
  min_v : Double,
  max_v : Double,
  reversed : Bool,
  crosses : String,
  crosses_at : Double?,
) -> Double {
  let v = value_axis_cross_value(min_v, max_v, crosses, crosses_at)
  let span = max_v - min_v
  let f0 = if span > 0.0 { (v - min_v) / span } else { 0.0 }
  let f = axis_fraction(f0, reversed)
  py + ph - f * ph
}

///|
/// §21.2.2.35 / §21.2.2.36 — x position where a vertical axis
/// crosses a horizontal value axis.
fn value_axis_cross_x(
  px : Double,
  pw : Double,
  min_v : Double,
  max_v : Double,
  reversed : Bool,
  crosses : String,
  crosses_at : Double?,
) -> Double {
  let v = value_axis_cross_value(min_v, max_v, crosses, crosses_at)
  let span = max_v - min_v
  let f0 = if span > 0.0 { (v - min_v) / span } else { 0.0 }
  let f = axis_fraction(f0, reversed)
  px + f * pw
}

///|
/// §21.2.2.34 crossBetween — size of one category interval along the
/// category axis. `between` places categories in bands between tick
/// marks; `midCat` places the category midpoint on the crossing axis.
fn category_axis_slot_span_for_cross(
  length : Double,
  cat_count : Int,
  cross_between : String,
) -> Double {
  if cat_count <= 0 {
    return 0.0
  }
  if cross_between == "midCat" && cat_count > 1 {
    length / (cat_count - 1).to_double()
  } else {
    length / cat_count.to_double()
  }
}

///|
/// §21.2.2.34 crossBetween — map a possibly fractional 0-based
/// category coordinate to a pixel/EMU position on a horizontal category
/// axis. This is the SoT used by data points, labels, trendlines, and
/// category ticks.
fn category_axis_fractional_position_for_cross(
  origin : Double,
  length : Double,
  cat_count : Int,
  coord : Double,
  reversed : Bool,
  cross_between : String,
) -> Double {
  if cat_count <= 0 {
    return origin
  }
  let mapped = if reversed {
    (cat_count - 1).to_double() - coord
  } else {
    coord
  }
  if cross_between == "midCat" {
    if cat_count > 1 {
      origin + mapped * (length / (cat_count - 1).to_double())
    } else {
      origin
    }
  } else {
    origin + (mapped + 0.5) * (length / cat_count.to_double())
  }
}

///|
/// Integer-category companion of
/// `category_axis_fractional_position_for_cross`.
fn category_axis_position_for_cross(
  origin : Double,
  length : Double,
  cat_count : Int,
  index : Int,
  reversed : Bool,
  cross_between : String,
) -> Double {
  category_axis_fractional_position_for_cross(
    origin,
    length,
    cat_count,
    index.to_double(),
    reversed,
    cross_between,
  )
}

///|
fn date_axis_coord_value(
  serial : Double,
  unit : String,
  date_system : @date_serial.DateSystem,
) -> Double {
  try @date_serial.serial_to_date_time(serial, date_system) catch {
    _ => serial
  } noraise {
    dt =>
      match unit {
        "years" => dt.year.to_double()
        "months" => (dt.year * 12 + dt.month - 1).to_double()
        _ => serial
      }
  }
}

///|
fn date_axis_bucket_value(
  serial : Double,
  unit : String,
  date_system : @date_serial.DateSystem,
) -> Int {
  try @date_serial.serial_to_date_time(serial, date_system) catch {
    _ => serial.to_int()
  } noraise {
    dt =>
      match unit {
        "years" => dt.year
        "months" => dt.year * 12 + dt.month
        _ => dt.year * 10000 + dt.month * 100 + dt.day
      }
  }
}

///|
fn date_axis_serial_range(
  serials : Array[Double?],
  base_unit : String,
  date_system : @date_serial.DateSystem,
) -> (Double, Double, Bool) {
  let mut found = false
  let mut min_v = 0.0
  let mut max_v = 0.0
  for slot in serials {
    match slot {
      Some(serial) => {
        let v = date_axis_coord_value(serial, base_unit, date_system)
        if !found {
          found = true
          min_v = v
          max_v = v
        } else {
          if v < min_v {
            min_v = v
          }
          if v > max_v {
            max_v = v
          }
        }
      }
      None => ()
    }
  }
  (min_v, max_v, found && max_v > min_v)
}

///|
fn date_axis_position_for_index(
  origin : Double,
  length : Double,
  cat_count : Int,
  index : Int,
  reversed : Bool,
  cross_between : String,
  axes : ChartAxesInfo,
  serials : Array[Double?],
) -> Double {
  if !axes.cat_is_date_axis() || index < 0 || index >= serials.length() {
    return category_axis_position_for_cross(
      origin, length, cat_count, index, reversed, cross_between,
    )
  }
  match serials[index] {
    Some(serial) => {
      let unit = axes.cat_base_time_unit()
      let (min_v, max_v, ok) = date_axis_serial_range(
        serials,
        unit,
        axes.date_system,
      )
      if !ok {
        return category_axis_position_for_cross(
          origin, length, cat_count, index, reversed, cross_between,
        )
      }
      let v = date_axis_coord_value(serial, unit, axes.date_system)
      let f0 = (v - min_v) / (max_v - min_v)
      let f = axis_fraction(f0, reversed)
      origin + f * length
    }
    None =>
      category_axis_position_for_cross(
        origin, length, cat_count, index, reversed, cross_between,
      )
  }
}

///|
fn date_axis_unit_changed(
  serials : Array[Double?],
  index : Int,
  unit : String,
  date_system : @date_serial.DateSystem,
) -> Bool {
  if index <= 0 || index >= serials.length() {
    return true
  }
  match (serials[index - 1], serials[index]) {
    (Some(prev), Some(curr)) =>
      date_axis_bucket_value(prev, unit, date_system) !=
      date_axis_bucket_value(curr, unit, date_system)
    _ => true
  }
}

///|
fn date_axis_label_should_render(
  axes : ChartAxesInfo,
  serials : Array[Double?],
  index : Int,
) -> Bool {
  if !axes.cat_is_date_axis() || serials.length() == 0 {
    return category_label_should_render(axes, index)
  }
  date_axis_unit_changed(
    serials,
    index,
    axes.cat_major_time_unit(),
    axes.date_system,
  )
}

///|
fn date_axis_ticks_bottom(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
  fh : Double,
  cat_count : Int,
  axes : ChartAxesInfo,
  serials : Array[Double?],
  major_tick_mark? : String = "cross",
  minor_tick_mark? : String = "cross",
  cross_between? : String = "between",
  axis_y? : Double? = None,
  tick_mark_skip? : Int = 1,
) -> Array[@xml.Node] {
  if !axes.cat_is_date_axis() || serials.length() == 0 {
    return category_axis_ticks_bottom(
      px,
      py,
      pw,
      ph,
      fh,
      cat_count,
      major_tick_mark~,
      cross_between~,
      axis_y~,
      tick_mark_skip~,
    )
  }
  if cat_count <= 0 || major_tick_mark == "none" {
    return []
  }
  let axis_color = "#bfbfbf"
  let major_half = fh * 0.0121
  let minor_half = fh * 0.0075
  let tick_y = axis_y.unwrap_or(py + ph)
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  for i in 0..<serials.length() {
    match serials[i] {
      Some(_) => {
        let x = date_axis_position_for_index(
          px,
          pw,
          cat_count,
          i,
          axes.cat_reversed(),
          cross_between,
          axes,
          serials,
        )
        let major = date_axis_unit_changed(
          serials,
          i,
          axes.cat_major_time_unit(),
          axes.date_system,
        )
        if major {
          nodes.push(
            axis_tick_v_line(
              tick_y - major_half,
              tick_y + major_half,
              x,
              axis_color,
              tick_stroke,
            ),
          )
        } else if minor_tick_mark != "none" &&
          date_axis_unit_changed(
            serials,
            i,
            axes.cat_minor_time_unit(),
            axes.date_system,
          ) {
          nodes.push(
            axis_tick_v_line(
              tick_y - minor_half,
              tick_y + minor_half,
              x,
              axis_color,
              tick_stroke,
            ),
          )
        }
      }
      None => ()
    }
  }
  nodes
}

///|
/// §21.2.2.35 / §21.2.2.36 — position where the perpendicular axis
/// crosses a category axis. For category axes, "autoZero" behaves as
/// the visible minimum category edge; "max" selects the maximum category
/// edge. When `crossesAt` is present, the OOXML category coordinate is
/// treated as 1-based and mapped through the same category-position SoT
/// as data points, labels, and ticks.
fn category_axis_cross_position(
  origin : Double,
  length : Double,
  cat_count : Int,
  reversed : Bool,
  cross_between : String,
  crosses : String,
  crosses_at : Double?,
) -> Double {
  if cat_count <= 0 {
    return origin
  }
  match crosses_at {
    Some(raw) => {
      let max_coord = (cat_count - 1).to_double()
      let coord0 = raw - 1.0
      let coord = if coord0 < 0.0 {
        0.0
      } else if coord0 > max_coord {
        max_coord
      } else {
        coord0
      }
      return category_axis_fractional_position_for_cross(
        origin, length, cat_count, coord, reversed, cross_between,
      )
    }
    None => ()
  }
  if crosses == "max" {
    if reversed {
      origin
    } else {
      origin + length
    }
  } else if reversed {
    origin + length
  } else {
    origin
  }
}

///|
/// Pick a "nice" tick step that lands on whole-number boundaries and
/// generates 5..11 tick intervals. §21.2.2.170 axis auto-scaling
/// prefers (1·10^n, 2·10^n, 5·10^n) step sizes.
fn nice_axis_step(max_v : Double) -> Double {
  if max_v <= 0.0 {
    return 1.0
  }
  // Aim for 8..10 intervals — the default density places a tick
  // every 5 units on a 0–45 axis (9 intervals) and every 5 on a
  // 0–25 axis (5 intervals); target_intervals=10 picks the smaller
  // step (5 instead of 10) at the 45 boundary.
  let target_intervals = 10.0
  let raw_step = max_v / target_intervals
  let mut order = 1.0
  while order * 10.0 <= raw_step {
    order = order * 10.0
  }
  while order > raw_step {
    order = order / 10.0
  }
  let m = raw_step / order
  let candidates = [1.0, 2.0, 5.0, 10.0]
  for c in candidates {
    if c >= m {
      return c * order
    }
  }
  10.0 * order
}

///|
/// Y-axis tick labels and (optional) horizontal gridlines at every
/// "nice" step (1/2/5·10^n) from 0 up to `max_v`. Numeric tick labels
/// are rounded to integers when max ≥ 4 and to one decimal otherwise.
/// `draw_gridlines` follows the axis's `<c:majorGridlines/>` declaration
/// per §21.2.2.99 — gridlines are suppressed on absence and our
/// fixtures match that behaviour. Gridlines stay light grey when drawn.
///
/// `fw` is the outer chart frame width; the gap between tick label and
/// plot left edge is taken as ≈ 1.4% of the frame (§21.2 implementation
/// default: 6pt gap on a 432pt frame). The label uses anchor="end" so
/// it grows rightward toward the plot's left axis.
fn y_axis_ticks(
  px : Double,
  py : Double,
  ph : Double,
  max_v : Double,
  pw : Double,
  fw : Double,
  draw_gridlines : Bool,
  label_suffix? : String = "",
  log_base? : Double? = None,
  style? : ChartStyleDefaults? = None,
  tick_lbl_pos? : String = "nextTo",
  num_fmt? : String? = None,
  draw_minor_gridlines? : Bool = false,
  major_gridlines_element? : @xml.Element? = None,
  minor_gridlines_element? : @xml.Element? = None,
  ctx? : ColorResolveContext? = None,
  defs? : SvgDefsCollector? = None,
  major_tick_mark? : String = "cross",
  minor_tick_mark? : String = "cross",
  major_unit? : Double? = None,
  minor_unit? : Double? = None,
  reversed? : Bool = false,
  axis_x? : Double? = None,
  display_unit_factor? : Double? = None,
) -> Array[@xml.Node] {
  if max_v <= 0.0 {
    return []
  }
  let grid_color = match style {
    Some(s) => s.grid_color
    None => chart_default_grid_color
  }
  let axis_color = match style {
    Some(s) => s.axis_color
    None => chart_default_axis_color
  }
  // Cross-style tick mark half-lengths per §21.2.2.137 / §21.2.2.101
  // on chart-bar-with-legend (432pt × 324pt frame): the major tick
  // is a 12px-tall feature and the minor tick is an 8px-tall feature
  // INCLUDING the strokewidth. Resolving the line stroke into the
  // bounding box: major covers 6 px each side of the axis; minor
  // covers 4 px each side. Expressed as a fraction of frame WIDTH
  // (576px at 96dpi → 5486400 EMU for the 6in fixtures):
  // major ≈ 6 / 576 ≈ 0.0104; minor ≈ 4 / 576 ≈ 0.0069. ECMA-376
  // §21.2.2.137 nominally defaults `majorTickMark` to "out" but
  // cross-style ticks straddling the axis line are the conventional
  // rendering — we follow that convention so the snapshot harness
  // sees the same pixel pattern at every intersection.
  let major_half = fw * 0.0104
  let minor_half = fw * 0.0069
  let tick_x = axis_x.unwrap_or(px)
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = match major_unit {
    Some(v) => if v > 0.0 { v } else { nice_axis_step(max_v) }
    None => nice_axis_step(max_v)
  }
  let major_gridline_style = if draw_gridlines {
    chart_gridline_style(
      major_gridlines_element,
      ctx,
      defs,
      "chart-major-gridlines",
      grid_color,
      ph * 0.002,
    )
  } else {
    None
  }
  let minor_gridline_style = if draw_minor_gridlines {
    chart_gridline_style(
      minor_gridlines_element,
      ctx,
      defs,
      "chart-minor-gridlines",
      grid_color,
      ph * 0.001,
      default_dasharray=Some("4,4"),
    )
  } else {
    None
  }
  let label_gap = fw * 0.014
  // Minor ticks: §21.2.2.107 subdivides each major step into 5 minor units
  // (visible on the 0..45 axis as 46 minor ticks at every integer).
  // Drawing minors first keeps major ticks visually on top.
  // §21.2.2.170 logBase — when set, use logarithmic positioning.
  let min_v_for_log = match log_base {
    Some(_) => 1.0
    None => 0.0
  }
  let minor_step = match minor_unit {
    Some(v) => if v > 0.0 { v } else { step / 5.0 }
    None => step / 5.0
  }
  let mut mv = min_v_for_log
  while mv <= max_v + minor_step * 0.001 {
    // §21.2.2.170 — flip the fraction (NOT the loop) under maxMin so
    // the minor ticks land on the SAME pixels the data path computes
    // via `value_axis_y`, keeping ticks and data aligned.
    let f = axis_fraction(
      log_scale_frac(mv, min_v_for_log, max_v, log_base),
      reversed,
    )
    let y = py + ph - f * ph
    if minor_tick_mark != "none" {
      nodes.push(
        axis_tick_h_line(
          tick_x - minor_half,
          tick_x + minor_half,
          y,
          axis_color,
          tick_stroke,
        ),
      )
    }
    // §21.2.2.105 minorGridlines — thin lines at minor tick positions.
    if mv > min_v_for_log {
      match minor_gridline_style {
        Some(line_style) => {
          let attrs : Array[@xml.Attribute] = [
            @markup.attr("x1", format_double(px)),
            @markup.attr("y1", format_double(y)),
            @markup.attr("x2", format_double(px + pw)),
            @markup.attr("y2", format_double(y)),
          ]
          push_chart_line_style_attrs(attrs, line_style)
          nodes.push(@markup.elem_ns("line", @markup.svg_ns, attrs, []))
        }
        None => ()
      }
    }
    mv = mv + minor_step
  }
  let mut tick_v = min_v_for_log
  while tick_v <= max_v + step * 0.001 {
    let f = axis_fraction(
      log_scale_frac(tick_v, min_v_for_log, max_v, log_base),
      reversed,
    )
    let y = py + ph - f * ph
    if tick_v > min_v_for_log {
      match major_gridline_style {
        Some(line_style) => {
          let attrs : Array[@xml.Attribute] = [
            @markup.attr("x1", format_double(px)),
            @markup.attr("y1", format_double(y)),
            @markup.attr("x2", format_double(px + pw)),
            @markup.attr("y2", format_double(y)),
          ]
          push_chart_line_style_attrs(attrs, line_style)
          nodes.push(@markup.elem_ns("line", @markup.svg_ns, attrs, []))
        }
        None => ()
      }
    }
    if major_tick_mark != "none" {
      nodes.push(
        axis_tick_h_line(
          tick_x - major_half,
          tick_x + major_half,
          y,
          axis_color,
          tick_stroke,
        ),
      )
    }
    // §21.2.2.209 tickLblPos — "none" suppresses labels entirely.
    if tick_lbl_pos != "none" {
      let label = format_axis_tick_label(
        tick_v, num_fmt, label_suffix, display_unit_factor,
      )
      let (lx, anchor) = if tick_lbl_pos == "high" {
        (px + pw + label_gap, "start")
      } else {
        (tick_x - label_gap, "end")
      }
      nodes.push(
        chart_text(label, lx, y, pw, ph, anchor~, baseline="middle", style~),
      )
    }
    tick_v = tick_v + step
  }
  nodes
}

///|
/// Horizontal axis-tick line segment from `x1` to `x2` at the given
/// y-coordinate. Helper used by `y_axis_ticks` to draw the cross-style
/// tick marks straddling a vertical (left/right) axis.
fn axis_tick_h_line(
  x1 : Double,
  x2 : Double,
  y : Double,
  color : String,
  stroke : String,
) -> @xml.Node {
  @markup.elem_ns(
    "line",
    @markup.svg_ns,
    [
      @markup.attr("x1", format_double(x1)),
      @markup.attr("y1", format_double(y)),
      @markup.attr("x2", format_double(x2)),
      @markup.attr("y2", format_double(y)),
      @markup.attr("stroke", color),
      @markup.attr("stroke-width", stroke),
    ],
    [],
  )
}

///|
/// Vertical axis-tick line segment from `y1` to `y2` at the given
/// x-coordinate. Symmetric companion of `axis_tick_h_line` used to
/// draw ticks straddling a horizontal (top/bottom) axis.
fn axis_tick_v_line(
  y1 : Double,
  y2 : Double,
  x : Double,
  color : String,
  stroke : String,
) -> @xml.Node {
  @markup.elem_ns(
    "line",
    @markup.svg_ns,
    [
      @markup.attr("x1", format_double(x)),
      @markup.attr("y1", format_double(y1)),
      @markup.attr("x2", format_double(x)),
      @markup.attr("y2", format_double(y2)),
      @markup.attr("stroke", color),
      @markup.attr("stroke-width", stroke),
    ],
    [],
  )
}

///|
fn chart_gridline_style(
  gridlines : @xml.Element?,
  ctx : ColorResolveContext?,
  defs : SvgDefsCollector?,
  id_hint : String,
  default_stroke : String,
  default_width : Double,
  default_dasharray? : String? = None,
) -> ChartLineStyle? {
  match gridlines {
    Some(e) =>
      match (ctx, defs) {
        (Some(c), Some(d)) =>
          chart_lines_style(
            e,
            c,
            d,
            id_hint,
            default_stroke,
            default_width,
            default_dasharray~,
          )
        _ =>
          Some({
            stroke: default_stroke,
            stroke_width: default_width,
            dasharray: default_dasharray,
            linecap: None,
          })
      }
    None =>
      Some({
        stroke: default_stroke,
        stroke_width: default_width,
        dasharray: default_dasharray,
        linecap: None,
      })
  }
}

///|
/// X-axis tick labels and (optional) vertical gridlines at every "nice"
/// step. Mirrors `y_axis_ticks` but oriented along the X axis so the
/// `barDir="bar"` (horizontal bars) layout shows the value axis at the
/// bottom of the plot rather than on the left. `draw_gridlines` follows
/// the axis's `<c:majorGridlines/>` declaration. `fh` is the outer frame
/// height; the gap between plot bottom and tick label top is taken as
/// ≈ 1.8% of the frame height to match the measured spacing.
fn x_axis_ticks(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
  max_v : Double,
  fh : Double,
  draw_gridlines : Bool,
  style? : ChartStyleDefaults? = None,
  tick_lbl_pos? : String = "nextTo",
  num_fmt? : String? = None,
  major_gridlines_element? : @xml.Element? = None,
  ctx? : ColorResolveContext? = None,
  defs? : SvgDefsCollector? = None,
  major_tick_mark? : String = "cross",
  minor_tick_mark? : String = "cross",
  major_unit? : Double? = None,
  minor_unit? : Double? = None,
  reversed? : Bool = false,
  axis_y? : Double? = None,
  display_unit_factor? : Double? = None,
) -> Array[@xml.Node] {
  if max_v <= 0.0 {
    return []
  }
  let grid_color = match style {
    Some(s) => s.grid_color
    None => chart_default_grid_color
  }
  let axis_color = match style {
    Some(s) => s.axis_color
    None => chart_default_axis_color
  }
  // Cross-style tick mark half-lengths against frame HEIGHT (the axis
  // is horizontal so the tick is vertical). Per §21.2.2.101 the major
  // tick is 12 px total (half = (12 - axis_stroke)/2 ≈ 5.22 px) and
  // the minor is 8 px total (half ≈ 3.22 px) on a 432px frame. With
  // our 9525 EMU/px and frame height in EMU, the half-length expressed
  // as a ratio of fh resolves to 0.0121 for major and 0.0075 for minor.
  let major_half = fh * 0.0121
  let minor_half = fh * 0.0075
  let tick_y = axis_y.unwrap_or(py + ph)
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = match major_unit {
    Some(v) => if v > 0.0 { v } else { nice_axis_step(max_v) }
    None => nice_axis_step(max_v)
  }
  let major_gridline_style = if draw_gridlines {
    chart_gridline_style(
      major_gridlines_element,
      ctx,
      defs,
      "chart-major-gridlines-x",
      grid_color,
      pw * 0.002,
    )
  } else {
    None
  }
  let minor_step = match minor_unit {
    Some(v) => if v > 0.0 { v } else { step / 5.0 }
    None => step / 5.0
  }
  let mut mv = 0.0
  while mv <= max_v + minor_step * 0.001 {
    // §21.2.2.170 — flip the fraction under maxMin so ticks track the
    // data drawn via `value_axis_x`.
    let f = axis_fraction(mv / max_v, reversed)
    let x = px + f * pw
    if minor_tick_mark != "none" {
      nodes.push(
        axis_tick_v_line(
          tick_y - minor_half,
          tick_y + minor_half,
          x,
          axis_color,
          tick_stroke,
        ),
      )
    }
    mv = mv + minor_step
  }
  let mut tick_v = 0.0
  while tick_v <= max_v + step * 0.001 {
    let f = axis_fraction(tick_v / max_v, reversed)
    let x = px + f * pw
    if tick_v > 0.0 {
      match major_gridline_style {
        Some(line_style) => {
          let attrs : Array[@xml.Attribute] = [
            @markup.attr("x1", format_double(x)),
            @markup.attr("y1", format_double(py)),
            @markup.attr("x2", format_double(x)),
            @markup.attr("y2", format_double(py + ph)),
          ]
          push_chart_line_style_attrs(attrs, line_style)
          nodes.push(@markup.elem_ns("line", @markup.svg_ns, attrs, []))
        }
        None => ()
      }
    }
    if major_tick_mark != "none" {
      nodes.push(
        axis_tick_v_line(
          tick_y - major_half,
          tick_y + major_half,
          x,
          axis_color,
          tick_stroke,
        ),
      )
    }
    if tick_lbl_pos != "none" {
      let label = format_axis_tick_label(
        tick_v, num_fmt, "", display_unit_factor,
      )
      let (ly, bl) = if tick_lbl_pos == "high" {
        (py - fh * 0.018, "auto")
      } else {
        (tick_y + fh * 0.018, "hanging")
      }
      nodes.push(
        chart_text(label, x, ly, pw, ph, anchor="middle", baseline=bl, style~),
      )
    }
    tick_v = tick_v + step
  }
  nodes
}

///|
/// Category-axis cross-style major tick marks at every category band
/// boundary on a BOTTOM horizontal axis (used by column-bar / line /
/// scatter charts). `cat_count` is the number of categories: this
/// produces `cat_count+1` ticks at evenly spaced band edges. The tick
/// stroke and half-length mirror `x_axis_ticks` so all axis ticks
/// agree visually.
fn category_axis_ticks_bottom(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
  fh : Double,
  cat_count : Int,
  major_tick_mark? : String = "cross",
  cross_between? : String = "between",
  axis_y? : Double? = None,
  tick_mark_skip? : Int = 1,
) -> Array[@xml.Node] {
  if cat_count <= 0 || major_tick_mark == "none" {
    return []
  }
  let axis_color = "#bfbfbf"
  let major_half = fh * 0.0121
  let tick_y = axis_y.unwrap_or(py + ph)
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let skip = if tick_mark_skip <= 1 { 1 } else { tick_mark_skip }
  let tick_count = if cross_between == "midCat" {
    cat_count
  } else {
    cat_count + 1
  }
  let mut i = 0
  while i < tick_count {
    if i % skip != 0 {
      i = i + 1
      continue
    }
    let x = if cross_between == "midCat" {
      category_axis_position_for_cross(
        px, pw, cat_count, i, false, cross_between,
      )
    } else {
      px + i.to_double() * (pw / cat_count.to_double())
    }
    nodes.push(
      axis_tick_v_line(
        tick_y - major_half,
        tick_y + major_half,
        x,
        axis_color,
        tick_stroke,
      ),
    )
    i = i + 1
  }
  nodes
}

///|
/// Category-axis cross-style major tick marks at every category band
/// boundary on a LEFT vertical axis (used by horizontal-bar charts
/// where the category labels stack along the Y axis). Produces
/// `cat_count+1` ticks at evenly spaced band edges. Mirrors
/// `category_axis_ticks_bottom` for the orthogonal layout.
fn category_axis_ticks_left(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
  fw : Double,
  cat_count : Int,
  major_tick_mark? : String = "cross",
  cross_between? : String = "between",
  axis_x? : Double? = None,
  tick_mark_skip? : Int = 1,
) -> Array[@xml.Node] {
  if cat_count <= 0 || major_tick_mark == "none" {
    return []
  }
  let axis_color = "#bfbfbf"
  let major_half = fw * 0.0091
  let tick_x = axis_x.unwrap_or(px)
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let skip = if tick_mark_skip <= 1 { 1 } else { tick_mark_skip }
  let tick_count = if cross_between == "midCat" {
    cat_count
  } else {
    cat_count + 1
  }
  let mut i = 0
  while i < tick_count {
    if i % skip != 0 {
      i = i + 1
      continue
    }
    let y = if cross_between == "midCat" {
      category_axis_position_for_cross(
        py, ph, cat_count, i, false, cross_between,
      )
    } else {
      py + i.to_double() * (ph / cat_count.to_double())
    }
    nodes.push(
      axis_tick_h_line(
        tick_x - major_half,
        tick_x + major_half,
        y,
        axis_color,
        tick_stroke,
      ),
    )
    i = i + 1
  }
  nodes
}

///|
/// §21.2.2.175 tickLblSkip — true when a category label should be
/// rendered. `0` / `1` mean every label, matching the existing bar
/// chart behaviour.
fn category_label_should_render(axes : ChartAxesInfo, index : Int) -> Bool {
  let lbl_skip = axes.cat_tick_lbl_skip()
  let skip = if lbl_skip <= 1 { 1 } else { lbl_skip }
  index % skip == 0
}

///|
/// §21.2.2.88 lblAlgn — map category label alignment to SVG
/// `text-anchor` for horizontal category axes.
fn category_label_anchor(axes : ChartAxesInfo) -> String {
  match axes.cat_lbl_algn() {
    "l" => "start"
    "r" => "end"
    _ => "middle"
  }
}

///|
/// §21.2.2.96 lblOffset — scale the existing bottom-axis label gap.
/// The default 100 preserves the current 1.8% frame-height spacing.
fn category_horizontal_label_offset(
  fh : Double,
  axes : ChartAxesInfo,
) -> Double {
  let pct = axes.cat_lbl_offset()
  let scale = if pct <= 0 { 1.0 } else { pct.to_double() / 100.0 }
  fh * 0.018 * scale
}

///|
/// §21.2.2.96 lblOffset — scale the existing left/right category
/// label gap for horizontal bar charts. The default 100 preserves the
/// current 0.6% frame-width spacing.
fn category_vertical_label_offset(fw : Double, axes : ChartAxesInfo) -> Double {
  let pct = axes.cat_lbl_offset()
  let scale = if pct <= 0 { 1.0 } else { pct.to_double() / 100.0 }
  fw * 0.006 * scale
}

///|
/// §21.2.2.209 tickLblPos — y/baseline for labels on a horizontal
/// category axis. "nextTo" follows the actual crossing axis line;
/// "high" remains on the far/high side of the plot area.
fn category_horizontal_label_y(
  py : Double,
  axis_y : Double,
  label_side : String,
  label_offset : Double,
) -> (Double, String) {
  if label_side == "high" {
    (py - label_offset, "auto")
  } else {
    (axis_y + label_offset, "hanging")
  }
}

///|
/// §21.2.2.209 tickLblPos — x/anchor for labels on a vertical category
/// axis. "nextTo" follows the actual crossing axis line; "high" remains
/// on the far/high side of the plot area.
fn category_vertical_label_x(
  px : Double,
  pw : Double,
  axis_x : Double,
  label_side : String,
  label_offset : Double,
) -> (Double, String) {
  if label_side == "high" {
    (px + pw + label_offset, "start")
  } else {
    (axis_x - label_offset, "end")
  }
}

///|
/// §21.2.2.47 ST_BuiltInUnit — numeric divisor for built-in display
/// units. Data coordinates remain in source units; only tick labels
/// are divided by this factor.
fn chart_display_unit_factor(unit : String) -> Double? {
  match unit {
    "hundreds" => Some(100.0)
    "thousands" => Some(1000.0)
    "tenThousands" => Some(10000.0)
    "hundredThousands" => Some(100000.0)
    "millions" => Some(1000000.0)
    "tenMillions" => Some(10000000.0)
    "hundredMillions" => Some(100000000.0)
    "billions" => Some(1000000000.0)
    "trillions" => Some(1000000000000.0)
    _ => None
  }
}

///|
/// §21.2.2.47 dispUnits — human-readable unit label used by the chart
/// SVG root. This is not debug paint; it is the visible display-unit
/// label that accompanies scaled value-axis ticks.
fn chart_display_unit_label(unit : String, factor : Double?) -> String {
  if unit == "custom" {
    match factor {
      Some(f) => "×" + format_axis_value(f)
      None => "custom"
    }
  } else {
    match unit {
      "hundreds" => "×100"
      "thousands" => "×1,000"
      "tenThousands" => "×10,000"
      "hundredThousands" => "×100,000"
      "millions" => "×1,000,000"
      "tenMillions" => "×10,000,000"
      "hundredMillions" => "×100,000,000"
      "billions" => "×1,000,000,000"
      "trillions" => "×1,000,000,000,000"
      _ => unit
    }
  }
}

///|
/// §21.2.2.47 dispUnits — apply the display-unit divisor to a tick
/// label value. The returned value is formatting-only; geometry and
/// gridline positions continue using the unscaled source value.
fn axis_display_value(v : Double, factor : Double?) -> Double {
  match factor {
    Some(f) => if f > 0.0 && f != 1.0 { v / f } else { v }
    None => v
  }
}

///|
/// Format a numeric value-axis tick after applying optional display
/// units and numFmt.
fn format_axis_tick_label(
  v : Double,
  num_fmt : String?,
  label_suffix : String,
  display_unit_factor : Double?,
) -> String {
  let display_v = axis_display_value(v, display_unit_factor)
  match num_fmt {
    Some(fmt) => format_axis_value_with_fmt(display_v, fmt) + label_suffix
    None => format_axis_value(display_v) + label_suffix
  }
}

///|
/// Format a numeric axis tick value: integer when close to whole,
/// otherwise one decimal. Keeps the label compact at chart sizes.
fn format_axis_value(v : Double) -> String {
  let rounded = (v + 0.5).to_int()
  let diff = v - rounded.to_double()
  let abs_diff = if diff < 0.0 { -diff } else { diff }
  if abs_diff < 0.05 {
    rounded.to_string()
  } else {
    let scaled = v * 10.0
    let i10 = (scaled + 0.5).to_int()
    let whole = i10 / 10
    let frac = i10 - whole * 10
    let frac_abs = if frac < 0 { -frac } else { frac }
    whole.to_string() + "." + frac_abs.to_string()
  }
}

///|
/// §21.2.2.117 numFmt — format a numeric value using the given format
/// code. Supports common patterns: "General", "0", "0.00", "0.0",
/// "#,##0", "0%", "0.00%". Uses `format_axis_value` for patterns
/// that are not implemented by the lightweight SVG renderer.
fn format_axis_value_with_fmt(v : Double, fmt : String) -> String {
  if fmt == "General" || fmt.length() == 0 {
    return format_axis_value(v)
  }
  // §18.8.30 — percentage formats.
  if fmt.has_suffix("%") {
    let pct = v
    let rounded = (pct + 0.5).to_int()
    return rounded.to_string() + "%"
  }
  // "0.00" — fixed decimal places.
  if fmt == "0.00" {
    let scaled = (v * 100.0 + 0.5).to_int()
    let whole = scaled / 100
    let frac = scaled - whole * 100
    let frac_abs = if frac < 0 { -frac } else { frac }
    let frac_str = if frac_abs < 10 {
      "0" + frac_abs.to_string()
    } else {
      frac_abs.to_string()
    }
    return whole.to_string() + "." + frac_str
  }
  if fmt == "0.0" {
    let scaled = (v * 10.0 + 0.5).to_int()
    let whole = scaled / 10
    let frac = scaled - whole * 10
    let frac_abs = if frac < 0 { -frac } else { frac }
    return whole.to_string() + "." + frac_abs.to_string()
  }
  // "0" or "#,##0" — integer.
  if fmt == "0" || fmt == "#,##0" {
    return (v + 0.5).to_int().to_string()
  }
  format_axis_value(v)
}

///|
/// Build a `<text>` node for an axis / category label. The font size is
/// scaled to the plot dimensions so labels stay legible across the
/// 6"×4.5" fixture frames without overflowing.
fn chart_text(
  text : String,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  anchor~ : String,
  baseline~ : String,
  style? : ChartStyleDefaults? = None,
) -> @xml.Node {
  let font_size = (if w < h { w } else { h }) * 0.035
  let fill = match style {
    Some(s) => s.text_color
    None => chart_default_text_color
  }
  let family = match style {
    Some(s) => s.font_family
    None => "sans-serif"
  }
  let _ = (try? @glyph.measure_text_width(
    text,
    font_size_pt=font_size / 96.0 * 72.0,
    letter_spacing_px=0.0,
    family=chart_default_family,
  )).unwrap_or(0.0)
  @markup.elem_ns(
    "text",
    @markup.svg_ns,
    [
      @markup.attr("x", format_double(x)),
      @markup.attr("y", format_double(y)),
      @markup.attr("text-anchor", anchor),
      @markup.attr("dominant-baseline", baseline),
      @markup.attr("font-size", format_double(font_size)),
      @markup.attr("fill", fill),
      @markup.attr("font-family", family),
    ],
    [@markup.text(text)],
  )
}
