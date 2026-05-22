// @source web-pptx packages/@aurochs/glyph/src/metrics/font-metrics.ts
//
// Public per-character / per-pair metric lookup with bold scaling
// and font-family ascender ratio fallback table.

///|
/// Default bold width scale factor.  Bold text is ~5% wider than
/// regular.  Mirrors `DEFAULT_BOLD_WIDTH_SCALE` in
/// `font-metrics.ts:22`.
let default_bold_width_scale : Double = 1.05

///|
/// Character-width lookup.  Returns the width as an em-ratio
/// (multiply by font size to get pixels).
///
/// Resolution order, faithfully mirroring `getCharWidth` in
/// `font-metrics.ts:34`:
///   1. Pick the font's metrics record (`get_font_metrics`).
///   2. Compute the global scale: `width_scale ?? 1.0`.
///   3. Compute the bold scale: when `font_weight ≥ 700`, use the
///      font's `bold_width_scale` or fall back to 1.05.
///   4. If `is_cjk`, return `cjk_average * scale * bold_scale`.
///   5. Else if the character has an override, return that.
///   6. Else return `latin_average * scale * bold_scale`.
pub fn get_char_width(
  char : Char,
  font_family : String?,
  is_cjk : Bool,
  font_weight? : Int = 400,
) -> Double {
  let metrics = get_font_metrics(font_family)
  let scale = metrics.width_scale.unwrap_or(1.0)
  let is_bold = font_weight >= 700
  let bold_scale = if is_bold {
    metrics.bold_width_scale.unwrap_or(default_bold_width_scale)
  } else {
    1.0
  }
  if is_cjk {
    return metrics.cjk_average * scale * bold_scale
  }
  match metrics.char_widths.get(char) {
    Some(w) => w * scale * bold_scale
    None => metrics.latin_average * scale * bold_scale
  }
}

///|
/// Kerning adjustment for a character pair `prev_char + char`.  Returns
/// an em-ratio (negative = tighter, multiply by font size to get px).
/// Mirrors `getKerningAdjustment` in `font-metrics.ts:71` — looks up
/// the two-character key in the font's kerning table, returning 0 if
/// missing or if the key is not exactly two chars long.
pub fn get_kerning_adjustment(pair : String, font_family : String?) -> Double {
  if pair.length() != 2 {
    return 0.0
  }
  let metrics = get_font_metrics(font_family)
  metrics.kerning.get(pair).unwrap_or(0.0)
}

///|
/// Kerning adjustments for every position in `text`.  `out[0]` is
/// always 0 (the first character has no predecessor).  Mirrors
/// `getKerningForText` in `font-metrics.ts:94`.
pub fn get_kerning_for_text(
  text : String,
  font_family : String?,
) -> Array[Double] {
  let chars : Array[Char] = []
  for c in text {
    chars.push(c)
  }
  let n = chars.length()
  let result : Array[Double] = Array::make(n, 0.0)
  for i in 1..<n {
    let pair = StringBuilder::new()
    pair.write_char(chars[i - 1])
    pair.write_char(chars[i])
    result[i] = get_kerning_adjustment(pair.to_string(), font_family)
  }
  result
}

///|
/// Ascender ratios for common fonts. Mirrors `ASCENDER_RATIOS` in
/// `font-metrics.ts:114`.  Determines baseline placement:
/// `baseline = font_size * ascender_ratio`.
fn ascender_ratios() -> Map[String, Double] {
  {
    "calibri": 0.75,
    "arial": 0.75,
    "helvetica": 0.75,
    "times new roman": 0.8,
    "georgia": 0.8,
    "verdana": 0.72,
    "tahoma": 0.72,
    "segoe ui": 0.75,
    "consolas": 0.8,
    "courier new": 0.8,
    // Japanese fonts frequently used in embedded-PDF conversions.
    "ms-pgothic": 0.8594,
    "hgmarugothicmpro": 0.8594,
  }
}

///|
/// Ascender ratio lookup.  Resolution order mirrors
/// `getAscenderRatio` in `font-metrics.ts:138`:
///   1. `None` → 0.8 (default).
///   2. Specific font metrics' `ascender_ratio` if defined.
///   3. Exact match in `ascender_ratios()`.
///   4. Partial (substring) match in `ascender_ratios()`.
///   5. 0.8 default.
pub fn get_ascender_ratio(font_family : String?) -> Double {
  match font_family {
    None => 0.8
    Some(ff) => {
      // Step 2 — specific font metrics.
      let metrics = get_font_metrics(Some(ff))
      match metrics.ascender_ratio {
        Some(r) => return r
        None => ()
      }
      // Step 3/4 — legacy table.
      let normalized = normalize_font_name(ff)
      let table = ascender_ratios()
      match table.get(normalized) {
        Some(r) => r
        None => {
          for k, v in table {
            if normalized.contains(k) {
              return v
            }
          }
          0.8
        }
      }
    }
  }
}
