// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `plaqueTabs`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `plaqueTabs` — four small concave-corner plaque tabs,
/// one in each corner of the bounding box. Each tab has two straight
/// legs and a quarter-arc that bows *inward* toward the box corner
/// (the inverse-rounded "plaque" corner).
///
/// Spec guides: `md = mod w h 0` is the diagonal `sqrt(w² + h²)`;
/// `dx = md/20` is the tab leg length; `y1 = b − dx`, `x1 = r − dx`.
/// Each tab is a closed sub-path made of one leg and one quarter
/// `arcTo` of radius `dx`:
/// - top-left: `(l, t) → (dx, t) → arc → (l, dx)`
/// - bottom-left: `(l, y1) → arc → (dx, b) → (l, b)`
/// - top-right: `(r, t) → (r, dx) → arc → (x1, t)`
/// - bottom-right: `(x1, b) → arc → (r, y1) → (r, b)`
///
/// Construction note: each spec `arcTo` is a quarter circle whose
/// centre is the box corner, so the arc is rendered as a `QuadTo`
/// with the control point at that corner — the same concave-corner
/// construction `build_plaque` uses for the `plaque` shape.
pub fn build_plaque_tabs(width : Int, height : Int) -> ShapeGeometry {
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
    // Top-left tab: arc bows in toward corner (l, t).
    MoveTo(0, 0),
    LineTo(dx, 0),
    QuadTo(0, 0, 0, dx),
    ClosePath,
    // Bottom-left tab: arc bows in toward corner (l, b).
    MoveTo(0, y1),
    QuadTo(0, height, dx, height),
    LineTo(0, height),
    ClosePath,
    // Top-right tab: arc bows in toward corner (r, t).
    MoveTo(width, 0),
    LineTo(width, dx),
    QuadTo(width, 0, x1, 0),
    ClosePath,
    // Bottom-right tab: arc bows in toward corner (r, b).
    MoveTo(x1, height),
    QuadTo(width, height, width, y1),
    LineTo(width, height),
    ClosePath,
  ]
  { commands, width, height }
}
