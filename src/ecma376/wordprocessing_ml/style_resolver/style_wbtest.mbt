///|
let w_ns = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

///|
fn qn(local_name : String) -> @xml.QName {
  { prefix: Some("w"), local_name, ns: Some(w_ns) }
}

///|
fn attr(local_name : String, value : String) -> @xml.Attribute {
  { name: qn(local_name), value }
}

///|
fn elem(
  local_name : String,
  attributes? : Array[@xml.Attribute] = [],
  children? : Array[@xml.Node] = [],
) -> @xml.Element {
  { name: qn(local_name), attributes, children }
}

///|
fn child(
  local_name : String,
  attributes? : Array[@xml.Attribute] = [],
  children? : Array[@xml.Node] = [],
) -> @xml.Node {
  @xml.Element(elem(local_name, attributes~, children~))
}

///|
fn style(
  style_id : String,
  style_type : String,
  children? : Array[@xml.Node] = [],
  default? : Bool = false,
) -> @xml.Node {
  let attributes = if default {
    [attr("styleId", style_id), attr("type", style_type), attr("default", "1")]
  } else {
    [attr("styleId", style_id), attr("type", style_type)]
  }
  @xml.Element(elem("style", attributes~, children~))
}

///|
fn styles(
  children : Array[@xml.Node],
) -> StyleTable raise @opc_errors.SchemaViolation {
  StyleTable::from_element(elem("styles", children~))
}

///|
fn prop_value(property : @xml.Element?, local_name : String) -> String? {
  match property {
    Some(element) =>
      match child_element(element, local_name) {
        Some(child) => attr_value(child, "val")
        None => None
      }
    None => None
  }
}

///|
test "single style with no basedOn resolves direct properties" {
  let table = styles([
    style("Body", "paragraph", children=[
      child("pPr", children=[child("jc", attributes=[attr("val", "left")])]),
    ]),
  ])
  let effective = table.effective_properties({ value: "Body" })
  assert_true(prop_value(effective.p_pr, "jc") == Some("left"))
  assert_eq(table.resolve_chain({ value: "Body" }).length(), 1)
}

///|
test "basedOn chain follows derived to root" {
  let table = styles([
    style("A", "paragraph", children=[
      child("basedOn", attributes=[attr("val", "B")]),
    ]),
    style("B", "paragraph", children=[
      child("basedOn", attributes=[attr("val", "C")]),
    ]),
    style("C", "paragraph"),
  ])
  let chain = table.resolve_chain({ value: "A" })
  assert_eq(chain.length(), 3)
  assert_eq(chain[0].style_id.value, "A")
  assert_eq(chain[1].style_id.value, "B")
  assert_eq(chain[2].style_id.value, "C")
}

///|
test "cycle in basedOn chain visits each style once" {
  let table = styles([
    style("A", "paragraph", children=[
      child("basedOn", attributes=[attr("val", "B")]),
    ]),
    style("B", "paragraph", children=[
      child("basedOn", attributes=[attr("val", "A")]),
    ]),
  ])
  let chain = table.resolve_chain({ value: "A" })
  assert_eq(chain.length(), 2)
  assert_eq(chain[0].style_id.value, "A")
  assert_eq(chain[1].style_id.value, "B")
}

///|
test "docDefaults apply as implicit paragraph and run base" {
  let table = styles([
    @xml.Element(
      elem("docDefaults", children=[
        child("pPrDefault", children=[
          child("pPr", children=[
            child("spacing", attributes=[attr("val", "240")]),
          ]),
        ]),
        child("rPrDefault", children=[
          child("rPr", children=[child("b", attributes=[attr("val", "1")])]),
        ]),
      ]),
    ),
    style("Body", "paragraph"),
  ])
  let effective = table.effective_properties({ value: "Body" })
  assert_true(prop_value(effective.p_pr, "spacing") == Some("240"))
  assert_true(prop_value(effective.r_pr, "b") == Some("1"))
}

///|
test "derived paragraph property replaces base property by local name" {
  let table = styles([
    style("Base", "paragraph", children=[
      child("pPr", children=[
        child("jc", attributes=[attr("val", "left")]),
        child("spacing", attributes=[attr("val", "120")]),
      ]),
    ]),
    style("Derived", "paragraph", children=[
      child("basedOn", attributes=[attr("val", "Base")]),
      child("pPr", children=[child("jc", attributes=[attr("val", "right")])]),
    ]),
  ])
  let effective = table.effective_properties({ value: "Derived" })
  assert_true(prop_value(effective.p_pr, "jc") == Some("right"))
  assert_true(prop_value(effective.p_pr, "spacing") == Some("120"))
}

///|
test "linkedTo metadata is extracted from link child" {
  let table = styles([
    style("Para", "paragraph", children=[
      child("link", attributes=[attr("val", "Char")]),
      child("next", attributes=[attr("val", "NextPara")]),
    ]),
    style("Char", "character"),
  ])
  let para = table.styles.get("Para").unwrap()
  assert_true(para.linked_to == Some({ value: "Char" }))
  assert_true(para.next == Some({ value: "NextPara" }))
}

///|
test "linkedTo metadata is also accepted from linkedTo child" {
  let table = styles([
    style("Char", "character", children=[
      child("linkedTo", attributes=[attr("val", "Para")]),
    ]),
  ])
  let char_style = table.styles.get("Char").unwrap()
  assert_true(char_style.linked_to == Some({ value: "Para" }))
}

///|
test "direct paragraph override wins over inherited style property" {
  let table = styles([
    style("Body", "paragraph", children=[
      child("pPr", children=[child("jc", attributes=[attr("val", "left")])]),
    ]),
  ])
  let direct = elem("pPr", children=[
    child("pStyle", attributes=[attr("val", "Body")]),
    child("jc", attributes=[attr("val", "center")]),
  ])
  let effective = table.resolve_paragraph(Some(direct))
  assert_true(prop_value(effective.p_pr, "jc") == Some("center"))
}

///|
test "missing basedOn parent stops chain without error" {
  let table = styles([
    style("Body", "paragraph", children=[
      child("basedOn", attributes=[attr("val", "Missing")]),
    ]),
  ])
  let chain = table.resolve_chain({ value: "Body" })
  assert_eq(chain.length(), 1)
  assert_eq(chain[0].style_id.value, "Body")
}

///|
test "unknown style lookup returns empty chain" {
  let table = styles([style("Body", "paragraph")])
  let chain = table.resolve_chain({ value: "Missing" })
  assert_eq(chain.length(), 0)
}

///|
test "style type discriminator parses all four style families" {
  let table = styles([
    style("P", "paragraph"),
    style("C", "character"),
    style("T", "table"),
    style("N", "numbering"),
  ])
  assert_true(table.styles.get("P").unwrap().style_type == Paragraph)
  assert_true(table.styles.get("C").unwrap().style_type == Character)
  assert_true(table.styles.get("T").unwrap().style_type == Table)
  assert_true(table.styles.get("N").unwrap().style_type == Numbering)
}

///|
test "direct run override wins over inherited run style property" {
  let table = styles([
    style("Emphasis", "character", children=[
      child("rPr", children=[child("color", attributes=[attr("val", "000000")])]),
    ]),
  ])
  let direct = elem("rPr", children=[
    child("rStyle", attributes=[attr("val", "Emphasis")]),
    child("color", attributes=[attr("val", "FF0000")]),
  ])
  let effective = table.resolve_run(Some(direct))
  assert_true(prop_value(effective.r_pr, "color") == Some("FF0000"))
}

///|
test "default attribute and display name are extracted" {
  let table = styles([
    style("Normal", "paragraph", default=true, children=[
      child("name", attributes=[attr("val", "Normal")]),
    ]),
  ])
  let normal = table.styles.get("Normal").unwrap()
  assert_true(normal.is_default)
  assert_true(normal.name == Some("Normal"))
}

///|
test "CT_Styles wrapper can be resolved without changing domain shape" {
  let wrapper = @domain.CT_Styles::new(
    elem("styles", children=[style("Wrapped", "paragraph")]),
  )
  let table = StyleTable::from_ct_styles(wrapper)
  assert_eq(table.resolve_chain({ value: "Wrapped" }).length(), 1)
}
