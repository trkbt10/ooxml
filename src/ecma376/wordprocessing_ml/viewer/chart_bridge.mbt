// §21.2 DrawingML chart bridge for WordprocessingML.  Adapts WML's
// local theme map onto the chart-renderer package
// (`drawing_ml/chart/viewer`).  The chart renderer owns the SVG
// geometry; this bridge only translates the WML-side inputs (the
// document theme map + the main-document part's relationship table)
// into the shape `@chart_viewer.render_chart_graphic_frame` expects.

///|
/// Build a `@paint.ColorResolveContext` from a WML-side theme map.
/// The chart renderer's `@paint.get_scheme_color` looks up by DML
/// slot name (`accent1`, `dk1`, …) so we populate the
/// `color_scheme` map with the entries this WML document carries.
/// Empty when no theme part is wired through; the chart renderer
/// then falls back to its baked Office 2013+ palette automatically.
///
/// §20.1.4.1.6 — WML's `ThemeColorMap` stores the §20.1.4.1.6
/// scheme entries under field names `dark1` / `light1` / `dark2` /
/// `light2` / `accent1..accent6` / `hyperlink` /
/// `followed_hyperlink`, which correspond one-for-one to the DML
/// slot names `dk1` / `lt1` / `dk2` / `lt2` / `accent1..accent6` /
/// `hlink` / `folHlink`.
pub fn paint_ctx_from_wml_theme(
  theme_map : ThemeColorMap,
) -> @paint.ColorResolveContext {
  let scheme : Map[String, String] = Map([], capacity=0)
  let put = fn(name : String, slot : String?) {
    match slot {
      Some(hex) => scheme[name] = hex
      None => ()
    }
  }
  put("dk1", theme_map.dark1)
  put("lt1", theme_map.light1)
  put("dk2", theme_map.dark2)
  put("lt2", theme_map.light2)
  put("accent1", theme_map.accent1)
  put("accent2", theme_map.accent2)
  put("accent3", theme_map.accent3)
  put("accent4", theme_map.accent4)
  put("accent5", theme_map.accent5)
  put("accent6", theme_map.accent6)
  put("hlink", theme_map.hyperlink)
  put("folHlink", theme_map.followed_hyperlink)
  @paint.ColorResolveContext::empty().with_color_scheme(scheme)
}

///|
/// Build the closure the WML viewer threads as `chart_resolver`
/// through its inline-render pipeline.  When the closure receives a
/// `<wp:inline>` / `<wp:anchor>` wrapper carrying a
/// `<c:chart r:id>` payload (caller's `frame` argument), it resolves
/// the rId via `part_resolver`, hands the resulting chart-space tree
/// + the WML-derived `ColorResolveContext` to the chart renderer,
/// and returns the produced SVG node.  Yields `None` for any frame
/// whose chart URI / rId / part cannot be resolved, so the caller
/// falls back to the placeholder branch in `emit_drawing_span`.
pub fn build_wml_chart_resolver(
  theme_map : ThemeColorMap,
  part_resolver : (String) -> @xml.Element?,
) -> (@xml.Element) -> @xml.Node? {
  let ctx = paint_ctx_from_wml_theme(theme_map)
  fn(frame : @xml.Element) -> @xml.Node? {
    let (w_px, h_px) = wp_frame_extent_px(frame)
    if w_px <= 0.0 || h_px <= 0.0 {
      return None
    }
    let defs = @paint.SvgDefsCollector::new()
    let nodes = @chart_viewer.render_chart_graphic_frame(
      frame, w_px, h_px, ctx, defs, part_resolver,
    )
    if nodes.length() == 0 {
      return None
    }
    Some(@markup.elem_ns("g", @markup.svg_ns, [@markup.attr("class", "chart")], nodes))
  }
}

///|
/// Read the `<wp:extent @cx @cy>` (EMU) on a `<wp:inline>` /
/// `<wp:anchor>` wrapper and return the chart frame's pixel size at
/// the renderer's standard 96 dpi.  Returns `(0, 0)` when the extent
/// is missing or unparseable — the caller treats that as a degenerate
/// frame and bails out before invoking the chart renderer.
fn wp_frame_extent_px(frame : @xml.Element) -> (Double, Double) {
  match first_child_named(frame, "extent") {
    None => (0.0, 0.0)
    Some(ext) => {
      let cx_emu = parse_double_attr(ext, "cx", 0.0)
      let cy_emu = parse_double_attr(ext, "cy", 0.0)
      // 914400 EMU per inch · 96 pixels per inch = 9525 EMU/px.
      let emu_per_px : Double = 9525.0
      (cx_emu / emu_per_px, cy_emu / emu_per_px)
    }
  }
}
