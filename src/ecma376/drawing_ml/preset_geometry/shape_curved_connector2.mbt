// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedConnector2`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `curvedConnector2` — a single-curve connector that
/// sweeps from the top-left corner to the bottom-right corner with a
/// smooth quarter-S bend.
///
/// Spec path (`fill="none"`): `moveTo (l, t)` then a cubic Bézier
/// `cubicBezTo (wd2, t) (r, hd2) (r, b)`, where `wd2 = w/2` and
/// `hd2 = h/2`. The connector is an open curve (no `close`).
pub fn build_curved_connector2(width : Int, height : Int) -> ShapeGeometry {
  let wd2 = width / 2
  let hd2 = height / 2
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    CurveTo(wd2, 0, width, hd2, width, height),
  ]
  { commands, width, height }
}
