// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `lineInv`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `lineInv` — the inverted straight diagonal line. It
/// runs from the bottom-left corner of the bounding box to the
/// top-right corner, mirroring `line` about the horizontal axis.
///
/// Spec path: `moveTo (l, b)` then `lnTo (r, t)`. The shape is an
/// open polyline (no `close`), drawn as a stroked segment.
pub fn build_line_inv(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = [
    MoveTo(0, height),
    LineTo(width, 0),
  ]
  { commands, width, height }
}
