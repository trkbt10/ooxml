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
pub fn build_double_wave(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(1350)),
    CurveTo(sx(3600), sy(-3150), sx(7200), sy(5850), sx(10800), sy(1350)),
    CurveTo(sx(14400), sy(-3150), sx(18000), sy(5850), sx(21600), sy(1350)),
    LineTo(sx(21600), sy(20250)),
    CurveTo(sx(18000), sy(24750), sx(14400), sy(15750), sx(10800), sy(20250)),
    CurveTo(sx(7200), sy(24750), sx(3600), sy(15750), sx(0), sy(20250)),
    ClosePath,
  ]
  { commands, width, height }
}
