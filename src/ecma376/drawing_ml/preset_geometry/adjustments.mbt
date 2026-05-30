// Part 1 §20.1.9 — adjustment-guide-aware preset geometry.
//
// `build_geometry` (geometry.mbt) renders every preset against the
// §20.1.10.56 spec-default `avLst` guides. A document may override
// those guides via `<a:prstGeom><a:avLst><a:gd name="adj" fmla="val
// N"/></a:avLst>` (§20.1.9.5 / §20.1.9.11); `decode.mbt` captures the
// overrides as `Array[Adjustment]`. This file applies them.
//
// The contract is purely additive: when no override is supplied (or
// for a preset whose builder is not yet adjustment-aware),
// `build_geometry_with_adjustments` produces byte-identical output to
// `build_geometry`, so existing render paths never regress — only
// shapes carrying a non-default guide change.

///|
/// §20.1.9.11 gd — resolve a named adjustment guide's integer value
/// from the decoded `avLst` overrides, falling back to `default_value`
/// when the guide is absent or carries a formula form this decoder
/// does not evaluate (an `avLst` guide may use only the `val n` form
/// per §20.1.10.56, captured as `Adjustment::value`).
pub fn adjustment_value(
  adjustments : Array[Adjustment],
  name : String,
  default_value : Int,
) -> Int {
  for a in adjustments {
    if a.name == name {
      return match a.value {
        Some(v) => v
        None => default_value
      }
    }
  }
  default_value
}

///|
/// §20.1.9.11 — clamp `value` to the closed range `[lo, hi]`, the
/// integer-arithmetic mirror of the spec's `pin lo x hi` guide
/// operator. Used to apply each preset's documented adjustment range
/// (e.g. roundRect's `a = pin 0 adj 50000`).
pub fn pin_int(value : Int, lo : Int, hi : Int) -> Int {
  if value < lo {
    lo
  } else if value > hi {
    hi
  } else {
    value
  }
}

///|
/// Part 1 §20.1.9.18 prstGeom — like `build_geometry`, but honours the
/// document's `avLst` adjustment guides (§20.1.9.11) for the presets
/// whose path geometry depends on them. Presets without an
/// adjustment-aware builder delegate to `build_geometry` (spec-default
/// guides), so the output is identical to the no-adjustment path when
/// no override is supplied.
///
/// Currently adjustment-aware: the rounded / snipped rectangle family
/// (`roundRect`, `plaque`, `round1Rect`, `round2SameRect`,
/// `round2DiagRect`, `snip1Rect`, `snip2SameRect`, `snip2DiagRect`,
/// `snipRoundRect`), all of which derive each corner radius / snip
/// from a guide pinned `0..50000` and scaled by `ss = min(w, h)`, plus
/// `parallelogram` and `trapezoid` (single `adj`, slant / inset
/// `ss·a/100000`). The
/// flowchart aliases that share `build_round_rect` (terminator,
/// alternateProcess) carry no `avLst` in the spec, so they keep their
/// fixed default rounding via the `build_geometry` delegation.
pub fn build_geometry_with_adjustments(
  shape : PresetShape,
  width : Int,
  height : Int,
  adjustments : Array[Adjustment],
) -> ShapeGeometry {
  if width <= 0 || height <= 0 {
    return { commands: [], width: 0, height: 0 }
  }
  // §20.1.9.11 — resolve a named guide (clamping is applied inside each
  // builder per the shape's documented `pin` range).
  fn g(name : String, default_value : Int) -> Int {
    adjustment_value(adjustments, name, default_value)
  }

  match shape {
    // Single `adj` guide (default 16667).
    ShapeRoundRect => build_round_rect(width, height, adj=g("adj", 16667))
    ShapePlaque => build_plaque(width, height, adj=g("adj", 16667))
    ShapeRound1Rect => build_round1_rect(width, height, adj=g("adj", 16667))
    ShapeSnip1Rect => build_snip1_rect(width, height, adj=g("adj", 16667))
    // Two `adj1`/`adj2` guides — top/bottom defaults 16667/0.
    ShapeRound2SameRect =>
      build_round2_same_rect(
        width,
        height,
        adj1=g("adj1", 16667),
        adj2=g("adj2", 0),
      )
    ShapeRound2DiagRect =>
      build_round2_diag_rect(
        width,
        height,
        adj1=g("adj1", 16667),
        adj2=g("adj2", 0),
      )
    ShapeSnip2SameRect =>
      build_snip2_same_rect(
        width,
        height,
        adj1=g("adj1", 16667),
        adj2=g("adj2", 0),
      )
    // snip2DiagRect — spec defaults adj1=0, adj2=16667.
    ShapeSnip2DiagRect =>
      build_snip2_diag_rect(
        width,
        height,
        adj1=g("adj1", 0),
        adj2=g("adj2", 16667),
      )
    // snipRoundRect — both guides default 16667 (round TL + snip TR).
    ShapeSnipRoundRect =>
      build_snip_round_rect(
        width,
        height,
        adj1=g("adj1", 16667),
        adj2=g("adj2", 16667),
      )
    // Single `adj` guide (default 25000); slant / inset are `ss`-based.
    ShapeParallelogram => build_parallelogram(width, height, adj=g("adj", 25000))
    ShapeTrapezoid => build_trapezoid(width, height, adj=g("adj", 25000))
    // mathMinus — bar thickness from the `adj1` guide (default 23520).
    ShapeMathMinus => build_minus(width, height, adj=g("adj1", 23520))
    // plus — corner inset from the `adj` guide (default 25000).
    ShapePlus => build_plus(width, height, adj=g("adj", 25000))
    // mathEqual — bar thickness (adj1) and inter-bar gap (adj2).
    ShapeMathEqual =>
      build_equal(width, height, adj1=g("adj1", 23520), adj2=g("adj2", 11760))
    // mathPlus — centred cross arm thickness from `adj1` (default 23520).
    ShapeMathPlus => build_math_plus(width, height, adj1=g("adj1", 23520))
    // mathDivide — bar thickness (adj1), dot gap (adj2), dot radius (adj3).
    ShapeMathDivide =>
      build_divide(
        width,
        height,
        adj1=g("adj1", 23520),
        adj2=g("adj2", 5880),
        adj3=g("adj3", 11760),
      )
    // homePlate / chevron — point depth from the `adj` guide (default 50000).
    ShapeHomePlate => build_home_plate(width, height, adj=g("adj", 50000))
    ShapeChevron => build_chevron(width, height, adj=g("adj", 50000))
    // Block arrows — adj1 = shaft thickness, adj2 = head length (ss-based).
    ShapeRightArrow =>
      build_right_arrow(width, height, adj1=g("adj1", 50000), adj2=g("adj2", 50000))
    ShapeLeftArrow =>
      build_left_arrow(width, height, adj1=g("adj1", 50000), adj2=g("adj2", 50000))
    ShapeUpArrow =>
      build_up_arrow(width, height, adj1=g("adj1", 50000), adj2=g("adj2", 50000))
    ShapeDownArrow =>
      build_down_arrow(width, height, adj1=g("adj1", 50000), adj2=g("adj2", 50000))
    ShapeLeftRightArrow =>
      build_left_right_arrow(
        width,
        height,
        adj1=g("adj1", 50000),
        adj2=g("adj2", 50000),
      )
    ShapeUpDownArrow =>
      build_up_down_arrow(
        width,
        height,
        adj1=g("adj1", 50000),
        adj2=g("adj2", 50000),
      )
    // frame — band thickness from the `adj1` guide (default 12500).
    ShapeFrame => build_frame(width, height, adj1=g("adj1", 12500))
    // corner — L-gnomon band widths from adj1 (height band) / adj2 (width band).
    ShapeCorner =>
      build_corner(width, height, adj1=g("adj1", 50000), adj2=g("adj2", 50000))
    // diagStripe — diagonal-band offset from the `adj` guide (default 50000).
    ShapeDiagStripe => build_diag_stripe(width, height, adj=g("adj", 50000))
    // bevel / foldedCorner — single `adj` band/fold width (ss-based).
    ShapeBevel => build_bevel(width, height, adj=g("adj", 12500))
    ShapeFoldedCorner => build_folded_corner(width, height, adj=g("adj", 16667))
    // cube depth / can cap — single `adj`, ss-based.
    ShapeCube => build_cube(width, height, adj=g("adj", 25000))
    ShapeCan => build_can(width, height, adj=g("adj", 25000))
    // Circular sectors — adj1 = start angle, adj2 = end angle (ECMA units).
    ShapePie => build_pie(width, height, adj1=g("adj1", 0), adj2=g("adj2", 16200000))
    ShapeArc =>
      build_arc(width, height, adj1=g("adj1", 16200000), adj2=g("adj2", 0))
    ShapeChord =>
      build_chord(width, height, adj1=g("adj1", 2700000), adj2=g("adj2", 16200000))
    // teardrop — pull amount of the corner point from `adj` (default 100000).
    ShapeTeardrop => build_teardrop(width, height, adj=g("adj", 100000))
    // notched / striped right arrows — shaft thickness + head length.
    ShapeNotchedRightArrow =>
      build_notched_right_arrow(
        width,
        height,
        adj1=g("adj1", 50000),
        adj2=g("adj2", 50000),
      )
    ShapeStripedRightArrow =>
      build_striped_right_arrow(
        width,
        height,
        adj1=g("adj1", 50000),
        adj2=g("adj2", 50000),
      )
    // curvedRightArrow — shaft thickness (adj1), head width (adj2),
    // head length (adj3); arcs via the verified rel_arc helper.
    ShapeCurvedRightArrow =>
      build_curved_right_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 50000),
        adj3=g("adj3", 25000),
      )
    ShapeCurvedLeftArrow =>
      build_curved_left_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 50000),
        adj3=g("adj3", 25000),
      )
    ShapeCurvedUpArrow =>
      build_curved_up_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 50000),
        adj3=g("adj3", 25000),
      )
    ShapeCurvedDownArrow =>
      build_curved_down_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 50000),
        adj3=g("adj3", 25000),
      )
    // right/left arrow callouts — box width + arrow shaft/head (ss-based).
    ShapeRightArrowCallout =>
      build_right_arrow_callout(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
        adj4=g("adj4", 64977),
      )
    ShapeLeftArrowCallout =>
      build_left_arrow_callout(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
        adj4=g("adj4", 64977),
      )
    ShapeUpArrowCallout =>
      build_up_arrow_callout(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
        adj4=g("adj4", 64977),
      )
    ShapeDownArrowCallout =>
      build_down_arrow_callout(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
        adj4=g("adj4", 64977),
      )
    ShapeLeftRightArrowCallout =>
      build_left_right_arrow_callout(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
        adj4=g("adj4", 48123),
      )
    ShapeUpDownArrowCallout =>
      build_up_down_arrow_callout(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
        adj4=g("adj4", 48123),
      )
    // leftRightUpArrow — left+right+up triple arrow, ss-based guides.
    ShapeLeftRightUpArrow =>
      build_left_right_up_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
      )
    // leftUpArrow — left+up double arrow, ss-based guides.
    ShapeLeftUpArrow =>
      build_left_up_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
      )
    // donut — ring thickness from the `adj` guide (default 25000).
    ShapeDonut => build_donut(width, height, adj=g("adj", 25000))
    // noSmoking — bar thickness from `adj`; bar angle = at2(w,h).
    ShapeNoSmoking => build_no_smoking(width, height, adj=g("adj", 18750))
    // leftBrace — curl radius (adj1) + pinch height (adj2), via rel_arc.
    ShapeLeftBrace =>
      build_left_brace(width, height, adj1=g("adj1", 8333), adj2=g("adj2", 50000))
    ShapeRightBrace =>
      build_right_brace(width, height, adj1=g("adj1", 8333), adj2=g("adj2", 50000))
    ShapeBracePair => build_brace_pair(width, height, adj=g("adj", 8333))
    // moon — crescent; adj is the inner-arc curvature (at2-derived).
    ShapeMoon => build_moon(width, height, adj=g("adj", 50000))
    // sun — eight rays + central disc; adj sets the disc/ray split.
    ShapeSun => build_sun(width, height, adj=g("adj", 25000))
    // circularArrow / leftCircularArrow — data-driven guide chains
    // (line/ellipse intersections) evaluated by the guide_engine.
    ShapeCircularArrow =>
      build_from_definition(circular_arrow_def(), width, height, adjustments)
    ShapeLeftCircularArrow =>
      build_from_definition(left_circular_arrow_def(), width, height, adjustments)
    ShapeLeftRightCircularArrow =>
      build_from_definition(
        left_right_circular_arrow_def(),
        width,
        height,
        adjustments,
      )
    // gear6 / gear9 — data-driven tooth chains via the guide_engine.
    ShapeGear6 => build_from_definition(gear6_def(), width, height, adjustments)
    ShapeGear9 => build_from_definition(gear9_def(), width, height, adjustments)
    // cloudCallout — cloud body + 3 tail bubbles; adj1/adj2 = tail tip.
    ShapeCloudCallout =>
      build_cloud_callout(
        width,
        height,
        adj1=g("adj1", -20833),
        adj2=g("adj2", 62500),
      )
    // brackets — corner radius from the `adj` guide.
    ShapeLeftBracket => build_left_bracket(width, height, adj=g("adj", 8333))
    ShapeRightBracket => build_right_bracket(width, height, adj=g("adj", 8333))
    ShapeBracketPair => build_bracket_pair(width, height, adj=g("adj", 16667))
    // wave / doubleWave — amplitude (adj1) + horizontal skew (adj2).
    ShapeWave => build_wave(width, height, adj1=g("adj1", 12500), adj2=g("adj2", 0))
    ShapeDoubleWave =>
      build_double_wave(width, height, adj1=g("adj1", 6250), adj2=g("adj2", 0))
    // bentUpArrow — L-shaped arrow, ss-based shaft/head guides.
    ShapeBentUpArrow =>
      build_bent_up_arrow(
        width,
        height,
        adj1=g("adj1", 25000),
        adj2=g("adj2", 25000),
        adj3=g("adj3", 25000),
      )
    // quadArrow — shaft thickness / head half-width / head length guides.
    ShapeQuadArrow =>
      build_quad_arrow(
        width,
        height,
        adj1=g("adj1", 22500),
        adj2=g("adj2", 22500),
        adj3=g("adj3", 22500),
      )
    // star{n} — point sharpness from `adj`; per-star hf/vf scale factors.
    ShapeStar4
    | ShapeStar5
    | ShapeStar6
    | ShapeStar7
    | ShapeStar8
    | ShapeStar10
    | ShapeStar12
    | ShapeStar16
    | ShapeStar24
    | ShapeStar32 =>
      match star_params(shape) {
        Some((n, default_adj, hf, vf)) =>
          build_star(n, width, height, adj=g("adj", default_adj), hf~, vf~)
        None => build_geometry(shape, width, height)
      }
    // blockArc — start/inner-start angles + ring thickness.
    ShapeBlockArc =>
      build_block_arc(
        width,
        height,
        adj1=g("adj1", 10800000),
        adj2=g("adj2", 0),
        adj3=g("adj3", 25000),
      )
    _ => build_geometry(shape, width, height)
  }
}
