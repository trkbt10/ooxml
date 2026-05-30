// §20.1.10.55 ST_ShapeType — SVG path-data generator that dispatches
// every spec-enumerated preset through the shared
// `@preset_geometry.build_geometry` API.
//
// The previous SML drawing path matched only 7 presets (rect /
// ellipse / line / triangle / rightTriangle / diamond) and emitted
// the empty string for everything else.  This file routes the full
// ST_ShapeType enumeration through the typed dispatcher in
// `drawing_ml/preset_geometry`, which materialises a `ShapeGeometry`
// of resolved PathCommand instructions, then linearises that into
// an SVG `d=` body.

///|
/// Render any §20.1.10.55 ST_ShapeType preset to an SVG `d=` body
/// scaled into the rectangle `(0, 0, w, h)`.  Returns `Some(d)`
/// for every enumerated preset, or `None` when the preset name is
/// not in ST_ShapeType (schema violation).
///
/// `adjustments` carries the decoded §20.1.9.5 `avLst` guide overrides
/// (`@preset_geometry.read_adjustments_lenient`). When empty — or for
/// a preset whose builder is not yet adjustment-aware — the geometry
/// is identical to the spec-default path, so the no-override case never
/// changes.
pub fn render_preset_shape_d(
  prst : String,
  w : Double,
  h : Double,
  adjustments~ : Array[@preset_geometry.Adjustment] = [],
) -> String? {
  if w <= 0.0 || h <= 0.0 {
    return None
  }
  let shape = try @preset_geometry.PresetShape::from_attr(prst) catch {
    // Schema violation — `prst` is outside ST_ShapeType.  Surface
    // None so the caller can emit a spec-anchored metadata fallback.
    _ => return None
  } noraise {
    s => s
  }
  // build_geometry_with_adjustments generates the path in a
  // `[0, w_i] × [0, h_i]` integer frame, applying the document's
  // §20.1.9.11 adjustment guides; we feed in our pixel dimensions
  // rounded to the nearest integer so the output requires no further
  // scaling. Sub-pixel precision is preserved by the SVG renderer's
  // float coordinate parser when the viewer rescales the bounding box.
  let geometry = @preset_geometry.build_geometry_with_adjustments(
    shape,
    w.to_int(),
    h.to_int(),
    adjustments,
  )
  Some(shape_geometry_to_svg_d(geometry))
}

///|
/// Linearise an array of `PathCommand` instructions into an SVG
/// `d=` body using single-letter command names.
fn shape_geometry_to_svg_d(geometry : @preset_geometry.ShapeGeometry) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for cmd in geometry.commands {
    if !first {
      buf.write_string(" ")
    }
    first = false
    match cmd {
      @preset_geometry.MoveTo(x, y) => {
        buf.write_string("M ")
        buf.write_string(x.to_string())
        buf.write_string(" ")
        buf.write_string(y.to_string())
      }
      @preset_geometry.LineTo(x, y) => {
        buf.write_string("L ")
        buf.write_string(x.to_string())
        buf.write_string(" ")
        buf.write_string(y.to_string())
      }
      @preset_geometry.QuadTo(cx, cy, x, y) => {
        buf.write_string("Q ")
        buf.write_string(cx.to_string())
        buf.write_string(" ")
        buf.write_string(cy.to_string())
        buf.write_string(" ")
        buf.write_string(x.to_string())
        buf.write_string(" ")
        buf.write_string(y.to_string())
      }
      @preset_geometry.CurveTo(c1x, c1y, c2x, c2y, x, y) => {
        buf.write_string("C ")
        buf.write_string(c1x.to_string())
        buf.write_string(" ")
        buf.write_string(c1y.to_string())
        buf.write_string(" ")
        buf.write_string(c2x.to_string())
        buf.write_string(" ")
        buf.write_string(c2y.to_string())
        buf.write_string(" ")
        buf.write_string(x.to_string())
        buf.write_string(" ")
        buf.write_string(y.to_string())
      }
      @preset_geometry.ArcTo(rx, ry, x_axis_rotation, large_arc, sweep, x, y) => {
        buf.write_string("A ")
        buf.write_string(rx.to_string())
        buf.write_string(" ")
        buf.write_string(ry.to_string())
        buf.write_string(" ")
        buf.write_string(x_axis_rotation.to_string())
        buf.write_string(" ")
        buf.write_string(if large_arc { "1" } else { "0" })
        buf.write_string(" ")
        buf.write_string(if sweep { "1" } else { "0" })
        buf.write_string(" ")
        buf.write_string(x.to_string())
        buf.write_string(" ")
        buf.write_string(y.to_string())
      }
      @preset_geometry.ClosePath => buf.write_string("Z")
    }
  }
  buf.to_string()
}
