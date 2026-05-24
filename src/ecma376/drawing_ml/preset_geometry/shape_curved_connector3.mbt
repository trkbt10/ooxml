// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedConnector3`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `curvedConnector3` — an S-curve connector built from
/// two cubic Bézier segments that sweep from the top-left corner,
/// through a mid-height inflection, to the bottom-right corner.
///
/// Spec geometry: `adj1` (default 50000) sets `x2 = w·adj1/100000`,
/// with `x1 = (l+x2)/2`, `x3 = (r+x2)/2`, `hd4 = h/4`, `vc = h/2` and
/// `y3 = 3·h/4`. The path (`fill="none"`) is `moveTo (l, t)` →
/// `cubicBezTo (x1, t) (x2, hd4) (x2, vc)` →
/// `cubicBezTo (x2, y3) (x3, b) (r, b)`, an open curve (no `close`).
pub fn build_curved_connector3(width : Int, height : Int) -> ShapeGeometry {
  // adj1 default 50000 → x2 at the horizontal midpoint.
  let x2 = percent(width, 50000)
  let x1 = x2 / 2
  let x3 = (width + x2) / 2
  let hd4 = height / 4
  let vc = height / 2
  let y3 = fraction(height, 3, 4)
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    CurveTo(x1, 0, x2, hd4, x2, vc),
    CurveTo(x2, y3, x3, height, width, height),
  ]
  { commands, width, height }
}
