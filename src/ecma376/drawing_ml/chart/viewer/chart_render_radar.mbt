// =============================================================================
// §21.2.2.150 CT_RadarChart — radar (spider / web) chart renderer.
// Draws a regular polygon per series on a circular grid with radial
// axes from the centre. The number of spokes equals the category count.
// Each series fills with a semi-transparent accent colour.
// =============================================================================

///|
fn render_radar_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  _fw : Double,
  _fh : Double,
  ctx : ColorResolveContext,
  style : ChartStyleDefaults,
) -> Array[@xml.Node] {
  // §21.2.2.153 radarStyle — "filled" uses opaque fill, "marker"
  // uses outline + markers.
  let radar_style = match first_child_named(elem, "radarStyle") {
    Some(s) => attr_or(s, "val", "marker")
    None => "marker"
  }
  let is_filled = radar_style == "filled"
  let all_series : Array[(Array[String], Array[Double])] = []
  let ser_elems : Array[@xml.Element] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_labels(se)
          let values = read_val_numbers(se)
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
  let n = labels.length()
  if n == 0 {
    return []
  }
  let mut data_max = 0.0
  for s in all_series {
    let (_, values) = s
    let mv = max_positive(values)
    if mv > data_max {
      data_max = mv
    }
  }
  let max_v = nice_axis_max(data_max)
  if max_v <= 0.0 {
    return []
  }
  let cx = w / 2.0
  let cy = h / 2.0
  let outer_r = (if w < h { w } else { h }) * 0.44
  let pi = 3.141592653589793
  let angle_step = 2.0 * pi / n.to_double()
  // Spoke angle: start from 12 o'clock (−π/2), clockwise.
  let spoke_angle = fn(i : Int) -> Double {
    -pi / 2.0 + i.to_double() * angle_step
  }
  let nodes : Array[@xml.Node] = []
  // §21.2.2.153 — radial axis uses 2–3 grid rings. The reference
  // renderer targets 2 intervals for the radial axis, so we compute
  // the step as max_v / 2 rounded to the nearest 1-2-5 step.
  let radar_step = {
    let raw = max_v / 2.5
    let mut ord = 1.0
    while ord * 10.0 <= raw {
      ord = ord * 10.0
    }
    while ord > raw {
      ord = ord / 10.0
    }
    let m = raw / ord
    let cands = [1.0, 2.0, 5.0, 10.0]
    let mut result = 10.0 * ord
    for c in cands {
      if c >= m {
        result = c * ord
        break
      }
    }
    result
  }
  let grid_levels_safe = {
    let gl = (max_v / radar_step + 0.5).to_int()
    if gl < 1 {
      1
    } else {
      gl
    }
  }
  let grid_color = style.grid_color
  let grid_stroke = format_double(h * 0.002)
  let mut lvl = 1
  while lvl <= grid_levels_safe {
    let r = outer_r * lvl.to_double() / grid_levels_safe.to_double()
    let ring_buf = StringBuilder::new()
    let mut first = true
    let mut i = 0
    while i < n {
      let a = spoke_angle(i)
      let x = cx + r * @math.cos(a)
      let y = cy + r * @math.sin(a)
      if !first {
        ring_buf.write_string(" ")
      }
      ring_buf.write_string(format_double(x))
      ring_buf.write_string(",")
      ring_buf.write_string(format_double(y))
      first = false
      i = i + 1
    }
    nodes.push(
      @markup.elem_ns(
        "polygon",
        @markup.svg_ns,
        [
          @markup.attr("points", ring_buf.to_string()),
          @markup.attr("fill", "none"),
          @markup.attr("stroke", grid_color),
          @markup.attr("stroke-width", grid_stroke),
        ],
        [],
      ),
    )
    lvl = lvl + 1
  }
  // Draw radial spoke lines from centre to outer ring.
  let mut i = 0
  while i < n {
    let a = spoke_angle(i)
    let x = cx + outer_r * @math.cos(a)
    let y = cy + outer_r * @math.sin(a)
    nodes.push(
      @markup.elem_ns(
        "line",
        @markup.svg_ns,
        [
          @markup.attr("x1", format_double(cx)),
          @markup.attr("y1", format_double(cy)),
          @markup.attr("x2", format_double(x)),
          @markup.attr("y2", format_double(y)),
          @markup.attr("stroke", grid_color),
          @markup.attr("stroke-width", grid_stroke),
        ],
        [],
      ),
    )
    i = i + 1
  }
  // Draw each series polygon (BEFORE axis labels so labels render on top).
  let mut si = all_series.length() - 1
  while si >= 0 {
    let (_, values) = all_series[si]
    let series_color = resolve_series_color(ser_elems[si], si, ctx)
    let poly_buf = StringBuilder::new()
    let mut first = true
    let mut j = 0
    while j < n && j < values.length() {
      let a = spoke_angle(j)
      let r = values[j] / max_v * outer_r
      let x = cx + r * @math.cos(a)
      let y = cy + r * @math.sin(a)
      if !first {
        poly_buf.write_string(" ")
      }
      poly_buf.write_string(format_double(x))
      poly_buf.write_string(",")
      poly_buf.write_string(format_double(y))
      first = false
      j = j + 1
    }
    nodes.push(
      @markup.elem_ns(
        "polygon",
        @markup.svg_ns,
        [
          @markup.attr("points", poly_buf.to_string()),
          @markup.attr("fill", if is_filled { series_color } else { "none" }),
          @markup.attr("stroke", series_color),
          @markup.attr("stroke-width", format_double(h * 0.004)),
          @markup.attr("stroke-linejoin", "round"),
        ],
        [],
      ),
    )
    // §21.2.2.153 radarStyle — "marker" emits circle markers at each
    // vertex.  "standard" draws lines only; "filled" fills the polygon
    // (no markers).  The renderer's default when `<c:radarStyle>` is
    // absent is "marker" so pruning the element brings markers BACK
    // — matching the schema's default `<c:radarStyle val="marker"/>`
    // semantics inside Office.
    if radar_style == "marker" {
      let marker_r = h * 0.01
      let mut jm = 0
      while jm < n && jm < values.length() {
        let a = spoke_angle(jm)
        let r = values[jm] / max_v * outer_r
        let x = cx + r * @math.cos(a)
        let y = cy + r * @math.sin(a)
        nodes.push(
          @markup.elem_ns(
            "circle",
            @markup.svg_ns,
            [
              @markup.attr("cx", format_double(x)),
              @markup.attr("cy", format_double(y)),
              @markup.attr("r", format_double(marker_r)),
              @markup.attr("fill", series_color),
            ],
            [],
          ),
        )
        jm = jm + 1
      }
    }
    si = si - 1
  }
  // Category labels at the outer ring + small offset.
  let label_r = outer_r * 1.12
  let mut k = 0
  while k < n && k < labels.length() {
    let a = spoke_angle(k)
    let lx = cx + label_r * @math.cos(a)
    let ly = cy + label_r * @math.sin(a)
    let anchor = if @math.cos(a) < -0.1 {
      "end"
    } else if @math.cos(a) > 0.1 {
      "start"
    } else {
      "middle"
    }
    let baseline = if @math.sin(a) < -0.1 {
      "auto"
    } else if @math.sin(a) > 0.1 {
      "hanging"
    } else {
      "middle"
    }
    nodes.push(
      chart_text(labels[k], lx, ly, w, h, anchor~, baseline~, style=Some(style)),
    )
    k = k + 1
  }
  // Axis value labels along the first spoke (on top of polygon).
  let font_size = (if w < h { w } else { h }) * 0.03
  let mut lv = 0.0
  while lv <= max_v + radar_step * 0.001 {
    let frac = lv / max_v
    let label_y = cy - frac * outer_r
    let label = format_axis_value(lv)
    nodes.push(
      @markup.elem_ns(
        "text",
        @markup.svg_ns,
        [
          @markup.attr("x", format_double(cx + font_size * 0.3)),
          @markup.attr("y", format_double(label_y)),
          @markup.attr("text-anchor", "start"),
          @markup.attr("dominant-baseline", "middle"),
          @markup.attr("font-size", format_double(font_size)),
          @markup.attr("fill", style.text_color),
          @markup.attr("font-family", style.font_family),
        ],
        [@markup.text(label)],
      ),
    )
    lv = lv + radar_step
  }
  nodes
}
