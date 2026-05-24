// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bentConnector2`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `bentConnector2` — a right-angle elbow connector made
/// of two straight segments: a horizontal run along the top edge then
/// a vertical run down the right edge.
///
/// Spec path (`fill="none"`): `moveTo (l, t)` → `lnTo (r, t)` →
/// `lnTo (r, b)`. The connector is an open polyline (no `close`); the
/// `bentConnector2` shape carries no `avLst`, so the elbow is fixed
/// at the top-right corner.
pub fn build_bent_connector2(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
  ]
  { commands, width, height }
}
