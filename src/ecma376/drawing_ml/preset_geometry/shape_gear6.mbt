// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `gear6` / `gear9`.

///|
/// §20.1.10.56 gear silhouette generator shared by `gear6` and
/// `gear9`. The spec geometry derives every tooth from a pin-shaped
/// trapezoid projected onto the rim circle with `cos`/`sin` guide
/// formulas and joins the gaps between teeth with `arcTo` rim arcs.
///
/// This generator renders a faithful, recognisable gear silhouette
/// with the spec's defaults: the rim radius is `min(w,h)/2` minus the
/// tooth height `th` (the spec's `adj1` default — `15000`/100000 of
/// `ss` for gear6, `10000`/100000 for gear9). Each tooth is a
/// trapezoid whose flank angle spans a fraction of the tooth pitch so
/// the tooth tip is narrower than its base (matching the spec's
/// `lFD` flank inset). The arc of the rim between two teeth is
/// approximated by a single `LineTo` from the falling base of one
/// tooth to the rising base of the next — the gaps are short enough
/// that the chord is visually indistinguishable from the spec arc.
///
/// `teeth` is the tooth count, `adj1_pp100k` is the spec `adj1`
/// default expressed in parts-per-100000 of the shape size `ss`.
fn build_gear(
  teeth : Int,
  adj1_pp100k : Int,
  width : Int,
  height : Int,
) -> ShapeGeometry {
  let cx = width / 2
  let cy = height / 2
  let ss = min_dim(width, height)
  // Tooth height: spec `th = ss * adj1 / 100000`.
  let th = percent(ss, adj1_pp100k)
  // Rim radii: the outer tooth tips sit on the bounding box, the rim
  // base circle is `th` smaller (the spec keeps separate rw/rh radii
  // so non-square boxes squash correctly).
  let outer_rx = width / 2
  let outer_ry = height / 2
  let rim_rx = outer_rx - th
  let rim_ry = outer_ry - th
  // Each tooth occupies one pitch of `360 / teeth` degrees. The tooth
  // tip spans 40% of the pitch and the gap the remaining 60%, with
  // the flanks sloping outward from base to tip.
  let pitch = 360 / teeth
  let tip_half = pitch * 20 / 100
  let base_half = pitch * 30 / 100
  let commands : Array[PathCommand] = []
  for i in 0..<teeth {
    // Tooth centre angle; start the first tooth pointing up.
    let centre = -90 + i * pitch
    // Four tooth vertices: rising base, rising tip, falling tip,
    // falling base — base on the rim circle, tip on the outer circle.
    let a_rise_base = centre - base_half
    let a_rise_tip = centre - tip_half
    let a_fall_tip = centre + tip_half
    let a_fall_base = centre + base_half
    fn pt(angle : Int, rx : Int, ry : Int) -> (Int, Int) {
      (
        cx + fraction(rx, cos10000(angle), 10000),
        cy + fraction(ry, sin10000(angle), 10000),
      )
    }

    let (x0, y0) = pt(a_rise_base, rim_rx, rim_ry)
    let (x1, y1) = pt(a_rise_tip, outer_rx, outer_ry)
    let (x2, y2) = pt(a_fall_tip, outer_rx, outer_ry)
    let (x3, y3) = pt(a_fall_base, rim_rx, rim_ry)
    if i == 0 {
      commands.push(MoveTo(x0, y0))
    } else {
      // Rim gap from the previous tooth's falling base to this
      // tooth's rising base.
      commands.push(LineTo(x0, y0))
    }
    commands.push(LineTo(x1, y1))
    commands.push(LineTo(x2, y2))
    commands.push(LineTo(x3, y3))
  }
  commands.push(ClosePath)
  { commands, width, height }
}

///|
/// §20.1.10.56 `gear6` — a gear wheel with six teeth. Uses the spec's
/// `adj1` default of `15000` parts-per-100000.
pub fn build_gear6(width : Int, height : Int) -> ShapeGeometry {
  build_gear(6, 15000, width, height)
}

///|
/// §20.1.10.56 `gear9` — a gear wheel with nine teeth. Uses the spec's
/// `adj1` default of `10000` parts-per-100000.
pub fn build_gear9(width : Int, height : Int) -> ShapeGeometry {
  build_gear(9, 10000, width, height)
}
