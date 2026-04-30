///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
test "custom XML datastoreItem round trip" {
  let xml = bytes(
    "<ds:datastoreItem xmlns:ds=\"http://purl.oclc.org/ooxml/officeDocument/customXml\" itemID=\"{00112233-4455-6677-8899-AABBCCDDEEFF}\"><ds:schemaRefs><ds:schemaRef uri=\"urn:test\"/></ds:schemaRefs></ds:datastoreItem>",
  )
  let item = read_datastore_item(xml)
  assert_eq(item.element.name.local_name, "datastoreItem")
  let reparsed = read_datastore_item(write_datastore_item(item))
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "schemaLibrary round trip" {
  let xml = bytes(
    "<sl:schemaLibrary xmlns:sl=\"http://purl.oclc.org/ooxml/schemaLibrary/main\"><sl:schema uri=\"urn:test\" manifestLocation=\"manifest.xml\" schemaLocation=\"schema.xsd\"/></sl:schemaLibrary>",
  )
  let library = read_schema_library(xml)
  assert_eq(library.element.name.local_name, "schemaLibrary")
  let reparsed = read_schema_library(write_schema_library(library))
  assert_eq(reparsed.element.children.length(), 1)
}

///|
test "custom and extended Properties round trip" {
  let custom = read_custom_properties(
    bytes(
      "<cp:Properties xmlns:cp=\"http://purl.oclc.org/ooxml/officeDocument/customProperties\"><cp:property pid=\"2\" name=\"Checked\"><vt:bool xmlns:vt=\"http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes\">true</vt:bool></cp:property></cp:Properties>",
    ),
  )
  assert_eq(
    read_custom_properties(write_custom_properties(custom)).element.children.length(),
    1,
  )
  let extended = read_extended_properties(
    bytes(
      "<ep:Properties xmlns:ep=\"http://purl.oclc.org/ooxml/officeDocument/extendedProperties\"><ep:Application>MoonBit</ep:Application></ep:Properties>",
    ),
  )
  assert_eq(
    read_extended_properties(write_extended_properties(extended)).element.children.length(),
    1,
  )
}
