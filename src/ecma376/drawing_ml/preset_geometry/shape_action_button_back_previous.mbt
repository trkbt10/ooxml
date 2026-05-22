// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonBackPrevious`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonBackPrevious` — a rectangular button face
/// carrying a left-pointing "previous" triangle.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`,
/// `g9 = vc − dx2`, `g10 = vc + dx2`, `g11 = hc − dx2`,
/// `g12 = hc + dx2`. The face is the bounding-box rectangle; the
/// symbol is the filled triangle `(g11,vc) → (g12,g9) → (g12,g10)`
/// — its apex at the left edge of the inset box, base on the right.
pub fn build_action_button_back_previous(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g10 = vc + dx2
  let g11 = hc - dx2
  let g12 = hc + dx2
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // "Previous" triangle pointing left.
    MoveTo(g11, vc),
    LineTo(g12, g9),
    LineTo(g12, g10),
    ClosePath,
  ]
  { commands, width, height }
}
