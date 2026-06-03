///|
fn shared_string_test_name(local_name : String) -> @xml.QName {
  {
    prefix: None,
    local_name,
    ns: Some("http://schemas.openxmlformats.org/spreadsheetml/2006/main"),
  }
}

///|
fn shared_string_test_text(value : String) -> @xml.Node {
  @xml.Node::Element({
    name: shared_string_test_name("t"),
    attributes: [],
    children: [@xml.Node::Text(value)],
  })
}

///|
fn shared_string_test_run(value : String) -> @xml.Node {
  @xml.Node::Element({
    name: shared_string_test_name("r"),
    attributes: [],
    children: [shared_string_test_text(value)],
  })
}

///|
fn shared_string_test_si(children : Array[@xml.Node]) -> @xml.Node {
  @xml.Node::Element({
    name: shared_string_test_name("si"),
    attributes: [],
    children,
  })
}

///|
fn shared_string_test_sst(children : Array[@xml.Node]) -> CT_Sst {
  try! CT_Sst::new({
    name: shared_string_test_name("sst"),
    attributes: [],
    children,
  })
}

///|
test "shared string lookup empty table" {
  let sst = shared_string_test_sst([])
  assert_eq(sst.count(), 0)
  assert_true(sst.lookup(0) == None)
}

///|
test "shared string lookup single plain string" {
  let sst = shared_string_test_sst([
    shared_string_test_si([shared_string_test_text("hello")]),
  ])
  assert_eq(sst.count(), 1)
  assert_true(sst.lookup(0) == Some("hello"))
  assert_true(sst.lookup(1) == None)
}

///|
test "shared string lookup concatenates rich text runs" {
  let sst = shared_string_test_sst([
    shared_string_test_si([
      shared_string_test_run("foo"),
      shared_string_test_run("bar"),
    ]),
  ])
  assert_eq(sst.count(), 1)
  assert_true(sst.lookup(0) == Some("foobar"))
}

///|
test "shared string lookup handles mixed plain and rich entries" {
  let sst = shared_string_test_sst([
    shared_string_test_si([shared_string_test_text("plain")]),
    shared_string_test_si([
      shared_string_test_run("rich"),
      shared_string_test_run(" text"),
    ]),
  ])
  assert_eq(sst.count(), 2)
  assert_true(sst.lookup(0) == Some("plain"))
  assert_true(sst.lookup(1) == Some("rich text"))
}

///|
test "shared string lookup preserves xml space text" {
  let sst = shared_string_test_sst([
    @xml.Node::Element({
      name: shared_string_test_name("si"),
      attributes: [],
      children: [
        @xml.Node::Element({
          name: shared_string_test_name("t"),
          attributes: [
            {
              name: {
                prefix: Some("xml"),
                local_name: "space",
                ns: Some(@xml.ns_xml_1998()),
              },
              value: "preserve",
            },
          ],
          children: [@xml.Node::Text("  spaced  ")],
        }),
      ],
    }),
  ])
  assert_eq(sst.count(), 1)
  assert_true(sst.lookup(0) == Some("  spaced  "))
}

///|
test "shared string lookup ignores phonetic markup" {
  let sst = shared_string_test_sst([
    shared_string_test_si([
      shared_string_test_text("foo"),
      @xml.Node::Element({
        name: shared_string_test_name("rPh"),
        attributes: [],
        children: [shared_string_test_text("X")],
      }),
    ]),
  ])
  assert_eq(sst.count(), 1)
  assert_true(sst.lookup(0) == Some("foo"))
}
