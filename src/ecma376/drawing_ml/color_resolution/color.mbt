///|
/// 8-bit-per-channel sRGB color with alpha. The result of applying a
/// §20.1.2.3 color reference and transform list.
pub(all) struct Rgba8 {
  r : Int
  g : Int
  b : Int
  a : Int
} derive(Eq, Debug)

///|
/// §20.1.6 ClrScheme named theme colors, indexed by ST_SchemeColorVal.
pub(all) struct ColorScheme {
  dk1 : Rgba8
  lt1 : Rgba8
  dk2 : Rgba8
  lt2 : Rgba8
  accent1 : Rgba8
  accent2 : Rgba8
  accent3 : Rgba8
  accent4 : Rgba8
  accent5 : Rgba8
  accent6 : Rgba8
  hlink : Rgba8
  fol_hlink : Rgba8
} derive(Eq, Debug)

///|
/// §20.1.2.3 color transform, applied in document order to a base RGBA color.
pub(all) enum ColorTransform {
  /// §20.1.2.3.34 tint lightens HSL luminance toward white.
  Tint(Int)
  /// §20.1.2.3.31 shade darkens HSL luminance toward black.
  Shade(Int)
  /// §20.1.2.3.20 lumMod multiplies HSL luminance.
  LumMod(Int)
  /// §20.1.2.3.21 lumOff offsets HSL luminance.
  LumOff(Int)
  /// §20.1.2.3.27 satMod multiplies HSL saturation.
  SatMod(Int)
  /// §20.1.2.3.14 hue assigns HSL hue.
  Hue(Int)
  /// §20.1.2.3.15 hueMod multiplies HSL hue.
  HueMod(Int)
  /// §20.1.2.3.16 hueOff offsets HSL hue.
  HueOff(Int)
  /// §20.1.2.3.1 alpha assigns opacity.
  Alpha(Int)
  /// §20.1.2.3.2 alphaMod multiplies opacity.
  AlphaMod(Int)
  /// §20.1.2.3.3 alphaOff offsets opacity.
  AlphaOff(Int)
  /// §20.1.2.3.8 gamma applies sRGB gamma expansion.
  Gamma
  /// §20.1.2.3.17 inv inverts RGB components.
  Inv
  /// §20.1.2.3.7 comp returns the RGB complement.
  Comp
  /// §20.1.2.3.9 gray converts RGB to relative-intensity grayscale.
  Gray
} derive(Eq, Debug)

///|
/// §20.1.2.3.29 schemeClr/@val discriminator for theme and placeholder colors.
pub(all) enum SchemeColorVal {
  Bg1
  Tx1
  Bg2
  Tx2
  Dk1
  Lt1
  Dk2
  Lt2
  Accent1
  Accent2
  Accent3
  Accent4
  Accent5
  Accent6
  Hlink
  FolHlink
  PhClr
} derive(Eq, Debug)

///|
/// §20.1.2.3 color reference before transforms.
pub(all) enum ColorRef {
  /// §20.1.2.3.32 srgbClr.
  Srgb(Rgba8)
  /// §20.1.2.3.29 schemeClr.
  Scheme(SchemeColorVal)
  /// §20.1.2.3.33 sysClr with resolved fallback color.
  Sys(String, Rgba8)
  /// §20.1.2.3.22 prstClr.
  Preset(String)
  /// §20.1.2.3.13 hslClr raw hue, saturation, luminance attributes.
  Hsl(Int, Int, Int)
  /// §20.1.2.3.30 scrgbClr — linear-RGB colour.  Stored as the
  /// already-gamma-encoded sRGB `Rgba8` so the resolver path is
  /// uniform with `Srgb`.
  ScRgb(Rgba8)
} derive(Eq, Debug)

///|
/// §20.1.2.3.29 resolves a color reference under a §20.1.6 theme color scheme,
/// then applies §20.1.2.3 transform children in order. `phClr` uses the
/// supplied placeholder color or raises SchemaViolation.
pub fn resolve_color(
  base : ColorRef,
  transforms : Array[ColorTransform],
  scheme : ColorScheme,
  placeholder_color : Rgba8?,
) -> Rgba8 raise @opc_errors.SchemaViolation {
  let mut color = match base {
    Srgb(value) => value
    ScRgb(value) => value
    Scheme(value) => scheme_color(value, scheme, placeholder_color)
    Sys(_, fallback) => fallback
    Preset(name) => preset_color(name)
    Hsl(hue, sat, lum) =>
      hsl_to_rgb(
        angle_units_to_turn(hue),
        percent_to_unit(sat),
        percent_to_unit(lum),
        255,
      )
  }
  for transform in transforms {
    color = apply_transform(color, transform)
  }
  color
}

///|
/// §20.1.2.3.32 parses srgbClr/@val as RRGGBB or RRGGBBAA, accepting upper or
/// lower case hexadecimal and rejecting any other lexical form.
pub fn parse_srgb_hex(
  value : String,
) -> Rgba8 raise @opc_errors.SchemaViolation {
  if value.length() != 6 && value.length() != 8 {
    schema_error("§20.1.2.3.32", "srgbClr/@val", "expected RRGGBB or RRGGBBAA")
  }
  for i in 0..<value.length() {
    hex_digit(value.code_unit_at(i), "srgbClr/@val") |> ignore
  }
  {
    r: hex_byte(value, 0),
    g: hex_byte(value, 2),
    b: hex_byte(value, 4),
    a: if value.length() == 8 {
      hex_byte(value, 6)
    } else {
      255
    },
  }
}

///|
/// §20.1.6 reads a CT_ColorScheme element with the 12 required named children,
/// each containing one §20.1.2.3 color reference. Transform children inside
/// scheme entries are applied against the partially read scheme-independent
/// base only; schemeClr/phClr inside clrScheme entries are rejected to avoid
/// recursive theme definitions.
pub fn read_color_scheme(
  element : @xml.Element,
) -> ColorScheme raise @opc_errors.SchemaViolation {
  require_local(element, "clrScheme", "§20.1.6", "clrScheme")
  {
    dk1: read_scheme_entry(element, "dk1"),
    lt1: read_scheme_entry(element, "lt1"),
    dk2: read_scheme_entry(element, "dk2"),
    lt2: read_scheme_entry(element, "lt2"),
    accent1: read_scheme_entry(element, "accent1"),
    accent2: read_scheme_entry(element, "accent2"),
    accent3: read_scheme_entry(element, "accent3"),
    accent4: read_scheme_entry(element, "accent4"),
    accent5: read_scheme_entry(element, "accent5"),
    accent6: read_scheme_entry(element, "accent6"),
    hlink: read_scheme_entry(element, "hlink"),
    fol_hlink: read_scheme_entry(element, "folHlink"),
  }
}

///|
/// §20.1.2.3 reads a srgbClr, schemeClr, sysClr, prstClr, or hslClr element and
/// returns its base color reference plus ordered transform list.
pub fn read_color_ref(
  element : @xml.Element,
) -> (ColorRef, Array[ColorTransform]) raise @opc_errors.SchemaViolation {
  let base = match element.name.local_name {
    "srgbClr" => Srgb(parse_srgb_hex(required_attr(element, "val")))
    // §20.1.2.3.30 scrgbClr — three linear-RGB percentage
    // channels (`@r`/`@g`/`@b`).  Gamma-encode to sRGB so the
    // result is comparable with srgbClr values.
    "scrgbClr" =>
      ScRgb(
        rgba(
          linear_unit_to_srgb_byte(
            percent_to_unit(
              parse_percentage_attr(element, "r", "§20.1.2.3.30"),
            ),
          ),
          linear_unit_to_srgb_byte(
            percent_to_unit(
              parse_percentage_attr(element, "g", "§20.1.2.3.30"),
            ),
          ),
          linear_unit_to_srgb_byte(
            percent_to_unit(
              parse_percentage_attr(element, "b", "§20.1.2.3.30"),
            ),
          ),
          255,
        ),
      )
    "schemeClr" => Scheme(parse_scheme_color(required_attr(element, "val")))
    "sysClr" =>
      Sys(
        required_attr(element, "val"),
        parse_srgb_hex(optional_attr(element, "lastClr").unwrap_or("000000")),
      )
    "prstClr" => Preset(required_attr(element, "val"))
    "hslClr" =>
      Hsl(
        parse_int_attr(element, "hue", "§20.1.2.3.13"),
        parse_percentage_attr(element, "sat", "§20.1.2.3.13"),
        parse_percentage_attr(element, "lum", "§20.1.2.3.13"),
      )
    name =>
      schema_error(
        "§20.1.2.3", name, "expected srgbClr, scrgbClr, schemeClr, sysClr, prstClr, or hslClr",
      )
  }
  (base, read_transforms(element))
}

///|
/// §20.1.2.3.22 maps DrawingML preset color names to RGBA. This implementation
/// covers the HTML4/SVG/CSS named colors plus OOXML short aliases used by
/// ST_PresetColorVal, including transparent alpha.
pub fn preset_color(name : String) -> Rgba8 raise @opc_errors.SchemaViolation {
  match name {
    "transparent" => rgba(0, 0, 0, 0)
    "black" => rgba(0, 0, 0, 255)
    "silver" => rgba(192, 192, 192, 255)
    "gray" | "grey" => rgba(128, 128, 128, 255)
    "white" => rgba(255, 255, 255, 255)
    "maroon" => rgba(128, 0, 0, 255)
    "red" => rgba(255, 0, 0, 255)
    "purple" => rgba(128, 0, 128, 255)
    "fuchsia" | "magenta" => rgba(255, 0, 255, 255)
    "green" => rgba(0, 128, 0, 255)
    "lime" => rgba(0, 255, 0, 255)
    "olive" => rgba(128, 128, 0, 255)
    "yellow" => rgba(255, 255, 0, 255)
    "navy" => rgba(0, 0, 128, 255)
    "blue" => rgba(0, 0, 255, 255)
    "teal" => rgba(0, 128, 128, 255)
    "aqua" | "cyan" => rgba(0, 255, 255, 255)
    _ => preset_color_svg(name)
  }
}

///|
fn apply_transform(c : Rgba8, transform : ColorTransform) -> Rgba8 {
  match transform {
    Tint(v) =>
      map_lum(c, fn(l) { l * (1.0 - percent_to_unit(v)) + percent_to_unit(v) })
    Shade(v) | LumMod(v) => map_lum(c, fn(l) { l * percent_to_unit(v) })
    LumOff(v) => map_lum(c, fn(l) { clamp_unit(l + percent_to_unit(v)) })
    SatMod(v) => map_sat(c, fn(s) { s * percent_to_unit(v) })
    Hue(v) => map_hue(c, fn(_) { angle_units_to_turn(v) })
    HueMod(v) => map_hue(c, fn(h) { normalize_turn(h * percent_to_unit(v)) })
    HueOff(v) =>
      map_hue(c, fn(h) { normalize_turn(h + angle_units_to_turn(v)) })
    Alpha(v) => { r: c.r, g: c.g, b: c.b, a: percent_to_byte(v) }
    AlphaMod(v) =>
      {
        r: c.r,
        g: c.g,
        b: c.b,
        a: clamp_byte((c.a.to_double() * percent_to_unit(v)).round().to_int()),
      }
    AlphaOff(v) =>
      {
        r: c.r,
        g: c.g,
        b: c.b,
        a: percent_unit_to_byte(c.a.to_double() / 255.0 + percent_to_unit(v)),
      }
    Gamma => gamma_color(c)
    Inv | Comp => { r: 255 - c.r, g: 255 - c.g, b: 255 - c.b, a: c.a }
    Gray => {
      let y = clamp_byte(
        (c.r.to_double() * 0.2126 +
        c.g.to_double() * 0.7152 +
        c.b.to_double() * 0.0722)
        .round()
        .to_int(),
      )
      { r: y, g: y, b: y, a: c.a }
    }
  }
}

///|
fn map_lum(c : Rgba8, f : (Double) -> Double) -> Rgba8 {
  let (h, s, l) = rgb_to_hsl(c)
  hsl_to_rgb(h, s, clamp_unit(f(l)), c.a)
}

///|
fn map_sat(c : Rgba8, f : (Double) -> Double) -> Rgba8 {
  let (h, s, l) = rgb_to_hsl(c)
  hsl_to_rgb(h, clamp_unit(f(s)), l, c.a)
}

///|
fn map_hue(c : Rgba8, f : (Double) -> Double) -> Rgba8 {
  let (h, s, l) = rgb_to_hsl(c)
  hsl_to_rgb(normalize_turn(f(h)), s, l, c.a)
}

///|
fn gamma_color(c : Rgba8) -> Rgba8 {
  {
    r: gamma_component(c.r),
    g: gamma_component(c.g),
    b: gamma_component(c.b),
    a: c.a,
  }
}

///|
fn gamma_component(v : Int) -> Int {
  percent_unit_to_byte(@math.pow(v.to_double() / 255.0, 1.0 / 2.2))
}

///|
fn scheme_color(
  value : SchemeColorVal,
  scheme : ColorScheme,
  placeholder_color : Rgba8?,
) -> Rgba8 raise @opc_errors.SchemaViolation {
  match value {
    Bg1 | Lt1 => scheme.lt1
    Tx1 | Dk1 => scheme.dk1
    Bg2 | Lt2 => scheme.lt2
    Tx2 | Dk2 => scheme.dk2
    Accent1 => scheme.accent1
    Accent2 => scheme.accent2
    Accent3 => scheme.accent3
    Accent4 => scheme.accent4
    Accent5 => scheme.accent5
    Accent6 => scheme.accent6
    Hlink => scheme.hlink
    FolHlink => scheme.fol_hlink
    PhClr =>
      match placeholder_color {
        Some(color) => color
        None =>
          schema_error(
            "§20.1.2.3.29", "schemeClr/@val=phClr", "placeholder color required",
          )
      }
  }
}

///|
fn read_scheme_entry(
  scheme : @xml.Element,
  local_name : String,
) -> Rgba8 raise @opc_errors.SchemaViolation {
  let container = required_child(scheme, local_name, "§20.1.6")
  let color_element = single_element_child(container, "§20.1.6", local_name)
  let (base, transforms) = read_color_ref(color_element)
  match base {
    Scheme(_) =>
      schema_error(
        "§20.1.6", local_name, "clrScheme entry cannot be a recursive schemeClr",
      )
    _ => resolve_color(base, transforms, zero_scheme(), None)
  }
}

///|
fn zero_scheme() -> ColorScheme {
  let z = rgba(0, 0, 0, 255)
  {
    dk1: z,
    lt1: z,
    dk2: z,
    lt2: z,
    accent1: z,
    accent2: z,
    accent3: z,
    accent4: z,
    accent5: z,
    accent6: z,
    hlink: z,
    fol_hlink: z,
  }
}

///|
fn read_transforms(
  element : @xml.Element,
) -> Array[ColorTransform] raise @opc_errors.SchemaViolation {
  let transforms : Array[ColorTransform] = []
  for child in element.children {
    if child is @xml.Node::Element(e) {
      transforms.push(read_transform(e))
    }
  }
  transforms
}

///|
fn read_transform(
  element : @xml.Element,
) -> ColorTransform raise @opc_errors.SchemaViolation {
  match element.name.local_name {
    "tint" => Tint(transform_percentage(element, "§20.1.2.3.34"))
    "shade" => Shade(transform_percentage(element, "§20.1.2.3.31"))
    "lumMod" => LumMod(transform_percentage(element, "§20.1.2.3.20"))
    "lumOff" => LumOff(transform_percentage(element, "§20.1.2.3.21"))
    "satMod" => SatMod(transform_percentage(element, "§20.1.2.3.27"))
    "hue" => Hue(parse_int_attr(element, "val", "§20.1.2.3.14"))
    "hueMod" => HueMod(transform_percentage(element, "§20.1.2.3.15"))
    "hueOff" => HueOff(parse_int_attr(element, "val", "§20.1.2.3.16"))
    "alpha" => Alpha(transform_percentage(element, "§20.1.2.3.1"))
    "alphaMod" => AlphaMod(transform_percentage(element, "§20.1.2.3.2"))
    "alphaOff" => AlphaOff(transform_percentage(element, "§20.1.2.3.3"))
    "gamma" => Gamma
    "inv" => Inv
    "comp" => Comp
    "gray" => Gray
    name =>
      schema_error(
        "§20.1.2.3", name, "unsupported color transform in color_resolution API",
      )
  }
}

///|
fn transform_percentage(
  element : @xml.Element,
  section : String,
) -> Int raise @opc_errors.SchemaViolation {
  parse_percentage_attr(element, "val", section)
}

///|
fn parse_scheme_color(
  value : String,
) -> SchemeColorVal raise @opc_errors.SchemaViolation {
  match value {
    "bg1" => Bg1
    "tx1" => Tx1
    "bg2" => Bg2
    "tx2" => Tx2
    "dk1" => Dk1
    "lt1" => Lt1
    "dk2" => Dk2
    "lt2" => Lt2
    "accent1" => Accent1
    "accent2" => Accent2
    "accent3" => Accent3
    "accent4" => Accent4
    "accent5" => Accent5
    "accent6" => Accent6
    "hlink" => Hlink
    "folHlink" => FolHlink
    "phClr" => PhClr
    _ => schema_error("§20.1.2.3.29", "schemeClr/@val", "unknown scheme color")
  }
}

///|
/// Convert an sRGB color to the HSL coordinate system used by
/// §20.1.2.3 color transforms and §20.1.8 image effects.
pub fn rgb_to_hsl(c : Rgba8) -> (Double, Double, Double) {
  let r = c.r.to_double() / 255.0
  let g = c.g.to_double() / 255.0
  let b = c.b.to_double() / 255.0
  let maxc = max_double(r, max_double(g, b))
  let minc = min_double(r, min_double(g, b))
  let l = (maxc + minc) / 2.0
  if maxc.is_close(minc, absolute_tolerance=0.0000000001) {
    (0.0, 0.0, l)
  } else {
    let d = maxc - minc
    let s = if l > 0.5 { d / (2.0 - maxc - minc) } else { d / (maxc + minc) }
    let h = if maxc == r {
      let add = if g < b { 1.0 } else { 0.0 }
      normalize_turn((g - b) / d / 6.0 + add)
    } else if maxc == g {
      ((b - r) / d + 2.0) / 6.0
    } else {
      ((r - g) / d + 4.0) / 6.0
    }
    (h, s, l)
  }
}

///|
/// Convert an HSL coordinate back to sRGB using the same rounding and
/// clamping as §20.1.2.3 color resolution. `h` is a turn in 0..1.
pub fn hsl_to_rgb(h : Double, s : Double, l : Double, a : Int) -> Rgba8 {
  let h = normalize_turn(h)
  let s = clamp_unit(s)
  let l = clamp_unit(l)
  if s.is_close(0.0, absolute_tolerance=0.0000000001) {
    let v = percent_unit_to_byte(l)
    { r: v, g: v, b: v, a }
  } else {
    let q = if l < 0.5 { l * (1.0 + s) } else { l + s - l * s }
    let p = 2.0 * l - q
    {
      r: percent_unit_to_byte(hue_to_rgb(p, q, h + 1.0 / 3.0)),
      g: percent_unit_to_byte(hue_to_rgb(p, q, h)),
      b: percent_unit_to_byte(hue_to_rgb(p, q, h - 1.0 / 3.0)),
      a,
    }
  }
}

///|
fn hue_to_rgb(p : Double, q : Double, t0 : Double) -> Double {
  let mut t = t0
  if t < 0.0 {
    t = t + 1.0
  }
  if t > 1.0 {
    t = t - 1.0
  }
  if t < 1.0 / 6.0 {
    p + (q - p) * 6.0 * t
  } else if t < 1.0 / 2.0 {
    q
  } else if t < 2.0 / 3.0 {
    p + (q - p) * (2.0 / 3.0 - t) * 6.0
  } else {
    p
  }
}

///|
fn preset_color_svg(name : String) -> Rgba8 raise @opc_errors.SchemaViolation {
  match name {
    "aliceBlue" => hex("F0F8FF")
    "antiqueWhite" => hex("FAEBD7")
    "aquamarine" => hex("7FFFD4")
    "azure" => hex("F0FFFF")
    "beige" => hex("F5F5DC")
    "bisque" => hex("FFE4C4")
    "blanchedAlmond" => hex("FFEBCD")
    "blueViolet" => hex("8A2BE2")
    "brown" => hex("A52A2A")
    "burlyWood" => hex("DEB887")
    "cadetBlue" => hex("5F9EA0")
    "chartreuse" => hex("7FFF00")
    "chocolate" => hex("D2691E")
    "coral" => hex("FF7F50")
    "cornflowerBlue" => hex("6495ED")
    "cornsilk" => hex("FFF8DC")
    "crimson" => hex("DC143C")
    "darkBlue" | "dkBlue" => hex("00008B")
    "darkCyan" | "dkCyan" => hex("008B8B")
    "darkGoldenrod" | "dkGoldenrod" => hex("B8860B")
    "darkGray" | "darkGrey" | "dkGray" | "dkGrey" => hex("A9A9A9")
    "darkGreen" | "dkGreen" => hex("006400")
    "darkKhaki" | "dkKhaki" => hex("BDB76B")
    "darkMagenta" | "dkMagenta" => hex("8B008B")
    "darkOliveGreen" | "dkOliveGreen" => hex("556B2F")
    "darkOrange" | "dkOrange" => hex("FF8C00")
    "darkOrchid" | "dkOrchid" => hex("9932CC")
    "darkRed" | "dkRed" => hex("8B0000")
    "darkSalmon" | "dkSalmon" => hex("E9967A")
    "darkSeaGreen" | "dkSeaGreen" => hex("8FBC8F")
    "darkSlateBlue" | "dkSlateBlue" => hex("483D8B")
    "darkSlateGray" | "darkSlateGrey" | "dkSlateGray" | "dkSlateGrey" =>
      hex("2F4F4F")
    "darkTurquoise" | "dkTurquoise" => hex("00CED1")
    "darkViolet" | "dkViolet" => hex("9400D3")
    "deepPink" => hex("FF1493")
    "deepSkyBlue" => hex("00BFFF")
    "dimGray" | "dimGrey" => hex("696969")
    "dodgerBlue" => hex("1E90FF")
    "firebrick" => hex("B22222")
    "floralWhite" => hex("FFFAF0")
    "forestGreen" => hex("228B22")
    "gainsboro" => hex("DCDCDC")
    "ghostWhite" => hex("F8F8FF")
    "gold" => hex("FFD700")
    "goldenrod" => hex("DAA520")
    "greenYellow" => hex("ADFF2F")
    "honeydew" => hex("F0FFF0")
    "hotPink" => hex("FF69B4")
    "indianRed" => hex("CD5C5C")
    "indigo" => hex("4B0082")
    "ivory" => hex("FFFFF0")
    "khaki" => hex("F0E68C")
    "lavender" => hex("E6E6FA")
    "lavenderBlush" => hex("FFF0F5")
    "lawnGreen" => hex("7CFC00")
    "lemonChiffon" => hex("FFFACD")
    "lightBlue" | "ltBlue" => hex("ADD8E6")
    "lightCoral" | "ltCoral" => hex("F08080")
    "lightCyan" | "ltCyan" => hex("E0FFFF")
    "lightGoldenrodYellow" | "ltGoldenrodYellow" => hex("FAFAD2")
    "lightGray" | "lightGrey" | "ltGray" | "ltGrey" => hex("D3D3D3")
    "lightGreen" | "ltGreen" => hex("90EE90")
    "lightPink" | "ltPink" => hex("FFB6C1")
    "lightSalmon" | "ltSalmon" => hex("FFA07A")
    "lightSeaGreen" | "ltSeaGreen" => hex("20B2AA")
    "lightSkyBlue" | "ltSkyBlue" => hex("87CEFA")
    "lightSlateGray" | "lightSlateGrey" | "ltSlateGray" | "ltSlateGrey" =>
      hex("778899")
    "lightSteelBlue" | "ltSteelBlue" => hex("B0C4DE")
    "lightYellow" | "ltYellow" => hex("FFFFE0")
    "limeGreen" => hex("32CD32")
    "linen" => hex("FAF0E6")
    "medAquamarine" | "mediumAquamarine" => hex("66CDAA")
    "medBlue" | "mediumBlue" => hex("0000CD")
    "medOrchid" | "mediumOrchid" => hex("BA55D3")
    "medPurple" | "mediumPurple" => hex("9370DB")
    "medSeaGreen" | "mediumSeaGreen" => hex("3CB371")
    "medSlateBlue" | "mediumSlateBlue" => hex("7B68EE")
    "medSpringGreen" | "mediumSpringGreen" => hex("00FA9A")
    "medTurquoise" | "mediumTurquoise" => hex("48D1CC")
    "medVioletRed" | "mediumVioletRed" => hex("C71585")
    "midnightBlue" => hex("191970")
    "mintCream" => hex("F5FFFA")
    "mistyRose" => hex("FFE4E1")
    "moccasin" => hex("FFE4B5")
    "navajoWhite" => hex("FFDEAD")
    "oldLace" => hex("FDF5E6")
    "oliveDrab" => hex("6B8E23")
    "orange" => hex("FFA500")
    "orangeRed" => hex("FF4500")
    "orchid" => hex("DA70D6")
    "paleGoldenrod" => hex("EEE8AA")
    "paleGreen" => hex("98FB98")
    "paleTurquoise" => hex("AFEEEE")
    "paleVioletRed" => hex("DB7093")
    "papayaWhip" => hex("FFEFD5")
    "peachPuff" => hex("FFDAB9")
    "peru" => hex("CD853F")
    "pink" => hex("FFC0CB")
    "plum" => hex("DDA0DD")
    "powderBlue" => hex("B0E0E6")
    "rosyBrown" => hex("BC8F8F")
    "royalBlue" => hex("4169E1")
    "saddleBrown" => hex("8B4513")
    "salmon" => hex("FA8072")
    "sandyBrown" => hex("F4A460")
    "seaGreen" => hex("2E8B57")
    "seaShell" => hex("FFF5EE")
    "sienna" => hex("A0522D")
    "skyBlue" => hex("87CEEB")
    "slateBlue" => hex("6A5ACD")
    "slateGray" | "slateGrey" => hex("708090")
    "snow" => hex("FFFAFA")
    "springGreen" => hex("00FF7F")
    "steelBlue" => hex("4682B4")
    "tan" => hex("D2B48C")
    "thistle" => hex("D8BFD8")
    "tomato" => hex("FF6347")
    "turquoise" => hex("40E0D0")
    "violet" => hex("EE82EE")
    "wheat" => hex("F5DEB3")
    "whiteSmoke" => hex("F5F5F5")
    "yellowGreen" => hex("9ACD32")
    _ => schema_error("§20.1.2.3.22", "prstClr/@val", "unknown preset color")
  }
}

///|
fn hex(value : String) -> Rgba8 raise @opc_errors.SchemaViolation {
  parse_srgb_hex(value)
}

///|
fn rgba(r : Int, g : Int, b : Int, a : Int) -> Rgba8 {
  { r, g, b, a }
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
fn single_element_child(
  element : @xml.Element,
  section : String,
  path : String,
) -> @xml.Element raise @opc_errors.SchemaViolation {
  let mut found : @xml.Element? = None
  for child in element.children {
    if child is @xml.Node::Element(e) {
      if found is Some(_) {
        schema_error(section, path, "expected exactly one child color element")
      }
      found = Some(e)
    }
  }
  match found {
    Some(e) => e
    None => schema_error(section, path, "expected child color element")
  }
}

///|
fn required_attr(
  element : @xml.Element,
  local_name : String,
) -> String raise @opc_errors.SchemaViolation {
  match optional_attr(element, local_name) {
    Some(value) => value
    None =>
      schema_error(
        "§20.1.2.3",
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
fn parse_int_attr(
  element : @xml.Element,
  attr : String,
  section : String,
) -> Int raise @opc_errors.SchemaViolation {
  parse_int(
    required_attr(element, attr),
    section,
    element.name.local_name + "/@" + attr,
  )
}

///|
fn parse_percentage_attr(
  element : @xml.Element,
  attr : String,
  section : String,
) -> Int raise @opc_errors.SchemaViolation {
  parse_percentage(
    required_attr(element, attr),
    section,
    element.name.local_name + "/@" + attr,
  )
}

///|
fn parse_percentage(
  value : String,
  section : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  if value.length() == 0 {
    schema_error(section, path, "empty percentage")
  }
  if value.code_unit_at(value.length() - 1) == '%' {
    parse_percent_string(value, section, path)
  } else {
    parse_int(value, section, path)
  }
}

///|
fn parse_percent_string(
  value : String,
  section : String,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  let body = value.unsafe_substring(start=0, end=value.length() - 1)
  let raw = parse_int(body, section, path)
  raw * 1000
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
fn hex_byte(
  value : String,
  offset : Int,
) -> Int raise @opc_errors.SchemaViolation {
  hex_digit(value.code_unit_at(offset), "hex") * 16 +
  hex_digit(value.code_unit_at(offset + 1), "hex")
}

///|
fn hex_digit(
  ch : UInt16,
  path : String,
) -> Int raise @opc_errors.SchemaViolation {
  if ch >= '0' && ch <= '9' {
    ch.to_int() - '0'.to_int()
  } else if ch >= 'a' && ch <= 'f' {
    ch.to_int() - 'a'.to_int() + 10
  } else if ch >= 'A' && ch <= 'F' {
    ch.to_int() - 'A'.to_int() + 10
  } else {
    schema_error("§20.1.2.3.32", path, "invalid hexadecimal digit")
  }
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  section : String,
  path : String,
) -> Unit raise @opc_errors.SchemaViolation {
  if element.name.local_name != local_name {
    schema_error(section, path, "unexpected element " + element.name.local_name)
  }
}

///|
fn percent_to_unit(value : Int) -> Double {
  value.to_double() / 100000.0
}

///|
/// §20.1.2.3.30 — convert a linear-RGB channel value in [0, 1]
/// to a gamma-encoded sRGB byte [0, 255] using the IEC
/// 61966-2-1 transfer function.  scRGB stores LINEAR light, so
/// a 50% channel maps to ≈188 (not 128) once gamma-encoded.
fn linear_unit_to_srgb_byte(linear : Double) -> Int {
  // Clamp to the displayable [0, 1] range first.
  let l = if linear < 0.0 { 0.0 } else if linear > 1.0 { 1.0 } else { linear }
  // IEC 61966-2-1 piecewise transfer function.
  let encoded = if l <= 0.0031308 {
    l * 12.92
  } else {
    1.055 * @math.pow(l, 1.0 / 2.4) - 0.055
  }
  let byte = (encoded * 255.0).round().to_int()
  if byte < 0 {
    0
  } else if byte > 255 {
    255
  } else {
    byte
  }
}

///|
fn percent_to_byte(value : Int) -> Int {
  percent_unit_to_byte(percent_to_unit(value))
}

///|
fn percent_unit_to_byte(value : Double) -> Int {
  clamp_byte((clamp_unit(value) * 255.0).round().to_int())
}

///|
fn angle_units_to_turn(value : Int) -> Double {
  normalize_turn(value.to_double() / 21600000.0)
}

///|
fn normalize_turn(value : Double) -> Double {
  let mut out = value
  while out < 0.0 {
    out = out + 1.0
  }
  while out >= 1.0 {
    out = out - 1.0
  }
  out
}

///|
fn clamp_unit(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
fn clamp_byte(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 255 {
    255
  } else {
    value
  }
}

///|
fn min_double(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn max_double(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn[T] schema_error(
  section : String,
  path : String,
  reason : String,
) -> T raise @opc_errors.SchemaViolation {
  raise @opc_errors.SchemaViolation(section~, path~, reason~)
}
