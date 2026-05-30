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
/// Now driven directly by the §20.1.10.56 wave gdLst so a custom
/// `adj1` (amplitude, `a1 = pin 0 adj1 20000`) and `adj2` (horizontal
/// skew, `a2 = pin -10000 adj2 10000`) are honoured. The vertical
/// guides are compound-fraction forms so they round identically to the
/// spec's final coordinates: `y1 = h·a1/100000`, `dy2 = y1·10/3`,
/// `y2 = y1−dy2`, `y3 = y1+dy2`, `y4 = b−y1`, `y5 = y4−dy2`,
/// `y6 = y4+dy2`. The horizontal skew uses the spec `?:` selection of
/// the per-edge offset `of2 = w·a2/50000`.
pub fn build_wave(
  width : Int,
  height : Int,
  adj1~ : Int = 12500,
  adj2~ : Int = 0,
) -> ShapeGeometry {
  let a1 = pin_int(adj1, 0, 20000)
  let a2 = pin_int(adj2, -10000, 10000)
  // Vertical guides as single fractions of `height` to match the
  // spec's final-coordinate rounding (e.g. y4 = b−y1 rounds the whole
  // expression, not `height − trunc(y1)`).
  let y1 = fraction(height, a1, 100000)
  let y2 = fraction(height, -7 * a1, 300000)
  let y3 = fraction(height, 13 * a1, 300000)
  let y4 = fraction(height, 100000 - a1, 100000)
  let y5 = fraction(height, 300000 - 13 * a1, 300000)
  let y6 = fraction(height, 300000 + 7 * a1, 300000)
  // §20.1.9.11 `?:` — `dx2 = of2>0 ? 0 : of2`, `dx5 = of2>0 ? of2 : 0`.
  let of2 = fraction(width, a2, 50000)
  let dx2 = if of2 > 0 { 0 } else { of2 }
  let dx5 = if of2 > 0 { of2 } else { 0 }
  let x2 = -dx2
  let x5 = width - dx5
  let dx3 = (dx2 + x5) / 3
  let x3 = x2 + dx3
  let x4 = (x3 + x5) / 2
  let x6 = dx5
  let x10 = width + dx2
  let x7 = x6 + dx3
  let x8 = (x7 + x10) / 2
  let commands : Array[PathCommand] = [
    MoveTo(x2, y1),
    CurveTo(x3, y2, x4, y3, x5, y1),
    LineTo(x10, y4),
    CurveTo(x8, y6, x7, y5, x6, y4),
    ClosePath,
  ]
  { commands, width, height }
}
