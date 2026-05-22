// @source web-pptx packages/@aurochs/glyph/src/metrics/types.ts

///|
/// Font category used for fallback metrics when a specific font is
/// not registered.  Mirrors `FontCategory` in `types.ts:48`.
pub(all) enum FontCategory {
  SansSerif
  Serif
  Monospace
  CJK
} derive(Eq, Show)

///|
/// Pixel metrics for a single font.
///
/// All width fields are expressed in *em units* (multiples of the
/// current font size), matching `FontMetrics` in `types.ts:20`.
///
/// Field-by-field mapping:
///   - `latin_average`     ← `latinAverage`
///   - `cjk_average`       ← `cjkAverage`
///   - `char_widths`       ← `charWidths`           (per-char overrides)
///   - `kerning`           ← `kerning`              (two-char string key)
///   - `ascender_ratio`    ← `ascenderRatio?`       (baseline placement)
///   - `width_scale`       ← `widthScale?`          (global calibration)
///   - `bold_width_scale`  ← `boldWidthScale?`      (≥700 weight scale)
///
/// In MoonBit we use `Map[Char, Double]` for char widths because
/// per-character overrides are addressed by code point. Kerning
/// pairs use `Map[String, Double]` to mirror the JS object key style.
pub struct FontMetrics {
  latin_average : Double
  cjk_average : Double
  char_widths : Map[Char, Double]
  kerning : Map[String, Double]
  ascender_ratio : Double?
  width_scale : Double?
  bold_width_scale : Double?
}
