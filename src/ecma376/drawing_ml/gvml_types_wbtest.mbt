///|
test "construct CT_GvmlShape from sp element" {
  let parsed = @xml.parse(
    bytes(
      "<a:sp xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:nvSpPr><a:cNvPr id=\"1\" name=\"Shape 1\"/><a:cNvSpPr/></a:nvSpPr><a:spPr/></a:sp>",
    ),
  )
  let value = CT_GvmlShape::new(parsed.root)
  assert_eq(value.element.name.local_name, "sp")
}

///|
test "construct CT_GvmlShapeNonVisual from nvSpPr element" {
  let parsed = @xml.parse(
    bytes(
      "<a:nvSpPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:cNvPr id=\"2\" name=\"Box\"/><a:cNvSpPr/></a:nvSpPr>",
    ),
  )
  let value = CT_GvmlShapeNonVisual::new(parsed.root)
  assert_eq(value.element.name.local_name, "nvSpPr")
}

///|
test "construct CT_GvmlConnector from cxnSp element" {
  let parsed = @xml.parse(
    bytes(
      "<a:cxnSp xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:nvCxnSpPr><a:cNvPr id=\"3\" name=\"Connector 1\"/><a:cNvCxnSpPr/></a:nvCxnSpPr><a:spPr/></a:cxnSp>",
    ),
  )
  let value = CT_GvmlConnector::new(parsed.root)
  assert_eq(value.element.name.local_name, "cxnSp")
}

///|
test "construct CT_GvmlConnectorNonVisual from nvCxnSpPr element" {
  let parsed = @xml.parse(
    bytes(
      "<a:nvCxnSpPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:cNvPr id=\"4\" name=\"Cxn\"/><a:cNvCxnSpPr/></a:nvCxnSpPr>",
    ),
  )
  let value = CT_GvmlConnectorNonVisual::new(parsed.root)
  assert_eq(value.element.name.local_name, "nvCxnSpPr")
}

///|
test "construct CT_GvmlPicture from pic element" {
  let parsed = @xml.parse(
    bytes(
      "<a:pic xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:nvPicPr><a:cNvPr id=\"5\" name=\"Pic\"/><a:cNvPicPr/></a:nvPicPr><a:blipFill/><a:spPr/></a:pic>",
    ),
  )
  let value = CT_GvmlPicture::new(parsed.root)
  assert_eq(value.element.name.local_name, "pic")
}

///|
test "construct CT_GvmlPictureNonVisual from nvPicPr element" {
  let parsed = @xml.parse(
    bytes(
      "<a:nvPicPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:cNvPr id=\"6\" name=\"Picture\"/><a:cNvPicPr/></a:nvPicPr>",
    ),
  )
  let value = CT_GvmlPictureNonVisual::new(parsed.root)
  assert_eq(value.element.name.local_name, "nvPicPr")
}

///|
test "construct CT_GvmlGraphicalObjectFrame from graphicFrame element" {
  let parsed = @xml.parse(
    bytes(
      "<a:graphicFrame xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:nvGraphicFramePr><a:cNvPr id=\"7\" name=\"Frame\"/><a:cNvGraphicFramePr/></a:nvGraphicFramePr><a:graphic><a:graphicData uri=\"urn:test\"/></a:graphic><a:xfrm/></a:graphicFrame>",
    ),
  )
  let value = CT_GvmlGraphicalObjectFrame::new(parsed.root)
  assert_eq(value.element.name.local_name, "graphicFrame")
}

///|
test "construct CT_GvmlGraphicFrameNonVisual from nvGraphicFramePr element" {
  let parsed = @xml.parse(
    bytes(
      "<a:nvGraphicFramePr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:cNvPr id=\"8\" name=\"Frame\"/><a:cNvGraphicFramePr/></a:nvGraphicFramePr>",
    ),
  )
  let value = CT_GvmlGraphicFrameNonVisual::new(parsed.root)
  assert_eq(value.element.name.local_name, "nvGraphicFramePr")
}

///|
test "construct CT_GvmlGroupShape from grpSp element" {
  let parsed = @xml.parse(
    bytes(
      "<a:grpSp xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:nvGrpSpPr><a:cNvPr id=\"9\" name=\"Group\"/><a:cNvGrpSpPr/></a:nvGrpSpPr><a:grpSpPr/></a:grpSp>",
    ),
  )
  let value = CT_GvmlGroupShape::new(parsed.root)
  assert_eq(value.element.name.local_name, "grpSp")
}

///|
test "construct CT_GvmlGroupShapeNonVisual from nvGrpSpPr element" {
  let parsed = @xml.parse(
    bytes(
      "<a:nvGrpSpPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:cNvPr id=\"10\" name=\"Group\"/><a:cNvGrpSpPr/></a:nvGrpSpPr>",
    ),
  )
  let value = CT_GvmlGroupShapeNonVisual::new(parsed.root)
  assert_eq(value.element.name.local_name, "nvGrpSpPr")
}

///|
test "construct CT_GvmlTextShape from txSp element" {
  let parsed = @xml.parse(
    bytes(
      "<a:txSp xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:txBody><a:bodyPr/><a:lstStyle/><a:p/></a:txBody><a:useSpRect/></a:txSp>",
    ),
  )
  let value = CT_GvmlTextShape::new(parsed.root)
  assert_eq(value.element.name.local_name, "txSp")
}

///|
test "construct CT_GvmlUseShapeRectangle from useSpRect element" {
  let parsed = @xml.parse(
    bytes(
      "<a:useSpRect xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
    ),
  )
  let value = CT_GvmlUseShapeRectangle::new(parsed.root)
  assert_eq(value.element.name.local_name, "useSpRect")
}
