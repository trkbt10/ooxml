// §20.5 SpreadsheetDrawing colour bridge — shape/text/connector fills
// must use the same DrawingML paint resolver as charts.

///|
fn xdr_color_qn(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn xdr_color_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: xdr_color_qn(local_name), value }
}

///|
fn xdr_color_el(
  local_name : String,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: xdr_color_qn(local_name), attributes, children }
}

///|
fn xdr_color_node(
  local_name : String,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element(xdr_color_el(local_name, attributes, children))
}

///|
fn xdr_color_theme() -> SmlThemeColorMap {
  let map = SmlThemeColorMap::empty()
  map.slots[4] = Some("123456")
  map.slots[5] = Some("ed7d31")
  map
}

///|
fn xdr_solid_fill(color_node : @xml.Node) -> @xml.Node {
  xdr_color_node("solidFill", [], [color_node])
}

///|
test "SpreadsheetML drawing shape fill resolves scheme colors through paint SoT" {
  let sp_pr = xdr_color_el("spPr", [], [
    xdr_solid_fill(
      xdr_color_node("schemeClr", [xdr_color_attr("val", "accent1")], []),
    ),
  ])
  let ctx = paint_ctx_from_sml_theme(xdr_color_theme())
  assert_eq(
    resolve_shape_solid_color(sp_pr, "solidFill", "currentColor", ctx),
    "#123456",
  )
}

///|
test "SpreadsheetML drawing text fill resolves preset colors through paint SoT" {
  let r_pr = xdr_color_el("rPr", [], [
    xdr_solid_fill(
      xdr_color_node("prstClr", [xdr_color_attr("val", "red")], []),
    ),
  ])
  let ctx = paint_ctx_from_sml_theme(xdr_color_theme())
  @debug.debug_inspect(
    drawing_text_color(r_pr, ctx),
    content=(
      #|Some("#ff0000")
    ),
  )
}

///|
test "SpreadsheetML drawing connector stroke resolves scheme colors" {
  let sp_pr = xdr_color_el("spPr", [], [
    xdr_color_node("ln", [xdr_color_attr("w", "19050")], [
      xdr_solid_fill(
        xdr_color_node("schemeClr", [xdr_color_attr("val", "accent2")], []),
      ),
    ]),
  ])
  let (stroke, width) = drawing_connector_stroke(sp_pr, xdr_color_theme())
  assert_eq(stroke, "#ed7d31")
  assert_eq(width, 2.0)
}
