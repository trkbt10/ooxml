// =============================================================================
// §21.2 chart series / data-point fills — gradient & pattern resolution.
//
// A chart series (`<c:ser>/<c:spPr>`) and per-data-point
// (`<c:dPt>/<c:spPr>`) may carry any §20.1.8 EG_FillProperties choice,
// not only a `<a:solidFill>`.  The historical chart renderer resolved
// ONLY the solid fill and degraded every gradient / pattern series to a
// flat colour.  This module resolves a series-level `<c:spPr>` (or any
// element directly containing the fill choice element) into an SVG
// `fill="…"` attribute value, registering a `<linearGradient>` /
// `<radialGradient>` / `<pattern>` def in the shared `SvgDefsCollector`
// when the fill is a gradient or pattern, and returning a `url(#id)`
// reference.
//
// Single-Source-of-Truth decision:
//   * COLOUR resolution is delegated wholesale to `@paint`
//     (`resolve_solid_fill` + `format_resolved_color`).  Every `<a:gs>`
//     gradient stop, every `<a:fgClr>` / `<a:bgClr>` pattern colour, and
//     the solid-fill path all flow through the same shared primitive, so
//     theme / scheme / tint-shade resolution is never duplicated.
//   * The SVG ELEMENT SHAPE (the `<linearGradient>` / `<radialGradient>`
//     / `<pattern>` node geometry) is built locally here rather than
//     reused from `presentation_ml/viewer/fill.mbt`.  That construction
//     lives in a DIFFERENT package (the PML slide viewer) which this
//     DrawingML-chart package must not depend on; extracting it into a
//     shared module would require moving the gradient-coordinate maths
//     AND the §20.1.10.51 pattern-tile geometry table into `@paint` (a
//     pure colour-resolution package today), an invasive cross-package
//     refactor.  The local construction is built strictly on the shared
//     `@paint` colour primitives, so no colour logic is duplicated — only
//     the SVG element wrapper, which is small and chart-context-specific
//     (a chart series fill always paints an object-bounding-box region,
//     unlike a slide shape).

///|
/// One gradient stop, with position in percent [0,100] and resolved
/// `@paint` colour (hex + alpha).  Mirrors the PML viewer's
/// `GradientStopValue` but keeps the chart package self-contained.
priv struct ChartGradientStop {
  position : Double
  color : ResolvedColor
}

///|
/// §20.1.8.36 (a:gs) — read the `<a:gsLst>` of a `<a:gradFill>` into a
/// list of stops.  The `@pos` attribute is ST_PositiveFixedPercentage
/// in thousandths-of-a-percent (0..100000) → /1000 to get percent.
/// Each stop's colour is resolved through `@paint.resolve_solid_fill`
/// (the SoT colour primitive), so a `<a:gs>` carrying a `<a:schemeClr>`
/// or tinted `<a:srgbClr>` resolves identically to a solid series fill.
fn read_chart_gradient_stops(
  grad_fill : @xml.Element,
  ctx : ColorResolveContext,
) -> Array[ChartGradientStop] {
  let result : Array[ChartGradientStop] = []
  let gs_lst = match first_child_named(grad_fill, "gsLst") {
    Some(e) => e
    None => return result
  }
  for child in gs_lst.children {
    match child {
      Element(gs) =>
        if gs.name.local_name == "gs" {
          let pos = match attr_value(gs, "pos") {
            Some(v) => parse_double_lenient(v) / 1000.0
            None => 0.0
          }
          match @paint.resolve_solid_fill(gs, ctx~) {
            Some(rc) => result.push({ position: pos, color: rc })
            None => ()
          }
        }
      _ => ()
    }
  }
  result
}

///|
/// Build the `<stop offset="..%" stop-color="#hex" [stop-opacity]/>`
/// nodes for a gradient stop list.  The colour text comes straight from
/// the `@paint`-resolved `ResolvedColor`, so no hex formatting logic is
/// re-derived here.
fn build_chart_stop_nodes(stops : Array[ChartGradientStop]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for stop in stops {
    let attrs : Array[@xml.Attribute] = [
      @markup.attr("offset", format_double(stop.position) + "%"),
      @markup.attr("stop-color", "#" + stop.color.hex),
    ]
    if stop.color.alpha < 1.0 {
      attrs.push(@markup.attr("stop-opacity", stop.color.alpha.to_string()))
    }
    nodes.push(@markup.elem_ns("stop", @markup.svg_ns, attrs, []))
  }
  nodes
}

///|
/// §20.1.8.46 (a:path) — true iff a `<a:gradFill>` is a radial (path)
/// gradient.  The presence of `<a:path>` indicates a radial gradient;
/// linear gradients use `<a:lin ang="…"/>`.
fn chart_is_radial_gradient(grad_fill : @xml.Element) -> Bool {
  match first_child_named(grad_fill, "path") {
    Some(_) => true
    None => false
  }
}

///|
/// §20.1.8.41 (a:lin) — read `<a:lin ang="…"/>` and return the angle in
/// degrees.  The `@ang` attribute is ST_PositiveFixedAngle in
/// 60000ths-of-a-degree; absent → 0° (left-to-right gradient).
fn chart_read_lin_angle(grad_fill : @xml.Element) -> Double {
  match first_child_named(grad_fill, "lin") {
    None => 0.0
    Some(lin) =>
      match attr_value(lin, "ang") {
        None => 0.0
        Some(v) => parse_double_lenient(v) / 60000.0
      }
  }
}

///|
/// Convert an OOXML linear-gradient angle (degrees, measured clockwise
/// from the positive-x axis in a Y-down system, §20.1.8.41) to SVG
/// `linearGradient` x1/y1/x2/y2 percentages.  SVG uses the same Y-down
/// convention, so the OOXML angle maps directly: the gradient direction
/// is `(cosθ, sinθ)` and the endpoints sit at the box centre ±half along
/// it.  This is the chart-local copy of the PML viewer's
/// `ooxml_angle_to_svg_linear_gradient`; the maths is tiny and the PML
/// helper lives in a package this one must not import.
fn chart_linear_gradient_coords(
  angle : Double,
) -> (Double, Double, Double, Double) {
  let rad = angle * (3.141592653589793 / 180.0)
  let x1 = 50.0 - 50.0 * @math.cos(rad)
  let y1 = 50.0 - 50.0 * @math.sin(rad)
  let x2 = 50.0 + 50.0 * @math.cos(rad)
  let y2 = 50.0 + 50.0 * @math.sin(rad)
  (x1, y1, x2, y2)
}

///|
/// §20.1.8.30 (a:fillToRect) — compute the radial-gradient centre from a
/// `<a:path>/<a:fillToRect l t r b>` (edge margins as percentages in
/// thousandths-of-a-percent).  The centre is the midpoint of the
/// uncovered region.  Returns the 50%/50% spec default when no
/// `<a:fillToRect>` is present.
fn chart_radial_gradient_center(grad_fill : @xml.Element) -> (Double, Double) {
  match first_child_named(grad_fill, "path") {
    None => (50.0, 50.0)
    Some(path_el) =>
      match first_child_named(path_el, "fillToRect") {
        None => (50.0, 50.0)
        Some(ftr) => {
          // ST_PositiveFixedPercentage — thousandths-of-a-percent.
          let pct = fn(name : String) -> Double {
            match attr_value(ftr, name) {
              Some(v) => parse_double_lenient(v) / 1000.0
              None => 0.0
            }
          }
          let l = pct("l")
          let t = pct("t")
          let r = pct("r")
          let b = pct("b")
          ((l + (100.0 - r)) / 2.0, (t + (100.0 - b)) / 2.0)
        }
      }
  }
}

///|
/// §20.1.8.33 (a:gradFill) — build an SVG `<linearGradient>` /
/// `<radialGradient>` def node for the gradient.  Returns `None` when
/// the gradient has no stops (the caller then keeps the accent-palette
/// fallback).  Stop colours are resolved via `@paint`; only the element
/// wrapper is constructed here.
fn build_chart_grad_fill_def(
  grad_fill : @xml.Element,
  gradient_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node? {
  let stops = read_chart_gradient_stops(grad_fill, ctx)
  if stops.length() == 0 {
    return None
  }
  let stop_nodes = build_chart_stop_nodes(stops)
  if chart_is_radial_gradient(grad_fill) {
    let (cx, cy) = chart_radial_gradient_center(grad_fill)
    Some(
      @markup.elem_ns(
        "radialGradient",
        @markup.svg_ns,
        [
          @markup.attr("id", gradient_id),
          @markup.attr("cx", format_double(cx) + "%"),
          @markup.attr("cy", format_double(cy) + "%"),
          @markup.attr("r", "50%"),
        ],
        stop_nodes,
      ),
    )
  } else {
    let (x1, y1, x2, y2) = chart_linear_gradient_coords(
      chart_read_lin_angle(grad_fill),
    )
    Some(
      @markup.elem_ns(
        "linearGradient",
        @markup.svg_ns,
        [
          @markup.attr("id", gradient_id),
          @markup.attr("x1", format_double(x1) + "%"),
          @markup.attr("y1", format_double(y1) + "%"),
          @markup.attr("x2", format_double(x2) + "%"),
          @markup.attr("y2", format_double(y2) + "%"),
        ],
        stop_nodes,
      ),
    )
  }
}

///|
/// §20.1.8.16 (a:fgClr) / §20.1.8.10 (a:bgClr) — resolve a pattern
/// fill's foreground / background colour via the shared `@paint`
/// primitive, falling back to `fallback` when the wrapper is absent.
fn chart_patt_fill_color(
  patt_fill : @xml.Element,
  child_local : String,
  fallback : String,
  ctx : ColorResolveContext,
) -> String {
  match first_child_named(patt_fill, child_local) {
    None => fallback
    Some(wrapper) =>
      match @paint.resolve_solid_fill(wrapper, ctx~) {
        Some(rc) => @paint.format_resolved_color(rc)
        None => fallback
      }
  }
}

///|
/// §20.1.10.51 — the percentage-density (`pct5` … `pct90`) preset
/// patterns map to a dot fraction in [0,1]; `None` for any other preset.
fn chart_pattern_pct_density(prst : String) -> Double? {
  match prst {
    "pct5" => Some(0.05)
    "pct10" => Some(0.1)
    "pct20" => Some(0.2)
    "pct25" => Some(0.25)
    "pct30" => Some(0.3)
    "pct40" => Some(0.4)
    "pct50" => Some(0.5)
    "pct60" => Some(0.6)
    "pct70" => Some(0.7)
    "pct75" => Some(0.75)
    "pct80" => Some(0.8)
    "pct90" => Some(0.9)
    _ => None
  }
}

///|
/// Build the geometry child nodes of a §20.1.8.47 pattern tile for a
/// recognised `@prst`.  The tile is an 8×8 user-space cell painted with
/// `fg`.  Covers the principal §20.1.10.50 ST_PresetPatternVal families
/// (percentage dots, horizontal / vertical / diagonal rules, cross- and
/// diagonal-hatch, grids, checks); `None` for an unknown preset so the
/// caller falls back to a flat foreground fill.  This is the
/// chart-context geometry table; it does NOT re-derive any colour logic
/// (the `fg` string is the already-`@paint`-resolved colour).
fn chart_pattern_tile_marks(prst : String, fg : String) -> Array[@xml.Node]? {
  fn line(x1 : Double, y1 : Double, x2 : Double, y2 : Double, sw : Double) {
    @markup.elem_ns(
      "line",
      @markup.svg_ns,
      [
        @markup.attr("x1", format_double(x1)),
        @markup.attr("y1", format_double(y1)),
        @markup.attr("x2", format_double(x2)),
        @markup.attr("y2", format_double(y2)),
        @markup.attr("stroke", fg),
        @markup.attr("stroke-width", format_double(sw)),
      ],
      [],
    )
  }

  fn dot(cx : Double, cy : Double, r : Double) {
    @markup.elem_ns(
      "circle",
      @markup.svg_ns,
      [
        @markup.attr("cx", format_double(cx)),
        @markup.attr("cy", format_double(cy)),
        @markup.attr("r", format_double(r)),
        @markup.attr("fill", fg),
      ],
      [],
    )
  }

  fn quad(x : Double, y : Double) {
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", format_double(x)),
        @markup.attr("y", format_double(y)),
        @markup.attr("width", "4"),
        @markup.attr("height", "4"),
        @markup.attr("fill", fg),
      ],
      [],
    )
  }

  // Percentage-density presets — a single centred dot whose radius grows
  // with the density fraction (area ∝ fraction over the 8×8 cell, capped
  // so high percentages still read as a pattern).
  match chart_pattern_pct_density(prst) {
    Some(frac) => {
      let r = (frac * 64.0 / 3.14159).sqrt().min(3.6)
      return Some([dot(4.0, 4.0, r)])
    }
    None => ()
  }
  match prst {
    "horz" | "ltHorz" => Some([line(0.0, 4.0, 8.0, 4.0, 1.0)])
    "dkHorz" => Some([line(0.0, 4.0, 8.0, 4.0, 2.5)])
    "narHorz" =>
      Some([line(0.0, 2.0, 8.0, 2.0, 1.0), line(0.0, 6.0, 8.0, 6.0, 1.0)])
    "vert" | "ltVert" => Some([line(4.0, 0.0, 4.0, 8.0, 1.0)])
    "dkVert" => Some([line(4.0, 0.0, 4.0, 8.0, 2.5)])
    "narVert" =>
      Some([line(2.0, 0.0, 2.0, 8.0, 1.0), line(6.0, 0.0, 6.0, 8.0, 1.0)])
    "ltDnDiag" | "dnDiag" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 1.0),
        line(-8.0, 0.0, 8.0, 16.0, 1.0),
        line(0.0, -8.0, 16.0, 8.0, 1.0),
      ])
    "dkDnDiag" | "wdDnDiag" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 2.5),
        line(-8.0, 0.0, 8.0, 16.0, 2.5),
        line(0.0, -8.0, 16.0, 8.0, 2.5),
      ])
    "ltUpDiag" | "upDiag" =>
      Some([
        line(0.0, 8.0, 8.0, 0.0, 1.0),
        line(-8.0, 8.0, 8.0, -8.0, 1.0),
        line(0.0, 16.0, 16.0, 0.0, 1.0),
      ])
    "dkUpDiag" | "wdUpDiag" =>
      Some([
        line(0.0, 8.0, 8.0, 0.0, 2.5),
        line(-8.0, 8.0, 8.0, -8.0, 2.5),
        line(0.0, 16.0, 16.0, 0.0, 2.5),
      ])
    "cross" | "smGrid" =>
      Some([line(0.0, 4.0, 8.0, 4.0, 1.0), line(4.0, 0.0, 4.0, 8.0, 1.0)])
    "lgGrid" =>
      Some([line(0.0, 0.0, 8.0, 0.0, 1.0), line(0.0, 0.0, 0.0, 8.0, 1.0)])
    "diagCross" =>
      Some([
        line(0.0, 0.0, 8.0, 8.0, 1.0),
        line(-8.0, 0.0, 8.0, 16.0, 1.0),
        line(0.0, -8.0, 16.0, 8.0, 1.0),
        line(0.0, 8.0, 8.0, 0.0, 1.0),
        line(-8.0, 8.0, 8.0, -8.0, 1.0),
        line(0.0, 16.0, 16.0, 0.0, 1.0),
      ])
    "dotGrid" => Some([dot(0.0, 0.0, 1.0)])
    "smCheck" | "lgCheck" => Some([quad(0.0, 0.0), quad(4.0, 4.0)])
    "dotDmnd" => Some([dot(4.0, 4.0, 1.0)])
    "sphere" => Some([dot(4.0, 4.0, 3.4)])
    _ => None
  }
}

///|
/// §20.1.8.47 (a:pattFill) — build an SVG `<pattern>` def for a pattern
/// fill.  Returns `None` when `@prst` is absent or names an unmapped
/// preset, so the caller can fall back to the foreground colour.  The
/// tile paints `<a:bgClr>` as the panel and `<a:fgClr>` for the marks;
/// both colours flow through `@paint`.
fn build_chart_patt_fill_def(
  patt_fill : @xml.Element,
  pattern_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node? {
  let prst = match attr_value(patt_fill, "prst") {
    Some(v) => v
    None => return None
  }
  let fg = chart_patt_fill_color(patt_fill, "fgClr", "#000000", ctx)
  let bg = chart_patt_fill_color(patt_fill, "bgClr", "#ffffff", ctx)
  let marks = match chart_pattern_tile_marks(prst, fg) {
    Some(m) => m
    None => return None
  }
  let children : Array[@xml.Node] = [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("x", "0"),
        @markup.attr("y", "0"),
        @markup.attr("width", "8"),
        @markup.attr("height", "8"),
        @markup.attr("fill", bg),
      ],
      [],
    ),
  ]
  for m in marks {
    children.push(m)
  }
  Some(
    @markup.elem_ns(
      "pattern",
      @markup.svg_ns,
      [
        @markup.attr("id", pattern_id),
        @markup.attr("patternUnits", "userSpaceOnUse"),
        @markup.attr("width", "8"),
        @markup.attr("height", "8"),
      ],
      children,
    ),
  )
}

///|
/// §21.2 — resolve the fill carried by a `<c:spPr>` (or any element that
/// directly contains a §20.1.8 EG_FillProperties choice element) into an
/// SVG `fill="…"` attribute value.
///
///   * `<a:solidFill>` → `#rrggbb` (the common case — byte-identical to
///     the historical `read_series_fill_color` path).
///   * `<a:gradFill>`  → registers a `<linearGradient>` / `<radialGradient>`
///     def in `defs` and returns `url(#id)`.
///   * `<a:pattFill>`  → registers a `<pattern>` def in `defs` and returns
///     `url(#id)` (an unmapped preset falls back to the `<a:fgClr>`
///     colour so the series still picks up the intended hue).
///   * `<a:noFill>` / no fill choice → returns `""` so the caller keeps
///     its accent-palette fallback (preserving the legacy behaviour for
///     fill-less series).
///
/// `id_hint` seeds the generated def id; the `SvgDefsCollector` appends a
/// monotonic counter so ids are stable AND collision-free across series
/// and data points within one chart render.
fn resolve_sppr_fill(
  sp_pr : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  id_hint : String,
) -> String {
  // §20.1.8 EG_FillProperties — the fill choice is a direct child of
  // `<a:spPr>`.  Probe each flavour in schema order; absence of any
  // recognised choice yields "" (caller keeps the accent fallback).
  match first_child_named(sp_pr, "solidFill") {
    Some(sf) =>
      match @paint.resolve_solid_fill(sf, ctx~) {
        Some(rc) => return @paint.format_resolved_color(rc)
        None => ()
      }
    None => ()
  }
  match first_child_named(sp_pr, "gradFill") {
    Some(gf) => {
      let id = defs.next_id(id_hint + "-grad")
      match build_chart_grad_fill_def(gf, id, ctx) {
        Some(def) => {
          defs.add_def(def)
          return "url(#" + id + ")"
        }
        None => ()
      }
    }
    None => ()
  }
  match first_child_named(sp_pr, "pattFill") {
    Some(pf) => {
      let id = defs.next_id(id_hint + "-patt")
      match build_chart_patt_fill_def(pf, id, ctx) {
        Some(def) => {
          defs.add_def(def)
          return "url(#" + id + ")"
        }
        None =>
          // Unmapped preset / missing `@prst` — fall back to the
          // `<a:fgClr>` colour so the series still picks up the
          // pattern's intended hue rather than vanishing.
          return chart_patt_fill_color(pf, "fgClr", "", ctx)
      }
    }
    None => ()
  }
  // §20.1.8.44 (a:noFill) and absent fill: no explicit fill — the caller
  // keeps the accent-palette fallback.
  ""
}

///|
/// §21.2.2.171 ser — resolve a series element's `<c:spPr>` fill.  Returns
/// `None` when the series has no `<c:spPr>` or no recognised fill choice
/// (so the caller falls back to the accent palette), `Some(value)` with a
/// `#rrggbb` solid or a `url(#id)` gradient / pattern reference otherwise.
fn resolve_series_fill(
  ser : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  id_hint : String,
) -> String? {
  let sp_pr = match first_child_named(ser, "spPr") {
    Some(s) => s
    None => return None
  }
  let v = resolve_sppr_fill(sp_pr, ctx, defs, id_hint)
  if v.length() == 0 {
    None
  } else {
    Some(v)
  }
}
