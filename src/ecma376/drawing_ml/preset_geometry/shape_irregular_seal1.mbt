// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `irregularSeal1`.

///|
/// §20.1.10.56 `irregularSeal1` — a starburst / explosion polygon with
/// an irregular spiky outline.
///
/// The spec path is a closed twenty-four-vertex polygon with literal
/// `<pt>` coordinates in a 21600×21600 frame. Each vertex is scaled
/// into the pixel bounding box via `fraction`.
pub fn build_irregular_seal1(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  // Literal spec polygon vertices (21600-unit frame).
  let pts : Array[(Int, Int)] = [
    (10800, 5800),
    (14522, 0),
    (14155, 5325),
    (18380, 4457),
    (16702, 7315),
    (21097, 8137),
    (17607, 10475),
    (21600, 13290),
    (16837, 12942),
    (18145, 18095),
    (14020, 14457),
    (13247, 19737),
    (10532, 14935),
    (8485, 21600),
    (7715, 15627),
    (4762, 17617),
    (5667, 13937),
    (135, 14587),
    (3722, 11775),
    (0, 8615),
    (4627, 7617),
    (370, 2295),
    (7312, 6320),
    (8352, 2295),
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
