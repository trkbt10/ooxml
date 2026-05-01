///|
/// ECMA-376 Part 1 §20.3 DrawingML locked canvas package.
///
/// The shape subpackage owns dml-lockedCanvas.xsd, whose target namespace is
/// http://purl.oclc.org/ooxml/drawingml/lockedCanvas and whose only top-level
/// element is lockedCanvas. The element's schema type is a:CT_GvmlGroupShape,
/// so CT_GvmlLockedCanvas preserves the lockedCanvas element and delegates its
/// group-shape child structure to DrawingML Main consumers. Public entry points
/// are read_locked_canvas and write_locked_canvas.
///
/// §3 TOC coverage from .kiro/specs/ecma376/drawing_ml/shape/coverage.json is
/// schema-only for dml-lockedCanvas.xsd; the broader DrawingML package cites
/// Part 1 §20.3 DrawingML Locked Canvas.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/shape"
}

///|
/// Schema validation error for dml-lockedCanvas.xsd content.
pub suberror SchemaViolation {
  SchemaViolation(schema~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// DrawingML lockedCanvas top-level element from dml-lockedCanvas.xsd.
///
/// The schema declares lockedCanvas as a:CT_GvmlGroupShape. This wrapper keeps
/// the source XML element so callers can inspect or pass through the DrawingML
/// Main group-shape children and attributes without losing namespace data.
pub(all) struct CT_GvmlLockedCanvas {
  element : @xml.Element
} derive(Eq, Debug)

///|
/// Construct a CT_GvmlLockedCanvas from a validated lockedCanvas XML element.
pub fn CT_GvmlLockedCanvas::new(
  element : @xml.Element,
) -> CT_GvmlLockedCanvas raise SchemaViolation {
  if element.name.local_name != "lockedCanvas" {
    raise SchemaViolation(
      schema="dml-lockedCanvas.xsd",
      path="/",
      reason="expected lockedCanvas top-level element",
    )
  }
  { element, }
}

///|
/// Read dml-lockedCanvas.xsd lockedCanvas XML bytes into CT_GvmlLockedCanvas.
pub fn read_locked_canvas(bytes : Bytes) -> CT_GvmlLockedCanvas raise {
  CT_GvmlLockedCanvas::new(@xml.parse(bytes).root)
}

///|
/// Write CT_GvmlLockedCanvas back to XML bytes, preserving its element tree.
pub fn write_locked_canvas(value : CT_GvmlLockedCanvas) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root: value.element })
}
