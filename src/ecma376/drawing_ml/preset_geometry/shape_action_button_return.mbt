// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonReturn`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonReturn` — a rectangular button face
/// carrying a curved "return" arrow that loops back on itself.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g10 = vc + dx2`, `g11 = hc − dx2`, `g12 = hc + dx2`,
/// `g13 = ss·3/4`, with `g14..g27` being eighths of `g13` offset
/// from `g9`/`g11` (see spec `gdLst`).
///
/// Approximation note: the spec arrow has four `arcTo` rounded
/// corners. Each arc connects two explicit `lnTo` endpoints, so
/// here the arcs are replaced by straight `LineTo` segments to
/// those same endpoints — a 14-vertex polygon. The looping arrow
/// silhouette is preserved; only the corner rounding is lost.
pub fn build_action_button_return(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g10 = vc + dx2
  let g11 = hc - dx2
  let g12 = hc + dx2
  let g13 = fraction(ss, 3, 4)
  let g15 = fraction(g13, 3, 4)
  let g16 = fraction(g13, 5, 8)
  let g17 = fraction(g13, 3, 8)
  let g18 = fraction(g13, 1, 4)
  let g14 = fraction(g13, 7, 8)
  // Vertical guides (offset from g9).
  let g19 = g9 + g15
  let g20 = g9 + g16
  let g21 = g9 + g18
  // Horizontal guides (offset from g11).
  let g22 = g11 + g14
  let g23 = g11 + g15
  let g24 = g11 + g16
  let g25 = g11 + g17
  let g26 = g11 + g18
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Return arrow (arcs approximated by straight corner segments).
    MoveTo(g12, g21),
    LineTo(g23, g9),
    LineTo(hc, g21),
    LineTo(g24, g21),
    LineTo(g24, g20),
    LineTo(g25, g19),
    LineTo(g26, g21),
    LineTo(g11, g21),
    LineTo(g11, g20),
    LineTo(hc, g10),
    LineTo(g22, g21),
    ClosePath,
  ]
  { commands, width, height }
}
