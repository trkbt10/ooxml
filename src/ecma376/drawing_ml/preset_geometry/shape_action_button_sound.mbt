// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `actionButtonSound`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `actionButtonSound` — a rectangular button face
/// carrying a loudspeaker symbol with three radiating sound waves.
///
/// Spec guides (`ss = min(w,h)`): `dx2 = ss·3/8`, `g9 = vc − dx2`,
/// `g10 = vc + dx2`, `g11 = hc − dx2`, `g12 = hc + dx2`,
/// `g13 = ss·3/4`. The remaining `gN` are sixteenths of `g13`
/// offset from `g9`/`g11` (see spec `gdLst`). The symbol is the
/// speaker cone `(g11,g21) → … → close` followed by three open
/// sound-wave segments to the right of the cone.
pub fn build_action_button_sound(width : Int, height : Int) -> ShapeGeometry {
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
  let g15 = fraction(g13, 5, 16)
  let g16 = fraction(g13, 5, 8)
  let g17 = fraction(g13, 11, 16)
  let g18 = fraction(g13, 3, 4)
  let g19 = fraction(g13, 7, 8)
  // Vertical guides (offset from g9).
  let g20 = g9 + g14
  let g21 = g9 + g15
  let g22 = g9 + g17
  let g23 = g9 + g19
  // Horizontal guides (offset from g11).
  let g24 = g11 + g15
  let g25 = g11 + g16
  let g26 = g11 + g18
  let commands : Array[PathCommand] = [
    // Button face.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Loudspeaker cone.
    MoveTo(g11, g21),
    LineTo(g11, g22),
    LineTo(g24, g22),
    LineTo(g25, g10),
    LineTo(g25, g9),
    LineTo(g24, g21),
    ClosePath,
    // Three radiating sound waves (open segments).
    MoveTo(g26, g21),
    LineTo(g12, g20),
    MoveTo(g26, vc),
    LineTo(g12, vc),
    MoveTo(g26, g22),
    LineTo(g12, g23),
  ]
  { commands, width, height }
}
