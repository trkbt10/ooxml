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
/// FAITHFUL transcription of the spec preset path. The button face is
/// the four-corner rectangle; the "?" hook is the spec's six `arcTo`
/// curls joined by three `lnTo` segments (`moveTo(g33,g27)` →
/// `arc(g16,g16,180°,180°)` → `arc(g14,g15,0°,90°)` →
/// `arc(g41,g42,270°,−90°)` → `lnTo(g37,g30)` → `lnTo(g36,g30)` →
/// `lnTo(g36,g29)` → `arc(g14,g15,180°,90°)` → `arc(g41,g42,90°,−90°)`
/// → `arc(g14,g14,0°,−180°)` → `close`). The dot is the spec full
/// circle of radius `g42` centred on `(hc, g31+g42)`. All arcs are
/// emitted through the verified `rel_arc` helper, so the glyph is
/// correct by construction. Guides (`ss = min(w,h)`): `dx2 = ss·3/8`,
/// `g13 = ss·3/4`, with `g14..g42` being spec fractions of `g13`.
pub fn build_action_button_help(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g11 = hc - dx2
  let g13 = fraction(ss, 3, 4)
  let g14 = fraction(g13, 1, 7)
  let g15 = fraction(g13, 3, 14)
  let g16 = fraction(g13, 2, 7)
  let g19 = fraction(g13, 3, 7)
  let g20 = fraction(g13, 4, 7)
  let g21 = fraction(g13, 17, 28)
  let g23 = fraction(g13, 21, 28)
  let g24 = fraction(g13, 11, 14)
  let g41 = fraction(g13, 1, 14)
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
  let commands : Array[PathCommand] = []
  // Button face.
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  // Question-mark hook — six spec arc curls + three line segments.
  commands.push(MoveTo(g33, g27))
  let (h1, x1, y1) = rel_arc(g33, g27, g16, g16, 10800000, 10800000)
  commands.push(h1)
  let (h2, x2, y2) = rel_arc(x1, y1, g14, g15, 0, 5400000)
  commands.push(h2)
  let (h3, _, _) = rel_arc(x2, y2, g41, g42, 16200000, -5400000)
  commands.push(h3)
  commands.push(LineTo(g37, g30))
  commands.push(LineTo(g36, g30))
  commands.push(LineTo(g36, g29))
  let (h4, x4, y4) = rel_arc(g36, g29, g14, g15, 10800000, 5400000)
  commands.push(h4)
  let (h5, x5, y5) = rel_arc(x4, y4, g41, g42, 5400000, -5400000)
  commands.push(h5)
  let (h6, _, _) = rel_arc(x5, y5, g14, g14, 0, -10800000)
  commands.push(h6)
  commands.push(ClosePath)
  // Dot of the question mark — full circle, two semicircle sweeps.
  commands.push(MoveTo(hc, g31))
  commands.push(ArcTo(g42, g42, 0, false, true, hc, g31 + g42 * 2))
  commands.push(ArcTo(g42, g42, 0, false, true, hc, g31))
  commands.push(ClosePath)
  { commands, width, height }
}
