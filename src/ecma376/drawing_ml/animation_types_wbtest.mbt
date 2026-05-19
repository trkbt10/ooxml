///|
test "construct CT_AnimationDgmElement from dgm element" {
  let parsed = @xml.parse(
    bytes(
      "<a:dgm xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" id=\"{11111111-1111-1111-1111-111111111111}\" bldStep=\"sp\"/>",
    ),
  )
  let value = CT_AnimationDgmElement::new(parsed.root)
  assert_eq(value.element.name.local_name, "dgm")
}

///|
test "construct CT_AnimationChartElement from chart element" {
  let parsed = @xml.parse(
    bytes(
      "<a:chart xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" seriesIdx=\"-1\" categoryIdx=\"-1\" bldStep=\"category\"/>",
    ),
  )
  let value = CT_AnimationChartElement::new(parsed.root)
  assert_eq(value.element.name.local_name, "chart")
}

///|
test "construct CT_AnimationElementChoice from graphicEl element" {
  let parsed = @xml.parse(
    bytes(
      "<a:graphicEl xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:dgm id=\"{00000000-0000-0000-0000-000000000000}\"/></a:graphicEl>",
    ),
  )
  let value = CT_AnimationElementChoice::new(parsed.root)
  assert_eq(value.element.name.local_name, "graphicEl")
}

///|
test "construct CT_AnimationDgmBuildProperties from bldDgm element" {
  let parsed = @xml.parse(
    bytes(
      "<a:bldDgm xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" bld=\"one\" rev=\"false\"/>",
    ),
  )
  let value = CT_AnimationDgmBuildProperties::new(parsed.root)
  assert_eq(value.element.name.local_name, "bldDgm")
}

///|
test "construct CT_AnimationChartBuildProperties from bldChart element" {
  let parsed = @xml.parse(
    bytes(
      "<a:bldChart xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" bld=\"category\" animBg=\"true\"/>",
    ),
  )
  let value = CT_AnimationChartBuildProperties::new(parsed.root)
  assert_eq(value.element.name.local_name, "bldChart")
}

///|
test "construct CT_AnimationGraphicalObjectBuildProperties from bldSub element" {
  let parsed = @xml.parse(
    bytes(
      "<a:bldSub xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:bldDgm bld=\"one\"/></a:bldSub>",
    ),
  )
  let value = CT_AnimationGraphicalObjectBuildProperties::new(parsed.root)
  assert_eq(value.element.name.local_name, "bldSub")
}

///|
test "construct CT_WholeE2oFormatting from whole element" {
  let parsed = @xml.parse(
    bytes(
      "<a:whole xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:ln w=\"9525\"/></a:whole>",
    ),
  )
  let value = CT_WholeE2oFormatting::new(parsed.root)
  assert_eq(value.element.name.local_name, "whole")
}

///|
test "construct CT_NonVisualContentPartProperties from cNvContentPartPr element" {
  let parsed = @xml.parse(
    bytes(
      "<a:cNvContentPartPr xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" isComment=\"true\"/>",
    ),
  )
  let value = CT_NonVisualContentPartProperties::new(parsed.root)
  assert_eq(value.element.name.local_name, "cNvContentPartPr")
}

///|
test "construct CT_ClipboardStyleSheet from clipboardStyleSheet element" {
  let parsed = @xml.parse(
    bytes(
      "<a:clipboardStyleSheet xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:themeElements/><a:clrMap bg1=\"lt1\" tx1=\"dk1\" bg2=\"lt2\" tx2=\"dk2\" accent1=\"accent1\" accent2=\"accent2\" accent3=\"accent3\" accent4=\"accent4\" accent5=\"accent5\" accent6=\"accent6\" hlink=\"hlink\" folHlink=\"folHlink\"/></a:clipboardStyleSheet>",
    ),
  )
  let value = CT_ClipboardStyleSheet::new(parsed.root)
  assert_eq(value.element.name.local_name, "clipboardStyleSheet")
}
