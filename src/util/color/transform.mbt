// @source web-pptx packages/@aurochs/color/src/transform.ts
//
// DrawingML color transforms.  All transforms work on lowercase 6- or
// 8-digit hex strings (no `#`).  When `is_alpha` is true and the
// input is 8 chars long, the trailing alpha byte is preserved.

///|
/// Clamp a transform value to [0, 1].  Several callers do this
/// inline in the TS source; we centralise it here.
fn clamp01(v : Double) -> Double {
  if v < 0.0 {
    0.0
  } else if v > 1.0 {
    1.0
  } else {
    v
  }
}

///|
/// Hex string → (r, g, b, alpha-tail).  When the input is 8 chars,
/// returns the trailing 2 chars unchanged (still lowercase hex); when
/// shorter, returns an empty alpha string.
fn split_hex_for_transform(hex : String) -> (Double, Double, Double, String) {
  let clean = if hex.length() > 0 && hex.code_unit_at(0) == 0x23 {
    hex.substring(start=1)
  } else {
    hex
  }
  let r = parse_hex_byte(clean, 0)
  let g = parse_hex_byte(clean, 2)
  let b = parse_hex_byte(clean, 4)
  let alpha = if clean.length() >= 8 {
    clean.substring(start=6, end=8)
  } else {
    ""
  }
  (r, g, b, alpha)
}

///|
/// Read two hex characters at `offset` as an integer 0-255 and return
/// it as Double for downstream arithmetic.
fn parse_hex_byte(hex : String, offset : Int) -> Double {
  if offset + 1 >= hex.length() {
    return 0.0
  }
  let sub = hex.substring(start=offset, end=offset + 2)
  // Re-use the parser from convert.mbt — small loop, no big-int needed.
  let mut acc : Int = 0
  for c in sub {
    let code = c.to_int()
    let d = if code >= 0x30 && code <= 0x39 {
      code - 0x30
    } else if code >= 0x41 && code <= 0x46 {
      code - 0x41 + 10
    } else if code >= 0x61 && code <= 0x66 {
      code - 0x61 + 10
    } else {
      -1
    }
    if d < 0 {
      break
    }
    acc = acc * 16 + d
  }
  acc.to_double()
}

///|
/// Rebuild a hex string from the transformed RGB plus the original
/// alpha tail (if `is_alpha` and the alpha byte was captured).
fn pack_hex(
  r : Double,
  g : Double,
  b : Double,
  alpha_tail : String,
  is_alpha : Bool,
) -> String {
  let base = to_hex(r) + to_hex(g) + to_hex(b)
  if is_alpha && alpha_tail.length() == 2 {
    base + alpha_tail
  } else {
    base
  }
}

///|
/// IEC 61966-2-1 sRGB transfer function — decode an 8-bit gamma-
/// encoded sRGB channel (0..255) to its linear-light value in [0, 1].
/// This is the inverse of `linear_byte_to_srgb`.
fn srgb_byte_to_linear(byte : Double) -> Double {
  let c = byte / 255.0
  if c <= 0.04045 {
    c / 12.92
  } else {
    @math.pow((c + 0.055) / 1.055, 2.4)
  }
}

///|
/// IEC 61966-2-1 sRGB transfer function — encode a linear-light
/// channel in [0, 1] back to a gamma-encoded sRGB byte in [0, 255].
fn linear_to_srgb_byte(linear : Double) -> Double {
  let l = clamp01(linear)
  let encoded = if l <= 0.0031308 {
    l * 12.92
  } else {
    1.055 * @math.pow(l, 1.0 / 2.4) - 0.055
  }
  encoded * 255.0
}

///|
/// Apply the DrawingML `shade` transform — interpolate each RGB
/// component toward BLACK in linear-light (gamma-decoded) space, then
/// re-encode.  `shade=1.0` is identity, `shade=0.0` is full black.
///
/// LibreOffice (and PowerPoint) apply shade in linear RGB, not sRGB:
/// for `4472C4` (68, 114, 196) with `shade=0.5`, the rendered result
/// is approximately `(50, 84, 144)` rather than the sRGB-arithmetic
/// `(34, 57, 98)`.  Performing the multiplication in linear space
/// matches the reference renderer to within 1-3 byte values.
///
/// @see ECMA-376 Part 1 §20.1.2.3.31 (a:shade)
pub fn apply_shade(
  rgb_str : String,
  shade_value : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let s = clamp01(shade_value)
  let lr = srgb_byte_to_linear(r) * s
  let lg = srgb_byte_to_linear(g) * s
  let lb = srgb_byte_to_linear(b) * s
  pack_hex(
    linear_to_srgb_byte(lr),
    linear_to_srgb_byte(lg),
    linear_to_srgb_byte(lb),
    alpha_tail,
    is_alpha,
  )
}

///|
/// Apply the DrawingML `tint` transform — interpolate each RGB
/// component toward WHITE in linear-light (gamma-decoded) space, then
/// re-encode.  `tint=1.0` is identity, `tint=0.0` is full white.
///
/// Formula (per channel in linear light): `c' = c * tint + 1.0 * (1 - tint)`.
/// LibreOffice (and PowerPoint) apply tint in linear RGB, not sRGB.
/// For `4472C4` (68, 114, 196) with `tint=0.5`, the rendered result
/// is approximately `(192, 200, 227)` rather than the sRGB-arithmetic
/// `(162, 185, 226)`.  Performing the interpolation in linear space
/// matches the reference renderer to within 1 byte per channel.
///
/// @see ECMA-376 Part 1 §20.1.2.3.34 (a:tint)
pub fn apply_tint(
  rgb_str : String,
  tint_value : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let t = clamp01(tint_value)
  let one_minus_t = 1.0 - t
  let lr = srgb_byte_to_linear(r) * t + one_minus_t
  let lg = srgb_byte_to_linear(g) * t + one_minus_t
  let lb = srgb_byte_to_linear(b) * t + one_minus_t
  pack_hex(
    linear_to_srgb_byte(lr),
    linear_to_srgb_byte(lg),
    linear_to_srgb_byte(lb),
    alpha_tail,
    is_alpha,
  )
}

///|
/// Apply luminance offset: `L' = clamp(L + offset, 0, 1)`.  Mirrors
/// `applyLumOff` in `transform.ts:85`.
pub fn apply_lum_off(
  rgb_str : String,
  offset : Double,
  is_alpha? : Bool = false,
) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let new_l = clamp01(offset + color.l)
  hsl_to_hex_string({ h: color.h, s: color.s, l: new_l, a: color.a }, is_alpha)
}

///|
/// Apply luminance multiplier: `L' = clamp(L * multiplier, 0, 1)`.
/// Mirrors `applyLumMod` in `transform.ts:95`.
pub fn apply_lum_mod(
  rgb_str : String,
  multiplier : Double,
  is_alpha? : Bool = false,
) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let new_l = if color.l * multiplier > 1.0 {
    1.0
  } else {
    color.l * multiplier
  }
  hsl_to_hex_string({ h: color.h, s: color.s, l: new_l, a: color.a }, is_alpha)
}

///|
/// Apply hue multiplier with 360° wraparound.  Mirrors `applyHueMod`
/// in `transform.ts:105`.
pub fn apply_hue_mod(
  rgb_str : String,
  multiplier : Double,
  is_alpha? : Bool = false,
) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let scaled = color.h * multiplier
  let new_h = if scaled >= 360.0 { scaled - 360.0 } else { scaled }
  hsl_to_hex_string({ h: new_h, s: color.s, l: color.l, a: color.a }, is_alpha)
}

///|
/// Apply saturation multiplier (clamped at 1.0).  Mirrors
/// `applySatMod` in `transform.ts:115`.
pub fn apply_sat_mod(
  rgb_str : String,
  multiplier : Double,
  is_alpha? : Bool = false,
) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let new_s = if color.s * multiplier > 1.0 {
    1.0
  } else {
    color.s * multiplier
  }
  hsl_to_hex_string({ h: color.h, s: new_s, l: color.l, a: color.a }, is_alpha)
}

///|
/// §20.1.2.3.19 a:hueOff — additive hue offset in degrees.  The
/// caller is responsible for converting the OOXML 60000ths-of-a-
/// degree attribute into a degree value before invocation.
///
/// In spec mode (`lo_compat=false`) the hue is wrapped modulo 360°
/// so `h + degrees` re-enters the [0, 360) cycle exactly as the
/// ECMA-376 specification requires (`val` is `ST_Angle`, the only
/// documented bound is the implicit 60000ths-per-degree scale; no
/// clamping is mentioned).
///
/// In LO-compat mode (`lo_compat=true`) the sum `h + degrees` is
/// instead CLAMPED to `[0, 360]` before being fed back to the HSL
/// → RGB converter.  This mirrors LibreOffice's non-conforming
/// behaviour: for an input colour with hue ≈ 218° and offsets of
/// 0° / 72° / 144° / 216° / 288°, LO produces blue / purple /
/// red / red / red — i.e. every offset that would push the hue
/// past 360° saturates at the red end of the wheel instead of
/// wrapping back to yellow / green / cyan.  Reverse-engineered
/// empirically against LO 24.x rendering of
/// `.snapshots/fixtures/pptx/color/color-hueOff-ladder.pptx`;
/// LO's PDF export samples at exactly (196, 68, 68) for all three
/// over-180° swatches which is the canonical result of clamping
/// 218 + {144, 216, 288} to 360°.  This is an LO-side bug
/// relative to ECMA-376 §20.1.2.3.19 — keep `lo_compat=false`
/// for any caller that wants strict ECMA-376 compliance.
pub fn apply_hue_off(
  rgb_str : String,
  degrees : Double,
  is_alpha? : Bool = false,
  lo_compat? : Bool = false,
) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let shifted = color.h + degrees
  let h = if lo_compat {
    // LO non-conforming behaviour: clamp the post-offset hue into
    // [0, 360] instead of wrapping.  Values >= 360 collapse to 360
    // (≡ 0°), values < 0 collapse to 0°.
    if shifted < 0.0 {
      0.0
    } else if shifted > 360.0 {
      360.0
    } else {
      shifted
    }
  } else {
    // ECMA-376 spec behaviour: wrap to [0, 360).  Use a remainder
    // loop because the offset can be negative or arbitrarily large.
    let mut h = shifted
    while h < 0.0 {
      h = h + 360.0
    }
    while h >= 360.0 {
      h = h - 360.0
    }
    h
  }
  hsl_to_hex_string({ h, s: color.s, l: color.l, a: color.a }, is_alpha)
}

///|
/// §20.1.2.3.7 a:satOff — additive saturation offset in [-1, 1].
/// The caller pre-divides the OOXML 100000ths-of-a-percent value
/// so `off` arrives in the unit range.  Result is clamped to
/// [0, 1].
pub fn apply_sat_off(
  rgb_str : String,
  off : Double,
  is_alpha? : Bool = false,
) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let new_s = clamp01(color.s + off)
  hsl_to_hex_string({ h: color.h, s: new_s, l: color.l, a: color.a }, is_alpha)
}

///|
/// §20.1.2.3.5 a:comp — colour complement.  ECMA-376 defines the
/// complement as the colour 180° around the HSL hue circle with
/// the saturation and lightness preserved (i.e. the colour-wheel
/// complement, NOT a per-channel `1.0 - c` inversion — that is
/// `a:inv`).
pub fn apply_comp(rgb_str : String, is_alpha? : Bool = false) -> String {
  let color = parse_color_to_hsl(rgb_str)
  let shifted = color.h + 180.0
  let new_h = if shifted >= 360.0 { shifted - 360.0 } else { shifted }
  hsl_to_hex_string({ h: new_h, s: color.s, l: color.l, a: color.a }, is_alpha)
}

///|
/// §20.1.2.3.20 a:inv — per-channel inversion `c' = 1.0 - c`.
/// Performed in linear-light space so the operation is consistent
/// with the rest of DrawingML's colour maths (and matches the
/// way LibreOffice / PowerPoint apply the transform).
pub fn apply_inv(rgb_str : String, is_alpha? : Bool = false) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lr = 1.0 - srgb_byte_to_linear(r)
  let lg = 1.0 - srgb_byte_to_linear(g)
  let lb = 1.0 - srgb_byte_to_linear(b)
  pack_hex(
    linear_to_srgb_byte(lr),
    linear_to_srgb_byte(lg),
    linear_to_srgb_byte(lb),
    alpha_tail,
    is_alpha,
  )
}

///|
/// §20.1.2.3.17 a:gray — convert to grayscale via the Rec. 709
/// luma coefficients (Y' = 0.2126 R' + 0.7152 G' + 0.0722 B').
/// The coefficients are applied to the **linear-light** values
/// to remain consistent with the rest of the DrawingML colour
/// transforms, then the resulting luminance is re-encoded to
/// sRGB.  Rec. 709 is the appropriate choice for sRGB primaries
/// (Rec. 601's coefficients assume the older NTSC primaries).
pub fn apply_gray(rgb_str : String, is_alpha? : Bool = false) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lr = srgb_byte_to_linear(r)
  let lg = srgb_byte_to_linear(g)
  let lb = srgb_byte_to_linear(b)
  let y = 0.2126 * lr + 0.7152 * lg + 0.0722 * lb
  let byte = linear_to_srgb_byte(y)
  pack_hex(byte, byte, byte, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.26 a:red — overwrite the red channel with the given
/// linear-RGB value in [0, 1].  After replacement the new linear
/// channel is gamma-encoded back to sRGB.
pub fn apply_red(
  rgb_str : String,
  channel : Double,
  is_alpha? : Bool = false,
) -> String {
  let (_, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lr = clamp01(channel)
  pack_hex(linear_to_srgb_byte(lr), g, b, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.21 a:green — overwrite the green channel with the
/// given linear-RGB value in [0, 1].
pub fn apply_green(
  rgb_str : String,
  channel : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, _, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lg = clamp01(channel)
  pack_hex(r, linear_to_srgb_byte(lg), b, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.4 a:blue — overwrite the blue channel with the given
/// linear-RGB value in [0, 1].
pub fn apply_blue(
  rgb_str : String,
  channel : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, _, alpha_tail) = split_hex_for_transform(rgb_str)
  let lb = clamp01(channel)
  pack_hex(r, g, linear_to_srgb_byte(lb), alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.25 a:redMod — multiply the red channel (linear) by
/// the given factor; clamp to [0, 1].
pub fn apply_red_mod(
  rgb_str : String,
  multiplier : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lr = clamp01(srgb_byte_to_linear(r) * multiplier)
  pack_hex(linear_to_srgb_byte(lr), g, b, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.27 a:redOff — add the given offset to the linear red
/// channel; clamp to [0, 1].
pub fn apply_red_off(
  rgb_str : String,
  offset : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lr = clamp01(srgb_byte_to_linear(r) + offset)
  pack_hex(linear_to_srgb_byte(lr), g, b, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.22 a:greenMod — multiply the green channel (linear)
/// by the given factor; clamp to [0, 1].
pub fn apply_green_mod(
  rgb_str : String,
  multiplier : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lg = clamp01(srgb_byte_to_linear(g) * multiplier)
  pack_hex(r, linear_to_srgb_byte(lg), b, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.23 a:greenOff — add the given offset to the linear
/// green channel; clamp to [0, 1].
pub fn apply_green_off(
  rgb_str : String,
  offset : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lg = clamp01(srgb_byte_to_linear(g) + offset)
  pack_hex(r, linear_to_srgb_byte(lg), b, alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.2 a:blueMod — multiply the blue channel (linear) by
/// the given factor; clamp to [0, 1].
pub fn apply_blue_mod(
  rgb_str : String,
  multiplier : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lb = clamp01(srgb_byte_to_linear(b) * multiplier)
  pack_hex(r, g, linear_to_srgb_byte(lb), alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.3 a:blueOff — add the given offset to the linear
/// blue channel; clamp to [0, 1].
pub fn apply_blue_off(
  rgb_str : String,
  offset : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lb = clamp01(srgb_byte_to_linear(b) + offset)
  pack_hex(r, g, linear_to_srgb_byte(lb), alpha_tail, is_alpha)
}

///|
/// §20.1.2.3.16 a:gamma — apply the sRGB transfer function (i.e.
/// treat the stored RGB values as if they were linear and gamma-
/// encode them).  The transform interprets the input bytes as
/// values in [0, 1] (raw byte / 255) and re-encodes them through
/// the IEC 61966-2-1 transfer function.  Net effect: mid-tones
/// are lifted.
pub fn apply_gamma(rgb_str : String, is_alpha? : Bool = false) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  // Treat byte/255 as a linear value and gamma-encode.
  let lr = clamp01(r / 255.0)
  let lg = clamp01(g / 255.0)
  let lb = clamp01(b / 255.0)
  pack_hex(
    linear_to_srgb_byte(lr),
    linear_to_srgb_byte(lg),
    linear_to_srgb_byte(lb),
    alpha_tail,
    is_alpha,
  )
}

///|
/// §20.1.2.3.13 a:invGamma — inverse of `apply_gamma`.  Treats
/// the stored RGB values as gamma-encoded sRGB, decodes them to
/// linear light, then writes the linear values back into the
/// byte slots (so mid-tones are darkened).
pub fn apply_inv_gamma(rgb_str : String, is_alpha? : Bool = false) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let lr = srgb_byte_to_linear(r) * 255.0
  let lg = srgb_byte_to_linear(g) * 255.0
  let lb = srgb_byte_to_linear(b) * 255.0
  pack_hex(lr, lg, lb, alpha_tail, is_alpha)
}
