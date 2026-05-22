// @source web-pptx packages/@aurochs/glyph/src/metrics/fonts/calibri.ts
//
// Calibri (Microsoft Office default font) metrics.  Empirically
// measured against LibreOffice 7.x rendering at 150 DPI on the
// pangram "The quick brown fox jumps over the lazy dog." at 24pt.

///|
/// Calibri-specific metrics. Mirrors `CALIBRI_METRICS` in
/// `calibri.ts:26`.
pub fn calibri_metrics() -> FontMetrics {
  // Start from DEFAULT_CHAR_WIDTHS and override the per-Calibri values
  // measured by the web-pptx team.
  let widths = default_char_widths()
  widths['i'] = 0.24
  widths['l'] = 0.24
  widths['I'] = 0.3
  widths['j'] = 0.3
  widths['f'] = 0.34
  widths['t'] = 0.34
  widths['r'] = 0.38
  widths[' '] = 0.28
  widths['a'] = 0.54
  widths['c'] = 0.52
  widths['e'] = 0.54
  widths['n'] = 0.56
  widths['o'] = 0.56
  widths['s'] = 0.5
  widths['u'] = 0.56
  {
    latin_average: 0.52,
    cjk_average: 1.0,
    char_widths: widths,
    kerning: sans_serif_kerning(),
    ascender_ratio: Some(0.75),
    width_scale: Some(1.08),
    bold_width_scale: None,
  }
}
