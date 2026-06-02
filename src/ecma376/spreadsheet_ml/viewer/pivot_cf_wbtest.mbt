// §18.3.1.18 — worksheet conditional formatting applied to pivot value
// cells (Excel stores pivot CF as a sheet `<conditionalFormatting>`
// block over the pivot region; `pivot_value_cf_style` reuses the shared
// `apply_cf_overlay` evaluator).

///|
test "pivot_value_cf_style is a no-op without conditional formatting" {
  let (fill, font) = pivot_value_cf_style(
    2,
    1,
    @formula.VNumber(5.0),
    default_render_options(),
    [],
    [],
    None,
    None,
    SmlThemeColorMap::empty(),
    SmlThemeFontMap::empty(),
  )
  assert_true(fill is None)
  assert_true(font is None)
}

///|
test "pivot_value_cf_style skips non-numeric values" {
  // A text aggregate cannot drive a value-based CF rule.
  let (fill, font) = pivot_value_cf_style(
    0,
    0,
    @formula.VString("abc"),
    default_render_options(),
    [],
    [],
    None,
    None,
    SmlThemeColorMap::empty(),
    SmlThemeFontMap::empty(),
  )
  assert_true(fill is None)
  assert_true(font is None)
}

///|
fn pivot_cf_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn pivot_cf_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: pivot_cf_name(local_name), value }
}

///|
fn pivot_cf_node(
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element({
    name: pivot_cf_name(local_name),
    attributes: attrs,
    children,
  })
}

///|
fn pivot_cf_scheme_font_styles() -> @domain.CT_Stylesheet {
  @domain.CT_Stylesheet::new({
    name: pivot_cf_name("styleSheet"),
    attributes: [],
    children: [
      pivot_cf_node("dxfs", [pivot_cf_attr("count", "1")], [
        pivot_cf_node("dxf", [], [
          pivot_cf_node("font", [], [
            pivot_cf_node("name", [pivot_cf_attr("val", "Pivot Placeholder")], []),
            pivot_cf_node("scheme", [pivot_cf_attr("val", "minor")], []),
          ]),
          pivot_cf_node("fill", [], [
            pivot_cf_node(
              "patternFill",
              [pivot_cf_attr("patternType", "solid")],
              [pivot_cf_node("fgColor", [pivot_cf_attr("rgb", "FFFF0000")], [])],
            ),
          ]),
        ]),
      ]),
    ],
  })
}

///|
fn pivot_cf_cell_is_block(sqref : String) -> @domain.CT_ConditionalFormatting {
  try! @domain.CT_ConditionalFormatting::new({
    name: pivot_cf_name("conditionalFormatting"),
    attributes: [pivot_cf_attr("sqref", sqref)],
    children: [
      pivot_cf_node(
        "cfRule",
        [
          pivot_cf_attr("type", "cellIs"),
          pivot_cf_attr("operator", "greaterThan"),
          pivot_cf_attr("dxfId", "0"),
          pivot_cf_attr("priority", "1"),
        ],
        [pivot_cf_node("formula", [], [@xml.Node::Text("0")])],
      ),
    ],
  })
}

///|
test "pivot_value_cf_style resolves dxf font scheme through theme font map" {
  let theme_fonts : SmlThemeFontMap = {
    major_latin: None,
    minor_latin: Some("Pivot Theme Minor"),
  }
  let cf_block = pivot_cf_cell_is_block("B2")
  assert_eq(cf_block.rules.length(), 1)
  assert_true(sqref_contains(cf_block.sqref, 2, 2))
  let (fill, font) = pivot_value_cf_style(
    1,
    1,
    @formula.VNumber(100.0),
    default_render_options(),
    [cf_block],
    [{ values: [@formula.VNumber(100.0)] }],
    Some(pivot_cf_scheme_font_styles()),
    None,
    SmlThemeColorMap::empty(),
    theme_fonts,
  )
  assert_true(fill == Some("#FF0000"))
  match font {
    Some(f) => assert_eq(f.family, "Pivot Theme Minor")
    None => abort("expected pivot dxf font override")
  }
}

///|
test "pivot_cell renders a resolved dxf font family override" {
  let font : ResolvedFont = {
    family: "Pivot Theme Minor",
    size: 11.0,
    bold: false,
    italic: false,
    underline: false,
    strikethrough: false,
    color: None,
  }
  let node = pivot_cell(
    0.0,
    0.0,
    50.0,
    20.0,
    "100",
    default_render_options(),
    false,
    false,
    false,
    false,
    text_font=Some(font),
  )
  let svg = match node {
    @xml.Node::Element(e) => @markup.serialize_svg(e)
    _ => ""
  }
  assert_true(
    svg.contains("font-family=\"&apos;Pivot Theme Minor&apos;, sans-serif\""),
  )
}

///|
test "render_pivot_overlay threads dxf scheme font to pivot value text" {
  let theme_fonts : SmlThemeFontMap = {
    major_latin: None,
    minor_latin: Some("Pivot Theme Minor"),
  }
  let svg = pivot_test_svg(
    render_pivot_overlay(
      pivot_test_basic_materialized("A1:B2"),
      pivot_test_layout(),
      default_render_options(),
      [pivot_cf_cell_is_block("B2")],
      [{ values: [@formula.VNumber(100.0)] }],
      Some(pivot_cf_scheme_font_styles()),
      None,
      SmlThemeColorMap::empty(),
      theme_fonts,
      max_digit_width_px=7.0,
    ),
  )
  assert_true(
    svg.contains("font-family=\"&apos;Pivot Theme Minor&apos;, sans-serif\""),
  )
  assert_true(svg.contains("fill=\"#FF0000\""))
  assert_false(svg.contains("Pivot Placeholder"))
}
