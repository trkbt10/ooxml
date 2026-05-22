// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonBeginning`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonBeginning` — a rectangular button face
/// carrying a "skip to start" symbol: a left-pointing triangle with
/// a vertical bar pinned against its left side.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`,
/// `g9 = vc − dx2`, `g10 = vc + dx2`, `g11 = hc − dx2`,
/// `g12 = hc + dx2`, `g13 = ss·3/4`, `g14 = g13/8`, `g15 = g13/4`,
/// `g16 = g11 + g14`, `g17 = g11 + g15`. The triangle runs
/// `(g17,vc) → (g12,g9) → (g12,g10)`; the bar is the rectangle
/// `(g16,g9) → (g11,g9) → (g11,g10) → (g16,g10)`.
pub fn build_action_button_beginning(
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
  let g13 = fraction(ss, 3, 4)
  let g14 = fraction(g13, 1, 8)
  let g15 = fraction(g13, 1, 4)
  let g16 = g11 + g14
  let g17 = g11 + g15
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Left-pointing triangle.
    MoveTo(g17, vc),
    LineTo(g12, g9),
    LineTo(g12, g10),
    ClosePath,
    // Start bar against the triangle's left side.
    MoveTo(g16, g9),
    LineTo(g11, g9),
    LineTo(g11, g10),
    LineTo(g16, g10),
    ClosePath,
  ]
  { commands, width, height }
}
