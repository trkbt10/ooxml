///|
/// ECMA-376 DrawingML font model for Part 1 §20.1 text and theme font
/// declarations.
///
/// This package implements CT_TextFont, CT_SupplementalFont,
/// CT_FontCollection, CT_FontScheme, and CT_FontReference from dml-main.xsd.
/// Public readers and writers include read_text_font/write_text_font and
/// read_font_scheme/write_font_scheme. Simple-type coverage includes
/// ST_TextFontSize, ST_TextTypeface, ST_PitchFamily,
/// ST_TextFontAlignType, and ST_TextFontScalePercentOrPercentString.
///
/// §3 TOC coverage follows .kiro/specs/ecma376/drawing_ml/coverage.json for
/// Part 1 §14.1-§14.2, §20.1 DrawingML Main, §20.3 locked canvas, §20.5
/// SpreadsheetML drawing, §21.1 DrawingML Main, and the tracked Part 4
/// DrawingML/VML migration sections.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/font"
}
