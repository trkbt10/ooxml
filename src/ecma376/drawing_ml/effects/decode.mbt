///|
/// §20.1.8 decode context. The active §20.1.6 theme color scheme and an
/// optional placeholder color used when a child color element resolves
/// `schemeClr/@val=phClr`.
pub(all) struct DecodeContext {
  scheme : @color.ColorScheme
  placeholder : @color.Rgba8?
} derive(Eq, Debug)

///|
/// §20.1.8.26 decode a `CT_EffectList` element into an ordered list of
/// `Effect` entries. Unknown child elements raise `SchemaViolation`.
pub fn decode_effect_list(
  list : @dml.CT_EffectList,
  ctx : DecodeContext,
) -> Array[Effect] raise @opc_errors.SchemaViolation {
  decode_effect_children(list.element, ctx)
}

///|
/// §20.1.8 decode each effect child of the supplied element under
/// `ctx`. Shared by `effectLst` and the per-effect entry points used in
/// tests.
pub fn decode_effect_children(
  element : @xml.Element,
  ctx : DecodeContext,
) -> Array[Effect] raise @opc_errors.SchemaViolation {
  let out : Array[Effect] = []
  for child in element.children {
    if child is @xml.Node::Element(e) {
      out.push(decode_effect_element(e, ctx))
    }
  }
  out
}

///|
/// §20.1.8 dispatch a single effect element into its `Effect` variant.
pub fn decode_effect_element(
  element : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  match element.name.local_name {
    "blur" => decode_blur(element)
    "glow" => decode_glow(element, ctx)
    "innerShdw" => decode_inner_shadow(element, ctx)
    "outerShdw" => decode_outer_shadow(element, ctx)
    "prstShdw" => decode_preset_shadow(element, ctx)
    "reflection" => decode_reflection(element)
    "softEdge" => decode_soft_edge(element)
    "tint" => decode_tint(element)
    "duotone" => decode_duotone(element, ctx)
    "lum" => decode_lum(element)
    "hsl" => decode_hsl(element)
    "fillOverlay" => decode_fill_overlay(element)
    "alphaMod" => Effect::AlphaModEffect
    "alphaModFix" => decode_alpha_mod_fix(element)
    "alphaCeiling" => Effect::AlphaCeiling
    "alphaFloor" => Effect::AlphaFloor
    "alphaInv" => decode_alpha_inverse(element, ctx)
    "alphaRepl" => decode_alpha_replace(element)
    "alphaOutset" => decode_alpha_outset(element)
    "alphaBiLevel" => decode_alpha_bilevel(element)
    "biLevel" => decode_bilevel(element)
    "blend" => decode_blend(element)
    "clrChange" => decode_clr_change(element, ctx)
    "clrRepl" => decode_clr_repl(element, ctx)
    "grayscl" => Effect::Grayscale
    "relOff" => decode_rel_off(element)
    "xfrm" => decode_xfrm(element)
    name =>
      schema_error("§20.1.8", name, "unknown effect element in effectLst")
  }
}

///|
fn decode_blur(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let rad = optional_int_attr(e, "rad").unwrap_or(0)
  let grow = optional_bool_attr(e, "grow").unwrap_or(true)
  Effect::Blur(rad, grow)
}

///|
fn decode_glow(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let rad = optional_int_attr(e, "rad").unwrap_or(0)
  let color = decode_single_color_child(e, "§20.1.8.32", "glow", ctx)
  Effect::Glow(rad, color)
}

///|
fn decode_inner_shadow(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let blur_rad = optional_int_attr(e, "blurRad").unwrap_or(0)
  let dist = optional_int_attr(e, "dist").unwrap_or(0)
  let dir = optional_int_attr(e, "dir").unwrap_or(0)
  let color = decode_single_color_child(e, "§20.1.8.40", "innerShdw", ctx)
  Effect::InnerShadow({ blur_rad, dist, dir, color })
}

///|
fn decode_outer_shadow(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let blur_rad = optional_int_attr(e, "blurRad").unwrap_or(0)
  let dist = optional_int_attr(e, "dist").unwrap_or(0)
  let dir = optional_int_attr(e, "dir").unwrap_or(0)
  let sx = optional_int_attr(e, "sx").unwrap_or(100000)
  let sy = optional_int_attr(e, "sy").unwrap_or(100000)
  let kx = optional_int_attr(e, "kx").unwrap_or(0)
  let ky = optional_int_attr(e, "ky").unwrap_or(0)
  let algn = optional_shadow_align(e, "algn").unwrap_or(ShadowAlign::B)
  let rot_with_shape = optional_bool_attr(e, "rotWithShape").unwrap_or(true)
  let color = decode_single_color_child(e, "§20.1.8.45", "outerShdw", ctx)
  Effect::OuterShadow({
    blur_rad,
    dist,
    dir,
    sx,
    sy,
    kx,
    ky,
    algn,
    rot_with_shape,
    color,
  })
}

///|
fn decode_preset_shadow(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let prst_attr = required_attr(e, "prst", "§20.1.8.49")
  let prst = parse_preset_shadow_kind(prst_attr)
  let dir = optional_int_attr(e, "dir").unwrap_or(0)
  let dist = optional_int_attr(e, "dist").unwrap_or(0)
  let color = decode_single_color_child(e, "§20.1.8.49", "prstShdw", ctx)
  Effect::PresetShadow({ prst, dir, dist, color })
}

///|
fn decode_reflection(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let blur_rad = optional_int_attr(e, "blurRad").unwrap_or(0)
  let st_a = optional_int_attr(e, "stA").unwrap_or(100000)
  let st_pos = optional_int_attr(e, "stPos").unwrap_or(0)
  let end_a = optional_int_attr(e, "endA").unwrap_or(0)
  let end_pos = optional_int_attr(e, "endPos").unwrap_or(100000)
  let dist = optional_int_attr(e, "dist").unwrap_or(0)
  let dir = optional_int_attr(e, "dir").unwrap_or(0)
  let fade_dir = optional_int_attr(e, "fadeDir").unwrap_or(5400000)
  let sx = optional_int_attr(e, "sx").unwrap_or(100000)
  let sy = optional_int_attr(e, "sy").unwrap_or(100000)
  let kx = optional_int_attr(e, "kx").unwrap_or(0)
  let ky = optional_int_attr(e, "ky").unwrap_or(0)
  let algn = optional_shadow_align(e, "algn").unwrap_or(ShadowAlign::B)
  let rot_with_shape = optional_bool_attr(e, "rotWithShape").unwrap_or(true)
  Effect::Reflection({
    blur_rad,
    st_a,
    st_pos,
    end_a,
    end_pos,
    dist,
    dir,
    fade_dir,
    sx,
    sy,
    kx,
    ky,
    algn,
    rot_with_shape,
  })
}

///|
fn decode_soft_edge(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let rad = optional_int_attr(e, "rad").unwrap_or(0)
  Effect::SoftEdge(rad)
}

///|
fn decode_tint(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let amt = optional_int_attr(e, "amt").unwrap_or(0)
  let hue = optional_int_attr(e, "hue").unwrap_or(0)
  Effect::Tint(amt, hue)
}

///|
fn decode_duotone(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let colors = decode_color_children(e, ctx)
  if colors.length() != 2 {
    schema_error("§20.1.8.23", "duotone", "expected two color children")
  }
  Effect::Duotone(colors[0], colors[1])
}

///|
fn decode_lum(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let bright = optional_int_attr(e, "bright").unwrap_or(0)
  let contrast = optional_int_attr(e, "contrast").unwrap_or(0)
  Effect::Lum(bright, contrast)
}

///|
fn decode_hsl(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let hue = optional_int_attr(e, "hue").unwrap_or(0)
  let sat = optional_int_attr(e, "sat").unwrap_or(0)
  let lum = optional_int_attr(e, "lum").unwrap_or(0)
  Effect::Hsl(hue, sat, lum)
}

///|
fn decode_fill_overlay(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let blend = parse_blend_mode(required_attr(e, "blend", "§20.1.8.29"))
  Effect::FillOverlay(blend)
}

///|
fn decode_alpha_mod_fix(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let amt = required_int_attr(e, "amt", "§20.1.8.6")
  Effect::AlphaModFix(amt)
}

///|
fn decode_alpha_inverse(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let colors = decode_color_children(e, ctx)
  if colors.length() == 0 {
    Effect::AlphaInverse(None)
  } else if colors.length() == 1 {
    Effect::AlphaInverse(Some(colors[0]))
  } else {
    schema_error("§20.1.8.4", "alphaInv", "expected at most one color child")
  }
}

///|
fn decode_alpha_replace(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let a = required_int_attr(e, "a", "§20.1.8.8")
  Effect::AlphaReplace(a)
}

///|
fn decode_alpha_outset(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let rad = optional_int_attr(e, "rad").unwrap_or(0)
  Effect::AlphaOutset(rad)
}

///|
fn decode_alpha_bilevel(
  e : @xml.Element,
) -> Effect raise @opc_errors.SchemaViolation {
  let thresh = required_int_attr(e, "thresh", "§20.1.8.1")
  Effect::AlphaBiLevel(thresh)
}

///|
fn decode_bilevel(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let thresh = required_int_attr(e, "thresh", "§20.1.8.11")
  Effect::BiLevel(thresh)
}

///|
fn decode_blend(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let blend = parse_blend_mode(required_attr(e, "blend", "§20.1.8.12"))
  Effect::Blend(blend)
}

///|
fn decode_clr_change(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let use_alpha = optional_bool_attr(e, "useA").unwrap_or(true)
  let from_container = required_child(e, "clrFrom", "§20.1.8.17")
  let to_container = required_child(e, "clrTo", "§20.1.8.19")
  let from = decode_color_container(
    from_container, "§20.1.8.17", "clrFrom", ctx,
  )
  let to = decode_color_container(to_container, "§20.1.8.19", "clrTo", ctx)
  Effect::ClrChange(from, to, use_alpha)
}

///|
fn decode_clr_repl(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Effect raise @opc_errors.SchemaViolation {
  let color = decode_single_color_ref_child(e, "§20.1.8.18", "clrRepl", ctx)
  Effect::ClrRepl(color)
}

///|
fn decode_rel_off(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let tx = optional_int_attr(e, "tx").unwrap_or(0)
  let ty = optional_int_attr(e, "ty").unwrap_or(0)
  Effect::RelativeOffset(tx, ty)
}

///|
fn decode_xfrm(e : @xml.Element) -> Effect raise @opc_errors.SchemaViolation {
  let sx = optional_int_attr(e, "sx").unwrap_or(100000)
  let sy = optional_int_attr(e, "sy").unwrap_or(100000)
  let kx = optional_int_attr(e, "kx").unwrap_or(0)
  let ky = optional_int_attr(e, "ky").unwrap_or(0)
  let tx = optional_int_attr(e, "tx").unwrap_or(0)
  let ty = optional_int_attr(e, "ty").unwrap_or(0)
  Effect::Transform({ sx, sy, kx, ky, tx, ty })
}

///|
fn decode_color_children(
  e : @xml.Element,
  ctx : DecodeContext,
) -> Array[@color.Rgba8] raise @opc_errors.SchemaViolation {
  let out : Array[@color.Rgba8] = []
  for child in e.children {
    if child is @xml.Node::Element(c) && is_color_ref_element(c) {
      let (base, transforms) = @color.read_color_ref(c)
      out.push(
        @color.resolve_color(base, transforms, ctx.scheme, ctx.placeholder),
      )
    }
  }
  out
}

///|
fn decode_single_color_child(
  e : @xml.Element,
  section : String,
  path : String,
  ctx : DecodeContext,
) -> @color.Rgba8 raise @opc_errors.SchemaViolation {
  let colors = decode_color_children(e, ctx)
  if colors.length() != 1 {
    schema_error(section, path, "expected one color child")
  }
  colors[0]
}

///|
fn decode_single_color_ref_child(
  e : @xml.Element,
  section : String,
  path : String,
  ctx : DecodeContext,
) -> @color.Rgba8 raise @opc_errors.SchemaViolation {
  decode_single_color_child(e, section, path, ctx)
}

///|
fn decode_color_container(
  container : @xml.Element,
  section : String,
  path : String,
  ctx : DecodeContext,
) -> @color.Rgba8 raise @opc_errors.SchemaViolation {
  decode_single_color_child(container, section, path, ctx)
}

///|
fn is_color_ref_element(e : @xml.Element) -> Bool {
  match e.name.local_name {
    "srgbClr" | "schemeClr" | "sysClr" | "prstClr" | "hslClr" => true
    _ => false
  }
}

///|
fn parse_blend_mode(
  value : String,
) -> BlendMode raise @opc_errors.SchemaViolation {
  match value {
    "over" => BlendMode::Over
    "mult" => BlendMode::Mult
    "screen" => BlendMode::Screen
    "darken" => BlendMode::Darken
    "lighten" => BlendMode::Lighten
    _ =>
      schema_error(
        "§20.1.10.11",
        "ST_BlendMode",
        "unknown blend mode " + value,
      )
  }
}

///|
fn parse_shadow_align(
  value : String,
) -> ShadowAlign raise @opc_errors.SchemaViolation {
  match value {
    "tl" => ShadowAlign::Tl
    "t" => ShadowAlign::T
    "tr" => ShadowAlign::Tr
    "l" => ShadowAlign::L
    "ctr" => ShadowAlign::Ctr
    "r" => ShadowAlign::R
    "bl" => ShadowAlign::Bl
    "b" => ShadowAlign::B
    "br" => ShadowAlign::Br
    _ =>
      schema_error(
        "§20.1.10.53",
        "ST_RectAlignment",
        "unknown shadow alignment " + value,
      )
  }
}

///|
fn parse_preset_shadow_kind(
  value : String,
) -> PresetShadowKind raise @opc_errors.SchemaViolation {
  match value {
    "shdw1" => PresetShadowKind::Shdw1
    "shdw2" => PresetShadowKind::Shdw2
    "shdw3" => PresetShadowKind::Shdw3
    "shdw4" => PresetShadowKind::Shdw4
    "shdw5" => PresetShadowKind::Shdw5
    "shdw6" => PresetShadowKind::Shdw6
    "shdw7" => PresetShadowKind::Shdw7
    "shdw8" => PresetShadowKind::Shdw8
    "shdw9" => PresetShadowKind::Shdw9
    "shdw10" => PresetShadowKind::Shdw10
    "shdw11" => PresetShadowKind::Shdw11
    "shdw12" => PresetShadowKind::Shdw12
    "shdw13" => PresetShadowKind::Shdw13
    "shdw14" => PresetShadowKind::Shdw14
    "shdw15" => PresetShadowKind::Shdw15
    "shdw16" => PresetShadowKind::Shdw16
    "shdw17" => PresetShadowKind::Shdw17
    "shdw18" => PresetShadowKind::Shdw18
    "shdw19" => PresetShadowKind::Shdw19
    "shdw20" => PresetShadowKind::Shdw20
    _ =>
      schema_error(
        "§20.1.10.52",
        "ST_PresetShadowVal",
        "unknown preset shadow " + value,
      )
  }
}

///|
fn required_child(
  element : @xml.Element,
  local_name : String,
  section : String,
) -> @xml.Element raise @opc_errors.SchemaViolation {
  for child in element.children {
    if child is @xml.Node::Element(e) && e.name.local_name == local_name {
      return e
    }
  }
  schema_error(section, local_name, "missing required child element")
}

///|
fn required_attr(
  element : @xml.Element,
  local_name : String,
  section : String,
) -> String raise @opc_errors.SchemaViolation {
  match optional_attr(element, local_name) {
    Some(value) => value
    None =>
      schema_error(
        section,
        element.name.local_name + "/@" + local_name,
        "missing required attribute",
      )
  }
}

///|
fn optional_attr(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
fn required_int_attr(
  element : @xml.Element,
  attr : String,
  section : String,
) -> Int raise @opc_errors.SchemaViolation {
  parse_int(
    required_attr(element, attr, section),
    section,
    element.name.local_name + "/@" + attr,
  )
}

///|
fn optional_int_attr(
  element : @xml.Element,
  attr : String,
) -> Int? raise @opc_errors.SchemaViolation {
  match optional_attr(element, attr) {
    Some(value) =>
      Some(parse_int(value, "§20.1.8", element.name.local_name + "/@" + attr))
    None => None
  }
}

///|
fn optional_bool_attr(
  element : @xml.Element,
  attr : String,
) -> Bool? raise @opc_errors.SchemaViolation {
  match optional_attr(element, attr) {
    Some(value) =>
      Some(parse_bool(value, "§20.1.8", element.name.local_name + "/@" + attr))
    None => None
  }
}

///|
fn optional_shadow_align(
  element : @xml.Element,
  attr : String,
) -> ShadowAlign? raise @opc_errors.SchemaViolation {
  match optional_attr(element, attr) {
    Some(value) => Some(parse_shadow_align(value))
    None => None
  }
}

///|
fn parse_bool(
  value : String,
  section : String,
  path : String,
) -> Bool raise @opc_errors.SchemaViolation {
  match value {
    "1" | "true" => true
    "0" | "false" => false
    _ => schema_error(section, path, "invalid boolean " + value)
  }
}

///|
fn parse_int(
  value : String,
  section : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  if value.length() == 0 {
    schema_error(section, path, "empty integer")
  }
  if value.code_unit_at(value.length() - 1) == '%' {
    let body = value.unsafe_substring(start=0, end=value.length() - 1)
    parse_int_raw(body, section, path) * 1000
  } else {
    parse_int_raw(value, section, path)
  }
}

///|
fn parse_int_raw(
  value : String,
  section : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  if value.length() == 0 {
    schema_error(section, path, "empty integer")
  }
  let mut sign = 1
  let mut index = 0
  if value.code_unit_at(0) == '-' {
    sign = -1
    index = 1
  } else if value.code_unit_at(0) == '+' {
    index = 1
  }
  if index == value.length() {
    schema_error(section, path, "missing integer digits")
  }
  let mut out = 0
  while index < value.length() {
    let ch = value.code_unit_at(index)
    if ch < '0' || ch > '9' {
      schema_error(section, path, "invalid integer digit")
    }
    out = out * 10 + (ch.to_int() - '0'.to_int())
    index = index + 1
  }
  out * sign
}

///|
fn[T] schema_error(
  section : String,
  path : String,
  reason : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(section~, path~, reason~)
}
