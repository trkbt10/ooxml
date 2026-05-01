///|
/// ECMA-376 DrawingML theme model for Part 1 §20.1 DrawingML Main theme
/// declarations.
///
/// This package implements CT_OfficeStyleSheet, CT_BaseStyles,
/// CT_BaseStylesOverride, CT_OfficeArtExtension, and
/// CT_OfficeArtExtensionList from dml-main.xsd. Public aliases Theme,
/// ThemeOverride, and ThemeManager map to those schema wrappers; public
/// readers and writers include read_theme/write_theme,
/// read_theme_override/write_theme_override, and
/// read_theme_manager/write_theme_manager.
///
/// §3 TOC coverage follows .kiro/specs/ecma376/drawing_ml/coverage.json for
/// Part 1 §14.1-§14.2, §20.1 DrawingML Main, §20.3 locked canvas, §20.5
/// SpreadsheetML drawing, §21.1 DrawingML Main, and the tracked Part 4
/// DrawingML/VML migration sections.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/theme"
}
