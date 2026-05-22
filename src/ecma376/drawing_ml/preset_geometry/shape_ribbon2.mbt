// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `ribbon2`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `ribbon2` — an upward banner ribbon: a central
/// horizontal band whose two folded tails rise above it (the vertical
/// mirror of `ribbon`).
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 16667` band thickness, `adj2 = 50000` band width). The
/// computed guides are `x2 = 5400`, `x3 = 6075`, `x4 = 7425`,
/// `x7 = 14175`, `x8 = 15525`, `x9 = 16200`, `x10 = 18900`,
/// `wd8 = 2700`, `wd32 = 675`; `y1 = 19800`, `y2 = 18000`,
/// `y3 = 12600`, `y4 = 3600`, `y6 = 20700`, `hR = 900`.
///
/// The notch folds are half/quarter-circle `arcTo` segments of radii
/// `wd32 × hR`; their endpoints land on clean guide coordinates so
/// each is emitted faithfully as an `ArcTo`.
pub fn build_ribbon2(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let rx = sx(675)
  let ry = sy(900)
  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(21600)),
    LineTo(sx(7425), sy(21600)),
    // arcTo(wd32,hR,cd4,-cd2): half-loop up to (x3,y1).
    ArcTo(rx, ry, 0, false, false, sx(6075), sy(19800)),
    LineTo(sx(6075), sy(19800)),
    // arcTo(wd32,hR,cd4,cd2): half-loop to (x8,y2).
    ArcTo(rx, ry, 0, false, true, sx(15525), sy(18000)),
    LineTo(sx(15525), sy(18000)),
    // arcTo(wd32,hR,3cd4,cd2): half-loop to (x7,y1).
    ArcTo(rx, ry, 0, false, true, sx(14175), sy(19800)),
    LineTo(sx(14175), sy(19800)),
    // arcTo(wd32,hR,3cd4,-cd2): half-loop to (r,b).
    ArcTo(rx, ry, 0, false, false, sx(21600), sy(21600)),
    LineTo(sx(21600), sy(21600)),
    LineTo(sx(18900), sy(12600)),
    LineTo(sx(21600), sy(3600)),
    LineTo(sx(16200), sy(3600)),
    LineTo(sx(16200), sy(900)),
    // arcTo(wd32,hR,0,-cd4): quarter turn up to the top edge.
    ArcTo(rx, ry, 0, false, false, sx(15525), sy(0)),
    LineTo(sx(6075), sy(0)),
    // arcTo(wd32,hR,3cd4,-cd4): quarter turn down to (x2,y4).
    ArcTo(rx, ry, 0, false, false, sx(5400), sy(900)),
    LineTo(sx(5400), sy(3600)),
    LineTo(sx(0), sy(3600)),
    LineTo(sx(2700), sy(12600)),
    ClosePath,
    // Fold shadow lines (`fill="none"` sub-paths in the spec).
    MoveTo(sx(8100), sy(18000)),
    LineTo(sx(8100), sy(20700)),
    MoveTo(sx(13500), sy(20700)),
    LineTo(sx(13500), sy(18000)),
    MoveTo(sx(5400), sy(18900)),
    LineTo(sx(5400), sy(3600)),
    MoveTo(sx(16200), sy(3600)),
    LineTo(sx(16200), sy(18900)),
  ]
  { commands, width, height }
}
