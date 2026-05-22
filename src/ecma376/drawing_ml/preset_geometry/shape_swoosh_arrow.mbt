// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `swooshArrow`.

///|
/// §20.1.10.56 `swooshArrow` — a tapered "swoosh" arrow that curves
/// up from the bottom-left to an arrowhead at the top-right.
///
/// Spec path (default guides `adj1 = 25000`, `adj2 = 16667`):
///   moveTo (l, b)
///   quadBezTo (xP1, yP1) → (xB, yB)      [the lower swoosh curve]
///   lnTo (xC, t)                          [arrowhead back-left barb]
///   lnTo (r, yD)                          [arrowhead tip]
///   lnTo (xE, yE)                         [arrowhead back-right barb]
///   lnTo (xF, yF)                         [arrowhead inner notch]
///   quadBezTo (xP2, yP2) → (l, b)         [the upper swoosh curve]
///
/// The guide cascade uses `tan` of `alfa = 90°/14 ≈ 6.43°`; this
/// generator evaluates it as `sin(6°)/cos(6°)` over the integer trig
/// tables, which is faithful to within sub-pixel rounding.
pub fn build_swoosh_arrow(width : Int, height : Int) -> ShapeGeometry {
  let l = 0
  let t = 0
  let r = width
  let b = height
  let ss = min_dim(width, height)
  let ssd8 = ss / 8
  // a1 = pin(1, adj1=25000, 75000); a2 = pin(0, adj2=16667, maxAdj2).
  let a1 = 25000
  let a2 = 16667
  let ad1 = fraction(height, a1, 100000)
  let ad2 = fraction(ss, a2, 100000)
  let x_b = r - ad2
  let y_b = t + ssd8
  // alfa = cd4 / 14 ≈ 6.43°; tan(alfa) ≈ tan(6°) = sin(6°)/cos(6°).
  fn tan_of(distance : Int) -> Int {
    let s = sin10000(6)
    let c = cos10000(6)
    if c == 0 {
      0
    } else {
      fraction(distance, s, c)
    }
  }

  let dx0 = tan_of(ssd8)
  let x_c = x_b - dx0
  let dx1 = tan_of(ad1)
  let y_f = y_b + ad1
  let x_f = x_b + dx1
  let x_e = x_f + dx0
  let y_e = y_f + ssd8
  let dy2 = y_e - t
  let dy22 = dy2 / 2
  let dy3 = height / 20
  let y_d = t + dy22 + dy3
  // Lower-curve control point P1 and upper-curve control point P2.
  let x_p1 = width / 6
  let y_p1 = height / 6 + height / 6
  let x_p2 = width / 4
  let y_p2 = y_f + height / 6 / 2
  let commands : Array[PathCommand] = [
    MoveTo(l, b),
    QuadTo(x_p1, y_p1, x_b, y_b),
    LineTo(x_c, t),
    LineTo(r, y_d),
    LineTo(x_e, y_e),
    LineTo(x_f, y_f),
    QuadTo(x_p2, y_p2, l, b),
    ClosePath,
  ]
  { commands, width, height }
}
