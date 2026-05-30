// ECMA-376 Part 1 §20.1.9.18 — render a faithful preset-shape geometry
// as an SVG path `d` string. Shared entry point so any renderer (the
// SpreadsheetML and PresentationML viewers) can obtain the spec
// geometry as SVG without re-implementing per-shape paths.

///|
/// Materialise the faithful geometry of preset shape `prst` on the
/// `width × height` box (applying any `avLst` adjustments) and return it
/// as an SVG path `d` string.  Returns `None` for an unknown preset name
/// or one whose dedicated generator is not yet authored (`supports` is
/// false), so a caller can fall back to its own handling.
pub fn render_shape_path(
  prst : String,
  width : Int,
  height : Int,
  adjustments : Array[Adjustment],
) -> String? {
  guard (try? PresetShape::from_attr(prst)) is Ok(shape) else { return None }
  if !supports(shape) {
    return None
  }
  Some(
    geometry_to_svg_path(
      build_geometry_with_adjustments(shape, width, height, adjustments),
    ),
  )
}

///|
/// Convert a `ShapeGeometry` command list into an SVG path `d` string.
fn geometry_to_svg_path(geometry : ShapeGeometry) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  fn sp() -> Unit {
    if !first {
      buf.write_string(" ")
    }
    first = false
  }

  fn num(n : Int) -> Unit {
    buf.write_string(n.to_string())
    buf.write_string(" ")
  }

  for cmd in geometry.commands {
    sp()
    match cmd {
      MoveTo(x, y) => {
        buf.write_string("M ")
        num(x)
        buf.write_string(y.to_string())
      }
      LineTo(x, y) => {
        buf.write_string("L ")
        num(x)
        buf.write_string(y.to_string())
      }
      QuadTo(cx, cy, x, y) => {
        buf.write_string("Q ")
        num(cx)
        num(cy)
        num(x)
        buf.write_string(y.to_string())
      }
      CurveTo(c1x, c1y, c2x, c2y, x, y) => {
        buf.write_string("C ")
        num(c1x)
        num(c1y)
        num(c2x)
        num(c2y)
        num(x)
        buf.write_string(y.to_string())
      }
      ArcTo(rx, ry, rot, large_arc, sweep, x, y) => {
        buf.write_string("A ")
        num(rx)
        num(ry)
        num(rot)
        buf.write_string(if large_arc { "1" } else { "0" })
        buf.write_string(" ")
        buf.write_string(if sweep { "1" } else { "0" })
        buf.write_string(" ")
        num(x)
        buf.write_string(y.to_string())
      }
      ClosePath => buf.write_string("Z")
    }
  }
  buf.to_string()
}
