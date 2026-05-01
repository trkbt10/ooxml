///|
fn name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
test "SpreadsheetML viewer renders row and cell values" {
  let worksheet = @domain.CT_Worksheet::new({
    name: name("worksheet"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("sheetData"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("row"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("c"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("v"),
                    attributes: [],
                    children: [@xml.Node::Text("42")],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
  let html = render_html(worksheet)
  assert_true(html.contains("data-ooxml=\"sml\""))
  assert_true(html.contains("<tr><td>42</td></tr>"))
}
