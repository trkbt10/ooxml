// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `moon`.

///|
/// §20.1.10.56 `moon` — a crescent moon: a half-ellipse outer edge and
/// a concave inner arc that carves the crescent bite.
///
/// FAITHFUL transcription of the spec preset path. Every guide is a 1:1
/// transcription of the spec `gdLst`; only the guides feeding path 1
/// are computed (the `g12..dy4`/`g10h..g16h` chain parameterises the
/// connection sites and inner rect, not the outline). The outer edge
/// `arcTo(w,hd2,cd4,cd2)` is a half-ellipse bulging left; the inner
/// concave edge `arcTo(g18w,dy1,stAng1,swAng1)` uses the spec radii
/// `g18w`/`dy1` and the `at2`-derived sweep `stAng1 = at2(−dx2p,−hd2)`,
/// `enAng1 = at2(−dx2p,hd2) − 360°`, `swAng1 = enAng1 − stAng1`, where
/// `dx2p = g0w + g18w − w`. Both arcs are emitted through the verified
/// `rel_arc` helper and the `at2` primitive, so the geometry is correct
/// by construction. The default `adj = 50000` produces a half-moon.
pub fn build_moon(width : Int, height : Int, adj~ : Int = 50000) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let w = width
  let hd2 = height / 2
  let cd4 = 5400000
  let cd2 = 10800000
  // Guide chain — faithful transcription of the spec gdLst (path-1
  // subset).
  let a = pin_int(adj, 0, 87500)
  let g0 = fraction(ss, a, 100000) // */ ss a 100000
  let g0w = if ss == 0 { 0 } else { fraction(g0, w, ss) } // */ g0 w ss
  let g1 = ss - g0 // +- ss 0 g0
  let g2 = if g1 == 0 { 0 } else { fraction(g0, g0, g1) } // */ g0 g0 g1
  let g3 = if g1 == 0 { 0 } else { fraction(ss, ss, g1) } // */ ss ss g1
  let g4 = g3 * 2 // */ g3 2 1
  let g5 = g4 - g2 // +- g4 0 g2
  let g6 = g5 - g0 // +- g5 0 g0
  let g6w = if ss == 0 { 0 } else { fraction(g6, w, ss) } // */ g6 w ss
  let g7 = g5 / 2 // */ g5 1 2
  let g8 = g7 - g0 // +- g7 0 g0
  let dy1 = if ss == 0 { 0 } else { fraction(g8, hd2, ss) } // */ g8 hd2 ss
  let g17w = g6w - g0w // +- g6w 0 g0w
  let g18w = g17w / 2 // */ g17w 1 2
  let dx2p = g0w + g18w - w // +- g0w g18w w
  let dx2 = -dx2p // */ dx2p -1 1
  let dy2 = -hd2 // */ hd2 -1 1
  let st_ang1 = at2(dx2, dy2) // at2 dx2 dy2
  let en_angp1 = at2(dx2, hd2) // at2 dx2 hd2
  let en_ang1 = en_angp1 - 21600000 // +- enAngp1 0 21600000
  let sw_ang1 = en_ang1 - st_ang1 // +- enAng1 0 stAng1
  // Path 1 — the crescent outline.
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(w, height))
  let (c1, ox, oy) = rel_arc(w, height, w, hd2, cd4, cd2)
  commands.push(c1)
  let (c2, _, _) = rel_arc(ox, oy, g18w, dy1, st_ang1, sw_ang1)
  commands.push(c2)
  commands.push(ClosePath)
  { commands, width, height }
}
