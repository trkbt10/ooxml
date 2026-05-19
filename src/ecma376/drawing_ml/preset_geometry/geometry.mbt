///|
/// Part 1 §20.1.10.56 — generate the path commands for a preset
/// shape on a `[0, width] × [0, height]` bounding box. The dispatch
/// routes each preset to its per-family constructor; shapes outside
/// the canonical-30 catalogue (see `.indexion/plans/g11-preset-shapes`)
/// fall through to `rectangular_fallback` so the renderer never sees
/// an empty geometry — the fallback preserves the bounding box and
/// the document still round-trips.
///
/// `width` and `height` must be positive; non-positive values return
/// an empty fallback geometry rather than risk integer overflow in
/// the per-shape constructors.
pub fn build_geometry(
  shape : PresetShape,
  width : Int,
  height : Int,
) -> ShapeGeometry {
  if width <= 0 || height <= 0 {
    return { commands: [], width: 0, height: 0 }
  }
  match shape {
    ShapeRect
    | ShapeFlowChartProcess
    | ShapeFlowChartPredefinedProcess
    | ShapeFlowChartInternalStorage => build_rect(width, height)
    ShapeRoundRect
    | ShapeFlowChartTerminator
    | ShapeFlowChartAlternateProcess => build_round_rect(width, height)
    ShapePlaque => build_plaque(width, height)
    ShapeEllipse | ShapeFlowChartConnector => build_ellipse(width, height)
    ShapeTriangle => build_triangle(width, height)
    ShapeRtTriangle => build_right_triangle(width, height)
    ShapeParallelogram | ShapeFlowChartInputOutput =>
      build_parallelogram(width, height)
    ShapeTrapezoid => build_trapezoid(width, height)
    ShapeDiamond | ShapeFlowChartDecision => build_diamond(width, height)
    ShapePentagon => build_regular_polygon(5, width, height)
    ShapeHexagon => build_regular_polygon(6, width, height)
    ShapeHeptagon => build_regular_polygon(7, width, height)
    ShapeOctagon => build_regular_polygon(8, width, height)
    ShapeDecagon => build_regular_polygon(10, width, height)
    ShapeDodecagon => build_regular_polygon(12, width, height)
    ShapeStar4 => build_star(4, width, height)
    ShapeStar5 => build_star(5, width, height)
    ShapeStar6 => build_star(6, width, height)
    ShapeStar7 => build_star(7, width, height)
    ShapeStar8 => build_star(8, width, height)
    ShapeStar10 => build_star(10, width, height)
    ShapeStar12 => build_star(12, width, height)
    ShapeStar16 => build_star(16, width, height)
    ShapeStar24 => build_star(24, width, height)
    ShapeStar32 => build_star(32, width, height)
    ShapeRightArrow => build_right_arrow(width, height)
    ShapeLeftArrow => build_left_arrow(width, height)
    ShapeUpArrow => build_up_arrow(width, height)
    ShapeDownArrow => build_down_arrow(width, height)
    ShapeLeftRightArrow => build_left_right_arrow(width, height)
    ShapeUpDownArrow => build_up_down_arrow(width, height)
    ShapeCallout1 => build_callout1(width, height)
    ShapeCallout2 => build_callout2(width, height)
    ShapeCallout3 => build_callout3(width, height)
    ShapeHeart => build_heart(width, height)
    ShapeCloud => build_cloud(width, height)
    ShapeSmileyFace => build_smiley_face(width, height)
    ShapePlus | ShapeMathPlus => build_plus(width, height)
    ShapeMathMinus => build_minus(width, height)
    ShapeMathMultiply => build_multiply(width, height)
    ShapeMathDivide => build_divide(width, height)
    ShapeMathEqual => build_equal(width, height)
    _ => rectangular_fallback(width, height)
  }
}

///|
/// Return the canonical four-corner rectangle for any preset whose
/// dedicated geometry generator is not yet implemented. Documented
/// as the fallback so a follow-up commit can replace it with a
/// faithful shape; until then renderers still get a non-empty,
/// bounding-box-correct path. The fallback is also returned for
/// degenerate inputs (`width` or `height` ≤ 0).
pub fn rectangular_fallback(width : Int, height : Int) -> ShapeGeometry {
  if width <= 0 || height <= 0 {
    return { commands: [], width: 0, height: 0 }
  }
  build_rect(width, height)
}

///|
/// Report whether `build_geometry` has a faithful (non-fallback)
/// geometry generator for the supplied preset. Useful for audit
/// tooling and for renderers that want to know whether the result
/// can be trusted as a pixel-faithful representation of the spec
/// shape image.
pub fn supports(shape : PresetShape) -> Bool {
  match shape {
    ShapeRect
    | ShapeRoundRect
    | ShapePlaque
    | ShapeEllipse
    | ShapeTriangle
    | ShapeRtTriangle
    | ShapeParallelogram
    | ShapeTrapezoid
    | ShapeDiamond
    | ShapePentagon
    | ShapeHexagon
    | ShapeHeptagon
    | ShapeOctagon
    | ShapeDecagon
    | ShapeDodecagon
    | ShapeStar4
    | ShapeStar5
    | ShapeStar6
    | ShapeStar7
    | ShapeStar8
    | ShapeStar10
    | ShapeStar12
    | ShapeStar16
    | ShapeStar24
    | ShapeStar32
    | ShapeRightArrow
    | ShapeLeftArrow
    | ShapeUpArrow
    | ShapeDownArrow
    | ShapeLeftRightArrow
    | ShapeUpDownArrow
    | ShapeCallout1
    | ShapeCallout2
    | ShapeCallout3
    | ShapeHeart
    | ShapeCloud
    | ShapeSmileyFace
    | ShapePlus
    | ShapeMathPlus
    | ShapeMathMinus
    | ShapeMathMultiply
    | ShapeMathDivide
    | ShapeMathEqual
    | ShapeFlowChartProcess
    | ShapeFlowChartPredefinedProcess
    | ShapeFlowChartInternalStorage
    | ShapeFlowChartDecision
    | ShapeFlowChartTerminator
    | ShapeFlowChartAlternateProcess
    | ShapeFlowChartConnector
    | ShapeFlowChartInputOutput => true
    _ => false
  }
}

///|
/// Compute `(numerator * scalar) / denominator` with integer math
/// while keeping the intermediate product in a 64-bit-safe range
/// (DrawingML's preset coordinate space tops out at 100000 so a
/// `width * 100000` product fits in an Int64). The helper centralises
/// the rounding policy: round half-to-zero.
fn fraction(scalar : Int, numerator : Int, denominator : Int) -> Int {
  if denominator == 0 {
    return 0
  }
  let big = scalar.to_int64() * numerator.to_int64()
  let div = big / denominator.to_int64()
  div.to_int()
}

///|
/// Compute `(scalar * percent) / 100000`. The DrawingML preset
/// adjustment guides express their default values as parts of
/// 100000 (e.g. roundRect's `adj = 16667` ≈ 1/6 of the side length).
fn percent(scalar : Int, parts_per_hundred_thousand : Int) -> Int {
  fraction(scalar, parts_per_hundred_thousand, 100000)
}

///|
/// Integer sine of `degrees` scaled by 10000. Used by the polygon and
/// star constructors to place vertices on a circle without pulling in
/// floating-point math. Values are precomputed for every 1-degree step
/// in the first quadrant and reflected into the remaining three.
fn sin10000(degrees : Int) -> Int {
  let normalized = (degrees % 360 + 360) % 360
  if normalized < 90 {
    sin_table_q1[normalized]
  } else if normalized < 180 {
    sin_table_q1[180 - normalized]
  } else if normalized < 270 {
    -sin_table_q1[normalized - 180]
  } else {
    -sin_table_q1[360 - normalized]
  }
}

///|
/// Integer cosine of `degrees` scaled by 10000, expressed as a
/// sine-with-phase-shift so the table is shared with `sin10000`.
fn cos10000(degrees : Int) -> Int {
  sin10000(degrees + 90)
}

///|
/// First-quadrant sine table, scaled by 10000. Indices 0..90 inclusive
/// give the sine of an integer degree from 0° to 90°. Values are exact
/// to within a unit-in-the-last-place which is more than enough for
/// integer-coordinate preset shape generation.
let sin_table_q1 : Array[Int] = [
  0, 175, 349, 523, 698, 872, 1045, 1219, 1392, 1564, 1736, 1908, 2079, 2250, 2419,
  2588, 2756, 2924, 3090, 3256, 3420, 3584, 3746, 3907, 4067, 4226, 4384, 4540, 4695,
  4848, 5000, 5150, 5299, 5446, 5592, 5736, 5878, 6018, 6157, 6293, 6428, 6561, 6691,
  6820, 6947, 7071, 7193, 7314, 7431, 7547, 7660, 7771, 7880, 7986, 8090, 8192, 8290,
  8387, 8480, 8572, 8660, 8746, 8829, 8910, 8988, 9063, 9135, 9205, 9272, 9336, 9397,
  9455, 9511, 9563, 9613, 9659, 9703, 9744, 9781, 9816, 9848, 9877, 9903, 9925, 9945,
  9962, 9976, 9986, 9994, 9998, 10000,
]
