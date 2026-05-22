// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/effects.ts
//
// SVG filter emission for ECMA-376 effects.
//
// ECMA-376 references:
//   §20.1.8.45 outerShdw  (CT_OuterShadowEffect)
//   §20.1.8.40 innerShdw  (CT_InnerShadowEffect)
//   §20.1.8.32 glow       (CT_GlowEffect)
//   §20.1.8.53 softEdge   (CT_SoftEdgesEffect)
//   §20.1.8.15 blur       (CT_BlurEffect)
//   §20.1.8.50 reflection (not rendered — requires complex transforms)
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
    hex.substring(start=1)
  } else {
    hex
  }
  let r = parse_hex_byte(normalized, 0).to_double() / 255.0
  let g = parse_hex_byte(normalized, 2).to_double() / 255.0
  let b = parse_hex_byte(normalized, 4).to_double() / 255.0
  (r, g, b)
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
  match resolve_solid_fill(element, ctx~) {
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
/// Two-node `<feMerge>` element merging `node1` over `node2`. Mirrors
/// the most common shape used in `effects.ts`.
fn fe_merge_two(node1 : String, node2 : String) -> @xml.Node {
  @markup.elem_ns("feMerge", @markup.svg_ns, [], [
    @markup.elem_ns(
      "feMergeNode",
      @markup.svg_ns,
      [@markup.attr("in", node1)],
      [],
    ),
    @markup.elem_ns(
      "feMergeNode",
      @markup.svg_ns,
      [@markup.attr("in", node2)],
      [],
    ),
  ])
}

///|
/// Wrap a sequence of primitive nodes as a complete `<filter>`
/// definition with the standard `(-50%, -50%, 200%, 200%)` viewport.
fn wrap_filter_standard(
  filter_id : String,
  body : Array[@xml.Node],
) -> @xml.Node {
  @markup.elem_ns(
    "filter",
    @markup.svg_ns,
    [
      @markup.attr("id", filter_id),
      @markup.attr("x", "-50%"),
      @markup.attr("y", "-50%"),
      @markup.attr("width", "200%"),
      @markup.attr("height", "200%"),
    ],
    body,
  )
}

///|
/// Wrap a sequence of primitive nodes as a complete `<filter>`
/// definition with a tight viewport (used by softEdge — the edge
/// blur only extends slightly outside the shape bounds).
fn wrap_filter_tight(filter_id : String, body : Array[@xml.Node]) -> @xml.Node {
  @markup.elem_ns(
    "filter",
    @markup.svg_ns,
    [
      @markup.attr("id", filter_id),
      @markup.attr("x", "-10%"),
      @markup.attr("y", "-10%"),
      @markup.attr("width", "120%"),
      @markup.attr("height", "120%"),
    ],
    body,
  )
}

///|
/// Generate an outer-shadow filter. Mirrors `generateOuterShadowFilter`
/// in `effects.ts:87`. The shadow's blur radius and distance are taken
/// from the §20.1.8.45 attributes; the colour is resolved via the
/// viewer's `ColorResolveContext` so scheme/theme colours work
/// transparently.
fn generate_outer_shadow_filter(
  shdw : @xml.Element,
  filter_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node {
  let dist = attr_double(shdw, "dist", 0.0)
  let dir = attr_double(shdw, "dir", 0.0)
  let blur_rad = attr_double(shdw, "blurRad", 0.0)
  let (dx, dy) = calculate_shadow_offset(dist, dir)
  let std_dev = blur_rad / 2.0
  let hex = resolve_effect_color_hex(shdw, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  // §20.1.2.3.7 `<a:alpha val>` — when the colour element
  // carries an explicit alpha child we honour it; otherwise we
  // default to 0.5 (50 %), matching the renderer-policy
  // intensity the TS reference uses.  The 50 % default is
  // surfaced via `data-ooxml-effect-alpha-source` on the
  // caller's <g> wrapper when no explicit alpha was present.
  let opacity = read_effect_alpha(shdw, 0.5)
  let matrix = color_matrix_values(r, g, b, opacity)
  let body : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, "blur"),
    fe_offset("blur", dx, dy, "offsetBlur"),
    fe_color_matrix("offsetBlur", matrix, "shadow"),
    fe_merge_two("shadow", "SourceGraphic"),
  ]
  wrap_filter_standard(filter_id, body)
}

///|
/// Generate an inner-shadow filter. Mirrors `generateInnerShadowFilter`
/// in `effects.ts:119`. The offset is negated (shadow comes from the
/// opposite direction) and a `feComposite operator="in"` clips the
/// shadow to the shape's alpha so the shadow only renders inside.
fn generate_inner_shadow_filter(
  shdw : @xml.Element,
  filter_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node {
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
  let body : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, "blur"),
    fe_offset("blur", -dx, -dy, "offsetBlur"),
    fe_color_matrix("offsetBlur", matrix, "shadow"),
    @markup.elem_ns(
      "feComposite",
      @markup.svg_ns,
      [
        @markup.attr("in", "shadow"),
        @markup.attr("in2", "SourceAlpha"),
        @markup.attr("operator", "in"),
        @markup.attr("result", "innerShadow"),
      ],
      [],
    ),
    fe_merge_two("SourceGraphic", "innerShadow"),
  ]
  wrap_filter_standard(filter_id, body)
}

///|
/// Generate a glow filter. Mirrors `generateGlowFilter` in
/// `effects.ts:178`. The glow is a blurred copy of the source's alpha
/// recoloured to the glow colour at 0.7 opacity and merged under the
/// source.
fn generate_glow_filter(
  glow : @xml.Element,
  filter_id : String,
  ctx : ColorResolveContext,
) -> @xml.Node {
  let rad = attr_double(glow, "rad", 0.0)
  let std_dev = rad / 2.0
  let hex = resolve_effect_color_hex(glow, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  // §20.1.2.3.7 `<a:alpha val>` — glow default 70 %.
  let opacity = read_effect_alpha(glow, 0.7)
  let matrix = color_matrix_values(r, g, b, opacity)
  let body : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, "blur"),
    fe_color_matrix("blur", matrix, "glow"),
    fe_merge_two("glow", "SourceGraphic"),
  ]
  wrap_filter_standard(filter_id, body)
}

///|
/// Generate a soft-edge filter. Mirrors `generateSoftEdgeFilter` in
/// `effects.ts:210`. The edge is feathered by blurring the alpha and
/// compositing the source over the blurred alpha with `operator="in"`.
fn generate_soft_edge_filter(
  soft : @xml.Element,
  filter_id : String,
) -> @xml.Node {
  let rad = attr_double(soft, "rad", 0.0)
  let std_dev = rad / 2.0
  let body : Array[@xml.Node] = [
    fe_gaussian_blur("SourceAlpha", std_dev, "blur"),
    @markup.elem_ns(
      "feComposite",
      @markup.svg_ns,
      [
        @markup.attr("in", "SourceGraphic"),
        @markup.attr("in2", "blur"),
        @markup.attr("operator", "in"),
      ],
      [],
    ),
  ]
  wrap_filter_tight(filter_id, body)
}

///|
/// Generate a blur filter. Mirrors §20.1.8.15 directly — the spec
/// blur primitive is a plain Gaussian blur of the source. `web-pptx`
/// doesn't ship a dedicated `blur` path (it short-circuits to glow's
/// rad-based blur), but the ECMA-376 element warrants explicit
/// handling so the filter chain can carry isolated blurs.
fn generate_blur_filter(blur : @xml.Element, filter_id : String) -> @xml.Node {
  let rad = attr_double(blur, "rad", 0.0)
  let std_dev = rad / 2.0
  let body : Array[@xml.Node] = [
    @markup.elem_ns(
      "feGaussianBlur",
      @markup.svg_ns,
      [
        @markup.attr("in", "SourceGraphic"),
        @markup.attr("stdDeviation", format_double_for_filter(std_dev)),
      ],
      [],
    ),
  ]
  wrap_filter_tight(filter_id, body)
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
/// Priority matches `effects.ts:252`: shadow > glow > softEdge > blur.
/// Reflection (§20.1.8.50) is not rendered — SVG cannot express the
/// distance/blur/start-alpha/end-alpha combination as a single filter
/// without `<image>` composition, and the TS version skips it too.
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
/// side-effect.  Priority matches `effects.ts:252`:
/// shadow > glow > softEdge > blur.
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
      // Priority: outerShdw > innerShdw > glow > softEdge > blur.
      let outer_shdw = first_child_named(lst, "outerShdw")
      let inner_shdw = first_child_named(lst, "innerShdw")
      let glow = first_child_named(lst, "glow")
      let soft_edge = first_child_named(lst, "softEdge")
      let blur = first_child_named(lst, "blur")
      let filter_body : @xml.Node? = match outer_shdw {
        Some(e) => Some(generate_outer_shadow_filter(e, filter_id, ctx))
        None =>
          match inner_shdw {
            Some(e) => Some(generate_inner_shadow_filter(e, filter_id, ctx))
            None =>
              match glow {
                Some(e) => Some(generate_glow_filter(e, filter_id, ctx))
                None =>
                  match soft_edge {
                    Some(e) => Some(generate_soft_edge_filter(e, filter_id))
                    None =>
                      match blur {
                        Some(e) => Some(generate_blur_filter(e, filter_id))
                        None => None
                      }
                  }
              }
          }
      }
      match filter_body {
        None => []
        Some(def) => {
          defs.add_def(def)
          [@markup.attr("filter", "url(#" + filter_id + ")")]
        }
      }
    }
  }
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
      match (try? @strconv.parse_double(v)) {
        Ok(d) => d
        Err(_) => default
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
          "srgbClr" | "schemeClr" | "sysClr" | "hslClr" | "scrgbClr" | "prstClr" =>
            for inner in color_el.children {
              match inner {
                @xml.Node::Element(alpha_el) =>
                  if alpha_el.name.local_name == "alpha" {
                    match attr_value(alpha_el, "val") {
                      Some(v) =>
                        match (try? @strconv.parse_double(v)) {
                          // §20.1.10.55 ST_PositiveFixedPercentage:
                          // value is in thousandths of a percent
                          // (0..100000), so divide by 100000 to
                          // get the 0..1 opacity multiplier.
                          Ok(d) => return d / 100000.0
                          Err(_) => ()
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
  default
}
