// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonDocument`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonDocument` — a rectangular button face
/// carrying a page symbol with a dog-eared (folded) top-right corner.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g10 = vc + dx2`, `dx1 = ss·9/32`, `g11 = hc − dx1`,
/// `g12 = hc + dx1`, `g13 = ss·3/16`, `g14 = g12 − g13`,
/// `g15 = g9 + g13`. The symbol is the page outline
/// `(g11,g9) → (g14,g9) → (g12,g15) → (g12,g10) → (g11,g10)` plus
/// the fold triangle leg `(g12,g15) → (g14,g15) → (g14,g9)`.
pub fn build_action_button_document(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g10 = vc + dx2
  let dx1 = fraction(ss, 9, 32)
  let g11 = hc - dx1
  let g12 = hc + dx1
  let g13 = fraction(ss, 3, 16)
  let g14 = g12 - g13
  let g15 = g9 + g13
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Page outline with the folded corner clipped off.
    MoveTo(g11, g9),
    LineTo(g14, g9),
    LineTo(g12, g15),
    LineTo(g12, g10),
    LineTo(g11, g10),
    ClosePath,
    // Fold-corner triangle.
    MoveTo(g12, g15),
    LineTo(g14, g15),
    LineTo(g14, g9),
    ClosePath,
  ]
  { commands, width, height }
}
