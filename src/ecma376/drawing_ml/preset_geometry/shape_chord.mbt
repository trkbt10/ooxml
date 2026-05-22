// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `chord`.

///|
/// §20.1.10.56 `chord` — a circle segment: an elliptical arc from
/// `stAng` to `enAng`, closed directly by a straight chord between the
/// two arc endpoints (no line through the centre, unlike `pie`).
///
/// Spec path: `moveTo(x1,y1)` → `arcTo(wd2,hd2,stAng,swAng)` →
/// `close`. The closing `ClosePath` draws the chord back to the start.
/// The default `avLst` is `adj1 = 2700000` (45°), `adj2 = 16200000`
/// (270°), so the default segment spans 45°→270°.
pub fn build_chord(width : Int, height : Int) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  let st_ang = 2700000
  let en_ang = 16200000
  let sw_ang = en_ang - st_ang
  let (x1, y1) = ellipse_point(cx, cy, rx, ry, st_ang)
  let commands : Array[PathCommand] = []
  commands.push(MoveTo(x1, y1))
  commands.push(arc_to_command(cx, cy, rx, ry, st_ang, sw_ang))
  commands.push(ClosePath)
  { commands, width, height }
}
