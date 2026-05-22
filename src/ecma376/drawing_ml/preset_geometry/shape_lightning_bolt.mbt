// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `lightningBolt`.

///|
/// §20.1.10.56 `lightningBolt` — a zigzag lightning bolt polygon.
///
/// The spec path is a closed eleven-vertex polygon expressed with
/// literal `<pt>` coordinates in a 21600×21600 frame. Each vertex is
/// scaled into the pixel bounding box via `fraction`.
pub fn build_lightning_bolt(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  // Literal spec polygon vertices (21600-unit frame).
  let pts : Array[(Int, Int)] = [
    (8472, 0),
    (12860, 6080),
    (11050, 6797),
    (16577, 12007),
    (14767, 12877),
    (21600, 21600),
    (10012, 14915),
    (12222, 13987),
    (5022, 9705),
    (7602, 8382),
    (0, 3890),
  ]
  let commands : Array[PathCommand] = []
  for i in 0..<pts.length() {
    let (x, y) = pts[i]
    if i == 0 {
      commands.push(MoveTo(sx(x), sy(y)))
    } else {
      commands.push(LineTo(sx(x), sy(y)))
    }
  }
  commands.push(ClosePath)
  { commands, width, height }
}
