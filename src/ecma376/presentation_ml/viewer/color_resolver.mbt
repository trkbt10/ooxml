// @source web-pptx packages/@aurochs-office/pptx/src/parser/graphics/color-resolver.ts
//        + packages/@aurochs-office/drawing-ml/src/domain/color-context.ts
//
// DrawingML colour reference resolution.  Handles all six §20.1.2.3
// colour types — srgbClr, schemeClr, scrgbClr, prstClr, hslClr,
// sysClr — and applies the six §20.1.2.3 colour transforms — alpha,
// shade, tint, lumMod, lumOff, hueMod, satMod.
//
// The transforms are delegated to `@color`; this file only knows how
// to walk a DrawingML colour element and produce a hex string.

///|
/// Theme colour scheme: maps scheme-color names (`dk1`, `lt1`,
/// `accent1`, ...) to hex strings without the leading `#`.  Mirrors
/// `ColorScheme` in `color-context.ts:21`.
pub type ColorScheme = Map[String, String]

///|
/// Slide colour map: maps abstract names (`tx1`, `bg2`) to the
/// underlying scheme-color names. Mirrors `ColorMap` in
/// `color-context.ts:30`.
pub type ColorMap = Map[String, String]

///|
/// Context for resolving DrawingML colour references.  Mirrors
/// `ColorResolveContext` in `color-context.ts:51`.  The slide-level
/// override takes precedence over the master colour map. `ph_clr`
/// holds the active `phClr` substitution (Annex A §20.1.4.1.6) when
/// rendering a fill that originates from a fmtScheme template — the
/// surrounding caller pushes the override before invoking the fill
/// renderer and the inner `resolve_solid_fill` reads it back.
pub struct ColorResolveContext {
  color_map : ColorMap
  color_map_override : ColorMap?
  color_scheme : ColorScheme
  ph_clr : String?
  /// §20.1.4.1.18 fontScheme — `<a:majorFont>` typefaces keyed
  /// by `"lt"` / `"ea"` / `"cs"` / `"sym"`. Empty when no theme.
  major_font : Map[String, String]
  /// §20.1.4.1.18 fontScheme — `<a:minorFont>` typefaces keyed
  /// by `"lt"` / `"ea"` / `"cs"` / `"sym"`. Empty when no theme.
  minor_font : Map[String, String]
}

///|
/// Build an empty colour context for situations where the theme is
/// unavailable (raw shape rendering, tests).
pub fn ColorResolveContext::empty() -> ColorResolveContext {
  {
    color_map: Map::new(),
    color_map_override: None,
    color_scheme: Map::new(),
    ph_clr: None,
    major_font: Map::new(),
    minor_font: Map::new(),
  }
}

///|
/// Derive a new context with a populated `phClr` substitution. The
/// rest of the context is preserved verbatim so theme-resolved colour
/// names continue to map through the same scheme.
///|
/// §20.1.4.1.18 fontScheme — copy `ctx` with `major_font` /
/// `minor_font` populated from a theme's `<a:fontScheme>` so the
/// run-property reader can resolve `+mj-lt` / `+mn-cs` shortcuts.
pub fn ColorResolveContext::with_font_scheme(
  ctx : ColorResolveContext,
  major_font : Map[String, String],
  minor_font : Map[String, String],
) -> ColorResolveContext {
  {
    color_map: ctx.color_map,
    color_map_override: ctx.color_map_override,
    color_scheme: ctx.color_scheme,
    ph_clr: ctx.ph_clr,
    major_font,
    minor_font,
  }
}

///|
/// §21.1.2.3.10 latin / §20.1.4.1.18 fontScheme — resolve a
/// `+mj-lt` / `+mn-ea` etc. shortcut against this context's
/// fontScheme. Returns `None` when the input is not a shortcut or
/// the requested entry is absent (caller keeps the raw typeface).
pub fn ColorResolveContext::resolve_theme_typeface(
  ctx : ColorResolveContext,
  typeface : String,
) -> String? {
  // §20.1.4.1.18 fontScheme — the only spec-defined typeface
  // shortcuts are the six "+<scheme>-<face>" forms:
  //   +mj-lt / +mn-lt — major/minor latin
  //   +mj-ea / +mn-ea — major/minor east-asian
  //   +mj-cs / +mn-cs — major/minor complex-script
  // Every other input MUST be returned as `None` (the caller then
  // treats the value as a literal typeface). We enforce exact
  // length=6 and face_kind ∈ {"lt","ea","cs"} so malformed inputs
  // like "+mj-ltExtra" do not silently match.
  if typeface.length() != 6 {
    return None
  }
  if typeface.code_unit_at(0).to_int() != 0x2B {  // '+'
    return None
  }
  if typeface.code_unit_at(3).to_int() != 0x2D {  // '-'
    return None
  }
  let scheme = typeface[1:3].to_string()
  let face_kind = typeface[4:6].to_string()
  if face_kind != "lt" && face_kind != "ea" && face_kind != "cs" {
    return None
  }
  let map = if scheme == "mj" {
    ctx.major_font
  } else if scheme == "mn" {
    ctx.minor_font
  } else {
    return None
  }
  map.get(face_kind)
}

/// §20.1.4.1.9 / §20.1.4.1.20 — phClr substitution semantics:
/// when a `<a:fillRef>` / `<a:lnRef>` (or any reference into the
/// fmtScheme) is resolved, every `<a:schemeClr val="phClr"/>`
/// element *anywhere inside the resolved template* (including
/// nested `<a:gradFill>/<a:gsLst>/<a:gs>/<a:schemeClr>`) is
/// replaced with the override colour the caller supplied.  This
/// is achieved here without an explicit walk: we push the
/// override into `ColorResolveContext.ph_clr` before re-entering
/// the EG_FillProperties / CT_LineProperties parser, and the
/// inner `get_scheme_color` (color_resolver.mbt:223) returns
/// `ph_clr` whenever `bare == "phClr"`.  Because every
/// `<a:schemeClr>` element passes through that single lookup,
/// the substitution is automatically applied at any depth.
pub fn ColorResolveContext::with_ph_clr(
  ctx : ColorResolveContext,
  ph_clr : String,
) -> ColorResolveContext {
  {
    color_map: ctx.color_map,
    color_map_override: ctx.color_map_override,
    color_scheme: ctx.color_scheme,
    ph_clr: Some(ph_clr),
    major_font: ctx.major_font,
    minor_font: ctx.minor_font,
  }
}

///|
/// §20.1.4.1.6 / §20.1.6.2 — populate the colour scheme table
/// from a theme's `<a:clrScheme>`.  Each slot (dk1/lt1/dk2/lt2,
/// accent1..accent6, hlink, folHlink) is added when its
/// `<a:srgbClr>` or `<a:sysClr lastClr>` value is resolvable.
/// Other colour forms (`schemeClr`, `hslClr`, `scrgbClr`,
/// `prstClr`) are skipped silently — they require a deeper DML
/// colour evaluator that is out of scope for the scheme table.
///|
/// §19.3.1.6 / §19.3.1.7 — install the slide-master `<p:clrMap>`
/// and the optional `<p:clrMapOvr>/<a:overrideClrMapping>` into
/// the context.  These maps remap abstract slot names (`bg1`,
/// `tx1`, `accent1`, …) onto concrete scheme entries (`lt1`,
/// `dk1`, `accent1`, …) before `get_scheme_color` looks them up.
pub fn ColorResolveContext::with_maps(
  ctx : ColorResolveContext,
  color_map : ColorMap,
  color_map_override : ColorMap?,
) -> ColorResolveContext {
  {
    color_map,
    color_map_override,
    color_scheme: ctx.color_scheme,
    ph_clr: ctx.ph_clr,
    major_font: ctx.major_font,
    minor_font: ctx.minor_font,
  }
}

///|
pub fn ColorResolveContext::with_color_scheme(
  ctx : ColorResolveContext,
  color_scheme : ColorScheme,
) -> ColorResolveContext {
  {
    color_map: ctx.color_map,
    color_map_override: ctx.color_map_override,
    color_scheme,
    ph_clr: ctx.ph_clr,
    major_font: ctx.major_font,
    minor_font: ctx.minor_font,
  }
}

///|
/// Default scheme-color mapping per ECMA-376 §20.1.6.2.
/// Maps abstract colour names (tx1/bg1) → concrete scheme entries
/// (dk1/lt1).  Mirrors `DEFAULT_COLOR_MAPPING` referenced in
/// `color-resolver.ts:50`.
fn default_color_mapping() -> Map[String, String] {
  { "bg1": "lt1", "tx1": "dk1", "bg2": "lt2", "tx2": "dk2" }
}

///|
/// Which scheme-color names are mappable through the colour map.
fn is_mappable_scheme_color(name : String) -> Bool {
  name == "tx1" || name == "tx2" || name == "bg1" || name == "bg2"
}

///|
/// Resolve the effective scheme-color name through (slide override → master
/// map → default mapping).  Mirrors `resolveEffectiveSchemeColor` in
/// `color-resolver.ts:61`.
fn resolve_effective_scheme_color(
  name : String,
  ctx : ColorResolveContext,
) -> String {
  if !is_mappable_scheme_color(name) {
    return name
  }
  match ctx.color_map_override {
    Some(o) =>
      match o.get(name) {
        Some(v) => return v
        None => ()
      }
    None => ()
  }
  match ctx.color_map.get(name) {
    Some(v) => return v
    None => ()
  }
  match default_color_mapping().get(name) {
    Some(v) => v
    None => name
  }
}

///|
/// Look up a scheme colour and return its hex value (no `#`).
/// `ph_clr` substitutes for `phClr` per `getSchemeColor` in
/// `color-resolver.ts:96`. The TS code expects the input prefixed
/// with `a:` and strips two chars; we accept the bare name plus the
/// optional prefix for resilience.
pub fn get_scheme_color(
  scheme_clr : String,
  ph_clr : String?,
  ctx : ColorResolveContext,
) -> String? {
  let bare = if scheme_clr.length() >= 2 &&
    scheme_clr.code_unit_at(0) == 0x61 &&
    scheme_clr.code_unit_at(1) == 0x3A {
    // "a:..." prefix → drop it.
    scheme_clr.substring(start=2)
  } else {
    scheme_clr
  }
  if bare == "phClr" {
    return ph_clr
  }
  let effective = resolve_effective_scheme_color(bare, ctx)
  ctx.color_scheme.get(effective)
}

///|
/// Resolved DrawingML colour: the hex digits, an optional alpha in
/// [0, 1] and the original transform list (kept abstract because the
/// renderer applies them immediately).
pub struct ResolvedColor {
  /// Lowercase 6-digit hex without `#`.  Empty when resolution failed.
  hex : String
  /// Alpha in [0, 1].  1.0 when no `<a:alpha>` was present.
  alpha : Double
}

///|
/// `child_by_local` is an alias of `first_child_named` so the
/// color-resolver code reads close to the TS source (which uses
/// `getChild`).
fn child_by_local(parent : @xml.Element, name : String) -> @xml.Element? {
  first_child_named(parent, name)
}

///|
/// OOXML uses a 1/1000th-of-a-percent ("60000ths") scaling for many
/// numeric attributes.  Mirrors `OOXML_PERCENT_FACTOR` in
/// `ooxml-units.ts`.
let ooxml_percent_factor : Double = 100000.0

///|
/// §20.1.2.3.30 — convert a linear-RGB channel value in [0, 1]
/// to a gamma-encoded sRGB byte (returned as a Double so it
/// feeds `@color.rgb_to_hex` directly) using the IEC
/// 61966-2-1 transfer function.
fn scrgb_linear_to_srgb_byte(linear : Double) -> Double {
  let l = if linear < 0.0 {
    0.0
  } else if linear > 1.0 {
    1.0
  } else {
    linear
  }
  let encoded = if l <= 0.0031308 {
    l * 12.92
  } else {
    1.055 * l.pow(1.0 / 2.4) - 0.055
  }
  let byte = encoded * 255.0
  if byte < 0.0 {
    0.0
  } else if byte > 255.0 {
    255.0
  } else {
    byte
  }
}

///|
/// Parse a percentage value attribute.  Accepts both `"50%"` and the
/// raw `"50000"` (50000 / 100000 = 0.5).  Mirrors
/// `parsePercentageValue` in `color-resolver.ts:300`.
fn parse_pct(value : String) -> Double {
  let trimmed = value.trim_space().to_string()
  let dropped = if trimmed.length() > 0 &&
    trimmed.code_unit_at(trimmed.length() - 1) == 0x25 {
    trimmed.substring(start=0, end=trimmed.length() - 1)
  } else {
    trimmed
  }
  match (try? @strconv.parse_double(dropped)) {
    Ok(v) => v
    Err(_) => 0.0
  }
}

///|
/// Common pattern: read `<a:xyz val="...">` from `element`, parse as
/// percentage, divide by 100000.  Returns `None` when the child or
/// attribute is missing.
fn pct_child(element : @xml.Element, name : String) -> Double? {
  match child_by_local(element, name) {
    None => None
    Some(c) =>
      match attr_value(c, "val") {
        None => None
        Some(v) => Some(parse_pct(v) / ooxml_percent_factor)
      }
  }
}

///|
/// Read a single colour element and return the base hex (no
/// transforms applied yet).  Mirrors the per-extractor case work
/// in `COLOR_EXTRACTORS` (`color-resolver.ts:284`).
///
/// §20.1.10.41 ST_HexColorRGB defines the value as xsd:hexBinary,
/// which is **case-insensitive** per the XSD §3.2.15 lexical
/// space.  We normalise via `to_lower()` — ASCII-only is safe
/// because hex digits are 0-9 / A-F and the case-fold table for
/// those code points is identical between ASCII and Unicode.
fn extract_base_color(
  element : @xml.Element,
  ctx : ColorResolveContext,
  ph_clr : String?,
) -> String {
  match element.name.local_name {
    "srgbClr" =>
      match attr_value(element, "val") {
        Some(v) => v.to_lower()
        None => ""
      }
    "schemeClr" =>
      match attr_value(element, "val") {
        Some(v) =>
          match get_scheme_color(v, ph_clr, ctx) {
            Some(h) => h.to_lower()
            None => ""
          }
        None => ""
      }
    "scrgbClr" => {
      // §20.1.2.3.30 scrgbClr — the `@r`/`@g`/`@b` percentages
      // are LINEAR-RGB light, NOT gamma-encoded sRGB.  We must
      // run the IEC 61966-2-1 transfer function so a 50% channel
      // maps to ≈188 (sRGB), not 128.
      let r = attr_value(element, "r").unwrap_or("0")
      let g = attr_value(element, "g").unwrap_or("0")
      let b = attr_value(element, "b").unwrap_or("0")
      let to_byte = (s : String) => {
        let linear = parse_pct(s) / ooxml_percent_factor
        scrgb_linear_to_srgb_byte(linear)
      }
      @color.rgb_to_hex(to_byte(r), to_byte(g), to_byte(b))
    }
    "prstClr" =>
      match attr_value(element, "val") {
        Some(v) =>
          match @color.get_color_name_to_hex(v) {
            Some(h) => h
            None => ""
          }
        None => ""
      }
    "hslClr" => {
      let h = attr_value(element, "hue").unwrap_or("0")
      let s = attr_value(element, "sat").unwrap_or("0")
      let l = attr_value(element, "lum").unwrap_or("0")
      let hue = parse_pct(h) / 60000.0
      let sat = parse_pct(s) / ooxml_percent_factor
      let lum = parse_pct(l) / ooxml_percent_factor
      let rgb = @color.hsl_to_rgb(hue, sat, lum)
      @color.rgb_to_hex(rgb.r, rgb.g, rgb.b)
    }
    "sysClr" => {
      // §20.1.2.3.32 — `@lastClr` records the last-resolved RGB
      // so non-system viewers can still recover a concrete
      // colour without consulting the OS palette.  When the
      // attribute is absent we fall back to the `@val`
      // ST_SystemColorVal enumeration.  The spec lists 30
      // values; we honour the two with concrete W3C-defined
      // mappings (windowText / window) and surface the rest as
      // a CSS `system-color-*` token via `data-ooxml-syscolor`
      // metadata upstream.  Unknown values fall through to the
      // empty string so the caller decides whether to treat
      // the colour as `auto` (currentColor).
      match attr_value(element, "lastClr") {
        Some(v) => return v.to_lower()
        None => ()
      }
      match attr_value(element, "val") {
        // §20.1.10.58 ST_SystemColorVal — values with a
        // well-defined sRGB mapping.
        Some("windowText") => "000000"
        Some("window") => "ffffff"
        // Remaining ST_SystemColorVal members carry no
        // normative sRGB mapping in ECMA-376; the spec defers
        // to the consumer's OS palette.  Pass the raw value
        // through (lowercase) so consumers can act on the
        // CSS `appWorkspace`/`activeCaption`/… token directly.
        Some(v) => v.to_lower()
        None => ""
      }
    }
    // §20.1.2.3 EG_ColorChoice — closed-6 group:
    //   scrgbClr, srgbClr, hslClr, sysClr, schemeClr, prstClr.
    // Each is matched above.  Reaching this arm means the
    // caller handed us an element outside the spec group —
    // return "" so the colour cascade treats it as `auto`.
    _ => ""
  }
}

///|
/// Apply all DrawingML transforms (alpha → hueMod → lumMod → lumOff →
/// satMod → shade → tint) in the order that the TS reference applies
/// them.  Returns the final hex string and the resolved alpha.
fn apply_color_transforms(
  element : @xml.Element,
  base_hex : String,
) -> ResolvedColor {
  if base_hex == "" {
    return { hex: "", alpha: 1.0 }
  }
  // Alpha first, because subsequent transforms operate on hex that
  // already has the alpha byte appended.
  let alpha_pct = pct_child(element, "alpha")
  let (initial_hex, alpha, has_alpha) = match alpha_pct {
    None => (base_hex, 1.0, false)
    Some(a) => {
      let hsl = @color.parse_color_to_hsl(base_hex)
      let with_a = @color.hsl_to_hex_string(
        { h: hsl.h, s: hsl.s, l: hsl.l, a: Some(a) },
        true,
      )
      (with_a, a, true)
    }
  }
  let mut result = initial_hex
  match pct_child(element, "hueMod") {
    Some(v) => result = @color.apply_hue_mod(result, v, is_alpha=has_alpha)
    None => ()
  }
  match pct_child(element, "lumMod") {
    Some(v) => result = @color.apply_lum_mod(result, v, is_alpha=has_alpha)
    None => ()
  }
  match pct_child(element, "lumOff") {
    Some(v) => result = @color.apply_lum_off(result, v, is_alpha=has_alpha)
    None => ()
  }
  match pct_child(element, "satMod") {
    Some(v) => result = @color.apply_sat_mod(result, v, is_alpha=has_alpha)
    None => ()
  }
  match pct_child(element, "shade") {
    Some(v) => result = @color.apply_shade(result, v, is_alpha=has_alpha)
    None => ()
  }
  match pct_child(element, "tint") {
    Some(v) => result = @color.apply_tint(result, v, is_alpha=has_alpha)
    None => ()
  }
  { hex: result, alpha }
}

///|
/// Find the first §20.1.2.3 colour child element of `parent`.
/// The TS implementation iterates a fixed key list — we do the same
/// in MoonBit.  Returns the resolved element.
fn find_color_child(parent : @xml.Element) -> @xml.Element? {
  let keys = ["srgbClr", "schemeClr", "scrgbClr", "prstClr", "hslClr", "sysClr"]
  for k in keys {
    match child_by_local(parent, k) {
      Some(e) => return Some(e)
      None => ()
    }
  }
  None
}

///|
/// True iff `element` is itself one of the six DrawingML colour
/// element types.
fn is_color_element(element : @xml.Element) -> Bool {
  let name = element.name.local_name
  name == "srgbClr" ||
  name == "schemeClr" ||
  name == "scrgbClr" ||
  name == "prstClr" ||
  name == "hslClr" ||
  name == "sysClr"
}

///|
/// Resolve a colour-bearing element (e.g. `<a:solidFill>`, an `<a:rPr>`
/// containing `<a:solidFill>`, or a colour element directly) to a
/// `ResolvedColor`.  Mirrors `getSolidFill` in `color-resolver.ts:149`
/// — but extended so `node` may itself be a colour element, which is
/// the common case when the caller has already drilled down.
pub fn resolve_solid_fill(
  node : @xml.Element,
  ph_clr? : String? = None,
  ctx~ : ColorResolveContext,
) -> ResolvedColor? {
  // When the caller did not pass an explicit `phClr` override, fall
  // back to the context-level slot so theme-template fills resolved
  // through `<p:bgRef>` (or a similar inheritance carrier) inherit
  // the phClr substitution automatically.
  let effective_ph_clr = match ph_clr {
    Some(_) => ph_clr
    None => ctx.ph_clr
  }
  // If the node itself is a colour element, use it directly.
  if is_color_element(node) {
    let base = extract_base_color(node, ctx, effective_ph_clr)
    return Some(apply_color_transforms(node, base))
  }
  // Look through <a:solidFill> if present.
  let target = match child_by_local(node, "solidFill") {
    Some(sf) => sf
    None => node
  }
  let found = find_color_child(target)
  match found {
    None => None
    Some(elt) => {
      let base = extract_base_color(elt, ctx, effective_ph_clr)
      Some(apply_color_transforms(elt, base))
    }
  }
}

///|
/// Format a `ResolvedColor` as a CSS-style colour value.  When alpha
/// is 1.0 the output is `#hex`; otherwise it is `rgba(r, g, b, a)`.
pub fn format_resolved_color(rc : ResolvedColor) -> String {
  if rc.hex == "" {
    return "none"
  }
  if rc.alpha >= 1.0 {
    "#" + rc.hex
  } else {
    let rgb = @color.hex_to_rgb(rc.hex)
    "rgba(" +
    rgb.r.to_int().to_string() +
    ", " +
    rgb.g.to_int().to_string() +
    ", " +
    rgb.b.to_int().to_string() +
    ", " +
    rc.alpha.to_string() +
    ")"
  }
}
