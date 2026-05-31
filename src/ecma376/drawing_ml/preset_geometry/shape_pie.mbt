// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `pie`.

///|
/// §20.1.10.56 `pie` — a pie slice: an elliptical arc from `stAng` to
/// `enAng`, then a line back to the centre, closed.
///
/// Spec path: `moveTo(x1,y1)` → `arcTo(wd2,hd2,stAng,swAng)` →
/// `lnTo(hc,vc)` → `close`. The default `avLst` is `adj1 = 0`,
/// `adj2 = 16200000` (270°), so the default slice spans 0°→270°.
pub fn build_pie(
  width : Int,
  height : Int,
  adj1? : Int = 0,
  adj2? : Int = 16200000,
) -> ShapeGeometry {
  // §20.1.10.56 pie: stAng = adj1, enAng = adj2 (ECMA angle units,
  // 60000ths of a degree); swAng = enAng − stAng.
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  let st_ang = adj1
  let en_ang = adj2
  let sw_ang = en_ang - st_ang
  let (x1, y1) = ellipse_point(cx, cy, rx, ry, st_ang)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x1, y1))
  commands.push(arc_to_command(cx, cy, rx, ry, st_ang, sw_ang))
  commands.push(LineTo(cx, cy))
  commands.push(ClosePath)
  { commands, width, height }
}
