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
                fmla.substring(start=4)
              } else {
                fmla
              }
              let v = match
                (try? @strconv.parse_double(body.trim_space().to_string())) {
                Ok(d) => d
                Err(_) => 0.0
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
    // 800+ KB resource file at render time.  Each comment notes
    // the corresponding spec table row.
    "star4" => Some(preset_star(w, h, 4, 0.382)) // §20.4.1 star4 adj=38197
    "star5" => Some(preset_star(w, h, 5, 0.382)) // §20.4.1 star5 adj=38197
    "star6" => Some(preset_star(w, h, 6, 0.5)) // §20.4.1 star6 adj=50000
    "star7" => Some(preset_star(w, h, 7, 0.382)) // §20.4.1 star7 adj=38197
    "star8" => Some(preset_star(w, h, 8, 0.382)) // §20.4.1 star8 adj=38197
    "star10" => Some(preset_star(w, h, 10, 0.382)) // §20.4.1 star10 adj=38197
    "star12" => Some(preset_star(w, h, 12, 0.382)) // §20.4.1 star12 adj=38197
    "star16" => Some(preset_star(w, h, 16, 0.382)) // §20.4.1 star16 adj=38197
    "star24" => Some(preset_star(w, h, 24, 0.382)) // §20.4.1 star24 adj=38197
    "star32" => Some(preset_star(w, h, 32, 0.382)) // §20.4.1 star32 adj=38197
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
/// `line` — diagonal/orthogonal line preset.  preset-shapes.ts:2837
fn preset_line(w : Double, h : Double) -> String {
  if h > w {
    "M " + fmt(w / 2.0) + " 0 L " + fmt(w / 2.0) + " " + fmt(h)
  } else {
    "M 0 " + fmt(h / 2.0) + " L " + fmt(w) + " " + fmt(h / 2.0)
  }
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
/// `parallelogram` — leans `adj` percent of the width.
/// preset-shapes.ts:2503
fn preset_parallelogram(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let offset = adj / 100000.0 * w
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
/// preset-shapes.ts:2508
fn preset_trapezoid(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let offset = adj / 100000.0 * w
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
/// `pentagon` — regular pentagon centred in the box.
/// preset-shapes.ts:2513
fn preset_pentagon(w : Double, h : Double) -> String {
  let cx = w / 2.0
  let cy = h / 2.0
  let ss = if w < h { w } else { h }
  let r = ss / 2.0
  let buf = StringBuilder::new()
  for i in 0..<5 {
    let angle = (i.to_double() * 72.0 - 90.0) * 3.141592653589793 / 180.0
    let x = cx + r * @math.cos(angle)
    let y = cy + r * @math.sin(angle)
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
/// `hexagon` — flat-top hexagon, sides controlled by `adj`.
/// preset-shapes.ts:2527
fn preset_hexagon(w : Double, h : Double, ctx : GuideContext) -> String {
  let adj = ctx.get("adj").unwrap_or(25000.0)
  let offset = adj / 100000.0 * w
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
/// `starN` — N-pointed star inscribed in the box.  `inner_ratio`
/// controls how deep the troughs go relative to the bounding radius.
/// Mirrors `generateStar` in preset-shapes.ts (referenced from 2537+).
fn preset_star(
  w : Double,
  h : Double,
  points : Int,
  inner_ratio : Double,
) -> String {
  let cx = w / 2.0
  let cy = h / 2.0
  let outer_r = if w < h { w / 2.0 } else { h / 2.0 }
  let inner_r = outer_r * inner_ratio
  let total = points * 2
  let buf = StringBuilder::new()
  let step = 2.0 * 3.141592653589793 / total.to_double()
  for i in 0..<total {
    let r = if i % 2 == 0 { outer_r } else { inner_r }
    let angle = i.to_double() * step - 3.141592653589793 / 2.0
    let x = cx + r * @math.cos(angle)
    let y = cy + r * @math.sin(angle)
    if i == 0 {
      buf.write_string("M " + fmt(x) + " " + fmt(y))
    } else {
      buf.write_string(" L " + fmt(x) + " " + fmt(y))
    }
  }
  buf.write_string(" Z")
  buf.to_string()
}
