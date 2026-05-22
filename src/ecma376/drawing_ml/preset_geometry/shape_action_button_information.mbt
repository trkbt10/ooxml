// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonInformation`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonInformation` — a rectangular button face
/// carrying an information ("i") symbol: a circular disc enclosing a
/// dot above a vertical stem.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g11 = hc − dx2`, `g13 = ss·3/4`; the remaining `gN` are
/// thirty-seconds of `g13` offset from `g9`/`g11` (see spec `gdLst`).
/// The disc is a full circle of radius `dx2` centred on `(hc,vc)`,
/// drawn as two semicircle `ArcTo` sweeps. The dot is a small full
/// circle of radius `g38 = g13·3/32` centred on `(hc,g25)`. The "i"
/// stem is the 10-vertex closed polygon.
pub fn build_action_button_information(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g11 = hc - dx2
  let g13 = fraction(ss, 3, 4)
  // Thirty-second ratios of g13.
  let g14 = fraction(g13, 1, 32)
  let g17 = fraction(g13, 5, 16)
  let g18 = fraction(g13, 3, 8)
  let g19 = fraction(g13, 13, 32)
  let g20 = fraction(g13, 19, 32)
  let g22 = fraction(g13, 11, 16)
  let g23 = fraction(g13, 13, 16)
  let g24 = fraction(g13, 7, 8)
  let g38 = fraction(g13, 3, 32)
  // Vertical guides (offset from g9).
  let g25 = g9 + g14
  let g28 = g9 + g17
  let g29 = g9 + g18
  let g30 = g9 + g23
  let g31 = g9 + g24
  // Horizontal guides (offset from g11).
  let g32 = g11 + g17
  let g34 = g11 + g19
  let g35 = g11 + g20
  let g37 = g11 + g22
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Information disc (full circle, two semicircle sweeps).
    MoveTo(hc, g9),
    ArcTo(dx2, dx2, 0, false, true, hc, g9 + dx2 * 2),
    ArcTo(dx2, dx2, 0, false, true, hc, g9),
    ClosePath,
    // Dot of the "i" (small full circle).
    MoveTo(hc, g25),
    ArcTo(g38, g38, 0, false, true, hc, g25 + g38 * 2),
    ArcTo(g38, g38, 0, false, true, hc, g25),
    ClosePath,
    // Stem of the "i" (10-vertex polygon).
    MoveTo(g32, g28),
    LineTo(g35, g28),
    LineTo(g35, g30),
    LineTo(g37, g30),
    LineTo(g37, g31),
    LineTo(g32, g31),
    LineTo(g32, g30),
    LineTo(g34, g30),
    LineTo(g34, g29),
    LineTo(g32, g29),
    ClosePath,
  ]
  { commands, width, height }
}
