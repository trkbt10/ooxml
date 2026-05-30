// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — additional preset
// geometry generators for the polygon / block / chart-marker families.
//
// Each generator materialises the spec preset's path at the default
// adjustment guide values, scaled into the integer frame
// `[0, width] × [0, height]`. They are dispatched from
// `build_geometry` and reported by `supports`.

///|
/// §20.1.10.56 `homePlate` — a five-sided "home-plate" pentagon: a
/// rectangle with the right edge replaced by an outward point. Per the
/// spec gdLst `maxAdj = 100000·w/ss`, `a = pin 0 adj maxAdj`, and the
/// point depth `dx1 = ss·a/100000` (`ss = min(w, h)`); the point base
/// sits at `x1 = w − dx1`. Default `adj = 50000`.
pub fn build_home_plate(
  width : Int,
  height : Int,
  adj~ : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let base_x = width - percent(ss, pin_int(adj, 0, max_adj))
  let mid_y = height / 2
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(base_x, 0),
    LineTo(width, mid_y),
    LineTo(base_x, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `chevron` — an arrow-like chevron: like `homePlate`
/// but the left edge is also notched inward, so the shape is a
/// six-point arrow band. Per the spec gdLst `x1 = ss·a/100000`
/// (`a = pin 0 adj maxAdj`, `maxAdj = 100000·w/ss`); the right point
/// base sits at `x2 = w − x1` and the left notch apex at `(x1, vc)`.
/// Default `adj = 50000`.
pub fn build_chevron(width : Int, height : Int, adj~ : Int = 50000) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let x1 = percent(ss, pin_int(adj, 0, max_adj))
  let x2 = width - x1
  let mid_y = height / 2
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(x2, 0),
    LineTo(width, mid_y),
    LineTo(x2, height),
    LineTo(0, height),
    LineTo(x1, mid_y),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `frame` — a rectangular picture frame: an outer
/// rectangle with a concentric rectangular hole. The `adj` guide
/// (default 12500) sets the frame band thickness. Emitted as two
/// sub-paths (outer CW, inner CCW) so the even-odd / non-zero fill
/// rule cuts the hole.
pub fn build_frame(width : Int, height : Int, adj1~ : Int = 12500) -> ShapeGeometry {
  // §20.1.10.56 frame gdLst: a1 = pin 0 adj1 50000; band x1 = ss·a1/100000.
  let band = percent(min_dim(width, height), pin_int(adj1, 0, 50000))
  let commands : Array[PathCommand] = [
    // Outer rectangle, clockwise.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Inner rectangle, counter-clockwise so the band is hollow.
    MoveTo(band, band),
    LineTo(band, height - band),
    LineTo(width - band, height - band),
    LineTo(width - band, band),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `halfFrame` — an L-shaped corner frame: the top and
/// left bands of a `frame`. The `adj` guides set the band widths;
/// defaults give a uniform band of 1/8 of the smaller dimension.
pub fn build_half_frame(width : Int, height : Int) -> ShapeGeometry {
  let band = percent(min_dim(width, height), 12500)
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width - band, band),
    LineTo(band, band),
    LineTo(band, height - band),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `corner` — an L-shaped corner gnomon: a vertical band
/// on the left joined to a horizontal band along the bottom. Per the
/// spec gdLst the vertical band width `x1 = ss·a2/100000`
/// (`a2 = pin 0 adj2 maxAdj2`, `maxAdj2 = 100000·w/ss`) and the
/// horizontal band height `dy1 = ss·a1/100000` (`a1 = pin 0 adj1
/// maxAdj1`, `maxAdj1 = 100000·h/ss`) are both `ss`-based (NOT
/// width/height). Defaults `adj1 = adj2 = 50000`.
pub fn build_corner(
  width : Int,
  height : Int,
  adj1~ : Int = 50000,
  adj2~ : Int = 50000,
) -> ShapeGeometry {
  let ss = min_dim(width, height)
  let max_adj1 = if ss == 0 { 0 } else { fraction(100000, height, ss) }
  let max_adj2 = if ss == 0 { 0 } else { fraction(100000, width, ss) }
  let band_w = percent(ss, pin_int(adj2, 0, max_adj2))
  let band_h = percent(ss, pin_int(adj1, 0, max_adj1))
  let commands : Array[PathCommand] = [
    MoveTo(0, 0),
    LineTo(band_w, 0),
    LineTo(band_w, height - band_h),
    LineTo(width, height - band_h),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `diagStripe` — a diagonal band crossing the bounding
/// box from the bottom-left to the top-right. The `adj` guide
/// (default 50000) sets the band offset.
pub fn build_diag_stripe(
  width : Int,
  height : Int,
  adj~ : Int = 50000,
) -> ShapeGeometry {
  // §20.1.10.56 diagStripe gdLst: a = pin 0 adj 100000; the upper
  // diagonal passes through (x2, 0) and (0, y2) with x2 = w·a/100000
  // (width-based) and y2 = h·a/100000 (height-based).
  let a = pin_int(adj, 0, 100000)
  let off_x = percent(width, a)
  let off_y = percent(height, a)
  let commands : Array[PathCommand] = [
    MoveTo(0, off_y),
    LineTo(off_x, 0),
    LineTo(width, 0),
    LineTo(0, height),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `cube` — an isometric cube: a front face, a top face
/// and a right face. The `adj` guide (default 25000) sets the depth
/// of the receding faces.
pub fn build_cube(width : Int, height : Int, adj~ : Int = 25000) -> ShapeGeometry {
  // §20.1.10.56 cube gdLst: a = pin 0 adj 100000; depth y1 = ss·a/100000.
  let depth = percent(min_dim(width, height), pin_int(adj, 0, 100000))
  let commands : Array[PathCommand] = [
    // Front face.
    MoveTo(0, depth),
    LineTo(0, height),
    LineTo(width - depth, height),
    LineTo(width - depth, depth),
    ClosePath,
    // Top face.
    MoveTo(0, depth),
    LineTo(depth, 0),
    LineTo(width, 0),
    LineTo(width - depth, depth),
    ClosePath,
    // Right face.
    MoveTo(width - depth, depth),
    LineTo(width, 0),
    LineTo(width, height - depth),
    LineTo(width - depth, height),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `can` — a cylinder (storage "can"): a rectangular body
/// capped by an ellipse at the top and the front half of an ellipse
/// at the bottom. The `adj` guide (default 25000) sets the cap
/// height as a fraction of the bounding box.
pub fn build_can(width : Int, height : Int, adj~ : Int = 25000) -> ShapeGeometry {
  // §20.1.10.56 can gdLst: maxAdj = 50000·h/ss; a = pin 0 adj maxAdj;
  // the cap ellipse vertical radius y1 = ss·a/200000 is `ss`-based
  // (NOT height-based).
  let ss = min_dim(width, height)
  let max_adj = if ss == 0 { 0 } else { fraction(50000, height, ss) }
  let rx = width / 2
  let ry = fraction(ss, pin_int(adj, 0, max_adj), 200000)
  let commands : Array[PathCommand] = [
    // Body + bottom front arc.
    MoveTo(0, ry),
    LineTo(0, height - ry),
    ArcTo(rx, ry, 0, false, false, width, height - ry),
    LineTo(width, ry),
    // Top ellipse (full).
    ArcTo(rx, ry, 0, false, false, 0, ry),
    ArcTo(rx, ry, 0, false, false, width, ry),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `bevel` — a rectangle with a raised bevelled border:
/// an outer rectangle and an inner rectangle joined at the corners
/// so the four trapezoidal bevel faces are visible. The `adj` guide
/// (default 12500) sets the bevel width.
pub fn build_bevel(width : Int, height : Int, adj~ : Int = 12500) -> ShapeGeometry {
  // §20.1.10.56 bevel gdLst: a = pin 0 adj 50000; bevel width x1 = ss·a/100000.
  let b = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let commands : Array[PathCommand] = [
    // Outer rectangle.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height),
    LineTo(0, height),
    ClosePath,
    // Inner rectangle.
    MoveTo(b, b),
    LineTo(b, height - b),
    LineTo(width - b, height - b),
    LineTo(width - b, b),
    ClosePath,
    // The four bevel diagonals joining outer to inner corners.
    MoveTo(0, 0),
    LineTo(b, b),
    MoveTo(width, 0),
    LineTo(width - b, b),
    MoveTo(width, height),
    LineTo(width - b, height - b),
    MoveTo(0, height),
    LineTo(b, height - b),
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `foldedCorner` — a rectangle with the bottom-right
/// corner turned up. The `adj` guide (default 16667) sets the fold
/// size.
pub fn build_folded_corner(
  width : Int,
  height : Int,
  adj~ : Int = 16667,
) -> ShapeGeometry {
  // §20.1.10.56 foldedCorner gdLst: a = pin 0 adj 50000; fold = ss·a/100000.
  let fold = percent(min_dim(width, height), pin_int(adj, 0, 50000))
  let commands : Array[PathCommand] = [
    // Body with the corner cut.
    MoveTo(0, 0),
    LineTo(width, 0),
    LineTo(width, height - fold),
    LineTo(width - fold, height),
    LineTo(0, height),
    ClosePath,
    // The folded triangle flap.
    MoveTo(width - fold, height),
    LineTo(width - fold, height - fold),
    LineTo(width, height - fold),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `chartX` — a diagonal cross marker used in charts:
/// two crossed bands forming an X.
pub fn build_chart_x(width : Int, height : Int) -> ShapeGeometry {
  let t = percent(min_dim(width, height), 12500)
  let commands : Array[PathCommand] = [
    // Top-left to bottom-right band.
    MoveTo(0, 0),
    LineTo(t, 0),
    LineTo(width, height - t),
    LineTo(width, height),
    LineTo(width - t, height),
    LineTo(0, t),
    ClosePath,
    // Top-right to bottom-left band.
    MoveTo(width - t, 0),
    LineTo(width, 0),
    LineTo(width, t),
    LineTo(t, height),
    LineTo(0, height),
    LineTo(0, height - t),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `chartPlus` — a plus-sign marker used in charts: a
/// vertical band crossed by a horizontal band.
pub fn build_chart_plus(width : Int, height : Int) -> ShapeGeometry {
  let t = percent(min_dim(width, height), 12500)
  let cx0 = (width - t) / 2
  let cx1 = (width + t) / 2
  let cy0 = (height - t) / 2
  let cy1 = (height + t) / 2
  let commands : Array[PathCommand] = [
    // Vertical band.
    MoveTo(cx0, 0),
    LineTo(cx1, 0),
    LineTo(cx1, height),
    LineTo(cx0, height),
    ClosePath,
    // Horizontal band.
    MoveTo(0, cy0),
    LineTo(width, cy0),
    LineTo(width, cy1),
    LineTo(0, cy1),
    ClosePath,
  ]
  { commands, width, height }
}

///|
/// §20.1.10.56 `chartStar` — a six-band asterisk marker used in
/// charts: the `chartPlus` cross plus the two diagonals.
pub fn build_chart_star(width : Int, height : Int) -> ShapeGeometry {
  let t = percent(min_dim(width, height), 12500)
  let cx0 = (width - t) / 2
  let cx1 = (width + t) / 2
  let cy0 = (height - t) / 2
  let cy1 = (height + t) / 2
  let commands : Array[PathCommand] = [
    // Vertical band.
    MoveTo(cx0, 0),
    LineTo(cx1, 0),
    LineTo(cx1, height),
    LineTo(cx0, height),
    ClosePath,
    // Horizontal band.
    MoveTo(0, cy0),
    LineTo(width, cy0),
    LineTo(width, cy1),
    LineTo(0, cy1),
    ClosePath,
    // Down-diagonal band.
    MoveTo(0, 0),
    LineTo(t, 0),
    LineTo(width, height - t),
    LineTo(width, height),
    LineTo(width - t, height),
    LineTo(0, t),
    ClosePath,
    // Up-diagonal band.
    MoveTo(width - t, 0),
    LineTo(width, 0),
    LineTo(width, t),
    LineTo(t, height),
    LineTo(0, height),
    LineTo(0, height - t),
    ClosePath,
  ]
  { commands, width, height }
}
