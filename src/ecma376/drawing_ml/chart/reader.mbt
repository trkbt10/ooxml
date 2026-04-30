///|
/// Read top-level XSD element chartSpace (§21.2) as CT_ChartSpace.
pub fn read_chart_space(bytes : Bytes) -> ChartSpace raise {
  let root = @xml.parse(bytes).root
  require_local(root, "chartSpace", "chartSpace")
  validate_chart_element(root)
  { element: root }
}

///|
/// Read top-level XSD element userShapes (§21.2) as cdr:CT_Drawing.
pub fn read_user_shapes(bytes : Bytes) -> UserShapes raise {
  let root = @xml.parse(bytes).root
  require_local(root, "userShapes", "userShapes")
  validate_chart_element(root)
  { element: root }
}

///|
/// Read top-level XSD element chart (§21.2) as CT_RelId.
pub fn read_chart(bytes : Bytes) -> Chart raise {
  let root = @xml.parse(bytes).root
  require_local(root, "chart", "chart")
  validate_chart_element(root)
  { element: root }
}

///|
fn validate_chart_element(element : @xml.Element) -> Unit raise SchemaViolation {
  validate_chart_attributes(element)
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) => validate_chart_element(child_element)
      _ => ()
    }
  }
}

///|
fn validate_chart_attributes(
  element : @xml.Element,
) -> Unit raise SchemaViolation {
  for attribute in element.attributes {
    let name = attribute.name.local_name
    let value = attribute.value
    match name {
      "layoutTarget" => ST_LayoutTarget::parse(value) |> ignore
      "layoutMode" => ST_LayoutMode::parse(value) |> ignore
      "barDir" => ST_BarDir::parse(value) |> ignore
      "grouping" => ST_Grouping::parse(value) |> ignore
      "scatterStyle" => ST_ScatterStyle::parse(value) |> ignore
      "radarStyle" => ST_RadarStyle::parse(value) |> ignore
      "legendPos" => ST_LegendPos::parse(value) |> ignore
      "dispBlanksAs" => ST_DispBlanksAs::parse(value) |> ignore
      "pageSetupOrientation" => ST_PageSetupOrientation::parse(value) |> ignore
      "val" => validate_non_empty("dml-chart.xsd", "val", value)
      _ => ()
    }
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
      schema="dml-chart.xsd",
      path~,
      reason="unexpected element name",
    )
  }
}
