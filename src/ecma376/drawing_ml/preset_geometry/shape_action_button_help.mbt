// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonHelp`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonHelp` — a rectangular button face
/// carrying a question-mark ("?") help symbol: a curled hook above a
/// separate dot.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g13 = ss·3/4`, with `g14..g42` being sevenths/fourteenths of
/// `g13` offset from `g9`/`g11` (see spec `gdLst`).
///
/// Approximation note: the spec hook is drawn with five `arcTo`
/// curls; here it is approximated as an 8-vertex polygon threaded
/// through the hook's defining guide points (`(g33,g27)`,
/// `(g37,g30)`, `(g36,g30)`, `(g36,g29)`, plus the top curl apex at
/// `(hc,g9)`). The dot remains a faithful full circle of radius
/// `g42` centred on `(hc,g31)`. The distinguishing "?" silhouette is
/// preserved; only the curl smoothness is lost.
pub fn build_action_button_help(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g11 = hc - dx2
  let g13 = fraction(ss, 3, 4)
  let g15 = fraction(g13, 3, 14)
  let g16 = fraction(g13, 2, 7)
  let g19 = fraction(g13, 3, 7)
  let g20 = fraction(g13, 4, 7)
  let g21 = fraction(g13, 17, 28)
  let g23 = fraction(g13, 21, 28)
  let g24 = fraction(g13, 11, 14)
  let g42 = fraction(g13, 3, 28)
  // Vertical guides (offset from g9).
  let g27 = g9 + g16
  let g29 = g9 + g21
  let g30 = g9 + g23
  let g31 = g9 + g24
  // Horizontal guides (offset from g11).
  let g33 = g11 + g15
  let g36 = g11 + g19
  let g37 = g11 + g20
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Question-mark hook (polygon approximation of the spec arcs).
    MoveTo(g33, g27),
    LineTo(hc, g9),
    LineTo(g37, g27),
    LineTo(g37, g30),
    LineTo(g36, g30),
    LineTo(g36, g29),
    LineTo(g33, g29),
    LineTo(g33, g27),
    ClosePath,
    // Dot of the question mark (full circle, two semicircle sweeps).
    MoveTo(hc, g31),
    ArcTo(g42, g42, 0, false, true, hc, g31 + g42 * 2),
    ArcTo(g42, g42, 0, false, true, hc, g31),
    ClosePath,
  ]
  { commands, width, height }
}
