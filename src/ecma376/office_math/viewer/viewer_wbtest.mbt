///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
test "Office Math viewer renders text as MathML" {
  let math = @domain.CT_OMath::new({
    name: name("oMath"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("r"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("t"),
            attributes: [],
            children: [@xml.Node::Text("x")],
          }),
        ],
      }),
    ],
  })
  let html = render_html(math)
  assert_true(html.contains("data-ooxml=\"omml\""))
  assert_true(html.contains("<mtext>x</mtext>"))
}
