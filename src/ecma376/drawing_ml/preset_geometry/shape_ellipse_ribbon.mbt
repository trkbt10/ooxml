// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `ellipseRibbon`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `ellipseRibbon` — a banner ribbon whose central band
/// is bowed along an ellipse arc, with two folded tails dropping
/// below it.
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 25000` band curvature, `adj2 = 50000` band width,
/// `adj3 = 12500` tail height). The computed guides are `x2 = 5400`,
/// `x3 = 8100`, `x4 = 13500`, `x5 = 16200`, `x6 = 18900`,
/// `wd8 = 2700`; `y1 = 2532`, `y2 = 9281`, `y3 = 4725`, `y5 = 18225`,
/// `y6 = 20925`, `rh = 16200`; control points `cx1 = 4050`,
/// `cy1 = 2025`, `cx2 = 17550`, `cy3 = 6075`, `cx4 = 2700`,
/// `cy4 = 17550`, `cx5 = 18900`, `cy6 = 22275`.
///
/// The bowed edges are quadratic Bézier (`quadBezTo`) segments mapped
/// directly to `QuadTo`; the tail folds are straight `lnTo` notches.
pub fn build_ellipse_ribbon(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(0)),
    QuadTo(sx(4050), sy(2025), sx(8100), sy(2532)),
    LineTo(sx(5400), sy(4725)),
    QuadTo(sx(10800), sy(6075), sx(16200), sy(4725)),
    LineTo(sx(13500), sy(2532)),
    QuadTo(sx(17550), sy(2025), sx(21600), sy(0)),
    LineTo(sx(18900), sy(9281)),
    LineTo(sx(21600), sy(16200)),
    QuadTo(sx(18900), sy(17550), sx(16200), sy(18225)),
    LineTo(sx(16200), sy(20925)),
    QuadTo(sx(10800), sy(22275), sx(5400), sy(20925)),
    LineTo(sx(5400), sy(18225)),
    QuadTo(sx(2700), sy(17550), sx(0), sy(16200)),
    LineTo(sx(2700), sy(9281)),
    ClosePath,
    // Front band panel (`fill="darkenLess"` sub-path in the spec).
    MoveTo(sx(8100), sy(5232)),
    LineTo(sx(8100), sy(2532)),
    LineTo(sx(5400), sy(4725)),
    QuadTo(sx(10800), sy(6075), sx(16200), sy(4725)),
    LineTo(sx(13500), sy(2532)),
    LineTo(sx(13500), sy(5232)),
    QuadTo(sx(10800), sy(5568), sx(8100), sy(5232)),
    ClosePath,
    // Fold shadow lines (`fill="none"` sub-paths in the spec).
    MoveTo(sx(5400), sy(18225)),
    LineTo(sx(5400), sy(4725)),
    MoveTo(sx(16200), sy(4725)),
    LineTo(sx(16200), sy(18225)),
    MoveTo(sx(8100), sy(2532)),
    LineTo(sx(8100), sy(5232)),
    MoveTo(sx(13500), sy(5232)),
    LineTo(sx(13500), sy(2532)),
  ]
  { commands, width, height }
}
