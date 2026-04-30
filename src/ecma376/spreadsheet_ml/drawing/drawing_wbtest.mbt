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
  let xml = bytes(
    "<xdr:wsDr xmlns:xdr=\"http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing\"><xdr:oneCellAnchor><xdr:from><xdr:col>0</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>0</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from><xdr:ext cx=\"1\" cy=\"1\"/><xdr:clientData/></xdr:oneCellAnchor></xdr:wsDr>",
  )
  let drawing = read_ws_dr(xml)
  assert_eq(drawing.element.name.local_name, "wsDr")
  let reparsed = read_ws_dr(write_ws_dr(drawing))
  assert_eq(reparsed.element.children.length(), 1)
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
