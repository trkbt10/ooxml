// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `irregularSeal2`.

///|
/// §20.1.10.56 `irregularSeal2` — a second starburst / explosion
/// polygon variant with an irregular spiky outline.
///
/// The spec path is a closed twenty-eight-vertex polygon with literal
/// `<pt>` coordinates in a 21600×21600 frame. Each vertex is scaled
/// into the pixel bounding box via `fraction`.
pub fn build_irregular_seal2(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  // Literal spec polygon vertices (21600-unit frame).
  let pts : Array[(Int, Int)] = [
    (11462, 4342),
    (14790, 0),
    (14525, 5777),
    (18007, 3172),
    (16380, 6532),
    (21600, 6645),
    (16985, 9402),
    (18270, 11290),
    (16380, 12310),
    (18877, 15632),
    (14640, 14350),
    (14942, 17370),
    (12180, 15935),
    (11612, 18842),
    (9872, 17370),
    (8700, 19712),
    (7527, 18125),
    (4917, 21600),
    (4805, 18240),
    (1285, 17825),
    (3330, 15370),
    (0, 12877),
    (3935, 11592),
    (1172, 8270),
    (5372, 7817),
    (4502, 3625),
    (8550, 6382),
    (9722, 1887),
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
