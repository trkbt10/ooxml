///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "parse namespaces with default prefix and scoped redefinition" {
  let doc = parse(
    bytes(
      "<root xmlns=\"urn:a\" xmlns:p=\"urn:p\"><p:item p:id=\"7\"><child xmlns=\"urn:b\"/></p:item></root>",
    ),
  )
  assert_true(doc.root.name.ns == Some("urn:a"))
  assert_eq(doc.root.name.local_name, "root")
  let item = match doc.root.children[0] {
    Element(element) => element
    _ => fail("expected item element")
  }
  assert_true(item.name.prefix == Some("p"))
  assert_true(item.name.ns == Some("urn:p"))
  assert_true(item.attributes[0].name.ns == Some("urn:p"))
  let child = match item.children[0] {
    Element(element) => element
    _ => fail("expected child element")
  }
  assert_true(child.name.ns == Some("urn:b"))
}

///|
test "is_ncname validates XML namespace NCName lexical forms" {
  assert_true(is_ncname("rId1"))
  assert_true(is_ncname("A5FFC797514BC"))
  assert_true(is_ncname("_name-1.2"))
  assert_true(is_ncname("名1"))
  assert_false(is_ncname(""))
  assert_false(is_ncname("1"))
  assert_false(is_ncname("bad id"))
  assert_false(is_ncname("a:b"))
}

///|
test "decode named and numeric entity references" {
  let doc = parse(
    bytes("<root a=\"&quot;&#65;&#x42;&apos;\">&amp;&lt;&gt;&#x43;</root>"),
  )
  assert_eq(doc.root.attributes[0].value, "\"AB'")
  assert_true(doc.root.children[0] == Text("&<>C"))
}

///|
test "preserve cdata comments and processing instructions" {
  let doc = parse(
    bytes("<root><![CDATA[a < b && c]]><!--ok--><?mso data?></root>"),
  )
  assert_true(doc.root.children[0] == CData("a < b && c"))
  assert_true(doc.root.children[1] == Comment("ok"))
  assert_true(
    doc.root.children[2] ==
    ProcessingInstruction({ target: "mso", data: "data" }),
  )
}

///|
test "reader yields declaration start text and end events" {
  let reader = Reader::new(
    bytes("<?xml version=\"1.0\" encoding=\"UTF-8\"?><a>t</a>"),
  )
  assert_true(
    reader.next() ==
    Some(
      XmlDeclaration({
        version: "1.0",
        encoding: Some("UTF-8"),
        standalone: None,
      }),
    ),
  )
  assert_true(reader.next() is Some(StartElement(_)))
  assert_true(reader.next() == Some(Text("t")))
  assert_true(reader.next() is Some(EndElement(_)))
  assert_true(reader.next() == None)
}

///|
test "write and parse representative document round trip" {
  let doc : Document = {
    declaration: Some({
      version: "1.0",
      encoding: Some("UTF-8"),
      standalone: Some(true),
    }),
    doctype: None,
    root: {
      name: { prefix: None, local_name: "root", ns: Some("urn:root") },
      attributes: [
        {
          name: { prefix: None, local_name: "plain", ns: None },
          value: "a&b\"c'",
        },
      ],
      children: [
        Element({
          name: { prefix: Some("p"), local_name: "item", ns: Some("urn:p") },
          attributes: [
            {
              name: { prefix: Some("p"), local_name: "id", ns: Some("urn:p") },
              value: "42",
            },
          ],
          children: [
            Text("x < y ]]> z"),
            CData("raw <xml>"),
            Comment("note"),
            ProcessingInstruction({ target: "mso", data: "x=\"1\"" }),
          ],
        }),
      ],
    },
  }
  assert_true(parse(write(doc)) == doc)
}

///|
test "writer emits namespace declarations only for changed bindings" {
  let doc : Document = {
    declaration: None,
    doctype: None,
    root: {
      name: { prefix: Some("p"), local_name: "root", ns: Some("urn:one") },
      attributes: [],
      children: [
        Element({
          name: { prefix: Some("p"), local_name: "child", ns: Some("urn:one") },
          attributes: [],
          children: [],
        }),
        Element({
          name: { prefix: Some("p"), local_name: "child", ns: Some("urn:two") },
          attributes: [],
          children: [],
        }),
      ],
    },
  }
  assert_eq(
    @utf8.decode(write(doc)[:]),
    "<p:root xmlns:p=\"urn:one\"><p:child/><p:child xmlns:p=\"urn:two\"/></p:root>",
  )
}

///|
test "default namespace can be cleared in child scope" {
  let doc : Document = {
    declaration: None,
    doctype: None,
    root: {
      name: { prefix: None, local_name: "root", ns: Some("urn:root") },
      attributes: [],
      children: [
        Element({
          name: { prefix: None, local_name: "plain", ns: None },
          attributes: [],
          children: [],
        }),
      ],
    },
  }
  assert_eq(
    @utf8.decode(write(doc)[:]),
    "<root xmlns=\"urn:root\"><plain xmlns=\"\"/></root>",
  )
  let parsed = parse(
    bytes("<root xmlns=\"urn:root\"><plain xmlns=\"\"/></root>"),
  )
  let child = match parsed.root.children[0] {
    Element(element) => element
    _ => fail("expected child element")
  }
  assert_true(child.name.ns == None)
}

///|
test "reject missing close tag" {
  try parse(bytes("<root><child></root>")) catch {
    XmlMalformed(_) => ()
    _ => fail("expected XmlMalformed")
  } noraise {
    _ => fail("expected parse failure")
  }
}

///|
test "reject unbalanced attribute quotes" {
  try parse(bytes("<root a=\"x></root>")) catch {
    XmlMalformed(_) => ()
    _ => fail("expected XmlMalformed")
  } noraise {
    _ => fail("expected parse failure")
  }
}

///|
test "reject undeclared prefix" {
  try parse(bytes("<p:root/>")) catch {
    UndeclaredPrefix(prefix~) => assert_eq(prefix, "p")
    _ => fail("expected UndeclaredPrefix")
  } noraise {
    _ => fail("expected parse failure")
  }
}

///|
test "reject duplicate expanded attributes" {
  try
    parse(bytes("<root xmlns:a=\"u\" xmlns:b=\"u\" a:id=\"1\" b:id=\"2\"/>"))
  catch {
    DuplicateAttribute(name~) => assert_eq(name, "{u}id")
    _ => fail("expected DuplicateAttribute")
  } noraise {
    _ => fail("expected parse failure")
  }
}

///|
/// XML 1.0 §4.3.3 — a leading U+FEFF byte-order mark is a legal
/// encoding signature, not document content.  The parser must skip
/// it and parse the document normally (ECMA-376 ships several XSD
/// parts with a UTF-8 BOM).
test "parse skips a leading UTF-8 byte-order mark" {
  let doc = parse(bytes("\u{FEFF}<root attr=\"v\"><child/></root>"))
  assert_eq(doc.root.name.local_name, "root")
  assert_eq(doc.root.children.length(), 1)
  // A BOM that is NOT at the start stays as ordinary text content.
  let doc2 = parse(bytes("<root>a\u{FEFF}b</root>"))
  match doc2.root.children[0] {
    Text(t) => assert_eq(t, "a\u{FEFF}b")
    _ => fail("expected text node")
  }
}
