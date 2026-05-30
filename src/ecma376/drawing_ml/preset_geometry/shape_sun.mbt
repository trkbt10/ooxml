// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `sun`.

///|
/// §20.1.10.56 `sun` — a central disc with eight triangular rays at
/// 45° intervals.
///
/// FAITHFUL transcription of the spec preset path. The guide chain is
/// pure integer arithmetic (`*/`, `+-`) keyed off `adj`, using the
/// spec's fixed-point trig constants `30274/32768 ≈ cos 22.5°`,
/// `12540/32768 ≈ sin 22.5°`, and the `18436/21600`, `3163/21600`
/// diagonal-tip ratios — so every coordinate is a 1:1 transcription
/// with no floating point. The eight ray triangles
/// (`moveTo`/`lnTo`/`lnTo`/`close`) are followed by the central disc
/// (radii `wR = w·g0/100000`, `hR = h·g0/100000`, `g0 = 50000 − a`),
/// emitted as two 180° arcs from the left point `(x19, vc)` so the
/// `large_arc` flag stays false.
pub fn build_sun(width : Int, height : Int, adj~ : Int = 25000) -> ShapeGeometry {
  let w = width
  let h = height
  let hc = width / 2
  let vc = height / 2
  // Guide chain — faithful integer transcription of the spec gdLst.
  let a = pin_int(adj, 12500, 46875)
  let g0 = 50000 - a // +- 50000 0 a
  let g1 = fraction(g0, 30274, 32768) // */ g0 30274 32768 (cos 22.5°)
  let g2 = fraction(g0, 12540, 32768) // */ g0 12540 32768 (sin 22.5°)
  let g5 = 50000 - g1 // +- 50000 0 g1
  let g6 = 50000 - g2 // +- 50000 0 g2
  let g10 = fraction(g5, 3, 4) // */ g5 3 4
  let g11 = fraction(g6, 3, 4) // */ g6 3 4
  let g12 = g10 + 3662 // +- g10 3662 0
  let g13 = g11 + 3662 // +- g11 3662 0
  let g14 = g11 + 12500 // +- g11 12500 0
  let g15 = 100000 - g10 // +- 100000 0 g10
  let g16 = 100000 - g12 // +- 100000 0 g12
  let g17 = 100000 - g13 // +- 100000 0 g13
  let g18 = 100000 - g14 // +- 100000 0 g14
  let ox1 = fraction(w, 18436, 21600)
  let oy1 = fraction(h, 3163, 21600)
  let ox2 = fraction(w, 3163, 21600)
  let oy2 = fraction(h, 18436, 21600)
  let x10 = fraction(w, g10, 100000)
  let x12 = fraction(w, g12, 100000)
  let x13 = fraction(w, g13, 100000)
  let x14 = fraction(w, g14, 100000)
  let x15 = fraction(w, g15, 100000)
  let x16 = fraction(w, g16, 100000)
  let x17 = fraction(w, g17, 100000)
  let x18 = fraction(w, g18, 100000)
  let x19 = fraction(w, a, 100000)
  let w_r = fraction(w, g0, 100000)
  let h_r = fraction(h, g0, 100000)
  let y10 = fraction(h, g10, 100000)
  let y12 = fraction(h, g12, 100000)
  let y13 = fraction(h, g13, 100000)
  let y14 = fraction(h, g14, 100000)
  let y15 = fraction(h, g15, 100000)
  let y16 = fraction(h, g16, 100000)
  let y17 = fraction(h, g17, 100000)
  let y18 = fraction(h, g18, 100000)
  let commands : Array[PathCommand] = []
  // Eight triangular rays: E, NE, N, NW, W, SW, S, SE.
  commands.push(MoveTo(w, vc))
  commands.push(LineTo(x15, y18))
  commands.push(LineTo(x15, y14))
  commands.push(ClosePath)
  commands.push(MoveTo(ox1, oy1))
  commands.push(LineTo(x16, y13))
  commands.push(LineTo(x17, y12))
  commands.push(ClosePath)
  commands.push(MoveTo(hc, 0))
  commands.push(LineTo(x18, y10))
  commands.push(LineTo(x14, y10))
  commands.push(ClosePath)
  commands.push(MoveTo(ox2, oy1))
  commands.push(LineTo(x13, y12))
  commands.push(LineTo(x12, y13))
  commands.push(ClosePath)
  commands.push(MoveTo(0, vc))
  commands.push(LineTo(x10, y14))
  commands.push(LineTo(x10, y18))
  commands.push(ClosePath)
  commands.push(MoveTo(ox2, oy2))
  commands.push(LineTo(x12, y17))
  commands.push(LineTo(x13, y16))
  commands.push(ClosePath)
  commands.push(MoveTo(hc, h))
  commands.push(LineTo(x14, y15))
  commands.push(LineTo(x18, y15))
  commands.push(ClosePath)
  commands.push(MoveTo(ox1, oy2))
  commands.push(LineTo(x17, y16))
  commands.push(LineTo(x16, y17))
  commands.push(ClosePath)
  // Central disc: full ellipse centred at (hc, vc), radii (wR, hR),
  // from the left point (x19, vc) = (hc − wR, vc).
  commands.push(MoveTo(x19, vc))
  commands.push(ArcTo(w_r, h_r, 0, false, true, hc + w_r, vc))
  commands.push(ArcTo(w_r, h_r, 0, false, true, x19, vc))
  commands.push(ClosePath)
  { commands, width, height }
}
