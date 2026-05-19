// TODO(consolidate): The HSL conversion routines below duplicate
// `color_resolution`'s private rgb_to_hsl / hsl_to_rgb. When a future
// refactor exposes them publicly (or moves them into a shared color
// helpers package), drop these duplicates and depend on the upstream
// implementation.

///|
/// §20.1.8.60 tint amount/hue. `amt` and `hue` use §20.1.10.24 fixed
/// percentages (-100000..100000) and §20.1.10.44 angle units (0..21600000).
/// Positive `amt` shifts the existing hue toward the target hue;
/// negative `amt` shifts it away. Saturation and luminance are preserved.
pub fn apply_tint(source : @color.Rgba8, amt : Int, hue : Int) -> @color.Rgba8 {
  let (h, s, l) = rgb_to_hsl(source)
  let target = angle_units_to_turn(hue)
  let weight = clamp_unit(percent_to_unit(abs_int(amt)))
  let shifted = if amt >= 0 {
    lerp_hue(h, target, weight)
  } else {
    lerp_hue(h, opposite_hue(target), weight)
  }
  hsl_to_rgb(shifted, s, l, source.a)
}

///|
/// §20.1.8.42 luminance brightness + contrast. `bright` shifts L by an
/// additive fraction; `contrast` scales (L - 0.5) by (1 + contrast/100000).
pub fn apply_lum(
  source : @color.Rgba8,
  bright : Int,
  contrast : Int,
) -> @color.Rgba8 {
  let (h, s, l) = rgb_to_hsl(source)
  let with_contrast = (l - 0.5) * (1.0 + percent_to_unit(contrast)) + 0.5
  let with_bright = with_contrast + percent_to_unit(bright)
  hsl_to_rgb(h, s, clamp_unit(with_bright), source.a)
}

///|
/// §20.1.8.39 HSL relative adjustment. Each channel is shifted by the
/// supplied percentage, with hue wrapped into the 0..1 turn.
pub fn apply_hsl(
  source : @color.Rgba8,
  hue_pct : Int,
  sat_pct : Int,
  lum_pct : Int,
) -> @color.Rgba8 {
  let (h, s, l) = rgb_to_hsl(source)
  let new_h = normalize_turn(h + percent_to_unit(hue_pct))
  let new_s = clamp_unit(s + percent_to_unit(sat_pct))
  let new_l = clamp_unit(l + percent_to_unit(lum_pct))
  hsl_to_rgb(new_h, new_s, new_l, source.a)
}

///|
/// §20.1.8.23 duotone two-color mix. For each pixel, the output is a
/// linear interpolation between `first` and `second` weighted by the
/// source's relative luminance.
pub fn apply_duotone(
  source : @color.Rgba8,
  first : @color.Rgba8,
  second : @color.Rgba8,
) -> @color.Rgba8 {
  let weight = relative_luminance(source)
  {
    r: byte_lerp(first.r, second.r, weight),
    g: byte_lerp(first.g, second.g, weight),
    b: byte_lerp(first.b, second.b, weight),
    a: source.a,
  }
}

///|
/// §20.1.8.16 clrChange: if the source pixel matches `from` (RGB or full
/// RGBA depending on `use_alpha`), replace it with `to`. Otherwise the
/// pixel is left alone.
pub fn apply_clr_change(
  source : @color.Rgba8,
  from : @color.Rgba8,
  to : @color.Rgba8,
  use_alpha : Bool,
) -> @color.Rgba8 {
  let rgb_match = source.r == from.r && source.g == from.g && source.b == from.b
  let matched = if use_alpha {
    rgb_match && source.a == from.a
  } else {
    rgb_match
  }
  if matched {
    to
  } else {
    source
  }
}

///|
/// §20.1.8.18 clrRepl: replace the color channels with the supplied
/// color, preserving the existing alpha.
pub fn apply_clr_repl(
  source : @color.Rgba8,
  color : @color.Rgba8,
) -> @color.Rgba8 {
  { r: color.r, g: color.g, b: color.b, a: source.a }
}

///|
/// §20.1.8.34 grayscl: replace RGB with the source's relative luminance.
/// Alpha is preserved.
pub fn apply_grayscale(source : @color.Rgba8) -> @color.Rgba8 {
  let y = clamp_byte((relative_luminance(source) * 255.0).round().to_int())
  { r: y, g: y, b: y, a: source.a }
}

///|
/// §20.1.8.6 alphaModFix: multiply alpha by a fixed §20.1.10.46 positive
/// percentage.
pub fn apply_alpha_mod_fix(source : @color.Rgba8, amt : Int) -> @color.Rgba8 {
  let scaled = clamp_unit(source.a.to_double() / 255.0 * percent_to_unit(amt))
  { r: source.r, g: source.g, b: source.b, a: percent_unit_to_byte(scaled) }
}

///|
/// §20.1.8.8 alphaRepl: replace alpha with a §20.1.10.45 positive fixed
/// percentage.
pub fn apply_alpha_replace(source : @color.Rgba8, a : Int) -> @color.Rgba8 {
  {
    r: source.r,
    g: source.g,
    b: source.b,
    a: percent_unit_to_byte(percent_to_unit(a)),
  }
}

///|
/// §20.1.8.2 alphaCeiling: any non-zero alpha becomes 100%.
pub fn apply_alpha_ceiling(source : @color.Rgba8) -> @color.Rgba8 {
  if source.a > 0 {
    { r: source.r, g: source.g, b: source.b, a: 255 }
  } else {
    source
  }
}

///|
/// §20.1.8.3 alphaFloor: any partially transparent pixel becomes fully
/// transparent.
pub fn apply_alpha_floor(source : @color.Rgba8) -> @color.Rgba8 {
  if source.a < 255 {
    { r: source.r, g: source.g, b: source.b, a: 0 }
  } else {
    source
  }
}

///|
/// §20.1.8.4 alphaInv: invert the alpha channel. If a replacement color
/// is supplied, its RGB is substituted as well; otherwise the existing
/// RGB is retained.
pub fn apply_alpha_inverse(
  source : @color.Rgba8,
  replacement : @color.Rgba8?,
) -> @color.Rgba8 {
  let new_a = 255 - source.a
  match replacement {
    Some(c) => { r: c.r, g: c.g, b: c.b, a: new_a }
    None => { r: source.r, g: source.g, b: source.b, a: new_a }
  }
}

///|
fn rgb_to_hsl(c : @color.Rgba8) -> (Double, Double, Double) {
  let r = c.r.to_double() / 255.0
  let g = c.g.to_double() / 255.0
  let b = c.b.to_double() / 255.0
  let maxc = max_double(r, max_double(g, b))
  let minc = min_double(r, min_double(g, b))
  let l = (maxc + minc) / 2.0
  if doubles_close(maxc, minc) {
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
fn hsl_to_rgb(h : Double, s : Double, l : Double, a : Int) -> @color.Rgba8 {
  let h = normalize_turn(h)
  let s = clamp_unit(s)
  let l = clamp_unit(l)
  if doubles_close(s, 0.0) {
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
fn relative_luminance(c : @color.Rgba8) -> Double {
  clamp_unit(
    (
      c.r.to_double() * 0.2126 +
      c.g.to_double() * 0.7152 +
      c.b.to_double() * 0.0722
    ) /
    255.0,
  )
}

///|
fn byte_lerp(a : Int, b : Int, weight : Double) -> Int {
  let w = clamp_unit(weight)
  clamp_byte((a.to_double() * (1.0 - w) + b.to_double() * w).round().to_int())
}

///|
fn lerp_hue(a : Double, b : Double, weight : Double) -> Double {
  let w = clamp_unit(weight)
  normalize_turn(a * (1.0 - w) + b * w)
}

///|
fn opposite_hue(turn : Double) -> Double {
  normalize_turn(turn + 0.5)
}

///|
fn percent_to_unit(value : Int) -> Double {
  value.to_double() / 100000.0
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
fn doubles_close(a : Double, b : Double) -> Bool {
  let diff = a - b
  let mag = if diff < 0.0 { -diff } else { diff }
  mag < 0.0000000001
}

///|
fn abs_int(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}
