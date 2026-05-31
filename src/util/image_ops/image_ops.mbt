// Pixel-level image processing for ECMA-376 §20.1.8 blip effects.
//
// These operations decode the image to an RGBA pixel buffer, perform
// per-pixel manipulation, and re-encode to PNG. They are invoked by
// the viewer's render_picture_svg as a pre-processing step BEFORE
// SVG filter composition — effects that SVG filters cannot represent
// (conditional colour matching, per-pixel HSL shifts) are baked into
// the image data here.

///|
/// Decode a base64-encoded image (PNG or JPEG) to an RGBA pixel buffer.
/// Returns None if decoding fails.
pub fn decode_image(
  mime_type : String,
  base64_data : String,
) -> @image.ImageData? {
  let bytes = try @base64.decode(base64_data[:]) catch {
    _ => return None
  } noraise {
    b => b
  }
  match mime_type {
    "image/png" =>
      try @image.decode_png(bytes) catch {
        _ => None
      } noraise {
        img => Some(img)
      }
    "image/jpeg" | "image/jpg" =>
      try @image.decode_jpeg(bytes) catch {
        _ => None
      } noraise {
        img => Some(img)
      }
    _ => None
  }
}

///|
/// Decode just the intrinsic `(width, height)` in pixels of a
/// base64-encoded image, or `None` when it cannot be decoded.  Used by
/// the renderer to size a `<a:tile>` blip fill's repeat box without
/// the caller needing to depend on `@mizchi/image` directly.
pub fn image_dimensions(
  mime_type : String,
  base64_data : String,
) -> (Int, Int)? {
  match decode_image(mime_type, base64_data) {
    Some(img) => Some((img.width, img.height))
    None => None
  }
}

///|
/// Re-encode an RGBA pixel buffer to the original format and return
/// as `(mime_type, base64)`. JPEG inputs re-encode as JPEG (quality
/// 90) to avoid size inflation; everything else encodes as PNG.
pub fn encode_image_base64(
  img : @image.ImageData,
  original_mime : String,
) -> (String, String)? {
  match original_mime {
    "image/jpeg" | "image/jpg" => {
      let bytes = try @image.encode_jpeg(img, quality=90) catch {
        _ => return None
      } noraise {
        b => b
      }
      Some(("image/jpeg", @base64.encode(bytes[:])))
    }
    _ => {
      let bytes = try @image.encode_png(img) catch {
        _ => return None
      } noraise {
        b => b
      }
      Some(("image/png", @base64.encode(bytes[:])))
    }
  }
}

///|
/// §20.1.8.16 clrChange — chroma-key colour replacement.
///
/// For each pixel whose RGB distance from `clr_from` is within
/// `tolerance`, replace its colour with `clr_to`. The `use_alpha`
/// flag controls whether the replacement also overwrites the alpha
/// channel (§20.1.8.16 @useA, default true).
///
/// Colour distance uses Euclidean distance in sRGB space; the
/// tolerance is expressed as a 0–255 per-channel threshold
/// (default 0 = exact match only).
pub fn apply_clr_change(
  img : @image.ImageData,
  clr_from : (Int, Int, Int),
  clr_to : (Int, Int, Int, Int),
  use_alpha : Bool,
  tolerance : Int,
) -> @image.ImageData {
  let w = img.width
  let h = img.height
  let src = img.data
  let len = w * h * 4
  let dst = FixedArray::make(len, b'\x00')
  let (fr, fg, fb) = clr_from
  let (tr, tg, tb, ta) = clr_to
  let tol_sq = tolerance * tolerance * 3
  for i = 0; i < len; i = i + 4 {
    let sr = src[i].to_int()
    let sg = src[i + 1].to_int()
    let sb = src[i + 2].to_int()
    let sa = src[i + 3].to_int()
    let dr = sr - fr
    let dg = sg - fg
    let db = sb - fb
    let dist_sq = dr * dr + dg * dg + db * db
    if dist_sq <= tol_sq {
      dst[i] = tr.to_byte()
      dst[i + 1] = tg.to_byte()
      dst[i + 2] = tb.to_byte()
      dst[i + 3] = if use_alpha { ta.to_byte() } else { sa.to_byte() }
    } else {
      dst[i] = sr.to_byte()
      dst[i + 1] = sg.to_byte()
      dst[i + 2] = sb.to_byte()
      dst[i + 3] = sa.to_byte()
    }
  }
  { width: w, height: h, data: Bytes::from_array(dst) }
}

///|
/// §20.1.8.60 tint — per-pixel hue convergence toward a target hue.
///
/// For each pixel, convert to HSL, interpolate the hue toward
/// `target_hue_deg` by `amt` (0.0–1.0), and convert back to RGB.
/// Saturation and lightness are preserved.
pub fn apply_tint(
  img : @image.ImageData,
  target_hue_deg : Double,
  amt : Double,
) -> @image.ImageData {
  let w = img.width
  let h = img.height
  let src = img.data
  let len = w * h * 4
  let dst = FixedArray::make(len, b'\x00')
  let abs_amt = if amt >= 0.0 { amt } else { -amt }
  for i = 0; i < len; i = i + 4 {
    let r = src[i].to_int().to_double() / 255.0
    let g = src[i + 1].to_int().to_double() / 255.0
    let b = src[i + 2].to_int().to_double() / 255.0
    let a = src[i + 3]
    let (h_deg, s, l) = rgb_to_hsl(r, g, b)
    let new_h = interpolate_hue(h_deg, target_hue_deg, abs_amt)
    let (nr, ng, nb) = hsl_to_rgb(new_h, s, l)
    dst[i] = clamp_byte(nr * 255.0)
    dst[i + 1] = clamp_byte(ng * 255.0)
    dst[i + 2] = clamp_byte(nb * 255.0)
    dst[i + 3] = a
  }
  { width: w, height: h, data: Bytes::from_array(dst) }
}

///|
/// §20.1.8.39 hsl — per-pixel HSL shift.
///
/// For each pixel, convert to HSL, add the shifts (hue_shift in
/// degrees, sat_shift and lum_shift in -1.0..1.0), and convert
/// back to RGB.
pub fn apply_hsl(
  img : @image.ImageData,
  hue_shift_deg : Double,
  sat_shift : Double,
  lum_shift : Double,
) -> @image.ImageData {
  let w = img.width
  let h = img.height
  let src = img.data
  let len = w * h * 4
  let dst = FixedArray::make(len, b'\x00')
  for i = 0; i < len; i = i + 4 {
    let r = src[i].to_int().to_double() / 255.0
    let g = src[i + 1].to_int().to_double() / 255.0
    let b = src[i + 2].to_int().to_double() / 255.0
    let a = src[i + 3]
    let (h_deg, s, l) = rgb_to_hsl(r, g, b)
    let new_h = (h_deg + hue_shift_deg) % 360.0
    let new_s = clamp01(s + sat_shift)
    let new_l = clamp01(l + lum_shift)
    let (nr, ng, nb) = hsl_to_rgb(
      if new_h < 0.0 {
        new_h + 360.0
      } else {
        new_h
      },
      new_s,
      new_l,
    )
    dst[i] = clamp_byte(nr * 255.0)
    dst[i + 1] = clamp_byte(ng * 255.0)
    dst[i + 2] = clamp_byte(nb * 255.0)
    dst[i + 3] = a
  }
  { width: w, height: h, data: Bytes::from_array(dst) }
}

// ===================================================================
// Colour-space conversion helpers
// ===================================================================

///|
fn rgb_to_hsl(r : Double, g : Double, b : Double) -> (Double, Double, Double) {
  let max = if r > g {
    if r > b {
      r
    } else {
      b
    }
  } else if g > b {
    g
  } else {
    b
  }
  let min = if r < g {
    if r < b {
      r
    } else {
      b
    }
  } else if g < b {
    g
  } else {
    b
  }
  let l = (max + min) / 2.0
  if max == min {
    return (0.0, 0.0, l)
  }
  let d = max - min
  let s = if l > 0.5 { d / (2.0 - max - min) } else { d / (max + min) }
  let h = if max == r {
    let h0 = (g - b) / d
    if h0 < 0.0 {
      h0 + 6.0
    } else {
      h0
    }
  } else if max == g {
    (b - r) / d + 2.0
  } else {
    (r - g) / d + 4.0
  }
  (h * 60.0, s, l)
}

///|
fn hsl_to_rgb(
  h_deg : Double,
  s : Double,
  l : Double,
) -> (Double, Double, Double) {
  if s == 0.0 {
    return (l, l, l)
  }
  let q = if l < 0.5 { l * (1.0 + s) } else { l + s - l * s }
  let p = 2.0 * l - q
  let h = h_deg / 360.0
  (
    hue_to_rgb(p, q, h + 1.0 / 3.0),
    hue_to_rgb(p, q, h),
    hue_to_rgb(p, q, h - 1.0 / 3.0),
  )
}

///|
fn hue_to_rgb(p : Double, q : Double, t_in : Double) -> Double {
  let t = if t_in < 0.0 {
    t_in + 1.0
  } else if t_in > 1.0 {
    t_in - 1.0
  } else {
    t_in
  }
  if t < 1.0 / 6.0 {
    return p + (q - p) * 6.0 * t
  }
  if t < 1.0 / 2.0 {
    return q
  }
  if t < 2.0 / 3.0 {
    return p + (q - p) * (2.0 / 3.0 - t) * 6.0
  }
  p
}

///|
fn interpolate_hue(current : Double, target : Double, amt : Double) -> Double {
  let mut diff = target - current
  if diff > 180.0 {
    diff = diff - 360.0
  } else if diff < -180.0 {
    diff = diff + 360.0
  }
  let result = current + diff * amt
  if result < 0.0 {
    result + 360.0
  } else if result >= 360.0 {
    result - 360.0
  } else {
    result
  }
}

///|
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
fn clamp_byte(v : Double) -> Byte {
  let i = (v + 0.5).to_int()
  if i < 0 {
    b'\x00'
  } else if i > 255 {
    b'\xFF'
  } else {
    i.to_byte()
  }
}
