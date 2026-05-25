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
) -> @domain.CT_Styles raise @domain.SchemaViolation {
  @domain.CT_Styles::parse(elem("styles", children~))
}

///|
fn prop_value(property : @xml.Element?, local_name : String) -> String? {
  match property {
    Some(element) =>
      // Local re-implementation of child-and-val lookup to keep the
      // wbtest decoupled from the resolver's private helpers.
      first_child_attr_val(element, local_name)
    None => None
  }
}

///|
fn first_child_attr_val(element : @xml.Element, child_name : String) -> String? {
  let mut found : String? = None
  for node in element.children {
    if found is None {
      match node {
        @xml.Element(child) =>
          if child.name.local_name == child_name {
            for attr in child.attributes {
              if found is None && attr.name.local_name == "val" {
                found = Some(attr.value)
              }
            }
          }
        _ => ()
      }
    }
  }
  found
}

///|
test "single style with no basedOn resolves direct properties" {
  let table = styles([
    style("Body", "paragraph", children=[
      child("pPr", children=[child("jc", attributes=[attr("val", "left")])]),
    ]),
  ])
  let effective = effective_properties(table, { value: "Body" })
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
  assert_eq(chain[0].style_id.unwrap().value, "A")
  assert_eq(chain[1].style_id.unwrap().value, "B")
  assert_eq(chain[2].style_id.unwrap().value, "C")
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
  assert_eq(chain[0].style_id.unwrap().value, "A")
  assert_eq(chain[1].style_id.unwrap().value, "B")
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
  let effective = effective_properties(table, { value: "Body" })
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
  let effective = effective_properties(table, { value: "Derived" })
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
  let effective = resolve_paragraph(table, Some(direct))
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
  assert_eq(chain[0].style_id.unwrap().value, "Body")
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
  assert_true(
    table.styles.get("P").unwrap().style_type ==
    Some(@domain.StyleTypeParagraph),
  )
  assert_true(
    table.styles.get("C").unwrap().style_type ==
    Some(@domain.StyleTypeCharacter),
  )
  assert_true(
    table.styles.get("T").unwrap().style_type == Some(@domain.StyleTypeTable),
  )
  assert_true(
    table.styles.get("N").unwrap().style_type ==
    Some(@domain.StyleTypeNumbering),
  )
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
  let effective = resolve_run(table, Some(direct))
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
test "domain CT_Styles round-trips through the resolver" {
  let wrapper = @domain.CT_Styles::new(
    elem("styles", children=[style("Wrapped", "paragraph")]),
  )
  assert_eq(wrapper.resolve_chain({ value: "Wrapped" }).length(), 1)
}

///|
/// §17.7.6 — a table-style with a `<w:tblStylePr w:type="firstRow">`
/// must contribute its `<w:tcPr>` overrides to the first-row cell
/// when `tbl_look.first_row` is true, and must NOT contribute it to
/// the second-row cell.
test "table_style resolves §17.7.6 firstRow override gated by tblLook" {
  // <w:style w:styleId="TblA" w:type="table">
  //   <w:tcPr><w:shd w:val="clear" w:fill="EEEEEE"/></w:tcPr>
  //   <w:tblStylePr w:type="firstRow">
  //     <w:tcPr><w:shd w:val="clear" w:fill="FF0000"/></w:tcPr>
  //   </w:tblStylePr>
  // </w:style>
  let tc_pr_base = child("tcPr", children=[
    child("shd", attributes=[attr("val", "clear"), attr("fill", "EEEEEE")]),
  ])
  let tc_pr_first_row = child("tcPr", children=[
    child("shd", attributes=[attr("val", "clear"), attr("fill", "FF0000")]),
  ])
  let style_a = style("TblA", "table", children=[
    tc_pr_base,
    child("tblStylePr", attributes=[attr("type", "firstRow")], children=[
      tc_pr_first_row,
    ]),
  ])
  let table = styles([style_a])
  let resolved = resolve_table_style(table, { value: "TblA" })
  let tbl_look = TblLook::default_()
  // Row 0, col 0 in a 2x2 table — firstRow + firstColumn buckets
  // both qualify, plus the wholeTable + base; first_row override
  // should layer onto base tcPr so the fill becomes FF0000.
  let row0 = resolve_cell(
    resolved,
    tbl_look,
    0,
    0,
    2,
    2,
    None,
    None,
    None,
    None,
  )
  assert_true(prop_value(row0.tc_pr, "shd") == Some("clear"))
  let shd0 = first_child_named(row0.tc_pr, "shd")
  assert_true(
    shd0.bind(fn(e) { attr_value_local(e, "fill") }) == Some("FF0000"),
  )
  // Row 1, col 0 — not firstRow, so the override must NOT apply;
  // the base tcPr.shd survives with fill=EEEEEE.
  let row1 = resolve_cell(
    resolved,
    tbl_look,
    1,
    0,
    2,
    2,
    None,
    None,
    None,
    None,
  )
  let shd1 = first_child_named(row1.tc_pr, "shd")
  assert_true(
    shd1.bind(fn(e) { attr_value_local(e, "fill") }) == Some("EEEEEE"),
  )
}

///|
/// §17.4.6 — `<w:tblLook>` legacy hex mask "04A0" must set
/// firstRow + firstColumn + no_h_band + no_v_band per the spec
/// bit layout.
test "tblLook decodes the legacy 0x04A0 hex mask" {
  let tbl_look_el : @xml.Element = elem("tblLook", attributes=[
    attr("val", "04A0"),
  ])
  let tl = TblLook::from_element(tbl_look_el)
  // 0x04A0 = 0x0400 (noVBand) | 0x0080 (firstColumn) | 0x0020 (firstRow)
  inspect(tl.first_row, content="true")
  inspect(tl.last_row, content="false")
  inspect(tl.first_column, content="true")
  inspect(tl.last_column, content="false")
  inspect(tl.no_h_band, content="false")
  inspect(tl.no_v_band, content="true")
}

///|
/// Helper — return the first child element of `parent` with the
/// given local name.
fn first_child_named(
  parent : @xml.Element?,
  local_name : String,
) -> @xml.Element? {
  match parent {
    None => None
    Some(p) => {
      for node in p.children {
        match node {
          @xml.Element(child) =>
            if child.name.local_name == local_name {
              return Some(child)
            }
          _ => ()
        }
      }
      None
    }
  }
}

///|
/// Helper — first attribute value by local name.
fn attr_value_local(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}
