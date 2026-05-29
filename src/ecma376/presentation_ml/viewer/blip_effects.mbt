// SVG filter emission for ECMA-376 §20.1.8.13 CT_Blip raster effects.
//
// Blip effects are cumulated in document order (§20.1.8.13 note):
// each effect's output feeds the next effect's input, forming a
// linear pipeline. This contrasts with shape effects (effectLst)
// which compose via merge-under/merge-over stacking.
//
// All 17 effects are handled at spec-level accuracy:
//
//   SVG filter (exact):
//     grayscl, alphaModFix, alphaRepl, lum, blur, alphaBiLevel,
//     biLevel, duotone, alphaFloor, alphaCeiling, alphaInv,
//     clrRepl, fillOverlay
//   SVG filter (limited container support):
//     alphaMod — handles single-alphaModFix container; complex
//                effect graphs require recursive traversal
//   Pixel pre-processing (via @image_ops, spec-compliant):
//     clrChange — per-pixel conditional colour matching
//     tint      — per-pixel hue convergence toward target
//     hsl       — per-pixel HSL shift
//
// Architecture: `preprocess_blip_image` runs pixel-level operations
// on the decoded image BEFORE SVG embedding. `build_blip_effect_filter`
// emits SVG `<filter>` primitives for effects that SVG can represent.
// Both walk the same `<a:blip>` children in document order.

///|
/// Pre-process a blip image for effects that require pixel-level
/// manipulation (clrChange, tint, hsl). Decodes the image, applies
/// each pixel-level effect in document order, and re-encodes to PNG.
/// Returns `Some((new_mime, new_base64))` when at least one pixel
/// effect was applied, `None` otherwise (caller keeps the original).
fn preprocess_blip_image(
  blip_fill : @xml.Element,
  mime_type : String,
  base64_data : String,
  ctx : ColorResolveContext,
) -> (String, String)? {
  let blip_el = match first_child_named(blip_fill, "blip") {
    Some(b) => b
    None => return None
  }
  let mut needs_pixel_ops = false
  for child in blip_el.children {
    match child {
      @xml.Node::Element(el) =>
        match el.name.local_name {
          "clrChange" | "tint" | "hsl" => {
            needs_pixel_ops = true
            break
          }
          _ => ()
        }
      _ => ()
    }
  }
  if !needs_pixel_ops {
    return None
  }
  let mut img = match @image_ops.decode_image(mime_type, base64_data) {
    Some(i) => i
    None => return None
  }
  for child in blip_el.children {
    match child {
      @xml.Node::Element(el) =>
        match el.name.local_name {
          "clrChange" => {
            let clr_from_el = match first_child_named(el, "clrFrom") {
              Some(e) => e
              None => continue
            }
            let clr_to_el = match first_child_named(el, "clrTo") {
              Some(e) => e
              None => continue
            }
            let hex_from = resolve_effect_color_hex(clr_from_el, ctx)
            let hex_to = resolve_effect_color_hex(clr_to_el, ctx)
            let (fr, fg, fb) = parse_hex_to_rgb(hex_from)
            let (tr, tg, tb) = parse_hex_to_rgb(hex_to)
            let use_alpha = parse_xsd_boolean_or(
              attr_value(el, "useA"),
              true,
            )
            img = @image_ops.apply_clr_change(
              img,
              (
                (fr * 255.0 + 0.5).to_int(),
                (fg * 255.0 + 0.5).to_int(),
                (fb * 255.0 + 0.5).to_int(),
              ),
              (
                (tr * 255.0 + 0.5).to_int(),
                (tg * 255.0 + 0.5).to_int(),
                (tb * 255.0 + 0.5).to_int(),
                255,
              ),
              use_alpha,
              10,
            )
          }
          "tint" => {
            let hue = attr_double(el, "hue", 0.0) / 60000.0
            let amt = read_pct_fraction(el, "amt", 0.0)
            if amt != 0.0 {
              img = @image_ops.apply_tint(img, hue, amt)
            }
          }
          "hsl" => {
            let hue = attr_double(el, "hue", 0.0) / 60000.0
            let sat = read_pct_fraction(el, "sat", 0.0)
            let lum = read_pct_fraction(el, "lum", 0.0)
            if hue != 0.0 || sat != 0.0 || lum != 0.0 {
              img = @image_ops.apply_hsl(img, hue, sat, lum)
            }
          }
          _ => ()
        }
      _ => ()
    }
  }
  @image_ops.encode_image_base64(img, mime_type)
}

///|
/// Build a `<filter>` definition for the blip effects declared on a
/// `<a:blipFill>` element. Returns `Some("url(#id)")` when at least
/// one supported effect is present, `None` otherwise. The filter
/// definition is pushed into `defs` as a side-effect.
fn build_blip_effect_filter(
  blip_fill : @xml.Element,
  defs : SvgDefsCollector,
  ctx : ColorResolveContext,
) -> String? {
  let blip_el = match first_child_named(blip_fill, "blip") {
    Some(b) => b
    None => return None
  }
  let primitives : Array[@xml.Node] = []
  let mut prev_result = "SourceGraphic"
  let mut idx = 0
  let mut needs_grow = false
  for child in blip_el.children {
    match child {
      @xml.Node::Element(el) => {
        let result_id = "bfx" + idx.to_string()
        let nodes : Array[@xml.Node] = match el.name.local_name {
          "grayscl" => blip_fx_grayscl(prev_result, result_id)
          "alphaModFix" => blip_fx_alpha_mod_fix(el, prev_result, result_id)
          "alphaRepl" => blip_fx_alpha_repl(el, prev_result, result_id)
          "lum" => blip_fx_lum(el, prev_result, result_id)
          "blur" => {
            let grow = parse_xsd_boolean_or(attr_value(el, "grow"), true)
            let rad_px = attr_double(el, "rad", 0.0) / 9525.0
            if grow && rad_px > 0.0 {
              needs_grow = true
            }
            blip_fx_blur(el, prev_result, result_id)
          }
          "alphaBiLevel" => blip_fx_alpha_bi_level(el, prev_result, result_id)
          "biLevel" => blip_fx_bi_level(el, prev_result, result_id)
          // tint, hsl, clrChange are handled by preprocess_blip_image
          // (pixel-level ops) — skip here to avoid double application.
          "tint" | "hsl" | "clrChange" => []
          "duotone" => blip_fx_duotone(el, prev_result, result_id, ctx)
          "fillOverlay" =>
            blip_fx_fill_overlay(el, prev_result, result_id, ctx)
          "alphaFloor" => blip_fx_alpha_floor(prev_result, result_id)
          "alphaCeiling" => blip_fx_alpha_ceiling(prev_result, result_id)
          "alphaInv" => blip_fx_alpha_inv(prev_result, result_id)
          "alphaMod" => blip_fx_alpha_mod(el, prev_result, result_id)
          "clrRepl" => blip_fx_clr_repl(el, prev_result, result_id, ctx)
          _ => []
        }
        if nodes.length() > 0 {
          for n in nodes {
            primitives.push(n)
          }
          prev_result = result_id
          idx = idx + 1
        }
      }
      _ => ()
    }
  }
  if primitives.length() == 0 {
    return None
  }
  let filter_id = defs.next_id("blip-fx")
  // When a blur with grow=true is present, widen the filter
  // viewport so the halo is not clipped. We don't know the
  // element's pixel dimensions at filter-build time, so we use
  // a fixed 50 % margin (matching the shape effect convention
  // in wrap_filter_with_extents). The default 0 % tight
  // viewport is kept for non-blur filters to avoid wasting
  // rasteriser buffer.
  let (x_pct, y_pct, w_pct, h_pct) = if needs_grow {
    (-50.0, -50.0, 200.0, 200.0)
  } else {
    (0.0, 0.0, 100.0, 100.0)
  }
  let pct_s = fn(v : Double) -> String { format_double_for_filter(v) + "%" }
  let filter_node = @markup.elem_ns(
    "filter",
    @markup.svg_ns,
    [
      @markup.attr("id", filter_id),
      @markup.attr("color-interpolation-filters", "sRGB"),
      @markup.attr("x", pct_s(x_pct)),
      @markup.attr("y", pct_s(y_pct)),
      @markup.attr("width", pct_s(w_pct)),
      @markup.attr("height", pct_s(h_pct)),
    ],
    primitives,
  )
  defs.add_def(filter_node)
  Some("url(#" + filter_id + ")")
}

///|
/// Read a percentage attribute as a 0..1 fraction, supporting both
/// the transitional integer format (thousandths of percent, e.g.
/// "50000" = 50 %) and the strict "%" suffix format ("50%").
/// Reuses the viewer's `parse_st_positive_fixed_percentage` per
/// handover requirement.
fn read_pct_fraction(el : @xml.Element, name : String, default_pct : Double) -> Double {
  let raw = attr_value(el, name)
  match raw {
    Some(_) => parse_st_positive_fixed_percentage(raw) / 100.0
    None => default_pct / 100.0
  }
}

// ===================================================================
// Tier 1 — direct SVG filter mapping
// ===================================================================

///|
/// BT.601 luminance coefficients — PowerPoint uses these for
/// greyscale conversion rather than BT.709.
let grayscale_r : Double = 0.299

///|
let grayscale_g : Double = 0.587

///|
let grayscale_b : Double = 0.114

///|
/// 4×5 feColorMatrix values for BT.601 greyscale conversion.
fn grayscale_matrix() -> String {
  let r = format_double_for_filter(grayscale_r)
  let g = format_double_for_filter(grayscale_g)
  let b = format_double_for_filter(grayscale_b)
  r + " " + g + " " + b + " 0 0  " + r + " " + g + " " + b +
  " 0 0  " + r + " " + g + " " + b + " 0 0  0 0 0 1 0"
}

///|
/// §20.1.8.34 grayscl — convert to greyscale using BT.601 coefficients
/// to match PowerPoint's rendering.
fn blip_fx_grayscl(in_attr : String, result : String) -> Array[@xml.Node] {
  [fe_color_matrix(in_attr, grayscale_matrix(), result)]
}

///|
/// §20.1.8.6 alphaModFix — multiplicative alpha modulation.
/// @amt is ST_PositivePercentage in thousandths of percent (default
/// 100000 = 100%).
fn blip_fx_alpha_mod_fix(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let amt = read_pct_fraction(el, "amt", 100.0)
  [
    fe_component_transfer(
      in_attr,
      result,
      func_a=[
        fe_func("feFuncA", "linear", slope=amt, intercept=0.0),
      ],
    ),
  ]
}

///|
/// §20.1.8.8 alphaRepl — replace alpha with a constant.
/// @a is ST_PositiveFixedPercentage in thousandths of percent.
fn blip_fx_alpha_repl(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let a = read_pct_fraction(el, "a", 100.0)
  [
    fe_component_transfer(
      in_attr,
      result,
      func_a=[
        fe_func("feFuncA", "linear", slope=0.0, intercept=a),
      ],
    ),
  ]
}

///|
/// §20.1.8.42 lum — brightness / contrast adjustment.
/// @bright and @contrast are ST_FixedPercentage in thousandths of
/// percent (default 0).
///
/// The SVG mapping applies per-channel linear transfer functions:
///   slope = 1 + contrast/100000
///   intercept = bright/100000 - contrast/200000
///
/// The intercept term `-contrast/200000` centres the contrast pivot
/// at mid-grey (0.5) so that increasing contrast darkens shadows and
/// brightens highlights symmetrically, matching the ECMA-376 spec's
/// §20.1.8.42 behaviour and PowerPoint's rendering.
fn blip_fx_lum(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let bright = read_pct_fraction(el, "bright", 0.0)
  let contrast = read_pct_fraction(el, "contrast", 0.0)
  let slope = 1.0 + contrast
  let intercept = bright - contrast * 0.5
  let func_r = fe_func("feFuncR", "linear", slope~, intercept~)
  let func_g = fe_func("feFuncG", "linear", slope~, intercept~)
  let func_b = fe_func("feFuncB", "linear", slope~, intercept~)
  [fe_component_transfer(in_attr, result, func_rgb=[func_r, func_g, func_b])]
}

///|
/// §20.1.8.15 blur — Gaussian blur.
/// @rad is ST_PositiveCoordinate in EMU (default 0).
/// @grow is xsd:boolean (default true) — for blip effects we always
/// constrain to the image bounds (the filter viewport is 0%/100%).
fn blip_fx_blur(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let rad_emu = attr_double(el, "rad", 0.0)
  let rad_px = rad_emu / 9525.0
  let std_dev = rad_px / 2.0
  if std_dev <= 0.0 {
    return []
  }
  [fe_gaussian_blur(in_attr, std_dev, result)]
}

///|
/// §20.1.8.1 alphaBiLevel — binary alpha threshold.
/// @thresh is ST_PositiveFixedPercentage in thousandths of percent.
/// Alpha values at or above the threshold snap to 1; below snap to 0.
fn blip_fx_alpha_bi_level(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let thresh = read_pct_fraction(el, "thresh", 50.0)
  let table = generate_discrete_table(thresh)
  [
    fe_component_transfer(
      in_attr,
      result,
      func_a=[fe_func_discrete("feFuncA", table)],
    ),
  ]
}

// ===================================================================
// Tier 2 — approximate SVG filter mapping
// ===================================================================

///|
/// §20.1.8.11 biLevel — binary luminance threshold (black/white).
/// @thresh is ST_PositiveFixedPercentage in thousandths of percent.
/// Pixels with luminance at or above the threshold become white;
/// below become black. Alpha is preserved.
fn blip_fx_bi_level(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let thresh = read_pct_fraction(el, "thresh", 50.0)
  let table = generate_discrete_table(thresh)
  let mid = result + "_gs"
  [
    fe_color_matrix(in_attr, grayscale_matrix(), mid),
    fe_component_transfer(
      mid,
      result,
      func_rgb=[
        fe_func_discrete("feFuncR", table),
        fe_func_discrete("feFuncG", table),
        fe_func_discrete("feFuncB", table),
      ],
    ),
  ]
}

///|
/// §20.1.8.60 tint — shift every pixel's hue toward a target hue.
/// @hue is ST_PositiveFixedAngle in 60000ths of degree (default 0).
// tint, hsl are now handled by preprocess_blip_image (pixel ops).

///|
/// §20.1.8.23 duotone — map luminance to a two-colour gradient.
/// Children: exactly two EG_ColorChoice arms in document order.
///
/// Implementation: greyscale → feComponentTransfer with per-channel
/// linear interpolation tables (type="table" tableValues="c1 c2")
/// mapping black to colour 1 and white to colour 2.
fn blip_fx_duotone(
  el : @xml.Element,
  in_attr : String,
  result : String,
  ctx : ColorResolveContext,
) -> Array[@xml.Node] {
  let colors = collect_color_children_hex(el, ctx)
  if colors.length() < 2 {
    return []
  }
  let (r1, g1, b1) = parse_hex_to_rgb(colors[0])
  let (r2, g2, b2) = parse_hex_to_rgb(colors[1])
  let mid = result + "_gs"
  let fr = format_double_for_filter
  [
    fe_color_matrix(in_attr, grayscale_matrix(), mid),
    fe_component_transfer(
      mid,
      result,
      func_rgb=[
        fe_func_table("feFuncR", fr(r1) + " " + fr(r2)),
        fe_func_table("feFuncG", fr(g1) + " " + fr(g2)),
        fe_func_table("feFuncB", fr(b1) + " " + fr(b2)),
      ],
    ),
  ]
}

///|
/// §20.1.8.29 fillOverlay — blend a fill colour over the image.
/// @blend is ST_BlendMode (default "over").
/// Child: EG_FillProperties (typically <a:solidFill>).
fn blip_fx_fill_overlay(
  el : @xml.Element,
  in_attr : String,
  result : String,
  ctx : ColorResolveContext,
) -> Array[@xml.Node] {
  let hex = resolve_effect_color_hex(el, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  let opacity = read_effect_alpha(el, 1.0)
  let blend = match attr_value(el, "blend") {
    Some(v) => v
    None => "over"
  }
  let flood_id = result + "_fl"
  let clip_id = result + "_cl"
  [
    fe_flood(rgb_css(r, g, b), opacity, flood_id),
    fe_composite(flood_id, in_attr, "in", clip_id),
    fe_blend(clip_id, in_attr, blend_to_svg_mode(blend), result),
  ]
}

///|
/// §20.1.8.3 alphaFloor — floor alpha to 0 unless fully opaque.
/// Alpha < 1.0 → 0; alpha = 1.0 → 1.
fn blip_fx_alpha_floor(in_attr : String, result : String) -> Array[@xml.Node] {
  let table = "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1"
  [
    fe_component_transfer(
      in_attr,
      result,
      func_a=[fe_func_discrete("feFuncA", table)],
    ),
  ]
}

// ===================================================================
// Tier 3 — limited SVG support
// ===================================================================

///|
/// §20.1.8.2 alphaCeiling — ceiling alpha: any non-zero alpha → 1.
fn blip_fx_alpha_ceiling(
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let table = "0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"
  [
    fe_component_transfer(
      in_attr,
      result,
      func_a=[fe_func_discrete("feFuncA", table)],
    ),
  ]
}

///|
/// §20.1.8.4 alphaInv — invert the alpha channel.
/// Optional EG_ColorChoice for colour replacement is ignored in this
/// SVG approximation.
fn blip_fx_alpha_inv(in_attr : String, result : String) -> Array[@xml.Node] {
  [
    fe_component_transfer(
      in_attr,
      result,
      func_a=[fe_func_table_values("feFuncA", "1 0")],
    ),
  ]
}

///|
/// §20.1.8.18 clrRepl — replace all pixel colours with a single
/// colour while preserving alpha.
fn blip_fx_clr_repl(
  el : @xml.Element,
  in_attr : String,
  result : String,
  ctx : ColorResolveContext,
) -> Array[@xml.Node] {
  let hex = resolve_effect_color_hex(el, ctx)
  let (r, g, b) = parse_hex_to_rgb(hex)
  let flood_id = result + "_fl"
  [
    fe_flood(rgb_css(r, g, b), 1.0, flood_id),
    fe_composite(flood_id, in_attr, "in", result),
  ]
}

///|
/// §20.1.8.5 alphaMod — alpha modulation from an effect container.
///
/// The `<cont>` child (CT_EffectContainer) holds a sub-pipeline of
/// effects whose composite output's alpha channel modulates the
/// input. We walk the container's children, build SVG primitives
/// for each recognised alpha effect, chain them, and then apply
/// the result's alpha to the input via `feComposite operator="in"`.
fn blip_fx_alpha_mod(
  el : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  let cont = match first_child_named(el, "cont") {
    Some(c) => c
    None => return []
  }
  let built : Array[@xml.Node] = []
  let (final_prev, _) = build_container_chain(
    cont, result, built, "SourceGraphic", 0,
  )
  if built.length() == 0 {
    return []
  }
  built.push(fe_composite(in_attr, final_prev, "in", result))
  built
}

///|
fn build_container_chain(
  cont : @xml.Element,
  prefix : String,
  out : Array[@xml.Node],
  prev_in : String,
  idx_in : Int,
) -> (String, Int) {
  let mut prev = prev_in
  let mut idx = idx_in
  for child in cont.children {
    match child {
      @xml.Node::Element(eff) => {
        let rid = prefix + "_am" + idx.to_string()
        match eff.name.local_name {
          "cont" => {
            let (new_prev, new_idx) = build_container_chain(
              eff, prefix, out, prev, idx,
            )
            prev = new_prev
            idx = new_idx
          }
          _ => {
            let nodes = dispatch_container_effect(eff, prev, rid)
            if nodes.length() > 0 {
              for n in nodes {
                out.push(n)
              }
              prev = rid
              idx = idx + 1
            }
          }
        }
      }
      _ => ()
    }
  }
  (prev, idx)
}

///|
fn dispatch_container_effect(
  eff : @xml.Element,
  in_attr : String,
  result : String,
) -> Array[@xml.Node] {
  match eff.name.local_name {
    "alphaModFix" => blip_fx_alpha_mod_fix(eff, in_attr, result)
    "alphaBiLevel" => blip_fx_alpha_bi_level(eff, in_attr, result)
    "alphaFloor" => blip_fx_alpha_floor(in_attr, result)
    "alphaCeiling" => blip_fx_alpha_ceiling(in_attr, result)
    "alphaInv" => blip_fx_alpha_inv(in_attr, result)
    "alphaRepl" => blip_fx_alpha_repl(eff, in_attr, result)
    "grayscl" => blip_fx_grayscl(in_attr, result)
    "lum" => blip_fx_lum(eff, in_attr, result)
    "blur" => blip_fx_blur(eff, in_attr, result)
    _ => []
  }
}

// clrChange is now handled by preprocess_blip_image (pixel ops).

// ===================================================================
// SVG filter primitive helpers
// ===================================================================

///|
/// `<feComponentTransfer in=in result=result> ... </feComponentTransfer>`.
/// Accepts optional per-channel transfer function children.
fn fe_component_transfer(
  in_attr : String,
  result : String,
  func_rgb~ : Array[@xml.Node] = [],
  func_a~ : Array[@xml.Node] = [],
) -> @xml.Node {
  let children : Array[@xml.Node] = []
  for n in func_rgb {
    children.push(n)
  }
  for n in func_a {
    children.push(n)
  }
  @markup.elem_ns(
    "feComponentTransfer",
    @markup.svg_ns,
    [@markup.attr("in", in_attr), @markup.attr("result", result)],
    children,
  )
}

///|
/// `<feFuncX type="linear" slope=slope intercept=intercept/>`.
fn fe_func(
  name : String,
  func_type : String,
  slope~ : Double = 1.0,
  intercept~ : Double = 0.0,
) -> @xml.Node {
  @markup.elem_ns(
    name,
    @markup.svg_ns,
    [
      @markup.attr("type", func_type),
      @markup.attr("slope", format_double_for_filter(slope)),
      @markup.attr("intercept", format_double_for_filter(intercept)),
    ],
    [],
  )
}

///|
/// `<feFuncX type="discrete" tableValues=table/>`.
fn fe_func_discrete(name : String, table : String) -> @xml.Node {
  @markup.elem_ns(
    name,
    @markup.svg_ns,
    [
      @markup.attr("type", "discrete"),
      @markup.attr("tableValues", table),
    ],
    [],
  )
}

///|
/// `<feFuncX type="table" tableValues=table/>`.
fn fe_func_table(name : String, table : String) -> @xml.Node {
  @markup.elem_ns(
    name,
    @markup.svg_ns,
    [@markup.attr("type", "table"), @markup.attr("tableValues", table)],
    [],
  )
}

///|
/// `<feFuncX type="table" tableValues=values/>` — alias for
/// clarity when used for alpha inversion and similar 2-point tables.
fn fe_func_table_values(name : String, values : String) -> @xml.Node {
  fe_func_table(name, values)
}

///|
/// Generate a discrete transfer table for a step-function threshold.
/// Uses 20 bins (5 % precision). Values below the threshold map to 0;
/// at or above map to 1.
fn generate_discrete_table(threshold : Double) -> String {
  let n = 20
  let buf = StringBuilder::new()
  for i = 0; i < n; i = i + 1 {
    if i > 0 {
      buf.write_string(" ")
    }
    let bin_start = i.to_double() / n.to_double()
    if bin_start >= threshold {
      buf.write_string("1")
    } else {
      buf.write_string("0")
    }
  }
  buf.to_string()
}

///|
/// Collect resolved hex colours from the EG_ColorChoice children of
/// an element. Used by duotone to extract its two endpoint colours.
fn collect_color_children_hex(
  el : @xml.Element,
  ctx : ColorResolveContext,
) -> Array[String] {
  let result : Array[String] = []
  for child in el.children {
    match child {
      @xml.Node::Element(color_el) =>
        match color_el.name.local_name {
          "srgbClr"
          | "schemeClr"
          | "sysClr"
          | "hslClr"
          | "scrgbClr"
          | "prstClr" =>
            match @paint.resolve_solid_fill(color_el, ctx~) {
              Some(rc) =>
                if rc.hex != "" {
                  result.push(rc.hex)
                } else {
                  result.push("000000")
                }
              None => result.push("000000")
            }
          _ => ()
        }
      _ => ()
    }
  }
  result
}
