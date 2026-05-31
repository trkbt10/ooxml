// =============================================================================
// Shared axis helpers.
// =============================================================================

///|
/// Background `<rect>` for the plot area plus left + bottom axis lines.
/// Stroke colour uses the §21.2 implementation default mid-grey axis
/// colour (`#bfbfbf`).
fn plot_axes_rect(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
  style? : ChartStyleDefaults? = None,
) -> @xml.Node {
  let axis_color = match style {
    Some(s) => s.axis_color
    None => chart_default_axis_color
  }
  let stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let group_kids : Array[@xml.Node] = [
    // Left axis line.
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", format_double(px)),
        @markup.attr("y1", format_double(py)),
        @markup.attr("x2", format_double(px)),
        @markup.attr("y2", format_double(py + ph)),
        @markup.attr("stroke", axis_color),
        @markup.attr("stroke-width", stroke),
      ],
      [],
    ),
    // Bottom axis line.
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", format_double(px)),
        @markup.attr("y1", format_double(py + ph)),
        @markup.attr("x2", format_double(px + pw)),
        @markup.attr("y2", format_double(py + ph)),
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
/// §21.2.2.170 — reverse a category index when the category axis runs
/// maxMin.  Given `cat_count` categories and a natural index `i` in
/// `[0, cat_count)`, returns `cat_count - 1 - i` when `reversed`, else
/// `i` unchanged.  Used to flip the band position of each category for
/// bar/column/line charts so the categories and their tick labels
/// reverse together.
fn category_index(i : Int, cat_count : Int, reversed : Bool) -> Int {
  if reversed {
    cat_count - 1 - i
  } else {
    i
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
  reversed? : Bool = false,
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
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = nice_axis_step(max_v)
  let label_gap = fw * 0.014
  // Minor ticks: §21.2.2.107 subdivides each major step into 5 minor units
  // (visible on the 0..45 axis as 46 minor ticks at every integer).
  // Drawing minors first keeps major ticks visually on top.
  // §21.2.2.170 logBase — when set, use logarithmic positioning.
  let min_v_for_log = match log_base {
    Some(_) => 1.0
    None => 0.0
  }
  let minor_per_major = 5
  let minor_step = step / minor_per_major.to_double()
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
    nodes.push(
      axis_tick_h_line(
        px - minor_half,
        px + minor_half,
        y,
        axis_color,
        tick_stroke,
      ),
    )
    // §21.2.2.105 minorGridlines — thin lines at minor tick positions.
    if draw_minor_gridlines && mv > min_v_for_log {
      nodes.push(
        @markup.elem_ns(
          "line",
          @markup.svg_ns,
          [
            @markup.attr("x1", format_double(px)),
            @markup.attr("y1", format_double(y)),
            @markup.attr("x2", format_double(px + pw)),
            @markup.attr("y2", format_double(y)),
            @markup.attr("stroke", grid_color),
            @markup.attr("stroke-width", format_double(ph * 0.001)),
            @markup.attr("stroke-dasharray", "4,4"),
          ],
          [],
        ),
      )
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
    if tick_v > min_v_for_log && draw_gridlines {
      nodes.push(
        @markup.elem_ns(
          "line",
          @markup.svg_ns,
          [
            @markup.attr("x1", format_double(px)),
            @markup.attr("y1", format_double(y)),
            @markup.attr("x2", format_double(px + pw)),
            @markup.attr("y2", format_double(y)),
            @markup.attr("stroke", grid_color),
            @markup.attr("stroke-width", format_double(ph * 0.002)),
          ],
          [],
        ),
      )
    }
    nodes.push(
      axis_tick_h_line(
        px - major_half,
        px + major_half,
        y,
        axis_color,
        tick_stroke,
      ),
    )
    // §21.2.2.209 tickLblPos — "none" suppresses labels entirely.
    if tick_lbl_pos != "none" {
      let label = match num_fmt {
        Some(fmt) => format_axis_value_with_fmt(tick_v, fmt) + label_suffix
        None => format_axis_value(tick_v) + label_suffix
      }
      let (lx, anchor) = if tick_lbl_pos == "high" {
        (px + pw + label_gap, "start")
      } else {
        (px - label_gap, "end")
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
  reversed? : Bool = false,
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
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = nice_axis_step(max_v)
  let minor_per_major = 5
  let minor_step = step / minor_per_major.to_double()
  let mut mv = 0.0
  while mv <= max_v + minor_step * 0.001 {
    // §21.2.2.170 — flip the fraction under maxMin so ticks track the
    // data drawn via `value_axis_x`.
    let f = axis_fraction(mv / max_v, reversed)
    let x = px + f * pw
    nodes.push(
      axis_tick_v_line(
        py + ph - minor_half,
        py + ph + minor_half,
        x,
        axis_color,
        tick_stroke,
      ),
    )
    mv = mv + minor_step
  }
  let mut tick_v = 0.0
  while tick_v <= max_v + step * 0.001 {
    let f = axis_fraction(tick_v / max_v, reversed)
    let x = px + f * pw
    if tick_v > 0.0 && draw_gridlines {
      nodes.push(
        @markup.elem_ns(
          "line",
          @markup.svg_ns,
          [
            @markup.attr("x1", format_double(x)),
            @markup.attr("y1", format_double(py)),
            @markup.attr("x2", format_double(x)),
            @markup.attr("y2", format_double(py + ph)),
            @markup.attr("stroke", grid_color),
            @markup.attr("stroke-width", format_double(pw * 0.002)),
          ],
          [],
        ),
      )
    }
    nodes.push(
      axis_tick_v_line(
        py + ph - major_half,
        py + ph + major_half,
        x,
        axis_color,
        tick_stroke,
      ),
    )
    if tick_lbl_pos != "none" {
      let label = match num_fmt {
        Some(fmt) => format_axis_value_with_fmt(tick_v, fmt)
        None => format_axis_value(tick_v)
      }
      let (ly, bl) = if tick_lbl_pos == "high" {
        (py - fh * 0.018, "auto")
      } else {
        (py + ph + fh * 0.018, "hanging")
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
) -> Array[@xml.Node] {
  if cat_count <= 0 {
    return []
  }
  let axis_color = "#bfbfbf"
  let major_half = fh * 0.0121
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = pw / cat_count.to_double()
  let mut i = 0
  while i <= cat_count {
    let x = px + i.to_double() * step
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
) -> Array[@xml.Node] {
  if cat_count <= 0 {
    return []
  }
  let axis_color = "#bfbfbf"
  let major_half = fw * 0.0091
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = ph / cat_count.to_double()
  let mut i = 0
  while i <= cat_count {
    let y = py + i.to_double() * step
    nodes.push(
      axis_tick_h_line(
        px - major_half,
        px + major_half,
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
/// "#,##0", "0%", "0.00%". Falls back to `format_axis_value` for
/// unrecognised patterns.
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
