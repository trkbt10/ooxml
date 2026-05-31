// §18.3.1.49 iconSet / §18.18.42 ST_IconSetType — render the actual
// conditional-format icon glyph for a cell's resolved (set, bucket),
// instead of surfacing the set name as metadata only.  Excel draws a
// concrete glyph per set: directional arrows, traffic-light circles,
// rating bars / stars / quarters, etc.  These are all expressible as
// SVG primitives, so we draw them — left-aligned in the cell — and the
// caller reserves the glyph's width so the cell text shifts right.
//
// The (set, bucket) pair is bucket 0 = lowest band … bucket (n-1) =
// highest band, matching Excel's value-ascending convention.

///|
/// Number of bands in an icon set (the leading digit of the
/// §18.18.42 ST_IconSetType name; defaults to 3).
fn icon_set_count(set_name : String) -> Int {
  if set_name.has_prefix("5") {
    5
  } else if set_name.has_prefix("4") {
    4
  } else {
    3
  }
}

///|
/// Linear interpolation between two `#rrggbb` colours at `t` ∈ [0,1].
fn icon_lerp_hex(
  lo : (Int, Int, Int),
  hi : (Int, Int, Int),
  t : Double,
) -> String {
  let tc = if t < 0.0 { 0.0 } else if t > 1.0 { 1.0 } else { t }
  let (lr, lg, lb) = lo
  let (hr, hg, hb) = hi
  let mix = fn(a : Int, b : Int) -> Int {
    let v = (a.to_double() + (b.to_double() - a.to_double()) * tc + 0.5).to_int()
    if v < 0 {
      0
    } else if v > 255 {
      255
    } else {
      v
    }
  }
  let nib = fn(n : Int) -> String {
    match n {
      0 => "0"
      1 => "1"
      2 => "2"
      3 => "3"
      4 => "4"
      5 => "5"
      6 => "6"
      7 => "7"
      8 => "8"
      9 => "9"
      10 => "a"
      11 => "b"
      12 => "c"
      13 => "d"
      14 => "e"
      _ => "f"
    }
  }
  let hex2 = fn(v : Int) -> String { nib(v / 16) + nib(v % 16) }
  let r = mix(lr, hr)
  let g = mix(lg, hg)
  let b = mix(lb, hb)
  "#" + hex2(r) + hex2(g) + hex2(b)
}

///|
/// Red → amber → green grade colour for band `bucket` of `count`
/// (lowest = red, highest = green) — the traffic-light / arrow scale.
fn icon_grade_color(bucket : Int, count : Int) -> String {
  if count <= 1 {
    return "#ffc000"
  }
  let t = bucket.to_double() / (count - 1).to_double()
  let red = (0xE0, 0x30, 0x30)
  let amber = (0xFF, 0xC0, 0x00)
  let green = (0x4C, 0xA0, 0x30)
  if t <= 0.5 {
    icon_lerp_hex(red, amber, t / 0.5)
  } else {
    icon_lerp_hex(amber, green, (t - 0.5) / 0.5)
  }
}

///|
/// A right-pointing arrow polygon in the unit square, rotated to face
/// the band direction (lowest band → down, middle → flat, highest →
/// up), scaled to `size` at (ox, oy).
fn icon_arrow_glyph(
  ox : Double,
  oy : Double,
  size : Double,
  bucket : Int,
  count : Int,
  color : String,
) -> @xml.Node {
  // Right-pointing arrow in [0,1]^2.
  let pts_unit = [
    (0.05, 0.35),
    (0.55, 0.35),
    (0.55, 0.18),
    (0.95, 0.5),
    (0.55, 0.82),
    (0.55, 0.65),
    (0.05, 0.65),
  ]
  let sb = StringBuilder::new()
  for i, p in pts_unit {
    let (ux, uy) = p
    if i > 0 {
      sb.write_char(' ')
    }
    sb.write_string(format_d(ox + ux * size))
    sb.write_char(',')
    sb.write_string(format_d(oy + uy * size))
  }
  // Direction: t=0 (lowest) points down (+90°), t=1 (highest) points
  // up (−90°), midband flat (0° = right).
  let t = if count <= 1 {
    0.5
  } else {
    bucket.to_double() / (count - 1).to_double()
  }
  let angle = 90.0 - 180.0 * t
  let cx = ox + size / 2.0
  let cy = oy + size / 2.0
  svg_elem(
    "polygon",
    [
      svg_attr("points", sb.to_string()),
      svg_attr("fill", color),
      svg_attr(
        "transform",
        "rotate(" +
        format_d(angle) +
        " " +
        format_d(cx) +
        " " +
        format_d(cy) +
        ")",
      ),
    ],
    [],
  )
}

///|
/// A filled circle band glyph (traffic lights / signs / flags / red-to-
/// black).
fn icon_circle_glyph(
  ox : Double,
  oy : Double,
  size : Double,
  color : String,
) -> @xml.Node {
  svg_elem(
    "circle",
    [
      svg_attr("cx", format_d(ox + size / 2.0)),
      svg_attr("cy", format_d(oy + size / 2.0)),
      svg_attr("r", format_d(size * 0.42)),
      svg_attr("fill", color),
    ],
    [],
  )
}

///|
/// A pie/quarters glyph: a circle outline with a `t`-fraction sector
/// filled clockwise from 12 o'clock (§18.18.42 `5Quarters`).
fn icon_quarter_glyph(
  ox : Double,
  oy : Double,
  size : Double,
  bucket : Int,
  count : Int,
) -> Array[@xml.Node] {
  let cx = ox + size / 2.0
  let cy = oy + size / 2.0
  let r = size * 0.42
  let nodes : Array[@xml.Node] = [
    svg_elem(
      "circle",
      [
        svg_attr("cx", format_d(cx)),
        svg_attr("cy", format_d(cy)),
        svg_attr("r", format_d(r)),
        svg_attr("fill", "#ffffff"),
        svg_attr("stroke", "#404040"),
        svg_attr("stroke-width", format_d(size * 0.06)),
      ],
      [],
    ),
  ]
  let frac = if count <= 1 {
    1.0
  } else {
    bucket.to_double() / (count - 1).to_double()
  }
  if frac >= 0.999 {
    nodes.push(
      svg_elem(
        "circle",
        [
          svg_attr("cx", format_d(cx)),
          svg_attr("cy", format_d(cy)),
          svg_attr("r", format_d(r)),
          svg_attr("fill", "#404040"),
        ],
        [],
      ),
    )
  } else if frac > 0.001 {
    let theta = frac * 2.0 * 3.14159265358979
    let ex = cx + r * @math.sin(theta)
    let ey = cy - r * @math.cos(theta)
    let large = if frac > 0.5 { 1 } else { 0 }
    let d = "M " +
      format_d(cx) +
      " " +
      format_d(cy) +
      " L " +
      format_d(cx) +
      " " +
      format_d(cy - r) +
      " A " +
      format_d(r) +
      " " +
      format_d(r) +
      " 0 " +
      large.to_string() +
      " 1 " +
      format_d(ex) +
      " " +
      format_d(ey) +
      " Z"
    nodes.push(
      svg_elem("path", [svg_attr("d", d), svg_attr("fill", "#404040")], []),
    )
  }
  nodes
}

///|
/// A segmented signal-strength bar: `count` cells, the lowest
/// `bucket + 1` filled grade-coloured, the rest light grey
/// (§18.18.42 `*Rating` / `*Boxes`).
fn icon_bar_glyph(
  ox : Double,
  oy : Double,
  size : Double,
  bucket : Int,
  count : Int,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  let gap = size * 0.12
  let seg_w = (size - gap * (count - 1).to_double()) / count.to_double()
  for i = 0; i < count; i = i + 1 {
    // Bars grow in height left→right; the lowest `bucket+1` are filled.
    let h_frac = 0.4 + 0.6 * (i.to_double() / (count - 1).max(1).to_double())
    let bh = size * h_frac
    let bx = ox + i.to_double() * (seg_w + gap)
    let by = oy + size - bh
    let filled = i <= bucket
    nodes.push(
      svg_elem(
        "rect",
        [
          svg_attr("x", format_d(bx)),
          svg_attr("y", format_d(by)),
          svg_attr("width", format_d(seg_w)),
          svg_attr("height", format_d(bh)),
          svg_attr("fill", if filled { "#4c7fd0" } else { "#d0d0d0" }),
        ],
        [],
      ),
    )
  }
  nodes
}

///|
/// A row of `count` stars, the lowest `bucket + 1` filled gold, the
/// rest grey outlines (§18.18.42 `3Stars`).
fn icon_stars_glyph(
  ox : Double,
  oy : Double,
  size : Double,
  bucket : Int,
  count : Int,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  let star_w = size / count.to_double()
  let r = star_w * 0.45
  for i = 0; i < count; i = i + 1 {
    let cx = ox + (i.to_double() + 0.5) * star_w
    let cy = oy + size / 2.0
    // Five-point star polygon.
    let sb = StringBuilder::new()
    for k = 0; k < 10; k = k + 1 {
      let rad = if k % 2 == 0 { r } else { r * 0.4 }
      let ang = -3.14159265358979 / 2.0 + k.to_double() * 3.14159265358979 / 5.0
      if k > 0 {
        sb.write_char(' ')
      }
      sb.write_string(format_d(cx + rad * @math.cos(ang)))
      sb.write_char(',')
      sb.write_string(format_d(cy + rad * @math.sin(ang)))
    }
    let filled = i <= bucket
    nodes.push(
      svg_elem(
        "polygon",
        [
          svg_attr("points", sb.to_string()),
          svg_attr("fill", if filled { "#f0b000" } else { "#d0d0d0" }),
        ],
        [],
      ),
    )
  }
  nodes
}

///|
/// §18.3.1.49 — render the icon-set glyph for `(set_name, bucket)` at
/// the left of the cell, plus the reserved horizontal width the caller
/// should shift the cell text by.  The glyph carries the `data-ooxml-*`
/// metadata as before so consumers can still re-derive the raw values.
fn render_cell_icon_glyph(
  layout : CellLayout,
  set_name : String,
  bucket : Int,
) -> (Array[@xml.Node], Double) {
  // Square glyph centred vertically, sized to the cell height (capped).
  let size = {
    let s = layout.height * 0.66
    let cap = if layout.width * 0.5 < 18.0 { layout.width * 0.5 } else { 18.0 }
    if s > cap {
      cap
    } else {
      s
    }
  }
  if size <= 1.0 {
    // Too small to draw — fall back to metadata only, no reserved space.
    return (render_cell_icon_metadata(layout, set_name, bucket), 0.0)
  }
  let pad = (layout.height - size) / 2.0
  let ox = layout.x + pad
  let oy = layout.y + pad
  let count = icon_set_count(set_name)
  // Clamp the bucket into [0, count-1].
  let band = if bucket < 0 {
    0
  } else if bucket >= count {
    count - 1
  } else {
    bucket
  }
  let glyph : Array[@xml.Node] = if set_name.contains("Arrows") {
    let color = if set_name.contains("Gray") {
      "#808080"
    } else {
      icon_grade_color(band, count)
    }
    [icon_arrow_glyph(ox, oy, size, band, count, color)]
  } else if set_name.contains("Triangles") {
    [icon_arrow_glyph(ox, oy, size, band, count, icon_grade_color(band, count))]
  } else if set_name.contains("Stars") {
    icon_stars_glyph(ox, oy, size, band, count)
  } else if set_name.contains("Quarters") {
    icon_quarter_glyph(ox, oy, size, band, count)
  } else if set_name.contains("Rating") || set_name.contains("Boxes") {
    icon_bar_glyph(ox, oy, size, band, count)
  } else if set_name.contains("RedToBlack") {
    // Highest = red, lowest = black (the set's own ordering runs the
    // colour from red down to black).
    let t = if count <= 1 {
      1.0
    } else {
      band.to_double() / (count - 1).to_double()
    }
    [
      icon_circle_glyph(
        ox,
        oy,
        size,
        icon_lerp_hex((0, 0, 0), (0xE0, 0x30, 0x30), t),
      ),
    ]
  } else {
    // TrafficLights / Signs / Flags / Symbols and any other set:
    // a grade-coloured circle.
    [icon_circle_glyph(ox, oy, size, icon_grade_color(band, count))]
  }
  let group = svg_elem(
    "g",
    [
      svg_attr("class", "cf-icon"),
      svg_attr("data-ooxml-icon", set_name),
      svg_attr("data-ooxml-bucket", bucket.to_string()),
    ],
    glyph,
  )
  // Reserve the glyph width plus a small right pad for the text shift.
  (([group] : Array[@xml.Node]), size + layout.height * 0.18)
}
