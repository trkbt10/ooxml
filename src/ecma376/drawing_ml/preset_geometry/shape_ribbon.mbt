// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `ribbon`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `ribbon` — a downward banner ribbon: a central
/// horizontal band with two folded tails dropping below it.
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 16667` band thickness, `adj2 = 50000` band width). The
/// computed guides are `x2 = 5400`, `x3 = 6075`, `x4 = 7425`,
/// `x7 = 14175`, `x8 = 15525`, `x9 = 16200`, `x10 = 18900`,
/// `wd8 = 2700`, `wd32 = 675`; `y1 = 1800`, `y2 = 3600`, `y3 = 9000`,
/// `y4 = 18000`, `y5 = 20700`, `hR = 900`.
///
/// The notch folds are quarter/half-circle `arcTo` segments of radii
/// `wd32 × hR`. They round the corners where the band meets the
/// folded tails; their endpoints land on clean guide coordinates so
/// each arc is emitted faithfully as an `ArcTo` from the spec start
/// point to the spec end point.
pub fn build_ribbon(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  // `arcTo` radii: wd32 horizontally, hR vertically.
  let rx = sx(675)
  let ry = sy(900)
  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(0)),
    LineTo(sx(7425), sy(0)),
    // arcTo(wd32,hR,3cd4,cd2): half-loop to (x3,y1).
    ArcTo(rx, ry, 0, false, true, sx(6075), sy(1800)),
    LineTo(sx(6075), sy(1800)),
    // arcTo(wd32,hR,3cd4,-cd2): half-loop to (x8,y2).
    ArcTo(rx, ry, 0, false, false, sx(15525), sy(3600)),
    LineTo(sx(15525), sy(3600)),
    // arcTo(wd32,hR,cd4,-cd2): half-loop to (x7,y1).
    ArcTo(rx, ry, 0, false, false, sx(14175), sy(1800)),
    LineTo(sx(14175), sy(1800)),
    // arcTo(wd32,hR,cd4,cd2): half-loop to (r,t).
    ArcTo(rx, ry, 0, false, true, sx(21600), sy(0)),
    LineTo(sx(21600), sy(0)),
    LineTo(sx(18900), sy(9000)),
    LineTo(sx(21600), sy(18000)),
    LineTo(sx(16200), sy(18000)),
    LineTo(sx(16200), sy(20700)),
    // arcTo(wd32,hR,0,cd4): quarter turn to (x3,b).
    ArcTo(rx, ry, 0, false, true, sx(15525), sy(21600)),
    LineTo(sx(15525), sy(21600)),
    LineTo(sx(6075), sy(21600)),
    // arcTo(wd32,hR,cd4,cd4): quarter turn to (x2,y4).
    ArcTo(rx, ry, 0, false, true, sx(5400), sy(20700)),
    LineTo(sx(5400), sy(18000)),
    LineTo(sx(0), sy(18000)),
    LineTo(sx(2700), sy(9000)),
    ClosePath,
    // Fold shadow lines (`fill="none"` sub-paths in the spec).
    MoveTo(sx(8100), sy(900)),
    LineTo(sx(8100), sy(3600)),
    MoveTo(sx(13500), sy(3600)),
    LineTo(sx(13500), sy(900)),
    MoveTo(sx(5400), sy(18000)),
    LineTo(sx(5400), sy(2700)),
    MoveTo(sx(16200), sy(2700)),
    LineTo(sx(16200), sy(18000)),
  ]
  { commands, width, height }
}
