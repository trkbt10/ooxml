// Glyph-outline extraction for envelope text warping — the
// PresentationML WordArt §20.1.10.76 `prstTxWarp` ENVELOPE families
// (inflate / deflate / can / chevron / triangle / cascade / fade …)
// deform the text BODY between two differing top/bottom guide curves.
// That is a non-affine 2-D mesh distortion of each glyph OUTLINE, which
// cannot be expressed by SVG `<textPath>` (it only bends the baseline).
//
// The wrapped `TTFont` exposes `char_outline`, yielding each glyph's
// contours as path commands in font units (em space, y-up).  Here we
// flatten the Bézier segments to polylines, scale to pixels, convert to
// screen space (y-down, baseline at y=0) and lay the string out
// left-to-right at real advances.  A caller then applies the envelope
// map to every vertex and emits filled `<path>` elements — the faithful
// WordArt render rather than a misleading flat fallback.

///|
/// Subdivision count for one Bézier segment whose control polygon, in
/// pixels, spans `poly_len`.  Bounded so tiny glyph details stay cheap
/// and large display-size WordArt stays smooth.
fn bezier_segments(poly_len : Double, tolerance : Double) -> Int {
  let tol = if tolerance > 0.05 { tolerance } else { 0.05 }
  let n = (poly_len / tol).to_int()
  if n < 2 {
    2
  } else if n > 24 {
    24
  } else {
    n
  }
}

///|
fn dist(a : (Double, Double), b : (Double, Double)) -> Double {
  let dx = a.0 - b.0
  let dy = a.1 - b.1
  (dx * dx + dy * dy).sqrt()
}

///|
/// Flatten one glyph's outline into closed contours of screen-space
/// pixel points: x offset by `pen_x`, y NEGATED so the font's y-up em
/// space becomes screen y-down with the baseline at y=0.  Bézier
/// segments are flattened to within `tolerance` pixels.
fn FontMeasurer::char_outline_contours(
  self : FontMeasurer,
  char : Char,
  font_size_pt~ : Double,
  pen_x~ : Double,
  tolerance~ : Double,
) -> Array[Array[(Double, Double)]] {
  let cmds = self.ttfont.char_outline(char.to_int())
  let scale = font_size_pt * pt_to_px / self.units_per_em.to_double()
  fn pt(fx : Double, fy : Double) -> (Double, Double) {
    (pen_x + fx * scale, -fy * scale)
  }

  let contours : Array[Array[(Double, Double)]] = []
  let mut current : Array[(Double, Double)] = []
  let mut cur : (Double, Double) = (pen_x, 0.0)
  fn finish() -> Unit {
    if current.length() >= 2 {
      contours.push(current)
    }
    current = []
  }

  for cmd in cmds {
    match cmd {
      @svg.MoveTo(fx, fy) => {
        finish()
        let p = pt(fx, fy)
        current = [p]
        cur = p
      }
      @svg.LineTo(fx, fy) => {
        let p = pt(fx, fy)
        current.push(p)
        cur = p
      }
      @svg.QuadraticCurveTo(cfx, cfy, fx, fy) => {
        let c = pt(cfx, cfy)
        let e = pt(fx, fy)
        let n = bezier_segments(dist(cur, c) + dist(c, e), tolerance)
        for i in 1..<=n {
          let t = i.to_double() / n.to_double()
          let u = 1.0 - t
          let x = u * u * cur.0 + 2.0 * u * t * c.0 + t * t * e.0
          let y = u * u * cur.1 + 2.0 * u * t * c.1 + t * t * e.1
          current.push((x, y))
        }
        cur = e
      }
      @svg.CurveTo(c1fx, c1fy, c2fx, c2fy, fx, fy) => {
        let c1 = pt(c1fx, c1fy)
        let c2 = pt(c2fx, c2fy)
        let e = pt(fx, fy)
        let n = bezier_segments(
          dist(cur, c1) + dist(c1, c2) + dist(c2, e),
          tolerance,
        )
        for i in 1..<=n {
          let t = i.to_double() / n.to_double()
          let u = 1.0 - t
          let x = u * u * u * cur.0 +
            3.0 * u * u * t * c1.0 +
            3.0 * u * t * t * c2.0 +
            t * t * t * e.0
          let y = u * u * u * cur.1 +
            3.0 * u * u * t * c1.1 +
            3.0 * u * t * t * c2.1 +
            t * t * t * e.1
          current.push((x, y))
        }
        cur = e
      }
      @svg.ClosePath => finish()
      // `char_outline` emits only the absolute Move/Line/Quad/Cubic/
      // Close subset above; ignore anything else defensively.
      _ => ()
    }
  }
  finish()
  contours
}

///|
/// Lay `text` out left-to-right at real advances and return every
/// glyph's flattened outline as closed contours of screen-space pixel
/// points (baseline at y=0, the run starting at x=0).  Raises
/// `FontUnresolvedError` when the family cannot be resolved.
///
/// `tolerance` is the Bézier flattening error in pixels (smaller =
/// smoother, more points).
pub fn text_outline_contours(
  text : String,
  family~ : String,
  font_size_pt~ : Double,
  weight? : Int = 400,
  italic? : Bool = false,
  tolerance? : Double = 0.75,
) -> Array[Array[(Double, Double)]] raise FontUnresolvedError {
  let m = resolve_measurer(family, weight, italic)
  let chars : Array[Char] = []
  for c in text {
    chars.push(c)
  }
  let out : Array[Array[(Double, Double)]] = []
  let mut pen = 0.0
  for i, ch in chars {
    if i > 0 {
      pen = pen + m.kerning_adjust(chars[i - 1], ch, font_size_pt~)
    }
    for
      contour in m.char_outline_contours(
        ch,
        font_size_pt~,
        pen_x=pen,
        tolerance~,
      ) {
      out.push(contour)
    }
    pen = pen + m.char_advance(ch, font_size_pt~)
  }
  out
}
