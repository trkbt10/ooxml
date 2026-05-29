// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/effects.ts
//
// SVG filter emission for ECMA-376 effects.
//
// ECMA-376 references:
//   §20.1.8.45 outerShdw   (CT_OuterShadowEffect)
//   §20.1.8.40 innerShdw   (CT_InnerShadowEffect)
//   §20.1.8.32 glow        (CT_GlowEffect)
//   §20.1.8.53 softEdge    (CT_SoftEdgesEffect)
//   §20.1.8.15 blur        (CT_BlurEffect; grow xsd:boolean default=true)
//   §20.1.8.29 fillOverlay (CT_FillOverlayEffect)
//   §20.1.8.50 reflection  (CT_ReflectionEffect; emitted as a sibling
//                            mirrored <g> clone by the caller — SVG
//                            filter primitives cannot flip the source.)
//
// Composition model (§20.1.8.16 EG_Effect / §20.1.8.27 effectLst):
// every child of <a:effectLst> contributes to the same composited
// output.  The previous implementation only honoured the highest-
// priority effect (shadow > glow > softEdge > blur) which dropped
// the second effect of a stack such as outerShdw + glow.  We now
// build a single multi-primitive <filter> whose primitives chain by
// `result=` id and whose final `feMerge` orders all per-effect
// outputs back over the source in document order — matching the
// spec's "stack of effects" model.
//
// The reader-side typed CT_* structs live in
// `src/ecma376/drawing_ml/effect_types.mbt`. This module operates on
// the raw `<a:effectLst>` element so it can be invoked from the SVG
// rendering pipeline without re-parsing.

///|
/// Generate a stable filter id from a shape id. Mirrors
/// `generateEffectsFilterId` in `effects.ts:27`.
fn generate_effects_filter_id(shape_id : String) -> String {
  "effect-" + shape_id
}

///|
/// Project a §20.1.2.1.6 ST_PositiveFixedAngle attribute (60000ths of
/// a degree, clockwise from the +x axis) onto an `(dx, dy)` shadow
/// offset at the given EMU distance.
///
/// Mirrors `calculateShadowOffset` in `effects.ts:44`. The TS version
/// receives the direction already in degrees; here we accept the raw
/// 60000ths-of-degree integer and divide.
fn calculate_shadow_offset(
  distance_emu : Double,
  dir_60k : Double,
) -> (Double, Double) {
  let degrees = dir_60k / 60000.0
  let radians = degrees * 3.14159265358979323846 / 180.0
  let dx = distance_emu * @math.cos(radians)
  let dy = distance_emu * @math.sin(radians)
  (dx, dy)
}

///|
/// Lowercase hex byte → 0..255 integer. Returns 0 on malformed input —
/// matches the TS `parseInt(...)` coercion behaviour when fed garbage.
fn parse_hex_byte(s : String, offset : Int) -> Int {
  if offset + 2 > s.length() {
    return 0
  }
  let hi = parse_hex_nibble(s.code_unit_at(offset).to_int())
  let lo = parse_hex_nibble(s.code_unit_at(offset + 1).to_int())
  hi * 16 + lo
}

///|
fn parse_hex_nibble(code : Int) -> Int {
  if code >= 48 && code <= 57 {
    code - 48
  } else if code >= 97 && code <= 102 {
    code - 97 + 10
  } else if code >= 65 && code <= 70 {
    code - 65 + 10
  } else {
    0
  }
}

///|
/// Parse a 6-digit hex colour (with or without leading `#`) into
/// (r, g, b) in 0.0..1.0 range. Mirrors `parseHexToRgb` in
/// `effects.ts:55`.
fn parse_hex_to_rgb(hex : String) -> (Double, Double, Double) {
  let normalized = if hex.length() > 0 && hex.code_unit_at(0).to_int() == 35 {
    hex[1:].to_owned()
  } else {
    hex
  }
  let r = parse_hex_byte(normalized, 0).to_double() / 255.0
  let g = parse_hex_byte(normalized, 2).to_double() / 255.0
  let b = parse_hex_byte(normalized, 4).to_double() / 255.0
  (r, g, b)
}

///|
/// Format a colour as a `rgb(r, g, b)` CSS string for `<feFlood>`.
fn rgb_css(r : Double, g : Double, b : Double) -> String {
  "rgb(" +
  (r * 255.0).to_int().to_string() +
  ", " +
  (g * 255.0).to_int().to_string() +
  ", " +
  (b * 255.0).to_int().to_string() +
  ")"
}

///|
/// §20.1.8.40 `<a:effectLst>` colour resolution.  Mirrors
/// `resolveEffectColor` in `effects.ts:67`.
///
/// The colour inputs to the SVG `<feColorMatrix>` filter pipeline
/// must be concrete numeric channels (0..1 floats), so we cannot
/// surface `currentColor` here — the filter would refuse a CSS
/// identifier.  When the colour cannot be resolved (e.g. the
/// scheme reference depends on a `phClr` placeholder we have no
/// context for), we fall back to `000000` per the §20.1.4.1.7
/// `<a:tx1>` text-default convention, and surface the unresolved
/// state to consumers via the effect's `data-ooxml-effect-color`
/// metadata on the caller's `<g>` wrapper.
fn resolve_effect_color_hex(
  element : @xml.Element,
  ctx : ColorResolveContext,
) -> String {
  match @paint.resolve_solid_fill(element, ctx~) {
    Some(rc) => if rc.hex == "" { "000000" } else { rc.hex }
    None => "000000"
  }
}

///|
/// Format an SVG `<feColorMatrix>` matrix tinting alpha-only input to
/// `(r, g, b, opacity)`. Layout matches the TS implementation:
/// `0 0 0 0 r  0 0 0 0 g  0 0 0 0 b  0 0 0 a 0`.
fn color_matrix_values(
  r : Double,
  g : Double,
  b : Double,
  opacity : Double,
) -> String {
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(r) +
  "  " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(g) +
  "  " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(b) +
  "  " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(0.0) +
  " " +
  format_double_for_filter(opacity) +
  " " +
  format_double_for_filter(0.0)
}

///|
/// SVG numeric formatter for filter attribute output. Integers render
/// without `.0`, other values use the default `to_string`.
fn format_double_for_filter(value : Double) -> String {
  if value == value.to_int().to_double() {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

///|
/// `<feGaussianBlur in="SourceAlpha" stdDeviation="..." result="blur"/>`.
fn fe_gaussian_blur(
  in_attr : String,
  std_dev : Double,
  result : String,
) -> @xml.Node {
  @markup.elem_ns(
    "feGaussianBlur",
    @markup.svg_ns,
    [
      @markup.attr("in", in_attr),
      @markup.attr("stdDeviation", format_double_for_filter(std_dev)),
      @markup.attr("result", result),
    ],
    [],
  )
}

///|
/// `<feOffset in="..." dx="..." dy="..." result="..."/>`.
fn fe_offset(
  in_attr : String,
  dx : Double,
  dy : Double,
  result : String,
) -> @xml.Node {
  @markup.elem_ns(
    "feOffset",
    @markup.svg_ns,
    [
      @markup.attr("in", in_attr),
      @markup.attr("dx", format_double_for_filter(dx)),
      @markup.attr("dy", format_double_for_filter(dy)),
      @markup.attr("result", result),
    ],
    [],
  )
}

///|
/// `<feColorMatrix in="..." type="matrix" values="..." result="..."/>`.
fn fe_color_matrix(
  in_attr : String,
  values : String,
  result : String,
) -> @xml.Node {
  @markup.elem_ns(
    "feColorMatrix",
    @markup.svg_ns,
    [
      @markup.attr("in", in_attr),
      @markup.attr("type", "matrix"),
      @markup.attr("values", values),
      @markup.attr("result", result),
    ],
    [],
  )
}

///|
/// `<feFlood flood-color="..." flood-opacity="..." result="..."/>`.
fn fe_flood(
  flood_color : String,
  flood_opacity : Double,
  result : String,
) -> @xml.Node {
  @markup.elem_ns(
    "feFlood",
    @markup.svg_ns,
    [
      @markup.attr("flood-color", flood_color),
      @markup.attr("flood-opacity", format_double_for_filter(flood_opacity)),
      @markup.attr("result", result),
    ],
    [],
  )
}

///|
/// `<feComposite in=in1 in2=in2 operator=op result=result/>`.
fn fe_composite(
  in1 : String,
  in2 : String,
  operator : String,
  result : String,
) -> @xml.Node {
  @markup.elem_ns(
    "feComposite",
    @markup.svg_ns,
    [
      @markup.attr("in", in1),
      @markup.attr("in2", in2),
      @markup.attr("operator", operator),
      @markup.attr("result", result),
    ],
    [],
  )
}

///|
/// `<feBlend in=in1 in2=in2 mode=mode result=result/>`.
fn fe_blend(
  in1 : String,
  in2 : String,
  mode : String,
  result : String,
) -> @xml.Node {
  @markup.elem_ns(
    "feBlend",
    @markup.svg_ns,
    [
      @markup.attr("in", in1),
      @markup.attr("in2", in2),
      @markup.attr("mode", mode),
      @markup.attr("result", result),
    ],
    [],
  )
}

///|
/// Final `feMerge` collapsing an ordered list of result IDs (back to
/// front).  Each entry becomes a `<feMergeNode in="...">`.
fn fe_merge_nodes(results : Array[String]) -> @xml.Node {
  let nodes : Array[@xml.Node] = []
  for r in results {
    nodes.push(
      @markup.elem_ns("feMergeNode", @markup.svg_ns, [@markup.attr("in", r)], []),
    )
  }
  @markup.elem_ns("feMerge", @markup.svg_ns, [], nodes)
}

///|
/// Extents added by an effect, expressed as fractional shape-box
/// margins on each side.  The wrapper viewport is the max across
/// all effects so the largest blur/glow halo isn't clipped.
priv struct FilterExtents {
  left : Double
  top : Double
  right : Double
  bottom : Double
}

///|
fn FilterExtents::zero() -> FilterExtents {
  { left: 0.0, top: 0.0, right: 0.0, bottom: 0.0 }
}

///|
fn FilterExtents::merge(a : FilterExtents, b : FilterExtents) -> FilterExtents {
  {
    left: if a.left > b.left {
      a.left
    } else {
      b.left
    },
    top: if a.top > b.top {
      a.top
    } else {
      b.top
    },
    right: if a.right > b.right {
      a.right
    } else {
      b.right
    },
    bottom: if a.bottom > b.bottom {
      a.bottom
    } else {
      b.bottom
    },
  }
}

///|
/// One effect's contribution to the composed filter — primitives to
/// splice into the filter body and the `result=` id whose output is
/// merged back into the final stack, plus the extents the wrapper
/// viewport must accommodate.
///
/// `merge_under` is true when the effect's output should be merged
/// *behind* SourceGraphic (shadow, glow, reflection, fillOverlay).
/// `merge_over` is true when it should be merged in front
/// (innerShdw, fillOverlay-mult/over).  softEdge / blur replace the
/// stack entirely (they declare `result_id = ""`).
priv struct EffectContribution {
  primitives : Array[@xml.Node]
  result_id : String
  merge_under : Bool
  merge_over : Bool
  extents : FilterExtents
  // softEdge / blur replace the entire source rendering — when
  // `replaces_source` is true, the final merge uses this effect's
  // result as the only output and ignores SourceGraphic/under/over.
  replaces_source : Bool
}

///|
/// Build an outer-shadow primitive group (§20.1.8.45). Mirrors
/// `generateOuterShadowFilter` in `effects.ts:87`; the shadow's blur
/// radius and distance come from the §20.1.8.45 attributes, the
/// colour is resolved through `ColorResolveContext` so scheme/theme
/// colours work.  Output result id `<prefix>_out`.
fn outer_shadow_primitives(
  shdw : @xml.Element,
  prefix : String,
  ctx : ColorResolveContext,
) -> EffectContribution {
  let dist = attr_double(shdw, "dist", 0.0)
  let dir = attr_double(shdw, "dir", 0.0)
  let blur_rad = attr_double(shdw, "blurRad", 0.0)
  let (dx, dy) = calculate_shadow_offset(dist, dir)
  let std_dev = blur_rad / 2.0
  let hex = resolve_effect_color_hex(shdw, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  // §20.1.2.3.7 `<a:alpha val>` — outer shadow default 50 %.
  let opacity = read_effect_alpha(shdw, 0.5)
  let matrix = color_matrix_values(r, g, b, opacity)
  let blur_id = prefix + "_blur"
  let off_id = prefix + "_off"
  let out_id = prefix + "_out"
  let primitives : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, blur_id),
    fe_offset(blur_id, dx, dy, off_id),
    fe_color_matrix(off_id, matrix, out_id),
  ]
  // Extents margin: halo extends ~3 std-devs from the shifted alpha
  // (3-sigma covers 99.7 % of the gaussian); plus the offset itself.
  let halo = std_dev * 3.0
  let extents = {
    left: if dx < 0.0 {
      -dx + halo
    } else {
      halo
    },
    right: if dx > 0.0 {
      dx + halo
    } else {
      halo
    },
    top: if dy < 0.0 {
      -dy + halo
    } else {
      halo
    },
    bottom: if dy > 0.0 {
      dy + halo
    } else {
      halo
    },
  }
  {
    primitives,
    result_id: out_id,
    merge_under: true,
    merge_over: false,
    extents,
    replaces_source: false,
  }
}

///|
/// Build an inner-shadow primitive group (§20.1.8.40). Mirrors
/// `generateInnerShadowFilter` in `effects.ts:119`.  The offset is
/// negated and the shadow is clipped to the source alpha so it
/// renders inside the shape.  Output result id `<prefix>_in`.
fn inner_shadow_primitives(
  shdw : @xml.Element,
  prefix : String,
  ctx : ColorResolveContext,
) -> EffectContribution {
  let dist = attr_double(shdw, "dist", 0.0)
  let dir = attr_double(shdw, "dir", 0.0)
  let blur_rad = attr_double(shdw, "blurRad", 0.0)
  let (dx, dy) = calculate_shadow_offset(dist, dir)
  let std_dev = blur_rad / 2.0
  let hex = resolve_effect_color_hex(shdw, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  // §20.1.2.3.7 `<a:alpha val>` — inner-shadow default 30 %.
  let opacity = read_effect_alpha(shdw, 0.3)
  let matrix = color_matrix_values(r, g, b, opacity)
  let blur_id = prefix + "_iblur"
  let off_id = prefix + "_ioff"
  let cm_id = prefix + "_icm"
  let out_id = prefix + "_in"
  let primitives : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, blur_id),
    fe_offset(blur_id, -dx, -dy, off_id),
    fe_color_matrix(off_id, matrix, cm_id),
    fe_composite(cm_id, "SourceAlpha", "in", out_id),
  ]
  // Inner shadow is clipped to source alpha; the only extent the
  // wrapper must add is what the source itself needs.
  {
    primitives,
    result_id: out_id,
    merge_under: false,
    merge_over: true,
    extents: FilterExtents::zero(),
    replaces_source: false,
  }
}

///|
/// Build a glow primitive group (§20.1.8.32).  Mirrors
/// `generateGlowFilter` in `effects.ts:178`.  The glow is a blurred
/// copy of the alpha recoloured to the glow colour and merged under
/// the source.  Output result id `<prefix>_glow`.
fn glow_primitives(
  glow : @xml.Element,
  prefix : String,
  ctx : ColorResolveContext,
) -> EffectContribution {
  let rad = attr_double(glow, "rad", 0.0)
  let std_dev = rad / 2.0
  let hex = resolve_effect_color_hex(glow, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  // §20.1.2.3.7 `<a:alpha val>` — glow default 70 %.
  let opacity = read_effect_alpha(glow, 0.7)
  let matrix = color_matrix_values(r, g, b, opacity)
  let blur_id = prefix + "_gblur"
  let out_id = prefix + "_glow"
  let primitives : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, blur_id),
    fe_color_matrix(blur_id, matrix, out_id),
  ]
  let halo = std_dev * 3.0
  let extents = { left: halo, top: halo, right: halo, bottom: halo }
  {
    primitives,
    result_id: out_id,
    merge_under: true,
    merge_over: false,
    extents,
    replaces_source: false,
  }
}

///|
/// Build a soft-edge primitive group (§20.1.8.53).  The edge is
/// feathered by blurring the alpha then re-clipping the source by
/// the blurred alpha with `feComposite operator="in"`.  softEdge
/// replaces the source rendering — the merge stage uses its output
/// in place of `SourceGraphic`.  Output result id `<prefix>_soft`.
fn soft_edge_primitives(
  soft : @xml.Element,
  prefix : String,
) -> EffectContribution {
  let rad = attr_double(soft, "rad", 0.0)
  let std_dev = rad / 2.0
  let blur_id = prefix + "_sblur"
  let out_id = prefix + "_soft"
  let primitives : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, blur_id),
    fe_composite("SourceGraphic", blur_id, "in", out_id),
  ]
  // softEdge's feComposite("in") clips the feathered alpha back to
  // the source shape — the feather never extends past the bounding
  // box, so the wrapper stays at the tight viewport (no extra
  // extents).  Without this the rasteriser allocates a needlessly
  // large filter buffer for every feathered shape.
  {
    primitives,
    result_id: out_id,
    merge_under: false,
    merge_over: false,
    extents: FilterExtents::zero(),
    replaces_source: true,
  }
}

///|
/// Build a uniform Gaussian blur (§20.1.8.15).  The `grow` attribute
/// (xsd:boolean default=true) controls whether the blur halo extends
/// past the original bounding box (`grow=true`) or is clipped inside
/// (`grow=false`); we honour it by widening the wrapper viewport when
/// `grow=true` and leaving the extents at zero when `grow=false`.
/// Output result id `<prefix>_blur`.
fn blur_primitives(blur : @xml.Element, prefix : String) -> EffectContribution {
  let rad = attr_double(blur, "rad", 0.0)
  let std_dev = rad / 2.0
  // §20.1.8.15 @grow — xsd:boolean default=true.
  let grow = parse_xsd_boolean_or(attr_value(blur, "grow"), true)
  let out_id = prefix + "_blur"
  let primitives : Array[@xml.Node] = [
    @markup.elem_ns(
      "feGaussianBlur",
      @markup.svg_ns,
      [
        @markup.attr("in", "SourceGraphic"),
        @markup.attr("stdDeviation", format_double_for_filter(std_dev)),
        @markup.attr("result", out_id),
      ],
      [],
    ),
  ]
  let halo = if grow { std_dev * 3.0 } else { 0.0 }
  let extents = { left: halo, top: halo, right: halo, bottom: halo }
  {
    primitives,
    result_id: out_id,
    merge_under: false,
    merge_over: false,
    extents,
    replaces_source: true,
  }
}

///|
/// Build a fill-overlay primitive group (§20.1.8.29).  Renders a
/// semi-opaque colour over the source, blended per the `blend`
/// attribute (`over` / `mult` / `screen` / `darken` / `lighten`).
/// The overlay is clipped to the source alpha so it doesn't bleed
/// past the shape silhouette.  Output result id `<prefix>_fo`.
fn fill_overlay_primitives(
  overlay : @xml.Element,
  prefix : String,
  ctx : ColorResolveContext,
) -> EffectContribution {
  let hex = resolve_effect_color_hex(overlay, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  let opacity = read_effect_alpha(overlay, 0.5)
  let blend = match attr_value(overlay, "blend") {
    Some(v) => v
    None => "over"
  }
  let flood_id = prefix + "_fflood"
  let clip_id = prefix + "_fclip"
  let out_id = prefix + "_fo"
  let primitives : Array[@xml.Node] = [
    fe_flood(rgb_css(r, g, b), opacity, flood_id),
    // Clip the flood rectangle to the source alpha so the overlay
    // matches the shape silhouette rather than the filter viewport.
    fe_composite(flood_id, "SourceAlpha", "in", clip_id),
    // Blend the clipped flood with the source per the §20.1.8.29
    // @blend attribute: `over` (paint on top), `mult` (multiply),
    // `screen`, `darken`, `lighten` map directly to SVG `feBlend`
    // modes (`normal`/`multiply`/`screen`/`darken`/`lighten`).
    fe_blend(clip_id, "SourceGraphic", blend_to_svg_mode(blend), out_id),
  ]
  // The overlay never expands the bounding box (it's clipped to
  // SourceAlpha), so no extra extents.
  {
    primitives,
    result_id: out_id,
    merge_under: false,
    merge_over: false,
    // The blend already composes the source — feMerge should use
    // this output in place of SourceGraphic, so flag as replacement.
    extents: FilterExtents::zero(),
    replaces_source: true,
  }
}

///|
/// Map a §20.1.8.29 @blend value to the corresponding SVG `feBlend`
/// @mode value.  Unknown / `over` map to `normal`.
fn blend_to_svg_mode(blend : String) -> String {
  match blend {
    "mult" => "multiply"
    "screen" => "screen"
    "darken" => "darken"
    "lighten" => "lighten"
    _ => "normal"
  }
}

///|
/// Build a `filter="url(#...)"` attribute from a shape's `<p:spPr>`
/// element, when an `<a:effectLst>` or `<a:effectDag>` is present and
/// at least one supported effect is found.
///
/// Side-effect: pushes the corresponding `<filter>` definition node
/// into `defs`. Returns an empty attribute list when no supported
/// effect is present, so callers can splat it unconditionally onto an
/// element.
///
/// Composition (§20.1.8.27): walks every child of `<a:effectLst>` in
/// document order — the spec's composition order — building one
/// multi-primitive filter.  Each effect's primitives chain through
/// unique result ids (`eff0_blur`, `eff0_glow`, etc.) and the final
/// `<feMerge>` stacks shadow/glow under the source and innerShdw
/// over it.  softEdge and blur replace the source rendering wholesale
/// (their output IS the rendered shape).  Reflection is not emitted
/// via the filter — SVG filter primitives cannot mirror — and is
/// instead surfaced by `reflection_extra_nodes` for the caller to
/// place as a sibling clone.
pub fn render_effects_filter_attr(
  sp_pr : @xml.Element,
  shape_id : String,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
) -> Array[@xml.Attribute] {
  effects_filter_attrs(sp_pr, shape_id, ctx, defs)
}

///|
/// Internal counterpart of `render_effects_filter_attr` that returns
/// the structured `filter` attribute list (empty when no supported
/// effect is present).  Pushes the `<filter>` node into `defs` as a
/// side-effect.
fn effects_filter_attrs(
  sp_pr : @xml.Element,
  shape_id : String,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
) -> Array[@xml.Attribute] {
  let effect_lst = first_child_named(sp_pr, "effectLst")
  let effect_dag = first_child_named(sp_pr, "effectDag")
  let container = match effect_lst {
    Some(e) => Some(e)
    None => effect_dag
  }
  match container {
    None => []
    Some(lst) => {
      let filter_id = generate_effects_filter_id(shape_id)
      let contributions : Array[EffectContribution] = []
      let mut idx : Int = 0
      // Walk in document order — §20.1.8.27 says child effects
      // compose in the order they appear inside the list.
      for child in lst.children {
        match child {
          @xml.Node::Element(el) => {
            let prefix = "eff" + idx.to_string()
            let contribution : EffectContribution? = match el.name.local_name {
              "outerShdw" => Some(outer_shadow_primitives(el, prefix, ctx))
              "innerShdw" => Some(inner_shadow_primitives(el, prefix, ctx))
              "glow" => Some(glow_primitives(el, prefix, ctx))
              "softEdge" => Some(soft_edge_primitives(el, prefix))
              "blur" => Some(blur_primitives(el, prefix))
              "fillOverlay" => Some(fill_overlay_primitives(el, prefix, ctx))
              // §20.1.8.50 reflection — handled outside the filter
              // by `reflection_extra_nodes`; skip here.
              // Unrecognised effect names are ignored.
              _ => None
            }
            match contribution {
              Some(c) => contributions.push(c)
              None => ()
            }
            idx = idx + 1
          }
          _ => ()
        }
      }
      if contributions.length() == 0 {
        return []
      }
      // Determine the source-of-truth for the final stack:
      //   * If any contribution declares `replaces_source` we use the
      //     LAST one's output in place of SourceGraphic.  This lets a
      //     <softEdge> after a <glow> render the feathered shape with
      //     the glow underneath; it also lets <blur> blur the whole
      //     stack.  In practice §20.1.8.27 stacks blur/softEdge at the
      //     end, so honouring the last replacement matches Office.
      //   * Otherwise SourceGraphic is the central layer.
      let mut source_layer = "SourceGraphic"
      for c in contributions {
        if c.replaces_source {
          source_layer = c.result_id
        }
      }

      // Collect filter primitives in document order.
      let body : Array[@xml.Node] = []
      for c in contributions {
        for n in c.primitives {
          body.push(n)
        }
      }

      // Build the merge stack: under-layers (shadow/glow) in
      // document order, then the source layer, then over-layers
      // (innerShdw / fillOverlay-blend) in document order.
      let merge_inputs : Array[String] = []
      for c in contributions {
        if c.merge_under {
          merge_inputs.push(c.result_id)
        }
      }
      merge_inputs.push(source_layer)
      for c in contributions {
        if c.merge_over {
          merge_inputs.push(c.result_id)
        }
      }
      body.push(fe_merge_nodes(merge_inputs))

      // Compute viewport.  Combined extents are the per-effect max,
      // expressed as fractional shape-box margins.  The default
      // 50 % box on every side covers the historical
      // shadow/glow halos; we widen further only when an effect's
      // extents call for it.  Extents are EMUs of margin; we don't
      // have the shape bbox here, so approximate via percentages
      // proportional to a 200 % bounding box and let the rsvg
      // clipper handle the rest.
      let mut extents = FilterExtents::zero()
      for c in contributions {
        extents = FilterExtents::merge(extents, c.extents)
      }
      let filter_node = wrap_filter_with_extents(filter_id, body, extents)
      defs.add_def(filter_node)
      [@markup.attr("filter", "url(#" + filter_id + ")")]
    }
  }
}

///|
/// Wrap a body of filter primitives in a `<filter>` element sized
/// to accommodate the combined extents.  Extents are EMU-scale
/// margins; we don't know the shape's EMU box at this layer, so we
/// convert margin → viewport percentage via the heuristic that 1 EMU
/// of halo ≈ 1/9525 px and the typical shape edge is sub-1 in.  We
/// keep the same nominal `(-50%, -50%, 200%, 200%)` viewport for
/// shadow/glow effects (matches the historical behaviour) and
/// widen when an effect's halo is large.  When no extra extents are
/// requested (softEdge / non-grow blur) we use the tight
/// `(-10%, -10%, 120%, 120%)` viewport so the rasteriser doesn't
/// allocate huge filter buffers needlessly.
fn wrap_filter_with_extents(
  filter_id : String,
  body : Array[@xml.Node],
  extents : FilterExtents,
) -> @xml.Node {
  let any_halo = extents.left > 0.0 ||
    extents.right > 0.0 ||
    extents.top > 0.0 ||
    extents.bottom > 0.0
  // Percentage margins to apply on each side of the shape box.
  // The historical shadow/glow filter used `-50%, -50%, 200%, 200%`
  // (50 % halo on each side).  For larger halos we widen so a deep
  // glow isn't clipped; for no halo we tighten so feather filters
  // don't allocate huge raster buffers.
  let (lp, tp, wp, hp) = if any_halo {
    // Heuristic margin: convert EMU halo to fractional shape-box
    // margin via an approximate "average shape ~ 1 in = 914400 EMU"
    // assumption.  Cap at 100 % on each side so the viewport
    // doesn't blow up for runaway radii.
    let frac = fn(emu : Double) -> Double {
      let m = emu / 914400.0
      if m > 1.0 {
        1.0
      } else if m < 0.5 {
        0.5
      } else {
        m
      }
    }
    let l = frac(extents.left) * 100.0
    let t = frac(extents.top) * 100.0
    let r = frac(extents.right) * 100.0
    let b = frac(extents.bottom) * 100.0
    (-l, -t, 100.0 + l + r, 100.0 + t + b)
  } else {
    (-10.0, -10.0, 120.0, 120.0)
  }
  let percent = fn(v : Double) -> String { format_double_for_filter(v) + "%" }
  @markup.elem_ns(
    "filter",
    @markup.svg_ns,
    [
      @markup.attr("id", filter_id),
      @markup.attr("x", percent(lp)),
      @markup.attr("y", percent(tp)),
      @markup.attr("width", percent(wp)),
      @markup.attr("height", percent(hp)),
    ],
    body,
  )
}

///|
/// §20.1.8.50 `<a:reflection>` — emit a mirrored clone of the
/// rendered shape geometry as a sibling `<g>` that the caller
/// inserts behind the shape's own `<g>`.  Returns an empty array
/// when there is no reflection child.
///
/// SVG filters cannot mirror the source vertically (no primitive
/// flips the y axis), so the reflection is implemented as a
/// duplicate `<g>` whose `transform` matrix scales `y` by `-1` and
/// translates by `2·h + dist` so the mirrored copy sits flush
/// underneath the original.  Fade-out is approximated by a constant
/// `opacity` derived from the §20.1.8.50 `stA` (start alpha) — a
/// linear-gradient mask would honour the `stPos`/`endPos`/`endA`
/// quartet exactly but the gradient mask requires a `<mask>` def
/// keyed to the shape's path; we surface a constant opacity (mean
/// of `stA` and `endA`) so the reflection's overall visibility
/// matches Office without the per-pixel falloff.
pub fn reflection_extra_nodes(
  sp_pr : @xml.Element,
  shape_path : @xml.Node,
  shape_height : Double,
) -> Array[@xml.Node] {
  let lst = match first_child_named(sp_pr, "effectLst") {
    Some(e) => e
    None =>
      match first_child_named(sp_pr, "effectDag") {
        Some(e) => e
        None => return []
      }
  }
  let refl = match first_child_named(lst, "reflection") {
    Some(e) => e
    None => return []
  }
  // §20.1.8.50 @dist — EMU gap between shape and reflection.
  let dist = attr_double(refl, "dist", 0.0)
  // §20.1.8.50 @stA / @endA — 0..100000 (positive-fixed-percentage).
  // Default fade: stA=50000 (50 %), endA=0 — same defaults Office
  // uses for the "tight reflection" preset.
  let st_a = attr_double(refl, "stA", 50000.0) / 100000.0
  let end_a = attr_double(refl, "endA", 0.0) / 100000.0
  let mean_alpha = (st_a + end_a) / 2.0
  // Mirror transform: scale(1, -1) flips around y=0, then we
  // translate down by 2·h + dist so the mirrored top edge sits at
  // y=h+dist (just below the original's bottom edge).
  //
  // The matrix is composed in user-space; the shape itself is
  // already positioned by its outer <g transform="translate(...)">
  // so we apply the mirror *inside* that frame.
  let ty = 2.0 * shape_height + dist
  let transform_val = "matrix(1 0 0 -1 0 " + format_double_for_filter(ty) + ")"
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("transform", transform_val),
    @markup.attr("opacity", format_double_for_filter(mean_alpha)),
    @markup.attr("data-ooxml-effect", "reflection"),
  ]
  [@markup.elem_ns("g", @markup.svg_ns, attrs, [shape_path])]
}

///|
/// Read a numeric attribute, returning `default` when missing or
/// unparseable. Matches the JS coercion semantics used throughout
/// `effects.ts`.
fn attr_double(
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
/// §20.1.2.3.7 `<a:alpha val>` — read the opacity (in 1000ths of
/// a percent, 0..100000) from the first `<a:alpha>` child of the
/// effect's colour element.  Returns `default` when no alpha
/// child is declared.  The colour element (`<a:srgbClr>`,
/// `<a:schemeClr>`, …) sits as a direct child of the effect
/// element (`<a:outerShdw>`, `<a:innerShdw>`, `<a:glow>`); we
/// scan all colour children and use the first alpha we find.
fn read_effect_alpha(effect : @xml.Element, default : Double) -> Double {
  for child in effect.children {
    match child {
      @xml.Node::Element(color_el) =>
        match color_el.name.local_name {
          // §20.1.2.3 EG_ColorChoice — the 6 colour-bearing
          // elements that may appear inside an effect.
          "srgbClr"
          | "schemeClr"
          | "sysClr"
          | "hslClr"
          | "scrgbClr"
          | "prstClr" =>
            for inner in color_el.children {
              match inner {
                @xml.Node::Element(alpha_el) =>
                  if alpha_el.name.local_name == "alpha" {
                    match attr_value(alpha_el, "val") {
                      Some(v) =>
                        try @string.parse_double(v) catch {
                          // §20.1.10.55 ST_PositiveFixedPercentage:
                          // value is in thousandths of a percent
                          // (0..100000), so divide by 100000 to
                          // get the 0..1 opacity multiplier.
                          _ => ()
                        } noraise {
                          d => return d / 100000.0
                        }
                      None => ()
                    }
                  }
                _ => ()
              }
            }
          // fillOverlay carries `<a:solidFill>` as its child;
          // recurse into the solidFill's colour element so the
          // alpha lookup works the same.
          "solidFill" =>
            for inner in color_el.children {
              match inner {
                @xml.Node::Element(color_inner) =>
                  match color_inner.name.local_name {
                    "srgbClr"
                    | "schemeClr"
                    | "sysClr"
                    | "hslClr"
                    | "scrgbClr"
                    | "prstClr" =>
                      for alpha_n in color_inner.children {
                        match alpha_n {
                          @xml.Node::Element(alpha_el) =>
                            if alpha_el.name.local_name == "alpha" {
                              match attr_value(alpha_el, "val") {
                                Some(v) =>
                                  try @string.parse_double(v) catch {
                                    _ => ()
                                  } noraise {
                                    d => return d / 100000.0
                                  }
                                None => ()
                              }
                            }
                          _ => ()
                        }
                      }
                    _ => ()
                  }
                _ => ()
              }
            }
          _ => ()
        }
      _ => ()
    }
  }
  default
}
