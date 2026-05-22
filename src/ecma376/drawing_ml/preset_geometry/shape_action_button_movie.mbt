// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonMovie`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonMovie` — a rectangular button face
/// carrying a film-camera ("movie") silhouette.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g10 = vc + dx2`, `g11 = hc − dx2`, `g12 = hc + dx2`,
/// `g13 = ss·3/4`. The camera profile guides `g14..g30` are
/// `g13·N/21600` ratios; the horizontal `g31..g38` add to `g11`
/// and the vertical `g39..g48` add to `g9` (see spec `gdLst`).
/// The symbol is the single closed 19-vertex camera outline.
pub fn build_action_button_movie(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g11 = hc - dx2
  let g12 = hc + dx2
  let g13 = fraction(ss, 3, 4)
  // 21600-denominator profile ratios of g13.
  let g14 = fraction(g13, 1455, 21600)
  let g15 = fraction(g13, 1905, 21600)
  let g16 = fraction(g13, 2325, 21600)
  let g17 = fraction(g13, 16155, 21600)
  let g18 = fraction(g13, 17010, 21600)
  let g19 = fraction(g13, 19335, 21600)
  let g20 = fraction(g13, 19725, 21600)
  let g21 = fraction(g13, 20595, 21600)
  let g22 = fraction(g13, 5280, 21600)
  let g23 = fraction(g13, 5730, 21600)
  let g24 = fraction(g13, 6630, 21600)
  let g25 = fraction(g13, 7492, 21600)
  let g26 = fraction(g13, 9067, 21600)
  let g27 = fraction(g13, 9555, 21600)
  let g28 = fraction(g13, 13342, 21600)
  let g29 = fraction(g13, 14580, 21600)
  let g30 = fraction(g13, 15592, 21600)
  // Horizontal guides (offset from g11).
  let g31 = g11 + g14
  let g32 = g11 + g15
  let g33 = g11 + g16
  let g34 = g11 + g17
  let g35 = g11 + g18
  let g36 = g11 + g19
  let g37 = g11 + g20
  let g38 = g11 + g21
  // Vertical guides (offset from g9).
  let g39 = g9 + g22
  let g40 = g9 + g23
  let g41 = g9 + g24
  let g42 = g9 + g25
  let g43 = g9 + g26
  let g44 = g9 + g27
  let g45 = g9 + g28
  let g46 = g9 + g29
  let g47 = g9 + g30
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Film-camera silhouette.
    MoveTo(g11, g39),
    LineTo(g11, g44),
    LineTo(g31, g44),
    LineTo(g32, g43),
    LineTo(g33, g43),
    LineTo(g33, g47),
    LineTo(g35, g47),
    LineTo(g35, g45),
    LineTo(g36, g45),
    LineTo(g38, g46),
    LineTo(g12, g46),
    LineTo(g12, g41),
    LineTo(g38, g41),
    LineTo(g37, g42),
    LineTo(g35, g42),
    LineTo(g35, g41),
    LineTo(g34, g40),
    LineTo(g32, g40),
    LineTo(g31, g39),
    ClosePath,
  ]
  { commands, width, height }
}
