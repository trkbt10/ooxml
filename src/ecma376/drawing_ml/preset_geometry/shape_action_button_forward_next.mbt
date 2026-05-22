// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonForwardNext`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonForwardNext` — a rectangular button face
/// carrying a right-pointing "next" triangle.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`,
/// `g9 = vc − dx2`, `g10 = vc + dx2`, `g11 = hc − dx2`,
/// `g12 = hc + dx2`. The face is the bounding-box rectangle; the
/// symbol is the filled triangle `(g12,vc) → (g11,g9) → (g11,g10)`
/// — its apex at the right edge of the inset box, base on the left.
pub fn build_action_button_forward_next(
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
    // "Next" triangle pointing right.
    MoveTo(g12, vc),
    LineTo(g11, g9),
    LineTo(g11, g10),
    ClosePath,
  ]
  { commands, width, height }
}
