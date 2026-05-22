// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `horizontalScroll`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `horizontalScroll` — a parchment scroll with a rolled
/// curl across its top edge.
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj = 12500` curl size). With `ss = 21600` the computed guides
/// are `ch = 2700` (curl diameter), `ch2 = 1350`, `ch4 = 675`,
/// `y3 = 4050`, `y4 = 5400`, `y6 = 18900`, `y7 = 20250`,
/// `x3 = 18900`, `x4 = 20250`.
///
/// The body outline mixes straight `lnTo` segments with quarter- and
/// half-circle `arcTo` rolls of radii `ch2` / `ch4`; a second closed
/// sub-path draws the small curled-corner disc. Every arc endpoint
/// lands on a clean guide coordinate, so each is emitted faithfully
/// as an `ArcTo`.
pub fn build_horizontal_scroll(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let r2x = sx(1350) // ch2 radius, x component
  let r2y = sy(1350) // ch2 radius, y component
  let r4x = sx(675) // ch4 radius, x component
  let r4y = sy(675) // ch4 radius, y component
  let commands : Array[PathCommand] = [
    // Scroll body.
    MoveTo(sx(21600), sy(1350)),
    ArcTo(r2x, r2y, 0, false, true, sx(20250), sy(2700)),
    LineTo(sx(20250), sy(1350)),
    ArcTo(r4x, r4y, 0, false, true, sx(18900), sy(1350)),
    LineTo(sx(18900), sy(2700)),
    LineTo(sx(1350), sy(2700)),
    ArcTo(r2x, r2y, 0, false, false, sx(0), sy(4050)),
    LineTo(sx(0), sy(20250)),
    ArcTo(r2x, r2y, 0, false, false, sx(2700), sy(20250)),
    LineTo(sx(2700), sy(18900)),
    LineTo(sx(20250), sy(18900)),
    ArcTo(r2x, r2y, 0, false, false, sx(21600), sy(17550)),
    ClosePath,
    // Curled-corner disc (`fill="darkenLess"` sub-path in the spec).
    MoveTo(sx(1350), sy(5400)),
    ArcTo(r2x, r2y, 0, false, false, sx(2700), sy(4050)),
    ArcTo(r4x, r4y, 0, false, false, sx(1350), sy(4050)),
    ClosePath,
  ]
  { commands, width, height }
}
