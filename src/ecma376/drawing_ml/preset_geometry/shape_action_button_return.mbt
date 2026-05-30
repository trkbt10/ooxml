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
/// FAITHFUL transcription of the spec preset path. The button face is
/// the four-corner rectangle; the return arrow is the spec's polyline
/// with four rounded `arcTo` corners — two small `g27`-radius curls at
/// the arrowhead notch (`stAng 0,+90°` and `90°,+90°`) and two larger
/// `g17`-radius curls at the loop bottom (`stAng 180°,−90°` and
/// `90°,−90°`). All arcs are emitted through the verified `rel_arc`
/// helper, so the glyph is correct by construction. Guides
/// (`ss = min(w,h)`): `dx2 = ss·3/8`, `g13 = ss·3/4`, with `g14..g27`
/// being spec eighths/quarters of `g13` offset from `g9`/`g11`.
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
  let g14 = fraction(g13, 7, 8)
  let g15 = fraction(g13, 3, 4)
  let g16 = fraction(g13, 5, 8)
  let g17 = fraction(g13, 3, 8)
  let g18 = fraction(g13, 1, 4)
  let g27 = fraction(g13, 1, 8)
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
  let commands : Array[PathCommand] = []
  // Button face.
  commands.push(MoveTo(0, 0))
  commands.push(LineTo(width, 0))
  commands.push(LineTo(width, height))
  commands.push(LineTo(0, height))
  commands.push(ClosePath)
  // Return arrow — polyline with four rounded `arcTo` corners.
  commands.push(MoveTo(g12, g21))
  commands.push(LineTo(g23, g9))
  commands.push(LineTo(hc, g21))
  commands.push(LineTo(g24, g21))
  commands.push(LineTo(g24, g20))
  let (a1, _, _) = rel_arc(g24, g20, g27, g27, 0, 5400000)
  commands.push(a1)
  commands.push(LineTo(g25, g19))
  let (a2, _, _) = rel_arc(g25, g19, g27, g27, 5400000, 5400000)
  commands.push(a2)
  commands.push(LineTo(g26, g21))
  commands.push(LineTo(g11, g21))
  commands.push(LineTo(g11, g20))
  let (a3, _, _) = rel_arc(g11, g20, g17, g17, 10800000, -5400000)
  commands.push(a3)
  commands.push(LineTo(hc, g10))
  let (a4, _, _) = rel_arc(hc, g10, g17, g17, 5400000, -5400000)
  commands.push(a4)
  commands.push(LineTo(g22, g21))
  commands.push(ClosePath)
  { commands, width, height }
}
