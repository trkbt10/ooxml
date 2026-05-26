// @source web-pptx packages/@aurochs/color/src/convert.ts

///|
/// Clamp `n` into `[lo, hi]`.
fn clamp(n : Double, lo : Double, hi : Double) -> Double {
  if n < lo {
    lo
  } else if n > hi {
    hi
  } else {
    n
  }
}

///|
/// Floor-equivalent: round towards zero for non-negative values
/// (sufficient for our use because all colour-space inputs are
/// already in [0, 1]).
fn round_to_int(n : Double) -> Int {
  // `Math.round` in JS uses banker's rounding for .5, but the colour
  // helpers do not depend on that subtlety — use straightforward
  // round-half-up.
  let bounded = clamp(n, -2147483648.0, 2147483647.0)
  if bounded >= 0.0 {
    (bounded + 0.5).to_int()
  } else {
    -(-bounded + 0.5).to_int()
  }
}

///|
/// Convert an integer 0-255 to a two-character lowercase hex string.
/// Mirrors `toHex` in `convert.ts:33` (which also clamps and uses
/// `toString(16)` with zero-padding).
pub fn to_hex(n : Double) -> String {
  let v = clamp(n, 0.0, 255.0).to_int()
  let rounded = round_to_int(clamp(n, 0.0, 255.0))
  // Use rounded value (matches Math.round behavior in convert.ts).
  let _ = v
  let digits = "0123456789abcdef"
  let hi = rounded / 16 % 16
  let lo = rounded % 16
  // Build using ASCII offset
  let buf = StringBuilder::new()
  buf.write_char(digits.code_unit_at(hi).to_char().unwrap())
  buf.write_char(digits.code_unit_at(lo).to_char().unwrap())
  buf.to_string()
}

///|
/// Parse a single hex digit. Returns -1 for invalid input. (We use -1
/// as sentinel and treat parse errors as 0 at the call site to match
/// `parseInt(..., 16)` returning `NaN` and then `NaN >> ... === 0`.)
fn hex_digit(c : Char) -> Int {
  let code = c.to_int()
  if code >= 0x30 && code <= 0x39 {
    code - 0x30
  } else if code >= 0x41 && code <= 0x46 {
    code - 0x41 + 10
  } else if code >= 0x61 && code <= 0x66 {
    code - 0x61 + 10
  } else {
    -1
  }
}

///|
/// Parse an arbitrary-length hex string into an `Int64` (we use Int64
/// because 8-digit hex with alpha can exceed Int32). Invalid chars
/// terminate the scan, mirroring `parseInt(..., 16)`.
fn parse_hex(s : String) -> Int64 {
  let mut acc : Int64 = 0L
  for c in s {
    let d = hex_digit(c)
    if d < 0 {
      break
    }
    acc = acc * 16L + d.to_int64()
  }
  acc
}

///|
/// Strip a leading `#` if present.
fn strip_hash(s : String) -> String {
  if s.length() > 0 && s.code_unit_at(0) == 0x23 {
    s[1:].to_owned()
  } else {
    s
  }
}

///|
/// Convert a hex colour string to RGB.  Accepts 3-digit (#RGB),
/// 6-digit (#RRGGBB), and 8-digit (#RRGGBBAA) forms.  The 8-digit
/// form encodes alpha as the trailing byte — we strip it here so the
/// returned channels are the pure RGB triple (callers needing the
/// alpha go through `ResolvedColor` instead).  Mirrors `hexToRgb` in
/// `convert.ts:11`.
///
/// Previously the 8-digit path fed the entire 32-bit integer through
/// the same shift/mask used for `#RRGGBB`, which extracts bytes
/// `[GG, BB, AA]` instead of `[RR, GG, BB]`.  That made every alpha-
/// modified srgbClr render with the wrong colour (notably the venn
/// fixture — `4472c4` + alpha → `(0x72, 0xc4, 0x80)`).
pub fn hex_to_rgb(hex : String) -> RgbColor {
  let stripped = strip_hash(hex)
  // §20.1.2.3 alpha is stored separately in DrawingML, but our
  // intermediate `hsl_to_hex_string(..., true)` round-trip emits
  // 8-digit `#RRGGBBAA`.  Drop the trailing alpha pair so the parser
  // operates on the canonical 6-digit body.
  let clean = if stripped.length() == 8 {
    stripped[0:6].to_owned()
  } else {
    stripped
  }
  let n = parse_hex(clean).reinterpret_as_uint64()
  if clean.length() == 3 {
    let r = ((n >> 8) & 0xFUL).to_int() * 17
    let g = ((n >> 4) & 0xFUL).to_int() * 17
    let b = (n & 0xFUL).to_int() * 17
    { r: r.to_double(), g: g.to_double(), b: b.to_double() }
  } else {
    let r = ((n >> 16) & 0xFFUL).to_int()
    let g = ((n >> 8) & 0xFFUL).to_int()
    let b = (n & 0xFFUL).to_int()
    { r: r.to_double(), g: g.to_double(), b: b.to_double() }
  }
}

///|
/// Convert RGB to a 6-character lowercase hex string. Mirrors
/// `rgbToHex` in `convert.ts:41`.
pub fn rgb_to_hex(r : Double, g : Double, b : Double) -> String {
  to_hex(r) + to_hex(g) + to_hex(b)
}

///|
/// RGB → HSL conversion. Mirrors `rgbToHsl` in `convert.ts:48`.
/// Returns hue in degrees [0, 360), saturation/lightness in [0, 1].
pub fn rgb_to_hsl(r : Double, g : Double, b : Double) -> HslColor {
  let r_norm = r / 255.0
  let g_norm = g / 255.0
  let b_norm = b / 255.0
  let max = if r_norm >= g_norm && r_norm >= b_norm {
    r_norm
  } else if g_norm >= b_norm {
    g_norm
  } else {
    b_norm
  }
  let min = if r_norm <= g_norm && r_norm <= b_norm {
    r_norm
  } else if g_norm <= b_norm {
    g_norm
  } else {
    b_norm
  }
  let l = (max + min) / 2.0
  if max == min {
    return { h: 0.0, s: 0.0, l, a: None }
  }
  let d = max - min
  let s = if l > 0.5 { d / (2.0 - max - min) } else { d / (max + min) }
  let h_base = if max == r_norm {
    let bias = if g_norm < b_norm { 6.0 } else { 0.0 }
    ((g_norm - b_norm) / d + bias) / 6.0
  } else if max == g_norm {
    ((b_norm - r_norm) / d + 2.0) / 6.0
  } else {
    ((r_norm - g_norm) / d + 4.0) / 6.0
  }
  { h: h_base * 360.0, s, l, a: None }
}

///|
/// Helper for `hsl_to_rgb`.  Mirrors `hueToRgb` in `convert.ts:75`.
fn hue_to_rgb(t1 : Double, t2 : Double, hue : Double) -> Double {
  let h = if hue < 0.0 {
    hue + 6.0
  } else if hue >= 6.0 {
    hue - 6.0
  } else {
    hue
  }
  if h < 1.0 {
    (t2 - t1) * h + t1
  } else if h < 3.0 {
    t2
  } else if h < 4.0 {
    (t2 - t1) * (4.0 - h) + t1
  } else {
    t1
  }
}

///|
/// HSL → RGB. Mirrors `hslToRgb` in `convert.ts:92`.
pub fn hsl_to_rgb(hue : Double, sat : Double, light : Double) -> RgbColor {
  let h = hue / 60.0
  let t2 = if light <= 0.5 {
    light * (sat + 1.0)
  } else {
    light + sat - light * sat
  }
  let t1 = light * 2.0 - t2
  {
    r: hue_to_rgb(t1, t2, h + 2.0) * 255.0,
    g: hue_to_rgb(t1, t2, h) * 255.0,
    b: hue_to_rgb(t1, t2, h - 2.0) * 255.0,
  }
}

///|
/// Parse a hex colour string into HSL.  Mirrors `parseColorToHsl` in
/// `convert.ts:107`.
pub fn parse_color_to_hsl(color_str : String) -> HslColor {
  let clean = strip_hash(color_str)
  let rgb = hex_to_rgb(clean)
  rgb_to_hsl(rgb.r, rgb.g, rgb.b)
}

///|
/// Convert HSL back to a hex string, optionally appending alpha as a
/// 2-digit hex byte.  Mirrors `hslToHexString` in `convert.ts:116`.
pub fn hsl_to_hex_string(hsl : HslColor, include_alpha : Bool) -> String {
  let rgb = hsl_to_rgb(hsl.h, hsl.s, hsl.l)
  let hex = rgb_to_hex(rgb.r, rgb.g, rgb.b)
  if include_alpha {
    match hsl.a {
      Some(a) => hex + to_hex(a * 255.0)
      None => hex
    }
  } else {
    hex
  }
}
