///|
/// A no-namespace element serialises to a bare fragment.
test "markup serialize emits a plain element fragment" {
  let root : @xml.Element = {
    name: qname("mrow"),
    attributes: [attr("class", "x")],
    children: [text("hi")],
  }
  let s = serialize(root)
  inspect(s, content=(
    #|<mrow class="x">hi</mrow>
  ))
}

///|
/// An empty element serialises as a self-closing tag.
test "markup serialize emits self-closing empty element" {
  let root : @xml.Element = {
    name: qname("br"),
    attributes: [],
    children: [],
  }
  inspect(serialize(root), content="<br/>")
}

///|
/// Attribute values and text nodes are escaped: an OOXML payload
/// carrying `<`, `&`, `"` cannot break out of its context.
test "markup serialize escapes attributes and text" {
  let root : @xml.Element = {
    name: qname("text"),
    attributes: [attr("title", "a \"b\" <c> & d")],
    children: [text("x < y & \"z\"")],
  }
  let s = serialize(root)
  // The attribute value escapes all five predefined entities.
  assert_true(s.contains("title=\"a &quot;b&quot; &lt;c&gt; &amp; d\""))
  // Text content escapes `<` and `&`.
  assert_true(s.contains(">x &lt; y &amp; \"z\"<"))
  // No raw markup survives.
  assert_false(s.contains("<c>"))
}

///|
/// An SVG tree built in `svg_ns` emits exactly one `xmlns`
/// declaration — on the root — and none on the descendants.
test "markup serialize_svg declares the SVG namespace once" {
  let root : @xml.Element = {
    name: qname_ns("svg", svg_ns),
    attributes: [attr("width", "100")],
    children: [
      elem_ns("rect", svg_ns, [attr("x", "0")], []),
      elem_ns(
        "g",
        svg_ns,
        [],
        [elem_ns("circle", svg_ns, [attr("r", "5")], [])],
      ),
    ],
  }
  let s = serialize_svg(root)
  // The namespace is declared on <svg> exactly once; descendants
  // inherit it with no repeat and no `xmlns=""` reset.  Verified
  // by inspecting the whole fragment.
  inspect(s, content=(
    #|<svg xmlns="http://www.w3.org/2000/svg" width="100"><rect x="0"/><g><circle r="5"/></g></svg>
  ))
}
