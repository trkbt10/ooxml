// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedConnector5`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `curvedConnector5` — an S-curve connector built from
/// four cubic Bézier segments sweeping from the top-left corner to
/// the bottom-right corner with three inflection points.
///
/// Spec geometry (adj1/adj2/adj3 default 50000): `x3 = w·adj1/100000`,
/// `x6 = w·adj3/100000`, `x1 = (x3+x6)/2`, `x2 = (l+x3)/2`,
/// `x4 = (x3+x1)/2`, `x5 = (x6+x1)/2`, `x7 = (x6+r)/2`;
/// `y4 = h·adj2/100000`, `y1 = (t+y4)/2`, `y2 = (t+y1)/2`,
/// `y3 = (y1+y4)/2`, `y5 = (b+y4)/2`, `y6 = (y5+y4)/2`,
/// `y7 = (y5+b)/2`. The path (`fill="none"`) is `moveTo (l, t)` →
/// `cubicBezTo (x2, t) (x3, y2) (x3, y1)` →
/// `cubicBezTo (x3, y3) (x4, y4) (x1, y4)` →
/// `cubicBezTo (x5, y4) (x6, y6) (x6, y5)` →
/// `cubicBezTo (x6, y7) (x7, b) (r, b)`, an open curve (no `close`).
pub fn build_curved_connector5(width : Int, height : Int) -> ShapeGeometry {
  // adj1/adj2/adj3 defaults 50000.
  let x3 = percent(width, 50000)
  let x6 = percent(width, 50000)
  let x1 = (x3 + x6) / 2
  let x2 = x3 / 2
  let x4 = (x3 + x1) / 2
  let x5 = (x6 + x1) / 2
  let x7 = (x6 + width) / 2
  let y4 = percent(height, 50000)
  let y1 = y4 / 2
  let y2 = y1 / 2
  let y3 = (y1 + y4) / 2
  let y5 = (height + y4) / 2
  let y6 = (y5 + y4) / 2
  let y7 = (y5 + height) / 2
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    CurveTo(x2, 0, x3, y2, x3, y1),
    CurveTo(x3, y3, x4, y4, x1, y4),
    CurveTo(x5, y4, x6, y6, x6, y5),
    CurveTo(x6, y7, x7, height, width, height),
  ]
  { commands, width, height }
}
