///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
test "PresentationML viewer renders slide text" {
  let slide = @domain.CT_Slide::new({
    name: name("sld"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sp"),
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
                    children: [@xml.Node::Text("Title")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(slide)
  assert_true(html.contains("data-ooxml=\"pml\""))
  assert_true(html.contains("<p>Title</p>"))
}
