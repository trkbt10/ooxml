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
/// Apply the DrawingML `shade` transform — multiply each RGB
/// component by `shade_value`.  Mirrors `applyShade` in
/// `transform.ts:20`.  `shade=1.0` is identity, `shade=0.0` is black.
///
/// @see ECMA-376 Part 1 §20.1.2.3.31 (a:shade)
pub fn apply_shade(
  rgb_str : String,
  shade_value : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let s = clamp01(shade_value)
  pack_hex(r * s, g * s, b * s, alpha_tail, is_alpha)
}

///|
/// Apply the DrawingML `tint` transform — move colour toward white.
/// Formula: `c' = c + (255 - c) * (1 - tint)`.  Mirrors `applyTint`
/// in `transform.ts:56`.  `tint=1.0` is identity, `tint=0.0` is white.
///
/// @see ECMA-376 Part 1 §20.1.2.3.34 (a:tint)
pub fn apply_tint(
  rgb_str : String,
  tint_value : Double,
  is_alpha? : Bool = false,
) -> String {
  let (r, g, b, alpha_tail) = split_hex_for_transform(rgb_str)
  let t = clamp01(tint_value)
  let new_r = r + (255.0 - r) * (1.0 - t)
  let new_g = g + (255.0 - g) * (1.0 - t)
  let new_b = b + (255.0 - b) * (1.0 - t)
  pack_hex(new_r, new_g, new_b, alpha_tail, is_alpha)
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
