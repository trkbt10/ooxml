///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
test "WordprocessingML viewer renders paragraph text" {
  let document = @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text("Hello <wml>")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(document)
  assert_true(html.contains("data-ooxml=\"wml\""))
  assert_true(html.contains("<p>Hello &lt;wml&gt;</p>"))
}
