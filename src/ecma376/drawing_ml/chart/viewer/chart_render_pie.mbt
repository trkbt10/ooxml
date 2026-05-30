// =============================================================================
// §21.2.2.141 CT_PieChart / §21.2.2.57 CT_DoughnutChart — slice renderer.
// For each `<c:val>` data point we compute its angular share of the
// total sum, then emit an SVG `<path>` describing a filled pie wedge.
// When `hole_percent` is `Some(p)`, an inner arc traces a concentric
// circle at radius `outer*p/100` to produce a doughnut cutout.
//
// Slice colours rotate through the accent palette (§21.2.2.227
// `varyColors="1"` behavior the fixtures request).
// =============================================================================

///|
fn render_pie_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  ctx : ColorResolveContext,
  hole_percent~ : Int?,
) -> Array[@xml.Node] {
  let ser = match first_child_named(elem, "ser") {
    Some(s) => s
    None => return []
  }
  let values = read_val_numbers(ser)
  if values.length() == 0 {
    return []
  }
  let total = sum_positive(values)
  if total <= 0.0 {
    return []
  }
  // First-slice angle: §21.2.2.68 firstSliceAng (default 0°, clockwise
  // from 12 o'clock).
  let start_deg = match first_child_named(elem, "firstSliceAng") {
    Some(a) =>
      match attr_value(a, "val") {
        Some(v) => parse_int_lenient(v)
        None => 0
      }
    None => 0
  }
  // Centre + outer radius. Use the smaller of w/h so the circle fits
  // inside the frame. The 0.469 multiplier is the §21.2.2.141
  // implementation default for pie geometry on a 6 in × 4.5 in chart
  // frame: at 96dpi the pie bbox is (277,157)..(682,562), i.e.
  // diameter 405px = 303.75pt, radius 151.88pt; with min(w,h)=324pt
  // that yields 151.88/324 ≈ 0.469.
  let cx = w / 2.0
  let cy = h / 2.0
  let outer = (if w < h { w } else { h }) * 0.469
  let inner = match hole_percent {
    Some(p) => outer * (p.to_double() / 100.0)
    None => 0.0
  }
  let nodes : Array[@xml.Node] = []
  let dpt_overrides = collect_dpt_colors(ser, ctx)
  // §21.2.2.64 explosion — per-data-point slice offset (in % of
  // outer radius).  Series-level <c:explosion> applies to all
  // slices; per-dPt <c:explosion> overrides individual slices.
  let series_explosion = match first_child_named(ser, "explosion") {
    Some(e) => parse_int_lenient(attr_or(e, "val", "0"))
    None => 0
  }
  let dpt_explosions = collect_dpt_explosions(ser)
  let mut accum_deg = start_deg.to_double()
  for i, v in values {
    if v <= 0.0 {
      continue
    }
    let frac = v / total
    let sweep_deg = frac * 360.0
    let color = match dpt_color_for(dpt_overrides, i) {
      Some(c) => c
      None => chart_series_color(ctx, i)
    }
    let expl_pct = {
      let dpt_v = dpt_explosion_for(dpt_explosions, i)
      if dpt_v > 0 { dpt_v } else { series_explosion }
    }
    // Slice offset: shift centre outward along the slice's midpoint
    // direction by `outer * expl_pct / 100`.
    let (slice_cx, slice_cy) = if expl_pct > 0 {
      let mid_deg = accum_deg + sweep_deg / 2.0
      let pi = 3.141592653589793
      let rad = (mid_deg - 90.0) * pi / 180.0
      let off = outer * expl_pct.to_double() / 100.0
      let dx = @math.cos(rad) * off
      let dy = @math.sin(rad) * off
      (cx + dx, cy + dy)
    } else {
      (cx, cy)
    }
    let path_d = pie_slice_path(
      slice_cx,
      slice_cy,
      outer,
      inner,
      accum_deg,
      accum_deg + sweep_deg,
    )
    nodes.push(
      @markup.elem_ns(
        "path",
        @markup.svg_ns,
        [
          @markup.attr("d", path_d),
          @markup.attr("fill", color),
          @markup.attr("stroke", "#ffffff"),
          @markup.attr("stroke-width", format_double(outer * 0.01)),
        ],
        [],
      ),
    )
    accum_deg = accum_deg + sweep_deg
  }
  // §21.2.2.49 dLbls — pie labels at each slice's midpoint.
  let dlbl_config = read_data_labels(elem)
  match dlbl_config {
    Some(cfg) => {
      let cat_labels = read_cat_labels(ser)
      let ser_name = match read_series_name(ser) {
        Some(nm) => nm
        None => ""
      }
      let pi = 3.141592653589793
      // §21.2.2.48 dLblPos — "outEnd" / "bestFit" place labels OUTSIDE
      // the pie; everything else (default) places them at the slice
      // mid-radius.  External labels get §21.2.2.92 leaderLines (when
      // requested) connecting the slice edge to the label.
      let external = cfg.pos == "outEnd" || cfg.pos == "bestFit"
      let label_r = if external { outer * 1.18 } else { (outer + inner) / 2.0 }
      if label_r <= 0.0 {
        return nodes
      }
      let font_size = (if w < h { w } else { h }) * 0.03
      let mut deg2 = start_deg.to_double()
      for i, v in values {
        if v <= 0.0 {
          continue
        }
        let frac = v / total
        let sweep = frac * 360.0
        let mid_deg = deg2 + sweep / 2.0
        let a = (mid_deg - 90.0) * pi / 180.0
        let ca = @math.cos(a)
        let sa = @math.sin(a)
        let lx = cx + label_r * ca
        let ly = cy + label_r * sa
        let cat_name = if i < cat_labels.length() {
          cat_labels[i]
        } else {
          ""
        }
        let text = build_data_label_text(cfg, v, cat_name, ser_name, total)
        if text.length() > 0 {
          // §21.2.2.92 leaderLines — for an external label, draw a
          // connector from the slice's outer edge to the label, then
          // anchor the text on the side it sits (left / right).
          if external && cfg.show_leader_lines {
            nodes.push(
              @markup.elem_ns(
                "line",
                @markup.svg_ns,
                [
                  @markup.attr("x1", format_double(cx + outer * ca)),
                  @markup.attr("y1", format_double(cy + outer * sa)),
                  @markup.attr("x2", format_double(lx)),
                  @markup.attr("y2", format_double(ly)),
                  @markup.attr("stroke", "#808080"),
                  @markup.attr("stroke-width", format_double(font_size * 0.08)),
                ],
                [],
              ),
            )
          }
          let (anchor, fill) = if external {
            // Right half → start (left-anchored); left half → end.
            ((if ca >= 0.0 { "start" } else { "end" }), "#404040")
          } else {
            ("middle", "#ffffff")
          }
          nodes.push(
            @markup.elem_ns(
              "text",
              @markup.svg_ns,
              [
                @markup.attr("x", format_double(lx)),
                @markup.attr("y", format_double(ly)),
                @markup.attr("text-anchor", anchor),
                @markup.attr("dominant-baseline", "middle"),
                @markup.attr("font-size", format_double(font_size)),
                @markup.attr("fill", fill),
                @markup.attr("font-family", "sans-serif"),
              ],
              [@markup.text(text)],
            ),
          )
        }
        deg2 = deg2 + sweep
      }
    }
    None => ()
  }
  nodes
}

///|
/// §21.2.2.57 doughnutChart/holeSize — return the hole percentage,
/// falling back to the schema-default 10% when the element is absent or
/// the lexical value cannot be coerced to an integer. Accepts both
/// `<c:holeSize val="50%"/>` (spec form) and `<c:holeSize val="50"/>`
/// (the form commonly seen in real-world files and the catalog fixtures use).
fn doughnut_hole_percent(elem : @xml.Element) -> Int {
  match first_child_named(elem, "holeSize") {
    None => 10
    Some(hs) =>
      match attr_value(hs, "val") {
        None => 10
        Some(v) => {
          let trimmed_view = if v.length() > 0 &&
            v[v.length() - 1:v.length()] == "%" {
            v[0:v.length() - 1]
          } else {
            v[:]
          }
          let n = parse_int_lenient(trimmed_view.to_owned())
          if n <= 0 || n >= 100 {
            10
          } else {
            n
          }
        }
      }
  }
}

///|
/// Build an SVG path describing a pie wedge between `start_deg` and
/// `end_deg` (degrees, clockwise from 12 o'clock per §21.2.2.68). When
/// `inner > 0` the path traces an outer arc forward + inner arc back to
/// produce a doughnut slice.
fn pie_slice_path(
  cx : Double,
  cy : Double,
  outer : Double,
  inner : Double,
  start_deg : Double,
  end_deg : Double,
) -> String {
  // Convert clockwise-from-12 to SVG's anticlockwise-from-3 by subtracting
  // 90° and negating into the standard math convention. SVG's y-axis
  // points down so a clockwise arc on screen matches a clockwise OOXML
  // sweep when we use sweep_flag = 1 and the angles are converted as
  // below.
  let pi = 3.141592653589793
  let to_rad = fn(deg : Double) -> Double { (deg - 90.0) * pi / 180.0 }
  let a0 = to_rad(start_deg)
  let a1 = to_rad(end_deg)
  let sweep = end_deg - start_deg
  let large_arc = if sweep > 180.0 { 1 } else { 0 }
  let x0 = cx + outer * @math.cos(a0)
  let y0 = cy + outer * @math.sin(a0)
  let x1 = cx + outer * @math.cos(a1)
  let y1 = cy + outer * @math.sin(a1)
  let buf = StringBuilder::new()
  if inner <= 0.0 {
    // Solid wedge: M centre → L outer-start → A outer-end → Z.
    buf.write_string("M ")
    buf.write_string(format_double(cx))
    buf.write_string(",")
    buf.write_string(format_double(cy))
    buf.write_string(" L ")
    buf.write_string(format_double(x0))
    buf.write_string(",")
    buf.write_string(format_double(y0))
    buf.write_string(" A ")
    buf.write_string(format_double(outer))
    buf.write_string(",")
    buf.write_string(format_double(outer))
    buf.write_string(" 0 ")
    buf.write_string(large_arc.to_string())
    buf.write_string(" 1 ")
    buf.write_string(format_double(x1))
    buf.write_string(",")
    buf.write_string(format_double(y1))
    buf.write_string(" Z")
  } else {
    // Doughnut slice: M outer-start → A outer-end → L inner-end →
    // A inner-start (reverse sweep) → Z.
    let ix0 = cx + inner * @math.cos(a0)
    let iy0 = cy + inner * @math.sin(a0)
    let ix1 = cx + inner * @math.cos(a1)
    let iy1 = cy + inner * @math.sin(a1)
    buf.write_string("M ")
    buf.write_string(format_double(x0))
    buf.write_string(",")
    buf.write_string(format_double(y0))
    buf.write_string(" A ")
    buf.write_string(format_double(outer))
    buf.write_string(",")
    buf.write_string(format_double(outer))
    buf.write_string(" 0 ")
    buf.write_string(large_arc.to_string())
    buf.write_string(" 1 ")
    buf.write_string(format_double(x1))
    buf.write_string(",")
    buf.write_string(format_double(y1))
    buf.write_string(" L ")
    buf.write_string(format_double(ix1))
    buf.write_string(",")
    buf.write_string(format_double(iy1))
    buf.write_string(" A ")
    buf.write_string(format_double(inner))
    buf.write_string(",")
    buf.write_string(format_double(inner))
    buf.write_string(" 0 ")
    buf.write_string(large_arc.to_string())
    buf.write_string(" 0 ")
    buf.write_string(format_double(ix0))
    buf.write_string(",")
    buf.write_string(format_double(iy0))
    buf.write_string(" Z")
  }
  buf.to_string()
}
