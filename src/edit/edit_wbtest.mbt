///|
priv struct Counter {
  mut count : Int
}

///|
fn p() -> @xml.Element {
  let qn = fn(name : String) -> @xml.QName {
    { prefix: Some("w"), local_name: name, ns: Some("urn:w") }
  }
  let r1 : @xml.Element = {
    name: qn("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: qn("t"),
        attributes: [],
        children: [@xml.Node::Text("hello")],
      }),
    ],
  }
  let r2 : @xml.Element = {
    name: qn("r"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: qn("t"),
        attributes: [],
        children: [@xml.Node::Text("world")],
      }),
    ],
  }
  {
    name: qn("p"),
    attributes: [unprefixed_attribute("paraId", "42")],
    children: [@xml.Node::Element(r1), @xml.Node::Element(r2)],
  }
}

///|
test "find_first matches a deeply nested descendant" {
  let tree = p()
  let t = find_first(tree, by_local_name("t"))
  assert_true(t is Some(_))
  assert_eq(text_content(t.unwrap()), "hello")
}

///|
test "find_all returns every t descendant in document order" {
  let tree = p()
  let ts = find_all(tree, by_local_name("t"))
  assert_eq(ts.length(), 2)
  assert_eq(text_content(ts[0]), "hello")
  assert_eq(text_content(ts[1]), "world")
}

///|
test "by_qname disambiguates across namespaces" {
  let tree = p()
  assert_true(find_first(tree, by_qname("t", "urn:w")) is Some(_))
  assert_true(find_first(tree, by_qname("t", "urn:other")) is None)
}

///|
test "append_child appends at the end and preserves siblings" {
  let tree = p()
  let qn = tree.name
  let extra : @xml.Element = empty_element(qn, "r")
  let updated = append_child(tree, @xml.Node::Element(extra))
  let runs = direct_children(updated, by_local_name("r"))
  assert_eq(runs.length(), 3)
}

///|
test "insert_child inserts at position and clamps oversize index" {
  let tree = p()
  let qn = tree.name
  let extra : @xml.Element = empty_element(qn, "r")
  let inserted = insert_child(tree, 1, @xml.Node::Element(extra))
  let runs = direct_children(inserted, by_local_name("r"))
  assert_eq(runs.length(), 3)
  // Clamping: position > children.length still appends.
  let inserted_high = insert_child(tree, 999, @xml.Node::Element(extra))
  assert_eq(direct_children(inserted_high, by_local_name("r")).length(), 3)
}

///|
test "remove_children drops every matching direct child" {
  let tree = p()
  let stripped = remove_children(tree, by_local_name("r"))
  assert_eq(direct_children(stripped, by_local_name("r")).length(), 0)
}

///|
test "replace_children swaps matching direct children for replacement" {
  let tree = p()
  let qn = tree.name
  let replacement : @xml.Element = empty_element(qn, "r")
  let swapped = replace_children(tree, by_local_name("r"), replacement)
  assert_eq(direct_children(swapped, by_local_name("r")).length(), 2)
  // Every remaining <r> is now the empty replacement.
  for r in direct_children(swapped, by_local_name("r")) {
    assert_eq(r.children.length(), 0)
  }
}

///|
test "set_attribute replaces existing value" {
  let tree = p()
  let updated = set_attribute(tree, unprefixed_attribute("paraId", "99"))
  assert_eq(attribute_by_local_name(updated, "paraId"), Some("99"))
}

///|
test "remove_attribute drops the matching attribute" {
  let tree = p()
  let qn : @xml.QName = { prefix: None, local_name: "paraId", ns: None }
  let updated = remove_attribute(tree, qn)
  assert_true(attribute_by_local_name(updated, "paraId") is None)
}

///|
test "update_first patches the first match only" {
  let tree = p()
  let updated = update_first(tree, by_local_name("t"), fn(e) {
    {
      name: e.name,
      attributes: e.attributes,
      children: [@xml.Node::Text("patched")],
    }
  })
  let ts = find_all(updated, by_local_name("t"))
  assert_eq(text_content(ts[0]), "patched")
  assert_eq(text_content(ts[1]), "world")
}

///|
test "map_subtree visits every element bottom-up" {
  let tree = p()
  let counter : Counter = { count: 0 }
  let _ = map_subtree(tree, fn(e) {
    counter.count = counter.count + 1
    e
  })
  // Tree has 5 elements: p + 2x r + 2x t.
  assert_eq(counter.count, 5)
}
