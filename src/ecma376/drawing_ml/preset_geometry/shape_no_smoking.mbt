// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `noSmoking`.

///|
/// §20.1.10.56 `noSmoking` — the prohibition ("no") symbol: a circular
/// ring with a diagonal bar crossing the inner opening.
///
/// FAITHFUL transcription of the spec preset path. The outer ring is
/// the full ellipse (four quarter `arcTo` edges, radii `wd2 × hd2`);
/// the diagonal bar is the spec's two arc-bounded slices on the inner
/// ellipse (radii `iwd2 × ihd2`, `iwd2 = wd2 − dr`, `ihd2 = hd2 − dr`,
/// `dr = ss·a/100000`). Every guide is a 1:1 transcription of the spec
/// `gdLst` using the verified primitives: `at2` (diagonal angle and
/// the `dang` half-width), `cos`/`sin` → `gcos`/`gsin`, `mod` → `gmod`.
/// The bar endpoints are `(hc ± dx1, vc ± dy1)` with `dx1 = n1·cos
/// stAng1`, `dy1 = n1·sin stAng1`, `n1 = iwd2·ihd2/mod(ct1,st1)`. All
/// arcs are emitted through the verified `rel_arc` helper, so the
/// geometry is correct by construction. Default `adj = 18750`.
pub fn build_no_smoking(
  width : Int,
  height : Int,
  adj~ : Int = 18750,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let w = width
  let h = height
  let wd2 = width / 2
  let hd2 = height / 2
  let hc = width / 2
  let vc = height / 2
  let cd2 = 10800000
  let cd4 = 5400000
  let c3d4 = 16200000
  // Guide chain — faithful transcription of the spec gdLst.
  let a = pin_int(adj, 0, 50000)
  let dr = fraction(ss, a, 100000) // */ ss a 100000
  let iwd2 = wd2 - dr // +- wd2 0 dr
  let ihd2 = hd2 - dr // +- hd2 0 dr
  let ang = at2(w, h) // at2 w h
  let ct = gcos(ihd2, ang) // cos ihd2 ang
  let st = gsin(iwd2, ang) // sin iwd2 ang
  let m = gmod(ct, st, 0) // mod ct st 0
  let n = if m == 0 { 0 } else { fraction(iwd2, ihd2, m) } // */ iwd2 ihd2 m
  let drd2 = dr / 2 // */ dr 1 2
  let dang = at2(n, drd2) // at2 n drd2
  let two_dang = dang * 2 // */ dang 2 1
  let sw_ang = -10800000 + two_dang // +- -10800000 2dang 0
  let st_ang1 = ang - dang // +- t3 0 dang  (t3 = at2 w h = ang)
  let st_ang2 = st_ang1 - cd2 // +- stAng1 0 cd2
  let ct1 = gcos(ihd2, st_ang1) // cos ihd2 stAng1
  let st1 = gsin(iwd2, st_ang1) // sin iwd2 stAng1
  let m1 = gmod(ct1, st1, 0) // mod ct1 st1 0
  let n1 = if m1 == 0 { 0 } else { fraction(iwd2, ihd2, m1) } // */ iwd2 ihd2 m1
  let dx1 = gcos(n1, st_ang1) // cos n1 stAng1
  let dy1 = gsin(n1, st_ang1) // sin n1 stAng1
  let x1 = hc + dx1 // +- hc dx1 0
  let y1 = vc + dy1 // +- vc dy1 0
  let x2 = hc - dx1 // +- hc 0 dx1
  let y2 = vc - dy1 // +- vc 0 dy1
  let commands : Array[PathCommand] = []
  // Outer ring — full ellipse from the left point, four quarter arcs.
  commands.push(MoveTo(0, vc))
  let (o1, ax, ay) = rel_arc(0, vc, wd2, hd2, cd2, cd4)
  commands.push(o1)
  let (o2, bx, by) = rel_arc(ax, ay, wd2, hd2, c3d4, cd4)
  commands.push(o2)
  let (o3, cx, cy) = rel_arc(bx, by, wd2, hd2, 0, cd4)
  commands.push(o3)
  let (o4, _, _) = rel_arc(cx, cy, wd2, hd2, cd4, cd4)
  commands.push(o4)
  commands.push(ClosePath)
  // Bar slice 1 — inner-ellipse arc from (x1, y1).
  commands.push(MoveTo(x1, y1))
  let (s1, _, _) = rel_arc(x1, y1, iwd2, ihd2, st_ang1, sw_ang)
  commands.push(s1)
  commands.push(ClosePath)
  // Bar slice 2 — inner-ellipse arc from (x2, y2).
  commands.push(MoveTo(x2, y2))
  let (s2, _, _) = rel_arc(x2, y2, iwd2, ihd2, st_ang2, sw_ang)
  commands.push(s2)
  commands.push(ClosePath)
  { commands, width, height }
}
