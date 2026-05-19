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
/// XSD complex type CT_GvmlLockedCanvas — Part 1 §20.3.2.1. The
/// dml-lockedCanvas.xsd `lockedCanvas` element binds to `a:CT_GvmlGroupShape`,
/// which requires `<nvGrpSpPr>` (CT_GvmlGroupShapeNonVisual) and `<grpSpPr>`
/// (CT_GroupShapeProperties) children plus an unbounded choice of nested
/// `txSp`, `sp`, `cxnSp`, `pic`, `graphicFrame`, or `grpSp` content and an
/// optional `<extLst>` (CT_OfficeArtExtensionList).
pub(all) struct CT_GvmlLockedCanvas {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvGrpSpPr> (CT_GvmlGroupShapeNonVisual) — required.
  nv_grp_sp_pr_child_name : String
  /// <grpSpPr> (CT_GroupShapeProperties) — required.
  grp_sp_pr_child_name : String
  /// Local names of nested group-content children (txSp/sp/cxnSp/pic/
  /// graphicFrame/grpSp), zero or more in document order.
  content_child_names : Array[String]
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  has_ext_lst : Bool
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
  let mut nv = ""
  let mut grp = ""
  let content : Array[String] = []
  let mut has_ext = false
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "nvGrpSpPr" => nv = "nvGrpSpPr"
        "grpSpPr" => grp = "grpSpPr"
        "txSp" | "sp" | "cxnSp" | "pic" | "graphicFrame" | "grpSp" =>
          content.push(child_element.name.local_name)
        "extLst" => has_ext = true
        _ => ()
      }
    }
  }
  {
    element,
    nv_grp_sp_pr_child_name: nv,
    grp_sp_pr_child_name: grp,
    content_child_names: content,
    has_ext_lst: has_ext,
  }
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
