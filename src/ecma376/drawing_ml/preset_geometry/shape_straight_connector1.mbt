// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `straightConnector1`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `straightConnector1` — a straight connector line
/// joining the top-left corner of the bounding box to the
/// bottom-right corner.
///
/// Spec path (`fill="none"`): `moveTo (l, t)` then `lnTo (r, b)`. The
/// connector is an open polyline (no `close`); the renderer strokes
/// it and the connector endpoints anchor to the attached shapes.
pub fn build_straight_connector1(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(width, height),
  ]
  { commands, width, height }
}
