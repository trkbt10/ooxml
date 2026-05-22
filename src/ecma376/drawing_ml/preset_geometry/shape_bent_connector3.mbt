// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bentConnector3`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `bentConnector3` — a right-angle elbow connector of
/// three straight segments: a horizontal run, a vertical drop, and a
/// second horizontal run.
///
/// Spec geometry: the `adj1` guide (default 50000) places the
/// vertical leg at `x1 = w·adj1/100000`. The path (`fill="none"`) is
/// `moveTo (l, t)` → `lnTo (x1, t)` → `lnTo (x1, b)` → `lnTo (r, b)`,
/// an open polyline (no `close`). With the default the elbow sits at
/// the horizontal midpoint.
pub fn build_bent_connector3(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  // adj1 default 50000 → x1 at the horizontal midpoint.
  let x1 = percent(width, 50000)
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(x1, 0),
    LineTo(x1, height),
    LineTo(width, height),
  ]
  { commands, width, height }
}
