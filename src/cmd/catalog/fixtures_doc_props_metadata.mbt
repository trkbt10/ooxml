// Document-property package fixtures.
//
// These cases exercise OPC package-level metadata parts:
//   * docProps/core.xml   - OPC core properties
//   * docProps/app.xml    - ECMA-376 extended properties
//   * docProps/custom.xml - ECMA-376 custom properties + variant types
//
// They are intentionally metadata-rich rather than visually rich.  The
// goal is fixture occurrence coverage plus XSD/OPC/format validation of
// real package parts.

///|
const NS_CORE_PROPS : String = "http://schemas.openxmlformats.org/package/2006/metadata/core-properties"

///|
const NS_EXTENDED_PROPS_STRICT : String = "http://purl.oclc.org/ooxml/officeDocument/extendedProperties"

///|
const NS_CUSTOM_PROPS_STRICT : String = "http://purl.oclc.org/ooxml/officeDocument/customProperties"

///|
const NS_DOC_PROPS_VT_STRICT : String = "http://purl.oclc.org/ooxml/officeDocument/docPropsVTypes"

///|
const NS_EXTENDED_PROPS_TRANSITIONAL : String = "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"

///|
const NS_CUSTOM_PROPS_TRANSITIONAL : String = "http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"

///|
const NS_DOC_PROPS_VT_TRANSITIONAL : String = "http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"

///|
struct DocPropsNamespaceSet {
  suffix : String
  extended_props : String
  custom_props : String
  variant_types : String
}

///|
fn doc_props_strict_namespaces() -> DocPropsNamespaceSet {
  {
    suffix: "strict",
    extended_props: NS_EXTENDED_PROPS_STRICT,
    custom_props: NS_CUSTOM_PROPS_STRICT,
    variant_types: NS_DOC_PROPS_VT_STRICT,
  }
}

///|
fn doc_props_transitional_namespaces() -> DocPropsNamespaceSet {
  {
    suffix: "transitional",
    extended_props: NS_EXTENDED_PROPS_TRANSITIONAL,
    custom_props: NS_CUSTOM_PROPS_TRANSITIONAL,
    variant_types: NS_DOC_PROPS_VT_TRANSITIONAL,
  }
}

///|
const CUSTOM_PROP_FMTID : String = "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}"

///|
const CUSTOM_PROP_CLSID : String = "{00020906-0000-0000-C000-000000000046}"

///|
fn doc_props_xml_lang(value : String) -> @xml.Attribute {
  {
    name: {
      prefix: Some("xml"),
      local_name: "lang",
      ns: Some("http://www.w3.org/XML/1998/namespace"),
    },
    value,
  }
}

///|
fn doc_props_nodes(elements : Array[@xml.Element]) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for e in elements {
    nodes.push(Element(e))
  }
  nodes
}

///|
fn core_text(name : String, value : String) -> @xml.Element {
  xep("cp", NS_CORE_PROPS, name, [], [Text(value)])
}

///|
fn core_text_with_attrs(
  name : String,
  attrs : Array[@xml.Attribute],
  value : String,
) -> @xml.Element {
  xep("cp", NS_CORE_PROPS, name, attrs, [Text(value)])
}

///|
fn extended_text(
  namespaces : DocPropsNamespaceSet,
  name : String,
  value : String,
) -> @xml.Element {
  xep("ep", namespaces.extended_props, name, [], [Text(value)])
}

///|
fn vt_text(
  namespaces : DocPropsNamespaceSet,
  name : String,
  value : String,
) -> @xml.Element {
  xep("vt", namespaces.variant_types, name, [], [Text(value)])
}

///|
fn vt_empty(namespaces : DocPropsNamespaceSet, name : String) -> @xml.Element {
  xep("vt", namespaces.variant_types, name, [], [])
}

///|
fn vt_variant(
  namespaces : DocPropsNamespaceSet,
  value : @xml.Element,
) -> @xml.Element {
  xep("vt", namespaces.variant_types, "variant", [], [Element(value)])
}

///|
fn vt_vector(
  namespaces : DocPropsNamespaceSet,
  base_type : String,
  values : Array[@xml.Element],
) -> @xml.Element {
  xep(
    "vt",
    namespaces.variant_types,
    "vector",
    [xa("baseType", base_type), xa("size", values.length().to_string())],
    doc_props_nodes(values),
  )
}

///|
fn vt_array(
  namespaces : DocPropsNamespaceSet,
  base_type : String,
  lower_bound : String,
  upper_bound : String,
  values : Array[@xml.Element],
) -> @xml.Element {
  xep(
    "vt",
    namespaces.variant_types,
    "array",
    [
      xa("lBounds", lower_bound),
      xa("uBounds", upper_bound),
      xa("baseType", base_type),
    ],
    doc_props_nodes(values),
  )
}

///|
fn doc_props_core_properties() -> @xml.Element {
  xep("cp", NS_CORE_PROPS, "coreProperties", [], [
    Element(core_text("category", "OOXML coverage")),
    Element(core_text("contentStatus", "fixture")),
    Element(
      xep("cp", NS_CORE_PROPS, "keywords", [doc_props_xml_lang("en-US")], [
        Element(
          core_text_with_attrs(
            "value",
            [doc_props_xml_lang("en-US")],
            "ECMA-376",
          ),
        ),
        Element(core_text("value", "docProps")),
        Element(core_text("value", "variant-types")),
      ]),
    ),
    Element(core_text("lastModifiedBy", "ooxml catalog")),
    Element(core_text("lastPrinted", "2026-06-05T00:00:00Z")),
    Element(core_text("revision", "1")),
    Element(core_text("version", "1.0")),
  ])
}

///|
fn doc_props_heading_pairs(namespaces : DocPropsNamespaceSet) -> @xml.Element {
  xep("ep", namespaces.extended_props, "HeadingPairs", [], [
    Element(
      vt_vector(namespaces, "variant", [
        vt_variant(namespaces, vt_text(namespaces, "lpstr", "Document")),
        vt_variant(namespaces, vt_text(namespaces, "i4", "1")),
      ]),
    ),
  ])
}

///|
fn doc_props_titles_of_parts(namespaces : DocPropsNamespaceSet) -> @xml.Element {
  xep("ep", namespaces.extended_props, "TitlesOfParts", [], [
    Element(
      vt_vector(namespaces, "lpstr", [
        vt_text(namespaces, "lpstr", "Metadata coverage"),
      ]),
    ),
  ])
}

///|
fn doc_props_hlinks(namespaces : DocPropsNamespaceSet) -> @xml.Element {
  xep("ep", namespaces.extended_props, "HLinks", [], [
    Element(
      vt_vector(namespaces, "variant", [
        vt_variant(
          namespaces,
          vt_text(namespaces, "lpstr", "https://example.test/ooxml"),
        ),
      ]),
    ),
  ])
}

///|
fn doc_props_extended_properties(
  namespaces : DocPropsNamespaceSet,
) -> @xml.Element {
  xep("ep", namespaces.extended_props, "Properties", [], [
    Element(extended_text(namespaces, "Template", "Normal.dotm")),
    Element(extended_text(namespaces, "Manager", "Catalog")),
    Element(extended_text(namespaces, "Company", "MoonBit OOXML")),
    Element(extended_text(namespaces, "Pages", "1")),
    Element(extended_text(namespaces, "Words", "4")),
    Element(extended_text(namespaces, "Characters", "28")),
    Element(extended_text(namespaces, "PresentationFormat", "On-screen Show")),
    Element(extended_text(namespaces, "Lines", "1")),
    Element(extended_text(namespaces, "Paragraphs", "1")),
    Element(extended_text(namespaces, "Slides", "1")),
    Element(extended_text(namespaces, "Notes", "0")),
    Element(extended_text(namespaces, "TotalTime", "0")),
    Element(extended_text(namespaces, "HiddenSlides", "0")),
    Element(extended_text(namespaces, "MMClips", "0")),
    Element(extended_text(namespaces, "ScaleCrop", "false")),
    Element(doc_props_heading_pairs(namespaces)),
    Element(doc_props_titles_of_parts(namespaces)),
    Element(extended_text(namespaces, "LinksUpToDate", "true")),
    Element(extended_text(namespaces, "CharactersWithSpaces", "31")),
    Element(extended_text(namespaces, "SharedDoc", "false")),
    Element(extended_text(namespaces, "HyperlinkBase", "https://example.test/")),
    Element(doc_props_hlinks(namespaces)),
    Element(extended_text(namespaces, "HyperlinksChanged", "false")),
    Element(
      xep("ep", namespaces.extended_props, "DigSig", [], [
        Element(vt_text(namespaces, "blob", "AQIDBA==")),
      ]),
    ),
    Element(extended_text(namespaces, "Application", "OOXML catalog")),
    Element(extended_text(namespaces, "AppVersion", "16.0000")),
    Element(extended_text(namespaces, "DocSecurity", "0")),
  ])
}

///|
fn doc_props_custom_property(
  namespaces : DocPropsNamespaceSet,
  pid : Int,
  name : String,
  value : @xml.Element,
) -> @xml.Element {
  xep(
    "cust",
    namespaces.custom_props,
    "property",
    [
      xa("fmtid", CUSTOM_PROP_FMTID),
      xa("pid", pid.to_string()),
      xa("name", name),
    ],
    [Element(value)],
  )
}

///|
fn doc_props_custom_properties(
  namespaces : DocPropsNamespaceSet,
) -> @xml.Element {
  let props : Array[@xml.Element] = [
    doc_props_custom_property(
      namespaces,
      2,
      "VectorVariant",
      vt_vector(namespaces, "variant", [
        vt_variant(namespaces, vt_text(namespaces, "lpstr", "vector item")),
      ]),
    ),
    doc_props_custom_property(
      namespaces,
      3,
      "ArrayInt",
      vt_array(namespaces, "i4", "0", "1", [
        vt_text(namespaces, "i4", "1"),
        vt_text(namespaces, "i4", "2"),
      ]),
    ),
    doc_props_custom_property(
      namespaces,
      4,
      "Blob",
      vt_text(namespaces, "blob", "AQID"),
    ),
    doc_props_custom_property(
      namespaces,
      5,
      "Oblob",
      vt_text(namespaces, "oblob", "BAUG"),
    ),
    doc_props_custom_property(
      namespaces,
      6,
      "Empty",
      vt_empty(namespaces, "empty"),
    ),
    doc_props_custom_property(
      namespaces,
      7,
      "Null",
      vt_empty(namespaces, "null"),
    ),
    doc_props_custom_property(
      namespaces,
      8,
      "I1",
      vt_text(namespaces, "i1", "-1"),
    ),
    doc_props_custom_property(
      namespaces,
      9,
      "I2",
      vt_text(namespaces, "i2", "-2"),
    ),
    doc_props_custom_property(
      namespaces,
      10,
      "I4",
      vt_text(namespaces, "i4", "-4"),
    ),
    doc_props_custom_property(
      namespaces,
      11,
      "I8",
      vt_text(namespaces, "i8", "-8"),
    ),
    doc_props_custom_property(
      namespaces,
      12,
      "Int",
      vt_text(namespaces, "int", "42"),
    ),
    doc_props_custom_property(
      namespaces,
      13,
      "Ui1",
      vt_text(namespaces, "ui1", "1"),
    ),
    doc_props_custom_property(
      namespaces,
      14,
      "Ui2",
      vt_text(namespaces, "ui2", "2"),
    ),
    doc_props_custom_property(
      namespaces,
      15,
      "Ui4",
      vt_text(namespaces, "ui4", "4"),
    ),
    doc_props_custom_property(
      namespaces,
      16,
      "Ui8",
      vt_text(namespaces, "ui8", "8"),
    ),
    doc_props_custom_property(
      namespaces,
      17,
      "Uint",
      vt_text(namespaces, "uint", "9"),
    ),
    doc_props_custom_property(
      namespaces,
      18,
      "R4",
      vt_text(namespaces, "r4", "1.25"),
    ),
    doc_props_custom_property(
      namespaces,
      19,
      "R8",
      vt_text(namespaces, "r8", "2.5"),
    ),
    doc_props_custom_property(
      namespaces,
      20,
      "Decimal",
      vt_text(namespaces, "decimal", "3.14"),
    ),
    doc_props_custom_property(
      namespaces,
      21,
      "Lpstr",
      vt_text(namespaces, "lpstr", "ansi text"),
    ),
    doc_props_custom_property(
      namespaces,
      22,
      "Lpwstr",
      vt_text(namespaces, "lpwstr", "wide text"),
    ),
    doc_props_custom_property(
      namespaces,
      23,
      "Bstr",
      vt_text(namespaces, "bstr", "basic string"),
    ),
    doc_props_custom_property(
      namespaces,
      24,
      "Date",
      vt_text(namespaces, "date", "2026-06-05T00:00:00Z"),
    ),
    doc_props_custom_property(
      namespaces,
      25,
      "Filetime",
      vt_text(namespaces, "filetime", "2026-06-05T00:00:00Z"),
    ),
    doc_props_custom_property(
      namespaces,
      26,
      "Bool",
      vt_text(namespaces, "bool", "true"),
    ),
    doc_props_custom_property(
      namespaces,
      27,
      "Cy",
      vt_text(namespaces, "cy", "123.4567"),
    ),
    doc_props_custom_property(
      namespaces,
      28,
      "Error",
      vt_text(namespaces, "error", "0x00000000"),
    ),
    doc_props_custom_property(
      namespaces,
      29,
      "Stream",
      vt_text(namespaces, "stream", "AQID"),
    ),
    doc_props_custom_property(
      namespaces,
      30,
      "Ostream",
      vt_text(namespaces, "ostream", "AQID"),
    ),
    doc_props_custom_property(
      namespaces,
      31,
      "Storage",
      vt_text(namespaces, "storage", "AQID"),
    ),
    doc_props_custom_property(
      namespaces,
      32,
      "Ostorage",
      vt_text(namespaces, "ostorage", "AQID"),
    ),
    doc_props_custom_property(
      namespaces,
      33,
      "Vstream",
      xep(
        "vt",
        namespaces.variant_types,
        "vstream",
        [xa("version", CUSTOM_PROP_CLSID)],
        [Text("AQID")],
      ),
    ),
    doc_props_custom_property(
      namespaces,
      34,
      "Clsid",
      vt_text(namespaces, "clsid", CUSTOM_PROP_CLSID),
    ),
  ]
  xep("cust", namespaces.custom_props, "Properties", [], doc_props_nodes(props))
}

///|
fn extras_doc_props_metadata(cases : Array[MetadataCase]) -> Unit {
  for
    namespaces in [
      doc_props_transitional_namespaces(),
      doc_props_strict_namespaces(),
    ] {
    cases.push({
      id: "properties-rich-" + namespaces.suffix,
      format: "docx",
      category: "metadata",
      content: xe(NS_W, "body", [], [
        Element(
          w_p(None, [
            w_run(
              None,
              "Document metadata coverage fixture: " + namespaces.suffix,
            ),
          ]),
        ),
      ]),
      core_properties: doc_props_core_properties(),
      extended_properties: doc_props_extended_properties(namespaces),
      custom_properties: doc_props_custom_properties(namespaces),
    })
  }
}
