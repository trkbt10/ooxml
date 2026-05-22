///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
test "DrawingML viewer renders svg text" {
  let shape : @xml.Element = {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("Shape")],
      }),
    ],
  }
  let svg = render_svg(shape)
  let html = render_html(shape)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("Shape"))
  assert_true(html.contains("data-ooxml=\"dml\""))
  // The SVG namespace is declared on the `<svg>` element.
  assert_true(svg.contains("xmlns=\"http://www.w3.org/2000/svg\""))
  // In the HTML wrapper the SVG subtree still carries its own
  // namespace declaration even though the host `<div>` has none.
  assert_true(html.contains("<div data-ooxml=\"dml\">"))
  assert_true(html.contains("xmlns=\"http://www.w3.org/2000/svg\""))
}

///|
/// DrawingML text content carrying XML-significant characters is
/// escaped: a `<t>` payload of `<`/`&`/`"` cannot break out of
/// the `<text>` element.
test "DrawingML viewer escapes markup in text content" {
  let shape : @xml.Element = {
    name: name("sp"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("t"),
        attributes: [],
        children: [@xml.Node::Text("a < b & \"</text><script>\"")],
      }),
    ],
  }
  let svg = render_svg(shape)
  // `<` and `&` are entity-escaped in text content.
  assert_true(svg.contains("a &lt; b &amp;"))
  // The injected `</text>` / `<script>` cannot survive as live
  // markup — every `<` is escaped.
  assert_false(svg.contains("</text><script>"))
}
