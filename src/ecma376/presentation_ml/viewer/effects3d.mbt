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
/// - `gradient_def` is pushed into the `<defs>` collector for
///   `url(#lighting-<shapeId>)` references.
pub struct Effects3d {
  transform_attrs : Array[@xml.Attribute]
  extrusion : @xml.Node?
  bevel : @xml.Node?
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
      gradient_def: None,
    }
  }
  let camera_preset = match scene3d {
    None => "orthographicFront"
    Some(s) =>
      match first_child_named(s, "camera") {
        None => "orthographicFront"
        Some(c) =>
          match attr_value(c, "prst") {
            Some(p) => p
            None => "orthographicFront"
          }
      }
  }
  let transform = calculate_camera_transform(camera_preset)
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
  { transform_attrs, extrusion, bevel, gradient_def }
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
    }
    None => ()
  }
  match scene3d {
    Some(s) =>
      match first_child_named(s, "camera") {
        Some(c) =>
          match attr_value(c, "prst") {
            Some(p) => p != "orthographicFront"
            None => false
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
  match preset {
    // Isometric — symmetric skews.
    "isometricTopUp" | "isometricTopDown" =>
      { ..id, skew_x: -30.0, skew_y: 30.0 }
    "isometricLeftUp" | "isometricLeftDown" => { ..id, skew_x: 30.0 }
    "isometricRightUp" | "isometricRightDown" => { ..id, skew_x: -30.0 }
    // Oblique — 15° offsets.
    "obliqueTopLeft" => { ..id, skew_x: -15.0, skew_y: -15.0 }
    "obliqueTopRight" => { ..id, skew_x: 15.0, skew_y: -15.0 }
    "obliqueBottomLeft" => { ..id, skew_x: -15.0, skew_y: 15.0 }
    "obliqueBottomRight" => { ..id, skew_x: 15.0, skew_y: 15.0 }
    "obliqueTop" => { ..id, skew_y: -15.0 }
    "obliqueBottom" => { ..id, skew_y: 15.0 }
    "obliqueLeft" => { ..id, skew_x: -15.0 }
    "obliqueRight" => { ..id, skew_x: 15.0 }
    // Perspective — depth scale.
    "perspectiveFront" | "perspectiveRelaxed" => { ..id, scale_y: 0.9 }
    "perspectiveAbove" => { ..id, skew_y: -10.0, scale_y: 0.85 }
    "perspectiveBelow" => { ..id, skew_y: 10.0, scale_y: 0.85 }
    "perspectiveLeft" => { ..id, skew_x: -10.0, scale_x: 0.9 }
    "perspectiveRight" => { ..id, skew_x: 10.0, scale_x: 0.9 }
    // §20.1.10.47 ST_PresetCameraType — `orthographicFront` is
    // the spec default and uses the identity transform.  The
    // 30+ remaining legacy / perspective variants
    // (`legacyObliqueTopLeft`, `legacyPerspectiveRight`,
    // `perspectiveContrastingLeftFacing`, …) all derive from
    // the same skew/scale primitives but require dedicated
    // matrix tables we have not yet built; they render with
    // the identity transform and surface the camera name as
    // `data-ooxml-camera="<preset>"` metadata upstream so
    // consumers can substitute the spec-correct projection.
    // Schema-violating values share the identity fallback.
    _ => id
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
  // The TS source uses bevelT (front face) for 2D rendering.
  let bevel = first_child_named(sp3d, "bevelT")
  match bevel {
    None => None
    Some(b) => {
      let bw = attr_emu_d(b, "w", 76200.0) // §20.1.8.5 default 76200 EMU
      let bh = attr_emu_d(b, "h", 76200.0)
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
      let paths : Array[@xml.Node] = [
        bevel_path_top(width, bevel_w, bevel_h, hi_side.contains("top")),
        bevel_path_left(height, bevel_w, bevel_h, hi_side.contains("left")),
        bevel_path_bottom(
          width,
          height,
          bevel_w,
          bevel_h,
          !sh_side.contains("bottom"),
        ),
        bevel_path_right(
          width,
          height,
          bevel_w,
          bevel_h,
          !sh_side.contains("right"),
        ),
      ]
      Some(
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          [@markup.attr("class", "bevel-effect")],
          paths,
        ),
      )
    }
  }
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
/// pull the first
/// `<a:srgbClr>` or `<a:sysClr lastClr>` colour from the
/// `<a:extrusionClr>` child.  Returns `currentColor` when the
/// child is absent or carries a colour we can't resolve without
/// the full DML colour cascade.
fn resolve_extrusion_color(sp3d : @xml.Element) -> String {
  for child in sp3d.children {
    match child {
      @xml.Node::Element(el) =>
        if el.name.local_name == "extrusionClr" {
          for grand in el.children {
            match grand {
              @xml.Node::Element(color_el) =>
                match color_el.name.local_name {
                  "srgbClr" =>
                    match attr_value(color_el, "val") {
                      Some(v) => return "#" + v.to_lower()
                      None => ()
                    }
                  "sysClr" =>
                    match attr_value(color_el, "lastClr") {
                      Some(v) => return "#" + v.to_lower()
                      None => ()
                    }
                  _ => ()
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
