// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/gradient-utils.ts
//
// Helpers for converting OOXML gradient specifications to SVG
// gradient coordinates.
//
// ECMA-376 references:
//   §20.1.8.33 (a:gradFill)
//   §20.1.8.41 (a:lin)
//   §20.1.8.30 (a:fillToRect)

///|
/// Linear-gradient coordinates as percentages (0-100).  Mirrors
/// `LinearGradientCoords` in `gradient-utils.ts:19`.
pub struct LinearGradientCoords {
  x1 : Double
  y1 : Double
  x2 : Double
  y2 : Double
}

///|
/// Radial-gradient coordinates as percentages (0-100).  Mirrors
/// `RadialGradientCoords` in `gradient-utils.ts:28`.
pub struct RadialGradientCoords {
  cx : Double
  cy : Double
  r : Double
  fx : Double?
  fy : Double?
}

///|
/// `Math.PI / 180` precomputed for degree → radian conversion.
let deg_to_rad : Double = 3.141592653589793 / 180.0

///|
/// Convert OOXML linear-gradient angle to SVG x1/y1/x2/y2 percentages.
///
/// §20.1.8.41 `<a:lin @ang>` — the angle is measured CLOCKWISE from
/// the positive-x (3 o'clock) direction, in a Y-DOWN coordinate
/// system:
///   0°   = gradient flows left → right
///   90°  = top → bottom
///   180° = right → left
///   270° = bottom → top
///
/// SVG's `linearGradient` uses exactly the same Y-down convention:
/// `x1,y1 → x2,y2` is the gradient direction.  So the OOXML angle
/// maps DIRECTLY — the gradient direction is `(cos θ, sin θ)` and the
/// start/end points are the box centre offset ±half along it.  (The
/// earlier code subtracted 90° "to align with SVG", which was wrong:
/// SVG is already Y-down, so `ang=0` came out vertical instead of
/// horizontal — the gradient ran the wrong way.)
pub fn ooxml_angle_to_svg_linear_gradient(
  angle : Double,
) -> LinearGradientCoords {
  let rad = angle * deg_to_rad
  let x1 = 50.0 - 50.0 * @math.cos(rad)
  let y1 = 50.0 - 50.0 * @math.sin(rad)
  let x2 = 50.0 + 50.0 * @math.cos(rad)
  let y2 = 50.0 + 50.0 * @math.sin(rad)
  { x1, y1, x2, y2 }
}

///|
/// Default radial-gradient coordinates.  When `extended` is true,
/// uses radius 70.7% (≈ √2/2) to cover corners — used for slide
/// backgrounds.  Mirrors `getRadialGradientCoords` in
/// `gradient-utils.ts:101`.
pub fn get_radial_gradient_coords(
  radial_center? : (Double, Double)? = None,
  extended? : Bool = false,
) -> RadialGradientCoords {
  let (cx, cy) = radial_center.unwrap_or((50.0, 50.0))
  let r = if extended { 70.7 } else { 50.0 }
  { cx, cy, r, fx: Some(cx), fy: Some(cy) }
}

///|
/// Compute radial-gradient centre from an `a:fillToRect` element
/// (left/top/right/bottom margins as percentages).  The centre is
/// the midpoint of the remaining (uncovered) area.  Mirrors
/// `fillToRectToRadialCenter` in `gradient-utils.ts:81`.
pub fn fill_to_rect_to_radial_center(
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
) -> (Double, Double) {
  let cx = (left + (100.0 - right)) / 2.0
  let cy = (top + (100.0 - bottom)) / 2.0
  (cx, cy)
}
