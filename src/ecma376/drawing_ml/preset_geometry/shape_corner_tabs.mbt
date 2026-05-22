// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `cornerTabs`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `cornerTabs` — four small right-triangle tabs, one
/// hugging each corner of the bounding box, used as crop / alignment
/// markers.
///
/// Spec guides: `md = mod w h 0` is the diagonal length
/// `sqrt(w² + h²)`; `dx = md/20` is the tab leg length;
/// `y1 = b − dx` and `x1 = r − dx`. Each tab is a closed three-vertex
/// sub-path:
/// - top-left: `(l, t) → (dx, t) → (l, dx)`
/// - bottom-left: `(l, y1) → (dx, b) → (l, b)`
/// - top-right: `(x1, t) → (r, t) → (r, dx)`
/// - bottom-right: `(r, y1) → (r, b) → (x1, b)`
pub fn build_corner_tabs(width : Int, height : Int) -> ShapeGeometry {
  // md = mod w h 0 = sqrt(w² + h²); integer floor square root.
  fn isqrt(n : Int) -> Int {
    if n <= 0 {
      return 0
    }
    let mut x = n
    let mut y = (x + 1) / 2
    while y < x {
      x = y
      y = (x + n / x) / 2
    }
    x
  }

  let md = isqrt(width * width + height * height)
  let dx = md / 20
  let y1 = height - dx
  let x1 = width - dx
  let commands : Array[PathCommand] = [
    // Top-left tab.
    MoveTo(0, 0),
    LineTo(dx, 0),
    LineTo(0, dx),
    ClosePath,
    // Bottom-left tab.
    MoveTo(0, y1),
    LineTo(dx, height),
    LineTo(0, height),
    ClosePath,
    // Top-right tab.
    MoveTo(x1, 0),
    LineTo(width, 0),
    LineTo(width, dx),
    ClosePath,
    // Bottom-right tab.
    MoveTo(width, y1),
    LineTo(width, height),
    LineTo(x1, height),
    ClosePath,
  ]
  { commands, width, height }
}
