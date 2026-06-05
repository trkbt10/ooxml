// OPC digital-signature schema fixtures.
//
// These are not signed packages.  They store the top-level
// opc-digSig elements as Custom XML Data Storage payloads so the
// fixture occurrence and XSD gates can exercise opc-digSig.xsd without
// inventing an XMLDSig validation story that the repository does not yet
// vendor.

///|
const NS_OPC_DIGSIG : String = "http://schemas.openxmlformats.org/package/2006/digital-signature"

///|
fn opc_digsig_custom_xml_properties(item_id : String) -> @xml.Element {
  shared_ancillary_custom_xml_properties(item_id, NS_OPC_DIGSIG)
}

///|
fn opc_signature_time_payload() -> @xml.Element {
  xep("digsig", NS_OPC_DIGSIG, "SignatureTime", [], [
    Element(
      xep("digsig", NS_OPC_DIGSIG, "Format", [], [
        Text("YYYY-MM-DDThh:mm:ssTZD"),
      ]),
    ),
    Element(
      xep("digsig", NS_OPC_DIGSIG, "Value", [], [Text("2026-06-05T00:00:00Z")]),
    ),
  ])
}

///|
fn opc_relationship_reference_payload() -> @xml.Element {
  xep(
    "digsig",
    NS_OPC_DIGSIG,
    "RelationshipReference",
    [xa("SourceId", "rId1")],
    [Text("package-root-office-document")],
  )
}

///|
fn opc_relationships_group_reference_payload() -> @xml.Element {
  xep(
    "digsig",
    NS_OPC_DIGSIG,
    "RelationshipsGroupReference",
    [
      xa(
        "SourceType", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
      ),
    ],
    [Text("office-document-relationship-group")],
  )
}

///|
fn extras_opc_digital_signature_custom_xml(
  cases : Array[CustomXmlCase],
) -> Unit {
  cases.push({
    id: "opc-digsig-signature-time",
    format: "docx",
    category: "opc-digital-signature",
    content: xe(NS_W, "body", [], [
      Element(w_p(None, [w_run(None, "OPC digital signature time coverage")])),
    ]),
    custom_xml: opc_signature_time_payload(),
    custom_xml_properties: opc_digsig_custom_xml_properties(
      "{44444444-5555-6666-7777-888888888888}",
    ),
  })
  cases.push({
    id: "opc-digsig-relationship-reference",
    format: "docx",
    category: "opc-digital-signature",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [w_run(None, "OPC digital signature relationship coverage")]),
      ),
    ]),
    custom_xml: opc_relationship_reference_payload(),
    custom_xml_properties: opc_digsig_custom_xml_properties(
      "{55555555-6666-7777-8888-999999999999}",
    ),
  })
  cases.push({
    id: "opc-digsig-relationships-group-reference",
    format: "docx",
    category: "opc-digital-signature",
    content: xe(NS_W, "body", [], [
      Element(
        w_p(None, [
          w_run(None, "OPC digital signature relationship group coverage"),
        ]),
      ),
    ]),
    custom_xml: opc_relationships_group_reference_payload(),
    custom_xml_properties: opc_digsig_custom_xml_properties(
      "{66666666-7777-8888-9999-AAAAAAAAAAAA}",
    ),
  })
}
