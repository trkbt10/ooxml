// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedLeftArrow`.

///|
/// §20.1.10.56 `curvedLeftArrow` — a block arrow whose shaft curves
/// along an arc and whose head points to the left. It is the
/// horizontal mirror of `curvedRightArrow`.
///
/// FAITHFUL transcription of the spec preset path (the main body
/// `path` with `stroke="false"`). The guide chain is identical to
/// `curvedRightArrow` up to `ah`; the arrowhead anchor `x1 = l + ah`
/// (the head is on the left) and the two body arcs use the angle
/// guides `dang2 = at2 idx (th/2)`, `swAng2 = dang2 − swAng`,
/// `swAng3 = swAng + dang2`, `stAng3 = −dang2`. Each guide is a 1:1
/// transcription of the spec `gdLst`; the arcs are emitted through the
/// verified `rel_arc` helper, so the geometry is correct by
/// construction.
///
/// Spec `avLst`: `adj1 = 25000` (shaft thickness `th`), `adj2 = 50000`
/// (head width `aw`), `adj3 = 25000` (head length `ah`).
pub fn build_curved_left_arrow(
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
  // Guide chain — faithful transcription of the spec gdLst.
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, h, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, a2)
  let th = fraction(ss, a1, 100000)
  let aw = fraction(ss, a2, 100000)
  let q1 = (th + aw) / 4
  let h_r = hd2 - q1
  let q7 = h_r * 2
  let q11 = isqrt(q7 * q7 - th * th)
  let idx = if q7 == 0 { 0 } else { fraction(q11, w, q7) }
  let max_adj3 = if ss == 0 { 0 } else { fraction(100000, idx, ss) }
  let a3 = pin_int(adj3, 0, max_adj3)
  let ah = fraction(ss, a3, 100000)
  let y3 = h_r + th
  let q5 = isqrt(w * w - ah * ah)
  let dy = if w == 0 { 0 } else { fraction(q5, h_r, w) }
  let y5 = h_r + dy
  let y7 = y3 + dy
  let dh = (aw - th) / 2
  let y4 = y5 - dh
  let y8 = y7 + dh
  let aw2 = aw / 2
  let y6 = h - aw2
  let x1 = ah // +- l ah 0
  let sw_ang = at2(ah, dy) // at2 ah dy
  let q12 = th / 2 // */ th 1 2
  let dang2 = at2(idx, q12) // at2 idx q12
  let sw_ang2 = dang2 - sw_ang // +- dang2 0 swAng
  let sw_ang3 = sw_ang + dang2 // +- swAng dang2 0
  let st_ang3 = -dang2 // +- 0 0 dang2
  // Path 1 — the main arrow body silhouette.
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(0, y6))
  commands.push(LineTo(x1, y4))
  commands.push(LineTo(x1, y5))
  let (c1, cx, cy) = rel_arc(x1, y5, w, h_r, sw_ang, sw_ang2)
  commands.push(c1)
  let (c2, _, _) = rel_arc(cx, cy, w, h_r, st_ang3, sw_ang3)
  commands.push(c2)
  commands.push(LineTo(x1, y8))
  commands.push(ClosePath)
  { commands, width, height }
}
