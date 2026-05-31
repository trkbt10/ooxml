// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `doubleWave`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `doubleWave` — a rectangle whose top and bottom edges
/// each carry a double-period sine wave.
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 6250` wave amplitude, `adj2 = 0` skew). With the skew
/// guide zero the x-guides collapse to plain frame positions:
/// `x2 = 0`, `x8 = 21600`, `x5 = 10800` (midpoint), `x3 = 3600`,
/// `x4 = 7200`, `x6 = 14400`, `x7 = 18000`, and `x9..x15` mirror them
/// on the bottom edge. The vertical guides are `y1 = 1350`,
/// `y4 = 20250` (baselines) with control offsets `y2 = -3150`,
/// `y3 = 5850`, `y5 = 15750`, `y6 = 24750`.
///
/// The top edge is two consecutive cubic Béziers (one per period);
/// the bottom edge mirrors them back to the left.
/// Now driven by the §20.1.10.56 doubleWave gdLst: `adj1` = amplitude
/// (`a1 = pin 0 adj1 12500`), `adj2` = horizontal skew (`a2 = pin
/// -10000 adj2 10000`). The vertical guides share `wave`'s form
/// (`dy2 = y1·10/3`); the horizontal guides split each of the two
/// periods into thirds/halves per the spec, with the `?:` skew offset
/// `of2 = w·a2/50000`.
pub fn build_double_wave(
  width : Int,
  height : Int,
  adj1? : Int = 6250,
  adj2? : Int = 0,
) -> ShapeGeometry {
  let a1 = pin_int(adj1, 0, 12500)
  let a2 = pin_int(adj2, -10000, 10000)
  let y1 = fraction(height, a1, 100000)
  let y2 = fraction(height, -7 * a1, 300000)
  let y3 = fraction(height, 13 * a1, 300000)
  let y4 = fraction(height, 100000 - a1, 100000)
  let y5 = fraction(height, 300000 - 13 * a1, 300000)
  let y6 = fraction(height, 300000 + 7 * a1, 300000)
  let of2 = fraction(width, a2, 50000)
  let dx2 = if of2 > 0 { 0 } else { of2 }
  let dx8 = if of2 > 0 { of2 } else { 0 }
  let x2 = -dx2
  let x8 = width - dx8
  let dx3 = (dx2 + x8) / 6
  let dx4 = (dx2 + x8) / 3
  let x3 = x2 + dx3
  let x4 = x2 + dx4
  let x5 = (x2 + x8) / 2
  let x6 = x5 + dx3
  let x7 = (x6 + x8) / 2
  let x9 = dx8
  let x15 = width + dx2
  let x10 = x9 + dx3
  let x11 = x9 + dx4
  let x12 = (x9 + x15) / 2
  let x13 = x12 + dx3
  let x14 = (x13 + x15) / 2
  let commands : Array[PathCommand] = [
    MoveTo(x2, y1),
    CurveTo(x3, y2, x4, y3, x5, y1),
    CurveTo(x6, y2, x7, y3, x8, y1),
    LineTo(x15, y4),
    CurveTo(x14, y6, x13, y5, x12, y4),
    CurveTo(x11, y6, x10, y5, x9, y4),
    ClosePath,
  ]
  { commands, width, height }
}
