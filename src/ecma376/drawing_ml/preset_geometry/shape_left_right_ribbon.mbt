// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `leftRightRibbon`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `leftRightRibbon` — a horizontal ribbon pointing both
/// left and right, pinched by a central knot.
///
/// Spec path (21600×21600 frame) with the default `avLst`
/// (`adj1 = 50000` band thickness, `adj2 = 50000` arrowhead depth,
/// `adj3 = 16667` knot height). The computed guides are `x1 = 10125`,
/// `x4 = 11475`, `wd32 = 675`; `ly1 = 3599`, `ly2 = 8999`,
/// `ly3 = 14399`, `ly4 = 17998`, `ry1 = 3602`, `ry2 = 7201`,
/// `ry3 = 12601`, `ry4 = 18001`, `hR = 900`.
///
/// The central knot is two consecutive half-circle `arcTo` segments
/// of radii `wd32 × hR` forming an S-bend; the front knot panel is
/// emitted as a `fill="darkenLess"` sub-path. The bottom knot fold is
/// a quarter-circle arc. Endpoints land on clean guide coordinates so
/// each arc is emitted faithfully as an `ArcTo`.
pub fn build_left_right_ribbon(width : Int, height : Int) -> ShapeGeometry {
  fn sx(v : Int) -> Int {
    fraction(width, v, 21600)
  }

  fn sy(v : Int) -> Int {
    fraction(height, v, 21600)
  }

  let rx = sx(675)
  let ry = sy(900)
  let commands : Array[PathCommand] = [
    MoveTo(sx(0), sy(8999)),
    LineTo(sx(10125), sy(0)),
    LineTo(sx(10125), sy(3599)),
    LineTo(sx(10800), sy(3599)),
    // Knot S-bend: arcTo(wd32,hR,3cd4,cd2) then arcTo(...,3cd4,-cd2).
    ArcTo(rx, ry, 0, false, true, sx(10800), sy(5399)),
    ArcTo(rx, ry, 0, false, false, sx(10800), sy(7199)),
    LineTo(sx(11475), sy(7201)),
    LineTo(sx(11475), sy(3602)),
    LineTo(sx(21600), sy(12601)),
    LineTo(sx(11475), sy(21600)),
    LineTo(sx(11475), sy(18001)),
    LineTo(sx(10800), sy(18001)),
    // Bottom knot fold: arcTo(wd32,hR,cd4,cd4) quarter turn.
    ArcTo(rx, ry, 0, false, true, sx(10125), sy(17101)),
    LineTo(sx(10125), sy(14399)),
    LineTo(sx(10125), sy(17998)),
    ClosePath,
    // Front knot panel (`fill="darkenLess"` sub-path in the spec).
    MoveTo(sx(11475), sy(4499)),
    ArcTo(rx, ry, 0, false, true, sx(10800), sy(5399)),
    ArcTo(rx, ry, 0, false, false, sx(10800), sy(7199)),
    LineTo(sx(11475), sy(7201)),
    ClosePath,
  ]
  { commands, width, height }
}
