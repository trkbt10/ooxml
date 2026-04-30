///|
/// Root entry of the `trkbt10/ooxml` library.
///
/// Office Open XML (ECMA-376) implementation for MoonBit.
/// Format facades are provided as separate packages:
///   - `trkbt10/ooxml/docx` — WordprocessingML files
///   - `trkbt10/ooxml/xlsx` — SpreadsheetML files
///   - `trkbt10/ooxml/pptx` — PresentationML files
///
/// The root package intentionally exposes no API of its own yet; downstream
/// users should depend on the format-specific package they need.
pub fn version() -> String {
  "0.1.0"
}
