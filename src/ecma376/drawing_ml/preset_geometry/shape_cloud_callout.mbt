// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `cloudCallout`.
//
// One preset shape per file. Dispatched from `build_geometry` and
// reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `cloudCallout` — a cloud-shaped body (a closed loop of
/// outward bumps) followed by a trail of three shrinking ellipse
/// bubbles leading to the callout target point.
///
/// FAITHFUL transcription of the spec preset path. The body is the
/// exact eleven-arc cloud outline (reuses `build_cloud`, which mirrors
/// the spec's 43200×43200 frame). The tail is the spec's three
/// full-circle bubbles, whose centres and radii come from a 1:1
/// transcription of the spec `gdLst`: the target `(xPos, yPos) =
/// (hc + w·adj1/100000, vc + h·adj2/100000)`, the cloud-edge anchor
/// `(g4, g5)` via `cat2`/`sat2`, the tail length `g8 = mod(g6, g7)`,
/// and the bubble radii `g12`, `g25`, `g26` (= `ss·{1800,1200,600}
/// /21600`). The verified `at2`/`gcat2`/`gsat2`/`gmod` primitives make
/// the geometry correct by construction. Spec `avLst`: `adj1 = -20833`,
/// `adj2 = 62500`.
pub fn build_cloud_callout(
  width : Int,
  height : Int,
  adj1? : Int = -20833,
  adj2? : Int = 62500,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let hc = width / 2
  let vc = height / 2
  let wd2 = width / 2
  let hd2 = height / 2
  // Cloud body — the faithful eleven-arc outline.
  let commands : Array[PathCommand] = []
  for cmd in build_cloud(width, height).commands {
    commands.push(cmd)
  }
  // Tail guide chain — faithful transcription of the spec gdLst.
  let dx_pos = fraction(width, adj1, 100000) // */ w adj1 100000
  let dy_pos = fraction(height, adj2, 100000) // */ h adj2 100000
  let x_pos = hc + dx_pos // +- hc dxPos 0
  let y_pos = vc + dy_pos // +- vc dyPos 0
  let ht = gcat2(hd2, dx_pos, dy_pos) // cat2 hd2 dxPos dyPos
  let wt = gsat2(wd2, dx_pos, dy_pos) // sat2 wd2 dxPos dyPos
  let g2 = gcat2(wd2, ht, wt) // cat2 wd2 ht wt
  let g3 = gsat2(hd2, ht, wt) // sat2 hd2 ht wt
  let g4 = hc + g2 // +- hc g2 0
  let g5 = vc + g3 // +- vc g3 0
  let g6 = g4 - x_pos // +- g4 0 xPos
  let g7 = g5 - y_pos // +- g5 0 yPos
  let g8 = gmod(g6, g7, 0) // mod g6 g7 0
  let g9 = fraction(ss, 6600, 21600) // */ ss 6600 21600
  let g10 = g8 - g9 // +- g8 0 g9
  let g11 = g10 / 3 // */ g10 1 3
  let g12 = fraction(ss, 1800, 21600) // */ ss 1800 21600
  let g13 = g11 + g12 // +- g11 g12 0
  let g14 = if g8 == 0 { 0 } else { fraction(g13, g6, g8) } // */ g13 g6 g8
  let g15 = if g8 == 0 { 0 } else { fraction(g13, g7, g8) } // */ g13 g7 g8
  let g16 = g14 + x_pos // +- g14 xPos 0
  let g17 = g15 + y_pos // +- g15 yPos 0
  let g18 = fraction(ss, 4800, 21600) // */ ss 4800 21600
  let g19 = g11 * 2 // */ g11 2 1
  let g20 = g18 + g19 // +- g18 g19 0
  let g21 = if g8 == 0 { 0 } else { fraction(g20, g6, g8) } // */ g20 g6 g8
  let g22 = if g8 == 0 { 0 } else { fraction(g20, g7, g8) } // */ g20 g7 g8
  let g23 = g21 + x_pos // +- g21 xPos 0
  let g24 = g22 + y_pos // +- g22 yPos 0
  let g25 = fraction(ss, 1200, 21600) // */ ss 1200 21600
  let g26 = fraction(ss, 600, 21600) // */ ss 600 21600
  // Three tail bubbles (full circles), in spec order: smallest at the
  // target tip (xPos, yPos), then (g16, g17), then the largest nearest
  // the cloud body at (g23, g24).
  let bubbles : Array[(Int, Int, Int)] = [
    (x_pos, y_pos, g26),
    (g16, g17, g25),
    (g23, g24, g12),
  ]
  for bubble in bubbles {
    let (bx, by, br) = bubble
    commands.push(MoveTo(bx - br, by))
    commands.push(ArcTo(br, br, 0, false, true, bx + br, by))
    commands.push(ArcTo(br, br, 0, false, true, bx - br, by))
    commands.push(ClosePath)
  }
  { commands, width, height }
}
