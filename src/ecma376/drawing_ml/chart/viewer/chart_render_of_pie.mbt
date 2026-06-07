// =============================================================================
// §21.2.2.126 CT_OfPieChart — pie-of-pie / bar-of-pie renderer.
//
// An <c:ofPieChart> is a TWO-TIER chart.  A PRIMARY pie shows the major
// data points plus one aggregated "Other" slice; a SECONDARY plot breaks
// that "Other" slice into its component points.  §21.2.2.127 ofPieType
// selects the secondary plot shape:
//
//   * ofPieType="pie"  → a small secondary PIE (the default).
//   * ofPieType="bar"  → a single STACKED vertical bar.
//
// Which points fall into the secondary plot is governed by §21.2.2.198
// splitType + §21.2.2.199 splitPos / §21.2.2.182 custSplit:
//
//   * "pos"     → the LAST `splitPos` points (by series order).
//   * "val"     → points whose value is < `splitPos`.
//   * "percent" → points whose value is < `splitPos`% of the total.
//   * "cust"    → exactly the indices listed by <c:secondPiePt>.
//   * "auto"    → implementation-defined; we mirror PowerPoint's common
//                 default of the LAST 2 points (documented below).
//
// §21.2.2.180 secondPieSize sets the secondary pie diameter as a percent
// of the primary (default 75%).
//
// The PRIMARY pie's slice geometry, the SECONDARY pie's slice geometry,
// and the plain pie/doughnut renderer ALL share `emit_pie_slices`
// (chart_render_pie.mbt) so the arc maths lives in exactly one place.
// Per-point dPt fills and series gradient/pattern fills flow through the
// same `collect_dpt_colors` / `resolve_series_fill` resolvers the plain
// pie uses, so overrides keep working across both tiers.
// =============================================================================

///|
/// §21.2.2.198 ST_SplitType — how the series points are partitioned
/// between the primary pie and the secondary plot.
priv enum OfPieSplit {
  /// "auto" — implementation default (last N points).
  Auto
  /// "cust" — explicit <c:secondPiePt> index list.
  Cust(Array[Int])
  /// "percent" — points below `pct`% of the total go to secondary.
  Percent(Double)
  /// "pos" — the last `count` points go to secondary.
  Pos(Int)
  /// "val" — points below `threshold` go to secondary.
  Val(Double)
}

///|
/// §21.2.2.198 splitType / §21.2.2.199 splitPos / §21.2.2.182 custSplit —
/// read the split rule from an <c:ofPieChart>.  `splitType` defaults to
/// "auto" (§21.2.2.198) when absent.  For "cust" the index list is read
/// from <c:custSplit>/<c:secondPiePt val="idx">.
fn read_of_pie_split(elem : @xml.Element) -> OfPieSplit {
  let split_type = match first_child_named(elem, "splitType") {
    Some(e) => attr_or(e, "val", "auto")
    None => "auto"
  }
  let split_pos = match first_child_named(elem, "splitPos") {
    Some(e) => parse_double_lenient(attr_or(e, "val", "0"))
    None => 0.0
  }
  match split_type {
    "pos" => OfPieSplit::Pos(split_pos.to_int())
    "val" => OfPieSplit::Val(split_pos)
    "percent" => OfPieSplit::Percent(split_pos)
    "cust" => {
      let idxs : Array[Int] = []
      match first_child_named(elem, "custSplit") {
        Some(cs) =>
          for ch in cs.children {
            match ch {
              @xml.Node::Element(e) =>
                if e.name.local_name == "secondPiePt" {
                  let idx = parse_int_lenient(attr_or(e, "val", "-1"))
                  if idx >= 0 {
                    idxs.push(idx)
                  }
                }
              _ => ()
            }
          }
        None => ()
      }
      OfPieSplit::Cust(idxs)
    }
    // "auto" and any unrecognised value fall through to the default.
    _ => OfPieSplit::Auto
  }
}

///|
/// Classify each point index as SECONDARY (true) or PRIMARY (false) per
/// the resolved split rule.  `values` carries the per-point magnitudes,
/// needed by the "val" / "percent" rules.
///
/// "auto" default: the LAST min(2, n-1) points go to the secondary plot.
/// We pick 2 because PowerPoint's pie-of-pie default groups the smallest
/// trailing points and 2 is the smallest count that still demonstrates
/// the two-tier split for the common 3-5 point series; we clamp to n-1 so
/// the primary pie always retains at least one own slice beside "Other".
fn classify_of_pie_secondary(
  split : OfPieSplit,
  values : Array[Double],
) -> Array[Bool] {
  let n = values.length()
  let is_secondary = Array::make(n, false)
  match split {
    OfPieSplit::Pos(count) => {
      // The LAST `count` points (clamped to [0, n-1] so the primary keeps
      // at least one own slice).
      let c = if count < 0 {
        0
      } else if count > n - 1 {
        if n > 0 {
          n - 1
        } else {
          0
        }
      } else {
        count
      }
      for i = n - c; i < n; i = i + 1 {
        if i >= 0 {
          is_secondary[i] = true
        }
      }
    }
    OfPieSplit::Val(threshold) =>
      for i = 0; i < n; i = i + 1 {
        if values[i] > 0.0 && values[i] < threshold {
          is_secondary[i] = true
        }
      }
    OfPieSplit::Percent(pct) => {
      let total = sum_positive(values)
      if total > 0.0 {
        for i = 0; i < n; i = i + 1 {
          if values[i] > 0.0 && values[i] / total * 100.0 < pct {
            is_secondary[i] = true
          }
        }
      }
    }
    OfPieSplit::Cust(idxs) =>
      for idx in idxs {
        if idx >= 0 && idx < n {
          is_secondary[idx] = true
        }
      }
    OfPieSplit::Auto => {
      // Last min(2, n-1) points.
      let want = if n - 1 < 2 { n - 1 } else { 2 }
      let c = if want < 0 { 0 } else { want }
      for i = n - c; i < n; i = i + 1 {
        if i >= 0 {
          is_secondary[i] = true
        }
      }
    }
  }
  is_secondary
}

///|
/// §21.2.2.180 secondPieSize — secondary pie diameter as a percent of the
/// primary pie's diameter.  Default 75 (§21.2.2.180); clamped to a sane
/// (0,200] range so a malformed value cannot blow up the layout.
fn read_second_pie_size(elem : @xml.Element) -> Double {
  match first_child_named(elem, "secondPieSize") {
    None => 75.0
    Some(e) => {
      let v = parse_double_lenient(attr_or(e, "val", "75"))
      if v <= 0.0 || v > 200.0 {
        75.0
      } else {
        v
      }
    }
  }
}

///|
/// §21.2.2.194 CT_ChartLines / §20.1.2.2.24 ln — resolve the line
/// properties carried by `<c:serLines>`.  Explicit `<a:noFill/>` means
/// the requested chart line has no visible stroke.
fn of_pie_ser_line_style(
  ser_lines : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  style : ChartStyleDefaults,
  default_width : Double,
) -> ChartLineStyle? {
  chart_lines_style(
    ser_lines,
    ctx,
    defs,
    "chart-of-pie-ser-lines",
    style.axis_color,
    default_width,
  )
}

///|
/// §21.2.2.194 serLines — connector from the primary "Other" wedge to
/// the secondary of-pie plot.  The caller has already proven that both
/// tiers exist; this helper only applies the CT_ChartLines styling.
fn render_of_pie_ser_line(
  ser_lines : @xml.Element,
  edge_x : Double,
  edge_y : Double,
  secondary_cx : Double,
  secondary_cy : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  style : ChartStyleDefaults,
  default_width : Double,
) -> @xml.Node? {
  match of_pie_ser_line_style(ser_lines, ctx, defs, style, default_width) {
    Some(line_style) => {
      let attrs : Array[@xml.Attribute] = [
        @markup.attr("x1", format_double(edge_x)),
        @markup.attr("y1", format_double(edge_y)),
        @markup.attr("x2", format_double(secondary_cx)),
        @markup.attr("y2", format_double(secondary_cy)),
        @markup.attr("data-ooxml", "chart-ser-lines"),
      ]
      push_chart_line_style_attrs(attrs, line_style)
      Some(@markup.elem_ns("line", @markup.svg_ns, attrs, []))
    }
    None => None
  }
}

///|
/// §21.2.2.126 CT_OfPieChart — render a pie-of-pie / bar-of-pie chart.
///
/// The single <c:ser> is split into PRIMARY and SECONDARY point sets
/// (`read_of_pie_split` + `classify_of_pie_secondary`).  The PRIMARY pie
/// occupies the LEFT half of the frame and draws the primary points plus
/// one aggregated "Other" wedge (value = Σ secondary points).  The
/// SECONDARY plot occupies the RIGHT half: for ofPieType="pie" a smaller
/// pie of the secondary points (diameter per secondPieSize), for
/// ofPieType="bar" a single stacked vertical bar.  When `<c:serLines>`
/// is present, a connector line links the primary "Other" wedge to the
/// secondary plot.
///
/// Signature mirrors the axis-bearing dispatch cases (`iw/ih` inner rect,
/// `fw/fh` outer frame, `axes`, `style`, `defs`) so the dispatcher wires
/// it identically; the pie geometry itself uses only `w/h/ctx/defs`, but
/// `style` supplies the label font/colour and `axes`/`fw`/`fh` are
/// accepted for dispatch uniformity.
fn render_of_pie_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  _fw : Double,
  _fh : Double,
  ctx : ColorResolveContext,
  _axes : ChartAxesInfo,
  style : ChartStyleDefaults,
  defs : SvgDefsCollector,
  disp_blanks_as? : @chart.ST_DispBlanksAs = @chart.ST_DispBlanksAs::DispBlanksAsZero,
) -> Array[@xml.Node] {
  let ser = match first_child_named(elem, "ser") {
    Some(s) => s
    None => return []
  }
  let values = read_val_number_slots(ser)
  if values.length() == 0 {
    return []
  }
  let cat_labels = read_cat_labels(ser)
  let split = read_of_pie_split(elem)
  let is_secondary = classify_of_pie_secondary(
    split,
    number_slots_to_zeroes(values),
  )

  // Partition into primary points (own slices) + secondary points, and
  // compute the aggregated "Other" value (Σ positive secondary points).
  let primary_slices : Array[PieSlice] = []
  let secondary_slices : Array[PieSlice] = []
  let dpt_overrides = collect_dpt_colors(ser, ctx, defs, "ofpie")
  let series_color = resolve_series_color(ser, 0, ctx, defs)
  let vary_colors = chart_vary_colors(elem)
  let mut other_value = 0.0
  for point in chart_rendered_points(values, disp_blanks_as) {
    let (i, v) = point
    if v <= 0.0 {
      continue
    }
    // §21.2.2.227 varyColors — pie points vary by the accent palette;
    // honour per-point dPt fill overrides (gradient/pattern resolved by
    // collect_dpt_colors) first, falling back to the palette by index.
    let color = match dpt_color_for(dpt_overrides, i) {
      Some(c) => c
      None =>
        if vary_colors {
          chart_series_color(ctx, i)
        } else {
          series_color
        }
    }
    if is_secondary[i] {
      secondary_slices.push({ value: v, color, explosion_pct: 0 })
      other_value = other_value + v
    } else {
      primary_slices.push({ value: v, color, explosion_pct: 0 })
    }
  }
  // Degenerate case: nothing was split off.  Fall back to a plain pie of
  // the primary points only (no synthetic "Other" wedge, no secondary
  // plot) so a misconfigured split still renders a sensible single pie.
  let primary_total = {
    let mut t = 0.0
    for s in primary_slices {
      t = t + s.value
    }
    t + other_value
  }
  if primary_total <= 0.0 {
    return []
  }

  // §21.2.2.227 — the aggregated "Other" wedge takes the next palette
  // colour after the primary points (so it reads distinctly from them).
  let other_color = if vary_colors {
    chart_series_color(ctx, primary_slices.length())
  } else {
    series_color
  }
  if other_value > 0.0 {
    primary_slices.push({
      value: other_value,
      color: other_color,
      explosion_pct: 0,
    })
  }

  // Layout: split the frame into a LEFT half (primary pie) and a RIGHT
  // half (secondary plot).  Each half hosts a centred plot; the pies are
  // sized to fit the smaller of the half-width / height.
  let half_w = w / 2.0
  let primary_cx = half_w / 2.0
  let primary_cy = h / 2.0
  let primary_outer = (if half_w < h { half_w } else { h }) * 0.42
  let secondary_cx = half_w + half_w / 2.0
  let secondary_cy = h / 2.0
  let nodes : Array[@xml.Node] = []

  // §21.2.2.68 firstSliceAng — primary pie start angle (default 0°).
  let start_deg = match first_child_named(elem, "firstSliceAng") {
    Some(a) => parse_int_lenient(attr_or(a, "val", "0"))
    None => 0
  }

  // PRIMARY pie.
  let primary_nodes = emit_pie_slices(
    primary_slices,
    primary_cx,
    primary_cy,
    primary_outer,
    0.0,
    primary_total,
    start_deg.to_double(),
  )
  for nd in primary_nodes {
    nodes.push(nd)
  }

  // §21.2.2.127 ofPieType — secondary plot shape (default "pie").
  let of_pie_type = match first_child_named(elem, "ofPieType") {
    Some(e) => attr_or(e, "val", "pie")
    None => "pie"
  }
  let secondary_total = {
    let mut t = 0.0
    for s in secondary_slices {
      t = t + s.value
    }
    t
  }

  // §21.2.2.194 serLines — link the primary "Other" wedge midpoint to
  // the secondary plot.  Drawn BEFORE the secondary shapes so it sits
  // beneath them.
  // The "Other" wedge is the LAST primary slice; its midpoint angle is
  // start + (primary_total - other_value)/primary_total*360 + half its
  // own sweep.
  match first_child_named(elem, "serLines") {
    Some(ser_lines) =>
      if other_value > 0.0 && secondary_total > 0.0 {
        let pi = 3.141592653589793
        let other_start = start_deg.to_double() +
          (primary_total - other_value) / primary_total * 360.0
        let other_mid = other_start + other_value / primary_total * 360.0 / 2.0
        let a = (other_mid - 90.0) * pi / 180.0
        let edge_x = primary_cx + primary_outer * @math.cos(a)
        let edge_y = primary_cy + primary_outer * @math.sin(a)
        match
          render_of_pie_ser_line(
            ser_lines,
            edge_x,
            edge_y,
            secondary_cx,
            secondary_cy,
            ctx,
            defs,
            style,
            primary_outer * 0.02,
          ) {
          Some(line) => nodes.push(line)
          None => ()
        }
      }
    None => ()
  }

  if secondary_total > 0.0 {
    if of_pie_type == "bar" {
      // §21.2.2.127 ofPieType="bar" — a single STACKED vertical bar of
      // the secondary points centred in the right half.
      let bar_nodes = emit_of_pie_secondary_bar(
        secondary_slices, secondary_cx, secondary_cy, half_w, h, secondary_total,
      )
      for nd in bar_nodes {
        nodes.push(nd)
      }
    } else {
      // §21.2.2.127 ofPieType="pie" + §21.2.2.180 secondPieSize — a
      // smaller pie scaled relative to the primary diameter.
      let size_pct = read_second_pie_size(elem)
      let secondary_outer = primary_outer * (size_pct / 100.0)
      let secondary_nodes = emit_pie_slices(
        secondary_slices,
        secondary_cx,
        secondary_cy,
        secondary_outer,
        0.0,
        secondary_total,
        start_deg.to_double(),
      )
      for nd in secondary_nodes {
        nodes.push(nd)
      }
    }
  }

  // §21.2.2.49 dLbls — labels on the PRIMARY pie's own points + the
  // "Other" wedge.  Reuse the shared data-label text builder; placement
  // mirrors the plain pie's interior labels (slice mid-radius).
  match read_data_labels(elem) {
    Some(cfg) => {
      let ser_name = match read_series_name(ser) {
        Some(nm) => nm
        None => ""
      }
      let value_num_fmt = read_val_number_format(ser)
      let pi = 3.141592653589793
      let label_r = primary_outer * 0.6
      let font_size = (if half_w < h { half_w } else { h }) * 0.04
      // Walk the SAME primary point order used to build `primary_slices`
      // so label angles align with the rendered wedges.
      let mut accum = start_deg.to_double()
      // Per-point primary labels, in the SAME order the wedges were
      // emitted (primary points in series order, secondary skipped).
      for point in chart_rendered_points(values, disp_blanks_as) {
        let (i, v) = point
        if v <= 0.0 || is_secondary[i] {
          continue
        }
        let sweep = v / primary_total * 360.0
        let mid = accum + sweep / 2.0
        let a = (mid - 90.0) * pi / 180.0
        let lx = primary_cx + label_r * @math.cos(a)
        let ly = primary_cy + label_r * @math.sin(a)
        let cat_name = if i < cat_labels.length() { cat_labels[i] } else { "" }
        let text = build_data_label_text(
          cfg,
          v,
          cat_name,
          ser_name,
          primary_total,
          value_num_fmt~,
        )
        if text.length() > 0 {
          nodes.push(of_pie_label(lx, ly, text, font_size, style))
        }
        accum = accum + sweep
      }
      // "Other" wedge label.
      if other_value > 0.0 {
        let sweep = other_value / primary_total * 360.0
        let mid = accum + sweep / 2.0
        let a = (mid - 90.0) * pi / 180.0
        let lx = primary_cx + label_r * @math.cos(a)
        let ly = primary_cy + label_r * @math.sin(a)
        let text = build_data_label_text(
          cfg,
          other_value,
          "Other",
          ser_name,
          primary_total,
          value_num_fmt~,
        )
        if text.length() > 0 {
          nodes.push(of_pie_label(lx, ly, text, font_size, style))
        }
      }
    }
    None => ()
  }
  nodes
}

///|
/// §21.2.2.127 ofPieType="bar" — emit a single STACKED vertical bar of
/// the secondary points, centred at `(cx, cy)` within a right-half region
/// of width `region_w` and height `region_h`.  Segments stack from the
/// bottom up in series order; each segment's height is proportional to
/// its value over the secondary total.  Segment fills reuse the resolved
/// per-point colours from the slice descriptors.
fn emit_of_pie_secondary_bar(
  segments : Array[PieSlice],
  cx : Double,
  cy : Double,
  region_w : Double,
  region_h : Double,
  total : Double,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  if total <= 0.0 {
    return nodes
  }
  // Bar geometry: width = 30% of the region width, height = 70% of the
  // region height, vertically centred at `cy`.
  let bar_w = region_w * 0.3
  let bar_h = region_h * 0.7
  let bar_x = cx - bar_w / 2.0
  let bar_top = cy - bar_h / 2.0
  // Stack from the bottom up.
  let mut y = bar_top + bar_h
  for s in segments {
    if s.value <= 0.0 {
      continue
    }
    let seg_h = s.value / total * bar_h
    let seg_top = y - seg_h
    nodes.push(
      @markup.elem_ns(
        "rect",
        @markup.svg_ns,
        [
          @markup.attr("x", format_double(bar_x)),
          @markup.attr("y", format_double(seg_top)),
          @markup.attr("width", format_double(bar_w)),
          @markup.attr("height", format_double(seg_h)),
          @markup.attr("fill", s.color),
          @markup.attr("stroke", "#ffffff"),
          @markup.attr("stroke-width", format_double(bar_w * 0.02)),
        ],
        [],
      ),
    )
    y = seg_top
  }
  nodes
}

///|
/// §21.2.2.49 — build one interior data-label text node for the ofPie
/// primary pie, honouring the chart text colour / font from `style`.
fn of_pie_label(
  x : Double,
  y : Double,
  text : String,
  font_size : Double,
  style : ChartStyleDefaults,
) -> @xml.Node {
  @markup.elem_ns(
    "text",
    @markup.svg_ns,
    [
      @markup.attr("x", format_double(x)),
      @markup.attr("y", format_double(y)),
      @markup.attr("text-anchor", "middle"),
      @markup.attr("dominant-baseline", "middle"),
      @markup.attr("font-size", format_double(font_size)),
      @markup.attr("fill", style.text_color),
      @markup.attr("font-family", style.font_family),
    ],
    [@markup.text(text)],
  )
}
