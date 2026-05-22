// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonBlank`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonBlank` — a plain rectangular action
/// button face with no inner symbol.
///
/// Spec path: a single rectangle `(l,t) → (r,t) → (r,b) → (l,b) →
/// close`. Unlike the other action buttons it carries no symbol
/// sub-path, so the geometry is the bare bounding-box rectangle.
pub fn build_action_button_blank(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}
