///|
fn qname(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
fn attr(local_name : String, value : String) -> @xml.Attribute {
  { name: qname(local_name), value }
}

///|
fn text_element(local_name : String, value : String) -> @xml.Element {
  {
    name: qname(local_name),
    attributes: [],
    children: [@xml.Node::Text(value)],
  }
}

///|
fn element(
  local_name : String,
  attributes? : Array[@xml.Attribute] = [],
  children? : Array[@xml.Node] = [],
) -> @xml.Element {
  { name: qname(local_name), attributes, children }
}

///|
fn cell(t? : String, v? : String, inline? : String) -> @domain.CT_Cell {
  let attributes = match t {
    Some(value) => [attr("t", value)]
    None => []
  }
  let children = match (v, inline) {
    (Some(value), _) => [@xml.Node::Element(text_element("v", value))]
    (_, Some(value)) =>
      [
        @xml.Node::Element(
          element("is", children=[@xml.Node::Element(text_element("t", value))]),
        ),
      ]
    _ => []
  }
  try! @domain.CT_Cell::new(element("c", attributes~, children~))
}

///|
fn sst(children : Array[@xml.Node]) -> @domain.CT_Sst {
  try! @domain.CT_Sst::new(element("sst", children~))
}

///|
fn si(text : String) -> @xml.Node {
  @xml.Node::Element(
    element("si", children=[@xml.Node::Element(text_element("t", text))]),
  )
}

///|
fn dt(
  year : Int,
  month : Int,
  day : Int,
  hour : Int,
  minute : Int,
  second : Int,
  millisecond? : Int = 0,
) -> @date_serial.CalendarDateTime {
  { year, month, day, hour, minute, second, millisecond }
}

///|
fn assert_close(actual : Double, expected : Double) -> Unit raise {
  assert_true(actual.is_close(expected, absolute_tolerance=0.0000001))
}

///|
test "§18.18.11 b decodes boolean true and false" {
  assert_true(try! (decode_cell_value(cell(t="b", v="1")) == Boolean(true)))
  assert_true(try! (decode_cell_value(cell(t="b", v="0")) == Boolean(false)))
}

///|
test "§18.18.11 d decodes ISO 8601 date-time" {
  assert_true(
    (try! decode_cell_value(cell(t="d", v="2024-12-31T23:59:59"))) ==
    Date(dt(2024, 12, 31, 23, 59, 59)),
  )
  assert_true(
    (try! decode_cell_value(cell(t="d", v="2024-12-31"))) ==
    Date(dt(2024, 12, 31, 0, 0, 0)),
  )
  assert_true(
    (try! decode_cell_value(cell(t="d", v="2024-12-31T23:59"))) ==
    Date(dt(2024, 12, 31, 23, 59, 0)),
  )
}

///|
test "§18.18.11 e decodes error literal" {
  assert_true(
    (try! decode_cell_value(cell(t="e", v="#DIV/0!"))) == Error("#DIV/0!"),
  )
}

///|
test "§18.18.11 inlineStr decodes inline rich text" {
  assert_true(
    (try! decode_cell_value(cell(t="inlineStr", inline="hello"))) ==
    InlineString("hello"),
  )
}

///|
test "§18.18.11 n decodes explicit and default numbers" {
  assert_true((try! decode_cell_value(cell(t="n", v="3.14"))) == Number(3.14))
  assert_true((try! decode_cell_value(cell(v="42"))) == Number(42.0))
}

///|
test "§18.18.11 s preserves unresolved shared string index" {
  assert_true(
    (try! decode_cell_value_with_sst(cell(t="s", v="5"), None)) ==
    SharedStringIndex(5),
  )
}

///|
test "§18.18.11 s lookup miss raises SchemaViolation" {
  let table = sst([])
  assert_true(
    (try? decode_cell_value_with_sst(cell(t="s", v="5"), Some(table)))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "§18.18.11 s resolves shared string through SST" {
  let table = sst([si("shared text")])
  assert_true(
    (try! decode_cell_value_with_sst(cell(t="s", v="0"), Some(table))) ==
    InlineString("shared text"),
  )
}

///|
test "§18.18.11 str decodes formula string" {
  assert_true(
    (try! decode_cell_value(cell(t="str", v="computed"))) ==
    FormulaString("computed"),
  )
}

///|
test "§18.3.1.4 empty cell decodes distinctly" {
  assert_true(try! (decode_cell_value(cell()) == Empty))
}

///|
test "§18.18.11 rejects malformed discriminator payloads" {
  assert_true(
    (try? decode_cell_value(cell(t="b", v="foo")))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? decode_cell_value(cell(t="d", v="2024-12-31T23:59:59+09:00")))
    is Err(@opc_errors.SchemaViolation(_)),
  )
  assert_true(
    (try? decode_cell_value(cell(t="unknown", v="1")))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}

///|
test "§18.18.11 display text coercion covers all variants" {
  assert_eq(Boolean(true).to_display_text(), "TRUE")
  assert_eq(Boolean(false).to_display_text(), "FALSE")
  assert_eq(
    Date(dt(2024, 12, 31, 23, 59, 59)).to_display_text(),
    "2024-12-31T23:59:59",
  )
  assert_eq(Error("#N/A").to_display_text(), "#N/A")
  assert_eq(InlineString("inline").to_display_text(), "inline")
  assert_eq(Number(3.14).to_display_text(), "3.14")
  assert_eq(SharedStringIndex(5).to_display_text(), "5")
  assert_eq(FormulaString("computed").to_display_text(), "computed")
  assert_eq(Empty.to_display_text(), "")
}

///|
test "§18.18.11 numeric coercion covers boolean number date and empty" {
  assert_close(
    try! Boolean(true).to_number(@date_serial.DateSystem::Serial1900),
    1.0,
  )
  assert_close(
    try! Boolean(false).to_number(@date_serial.DateSystem::Serial1900),
    0.0,
  )
  assert_close(
    try! Number(3.14).to_number(@date_serial.DateSystem::Serial1900),
    3.14,
  )
  assert_close(try! Empty.to_number(@date_serial.DateSystem::Serial1900), 0.0)
  assert_close(
    try! Date(dt(1900, 1, 1, 0, 0, 0)).to_number(
      @date_serial.DateSystem::Serial1900,
    ),
    2.0,
  )
  assert_close(
    try! Date(dt(1904, 1, 1, 0, 0, 0)).to_number(
      @date_serial.DateSystem::Serial1904,
    ),
    0.0,
  )
  assert_true(
    (try? InlineString("x").to_number(@date_serial.DateSystem::Serial1900))
    is Err(@opc_errors.SchemaViolation(_)),
  )
}
