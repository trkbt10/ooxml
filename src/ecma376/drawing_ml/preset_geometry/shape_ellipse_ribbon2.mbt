// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `ellipseRibbon2`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `ellipseRibbon2` — a banner ribbon bowed along an
/// ellipse arc whose two folded tails rise above the central band
/// (the vertical mirror of `ellipseRibbon`).
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 25000` band curvature, `adj2 = 50000` band width,
/// `adj3 = 12500` tail height). The computed guides are `x2 = 5400`,
/// `x3 = 8100`, `x4 = 13500`, `x5 = 16200`, `x6 = 18900`,
/// `wd8 = 2700`; `y1 = 19068`, `y2 = 12319`, `y3 = 16875`,
/// `y5 = 3375`, `y6 = 675`, `q1 = 5400`; control points
/// `cx1 = 4050`, `cy1 = 19575`, `cx2 = 17550`, `cy3 = 15525`,
/// `cx4 = 2700`, `cy4 = 4050`, `cx5 = 18900`, `cy6 = -675`.
///
/// The bowed edges are quadratic Bézier (`quadBezTo`) segments mapped
/// directly to `QuadTo`; the tail folds are straight `lnTo` notches.
pub fn build_ellipse_ribbon2(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(21600)),
    QuadTo(sx(4050), sy(19575), sx(8100), sy(19068)),
    LineTo(sx(5400), sy(16875)),
    QuadTo(sx(10800), sy(15525), sx(16200), sy(16875)),
    LineTo(sx(13500), sy(19068)),
    QuadTo(sx(17550), sy(19575), sx(21600), sy(21600)),
    LineTo(sx(18900), sy(12319)),
    LineTo(sx(21600), sy(5400)),
    QuadTo(sx(18900), sy(4050), sx(16200), sy(3375)),
    LineTo(sx(16200), sy(675)),
    QuadTo(sx(10800), sy(-675), sx(5400), sy(675)),
    LineTo(sx(5400), sy(3375)),
    QuadTo(sx(2700), sy(4050), sx(0), sy(5400)),
    LineTo(sx(2700), sy(12319)),
    ClosePath,
    // Front band panel (`fill="darkenLess"` sub-path in the spec).
    MoveTo(sx(8100), sy(16368)),
    LineTo(sx(8100), sy(19068)),
    LineTo(sx(5400), sy(16875)),
    QuadTo(sx(10800), sy(15525), sx(16200), sy(16875)),
    LineTo(sx(13500), sy(19068)),
    LineTo(sx(13500), sy(16368)),
    QuadTo(sx(10800), sy(16032), sx(8100), sy(16368)),
    ClosePath,
    // Fold shadow lines (`fill="none"` sub-paths in the spec).
    MoveTo(sx(5400), sy(16875)),
    LineTo(sx(5400), sy(3375)),
    MoveTo(sx(16200), sy(3375)),
    LineTo(sx(16200), sy(16875)),
    MoveTo(sx(8100), sy(16368)),
    LineTo(sx(8100), sy(19068)),
    MoveTo(sx(13500), sy(19068)),
    LineTo(sx(13500), sy(16368)),
  ]
  { commands, width, height }
}
