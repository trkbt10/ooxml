// =============================================================================
// Microsoft x14 sparklines SVG renderer.
//
// Produces one SVG group per `Sparkline`, sized to a host-supplied
// cell box. The renderer is intentionally self-contained: it does not
// touch the worksheet's `<sheetData>` directly. Callers pull the
// data values out of the worksheet (or use `Sparkline.literal_values`
// for fixtures) and pass the typed `(box, sparkline, group)` tuple to
// `render_sparkline`.
//
// Output is always a `<g class="sparkline" data-ooxml-sparkline-type="…">`
// wrapping zero or more `<polyline>` / `<rect>` / `<line>` /
// `<circle>` nodes. Colours come from `SparklineGroup.color_*` with
// well-documented fallbacks when an attribute is omitted.
// =============================================================================

///|
/// Bounding box the host viewer reserves for the sparkline inside
/// a cell. Coordinates are absolute SVG pixels.
pub(all) struct SparklineBox {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Eq, Debug)

///|
/// Default colour palette used when a `<x14:color*>` entry is
/// omitted. Values mirror Excel 2010's defaults documented in
/// `[MS-XLSX]` §2.6.5 (a deep-blue series, red negative, dark-red
/// markers, etc.). All literals are ARGB hex strings without the
/// leading `#`; the renderer prefixes `#` when writing the SVG
/// `stroke` / `fill` attribute.
fn default_color_series() -> String {
  "376092"
}

///|
fn default_color_negative() -> String {
  "FF0000"
}

///|
fn default_color_axis() -> String {
  "808080"
}

///|
fn default_color_markers() -> String {
  "D00000"
}

///|
fn default_color_first() -> String {
  "5F5F5F"
}

///|
fn default_color_last() -> String {
  "5F5F5F"
}

///|
fn default_color_high() -> String {
  "00B050"
}

///|
fn default_color_low() -> String {
  "C00000"
}

///|
/// Resolve a `SparklineColor` to a `"#RRGGBB"` string. When the
/// theme / tint attributes are present but no `rgb` literal is
/// supplied the renderer falls back to `default_hex`: §18.8.3
/// theme-colour resolution lives in the SML viewer and pulling it
/// into this package would create a circular dependency
/// (sparkline → viewer → sparkline). The fallback is documented
/// alongside the package's deferred-features list in the README.
fn color_or(color : SparklineColor, default_hex : String) -> String {
  let hex = match color.hex {
    Some(h) => h
    None => default_hex
  }
  // ARGB hex (8 chars) → strip the leading alpha byte for SVG.
  // SVG expects RGB or RGBA per its colour syntax, and OOXML's
  // alpha channel is in the high byte (§18.8.19 ST_UnsignedIntHex).
  let body = if hex.length() == 8 {
    hex.unsafe_substring(start=2, end=8)
  } else {
    hex
  }
  "#" + body
}

///|
/// Render a single sparkline into the supplied box. Returns the
/// list of SVG nodes (one `<g>` wrapping the glyph elements).
///
/// `data` is the value array the renderer paints. When
/// `sparkline.literal_values` is non-empty the caller SHOULD pass
/// that; otherwise the caller is responsible for resolving the
/// data-range formula against `<sheetData>` and supplying the
/// values here.
pub fn render_sparkline(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
) -> @xml.Node {
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("class", "sparkline"),
    @markup.attr("data-ooxml-sparkline-type", kind_to_string(group.kind)),
  ]
  let children : Array[@xml.Node] = []
  // Skip empties (per displayEmptyCellsAs="gap" the renderer simply
  // doesn't paint a glyph; the spec's "zero" and "span" variants
  // are deferred — see README).
  if data.length() == 0 {
    return @markup.elem_ns("g", @markup.svg_ns, attrs, children)
  }
  let (min_v, max_v) = data_range(data, group)
  // §[MS-XLSX] 2.6.5 — the axis sits at y=0 for line / column
  // sparklines that span both signs, otherwise at the box's
  // baseline. `displayXAxis` opts into an explicit axis line.
  let axis_y = scale_y(0.0, min_v, max_v, box)
  match group.kind {
    Line => render_line_into(box, data, group, min_v, max_v, axis_y, children)
    Column =>
      render_column_into(box, data, group, min_v, max_v, axis_y, children)
    Stacked =>
      render_stacked_into(box, data, group, min_v, max_v, axis_y, children)
  }
  @markup.elem_ns("g", @markup.svg_ns, attrs, children)
}

///|
/// Pick a (min, max) tuple for the value range. Stacked (win/loss)
/// fixes the range to ±1 because the bars are signed but
/// unit-height; line / column scale to the data.
fn data_range(data : Array[Double], group : SparklineGroup) -> (Double, Double) {
  match group.kind {
    Stacked => (-1.0, 1.0)
    _ => {
      let mut lo = data[0]
      let mut hi = data[0]
      for v in data {
        if v < lo {
          lo = v
        }
        if v > hi {
          hi = v
        }
      }
      // Always include the axis (y=0) in the visible range so the
      // optional axis line / negative bars line up with the data.
      if lo > 0.0 {
        lo = 0.0
      }
      if hi < 0.0 {
        hi = 0.0
      }
      // Avoid a zero-span which would divide-by-zero downstream.
      if (hi - lo).abs() < 1.0e-12 {
        if hi == 0.0 {
          hi = 1.0
          lo = -1.0
        } else {
          lo = hi - 1.0
        }
      }
      (lo, hi)
    }
  }
}

///|
/// Project a data value to its pixel-y inside `box`. The y axis is
/// inverted because SVG's origin is at the top-left.
fn scale_y(v : Double, lo : Double, hi : Double, box : SparklineBox) -> Double {
  let span = hi - lo
  if span <= 0.0 {
    return box.y + box.height / 2.0
  }
  box.y + box.height - (v - lo) / span * box.height
}

///|
/// Project a data-index (0..n-1) to its pixel-x inside `box`. The
/// first and last points sit on the box edges.
fn scale_x(i : Int, n : Int, box : SparklineBox) -> Double {
  if n <= 1 {
    return box.x + box.width / 2.0
  }
  box.x + i.to_double() / (n - 1).to_double() * box.width
}

///|
/// Polyline through the data points, optional markers, optional
/// per-data-point highlights, and the optional axis line.
fn render_line_into(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
  min_v : Double,
  max_v : Double,
  axis_y : Double,
  out : Array[@xml.Node],
) -> Unit {
  if group.display_x_axis {
    out.push(axis_line(box, axis_y, group))
  }
  let n = data.length()
  let buf = StringBuilder::new()
  for i in 0..<n {
    let x = scale_x(i, n, box)
    let y = scale_y(data[i], min_v, max_v, box)
    if i > 0 {
      buf.write_string(" ")
    }
    buf.write_string(format_d(x))
    buf.write_string(",")
    buf.write_string(format_d(y))
  }
  out.push(
    @markup.elem_ns(
      "polyline",
      @markup.svg_ns,
      [
        @markup.attr("fill", "none"),
        @markup.attr(
          "stroke",
          color_or(group.color_series, default_color_series()),
        ),
        @markup.attr("stroke-width", "0.75"),
        @markup.attr("points", buf.to_string()),
      ],
      [],
    ),
  )
  if group.markers {
    push_markers(box, data, group, min_v, max_v, out)
  }
  // Per-data-point highlights — small filled circles overlaid on
  // the marker dots. Multiple highlights can land on the same
  // point (e.g. high == last) and that's fine; each gets its own
  // circle so the colour blend reflects the spec precedence
  // (markers < first/last < high/low per `[MS-XLSX]` §2.6.5).
  push_highlights(box, data, group, min_v, max_v, out)
}

///|
/// Column bars: one filled rect per data value, positive bars
/// growing up from the axis, negative bars growing down. Negative
/// bars use `color_negative` when `group.negative` is set.
fn render_column_into(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
  min_v : Double,
  max_v : Double,
  axis_y : Double,
  out : Array[@xml.Node],
) -> Unit {
  let n = data.length()
  if n == 0 {
    return
  }
  // Bar width = box.width / n, with a 1-px gap between bars for
  // legibility (Excel uses ~10% of the bar pitch as a gap).
  let pitch = box.width / n.to_double()
  let gap = if pitch > 4.0 { pitch * 0.1 } else { 0.5 }
  let bw = pitch - gap
  let pos_fill = color_or(group.color_series, default_color_series())
  let neg_fill = if group.negative {
    color_or(group.color_negative, default_color_negative())
  } else {
    pos_fill
  }
  for i in 0..<n {
    let v = data[i]
    let x = box.x + i.to_double() * pitch + gap / 2.0
    let y0 = scale_y(0.0, min_v, max_v, box)
    let y1 = scale_y(v, min_v, max_v, box)
    let (top, bot) = if y1 < y0 { (y1, y0) } else { (y0, y1) }
    let h = (bot - top).abs()
    if h < 0.5 {
      // Excel still paints a 1-px hairline for zero / near-zero
      // values; keep the bar visible by clamping to 1 pixel.
      let _ = h
      let fill = if v < 0.0 { neg_fill } else { pos_fill }
      out.push(rect(x, axis_y - 0.5, bw, 1.0, fill))
    } else {
      let fill = if v < 0.0 { neg_fill } else { pos_fill }
      out.push(rect(x, top, bw, h, fill))
    }
  }
  if group.display_x_axis {
    out.push(axis_line(box, axis_y, group))
  }
  push_column_highlights(box, data, group, axis_y, pitch, gap, bw, out)
}

///|
/// Stacked (win/loss) bars: unit-height bars centred on the axis,
/// pointing up when positive and down when negative. Zero values
/// are skipped per the schema's "loss = negative, win = positive".
fn render_stacked_into(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
  min_v : Double,
  max_v : Double,
  axis_y : Double,
  out : Array[@xml.Node],
) -> Unit {
  let n = data.length()
  if n == 0 {
    return
  }
  let pitch = box.width / n.to_double()
  let gap = if pitch > 4.0 { pitch * 0.1 } else { 0.5 }
  let bw = pitch - gap
  // Win/loss bars are uniformly tall — half the box for each side.
  let half = box.height / 2.0
  let pos_fill = color_or(group.color_series, default_color_series())
  let neg_fill = color_or(group.color_negative, default_color_negative())
  for i in 0..<n {
    let v = data[i]
    if v == 0.0 {
      continue
    }
    let x = box.x + i.to_double() * pitch + gap / 2.0
    if v > 0.0 {
      out.push(rect(x, axis_y - half * 0.9, bw, half * 0.9, pos_fill))
    } else {
      out.push(rect(x, axis_y, bw, half * 0.9, neg_fill))
    }
  }
  let _ = min_v
  let _ = max_v
  if group.display_x_axis {
    out.push(axis_line(box, axis_y, group))
  }
}

///|
/// A `<line>` across the box at the data axis. Used by the optional
/// `displayXAxis` flag (and pulled in by column / stacked renderers
/// when the negative band needs a visual baseline).
fn axis_line(
  box : SparklineBox,
  y : Double,
  group : SparklineGroup,
) -> @xml.Node {
  @markup.elem_ns(
    "line",
    @markup.svg_ns,
    [
      @markup.attr("x1", format_d(box.x)),
      @markup.attr("y1", format_d(y)),
      @markup.attr("x2", format_d(box.x + box.width)),
      @markup.attr("y2", format_d(y)),
      @markup.attr("stroke", color_or(group.color_axis, default_color_axis())),
      @markup.attr("stroke-width", "0.5"),
    ],
    [],
  )
}

///|
/// Push marker dots for a `line` sparkline. `markers` is the
/// universal opt-in; per-data-point highlights are layered on top
/// via `push_highlights`.
fn push_markers(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
  min_v : Double,
  max_v : Double,
  out : Array[@xml.Node],
) -> Unit {
  let n = data.length()
  let fill = color_or(group.color_markers, default_color_markers())
  for i in 0..<n {
    let cx = scale_x(i, n, box)
    let cy = scale_y(data[i], min_v, max_v, box)
    out.push(marker_dot(cx, cy, fill))
  }
}

///|
/// Layer per-data-point highlights on top of the marker pass.
/// Precedence: high / low / first / last / negative — each gets its
/// own circle so the SVG painter draws them in this order.
fn push_highlights(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
  min_v : Double,
  max_v : Double,
  out : Array[@xml.Node],
) -> Unit {
  let n = data.length()
  if n == 0 {
    return
  }
  let mut hi_i = 0
  let mut lo_i = 0
  for i in 0..<n {
    if data[i] > data[hi_i] {
      hi_i = i
    }
    if data[i] < data[lo_i] {
      lo_i = i
    }
  }
  if group.high {
    let cx = scale_x(hi_i, n, box)
    let cy = scale_y(data[hi_i], min_v, max_v, box)
    out.push(
      marker_dot(cx, cy, color_or(group.color_high, default_color_high())),
    )
  }
  if group.low {
    let cx = scale_x(lo_i, n, box)
    let cy = scale_y(data[lo_i], min_v, max_v, box)
    out.push(marker_dot(cx, cy, color_or(group.color_low, default_color_low())))
  }
  if group.first {
    let cx = scale_x(0, n, box)
    let cy = scale_y(data[0], min_v, max_v, box)
    out.push(
      marker_dot(cx, cy, color_or(group.color_first, default_color_first())),
    )
  }
  if group.last {
    let cx = scale_x(n - 1, n, box)
    let cy = scale_y(data[n - 1], min_v, max_v, box)
    out.push(
      marker_dot(cx, cy, color_or(group.color_last, default_color_last())),
    )
  }
  if group.negative {
    for i in 0..<n {
      if data[i] < 0.0 {
        let cx = scale_x(i, n, box)
        let cy = scale_y(data[i], min_v, max_v, box)
        out.push(
          marker_dot(
            cx,
            cy,
            color_or(group.color_negative, default_color_negative()),
          ),
        )
      }
    }
  }
}

///|
/// Column-sparkline variant of `push_highlights` — paints a small
/// fill-tinted band over the bar that wins each category, instead
/// of a circle.
fn push_column_highlights(
  box : SparklineBox,
  data : Array[Double],
  group : SparklineGroup,
  axis_y : Double,
  pitch : Double,
  gap : Double,
  bw : Double,
  out : Array[@xml.Node],
) -> Unit {
  let n = data.length()
  if n == 0 {
    return
  }
  let mut hi_i = 0
  let mut lo_i = 0
  for i in 0..<n {
    if data[i] > data[hi_i] {
      hi_i = i
    }
    if data[i] < data[lo_i] {
      lo_i = i
    }
  }
  let dot = (h : Int, fill : String) => {
    let cx = box.x + h.to_double() * pitch + gap / 2.0 + bw / 2.0
    let cy = if data[h] >= 0.0 { axis_y - 1.0 } else { axis_y + 1.0 }
    out.push(marker_dot(cx, cy, fill))
  }
  if group.high {
    dot(hi_i, color_or(group.color_high, default_color_high()))
  }
  if group.low {
    dot(lo_i, color_or(group.color_low, default_color_low()))
  }
  if group.first {
    dot(0, color_or(group.color_first, default_color_first()))
  }
  if group.last {
    dot(n - 1, color_or(group.color_last, default_color_last()))
  }
}

///|
/// Small filled circle used by every marker / highlight pass.
fn marker_dot(cx : Double, cy : Double, fill : String) -> @xml.Node {
  @markup.elem_ns(
    "circle",
    @markup.svg_ns,
    [
      @markup.attr("cx", format_d(cx)),
      @markup.attr("cy", format_d(cy)),
      @markup.attr("r", "1.25"),
      @markup.attr("fill", fill),
    ],
    [],
  )
}

///|
/// `<rect>` shorthand used by column / stacked passes.
fn rect(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  fill : String,
) -> @xml.Node {
  @markup.elem_ns(
    "rect",
    @markup.svg_ns,
    [
      @markup.attr("x", format_d(x)),
      @markup.attr("y", format_d(y)),
      @markup.attr("width", format_d(w)),
      @markup.attr("height", format_d(h)),
      @markup.attr("fill", fill),
    ],
    [],
  )
}

///|
/// Format a double for SVG output; integral values omit the
/// fractional part. Mirrors `svg_render.mbt`'s `format_d` so the
/// two renderers share serialisation conventions.
fn format_d(value : Double) -> String {
  if value == value.to_int().to_double() {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

///|
/// String literal for a `SparklineKind` — surfaced as the
/// `data-ooxml-sparkline-type` attribute on the wrapping `<g>` so
/// downstream consumers can re-skin without re-parsing.
fn kind_to_string(k : SparklineKind) -> String {
  match k {
    Line => "line"
    Column => "column"
    Stacked => "stacked"
  }
}
