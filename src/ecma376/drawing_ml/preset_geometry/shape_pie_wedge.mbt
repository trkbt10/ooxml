// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `pieWedge`.

///|
/// §20.1.10.56 `pieWedge` — a quarter-ellipse wedge filling the
/// bottom-right corner of the bounding box.
///
/// Spec path: `moveTo(l,b)` → `arcTo(w,h,cd2,cd4)` → `lnTo(r,b)` →
/// `close`. The `arcTo` radii are the full width and height, so the
/// arc is a quarter of the ellipse centred at `(r,b)` — it starts at
/// the bottom-left `(l,b)` (angle 180°) and sweeps 90° clockwise to the
/// top-right `(r,t)`. The straight segments `(r,t)`→`(r,b)` and the
/// closing `(r,b)`→`(l,b)` complete the wedge. `pieWedge` has no
/// adjustable guides.
pub fn build_pie_wedge(width : Int, height : Int) -> ShapeGeometry {
  let commands : Array[PathCommand] = []
  // Start at the bottom-left corner.
  commands.push(MoveTo(0, height))
  // Quarter-ellipse arc (radii = full w/h) from bottom-left to
  // top-right, sweeping clockwise.
  commands.push(ArcTo(width, height, 0, false, true, width, 0))
  // Down the right edge to the bottom-right corner.
  commands.push(LineTo(width, height))
  commands.push(ClosePath)
  { commands, width, height }
}
