// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `curvedDownArrow`.

///|
/// §20.1.10.56 `curvedDownArrow` — a block arrow whose shaft curves
/// along an arc and whose head points downward. It is the vertical
/// mirror of `curvedUpArrow`.
///
/// FAITHFUL transcription of the spec preset path (the main body
/// `path` with `stroke="false"`). Every guide is a 1:1 transcription
/// of the spec `gdLst`; the same two spec quirks as `curvedUpArrow`
/// hold (`a1 = pin 0 adj1 100000`; `ah = */ ss adj3 100000` uses raw
/// `adj3`). The bottom-referenced head sits at `y1 = b − ah`; the two
/// body arcs (`stAng = 3cd4 + swAng` with sweep `−swAng`, and
/// `stAng = 3cd4` with sweep `swAng`) are emitted through the verified
/// `rel_arc` helper, so the geometry is correct by construction.
///
/// Spec `avLst`: `adj1 = 25000` (shaft thickness `th`), `adj2 = 50000`
/// (head width `aw`), `adj3 = 25000` (head length `ah`).
pub fn build_curved_down_arrow(
  width : Int,
  height : Int,
  adj1? : Int = 25000,
  adj2? : Int = 50000,
  adj3? : Int = 25000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let w = width
  let h = height
  let wd2 = w / 2
  let c3d4 = 16200000 // 3cd4 (270°)
  // Guide chain — faithful transcription of the spec gdLst.
  let max_adj2 = if ss == 0 { 0 } else { fraction(50000, w, ss) }
  let a2 = pin_int(adj2, 0, max_adj2)
  let a1 = pin_int(adj1, 0, 100000) // pin 0 adj1 100000
  let th = fraction(ss, a1, 100000)
  let aw = fraction(ss, a2, 100000)
  let q1 = (th + aw) / 4
  let w_r = wd2 - q1 // +- wd2 0 q1
  // The spec also derives idy/maxAdj3/a3/dang2 from wR, but those guides
  // only parameterise the path-2/3 accent + stroke outline; the main
  // body path-1 transcribed here does not reference them.
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
  let y1 = h - ah // +- b 0 ah
  let sw_ang = at2(ah, dx) // at2 ah dx
  let st_ang = c3d4 + sw_ang // +- 3cd4 swAng 0
  let msw_ang = -sw_ang // +- 0 0 swAng
  // Path 1 — the main arrow body silhouette.
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x6, h))
  commands.push(LineTo(x4, y1))
  commands.push(LineTo(x5, y1))
  let (c1, _, _) = rel_arc(x5, y1, w_r, h, st_ang, msw_ang)
  commands.push(c1)
  commands.push(LineTo(x3, 0))
  let (c2, _, _) = rel_arc(x3, 0, w_r, h, c3d4, sw_ang)
  commands.push(c2)
  commands.push(LineTo(x8, y1))
  commands.push(ClosePath)
  { commands, width, height }
}
