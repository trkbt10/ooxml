// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `arc`.

///|
/// §20.1.10.56 `arc` — an open elliptical arc outline. Unlike `pie`
/// and `chord` this shape has no closing segment: the spec's stroked
/// path is simply `moveTo(x1,y1)` → `arcTo(wd2,hd2,stAng,swAng)` with
/// no `close`.
///
/// The default `avLst` is `adj1 = 16200000` (start 270°), `adj2 = 0`
/// (end 0°). The swept angle is `enAng - stAng` normalised into
/// `[0, 21600000)`: `0 - 16200000 = -16200000`, plus a full turn gives
/// `5400000` (90°). The default arc therefore sweeps 270°→360°, i.e.
/// the bottom-right quarter of the bounding ellipse.
pub fn build_arc(
  width : Int,
  height : Int,
  adj1? : Int = 16200000,
  adj2? : Int = 0,
) -> ShapeGeometry {
  // §20.1.10.56 arc: stAng = adj1, enAng = adj2; swAng = enAng − stAng
  // normalised into [0, 21600000) so the open arc sweeps clockwise.
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  let st_ang = adj1
  let en_ang = adj2
  let raw = en_ang - st_ang
  // swAng is normalised positive (full revolution = 21600000).
  let sw_ang = if raw < 0 { raw + 21600000 } else { raw }
  let (x1, y1) = ellipse_point(cx, cy, rx, ry, st_ang)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x1, y1))
  commands.push(arc_to_command(cx, cy, rx, ry, st_ang, sw_ang))
  // No ClosePath — `arc` is an open outline.
  { commands, width, height }
}
