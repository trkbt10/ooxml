///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "read and write DML marker from element" {
  let xml = bytes(
    "<xdr:from xmlns:xdr=\"http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing\"><xdr:col>1</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>2</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from>",
  )
  let marker = read_from(xml)
  assert_eq(marker.element.name.local_name, "from")
  let reparsed = read_from(write_from(marker))
  assert_eq(reparsed.element.children.length(), 4)
}

///|
test "read and write DML worksheet drawing with anchors" {
  // §20.5.2.23 CT_OneCellAnchor requires an EG_ObjectChoices child
  // (sp / grpSp / graphicFrame / cxnSp / pic / contentPart). We use a
  // minimal <xdr:sp> with the required @id / @name on cNvPr and an
  // empty spPr / nvSpPr to satisfy the schema.
  let xml = bytes(
    "<xdr:wsDr xmlns:xdr=\"http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing\" xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\">" +
    "<xdr:oneCellAnchor>" +
    "<xdr:from><xdr:col>0</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>0</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from>" +
    "<xdr:ext cx=\"1\" cy=\"1\"/>" +
    "<xdr:sp><xdr:nvSpPr><xdr:cNvPr id=\"1\" name=\"s\"/><xdr:cNvSpPr/></xdr:nvSpPr><xdr:spPr/></xdr:sp>" +
    "<xdr:clientData/>" +
    "</xdr:oneCellAnchor>" +
    "</xdr:wsDr>",
  )
  let drawing = read_ws_dr(xml)
  assert_eq(drawing.element.name.local_name, "wsDr")
  assert_eq(drawing.anchors.length(), 1)
  // Verify the typed projection — we expect a OneCellAnchor with an
  // Sp choice (not just "we remembered the local name").
  match drawing.anchors[0] {
    OneCellAnchor(a) =>
      match a.object_choice {
        Sp(_) => assert_true(true)
        _ => fail("expected Sp(...) inside OneCellAnchor")
      }
    _ => fail("expected OneCellAnchor")
  }
  let reparsed = read_ws_dr(write_ws_dr(drawing))
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "read DML worksheet drawing transitional namespace two-cell anchor" {
  let xml = bytes(
    "<xdr:wsDr xmlns:xdr=\"http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing\" xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\">" +
    "<xdr:twoCellAnchor editAs=\"twoCell\">" +
    "<xdr:from><xdr:col>1</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>1</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from>" +
    "<xdr:to><xdr:col>5</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>8</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:to>" +
    "<xdr:sp><xdr:nvSpPr><xdr:cNvPr id=\"2\" name=\"s\"/><xdr:cNvSpPr/></xdr:nvSpPr><xdr:spPr><a:prstGeom prst=\"rect\"><a:avLst/></a:prstGeom><a:solidFill><a:schemeClr val=\"accent1\"/></a:solidFill></xdr:spPr></xdr:sp>" +
    "<xdr:clientData/>" +
    "</xdr:twoCellAnchor>" +
    "</xdr:wsDr>",
  )
  let drawing = read_ws_dr(xml)
  assert_eq(drawing.anchors.length(), 1)
  match drawing.anchors[0] {
    TwoCellAnchor(a) =>
      match a.object_choice {
        Sp(_) => assert_true(true)
        _ => fail("expected Sp(...) inside TwoCellAnchor")
      }
    _ => fail("expected TwoCellAnchor")
  }
}

///|
test "read and write VML ClientData element" {
  let xml = bytes(
    "<x:ClientData xmlns:x=\"urn:schemas-microsoft-com:office:excel\" ObjectType=\"Button\"><x:MoveWithCells/><x:Anchor>1, 0, 2, 0, 3, 0, 4, 0</x:Anchor></x:ClientData>",
  )
  let client_data = read_client_data(xml)
  assert_eq(client_data.element.name.local_name, "ClientData")
  let reparsed = read_client_data(write_client_data(client_data))
  assert_eq(reparsed.element.attributes.length(), 1)
}
