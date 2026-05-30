// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `donut`.
//
// One preset shape per file. The generator materialises the spec
// preset path scaled into the integer frame `[0, width] × [0, height]`.
// Dispatched from `build_geometry` and reported by `supports`.

///|
/// §20.1.10.56 `donut` — a ring (annulus): a full outer ellipse with a
/// concentric full inner ellipse punched out.
///
/// Spec path: the outer boundary is four quarter `arcTo` commands over
/// `wd2`/`hd2`; the inner boundary is four quarter `arcTo` commands
/// over `iwd2`/`ihd2` swept the opposite way. The default `adj` guide
/// is 25000 — the ring thickness `dr` is `adj` percent of the shorter
/// side (`ss`). Each full ellipse is emitted here as two 180° ArcTo
/// commands so the `large_arc` flag stays false (matching
/// `build_ellipse`).
pub fn build_donut(width : Int, height : Int, adj~ : Int = 25000) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let rx = width / 2
  let ry = height / 2
  // §20.1.10.56 donut: a = pin 0 adj 50000; ring thickness
  // dr = ss·a/100000 (adj default 25000).
  let dr = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let irx = rx - dr
  let iry = ry - dr
  let commands : Array[PathCommand] = []
  // Outer ellipse — clockwise, top-half then bottom-half.
  commands.push(MoveTo(cx - rx, cy))
  commands.push(ArcTo(rx, ry, 0, false, true, cx + rx, cy))
  commands.push(ArcTo(rx, ry, 0, false, true, cx - rx, cy))
  commands.push(ClosePath)
  // Inner ellipse — counter-clockwise so an even-odd / non-zero fill
  // leaves the ring hollow.
  commands.push(MoveTo(cx - irx, cy))
  commands.push(ArcTo(irx, iry, 0, false, false, cx + irx, cy))
  commands.push(ArcTo(irx, iry, 0, false, false, cx - irx, cy))
  commands.push(ClosePath)
  { commands, width, height }
}
