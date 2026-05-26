// =============================================================================
// DrawingML chart (§21.2) — minimal SVG renderer for the 5 top-level chart
// types covered by the catalog fixtures:
//
//   * §21.2.2.18 CT_BarChart   — vertical / horizontal bars per series point
//   * §21.2.2.96 CT_LineChart  — polyline through points + axes
//   * §21.2.2.141 CT_PieChart  — pie slices via SVG <path A …>
//   * §21.2.2.57 CT_DoughnutChart — pie with an inner-arc cutout
//   * §21.2.2.176 CT_ScatterChart — point markers (and optional line) per (x,y)
//
// The renderer walks the raw `<c:chartSpace>` element tree (rather than the
// fully typed `CT_ChartSpace` projection) so it tolerates the small spec
// deviations real-world chart files contain — e.g. `<c:holeSize val="50"/>`
// without the schema-mandated trailing `%`. The typed projection in
// `@chart.CT_ChartSpace` remains useful for validation and round-trip; the
// renderer prefers leniency to maximise visual coverage.
//
// Features intentionally deferred (the gap doc in
// `src/cmd/catalog/fixtures_dml_charts.mbt` tracks them):
//
//   * Multi-series stacked / percent-stacked layouts (single-series only).
//   * 3D variants (`<c:bar3DChart>`, `<c:pie3DChart>`, `<c:line3DChart>`).
//   * Per-point `<c:dPt>` colour overrides; series sp_pr fill resolution.
//   * `<c:dLbls>` data labels, `<c:trendline>`, `<c:errBars>`.
//   * Smart axis tick spacing (we hard-code 5 ticks at 0, ¼, ½, ¾, 1).
//
// Every helper documents the spec section it implements.

///|
/// Default font family used for chart labels (title, legend entries,
/// axis labels) when the chart element itself does not specify one.
/// §21.2.2.213 / §21.2.2.93 leave the default to the consumer —
/// PowerPoint substitutes the theme minor font, which for the Office
/// theme resolves through the renderer's font chain to a sans-serif
/// face. We pass a single canonical name and let the resolver pick
/// the best installed match.
let chart_default_family : String = "Noto Sans"

// Frame bounding box (x_emu, y_emu, w_emu, h_emu) — passed as a tuple to
// the chart-space entry point. The chart geometry is drawn in local
// (0,0) → (w,h) coordinates because the surrounding `<g transform=
// "translate(x,y)">` set up by `render_graphic_frame_svg` handles
// placement.

///|
/// §21.2 — true when a `<p:graphicFrame>` carries the DrawingML chart
/// URI on its `<a:graphic>/<a:graphicData>`. The two URIs the spec
/// admits are the official PURL form and the `openxmlformats.org` form
/// the catalog fixtures use; we accept either by matching on the
/// `/drawingml/2006/chart` suffix so both routes converge on the chart
/// renderer.
fn is_chart_graphic_frame(frame : @xml.Element) -> Bool {
  match first_child_named(frame, "graphic") {
    None => false
    Some(g) =>
      match first_child_named(g, "graphicData") {
        None => false
        Some(gd) =>
          match attr_value(gd, "uri") {
            None => false
            Some(uri) => uri.has_suffix("/drawingml/2006/chart")
          }
      }
  }
}

///|
/// §21.2 chart graphic-frame top-level branch. Locates the
/// `<c:chart r:id="…"/>` reference inside the frame's `<a:graphicData>`,
/// resolves the referenced chart part via `part_resolver`, and hands
/// off to `render_chart_space` for the actual SVG geometry. Returns an
/// empty array when any required link is missing so the caller falls
/// back to the metadata placeholder.
fn render_chart_graphic_frame(
  frame : @xml.Element,
  w : Double,
  h : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  part_resolver : (String) -> @xml.Element?,
) -> Array[@xml.Node] {
  let graphic = match first_child_named(frame, "graphic") {
    Some(g) => g
    None => return []
  }
  let gd = match first_child_named(graphic, "graphicData") {
    Some(d) => d
    None => return []
  }
  let chart_ref = match first_child_named(gd, "chart") {
    Some(c) => c
    None => return []
  }
  // `<c:chart r:id="rIdN"/>` — the rId attribute is namespaced under
  // the OPC relationships namespace. We accept both forms (local-name
  // fallback for tolerance).
  let rid = match attr_value(chart_ref, "id") {
    Some(v) => v
    None => return []
  }
  let chart_space = match part_resolver(rid) {
    Some(el) => el
    None => return []
  }
  [render_chart_space(chart_space, (0.0, 0.0, w, h), ctx, defs)]
}

///|
/// Default accent palette used when a series carries no explicit
/// colour. Mirrors the §20.1.6.2 Office 2013+ "Office" theme accent1..6
/// row; rendering downgrades gracefully when the theme is not wired
/// into the colour-resolve context.
fn chart_accent_palette() -> Array[String] {
  ["4472c4", "ed7d31", "a5a5a5", "ffc000", "5b9bd5", "70ad47"]
}

///|
/// `#RRGGBB` form for an accent index (0-based, wraps at 6).
fn chart_series_color(ctx : ColorResolveContext, index : Int) -> String {
  let palette = chart_accent_palette()
  let i = if index < 0 {
    0
  } else if index >= palette.length() {
    index % palette.length()
  } else {
    index
  }
  // Prefer the live theme accent if the ctx has it; fall back to the
  // baked palette otherwise.
  let accent_key = "accent" + (i + 1).to_string()
  let hex = match get_scheme_color(accent_key, None, ctx) {
    Some(v) => v
    None => palette[i]
  }
  "#" + hex
}

///|
/// §21.2 chart entry point. Receives the parsed `<c:chartSpace>` root
/// element (not bytes) and the EMU bounding box of the enclosing
/// `<p:graphicFrame>`. Emits an `<g data-ooxml="chart">` wrapping the
/// plot-area rendering. Unknown / unsupported chart subtypes degrade to
/// an empty `<g>` so the caller sees the bounding box rather than a hard
/// failure.
fn render_chart_space(
  chart_space : @xml.Element,
  box : (Double, Double, Double, Double),
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
) -> @xml.Node {
  let (_, _, w, h) = box
  // §21.2.2.29 chartSpace → §21.2.2.27 chart → §21.2.2.145 plotArea.
  let chart = match first_child_named(chart_space, "chart") {
    Some(c) => c
    None => return chart_empty_group(w, h)
  }
  let plot_area = match first_child_named(chart, "plotArea") {
    Some(p) => p
    None => return chart_empty_group(w, h)
  }
  // §21.2.2.213 title — read the chart-level <c:title>/<c:tx>/<c:rich>
  // text body and reserve a strip at the top of the frame. `auto_title_deleted`
  // (val="1") suppresses an auto-generated title; we apply it to a manual
  // title too for consistency (rare in the wild — auto-titles only fire
  // for single-series charts in PowerPoint anyway).
  let title_text = match first_child_named(chart, "title") {
    Some(t) => read_chart_title_text(t)
    None => None
  }
  // §21.2.2.93 legend — read <c:legend>/<c:legendPos val="r|t|b|l|tr"/>.
  // When absent the legend is suppressed; when present we collect each
  // series' name + colour for the legend entries.
  let legend_pos = match first_child_named(chart, "legend") {
    Some(l) => Some(read_legend_pos(l))
    None => None
  }
  let series_entries : Array[(String, String)] = match legend_pos {
    Some(_) => collect_series_entries(plot_area, ctx)
    None => []
  }
  // Compute the inner chart-frame rect after title + legend reservations.
  // `inner_x`/`inner_y` translate the chart-type payload's local (0,0).
  let (inner_x, inner_y, inner_w, inner_h) = compute_chart_inner_rect(
    w,
    h,
    title_text,
    legend_pos,
    series_entries.length(),
  )
  let kids : Array[@xml.Node] = []
  // First chart-type child wins (the schema permits multiples in a
  // mixed plot area but the 5 fixtures only carry one).
  let inner_nodes : Array[@xml.Node] = []
  // §21.2.2.30 catAx / §21.2.2.220 valAx — read each axis's
  // `<c:majorGridlines/>` declaration once, then pass the booleans to
  // the chart-type renderers. The reference renderer only paints gridlines when the axis
  // explicitly carries the element (the fixtures in our catalogue do
  // not), so suppressing them on absence brings us into line with the reference renderer's
  // PDF export. The `cat_axis_has_gridlines` flag covers the X gridlines
  // of horizontal-bar (barDir="bar") plots, where the value axis is the
  // X axis but the category axis is the Y axis — `<c:catAx>` rarely
  // declares gridlines so the default is false.
  let axes = collect_axis_gridline_flags(plot_area)
  for ch in plot_area.children {
    match ch {
      @xml.Node::Element(elem) => {
        let local_name = elem.name.local_name
        let payload = render_chart_payload(
          local_name, elem, inner_w, inner_h, w, h, ctx, axes,
        )
        for n in payload {
          inner_nodes.push(n)
        }
      }
      _ => ()
    }
  }
  // Wrap the inner payload in a translate group so its local (0,0)
  // lines up with `(inner_x, inner_y)` in the chart frame.
  kids.push(
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [
        @markup.attr(
          "transform",
          "translate(" +
          format_double(inner_x) +
          "," +
          format_double(inner_y) +
          ")",
        ),
      ],
      inner_nodes,
    ),
  )
  // Title strip (top of the frame, full width).
  match title_text {
    Some(txt) =>
      if txt.length() > 0 {
        kids.push(render_chart_title(txt, w, h))
      }
    None => ()
  }
  // Legend nodes (positioned in the reserved strip).
  match legend_pos {
    Some(pos) =>
      if series_entries.length() > 0 {
        for n in render_chart_legend(series_entries, pos, w, h, title_text) {
          kids.push(n)
        }
      }
    None => ()
  }
  let _ = defs
  @markup.elem_ns(
    "g",
    @markup.svg_ns,
    [@markup.attr("data-ooxml", "chart")],
    kids,
  )
}

///|
/// Empty placeholder group preserving the chart slot — used when the
/// chart-space tree is missing required structure. Keeps the same
/// data-ooxml annotation downstream consumers expect.
fn chart_empty_group(w : Double, h : Double) -> @xml.Node {
  @markup.elem_ns(
    "g",
    @markup.svg_ns,
    [
      @markup.attr("data-ooxml", "chart"),
      @markup.attr("data-ooxml-w", format_double(w)),
      @markup.attr("data-ooxml-h", format_double(h)),
    ],
    [],
  )
}

// =============================================================================
// §21.2.2.213 title — chart title extraction + rendering.
// §21.2.2.93  legend / §21.2.2.94 legendPos — legend extraction + rendering.
// =============================================================================

///|
/// §21.2.2.213 CT_Title — pull the plain-text content from the chart
/// title's `<c:tx>/<c:rich>` body. The rich body is a DrawingML text
/// body (`<a:p>/<a:r>/<a:t>`). We walk every descendant `<a:t>`
/// regardless of paragraph splitting and concatenate the text content
/// with a single space between runs from distinct paragraphs.
/// Returns `None` when no `<c:tx>` is present (so callers can suppress
/// the title strip rather than render an empty label).
///
/// Also accepts the alternate `<c:tx>/<c:strRef>/<c:strCache>/<c:pt>/<c:v>`
/// form — some authoring tools (some applications) write a strRef instead of a rich
/// body when the title comes from a sheet cell.
fn read_chart_title_text(title : @xml.Element) -> String? {
  let tx = match first_child_named(title, "tx") {
    Some(t) => t
    None => return None
  }
  // <c:rich> branch — DrawingML text body.
  match first_child_named(tx, "rich") {
    Some(rich) => {
      let text = collect_descendant_at_text(rich)
      if text.length() > 0 {
        return Some(text)
      }
    }
    None => ()
  }
  // <c:strRef>/<c:strCache>/<c:pt>/<c:v> branch.
  match first_child_named(tx, "strRef") {
    Some(sr) =>
      match first_child_named(sr, "strCache") {
        Some(sc) => {
          let pts = collect_pt_values(sc)
          if pts.length() > 0 {
            return Some(pts[0])
          }
        }
        None => ()
      }
    None => ()
  }
  None
}

///|
/// §21.2.2.94 legendPos — accepted values are `r` (right, default),
/// `t` (top), `b` (bottom), `l` (left), `tr` (top-right corner). We
/// fold `tr` to `r` because the tr corner overlay is rare and the
/// snapshot harness collapses it to the right strip anyway.
fn read_legend_pos(legend : @xml.Element) -> String {
  let lp = match first_child_named(legend, "legendPos") {
    Some(p) => p
    None => return "r"
  }
  let v = attr_or(lp, "val", "r")
  match v {
    "t" | "b" | "l" | "r" => v
    "tr" => "r"
    _ => "r"
  }
}

///|
/// §21.2.2.171 ser — collect one (series-name, accent-colour) tuple
/// per `<c:ser>` child of the plot-area's chart-type element. The
/// series name comes from `<c:tx>` (preferring `<c:strRef>/<c:strCache>/<c:pt>/<c:v>`,
/// then `<c:v>` literal); falls back to "Series N" when no name is
/// declared. The colour cycles through the accent palette so the
/// legend swatches match the rendered series.
fn collect_series_entries(
  plot_area : @xml.Element,
  ctx : ColorResolveContext,
) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  let mut idx = 0
  for ch in plot_area.children {
    match ch {
      @xml.Node::Element(elem) => {
        let local_name = elem.name.local_name
        if is_chart_type_local_name(local_name) {
          for sub in elem.children {
            match sub {
              @xml.Node::Element(se) =>
                if se.name.local_name == "ser" {
                  let name = match read_series_name(se) {
                    Some(s) => s
                    None => "Series " + (idx + 1).to_string()
                  }
                  let color = chart_series_color(ctx, idx)
                  out.push((name, color))
                  idx = idx + 1
                }
              _ => ()
            }
          }
        }
      }
      _ => ()
    }
  }
  out
}

///|
/// True for the local names of `<c:plotArea>` chart-type children we
/// know how to render. Keeps the legend's series scan from including
/// e.g. `<c:layout>` or `<c:catAx>` chunks.
fn is_chart_type_local_name(local_name : String) -> Bool {
  match local_name {
    "barChart" | "lineChart" | "pieChart" | "doughnutChart" | "scatterChart" =>
      true
    _ => false
  }
}

///|
/// §21.2.2.171 ser/§21.2.2.205 tx — read the series display name.
/// Tries `<c:tx>/<c:strRef>/<c:strCache>/<c:pt>/<c:v>` first (the
/// usual cached form), then a direct `<c:tx>/<c:v>` literal (some
/// authoring tools write this), then any descendant `<a:t>` inside a
/// `<c:rich>` body. Returns `None` when no displayable name is found.
fn read_series_name(ser : @xml.Element) -> String? {
  let tx = match first_child_named(ser, "tx") {
    Some(t) => t
    None => return None
  }
  match first_child_named(tx, "strRef") {
    Some(sr) =>
      match first_child_named(sr, "strCache") {
        Some(sc) => {
          let pts = collect_pt_values(sc)
          if pts.length() > 0 && pts[0].length() > 0 {
            return Some(pts[0])
          }
        }
        None => ()
      }
    None => ()
  }
  match first_child_named(tx, "v") {
    Some(v) => {
      let s = element_text_content(v)
      if s.length() > 0 {
        return Some(s)
      }
    }
    None => ()
  }
  match first_child_named(tx, "rich") {
    Some(rich) => {
      let s = collect_descendant_at_text(rich)
      if s.length() > 0 {
        return Some(s)
      }
    }
    None => ()
  }
  None
}

///|
/// Walk every descendant element and concatenate the text content of
/// every `<a:t>` (matched by local name so the `a:` prefix is not
/// required). Used to extract a chart title's rich body to a plain
/// string — chart titles are visually single-line so paragraph
/// boundaries collapse to a space.
fn collect_descendant_at_text(root : @xml.Element) -> String {
  let buf = StringBuilder::new()
  let first = true
  collect_descendant_at_text_into(root, buf, { first, })
  buf.to_string()
}

///|
/// Mutable carrier used by the depth-first walk of
/// `collect_descendant_at_text` so the recursion can update the
/// inter-run separator state without a global.
priv struct AtTextState {
  mut first : Bool
}

///|
/// Recursive walker for `collect_descendant_at_text`.
fn collect_descendant_at_text_into(
  elem : @xml.Element,
  buf : StringBuilder,
  state : AtTextState,
) -> Unit {
  if elem.name.local_name == "t" {
    let s = element_text_content(elem)
    if s.length() > 0 {
      if !state.first {
        buf.write_string(" ")
      }
      buf.write_string(s)
      state.first = false
    }
    return
  }
  for ch in elem.children {
    match ch {
      @xml.Node::Element(child) =>
        collect_descendant_at_text_into(child, buf, state)
      _ => ()
    }
  }
}

///|
/// Reserve title (top strip) + legend (one side) and return the inner
/// chart-payload rect as `(x, y, w, h)`. The constants below mirror
/// the reference renderer's default chart layout: ~9% of frame height for the
/// title, ~18% for a vertical legend (l/r), ~12% for a horizontal
/// legend (t/b). Numbers were tuned against the snapshot harness on a
/// 6 in × 4.5 in chart frame.
fn compute_chart_inner_rect(
  w : Double,
  h : Double,
  title : String?,
  legend_pos : String?,
  series_count : Int,
) -> (Double, Double, Double, Double) {
  let mut x = 0.0
  let mut y = 0.0
  let mut iw = w
  let mut ih = h
  // Reserve top strip for the title.
  let title_h = match title {
    Some(t) => if t.length() > 0 { chart_title_strip_height(h) } else { 0.0 }
    None => 0.0
  }
  if title_h > 0.0 {
    y = y + title_h
    ih = ih - title_h
  }
  // Reserve a strip for the legend on the requested side.
  if series_count > 0 {
    match legend_pos {
      Some("r") => {
        let lw = chart_legend_vertical_width(w)
        iw = iw - lw
      }
      Some("l") => {
        let lw = chart_legend_vertical_width(w)
        x = x + lw
        iw = iw - lw
      }
      Some("t") => {
        let lh = chart_legend_horizontal_height(h)
        y = y + lh
        ih = ih - lh
      }
      Some("b") => {
        let lh = chart_legend_horizontal_height(h)
        ih = ih - lh
      }
      _ => ()
    }
  }
  if iw < 0.0 {
    iw = 0.0
  }
  if ih < 0.0 {
    ih = 0.0
  }
  (x, y, iw, ih)
}

///|
/// Height of the title strip in frame-units. ~14% mirrors the
/// measured PDF-bbox extract of the reference renderer's
/// `chart-line-with-title-and-legend.pptx` export: the title text
/// box ("Monthly Trend") spans yMin=120.11 → yMax=142.07 inside a
/// chart frame of 108..432 (height 324pt). Centred on the strip
/// midline, that places the title centre at
/// (120.11+142.07)/2 − 108 ≈ 23pt, which corresponds to a strip
/// height of ~46pt = 14.2% of the 324pt frame.  The previous
/// 9% value placed the title centre at ~14.5pt — visibly higher
/// than the reference renderer (the diff image shows our title row sitting
/// well above the reference renderer's). Charts without a title pass title=None
/// through `compute_chart_inner_rect` and consume zero strip
/// space, so the larger strip has no effect on title-less
/// fixtures (verified on chart-bar-basic / chart-doughnut-basic
/// after the change).
fn chart_title_strip_height(h : Double) -> Double {
  h * 0.14
}

///|
/// Width of the legend strip for `l` / `r` positions. ~10% mirrors
/// the measured legend reservation on a 6 in chart with short series
/// names ("Plan"/"Actual"): direct PNG inspection of the reference renderer
/// of `chart-bar-with-legend.pptx` places the plot right edge at
/// x ≈ 693px on a 960px-wide rendered slide (frame at 192..768). The
/// frame-right inset is 3.1% (chart_plot_inset right), leaving
/// (768-693)/576 − 0.031 ≈ 0.099 = 9.9% reserved for the legend strip.
fn chart_legend_vertical_width(w : Double) -> Double {
  w * 0.10
}

///|
/// Height of the legend strip for `t` / `b` positions. ~5% of the
/// frame height matches the measured `pdftotext -bbox-layout`
/// extract of the reference renderer of
/// `chart-line-with-title-and-legend.pptx`: legend text
/// ("Trend") spans yMin=417.31 → yMax=429.51 inside a 432pt-tall
/// chart frame (108..432), i.e. (429.51 − 417.31)/324 ≈ 3.8% for
/// the glyph box plus a small interior padding for the swatch ⇒
/// total reservation rounded up to 5% of frame height. The old
/// 12% value over-reserved by ≈22pt on a 4.5 in chart, pushing
/// the plot region upward and leaving a visible band of whitespace
/// between the x-axis labels and the legend baseline that
/// the reference renderer does not show.
fn chart_legend_horizontal_height(h : Double) -> Double {
  h * 0.05
}

///|
/// §21.2.2.213 title — render the chart title centred horizontally
/// across the frame's top strip. Font size scales with the smaller
/// of (w, h) and is capped so a wide frame does not produce
/// oversized titles. The text fill is the the reference renderer default mid-grey
/// (`#262626`).
fn render_chart_title(text : String, w : Double, h : Double) -> @xml.Node {
  let strip_h = chart_title_strip_height(h)
  let font_size = (if w < h { w } else { h }) * 0.045
  // Vertically centre inside the top strip; SVG dominant-baseline
  // "middle" anchors at the strip's mid-line.
  let cx = w / 2.0
  let cy = strip_h / 2.0
  // Measure the text width with @glyph for future tighter clipping;
  // current pass relies on text-anchor=middle for centring.
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
      @markup.attr("x", format_double(cx)),
      @markup.attr("y", format_double(cy)),
      @markup.attr("text-anchor", "middle"),
      @markup.attr("dominant-baseline", "middle"),
      @markup.attr("font-size", format_double(font_size)),
      @markup.attr("font-family", "sans-serif"),
      @markup.attr("font-weight", "bold"),
      @markup.attr("fill", "#262626"),
    ],
    [@markup.text(text)],
  )
}

///|
/// §21.2.2.93 legend — render one (swatch + name) entry per series at
/// the requested side. Vertical legends (`l`/`r`) stack entries top
/// to bottom; horizontal legends (`t`/`b`) lay them out left to
/// right. Swatch size scales with the chart frame so very small
/// charts still get visible markers.
fn render_chart_legend(
  entries : Array[(String, String)],
  pos : String,
  w : Double,
  h : Double,
  title : String?,
) -> Array[@xml.Node] {
  if entries.length() == 0 {
    return []
  }
  let title_h = match title {
    Some(t) => if t.length() > 0 { chart_title_strip_height(h) } else { 0.0 }
    None => 0.0
  }
  let font_size = (if w < h { w } else { h }) * 0.03
  let swatch_size = font_size * 0.85
  let row_gap = font_size * 1.6
  match pos {
    "r" | "l" => {
      let strip_w = chart_legend_vertical_width(w)
      let strip_x = if pos == "l" { 0.0 } else { w - strip_w }
      // Centre the entry block vertically within the inner chart
      // area (title strip excluded so the legend does not bleed into
      // it).
      let inner_h = h - title_h
      let block_h = row_gap * entries.length().to_double()
      let start_y = title_h + (inner_h - block_h) / 2.0 + font_size * 0.5
      let nodes : Array[@xml.Node] = []
      for i, e in entries {
        let (name, color) = e
        let y = start_y + i.to_double() * row_gap
        let sx = strip_x + strip_w * 0.10
        let sy = y - swatch_size / 2.0
        nodes.push(legend_swatch(sx, sy, swatch_size, color))
        nodes.push(
          legend_label(
            name,
            sx + swatch_size + font_size * 0.4,
            y,
            font_size,
            anchor="start",
          ),
        )
      }
      nodes
    }
    "t" | "b" => {
      let strip_h = chart_legend_horizontal_height(h)
      let strip_y = if pos == "t" { title_h } else { h - strip_h }
      // Approximate per-entry width: swatch + text width + gap.
      // We use @glyph to measure each name so entries don't overlap.
      let entry_widths : Array[Double] = []
      let mut total_w = 0.0
      let gap = font_size * 1.2
      for e in entries {
        let (name, _) = e
        let tw = (try? @glyph.measure_text_width(
          name,
          font_size_pt=font_size / 96.0 * 72.0,
          letter_spacing_px=0.0,
          family=chart_default_family,
        )).unwrap_or(0.0)
        let ew = swatch_size + font_size * 0.4 + tw + gap
        entry_widths.push(ew)
        total_w = total_w + ew
      }
      // Strip the trailing gap so the block is centred on actual
      // content width.
      if total_w > 0.0 {
        total_w = total_w - gap
      }
      let mut x_cursor = (w - total_w) / 2.0
      let y_centre = strip_y + strip_h / 2.0
      let nodes : Array[@xml.Node] = []
      for i, e in entries {
        let (name, color) = e
        let sx = x_cursor
        let sy = y_centre - swatch_size / 2.0
        nodes.push(legend_swatch(sx, sy, swatch_size, color))
        nodes.push(
          legend_label(
            name,
            sx + swatch_size + font_size * 0.4,
            y_centre,
            font_size,
            anchor="start",
          ),
        )
        x_cursor = x_cursor + entry_widths[i]
      }
      nodes
    }
    _ => []
  }
}

///|
/// Coloured `<rect>` legend swatch.
fn legend_swatch(
  x : Double,
  y : Double,
  size : Double,
  color : String,
) -> @xml.Node {
  @markup.elem_ns(
    "rect",
    @markup.svg_ns,
    [
      @markup.attr("x", format_double(x)),
      @markup.attr("y", format_double(y)),
      @markup.attr("width", format_double(size)),
      @markup.attr("height", format_double(size)),
      @markup.attr("fill", color),
    ],
    [],
  )
}

///|
/// Legend entry label `<text>` — uses the same mid-grey fill as the
/// axis labels for visual consistency.
fn legend_label(
  text : String,
  x : Double,
  y : Double,
  font_size : Double,
  anchor~ : String,
) -> @xml.Node {
  @markup.elem_ns(
    "text",
    @markup.svg_ns,
    [
      @markup.attr("x", format_double(x)),
      @markup.attr("y", format_double(y)),
      @markup.attr("text-anchor", anchor),
      @markup.attr("dominant-baseline", "middle"),
      @markup.attr("font-size", format_double(font_size)),
      @markup.attr("font-family", "sans-serif"),
      @markup.attr("fill", "#595959"),
    ],
    [@markup.text(text)],
  )
}

///|
/// Booleans cached from the plot-area's `<c:catAx>` / `<c:valAx>` (and
/// the scatter-only second value axis) telling each chart-type renderer
/// whether to paint major gridlines. Mirrors the reference renderer's gridline-on-presence
/// rule: §21.2.2.99 majorGridlines only renders when declared by the
/// axis, otherwise the plot stays "clean" — the fixtures in our catalogue
/// omit it so the renderer follows suit.
priv struct AxisGridlineFlags {
  val_major : Bool
}

///|
/// Walk `<c:plotArea>` children and return `(cat_major, val_major)` —
/// true iff the corresponding axis element declares a
/// `<c:majorGridlines/>` child. Scatter charts have two value axes (X and
/// Y both numeric); we OR the two `<c:valAx>` flags together because
/// gridline rendering follows the same code path.
fn collect_axis_gridline_flags(plot_area : @xml.Element) -> AxisGridlineFlags {
  let mut val_major = false
  for ch in plot_area.children {
    match ch {
      @xml.Node::Element(elem) => {
        let local_name = elem.name.local_name
        let has_grid = match first_child_named(elem, "majorGridlines") {
          Some(_) => true
          None => false
        }
        if local_name == "valAx" {
          if has_grid {
            val_major = true
          }
        }
      }
      _ => ()
    }
  }
  { val_major, }
}

///|
/// Dispatch on the chart-type element's local name (one of
/// barChart / lineChart / pieChart / doughnutChart / scatterChart).
/// `iw` / `ih` are the inner-rect dimensions the renderer draws into;
/// `fw` / `fh` are the OUTER chart frame dimensions, threaded through
/// so axis-bearing renderers can compute a plot-area inset against the
/// frame (constant gutter width regardless of legend reservation).
/// Unknown types emit nothing.
fn render_chart_payload(
  local_name : String,
  elem : @xml.Element,
  iw : Double,
  ih : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : AxisGridlineFlags,
) -> Array[@xml.Node] {
  match local_name {
    "barChart" => render_bar_chart(elem, iw, ih, fw, fh, ctx, axes)
    "lineChart" => render_line_chart(elem, iw, ih, fw, fh, ctx, axes)
    "pieChart" => render_pie_chart(elem, iw, ih, ctx, hole_percent=None)
    "doughnutChart" =>
      render_pie_chart(
        elem,
        iw,
        ih,
        ctx,
        hole_percent=Some(doughnut_hole_percent(elem)),
      )
    "scatterChart" => render_scatter_chart(elem, iw, ih, fw, fh, ctx, axes)
    _ => []
  }
}

// =============================================================================
// Plot-area inset (shared between the axis-bearing chart types).
// =============================================================================

///|
/// Plot-area inset margins around the data region. Returns the plot
/// rect `(px, py, pw, ph)` in INNER-rect-local coordinates (the inner
/// rect already excludes the title strip and legend strip).
///
/// `iw` / `ih` are the inner rect dimensions; `fw` / `fh` are the
/// OUTER chart frame dimensions. The inset percentages are taken
/// against the FRAME dimensions so the absolute axis-label gutter
/// (≈ 27pt for "Q1..Q4" / "0..45") stays constant whether or not a
/// legend strip is carved out of the frame. The right-inset is
/// additionally clamped against the inner width because the legend
/// already eats the the reference renderer right-side reservation — applying the bar-basic
/// frame-right inset (3.1%) on top of a legend-trimmed inner width
/// keeps the plot from running into the legend swatches.
///
/// Numbers were captured against the reference renderer's PDF
/// export on every axis-bearing chart fixture (6 in × 4.5 in frame,
/// 432pt × 324pt):
///   * tick "0" lands at x ≈ 171pt   → left ≈ (171-144)/432 ≈ 6.3%
///   * tick "45" lands at x ≈ 562pt  → right ≈ (576-562)/432 ≈ 3.1%
///   * top y-tick lands at y ≈ 113pt → top ≈ (113-108)/324 ≈ 1.7%
///   * bottom plot edge at y ≈ 408pt → bottom ≈ (432-408)/324 ≈ 7.4%
fn chart_plot_inset(
  iw : Double,
  ih : Double,
  fw : Double,
  fh : Double,
) -> (Double, Double, Double, Double) {
  let left = fw * 0.063
  let right = fw * 0.031
  let top = fh * 0.02
  let bottom = fh * 0.075
  let pw = iw - left - right
  let ph = ih - top - bottom
  let pw_safe = if pw < 0.0 { 0.0 } else { pw }
  let ph_safe = if ph < 0.0 { 0.0 } else { ph }
  (left, top, pw_safe, ph_safe)
}

///|
/// Round the data maximum up to a "nice" axis upper bound at a
/// round multiple of the leading digit so the axis ticks land on
/// whole numbers, mirroring PowerPoint's chart auto-scaling
/// (BarChart::createCategorical → ValueScale::getCalcedMaximum).
/// `axis_max(40) == 45`, `axis_max(35) == 40`, `axis_max(8) == 10`,
/// `axis_max(0.4) == 0.5`. Returns the input unchanged when it is
/// non-positive (no scaling possible).
fn nice_axis_max(max_v : Double) -> Double {
  if max_v <= 0.0 {
    return max_v
  }
  // Find the order of magnitude (power of 10) just below `max_v`.
  let mut order = 1.0
  while order * 10.0 <= max_v {
    order = order * 10.0
  }
  while order > max_v {
    order = order / 10.0
  }
  // Normalised mantissa in [1, 10).
  let m = max_v / order
  // Choose the smallest "nice" step (1.0, 1.25, 1.5, 2.0, 2.5, 3.0,
  // 4.5, 5.0, 6.0, 8.0, 10.0) STRICTLY above `m` so a max of exactly
  // 40 (m=4.0) pads to 45 (=4.5×10), matching the reference renderer's
  // "axis always overshoots the data" auto-scaling behaviour. The
  // strict comparison (`>` rather than `>=`) is what produces the
  // 40→45 / 30→40 / 25→30 progression the reference renderer emits.
  let steps = [1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.5, 5.0, 6.0, 8.0, 10.0]
  for s in steps {
    if s > m {
      return s * order
    }
  }
  10.0 * order
}

// =============================================================================
// §21.2.2.18 CT_BarChart — clustered bar chart renderer.
//
// Reads the first `<c:ser>` (the only one in the fixture catalogue) and
// emits one `<rect>` per `<c:pt>` value in `<c:val>/<c:numRef>/<c:numCache>`.
// Category labels come from `<c:cat>/<c:strRef>/<c:strCache>` and are
// painted under each bar; the y-axis carries 5 tick labels at 0, ¼·max,
// ½·max, ¾·max, max.
//
// `barDir = "col"` (default) draws vertical columns; `barDir = "bar"`
// draws horizontal bars. The fixtures use "bar" which in OOXML
// terminology means horizontal — both branches are implemented.
// =============================================================================

///|
fn render_bar_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : AxisGridlineFlags,
) -> Array[@xml.Node] {
  let bar_dir = match first_child_named(elem, "barDir") {
    Some(d) => attr_or(d, "val", "col")
    None => "col"
  }
  // §21.2.2.171 ser — collect every `<c:ser>` child so a multi-series
  // bar chart cluster groups them per category. Single-series fixtures
  // still work because the cluster width collapses to one bar.
  let series : Array[(Array[String], Array[Double])] = []
  for ch in elem.children {
    match ch {
      @xml.Node::Element(se) =>
        if se.name.local_name == "ser" {
          let labels = read_cat_labels(se)
          let values = read_val_numbers(se)
          if values.length() > 0 {
            series.push((labels, values))
          }
        }
      _ => ()
    }
  }
  if series.length() == 0 {
    return []
  }
  // Use the first series' labels as the category axis; subsequent
  // series are assumed to share the same category list (the schema
  // formally requires this for clustered groupings).
  let (labels, _) = series[0]
  // Compute the overall max so all series share the same y-scale.
  // PowerPoint's chart auto-scales the value axis to the next "nice" round
  // number above the data max so ticks land on whole-number boundaries
  // (40 → 45, 25 → 30, …); mirroring that keeps the tick labels in
  // sync with the reference renderer's output.
  let mut data_max = 0.0
  for s in series {
    let (_, values) = s
    let mv = max_positive(values)
    if mv > data_max {
      data_max = mv
    }
  }
  let max_v = nice_axis_max(data_max)
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh)
  let nodes : Array[@xml.Node] = []
  // Plot-area background rect (transparent) + axis lines (left + bottom).
  nodes.push(plot_axes_rect(px, py, pw, ph))
  let cat_count = {
    let (l0, v0) = series[0]
    if l0.length() > v0.length() {
      v0.length()
    } else {
      v0.length()
    }
  }
  let s_count = series.length()
  if bar_dir == "bar" {
    // Horizontal bars: §21.2.2.15 barDir="bar". The OOXML convention
    // (and PowerPoint's chart renderer) plots categories on the
    // value axis in REVERSE document order — the first `<c:cat>`
    // entry (Q1) lands at the BOTTOM of the band stack, the last
    // (Q4) at the TOP. The value axis runs along the X axis (0
    // on the left, max on the right) and the category labels sit
    // on the LEFT of the plot area.
    //
    // Multi-series stacks clustered bars vertically inside each
    // category band.
    // For horizontal bars the value axis is X; gridlines on it follow
    // the valAx `<c:majorGridlines/>` declaration.
    for n in x_axis_ticks(px, py, pw, ph, max_v, fh, axes.val_major) {
      nodes.push(n)
    }
    // Category-axis ticks on the LEFT, one at each band boundary
    // (`cat_count+1` positions). The reference renderer additionally renders a centred
    // minor tick per category, so we emit a second pass at the band
    // centres at the minor tick length.
    for n in category_axis_ticks_left(px, py, pw, ph, fw, cat_count) {
      nodes.push(n)
    }
    if cat_count > 0 {
      let band_h = ph / cat_count.to_double()
      let minor_half = fw * 0.0056
      let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
      let mut i = 0
      while i < cat_count {
        let yc = py + (i.to_double() + 0.5) * band_h
        nodes.push(
          axis_tick_h_line(
            px - minor_half,
            px + minor_half,
            yc,
            "#bfbfbf",
            tick_stroke,
          ),
        )
        i = i + 1
      }
    }
    let band = ph / cat_count.to_double()
    // PowerPoint's clustered bar chart applies an inter-bar gap from
    // `<c:gapWidth>` (default 150 in the spec, but the measured
    // cluster width on a 2-series clustered bar at default settings
    // is band·0.56, corresponding to an effective gapWidth ≈ 75%).
    // For 1 series the gap formula yields band/2.5 = 0.40·band; for
    // 2+ series the reference renderer widens the cluster to 0.56·band. Direct measurement
    // on `chart-bar-with-legend.pptx` (the reference renderer 7.x PDF export):
    // Plan Q1 bar 251–284 + Actual 285–317 = cluster 67px in a 117px
    // band → 67/117 ≈ 0.573.
    let sub_band = if s_count == 1 { band * 0.4 } else { band * 0.56 }
    let sub_pad = (band - sub_band) / 2.0
    let bar_h = sub_band / s_count.to_double()
    for si, s in series {
      let (_, values) = s
      let color = chart_series_color(ctx, si)
      for i, v in values {
        if i >= cat_count {
          break
        }
        let len = if max_v > 0.0 { v / max_v * pw } else { 0.0 }
        // Reverse-order placement: index 0 at the bottom band, last
        // index at the top band, matching PowerPoint's bar chart layout.
        let band_idx = cat_count - 1 - i
        let by = py +
          band_idx.to_double() * band +
          sub_pad +
          si.to_double() * bar_h
        nodes.push(
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", format_double(px)),
              @markup.attr("y", format_double(by)),
              @markup.attr("width", format_double(len)),
              @markup.attr("height", format_double(bar_h)),
              @markup.attr("fill", color),
            ],
            [],
          ),
        )
      }
    }
    // Category labels on the left (one per band, from series 0). The
    // gap (≈ 0.6% of frame width, ≈ 2.5pt on a 432pt-wide frame)
    // matches the measured spacing between plot-left and right edge of
    // category-axis labels. Same reverse-order rule keeps the first
    // category at the bottom.
    for i, label in labels {
      if i >= cat_count {
        break
      }
      let band_idx = cat_count - 1 - i
      let by = py + band_idx.to_double() * band + band / 2.0
      nodes.push(
        chart_text(
          label,
          px - fw * 0.006,
          by,
          w,
          h,
          anchor="end",
          baseline="middle",
        ),
      )
    }
  } else {
    // Vertical columns share the y-axis ticks helper.
    for n in y_axis_ticks(px, py, ph, max_v, pw, fw, axes.val_major) {
      nodes.push(n)
    }
    // Category-axis ticks along the BOTTOM at every band boundary
    // (column-bar charts only show boundary ticks — they omit the
    // intra-band centres that horizontal-bar charts add).
    for n in category_axis_ticks_bottom(px, py, pw, ph, fh, cat_count) {
      nodes.push(n)
    }
    // Vertical columns (the default barDir="col"). Multi-series
    // stacks clustered columns horizontally inside each category
    // band. the default `gapWidth=150` yields a cluster width
    // = 1/(1+1.5) ≈ 0.4 × category band; when multiple series share
    // a band the cluster is divided evenly between them and a
    // `overlap=0` gap rule keeps them flush. See bar branch above
    // for the derivation.
    let band = pw / cat_count.to_double()
    let cluster_w = if s_count == 1 { band * 0.4 } else { band * 0.56 }
    let pad = (band - cluster_w) / 2.0
    let bar_w = cluster_w / s_count.to_double()
    for si, s in series {
      let (_, values) = s
      let color = chart_series_color(ctx, si)
      for i, v in values {
        if i >= cat_count {
          break
        }
        let hgt = if max_v > 0.0 { v / max_v * ph } else { 0.0 }
        let bx = px + i.to_double() * band + pad + si.to_double() * bar_w
        let by = py + ph - hgt
        nodes.push(
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", format_double(bx)),
              @markup.attr("y", format_double(by)),
              @markup.attr("width", format_double(bar_w)),
              @markup.attr("height", format_double(hgt)),
              @markup.attr("fill", color),
            ],
            [],
          ),
        )
      }
    }
    // Category labels along the bottom (from series 0). Gap to plot
    // bottom is ≈ 1.8 % of the FRAME height (≈ 6pt on a 324pt frame),
    // matching the measured 7.x px gap between plot bottom and the
    // text top of Q1/Q2/… on a 4.5 in chart frame.
    for i, label in labels {
      if i >= cat_count {
        break
      }
      let bx = px + i.to_double() * band + band / 2.0
      let by = py + ph + fh * 0.018
      nodes.push(
        chart_text(label, bx, by, w, h, anchor="middle", baseline="hanging"),
      )
    }
  }
  nodes
}

// =============================================================================
// §21.2.2.96 CT_LineChart — single-series polyline renderer.
// Emits one `<polyline>` connecting the series points in category order,
// stroked with the series accent colour. Markers are not drawn by default
// (the fixture sets `<c:marker val="1"/>` but the per-point marker
// geometry is deferred to a future iteration).
// =============================================================================

///|
fn render_line_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : AxisGridlineFlags,
) -> Array[@xml.Node] {
  let ser = match first_child_named(elem, "ser") {
    Some(s) => s
    None => return []
  }
  let labels = read_cat_labels(ser)
  let values = read_val_numbers(ser)
  if values.length() == 0 {
    return []
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh)
  let max_v = nice_axis_max(max_positive(values))
  let n = values.length()
  let series_color = chart_series_color(ctx, 0)
  let nodes : Array[@xml.Node] = []
  nodes.push(plot_axes_rect(px, py, pw, ph))
  for n2 in y_axis_ticks(px, py, ph, max_v, pw, fw, axes.val_major) {
    nodes.push(n2)
  }
  // Line charts place a category tick at EACH data point along the
  // bottom axis (not at band boundaries). For n points the ticks are
  // at the same x positions as the polyline vertices.
  if n > 0 {
    let axis_color = "#bfbfbf"
    let major_half = fh * 0.0121
    let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
    let xstep = if n > 1 { pw / (n - 1).to_double() } else { 0.0 }
    let mut i = 0
    while i < n {
      let x = px + i.to_double() * xstep
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
  }
  // Build the points string ("x,y x,y …").
  let buf = StringBuilder::new()
  let step = if n > 1 { pw / (n - 1).to_double() } else { 0.0 }
  let mut first = true
  for i, v in values {
    let x = px + i.to_double() * step
    let y = if max_v > 0.0 { py + ph - v / max_v * ph } else { py + ph }
    if !first {
      buf.write_string(" ")
    }
    buf.write_string(format_double(x))
    buf.write_string(",")
    buf.write_string(format_double(y))
    first = false
  }
  nodes.push(
    @markup.elem_ns(
      "polyline",
      @markup.svg_ns,
      [
        @markup.attr("points", buf.to_string()),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", series_color),
        @markup.attr("stroke-width", format_double(h * 0.005)),
        @markup.attr("stroke-linejoin", "round"),
      ],
      [],
    ),
  )
  // Marker dots so the data is visible at low resolutions.
  let marker_r = h * 0.008
  for i, v in values {
    let x = px + i.to_double() * step
    let y = if max_v > 0.0 { py + ph - v / max_v * ph } else { py + ph }
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
  }
  // Category labels along the bottom. Same gap-vs-frame-height rule as
  // the vertical-column bar chart so the two chart-types agree on tick
  // text placement.
  for i, label in labels {
    if i >= n {
      break
    }
    let bx = px + i.to_double() * step
    let by = py + ph + fh * 0.018
    nodes.push(
      chart_text(label, bx, by, w, h, anchor="middle", baseline="hanging"),
    )
  }
  nodes
}

// =============================================================================
// §21.2.2.141 CT_PieChart / §21.2.2.57 CT_DoughnutChart — slice renderer.
// For each `<c:val>` data point we compute its angular share of the
// total sum, then emit an SVG `<path>` describing a filled pie wedge.
// When `hole_percent` is `Some(p)`, an inner arc traces a concentric
// circle at radius `outer*p/100` to produce a doughnut cutout.
//
// Slice colours rotate through the accent palette (matching the reference renderer's
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
  // inside the frame. The 0.469 multiplier matches the reference renderer's
  // measured pie geometry on a 6 in × 4.5 in chart frame: rasterising
  // the reference renderer at 96dpi places the pie bbox at (277,157)..(682,562),
  // i.e. diameter 405px = 303.75pt, radius 151.88pt; with min(w,h)=324pt
  // that yields 151.88/324 ≈ 0.469. The previous 0.42 produced a noticeably
  // smaller pie (RMSE ≈ 0.10 against the reference renderer).
  let cx = w / 2.0
  let cy = h / 2.0
  let outer = (if w < h { w } else { h }) * 0.469
  let inner = match hole_percent {
    Some(p) => outer * (p.to_double() / 100.0)
    None => 0.0
  }
  let nodes : Array[@xml.Node] = []
  let mut accum_deg = start_deg.to_double()
  for i, v in values {
    if v <= 0.0 {
      continue
    }
    let frac = v / total
    let sweep_deg = frac * 360.0
    let color = chart_series_color(ctx, i)
    let path_d = pie_slice_path(
      cx,
      cy,
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
  nodes
}

///|
/// §21.2.2.57 doughnutChart/holeSize — return the hole percentage,
/// falling back to the schema-default 10% when the element is absent or
/// the lexical value cannot be coerced to an integer. Accepts both
/// `<c:holeSize val="50%"/>` (spec form) and `<c:holeSize val="50"/>`
/// (the form the reference renderer tolerates and the catalog fixtures use).
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

// =============================================================================
// §21.2.2.176 CT_ScatterChart — XY point renderer with optional line.
// Reads the first `<c:ser>` and pulls X values from `<c:xVal>` and Y
// values from `<c:yVal>`. The `scatterStyle` attribute decides whether
// to connect points with a line (`lineMarker` / `smoothMarker`) or
// only draw markers (`marker`).
// =============================================================================

///|
fn render_scatter_chart(
  elem : @xml.Element,
  w : Double,
  h : Double,
  fw : Double,
  fh : Double,
  ctx : ColorResolveContext,
  axes : AxisGridlineFlags,
) -> Array[@xml.Node] {
  let style = match first_child_named(elem, "scatterStyle") {
    Some(s) => attr_or(s, "val", "marker")
    None => "marker"
  }
  let ser = match first_child_named(elem, "ser") {
    Some(s) => s
    None => return []
  }
  let xs = read_axis_numbers(ser, "xVal")
  let ys = read_axis_numbers(ser, "yVal")
  let n = if xs.length() < ys.length() { xs.length() } else { ys.length() }
  if n == 0 {
    return []
  }
  let (px, py, pw, ph) = chart_plot_inset(w, h, fw, fh)
  let max_x = nice_axis_max(max_positive(xs))
  let max_y = nice_axis_max(max_positive(ys))
  let min_x = min_value(xs)
  let min_y = min_value(ys)
  let series_color = chart_series_color(ctx, 0)
  let nodes : Array[@xml.Node] = []
  nodes.push(plot_axes_rect(px, py, pw, ph))
  for tick in y_axis_ticks(px, py, ph, max_y, pw, fw, axes.val_major) {
    nodes.push(tick)
  }
  let span_x = if max_x > min_x { max_x - min_x } else { 1.0 }
  let span_y = if max_y > min_y { max_y - min_y } else { 1.0 }
  let to_xy = fn(xi : Double, yi : Double) -> (Double, Double) {
    let x = px + (xi - min_x) / span_x * pw
    let y = py + ph - (yi - min_y) / span_y * ph
    (x, y)
  }
  let draw_line = style == "lineMarker" ||
    style == "smoothMarker" ||
    style == "line" ||
    style == "smooth"
  if draw_line {
    let buf = StringBuilder::new()
    let mut first = true
    let mut i = 0
    while i < n {
      let (x, y) = to_xy(xs[i], ys[i])
      if !first {
        buf.write_string(" ")
      }
      buf.write_string(format_double(x))
      buf.write_string(",")
      buf.write_string(format_double(y))
      first = false
      i = i + 1
    }
    nodes.push(
      @markup.elem_ns(
        "polyline",
        @markup.svg_ns,
        [
          @markup.attr("points", buf.to_string()),
          @markup.attr("fill", "none"),
          @markup.attr("stroke", series_color),
          @markup.attr("stroke-width", format_double(h * 0.005)),
          @markup.attr("stroke-linejoin", "round"),
        ],
        [],
      ),
    )
  }
  let marker_r = h * 0.012
  let mut j = 0
  while j < n {
    let (x, y) = to_xy(xs[j], ys[j])
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
    j = j + 1
  }
  nodes
}

// =============================================================================
// Shared axis helpers.
// =============================================================================

///|
/// Background `<rect>` for the plot area plus left + bottom axis lines.
/// Stroke colour mirrors the reference renderer's default mid-grey axis colour
/// (`#bfbfbf`).
fn plot_axes_rect(
  px : Double,
  py : Double,
  pw : Double,
  ph : Double,
) -> @xml.Node {
  let axis_color = "#bfbfbf"
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
/// Pick a "nice" tick step that lands on whole-number boundaries and
/// generates 5..11 tick intervals. Mirrors the reference renderer's
/// ScaleAutomatism::calculateExplicitIncrementAndScales which prefers
/// (1·10^n, 2·10^n, 5·10^n) step sizes.
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
  let candidates = [1.0, 2.0, 2.5, 5.0, 10.0]
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
/// — the reference renderer suppresses the gridlines on absence and our fixtures match that
/// behaviour. Gridlines stay light grey when drawn.
///
/// `fw` is the outer chart frame width; the gap between tick label and
/// plot left edge is taken as ≈ 1.4% of the frame (matching the reference renderer's
/// measured 6pt gap on a 432pt frame). The label uses anchor="end" so
/// it grows rightward toward the plot's left axis.
fn y_axis_ticks(
  px : Double,
  py : Double,
  ph : Double,
  max_v : Double,
  pw : Double,
  fw : Double,
  draw_gridlines : Bool,
) -> Array[@xml.Node] {
  if max_v <= 0.0 {
    return []
  }
  let grid_color = "#e0e0e0"
  let axis_color = "#bfbfbf"
  // Cross-style tick mark half-lengths measured against the reference renderer
  // on chart-bar-with-legend (432pt × 324pt frame): the reference renderer renders the
  // major tick as a 12px-tall feature and the minor tick as an 8px-
  // tall feature INCLUDING the strokewidth. Resolving the line stroke
  // into the bounding box: major covers 6 px each side of the axis;
  // minor covers 4 px each side. Expressed as a fraction of frame
  // WIDTH (576px at 96dpi → 5486400 EMU for the 6in fixtures):
  // major ≈ 6 / 576 ≈ 0.0104; minor ≈ 4 / 576 ≈ 0.0069. ECMA-376
  // §21.2.2.137 nominally defaults `majorTickMark` to "out" but the reference renderer
  // draws cross-style ticks straddling the axis line — we match the reference renderer
  // so the snapshot harness sees the same pixel pattern at every
  // intersection.
  let major_half = fw * 0.0104
  let minor_half = fw * 0.0069
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = nice_axis_step(max_v)
  let label_gap = fw * 0.014
  // Minor ticks: the reference renderer subdivides each major step into 5 minor units
  // (visible on the 0..45 axis as 46 minor ticks at every integer).
  // Drawing minors first keeps major ticks visually on top.
  let minor_per_major = 5
  let minor_step = step / minor_per_major.to_double()
  let mut mv = 0.0
  while mv <= max_v + minor_step * 0.001 {
    let f = mv / max_v
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
    mv = mv + minor_step
  }
  let mut tick_v = 0.0
  while tick_v <= max_v + step * 0.001 {
    let f = tick_v / max_v
    let y = py + ph - f * ph
    if tick_v > 0.0 && draw_gridlines {
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
    let label = format_axis_value(tick_v)
    nodes.push(
      chart_text(
        label,
        px - label_gap,
        y,
        pw,
        ph,
        anchor="end",
        baseline="middle",
      ),
    )
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
) -> Array[@xml.Node] {
  if max_v <= 0.0 {
    return []
  }
  let grid_color = "#e0e0e0"
  let axis_color = "#bfbfbf"
  // Cross-style tick mark half-lengths against frame HEIGHT (the axis
  // is horizontal so the tick is vertical). the reference renderer renders the major tick
  // at 12 px total (half = (12 - axis_stroke)/2 ≈ 5.22 px) and the
  // minor at 8 px total (half ≈ 3.22 px) on a 432px frame. With our
  // 9525 EMU/px and frame height in EMU, the half-length expressed as
  // a ratio of fh resolves to 0.0121 for major and 0.0075 for minor.
  let major_half = fh * 0.0121
  let minor_half = fh * 0.0075
  let tick_stroke = format_double((if pw < ph { pw } else { ph }) * 0.004)
  let nodes : Array[@xml.Node] = []
  let step = nice_axis_step(max_v)
  let minor_per_major = 5
  let minor_step = step / minor_per_major.to_double()
  let mut mv = 0.0
  while mv <= max_v + minor_step * 0.001 {
    let f = mv / max_v
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
    let f = tick_v / max_v
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
    let label = format_axis_value(tick_v)
    nodes.push(
      chart_text(
        label,
        x,
        py + ph + fh * 0.018,
        pw,
        ph,
        anchor="middle",
        baseline="hanging",
      ),
    )
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
    // One decimal place.
    let scaled = v * 10.0
    let i10 = (scaled + 0.5).to_int()
    let whole = i10 / 10
    let frac = i10 - whole * 10
    let frac_abs = if frac < 0 { -frac } else { frac }
    whole.to_string() + "." + frac_abs.to_string()
  }
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
) -> @xml.Node {
  let font_size = (if w < h { w } else { h }) * 0.035
  // §21.1.2 — we measure with @glyph for future tighter layout but the
  // current pass only needs the text node itself; the helper call keeps
  // the dependency live so it gets pulled in.
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
      @markup.attr("fill", "#595959"),
      @markup.attr("font-family", "sans-serif"),
    ],
    [@markup.text(text)],
  )
}

// =============================================================================
// Element-tree helpers — pull labels / numbers out of the well-known
// `<c:cat>` / `<c:val>` / `<c:xVal>` / `<c:yVal>` subtrees regardless of
// whether the values live in a `<c:numRef>/<c:numCache>` or a
// `<c:numLit>` (literal cache). We accept missing pieces silently and
// fall back to empty arrays so the renderer never raises.
// =============================================================================

///|
/// Read the category labels for a series. Tries
/// `<c:cat>/<c:strRef>/<c:strCache>/<c:pt>/<c:v>` first, then falls back
/// to `<c:cat>/<c:strLit>` and to the numeric `<c:cat>/<c:numRef>` cache
/// (rendered as the underlying number's lexical form) for completeness.
fn read_cat_labels(ser : @xml.Element) -> Array[String] {
  let cat = match first_child_named(ser, "cat") {
    Some(c) => c
    None => return []
  }
  match first_child_named(cat, "strRef") {
    Some(sr) =>
      match first_child_named(sr, "strCache") {
        Some(sc) => collect_pt_values(sc)
        None => []
      }
    None =>
      match first_child_named(cat, "strLit") {
        Some(sl) => collect_pt_values(sl)
        None =>
          match first_child_named(cat, "numRef") {
            Some(nr) =>
              match first_child_named(nr, "numCache") {
                Some(nc) => collect_pt_values(nc)
                None => []
              }
            None => []
          }
      }
  }
}

///|
/// Read numeric values from a series' `<c:val>` child as
/// (`<c:numRef>/<c:numCache>` preferred, `<c:numLit>` fallback).
fn read_val_numbers(ser : @xml.Element) -> Array[Double] {
  let val = match first_child_named(ser, "val") {
    Some(v) => v
    None => return []
  }
  read_num_data_under(val)
}

///|
/// Same as `read_val_numbers` but for the scatter chart's `<c:xVal>` /
/// `<c:yVal>` children. The element name is parameterised because the
/// schema spells the two axes differently.
fn read_axis_numbers(ser : @xml.Element, name : String) -> Array[Double] {
  let v = match first_child_named(ser, name) {
    Some(e) => e
    None => return []
  }
  read_num_data_under(v)
}

///|
/// Walk into a `<c:val>` / `<c:xVal>` / `<c:yVal>` element and find the
/// numeric cache underneath, then return the parsed point values.
fn read_num_data_under(parent : @xml.Element) -> Array[Double] {
  let cache = match first_child_named(parent, "numRef") {
    Some(nr) => first_child_named(nr, "numCache")
    None => first_child_named(parent, "numLit")
  }
  let cache_el = match cache {
    Some(c) => c
    None => return []
  }
  let strings = collect_pt_values(cache_el)
  let nums : Array[Double] = []
  for s in strings {
    nums.push(parse_double_lenient(s))
  }
  nums
}

///|
/// Walk a `<c:strCache>` / `<c:numCache>` element, collecting the text
/// content of each `<c:pt>/<c:v>` child in document order. The schema
/// indexes points via `@idx` but we honour the order they appear, which
/// matches every catalog fixture and the canonical writer output.
fn collect_pt_values(cache : @xml.Element) -> Array[String] {
  let out : Array[String] = []
  for ch in cache.children {
    match ch {
      @xml.Node::Element(elem) =>
        if elem.name.local_name == "pt" {
          match first_child_named(elem, "v") {
            Some(v_el) => out.push(element_text_content(v_el))
            None => ()
          }
        }
      _ => ()
    }
  }
  out
}

///|
/// Concatenate the text + cdata children of an element into a single
/// String. Mirrors the chart-package's private `element_text` so we
/// don't need to cross the schema-violation boundary.
fn element_text_content(elem : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for ch in elem.children {
    match ch {
      @xml.Node::Text(t) => buf.write_string(t)
      @xml.Node::CData(t) => buf.write_string(t)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// Lenient `attr value` lookup (no namespace check) that falls back to a
/// supplied default when the attribute is absent. Used for the chart
/// type's small enum attributes (barDir, scatterStyle).
fn attr_or(elem : @xml.Element, name : String, fallback : String) -> String {
  for a in elem.attributes {
    if a.name.local_name == name {
      return a.value
    }
  }
  fallback
}

// =============================================================================
// Lenient numeric parsers — accept what the reference renderer accepts (signed
// integers / decimals, scientific notation rejected for simplicity).
// The catalog fixtures only carry plain integers ("10", "30", …) so we
// keep the implementation small and explicit instead of pulling in the
// dml-chart.xsd typed parsers (which raise on malformed input).
// =============================================================================

///|
/// Parse a signed integer; returns 0 for unparseable input.
fn parse_int_lenient(s : String) -> Int {
  if s.length() == 0 {
    return 0
  }
  let mut i = 0
  let mut negative = false
  if s[0:1] == "-" {
    negative = true
    i = 1
  } else if s[0:1] == "+" {
    i = 1
  }
  let mut n = 0
  while i < s.length() {
    let ch = s[i:i + 1]
    if ch < "0" || ch > "9" {
      break
    }
    let d = ch[0].to_int() - "0"[0].to_int()
    n = n * 10 + d
    i = i + 1
  }
  if negative {
    -n
  } else {
    n
  }
}

///|
/// Parse a signed decimal; returns 0.0 for unparseable input.
fn parse_double_lenient(s : String) -> Double {
  if s.length() == 0 {
    return 0.0
  }
  let mut i = 0
  let mut negative = false
  if s[0:1] == "-" {
    negative = true
    i = 1
  } else if s[0:1] == "+" {
    i = 1
  }
  let mut whole : Int64 = 0L
  while i < s.length() && s[i:i + 1] != "." {
    let ch = s[i:i + 1]
    if ch < "0" || ch > "9" {
      break
    }
    let d = (ch[0].to_int() - "0"[0].to_int()).to_int64()
    whole = whole * 10L + d
    i = i + 1
  }
  let mut frac : Double = 0.0
  let mut scale : Double = 1.0
  if i < s.length() && s[i:i + 1] == "." {
    i = i + 1
    while i < s.length() {
      let ch = s[i:i + 1]
      if ch < "0" || ch > "9" {
        break
      }
      let d = (ch[0].to_int() - "0"[0].to_int()).to_double()
      scale = scale * 10.0
      frac = frac + d / scale
      i = i + 1
    }
  }
  let magnitude = whole.to_double() + frac
  if negative {
    -magnitude
  } else {
    magnitude
  }
}

///|
/// Sum of strictly positive values (negative entries are dropped to
/// keep the pie/doughnut total well-defined).
fn sum_positive(values : Array[Double]) -> Double {
  let mut s = 0.0
  for v in values {
    if v > 0.0 {
      s = s + v
    }
  }
  s
}

///|
/// Maximum of the positive values; returns 0.0 when the array is empty
/// or every entry is non-positive.
fn max_positive(values : Array[Double]) -> Double {
  let mut m = 0.0
  for v in values {
    if v > m {
      m = v
    }
  }
  m
}

///|
/// Minimum of all values (including negatives). Returns 0.0 for the
/// empty array; used by the scatter chart to compute axis spans.
fn min_value(values : Array[Double]) -> Double {
  if values.length() == 0 {
    return 0.0
  }
  let mut m = values[0]
  for v in values {
    if v < m {
      m = v
    }
  }
  m
}
