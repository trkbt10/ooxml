///|
/// ECMA-376 DrawingML color model for Part 1 §20.1 DrawingML Main.
///
/// This package implements color and fill wrappers from dml-main.xsd:
/// CT_ColorScheme, CT_CustomColorList, CT_SRgbColor, CT_ScRgbColor,
/// CT_HslColor, CT_SystemColor, CT_SchemeColor, CT_PresetColor, CT_Color,
/// CT_ColorMapping, CT_ColorMappingOverride, CT_ColorSchemeAndMapping, and
/// CT_SolidColorFillProperties. Public readers and writers include
/// read_color_scheme/write_color_scheme, read_s_rgb_color/write_s_rgb_color,
/// read_scheme_color/write_scheme_color, read_system_color/write_system_color,
/// read_preset_color/write_preset_color, and read_color_mapping/
/// write_color_mapping. Simple-type coverage includes ST_ColorSchemeIndex,
/// ST_SystemColorVal, ST_SchemeColorVal, and ST_PresetColorVal.
///
/// §3 TOC coverage follows .kiro/specs/ecma376/drawing_ml/coverage.json for
/// Part 1 §14.1-§14.2, §20.1 DrawingML Main, §20.3 locked canvas, §20.5
/// SpreadsheetML drawing, §21.1 DrawingML Main, and the tracked Part 4
/// DrawingML/VML migration sections.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/color"
}
