///|
fn element(
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  {
    name: { prefix: Some("mc"), local_name, ns: Some("urn:mc") },
    attributes: attrs,
    children,
  }
}

///|
fn attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name, ns: None }, value }
}

///|
test "AlternateContent selects first supported choice" {
  let ac = parse_alternate_content(
    element("AlternateContent", [], [
      @xml.Node::Element(
        element("Choice", [attr("Requires", "w14")], [@xml.Node::Text("new")]),
      ),
      @xml.Node::Element(
        element("Choice", [attr("Requires", "w15")], [@xml.Node::Text("newer")]),
      ),
      @xml.Node::Element(element("Fallback", [], [@xml.Node::Text("old")])),
    ]),
  )
  assert_true(ac.evaluate(["w15"]) == [@xml.Node::Text("newer")])
  assert_true(ac.evaluate(["w14", "w15"]) == [@xml.Node::Text("new")])
}

///|
test "AlternateContent falls back when choices are unsupported" {
  let ac = parse_alternate_content(
    element("AlternateContent", [], [
      @xml.Node::Element(
        element("Choice", [attr("Requires", "w14 w15")], [
          @xml.Node::Text("new"),
        ]),
      ),
      @xml.Node::Element(element("Fallback", [], [@xml.Node::Text("old")])),
    ]),
  )
  assert_true(ac.evaluate(["w14"]) == [@xml.Node::Text("old")])
}

///|
test "markup compatibility token list helpers trim whitespace" {
  @debug.assert_eq(parse_ignorable("  w14   w15 "), ["w14", "w15"])
  @debug.assert_eq(parse_process_content("w14:para w15:run"), ["w14:para", "w15:run"])
  @debug.assert_eq(parse_preserve_attributes("w14:attr"), ["w14:attr"])
  @debug.assert_eq(parse_preserve_elements("w15:el"), ["w15:el"])
}
