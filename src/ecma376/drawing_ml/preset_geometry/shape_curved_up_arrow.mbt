// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedUpArrow`.

///|
/// §20.1.10.56 `curvedUpArrow` — a block arrow whose shaft curves
/// along an arc and whose head points upward. It is the vertical
/// analogue of `curvedRightArrow` (the roles of width/height and
/// `wR`/`hR` are swapped).
///
/// FAITHFUL transcription of the spec preset path (the main body
/// `path` with `stroke="false"`). Every guide is a 1:1 transcription
/// of the spec `gdLst`. Two spec quirks are preserved verbatim:
/// `a1 = pin 0 adj1 100000` (clamped to 100000, not `a2`), and
/// `ah = */ ss adj3 100000` uses the raw `adj3` rather than the pinned
/// `a3`. The two body arcs are emitted through the verified `rel_arc`
/// helper, so the geometry is correct by construction.
///
/// Spec `avLst`: `adj1 = 25000` (shaft thickness `th`), `adj2 = 50000`
/// (head width `aw`), `adj3 = 25000` (head length `ah`).
pub fn build_curved_up_arrow(
  width : Int,
  height : Int,
  adj1~ : Int = 25000,
  adj2~ : Int = 50000,
  adj3~ : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let w = width
  let h = height
  let wd2 = w / 2
  let cd4 = 5400000
  // Guide chain — faithful transcription of the spec gdLst.
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, w, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, 100000) // pin 0 adj1 100000
  let th = fraction(ss, a1, 100000)
  let aw = fraction(ss, a2, 100000)
  let q1 = (th + aw) / 4
  let w_r = wd2 - q1 // +- wd2 0 q1
  let q7 = w_r * 2
  let q11 = isqrt(q7 * q7 - th * th)
  let idy = if q7 == 0 { 0 } else { fraction(q11, h, q7) } // */ q11 h q7
  let ah = fraction(ss, adj3, 100000) // */ ss adj3 100000 (raw adj3)
  let x3 = w_r + th // +- wR th 0
  let q5 = isqrt(h * h - ah * ah)
  let dx = if h == 0 { 0 } else { fraction(q5, w_r, h) } // */ q5 wR h
  let x5 = w_r + dx // +- wR dx 0
  let x7 = x3 + dx // +- x3 dx 0
  let dh = (aw - th) / 2
  let x4 = x5 - dh // +- x5 0 dh
  let x8 = x7 + dh // +- x7 dh 0
  let aw2 = aw / 2
  let x6 = w - aw2 // +- r 0 aw2
  let y1 = ah // +- t ah 0
  let sw_ang = at2(ah, dx) // at2 ah dx
  let q12 = th / 2
  let dang2 = at2(idy, q12) // at2 idy q12
  let sw_ang2 = dang2 - sw_ang // +- dang2 0 swAng
  let st_ang3 = cd4 - sw_ang // +- cd4 0 swAng
  let sw_ang3 = sw_ang + dang2 // +- swAng dang2 0
  let st_ang2 = cd4 - dang2 // +- cd4 0 dang2
  // Path 1 — the main arrow body silhouette.
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x6, 0))
  commands.push(LineTo(x8, y1))
  commands.push(LineTo(x7, y1))
  let (c1, cx, cy) = rel_arc(x7, y1, w_r, h, st_ang3, sw_ang3)
  commands.push(c1)
  let (c2, _, _) = rel_arc(cx, cy, w_r, h, st_ang2, sw_ang2)
  commands.push(c2)
  commands.push(LineTo(x4, y1))
  commands.push(ClosePath)
  { commands, width, height }
}
