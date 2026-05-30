// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedRightArrow`.

///|
/// §20.1.10.56 `curvedRightArrow` — a block arrow whose shaft curves
/// along an arc and whose head points to the right.
///
/// FAITHFUL transcription of the spec preset path (the main body
/// `path` with `stroke="false"`). Every guide below is a 1:1
/// transcription of the spec `gdLst` formula — `*/ x y z` →
/// `fraction(x, y, z)`, `+- x y z` → `x + y − z`, `+/ x y z` →
/// `(x + y) / z`, `pin a b c` → `pin_int(b, a, c)`, `sqrt` → `isqrt`,
/// `at2` → the verified `at2` primitive — so the geometry is correct
/// by construction. The two `arcTo` edges are emitted through the
/// independently-verified `rel_arc` helper. The arcs share the radii
/// `(w, hR)` but start from different pen positions, so they trace
/// distinct offset arcs that bound the curved band; the arrowhead is
/// the straight `lnTo` chain reaching the tip at `(r, y6)` on the
/// right edge.
///
/// Spec `avLst`: `adj1 = 25000` (shaft thickness fraction `th`),
/// `adj2 = 50000` (arrowhead width `aw`), `adj3 = 25000` (head length
/// `ah`).
pub fn build_curved_right_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 25000,
  adj2~ : Int = 50000,
  adj3~ : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let w = width
  let h = height
  let hd2 = h / 2
  let cd2 = 10800000
  // Guide chain — faithful transcription of the spec gdLst.
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, h, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, a2)
  let th = fraction(ss, a1, 100000) // */ ss a1 100000
  let aw = fraction(ss, a2, 100000) // */ ss a2 100000
  let q1 = (th + aw) / 4 // +/ th aw 4
  let h_r = hd2 - q1 // +- hd2 0 q1
  let q7 = h_r * 2 // */ hR 2 1
  let q11 = isqrt(q7 * q7 - th * th) // sqrt (q7² − th²)
  let idx = if q7 == 0 { 0 } else { fraction(q11, w, q7) } // */ q11 w q7
  let max_adj3 = if ss == 0 { 0 } else { fraction(100000, idx, ss) }
  let a3 = pin_int(adj3, 0, max_adj3)
  let ah = fraction(ss, a3, 100000) // */ ss a3 100000
  let y3 = h_r + th // +- hR th 0
  let q5 = isqrt(w * w - ah * ah) // sqrt (w² − ah²)
  let dy = if w == 0 { 0 } else { fraction(q5, h_r, w) } // */ q5 hR w
  let y5 = h_r + dy // +- hR dy 0
  let y7 = y3 + dy // +- y3 dy 0
  let dh = (aw - th) / 2 // */ (+- aw 0 th) 1 2
  let y4 = y5 - dh // +- y5 0 dh
  let y8 = y7 + dh // +- y7 dh 0
  let aw2 = aw / 2 // */ aw 1 2
  let y6 = h - aw2 // +- b 0 aw2
  let x1 = w - ah // +- r 0 ah
  let sw_ang = at2(ah, dy) // at2 ah dy
  let st_ang = cd2 - sw_ang // +- cd2 0 swAng
  let msw_ang = -sw_ang // +- 0 0 swAng
  // Path 1 — the main arrow body silhouette.
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, h_r))
  let (c1, _, _) = rel_arc(0, h_r, w, h_r, cd2, msw_ang)
  commands.push(c1)
  commands.push(LineTo(x1, y4))
  commands.push(LineTo(w, y6))
  commands.push(LineTo(x1, y8))
  commands.push(LineTo(x1, y7))
  let (c2, _, _) = rel_arc(x1, y7, w, h_r, st_ang, sw_ang)
  commands.push(c2)
  commands.push(ClosePath)
  { commands, width, height }
}
