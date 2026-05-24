// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedConnector4`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `curvedConnector4` — an S-curve connector built from
/// three cubic Bézier segments sweeping from the top-left corner to
/// the bottom-right corner with two inflection points.
///
/// Spec geometry (adj1/adj2 default 50000): `x2 = w·adj1/100000`,
/// `x1 = (l+x2)/2`, `x3 = (r+x2)/2`, `x4 = (x2+x3)/2`,
/// `x5 = (x3+r)/2`; `y4 = h·adj2/100000`, `y1 = (t+y4)/2`,
/// `y2 = (t+y1)/2`, `y3 = (y1+y4)/2`, `y5 = (b+y4)/2`. The path
/// (`fill="none"`) is `moveTo (l, t)` →
/// `cubicBezTo (x1, t) (x2, y2) (x2, y1)` →
/// `cubicBezTo (x2, y3) (x4, y4) (x3, y4)` →
/// `cubicBezTo (x5, y4) (r, y5) (r, b)`, an open curve (no `close`).
pub fn build_curved_connector4(width : Int, height : Int) -> ShapeGeometry {
  // adj1/adj2 defaults 50000.
  let x2 = percent(width, 50000)
  let x1 = x2 / 2
  let x3 = (width + x2) / 2
  let x4 = (x2 + x3) / 2
  let x5 = (x3 + width) / 2
  let y4 = percent(height, 50000)
  let y1 = y4 / 2
  let y2 = y1 / 2
  let y3 = (y1 + y4) / 2
  let y5 = (height + y4) / 2
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    CurveTo(x1, 0, x2, y2, x2, y1),
    CurveTo(x2, y3, x4, y4, x3, y4),
    CurveTo(x5, y4, width, y5, width, height),
  ]
  { commands, width, height }
}
