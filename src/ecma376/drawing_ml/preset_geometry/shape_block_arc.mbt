// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `blockArc`.

///|
/// §20.1.10.56 `blockArc` — a thick curved band: an outer arc and a
/// concentric inner arc joined by two radial straight edges.
///
/// Spec path: `moveTo(x1,y1)` → `arcTo(wd2,hd2,stAng,swAng)` (outer
/// edge) → `lnTo(x2,y2)` (radial edge) → `arcTo(iwd2,ihd2,istAng,
/// iswAng)` (inner edge swept the opposite way) → `close` (second
/// radial edge).
///
/// The default `avLst` is `adj1 = 10800000` (outer start 180°),
/// `adj2 = 0` (inner start 0°), `adj3 = 25000` (band thickness `dr`).
/// With those values `swAng` normalises to `10800000` (a 180° band
/// across the top half) and `iswAng = -swAng`.
pub fn build_block_arc(
  width : Int,
  height : Int,
  adj1? : Int = 10800000,
  adj2? : Int = 0,
  adj3? : Int = 25000,
) -> ShapeGeometry {
  // §20.1.10.56 blockArc: stAng = pin 0 adj1 21599999, istAng =
  // pin 0 adj2 21599999 (ECMA angle units); ring thickness
  // dr = ss·a3/100000 with a3 = pin 0 adj3 50000.
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  let dr = percent(min_dim(width, height), pin_int(adj3, 0, 50000))
  let irx = rx - dr
  let iry = ry - dr
  let st_ang = pin_int(adj1, 0, 21599999)
  let ist_ang = pin_int(adj2, 0, 21599999)
  // swAng = istAng - stAng, normalised into (0, 21600000].
  let raw = ist_ang - st_ang
  let sw_ang = if raw <= 0 { raw + 21600000 } else { raw }
  let isw_ang = -sw_ang
  let (x1, y1) = ellipse_point(cx, cy, rx, ry, st_ang)
  let (x2, y2) = ellipse_point(cx, cy, irx, iry, ist_ang)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x1, y1))
  commands.push(arc_to_command(cx, cy, rx, ry, st_ang, sw_ang))
  commands.push(LineTo(x2, y2))
  commands.push(arc_to_command(cx, cy, irx, iry, ist_ang, isw_ang))
  commands.push(ClosePath)
  { commands, width, height }
}
