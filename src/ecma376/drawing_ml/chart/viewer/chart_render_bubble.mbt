// =============================================================================
// §21.2.2.21 CT_BubbleChart — bubble chart renderer.
// Like a scatter chart but each data point carries a third dimension
// (`<c:bubbleSize>`) that controls the circle radius. When `bubbleSize`
// is absent, all points render at a uniform default size.
// =============================================================================

///|
fn render_bubble_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : ChartAxesInfo,
  style : ChartStyleDefaults,
  defs : SvgDefsCollector,
) -> Array[@xml.Node] {
  let ser = match first_child_named(elem, "ser") {
    Some(s) => s
    None => return []
  }
  let xs = read_axis_numbers(ser, "xVal")
  let ys = read_axis_numbers(ser, "yVal")
  let bs = read_axis_numbers(ser, "bubbleSize")
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n == 0 {
    return []
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh, axes=Some(axes))
  let max_x = effective_axis_max(max_positive(xs), axes)
  let max_y = effective_axis_max(max_positive(ys), axes)
  // §21.2.2.170 — axis origin defaults to 0 for scatter/bubble.
  let min_x = effective_axis_min(axes)
  let min_y = effective_axis_min(axes)
  let series_color = resolve_series_color(ser, 0, ctx, defs)
  let nodes : Array[@xml.Node] = []
  nodes.push(plot_axes_rect(px, py, pw, ph, style=Some(style)))
  if !axes.val_deleted() {
    for
      tick in y_axis_ticks(
        px,
        py,
        ph,
        max_y,
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
  if !axes.cat_deleted() {
    for
      tick in x_axis_ticks(
        px,
        py,
        pw,
        ph,
        max_x,
        fh,
        axes.val_major(),
        style=Some(style),
      ) {
      nodes.push(tick)
    }
  }
  let span_x = if max_x > min_x { max_x - min_x } else { 1.0 }
  let span_y = if max_y > min_y { max_y - min_y } else { 1.0 }
  // Determine the maximum bubble size for normalisation. The spec
  // (§21.2.2.22 CT_BubbleSer) defines bubbleSize as proportional to
  // §21.2.2.181 sizeRepresents — "area" (default) or "w" (width).
  // Area mode uses sqrt scaling; width mode uses linear scaling.
  let size_represents = match first_child_named(elem, "sizeRepresents") {
    Some(e) => attr_or(e, "val", "area")
    None => "area"
  }
  let max_bs = if bs.length() > 0 { max_positive(bs) } else { 1.0 }
  // §21.2.2.23 bubbleScale — scale factor (default 100%).
  let bubble_scale = match first_child_named(elem, "bubbleScale") {
    Some(e) => {
      let v = parse_int_lenient(attr_or(e, "val", "100"))
      if v > 0 && v <= 300 {
        v
      } else {
        100
      }
    }
    None => 100
  }
  // §21.2.2.22 bubble3D — when val="true", render bubbles with a
  // highlight overlay simulating a 3D shine.  Default is false.
  let is_3d = match first_child_named(elem, "bubble3D") {
    Some(e) => {
      let v = attr_or(e, "val", "true")
      v == "1" || v == "true"
    }
    None => false
  }
  // §21.2.2.23 — largest bubble radius. The spec leaves the base
  // size implementation-defined; at bubbleScale=100 the largest
  // diameter is ≈ 18% of the shorter plot dimension → radius ≈ 9%.
  let base_r = (if pw < ph { pw } else { ph }) * 0.09
  let max_r = base_r * bubble_scale.to_double() / 100.0
  let mut j = 0
  while j < n {
    let x = px + (xs[j] - min_x) / span_x * pw
    let y = py + ph - (ys[j] - min_y) / span_y * ph
    let bval = if j < bs.length() { bs[j] } else { max_bs }
    let ratio = if max_bs > 0.0 { bval / max_bs } else { 1.0 }
    // §21.2.2.181 — area mode uses sqrt; width mode uses linear.
    let r = if size_represents == "w" {
      (if ratio > 0.0 { ratio } else { 0.0 }) * max_r
    } else {
      (if ratio > 0.0 { ratio } else { 0.0 }).sqrt() * max_r
    }
    let r_safe = if r < h * 0.005 { h * 0.005 } else { r }
    nodes.push(
      @markup.elem_ns(
        "circle",
        @markup.svg_ns,
        [
          @markup.attr("cx", format_double(x)),
          @markup.attr("cy", format_double(y)),
          @markup.attr("r", format_double(r_safe)),
          @markup.attr("fill", series_color),
          @markup.attr("stroke", series_color),
          @markup.attr("stroke-width", format_double(h * 0.002)),
        ],
        [],
      ),
    )
    // §21.2.2.22 bubble3D — highlight ellipse simulating a 3D shine
    // at the top-left of each bubble.  Adds one extra `<ellipse>`
    // node per data point, so pruning `<c:bubble3D>` removes the
    // highlights and the SVG skeleton differs.
    if is_3d {
      nodes.push(
        @markup.elem_ns(
          "ellipse",
          @markup.svg_ns,
          [
            @markup.attr("cx", format_double(x - r_safe * 0.35)),
            @markup.attr("cy", format_double(y - r_safe * 0.4)),
            @markup.attr("rx", format_double(r_safe * 0.3)),
            @markup.attr("ry", format_double(r_safe * 0.2)),
            @markup.attr("fill", "#ffffff"),
            @markup.attr("fill-opacity", "0.6"),
          ],
          [],
        ),
      )
    }
    j = j + 1
  }
  nodes
}
