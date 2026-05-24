// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `bentConnector5`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `bentConnector5` — a right-angle elbow connector of
/// five straight segments: horizontal, vertical, horizontal,
/// vertical, then a closing horizontal run to the bottom-right.
///
/// Spec geometry: `adj1`/`adj3` (defaults 50000) place the two
/// vertical legs at `x1 = w·adj1/100000` and `x3 = w·adj3/100000`;
/// `adj2` (default 50000) places the middle horizontal leg at
/// `y2 = h·adj2/100000`. The path (`fill="none"`) is `moveTo (l, t)`
/// → `lnTo (x1, t)` → `lnTo (x1, y2)` → `lnTo (x3, y2)` →
/// `lnTo (x3, b)` → `lnTo (r, b)`, an open polyline (no `close`).
pub fn build_bent_connector5(width : Int, height : Int) -> ShapeGeometry {
  // adj1/adj2/adj3 defaults 50000 → x1/x3/y2 at the box midpoints.
  let x1 = percent(width, 50000)
  let x3 = percent(width, 50000)
  let y2 = percent(height, 50000)
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(x1, 0),
    LineTo(x1, y2),
    LineTo(x3, y2),
    LineTo(x3, height),
    LineTo(width, height),
  ]
  { commands, width, height }
}
