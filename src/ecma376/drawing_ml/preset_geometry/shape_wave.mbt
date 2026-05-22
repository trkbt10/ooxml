// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `wave`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `wave` — a rectangle whose top and bottom edges are a
/// single-period sine wave. The left/right edges stay vertical so the
/// silhouette is a wavy band.
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 12500` wave amplitude, `adj2 = 0` skew). The horizontal
/// skew guide `adj2` is zero, so all x-guides collapse to plain frame
/// positions: `x2 = 0`, `x5 = 21600`, `x3 = 7200`, `x4 = 14400` and
/// `x6/x7/x8/x10` mirror them on the bottom edge. The vertical guides
/// are `y1 = 2700`, `y4 = 18900` (the wave baselines) with control
/// offsets `y2 = -6300`, `y3 = 11700`, `y5 = 9900`, `y6 = 27900`.
///
/// The top edge is a single cubic Bézier from `(x2,y1)` to `(x5,y1)`
/// with control points `(x3,y2)` and `(x4,y3)`; the bottom edge
/// mirrors it from `(x10,y4)` back to `(x6,y4)`.
pub fn build_wave(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(2700)),
    CurveTo(sx(7200), sy(-6300), sx(14400), sy(11700), sx(21600), sy(2700)),
    LineTo(sx(21600), sy(18900)),
    CurveTo(sx(14400), sy(27900), sx(7200), sy(9900), sx(0), sy(18900)),
    ClosePath,
  ]
  { commands, width, height }
}
