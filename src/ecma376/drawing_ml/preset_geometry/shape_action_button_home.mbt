// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonHome`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonHome` — a rectangular button face
/// carrying a house ("home") symbol: a gabled roof above a wall box
/// with a doorway cut into it.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g10 = vc + dx2`, `g11 = hc − dx2`, `g12 = hc + dx2`,
/// `g13 = ss·3/4`. The remaining `gN` are sixteenths of `g13`
/// offset from `g9` (vertical) or `g11` (horizontal); see the spec
/// `gdLst`. The symbol is the single outline sub-path that traces
/// the roof apex, the right eave/chimney step, the wall corner and
/// the doorway notch (`(hc,g9) → (g11,vc) → … → close`).
pub fn build_action_button_home(width : Int, height : Int) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let dx2 = fraction(ss, 3, 8)
  let hc = width / 2
  let vc = height / 2
  let g9 = vc - dx2
  let g10 = vc + dx2
  let g11 = hc - dx2
  let g12 = hc + dx2
  let g13 = fraction(ss, 3, 4)
  // Sixteenth steps of g13.
  let g14 = fraction(g13, 1, 16)
  let g16 = fraction(g13, 3, 16)
  let g17 = fraction(g13, 5, 16)
  let g15 = fraction(g13, 1, 8)
  let g18 = fraction(g13, 7, 16)
  let g19 = fraction(g13, 9, 16)
  let g20 = fraction(g13, 11, 16)
  let g21 = fraction(g13, 3, 4)
  let g22 = fraction(g13, 13, 16)
  let g23 = fraction(g13, 7, 8)
  // Vertical guides (offset from g9).
  let g24 = g9 + g14
  let g25 = g9 + g16
  let g26 = g9 + g17
  let g27 = g9 + g21
  // Horizontal guides (offset from g11).
  let g28 = g11 + g15
  let g29 = g11 + g18
  let g30 = g11 + g19
  let g31 = g11 + g20
  let g32 = g11 + g22
  let g33 = g11 + g23
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // House outline: roof apex, eaves, wall and doorway notch.
    MoveTo(hc, g9),
    LineTo(g11, vc),
    LineTo(g28, vc),
    LineTo(g28, g10),
    LineTo(g33, g10),
    LineTo(g33, vc),
    LineTo(g12, vc),
    LineTo(g32, g26),
    LineTo(g32, g24),
    LineTo(g31, g24),
    LineTo(g31, g25),
    ClosePath,
    // Doorway cut-out.
    MoveTo(g29, g10),
    LineTo(g29, g27),
    LineTo(g30, g27),
    LineTo(g30, g10),
    ClosePath,
  ]
  { commands, width, height }
}
