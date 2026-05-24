// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `line`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `line` — a straight diagonal line running from the
/// top-left corner of the bounding box to the bottom-right corner.
///
/// Spec path: `moveTo (l, t)` then `lnTo (r, b)`. The shape is an
/// open polyline (no `close`), so the renderer draws it as a stroked
/// segment rather than a filled region.
pub fn build_line(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = [MoveTo(0, 0), LineTo(width, height)]
  { commands, width, height }
}
