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
}
