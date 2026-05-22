// ECMA-376 Part 1 §20.1.10.56 ST_PresetGeometry — `cloudCallout`.
//
// One preset shape per file. Dispatched from `build_geometry` and
// reported by `supports` in `geometry.mbt`.

///|
/// §20.1.10.56 `cloudCallout` — a cloud-shaped body (a closed loop of
/// outward bumps) followed by a trail of three shrinking ellipse
/// bubbles leading to the callout target point.
///
/// The spec preset draws the cloud with eleven `arcTo` lobes in a
/// 43200×43200 frame. Reproducing every lobe arc faithfully is
/// unnecessary for a rasteriser: we approximate the bumpy outline with
/// quadratic Béziers (`QuadTo`) — the same technique already used by
/// `build_cloud` — which preserves the silhouette character (a closed
/// scalloped loop) while keeping the path integer-only.
///
/// Spec guides (`avLst` defaults): `adj1 = -20833`, `adj2 = 62500`.
/// `dxPos = w*adj1/100000`, `dyPos = h*adj2/100000`, and the target
/// point is `(xPos,yPos) = (w/2 + dxPos, h/2 + dyPos)`. The three
/// trailing bubbles shrink as they approach the target; each is a
/// closed ellipse subpath emitted as `MoveTo` + two `ArcTo` halves.
///
/// The cloud body occupies the upper region of the bounding box so the
/// trail (which runs down toward `yPos`, below the box) has room.
pub fn build_cloud_callout(width : Int, height : Int) -> ShapeGeometry {
  // Cloud body region: full width, top 70% of the box height.
  let body_h = percent(height, 70000)
  let q1 = percent(width, 25000)
  let q2 = percent(width, 50000)
  let q3 = percent(width, 75000)
  let bump = fraction(body_h, 30, 100)
  let commands : Array[PathCommand] = []
  // Bumpy cloud outline approximated with quadratic Béziers.
  commands.push(MoveTo(q1, body_h - bump))
  commands.push(QuadTo(0, body_h - bump, 0, fraction(body_h, 60, 100)))
  commands.push(QuadTo(0, fraction(body_h, 25, 100), q1, fraction(body_h, 25, 100)))
  commands.push(QuadTo(q1, 0, q2, fraction(body_h, 15, 100)))
  commands.push(QuadTo(q2, 0, q3, fraction(body_h, 20, 100)))
  commands.push(QuadTo(width, 0, width, fraction(body_h, 40, 100)))
  commands.push(QuadTo(width, fraction(body_h, 70, 100), q3, body_h - bump))
  commands.push(QuadTo(q3, body_h, q2, body_h - bump))
  commands.push(QuadTo(q1, body_h, q1, body_h - bump))
  commands.push(ClosePath)

  // Callout target point from the avLst guides.
  let target_x = width / 2 + percent(width, -20833)
  let target_y = height / 2 + percent(height, 62500)
  // Trail anchor on the lower cloud edge.
  let anchor_x = q2
  let anchor_y = body_h - bump / 2

  // Three shrinking ellipse bubbles interpolated from the cloud edge
  // toward the target. Bubble i sits at fraction t along the trail
  // with a radius that shrinks toward the target.
  fn lerp(a : Int, b : Int, num : Int, den : Int) -> Int {
    a + fraction(b - a, num, den)
  }

  let base_r = min_dim(percent(width, 9000), percent(height, 9000))
  let steps = [40, 70, 95]
  let radii = [
    fraction(base_r, 70, 100),
    fraction(base_r, 45, 100),
    fraction(base_r, 25, 100),
  ]
  for i in 0..<3 {
    let t = steps[i]
    let cx = lerp(anchor_x, target_x, t, 100)
    let cy = lerp(anchor_y, target_y, t, 100)
    let r = radii[i]
    commands.push(MoveTo(cx - r, cy))
    commands.push(ArcTo(r, r, 0, false, true, cx + r, cy))
    commands.push(ArcTo(r, r, 0, false, true, cx - r, cy))
    commands.push(ClosePath)
  }
  { commands, width, height }
}
