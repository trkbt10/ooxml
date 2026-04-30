///|
/// Read top-level XSD element colorsDef as CT_ColorTransform.
pub fn read_colors_def(bytes : Bytes) -> ColorsDef raise {
  let root = @xml.parse(bytes).root
  require_local(root, "colorsDef", "colorsDef")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element colorsDefHdr as CT_ColorTransformHeader.
pub fn read_colors_def_hdr(bytes : Bytes) -> ColorsDefHdr raise {
  let root = @xml.parse(bytes).root
  require_local(root, "colorsDefHdr", "colorsDefHdr")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element colorsDefHdrLst as CT_ColorTransformHeaderLst.
pub fn read_colors_def_hdr_lst(bytes : Bytes) -> ColorsDefHdrLst raise {
  let root = @xml.parse(bytes).root
  require_local(root, "colorsDefHdrLst", "colorsDefHdrLst")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element dataModel as CT_DataModel.
pub fn read_data_model(bytes : Bytes) -> DataModel raise {
  let root = @xml.parse(bytes).root
  require_local(root, "dataModel", "dataModel")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element layoutDef as CT_DiagramDefinition.
pub fn read_layout_def(bytes : Bytes) -> LayoutDef raise {
  let root = @xml.parse(bytes).root
  require_local(root, "layoutDef", "layoutDef")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element layoutDefHdr as CT_DiagramDefinitionHeader.
pub fn read_layout_def_hdr(bytes : Bytes) -> LayoutDefHdr raise {
  let root = @xml.parse(bytes).root
  require_local(root, "layoutDefHdr", "layoutDefHdr")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element layoutDefHdrLst as CT_DiagramDefinitionHeaderLst.
pub fn read_layout_def_hdr_lst(bytes : Bytes) -> LayoutDefHdrLst raise {
  let root = @xml.parse(bytes).root
  require_local(root, "layoutDefHdrLst", "layoutDefHdrLst")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element relIds as CT_RelIds.
pub fn read_rel_ids(bytes : Bytes) -> RelIds raise {
  let root = @xml.parse(bytes).root
  require_local(root, "relIds", "relIds")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element styleDef as CT_StyleDefinition.
pub fn read_style_def(bytes : Bytes) -> StyleDef raise {
  let root = @xml.parse(bytes).root
  require_local(root, "styleDef", "styleDef")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element styleDefHdr as CT_StyleDefinitionHeader.
pub fn read_style_def_hdr(bytes : Bytes) -> StyleDefHdr raise {
  let root = @xml.parse(bytes).root
  require_local(root, "styleDefHdr", "styleDefHdr")
  validate_diagram_element(root)
  { element: root }
}

///|
/// Read top-level XSD element styleDefHdrLst as CT_StyleDefinitionHeaderLst.
pub fn read_style_def_hdr_lst(bytes : Bytes) -> StyleDefHdrLst raise {
  let root = @xml.parse(bytes).root
  require_local(root, "styleDefHdrLst", "styleDefHdrLst")
  validate_diagram_element(root)
  { element: root }
}

///|
fn validate_diagram_element(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  validate_diagram_attributes(element)
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        validate_diagram_element(child_element)
      _ => ()
    }
  }
}

///|
fn validate_diagram_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let name = attribute.name.local_name
    let value = attribute.value
    match name {
      "meth" => ST_ClrAppMethod::parse(value) |> ignore
      "hueDir" => ST_HueDir::parse(value) |> ignore
      "type" => validate_type_attribute(value)
      "ptType" | "refPtType" => ST_PtType::parse(value) |> ignore
      "axis" => ST_AxisType::parse(value) |> ignore
      "op" => validate_operator_attribute(value)
      "chOrder" => ST_ChildOrderType::parse(value) |> ignore
      "for" | "refFor" => ST_ConstraintRelationship::parse(value) |> ignore
      "func" => ST_FunctionType::parse(value) |> ignore
      "arg" => ST_FunctionArgument::parse(value) |> ignore
      "val" => validate_val_attribute(value)
      "rev"
      | "hideLastTrans"
      | "useDef"
      | "max"
      | "coherent3DOff"
      | "phldr"
      | "custFlipVert"
      | "custFlipHor"
      | "custT"
      | "hideGeom"
      | "lkTxEntry"
      | "blipPhldr" => validate_optional_bool(name, value)
      "idx"
      | "srcOrd"
      | "destOrd"
      | "presStyleIdx"
      | "presStyleCnt"
      | "custAng"
      | "custSzX"
      | "custSzY" => validate_optional_int(name, value)
      "st" | "cnt" | "step" => validate_optional_int(name, value)
      _ => ()
    }
  }
}

///|
fn validate_type_attribute(value : String) -> Unit {
  try ST_PtType::parse(value) |> ignore catch {
    SchemaViolation(_) =>
      try ST_CxnType::parse(value) |> ignore catch {
        SchemaViolation(_) =>
          try ST_AlgorithmType::parse(value) |> ignore catch {
            SchemaViolation(_) =>
              try ST_ParameterId::parse(value) |> ignore catch {
                SchemaViolation(_) =>
                  try ST_ConstraintType::parse(value) |> ignore catch {
                    SchemaViolation(_) =>
                      try ST_ElementType::parse(value) |> ignore catch {
                        SchemaViolation(_) => ()
                      }
                  }
              }
          }
      }
  }
}

///|
fn validate_operator_attribute(value : String) -> Unit raise SchemaViolation {
  try ST_BoolOperator::parse(value) |> ignore catch {
    SchemaViolation(_) => ST_FunctionOperator::parse(value) |> ignore
  }
}

///|
fn validate_val_attribute(value : String) -> Unit raise SchemaViolation {
  if value.length() == 0 {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path="val",
      reason="empty attribute value",
    )
  }
}

///|
fn validate_optional_bool(
  path : String,
  value : String,
) -> Unit raise SchemaViolation {
  if !(value == "true" || value == "false" || value == "1" || value == "0") {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="invalid xsd:boolean value",
    )
  }
}

///|
fn validate_optional_int(
  path : String,
  value : String,
) -> Unit raise SchemaViolation {
  if !is_int(value) {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="invalid xsd:int value",
    )
  }
}

///|
fn require_local(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      schema="dml-diagram.xsd",
      path~,
      reason="unexpected element name",
    )
  }
}
