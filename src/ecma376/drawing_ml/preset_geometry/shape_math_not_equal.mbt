// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `mathNotEqual`.
//
// One preset shape per file. The generator materialises the spec
// preset path (from `presetShapeDefinitions.xml`) scaled into the
// integer frame `[0, width] × [0, height]`. Dispatched from
// `build_geometry` and reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `mathNotEqual` — the not-equal sign: two horizontal
/// equals bars overlaid with a diagonal slash, rendered as one closed
/// 20-vertex polygon (the slash carves a parallelogram notch out of
/// each bar).
///
/// Spec geometry with the default `avLst` (`adj1 = 23520`,
/// `adj2 = 6600000`, `adj3 = 11760`):
/// - `a1 = pin(0, adj1, 50000)`, bar thickness fraction.
/// - `crAng = pin(4200000, adj2, 6600000)`, the slash angle in
///   60000ths of a degree; `cadj2 = crAng − cd4` (cd4 = 90°).
/// - `a3 = pin(0, adj3, 100000 − 2·a1)`, the half-gap fraction.
/// - `dy1 = h·a1/100000`, `dy2 = h·a3/200000`,
///   `dx1 = w·73490/200000`.
/// - `x1 = hc − dx1`, `x8 = hc + dx1`; `y2 = vc − dy2`,
///   `y3 = vc + dy2`, `y1 = y2 − dy1`, `y4 = y3 + dy1`.
/// - `xadj2 = hd2·tan(cadj2)`, `len = sqrt(xadj2² + hd2²)`,
///   `bhw = len·dy1/hd2` is the slash half-width measured along the
///   bars.
/// - `x7 = hc + xadj2 − bhw/2`; the `x2..x6` columns step left from
///   `x7` by `xadj2·yk/hd2`, and `rx2..rx7 = xk + bhw` are their
///   right-hand companions. The slash end caps are `(lx, ly)`,
///   `(rx, ry)` at the top and `(dlx, dly)`, `(drx, dry)` at the
///   bottom (mirror through the centre).
///
/// With the default `cadj2 > 0` the spec `?:` guides resolve to
/// `lx = x7`, `rx = x7 + dx7`, `ly = 0`, `ry = dy3`.
pub fn build_math_not_equal(
  width : Int,
  height : Int,
) -> ShapeGeometry {
  fn pin(lo : Int, v : Int, hi : Int) -> Int {
    if v < lo {
      lo
    } else if v > hi {
      hi
    } else {
      v
    }
  }

  // md = mod x y 0 = sqrt(x² + y²); integer floor square root.
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

  let hc = width / 2
  let vc = height / 2
  let hd2 = height / 2
  // Adjustment guides (defaults adj1=23520, adj2=6600000, adj3=11760).
  let a1 = pin(0, 23520, 50000)
  let cr_ang = pin(4200000, 6600000, 6600000)
  let max_adj3 = 100000 - 2 * a1
  let a3 = pin(0, 11760, max_adj3)
  let dy1 = fraction(height, a1, 100000)
  let dy2 = fraction(height, a3, 200000)
  let dx1 = fraction(width, 73490, 200000)
  let x1 = hc - dx1
  let x8 = hc + dx1
  let y2 = vc - dy2
  let y3 = vc + dy2
  let y1 = y2 - dy1
  let y4 = y3 + dy1
  // cadj2 = crAng - cd4 (cd4 = 90° = 5400000); the slash tilt.
  let cadj2 = cr_ang - 5400000
  let cadj2_deg = (cadj2 + 30000) / 60000
  // xadj2 = hd2 * tan(cadj2) = hd2 * sin/cos.
  let xadj2 = fraction(hd2, sin10000(cadj2_deg), cos10000(cadj2_deg))
  // len = sqrt(xadj2² + hd2²).
  let len = isqrt(xadj2 * xadj2 + hd2 * hd2)
  let bhw = if len == 0 { 0 } else { fraction(len, dy1, hd2) }
  let bhw2 = bhw / 2
  let x7 = hc + xadj2 - bhw2
  // xk = x7 - xadj2 * yk / hd2 columns (skew tracks the bar rows).
  let dx67 = if hd2 == 0 { 0 } else { fraction(xadj2, y1, hd2) }
  let x6 = x7 - dx67
  let dx57 = if hd2 == 0 { 0 } else { fraction(xadj2, y2, hd2) }
  let x5 = x7 - dx57
  let dx47 = if hd2 == 0 { 0 } else { fraction(xadj2, y3, hd2) }
  let x4 = x7 - dx47
  let dx37 = if hd2 == 0 { 0 } else { fraction(xadj2, y4, hd2) }
  let x3 = x7 - dx37
  // Right-hand companions, offset by the slash width.
  let rx3 = x3 + bhw
  let rx4 = x4 + bhw
  let rx5 = x5 + bhw
  let rx6 = x6 + bhw
  // Slash end caps. With cadj2 > 0: lx = x7, rx = x7 + dx7,
  // ly = 0, ry = dy3.
  let dx7 = if len == 0 { 0 } else { fraction(dy1, hd2, len) }
  let rxt = x7 + dx7
  let rx = rxt
  let lx = x7
  let dy3 = if len == 0 { 0 } else { fraction(dy1, xadj2, len) }
  let ry = dy3
  let ly = 0
  // Bottom caps mirror the top ones through the centre.
  let dlx = width - rx
  let drx = width - lx
  let dly = height - ry
  let dry = height - ly
  let commands : Array[PathCommand] = [
    MoveTo(x1, y1),
    LineTo(x6, y1),
    LineTo(lx, ly),
    LineTo(rx, ry),
    LineTo(rx6, y1),
    LineTo(x8, y1),
    LineTo(x8, y2),
    LineTo(rx5, y2),
    LineTo(rx4, y3),
    LineTo(x8, y3),
    LineTo(x8, y4),
    LineTo(rx3, y4),
    LineTo(drx, dry),
    LineTo(dlx, dly),
    LineTo(x3, y4),
    LineTo(x1, y4),
    LineTo(x1, y3),
    LineTo(x4, y3),
    LineTo(x5, y2),
    LineTo(x1, y2),
    ClosePath,
  ]
  { commands, width, height }
}
