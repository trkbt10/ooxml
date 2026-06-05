// Shared ancillary ECMA-376 XML fixtures stored as Custom XML Data Storage.
//
// These schemas are implemented as self-contained ancillary packages rather
// than WML/SML/PML document parts.  Storing them through `customXml` gives the
// generated package a real OPC relationship graph while keeping the payload
// content type at the Custom XML Data Storage `application/xml` slot.

///|
const NS_ADDITIONAL_CHARACTERISTICS : String = "http://schemas.openxmlformats.org/officeDocument/2006/characteristics"

///|
const NS_SCHEMA_LIBRARY : String = "http://schemas.openxmlformats.org/schemaLibrary/2006/main"

///|
fn schema_library_attr(name : String, value : String) -> @xml.Attribute {
  {
    name: { prefix: Some("sl"), local_name: name, ns: Some(NS_SCHEMA_LIBRARY) },
    value,
  }
}

///|
fn shared_ancillary_custom_xml_properties(
  item_id : String,
  schema_uri : String,
) -> @xml.Element {
  xep(
    "ds",
    NS_CUSTOM_XML_PROPS,
    "datastoreItem",
    [custom_xml_props_attr("itemID", item_id)],
    [
      Element(
        xep("ds", NS_CUSTOM_XML_PROPS, "schemaRefs", [], [
          Element(
            xep(
              "ds",
              NS_CUSTOM_XML_PROPS,
              "schemaRef",
              [custom_xml_props_attr("uri", schema_uri)],
              [],
            ),
          ),
        ]),
      ),
    ],
  )
}

///|
fn additional_characteristics_payload() -> @xml.Element {
  xep("ac", NS_ADDITIONAL_CHARACTERISTICS, "additionalCharacteristics", [], [
    Element(
      xep(
        "ac",
        NS_ADDITIONAL_CHARACTERISTICS,
        "characteristic",
        [
          xa("name", "word-count"),
          xa("relation", "ge"),
          xa("val", "1"),
          xa("vocabulary", "urn:ooxml:fixture:additional-characteristics"),
        ],
        [],
      ),
    ),
  ])
}

///|
fn schema_library_payload() -> @xml.Element {
  xep("sl", NS_SCHEMA_LIBRARY, "schemaLibrary", [], [
    Element(
      xep(
        "sl",
        NS_SCHEMA_LIBRARY,
        "schema",
        [
          schema_library_attr("uri", "urn:ooxml:fixture:schema-library"),
          schema_library_attr("manifestLocation", "schemas/manifest.xml"),
          schema_library_attr("schemaLocation", "schemas/schema.xsd"),
          schema_library_attr("schemaLanguage", "XMLSCHEMA"),
        ],
        [],
      ),
    ),
  ])
}

///|
fn extras_shared_ancillary_custom_xml(cases : Array[CustomXmlCase]) -> Unit {
  cases.push({
    id: "additional-characteristics",
    format: "docx",
    category: "shared-ancillary",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Additional characteristics coverage")])),
    ]),
    custom_xml: additional_characteristics_payload(),
    custom_xml_properties: shared_ancillary_custom_xml_properties(
      "{22222222-3333-4444-5555-666666666666}",
      NS_ADDITIONAL_CHARACTERISTICS,
    ),
  })
  cases.push({
    id: "schema-library",
    format: "docx",
    category: "shared-ancillary",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "Schema library coverage")])),
    ]),
    custom_xml: schema_library_payload(),
    custom_xml_properties: shared_ancillary_custom_xml_properties(
      "{33333333-4444-5555-6666-777777777777}",
      NS_SCHEMA_LIBRARY,
    ),
  })
}
