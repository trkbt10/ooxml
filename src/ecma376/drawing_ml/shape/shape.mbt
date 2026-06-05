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
/// Part 1 §20.3 DrawingML Locked Canvas plus dml-lockedCanvas.xsd.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/shape"
}

///|
/// Schema validation error for dml-lockedCanvas.xsd content. ResourceMissing is
/// intentionally outside this package: lockedCanvas has no OPC relationship
/// target of its own, so relationship resolution is handled by the embedding
/// package boundary.
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
/// GvmlGroupContent is the package-local projection of the XSD element
/// lockedCanvas from Schema dml-lockedCanvas.xsd. The lockedCanvas element
/// binds to `a:CT_GvmlGroupShape`, whose EG_ShapeGroupContent choice contains
/// `txSp`, `sp`, `cxnSp`, `pic`, `graphicFrame`, and `grpSp` children per
/// ECMA-376 Part 1 §20.3 / §20.1.2.2.32.
pub(all) enum GvmlGroupContent {
  TxSp(@a.CT_GvmlTextShape)
  Sp(@a.CT_GvmlShape)
  CxnSp(@a.CT_GvmlConnector)
  Pic(@a.CT_GvmlPicture)
  GraphicFrame(@a.CT_GvmlGraphicalObjectFrame)
  GrpSp(@a.CT_GvmlGroupShape)
} derive(Eq, Debug)

///|
pub(all) struct CT_GvmlLockedCanvas {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <nvGrpSpPr> (CT_GvmlGroupShapeNonVisual) — required.
  nv_grp_sp_pr : @a.CT_GvmlGroupShapeNonVisual
  /// <grpSpPr> (CT_GroupShapeProperties) — required.
  grp_sp_pr : @a.CT_GroupShapeProperties
  /// Nested group-content children in document order — the
  /// EG_ShapeGroupContent unbounded choice (§20.1.2.2.32).
  contents : Array[GvmlGroupContent]
  /// <extLst> (CT_OfficeArtExtensionList) — optional.
  ext_lst : @a.CT_OfficeArtExtensionList?
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
  let nv_el = required_child(
    element, "nvGrpSpPr", "CT_GvmlLockedCanvas/nvGrpSpPr",
  )
  let grp_el = required_child(element, "grpSpPr", "CT_GvmlLockedCanvas/grpSpPr")
  let nv_grp_sp_pr = wrap_a_violation(
    () => @a.CT_GvmlGroupShapeNonVisual::new(nv_el),
    "CT_GvmlLockedCanvas/nvGrpSpPr",
  )
  let grp_sp_pr = wrap_a_violation(
    () => @a.CT_GroupShapeProperties::new(grp_el),
    "CT_GvmlLockedCanvas/grpSpPr",
  )
  let contents : Array[GvmlGroupContent] = []
  let mut ext_lst : @a.CT_OfficeArtExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "txSp" =>
          contents.push(
            TxSp(
              wrap_a_violation(
                () => @a.CT_GvmlTextShape::new(child_element),
                "CT_GvmlLockedCanvas/txSp",
              ),
            ),
          )
        "sp" =>
          contents.push(
            Sp(
              wrap_a_violation(
                () => @a.CT_GvmlShape::new(child_element),
                "CT_GvmlLockedCanvas/sp",
              ),
            ),
          )
        "cxnSp" =>
          contents.push(
            CxnSp(
              wrap_a_violation(
                () => @a.CT_GvmlConnector::new(child_element),
                "CT_GvmlLockedCanvas/cxnSp",
              ),
            ),
          )
        "pic" =>
          contents.push(
            Pic(
              wrap_a_violation(
                () => @a.CT_GvmlPicture::new(child_element),
                "CT_GvmlLockedCanvas/pic",
              ),
            ),
          )
        "graphicFrame" =>
          contents.push(
            GraphicFrame(
              wrap_a_violation(
                () => @a.CT_GvmlGraphicalObjectFrame::new(child_element),
                "CT_GvmlLockedCanvas/graphicFrame",
              ),
            ),
          )
        "grpSp" =>
          contents.push(
            GrpSp(
              wrap_a_violation(
                () => @a.CT_GvmlGroupShape::new(child_element),
                "CT_GvmlLockedCanvas/grpSp",
              ),
            ),
          )
        "extLst" =>
          ext_lst = Some(
            wrap_a_violation(
              () => @a.CT_OfficeArtExtensionList::new(child_element),
              "CT_GvmlLockedCanvas/extLst",
            ),
          )
        _ => ()
      }
    }
  }
  { element, nv_grp_sp_pr, grp_sp_pr, contents, ext_lst }
}

///|
/// Locate a required child element by local name.
fn required_child(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> @xml.Element raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return child_element
        }
      _ => ()
    }
  }
  raise SchemaViolation(
    schema="dml-lockedCanvas.xsd",
    path~,
    reason="required child element is missing",
  )
}

///|
/// Bridge @a.SchemaViolation into our local one.
fn[T] wrap_a_violation(
  body : () -> T raise @a.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @a.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(
        schema="dml-lockedCanvas.xsd",
        path=path + " (" + p + ")",
        reason~,
      )
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
