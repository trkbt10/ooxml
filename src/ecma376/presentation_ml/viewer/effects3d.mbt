// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/effects3d.ts
//
// ECMA-376 §20.1.5 3D scene/shape effects rendered as 2D SVG
// approximations. The TS source explicitly notes that SVG is a 2D
// format so the result is a deliberate approximation — extrusion via
// layered paths, bevel via four trapezoidal highlight/shadow paths,
// lighting via a single linearGradient.
//
// Spec references:
//   §20.1.5.5  camera        (camera preset → 2D skew/scale)
//   §20.1.5.9  lightRig      (rig + dir → gradient stops)
//   §20.1.5.4  bevelT        (top bevel → trapezoid stack)
//   §20.1.5.12 sp3d          (extrusionH / contourW / extrusionClr)
//   §20.1.10.47 ST_PresetCameraType (camera preset enumeration)
//   §20.1.10.50 ST_LightRigDirection (light direction enumeration)
//   §20.1.10.51 ST_LightRigType (rig type enumeration)
//
// Like effects.mbt and marker.mbt this module operates on raw XML
// elements so it can be invoked inline from `render_sp_shape_svg`
// without re-parsing the §20.1.5 substructure.

///|
/// Result of resolving a §20.1.5.5 `camera` preset (§20.1.10.47
/// ST_PresetCameraType) to a CSS-style
/// transform. Mirrors `Transform3dResult` in `effects3d.ts:150`.
/// The structured fields are the single source of truth — the
/// `transform` attribute string is composed from them on demand by
/// `compose_transform3d_attr` so callers can also re-use the
/// components when stacking the camera transform with a group / shape
/// transform.
priv struct Transform3d {
  skew_x : Double
  skew_y : Double
  scale_x : Double
  scale_y : Double
  rotation : Double
}

///|
fn transform3d_identity() -> Transform3d {
  { skew_x: 0.0, skew_y: 0.0, scale_x: 1.0, scale_y: 1.0, rotation: 0.0 }
}

///|
fn transform3d_is_identity(t : Transform3d) -> Bool {
  t.skew_x == 0.0 &&
  t.skew_y == 0.0 &&
  t.scale_x == 1.0 &&
  t.scale_y == 1.0 &&
  t.rotation == 0.0
}

///|
/// Compose the §20.1.5.5 camera transform (§20.1.10.47
/// ST_PresetCameraType preset values) from its structured fields
/// into a CSS-syntax `transform` attribute value. Emits primitives in
/// the order `rotate → skewX → skewY → scale`, skipping identity
/// components so the result matches the inline transform string the
/// renderer used to produce by hand.
fn compose_transform3d_attr(t : Transform3d) -> String {
  let parts = StringBuilder::new()
  let first : Ref[Bool] = { val: true }
  let append_sep = fn() {
    if first.val {
      first.val = false
    } else {
      parts.write_char(' ')
    }
  }
  if t.rotation != 0.0 {
    append_sep()
    parts.write_string("rotate(")
    parts.write_string(format_double_for_filter(t.rotation))
    parts.write_string(")")
  }
  if t.skew_x != 0.0 {
    append_sep()
    parts.write_string("skewX(")
    parts.write_string(format_double_for_filter(t.skew_x))
    parts.write_string(")")
  }
  if t.skew_y != 0.0 {
    append_sep()
    parts.write_string("skewY(")
    parts.write_string(format_double_for_filter(t.skew_y))
    parts.write_string(")")
  }
  if t.scale_x != 1.0 || t.scale_y != 1.0 {
    append_sep()
    parts.write_string("scale(")
    parts.write_string(format_double_for_filter(t.scale_x))
    parts.write_string(", ")
    parts.write_string(format_double_for_filter(t.scale_y))
    parts.write_string(")")
  }
  parts.to_string()
}

///|
/// Structured §20.1.5 3D-effect bundle for a shape.
///
/// - `transform_attrs` is the `transform` attribute list (empty when
///   the camera preset is the identity) applied on the outer `<g>`.
/// - `extrusion` is rendered *before* the main shape path.
/// - `bevel` is rendered *after* the main shape path.
/// - `contour` (§20.1.5.12 contourW / contourClr) is the edge outline,
///   rendered *after* the bevel so it traces the shape's silhouette.
/// - `gradient_def` is pushed into the `<defs>` collector for
///   `url(#lighting-<shapeId>)` references.
pub struct Effects3d {
  transform_attrs : Array[@xml.Attribute]
  extrusion : @xml.Node?
  bevel : @xml.Node?
  contour : @xml.Node?
  gradient_def : @xml.Node?
}

///|
/// Compute the §20.1.5 effect bundle for a shape as a structured
/// `Effects3d` record.  Internal counterpart of `render_3d_effects`
/// — viewer-internal callers thread the nodes straight into the SVG
/// tree rather than re-parsing serialised fragments.
fn compute_3d_effects(
  sp_pr : @xml.Element,
  shape_path : String,
  shape_id : String,
  width : Double,
  height : Double,
) -> Effects3d {
  let scene3d = first_child_named(sp_pr, "scene3d")
  let sp3d = first_child_named(sp_pr, "sp3d")
  if scene3d is None && sp3d is None {
    return {
      transform_attrs: [],
      extrusion: None,
      bevel: None,
      contour: None,
      gradient_def: None,
    }
  }
  let camera_el = match scene3d {
    None => None
    Some(s) => first_child_named(s, "camera")
  }
  let camera_preset = match camera_el {
    None => "orthographicFront"
    Some(c) =>
      match attr_value(c, "prst") {
        Some(p) => p
        None => "orthographicFront"
      }
  }
  // §20.1.5.5 — the preset gives the base projection; `@zoom` and the
  // `<a:rot>` child refine it.  `@zoom` (ST_PositivePercentage, default
  // 100 000 = 100 %) scales the apparent size; `<a:rot @rev>` is the
  // camera roll (60 000ths of a degree) and maps exactly onto the 2D
  // rotation.  (`@lat`/`@lon` are out-of-plane rotations a flat
  // projection cannot reproduce, so they are not applied.)
  let transform = match camera_el {
    None => calculate_camera_transform(camera_preset)
    Some(c) =>
      apply_camera_zoom_rot(calculate_camera_transform(camera_preset), c)
  }
  let transform_attrs : Array[@xml.Attribute] = if transform3d_is_identity(
      transform,
    ) {
    []
  } else {
    [@markup.attr("transform", compose_transform3d_attr(transform))]
  }
  let light_dir = match scene3d {
    None => "tl"
    Some(s) =>
      match first_child_named(s, "lightRig") {
        None => "tl"
        Some(lr) =>
          match attr_value(lr, "dir") {
            Some(d) => d
            None => "tl"
          }
      }
  }
  let gradient_def = match scene3d {
    None => None
    Some(s) =>
      match first_child_named(s, "lightRig") {
        None => None
        Some(lr) => Some(lighting_gradient(lr, shape_id))
      }
  }
  let extrusion = match sp3d {
    None => None
    Some(s) => extrusion_element(s, shape_path, camera_preset)
  }
  let bevel = match sp3d {
    None => None
    Some(s) => bevel_element(s, width, height, light_dir)
  }
  let contour = match sp3d {
    None => None
    Some(s) => contour_element(s, shape_path)
  }
  { transform_attrs, extrusion, bevel, contour, gradient_def }
}

///|
/// Render the §20.1.5 effect bundle for a shape as a structured
/// `Effects3d` record so the caller can thread its `@xml.Node` parts
/// straight into the SVG tree.  The SVG payload is always built from
/// an `@xml.Node` tree — never assembled by string concatenation.
///
/// - `transform_attrs` is the `transform` attribute list (empty when
///   the camera preset is the identity) applied on the outer `<g>`.
/// - `extrusion` is rendered *before* the main shape path.
/// - `bevel` is rendered *after* the main shape path.
/// - `gradient_def` is pushed into the `<defs>` collector for
///   `url(#lighting-<shapeId>)` references.
pub fn render_3d_effects(
  sp_pr : @xml.Element,
  shape_path : String,
  shape_id : String,
  width : Double,
  height : Double,
) -> Effects3d {
  compute_3d_effects(sp_pr, shape_path, shape_id, width, height)
}

///|
/// Has any §20.1.5 3D effect? Used as a fast-path skip in callers.
pub fn has_3d_effects(sp_pr : @xml.Element) -> Bool {
  let scene3d = first_child_named(sp_pr, "scene3d")
  let sp3d = first_child_named(sp_pr, "sp3d")
  match sp3d {
    Some(s) => {
      if attr_value(s, "extrusionH") is Some(v) {
        if (try? @string.parse_double(v)) is Ok(d) {
          if d > 0.0 {
            return true
          }
        }
      }
      if first_child_named(s, "bevelT") is Some(_) {
        return true
      }
      if first_child_named(s, "bevelB") is Some(_) {
        return true
      }
      // §20.1.5.12 contourW — a coloured edge outline is a 3D effect
      // even without extrusion / bevel.
      if attr_value(s, "contourW") is Some(v) {
        if (try? @string.parse_double(v)) is Ok(d) {
          if d > 0.0 {
            return true
          }
        }
      }
    }
    None => ()
  }
  match scene3d {
    Some(s) =>
      match first_child_named(s, "camera") {
        Some(c) => {
          // A non-default preset, an explicit zoom, or a roll/tilt all
          // produce a non-identity camera transform.
          let non_default_prst = match attr_value(c, "prst") {
            Some(p) => p != "orthographicFront"
            None => false
          }
          let has_zoom = attr_value(c, "zoom") is Some(_)
          let has_rot = first_child_named(c, "rot") is Some(_)
          non_default_prst || has_zoom || has_rot
        }
        None => false
      }
    None => false
  }
}

// ─────────────────────────────────────────────────────────────────────
// §20.1.5.5 camera preset → 2D transform.
// Mirrors `calculateCameraTransform` in `effects3d.ts:195`.
// ─────────────────────────────────────────────────────────────────────

///|
fn calculate_camera_transform(preset : String) -> Transform3d {
  let id = transform3d_identity()
  // §20.1.10.47 ST_PresetCameraType — the 62 enumerated camera
  // presets.  ECMA-376 names the cameras but does not publish their
  // projection matrices (the actual rotation/position is application-
  // defined), so each is approximated here on the 2D SVG surface with
  // a skew/scale derived from the camera's named direction and family:
  //   • isometric  → ±30° skews (off-axis variants add a secondary
  //     skew on the orthogonal axis);
  //   • oblique / legacyOblique → ±15° directional skews;
  //   • perspective / legacyPerspective → directional skew + a depth
  //     foreshortening scale, growing for the heroic / extreme rigs.
  // `orthographicFront` (the spec default) and the head-on `*Front`
  // cameras stay at identity.  Schema-violating values fall back to
  // identity.
  match preset {
    // ── Orthographic (spec default, head-on) ─────────────────────
    "orthographicFront" => id
    // ── Isometric (±30° symmetric skews) ─────────────────────────
    "isometricTopUp" | "isometricTopDown" =>
      { ..id, skew_x: -30.0, skew_y: 30.0 }
    "isometricBottomUp" | "isometricBottomDown" =>
      { ..id, skew_x: 30.0, skew_y: -30.0 }
    "isometricLeftUp" | "isometricLeftDown" => { ..id, skew_x: 30.0 }
    "isometricRightUp" | "isometricRightDown" => { ..id, skew_x: -30.0 }
    // Isometric off-axis rigs — primary 30° skew plus a 20° tilt on
    // the orthogonal axis, signed by the named facing.
    "isometricOffAxis1Left" => { ..id, skew_x: 30.0, skew_y: 20.0 }
    "isometricOffAxis1Right" => { ..id, skew_x: -30.0, skew_y: 20.0 }
    "isometricOffAxis1Top" => { ..id, skew_x: -20.0, skew_y: 30.0 }
    "isometricOffAxis2Left" => { ..id, skew_x: 30.0, skew_y: -20.0 }
    "isometricOffAxis2Right" => { ..id, skew_x: -30.0, skew_y: -20.0 }
    "isometricOffAxis2Top" => { ..id, skew_x: 20.0, skew_y: 30.0 }
    "isometricOffAxis3Left" => { ..id, skew_x: 20.0, skew_y: -30.0 }
    "isometricOffAxis3Right" => { ..id, skew_x: -20.0, skew_y: -30.0 }
    "isometricOffAxis3Bottom" => { ..id, skew_x: -30.0, skew_y: -20.0 }
    "isometricOffAxis4Left" => { ..id, skew_x: 20.0, skew_y: 30.0 }
    "isometricOffAxis4Right" => { ..id, skew_x: -20.0, skew_y: 30.0 }
    "isometricOffAxis4Bottom" => { ..id, skew_x: 30.0, skew_y: 20.0 }
    // ── Oblique / legacy oblique (15° directional skews) ─────────
    "obliqueTopLeft" | "legacyObliqueTopLeft" =>
      { ..id, skew_x: -15.0, skew_y: -15.0 }
    "obliqueTop" | "legacyObliqueTop" => { ..id, skew_y: -15.0 }
    "obliqueTopRight" | "legacyObliqueTopRight" =>
      { ..id, skew_x: 15.0, skew_y: -15.0 }
    "obliqueLeft" | "legacyObliqueLeft" => { ..id, skew_x: -15.0 }
    "legacyObliqueFront" => id
    "obliqueRight" | "legacyObliqueRight" => { ..id, skew_x: 15.0 }
    "obliqueBottomLeft" | "legacyObliqueBottomLeft" =>
      { ..id, skew_x: -15.0, skew_y: 15.0 }
    "obliqueBottom" | "legacyObliqueBottom" => { ..id, skew_y: 15.0 }
    "obliqueBottomRight" | "legacyObliqueBottomRight" =>
      { ..id, skew_x: 15.0, skew_y: 15.0 }
    // ── Perspective / legacy perspective (skew + depth scale) ────
    "perspectiveFront" | "perspectiveRelaxed" | "legacyPerspectiveFront" =>
      { ..id, scale_y: 0.9 }
    "perspectiveRelaxedModerately" => { ..id, scale_y: 0.93 }
    "perspectiveAbove" | "legacyPerspectiveTop" =>
      { ..id, skew_y: -10.0, scale_y: 0.85 }
    "perspectiveBelow" | "legacyPerspectiveBottom" =>
      { ..id, skew_y: 10.0, scale_y: 0.85 }
    "perspectiveLeft" | "legacyPerspectiveLeft" =>
      { ..id, skew_x: -10.0, scale_x: 0.9 }
    "perspectiveRight" | "legacyPerspectiveRight" =>
      { ..id, skew_x: 10.0, scale_x: 0.9 }
    "legacyPerspectiveTopLeft" =>
      { ..id, skew_x: -10.0, skew_y: -10.0, scale_y: 0.9 }
    "legacyPerspectiveTopRight" =>
      { ..id, skew_x: 10.0, skew_y: -10.0, scale_y: 0.9 }
    "legacyPerspectiveBottomLeft" =>
      { ..id, skew_x: -10.0, skew_y: 10.0, scale_y: 0.9 }
    "legacyPerspectiveBottomRight" =>
      { ..id, skew_x: 10.0, skew_y: 10.0, scale_y: 0.9 }
    "perspectiveAboveLeftFacing" =>
      { ..id, skew_x: -10.0, skew_y: -10.0, scale_y: 0.85 }
    "perspectiveAboveRightFacing" =>
      { ..id, skew_x: 10.0, skew_y: -10.0, scale_y: 0.85 }
    "perspectiveContrastingLeftFacing" =>
      { ..id, skew_x: -15.0, scale_x: 0.9, scale_y: 0.9 }
    "perspectiveContrastingRightFacing" =>
      { ..id, skew_x: 15.0, scale_x: 0.9, scale_y: 0.9 }
    "perspectiveHeroicLeftFacing" => { ..id, skew_x: -20.0, scale_y: 0.85 }
    "perspectiveHeroicRightFacing" => { ..id, skew_x: 20.0, scale_y: 0.85 }
    "perspectiveHeroicExtremeLeftFacing" =>
      { ..id, skew_x: -25.0, scale_x: 0.85, scale_y: 0.8 }
    "perspectiveHeroicExtremeRightFacing" =>
      { ..id, skew_x: 25.0, scale_x: 0.85, scale_y: 0.8 }
    // Schema-violating / unknown values → identity fallback.
    _ => id
  }
}

///|
/// §20.1.5.5 `<a:camera>` — refine the preset transform with the
/// camera's `@zoom` (ST_PositivePercentage; scales apparent size) and
/// the `<a:rot lat lon rev>` orientation (ST_Angle, 60 000ths of a
/// degree).
///
///   • `@rev` is the camera roll → the in-plane 2D rotation.
///   • `@lat` (pitch) and `@lon` (yaw) are out-of-plane rotations.  A
///     flat projection cannot reveal faces that rotate out of view, but
///     it CAN reproduce the dominant visible effect: a plane rotated by
///     θ about an in-view axis foreshortens its projected extent by
///     cos θ.  We apply that foreshortening (lat → vertical, lon →
///     horizontal) so lat/lon influence the silhouette, mirroring how
///     the perspective presets already skew/scale.  (The hidden-face
///     content a full rotation would expose is genuinely absent from a
///     2D shape and is the one irreducibly-3D residual.)
fn apply_camera_zoom_rot(
  base : Transform3d,
  camera : @xml.Element,
) -> Transform3d {
  // @zoom — thousandths of a percent; default 100000 (= 100 %).
  let zoom_raw = match attr_value(camera, "zoom") {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => 100000.0
      } noraise {
        n => n
      }
    None => 100000.0
  }
  let zoom = zoom_raw / 100000.0
  let zoom_factor = if zoom > 0.0 { zoom } else { 1.0 }
  // <a:rot lat lon rev> — all in 60000ths of a degree.
  fn rot_attr(name : String) -> Double {
    match first_child_named(camera, "rot") {
      None => 0.0
      Some(rot) =>
        match attr_value(rot, name) {
          Some(v) =>
            try @string.parse_double(v) catch {
              _ => 0.0
            } noraise {
              n => n / 60000.0
            }
          None => 0.0
        }
    }
  }

  let rev_deg = rot_attr("rev")
  let lat_deg = rot_attr("lat")
  let lon_deg = rot_attr("lon")
  // Foreshortening factor |cos θ| (clamped to a small floor so an
  // edge-on plane does not collapse to a zero-area, invisible shape).
  fn foreshorten(deg : Double) -> Double {
    if deg == 0.0 {
      1.0
    } else {
      let c = @math.cos(deg * 3.14159265358979 / 180.0)
      let a = if c < 0.0 { -c } else { c }
      if a < 0.05 {
        0.05
      } else {
        a
      }
    }
  }

  {
    ..base,
    scale_x: base.scale_x * zoom_factor * foreshorten(lon_deg),
    scale_y: base.scale_y * zoom_factor * foreshorten(lat_deg),
    rotation: base.rotation + rev_deg,
  }
}

// ─────────────────────────────────────────────────────────────────────
// §20.1.5.9 lightRig → lighting gradient.
// Mirrors `calculateLightingGradient` in `effects3d.ts:361`.
// ─────────────────────────────────────────────────────────────────────

///|
fn lighting_gradient(light_rig : @xml.Element, shape_id : String) -> @xml.Node {
  let direction = match attr_value(light_rig, "dir") {
    Some(d) => d
    None => "tl"
  }
  let rig = match attr_value(light_rig, "rig") {
    Some(r) => r
    None => "threePt"
  }
  let coords = gradient_coords(direction)
  let (hi, sh) = lighting_intensity(rig)
  let stop = (offset : String, color : String, opacity : String) => {
    @markup.elem_ns(
      "stop",
      @markup.svg_ns,
      [
        @markup.attr("offset", offset),
        @markup.attr("stop-color", color),
        @markup.attr("stop-opacity", opacity),
      ],
      [],
    )
  }
  @markup.elem_ns(
    "linearGradient",
    @markup.svg_ns,
    [
      @markup.attr("id", "lighting-" + shape_id),
      @markup.attr("x1", format_pct(coords.0) + "%"),
      @markup.attr("y1", format_pct(coords.1) + "%"),
      @markup.attr("x2", format_pct(coords.2) + "%"),
      @markup.attr("y2", format_pct(coords.3) + "%"),
    ],
    [
      stop("0%", "white", format_opacity(hi)),
      stop("50%", "white", "0"),
      stop("100%", "black", format_opacity(sh)),
    ],
  )
}

///|
fn gradient_coords(direction : String) -> (Double, Double, Double, Double) {
  // §20.1.10.50 ST_LightRigDirection — closed-8 enum:
  // tl, t, tr, l, r, bl, b, br.
  match direction {
    "tl" => (0.0, 0.0, 100.0, 100.0)
    "t" => (50.0, 0.0, 50.0, 100.0)
    "tr" => (100.0, 0.0, 0.0, 100.0)
    "l" => (0.0, 50.0, 100.0, 50.0)
    "r" => (100.0, 50.0, 0.0, 50.0)
    "bl" => (0.0, 100.0, 100.0, 0.0)
    "b" => (50.0, 100.0, 50.0, 0.0)
    "br" => (100.0, 100.0, 0.0, 0.0)
    // Schema violation — fall back to the §20.1.10.50 default
    // direction `tl` (top-left).
    _ => (0.0, 0.0, 100.0, 100.0)
  }
}

///|
fn lighting_intensity(rig : String) -> (Double, Double) {
  // §20.1.10.51 ST_LightRigType — closed-18 enum:
  //   threePt, balanced, soft, harsh, flood, contrasting, morning,
  //   sunrise, sunset, chilly, freezing, flat, twoPt, glow,
  //   brightRoom, sky, fluorescent, legacyFlat1..4, legacyNormal1..4,
  //   legacyHarsh1..4, legacyHard1..4.  (Spec lists 18 base
  //   names plus 16 legacy variants for backward compatibility.)
  //
  // The highlight / shadow intensity tuple is renderer policy
  // — the spec describes the rigs qualitatively (e.g. "harsh"
  // gives strong contrast) but does NOT pin numeric opacity
  // values.  The constants below mirror the TS reference; spec-
  // aware consumers can override via `<a:lightRig>` rotation
  // sub-elements.
  match rig {
    "harsh"
    | "legacyHarsh1"
    | "legacyHarsh2"
    | "legacyHarsh3"
    | "legacyHarsh4" => (0.4, 0.4)
    "soft" | "balanced" | "threePt" | "twoPt" => (0.2, 0.2)
    "flat" | "legacyFlat1" | "legacyFlat2" | "legacyFlat3" | "legacyFlat4" =>
      (0.1, 0.1)
    "flood" | "brightRoom" => (0.3, 0.1)
    "contrasting" => (0.5, 0.5)
    "glow" => (0.4, 0.15)
    "morning" | "sunrise" | "sunset" => (0.3, 0.2)
    "chilly" | "freezing" => (0.25, 0.3)
    "sky" => (0.3, 0.15)
    "fluorescent" => (0.4, 0.1)
    "legacyNormal1" | "legacyNormal2" | "legacyNormal3" | "legacyNormal4" =>
      (0.2, 0.2)
    "legacyHard1" | "legacyHard2" | "legacyHard3" | "legacyHard4" =>
      (0.35, 0.35)
    // Schema violation — value outside ST_LightRigType.  Fall
    // back to a neutral intensity tuple.
    _ => (0.25, 0.25)
  }
}

// ─────────────────────────────────────────────────────────────────────
// §20.1.5.4 bevelT → four trapezoidal highlight/shadow paths.
// Mirrors `renderBevelEffect` in `effects3d.ts:471`.
// ─────────────────────────────────────────────────────────────────────

///|
fn bevel_element(
  sp3d : @xml.Element,
  width : Double,
  height : Double,
  light_direction : String,
) -> @xml.Node? {
  // §20.1.5.4 bevelT (front face) + §20.1.5.3 bevelB (back face).  The
  // back bevel is lit from the opposite side (its facets point away
  // from the viewer) and reads dimmer, so it is drawn first (behind),
  // with inverted highlight / shadow and reduced opacity, then the
  // front bevel on top.
  let back = match first_child_named(sp3d, "bevelB") {
    Some(bb) =>
      bevel_band_group(
        bb,
        width,
        height,
        light_direction,
        invert=true,
        opacity_scale=0.5,
        class_name="bevel-effect-back",
      )
    None => None
  }
  let front = match first_child_named(sp3d, "bevelT") {
    Some(bt) =>
      bevel_band_group(
        bt,
        width,
        height,
        light_direction,
        invert=false,
        opacity_scale=1.0,
        class_name="bevel-effect",
      )
    None => None
  }
  match (back, front) {
    (None, None) => None
    (None, Some(f)) => Some(f)
    (Some(b), None) => Some(b)
    (Some(b), Some(f)) =>
      Some(
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          [@markup.attr("class", "bevel-effect")],
          [b, f],
        ),
      )
  }
}

///|
/// Build the four trapezoidal highlight / shadow bands for a single
/// bevel (§20.1.5.3 bevelB / §20.1.5.4 bevelT).  `invert` swaps the
/// highlight / shadow sides for the back face; `opacity_scale` dims the
/// whole group (the back face reads fainter).  The §20.1.10.27
/// `@prst` profile further softens rounded edges.
fn bevel_band_group(
  bevel_el : @xml.Element,
  width : Double,
  height : Double,
  light_direction : String,
  invert~ : Bool,
  opacity_scale~ : Double,
  class_name~ : String,
) -> @xml.Node? {
  let bw = attr_emu_d(bevel_el, "w", 76200.0) // §20.1.8.5 default 76200 EMU
  let bh = attr_emu_d(bevel_el, "h", 76200.0)
  let scale_emu = 9525.0 // EMU/px conversion for the 2D-space caps.
  let bw_px = bw / scale_emu
  let bh_px = bh / scale_emu
  let cap_w = min_double(width / 4.0, bw_px)
  let cap_h = min_double(height / 4.0, bh_px)
  let bevel_w = min_double(cap_w, cap_h)
  let bevel_h = bevel_w
  if bevel_w <= 0.0 || bevel_h <= 0.0 {
    return None
  }
  let (hi_side, sh_side) = bevel_sides(light_direction)
  // The four edge-highlight booleans, optionally inverted for a back
  // face whose facets are lit from the opposite direction.
  let top0 = hi_side.contains("top")
  let left0 = hi_side.contains("left")
  let bottom0 = !sh_side.contains("bottom")
  let right0 = !sh_side.contains("right")
  let (top, left, bottom, right) = if invert {
    (!top0, !left0, !bottom0, !right0)
  } else {
    (top0, left0, bottom0, right0)
  }
  let paths : Array[@xml.Node] = [
    bevel_path_top(width, bevel_w, bevel_h, top),
    bevel_path_left(height, bevel_w, bevel_h, left),
    bevel_path_bottom(width, height, bevel_w, bevel_h, bottom),
    bevel_path_right(width, height, bevel_w, bevel_h, right),
  ]
  // §20.1.10.27 ST_BevelPresetType — the preset names the edge cross-
  // section profile.  A flat 2D front projection cannot show the
  // profile geometry, but it CAN reflect how harsh the edge shading
  // reads: rounded profiles (circle / softRound / convex /
  // relaxedInset / coolSlant) have a gradual light→shadow falloff, so
  // we soften the bands via a group opacity; angular / grooved
  // profiles keep the full-strength edge.  The band geometry / light
  // direction are already driven by @w / @h / lightRig.
  let prst = match attr_value(bevel_el, "prst") {
    Some(p) => p
    None => "relaxedInset"
  }
  let prst_opacity = match prst {
    "circle" | "softRound" | "convex" | "relaxedInset" | "coolSlant" => 0.65
    _ => 1.0
  }
  let opacity = prst_opacity * opacity_scale
  let g_attrs : Array[@xml.Attribute] = [@markup.attr("class", class_name)]
  if opacity != 1.0 {
    g_attrs.push(@markup.attr("opacity", format_opacity(opacity)))
  }
  Some(@markup.elem_ns("g", @markup.svg_ns, g_attrs, paths))
}

///|
/// Build a bevel-edge `<path>` element from its path-data string and
/// fill colour.
fn bevel_path(d : String, fill : String) -> @xml.Node {
  @markup.elem_ns(
    "path",
    @markup.svg_ns,
    [@markup.attr("d", d), @markup.attr("fill", fill)],
    [],
  )
}

///|
fn bevel_path_top(
  width : Double,
  bw : Double,
  bh : Double,
  highlight : Bool,
) -> @xml.Node {
  // §20.1.5.4 bevelT / §20.1.5.3 bevelB — the spec describes the highlight
  // / shadow tonal direction qualitatively but does NOT pin
  // numeric RGBA values; the constants below are renderer
  // policy chosen to match the TS reference's bevel preview.
  // Spec-aware consumers can override via the parent shape's
  // `<a:lnRef>` colour cascade if they need precise tones.
  let fill = if highlight { "rgba(255,255,255,0.3)" } else { "rgba(0,0,0,0.2)" }
  let d = "M 0,0 L " +
    format_double_for_filter(width) +
    ",0 L " +
    format_double_for_filter(width - bw) +
    "," +
    format_double_for_filter(bh) +
    " L " +
    format_double_for_filter(bw) +
    "," +
    format_double_for_filter(bh) +
    " Z"
  bevel_path(d, fill)
}

///|
fn bevel_path_left(
  height : Double,
  bw : Double,
  bh : Double,
  highlight : Bool,
) -> @xml.Node {
  let fill = if highlight {
    "rgba(255,255,255,0.25)"
  } else {
    "rgba(0,0,0,0.15)"
  }
  let d = "M 0,0 L " +
    format_double_for_filter(bw) +
    "," +
    format_double_for_filter(bh) +
    " L " +
    format_double_for_filter(bw) +
    "," +
    format_double_for_filter(height - bh) +
    " L 0," +
    format_double_for_filter(height) +
    " Z"
  bevel_path(d, fill)
}

///|
fn bevel_path_bottom(
  width : Double,
  height : Double,
  bw : Double,
  bh : Double,
  highlight : Bool,
) -> @xml.Node {
  let fill = if highlight {
    "rgba(255,255,255,0.2)"
  } else {
    "rgba(0,0,0,0.25)"
  }
  let d = "M 0," +
    format_double_for_filter(height) +
    " L " +
    format_double_for_filter(bw) +
    "," +
    format_double_for_filter(height - bh) +
    " L " +
    format_double_for_filter(width - bw) +
    "," +
    format_double_for_filter(height - bh) +
    " L " +
    format_double_for_filter(width) +
    "," +
    format_double_for_filter(height) +
    " Z"
  bevel_path(d, fill)
}

///|
fn bevel_path_right(
  width : Double,
  height : Double,
  bw : Double,
  bh : Double,
  highlight : Bool,
) -> @xml.Node {
  let fill = if highlight {
    "rgba(255,255,255,0.25)"
  } else {
    "rgba(0,0,0,0.2)"
  }
  let d = "M " +
    format_double_for_filter(width) +
    ",0 L " +
    format_double_for_filter(width) +
    "," +
    format_double_for_filter(height) +
    " L " +
    format_double_for_filter(width - bw) +
    "," +
    format_double_for_filter(height - bh) +
    " L " +
    format_double_for_filter(width - bw) +
    "," +
    format_double_for_filter(bh) +
    " Z"
  bevel_path(d, fill)
}

///|
fn bevel_sides(direction : String) -> (Array[String], Array[String]) {
  match direction {
    "tl" => (["top", "left"], ["bottom", "right"])
    "t" => (["top"], ["bottom"])
    "tr" => (["top", "right"], ["bottom", "left"])
    "l" => (["left"], ["right"])
    "r" => (["right"], ["left"])
    "bl" => (["bottom", "left"], ["top", "right"])
    "b" => (["bottom"], ["top"])
    "br" => (["bottom", "right"], ["top", "left"])
    _ => (["top", "left"], ["bottom", "right"])
  }
}

// ─────────────────────────────────────────────────────────────────────
// §20.1.5.12 sp3d/@extrusionH → layered translate copies of the path.
// Mirrors `renderExtrusionEffect` in `effects3d.ts:596`.
// ─────────────────────────────────────────────────────────────────────

///|
fn extrusion_element(
  sp3d : @xml.Element,
  shape_path : String,
  camera_preset : String,
) -> @xml.Node? {
  // extrusionH is in EMU (ST_PositiveCoordinate). Convert to px so
  // the per-layer offsets remain visible.
  let extrusion_emu = attr_emu_d(sp3d, "extrusionH", 0.0)
  if extrusion_emu <= 0.0 {
    return None
  }
  let extrusion_h = extrusion_emu / 9525.0
  // §20.1.5.12 `<a:sp3d>` — extrusion colour comes from the
  // optional `<a:extrusionClr>` child.  We resolve its first
  // colour-bearing element through the same path we use for
  // line / fill colours; when no child is present the spec
  // says the extrusion inherits from the shape's fill (which
  // we have no access to here), so we fall back to
  // `currentColor` so the SVG cascade resolves the hue
  // upstream rather than committing to a literal medium-grey.
  let extrusion_color = resolve_extrusion_color(sp3d)
  let (offset_x, offset_y) = extrusion_offset(camera_preset, extrusion_h)
  // Layers = min(ceil(h/2), 10), per the TS source.
  let raw_layers = (extrusion_h / 2.0 + 0.999).to_int()
  let layers = if raw_layers > 10 { 10 } else { raw_layers }
  if layers <= 0 {
    return None
  }
  let paths : Array[@xml.Node] = []
  // Layers are emitted back-to-front so the closest layer overwrites
  // earlier ones.
  for i = layers; i > 0; i = i - 1 {
    let layer_offset = i.to_double() / layers.to_double()
    let x = offset_x * layer_offset
    let y = offset_y * layer_offset
    let opacity = 0.5 + 0.5 * (1.0 - layer_offset)
    paths.push(
      @markup.elem_ns(
        "path",
        @markup.svg_ns,
        [
          @markup.attr("d", shape_path),
          @markup.attr(
            "transform",
            "translate(" +
            format_double_for_filter(x) +
            ", " +
            format_double_for_filter(y) +
            ")",
          ),
          @markup.attr("fill", extrusion_color),
          @markup.attr("fill-opacity", format_opacity(opacity)),
          @markup.attr("stroke", "none"),
        ],
        [],
      ),
    )
  }
  Some(
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("class", "extrusion-effect")],
      paths,
    ),
  )
}

///|
fn extrusion_offset(camera : String, height : Double) -> (Double, Double) {
  let depth = height * 0.5
  match camera {
    "isometricTopUp" | "isometricTopDown" => (depth * 0.5, depth * 0.5)
    "obliqueTopLeft" | "perspectiveAboveLeftFacing" => (-depth, -depth)
    "obliqueTopRight" | "perspectiveAboveRightFacing" => (depth, -depth)
    "obliqueBottomLeft" => (-depth, depth)
    "obliqueBottomRight" => (depth, depth)
    "obliqueTop" | "perspectiveAbove" => (0.0, -depth)
    "obliqueBottom" | "perspectiveBelow" => (0.0, depth)
    "obliqueLeft" | "perspectiveLeft" => (-depth, 0.0)
    "obliqueRight" | "perspectiveRight" => (depth, 0.0)
    _ => (depth * 0.3, depth * 0.3)
  }
}

// ─────────────────────────────────────────────────────────────────────
// Local helpers.
// ─────────────────────────────────────────────────────────────────────

///|
fn min_double(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn attr_emu_d(
  element : @xml.Element,
  name : String,
  default : Double,
) -> Double {
  match attr_value(element, name) {
    None => default
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => default
      } noraise {
        d => d
      }
  }
}

///|
/// §20.1.5.7 `<a:extrusionClr>` (child of §20.1.5.12 sp3d) —
/// resolve the first DrawingML colour child from the
/// `<a:extrusionClr>` child. Returns `currentColor` when the child is
/// absent or carries a theme-bound colour that cannot resolve without
/// the deck's colour scheme.
fn resolve_extrusion_color(sp3d : @xml.Element) -> String {
  resolve_sp3d_color(sp3d, "extrusionClr")
}

///|
/// §20.1.5.12 `<a:sp3d>` colour child resolver — return the first
/// DrawingML colour under the named child (`extrusionClr` or
/// `contourClr`), or `currentColor` so the SVG cascade resolves the
/// hue upstream when the colour is absent or scheme-bound.
fn resolve_sp3d_color(sp3d : @xml.Element, child_name : String) -> String {
  let ctx = ColorResolveContext::empty()
  for child in sp3d.children {
    match child {
      @xml.Node::Element(el) =>
        if el.name.local_name == child_name {
          for grand in el.children {
            match grand {
              @xml.Node::Element(color_el) =>
                match @paint.resolve_solid_fill(color_el, ctx~) {
                  Some(rc) => {
                    let color = @paint.format_resolved_color(rc)
                    if color != "none" {
                      return color
                    }
                  }
                  None => ()
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  "currentColor"
}

///|
/// §20.1.5.12 `<a:sp3d contourW=… >` + `<a:contourClr>` — the contour
/// is the coloured edge that outlines a 3D-formatted shape.  Unlike the
/// extrusion / bevel (which are genuine depth cues a 2D surface can
/// only approximate), the contour is a stroke and maps exactly onto an
/// SVG `<path>` outline of the shape silhouette.  `None` when
/// `@contourW` is absent or zero.
fn contour_element(sp3d : @xml.Element, shape_path : String) -> @xml.Node? {
  // contourW is ST_LineWidth in EMU (0 .. 20116800).
  let contour_emu = attr_emu_d(sp3d, "contourW", 0.0)
  if contour_emu <= 0.0 {
    return None
  }
  let w_px = contour_emu / 9525.0
  let color = resolve_sp3d_color(sp3d, "contourClr")
  Some(
    @markup.elem_ns(
      "path",
      @markup.svg_ns,
      [
        @markup.attr("class", "contour-effect"),
        @markup.attr("d", shape_path),
        @markup.attr("fill", "none"),
        @markup.attr("stroke", color),
        @markup.attr("stroke-width", format_double_for_filter(w_px)),
        // §20.1.5.12 — the contour hugs the silhouette; round joins
        // keep convex corners from spiking at wide contour widths.
        @markup.attr("stroke-linejoin", "round"),
      ],
      [],
    ),
  )
}

///|
fn format_pct(value : Double) -> String {
  // Percentages can come out as integers from the table; render
  // without a trailing `.0` when so.
  format_double_for_filter(value)
}

///|
fn format_opacity(value : Double) -> String {
  // Opacity is typically 0.0..1.0; we keep at most three decimals via
  // the default `to_string` formatter.
  if value == value.to_int().to_double() {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}
