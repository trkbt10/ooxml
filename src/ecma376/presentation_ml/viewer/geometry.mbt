// @source web-pptx packages/@aurochs-renderer/drawing-ml/src/svg/geometry/*
//
// Dispatcher + simple preset-geometry generators.  The dispatcher
// honours every entry in `preset_shapes_*` registries; concrete
// preset implementations live in
//   preset_shapes_basic.mbt      — rect, ellipse, triangle, ...
//   preset_shapes_polygon.mbt    — pentagon, hexagon, ...
//   preset_shapes_star.mbt       — star4 … star32
//   preset_shapes_arrow.mbt      — rightArrow, leftArrow, ...
//   preset_shapes_callout.mbt    — wedgeRectCallout, ...
//   preset_shapes_flowchart.mbt  — flowChartProcess, ...
//   preset_shapes_action.mbt     — actionButtonBlank, ...
//
// ECMA-376 references:
//   §20.1.9      DrawingML shape definitions
//   §20.1.9.18   ST_GeomGuideFormula
//   §20.1.10.55  ST_ShapeType
//   §20.1.10.56  Preset shape registry

///|
/// Adjust-value list parser — read `<a:avLst><a:gd name="adj1" fmla="val ..."/>`
/// children into an `Array[AdjustValue]`.  The `fmla` body for an
/// avLst entry is always `val <number>` so we extract the literal.
fn parse_adjust_values(av_lst : @xml.Element?) -> Array[AdjustValue] {
  let result : Array[AdjustValue] = []
  match av_lst {
    None => return result
    Some(lst) =>
      for child in lst.children {
        match child {
          Element(gd) =>
            if gd.name.local_name == "gd" {
              let name = match attr_value(gd, "name") {
                Some(n) => n
                None => continue
              }
              let fmla = match attr_value(gd, "fmla") {
                Some(f) => f
                None => continue
              }
              // fmla is "val <number>" — strip the leading "val ".
              let body = if fmla.has_prefix("val ") {
                fmla[4:].to_owned()
              } else {
                fmla
              }
              let v = try @string.parse_double(body.trim().to_owned()) catch {
                _ => 0.0
              } noraise {
                d => d
              }
              result.push({ name, value: v })
            }
          _ => ()
        }
      }
  }
  result
}

///|
/// Format a Double for path data — integer values render without
/// fractional digits to keep the output compact and close to the TS
/// reference output (which uses template literals on numbers).
fn fmt(value : Double) -> String {
  let rounded = value.to_int().to_double()
  if rounded == value {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

///|
/// Render a `<a:prstGeom>` element to an SVG path-data string.
///
/// Walks `<a:avLst>` first to gather adjust values, then dispatches
/// on the `prst` attribute.  Returns `Some(path_data)` for every
/// preset listed in `preset_shape_dispatch`, or `None` when the
/// preset is unknown.
pub fn render_preset_geometry(
  prst_geom : @xml.Element,
  width : Double,
  height : Double,
) -> String? {
  let prst = match attr_value(prst_geom, "prst") {
    Some(p) => p
    None => return None
  }
  let avs = parse_adjust_values(first_child_named(prst_geom, "avLst"))
  let ctx = create_guide_context(width, height, adjust_values=avs)
  preset_shape_dispatch(prst, width, height, ctx)
}

///|
/// Format a custom-geometry coordinate, snapping floating-point noise.
/// Trig in `arcTo` leaves residuals like `3.06e-15` where an exact `0`
/// is meant; rounding to 1e-4 px removes the noise (and the ugly
/// scientific-notation output) while staying well below sub-pixel
/// significance, then `fmt` collapses integral results to plain ints.
fn fmt_coord(value : Double) -> String {
  let scaled = value * 10000.0
  let rounded = (scaled + (if scaled >= 0.0 { 0.5 } else { -0.5 })).to_int().to_double() /
    10000.0
  // Avoid emitting "-0".
  let normal = if rounded == 0.0 { 0.0 } else { rounded }
  fmt(normal)
}

///|
/// Read the `<a:gdLst>` of a `<a:custGeom>` into `GuideEntry`s — each
/// `<a:gd name="…" fmla="…"/>` becomes one entry.  Unlike
/// `parse_adjust_values` (which only handles the `val N` formulas of an
/// `<a:avLst>`), these formulas are full guide expressions (`*/ w 2 1`,
/// `pin 0 x1 w`, …) evaluated by `evaluate_guides`.
fn parse_geom_guides(gd_lst : @xml.Element?) -> Array[GuideEntry] {
  let result : Array[GuideEntry] = []
  match gd_lst {
    None => return result
    Some(lst) =>
      for child in lst.children {
        match child {
          Element(gd) =>
            if gd.name.local_name == "gd" {
              let name = match attr_value(gd, "name") {
                Some(n) => n
                None => continue
              }
              let fmla = match attr_value(gd, "fmla") {
                Some(f) => f
                None => continue
              }
              result.push({ name, formula: fmla })
            }
          _ => ()
        }
      }
  }
  result
}

///|
/// Resolve an `<a:pt>` child's `x` / `y` coordinate through the guide
/// context.  Each attribute is an `ST_AdjCoordinate` — either a literal
/// number or a guide name — so `evaluate_expression` handles both.
/// Coordinates are returned in the path's own coordinate space (before
/// scaling to the rendered box).
fn resolve_pt(pt : @xml.Element, ctx : GuideContext) -> (Double, Double) {
  let x = match attr_value(pt, "x") {
    Some(v) => evaluate_expression(v, ctx)
    None => 0.0
  }
  let y = match attr_value(pt, "y") {
    Some(v) => evaluate_expression(v, ctx)
    None => 0.0
  }
  (x, y)
}

///|
/// Render a `<a:custGeom>` element (§20.1.9.8) to an SVG path-data
/// string.  Walks `<a:pathLst>/<a:path>` and translates each path
/// command into its SVG equivalent:
///
/// | OOXML (§20.1.9)        | SVG path command            |
/// |------------------------|-----------------------------|
/// | `<a:moveTo>`           | `M x y`                     |
/// | `<a:lnTo>`             | `L x y`                     |
/// | `<a:cubicBezTo>` (3pt) | `C x1 y1 x2 y2 x y`         |
/// | `<a:quadBezTo>` (2pt)  | `Q x1 y1 x y`               |
/// | `<a:arcTo>`            | `A rx ry 0 laf sf ex ey`    |
/// | `<a:close>`            | `Z`                         |
///
/// Point coordinates are resolved through the shape guide engine
/// (`<a:gdLst>` + `<a:avLst>`), then scaled from each path's declared
/// `w`/`h` coordinate space into the rendered `width`×`height` box.
///
/// Returns `None` when no `<a:pathLst>` is present, mirroring
/// `render_preset_geometry`'s unknown-geometry contract so the caller
/// falls back to a bounding rect.
pub fn render_custom_geometry(
  cust_geom : @xml.Element,
  width : Double,
  height : Double,
) -> String? {
  let path_lst = match first_child_named(cust_geom, "pathLst") {
    Some(p) => p
    None => return None
  }
  let avs = parse_adjust_values(first_child_named(cust_geom, "avLst"))
  let guides = parse_geom_guides(first_child_named(cust_geom, "gdLst"))
  let out = StringBuilder::new()
  let mut emitted = false
  for path_child in path_lst.children {
    let path = match path_child {
      Element(p) => if p.name.local_name == "path" { p } else { continue }
      _ => continue
    }
    // Each `<a:path>` declares the coordinate space its points live in
    // via `w`/`h`; absent (or zero) means the points are already in the
    // rendered space, so the scale collapses to 1.
    let path_w = match attr_value(path, "w") {
      Some(v) =>
        try @string.parse_double(v) catch {
          _ => 0.0
        } noraise {
          d => d
        }
      None => 0.0
    }
    let path_h = match attr_value(path, "h") {
      Some(v) =>
        try @string.parse_double(v) catch {
          _ => 0.0
        } noraise {
          d => d
        }
      None => 0.0
    }
    let sx = if path_w > 0.0 { width / path_w } else { 1.0 }
    let sy = if path_h > 0.0 { height / path_h } else { 1.0 }
    // Guide built-ins (`w`,`h`,`hc`,…) are derived from this path's
    // coordinate space so that guide-driven coordinates land in the
    // same units as the literal points before scaling.
    let ctx_w = if path_w > 0.0 { path_w } else { width }
    let ctx_h = if path_h > 0.0 { path_h } else { height }
    let ctx = create_guide_context(ctx_w, ctx_h, adjust_values=avs)
    evaluate_guides(guides, ctx)
    // The "current point" — arcTo needs it to derive the arc centre.
    let mut cur_x = 0.0
    let mut cur_y = 0.0
    for cmd_node in path.children {
      let cmd = match cmd_node {
        Element(c) => c
        _ => continue
      }
      match cmd.name.local_name {
        "moveTo" =>
          match first_child_named(cmd, "pt") {
            Some(pt) => {
              let (x, y) = resolve_pt(pt, ctx)
              cur_x = x
              cur_y = y
              if emitted {
                out.write_string(" ")
              }
              out.write_string("M " + fmt_coord(x * sx) + " " + fmt_coord(y * sy))
              emitted = true
            }
            None => ()
          }
        "lnTo" =>
          match first_child_named(cmd, "pt") {
            Some(pt) => {
              let (x, y) = resolve_pt(pt, ctx)
              cur_x = x
              cur_y = y
              out.write_string(" L " + fmt_coord(x * sx) + " " + fmt_coord(y * sy))
            }
            None => ()
          }
        "cubicBezTo" => {
          let pts = pt_children(cmd, ctx)
          if pts.length() == 3 {
            let (x1, y1) = pts[0]
            let (x2, y2) = pts[1]
            let (x3, y3) = pts[2]
            cur_x = x3
            cur_y = y3
            out.write_string(
              " C " +
              fmt_coord(x1 * sx) + " " + fmt_coord(y1 * sy) + " " +
              fmt_coord(x2 * sx) + " " + fmt_coord(y2 * sy) + " " +
              fmt_coord(x3 * sx) + " " + fmt_coord(y3 * sy),
            )
          }
        }
        "quadBezTo" => {
          let pts = pt_children(cmd, ctx)
          if pts.length() == 2 {
            let (x1, y1) = pts[0]
            let (x2, y2) = pts[1]
            cur_x = x2
            cur_y = y2
            out.write_string(
              " Q " +
              fmt_coord(x1 * sx) + " " + fmt_coord(y1 * sy) + " " +
              fmt_coord(x2 * sx) + " " + fmt_coord(y2 * sy),
            )
          }
        }
        "arcTo" => {
          let (seg, ex, ey) = arc_to_svg(cmd, ctx, cur_x, cur_y, sx, sy)
          cur_x = ex
          cur_y = ey
          out.write_string(seg)
        }
        "close" => out.write_string(" Z")
        _ => ()
      }
    }
  }
  if emitted {
    Some(out.to_string())
  } else {
    None
  }
}

///|
/// Resolve every `<a:pt>` child of a path command into a list of
/// path-space (x, y) coordinates, in document order.  Used by the
/// multi-point commands `cubicBezTo` (3) and `quadBezTo` (2).
fn pt_children(
  cmd : @xml.Element,
  ctx : GuideContext,
) -> Array[(Double, Double)] {
  let pts : Array[(Double, Double)] = []
  for child in cmd.children {
    match child {
      Element(p) => if p.name.local_name == "pt" { pts.push(resolve_pt(p, ctx)) }
      _ => ()
    }
  }
  pts
}

///|
/// Translate an `<a:arcTo wR hR stAng swAng>` command (§20.1.9.3) into
/// an SVG elliptical-arc segment, given the current point `(cur_x,
/// cur_y)` in path space and the path→box scale `(sx, sy)`.
///
/// OOXML arc semantics: the arc lies on an axis-aligned ellipse with
/// radii `wR` (x) and `hR` (y).  `stAng` is the start angle and `swAng`
/// the swept angle, both in 1/60000 degree.  The ellipse centre is
/// fixed by requiring the arc to *start* at the current point:
///   `cx = cur_x − wR·cos(stAng)`, `cy = cur_y − hR·sin(stAng)`.
/// The end point is `(cx + wR·cos(stAng+swAng), cy + hR·sin(stAng+swAng))`.
///
/// SVG mapping: `A rx ry 0 large-arc-flag sweep-flag ex ey` where
/// `rx=wR·sx`, `ry=hR·sy`.  Both OOXML and SVG use a y-down coordinate
/// system with angles increasing clockwise, so a positive `swAng` maps
/// to `sweep-flag = 1`; `large-arc-flag = 1` when `|swAng| > 180°`.
///
/// Returns the SVG path segment string plus the unscaled end point
/// (so the caller can update its current-point tracker).
fn arc_to_svg(
  cmd : @xml.Element,
  ctx : GuideContext,
  cur_x : Double,
  cur_y : Double,
  sx : Double,
  sy : Double,
) -> (String, Double, Double) {
  fn ang(name : String) -> Double {
    match attr_value(cmd, name) {
      Some(v) => evaluate_expression(v, ctx)
      None => 0.0
    }
  }

  let w_r = ang("wR")
  let h_r = ang("hR")
  // 1/60000 degree → radians.
  let deg_per_unit = 1.0 / 60000.0
  let to_rad = 3.141592653589793 / 180.0
  let st_ang_u = ang("stAng")
  let sw_ang_u = ang("swAng")
  let st = st_ang_u * deg_per_unit * to_rad
  let sw = sw_ang_u * deg_per_unit * to_rad
  // Centre fixed so the arc starts at the current point.
  let cx = cur_x - w_r * @math.cos(st)
  let cy = cur_y - h_r * @math.sin(st)
  let end = st + sw
  let ex = cx + w_r * @math.cos(end)
  let ey = cy + h_r * @math.sin(end)
  // |swAng| > 180° (10800000 units) selects the large arc.
  let large = if sw_ang_u > 10800000.0 || sw_ang_u < -10800000.0 {
    "1"
  } else {
    "0"
  }
  // y-down clockwise: positive sweep → SVG sweep-flag 1.
  let sweep = if sw_ang_u >= 0.0 { "1" } else { "0" }
  let seg =
    " A " +
    fmt_coord(w_r * sx) + " " + fmt_coord(h_r * sy) + " 0 " +
    large + " " + sweep + " " +
    fmt_coord(ex * sx) + " " + fmt_coord(ey * sy)
  (seg, ex, ey)
}

///|
/// One sub-path of a multi-fill preset.  `path` is the SVG path-data
/// string; `fill_mod` is a relative luminosity offset applied to the
/// base fill colour: 0.0 = same fill, +0.25 = 25 % lighter, −0.25 =
/// 25 % darker.  3D presets (cube, bevel, can, cylinder) use this to
/// give their lit / shaded faces.
pub struct PresetLayer {
  path : String
  fill_mod : Double
}

///|
/// Multi-path counterpart of `render_preset_geometry`.  Returns one
/// or more `PresetLayer`s — most presets return exactly one (mod 0),
/// but 3D / shaded presets return their constituent faces with
/// per-face luminosity offsets so the caller can paint them with
/// derived shades of the source fill.  Returns `None` when the
/// preset name is unknown (mirrors `render_preset_geometry`).
pub fn render_preset_geometry_layered(
  prst_geom : @xml.Element,
  width : Double,
  height : Double,
) -> Array[PresetLayer]? {
  let prst = match attr_value(prst_geom, "prst") {
    Some(p) => p
    None => return None
  }
  let avs = parse_adjust_values(first_child_named(prst_geom, "avLst"))
  let ctx = create_guide_context(width, height, adjust_values=avs)
  match preset_shape_dispatch_layered(prst, width, height, ctx) {
    Some(layers) => Some(layers)
    None =>
      // Fall back to the single-path dispatcher and wrap it in a
      // one-layer result so the caller can use the layered API
      // uniformly for every preset, with 3D / shaded presets simply
      // returning multiple entries.
      match preset_shape_dispatch(prst, width, height, ctx) {
        Some(d) => Some([{ path: d, fill_mod: 0.0 }])
        None => None
      }
  }
}

///|
/// Multi-path dispatcher — handles only the presets whose canonical
/// PowerPoint render is a STACK of fills (a 3D / shaded
/// preset).  Returns `None` for every other preset so the caller can
/// fall through to the standard single-path dispatcher.
fn preset_shape_dispatch_layered(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer]? {
  match preset {
    "can" => Some(preset_can_layers(w, h, ctx))
    "cube" => Some(preset_cube_layers(w, h))
    "bevel" => Some(preset_bevel_layers(w, h, ctx))
    // The flowchart "magnetic" symbols are 3D cylinders viewed from
    // different sides — same body+cap layering as a generic `can`,
    // with the cap height and orientation set per shape.
    "flowChartMagneticDisk" => Some(preset_can_layers_with_cap(w, h, 0.15))
    "flowChartMagneticDrum" => Some(preset_drum_layers(w, h, 0.15))
    "flowChartMagneticTape" => Some(preset_can_layers_with_cap(w, h, 0.15))
    // Curved arrows: main spec body + `darkenLess` 3D ribbon overlay.
    "curvedRightArrow" => Some(curved_right_arrow_layers(w, h, ctx))
    "curvedLeftArrow" => Some(curved_left_arrow_layers(w, h, ctx))
    "curvedUpArrow" => Some(curved_up_arrow_layers(w, h, ctx))
    "curvedDownArrow" => Some(curved_down_arrow_layers(w, h, ctx))
    _ => None
  }
}

///|
/// `can`-like layering with an explicit cap-height fraction.  Used
/// by the flowchart "magnetic" cylinder family.
fn preset_can_layers_with_cap(
  w : Double,
  h : Double,
  cap_frac : Double,
) -> Array[PresetLayer] {
  let cap_h = cap_frac * h
  let ry = cap_h / 2.0
  let rx = w / 2.0
  let body = "M 0 " +
    fmt(ry) +
    " L 0 " +
    fmt(h - ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 0 " +
    fmt(w) +
    " " +
    fmt(h - ry) +
    " L " +
    fmt(w) +
    " " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 0 " +
    fmt(ry) +
    " Z"
  let cap = "M 0 " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 " +
    fmt(w) +
    " " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 0 " +
    fmt(ry) +
    " Z"
  [{ path: body, fill_mod: 0.0 }, { path: cap, fill_mod: 0.20 }]
}

///|
/// Horizontal cylinder (drum) — same as can but lying on its side.
/// The "cap" here is the round LEFT face (an ellipse).
fn preset_drum_layers(
  w : Double,
  h : Double,
  cap_frac : Double,
) -> Array[PresetLayer] {
  let cap_w = cap_frac * w
  let rx = cap_w / 2.0
  let ry = h / 2.0
  // Body: top edge, right cap arc, bottom edge, left arc back.
  let body = "M " +
    fmt(rx) +
    " 0 L " +
    fmt(w - rx) +
    " 0 A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 " +
    fmt(w - rx) +
    " " +
    fmt(h) +
    " L " +
    fmt(rx) +
    " " +
    fmt(h) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 " +
    fmt(rx) +
    " 0 Z"
  // Left face — a full vertical ellipse.
  let cap = "M " +
    fmt(rx) +
    " 0 A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 0 " +
    fmt(rx) +
    " " +
    fmt(h) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 0 " +
    fmt(rx) +
    " 0 Z"
  [{ path: body, fill_mod: 0.0 }, { path: cap, fill_mod: 0.20 }]
}

///|
/// `can` preset — a cylinder, viewed from above-side.  Layers:
///   1. body (the side rectangle with rounded top + bottom arcs),
///      painted at base luminosity
///   2. top elliptical cap, painted lighter (`+0.20` lumMod)
/// The `adj` (default 25000) is the cap height as a fraction of `h`.
fn preset_can_layers(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer] {
  let cap_h = ctx.get("adj").unwrap_or(25000.0) / 100000.0 * h
  let ry = cap_h / 2.0
  let rx = w / 2.0
  // BODY — the cylinder side: left edge, arc across the bottom,
  // right edge, arc across the top back to the start.  The top arc
  // is concave-down (sweep 1) so the body's filled region matches a
  // 2D projection of the cylinder side, not a flat-topped rect.
  let body = "M 0 " +
    fmt(ry) +
    " L 0 " +
    fmt(h - ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 0 " +
    fmt(w) +
    " " +
    fmt(h - ry) +
    " L " +
    fmt(w) +
    " " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 0 " +
    fmt(ry) +
    " Z"
  // TOP CAP — a full ellipse at `y = ry` (centred on the body top).
  // Drawn as two arc-tos so it closes cleanly.
  let cap = "M 0 " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 " +
    fmt(w) +
    " " +
    fmt(ry) +
    " A " +
    fmt(rx) +
    " " +
    fmt(ry) +
    " 0 0 1 0 " +
    fmt(ry) +
    " Z"
  [{ path: body, fill_mod: 0.0 }, { path: cap, fill_mod: 0.20 }]
}

///|
/// `cube` preset — an isometric box, three visible faces.
///   1. FRONT face (largest, at base luminosity)
///   2. TOP face (lighter, +0.20)
///   3. RIGHT face (darker, −0.20)
/// The depth (the diagonal offset of the back face) is fixed at 25 %
/// of the shorter side, matching the standard PowerPoint cube.
fn preset_cube_layers(w : Double, h : Double) -> Array[PresetLayer] {
  let depth = (if w < h { w } else { h }) * 0.25
  // Front face: a rectangle from (0, depth) to (w-depth, h).
  let front = "M 0 " +
    fmt(depth) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(depth) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(h) +
    " L 0 " +
    fmt(h) +
    " Z"
  // Top face: parallelogram from (0,depth) → (depth, 0) → (w, 0) →
  // (w-depth, depth).
  let top = "M 0 " +
    fmt(depth) +
    " L " +
    fmt(depth) +
    " 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w - depth) +
    " " +
    fmt(depth) +
    " Z"
  // Right face: parallelogram from (w-depth, depth) → (w, 0) →
  // (w, h-depth) → (w-depth, h).
  let right = "M " +
    fmt(w - depth) +
    " " +
    fmt(depth) +
    " L " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(h - depth) +
    " L " +
    fmt(w - depth) +
    " " +
    fmt(h) +
    " Z"
  [
    { path: front, fill_mod: 0.0 },
    { path: top, fill_mod: 0.20 },
    { path: right, fill_mod: -0.20 },
  ]
}

///|
/// `bevel` preset — a flat rectangular tile with four trapezoidal
/// bevel faces around an inset centre.  Layers:
///   1. CENTRE inset rectangle (base luminosity)
///   2. TOP trapezoid (lighter, +0.25)
///   3. RIGHT trapezoid (slightly darker, −0.10)
///   4. BOTTOM trapezoid (darker, −0.25)
///   5. LEFT trapezoid (slightly lighter, +0.10)
/// `adj` is the bevel width as a fraction of the shorter side
/// (default 12500 = 12.5 %).
fn preset_bevel_layers(
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> Array[PresetLayer] {
  let bw = ctx.get("adj").unwrap_or(12500.0) /
    100000.0 *
    (if w < h { w } else { h })
  // Centre inset.
  let centre = "M " +
    fmt(bw) +
    " " +
    fmt(bw) +
    " L " +
    fmt(w - bw) +
    " " +
    fmt(bw) +
    " L " +
    fmt(w - bw) +
    " " +
    fmt(h - bw) +
    " L " +
    fmt(bw) +
    " " +
    fmt(h - bw) +
    " Z"
  // Top bevel.
  let top = "M 0 0 L " +
    fmt(w) +
    " 0 L " +
    fmt(w - bw) +
    " " +
    fmt(bw) +
    " L " +
    fmt(bw) +
    " " +
    fmt(bw) +
    " Z"
  // Right bevel.
  let right = "M " +
    fmt(w) +
    " 0 L " +
    fmt(w) +
    " " +
    fmt(h) +
    " L " +
    fmt(w - bw) +
    " " +
    fmt(h - bw) +
    " L " +
    fmt(w - bw) +
    " " +
    fmt(bw) +
    " Z"
  // Bottom bevel.
  let bottom = "M 0 " +
    fmt(h) +
    " L " +
    fmt(bw) +
    " " +
    fmt(h - bw) +
    " L " +
    fmt(w - bw) +
    " " +
    fmt(h - bw) +
    " L " +
    fmt(w) +
    " " +
    fmt(h) +
    " Z"
  // Left bevel.
  let left = "M 0 0 L " +
    fmt(bw) +
    " " +
    fmt(bw) +
    " L " +
    fmt(bw) +
    " " +
    fmt(h - bw) +
    " L 0 " +
    fmt(h) +
    " Z"
  [
    { path: centre, fill_mod: 0.0 },
    { path: top, fill_mod: 0.25 },
    { path: right, fill_mod: -0.10 },
    { path: bottom, fill_mod: -0.25 },
    { path: left, fill_mod: 0.10 },
  ]
}

///|
/// Dispatcher: pick the path generator for `preset` and call it with
/// the prepared `GuideContext`.  Returns `None` only when the preset
/// name is unknown.  Each shape generator returns SVG `d=` body.
fn preset_shape_dispatch(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  // Order: most-frequent presets first.  The TS source uses an
  // object-literal map; in MoonBit a chained match keeps everything
  // inlinable and avoids closure allocations.
  match preset {
    "rect" => Some(preset_rect(w, h))
    "roundRect" => Some(preset_round_rect(w, h, ctx))
    "ellipse" => Some(preset_ellipse(w, h))
    "line" => Some(preset_line(w, h))
    "triangle" => Some(preset_triangle(w, h))
    "rtTriangle" => Some(preset_rt_triangle(w, h))
    "diamond" => Some(preset_diamond(w, h))
    "parallelogram" => Some(preset_parallelogram(w, h, ctx))
    "trapezoid" => Some(preset_trapezoid(w, h, ctx))
    "pentagon" => Some(preset_pentagon(w, h))
    "hexagon" => Some(preset_hexagon(w, h, ctx))
    "octagon" => Some(preset_octagon(w, h, ctx))
    "plus" => Some(preset_plus(w, h, ctx))
    // §20.1.10.56 / §20.4.1 — star presets' inner-radius ratios
    // come from `presetShapeDefinitions.xml`'s `<a:avLst>` default
    // adjusts.  `adj` is fixed by the preset definition; we
    // hard-code the resolved value below to avoid loading the
    // 800+ KB resource file at render time.
    //
    // The inner-radius RATIO is twice the spec `adj` fraction —
    // PowerPoint's adj-to-inner mapping for these presets is
    // `inner = 2 × adj/100000` — so e.g. star5's spec `adj=19098`
    // gives the classic inner_ratio 0.382, star8's `adj=37500`
    // gives the ribbon-edged 0.75, etc.  The old uniform 0.382 for
    // star8+ produced spike-heavy renders that did not match the
    // shallow-notched reference renderer's images.
    "star4" => Some(preset_star(w, h, 4, 0.250)) // adj=12500
    "star5" => Some(preset_star(w, h, 5, 0.382)) // adj=19098
    "star6" => Some(preset_star(w, h, 6, 0.577)) // adj=28868
    "star7" => Some(preset_star(w, h, 7, 0.692)) // adj=34601
    "star8" => Some(preset_star(w, h, 8, 0.750)) // adj=37500
    "star10" => Some(preset_star(w, h, 10, 0.851)) // adj=42533
    "star12" => Some(preset_star(w, h, 12, 0.750)) // adj=37500
    "star16" => Some(preset_star(w, h, 16, 0.750)) // adj=37500
    "star24" => Some(preset_star(w, h, 24, 0.750)) // adj=37500
    "star32" => Some(preset_star(w, h, 32, 0.750)) // adj=37500
    _ => preset_shape_dispatch_extended(preset, w, h, ctx)
  }
}

///|
/// Extension point: presets not in the basic dispatcher are looked
/// up via the per-category dispatcher functions below.  Each
/// category lives in its own `preset_shapes_*.mbt` file and exposes a
/// single `dispatch_<category>` entry point that returns
/// `Some(path)` for the presets it owns or `None` to defer.
fn preset_shape_dispatch_extended(
  preset : String,
  w : Double,
  h : Double,
  ctx : GuideContext,
) -> String? {
  match dispatch_arrow(preset, w, h, ctx) {
    Some(p) => return Some(p)
    None => ()
  }
  match dispatch_callout(preset, w, h, ctx) {
    Some(p) => return Some(p)
    None => ()
  }
  match dispatch_flowchart(preset, w, h, ctx) {
    Some(p) => return Some(p)
    None => ()
  }
  match dispatch_action_button(preset, w, h, ctx) {
    Some(p) => return Some(p)
    None => ()
  }
  match dispatch_misc(preset, w, h, ctx) {
    Some(p) => return Some(p)
    None => ()
  }
  None
}

// ============================================================================
// Basic preset implementations (lines from preset-shapes.ts:2483-2554)
// ============================================================================

///|
/// `rect` — full bounding rectangle.  preset-shapes.ts:2484
fn preset_rect(w : Double, h : Double) -> String {
  "M 0 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `ellipse` — bounding ellipse via two arc-to commands.
/// preset-shapes.ts:2486
fn preset_ellipse(w : Double, h : Double) -> String {
  let rx = w / 2.0
  let ry = h / 2.0
  "M " +
  fmt(rx) +
  " 0 A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(rx) +
  " " +
  fmt(h) +
  " A " +
  fmt(rx) +
  " " +
  fmt(ry) +
  " 0 1 1 " +
  fmt(rx) +
  " 0 Z"
}

///|
/// `roundRect` — rectangle with rounded corners.  Adj `adj` controls
/// the radius as a percentage of the shorter side.
/// preset-shapes.ts:2492
fn preset_round_rect(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(16667.0)
  let pct = if adj > 50000.0 { 50000.0 } else { adj }
  let ss = if w < h { w } else { h }
  let r = pct / 100000.0 * ss
  "M " +
  fmt(r) +
  " 0 L " +
  fmt(w - r) +
  " 0 Q " +
  fmt(w) +
  " 0 " +
  fmt(w) +
  " " +
  fmt(r) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - r) +
  " Q " +
  fmt(w) +
  " " +
  fmt(h) +
  " " +
  fmt(w - r) +
  " " +
  fmt(h) +
  " L " +
  fmt(r) +
  " " +
  fmt(h) +
  " Q 0 " +
  fmt(h) +
  " 0 " +
  fmt(h - r) +
  " L 0 " +
  fmt(r) +
  " Q 0 0 " +
  fmt(r) +
  " 0 Z"
}

///|
/// `line` — §20.1.10.56 a single straight line from the top-left
/// corner `(0, 0)` to the bottom-right corner `(w, h)` of the
/// bounding box.  The earlier "horizontal or vertical depending on
/// aspect ratio" rule was wrong: PowerPoint's `line` preset is
/// always a corner-to-corner diagonal — `straightConnector1` is the
/// straight horizontal/vertical case.
fn preset_line(w : Double, h : Double) -> String {
  "M 0 0 L " + fmt(w) + " " + fmt(h)
}

///|
/// `triangle` — isoceles triangle with apex at top centre.
/// preset-shapes.ts:2497
fn preset_triangle(w : Double, h : Double) -> String {
  "M " +
  fmt(w / 2.0) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `rtTriangle` — right triangle with legs on left and bottom.
/// preset-shapes.ts:2499
fn preset_rt_triangle(w : Double, h : Double) -> String {
  "M 0 0 L " + fmt(w) + " " + fmt(h) + " L 0 " + fmt(h) + " Z"
}

///|
/// `diamond` — rhombus with vertices at the four box midpoints.
/// preset-shapes.ts:2501
fn preset_diamond(w : Double, h : Double) -> String {
  "M " +
  fmt(w / 2.0) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w / 2.0) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `parallelogram` — §20.1.10.56, leans by `adj` percent of the
/// shorter side (`min(w,h)`), not of `w`.  Applying the offset to
/// `w` made wide parallelograms lean too much and tall ones not
/// enough; the geometric proportion is fixed in `min(w,h)`, matching
/// PowerPoint.
fn preset_parallelogram(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let ss = if w < h { w } else { h }
  let offset = adj / 100000.0 * ss
  "M " +
  fmt(offset) +
  " 0 L " +
  fmt(w) +
  " 0 L " +
  fmt(w - offset) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `trapezoid` — top edge is shorter than the bottom by 2 × offset.
/// `offset` is a fraction of the SHORTER side, mirroring
/// `parallelogram`'s geometric proportion.
/// preset-shapes.ts:2508
fn preset_trapezoid(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let ss = if w < h { w } else { h }
  let offset = adj / 100000.0 * ss
  "M " +
  fmt(offset) +
  " 0 L " +
  fmt(w - offset) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h) +
  " Z"
}

///|
/// `pentagon` — §20.1.10.56 regular upward pentagon that FILLS the
/// bounding box.
///
/// The OOXML `pentagon` preset is box-filling: its apex touches the
/// top edge, its two base vertices the bottom edge, and its widest
/// pair the side edges.  A regular pentagon is not vertically
/// symmetric, so a single circumscribed radius cannot do this — the
/// earlier `r = min(w,h)/2` centred pentagon left gaps and, on a
/// non-square box, did not fill the width.  Instead the unit regular
/// pentagon's own bounding box is mapped onto `[0,w]×[0,h]` by an
/// independent x/y scale.
fn preset_pentagon(w : Double, h : Double) -> String {
  // Unit regular pentagon vertices, apex first, at -90° + k·72°.
  let xs : Array[Double] = []
  let ys : Array[Double] = []
  for i in 0..<5 {
    let angle = (i.to_double() * 72.0 - 90.0) * 3.141592653589793 / 180.0
    xs.push(@math.cos(angle))
    ys.push(@math.sin(angle))
  }
  // Bounding box of the unit pentagon.
  let mut min_x = xs[0]
  let mut max_x = xs[0]
  let mut min_y = ys[0]
  let mut max_y = ys[0]
  for i in 1..<5 {
    if xs[i] < min_x {
      min_x = xs[i]
    }
    if xs[i] > max_x {
      max_x = xs[i]
    }
    if ys[i] < min_y {
      min_y = ys[i]
    }
    if ys[i] > max_y {
      max_y = ys[i]
    }
  }
  let span_x = max_x - min_x
  let span_y = max_y - min_y
  let buf = StringBuilder::new()
  for i in 0..<5 {
    // Map the unit-pentagon bbox onto the full [0,w]×[0,h] box.
    let x = (xs[i] - min_x) / span_x * w
    let y = (ys[i] - min_y) / span_y * h
    if i == 0 {
      buf.write_string("M " + fmt(x) + " " + fmt(y))
    } else {
      buf.write_string(" L " + fmt(x) + " " + fmt(y))
    }
  }
  buf.write_string(" Z")
  buf.to_string()
}

///|
/// `hexagon` — §20.1.10.56 flat-top hexagon, the notch controlled by
/// `adj`.
///
/// The horizontal inset of the two top / two bottom vertices is the
/// `adj` fraction of the SHORTER side (`min(w,h)`), not of `w`: a
/// regular hexagon's notch is a fixed geometric proportion, and
/// scaling it by `w` on a wide box pulled the top/bottom edges in too
/// far.  The side vertices stay on the box edges at `y = h/2`.
fn preset_hexagon(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let ss = if w < h { w } else { h }
  let offset = adj / 100000.0 * ss
  "M " +
  fmt(offset) +
  " 0 L " +
  fmt(w - offset) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(h / 2.0) +
  " L " +
  fmt(w - offset) +
  " " +
  fmt(h) +
  " L " +
  fmt(offset) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h / 2.0) +
  " Z"
}

///|
/// `octagon` — eight-sided shape, corner inset controlled by `adj`.
/// preset-shapes.ts:2532
fn preset_octagon(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(29289.0)
  let ss = if w < h { w } else { h }
  let offset = adj / 100000.0 * ss
  "M " +
  fmt(offset) +
  " 0 L " +
  fmt(w - offset) +
  " 0 L " +
  fmt(w) +
  " " +
  fmt(offset) +
  " L " +
  fmt(w) +
  " " +
  fmt(h - offset) +
  " L " +
  fmt(w - offset) +
  " " +
  fmt(h) +
  " L " +
  fmt(offset) +
  " " +
  fmt(h) +
  " L 0 " +
  fmt(h - offset) +
  " L 0 " +
  fmt(offset) +
  " Z"
}

///|
/// `plus` — cross shape, arm width controlled by `adj`.
/// preset-shapes.ts:2548
fn preset_plus(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let arm = adj / 100000.0
  let x1 = w * arm
  let x2 = w * (1.0 - arm)
  let y1 = h * arm
  let y2 = h * (1.0 - arm)
  "M " +
  fmt(x1) +
  " 0 L " +
  fmt(x2) +
  " 0 L " +
  fmt(x2) +
  " " +
  fmt(y1) +
  " L " +
  fmt(w) +
  " " +
  fmt(y1) +
  " L " +
  fmt(w) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(y2) +
  " L " +
  fmt(x2) +
  " " +
  fmt(h) +
  " L " +
  fmt(x1) +
  " " +
  fmt(h) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y2) +
  " L 0 " +
  fmt(y2) +
  " L 0 " +
  fmt(y1) +
  " L " +
  fmt(x1) +
  " " +
  fmt(y1) +
  " Z"
}

///|
/// `starN` — §20.1.10.56 N-pointed star that FILLS the bounding box.
/// `inner_ratio` controls how deep the troughs go relative to the
/// outer radius.
///
/// The OOXML star presets are box-filling: the outer points reach
/// the box edges.  An odd-pointed star is not vertically symmetric,
/// so — like `pentagon` — a single circumscribed radius leaves the
/// star inset; instead the unit star's own bounding box is mapped
/// onto `[0,w]×[0,h]` by an independent x/y scale.
fn preset_star(
  w : Double,
  h : Double,
  points : Int,
  inner_ratio : Double,
) -> String {
  let total = points * 2
  let step = 2.0 * 3.141592653589793 / total.to_double()
  // Unit star vertices (outer radius 1, inner radius `inner_ratio`),
  // first outer point at the top (-90°).
  let xs : Array[Double] = []
  let ys : Array[Double] = []
  for i in 0..<total {
    let r = if i % 2 == 0 { 1.0 } else { inner_ratio }
    let angle = i.to_double() * step - 3.141592653589793 / 2.0
    xs.push(r * @math.cos(angle))
    ys.push(r * @math.sin(angle))
  }
  // The unit star's bounding box is determined by the OUTER points
  // only, so map that bbox onto the full [0,w]×[0,h] box.
  let mut min_x = xs[0]
  let mut max_x = xs[0]
  let mut min_y = ys[0]
  let mut max_y = ys[0]
  for i in 1..<total {
    if xs[i] < min_x {
      min_x = xs[i]
    }
    if xs[i] > max_x {
      max_x = xs[i]
    }
    if ys[i] < min_y {
      min_y = ys[i]
    }
    if ys[i] > max_y {
      max_y = ys[i]
    }
  }
  let span_x = max_x - min_x
  let span_y = max_y - min_y
  let buf = StringBuilder::new()
  for i in 0..<total {
    let x = (xs[i] - min_x) / span_x * w
    let y = (ys[i] - min_y) / span_y * h
    if i == 0 {
      buf.write_string("M " + fmt(x) + " " + fmt(y))
    } else {
      buf.write_string(" L " + fmt(x) + " " + fmt(y))
    }
  }
  buf.write_string(" Z")
  buf.to_string()
}
