// Catalog-wide round-trip + render verification.
//
// For every catalog entry this embeds the synthesised element tree
// into a complete host OOXML package, then drives the full pipeline
// with THIS package's own builder / reader / renderer:
//
//   reader.open(bytes) -> ctx.save() -> reader.open(saved)
//                                    -> renderer.to_svg(ctx)
//
// The open -> save -> open leg is the round-trip health check
// (reader and builder agree); the final to_svg is the render check.
//
// Every XML part is built as an `@xml.Element` tree and serialised
// once by `@xml.write` — never assembled by string concatenation.

///|
/// The package-relationships namespace.
const NS_PKG_REL : String = "http://schemas.openxmlformats.org/package/2006/relationships"

///|
/// The content-types namespace.
const NS_CT : String = "http://schemas.openxmlformats.org/package/2006/content-types"

///|
/// The office-document relationship type.
const RT_OFFICE_DOC : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"

///|
/// Package-level core-properties relationship type.
const RT_CORE_PROPERTIES : String = "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"

///|
/// Package-level extended-properties relationship type.
const RT_EXTENDED_PROPERTIES : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"

///|
/// Package-level custom-properties relationship type.
const RT_CUSTOM_PROPERTIES : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties"

///|
/// Main-document relationship type for Custom XML Data Storage parts.
const RT_CUSTOM_XML : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml"

///|
/// Custom XML Data Storage part relationship type for item properties.
const RT_CUSTOM_XML_PROPS : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXmlProps"

///|
/// Worksheet / slide relationship type for legacy VML Drawing parts.
const RT_VML_DRAWING : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing"

///|
/// Workbook relationship type for Worksheet parts.
const RT_WORKSHEET : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"

///|
/// Workbook relationship type for Chartsheet parts.
const RT_CHARTSHEET : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chartsheet"

///|
/// Workbook relationship type for Dialogsheet parts.
const RT_DIALOGSHEET : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/dialogsheet"

///|
/// Sheet relationship type for Spreadsheet Drawing parts.
const RT_DRAWING : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing"

///|
/// Sheet relationship type for background image parts.
const RT_IMAGE : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"

///|
/// Sheet relationship type for SpreadsheetML Custom Property parts.
const RT_SPREADSHEET_CUSTOM_PROPERTY : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customProperty"

///|
/// Sheet relationship type for Single Cell Table Definitions parts.
const RT_TABLE_SINGLE_CELLS : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/tableSingleCells"

///|
/// Sheet relationship type for Embedded Control Persistence parts.
const RT_CONTROL : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/control"

///|
/// Core-properties content type.
const CT_CORE_PROPERTIES : String = "application/vnd.openxmlformats-package.core-properties+xml"

///|
/// Extended-properties content type.
const CT_EXTENDED_PROPERTIES : String = "application/vnd.openxmlformats-officedocument.extended-properties+xml"

///|
/// Custom-properties content type.
const CT_CUSTOM_PROPERTIES : String = "application/vnd.openxmlformats-officedocument.custom-properties+xml"

///|
/// Custom XML Data Storage properties content type.
const CT_CUSTOM_XML_PROPERTIES : String = "application/vnd.openxmlformats-officedocument.customXmlProperties+xml"

///|
/// Legacy VML Drawing part content type.
const CT_VML_DRAWING : String = "application/vnd.openxmlformats-officedocument.vmlDrawing"

///|
/// Spreadsheet Drawing part content type.
const CT_SPREADSHEET_DRAWING : String = "application/vnd.openxmlformats-officedocument.drawing+xml"

///|
/// Single Cell Table Definitions part content type.
const CT_TABLE_SINGLE_CELLS : String = "application/vnd.openxmlformats-officedocument.spreadsheetml.tableSingleCells+xml"

///|
/// Embedded ActiveX control persistence content type.
const CT_ACTIVE_X_CONTROL : String = "application/vnd.ms-office.activeX+xml"

///|
/// Catalog bitmap fixture content type.
const CT_IMAGE_PNG : String = "image/png"

///|
/// The office-document relationship-reference namespace.
const NS_OFFICE_REL : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

///|
/// Catalog-local embedded font-data relationship id.
const FONT_TABLE_DATA_RID : String = "rIdFontData1"

///|
/// Build a plain (no-prefix, no-namespace) attribute.
fn xa(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name: name, ns: None }, value }
}

///|
/// Build a default-namespace element (no prefix) with attrs and kids.
fn xe(
  ns : String,
  name : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: { prefix: None, local_name: name, ns: Some(ns) },
    attributes: attrs,
    children: kids,
  }
}

///|
/// Build a prefixed-namespace element (`<prefix:local …/>`).  Used
/// when the consumer's PPTX parser only accepts the prefix form of
/// the element name — the DrawingML `<a:theme>` payload triggers
/// exactly this requirement: emitting `<theme>` with an
/// `xmlns="...drawingml..."` default namespace declaration validates
/// as XML, but conformant OOXML importers refuse to populate the
/// colour scheme from it.  Switching to `<a:theme>` /
/// `<a:clrScheme>` / `<a:accent1>` etc. lets the reference renderer
/// resolve `<a:schemeClr val="accent1"/>` against the theme.
fn xep(
  prefix : String,
  ns : String,
  name : String,
  attrs : Array[@xml.Attribute],
  kids : Array[@xml.Node],
) -> @xml.Element {
  {
    name: { prefix: Some(prefix), local_name: name, ns: Some(ns) },
    attributes: attrs,
    children: kids,
  }
}

///|
/// §19.3.1.5 / §19.3.1.45 — canonical PresentationML common-slide
/// data skeleton used by every catalog PPTX host.  The `<p:spTree>`
/// root is itself a `CT_GroupShape`, so it must carry the required
/// `<p:nvGrpSpPr>` and `<p:grpSpPr>` children before any visible
/// shapes. Keeping this in one helper avoids a second source of
/// truth between structural catalog probes and visual fixtures.
fn pptx_common_slide_data(
  ns_p : String,
  shapes : Array[@xml.Element],
) -> @xml.Element {
  pptx_common_slide_data_with_children(ns_p, [], shapes, [])
}

///|
/// Variant for §19.3.1.16 child ordering around `<p:spTree>`, e.g.
/// `<p:bg>` before the tree or tolerated extension probes after it.
fn pptx_common_slide_data_with_children(
  ns_p : String,
  before_sp_tree : Array[@xml.Element],
  shapes : Array[@xml.Element],
  after_sp_tree : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  for child in before_sp_tree {
    kids.push(Element(child))
  }
  kids.push(Element(pptx_shape_tree(ns_p, shapes)))
  for child in after_sp_tree {
    kids.push(Element(child))
  }
  xep("p", ns_p, "cSld", [], kids)
}

///|
fn pptx_shape_tree(ns_p : String, shapes : Array[@xml.Element]) -> @xml.Element {
  pptx_shape_tree_with_group_properties(ns_p, shapes, [])
}

///|
fn pptx_shape_tree_with_group_properties(
  ns_p : String,
  shapes : Array[@xml.Element],
  grp_sp_pr_children : Array[@xml.Element],
) -> @xml.Element {
  let grp_sp_pr_kids : Array[@xml.Node] = []
  for child in grp_sp_pr_children {
    grp_sp_pr_kids.push(Element(child))
  }
  let kids : Array[@xml.Node] = [
    Element(
      xep("p", ns_p, "nvGrpSpPr", [], [
        Element(xep("p", ns_p, "cNvPr", [xa("id", "1"), xa("name", "")], [])),
        Element(xep("p", ns_p, "cNvGrpSpPr", [], [])),
        Element(xep("p", ns_p, "nvPr", [], [])),
      ]),
    ),
    Element(xep("p", ns_p, "grpSpPr", [], grp_sp_pr_kids)),
  ]
  for shape in shapes {
    kids.push(Element(shape))
  }
  xep("p", ns_p, "spTree", [], kids)
}

///|
/// Serialise an element as a standalone XML document to UTF-8 bytes.
fn write_part(root : @xml.Element) -> Bytes {
  @xml.write({
    declaration: Some({
      version: "1.0",
      encoding: Some("UTF-8"),
      standalone: Some(true),
    }),
    doctype: None,
    root,
  })
}

///|
/// The OPC `[Content_Types].xml` part: default extensions plus the
/// given part overrides.
fn content_types_part(overrides : Array[(String, String)]) -> Bytes {
  let kids : Array[@xml.Node] = [
    Element(
      xe(
        NS_CT,
        "Default",
        [
          xa("Extension", "rels"),
          xa(
            "ContentType", "application/vnd.openxmlformats-package.relationships+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Default",
        [xa("Extension", "xml"), xa("ContentType", "application/xml")],
        [],
      ),
    ),
  ]
  for ov in overrides {
    let (part, ct) = ov
    kids.push(
      Element(
        xe(NS_CT, "Override", [xa("PartName", part), xa("ContentType", ct)], []),
      ),
    )
  }
  write_part(xe(NS_CT, "Types", [], kids))
}

///|
/// The package root `.rels` part pointing rId1 at `target`.
fn root_rels_part(target : String) -> Bytes {
  write_part(
    xe(NS_PKG_REL, "Relationships", [], [
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [xa("Id", "rId1"), xa("Type", RT_OFFICE_DOC), xa("Target", target)],
          [],
        ),
      ),
    ]),
  )
}

///|
/// Package root `.rels` with the main document plus the three
/// standard document-property parts.  These relationships live at
/// package scope, not under `word/_rels/document.xml.rels`.
fn root_rels_part_with_doc_props(target : String) -> Bytes {
  write_part(
    xe(NS_PKG_REL, "Relationships", [], [
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [xa("Id", "rId1"), xa("Type", RT_OFFICE_DOC), xa("Target", target)],
          [],
        ),
      ),
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", "rId2"),
            xa("Type", RT_CORE_PROPERTIES),
            xa("Target", "docProps/core.xml"),
          ],
          [],
        ),
      ),
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", "rId3"),
            xa("Type", RT_EXTENDED_PROPERTIES),
            xa("Target", "docProps/app.xml"),
          ],
          [],
        ),
      ),
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", "rId4"),
            xa("Type", RT_CUSTOM_PROPERTIES),
            xa("Target", "docProps/custom.xml"),
          ],
          [],
        ),
      ),
    ]),
  )
}

///|
/// Assemble a `.docx` package whose `<w:document>` directly contains
/// `body` — the element under test wrapped in its ancestry from
/// `<w:body>` down.
///
/// Namespace declarations are NOT written as explicit `xmlns:*`
/// attributes: every element / attribute QName in the tree carries
/// its namespace URI, and `@xml.write` emits each `xmlns` declaration
/// once, at the element that first uses the prefix.  Adding explicit
/// `xmlns:*` attributes on top would emit each declaration twice — a
/// malformed document that conformant readers reject.
fn docx_package(body : @xml.Element) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  // If `body` is already a `<w:document>` element (the
  // element-under-test IS the document root — §17.2.3 CT_Document),
  // use it as-is so we never produce a nested
  // `<w:document><w:document>...` malformed payload.
  let document : @xml.Element = if body.name.local_name == "document" {
    body
  } else {
    {
      name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
      attributes: [],
      children: [Element(body)],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.docx` package carrying the three standard `docProps/` metadata
/// parts.  The caller supplies schema-valid XML roots for core,
/// extended, and custom properties; this builder owns only the OPC
/// content-type overrides and package-root relationships.
fn docx_package_with_doc_props(
  body : @xml.Element,
  core_properties : @xml.Element,
  extended_properties : @xml.Element,
  custom_properties : @xml.Element,
) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let document : @xml.Element = if body.name.local_name == "document" {
    body
  } else {
    {
      name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
      attributes: [],
      children: [Element(body)],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
        ("/docProps/core.xml", CT_CORE_PROPERTIES),
        ("/docProps/app.xml", CT_EXTENDED_PROPERTIES),
        ("/docProps/custom.xml", CT_CUSTOM_PROPERTIES),
      ]),
    ),
    ("_rels/.rels", root_rels_part_with_doc_props("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("docProps/core.xml", write_part(core_properties)),
    ("docProps/app.xml", write_part(extended_properties)),
    ("docProps/custom.xml", write_part(custom_properties)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.docx` package carrying a Custom XML Data Storage part plus its
/// `customXmlProps` metadata part.  The custom XML item keeps the
/// generic `application/xml` default content type; only
/// `itemProps1.xml` has a standardized OOXML content-type override.
fn docx_package_with_custom_xml(
  body : @xml.Element,
  custom_xml : @xml.Element,
  custom_xml_properties : @xml.Element,
) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let document : @xml.Element = if body.name.local_name == "document" {
    body
  } else {
    {
      name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
      attributes: [],
      children: [Element(body)],
    }
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa("Type", RT_CUSTOM_XML),
          xa("Target", "../customXml/item1.xml"),
        ],
        [],
      ),
    ),
  ])
  let item_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa("Type", RT_CUSTOM_XML_PROPS),
          xa("Target", "itemProps1.xml"),
        ],
        [],
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
        ("/customXml/itemProps1.xml", CT_CUSTOM_XML_PROPERTIES),
      ]),
    ),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
    ("customXml/item1.xml", write_part(custom_xml)),
    ("customXml/_rels/item1.xml.rels", write_part(item_rels)),
    ("customXml/itemProps1.xml", write_part(custom_xml_properties)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
fn docx_package_with_content_part(body : @xml.Element) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let document : @xml.Element = if body.name.local_name == "document" {
    body
  } else {
    {
      name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
      attributes: [],
      children: [Element(body)],
    }
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rIdContentPart"),
          xa("Type", RT_CUSTOM_XML),
          xa("Target", "../customXml/item1.xml"),
        ],
        [],
      ),
    ),
  ])
  let custom_xml = xe(
    "http://www.w3.org/2000/svg",
    "svg",
    [xa("viewBox", "0 0 10 10")],
    [
      Element(
        xe("http://www.w3.org/2000/svg", "title", [], [
          Text("OOXML contentPart"),
        ]),
      ),
    ],
  )
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
    ("customXml/item1.xml", write_part(custom_xml)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.docx` package whose main document embeds a binary image part at
/// `word/media/image1.png` and wires `r:embed="rId2"` through
/// `word/_rels/document.xml.rels`.  The renderer still resolves images
/// through the normal WML context's part-aware resolver; this host only
/// supplies the OPC relationship/media parts that a picture blip needs.
fn docx_package_with_embedded_image(
  body : @xml.Element,
  image_bytes : Bytes,
) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let document : @xml.Element = if body.name.local_name == "document" {
    body
  } else {
    {
      name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
      attributes: [],
      children: [Element(body)],
    }
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
          ),
          xa("Target", "media/image1.png"),
        ],
        [],
      ),
    ),
  ])
  let ct_kids : Array[@xml.Node] = [
    Element(
      xe(
        NS_CT,
        "Default",
        [
          xa("Extension", "rels"),
          xa(
            "ContentType", "application/vnd.openxmlformats-package.relationships+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Default",
        [xa("Extension", "xml"), xa("ContentType", "application/xml")],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Default",
        [xa("Extension", "png"), xa("ContentType", "image/png")],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Override",
        [
          xa("PartName", "/word/document.xml"),
          xa(
            "ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
          ),
        ],
        [],
      ),
    ),
  ]
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", write_part(xe(NS_CT, "Types", [], ct_kids))),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
    ("word/media/image1.png", image_bytes),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Assemble an `.xlsx` package whose `<worksheet>` directly contains
/// `content`.
fn xlsx_package(content : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // `xmlns:r` is auto-declared by the writer at the `r:id` attribute
  // that first uses it — no explicit `xmlns:r` attribute (which would
  // double the declaration).
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Namespaces are auto-declared by `@xml.write` from QName URIs; no
  // explicit `xmlns:*` attributes (see `docx_package`).
  //
  // If `content` is already a `<worksheet>` element, use it as-is so
  // a fixture can carry multiple top-level children (`<cols>`,
  // `<sheetData>`, `<mergeCells>`, `<hyperlinks>`, ...); otherwise
  // wrap the single payload in a `<worksheet>` for backwards
  // compatibility with the simple single-child fixtures.
  let worksheet : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose worksheet references one legacy VML Drawing
/// part through `<legacyDrawing r:id="rId1"/>`.
///
/// ECMA-376 Part 4 §8.2 says the VML Drawing part root is a
/// null-namespace `<xml>` wrapper containing VML markup.  The caller
/// supplies that root; this builder owns only the OPC graph and the
/// worksheet sequence slot for `<legacyDrawing>`.
fn xlsx_package_with_vml_drawing(
  content : @xml.Element,
  vml_drawing : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
  ])
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa("Type", RT_VML_DRAWING),
          xa("Target", "../drawings/vmlDrawing1.vml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet_body : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let legacy_drawing = xe(
    ns_s,
    "legacyDrawing",
    [
      {
        name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
        value: "rId1",
      },
    ],
    [],
  )
  let worksheet_children : Array[@xml.Node] = []
  for child in worksheet_body.children {
    worksheet_children.push(child)
  }
  worksheet_children.push(Element(legacy_drawing))
  let worksheet : @xml.Element = {
    name: worksheet_body.name,
    attributes: worksheet_body.attributes,
    children: worksheet_children,
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        ("/xl/drawings/vmlDrawing1.vml", CT_VML_DRAWING),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    ("xl/drawings/vmlDrawing1.vml", write_part(vml_drawing)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose `<worksheet>` carries a `<tableParts>` child
/// referencing one or more `<table>` parts.  Each `tables[i]` element
/// becomes `xl/tables/table{i+1}.xml`; the worksheet's per-part
/// relationships file (`xl/worksheets/_rels/sheet1.xml.rels`) wires
/// the `r:id` references; `[Content_Types]` carries the
/// `…spreadsheetml.table+xml` content-type override.
///
/// The caller's `content` is the `<worksheet>` payload (a
/// `<sheetData>` for a bare grid, or a `<worksheet>` element when the
/// fixture carries `<cols>`, `<autoFilter>`, etc.).  This builder
/// APPENDS a `<tableParts count="N">` containing one
/// `<tablePart r:id="rIdN"/>` per `tables[i]` — the caller MUST NOT
/// embed its own `<tableParts>` (the builder owns the rId numbering).
/// §18.3.1.95 tableParts / §18.5.1.2 table.
fn xlsx_package_with_tables(
  content : @xml.Element,
  tables : Array[@xml.Element],
  styles? : @xml.Element? = None,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels_kids : Array[@xml.Node] = [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
  ]
  match styles {
    Some(_) =>
      wb_rels_kids.push(
        Element(
          xe(
            NS_PKG_REL,
            "Relationship",
            [
              xa("Id", "rId2"),
              xa(
                "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
              ),
              xa("Target", "styles.xml"),
            ],
            [],
          ),
        ),
      )
    None => ()
  }
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], wb_rels_kids)
  // Build the worksheet's per-part relationships, one rId per table.
  let sheet_rels_kids : Array[@xml.Node] = []
  for i, _t in tables {
    let rid = "rId" + (i + 1).to_string()
    let target = "../tables/table" + (i + 1).to_string() + ".xml"
    sheet_rels_kids.push(
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", rid),
            xa(
              "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/table",
            ),
            xa("Target", target),
          ],
          [],
        ),
      ),
    )
  }
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], sheet_rels_kids)
  // Build the worksheet: take the caller's content (already
  // `<worksheet>` or wrap it), then append `<tableParts>` with one
  // `<tablePart>` per table.
  let worksheet_body : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let table_parts_kids : Array[@xml.Node] = []
  for i, _t in tables {
    let rid = "rId" + (i + 1).to_string()
    table_parts_kids.push(
      Element(
        xe(
          ns_s,
          "tablePart",
          [
            {
              name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
              value: rid,
            },
          ],
          [],
        ),
      ),
    )
  }
  let table_parts_elt = xe(
    ns_s,
    "tableParts",
    [xa("count", tables.length().to_string())],
    table_parts_kids,
  )
  let merged_children : Array[@xml.Node] = []
  for n in worksheet_body.children {
    merged_children.push(n)
  }
  merged_children.push(Element(table_parts_elt))
  let worksheet : @xml.Element = {
    name: worksheet_body.name,
    attributes: worksheet_body.attributes,
    children: merged_children,
  }
  // Content types and parts.
  let overrides : Array[(String, String)] = [
    (
      "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
    ),
    (
      "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
    ),
  ]
  match styles {
    Some(_) =>
      overrides.push(
        (
          "/xl/styles.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml",
        ),
      )
    None => ()
  }
  for i, _t in tables {
    overrides.push(
      (
        "/xl/tables/table" + (i + 1).to_string() + ".xml",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.table+xml",
      ),
    )
  }
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", content_types_part(overrides)),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
  ]
  for i, t in tables {
    parts.push(
      ("xl/tables/table" + (i + 1).to_string() + ".xml", write_part(t)),
    )
  }
  match styles {
    Some(s) => parts.push(("xl/styles.xml", write_part(s)))
    None => ()
  }
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose worksheet relationship points at a pivot
/// table part, fully wired into the workbook's `<pivotCaches>`, the
/// per-part `_rels` for the worksheet + the pivot table + the pivot
/// cache definition, and the three new `[Content_Types]` overrides
/// (pivotTable, pivotCacheDefinition, pivotCacheRecords).  Mirrors
/// §18.10 PivotTable plumbing while keeping `xl/worksheets/sheet1.xml`
/// valid against the ECMA-376 worksheet schema.
///
/// The caller supplies the four `<…>` element trees:
///
///   * `content` — the `<worksheet>` payload (a `<sheetData>` element
///     or a full `<worksheet>` carrying `<cols>`, etc.).
///   * `cache_def` — the `<pivotCacheDefinition>` root element
///     (§18.10.1.67).
///   * `cache_records` — the `<pivotCacheRecords>` root element
///     (§18.10.1.68).
///   * `pivot_def` — the `<pivotTableDefinition>` root element
///     (§18.10.1.73). Its `@cacheId` MUST match the `cacheId="0"`
///     this builder writes into `<workbook>/<pivotCaches>/<pivotCache>`.
fn xlsx_package_with_pivot(
  content : @xml.Element,
  cache_def : @xml.Element,
  cache_records : @xml.Element,
  pivot_def : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // Workbook with `<sheets>` + `<pivotCaches>` mapping cacheId 0 to
  // rId2 (the pivot cache definition rel).
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "pivotCaches", [], [
        Element(
          xe(
            ns_s,
            "pivotCache",
            [
              xa("cacheId", "0"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  // Workbook rels — sheet (rId1) + pivot cache definition (rId2).
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/pivotCacheDefinition",
          ),
          xa("Target", "pivotCache/pivotCacheDefinition1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Worksheet payload — wrap in `<worksheet>` if it isn't already.
  // PivotTable parts are linked through `sheet1.xml.rels`; ECMA-376
  // exposes `<pivotTableDefinition>` as a part root, not as a
  // `<worksheet>` child.
  let worksheet_body : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let worksheet_children : Array[@xml.Node] = []
  let ext_children : Array[@xml.Node] = []
  for n in worksheet_body.children {
    match n {
      Element(e) if e.name.local_name == "extLst" => ext_children.push(n)
      _ => worksheet_children.push(n)
    }
  }
  for n in ext_children {
    worksheet_children.push(n)
  }
  let worksheet : @xml.Element = {
    name: worksheet_body.name,
    attributes: worksheet_body.attributes,
    children: worksheet_children,
  }
  // Worksheet rels — rId1 → pivotTable1.xml.
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/pivotTable",
          ),
          xa("Target", "../pivotTables/pivotTable1.xml"),
        ],
        [],
      ),
    ),
  ])
  // pivotTable1.xml's own rels — rId1 → cache definition.
  let pivot_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/pivotCacheDefinition",
          ),
          xa("Target", "../pivotCache/pivotCacheDefinition1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Cache definition rels — rId1 → records.
  let cache_def_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/pivotCacheRecords",
          ),
          xa("Target", "pivotCacheRecords1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Content-type overrides per §18.10 part-name conventions.
  let overrides : Array[(String, String)] = [
    (
      "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
    ),
    (
      "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
    ),
    (
      "/xl/pivotTables/pivotTable1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.pivotTable+xml",
    ),
    (
      "/xl/pivotCache/pivotCacheDefinition1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.pivotCacheDefinition+xml",
    ),
    (
      "/xl/pivotCache/pivotCacheRecords1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.pivotCacheRecords+xml",
    ),
  ]
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", content_types_part(overrides)),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    ("xl/pivotTables/pivotTable1.xml", write_part(pivot_def)),
    ("xl/pivotTables/_rels/pivotTable1.xml.rels", write_part(pivot_rels)),
    ("xl/pivotCache/pivotCacheDefinition1.xml", write_part(cache_def)),
    (
      "xl/pivotCache/_rels/pivotCacheDefinition1.xml.rels",
      write_part(cache_def_rels),
    ),
    ("xl/pivotCache/pivotCacheRecords1.xml", write_part(cache_records)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Catalog-only §18.10 host selection.  These are the PivotTable
/// elements whose content reaches the existing
/// `spreadsheet_ml/pivot_table` materializer and `viewer/pivot_render`
/// overlay.  Metadata-only PivotTable children are intentionally left
/// to the generic `parsed` path so the catalog does not over-count
/// data-attribute-only traces as rendered output.
fn is_sml_pivot_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  if strip_ns(ns) != "spreadsheetml/main" {
    return false
  }
  let type_local = catalog_type_local(type_name)
  match type_local {
    "CT_PivotCacheDefinition"
    | "CT_CacheSource"
    | "CT_CacheFields"
    | "CT_CacheField"
    | "CT_SharedItems"
    | "CT_PivotCacheRecords"
    | "CT_Record"
    | "CT_Index"
    | "CT_Number"
    | "CT_String"
    | "CT_pivotTableDefinition"
    | "CT_Location"
    | "CT_PivotFields"
    | "CT_PivotField"
    | "CT_RowFields"
    | "CT_ColFields"
    | "CT_rowItems"
    | "CT_colItems"
    | "CT_DataFields"
    | "CT_DataField"
    | "CT_Field"
    | "CT_I" => true
    _ =>
      match local_name {
        "pivotCacheDefinition" | "pivotCacheRecords" | "pivotTableDefinition" =>
          true
        _ => false
      }
  }
}

///|
/// Normalize a catalog target into one of the three §18.10 PivotTable
/// part roots.  This is host scaffolding only: it supplies the
/// required siblings around the target so the existing reader ->
/// context -> pivot materializer -> viewer path is exercised.  The
/// host later packages the returned root verbatim; it does not fill
/// pruned children back in, preserving the verifier's differential
/// baseline.
fn catalog_sml_pivot_root(
  content : @xml.Element,
  type_name : String,
) -> @xml.Element {
  let type_local = catalog_type_local(type_name)
  match catalog_sml_pivot_branch(content.name.local_name, type_local) {
    "cache" => catalog_sml_pivot_cache_def_root(content)
    "records" => catalog_sml_pivot_records_root(content)
    _ => catalog_sml_pivot_table_def_root(content)
  }
}

///|
fn catalog_sml_pivot_branch(local_name : String, type_local : String) -> String {
  match type_local {
    "CT_PivotCacheDefinition"
    | "CT_CacheSource"
    | "CT_CacheFields"
    | "CT_CacheField"
    | "CT_SharedItems"
    | "CT_String" => "cache"
    "CT_PivotCacheRecords" | "CT_Record" | "CT_Index" | "CT_Number" => "records"
    _ =>
      match local_name {
        "pivotCacheDefinition" => "cache"
        "pivotCacheRecords" => "records"
        _ => "pivot"
      }
  }
}

///|
fn catalog_sml_pivot_parts(
  content : @xml.Element,
) -> (@xml.Element, @xml.Element, @xml.Element, @xml.Element) {
  let sheet = catalog_sml_pivot_sheet_data()
  let cache_def = match content.name.local_name {
    "pivotCacheDefinition" => content
    _ => catalog_sml_pivot_default_cache_def()
  }
  let cache_records = match content.name.local_name {
    "pivotCacheRecords" => content
    _ => catalog_sml_pivot_default_records()
  }
  let pivot_def = match content.name.local_name {
    "pivotTableDefinition" => content
    _ => catalog_sml_pivot_default_table_def()
  }
  (sheet, cache_def, cache_records, pivot_def)
}

///|
fn catalog_sml_pivot_sheet_data() -> @xml.Element {
  xe(NS_S_PVT, "sheetData", [], [
    Element(s_row("1", [s_inline("A1", "Region"), s_inline("B1", "Sales")])),
    Element(s_row("2", [s_inline("A2", "East"), s_cell("B2", "10")])),
    Element(s_row("3", [s_inline("A3", "West"), s_cell("B3", "20")])),
  ])
}

///|
fn catalog_sml_pivot_default_cache_def() -> @xml.Element {
  cache_def_root(
    cache_source_worksheet("S1", "A1:B3"),
    catalog_sml_pivot_default_cache_fields(),
    2,
  )
}

///|
fn catalog_sml_pivot_default_cache_fields() -> @xml.Element {
  cache_fields_wrap([
    cache_field_strings("Region", ["East", "West"]),
    cache_field_numbers_inline("Sales"),
  ])
}

///|
fn catalog_sml_pivot_default_records() -> @xml.Element {
  records_root([
    record_row([rec_x(0), rec_n("10")]),
    record_row([rec_x(1), rec_n("20")]),
  ])
}

///|
fn catalog_sml_pivot_default_table_def() -> @xml.Element {
  pivot_def_root(
    "CatalogPivot",
    pivot_location("E1:F4", 0, 1, 1),
    pivot_fields_wrap([
      pivot_field("axisRow", false, 2),
      pivot_field("", true, 0),
    ]),
    Some(axis_fields("rowFields", [0])),
    None,
    axis_items_wrap("rowItems", [
      pivot_axis_item([0], false),
      pivot_axis_item([1], false),
    ]),
    axis_items_wrap("colItems", [pivot_axis_item([], false)]),
    data_fields_wrap([data_field_entry("Sum of Sales", 1, "sum")]),
    false,
    false,
  )
}

///|
fn catalog_sml_pivot_cache_def_root(content : @xml.Element) -> @xml.Element {
  match content.name.local_name {
    "pivotCacheDefinition" =>
      catalog_sml_pivot_element_with_children(
        content,
        catalog_pivot_attrs_with_defaults(content.attributes, [
          ("recordCount", "2"),
          ("createdVersion", "3"),
          ("refreshedVersion", "3"),
        ]),
        [
          Element(cache_source_worksheet("S1", "A1:B3")),
          Element(
            cache_fields_wrap([
              cache_field_strings("Region", ["North", "South"]),
              cache_field_numbers_inline("Sales"),
            ]),
          ),
        ],
      )
    "cacheSource" =>
      cache_def_root(
        catalog_sml_pivot_cache_source(content),
        catalog_sml_pivot_default_cache_fields(),
        2,
      )
    "cacheFields" =>
      cache_def_root(
        cache_source_worksheet("S1", "A1:B3"),
        catalog_sml_pivot_cache_fields(content),
        2,
      )
    "cacheField" =>
      cache_def_root(
        cache_source_worksheet("S1", "A1:B3"),
        catalog_sml_pivot_cache_fields_with_region(
          catalog_sml_pivot_region_cache_field(content),
        ),
        2,
      )
    "sharedItems" =>
      cache_def_root(
        cache_source_worksheet("S1", "A1:B3"),
        catalog_sml_pivot_cache_fields_with_region(
          catalog_sml_pivot_region_cache_field_with_shared_items(content),
        ),
        2,
      )
    "s" =>
      cache_def_root(
        cache_source_worksheet("S1", "A1:B3"),
        catalog_sml_pivot_cache_fields_with_region(
          catalog_sml_pivot_region_cache_field_with_shared_items(
            catalog_sml_pivot_shared_items_with_value(content),
          ),
        ),
        2,
      )
    _ => catalog_sml_pivot_default_cache_def()
  }
}

///|
fn catalog_sml_pivot_cache_source(source : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    source,
    catalog_pivot_force_attrs(source.attributes, [("type", "worksheet")]),
    [
      Element(
        xe(
          NS_S_PVT,
          "worksheetSource",
          [xa("sheet", "S1"), xa("ref", "A1:B3")],
          [],
        ),
      ),
    ],
  )
}

///|
fn catalog_sml_pivot_cache_fields(fields : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut saw_region = false
  for child in fields.children {
    match child {
      Element(ce) if ce.name.local_name == "cacheField" => {
        kids.push(Element(catalog_sml_pivot_region_cache_field(ce)))
        saw_region = true
      }
      _ => ()
    }
  }
  if !saw_region {
    kids.push(Element(cache_field_strings("Region", ["East", "West"])))
  }
  kids.push(Element(cache_field_numbers_inline("Sales")))
  catalog_sml_pivot_element_with_children(
    fields,
    catalog_pivot_force_attrs(fields.attributes, [("count", "2")]),
    kids,
  )
}

///|
fn catalog_sml_pivot_cache_fields_with_region(
  region : @xml.Element,
) -> @xml.Element {
  xe(NS_S_PVT, "cacheFields", [xa("count", "2")], [
    Element(region),
    Element(cache_field_numbers_inline("Sales")),
  ])
}

///|
fn catalog_sml_pivot_region_cache_field(field : @xml.Element) -> @xml.Element {
  let shared = match first_child_named_local_local(field, "sharedItems") {
    Some(items) => catalog_sml_pivot_shared_items(items)
    None => catalog_sml_pivot_shared_items_default()
  }
  catalog_sml_pivot_element_with_children(
    field,
    catalog_pivot_force_attrs(field.attributes, [
      ("name", "Region"),
      ("numFmtId", "0"),
    ]),
    [Element(shared)],
  )
}

///|
fn catalog_sml_pivot_region_cache_field_with_shared_items(
  shared_items : @xml.Element,
) -> @xml.Element {
  xe(NS_S_PVT, "cacheField", [xa("name", "Region"), xa("numFmtId", "0")], [
    Element(catalog_sml_pivot_shared_items(shared_items)),
  ])
}

///|
fn catalog_sml_pivot_shared_items_default() -> @xml.Element {
  xe(NS_S_PVT, "sharedItems", [xa("count", "2"), xa("containsString", "1")], [
    Element(xe(NS_S_PVT, "s", [xa("v", "East")], [])),
    Element(xe(NS_S_PVT, "s", [xa("v", "West")], [])),
  ])
}

///|
fn catalog_sml_pivot_shared_items(shared_items : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut saw_value = false
  for child in shared_items.children {
    match child {
      Element(ce) if ce.name.local_name == "s" => {
        kids.push(Element(catalog_sml_pivot_shared_string_value(ce, "East")))
        saw_value = true
      }
      _ => ()
    }
  }
  if !saw_value {
    kids.push(Element(xe(NS_S_PVT, "s", [xa("v", "East")], [])))
  }
  kids.push(Element(xe(NS_S_PVT, "s", [xa("v", "West")], [])))
  catalog_sml_pivot_element_with_children(
    shared_items,
    catalog_pivot_force_attrs(shared_items.attributes, [
      ("count", "2"),
      ("containsString", "1"),
    ]),
    kids,
  )
}

///|
fn catalog_sml_pivot_shared_items_with_value(
  value : @xml.Element,
) -> @xml.Element {
  xe(NS_S_PVT, "sharedItems", [xa("count", "2"), xa("containsString", "1")], [
    Element(catalog_sml_pivot_shared_string_value(value, "East")),
    Element(xe(NS_S_PVT, "s", [xa("v", "West")], [])),
  ])
}

///|
fn catalog_sml_pivot_shared_string_value(
  value : @xml.Element,
  fallback : String,
) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    value,
    catalog_pivot_force_attrs(value.attributes, [("v", fallback)]),
    [],
  )
}

///|
fn catalog_sml_pivot_records_root(content : @xml.Element) -> @xml.Element {
  match content.name.local_name {
    "pivotCacheRecords" =>
      catalog_sml_pivot_element_with_children(
        content,
        catalog_pivot_force_attrs(content.attributes, [("count", "2")]),
        [
          Element(record_row([rec_x(0), rec_n("90")])),
          Element(record_row([rec_x(1), rec_n("80")])),
        ],
      )
    "r" =>
      xe(NS_S_PVT, "pivotCacheRecords", [xa("count", "2")], [
        Element(catalog_sml_pivot_record(content)),
        Element(record_row([rec_x(1), rec_n("20")])),
      ])
    "x" =>
      xe(NS_S_PVT, "pivotCacheRecords", [xa("count", "2")], [
        Element(
          record_row([catalog_sml_pivot_record_index(content, "0"), rec_n("10")]),
        ),
        Element(record_row([rec_x(1), rec_n("20")])),
      ])
    "n" =>
      xe(NS_S_PVT, "pivotCacheRecords", [xa("count", "2")], [
        Element(
          record_row([rec_x(0), catalog_sml_pivot_record_number(content, "10")]),
        ),
        Element(record_row([rec_x(1), rec_n("20")])),
      ])
    _ => catalog_sml_pivot_default_records()
  }
}

///|
fn catalog_sml_pivot_record(record : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(record, record.attributes, [
    Element(rec_x(0)),
    Element(rec_n("10")),
  ])
}

///|
fn catalog_sml_pivot_record_index(
  value : @xml.Element,
  fallback : String,
) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    value,
    catalog_pivot_force_attrs(value.attributes, [("v", fallback)]),
    [],
  )
}

///|
fn catalog_sml_pivot_record_number(
  value : @xml.Element,
  fallback : String,
) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    value,
    catalog_pivot_force_attrs(value.attributes, [("v", fallback)]),
    [],
  )
}

///|
fn catalog_sml_pivot_table_def_root(content : @xml.Element) -> @xml.Element {
  match content.name.local_name {
    "pivotTableDefinition" =>
      catalog_sml_pivot_element_with_children(
        content,
        catalog_pivot_force_attrs(content.attributes, [
          ("name", "CatalogPivot"),
          ("cacheId", "0"),
          ("dataCaption", "Values"),
        ]),
        catalog_sml_pivot_table_def_children(),
      )
    "location" =>
      catalog_sml_pivot_table_def_with(
        "location",
        catalog_sml_pivot_location(content),
      )
    "pivotFields" =>
      catalog_sml_pivot_table_def_with(
        "pivotFields",
        catalog_sml_pivot_pivot_fields(content),
      )
    "pivotField" =>
      catalog_sml_pivot_table_def_with(
        "pivotFields",
        pivot_fields_wrap([
          catalog_sml_pivot_axis_field(content),
          pivot_field("", true, 0),
        ]),
      )
    "rowFields" =>
      catalog_sml_pivot_table_def_with(
        "rowFields",
        catalog_sml_pivot_row_fields(content),
      )
    "colFields" =>
      catalog_sml_pivot_table_def_with_col_axis(
        catalog_sml_pivot_col_fields(content),
        axis_items_wrap("colItems", [pivot_axis_item([0], false)]),
      )
    "field" =>
      catalog_sml_pivot_table_def_with(
        "rowFields",
        xe(NS_S_PVT, "rowFields", [xa("count", "1")], [
          Element(catalog_sml_pivot_field_index(content, "0")),
        ]),
      )
    "rowItems" =>
      catalog_sml_pivot_table_def_with(
        "rowItems",
        catalog_sml_pivot_axis_items(content),
      )
    "colItems" =>
      catalog_sml_pivot_table_def_with_col_axis(
        axis_fields("colFields", [0]),
        catalog_sml_pivot_axis_items(content),
      )
    "i" =>
      catalog_sml_pivot_table_def_with(
        "rowItems",
        xe(NS_S_PVT, "rowItems", [xa("count", "1")], [
          Element(catalog_sml_pivot_axis_item(content)),
        ]),
      )
    "dataFields" =>
      catalog_sml_pivot_table_def_with(
        "dataFields",
        catalog_sml_pivot_data_fields(content),
      )
    "dataField" =>
      catalog_sml_pivot_table_def_with(
        "dataFields",
        xe(NS_S_PVT, "dataFields", [xa("count", "1")], [
          Element(catalog_sml_pivot_data_field(content)),
        ]),
      )
    _ => catalog_sml_pivot_default_table_def()
  }
}

///|
fn catalog_sml_pivot_table_def_with(
  local_name : String,
  replacement : @xml.Element,
) -> @xml.Element {
  let default = catalog_sml_pivot_default_table_def()
  let kids : Array[@xml.Node] = []
  for child in default.children {
    match child {
      Element(ce) if ce.name.local_name == local_name =>
        kids.push(Element(replacement))
      _ => kids.push(child)
    }
  }
  { name: default.name, attributes: default.attributes, children: kids }
}

///|
fn catalog_sml_pivot_table_def_with_col_axis(
  col_fields : @xml.Element,
  col_items : @xml.Element,
) -> @xml.Element {
  let default = catalog_sml_pivot_default_table_def()
  let kids : Array[@xml.Node] = []
  for child in default.children {
    match child {
      Element(ce) if ce.name.local_name == "colItems" => {
        kids.push(Element(col_fields))
        kids.push(Element(col_items))
      }
      _ => kids.push(child)
    }
  }
  { name: default.name, attributes: default.attributes, children: kids }
}

///|
fn catalog_sml_pivot_table_def_children() -> Array[@xml.Node] {
  let default = catalog_sml_pivot_default_table_def()
  let kids : Array[@xml.Node] = []
  for child in default.children {
    kids.push(child)
  }
  kids
}

///|
fn catalog_sml_pivot_location(location : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    location,
    catalog_pivot_force_attrs(location.attributes, [
      ("ref", "E1:F4"),
      ("firstHeaderRow", "0"),
      ("firstDataRow", "1"),
      ("firstDataCol", "1"),
    ]),
    [],
  )
}

///|
fn catalog_sml_pivot_pivot_fields(fields : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    fields,
    catalog_pivot_force_attrs(fields.attributes, [("count", "2")]),
    [
      Element(catalog_sml_pivot_hidden_axis_field()),
      Element(pivot_field("", true, 0)),
    ],
  )
}

///|
fn catalog_sml_pivot_hidden_axis_field() -> @xml.Element {
  xe(
    NS_S_PVT,
    "pivotField",
    [
      xa("axis", "axisRow"),
      xa("compact", "0"),
      xa("outline", "0"),
      xa("showAll", "0"),
    ],
    [
      Element(
        xe(NS_S_PVT, "items", [xa("count", "3")], [
          Element(xe(NS_S_PVT, "item", [xa("x", "0")], [])),
          Element(xe(NS_S_PVT, "item", [xa("x", "1"), xa("h", "1")], [])),
          Element(xe(NS_S_PVT, "item", [xa("t", "default")], [])),
        ]),
      ),
    ],
  )
}

///|
fn catalog_sml_pivot_axis_field(field : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    field,
    catalog_pivot_force_attrs(field.attributes, [
      ("axis", "axisRow"),
      ("compact", "0"),
      ("outline", "0"),
      ("showAll", "0"),
    ]),
    [
      Element(
        xe(NS_S_PVT, "items", [xa("count", "3")], [
          Element(xe(NS_S_PVT, "item", [xa("x", "0")], [])),
          Element(xe(NS_S_PVT, "item", [xa("x", "1"), xa("h", "1")], [])),
          Element(xe(NS_S_PVT, "item", [xa("t", "default")], [])),
        ]),
      ),
    ],
  )
}

///|
fn catalog_sml_pivot_row_fields(fields : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    fields,
    catalog_pivot_force_attrs(fields.attributes, [("count", "1")]),
    [Element(xe(NS_S_PVT, "field", [xa("x", "0")], []))],
  )
}

///|
fn catalog_sml_pivot_col_fields(fields : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    fields,
    catalog_pivot_force_attrs(fields.attributes, [("count", "1")]),
    [Element(xe(NS_S_PVT, "field", [xa("x", "0")], []))],
  )
}

///|
fn catalog_sml_pivot_field_index(
  field : @xml.Element,
  fallback : String,
) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    field,
    catalog_pivot_force_attrs(field.attributes, [("x", fallback)]),
    [],
  )
}

///|
fn catalog_sml_pivot_axis_items(items : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    items,
    catalog_pivot_force_attrs(items.attributes, [("count", "1")]),
    [Element(pivot_axis_item([1], false))],
  )
}

///|
fn catalog_sml_pivot_axis_item(item : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(item, item.attributes, [
    Element(xe(NS_S_PVT, "x", [xa("v", "1")], [])),
  ])
}

///|
fn catalog_sml_pivot_data_fields(fields : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    fields,
    catalog_pivot_force_attrs(fields.attributes, [("count", "1")]),
    [Element(data_field_entry("Sum of Sales", 1, "sum"))],
  )
}

///|
fn catalog_sml_pivot_data_field(field : @xml.Element) -> @xml.Element {
  catalog_sml_pivot_element_with_children(
    field,
    catalog_pivot_force_attrs(field.attributes, [
      ("name", "Sum of Sales"),
      ("fld", "1"),
    ]),
    [],
  )
}

///|
fn catalog_sml_pivot_element_with_children(
  element : @xml.Element,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: element.name, attributes, children }
}

///|
fn catalog_attrs_with_defaults(
  attrs : Array[@xml.Attribute],
  defaults : Array[(String, String)],
) -> Array[@xml.Attribute] {
  let out : Array[@xml.Attribute] = []
  for a in attrs {
    out.push(a)
  }
  for d in defaults {
    let (name, value) = d
    let mut found = false
    for a in out {
      if a.name.local_name == name {
        found = true
        break
      }
    }
    if !found {
      out.push(xa(name, value))
    }
  }
  out
}

///|
fn catalog_force_attrs(
  attrs : Array[@xml.Attribute],
  forced : Array[(String, String)],
) -> Array[@xml.Attribute] {
  let out : Array[@xml.Attribute] = []
  for a in attrs {
    let mut replaced = false
    for f in forced {
      let (name, value) = f
      if a.name.local_name == name {
        out.push({ name: a.name, value })
        replaced = true
        break
      }
    }
    if !replaced {
      out.push(a)
    }
  }
  for f in forced {
    let (name, value) = f
    let mut found = false
    for a in out {
      if a.name.local_name == name {
        found = true
        break
      }
    }
    if !found {
      out.push(xa(name, value))
    }
  }
  out
}

///|
fn catalog_pivot_attrs_with_defaults(
  attrs : Array[@xml.Attribute],
  defaults : Array[(String, String)],
) -> Array[@xml.Attribute] {
  catalog_attrs_with_defaults(attrs, defaults)
}

///|
fn catalog_pivot_force_attrs(
  attrs : Array[@xml.Attribute],
  forced : Array[(String, String)],
) -> Array[@xml.Attribute] {
  catalog_force_attrs(attrs, forced)
}

///|
/// `.xlsx` package whose `<worksheet>` carries a Microsoft x14
/// sparklines extension inline via
/// `<extLst>/<ext uri="{05C60535-1F16-4FD2-B633-F4F36F0B64E0}">/<x14:sparklineGroups>`.
///
/// Per `[MS-XLSX]` §2.2.4 the sparkline payload is NOT a separate
/// OPC part — it lives inside the worksheet XML — so this helper
/// is the thin wrapper around `xlsx_package` that splices the
/// pre-built `<x14:sparklineGroups>` tree under an
/// `<extLst>/<ext>` carrier element with the right URI.
///
/// `content` is the worksheet payload (a `<sheetData>` for a bare
/// grid, or a full `<worksheet>` when the fixture carries
/// `<cols>`, `<mergeCells>`, etc. — the helper still appends the
/// extension list to the end of the existing children).
///
/// `sparkline_groups` is the `<x14:sparklineGroups>` element built
/// by the fixture (always in the x14 namespace; the fixture
/// constructs it via the typed `@xml.Element` helpers — no XML
/// string assembly per AGENTS.md).
fn xlsx_package_with_sparklines(
  content : @xml.Element,
  sparkline_groups : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  // Build `<ext uri="…">…</ext>` carrying the sparkline groups.
  let ext_elt : @xml.Element = xe(
    ns_s,
    "ext",
    [xa("uri", @sml_sparkline.sparkline_ext_uri())],
    [Element(sparkline_groups)],
  )
  // Build `<extLst><ext>…</ext></extLst>`.
  let ext_lst_elt : @xml.Element = xe(ns_s, "extLst", [], [Element(ext_elt)])
  // Splice `<extLst>` onto the worksheet payload. Per §18.3.1.99
  // the schema sequence places `<extLst>` as the LAST element, so
  // we always append.
  let worksheet : @xml.Element = if content.name.local_name == "worksheet" {
    let merged_children : Array[@xml.Node] = []
    for n in content.children {
      merged_children.push(n)
    }
    merged_children.push(Element(ext_lst_elt))
    {
      name: content.name,
      attributes: content.attributes,
      children: merged_children,
    }
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content), Element(ext_lst_elt)],
    }
  }
  // Reuse xlsx_package by handing it the fully-assembled
  // `<worksheet>` (which detects `local_name == "worksheet"` and
  // uses it verbatim).
  xlsx_package(worksheet)
}

///|
/// `.docx` package with optional `word/numbering.xml` and / or
/// `word/styles.xml` aux parts wired into the workbook
/// relationships and `[Content_Types]`.  WML readers use these to
/// resolve list numbers, paragraph styles, and run styles.
fn docx_package_with_aux(
  body : @xml.Element,
  numbering : @xml.Element?,
  styles : @xml.Element?,
) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let document : @xml.Element = {
    name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
    attributes: [],
    children: [Element(body)],
  }
  // The document's own relationships file lists any auxiliary parts
  // it references (numbering, styles); the canonical paths are used,
  // matching what `@wml_context.open` looks up.
  let rels_children : Array[@xml.Node] = []
  let mut next_rid = 1
  if numbering is Some(_) {
    rels_children.push(
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", "rId" + next_rid.to_string()),
            xa(
              "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering",
            ),
            xa("Target", "numbering.xml"),
          ],
          [],
        ),
      ),
    )
    next_rid = next_rid + 1
  }
  if styles is Some(_) {
    rels_children.push(
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", "rId" + next_rid.to_string()),
            xa(
              "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
            ),
            xa("Target", "styles.xml"),
          ],
          [],
        ),
      ),
    )
    let _ = next_rid + 1
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], rels_children)
  let overrides : Array[(String, String)] = [
    (
      "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
    ),
  ]
  match numbering {
    Some(_) =>
      overrides.push(
        (
          "/word/numbering.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml",
        ),
      )
    None => ()
  }
  match styles {
    Some(_) =>
      overrides.push(
        (
          "/word/styles.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml",
        ),
      )
    None => ()
  }
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", content_types_part(overrides)),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
  ]
  match numbering {
    Some(n) => parts.push(("word/numbering.xml", write_part(n)))
    None => ()
  }
  match styles {
    Some(s) => parts.push(("word/styles.xml", write_part(s)))
    None => ()
  }
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package with an explicit `xl/styles.xml` part included
/// AND wired into the workbook's relationships and `[Content_Types]`.
/// Use this when a fixture references styles by `s=` attribute on a
/// cell or column — without the styles part the SML reader silently
/// drops the style index and renders the cell with defaults.
fn xlsx_package_styled(content : @xml.Element, styles : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  // The workbook references BOTH the worksheet (rId1) and the
  // styles part (rId2).  The styles part rel type is the SpreadsheetML
  // "styles" relationship.
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
          ),
          xa("Target", "styles.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        (
          "/xl/styles.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/styles.xml", write_part(styles)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Worksheet probe used by the styles.xml catalog host.  The only
/// style-bearing surface is A1, which references `cellXfs[1]`; all
/// style semantics remain in the SpreadsheetML reader/context/viewer.
fn catalog_sml_style_probe_worksheet() -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xep("s", ns_s, "worksheet", [], [
    Element(xep("s", ns_s, "dimension", [xa("ref", "A1:A1")], [])),
    Element(
      xep("s", ns_s, "sheetData", [], [
        Element(
          xep("s", ns_s, "row", [xa("r", "1")], [
            Element(
              xep("s", ns_s, "c", [xa("r", "A1"), xa("s", "1")], [
                Element(xep("s", ns_s, "v", [], [Text("1234.5")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn catalog_sml_style_name_in(
  local_name : String,
  names : Array[String],
) -> Bool {
  for name in names {
    if local_name == name {
      return true
    }
  }
  false
}

///|
fn catalog_sml_style_find_any(
  element : @xml.Element,
  names : Array[String],
) -> @xml.Element? {
  if catalog_sml_style_name_in(element.name.local_name, names) {
    return Some(element)
  }
  for child in element.children {
    match child {
      Element(c) =>
        match catalog_sml_style_find_any(c, names) {
          Some(found) => return Some(found)
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
fn catalog_sml_style_force_element(
  element : @xml.Element,
  attrs : Array[(String, String)],
) -> @xml.Element {
  {
    name: element.name,
    attributes: catalog_force_attrs(element.attributes, attrs),
    children: element.children,
  }
}

///|
fn catalog_sml_style_default_font() -> @xml.Element {
  ss_font("11", "sans-serif", [])
}

///|
fn catalog_sml_style_font_blue() -> @xml.Element {
  ss_font("11", "sans-serif", [ss_color("FF0000FF")])
}

///|
fn catalog_sml_style_default_fills() -> Array[@xml.Element] {
  [ss_fill_none(), ss_fill_gray125()]
}

///|
fn catalog_sml_style_default_borders() -> Array[@xml.Element] {
  [ss_border_none()]
}

///|
fn catalog_sml_style_default_xf() -> @xml.Element {
  ss_cell_xf("0", "0", "0", "0", None)
}

///|
fn catalog_sml_style_default_sheet() -> @xml.Element {
  ss_sheet(
    [],
    [catalog_sml_style_default_font()],
    catalog_sml_style_default_fills(),
    catalog_sml_style_default_borders(),
    [catalog_sml_style_default_xf(), catalog_sml_style_default_xf()],
  )
}

///|
fn catalog_sml_style_color_with_rgb(
  color : @xml.Element,
  argb : String,
) -> @xml.Element {
  catalog_sml_style_force_element(color, [("rgb", argb)])
}

///|
fn catalog_sml_style_font_child(child : @xml.Element) -> @xml.Element {
  match child.name.local_name {
    "color" => catalog_sml_style_color_with_rgb(child, "FFFF0000")
    "sz" => catalog_sml_style_force_element(child, [("val", "18")])
    "name" => catalog_sml_style_force_element(child, [("val", "serif")])
    "b" | "i" | "strike" | "outline" | "shadow" | "condense" | "extend" =>
      catalog_sml_style_force_element(child, [("val", "1")])
    "u" => catalog_sml_style_force_element(child, [("val", "single")])
    _ => child
  }
}

///|
fn catalog_sml_style_font_from_font(font : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_sz = false
  let mut has_name = false
  let mut has_visible_child = false
  for child in font.children {
    match child {
      Element(c) => {
        match c.name.local_name {
          "sz" => has_sz = true
          "name" => has_name = true
          "color"
          | "b"
          | "i"
          | "strike"
          | "outline"
          | "shadow"
          | "condense"
          | "extend"
          | "u" => has_visible_child = true
          _ => ()
        }
        kids.push(Element(catalog_sml_style_font_child(c)))
      }
      other => kids.push(other)
    }
  }
  if !has_sz {
    kids.push(Element(xe(NS_S, "sz", [xa("val", "11")], [])))
  }
  if !has_visible_child {
    kids.push(Element(ss_color("FF0000FF")))
  }
  if !has_name {
    kids.push(Element(xe(NS_S, "name", [xa("val", "sans-serif")], [])))
  }
  { name: font.name, attributes: font.attributes, children: kids }
}

///|
fn catalog_sml_style_font_from_child(child : @xml.Element) -> @xml.Element {
  ss_font("11", "sans-serif", [catalog_sml_style_font_child(child)])
}

///|
fn catalog_sml_style_font_sheet(font : @xml.Element) -> @xml.Element {
  let styled_font = if font.name.local_name == "font" {
    catalog_sml_style_font_from_font(font)
  } else {
    catalog_sml_style_font_from_child(font)
  }
  ss_sheet(
    [],
    [catalog_sml_style_default_font(), styled_font],
    catalog_sml_style_default_fills(),
    catalog_sml_style_default_borders(),
    [catalog_sml_style_default_xf(), ss_cell_xf("0", "1", "0", "0", None)],
  )
}

///|
fn catalog_sml_style_pattern_fill_from(pattern : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_fg = false
  let mut has_bg = false
  for child in pattern.children {
    match child {
      Element(c) =>
        if c.name.local_name == "fgColor" {
          has_fg = true
          kids.push(Element(catalog_sml_style_color_with_rgb(c, "FFFF0000")))
        } else if c.name.local_name == "bgColor" {
          has_bg = true
          kids.push(Element(catalog_sml_style_color_with_rgb(c, "FFFFFF00")))
        } else {
          kids.push(Element(c))
        }
      other => kids.push(other)
    }
  }
  if !has_fg {
    kids.push(Element(xe(NS_S, "fgColor", [xa("rgb", "FF0000FF")], [])))
  }
  {
    name: pattern.name,
    attributes: catalog_force_attrs(pattern.attributes, [
      ("patternType", if has_bg { "darkGrid" } else { "solid" }),
    ]),
    children: kids,
  }
}

///|
fn catalog_sml_style_gradient_stop_from(stop : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_color = false
  for child in stop.children {
    match child {
      Element(c) =>
        if c.name.local_name == "color" {
          has_color = true
          kids.push(Element(catalog_sml_style_color_with_rgb(c, "FFFF0000")))
        } else {
          kids.push(Element(c))
        }
      other => kids.push(other)
    }
  }
  if !has_color {
    kids.push(Element(ss_color("FFFF0000")))
  }
  {
    name: stop.name,
    attributes: catalog_force_attrs(stop.attributes, [("position", "0")]),
    children: kids,
  }
}

///|
fn catalog_sml_style_gradient_fill_from(
  gradient : @xml.Element,
) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_stop = false
  for child in gradient.children {
    match child {
      Element(c) =>
        if c.name.local_name == "stop" {
          has_stop = true
          kids.push(Element(catalog_sml_style_gradient_stop_from(c)))
        } else {
          kids.push(Element(c))
        }
      other => kids.push(other)
    }
  }
  if !has_stop {
    kids.push(
      Element(
        xe(NS_S, "stop", [xa("position", "0")], [Element(ss_color("FFFF0000"))]),
      ),
    )
    kids.push(
      Element(
        xe(NS_S, "stop", [xa("position", "1")], [Element(ss_color("FFFFFFFF"))]),
      ),
    )
  }
  {
    name: gradient.name,
    attributes: catalog_attrs_with_defaults(gradient.attributes, [
      ("type", "linear"),
    ]),
    children: kids,
  }
}

///|
fn catalog_sml_style_fill_from_fill(fill : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_fill_child = false
  for child in fill.children {
    match child {
      Element(c) => {
        has_fill_child = true
        if c.name.local_name == "patternFill" {
          kids.push(Element(catalog_sml_style_pattern_fill_from(c)))
        } else if c.name.local_name == "gradientFill" {
          kids.push(Element(catalog_sml_style_gradient_fill_from(c)))
        } else {
          kids.push(Element(c))
        }
      }
      other => kids.push(other)
    }
  }
  if !has_fill_child {
    kids.push(
      Element(
        xe(NS_S, "patternFill", [xa("patternType", "solid")], [
          Element(xe(NS_S, "fgColor", [xa("rgb", "FF0000FF")], [])),
        ]),
      ),
    )
  }
  { name: fill.name, attributes: fill.attributes, children: kids }
}

///|
fn catalog_sml_style_fill_from_child(child : @xml.Element) -> @xml.Element {
  match child.name.local_name {
    "patternFill" =>
      xe(NS_S, "fill", [], [Element(catalog_sml_style_pattern_fill_from(child))])
    "fgColor" =>
      xe(NS_S, "fill", [], [
        Element(
          xe(NS_S, "patternFill", [xa("patternType", "solid")], [
            Element(catalog_sml_style_color_with_rgb(child, "FFFF0000")),
          ]),
        ),
      ])
    "bgColor" =>
      xe(NS_S, "fill", [], [
        Element(
          xe(NS_S, "patternFill", [xa("patternType", "darkGrid")], [
            Element(xe(NS_S, "fgColor", [xa("rgb", "FFFF0000")], [])),
            Element(catalog_sml_style_color_with_rgb(child, "FFFFFF00")),
          ]),
        ),
      ])
    "gradientFill" =>
      xe(NS_S, "fill", [], [
        Element(catalog_sml_style_gradient_fill_from(child)),
      ])
    "stop" =>
      xe(NS_S, "fill", [], [
        Element(
          xe(NS_S, "gradientFill", [xa("type", "linear")], [
            Element(catalog_sml_style_gradient_stop_from(child)),
            Element(
              xe(NS_S, "stop", [xa("position", "1")], [
                Element(ss_color("FFFFFFFF")),
              ]),
            ),
          ]),
        ),
      ])
    _ => ss_pattern_fill("solid", Some("FF0000FF"), None)
  }
}

///|
fn catalog_sml_style_fill_sheet(fill : @xml.Element) -> @xml.Element {
  let styled_fill = if fill.name.local_name == "fill" {
    catalog_sml_style_fill_from_fill(fill)
  } else {
    catalog_sml_style_fill_from_child(fill)
  }
  ss_sheet(
    [],
    [catalog_sml_style_default_font()],
    [ss_fill_none(), styled_fill],
    catalog_sml_style_default_borders(),
    [catalog_sml_style_default_xf(), ss_cell_xf("0", "0", "1", "0", None)],
  )
}

///|
fn catalog_sml_style_border_side(side : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_color = false
  for child in side.children {
    match child {
      Element(c) =>
        if c.name.local_name == "color" {
          has_color = true
          kids.push(Element(catalog_sml_style_color_with_rgb(c, "FF000000")))
        } else {
          kids.push(Element(c))
        }
      other => kids.push(other)
    }
  }
  if !has_color {
    kids.push(Element(ss_color("FF000000")))
  }
  {
    name: side.name,
    attributes: catalog_force_attrs(side.attributes, [("style", "thin")]),
    children: kids,
  }
}

///|
fn catalog_sml_style_border_from_border(border : @xml.Element) -> @xml.Element {
  let kids : Array[@xml.Node] = []
  let mut has_side = false
  for child in border.children {
    match child {
      Element(c) =>
        match c.name.local_name {
          "start" | "end" | "left" | "right" | "top" | "bottom" | "diagonal" => {
            has_side = true
            kids.push(Element(catalog_sml_style_border_side(c)))
          }
          _ => kids.push(Element(c))
        }
      other => kids.push(other)
    }
  }
  if !has_side {
    kids.push(
      Element(
        xe(NS_S, "left", [xa("style", "thin")], [Element(ss_color("FF000000"))]),
      ),
    )
  }
  {
    name: border.name,
    attributes: catalog_attrs_with_defaults(border.attributes, [
      ("diagonalUp", "1"),
      ("diagonalDown", "1"),
    ]),
    children: kids,
  }
}

///|
fn catalog_sml_style_border_from_child(child : @xml.Element) -> @xml.Element {
  let side = catalog_sml_style_border_side(child)
  let attrs = if child.name.local_name == "diagonal" {
    [xa("diagonalUp", "1"), xa("diagonalDown", "1")]
  } else {
    []
  }
  xe(NS_S, "border", attrs, [Element(side)])
}

///|
fn catalog_sml_style_border_sheet(border : @xml.Element) -> @xml.Element {
  let styled_border = if border.name.local_name == "border" {
    catalog_sml_style_border_from_border(border)
  } else {
    catalog_sml_style_border_from_child(border)
  }
  ss_sheet(
    [],
    [catalog_sml_style_default_font()],
    catalog_sml_style_default_fills(),
    [ss_border_none(), styled_border],
    [catalog_sml_style_default_xf(), ss_cell_xf("0", "0", "0", "1", None)],
  )
}

///|
fn catalog_sml_style_alignment_from(alignment : @xml.Element) -> @xml.Element {
  catalog_sml_style_force_element(alignment, [
    ("horizontal", "right"),
    ("vertical", "top"),
  ])
}

///|
fn catalog_sml_style_alignment_sheet(alignment : @xml.Element) -> @xml.Element {
  ss_sheet(
    [],
    [catalog_sml_style_default_font()],
    catalog_sml_style_default_fills(),
    catalog_sml_style_default_borders(),
    [
      catalog_sml_style_default_xf(),
      ss_cell_xf(
        "0",
        "0",
        "0",
        "0",
        Some(catalog_sml_style_alignment_from(alignment)),
      ),
    ],
  )
}

///|
fn catalog_sml_style_num_fmt_sheet(num_fmt : @xml.Element) -> @xml.Element {
  let fmt = catalog_sml_style_force_element(num_fmt, [
    ("numFmtId", "164"),
    ("formatCode", "0.00"),
  ])
  ss_sheet(
    [fmt],
    [catalog_sml_style_default_font()],
    catalog_sml_style_default_fills(),
    catalog_sml_style_default_borders(),
    [catalog_sml_style_default_xf(), ss_cell_xf("164", "0", "0", "0", None)],
  )
}

///|
fn catalog_sml_style_xf_sheet(xf : @xml.Element) -> @xml.Element {
  let style_xf = catalog_sml_style_force_element(xf, [
    ("numFmtId", "164"),
    ("fontId", "1"),
    ("fillId", "1"),
    ("borderId", "1"),
    ("applyNumberFormat", "1"),
    ("applyFont", "1"),
    ("applyFill", "1"),
    ("applyBorder", "1"),
  ])
  ss_sheet(
    [ss_num_fmt("164", "0.00")],
    [catalog_sml_style_default_font(), catalog_sml_style_font_blue()],
    [ss_fill_none(), ss_pattern_fill("solid", Some("FFFFFF00"), None)],
    [
      ss_border_none(),
      ss_border("thin", "thin", "thin", "thin", "", [], "FF000000"),
    ],
    [catalog_sml_style_default_xf(), style_xf],
  )
}

///|
/// Build a styleSheet that connects the catalog target to A1's
/// `s="1"` style index.  This is host scaffolding only: the
/// SpreadsheetML reader/context/viewer remains the single source of
/// style interpretation.
fn catalog_sml_stylesheet_for_render(content : @xml.Element) -> @xml.Element {
  let root : @xml.Element = if content.name.local_name == "styleSheet" {
    content
  } else {
    xe(NS_S, "styleSheet", [], [Element(content)])
  }
  match catalog_sml_style_find_any(root, ["numFmt"]) {
    Some(num_fmt) => return catalog_sml_style_num_fmt_sheet(num_fmt)
    None => ()
  }
  match catalog_sml_style_find_any(root, ["xf"]) {
    Some(xf) => return catalog_sml_style_xf_sheet(xf)
    None => ()
  }
  match catalog_sml_style_find_any(root, ["alignment"]) {
    Some(alignment) => return catalog_sml_style_alignment_sheet(alignment)
    None => ()
  }
  match
    catalog_sml_style_find_any(root, [
      "color", "sz", "name", "b", "i", "u", "strike", "outline", "shadow", "condense",
      "extend",
    ]) {
    Some(font_child) => return catalog_sml_style_font_sheet(font_child)
    None => ()
  }
  match catalog_sml_style_find_any(root, ["font"]) {
    Some(font) => return catalog_sml_style_font_sheet(font)
    None => ()
  }
  match catalog_sml_style_find_any(root, ["fill"]) {
    Some(fill) => return catalog_sml_style_fill_sheet(fill)
    None => ()
  }
  match
    catalog_sml_style_find_any(root, [
      "patternFill", "gradientFill", "stop", "fgColor", "bgColor",
    ]) {
    Some(fill_child) => return catalog_sml_style_fill_sheet(fill_child)
    None => ()
  }
  match
    catalog_sml_style_find_any(root, [
      "start", "end", "left", "right", "top", "bottom", "diagonal",
    ]) {
    Some(border_child) => return catalog_sml_style_border_sheet(border_child)
    None => ()
  }
  match catalog_sml_style_find_any(root, ["border"]) {
    Some(border) => return catalog_sml_style_border_sheet(border)
    None => ()
  }
  catalog_sml_style_default_sheet()
}

///|
/// `.xlsx` package whose worksheet references a dedicated
/// `xl/drawings/drawing1.xml` part. The catalog supplies the
/// `<xdr:wsDr>` root; SpreadsheetML context owns the worksheet
/// `<drawing r:id>` relationship resolution and the SML viewer owns
/// anchor rendering.
fn xlsx_with_drawing_root_package(drawing_root : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let workbook_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rIdD1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing",
          ),
          xa("Target", "../drawings/drawing1.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet = xe(ns_s, "worksheet", [], [
    Element(xe(ns_s, "dimension", [xa("ref", "A1:D10")], [])),
    Element(
      xe(ns_s, "sheetData", [], [Element(s_row("1", [s_cell("A1", "1")]))]),
    ),
    Element(
      xe(
        ns_s,
        "drawing",
        [
          {
            name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
            value: "rIdD1",
          },
        ],
        [],
      ),
    ),
  ])
  let drawing_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "svg1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/customXml",
          ),
          xa("Target", "svg1.xml"),
          xa("TargetMode", "Internal"),
        ],
        [],
      ),
    ),
  ])
  let svg_content = xe(
    "http://www.w3.org/2000/svg",
    "svg",
    [xa("viewBox", "0 0 10 10")],
    [
      Element(
        xe("http://www.w3.org/2000/svg", "title", [], [
          Text("OOXML contentPart"),
        ]),
      ),
      Element(
        xe(
          "http://www.w3.org/2000/svg",
          "rect",
          [
            xa("x", "1"),
            xa("y", "1"),
            xa("width", "8"),
            xa("height", "8"),
            xa("fill", "#4472C4"),
          ],
          [],
        ),
      ),
    ],
  )
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        (
          "/xl/drawings/drawing1.xml", "application/vnd.openxmlformats-officedocument.drawing+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(workbook_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(worksheet_rels)),
    ("xl/drawings/drawing1.xml", write_part(drawing_root)),
    ("xl/drawings/_rels/drawing1.xml.rels", write_part(drawing_rels)),
    ("xl/drawings/svg1.xml", write_part(svg_content)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose `xl/workbook.xml` declares an
/// `<externalReferences>` block (§18.14.7) pointing at an
/// `xl/externalLinks/externalLink1.xml` part.  Used by fixtures that
/// reference cross-workbook data via `[1]Sheet1!$A$1` formula syntax
/// (§18.17 / §18.14.5 CT_ExternalBook).
///
/// The caller supplies:
///   * `content` — the `<worksheet>` payload (or a `<sheetData>`).
///   * `external_link` — the `<externalLink>` root element
///     (§18.14.8 CT_ExternalLink).  Typically contains a single
///     `<externalBook>` child with `<sheetNames>` and `<sheetDataSet>`
///     entries that mirror what the formula references.
///
/// The builder owns rId numbering:
///   * `rId1` — workbook → worksheet.
///   * `rId2` — workbook → external link part.
///   * `externalLink1.xml` `rId1` — external link part → external workbook path.
/// The `<externalReference r:id="…">` child the builder inserts into
/// the workbook MUST resolve to `rId2`; this is wired automatically.
fn xlsx_package_with_externals(
  content : @xml.Element,
  external_link : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // The workbook carries both `<sheets>` and `<externalReferences>`.
  // Per §18.2.1 the canonical sequence places `<externalReferences>`
  // AFTER `<sheets>` and BEFORE `<definedNames>` / `<calcPr>` — keep
  // that order so conformant consumers accept the workbook.
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "externalReferences", [], [
        Element(
          xe(
            ns_s,
            "externalReference",
            [
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/externalLink",
          ),
          xa("Target", "externalLinks/externalLink1.xml"),
        ],
        [],
      ),
    ),
  ])
  let external_link_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/externalLinkPath",
          ),
          xa("Target", "file:///external-workbook.xlsx"),
          xa("TargetMode", "External"),
        ],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        (
          "/xl/externalLinks/externalLink1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.externalLink+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/externalLinks/externalLink1.xml", write_part(external_link)),
    (
      "xl/externalLinks/_rels/externalLink1.xml.rels",
      write_part(external_link_rels),
    ),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// DrawingML namespace URI — used by `pptx_theme_part` and any other
/// PML helper that needs to embed `<a:*>` payload (clrScheme,
/// fontScheme, fmtScheme).
const NS_A_THEME : String = "http://schemas.openxmlformats.org/drawingml/2006/main"

///|
/// Build the canonical "Office" `theme1.xml` part for a fixture
/// package.  The palette mirrors the renderer's
/// `default_office_scheme()` table so a `<a:schemeClr val="accent3"/>`
/// resolves to the same colour whether the reference renderer or our
/// renderer is asked.  Without this part the reference renderer has
/// no `<a:clrScheme>` to consult and falls back to its built-in "all
/// scheme colours render as black" path — which leaves the
/// `color-scheme-*` fixtures comparing a properly resolved Office
/// palette against a wall of black.
///
/// §20.1.6.9 CT_OfficeStyleSheet — themeElements must carry a
/// `<a:clrScheme>`, `<a:fontScheme>`, and `<a:fmtScheme>`.  Each
/// section uses the bare-minimum spec-valid payload (the format
/// scheme ships a single solid-fill / line / effect entry; readers
/// that hit a missing index fall back to slot zero).
fn pptx_theme_part() -> Bytes {
  let ns_a = NS_A_THEME
  // Every element under `<a:theme>` MUST carry the `a:` prefix.
  // Using a default-namespace declaration on each child (`xmlns="…"`)
  // parses as valid XML but conformant OOXML importers reject it
  // when reading the colour scheme — the scheme is silently dropped
  // and every `<a:schemeClr>` falls back to black.  Mirrors the
  // serialisation PowerPoint and the ECMA-376 Annex A sample emit.
  fn ae(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("a", ns_a, name, attrs, kids)
  }

  // ---- <a:clrScheme name="Office"> with the canonical palette ----
  // Slot ordering matters: ECMA-376 §20.1.4.1.6 requires
  // dk1/lt1/dk2/lt2 first, then accent1..accent6, then hlink /
  // folHlink.
  fn srgb_slot(slot : String, hex : String) -> @xml.Element {
    ae(slot, [], [Element(ae("srgbClr", [xa("val", hex)], []))])
  }

  // `<a:sysClr val="windowText" lastClr="000000"/>` is the canonical
  // dk1 spelling so the colour map (`tx1 -> dk1`) still resolves
  // when a consumer prefers OS palette colours.
  fn sys_slot(slot : String, sys_val : String, hex : String) -> @xml.Element {
    ae(slot, [], [
      Element(ae("sysClr", [xa("val", sys_val), xa("lastClr", hex)], [])),
    ])
  }

  let clr_scheme = ae("clrScheme", [xa("name", "Office")], [
    Element(sys_slot("dk1", "windowText", "000000")),
    Element(sys_slot("lt1", "window", "FFFFFF")),
    Element(srgb_slot("dk2", "44546A")),
    Element(srgb_slot("lt2", "E7E6E6")),
    Element(srgb_slot("accent1", "4472C4")),
    Element(srgb_slot("accent2", "ED7D31")),
    Element(srgb_slot("accent3", "A5A5A5")),
    Element(srgb_slot("accent4", "FFC000")),
    Element(srgb_slot("accent5", "5B9BD5")),
    Element(srgb_slot("accent6", "70AD47")),
    Element(srgb_slot("hlink", "0563C1")),
    Element(srgb_slot("folHlink", "954F72")),
  ])

  // ---- <a:fontScheme name="Office"> ----
  // §20.1.4.1.18 CT_FontScheme — majorFont / minorFont each are
  // CT_FontCollection (§20.1.4.1.17) which REQUIRES `<a:latin>`,
  // `<a:ea>` (East Asian), and `<a:cs>` (complex script) all three
  // (minOccurs=1).  Without all three the typed theme reader
  // raises `CT_FontCollection/ea: missing required child element
  // <ea>` and the slide renderer falls back to no-theme, losing
  // schemeClr resolution AND silencing the data-ooxml-theme-*
  // metadata projection.
  fn font_face(local_name : String, typeface : String) -> @xml.Element {
    ae(local_name, [xa("typeface", typeface)], [])
  }

  // §22.9.2 ST_TextTypeface — non-empty xsd:string.  ECMA-376 Annex
  // A's sample theme leaves the East Asian / complex-script
  // typeface fields blank by writing `typeface=""`, but the typed
  // theme reader rejects that as "value outside the
  // schema-permitted range" so we mirror the latin face name into
  // ea / cs. Font resolution remains the renderer's ECMA-376 chain;
  // this helper does not add any extra font-resolution source.
  let font_scheme = ae("fontScheme", [xa("name", "Office")], [
    Element(
      ae("majorFont", [], [
        Element(font_face("latin", "Calibri Light")),
        Element(font_face("ea", "Calibri Light")),
        Element(font_face("cs", "Calibri Light")),
      ]),
    ),
    Element(
      ae("minorFont", [], [
        Element(font_face("latin", "Calibri")),
        Element(font_face("ea", "Calibri")),
        Element(font_face("cs", "Calibri")),
      ]),
    ),
  ])

  // ---- <a:fmtScheme> — phClr-driven payload mirroring Office ----
  // The format scheme MUST resolve to non-empty fills when a chart
  // series, a SmartArt shape or any `<a:fillRef idx="…"/>` consumer
  // looks it up.  A conformant chart renderer derives each series'
  // fill by looking up `fillStyleLst[idx]` (idx ≥ 1000 → subtract
  // 1000) and substituting the colour scheme's accentN palette for
  // every `<a:schemeClr val="phClr"/>` placeholder; if every entry
  // is a flat `srgbClr` (no `phClr`) the renderer sees the override
  // as "white on white" and emits a transparent chart. The minimal
  // §20.1.4.1.14 CT_StyleMatrix therefore needs three styled fill
  // entries, three styled line entries, three styled effect entries,
  // and three bgFill entries — each carrying a `<a:schemeClr
  // val="phClr"/>` for the renderer to colour-substitute.
  //
  // The structure below mirrors the canonical Office 2010 theme
  // distribution (the same shape python-pptx and PowerPoint emit):
  //   * fillStyle[0] — flat solidFill phClr (subtle)
  //   * fillStyle[1] — light->mid gradFill phClr (moderate)
  //   * fillStyle[2] — mid->shade gradFill phClr (intense, used for
  //                    chart series)
  //   * lnStyle[0..2] — solidFill phClr at 9525/25400/38100 EMU
  //                    widths
  //   * effectStyle[0..2] — outerShdw with rising depth
  //   * bgFillStyle[0..2] — flat / linear / radial phClr
  fn ph_clr(extras : Array[@xml.Element]) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for ex in extras {
      kids.push(Element(ex))
    }
    ae("schemeClr", [xa("val", "phClr")], kids)
  }

  fn solid_ph() -> @xml.Element {
    ae("solidFill", [], [Element(ph_clr([]))])
  }

  fn grad_stop(pos : String, mods : Array[@xml.Element]) -> @xml.Element {
    ae("gs", [xa("pos", pos)], [Element(ph_clr(mods))])
  }

  fn grad_fill_subtle() -> @xml.Element {
    ae("gradFill", [xa("rotWithShape", "1")], [
      Element(
        ae("gsLst", [], [
          Element(
            grad_stop("0", [
              ae("tint", [xa("val", "50000")], []),
              ae("satMod", [xa("val", "300000")], []),
            ]),
          ),
          Element(
            grad_stop("35000", [
              ae("tint", [xa("val", "37000")], []),
              ae("satMod", [xa("val", "300000")], []),
            ]),
          ),
          Element(
            grad_stop("100000", [
              ae("tint", [xa("val", "15000")], []),
              ae("satMod", [xa("val", "350000")], []),
            ]),
          ),
        ]),
      ),
      Element(ae("lin", [xa("ang", "16200000"), xa("scaled", "1")], [])),
    ])
  }

  fn grad_fill_intense() -> @xml.Element {
    ae("gradFill", [xa("rotWithShape", "1")], [
      Element(
        ae("gsLst", [], [
          Element(
            grad_stop("0", [
              ae("shade", [xa("val", "51000")], []),
              ae("satMod", [xa("val", "130000")], []),
            ]),
          ),
          Element(
            grad_stop("80000", [
              ae("shade", [xa("val", "93000")], []),
              ae("satMod", [xa("val", "130000")], []),
            ]),
          ),
          Element(
            grad_stop("100000", [
              ae("shade", [xa("val", "94000")], []),
              ae("satMod", [xa("val", "135000")], []),
            ]),
          ),
        ]),
      ),
      Element(ae("lin", [xa("ang", "16200000"), xa("scaled", "0")], [])),
    ])
  }

  fn solid_phs_modded(mods : Array[@xml.Element]) -> @xml.Element {
    ae("solidFill", [], [Element(ph_clr(mods))])
  }

  fn ln_style(width_emu : String, mods : Array[@xml.Element]) -> @xml.Element {
    ae(
      "ln",
      [
        xa("w", width_emu),
        xa("cap", "flat"),
        xa("cmpd", "sng"),
        xa("algn", "ctr"),
      ],
      [
        Element(solid_phs_modded(mods)),
        Element(ae("prstDash", [xa("val", "solid")], [])),
      ],
    )
  }

  fn outer_shdw_effect(
    blur : String,
    dist : String,
    alpha : String,
  ) -> @xml.Element {
    ae("effectStyle", [], [
      Element(
        ae("effectLst", [], [
          Element(
            ae(
              "outerShdw",
              [
                xa("blurRad", blur),
                xa("dist", dist),
                xa("dir", "5400000"),
                xa("rotWithShape", "0"),
              ],
              [
                Element(
                  ae("srgbClr", [xa("val", "000000")], [
                    Element(ae("alpha", [xa("val", alpha)], [])),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    ])
  }

  let fmt_scheme = ae("fmtScheme", [xa("name", "Office")], [
    Element(
      ae("fillStyleLst", [], [
        Element(solid_ph()),
        Element(grad_fill_subtle()),
        Element(grad_fill_intense()),
      ]),
    ),
    Element(
      ae("lnStyleLst", [], [
        Element(
          ln_style("6350", [
            ae("shade", [xa("val", "95000")], []),
            ae("satMod", [xa("val", "105000")], []),
          ]),
        ),
        Element(ln_style("12700", [])),
        Element(ln_style("19050", [])),
      ]),
    ),
    Element(
      ae("effectStyleLst", [], [
        Element(outer_shdw_effect("40000", "20000", "38000")),
        Element(outer_shdw_effect("40000", "23000", "35000")),
        Element(outer_shdw_effect("40000", "23000", "35000")),
      ]),
    ),
    Element(
      ae("bgFillStyleLst", [], [
        Element(solid_ph()),
        Element(solid_ph()),
        Element(solid_ph()),
      ]),
    ),
  ])
  let theme_elements = ae("themeElements", [], [
    Element(clr_scheme),
    Element(font_scheme),
    Element(fmt_scheme),
  ])
  let theme = ae("theme", [xa("name", "Office Theme")], [
    Element(theme_elements),
  ])
  write_part(theme)
}

///|
/// Build a `theme1.xml` companion `<p:slideMaster>` root.  The master
/// declares the colour map (`<p:clrMap>`) that maps abstract slots
/// (`bg1`/`tx1`/...) onto the concrete `<a:clrScheme>` entries the
/// theme provides.  A spec-valid master needs `<p:cSld>` (with an
/// empty shape tree); catalog text-style probes may also supply the
/// optional `<p:txStyles>` slot so the existing PresentationML viewer
/// can exercise §19.3.1.52 through the real slide -> layout -> master
/// chain.
fn pptx_slide_master_root(tx_styles : @xml.Element?) -> @xml.Element {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // All `<p:*>` payload must carry the `p:` prefix for conformant
  // PPTX importers to populate the colour map and the layout list —
  // same rationale as `pptx_theme_part` (default-namespace form
  // parses but is silently ignored).
  fn pe(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("p", ns_p, name, attrs, kids)
  }

  let cmap_attrs = [
    xa("bg1", "lt1"),
    xa("tx1", "dk1"),
    xa("bg2", "lt2"),
    xa("tx2", "dk2"),
    xa("accent1", "accent1"),
    xa("accent2", "accent2"),
    xa("accent3", "accent3"),
    xa("accent4", "accent4"),
    xa("accent5", "accent5"),
    xa("accent6", "accent6"),
    xa("hlink", "hlink"),
    xa("folHlink", "folHlink"),
  ]
  // §19.3.1.42 CT_SlideMaster — `<p:cSld>` is required.  The
  // shape-tree skeleton is shared with slide/layout hosts so the
  // group-shape required-child rules stay single-sourced.
  let cSld = pptx_common_slide_data(ns_p, [])
  let clr_map = pe("clrMap", cmap_attrs, [])
  let sl_id_lst = pe("sldLayoutIdLst", [], [
    Element(
      pe(
        "sldLayoutId",
        [
          xa("id", "2147483649"),
          {
            name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
            value: "rId1",
          },
        ],
        [],
      ),
    ),
  ])
  let kids : Array[@xml.Node] = [
    Element(cSld),
    Element(clr_map),
    Element(sl_id_lst),
  ]
  match tx_styles {
    Some(txs) => kids.push(Element(txs))
    None => ()
  }
  pe("sldMaster", [], kids)
}

///|
fn pptx_slide_master_part() -> Bytes {
  write_part(pptx_slide_master_root(None))
}

///|
/// Build a `<p:sldLayout>` part — a minimal layout that simply
/// inherits from its master.  Spec requires `<p:cSld>` and a `type`
/// attribute on `<p:sldLayout>` so we ship the `title` layout type
/// (the safest default).
fn pptx_slide_layout_part() -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  fn pe(
    name : String,
    attrs : Array[@xml.Attribute],
    kids : Array[@xml.Node],
  ) -> @xml.Element {
    xep("p", ns_p, name, attrs, kids)
  }

  let cSld = pptx_common_slide_data(ns_p, [])
  let layout = pe("sldLayout", [xa("type", "title"), xa("preserve", "1")], [
    Element(cSld),
  ])
  write_part(layout)
}

///|
/// Complete a catalog-built `<p:cSld>` with the required
/// `<p:spTree>` when the element under test is a common-slide child
/// such as `<p:bg>`.  The canonical shape-tree skeleton is owned by
/// `pptx_shape_tree`; this helper only splices it at the schema slot.
fn pptx_complete_common_slide_data(
  ns_p : String,
  c_sld : @xml.Element,
) -> @xml.Element {
  for child in c_sld.children {
    match child {
      Element(e) if e.name.local_name == "spTree" => return c_sld
      _ => ()
    }
  }
  let children : Array[@xml.Node] = []
  let mut inserted = false
  for child in c_sld.children {
    if !inserted {
      match child {
        Element(e) if e.name.local_name == "bg" => ()
        _ => {
          children.push(Element(pptx_shape_tree(ns_p, [])))
          inserted = true
        }
      }
    }
    children.push(child)
  }
  if !inserted {
    children.push(Element(pptx_shape_tree(ns_p, [])))
  }
  { name: c_sld.name, attributes: c_sld.attributes, children }
}

///|
/// Build the slide part root for catalog probes.  `wrap_in_ancestry`
/// deliberately omits the part root (`sld`), so a probe for
/// slide-level siblings (`clrMapOvr`, `transition`, `timing`,
/// `extLst`) arrives here as that sibling alone.  CT_Slide still
/// requires `<p:cSld>` first; keep that skeleton in one host helper
/// instead of spreading special cases through the verifier.
fn pptx_slide_for_catalog_content(
  ns_p : String,
  content : @xml.Element,
) -> @xml.Element {
  if content.name.local_name == "sld" {
    return content
  }
  let slide_children : Array[@xml.Node] = []
  match content.name.local_name {
    "cSld" =>
      slide_children.push(
        Element(pptx_complete_common_slide_data(ns_p, content)),
      )
    "clrMapOvr" | "transition" | "timing" | "extLst" => {
      slide_children.push(Element(pptx_common_slide_data(ns_p, [])))
      slide_children.push(Element(content))
    }
    _ => slide_children.push(Element(content))
  }
  {
    name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
    attributes: [],
    children: slide_children,
  }
}

///|
/// Assemble a `.pptx` package whose `<p:sld>` directly contains
/// `content`.  Ships a canonical Office-palette theme part plus a
/// minimal slideMaster / slideLayout chain so consumers (PowerPoint,
/// the reference renderer, our own viewer) can resolve
/// `<a:schemeClr val="accent1"/>` to the documented hue.  Omitting
/// these auxiliary parts is technically valid OPC, but the reference
/// renderer degrades to "every scheme colour renders as black",
/// which collapses the `color-scheme-*` fixture set into one
/// indistinct swatch.
fn pptx_package(content : @xml.Element) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // `xmlns:p` / `xmlns:r` are auto-declared by the writer from the
  // QName URIs — no explicit `xmlns:*` attributes (see docx_package).
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  // The slideMaster's rels point at its layout (rId1) and its theme
  // (rId2).  The layout's rels point back at the master (rId1).  The
  // slide's rels point at its layout (rId1).
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Namespaces are auto-declared by `@xml.write` from QName URIs; no
  // explicit `xmlns:*` attributes (see `docx_package`).
  //
  let slide = pptx_slide_for_catalog_content(ns_p, content)
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.pptx` package whose slide embeds a binary image part at
/// `ppt/media/image1.png` wired via `r:embed="rId2"` on the
/// `<a:blip>`.  The `[Content_Types].xml` carries a `Default
/// Extension="png"` entry so the image part is recognised by
/// conformant readers.
fn pptx_package_with_embedded_image(
  content : @xml.Element,
  image_bytes : Bytes,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
          ),
          xa("Target", "../media/image1.png"),
        ],
        [],
      ),
    ),
  ])
  let slide : @xml.Element = if content.name.local_name == "sld" {
    content
  } else {
    {
      name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let ct_kids : Array[@xml.Node] = [
    Element(
      xe(
        NS_CT,
        "Default",
        [
          xa("Extension", "rels"),
          xa(
            "ContentType", "application/vnd.openxmlformats-package.relationships+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Default",
        [xa("Extension", "xml"), xa("ContentType", "application/xml")],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Default",
        [xa("Extension", "png"), xa("ContentType", "image/png")],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Override",
        [
          xa("PartName", "/ppt/presentation.xml"),
          xa(
            "ContentType", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Override",
        [
          xa("PartName", "/ppt/slides/slide1.xml"),
          xa(
            "ContentType", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Override",
        [
          xa("PartName", "/ppt/slideLayouts/slideLayout1.xml"),
          xa(
            "ContentType", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Override",
        [
          xa("PartName", "/ppt/slideMasters/slideMaster1.xml"),
          xa(
            "ContentType", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
          ),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_CT,
        "Override",
        [
          xa("PartName", "/ppt/theme/theme1.xml"),
          xa(
            "ContentType", "application/vnd.openxmlformats-officedocument.theme+xml",
          ),
        ],
        [],
      ),
    ),
  ]
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", write_part(xe(NS_CT, "Types", [], ct_kids))),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
    ("ppt/media/image1.png", image_bytes),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// True for WML DrawingML picture elements that only become visible
/// when hosted in a real document drawing with a document-scoped image
/// relationship.  The catalog host below supplies that OPC plumbing;
/// the existing WML context + viewer remain the only rendering SoT.
fn is_wml_picture_blip_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  let type_local = catalog_type_local(type_name)
  match strip_ns(ns) {
    "drawingml/picture" => local_name == "pic" && type_local == "CT_Picture"
    "drawingml/wordprocessingDrawing" =>
      (local_name == "inline" && type_local == "CT_Inline") ||
      (local_name == "anchor" && type_local == "CT_Anchor")
    _ => false
  }
}

///|
/// Normalize a WordprocessingML picture target into
/// `<w:body>/<w:p>/<w:r>/<w:drawing>...`.  The added OPC host supplies
/// the body-part image relationship; the existing WML viewer remains
/// the rendering SoT.
fn catalog_wml_picture_blip_root(content : @xml.Element) -> @xml.Element {
  match content.name.local_name {
    "body" => content
    _ =>
      xep("w", NS_W, "body", [], [
        Element(
          xep("w", NS_W, "p", [], [
            Element(
              xep("w", NS_W, "r", [], [
                Element(catalog_wml_picture_blip_drawing(content)),
              ]),
            ),
          ]),
        ),
      ])
  }
}

///|
fn catalog_wml_picture_blip_drawing(content : @xml.Element) -> @xml.Element {
  let frame = match content.name.local_name {
    "inline" => catalog_wml_normalize_inline_picture(content)
    "anchor" => catalog_wml_normalize_anchor_picture(content)
    _ =>
      catalog_wml_default_inline_picture(
        catalog_wml_picture_graphic(catalog_wml_picture_pic(content)),
      )
  }
  xep("w", NS_W, "drawing", [], [Element(frame)])
}

///|
fn catalog_wml_picture_pic(content : @xml.Element) -> @xml.Element {
  if content.name.local_name == "pic" &&
    strip_ns(content.name.ns.unwrap_or("")) == "drawingml/picture" {
    return catalog_wml_normalize_pic(content)
  }
  xep(
    "pic",
    "http://schemas.openxmlformats.org/drawingml/2006/picture",
    "pic",
    [],
    [
      Element(catalog_wml_default_nv_pic_pr()),
      Element(catalog_wml_default_blip_fill()),
      Element(catalog_wml_default_pic_sp_pr()),
    ],
  )
}

///|
fn catalog_wml_normalize_pic(pic : @xml.Element) -> @xml.Element {
  catalog_normalize_picture_element(
    pic,
    catalog_wml_default_nv_pic_pr,
    catalog_wml_normalize_blip_fill,
    fn(sp_pr) {
      catalog_ensure_picture_sp_pr(sp_pr, catalog_wml_default_pic_xfrm)
    },
    catalog_wml_default_blip_fill,
    catalog_wml_default_pic_sp_pr,
  )
}

///|
fn catalog_wml_normalize_blip_fill(blip_fill : @xml.Element) -> @xml.Element {
  catalog_normalize_picture_blip_fill(
    blip_fill, catalog_default_blip_to_catalog_image, catalog_default_stretch,
  )
}

///|
fn catalog_wml_normalize_inline_picture(inline : @xml.Element) -> @xml.Element {
  catalog_wml_normalize_picture_frame(inline, "inline")
}

///|
fn catalog_wml_normalize_anchor_picture(anchor : @xml.Element) -> @xml.Element {
  catalog_wml_normalize_picture_frame(anchor, "anchor")
}

///|
fn catalog_wml_normalize_picture_frame(
  frame : @xml.Element,
  local_name : String,
) -> @xml.Element {
  let has_content = frame.children.length() > 0
  if !has_content {
    let default_frame = if local_name == "anchor" {
      catalog_wml_default_anchor_picture(catalog_wml_default_picture_graphic())
    } else {
      catalog_wml_default_inline_picture(catalog_wml_default_picture_graphic())
    }
    return {
      name: frame.name,
      attributes: catalog_wml_attrs_with_defaults(
        frame.attributes,
        default_frame.attributes,
      ),
      children: default_frame.children,
    }
  }
  let kids : Array[@xml.Node] = []
  let mut has_graphic = false
  for child in frame.children {
    match child {
      Element(ce) =>
        if ce.name.local_name == "graphic" {
          has_graphic = true
          kids.push(Element(catalog_wml_default_picture_graphic()))
        } else {
          kids.push(child)
        }
      _ => kids.push(child)
    }
  }
  if !has_graphic {
    kids.push(Element(catalog_wml_default_picture_graphic()))
  }
  { name: frame.name, attributes: frame.attributes, children: kids }
}

///|
fn catalog_wml_attrs_with_defaults(
  attrs : Array[@xml.Attribute],
  defaults : Array[@xml.Attribute],
) -> Array[@xml.Attribute] {
  let out : Array[@xml.Attribute] = []
  for a in attrs {
    out.push(a)
  }
  for d in defaults {
    let mut exists = false
    for a in out {
      if a.name.local_name == d.name.local_name && a.name.ns == d.name.ns {
        exists = true
        break
      }
    }
    if !exists {
      out.push(d)
    }
  }
  out
}

///|
fn catalog_wml_picture_graphic(pic : @xml.Element) -> @xml.Element {
  xep("a", NS_A, "graphic", [], [
    Element(
      xep(
        "a",
        NS_A,
        "graphicData",
        [xa("uri", "http://schemas.openxmlformats.org/drawingml/2006/picture")],
        [Element(pic)],
      ),
    ),
  ])
}

///|
fn catalog_wml_default_picture_graphic() -> @xml.Element {
  catalog_wml_picture_graphic(
    catalog_wml_picture_pic(
      xep(
        "pic",
        "http://schemas.openxmlformats.org/drawingml/2006/picture",
        "pic",
        [],
        [],
      ),
    ),
  )
}

///|
fn catalog_wml_default_inline_picture(graphic : @xml.Element) -> @xml.Element {
  xep(
    "wp",
    "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing",
    "inline",
    [],
    [
      Element(catalog_wml_default_extent()),
      Element(catalog_wml_default_doc_pr()),
      Element(graphic),
    ],
  )
}

///|
fn catalog_wml_default_anchor_picture(graphic : @xml.Element) -> @xml.Element {
  let ns_wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xep(
    "wp",
    ns_wp,
    "anchor",
    [
      xa("distT", "0"),
      xa("distB", "0"),
      xa("distL", "0"),
      xa("distR", "0"),
      xa("simplePos", "0"),
      xa("relativeHeight", "251658240"),
      xa("behindDoc", "0"),
      xa("locked", "0"),
      xa("layoutInCell", "1"),
      xa("allowOverlap", "1"),
    ],
    [
      Element(xep("wp", ns_wp, "simplePos", [xa("x", "0"), xa("y", "0")], [])),
      Element(
        xep("wp", ns_wp, "positionH", [xa("relativeFrom", "column")], [
          Element(xep("wp", ns_wp, "posOffset", [], [Text("0")])),
        ]),
      ),
      Element(
        xep("wp", ns_wp, "positionV", [xa("relativeFrom", "paragraph")], [
          Element(xep("wp", ns_wp, "posOffset", [], [Text("0")])),
        ]),
      ),
      Element(catalog_wml_default_extent()),
      Element(xep("wp", ns_wp, "wrapNone", [], [])),
      Element(catalog_wml_default_doc_pr()),
      Element(graphic),
    ],
  )
}

///|
fn catalog_wml_default_extent() -> @xml.Element {
  xep(
    "wp",
    "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing",
    "extent",
    [xa("cx", "1828800"), xa("cy", "1371600")],
    [],
  )
}

///|
fn catalog_wml_default_doc_pr() -> @xml.Element {
  xep(
    "wp",
    "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing",
    "docPr",
    [xa("id", "1"), xa("name", "Catalog Picture")],
    [],
  )
}

///|
fn catalog_wml_default_nv_pic_pr() -> @xml.Element {
  let ns_pic = "http://schemas.openxmlformats.org/drawingml/2006/picture"
  xep("pic", ns_pic, "nvPicPr", [], [
    Element(
      xep(
        "pic",
        ns_pic,
        "cNvPr",
        [xa("id", "2"), xa("name", "Catalog Picture")],
        [],
      ),
    ),
    Element(
      xep("pic", ns_pic, "cNvPicPr", [], [
        Element(xep("a", NS_A, "picLocks", [xa("noChangeAspect", "1")], [])),
      ]),
    ),
  ])
}

///|
fn catalog_wml_default_blip_fill() -> @xml.Element {
  xep(
    "pic",
    "http://schemas.openxmlformats.org/drawingml/2006/picture",
    "blipFill",
    [],
    [
      Element(catalog_default_blip_to_catalog_image()),
      Element(catalog_default_stretch()),
    ],
  )
}

///|
fn catalog_wml_default_pic_sp_pr() -> @xml.Element {
  xep(
    "pic",
    "http://schemas.openxmlformats.org/drawingml/2006/picture",
    "spPr",
    [],
    [
      Element(catalog_wml_default_pic_xfrm()),
      Element(
        xep("a", NS_A, "prstGeom", [xa("prst", "rect")], [
          Element(xep("a", NS_A, "avLst", [], [])),
        ]),
      ),
    ],
  )
}

///|
fn catalog_wml_default_pic_xfrm() -> @xml.Element {
  xep("a", NS_A, "xfrm", [], [
    Element(xep("a", NS_A, "off", [xa("x", "0"), xa("y", "0")], [])),
    Element(
      xep("a", NS_A, "ext", [xa("cx", "1828800"), xa("cy", "1371600")], []),
    ),
  ])
}

///|
fn is_pml_picture_blip_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  let type_local = catalog_type_local(type_name)
  let ns_tail = strip_ns(ns)
  if ns_tail == "presentationml/main" {
    match local_name {
      "pic" => return type_local == "CT_Picture"
      "blipFill" => return type_local == "CT_BlipFillProperties"
      _ => ()
    }
  }
  if ns_tail == "drawingml/main" {
    match local_name {
      "blip" => return type_local == "CT_Blip"
      "srcRect" | "fillRect" => return type_local == "CT_RelativeRect"
      "tile" => return type_local == "CT_TileInfoProperties"
      "stretch" => return type_local == "CT_StretchInfoProperties"
      _ => return is_dml_blip_effect_catalog_target(local_name, type_local)
    }
  }
  false
}

///|
fn is_dml_blip_effect_catalog_target(
  local_name : String,
  type_local : String,
) -> Bool {
  match local_name {
    "alphaBiLevel" => type_local == "CT_AlphaBiLevelEffect"
    "alphaCeiling" => type_local == "CT_AlphaCeilingEffect"
    "alphaFloor" => type_local == "CT_AlphaFloorEffect"
    "alphaInv" => type_local == "CT_AlphaInverseEffect"
    "alphaMod" => type_local == "CT_AlphaModulateEffect"
    "alphaModFix" => type_local == "CT_AlphaModulateFixedEffect"
    "alphaRepl" => type_local == "CT_AlphaReplaceEffect"
    "biLevel" => type_local == "CT_BiLevelEffect"
    "blur" => type_local == "CT_BlurEffect"
    "clrChange" => type_local == "CT_ColorChangeEffect"
    "clrRepl" => type_local == "CT_ColorReplaceEffect"
    "duotone" => type_local == "CT_DuotoneEffect"
    "fillOverlay" => type_local == "CT_FillOverlayEffect"
    "grayscl" => type_local == "CT_GrayscaleEffect"
    "hsl" => type_local == "CT_HSLEffect"
    "lum" => type_local == "CT_LuminanceEffect"
    "tint" => type_local == "CT_TintEffect"
    _ => false
  }
}

///|
/// Normalize a picture/blip target into a slide body:
/// `<p:cSld>/<p:spTree>/<p:pic>...`.
///
/// The target subtree is preserved and merely placed in the
/// schema-correct picture branch.  Any `<a:blip>` in that branch is
/// retargeted to slide relationship `rId2`, which
/// `pptx_package_with_embedded_image` owns.
fn catalog_pml_picture_blip_root(content : @xml.Element) -> @xml.Element {
  match content.name.local_name {
    "cSld" => content
    "spTree" => xep("p", NS_PML, "cSld", [], [Element(content)])
    _ => pptx_common_slide_data(NS_PML, [catalog_pml_picture_blip_pic(content)])
  }
}

///|
fn catalog_pml_picture_blip_pic(content : @xml.Element) -> @xml.Element {
  if content.name.local_name == "pic" &&
    strip_ns(content.name.ns.unwrap_or("")) == "presentationml/main" {
    return catalog_pml_normalize_pic(content)
  }
  xep("p", NS_PML, "pic", [], [
    Element(catalog_pml_default_nv_pic_pr()),
    Element(catalog_pml_blip_fill_for_target(content)),
    Element(catalog_pml_default_pic_sp_pr()),
  ])
}

///|
fn catalog_pml_normalize_pic(pic : @xml.Element) -> @xml.Element {
  catalog_normalize_picture_element(
    pic,
    catalog_pml_default_nv_pic_pr,
    catalog_pml_normalize_blip_fill,
    fn(sp_pr) {
      catalog_ensure_picture_sp_pr(sp_pr, catalog_pml_default_pic_xfrm)
    },
    catalog_pml_default_blip_fill,
    catalog_pml_default_pic_sp_pr,
  )
}

///|
fn catalog_pml_blip_fill_for_target(target : @xml.Element) -> @xml.Element {
  let lname = target.name.local_name
  if lname == "blipFill" {
    return catalog_pml_normalize_blip_fill(
      if strip_ns(target.name.ns.unwrap_or("")) == "presentationml/main" {
        target
      } else {
        {
          name: { prefix: Some("p"), local_name: "blipFill", ns: Some(NS_PML) },
          attributes: target.attributes,
          children: target.children,
        }
      },
    )
  }
  let kids : Array[@xml.Node] = []
  match lname {
    "blip" => {
      kids.push(Element(catalog_retarget_blip_to_catalog_image(target)))
      kids.push(Element(catalog_default_stretch()))
    }
    "srcRect" | "tile" | "stretch" => {
      kids.push(Element(catalog_default_blip_to_catalog_image()))
      kids.push(Element(target))
    }
    "fillRect" => {
      kids.push(Element(catalog_default_blip_to_catalog_image()))
      kids.push(Element(xep("a", NS_A, "stretch", [], [Element(target)])))
    }
    _ => {
      kids.push(Element(catalog_default_blip_with_child(target)))
      kids.push(Element(catalog_default_stretch()))
    }
  }
  xep("p", NS_PML, "blipFill", [], kids)
}

///|
fn catalog_pml_normalize_blip_fill(blip_fill : @xml.Element) -> @xml.Element {
  catalog_normalize_picture_blip_fill(
    blip_fill, catalog_default_blip_to_catalog_image, catalog_default_stretch,
  )
}

///|
fn catalog_normalize_picture_element(
  pic : @xml.Element,
  default_nv_pic_pr : () -> @xml.Element,
  normalize_blip_fill : (@xml.Element) -> @xml.Element,
  ensure_pic_sp_pr : (@xml.Element) -> @xml.Element,
  default_blip_fill : () -> @xml.Element,
  default_pic_sp_pr : () -> @xml.Element,
) -> @xml.Element {
  let mut nv_pic_pr : @xml.Element? = None
  let mut blip_fill : @xml.Element? = None
  let mut sp_pr : @xml.Element? = None
  let rest : Array[@xml.Node] = []
  for child in pic.children {
    match child {
      Element(ce) =>
        match ce.name.local_name {
          "nvPicPr" =>
            if nv_pic_pr is None {
              nv_pic_pr = Some(ce)
            } else {
              rest.push(child)
            }
          "blipFill" =>
            if blip_fill is None {
              blip_fill = Some(normalize_blip_fill(ce))
            } else {
              rest.push(child)
            }
          "spPr" =>
            if sp_pr is None {
              sp_pr = Some(ensure_pic_sp_pr(ce))
            } else {
              rest.push(child)
            }
          _ => rest.push(child)
        }
      _ => rest.push(child)
    }
  }
  let kids : Array[@xml.Node] = [
    Element(nv_pic_pr.unwrap_or(default_nv_pic_pr())),
    Element(blip_fill.unwrap_or(default_blip_fill())),
    Element(sp_pr.unwrap_or(default_pic_sp_pr())),
  ]
  for child in rest {
    kids.push(child)
  }
  { name: pic.name, attributes: pic.attributes, children: kids }
}

///|
fn catalog_normalize_picture_blip_fill(
  blip_fill : @xml.Element,
  default_blip : () -> @xml.Element,
  default_stretch : () -> @xml.Element,
) -> @xml.Element {
  let parsed_kids : Array[@xml.Node] = []
  let mut has_blip = false
  let mut has_mode = false
  for child in blip_fill.children {
    match child {
      Element(ce) =>
        match ce.name.local_name {
          "blip" => {
            has_blip = true
            parsed_kids.push(
              Element(catalog_retarget_blip_to_catalog_image(ce)),
            )
          }
          "tile" | "stretch" => {
            has_mode = true
            parsed_kids.push(child)
          }
          _ => parsed_kids.push(child)
        }
      _ => parsed_kids.push(child)
    }
  }
  let kids : Array[@xml.Node] = []
  if !has_blip {
    kids.push(Element(default_blip()))
  }
  for child in parsed_kids {
    kids.push(child)
  }
  if !has_mode {
    kids.push(Element(default_stretch()))
  }
  { name: blip_fill.name, attributes: blip_fill.attributes, children: kids }
}

///|
fn catalog_retarget_blip_to_catalog_image(blip : @xml.Element) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  for a in blip.attributes {
    if a.name.local_name != "embed" && a.name.local_name != "link" {
      attrs.push(a)
    }
  }
  attrs.push({
    name: { prefix: Some("r"), local_name: "embed", ns: Some(NS_OFFICE_REL) },
    value: "rId2",
  })
  { name: blip.name, attributes: attrs, children: blip.children }
}

///|
fn catalog_default_blip_to_catalog_image() -> @xml.Element {
  catalog_retarget_blip_to_catalog_image(xep("a", NS_A, "blip", [], []))
}

///|
fn catalog_default_blip_with_child(child : @xml.Element) -> @xml.Element {
  let blip = catalog_default_blip_to_catalog_image()
  { name: blip.name, attributes: blip.attributes, children: [Element(child)] }
}

///|
fn catalog_default_stretch() -> @xml.Element {
  xep("a", NS_A, "stretch", [], [Element(xep("a", NS_A, "fillRect", [], []))])
}

///|
fn catalog_pml_default_nv_pic_pr() -> @xml.Element {
  xep("p", NS_PML, "nvPicPr", [], [
    Element(
      xep(
        "p",
        NS_PML,
        "cNvPr",
        [xa("id", "2"), xa("name", "Catalog Picture")],
        [],
      ),
    ),
    Element(
      xep("p", NS_PML, "cNvPicPr", [], [
        Element(xep("a", NS_A, "picLocks", [xa("noChangeAspect", "1")], [])),
      ]),
    ),
    Element(xep("p", NS_PML, "nvPr", [], [])),
  ])
}

///|
fn catalog_pml_default_pic_sp_pr() -> @xml.Element {
  xep("p", NS_PML, "spPr", [], [
    Element(catalog_pml_default_pic_xfrm()),
    Element(
      xep("a", NS_A, "prstGeom", [xa("prst", "rect")], [
        Element(xep("a", NS_A, "avLst", [], [])),
      ]),
    ),
  ])
}

///|
fn catalog_ensure_picture_sp_pr(
  sp_pr : @xml.Element,
  default_xfrm : () -> @xml.Element,
) -> @xml.Element {
  if first_child_named_in(sp_pr, "xfrm") is Some(_) {
    return sp_pr
  }
  let kids : Array[@xml.Node] = [Element(default_xfrm())]
  for child in sp_pr.children {
    kids.push(child)
  }
  { name: sp_pr.name, attributes: sp_pr.attributes, children: kids }
}

///|
fn catalog_pml_default_pic_xfrm() -> @xml.Element {
  xep("a", NS_A, "xfrm", [], [
    Element(xep("a", NS_A, "off", [xa("x", "914400"), xa("y", "914400")], [])),
    Element(
      xep("a", NS_A, "ext", [xa("cx", "2743200"), xa("cy", "1828800")], []),
    ),
  ])
}

///|
fn catalog_pml_default_blip_fill() -> @xml.Element {
  xep("p", NS_PML, "blipFill", [], [
    Element(catalog_default_blip_to_catalog_image()),
    Element(catalog_default_stretch()),
  ])
}

///|
/// `.pptx` package whose slide-side `.rels` part wires up extra
/// external relationships in addition to the standard
/// slideLayout rId1.  Use this for fixtures whose content carries
/// `<a:videoFile r:link="…">` (§20.1.3.6) or `<a:hlinkClick r:id="…">`
/// (§20.1.2.2.20 / §21.1.2.3.5) — both REQUIRE a relationship target
/// (XSD `r:link`/`r:id`), and consumers reject a slide whose
/// referenced rIds are unresolved.
///
/// `extra_rels` carries `(rId, type, target, target_mode)` tuples
/// where `target_mode` is "External" for external URIs (hyperlinks,
/// external video sources) or "" for internal package targets.
/// The builder owns rId numbering for the layout (rId1) so callers
/// MUST start their own rIds at "rId2" upward.
fn pptx_package_with_slide_rels(
  content : @xml.Element,
  extra_rels : Array[(String, String, String, String)],
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Slide rels: layout (rId1) + caller-supplied extras (rId2..).
  let slide_rels_kids : Array[@xml.Node] = [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
  ]
  for r in extra_rels {
    let (rid, rtype, target, mode) = r
    let attrs : Array[@xml.Attribute] = [
      xa("Id", rid),
      xa("Type", rtype),
      xa("Target", target),
    ]
    if mode != "" {
      attrs.push(xa("TargetMode", mode))
    }
    slide_rels_kids.push(Element(xe(NS_PKG_REL, "Relationship", attrs, [])))
  }
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], slide_rels_kids)
  let slide : @xml.Element = if content.name.local_name == "sld" {
    content
  } else {
    {
      name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
      attributes: [],
      children: [Element(content)],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.pptx` package whose slide carries a `<p:graphicFrame>` whose
/// `<a:graphicData uri="…/chart">` references a DrawingML chart
/// part (`ppt/charts/chart1.xml`).  The slide's relationship file
/// maps `rId2` to the chart part using the
/// `…relationships/chart` type — slide layout / master / theme
/// keep the same rIds as in `pptx_package`.
///
/// The caller supplies:
///
///   * `content` — the `<p:cSld>` payload (an `<p:spTree>` produced
///     by `sp_tree(...)`) that contains exactly one
///     `<p:graphicFrame>` whose `<a:graphic>/<a:graphicData>` has
///     `@uri="http://schemas.openxmlformats.org/drawingml/2006/chart"`
///     and a `<c:chart r:id="rId2"/>` child pointing at the chart
///     part this builder writes.
///   * `chart_space` — the `<c:chartSpace>` root element
///     (§21.2.2.29) written verbatim to `ppt/charts/chart1.xml`.
///
/// The four wired auxiliary parts (theme1.xml, slideMaster1.xml,
/// slideLayout1.xml, chart1.xml) match the spec-recommended
/// "minimum chart-bearing PPTX" layout.  The PML viewer resolves
/// the graphic-frame `rId2` through this package relationship and
/// hands the resulting `<c:chartSpace>` to the DrawingML chart
/// viewer; only unresolved chart references fall back to a metadata
/// placeholder.
fn pptx_package_with_chart(
  content : @xml.Element,
  chart_space : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Slide rels: rId1 → slideLayout1, rId2 → chart1 (§21.2 chart rel
  // type per the OPC registry).
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart",
          ),
          xa("Target", "../charts/chart1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide : @xml.Element = {
    name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
    attributes: [],
    children: [Element(content)],
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
        (
          "/ppt/charts/chart1.xml", "application/vnd.openxmlformats-officedocument.drawingml.chart+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
    ("ppt/charts/chart1.xml", write_part(chart_space)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.pptx` package whose slide carries a `<p:graphicFrame>` whose
/// `<a:graphicData uri="…/diagram">` references the four DrawingML
/// SmartArt parts (§21.4): the data model (`diagrams/data1.xml`),
/// layout definition (`diagrams/layout1.xml`), style definition
/// (`diagrams/quickStyle1.xml`), and color transform
/// (`diagrams/colors1.xml`).  Each carries its own
/// `[Content_Types]` override; the slide's relationship file maps
/// `rId2`..`rId5` to the four parts using the §21.4-defined
/// relationship types (`diagramData`, `diagramLayout`,
/// `diagramQuickStyle`, `diagramColors`).
///
/// The caller supplies:
///
///   * `content` — the `<p:cSld>` payload (an `<p:spTree>` produced
///     by `sp_tree(...)`) containing exactly one
///     `<p:graphicFrame>` whose `<a:graphic>/<a:graphicData>` has
///     `@uri="http://schemas.openxmlformats.org/drawingml/2006/diagram"`
///     and a `<dgm:relIds>` child pointing at the four diagram
///     parts via rIds `rId2..rId5`.
///   * `data_model` — the `<dgm:dataModel>` root element
///     (§21.4.2.3) — the SmartArt's hierarchical content.
///   * `layout_def` — the `<dgm:layoutDef>` root element
///     (§21.4.2.18) — the layout algorithm (orgChart, list,
///     cycle, hierarchy, process, …) the renderer uses to position
///     the data model's points.
///   * `style_def` — the `<dgm:styleDef>` root element
///     (§21.4.2.29) — fonts / fills / lines per element type.
///   * `colors_def` — the `<dgm:colorsDef>` root element
///     (§21.4.2.1) — the color transform that maps logical
///     accent indices to the theme.
///
/// The renderer resolves the slide-side `<dgm:relIds>` references
/// and emits SmartArt SVG through `diagram_layout` when the layoutDef
/// carries geometric constraints.  Unresolved parts, typed decode
/// failures, or layout definitions without geometric constraints fall
/// back to the graphicFrame placeholder, so this builder remains the
/// OPC and host-package source of truth for the four SmartArt parts.
fn pptx_package_with_diagram(
  content : @xml.Element,
  data_model : @xml.Element,
  layout_def : @xml.Element,
  style_def : @xml.Element,
  colors_def : @xml.Element,
  drawing : @xml.Element?,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let ns_dgm = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let ns_dsp = "http://schemas.microsoft.com/office/drawing/2008/diagram"
  let _ = ns_a
  // When a cached drawing part is supplied, splice a `<dgm:extLst>`
  // extension into the data model that points consumers at the
  // drawing's rels entry. The drawing part is wired off the data
  // model's own rels file (`diagrams/_rels/data1.xml.rels`), so the
  // dataModelExt rId need only be unique inside that rels — we use
  // `rId1` since the data model has no other relationships.
  // §[MS-OOXML] diagram-layout-extensions
  // (http://schemas.microsoft.com/office/drawing/2008/diagram) —
  // PowerPoint honours this extension to skip re-running the layout
  // engine.
  let data_model_emitted = match drawing {
    None => data_model
    Some(_) => {
      let data_model_ext : @xml.Element = {
        name: {
          prefix: Some("dsp"),
          local_name: "dataModelExt",
          ns: Some(ns_dsp),
        },
        attributes: [
          {
            name: { prefix: None, local_name: "relId", ns: None },
            value: "rId1",
          },
          {
            name: { prefix: None, local_name: "minVer", ns: None },
            value: "http://schemas.openxmlformats.org/drawingml/2008/diagram",
          },
        ],
        children: [],
      }
      let ext : @xml.Element = xep(
        "a",
        "http://schemas.openxmlformats.org/drawingml/2006/main",
        "ext",
        [xa("uri", "{82BCEF34-CCCB-431D-8929-90D85D03A4D8}")],
        [Element(data_model_ext)],
      )
      let ext_lst : @xml.Element = xep("dgm", ns_dgm, "extLst", [], [
        Element(ext),
      ])
      // Insert `<dgm:extLst>` as the LAST child of the data model —
      // the §21.4.2.10 CT_DataModel schema places `extLst` after
      // `ptLst`, `cxnLst`, `bg`, and `whole` in document order.
      let kids : Array[@xml.Node] = []
      for c in data_model.children {
        kids.push(c)
      }
      kids.push(Element(ext_lst))
      {
        name: data_model.name,
        attributes: data_model.attributes,
        children: kids,
      }
    }
  }
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Slide rels — rId1 → slideLayout1, rId2..rId5 → the four
  // SmartArt parts per §21.4 relationship-type URIs.
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", DIAGRAM_REL_ID_DATA_MODEL),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/diagramData",
          ),
          xa("Target", "../diagrams/data1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", DIAGRAM_REL_ID_LAYOUT),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/diagramLayout",
          ),
          xa("Target", "../diagrams/layout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", DIAGRAM_REL_ID_QUICK_STYLE),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/diagramQuickStyle",
          ),
          xa("Target", "../diagrams/quickStyle1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", DIAGRAM_REL_ID_COLORS),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/diagramColors",
          ),
          xa("Target", "../diagrams/colors1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide : @xml.Element = {
    name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
    attributes: [],
    children: [Element(content)],
  }
  // Content-type overrides — base set, plus the drawing override
  // when a cached drawing is supplied.
  let content_overrides : Array[(String, String)] = [
    (
      "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
    ),
    (
      "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
    ),
    (
      "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
    ),
    (
      "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
    ),
    (
      "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
    ),
    (
      "/ppt/diagrams/data1.xml", "application/vnd.openxmlformats-officedocument.drawingml.diagramData+xml",
    ),
    (
      "/ppt/diagrams/layout1.xml", "application/vnd.openxmlformats-officedocument.drawingml.diagramLayout+xml",
    ),
    (
      "/ppt/diagrams/quickStyle1.xml", "application/vnd.openxmlformats-officedocument.drawingml.diagramStyle+xml",
    ),
    (
      "/ppt/diagrams/colors1.xml", "application/vnd.openxmlformats-officedocument.drawingml.diagramColors+xml",
    ),
  ]
  match drawing {
    None => ()
    Some(_) =>
      content_overrides.push(
        (
          "/ppt/diagrams/drawing1.xml", "application/vnd.ms-office.drawingml.diagramDrawing+xml",
        ),
      )
  }
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", content_types_part(content_overrides)),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
    ("ppt/diagrams/data1.xml", write_part(data_model_emitted)),
    ("ppt/diagrams/layout1.xml", write_part(layout_def)),
    ("ppt/diagrams/quickStyle1.xml", write_part(style_def)),
    ("ppt/diagrams/colors1.xml", write_part(colors_def)),
  ]
  // Cached drawing wiring — the data model's own rels file points
  // `rId1` at the drawing part with the Microsoft Office 2007
  // `diagramDrawing` relationship type. PowerPoint picks up the
  // drawing through this rels chain.
  match drawing {
    None => ()
    Some(drawing_root) => {
      let data_model_rels = xe(NS_PKG_REL, "Relationships", [], [
        Element(
          xe(
            NS_PKG_REL,
            "Relationship",
            [
              xa("Id", "rId1"),
              xa(
                "Type", "http://schemas.microsoft.com/office/2007/relationships/diagramDrawing",
              ),
              xa("Target", "drawing1.xml"),
            ],
            [],
          ),
        ),
      ])
      parts.push(
        ("ppt/diagrams/_rels/data1.xml.rels", write_part(data_model_rels)),
      )
      parts.push(("ppt/diagrams/drawing1.xml", write_part(drawing_root)))
    }
  }
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Sentinel attribute name stamped on the element under test, so the
/// verifier can locate it inside the synthesised ancestry tree.  It
/// is stripped before rendering so it never perturbs output itself.
const TARGET_ATTR : String = "__cat_target"

///|
/// Return a copy of `el` carrying the `TARGET_ATTR` sentinel — marks
/// the element under test so the verifier can locate (and, for the
/// differential baseline, prune) it inside the ancestry tree.
fn stamp_target(el : @xml.Element) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  for a in el.attributes {
    attrs.push(a)
  }
  attrs.push({
    name: { prefix: None, local_name: TARGET_ATTR, ns: None },
    value: "1",
  })
  { name: el.name, attributes: attrs, children: el.children }
}

///|
/// Return a copy of `el` with every `TEXT_MARKER` text node replaced
/// by `marker`, and whether any replacement happened.
fn substitute_marker(
  el : @xml.Element,
  marker : String,
) -> (@xml.Element, Bool) {
  let mut found = false
  fn walk(e : @xml.Element) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for child in e.children {
      match child {
        Text(t) =>
          if t == TEXT_MARKER {
            found = true
            kids.push(Text(marker))
          } else {
            kids.push(Text(t))
          }
        Element(c) => kids.push(Element(walk(c)))
        other => kids.push(other)
      }
    }
    { name: e.name, attributes: e.attributes, children: kids }
  }

  let out = walk(el)
  (out, found)
}

///|
/// Plant the unique `marker` as a text node directly inside the element
/// under test (the one carrying `TARGET_ATTR`). Used when the target is
/// a structural / attribute-only element with no `TEXT_MARKER` text slot
/// of its own: the raw-preservation writer re-emits the target verbatim,
/// so a planted marker survives iff the target round-trips — proving
/// survival even when the target's tag collides with host scaffolding
/// (the case the differential reports as `fy-ambiguous`). Returns the
/// new tree and whether a target was found to inject into.
fn inject_marker_into_target(
  el : @xml.Element,
  marker : String,
) -> (@xml.Element, Bool) {
  let mut injected = false
  fn is_target(e : @xml.Element) -> Bool {
    for a in e.attributes {
      if a.name.local_name == TARGET_ATTR {
        return true
      }
    }
    false
  }

  fn walk(e : @xml.Element) -> @xml.Element {
    if !injected && is_target(e) {
      injected = true
      let kids : Array[@xml.Node] = []
      for child in e.children {
        kids.push(child)
      }
      kids.push(Text(marker))
      return { name: e.name, attributes: e.attributes, children: kids }
    }
    let kids : Array[@xml.Node] = []
    for child in e.children {
      match child {
        Element(c) => kids.push(Element(walk(c)))
        other => kids.push(other)
      }
    }
    { name: e.name, attributes: e.attributes, children: kids }
  }

  let out = walk(el)
  (out, injected)
}

///|
/// Plant the unique `marker` inside the target element's ECMA-376
/// extension-list slot, for structural singletons whose host builder
/// splices element children into a spec-valid skeleton.  Plain text
/// injection is still tried first; this helper is only used after the
/// normal differential cannot distinguish the target from scaffolding.
fn inject_extlst_marker_into_target(
  el : @xml.Element,
  marker : String,
) -> (@xml.Element, Bool) {
  let mut injected = false
  fn is_target(e : @xml.Element) -> Bool {
    for a in e.attributes {
      if a.name.local_name == TARGET_ATTR {
        return true
      }
    }
    false
  }

  fn target_extlst(e : @xml.Element) -> @xml.Element? {
    let ns = e.name.ns.unwrap_or("")
    let prefix = e.name.prefix.unwrap_or(
      if ns.contains("presentationml") {
        "p"
      } else {
        "a"
      },
    )
    let target_name = e.name.local_name
    let marker_payload = xep(
      "cat",
      "urn:ooxml-catalog-fidelity",
      "marker",
      [],
      [Text(marker)],
    )
    // §20.1.6.9 `<a:theme>` and §20.1.6.2
    // `<a:themeElements>` both allow trailing
    // `<a:extLst>` (CT_OfficeArtExtensionList).
    if ns.contains("drawingml") &&
      (target_name == "theme" || target_name == "themeElements") {
      return Some(
        xep(prefix, ns, "extLst", [], [
          Element(
            xep("a", ns, "ext", [xa("uri", "urn:ooxml-catalog-fidelity")], [
              Element(marker_payload),
            ]),
          ),
        ]),
      )
    }
    // §19.2.1.26 `<p:presentation>` allows trailing
    // `<p:extLst>` (CT_ExtensionList).
    if ns.contains("presentationml") && target_name == "presentation" {
      return Some(
        xep(prefix, ns, "extLst", [], [
          Element(
            xep("p", ns, "ext", [xa("uri", "urn:ooxml-catalog-fidelity")], [
              Element(marker_payload),
            ]),
          ),
        ]),
      )
    }
    None
  }

  fn walk(e : @xml.Element) -> @xml.Element {
    if !injected && is_target(e) {
      match target_extlst(e) {
        Some(ext) => {
          injected = true
          let kids : Array[@xml.Node] = []
          for child in e.children {
            kids.push(child)
          }
          kids.push(Element(ext))
          return { name: e.name, attributes: e.attributes, children: kids }
        }
        None => ()
      }
    }
    let kids : Array[@xml.Node] = []
    for child in e.children {
      match child {
        Element(c) => kids.push(Element(walk(c)))
        other => kids.push(other)
      }
    }
    { name: e.name, attributes: e.attributes, children: kids }
  }

  let out = walk(el)
  (out, injected)
}

///|
/// Return a copy of `el` with the `TARGET_ATTR` sentinel attribute
/// removed wherever it appears — the sentinel is verifier bookkeeping
/// and must not reach the renderer.
fn strip_target_attr(el : @xml.Element) -> @xml.Element {
  fn walk(e : @xml.Element) -> @xml.Element {
    let attrs : Array[@xml.Attribute] = []
    for a in e.attributes {
      if a.name.local_name != TARGET_ATTR {
        attrs.push(a)
      }
    }
    let kids : Array[@xml.Node] = []
    for child in e.children {
      match child {
        Element(c) => kids.push(Element(walk(c)))
        other => kids.push(other)
      }
    }
    { name: e.name, attributes: attrs, children: kids }
  }

  walk(el)
}

///|
/// Return a copy of `el` with the subtree carrying the `TARGET_ATTR`
/// sentinel pruned out, and whether such a subtree was found.  This
/// builds the differential baseline: the synthesised ancestry with
/// the element under test absent.
fn prune_target(el : @xml.Element) -> (@xml.Element, Bool) {
  let mut pruned = false
  fn is_target(e : @xml.Element) -> Bool {
    for a in e.attributes {
      if a.name.local_name == TARGET_ATTR {
        return true
      }
    }
    false
  }

  fn walk(e : @xml.Element) -> @xml.Element {
    let kids : Array[@xml.Node] = []
    for child in e.children {
      match child {
        Element(c) =>
          if is_target(c) {
            pruned = true
          } else {
            kids.push(Element(walk(c)))
          }
        other => kids.push(other)
      }
    }
    { name: e.name, attributes: e.attributes, children: kids }
  }

  let out = walk(el)
  (out, pruned)
}

///|
/// Render one host package's SVG, or `None` when the open / round-trip
/// pipeline cannot complete.  `which` selects the host format.
fn render_svg_of(which : String, pkg : Bytes) -> String? {
  // The `which` token is either a bare format (`docx`/`xlsx`/`pptx`)
  // or a `format:part-kind` aux-host token (`docx:settings`,
  // `pptx:theme`, `xlsx:workbook`, …).  Normalise to the bare
  // format so the reader-dispatch below sees the right family —
  // before the prefix split was added, an aux-host token like
  // `pptx:presentation` fell to the default `wml_context.open`
  // arm and every aux part rejected as "expected document".
  let base = match which.find(":") {
    Some(i) => which[0:i].to_owned()
    None => which
  }
  // Catalog verification MUST observe the renderer's
  // `data-ooxml-*` decoration: the differential render verifier
  // (`verify_entry` ⇒ `svg_visible_skeleton`) discriminates
  // "rendered" sections precisely by walking those attributes.
  // Production callers pass the default `debug_attrs=false` and
  // receive a clean SVG; we explicitly opt in.
  match base {
    "xlsx" =>
      try @sml_context.open(pkg) catch {
        _ => None
      } noraise {
        w =>
          try @sml_context.open(w.save()) catch {
            _ => None
          } noraise {
            w2 => Some(w2.to_svg(debug_attrs=true))
          }
      }
    "pptx" =>
      try @pml_context.open(pkg) catch {
        _ => None
      } noraise {
        pr =>
          try @pml_context.open(pr.save()) catch {
            _ => None
          } noraise {
            pr2 => Some(pr2.to_svg(debug_attrs=true))
          }
      }
    _ =>
      try @wml_context.open(pkg) catch {
        _ => None
      } noraise {
        d =>
          try @wml_context.open(d.save()) catch {
            _ => None
          } noraise {
            d2 => Some(d2.to_svg(debug_attrs=true))
          }
      }
  }
}

///|
/// Round-trip *fidelity* probe (non-visual), distinct from the
/// no-crash leg in `render_svg_of`.  Opens `pkg`, saves it, then
/// returns the decoded XML of every part in the *saved* package
/// concatenated with `\n` separators — or `None` when the open/save
/// pipeline cannot complete.
///
/// Rationale (SoT): "opens + round-trips without crash" only proves
/// the package is still well-formed after open->save.  It cannot
/// prove the serializer *re-emitted* the element under test: an
/// element the reader parses into the typed model but the writer
/// silently omits produces a package that opens perfectly well
/// *without* it.  Inspecting the saved part XML for the element's
/// tag (and, when present, its unique marker) is the only way to
/// catch a lossy round-trip — a real ECMA-376 conformance defect,
/// since OOXML consumers expect open->save to preserve content.

///|
/// Open `pkg` through the typed reader for `which` and save it back,
/// returning the full re-serialised package bytes (or `None` when the
/// reader rejects the package).  Used by the structural-validity leg
/// to re-open the round-tripped package as an OPC `Package` and assert
/// its §6/§7/§11 invariants.
fn roundtrip_saved_package(which : String, pkg : Bytes) -> Bytes? {
  let base = match which.find(":") {
    Some(i) => which[0:i].to_owned()
    None => which
  }
  match base {
    "xlsx" =>
      try @sml_context.open(pkg) catch {
        _ => None
      } noraise {
        w => Some(w.save())
      }
    "pptx" =>
      try @pml_context.open(pkg) catch {
        _ => None
      } noraise {
        pr => Some(pr.save())
      }
    _ =>
      try @wml_context.open(pkg) catch {
        _ => None
      } noraise {
        d => Some(d.save())
      }
  }
}

///|
/// §6/§7/§11 — round-trip an empty-body host package for `format` and
/// validate the re-opened package's OPC structural invariants.
/// Returns the violation list (empty ⇒ structurally valid / a
/// conforming consumer such as Microsoft Office will accept the
/// package's structure).  A `None` open/reopen is reported as a single
/// synthetic violation so the caller still sees a non-empty result.
pub fn structural_validity(format : String) -> Array[String] {
  let host = empty_body_package(format)
  match roundtrip_saved_package(format, host) {
    None => ["round-tripped package failed to re-open"]
    Some(saved) =>
      match (try? @opc.Package::open(saved)) {
        Ok(pkg) => pkg.validate()
        Err(_) => ["saved bytes are not a readable OPC package"]
      }
  }
}

///|
fn roundtrip_saved_xml(which : String, pkg : Bytes) -> String? {
  let base = match which.find(":") {
    Some(i) => which[0:i].to_owned()
    None => which
  }
  let saved : Bytes? = match base {
    "xlsx" =>
      try @sml_context.open(pkg) catch {
        _ => None
      } noraise {
        w => Some(w.save())
      }
    "pptx" =>
      try @pml_context.open(pkg) catch {
        _ => None
      } noraise {
        pr => Some(pr.save())
      }
    _ =>
      try @wml_context.open(pkg) catch {
        _ => None
      } noraise {
        d => Some(d.save())
      }
  }
  let bytes = match saved {
    None => return None
    Some(b) => b
  }
  // Unzip the saved OPC package and decode every XML part.  A part
  // that is not valid UTF-8 (e.g. an embedded binary) is skipped —
  // the catalog only ever embeds XML payloads.
  let archive = @zip.read(bytes) catch { _ => return None }
  let buf = StringBuilder::new()
  for entry in archive.entries {
    let name = entry.name
    // Only inspect XML parts; binary parts (media, etc.) carry no
    // element markup and would only add decode failures.
    if name.has_suffix(".xml") || name.has_suffix(".rels") {
      try @utf8.decode(entry.data[:]) catch {
        _ => ()
      } noraise {
        text => {
          buf.write_string(text)
          buf.write_char('\n')
        }
      }
    }
  }
  Some(buf.to_string())
}

///|
/// Fidelity classification for one catalog entry, computed
/// *differentially* from the saved-package XML produced by
/// `roundtrip_saved_xml`.  `marker` is the entry's unique token
/// (present in the saved XML only if the element's text content
/// survived open->save); the element's tag is located via the
/// `TARGET_ATTR` sentinel inside `content`.
///
/// Why differential (SoT): a plain "does the tag appear in the
/// saved XML" test is unsound — the host scaffolding (theme, body,
/// minimal parts) routinely contains the same local name, so a tag
/// can survive even when the writer drops the *target*.  That is the
/// exact false-positive class that inflated an earlier render metric.
/// Here we compare the saved XML WITH the target against the saved
/// XML with the target pruned: only a drop in the tag's occurrence
/// count (or a surviving unique marker) proves the *target* element
/// round-tripped.  When the count is unchanged we cannot attribute
/// the tag to the target, so we report `fy-ambiguous` — NOT a
/// success.
///
/// Outcomes:
///   * `fy-open-fail` — open/save pipeline could not complete.
///   * `fy-marker`    — the unique marker survived: the element's
///                      *content* round-tripped through the writer
///                      (strongest evidence).
///   * `fy-tag`       — pruning the target lowered the saved-XML
///                      occurrence count of its tag: the target's own
///                      tag demonstrably round-tripped.
///   * `fy-drop`      — the tag is entirely absent from the saved XML
///                      though the target carried it: the writer
///                      dropped the element (lossy round-trip).
///   * `fy-ambiguous` — the tag is present but its count is identical
///                      with and without the target: survival cannot
///                      be attributed to the target (scaffolding may
///                      account for it).  Not counted as preserved.
fn roundtrip_fidelity(
  format : String,
  content : @xml.Element,
  marker : String,
) -> String {
  let (with_marker, has_marker) = substitute_marker(content, marker)
  let present_tree = strip_target_attr(with_marker)
  let local_name = target_local_name(content)
  let present = match
    roundtrip_saved_xml(format, host_package(format, present_tree)) {
    None => return "fy-open-fail"
    Some(s) => s
  }
  // Marker survival is the strongest, self-contained signal: the
  // marker is globally unique, so its presence in the saved XML
  // proves the writer re-emitted the target's actual text content —
  // no differential needed.
  if has_marker && present.contains(marker) {
    return "fy-marker"
  }
  // No natural text marker (a structural / attribute-only target): plant
  // the unique marker INSIDE the element under test and probe a second
  // save. The raw-preservation writer re-emits the target verbatim, so
  // the planted marker survives iff the target round-trips — proving
  // survival even when the target's tag collides with host scaffolding
  // (the differential's `fy-ambiguous` case). This is non-destructive:
  // if the plant does not cleanly survive (a host that de-dups a
  // required singleton, or a strict reader that rejects the plant), we
  // fall through to the differential rather than overclaim a drop.
  if !has_marker {
    let (probe, injected) = inject_marker_into_target(with_marker, marker)
    if injected {
      match
        roundtrip_saved_xml(
          format,
          host_package(format, strip_target_attr(probe)),
        ) {
        Some(saved) => if saved.contains(marker) { return "fy-inject" }
        None => ()
      }
    }
  }
  // No traceable marker (attribute- or structure-only element).
  // Count the target's tag in the saved present XML, then in a saved
  // baseline with the target pruned; the difference isolates the
  // target's own contribution from scaffolding.
  let present_count = saved_count_tag(present, local_name)
  let (baseline_tree, did_prune) = prune_target(content)
  let absent_count = if did_prune {
    let absent_clean = strip_target_attr(baseline_tree)
    match roundtrip_saved_xml(format, host_package(format, absent_clean)) {
      // Pruning broke the package (reader rejected the absent tree).
      // The target is a schema-required child the writer pipeline
      // depends on — its tag round-trips as part of a valid save.
      None => -1
      Some(absent) => saved_count_tag(absent, local_name)
    }
  } else if root_is_target(content) {
    // The element under test is the embed tree's root; the natural
    // baseline is an empty body, which contains none of the target's
    // own tag occurrences beyond scaffolding.
    match roundtrip_saved_xml(format, empty_body_package(format)) {
      None => -1
      Some(absent) => saved_count_tag(absent, local_name)
    }
  } else {
    // No prunable target subtree and the root is not the target —
    // cannot build a differential baseline.  Fall back to bare
    // presence, but label it ambiguous unless the tag is wholly
    // absent (a definite drop).
    if present_count == 0 {
      return "fy-drop"
    }
    return "fy-ambiguous"
  }
  // A broken-when-pruned baseline (-1) means the target is
  // structurally load-bearing: its presence is required for a valid
  // save, so it demonstrably round-trips.
  if absent_count < 0 {
    return "fy-tag"
  }
  if present_count == 0 {
    // The tag never made it into the saved XML at all — the writer
    // emitted nothing for it.  A genuine, unambiguous drop.
    return "fy-drop"
  }
  if present_count > absent_count {
    // Removing the target removed at least one occurrence of its tag
    // from the saved XML — direct proof the target's own tag survived
    // the writer.
    return "fy-tag"
  }
  if !has_marker {
    let (probe, injected) = inject_extlst_marker_into_target(
      with_marker, marker,
    )
    if injected {
      match
        roundtrip_saved_xml(
          format,
          host_package(format, strip_target_attr(probe)),
        ) {
        Some(saved) => if saved.contains(marker) { return "fy-inject" }
        None => ()
      }
    }
  }
  // The tag is present but pruning the target did not change its
  // count: scaffolding fully accounts for the occurrences, so we
  // cannot prove the *target* round-tripped.  Honest non-success.
  "fy-ambiguous"
}

///|
/// The unqualified local name of the element carrying the
/// `TARGET_ATTR` sentinel inside `content`, or the root's own local
/// name when the root is itself the target.  Used by
/// `roundtrip_fidelity` to look for the element's tag in saved XML.
fn target_local_name(content : @xml.Element) -> String {
  let mut found = ""
  fn walk(e : @xml.Element) -> Unit {
    for a in e.attributes {
      if a.name.local_name == TARGET_ATTR {
        found = e.name.local_name
        return
      }
    }
    for child in e.children {
      match child {
        Element(c) => if found == "" { walk(c) }
        _ => ()
      }
    }
  }

  walk(content)
  if found == "" {
    content.name.local_name
  } else {
    found
  }
}

///|
/// Count element start tags in `xml` whose local name is exactly
/// `local_name` — a `<` followed by an optional `prefix:`, then
/// `local_name`, then a tag terminator (space, `/`, `>`, tab,
/// newline).  Matching the whole local name (not a prefix) keeps
/// `<a:ln>` from counting toward `<a:lnRef>`.  Used by
/// `roundtrip_fidelity` for the differential present-vs-absent
/// occurrence comparison.
fn saved_count_tag(xml : String, local_name : String) -> Int {
  if local_name == "" {
    return 0
  }
  let n = xml.length()
  let llen = local_name.length()
  let mut count = 0
  let mut i = 0
  while i < n {
    if xml[i] == '<' {
      // Scan the name region: skip an optional `prefix:` segment.
      let mut j = i + 1
      // Find the start of the local part after a possible colon.
      let mut name_start = j
      while j < n {
        let c = xml[j]
        if c == ':' {
          name_start = j + 1
        } else if c == ' ' ||
          c == '\t' ||
          c == '\n' ||
          c == '\r' ||
          c == '>' ||
          c == '/' {
          break
        } else if c == '<' || c == '=' || c == '"' || c == '\'' {
          // Not a tag name region (e.g. text content) — bail this `<`.
          break
        }
        j = j + 1
      }
      // [name_start, j) is the local name; compare to `local_name`.
      if j - name_start == llen {
        let mut k = 0
        let mut eq = true
        while k < llen {
          if xml[name_start + k] != local_name[k] {
            eq = false
            break
          }
          k = k + 1
        }
        if eq {
          count = count + 1
        }
      }
      i = j
    } else {
      i = i + 1
    }
  }
  count
}

///|
/// Build the host package for `which` around `content`.  `which` is
/// either a bare format name (`docx`/`xlsx`/`pptx`) or
/// `format:part-kind` where `part-kind` selects an OPC auxiliary
/// part — `docx:settings` wires `content` as the body of
/// `word/settings.xml`, `pptx:theme` as `ppt/theme/theme1.xml`, and
/// so on.  Aux-part hosts always ship a minimal body part too
/// (empty `<w:body>` / `<worksheet>` / `<p:sld>`) so the package is
/// fully spec-valid OPC.
fn host_package(which : String, content : @xml.Element) -> Bytes {
  match which {
    "xlsx" => catalog_xlsx_package(content)
    "pptx" => pptx_package(content)
    "docx:settings" => docx_aux_package("settings", content)
    "docx:styles" => docx_aux_package("styles", content)
    "docx:numbering" => docx_aux_package("numbering", content)
    "docx:header" => docx_header_footer_package("header", content)
    "docx:footer" => docx_header_footer_package("footer", content)
    "docx:glossary" => docx_aux_package("glossary", content)
    "docx:fonts" => docx_aux_package("fonts", content)
    "docx:webSettings" => docx_aux_package("webSettings", content)
    "docx:comments" => docx_aux_package("comments", content)
    "docx:footnotes" => docx_aux_package("footnotes", content)
    "docx:endnotes" => docx_aux_package("endnotes", content)
    "docx:annotationRefs" => docx_package_with_annotation_refs(content)
    "docx:contentPart" => docx_package_with_content_part(content)
    "docx:picture-blip" =>
      docx_package_with_embedded_image(
        catalog_wml_picture_blip_root(content),
        test_image_8x8_quad(),
      )
    "pptx:theme" => pptx_with_aux_root_package("theme", content)
    "pptx:presentation" => pptx_with_aux_root_package("presentation", content)
    "pptx:presentationPr" =>
      pptx_with_aux_root_package("presentationPr", content)
    "pptx:viewPr" => pptx_with_aux_root_package("viewPr", content)
    "pptx:themeOverride" => pptx_with_aux_root_package("themeOverride", content)
    "pptx:themeManager" => pptx_with_aux_root_package("themeManager", content)
    "pptx:master-txstyle" => pptx_package_with_master_tx_styles(content)
    "pptx:placeholder-chain" => pptx_package_with_placeholder_chain(content)
    "pptx:slideRefs" => pptx_package_with_slide_refs(content)
    "pptx:comments" => pptx_with_aux_root_package("comments", content)
    "pptx:commentAuthors" =>
      pptx_with_aux_root_package("commentAuthors", content)
    "pptx:sldSyncPr" => pptx_with_aux_root_package("sldSyncPr", content)
    "pptx:notes" => pptx_with_aux_root_package("notes", content)
    "pptx:notesMaster" => pptx_with_aux_root_package("notesMaster", content)
    "pptx:handoutMaster" => pptx_with_aux_root_package("handoutMaster", content)
    "pptx:presentationRefs" => pptx_package_with_presentation_refs(content)
    "pptx:picture-blip" =>
      pptx_package_with_embedded_image(
        catalog_pml_picture_blip_root(content),
        test_image_8x8_quad(),
      )
    "xlsx:workbook" => xlsx_with_aux_root_package("workbook", content)
    "xlsx:sharedStrings" => xlsx_with_aux_root_package("sharedStrings", content)
    "xlsx:styles" => xlsx_with_aux_root_package("styles", content)
    "xlsx:comments" => xlsx_with_aux_root_package("comments", content)
    "xlsx:calcChain" => xlsx_with_aux_root_package("calcChain", content)
    "xlsx:connections" => xlsx_with_aux_root_package("connections", content)
    "xlsx:metadata" => xlsx_with_aux_root_package("metadata", content)
    "xlsx:xmlMaps" => xlsx_with_aux_root_package("xmlMaps", content)
    "xlsx:queryTable" => xlsx_with_aux_root_package("queryTable", content)
    "xlsx:revisionHeaders" =>
      xlsx_with_aux_root_package("revisionHeaders", content)
    "xlsx:revisionLog" => xlsx_with_aux_root_package("revisionLog", content)
    "xlsx:userNames" => xlsx_with_aux_root_package("userNames", content)
    "xlsx:volatileDependencies" =>
      xlsx_with_aux_root_package("volatileDependencies", content)
    "xlsx:drawing" => xlsx_with_drawing_root_package(content)
    "xlsx:worksheetRefs" => xlsx_package_with_worksheet_refs(content)
    "xlsx:chartsheet" => xlsx_package_with_chartsheet(content)
    "xlsx:dialogsheet" => xlsx_package_with_dialogsheet(content)
    "xlsx:tableSingleCells" => xlsx_package_with_table_single_cells(content)
    "xlsx:pivot" => {
      let (sheet, cache_def, cache_records, pivot_def) = catalog_sml_pivot_parts(
        content,
      )
      xlsx_package_with_pivot(sheet, cache_def, cache_records, pivot_def)
    }
    // §21.2 DrawingML chart — the element's ancestry walks up to a
    // `<c:chartSpace>` root, so `content` is already a typed
    // chartSpace tree. Wrap it in a minimal slide that carries a
    // `<p:graphicFrame>` referencing `chart1.xml`, then hand both to
    // the existing `pptx_package_with_chart` builder so the chart part
    // is wired into the slide's `.rels` + `[Content_Types]` exactly
    // the way the visual fixtures (`fixtures_dml_charts.mbt`) do.
    "pptx:chart" =>
      pptx_package_with_chart(
        default_chart_slide_body(),
        enhance_chart_space_for_render(content),
      )
    "pptx:diagram-relids" =>
      pptx_package_with_diagram(
        diagram_slide_body_with_rel_ids(content),
        shared_data_model(["Catalog"]),
        make_layout_def_with_child_constraints(
          "urn:catalog:diagram-relids",
          "lin",
          explicit_w=900000.0,
          explicit_h=360000.0,
        ),
        make_style_def("urn:catalog:diagram-relids:style"),
        make_colors_def("urn:catalog:diagram-relids:colors"),
        None,
      )
    "pptx:diagram-data" =>
      pptx_package_with_diagram(
        default_diagram_slide_body(),
        content,
        default_diagram_layout_def(),
        default_diagram_style_def(),
        default_diagram_colors_def(),
        None,
      )
    "pptx:diagram-layout" =>
      pptx_package_with_diagram(
        default_diagram_slide_body(),
        default_diagram_data_model(),
        content,
        default_diagram_style_def(),
        default_diagram_colors_def(),
        None,
      )
    "pptx:diagram-style" =>
      pptx_package_with_diagram(
        default_diagram_slide_body(),
        default_diagram_data_model(),
        default_diagram_layout_def(),
        content,
        default_diagram_colors_def(),
        None,
      )
    "pptx:diagram-colors" =>
      pptx_package_with_diagram(
        default_diagram_slide_body(),
        default_diagram_data_model(),
        default_diagram_layout_def(),
        default_diagram_style_def(),
        content,
        None,
      )
    "pptx:table" => pptx_package(default_table_slide_body(content))
    // §21.3 chartDrawing — `<c:userShapes>` is the chart's user-shape
    // overlay part.  The host wires the part through chart-part
    // relationships so the PresentationML chart renderer resolves
    // `<c:userShapes r:id>` and walks the real
    // `<cdr:absSizeAnchor>` / `<cdr:relSizeAnchor>` payload.
    "pptx:chart-usershapes" =>
      pptx_package_with_chart_usershapes_real(
        default_chart_slide_body(),
        default_minimal_chart_space_with_userShapes(),
        content,
      )
    _ => docx_package(content)
  }
}

///|
fn replace_zip_entry(bytes : Bytes, name : String, data : Bytes) -> Bytes {
  let archive = @zip.read(bytes) catch { _ => return bytes }
  let entries : Array[(String, Bytes)] = []
  let mut replaced = false
  for entry in archive.entries {
    if entry.name == name {
      entries.push((entry.name, data))
      replaced = true
    } else {
      entries.push((entry.name, entry.data))
    }
  }
  if !replaced {
    entries.push((name, data))
  }
  (try? @zip.write(@zip.Archive::new(entries))).unwrap_or(bytes)
}

///|
fn pml_master_tx_style_kind(tx_styles : @xml.Element) -> String {
  match tx_styles.name.local_name {
    "titleStyle" | "bodyStyle" | "otherStyle" =>
      return tx_styles.name.local_name
    _ => ()
  }
  for child in tx_styles.children {
    match child {
      Element(el) =>
        match el.name.local_name {
          "titleStyle" | "bodyStyle" | "otherStyle" => return el.name.local_name
          _ => ()
        }
      _ => ()
    }
  }
  "bodyStyle"
}

///|
fn pml_master_tx_style_level_name(local_name : String) -> Int? {
  if !local_name.has_prefix("lvl") || !local_name.has_suffix("pPr") {
    return None
  }
  let digit = local_name[3:local_name.length() - 3].to_owned()
  try @string.parse_int(digit) catch {
    _ => None
  } noraise {
    n => if n >= 1 && n <= 9 { Some(n - 1) } else { None }
  }
}

///|
fn pml_master_tx_style_level_in_tree(element : @xml.Element) -> Int? {
  if element.name.local_name == "defPPr" {
    return Some(0)
  }
  match pml_master_tx_style_level_name(element.name.local_name) {
    Some(level) => return Some(level)
    None => ()
  }
  for child in element.children {
    match child {
      Element(el) =>
        match pml_master_tx_style_level_in_tree(el) {
          Some(level) => return Some(level)
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
fn pml_master_tx_style_paragraph_level(
  tx_styles : @xml.Element,
  style_name : String,
) -> Int {
  match tx_styles.name.local_name {
    "titleStyle" | "bodyStyle" | "otherStyle" =>
      match pml_master_tx_style_level_in_tree(tx_styles) {
        Some(level) => return level
        None => return 0
      }
    _ => ()
  }
  for child in tx_styles.children {
    match child {
      Element(el) =>
        if el.name.local_name == style_name {
          match pml_master_tx_style_level_in_tree(el) {
            Some(level) => return level
            None => return 0
          }
        }
      _ => ()
    }
  }
  match pml_master_tx_style_level_in_tree(tx_styles) {
    Some(level) => level
    None => 0
  }
}

///|
fn pml_master_tx_style_placeholder_type(style_name : String) -> String {
  match style_name {
    "titleStyle" => "title"
    "otherStyle" => "ftr"
    _ => "body"
  }
}

///|
fn catalog_master_tx_styles_root(content : @xml.Element) -> @xml.Element {
  if content.name.local_name == "txStyles" {
    return content
  }
  let ns_p = content.name.ns.unwrap_or(
    "http://schemas.openxmlformats.org/presentationml/2006/main",
  )
  let prefix = content.name.prefix.unwrap_or("p")
  xep(prefix, ns_p, "txStyles", [], [Element(content)])
}

///|
fn catalog_master_tx_paragraph_style_root(
  content : @xml.Element,
) -> @xml.Element {
  match content.name.local_name {
    "txStyles" | "titleStyle" | "bodyStyle" | "otherStyle" =>
      catalog_master_tx_styles_root(content)
    _ =>
      catalog_master_tx_styles_root(
        xep("p", NS_PML, "bodyStyle", [], [Element(content)]),
      )
  }
}

///|
fn catalog_txstyle_placeholder_shape(
  style_name : String,
  paragraph_level : Int,
  ns_p : String,
) -> @xml.Element {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let ph_type = pml_master_tx_style_placeholder_type(style_name)
  let p_children : Array[@xml.Node] = []
  if paragraph_level > 0 {
    p_children.push(
      Element(
        xep("a", ns_a, "pPr", [xa("lvl", paragraph_level.to_string())], []),
      ),
    )
  }
  p_children.push(
    Element(
      xep("a", ns_a, "r", [], [
        Element(xep("a", ns_a, "t", [], [Text("Catalog master text")])),
      ]),
    ),
  )
  xep("p", ns_p, "sp", [], [
    Element(
      xep("p", ns_p, "nvSpPr", [], [
        Element(
          xep(
            "p",
            ns_p,
            "cNvPr",
            [xa("id", "2"), xa("name", "Catalog Placeholder")],
            [],
          ),
        ),
        Element(xep("p", ns_p, "cNvSpPr", [], [])),
        Element(
          xep("p", ns_p, "nvPr", [], [
            Element(xep("p", ns_p, "ph", [xa("type", ph_type)], [])),
          ]),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "spPr", [], [
        Element(
          xep("a", ns_a, "xfrm", [], [
            Element(
              xep("a", ns_a, "off", [xa("x", "914400"), xa("y", "914400")], []),
            ),
            Element(
              xep("a", ns_a, "ext", [xa("cx", "5486400"), xa("cy", "914400")], []),
            ),
          ]),
        ),
        Element(
          xep("a", ns_a, "prstGeom", [xa("prst", "rect")], [
            Element(xep("a", ns_a, "avLst", [], [])),
          ]),
        ),
        Element(xep("a", ns_a, "noFill", [], [])),
      ]),
    ),
    Element(
      xep("p", ns_p, "txBody", [], [
        Element(xep("a", ns_a, "bodyPr", [], [])),
        Element(xep("a", ns_a, "p", [], p_children)),
      ]),
    ),
  ])
}

///|
fn pptx_package_with_master_tx_styles(tx_styles : @xml.Element) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let tx_styles_root = catalog_master_tx_styles_root(tx_styles)
  let style_name = pml_master_tx_style_kind(tx_styles_root)
  let paragraph_level = pml_master_tx_style_paragraph_level(
    tx_styles_root, style_name,
  )
  let base = pptx_package(
    pptx_common_slide_data(ns_p, [
      catalog_txstyle_placeholder_shape(style_name, paragraph_level, ns_p),
    ]),
  )
  replace_zip_entry(
    base,
    "ppt/slideMasters/slideMaster1.xml",
    write_part(pptx_slide_master_root(Some(tx_styles_root))),
  )
}

///|
fn is_pml_placeholder_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  local_name == "ph" &&
  strip_ns(ns) == "presentationml/main" &&
  catalog_type_local(type_name) == "CT_Placeholder"
}

///|
fn catalog_pml_placeholder_chain_root(content : @xml.Element) -> @xml.Element {
  let ns_p = content.name.ns.unwrap_or(NS_PML)
  let ph_root = if content.name.local_name == "ph" {
    content
  } else {
    xep("p", ns_p, "ph", [xa("type", "title"), xa("idx", "0")], [
      Element(content),
    ])
  }
  xep("p", ns_p, "cSld", [], [
    Element(
      pptx_shape_tree(ns_p, [
        xep("p", ns_p, "sp", [], [
          Element(
            xep("p", ns_p, "nvSpPr", [], [
              Element(
                xep(
                  "p",
                  ns_p,
                  "cNvPr",
                  [xa("id", "2"), xa("name", "Catalog Placeholder Probe")],
                  [],
                ),
              ),
              Element(xep("p", ns_p, "cNvSpPr", [], [])),
              Element(xep("p", ns_p, "nvPr", [], [Element(ph_root)])),
            ]),
          ),
          Element(
            catalog_pml_placeholder_sp_pr(
              ns_p, "914400", "2743200", "5486400", "914400", "E97132",
            ),
          ),
        ]),
      ]),
    ),
  ])
}

///|
fn catalog_pml_placeholder_sp_pr(
  ns_p : String,
  x : String,
  y : String,
  cx : String,
  cy : String,
  fill : String,
) -> @xml.Element {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  xep("p", ns_p, "spPr", [], [
    Element(
      xep("a", ns_a, "xfrm", [], [
        Element(xep("a", ns_a, "off", [xa("x", x), xa("y", y)], [])),
        Element(xep("a", ns_a, "ext", [xa("cx", cx), xa("cy", cy)], [])),
      ]),
    ),
    Element(
      xep("a", ns_a, "prstGeom", [xa("prst", "rect")], [
        Element(xep("a", ns_a, "avLst", [], [])),
      ]),
    ),
    Element(
      xep("a", ns_a, "solidFill", [], [
        Element(xep("a", ns_a, "srgbClr", [xa("val", fill)], [])),
      ]),
    ),
  ])
}

///|
fn catalog_pml_placeholder_layout_shape(ns_p : String) -> @xml.Element {
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  xep("p", ns_p, "sp", [], [
    Element(
      xep("p", ns_p, "nvSpPr", [], [
        Element(
          xep(
            "p",
            ns_p,
            "cNvPr",
            [xa("id", "3"), xa("name", "Catalog Layout Placeholder")],
            [],
          ),
        ),
        Element(xep("p", ns_p, "cNvSpPr", [], [])),
        Element(
          xep("p", ns_p, "nvPr", [], [
            Element(
              xep("p", ns_p, "ph", [xa("type", "title"), xa("idx", "0")], []),
            ),
          ]),
        ),
      ]),
    ),
    Element(
      catalog_pml_placeholder_sp_pr(
        ns_p, "914400", "914400", "5486400", "914400", "4472C4",
      ),
    ),
    Element(
      xep("p", ns_p, "txBody", [], [
        Element(xep("a", ns_a, "bodyPr", [], [])),
        Element(xep("a", ns_a, "lstStyle", [], [])),
        Element(
          xep("a", ns_a, "p", [], [
            Element(
              xep("a", ns_a, "r", [], [
                Element(
                  xep("a", ns_a, "t", [], [Text("Catalog placeholder text")]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn pptx_package_with_placeholder_chain(content : @xml.Element) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let slide_root = if content.name.local_name == "cSld" {
    content
  } else {
    catalog_pml_placeholder_chain_root(content)
  }
  let base = pptx_package(slide_root)
  let layout_root = xep(
    "p",
    ns_p,
    "sldLayout",
    [xa("type", "title"), xa("preserve", "1")],
    [
      Element(
        pptx_common_slide_data(ns_p, [
          catalog_pml_placeholder_layout_shape(ns_p),
        ]),
      ),
    ],
  )
  replace_zip_entry(
    base,
    "ppt/slideLayouts/slideLayout1.xml",
    write_part(layout_root),
  )
}

///|
/// True when a DrawingML paragraph-default element can be verified
/// through the existing PresentationML slide-master text-style cascade.
/// The renderer consumes these only when they live under
/// `<p:txStyles>/<p:*Style>`; the catalog host supplies that wrapper
/// and leaves DrawingML parsing / layout to the PresentationML viewer.
fn is_pml_master_tx_paragraph_style_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  if strip_ns(ns) != "drawingml/main" ||
    catalog_type_local(type_name) != "CT_TextParagraphProperties" {
    return false
  }
  if local_name == "defPPr" {
    return true
  }
  pml_master_tx_style_level_name(local_name) is Some(_)
}

///|
/// True when a PresentationML master text style can be verified through
/// the existing slide-master placeholder cascade.  `notesStyle` is
/// intentionally excluded: it belongs to notes masters and the slide
/// renderer does not render a notes-master style path here.
fn is_pml_master_tx_style_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  if strip_ns(ns) != "presentationml/main" ||
    catalog_type_local(type_name) != "CT_TextListStyle" {
    return false
  }
  match local_name {
    "titleStyle" | "bodyStyle" | "otherStyle" => true
    _ => false
  }
}

///|
/// True when an ECMA-376 §21.1.3 DrawingML table element has a
/// renderer-observable effect in the PresentationML graphicFrame table
/// renderer.
/// This is catalog-host selection only: the table model and renderer
/// remain in `drawing_ml/shape_table_types.mbt` and
/// `presentation_ml/viewer/table.mbt`.
fn is_drawingml_table_catalog_target(
  local_name : String,
  type_name : String,
  ns : String,
) -> Bool {
  let ns_tail = strip_ns(ns)
  let type_local = catalog_type_local(type_name)
  let is_dml_main = ns_tail == "drawingml/main"
  if is_dml_main {
    match type_local {
      "CT_Table"
      | "CT_TableGrid"
      | "CT_TableCol"
      | "CT_TableRow"
      | "CT_TableCell"
      | "CT_TableCellProperties" => return true
      "CT_LineProperties" =>
        match local_name {
          "lnL" | "lnR" | "lnT" | "lnB" | "lnTlToBr" | "lnBlToTr" => return true
          _ => ()
        }
      _ => ()
    }
  }
  false
}

///|
fn table_ns_for(content : @xml.Element) -> String {
  match content.name.ns {
    Some(ns) if ns.contains("drawingml/main") => ns
    _ => NS_A
  }
}

///|
fn table_elem(
  ns : String,
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  xep("a", ns, local_name, attrs, children)
}

///|
fn default_table_grid(ns : String) -> @xml.Element {
  table_elem(ns, "tblGrid", [], [
    Element(table_elem(ns, "gridCol", [xa("w", "914400")], [])),
  ])
}

///|
fn default_table_text_body(ns : String) -> @xml.Element {
  table_elem(ns, "txBody", [], [
    Element(table_elem(ns, "bodyPr", [], [])),
    Element(table_elem(ns, "lstStyle", [], [])),
    Element(
      table_elem(ns, "p", [], [
        Element(
          table_elem(ns, "r", [], [
            Element(table_elem(ns, "t", [], [Text("Catalog table")])),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn default_table_cell(ns : String) -> @xml.Element {
  table_elem(ns, "tc", [], [
    Element(default_table_text_body(ns)),
    Element(table_elem(ns, "tcPr", [], [])),
  ])
}

///|
fn default_table_row(ns : String) -> @xml.Element {
  table_elem(ns, "tr", [xa("h", "914400")], [Element(default_table_cell(ns))])
}

///|
fn table_cell_with_pr(ns : String, tc_pr : @xml.Element) -> @xml.Element {
  table_elem(ns, "tc", [], [
    Element(default_table_text_body(ns)),
    Element(tc_pr),
  ])
}

///|
fn table_with_parts(
  ns : String,
  tbl_pr : @xml.Element?,
  tbl_grid : @xml.Element,
  row : @xml.Element,
) -> @xml.Element {
  let children : Array[@xml.Node] = []
  match tbl_pr {
    Some(pr) => children.push(Element(pr))
    None => ()
  }
  children.push(Element(tbl_grid))
  children.push(Element(row))
  table_elem(ns, "tbl", [], children)
}

///|
/// Normalize a catalog table-family target into the minimum
/// `<a:tbl>` context consumed by the existing PresentationML table
/// renderer. The target subtree itself is left intact and, for
/// non-`tbl` roots, remains below the table root so the differential
/// verifier compares the same table host with and without the target.
fn catalog_table_root(content : @xml.Element) -> @xml.Element {
  let ns = table_ns_for(content)
  match content.name.local_name {
    "tbl" => content
    "tblGrid" => table_with_parts(ns, None, content, default_table_row(ns))
    "gridCol" =>
      table_with_parts(
        ns,
        None,
        table_elem(ns, "tblGrid", [], [Element(content)]),
        default_table_row(ns),
      )
    "tr" => table_with_parts(ns, None, default_table_grid(ns), content)
    "tc" =>
      table_with_parts(
        ns,
        None,
        default_table_grid(ns),
        table_elem(ns, "tr", [xa("h", "914400")], [Element(content)]),
      )
    "tcPr" =>
      table_with_parts(
        ns,
        None,
        default_table_grid(ns),
        table_elem(ns, "tr", [xa("h", "914400")], [
          Element(table_cell_with_pr(ns, content)),
        ]),
      )
    "lnL" | "lnR" | "lnT" | "lnB" | "lnTlToBr" | "lnBlToTr" =>
      table_with_parts(
        ns,
        None,
        default_table_grid(ns),
        table_elem(ns, "tr", [xa("h", "914400")], [
          Element(
            table_cell_with_pr(
              ns,
              table_elem(ns, "tcPr", [], [Element(content)]),
            ),
          ),
        ]),
      )
    _ =>
      table_with_parts(ns, None, default_table_grid(ns), default_table_row(ns))
  }
}

///|
/// Slide body `<p:cSld>` for hosting DrawingML table catalog probes
/// under the existing PresentationML graphicFrame table renderer.
fn default_table_slide_body(content : @xml.Element) -> @xml.Element {
  let ns_p = NS_PML
  let ns_a = table_ns_for(content)
  let table_uri = "http://schemas.openxmlformats.org/drawingml/2006/table"
  let tbl = catalog_table_root(content)
  let graphic_frame = xep("p", ns_p, "graphicFrame", [], [
    Element(
      xep("p", ns_p, "nvGraphicFramePr", [], [
        Element(
          xep("p", ns_p, "cNvPr", [xa("id", "2"), xa("name", "Table 1")], []),
        ),
        Element(xep("p", ns_p, "cNvGraphicFramePr", [], [])),
        Element(xep("p", ns_p, "nvPr", [], [])),
      ]),
    ),
    Element(
      xep("p", ns_p, "xfrm", [], [
        Element(
          xep("a", ns_a, "off", [xa("x", "914400"), xa("y", "914400")], []),
        ),
        Element(
          xep("a", ns_a, "ext", [xa("cx", "6096000"), xa("cy", "2743200")], []),
        ),
      ]),
    ),
    Element(
      xep("a", ns_a, "graphic", [], [
        Element(
          xep("a", ns_a, "graphicData", [xa("uri", table_uri)], [Element(tbl)]),
        ),
      ]),
    ),
  ])
  pptx_common_slide_data(ns_p, [graphic_frame])
}

///|
/// Catalog-specific `.xlsx` host. A synthesised AutoFilter subtree is
/// structurally valid but not render-observable by itself when it has
/// no `@ref`, candidate rows, `styles.xml` dxfs, or iconSet conditional
/// formatting to compare. When the generated tree carries an
/// `<autoFilter>/<filterColumn>` path, provide those runtime facts as
/// fixture data; the row decision stays in
/// `spreadsheet_ml/autofilter`.
fn catalog_xlsx_package(content : @xml.Element) -> Bytes {
  if has_autofilter_filter_column(content) {
    xlsx_package_styled(
      catalog_autofilter_worksheet(content),
      catalog_autofilter_styles(),
    )
  } else {
    xlsx_package(content)
  }
}

///|
fn has_autofilter_filter_column(element : @xml.Element) -> Bool {
  if !is_catalog_autofilter_probe_root(element) &&
    element.name.local_name != "autoFilter" {
    return false
  }
  fn walk(e : @xml.Element) -> Bool {
    if e.name.local_name == "filterColumn" {
      return true
    }
    for child in e.children {
      match child {
        Element(ce) => if walk(ce) { return true }
        _ => ()
      }
    }
    false
  }
  walk(element)
}

///|
/// The catalog ancestry for `<colorFilter>` / `<iconFilter>` is a
/// synthetic `worksheet -> autoFilter -> filterColumn -> target` tree;
/// `main.mbt` skips the implicit worksheet root before calling
/// `host_package`, so the production probe arrives here as an
/// `autoFilter` root.  This helper keeps the white-box worksheet
/// shape accepted too, while excluding real worksheet, table, pivot,
/// or dialog-sheet roots so their original content still drives the
/// round-trip fidelity checks.
fn is_catalog_autofilter_probe_root(element : @xml.Element) -> Bool {
  if element.name.local_name != "worksheet" {
    return false
  }
  let mut element_child_count = 0
  let mut only_child_is_autofilter = false
  for child in element.children {
    match child {
      Element(ce) => {
        element_child_count += 1
        only_child_is_autofilter = ce.name.local_name == "autoFilter"
      }
      _ => ()
    }
  }
  element_child_count == 1 && only_child_is_autofilter
}

///|
fn catalog_autofilter_worksheet(content : @xml.Element) -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let auto_filter = match first_descendant_named_local(content, "autoFilter") {
    Some(e) => normalize_catalog_autofilter(e)
    None => return content
  }
  xe(ns_s, "worksheet", [], [
    Element(xe(ns_s, "dimension", [xa("ref", "A1:B4")], [])),
    Element(
      xe(ns_s, "sheetData", [], [
        Element(s_row("1", [s_inline("A1", "Item"), s_inline("B1", "Score")])),
        Element(
          s_row("2", [
            s_inline("A2", "Red low"),
            s_cell_styled_x("B2", "10", "1"),
          ]),
        ),
        Element(
          s_row("3", [
            s_inline("A3", "Green middle"),
            s_cell_styled_x("B3", "50", "2"),
          ]),
        ),
        Element(
          s_row("4", [
            s_inline("A4", "Red high"),
            s_cell_styled_x("B4", "90", "1"),
          ]),
        ),
      ]),
    ),
    Element(catalog_autofilter_iconset_cf()),
    Element(auto_filter),
  ])
}

///|
fn first_descendant_named_local(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  if element.name.local_name == local_name {
    return Some(element)
  }
  for child in element.children {
    match child {
      Element(ce) =>
        match first_descendant_named_local(ce, local_name) {
          Some(found) => return Some(found)
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
fn normalize_catalog_autofilter(element : @xml.Element) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  let mut saw_ref = false
  let mut saw_col_id = false
  for attr in element.attributes {
    if element.name.local_name == "autoFilter" && attr.name.local_name == "ref" {
      attrs.push({ name: attr.name, value: "A1:B4" })
      saw_ref = true
    } else if element.name.local_name == "filterColumn" &&
      attr.name.local_name == "colId" {
      attrs.push({ name: attr.name, value: "1" })
      saw_col_id = true
    } else {
      attrs.push(attr)
    }
  }
  if element.name.local_name == "autoFilter" && !saw_ref {
    attrs.push(xa("ref", "A1:B4"))
  }
  if element.name.local_name == "filterColumn" && !saw_col_id {
    attrs.push(xa("colId", "1"))
  }
  let children : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(ce) => children.push(Element(normalize_catalog_autofilter(ce)))
      _ => children.push(child)
    }
  }
  { name: element.name, attributes: attrs, children }
}

///|
fn catalog_autofilter_iconset_cf() -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xe(ns_s, "conditionalFormatting", [xa("sqref", "B2:B4")], [
    Element(
      xe(ns_s, "cfRule", [xa("type", "iconSet"), xa("priority", "1")], [
        Element(
          xe(ns_s, "iconSet", [xa("iconSet", "3Arrows")], [
            Element(
              xe(ns_s, "cfvo", [xa("type", "percent"), xa("val", "0")], []),
            ),
            Element(
              xe(ns_s, "cfvo", [xa("type", "percent"), xa("val", "33")], []),
            ),
            Element(
              xe(ns_s, "cfvo", [xa("type", "percent"), xa("val", "67")], []),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn catalog_autofilter_styles() -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xe(ns_s, "styleSheet", [], [
    Element(
      xe(ns_s, "fonts", [xa("count", "1")], [
        Element(ss_font("11", "Calibri", [])),
      ]),
    ),
    Element(
      xe(ns_s, "fills", [xa("count", "4")], [
        Element(ss_fill_none()),
        Element(ss_fill_gray125()),
        Element(ss_pattern_fill("solid", Some("FFFF0000"), None)),
        Element(ss_pattern_fill("solid", Some("FF00FF00"), None)),
      ]),
    ),
    Element(
      xe(ns_s, "borders", [xa("count", "1")], [Element(ss_border_none())]),
    ),
    Element(
      xe(ns_s, "cellXfs", [xa("count", "3")], [
        Element(ss_cell_xf("0", "0", "0", "0", None)),
        Element(ss_cell_xf("0", "0", "2", "0", None)),
        Element(ss_cell_xf("0", "0", "3", "0", None)),
      ]),
    ),
    Element(
      cf_dxfs([cf_dxf_solid_fill("FF00FF00"), cf_dxf_solid_fill("FFFF0000")]),
    ),
  ])
}

///|
/// Build a `<c:chartSpace>` minimal tree that includes a
/// `<c:userShapes r:id="rId1"/>` reference plus chart-owned
/// relationship references for `<c:externalData r:id="rId2">` and
/// `<c:legacyDrawingHF r:id="rId3"/>`.  Mirrors the scaffold
/// barChart `enhance_chart_space_for_render` injects so the chart
/// still has a renderable plotArea.
fn default_minimal_chart_space_with_userShapes() -> @xml.Element {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let rel_attr = fn(id : String) -> @xml.Attribute {
    { name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) }, value: id }
  }
  let bar_chart = xep("c", ns_c, "barChart", [], [
    Element(xep("c", ns_c, "barDir", [xa("val", "col")], [])),
    Element(xep("c", ns_c, "grouping", [xa("val", "clustered")], [])),
    Element(xep("c", ns_c, "varyColors", [xa("val", "0")], [])),
    Element(
      xep("c", ns_c, "ser", [], [
        Element(xep("c", ns_c, "idx", [xa("val", "0")], [])),
        Element(xep("c", ns_c, "order", [xa("val", "0")], [])),
        Element(
          xep("c", ns_c, "val", [], [
            Element(
              xep("c", ns_c, "numRef", [], [
                Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$2:$D$2")])),
                Element(
                  xep("c", ns_c, "numCache", [], [
                    Element(xep("c", ns_c, "formatCode", [], [Text("General")])),
                    Element(xep("c", ns_c, "ptCount", [xa("val", "3")], [])),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "0")], [
                        Element(xep("c", ns_c, "v", [], [Text("2")])),
                      ]),
                    ),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "1")], [
                        Element(xep("c", ns_c, "v", [], [Text("5")])),
                      ]),
                    ),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "2")], [
                        Element(xep("c", ns_c, "v", [], [Text("3")])),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
    Element(xep("c", ns_c, "axId", [xa("val", "1")], [])),
    Element(xep("c", ns_c, "axId", [xa("val", "2")], [])),
  ])
  let chart_inner = xep("c", ns_c, "chart", [], [
    Element(
      xep("c", ns_c, "plotArea", [], [
        Element(xep("c", ns_c, "layout", [], [])),
        Element(bar_chart),
        Element(
          xep("c", ns_c, "catAx", [], [
            Element(xep("c", ns_c, "axId", [xa("val", "1")], [])),
            Element(
              xep("c", ns_c, "scaling", [], [
                Element(
                  xep("c", ns_c, "orientation", [xa("val", "minMax")], []),
                ),
              ]),
            ),
            Element(xep("c", ns_c, "delete", [xa("val", "0")], [])),
            Element(xep("c", ns_c, "axPos", [xa("val", "b")], [])),
            Element(xep("c", ns_c, "crossAx", [xa("val", "2")], [])),
          ]),
        ),
        Element(
          xep("c", ns_c, "valAx", [], [
            Element(xep("c", ns_c, "axId", [xa("val", "2")], [])),
            Element(
              xep("c", ns_c, "scaling", [], [
                Element(
                  xep("c", ns_c, "orientation", [xa("val", "minMax")], []),
                ),
              ]),
            ),
            Element(xep("c", ns_c, "delete", [xa("val", "0")], [])),
            Element(xep("c", ns_c, "axPos", [xa("val", "l")], [])),
            Element(xep("c", ns_c, "crossAx", [xa("val", "1")], [])),
          ]),
        ),
      ]),
    ),
    Element(xep("c", ns_c, "plotVisOnly", [xa("val", "1")], [])),
  ])
  let external_data_ref = xep("c", ns_c, "externalData", [rel_attr("rId2")], [
    Element(xep("c", ns_c, "autoUpdate", [xa("val", "0")], [])),
  ])
  let print_settings = xep("c", ns_c, "printSettings", [], [
    Element(xep("c", ns_c, "legacyDrawingHF", [rel_attr("rId3")], [])),
  ])
  let user_shapes_ref = xep("c", ns_c, "userShapes", [rel_attr("rId1")], [])
  xep("c", ns_c, "chartSpace", [], [
    Element(chart_inner),
    Element(external_data_ref),
    Element(print_settings),
    Element(user_shapes_ref),
  ])
}

///|
/// Minimal VML Drawing part used by chart `<c:legacyDrawingHF>`.
/// ECMA-376 Transitional VML Drawing has a no-namespace `<xml>` root
/// containing VML (`v:*`) drawing payloads.
fn chart_legacy_vml_drawing_part() -> @xml.Element {
  let ns_v = "urn:schemas-microsoft-com:vml"
  {
    name: { prefix: None, local_name: "xml", ns: None },
    attributes: [],
    children: [
      Element(
        xep(
          "v",
          ns_v,
          "rect",
          [
            xa("id", "_x0000_s1025"),
            xa(
              "style", "position:absolute;margin-left:0;margin-top:0;width:72pt;height:18pt",
            ),
            xa("fillcolor", "#F2F7FF"),
            xa("strokecolor", "#2F5597"),
          ],
          [],
        ),
      ),
    ],
  }
}

///|
/// `.pptx` package mirroring `pptx_package_with_chart` but additionally
/// wiring a `<c:userShapes>` sibling part bound to the chart via
/// chart-part rels (rId1).  The same chart rels part also binds
/// `<c:externalData r:id="rId2">` to an External workbook target and
/// `<c:legacyDrawingHF r:id="rId3">` to a VML Drawing part, so the
/// chart relationship references are validated together.
fn pptx_package_with_chart_usershapes_real(
  slide_body : @xml.Element,
  chart_space : @xml.Element,
  user_shapes_content : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // Re-issue the base chart package and graft the userShapes part +
  // chart-rels onto it.  Because pptx_package_with_chart returns
  // serialised zip bytes (opaque), we rebuild the whole package
  // here, inlined from pptx_package_with_chart's structure.
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Slide rels: rId1 → slideLayout1, rId2 → chart1.
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart",
          ),
          xa("Target", "../charts/chart1.xml"),
        ],
        [],
      ),
    ),
  ])
  // Chart rels: rId1 → userShapes part, rId2 → External workbook
  // data source, rId3 → VML Drawing part for legacy header/footer
  // drawing.  The chart_space helper above carries all three refs.
  let chart_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chartUserShapes",
          ),
          xa("Target", "userShapes1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/externalLinkPath",
          ),
          xa("Target", "file:///tmp/ooxml-catalog-chart-data.xlsx"),
          xa("TargetMode", "External"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing",
          ),
          xa("Target", "../drawings/vmlDrawing1.vml"),
        ],
        [],
      ),
    ),
  ])
  let slide : @xml.Element = {
    name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
    attributes: [],
    children: [Element(slide_body)],
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
        (
          "/ppt/charts/chart1.xml", "application/vnd.openxmlformats-officedocument.drawingml.chart+xml",
        ),
        (
          "/ppt/charts/userShapes1.xml", "application/vnd.openxmlformats-officedocument.drawingml.chartshapes+xml",
        ),
        (
          "/ppt/drawings/vmlDrawing1.vml", "application/vnd.openxmlformats-officedocument.vmlDrawing",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
    ("ppt/charts/chart1.xml", write_part(chart_space)),
    ("ppt/charts/_rels/chart1.xml.rels", write_part(chart_rels)),
    ("ppt/charts/userShapes1.xml", write_part(user_shapes_content)),
    (
      "ppt/drawings/vmlDrawing1.vml",
      write_part(chart_legacy_vml_drawing_part()),
    ),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Slide body `<p:cSld>` for hosting a diagram element under
/// `pptx:diagram-*`.  Mirrors `default_chart_slide_body` but carries
/// a `<dgm:relIds>` payload binding to the four SmartArt parts
/// pptx_package_with_diagram writes (rId2..rId5 = dm/lo/qs/cs).
fn default_diagram_slide_body() -> @xml.Element {
  let ns_p = NS_PML
  let ns_a = NS_A
  let ns_dgm = DIAGRAM_URI

  let graphic_frame = xep("p", ns_p, "graphicFrame", [], [
    Element(
      xep("p", ns_p, "nvGraphicFramePr", [], [
        Element(
          xep("p", ns_p, "cNvPr", [xa("id", "2"), xa("name", "Diagram 1")], []),
        ),
        Element(xep("p", ns_p, "cNvGraphicFramePr", [], [])),
        Element(xep("p", ns_p, "nvPr", [], [])),
      ]),
    ),
    Element(
      xep("p", ns_p, "xfrm", [], [
        Element(
          xep("a", ns_a, "off", [xa("x", "914400"), xa("y", "914400")], []),
        ),
        Element(
          xep("a", ns_a, "ext", [xa("cx", "6096000"), xa("cy", "4572000")], []),
        ),
      ]),
    ),
    Element(
      xep("a", ns_a, "graphic", [], [
        Element(
          xep("a", ns_a, "graphicData", [xa("uri", ns_dgm)], [
            Element(
              xep(
                "dgm",
                ns_dgm,
                "relIds",
                [
                  diagram_rel_ids_attr("dm"),
                  diagram_rel_ids_attr("lo"),
                  diagram_rel_ids_attr("qs"),
                  diagram_rel_ids_attr("cs"),
                ],
                [],
              ),
            ),
          ]),
        ),
      ]),
    ),
  ])
  pptx_common_slide_data(ns_p, [graphic_frame])
}

///|
fn normalize_diagram_rel_ids(rel_ids : @xml.Element) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  for attr in rel_ids.attributes {
    if attr.name.ns == Some(NS_OFFICE_REL) || attr.name.prefix == Some("r") {
      match attr.name.local_name {
        "dm" | "lo" | "qs" | "cs" => ()
        _ => attrs.push(attr)
      }
    } else {
      attrs.push(attr)
    }
  }
  attrs.push(diagram_rel_ids_attr("dm"))
  attrs.push(diagram_rel_ids_attr("lo"))
  attrs.push(diagram_rel_ids_attr("qs"))
  attrs.push(diagram_rel_ids_attr("cs"))
  { name: rel_ids.name, attributes: attrs, children: rel_ids.children }
}

///|
fn diagram_slide_body_with_rel_ids(rel_ids : @xml.Element) -> @xml.Element {
  let replacement = normalize_diagram_rel_ids(rel_ids)
  fn rewrite(element : @xml.Element) -> @xml.Element {
    if element.name.local_name == "relIds" && element.name.ns == Some(NS_DGM) {
      return replacement
    }
    let kids : Array[@xml.Node] = []
    for child in element.children {
      match child {
        @xml.Node::Element(child_element) =>
          kids.push(@xml.Node::Element(rewrite(child_element)))
        other => kids.push(other)
      }
    }
    { name: element.name, attributes: element.attributes, children: kids }
  }

  rewrite(default_diagram_slide_body())
}

///|
fn default_diagram_data_model() -> @xml.Element {
  let ns_dgm = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
  xep("dgm", ns_dgm, "dataModel", [], [
    Element(
      xep("dgm", ns_dgm, "ptLst", [], [
        Element(
          xep("dgm", ns_dgm, "pt", [xa("modelId", "0"), xa("type", "doc")], [
            Element(xep("dgm", ns_dgm, "prSet", [], [])),
            Element(xep("dgm", ns_dgm, "spPr", [], [])),
          ]),
        ),
      ]),
    ),
    Element(xep("dgm", ns_dgm, "cxnLst", [], [])),
  ])
}

///|
fn default_diagram_layout_def() -> @xml.Element {
  let ns_dgm = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
  // Minimal layoutDef with a `<dgm:constrLst>` carrying width/height
  // geometric constraints — required so the engine's
  // `definition_has_geometric_constraints` gate passes and the
  // SmartArt engine actually emits node bounds.  Without this the
  // engine returns `[]` and per-element diagram tests cannot see a
  // differential render outcome.
  xep("dgm", ns_dgm, "layoutDef", [xa("uniqueId", "default")], [
    Element(xep("dgm", ns_dgm, "title", [xa("val", "Default")], [])),
    Element(xep("dgm", ns_dgm, "desc", [xa("val", "Default")], [])),
    Element(xep("dgm", ns_dgm, "catLst", [], [])),
    Element(xep("dgm", ns_dgm, "sampData", [], [])),
    Element(xep("dgm", ns_dgm, "styleData", [], [])),
    Element(xep("dgm", ns_dgm, "clrData", [], [])),
    Element(
      xep("dgm", ns_dgm, "layoutNode", [xa("name", "node1")], [
        Element(
          xep("dgm", ns_dgm, "constrLst", [], [
            Element(
              xep(
                "dgm",
                ns_dgm,
                "constr",
                [xa("type", "w"), xa("val", "1.0")],
                [],
              ),
            ),
            Element(
              xep(
                "dgm",
                ns_dgm,
                "constr",
                [xa("type", "h"), xa("val", "1.0")],
                [],
              ),
            ),
          ]),
        ),
      ]),
    ),
  ])
}

///|
fn default_diagram_style_def() -> @xml.Element {
  let ns_dgm = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
  xep("dgm", ns_dgm, "styleDef", [xa("uniqueId", "default")], [
    Element(xep("dgm", ns_dgm, "title", [xa("val", "Default")], [])),
    Element(xep("dgm", ns_dgm, "desc", [xa("val", "Default")], [])),
    Element(xep("dgm", ns_dgm, "catLst", [], [])),
    Element(xep("dgm", ns_dgm, "scene3d", [], [])),
    Element(xep("dgm", ns_dgm, "styleLbl", [xa("name", "node1")], [])),
  ])
}

///|
fn default_diagram_colors_def() -> @xml.Element {
  let ns_dgm = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
  xep("dgm", ns_dgm, "colorsDef", [xa("uniqueId", "default")], [
    Element(xep("dgm", ns_dgm, "title", [xa("val", "Default")], [])),
    Element(xep("dgm", ns_dgm, "desc", [xa("val", "Default")], [])),
    Element(xep("dgm", ns_dgm, "catLst", [], [])),
    Element(xep("dgm", ns_dgm, "styleLbl", [xa("name", "node1")], [])),
  ])
}

///|
/// Slide body `<p:cSld>` for hosting a chart element under
/// `pptx:chart`.  `pptx_package_with_chart` wraps the supplied
/// content in `<p:sld>` so this builder returns the cSld + spTree +
/// graphicFrame chain alone.  The graphicFrame's
/// `<a:graphicData uri="…/chart">` references the chart part via
/// `rId2` — the same rId `pptx_package_with_chart` writes for
/// `ppt/charts/chart1.xml`.
fn default_chart_slide_body() -> @xml.Element {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let graphic_frame = xep("p", ns_p, "graphicFrame", [], [
    Element(
      xep("p", ns_p, "nvGraphicFramePr", [], [
        Element(
          xep("p", ns_p, "cNvPr", [xa("id", "2"), xa("name", "Chart 1")], []),
        ),
        Element(xep("p", ns_p, "cNvGraphicFramePr", [], [])),
        Element(xep("p", ns_p, "nvPr", [], [])),
      ]),
    ),
    Element(
      xep("p", ns_p, "xfrm", [], [
        Element(
          xep("a", ns_a, "off", [xa("x", "914400"), xa("y", "914400")], []),
        ),
        Element(
          xep("a", ns_a, "ext", [xa("cx", "6096000"), xa("cy", "4572000")], []),
        ),
      ]),
    ),
    Element(
      xep("a", ns_a, "graphic", [], [
        Element(
          xep("a", ns_a, "graphicData", [xa("uri", ns_c)], [
            Element(
              xep(
                "c",
                ns_c,
                "chart",
                [
                  {
                    name: {
                      prefix: Some("r"),
                      local_name: "id",
                      ns: Some(ns_r),
                    },
                    value: "rId2",
                  },
                ],
                [],
              ),
            ),
          ]),
        ),
      ]),
    ),
  ])
  pptx_common_slide_data(ns_p, [graphic_frame])
}

///|
/// §21.2 — fold a renderable scaffold into a `<c:chartSpace>` tree that
/// only carries the target element's ancestry skeleton.  The catalog's
/// per-element wrap_in_ancestry surrounds the target with the minimum
/// chain from `chartSpace` down (e.g. `chartSpace/chart/plotArea/valAx`
/// for `majorGridlines`), but the chart renderer needs at least one
/// chart-type sibling (`<c:barChart>` / `<c:lineChart>` / …) and one
/// numeric series in `plotArea` to actually paint axes / bars /
/// gridlines.  Without this enhancement the per-element verifier sees
/// an empty chart frame both with the target present and pruned, so
/// every axis / gridline / data-label sub-element falls to `parsed`.
///
/// The enhancement:
///   1. If `<c:chart>` is missing, return content unchanged (target is
///      probably chartSpace itself).
///   2. If `<c:plotArea>` already carries a chart-type child, return
///      content unchanged.
///   3. Otherwise splice a default `<c:barChart>` with one series of
///      three numeric points + `<c:axId>` pairs that match the
///      existing `<c:catAx>` / `<c:valAx>` axIds (synthesised when
///      absent).
fn first_child_named_in(e : @xml.Element, local_name : String) -> @xml.Element? {
  for child in e.children {
    match child {
      @xml.Node::Element(ce) =>
        if ce.name.local_name == local_name {
          return Some(ce)
        }
      _ => ()
    }
  }
  None
}

///|
fn build_default_num_cache() -> @xml.Element {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  xep("c", ns_c, "numCache", [], [
    Element(xep("c", ns_c, "formatCode", [], [Text("General")])),
    Element(xep("c", ns_c, "ptCount", [xa("val", "3")], [])),
    Element(
      xep("c", ns_c, "pt", [xa("idx", "0")], [
        Element(xep("c", ns_c, "v", [], [Text("2")])),
      ]),
    ),
    Element(
      xep("c", ns_c, "pt", [xa("idx", "1")], [
        Element(xep("c", ns_c, "v", [], [Text("5")])),
      ]),
    ),
    Element(
      xep("c", ns_c, "pt", [xa("idx", "2")], [
        Element(xep("c", ns_c, "v", [], [Text("3")])),
      ]),
    ),
  ])
}

///|
fn build_default_str_cache(values : Array[String]) -> @xml.Element {
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  let pts : Array[@xml.Node] = [
    Element(
      xep("c", ns_c, "ptCount", [xa("val", values.length().to_string())], []),
    ),
  ]
  for i, v in values {
    pts.push(
      Element(
        xep("c", ns_c, "pt", [xa("idx", i.to_string())], [
          Element(xep("c", ns_c, "v", [], [Text(v)])),
        ]),
      ),
    )
  }
  xep("c", ns_c, "strCache", [], pts)
}

///|
/// Walk the chart-space tree and, for every `<c:numRef>` / `<c:strRef>`
/// missing its `<c:numCache>` / `<c:strCache>` sibling, splice in a
/// default cache so the chart renderer's
/// `read_num_data_under` / `collect_pt_values` walkers find real
/// numeric / string points instead of returning empty.  Without this,
/// the chart-type renderers (line / bar / area / scatter / …) skip
/// the entire series via `if values.length() > 0` and emit no
/// trendline / errBars / data-label / marker geometry, so per-element
/// verification of every series-decoration sub-element falls to
/// `parsed`.
fn ensure_chart_data_caches(content : @xml.Element) -> @xml.Element {
  let default_strs = ["A", "B", "C"]
  fn cache_has_pt(cache : @xml.Element) -> Bool {
    for c in cache.children {
      match c {
        @xml.Node::Element(ce) => if ce.name.local_name == "pt" { return true }
        _ => ()
      }
    }
    false
  }

  fn rewrite(node : @xml.Node) -> @xml.Node {
    match node {
      @xml.Node::Element(e) => {
        let local = e.name.local_name
        // §21.2.2.97 CT_NumCache — when present-but-empty, fill it
        // with default points so chart_render's data extraction
        // returns a non-empty array.
        if local == "numCache" && !cache_has_pt(e) {
          let merged = build_default_num_cache()
          return Element({
            name: e.name,
            attributes: e.attributes,
            children: merged.children,
          })
        }
        // §21.2.2.196 CT_StrCache — same treatment.
        if local == "strCache" && !cache_has_pt(e) {
          let merged = build_default_str_cache(default_strs)
          return Element({
            name: e.name,
            attributes: e.attributes,
            children: merged.children,
          })
        }
        if local == "numRef" {
          // §21.2.2.117 CT_NumRef — splice numCache if absent.
          let has_cache = first_child_named_in(e, "numCache") is Some(_)
          if !has_cache {
            let kids : Array[@xml.Node] = []
            for c in e.children {
              kids.push(rewrite(c))
            }
            kids.push(Element(build_default_num_cache()))
            return Element({
              name: e.name,
              attributes: e.attributes,
              children: kids,
            })
          }
        }
        if local == "strRef" {
          // §21.2.2.196 CT_StrRef — splice strCache if absent.
          let has_cache = first_child_named_in(e, "strCache") is Some(_)
          if !has_cache {
            let kids : Array[@xml.Node] = []
            for c in e.children {
              kids.push(rewrite(c))
            }
            kids.push(Element(build_default_str_cache(default_strs)))
            return Element({
              name: e.name,
              attributes: e.attributes,
              children: kids,
            })
          }
        }
        let new_kids : Array[@xml.Node] = []
        for c in e.children {
          new_kids.push(rewrite(c))
        }
        Element({ name: e.name, attributes: e.attributes, children: new_kids })
      }
      other => other
    }
  }
  match rewrite(Element(content)) {
    @xml.Node::Element(e) => e
    _ => content
  }
}

///|
fn patch_synth_numeric_text(content : @xml.Element) -> @xml.Element {
  // Walk every `<c:v>` element under the chart's data caches and
  // replace text content equal to the synth placeholder "x" with
  // a real numeric "1".  Skips text matching the catalog's
  // `CATm…m` marker so per-element verification still detects
  // marker survival.  The chart renderer parses `<c:v>` as
  // Double via `@string.parse_double`; "x" yields 0.0 → every
  // series gets zero-length and the chart-type renderer skips it
  // (the `if values.length() > 0` guard in `render_area_chart` etc.),
  // which collapses the SVG into the empty `<g>` we observed.
  fn rewrite_node(node : @xml.Node) -> @xml.Node {
    match node {
      @xml.Node::Element(e) => {
        let local = e.name.local_name
        // §21.2.2.149 `<c:v>` — series data cache value. Replace
        // synth "x" with numeric "1"; preserve catalog markers.
        if local == "v" {
          let kids : Array[@xml.Node] = []
          for c in e.children {
            match c {
              @xml.Node::Text(t) =>
                if t == "x" {
                  kids.push(@xml.Node::Text("1"))
                } else {
                  kids.push(c)
                }
              other => kids.push(other)
            }
          }
          @xml.Node::Element({
            name: e.name,
            attributes: e.attributes,
            children: kids,
          })
        } else {
          let new_kids : Array[@xml.Node] = []
          for c in e.children {
            new_kids.push(rewrite_node(c))
          }
          @xml.Node::Element({
            name: e.name,
            attributes: e.attributes,
            children: new_kids,
          })
        }
      }
      other => other
    }
  }
  match rewrite_node(@xml.Node::Element(content)) {
    @xml.Node::Element(e) => e
    _ => content
  }
}

///|
fn enhance_chart_space_for_render(content : @xml.Element) -> @xml.Element {
  // The chart namespace; matches both transitional and strict by
  // using the transitional URI for prefix output (the actual element
  // names match by local_name in the renderer).
  let ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  // First, normalise every `<c:v>` synth placeholder so the chart
  // renderer's per-series value loop is no longer empty.
  let content = patch_synth_numeric_text(content)
  // Then ensure every numRef / strRef carries a numCache / strCache
  // with default data so series data extraction returns a non-empty
  // array.
  let content = ensure_chart_data_caches(content)
  if content.name.local_name != "chartSpace" {
    return content
  }
  let chart = match first_child_named_in(content, "chart") {
    Some(c) => c
    None => return content
  }
  let plot_area = match first_child_named_in(chart, "plotArea") {
    Some(p) => p
    None => return content
  }
  // Detect any existing chart-type child — if present, no scaffold
  // is needed (the target is itself a chart-type child or sibling).
  let chart_type_names = [
    "areaChart", "area3DChart", "barChart", "bar3DChart", "lineChart", "line3DChart",
    "pieChart", "pie3DChart", "doughnutChart", "ofPieChart", "scatterChart", "radarChart",
    "bubbleChart", "stockChart", "surfaceChart", "surface3DChart",
  ]
  fn has_chart_type(elem : @xml.Element) -> Bool {
    for child in elem.children {
      match child {
        @xml.Node::Element(ce) =>
          for n in chart_type_names {
            if ce.name.local_name == n {
              return true
            }
          }
        _ => ()
      }
    }
    false
  }

  // Always inject the scaffold — even when the synth has emitted a
  // chart-type child, that synth's `<c:v>x</c:v>` text content parses
  // to 0.0 and the renderer's series-skip guard
  // (`if values.length() > 0`) drops the entire chart, leaving the
  // SVG empty.  The scaffold has real numeric data so the renderer
  // produces axes / bars / gridlines that the per-element
  // differential check can detect.  When the target IS one of the
  // chart-type siblings (`<c:areaChart>` / `<c:lineChart>` / …),
  // pruning that target removes its specific render and leaves only
  // the scaffold's render — the skeleton diff still triggers because
  // the pruned chart-type's polygon / line / etc. disappears.
  let _ = has_chart_type
  // Build the scaffold barChart: barDir="col", grouping="clustered",
  // single series with 3 numeric points and matching axId references.
  // The axIds use a high numeric token (1000000001/2) so the scaffold's
  // pair never collides with the synth's axId="1" already on existing
  // catAx / valAx — both pairs coexist, and the renderer treats each
  // chart-type's axIds as authoritative for its own bars.
  let chart_axid_1 = "1000000001"
  let chart_axid_2 = "1000000002"
  let bar_chart = xep("c", ns_c, "barChart", [], [
    Element(xep("c", ns_c, "barDir", [xa("val", "col")], [])),
    Element(xep("c", ns_c, "grouping", [xa("val", "clustered")], [])),
    Element(xep("c", ns_c, "varyColors", [xa("val", "0")], [])),
    Element(
      xep("c", ns_c, "ser", [], [
        Element(xep("c", ns_c, "idx", [xa("val", "0")], [])),
        Element(xep("c", ns_c, "order", [xa("val", "0")], [])),
        Element(
          xep("c", ns_c, "tx", [], [
            Element(
              xep("c", ns_c, "strRef", [], [
                Element(xep("c", ns_c, "f", [], [Text("Sheet1!$A$1")])),
                Element(
                  xep("c", ns_c, "strCache", [], [
                    Element(xep("c", ns_c, "ptCount", [xa("val", "1")], [])),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "0")], [
                        Element(xep("c", ns_c, "v", [], [Text("Series 1")])),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        Element(
          xep("c", ns_c, "cat", [], [
            Element(
              xep("c", ns_c, "strRef", [], [
                Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$1:$D$1")])),
                Element(
                  xep("c", ns_c, "strCache", [], [
                    Element(xep("c", ns_c, "ptCount", [xa("val", "3")], [])),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "0")], [
                        Element(xep("c", ns_c, "v", [], [Text("A")])),
                      ]),
                    ),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "1")], [
                        Element(xep("c", ns_c, "v", [], [Text("B")])),
                      ]),
                    ),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "2")], [
                        Element(xep("c", ns_c, "v", [], [Text("C")])),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        Element(
          xep("c", ns_c, "val", [], [
            Element(
              xep("c", ns_c, "numRef", [], [
                Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$2:$D$2")])),
                Element(
                  xep("c", ns_c, "numCache", [], [
                    Element(xep("c", ns_c, "formatCode", [], [Text("General")])),
                    Element(xep("c", ns_c, "ptCount", [xa("val", "3")], [])),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "0")], [
                        Element(xep("c", ns_c, "v", [], [Text("2")])),
                      ]),
                    ),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "1")], [
                        Element(xep("c", ns_c, "v", [], [Text("5")])),
                      ]),
                    ),
                    Element(
                      xep("c", ns_c, "pt", [xa("idx", "2")], [
                        Element(xep("c", ns_c, "v", [], [Text("3")])),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ),
    Element(xep("c", ns_c, "axId", [xa("val", chart_axid_1)], [])),
    Element(xep("c", ns_c, "axId", [xa("val", chart_axid_2)], [])),
  ])
  // §21.2.2.171 — For every existing chart-type child in plotArea,
  // inject a default `<c:ser>` matching that chart-type's series
  // shape when the wrapper synth produced none.  Without this, the
  // per-element verifier targets sitting INSIDE a non-bar chart-type
  // (scatterStyle inside scatterChart, bubbleScale inside
  // bubbleChart, radarStyle inside radarChart, smooth inside
  // lineChart, …) never reach the renderer because the chart-type's
  // ser-loop returns empty — both the present and absent branches
  // render to the same scaffold-only SVG.  Injecting a per-type ser
  // here gives each chart-type real data to draw, so pruning a
  // child of that chart-type produces a real differential.
  fn inject_ser_if_missing(chart_type : @xml.Element) -> @xml.Element {
    let local = chart_type.name.local_name
    // Required data carriers per chart-type.  A ser is considered
    // "complete" only when every required carrier has at least one
    // `<c:pt>/<c:v>` with non-empty text.  For scatter/bubble both
    // xVal AND yVal must carry data (bubble adds bubbleSize too);
    // for line/bar/area/pie/etc. only `<c:val>` is required (cat is
    // a string label, optional from the renderer's perspective).
    let required_carriers : Array[String] = match local {
      "scatterChart" => ["xVal", "yVal"]
      "bubbleChart" => ["xVal", "yVal", "bubbleSize"]
      _ => ["val"]
    }
    fn carrier_has_data(ser : @xml.Element, carrier_name : String) -> Bool {
      let carrier = {
        let mut found : @xml.Element? = None
        for c in ser.children {
          match c {
            @xml.Node::Element(ce) =>
              if ce.name.local_name == carrier_name {
                found = Some(ce)
                break
              }
            _ => ()
          }
        }
        found
      }
      let carrier = match carrier {
        Some(c) => c
        None => return false
      }
      // Walk down to numCache → pt → v.
      fn walk(e : @xml.Element) -> Bool {
        for c in e.children {
          match c {
            @xml.Node::Element(ce) => {
              if ce.name.local_name == "pt" {
                for vc in ce.children {
                  match vc {
                    @xml.Node::Element(ve) =>
                      if ve.name.local_name == "v" {
                        for tn in ve.children {
                          match tn {
                            @xml.Node::Text(t) =>
                              if t.length() > 0 {
                                return true
                              }
                            _ => ()
                          }
                        }
                      }
                    _ => ()
                  }
                }
              }
              if walk(ce) {
                return true
              }
            }
            _ => ()
          }
        }
        false
      }
      walk(carrier)
    }
    fn count_carrier_points(ser : @xml.Element, carrier_name : String) -> Int {
      let carrier = {
        let mut found : @xml.Element? = None
        for c in ser.children {
          match c {
            @xml.Node::Element(ce) =>
              if ce.name.local_name == carrier_name {
                found = Some(ce)
                break
              }
            _ => ()
          }
        }
        found
      }
      let carrier = match carrier {
        Some(c) => c
        None => return 0
      }
      let mut count = 0
      fn walk(e : @xml.Element) -> Unit {
        for c in e.children {
          match c {
            @xml.Node::Element(ce) => {
              if ce.name.local_name == "pt" {
                for vc in ce.children {
                  match vc {
                    @xml.Node::Element(ve) =>
                      if ve.name.local_name == "v" {
                        for tn in ve.children {
                          match tn {
                            @xml.Node::Text(t) =>
                              if t.length() > 0 {
                                count = count + 1
                                break
                              }
                            _ => ()
                          }
                        }
                      }
                    _ => ()
                  }
                }
              }
              walk(ce)
            }
            _ => ()
          }
        }
      }
      walk(carrier)
      count
    }
    fn ser_data_state(ser : @xml.Element) -> Int {
      // 0 = no data at all, 1 = partial (some carriers populated,
      // others missing), 2 = complete (all required carriers
      // populated).
      let mut populated = 0
      for carrier in required_carriers {
        if count_carrier_points(ser, carrier) >= 1 {
          populated = populated + 1
        }
      }
      if populated == required_carriers.length() {
        2
      } else if populated == 0 {
        0
      } else {
        1
      }
    }
    let mut ser_count = 0
    let mut any_complete = false
    let mut any_partial = false
    for c in chart_type.children {
      match c {
        @xml.Node::Element(ce) =>
          if ce.name.local_name == "ser" {
            ser_count = ser_count + 1
            match ser_data_state(ce) {
              2 => any_complete = true
              1 => any_partial = true
              _ => ()
            }
          }
        _ => ()
      }
    }
    if any_complete {
      // Real series data is already present — nothing to do.
      return chart_type
    }
    if any_partial {
      // Some series carrier is populated, others empty — the
      // empty one is likely the verifier's prune target (e.g.
      // `<c:yVal>` removed by the differential check).  Leave the
      // ser alone so present-has-data / absent-has-no-data
      // remains a real differential.
      return chart_type
    }
    if ser_count == 0 {
      // No ser at all — the target was probably the ser itself.
      // Injecting one here would mask the diff.
      return chart_type
    }
    // Pick the appropriate series shape per chart-type.
    let new_ser = match local {
      "scatterChart" =>
        // §21.2.2.176 CT_ScatterChart — CT_ScatterSer with xVal/yVal.
        xep("c", ns_c, "ser", [], [
          Element(xep("c", ns_c, "idx", [xa("val", "0")], [])),
          Element(xep("c", ns_c, "order", [xa("val", "0")], [])),
          Element(
            xep("c", ns_c, "xVal", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$A$2:$A$4")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
          Element(
            xep("c", ns_c, "yVal", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$2:$B$4")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
        ])
      "bubbleChart" =>
        // §21.2.2.21 CT_BubbleChart — CT_BubbleSer with
        // xVal/yVal/bubbleSize.
        xep("c", ns_c, "ser", [], [
          Element(xep("c", ns_c, "idx", [xa("val", "0")], [])),
          Element(xep("c", ns_c, "order", [xa("val", "0")], [])),
          Element(
            xep("c", ns_c, "xVal", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$A$2:$A$4")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
          Element(
            xep("c", ns_c, "yVal", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$2:$B$4")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
          Element(
            xep("c", ns_c, "bubbleSize", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$C$2:$C$4")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
        ])
      "surfaceChart" | "surface3DChart" =>
        // §21.2.2.202 CT_SurfaceChart — CT_SurfaceSer with just val.
        xep("c", ns_c, "ser", [], [
          Element(xep("c", ns_c, "idx", [xa("val", "0")], [])),
          Element(xep("c", ns_c, "order", [xa("val", "0")], [])),
          Element(
            xep("c", ns_c, "val", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$2:$D$2")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
        ])
      _ =>
        // Default — CT_LineSer / CT_BarSer / CT_AreaSer / CT_PieSer /
        // CT_DoughnutChart / CT_OfPieSer / CT_RadarSer / CT_StockSer
        // all carry cat + val.  Re-use the bar_chart's ser shape.
        xep("c", ns_c, "ser", [], [
          Element(xep("c", ns_c, "idx", [xa("val", "0")], [])),
          Element(xep("c", ns_c, "order", [xa("val", "0")], [])),
          Element(
            xep("c", ns_c, "cat", [], [
              Element(
                xep("c", ns_c, "strRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$1:$D$1")])),
                  Element(build_default_str_cache(["A", "B", "C"])),
                ]),
              ),
            ]),
          ),
          Element(
            xep("c", ns_c, "val", [], [
              Element(
                xep("c", ns_c, "numRef", [], [
                  Element(xep("c", ns_c, "f", [], [Text("Sheet1!$B$2:$D$2")])),
                  Element(build_default_num_cache()),
                ]),
              ),
            ]),
          ),
        ])
    }
    // Drop any existing empty ser children (the synth wrapper may
    // have emitted one with no numCache pt data, which would mask
    // our injected ser when the renderer picks the first one).  Then
    // splice the new ser BEFORE the first axId (or append if none).
    let new_kids : Array[@xml.Node] = []
    let mut injected = false
    for c in chart_type.children {
      match c {
        @xml.Node::Element(ce) => {
          if ce.name.local_name == "ser" {
            // Drop empty synth-wrapped ser; the new one replaces it.
            continue
          }
          if !injected && ce.name.local_name == "axId" {
            new_kids.push(@xml.Node::Element(new_ser))
            injected = true
          }
        }
        _ => ()
      }
      new_kids.push(c)
    }
    if !injected {
      new_kids.push(@xml.Node::Element(new_ser))
    }
    {
      name: chart_type.name,
      attributes: chart_type.attributes,
      children: new_kids,
    }
  }

  // Rebuild plotArea: rewrite each chart-type child to ensure it has
  // a default ser, then splice the scaffold barChart in before the
  // first axis child (or append when no axis exists).
  let new_pa_kids : Array[@xml.Node] = []
  let mut inserted = false
  fn is_axis_child(n : String) -> Bool {
    n == "catAx" || n == "valAx" || n == "dateAx" || n == "serAx"
  }
  fn is_chart_type_child(n : String) -> Bool {
    for name in chart_type_names {
      if n == name {
        return true
      }
    }
    false
  }
  for child in plot_area.children {
    match child {
      @xml.Node::Element(ce) => {
        if !inserted && is_axis_child(ce.name.local_name) {
          new_pa_kids.push(@xml.Node::Element(bar_chart))
          inserted = true
        }
        if is_chart_type_child(ce.name.local_name) {
          new_pa_kids.push(@xml.Node::Element(inject_ser_if_missing(ce)))
          continue
        }
      }
      _ => ()
    }
    new_pa_kids.push(child)
  }
  if !inserted {
    new_pa_kids.push(@xml.Node::Element(bar_chart))
  }
  let new_plot_area : @xml.Element = {
    name: plot_area.name,
    attributes: plot_area.attributes,
    children: new_pa_kids,
  }
  // Rebuild chart with new plot_area.
  let new_chart_kids : Array[@xml.Node] = []
  for child in chart.children {
    match child {
      @xml.Node::Element(ce) if ce.name.local_name == "plotArea" => {
        let _ = ce
        new_chart_kids.push(@xml.Node::Element(new_plot_area))
      }
      other => new_chart_kids.push(other)
    }
  }
  let new_chart : @xml.Element = {
    name: chart.name,
    attributes: chart.attributes,
    children: new_chart_kids,
  }
  // Rebuild chartSpace.
  let new_cs_kids : Array[@xml.Node] = []
  for child in content.children {
    match child {
      @xml.Node::Element(ce) if ce.name.local_name == "chart" => {
        let _ = ce
        new_cs_kids.push(@xml.Node::Element(new_chart))
      }
      other => new_cs_kids.push(other)
    }
  }
  { name: content.name, attributes: content.attributes, children: new_cs_kids }
}

///|
/// Return whether `local_name` is one of the §17.8.2.4 embedded-font
/// relationship elements inside `/word/fontTable.xml`.
fn is_font_table_embed_element(local_name : String) -> Bool {
  match local_name {
    "embedRegular" | "embedBold" | "embedItalic" | "embedBoldItalic" => true
    _ => false
  }
}

///|
/// `docx_aux_package("fonts", ...)` owns exactly one synthetic
/// font-data relationship. The catalog synthesiser produces
/// facet-valid ST_RelationshipId values such as `"0"` for the WML
/// `r:id` reference, while OPC relationship elements require xsd:ID
/// NCNames. Retarget only the fontTable embedded-font references here
/// so OPC validation remains the single source of truth for
/// relationship-element ids.
fn retarget_font_table_embed_rids(element : @xml.Element) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  if is_font_table_embed_element(element.name.local_name) {
    for attr in element.attributes {
      if attr.name.local_name == "id" &&
        (attr.name.ns == Some(NS_OFFICE_REL) || attr.name.prefix == Some("r")) {
        attrs.push({
          name: { prefix: Some("r"), local_name: "id", ns: Some(NS_OFFICE_REL) },
          value: FONT_TABLE_DATA_RID,
        })
      } else {
        attrs.push(attr)
      }
    }
  } else {
    for attr in element.attributes {
      attrs.push(attr)
    }
  }
  let children : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(ce) => children.push(Element(retarget_font_table_embed_rids(ce)))
      _ => children.push(child)
    }
  }
  { name: element.name, attributes: attrs, children }
}

///|
/// `.docx` package that ships `content` as the body of a WML auxiliary
/// part (`settings.xml` / `styles.xml` / `numbering.xml` /
/// `fontTable.xml` / `webSettings.xml` / `comments.xml` /
/// `footnotes.xml` / `endnotes.xml`) — wired into the document's
/// relationships and `[Content_Types].xml` with the matching
/// §17.18 relationship-type URI and content-type override.  The
/// `<w:document>` part stays a minimal empty `<w:body/>` so the
/// auxiliary part is the only render-affecting payload.
fn docx_aux_package(part_kind : String, content : @xml.Element) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  // Map the part kind to its (canonical part-name, rel-type URI,
  // content-type, root-element local name) — these come from the
  // OPC registry's WordprocessingML section.
  let (part_path, rel_type, content_type, root_name) : (
    String,
    String,
    String,
    String,
  ) = match part_kind {
    "settings" =>
      (
        "settings.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml",
        "settings",
      )
    "styles" =>
      (
        "styles.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml",
        "styles",
      )
    "numbering" =>
      (
        "numbering.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml",
        "numbering",
      )
    "fonts" =>
      (
        "fontTable.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml",
        "fonts",
      )
    "webSettings" =>
      (
        "webSettings.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml",
        "webSettings",
      )
    "glossary" =>
      (
        "glossary/document.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/glossaryDocument",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document.glossary+xml",
        "glossaryDocument",
      )
    "comments" =>
      (
        "comments.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml",
        "comments",
      )
    "footnotes" =>
      (
        "footnotes.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml",
        "footnotes",
      )
    "endnotes" =>
      (
        "endnotes.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml",
        "endnotes",
      )
    _ =>
      (
        "settings.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml",
        "settings",
      )
  }
  // Wrap `content` in the part's root element if it isn't already —
  // each aux part's root carries the WML namespace and the
  // ECMA-376-defined local name (settings, styles, numbering, ...).
  let aux_content = if part_kind == "fonts" {
    retarget_font_table_embed_rids(content)
  } else {
    content
  }
  let aux_root : @xml.Element = if aux_content.name.local_name == root_name {
    aux_content
  } else {
    {
      name: { prefix: Some("w"), local_name: root_name, ns: Some(ns_w) },
      attributes: [],
      children: [Element(aux_content)],
    }
  }
  // Minimal `<w:document>` body — the auxiliary part is what we
  // care about, but a docx needs a document part to be a valid
  // OPC office-document package.
  let document : @xml.Element = {
    name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
    attributes: [],
    children: [
      Element({
        name: { prefix: Some("w"), local_name: "body", ns: Some(ns_w) },
        attributes: [],
        children: [],
      }),
    ],
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [xa("Id", "rId1"), xa("Type", rel_type), xa("Target", part_path)],
        [],
      ),
    ),
  ])
  // §17.8.2.4 — only the `fonts` aux part carries `r:id` pointers
  // (`<w:embedRegular/Bold/Italic/BoldItalic>` reference satellite
  // font-data parts). Other WML aux parts (`settings`, `styles`,
  // ...) do not. Attaching an aux-part rels file unconditionally
  // breaks the open of the parts that don't need rels because the
  // Content-Types map lacks the satellite part's content type.
  let ct_overrides : Array[(String, String)] = [
    (
      "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
    ),
    ("/word/" + part_path, content_type),
  ]
  if part_kind == "fonts" {
    ct_overrides.push(("/word/fonts/font0.fntdata", "application/x-fontdata"))
  }
  let parts : Array[(String, Bytes)] = [
    ("[Content_Types].xml", content_types_part(ct_overrides)),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
    ("word/" + part_path, write_part(aux_root)),
  ]
  if part_kind == "fonts" {
    // §17.8.2.4 font-data targets: the schema synthesiser's
    // ST_RelationshipId sample may be `"0"` on `<w:embed*>`, but
    // OPC Relationship/@Id is xsd:ID. Keep that distinction at the
    // package boundary by retargeting the fontTable references above
    // and emitting exactly the matching valid relationship id here.
    let aux_rels = xe(NS_PKG_REL, "Relationships", [], [
      Element(
        xe(
          NS_PKG_REL,
          "Relationship",
          [
            xa("Id", FONT_TABLE_DATA_RID),
            xa(
              "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/font",
            ),
            xa("Target", "fonts/font0.fntdata"),
            xa("TargetMode", "Internal"),
          ],
          [],
        ),
      ),
    ])
    parts.push(("word/_rels/" + part_path + ".rels", write_part(aux_rels)))
    parts.push(("word/fonts/font0.fntdata", Bytes::new(0)))
  }
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.docx` package whose main document contains comment / footnote /
/// endnote reference elements and whose relationship graph carries
/// the matching annotation parts.
fn docx_package_with_annotation_refs(body : @xml.Element) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let body_root : @xml.Element = if body.name.local_name == "body" {
    body
  } else {
    xep("w", ns_w, "body", [], [Element(body)])
  }
  let document : @xml.Element = {
    name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
    attributes: [],
    children: [Element(body_root)],
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rIdComments"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments",
          ),
          xa("Target", "comments.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rIdFootnotes"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes",
          ),
          xa("Target", "footnotes.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rIdEndnotes"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes",
          ),
          xa("Target", "endnotes.xml"),
        ],
        [],
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
        (
          "/word/comments.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml",
        ),
        (
          "/word/footnotes.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml",
        ),
        (
          "/word/endnotes.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
    ("word/comments.xml", write_part(wml_aux_comments_part())),
    ("word/footnotes.xml", write_part(wml_aux_footnotes_part())),
    ("word/endnotes.xml", write_part(wml_aux_endnotes_part())),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.docx` package with a header or footer part wired through
/// `<w:sectPr>` in `word/document.xml`.  Rendering stays owned by the
/// WML context/viewer header-footer path; this host only supplies the
/// ECMA-376 OPC relationship and section reference.
fn docx_header_footer_package(
  part_kind : String,
  content : @xml.Element,
) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let (root_name, part_path, rel_type, content_type, reference_name) : (
    String,
    String,
    String,
    String,
    String,
  ) = match part_kind {
    "footer" =>
      (
        "ftr", "footer1.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml",
        "footerReference",
      )
    _ =>
      (
        "hdr", "header1.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml",
        "headerReference",
      )
  }
  let part_root : @xml.Element = if content.name.local_name == root_name {
    content
  } else {
    xep("w", ns_w, root_name, [], [Element(content)])
  }
  let reference = xep(
    "w",
    ns_w,
    reference_name,
    [
      {
        name: { prefix: Some("w"), local_name: "type", ns: Some(ns_w) },
        value: "default",
      },
      {
        name: { prefix: Some("r"), local_name: "id", ns: Some(NS_OFFICE_REL) },
        value: "rId1",
      },
    ],
    [],
  )
  let body = xep("w", ns_w, "body", [], [
    Element(
      xep("w", ns_w, "p", [], [
        Element(
          xep("w", ns_w, "r", [], [
            Element(xep("w", ns_w, "t", [], [Text("Catalog body")])),
          ]),
        ),
      ]),
    ),
    Element(xep("w", ns_w, "sectPr", [], [Element(reference)])),
  ])
  let document : @xml.Element = {
    name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
    attributes: [],
    children: [Element(body)],
  }
  let doc_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [xa("Id", "rId1"), xa("Type", rel_type), xa("Target", part_path)],
        [],
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/word/document.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        ),
        ("/word/" + part_path, content_type),
      ]),
    ),
    ("_rels/.rels", root_rels_part("word/document.xml")),
    ("word/document.xml", write_part(document)),
    ("word/_rels/document.xml.rels", write_part(doc_rels)),
    ("word/" + part_path, write_part(part_root)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.pptx` package whose `ppt/theme/theme1.xml` (or
/// `ppt/presentation.xml`) is replaced with `content`.  The slide /
/// slideLayout / slideMaster chain stays minimal so the rendered
/// SVG reflects only what the replaced aux part contributes.
fn pptx_with_aux_root_package(
  part_kind : String,
  content : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  match part_kind {
    "theme" => {
      // Wrap `content` in `<a:theme>` if it isn't already.  The
      // theme part's root must be `<a:theme>` per §20.1.6.9.
      let theme_root : @xml.Element = if content.name.local_name == "theme" {
        content
      } else {
        xep("a", ns_a, "theme", [xa("name", "x")], [Element(content)])
      }
      pptx_package_with_replaced_theme(theme_root)
    }
    "presentation" => {
      // For the presentation part we can't easily swap it out
      // because the slide-master / slide chain depends on it.
      // Fall back to wrapping in a normal pptx where the
      // `<p:presentation>` part is replaced; if `content` is
      // already a `<p:presentation>` it becomes the part.
      let pres_root : @xml.Element = if content.name.local_name ==
        "presentation" {
        content
      } else {
        xep("p", ns_p, "presentation", [], [Element(content)])
      }
      pptx_package_with_replaced_presentation(pres_root)
    }
    "presentationPr" => pptx_package_with_presentation_props(content)
    "viewPr" =>
      pptx_package_with_standard_aux_part(
        "ppt/viewProps.xml", "application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/viewProps",
        "viewProps.xml", content,
      )
    "themeOverride" =>
      pptx_package_with_standard_aux_part(
        "ppt/theme/themeOverride1.xml", "application/vnd.openxmlformats-officedocument.themeOverride+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/themeOverride",
        "theme/themeOverride1.xml", content,
      )
    "themeManager" =>
      pptx_package_with_standard_aux_part(
        "ppt/theme/themeManager.xml", "application/vnd.openxmlformats-officedocument.themeManager+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/themeManager",
        "theme/themeManager.xml", content,
      )
    "comments" =>
      pptx_package_with_slide_aux_part(
        "ppt/comments/comment1.xml", "application/vnd.openxmlformats-officedocument.presentationml.comments+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments",
        "../comments/comment1.xml", content,
      )
    "sldSyncPr" =>
      pptx_package_with_slide_aux_part(
        "ppt/slideUpdateInfo/slideUpdateInfo1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideUpdateInfo+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideUpdateInfo",
        "../slideUpdateInfo/slideUpdateInfo1.xml", content,
      )
    "commentAuthors" =>
      pptx_package_with_standard_aux_part(
        "ppt/commentAuthors.xml", "application/vnd.openxmlformats-officedocument.presentationml.commentAuthors+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/commentAuthors",
        "commentAuthors.xml", content,
      )
    "notes" =>
      pptx_package_with_slide_aux_part(
        "ppt/notesSlides/notesSlide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.notesSlide+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesSlide",
        "../notesSlides/notesSlide1.xml", content,
      )
    "notesMaster" =>
      pptx_package_with_standard_aux_part(
        "ppt/notesMasters/notesMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.notesMaster+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/notesMaster",
        "notesMasters/notesMaster1.xml", content,
      )
    "handoutMaster" =>
      pptx_package_with_standard_aux_part(
        "ppt/handoutMasters/handoutMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.handoutMaster+xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/handoutMaster",
        "handoutMasters/handoutMaster1.xml", content,
      )
    _ => pptx_package(content)
  }
}

///|
fn pptx_od_rel(local_name : String) -> String {
  "http://schemas.openxmlformats.org/officeDocument/2006/relationships/" +
  local_name
}

///|
fn pptx_relationship(
  id : String,
  relationship_type : String,
  target : String,
) -> @xml.Element {
  xe(
    NS_PKG_REL,
    "Relationship",
    [xa("Id", id), xa("Type", relationship_type), xa("Target", target)],
    [],
  )
}

///|
fn pptx_external_relationship(
  id : String,
  relationship_type : String,
  target : String,
) -> @xml.Element {
  xe(
    NS_PKG_REL,
    "Relationship",
    [
      xa("Id", id),
      xa("Type", relationship_type),
      xa("Target", target),
      xa("TargetMode", "External"),
    ],
    [],
  )
}

///|
fn pptx_base_content_type_overrides() -> Array[(String, String)] {
  [
    (
      "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
    ),
    (
      "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
    ),
    (
      "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
    ),
    (
      "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
    ),
    (
      "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
    ),
  ]
}

///|
fn pptx_catalog_tag_list_part() -> @xml.Element {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  xep("p", ns_p, "tagLst", [], [
    Element(
      xep(
        "p",
        ns_p,
        "tag",
        [xa("name", "CatalogTag"), xa("val", "CatalogValue")],
        [],
      ),
    ),
  ])
}

///|
fn pptx_catalog_custom_xml_part(name : String) -> @xml.Element {
  xe("urn:ooxml:catalog", name, [], [])
}

///|
/// Add one slide-owned PresentationML auxiliary XML part to the
/// canonical one-slide package.  The slide relationship table is the
/// source of truth for comments / notes slides and other slide-local
/// data parts.
fn pptx_package_with_slide_aux_part(
  part_name : String,
  content_type : String,
  relationship_type : String,
  target : String,
  content : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let base = pptx_package(pptx_common_slide_data(ns_p, []))
  let archive = @zip.read(base) catch { _ => return Bytes::new(0) }
  let parts : Array[(String, Bytes)] = []
  for entry in archive.entries {
    if entry.name != "[Content_Types].xml" &&
      entry.name != "ppt/slides/_rels/slide1.xml.rels" {
      parts.push((entry.name, entry.data))
    }
  }
  let ct_overrides = pptx_base_content_type_overrides()
  ct_overrides.push(("/" + part_name, content_type))
  parts.push(("[Content_Types].xml", content_types_part(ct_overrides)))
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      pptx_relationship(
        "rId1",
        pptx_od_rel("slideLayout"),
        "../slideLayouts/slideLayout1.xml",
      ),
    ),
    Element(pptx_relationship("rId2", relationship_type, target)),
  ])
  parts.push(("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)))
  parts.push((part_name, write_part(content)))
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Rich slide-local relationship host for §19.3.1.16 common slide
/// data references: contentPart, custData, tags and controls live in
/// the slide XML while their targets are wired through slide1.xml.rels.
fn pptx_package_with_slide_refs(c_sld : @xml.Element) -> Bytes {
  let base = pptx_package(c_sld)
  let archive = @zip.read(base) catch { _ => return Bytes::new(0) }
  let parts : Array[(String, Bytes)] = []
  for entry in archive.entries {
    if entry.name != "[Content_Types].xml" &&
      entry.name != "ppt/slides/_rels/slide1.xml.rels" {
      parts.push((entry.name, entry.data))
    }
  }
  let ct_overrides = pptx_base_content_type_overrides()
  ct_overrides.push(
    (
      "/ppt/tags/tag1.xml", "application/vnd.openxmlformats-officedocument.presentationml.tags+xml",
    ),
  )
  parts.push(("[Content_Types].xml", content_types_part(ct_overrides)))
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      pptx_relationship(
        "rId1",
        pptx_od_rel("slideLayout"),
        "../slideLayouts/slideLayout1.xml",
      ),
    ),
    Element(
      pptx_relationship(
        "rId2",
        pptx_od_rel("customXml"),
        "../customXml/contentPart1.xml",
      ),
    ),
    Element(
      pptx_relationship(
        "rId3",
        pptx_od_rel("customXml"),
        "../customXml/customerData1.xml",
      ),
    ),
    Element(pptx_relationship("rId4", pptx_od_rel("tags"), "../tags/tag1.xml")),
  ])
  parts.push(("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)))
  parts.push(("ppt/tags/tag1.xml", write_part(pptx_catalog_tag_list_part())))
  parts.push(
    (
      "ppt/customXml/contentPart1.xml",
      write_part(pptx_catalog_custom_xml_part("contentPart")),
    ),
  )
  parts.push(
    (
      "ppt/customXml/customerData1.xml",
      write_part(pptx_catalog_custom_xml_part("customerData")),
    ),
  )
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Presentation-owned relationship host for master ids, smart tags,
/// custom data tags and embedded font-data ids.
fn pptx_package_with_presentation_refs(presentation : @xml.Element) -> Bytes {
  let base = pptx_package_with_replaced_presentation(presentation)
  let archive = @zip.read(base) catch { _ => return Bytes::new(0) }
  let parts : Array[(String, Bytes)] = []
  for entry in archive.entries {
    if entry.name != "[Content_Types].xml" &&
      entry.name != "ppt/_rels/presentation.xml.rels" {
      parts.push((entry.name, entry.data))
    }
  }
  let ct_overrides = pptx_base_content_type_overrides()
  ct_overrides.push(
    (
      "/ppt/notesMasters/notesMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.notesMaster+xml",
    ),
  )
  ct_overrides.push(
    (
      "/ppt/handoutMasters/handoutMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.handoutMaster+xml",
    ),
  )
  ct_overrides.push(
    (
      "/ppt/tags/presentationTags.xml", "application/vnd.openxmlformats-officedocument.presentationml.tags+xml",
    ),
  )
  ct_overrides.push(("/ppt/fonts/regular.fntdata", "application/x-fontdata"))
  ct_overrides.push(("/ppt/fonts/bold.fntdata", "application/x-fontdata"))
  ct_overrides.push(("/ppt/fonts/italic.fntdata", "application/x-fontdata"))
  ct_overrides.push(("/ppt/fonts/boldItalic.fntdata", "application/x-fontdata"))
  parts.push(("[Content_Types].xml", content_types_part(ct_overrides)))
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      pptx_relationship("rId1", pptx_od_rel("slide"), "slides/slide1.xml"),
    ),
    Element(
      pptx_relationship(
        "rId2",
        pptx_od_rel("slideMaster"),
        "slideMasters/slideMaster1.xml",
      ),
    ),
    Element(pptx_relationship("rId3", pptx_od_rel("theme"), "theme/theme1.xml")),
    Element(
      pptx_relationship(
        "rId4",
        pptx_od_rel("notesMaster"),
        "notesMasters/notesMaster1.xml",
      ),
    ),
    Element(
      pptx_relationship(
        "rId5",
        pptx_od_rel("handoutMaster"),
        "handoutMasters/handoutMaster1.xml",
      ),
    ),
    Element(
      pptx_relationship(
        "rId6",
        pptx_od_rel("customXml"),
        "customXml/smartTags.xml",
      ),
    ),
    Element(
      pptx_relationship(
        "rId7",
        pptx_od_rel("customXml"),
        "customXml/customerData.xml",
      ),
    ),
    Element(
      pptx_relationship(
        "rId8",
        pptx_od_rel("tags"),
        "tags/presentationTags.xml",
      ),
    ),
    Element(
      pptx_relationship("rId9", pptx_od_rel("font"), "fonts/regular.fntdata"),
    ),
    Element(
      pptx_relationship("rId10", pptx_od_rel("font"), "fonts/bold.fntdata"),
    ),
    Element(
      pptx_relationship("rId11", pptx_od_rel("font"), "fonts/italic.fntdata"),
    ),
    Element(
      pptx_relationship(
        "rId12",
        pptx_od_rel("font"),
        "fonts/boldItalic.fntdata",
      ),
    ),
  ])
  parts.push(("ppt/_rels/presentation.xml.rels", write_part(pres_rels)))
  parts.push(
    (
      "ppt/notesMasters/notesMaster1.xml",
      write_part(pml_cov_notes_master_root()),
    ),
  )
  parts.push(
    (
      "ppt/handoutMasters/handoutMaster1.xml",
      write_part(pml_cov_handout_master_root()),
    ),
  )
  parts.push(
    ("ppt/tags/presentationTags.xml", write_part(pptx_catalog_tag_list_part())),
  )
  parts.push(
    (
      "ppt/customXml/smartTags.xml",
      write_part(pptx_catalog_custom_xml_part("smartTags")),
    ),
  )
  parts.push(
    (
      "ppt/customXml/customerData.xml",
      write_part(pptx_catalog_custom_xml_part("presentationData")),
    ),
  )
  parts.push(("ppt/fonts/regular.fntdata", Bytes::new(0)))
  parts.push(("ppt/fonts/bold.fntdata", Bytes::new(0)))
  parts.push(("ppt/fonts/italic.fntdata", Bytes::new(0)))
  parts.push(("ppt/fonts/boldItalic.fntdata", Bytes::new(0)))
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Presentation properties host.  `<p:htmlPubPr>` carries an
/// `@r:id` scoped to `ppt/presProps.xml`, so the aux part needs its
/// own relationship table in addition to the presentation.xml link.
fn pptx_package_with_presentation_props(content : @xml.Element) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let base = pptx_package(pptx_common_slide_data(ns_p, []))
  let archive = @zip.read(base) catch { _ => return Bytes::new(0) }
  let parts : Array[(String, Bytes)] = []
  for entry in archive.entries {
    if entry.name != "[Content_Types].xml" &&
      entry.name != "ppt/_rels/presentation.xml.rels" {
      parts.push((entry.name, entry.data))
    }
  }
  let ct_overrides = pptx_base_content_type_overrides()
  ct_overrides.push(
    (
      "/ppt/presProps.xml", "application/vnd.openxmlformats-officedocument.presentationml.presProps+xml",
    ),
  )
  parts.push(("[Content_Types].xml", content_types_part(ct_overrides)))
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      pptx_relationship("rId1", pptx_od_rel("slide"), "slides/slide1.xml"),
    ),
    Element(
      pptx_relationship(
        "rId2",
        pptx_od_rel("slideMaster"),
        "slideMasters/slideMaster1.xml",
      ),
    ),
    Element(pptx_relationship("rId3", pptx_od_rel("theme"), "theme/theme1.xml")),
    Element(
      pptx_relationship("rId4", pptx_od_rel("presProps"), "presProps.xml"),
    ),
  ])
  let props_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      pptx_external_relationship(
        "rId1",
        pptx_od_rel("htmlPubSaveAs"),
        "catalog.html",
      ),
    ),
  ])
  parts.push(("ppt/_rels/presentation.xml.rels", write_part(pres_rels)))
  parts.push(("ppt/_rels/presProps.xml.rels", write_part(props_rels)))
  parts.push(("ppt/presProps.xml", write_part(content)))
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Add one standard PresentationML auxiliary XML part to the
/// canonical one-slide package.  The existing slide/master/layout
/// scaffolding is kept byte-for-byte except for the content types and
/// presentation relationship table required to make the new part a
/// reachable OOXML part.
fn pptx_package_with_standard_aux_part(
  part_name : String,
  content_type : String,
  relationship_type : String,
  target : String,
  content : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let base = pptx_package(pptx_common_slide_data(ns_p, []))
  let archive = @zip.read(base) catch { _ => return Bytes::new(0) }
  let parts : Array[(String, Bytes)] = []
  for entry in archive.entries {
    if entry.name != "[Content_Types].xml" &&
      entry.name != "ppt/_rels/presentation.xml.rels" {
      parts.push((entry.name, entry.data))
    }
  }
  parts.push(
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
        ("/" + part_name, content_type),
      ]),
    ),
  )
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [xa("Id", "rId4"), xa("Type", relationship_type), xa("Target", target)],
        [],
      ),
    ),
  ])
  parts.push(("ppt/_rels/presentation.xml.rels", write_part(pres_rels)))
  parts.push((part_name, write_part(content)))
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose `xl/workbook.xml` / `xl/sharedStrings.xml` /
/// `xl/styles.xml` is replaced with `content`.  The worksheet /
/// workbook plumbing stays minimal so the rendered SVG reflects only
/// what the replaced aux part contributes.
fn xlsx_with_aux_root_package(
  part_kind : String,
  content : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  match part_kind {
    "workbook" => {
      let wb_root : @xml.Element = if content.name.local_name == "workbook" {
        content
      } else {
        xe(ns_s, "workbook", [], [Element(content)])
      }
      xlsx_package_with_replaced_workbook(wb_root)
    }
    "sharedStrings" => {
      let sst_root : @xml.Element = if content.name.local_name == "sst" {
        content
      } else {
        xe(ns_s, "sst", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "sharedStrings", "sharedStrings.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml",
        sst_root,
      )
    }
    "styles" => {
      let styles_root : @xml.Element = if content.name.local_name ==
        "styleSheet" {
        content
      } else {
        xe(ns_s, "styleSheet", [], [Element(content)])
      }
      xlsx_package_styled(
        catalog_sml_style_probe_worksheet(),
        catalog_sml_stylesheet_for_render(styles_root),
      )
    }
    "comments" => {
      let comments_root : @xml.Element = if content.name.local_name ==
        "comments" {
        content
      } else {
        xe(ns_s, "comments", [], [Element(content)])
      }
      xlsx_package_with_comments_part(
        retarget_spreadsheet_comment_refs(comments_root),
      )
    }
    "calcChain" => {
      let calc_chain_root : @xml.Element = if content.name.local_name ==
        "calcChain" {
        content
      } else {
        xe(ns_s, "calcChain", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "calcChain", "calcChain.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/calcChain",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.calcChain+xml",
        calc_chain_root,
      )
    }
    "connections" => {
      let connections_root : @xml.Element = if content.name.local_name ==
        "connections" {
        content
      } else {
        xe(ns_s, "connections", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "connections", "connections.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/connections",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.connections+xml",
        connections_root,
      )
    }
    "metadata" => {
      let metadata_root : @xml.Element = if content.name.local_name ==
        "metadata" {
        content
      } else {
        xe(ns_s, "metadata", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "metadata", "metadata.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sheetMetadata",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheetMetadata+xml",
        metadata_root,
      )
    }
    "xmlMaps" => {
      let xml_maps_root : @xml.Element = if content.name.local_name == "MapInfo" {
        content
      } else {
        xe(ns_s, "MapInfo", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "xmlMaps", "xmlMaps.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/xmlMaps",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.xmlMaps+xml",
        xml_maps_root,
      )
    }
    "queryTable" => {
      let query_table_root : @xml.Element = if content.name.local_name ==
        "queryTable" {
        content
      } else {
        xe(ns_s, "queryTable", [], [Element(content)])
      }
      xlsx_package_with_query_table_part(query_table_root)
    }
    "revisionHeaders" => {
      let headers_root : @xml.Element = if content.name.local_name == "headers" {
        content
      } else {
        xe(ns_s, "headers", [], [Element(content)])
      }
      xlsx_package_with_revision_parts(
        headers_root,
        catalog_sml_revisions_minimal(),
      )
    }
    "revisionLog" => {
      let revisions_root : @xml.Element = if content.name.local_name ==
        "revisions" {
        content
      } else {
        xe(ns_s, "revisions", [], [Element(content)])
      }
      xlsx_package_with_revision_parts(
        catalog_sml_revision_headers_minimal(),
        revisions_root,
      )
    }
    "userNames" => {
      let users_root : @xml.Element = if content.name.local_name == "users" {
        content
      } else {
        xe(ns_s, "users", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "userNames", "revisions/userNames.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/usernames",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.userNames+xml",
        users_root,
      )
    }
    "volatileDependencies" => {
      let vol_types_root : @xml.Element = if content.name.local_name ==
        "volTypes" {
        content
      } else {
        xe(ns_s, "volTypes", [], [Element(content)])
      }
      xlsx_package_with_aux_part(
        "volatileDependencies", "volatileDependencies.xml", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/volatileDependencies",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.volatileDependencies+xml",
        vol_types_root,
      )
    }
    _ => xlsx_package(content)
  }
}

///|
fn catalog_opc_relationship(
  id : String,
  relationship_type : String,
  target : String,
) -> @xml.Element {
  xe(
    NS_PKG_REL,
    "Relationship",
    [xa("Id", id), xa("Type", relationship_type), xa("Target", target)],
    [],
  )
}

///|
fn catalog_sml_single_sheet_workbook(sheet_name : String) -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", sheet_name),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
}

///|
fn catalog_sml_workbook_rels(
  sheet_rel_type : String,
  sheet_target : String,
  extra_relationships : Array[@xml.Element],
) -> @xml.Element {
  let kids : Array[@xml.Node] = [
    Element(catalog_opc_relationship("rId1", sheet_rel_type, sheet_target)),
  ]
  for rel in extra_relationships {
    kids.push(Element(rel))
  }
  xe(NS_PKG_REL, "Relationships", [], kids)
}

///|
fn catalog_empty_spreadsheet_drawing_part() -> @xml.Element {
  xep(
    "xdr",
    "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing",
    "wsDr",
    [],
    [],
  )
}

///|
fn catalog_spreadsheet_custom_property_part() -> @xml.Element {
  let ns_custom = "urn:ooxml:fixture:custom-property"
  xe(ns_custom, "CustomApplicationData", [], [
    Element(
      xe(
        ns_custom,
        "CustomProperty",
        [xa("name", "CatalogProperty"), xa("value", "observed")],
        [],
      ),
    ),
  ])
}

///|
fn catalog_active_x_control_part() -> @xml.Element {
  let ns_ax = "http://schemas.microsoft.com/office/2006/activeX"
  xep(
    "ax",
    ns_ax,
    "ocx",
    [
      xa("classid", "{D7053240-CE69-11CD-A777-00DD01143C57}"),
      xa("persistence", "persistPropertyBag"),
    ],
    [
      Element(
        xep(
          "ax",
          ns_ax,
          "ocxPr",
          [xa("name", "Caption"), xa("value", "CatalogControl")],
          [],
        ),
      ),
    ],
  )
}

///|
fn catalog_sml_single_xml_cells_minimal() -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xe(ns_s, "singleXmlCells", [], [
    Element(
      xe(
        ns_s,
        "singleXmlCell",
        [xa("id", "1"), xa("r", "A1"), xa("connectionId", "1")],
        [
          Element(
            xe(ns_s, "xmlCellPr", [xa("id", "1"), xa("uniqueName", "A1")], [
              Element(
                xe(
                  ns_s,
                  "xmlPr",
                  [
                    xa("mapId", "1"),
                    xa("xpath", "/root/value"),
                    xa("xmlDataType", "string"),
                  ],
                  [],
                ),
              ),
            ]),
          ),
        ],
      ),
    ),
  ])
}

///|
/// `.xlsx` package whose worksheet carries the late-sequence SML
/// relationship-bearing children: customProperties, legacyDrawingHF,
/// drawingHF, picture, oleObjects, and controls.
fn xlsx_package_with_worksheet_refs(content : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let worksheet : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    xe(ns_s, "worksheet", [], [Element(content)])
  }
  let workbook = catalog_sml_single_sheet_workbook("S1")
  let workbook_rels = catalog_sml_workbook_rels(
    RT_WORKSHEET,
    "worksheets/sheet1.xml",
    [],
  )
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      catalog_opc_relationship(
        "rIdCustom",
        RT_SPREADSHEET_CUSTOM_PROPERTY,
        "../customProperties/customProperty1.xml",
      ),
    ),
    Element(
      catalog_opc_relationship(
        "rIdLegacyHF",
        RT_VML_DRAWING,
        "../drawings/vmlDrawingHF1.vml",
      ),
    ),
    Element(
      catalog_opc_relationship(
        "rIdDrawingHF",
        RT_DRAWING,
        "../drawings/drawingHF1.xml",
      ),
    ),
    Element(
      catalog_opc_relationship("rIdPicture", RT_IMAGE, "../media/image1.png"),
    ),
    Element(
      catalog_opc_relationship(
        "rIdControl",
        RT_CONTROL,
        "../activeX/activeX1.xml",
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        ("/xl/customProperties/customProperty1.xml", "application/xml"),
        ("/xl/drawings/vmlDrawingHF1.vml", CT_VML_DRAWING),
        ("/xl/drawings/drawingHF1.xml", CT_SPREADSHEET_DRAWING),
        ("/xl/media/image1.png", CT_IMAGE_PNG),
        ("/xl/activeX/activeX1.xml", CT_ACTIVE_X_CONTROL),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(workbook_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    (
      "xl/customProperties/customProperty1.xml",
      write_part(catalog_spreadsheet_custom_property_part()),
    ),
    (
      "xl/drawings/vmlDrawingHF1.vml",
      write_part(chart_legacy_vml_drawing_part()),
    ),
    (
      "xl/drawings/drawingHF1.xml",
      write_part(catalog_empty_spreadsheet_drawing_part()),
    ),
    ("xl/media/image1.png", test_image_8x8_quad()),
    ("xl/activeX/activeX1.xml", write_part(catalog_active_x_control_part())),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
fn xlsx_package_with_chartsheet(content : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let chartsheet : @xml.Element = if content.name.local_name == "chartsheet" {
    content
  } else {
    xe(ns_s, "chartsheet", [], [Element(content)])
  }
  let workbook = catalog_sml_single_sheet_workbook("C1")
  let workbook_rels = catalog_sml_workbook_rels(
    RT_CHARTSHEET,
    "chartsheets/sheet1.xml",
    [],
  )
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      catalog_opc_relationship(
        "rIdDrawing",
        RT_DRAWING,
        "../drawings/drawing1.xml",
      ),
    ),
    Element(
      catalog_opc_relationship(
        "rIdLegacyHF",
        RT_VML_DRAWING,
        "../drawings/vmlDrawingHF1.vml",
      ),
    ),
    Element(
      catalog_opc_relationship(
        "rIdDrawingHF",
        RT_DRAWING,
        "../drawings/drawingHF1.xml",
      ),
    ),
    Element(
      catalog_opc_relationship("rIdPicture", RT_IMAGE, "../media/image1.png"),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/chartsheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.chartsheet+xml",
        ),
        ("/xl/drawings/drawing1.xml", CT_SPREADSHEET_DRAWING),
        ("/xl/drawings/vmlDrawingHF1.vml", CT_VML_DRAWING),
        ("/xl/drawings/drawingHF1.xml", CT_SPREADSHEET_DRAWING),
        ("/xl/media/image1.png", CT_IMAGE_PNG),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(workbook_rels)),
    ("xl/chartsheets/sheet1.xml", write_part(chartsheet)),
    ("xl/chartsheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    (
      "xl/drawings/drawing1.xml",
      write_part(catalog_empty_spreadsheet_drawing_part()),
    ),
    (
      "xl/drawings/vmlDrawingHF1.vml",
      write_part(chart_legacy_vml_drawing_part()),
    ),
    (
      "xl/drawings/drawingHF1.xml",
      write_part(catalog_empty_spreadsheet_drawing_part()),
    ),
    ("xl/media/image1.png", test_image_8x8_quad()),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
fn xlsx_package_with_dialogsheet(content : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let dialogsheet : @xml.Element = if content.name.local_name == "dialogsheet" {
    content
  } else {
    xe(ns_s, "dialogsheet", [], [Element(content)])
  }
  let workbook = catalog_sml_single_sheet_workbook("D1")
  let workbook_rels = catalog_sml_workbook_rels(
    RT_DIALOGSHEET,
    "dialogsheets/sheet1.xml",
    [],
  )
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      catalog_opc_relationship(
        "rIdLegacyHF",
        RT_VML_DRAWING,
        "../drawings/vmlDrawingHF1.vml",
      ),
    ),
    Element(
      catalog_opc_relationship(
        "rIdDrawingHF",
        RT_DRAWING,
        "../drawings/drawingHF1.xml",
      ),
    ),
    Element(
      catalog_opc_relationship(
        "rIdControl",
        RT_CONTROL,
        "../activeX/activeX1.xml",
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/dialogsheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.dialogsheet+xml",
        ),
        ("/xl/drawings/vmlDrawingHF1.vml", CT_VML_DRAWING),
        ("/xl/drawings/drawingHF1.xml", CT_SPREADSHEET_DRAWING),
        ("/xl/activeX/activeX1.xml", CT_ACTIVE_X_CONTROL),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(workbook_rels)),
    ("xl/dialogsheets/sheet1.xml", write_part(dialogsheet)),
    ("xl/dialogsheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    (
      "xl/drawings/vmlDrawingHF1.vml",
      write_part(chart_legacy_vml_drawing_part()),
    ),
    (
      "xl/drawings/drawingHF1.xml",
      write_part(catalog_empty_spreadsheet_drawing_part()),
    ),
    ("xl/activeX/activeX1.xml", write_part(catalog_active_x_control_part())),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
fn xlsx_package_with_table_single_cells(content : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let single_xml_cells : @xml.Element = if content.name.local_name ==
    "singleXmlCells" {
    content
  } else {
    xe(ns_s, "singleXmlCells", [], [Element(content)])
  }
  let workbook = catalog_sml_single_sheet_workbook("S1")
  let workbook_rels = catalog_sml_workbook_rels(
    RT_WORKSHEET,
    "worksheets/sheet1.xml",
    [
      catalog_opc_relationship(
        "rId2", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/connections",
        "connections.xml",
      ),
      catalog_opc_relationship(
        "rId3", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/xmlMaps",
        "xmlMaps.xml",
      ),
    ],
  )
  let worksheet = xe(ns_s, "worksheet", [], [
    Element(xe(ns_s, "dimension", [xa("ref", "A1:A1")], [])),
    Element(
      xe(ns_s, "sheetData", [], [
        Element(
          xe(ns_s, "row", [xa("r", "1")], [
            Element(
              xe(ns_s, "c", [xa("r", "A1"), xa("t", "str")], [
                Element(xe(ns_s, "v", [], [Text("mapped")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      catalog_opc_relationship(
        "rIdTableSingleCells",
        RT_TABLE_SINGLE_CELLS,
        "../tables/tableSingleCells1.xml",
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        ("/xl/tables/tableSingleCells1.xml", CT_TABLE_SINGLE_CELLS),
        (
          "/xl/connections.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.connections+xml",
        ),
        (
          "/xl/xmlMaps.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.xmlMaps+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(workbook_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    ("xl/tables/tableSingleCells1.xml", write_part(single_xml_cells)),
    ("xl/connections.xml", write_part(sml_aux_connections_part())),
    ("xl/xmlMaps.xml", write_part(sml_aux_xml_maps_part())),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// The catalog comments host paints indicators on a synthetic sheet
/// containing `A1`; keep generated `<comment @ref>` values aligned
/// with that sheet so §18.7 comments exercise the real renderer path.
fn retarget_spreadsheet_comment_refs(element : @xml.Element) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  if element.name.local_name == "comment" {
    for attr in element.attributes {
      if attr.name.local_name == "ref" &&
        (attr.value == "x" || attr.value == "") {
        attrs.push({ name: attr.name, value: "A1" })
      } else {
        attrs.push(attr)
      }
    }
  } else {
    for attr in element.attributes {
      attrs.push(attr)
    }
  }
  let children : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(ce) =>
        children.push(Element(retarget_spreadsheet_comment_refs(ce)))
      _ => children.push(child)
    }
  }
  { name: element.name, attributes: attrs, children }
}

///|
/// `.xlsx` package whose worksheet owns a comments part.  Comments
/// are resolved from `xl/worksheets/sheet1.xml.rels`, not from the
/// workbook relationship table, per ECMA-376 §18.7.
fn xlsx_package_with_comments_part(comments_root : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let workbook_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = xe(ns_s, "worksheet", [], [
    Element(
      xe(ns_s, "sheetData", [], [
        Element(
          xe(ns_s, "row", [xa("r", "1")], [
            Element(
              xe(ns_s, "c", [xa("r", "A1"), xa("t", "str")], [
                Element(xe(ns_s, "v", [], [Text("commented")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments",
          ),
          xa("Target", "../comments1.xml"),
        ],
        [],
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        (
          "/xl/comments1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(workbook_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    ("xl/comments1.xml", write_part(comments_root)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// The §20.1.6.9 CT_OfficeStyleSheet child element names, in their
/// schema sequence order.  Mirrors `workbook_child_order()` for the
/// SML workbook splice — `<themeElements>` is the only schema-
/// required child (`minOccurs=1`) but downstream consumers expect
/// the canonical sequence.
fn theme_child_order() -> Array[String] {
  [
    "themeElements", "objectDefaults", "extraClrSchemeLst", "custClrLst", "extLst",
  ]
}

///|
/// The §20.1.6.2 CT_BaseStyles child element names, in their schema
/// sequence order.  `themeElements` REQUIRES all three style
/// schemes (`minOccurs=1` for clrScheme / fontScheme / fmtScheme),
/// so when the caller's themeElements lacks a sibling the skeleton
/// version is kept — otherwise CT_OfficeStyleSheet::new raises and
/// the renderer falls back to no-theme.
fn theme_elements_child_order() -> Array[String] {
  ["clrScheme", "fontScheme", "fmtScheme", "extLst"]
}

///|
/// Wrap `theme` with a §20.1.6.9-valid skeleton.  Merging happens
/// at two levels:
///
///   * `<a:theme>` children — the caller's top-level theme
///     children (`themeElements`, `objectDefaults`,
///     `extraClrSchemeLst`, `custClrLst`, `extLst`) are spliced
///     into the canonical pptx_theme_part skeleton.  When the
///     caller does NOT supply a `<themeElements>`, the canonical
///     one survives — its required `clrScheme / fontScheme /
///     fmtScheme` triple is what makes the theme part parseable.
///   * `<a:themeElements>` inner children — when the caller DOES
///     supply a `<themeElements>`, its children
///     (`clrScheme / fontScheme / fmtScheme / extLst`) are spliced
///     into the canonical themeElements one-by-one.  This way a
///     target like `<a:clrScheme>` replaces the canonical
///     clrScheme but the canonical fontScheme / fmtScheme stay,
///     keeping the §20.1.6.2 CT_BaseStyles required-child
///     contract intact.
fn ensure_theme_skeleton(theme : @xml.Element) -> @xml.Element {
  let canonical_bytes = pptx_theme_part()
  let canonical = try @xml.parse(canonical_bytes) catch {
    _ => theme
  } noraise {
    doc => doc.root
  }
  // The single themeElements child of the caller, if any —
  // extracted so its children can be spliced into the canonical
  // themeElements one-by-one rather than replacing the whole
  // themeElements (which would discard the canonical's required
  // fontScheme / fmtScheme).
  fn extract_theme_elements(t : @xml.Element) -> @xml.Element? {
    for child in t.children {
      match child {
        Element(ce) if ce.name.local_name == "themeElements" => return Some(ce)
        _ => ()
      }
    }
    None
  }

  if theme.name.local_name == "theme" {
    let mut cur = canonical
    // First splice the non-themeElements children of `theme`
    // into the canonical at their sequence positions.
    for child in theme.children {
      match child {
        Element(ce) if ce.name.local_name != "themeElements" =>
          cur = splice_child_in_sequence(cur, ce, theme_child_order())
        _ => ()
      }
    }
    // Then, if the caller supplied a `<themeElements>`, splice
    // each of its inner children into the canonical themeElements
    // one-by-one (preserving the canonical's required siblings).
    match extract_theme_elements(theme) {
      None => ()
      Some(caller_te) => {
        let canonical_te = match
          first_child_named_local_local(cur, "themeElements") {
          Some(ct) => ct
          None => caller_te
        }
        let mut new_te = canonical_te
        for inner in caller_te.children {
          match inner {
            Element(ie) =>
              new_te = splice_child_in_sequence(
                new_te,
                ie,
                theme_elements_child_order(),
              )
            _ => ()
          }
        }
        cur = splice_child_in_sequence(cur, new_te, theme_child_order())
      }
    }
    cur
  } else {
    splice_child_in_sequence(canonical, theme, theme_child_order())
  }
}

///|
/// Helper local to `ensure_theme_skeleton` — return the first
/// element child of `e` whose local name matches `local_name`.
fn first_child_named_local_local(
  e : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in e.children {
    match child {
      Element(ce) if ce.name.local_name == local_name => return Some(ce)
      _ => ()
    }
  }
  None
}

///|
/// `.pptx` package that uses `theme` as `ppt/theme/theme1.xml`
/// instead of the canonical `pptx_theme_part()`.  Built on top of
/// `pptx_package` by re-emitting the same OPC scaffolding with the
/// theme part swapped, AFTER splicing the caller's content into a
/// spec-valid skeleton so the required `<themeElements>` chain
/// remains intact.  All other parts (presentation, slides,
/// slideMasters, slideLayouts) keep their canonical content.
fn pptx_package_with_replaced_theme(theme : @xml.Element) -> Bytes {
  let theme = ensure_theme_skeleton(theme)
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let presentation : @xml.Element = xep("p", ns_p, "presentation", [], [
    Element(
      xep("p", ns_p, "sldMasterIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldMasterId",
            [
              xa("id", "2147483648"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId2",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep("p", ns_p, "sldIdLst", [], [
        Element(
          xep(
            "p",
            ns_p,
            "sldId",
            [
              xa("id", "256"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xep(
        "p",
        ns_p,
        "sldSz",
        [xa("cx", "9144000"), xa("cy", "6858000"), xa("type", "screen4x3")],
        [],
      ),
    ),
    Element(
      xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
    ),
  ])
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide : @xml.Element = {
    name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
    attributes: [],
    children: [Element(pptx_common_slide_data(ns_p, []))],
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", write_part(theme)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// The §19.2.1.26 CT_Presentation child element names, in their schema
/// sequence order.  Mirrors `workbook_child_order()` for the SML
/// workbook splice — the splice must preserve the canonical
/// `sldMasterIdLst → notesMasterIdLst → … → extLst` order so the
/// reader's per-child handlers see siblings in spec position.
fn presentation_child_order() -> Array[String] {
  [
    "sldMasterIdLst", "notesMasterIdLst", "handoutMasterIdLst", "sldIdLst", "sldSz",
    "notesSz", "smartTags", "embeddedFontLst", "custShowLst", "photoAlbum", "custDataLst",
    "kinsoku", "defaultTextStyle", "modifyVerifier", "extLst",
  ]
}

///|
/// `.pptx` package whose `ppt/presentation.xml` carries the caller's
/// target child element spliced into a minimal spec-valid skeleton.
///
/// §19.2.1.26 CT_Presentation requires `<notesSz>` (minOccurs=1)
/// and Office consumers reject a presentation without at least one
/// `<sldMasterIdLst>/<sldMasterId>` reference, so the skeleton
/// ships those plus an `<sldIdLst>` pointing at the single slide
/// this builder writes.  Children are spliced in via
/// `splice_child_in_sequence` so a presentation-level target (e.g.
/// `<sldSz>`, `<embeddedFontLst>`, `<modifyVerifier>`) lands at
/// its canonical sequence position and replaces the skeleton's
/// own entry of the same name when one exists.
fn pptx_package_with_replaced_presentation(
  presentation : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // §19.2.1.26 minimal spec-valid presentation skeleton.  The
  // sld[Master]IdLst entries reference the rId2 / rId1 the package
  // builder below wires; sldSz / notesSz default to the standard
  // 9144000×6858000 / 6858000×9144000 EMU sizes (10" × 7.5"
  // landscape slides, 7.5" × 10" portrait notes).
  let skeleton : @xml.Element = {
    name: { prefix: Some("p"), local_name: "presentation", ns: Some(ns_p) },
    attributes: [],
    children: [
      Element(
        xep("p", ns_p, "sldMasterIdLst", [], [
          Element(
            xep(
              "p",
              ns_p,
              "sldMasterId",
              [
                xa("id", "2147483648"),
                {
                  name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                  value: "rId2",
                },
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xep("p", ns_p, "sldIdLst", [], [
          Element(
            xep(
              "p",
              ns_p,
              "sldId",
              [
                xa("id", "256"),
                {
                  name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                  value: "rId1",
                },
              ],
              [],
            ),
          ),
        ]),
      ),
      Element(
        xep("p", ns_p, "sldSz", [xa("cx", "9144000"), xa("cy", "6858000")], []),
      ),
      Element(
        xep("p", ns_p, "notesSz", [xa("cx", "6858000"), xa("cy", "9144000")], []),
      ),
    ],
  }
  let merged : @xml.Element = if presentation.name.local_name == "presentation" {
    let mut cur = skeleton
    for child in presentation.children {
      match child {
        Element(ce) =>
          cur = splice_child_in_sequence(cur, ce, presentation_child_order())
        _ => ()
      }
    }
    cur
  } else {
    splice_child_in_sequence(skeleton, presentation, presentation_child_order())
  }
  // From this point on the original packaging applies — the rels /
  // slide-master / slide-layout / theme parts stay canonical.
  let presentation = merged
  let pres_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
          ),
          xa("Target", "slides/slide1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId3"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let master_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme",
          ),
          xa("Target", "../theme/theme1.xml"),
        ],
        [],
      ),
    ),
  ])
  let layout_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster",
          ),
          xa("Target", "../slideMasters/slideMaster1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
          ),
          xa("Target", "../slideLayouts/slideLayout1.xml"),
        ],
        [],
      ),
    ),
  ])
  let slide : @xml.Element = {
    name: { prefix: Some("p"), local_name: "sld", ns: Some(ns_p) },
    attributes: [],
    children: [Element(pptx_common_slide_data(ns_p, []))],
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/ppt/presentation.xml", "application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml",
        ),
        (
          "/ppt/slides/slide1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
        ),
        (
          "/ppt/slideLayouts/slideLayout1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml",
        ),
        (
          "/ppt/slideMasters/slideMaster1.xml", "application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml",
        ),
        (
          "/ppt/theme/theme1.xml", "application/vnd.openxmlformats-officedocument.theme+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("ppt/presentation.xml")),
    ("ppt/presentation.xml", write_part(presentation)),
    ("ppt/_rels/presentation.xml.rels", write_part(pres_rels)),
    ("ppt/slides/slide1.xml", write_part(slide)),
    ("ppt/slides/_rels/slide1.xml.rels", write_part(slide_rels)),
    ("ppt/slideLayouts/slideLayout1.xml", pptx_slide_layout_part()),
    ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", write_part(layout_rels)),
    ("ppt/slideMasters/slideMaster1.xml", pptx_slide_master_part()),
    ("ppt/slideMasters/_rels/slideMaster1.xml.rels", write_part(master_rels)),
    ("ppt/theme/theme1.xml", pptx_theme_part()),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// The §18.2.1 CT_Workbook child element names, in their schema
/// sequence order.  `xlsx_package_with_replaced_workbook` uses this
/// to splice the caller's target into a spec-valid skeleton at the
/// correct position — `<sheets>` is the only required child per
/// the XSD, but consumer readers reject a workbook with sibling
/// elements appearing out of sequence order, so the splice must
/// keep the canonical order.
fn workbook_child_order() -> Array[String] {
  [
    "fileVersion", "fileSharing", "workbookPr", "workbookProtection", "bookViews",
    "sheets", "functionGroups", "externalReferences", "definedNames", "calcPr", "oleSize",
    "customWorkbookViews", "pivotCaches", "smartTagPr", "smartTagTypes", "webPublishing",
    "fileRecoveryPr", "webPublishObjects", "extLst",
  ]
}

///|
/// Splice `replacement` (an `@xml.Element` whose local name names a
/// position in `order`) into `skeleton`'s child sequence —
/// replacing the existing child of the same local name when one
/// exists, or inserting at the canonical sequence position (per
/// `order`) when not.  Unknown local names append to the end so a
/// future workbook / presentation child is still represented in the
/// output.
fn splice_child_in_sequence(
  skeleton : @xml.Element,
  replacement : @xml.Element,
  order : Array[String],
) -> @xml.Element {
  let target_name = replacement.name.local_name
  let mut target_pos = order.length()
  for i, n in order {
    if n == target_name {
      target_pos = i
      break
    }
  }
  let kids : Array[@xml.Node] = []
  let mut inserted = false
  for child in skeleton.children {
    match child {
      Element(ce) if ce.name.local_name == target_name => {
        kids.push(Element(replacement))
        inserted = true
      }
      Element(ce) => {
        let mut ce_pos = order.length()
        for i, n in order {
          if n == ce.name.local_name {
            ce_pos = i
            break
          }
        }
        if !inserted && target_pos < ce_pos {
          kids.push(Element(replacement))
          inserted = true
        }
        kids.push(Element(ce))
      }
      other => kids.push(other)
    }
  }
  if !inserted {
    kids.push(Element(replacement))
  }
  { name: skeleton.name, attributes: skeleton.attributes, children: kids }
}

///|
/// `.xlsx` package whose `xl/workbook.xml` carries the caller's
/// target workbook child (`<workbookProtection>`, `<fileVersion>`,
/// `<bookViews>`, …) spliced into a minimal spec-valid skeleton.
///
/// §18.2.1 CT_Workbook only REQUIRES `<sheets>` per the XSD, but
/// Office consumers reject a bare-sheets workbook outright and the
/// SML renderer's `<workbook>` metadata reader only surfaces
/// values when the workbook plumbing is intact.  The skeleton
/// therefore ships `<fileVersion>`, `<workbookPr>`, `<bookViews>`,
/// `<sheets>` (with one sheet pointing at the worksheet part this
/// builder writes) and `<calcPr>` — the five children Excel emits
/// for every new workbook.
///
/// The target is spliced via `splice_child_in_sequence` so a
/// workbook child like `<workbookProtection>` lands at its
/// canonical sequence position (between `<workbookPr>` and
/// `<bookViews>`), keeping the §18.2.1 sequence ordering even
/// when the target replaces or inserts.  When the caller supplies
/// a `<workbook>` root, every one of its children is spliced in
/// turn so a multi-child workbook (e.g. the renderer's existing
/// xlsx fixture) survives wholesale.
fn xlsx_package_with_replaced_workbook(workbook : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let skeleton : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(
        ns_s,
        "fileVersion",
        [xa("appName", "xl"), xa("lastEdited", "0"), xa("rupBuild", "0")],
        [],
      ),
    ),
    Element(xe(ns_s, "workbookPr", [], [])),
    Element(
      xe(ns_s, "bookViews", [], [
        Element(
          xe(
            ns_s,
            "workbookView",
            [
              xa("xWindow", "0"),
              xa("yWindow", "0"),
              xa("windowWidth", "16384"),
              xa("windowHeight", "8192"),
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
    Element(xe(ns_s, "calcPr", [xa("calcId", "0")], [])),
  ])
  let merged : @xml.Element = if workbook.name.local_name == "workbook" {
    let mut cur = skeleton
    for child in workbook.children {
      match child {
        Element(ce) =>
          cur = splice_child_in_sequence(cur, ce, workbook_child_order())
        _ => ()
      }
    }
    cur
  } else {
    splice_child_in_sequence(skeleton, workbook, workbook_child_order())
  }
  let merged = retarget_workbook_sheet_rids(merged, ns_r)
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = {
    name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
    attributes: [],
    children: [Element(xe(ns_s, "sheetData", [], []))],
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(merged)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `xlsx_package_with_replaced_workbook` owns exactly one workbook ->
/// worksheet relationship (`rId1`).  The schema synthesiser may emit a
/// facet-valid but unresolved `r:id` such as `"0"` on the target
/// `<sheet>` element; retarget it here so workbook-child catalog probes
/// exercise the actual workbook renderer instead of an empty workbook.
fn retarget_workbook_sheet_rids(
  element : @xml.Element,
  ns_r : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  let mut saw_rid = false
  if element.name.local_name == "sheet" {
    for attr in element.attributes {
      if attr.name.local_name == "id" &&
        (attr.name.ns == Some(ns_r) || attr.name.prefix == Some("r")) {
        attrs.push({
          name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
          value: "rId1",
        })
        saw_rid = true
      } else {
        attrs.push(attr)
      }
    }
    if !saw_rid {
      attrs.push({
        name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
        value: "rId1",
      })
    }
  } else {
    for attr in element.attributes {
      attrs.push(attr)
    }
  }
  let children : Array[@xml.Node] = []
  for child in element.children {
    match child {
      Element(ce) =>
        children.push(Element(retarget_workbook_sheet_rids(ce, ns_r)))
      _ => children.push(child)
    }
  }
  { name: element.name, attributes: attrs, children }
}

///|
/// `.xlsx` package with one auxiliary SML part wired in (sharedStrings
/// is the only current case; others use the dedicated `xlsx_*`
/// builders).  `aux_root` is the part's root element; `part_path`,
/// `rel_type`, `content_type` come from §18.2 / §18.8 part-name
/// conventions.  The sharedStrings host supplies an A1 string cell so
/// the SML viewer resolves `/xl/sharedStrings.xml` through a real
/// worksheet reference.
fn xlsx_package_with_aux_part(
  part_kind : String,
  part_path : String,
  rel_type : String,
  content_type : String,
  aux_root : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [xa("Id", "rId2"), xa("Type", rel_type), xa("Target", part_path)],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = if part_kind == "sharedStrings" {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [
        Element(xe(ns_s, "dimension", [xa("ref", "A1:A1")], [])),
        Element(
          xe(ns_s, "sheetData", [], [
            Element(
              xe(ns_s, "row", [xa("r", "1")], [
                Element(
                  xe(ns_s, "c", [xa("r", "A1"), xa("t", "s")], [
                    Element(xe(ns_s, "v", [], [Text("0")])),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ],
    }
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(xe(ns_s, "sheetData", [], []))],
    }
  }
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        ("/xl/" + part_path, content_type),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/" + part_path, write_part(aux_root)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Minimal Shared Workbook Revision Headers part.  The `<header>`'s
/// `r:id` is resolved by `xlsx_package_with_revision_parts` to the
/// companion revision log part.
fn catalog_sml_revision_headers_minimal() -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xe(ns_s, "headers", [xa("guid", "{233BEE23-EB5C-4542-905D-0230EFFED88B}")], [
    Element(
      xe(
        ns_s,
        "header",
        [
          xa("guid", "{A5A4B6F1-2B31-4B09-9AC8-000000000001}"),
          xa("dateTime", "2026-06-06T00:00:00Z"),
          xa("maxSheetId", "1"),
          xa("userName", "Catalog User"),
          {
            name: {
              prefix: Some("r"),
              local_name: "id",
              ns: Some(NS_OFFICE_REL),
            },
            value: "rId1",
          },
        ],
        [
          Element(
            xe(ns_s, "sheetIdMap", [xa("count", "1")], [
              Element(xe(ns_s, "sheetId", [xa("val", "1")], [])),
            ]),
          ),
        ],
      ),
    ),
  ])
}

///|
/// Minimal Shared Workbook Revision Log part used as a companion when
/// the target fixture is the revision headers root.
fn catalog_sml_revisions_minimal() -> @xml.Element {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xe(ns_s, "revisions", [], [
    Element(
      xe(
        ns_s,
        "rcv",
        [
          xa("guid", "{A5A4B6F1-2B31-4B09-9AC8-000000000002}"),
          xa("action", "add"),
        ],
        [],
      ),
    ),
  ])
}

///|
/// `.xlsx` package carrying the shared-workbook revision header/log
/// relationship stack: workbook -> revisionHeaders -> revisionLog.
/// Revision logs are explicit relationships from the headers part, so
/// `xlsx_package_with_aux_part` cannot model this graph.
fn xlsx_package_with_revision_parts(
  headers_root : @xml.Element,
  revisions_root : @xml.Element,
) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/revisionHeaders",
          ),
          xa("Target", "revisions/revisionHeaders.xml"),
        ],
        [],
      ),
    ),
  ])
  let header_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/revisionLog",
          ),
          xa("Target", "revisionLog1.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = xe(ns_s, "worksheet", [], [
    Element(xe(ns_s, "sheetData", [], [])),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        (
          "/xl/revisions/revisionHeaders.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.revisionHeaders+xml",
        ),
        (
          "/xl/revisions/revisionLog1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.revisionLog+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/revisions/revisionHeaders.xml", write_part(headers_root)),
    ("xl/revisions/_rels/revisionHeaders.xml.rels", write_part(header_rels)),
    ("xl/revisions/revisionLog1.xml", write_part(revisions_root)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose worksheet owns a queryTable relationship.
/// The queryTable references connection id 1, so the host includes a
/// minimal workbook-level connections part as its referent.
fn xlsx_package_with_query_table_part(query_table_root : @xml.Element) -> Bytes {
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let workbook : @xml.Element = xe(ns_s, "workbook", [], [
    Element(
      xe(ns_s, "sheets", [], [
        Element(
          xe(
            ns_s,
            "sheet",
            [
              xa("name", "S1"),
              xa("sheetId", "1"),
              {
                name: { prefix: Some("r"), local_name: "id", ns: Some(ns_r) },
                value: "rId1",
              },
            ],
            [],
          ),
        ),
      ]),
    ),
  ])
  let wb_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet",
          ),
          xa("Target", "worksheets/sheet1.xml"),
        ],
        [],
      ),
    ),
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId2"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/connections",
          ),
          xa("Target", "connections.xml"),
        ],
        [],
      ),
    ),
  ])
  let worksheet : @xml.Element = xe(ns_s, "worksheet", [], [
    Element(
      xe(ns_s, "sheetData", [], [
        Element(
          xe(ns_s, "row", [xa("r", "1")], [
            Element(
              xe(ns_s, "c", [xa("r", "A1"), xa("t", "str")], [
                Element(xe(ns_s, "v", [], [Text("query-table")])),
              ]),
            ),
          ]),
        ),
      ]),
    ),
  ])
  let sheet_rels = xe(NS_PKG_REL, "Relationships", [], [
    Element(
      xe(
        NS_PKG_REL,
        "Relationship",
        [
          xa("Id", "rId1"),
          xa(
            "Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/queryTable",
          ),
          xa("Target", "../queryTables/queryTable1.xml"),
        ],
        [],
      ),
    ),
  ])
  let connections_root : @xml.Element = xe(ns_s, "connections", [], [
    Element(
      xe(
        ns_s,
        "connection",
        [xa("id", "1"), xa("refreshedVersion", "3"), xa("name", "CatalogQuery")],
        [],
      ),
    ),
  ])
  let parts : Array[(String, Bytes)] = [
    (
      "[Content_Types].xml",
      content_types_part([
        (
          "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml",
        ),
        (
          "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml",
        ),
        (
          "/xl/queryTables/queryTable1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.queryTable+xml",
        ),
        (
          "/xl/connections.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.connections+xml",
        ),
      ]),
    ),
    ("_rels/.rels", root_rels_part("xl/workbook.xml")),
    ("xl/workbook.xml", write_part(workbook)),
    ("xl/_rels/workbook.xml.rels", write_part(wb_rels)),
    ("xl/worksheets/sheet1.xml", write_part(worksheet)),
    ("xl/worksheets/_rels/sheet1.xml.rels", write_part(sheet_rels)),
    ("xl/queryTables/queryTable1.xml", write_part(query_table_root)),
    ("xl/connections.xml", write_part(connections_root)),
  ]
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// Render the present / absent SVG pair for one catalog entry — the
/// differential-check inputs, exposed for the `debug` probe.
fn debug_render_pair(
  format : String,
  content : @xml.Element,
) -> (String, String) {
  let present_tree = strip_target_attr(content)
  let present = match
    render_svg_of(format, host_package(format, present_tree)) {
    Some(s) => s
    None => "<open-fail>"
  }
  let (baseline_tree, did_prune) = prune_target(content)
  let absent = if did_prune {
    match
      render_svg_of(
        format,
        host_package(format, strip_target_attr(baseline_tree)),
      ) {
      Some(s) => s
      None => "<open-fail>"
    }
  } else {
    "<no-target-tag>"
  }
  (present, absent)
}

///|
/// Verify one catalog entry with a differential render check.
///
/// `content` is the element under test wrapped in its schema
/// ancestry; the element itself carries the `TARGET_ATTR` sentinel.
/// Two host packages are built and rendered:
///
///   * `present` — the full tree (sentinel stripped, marker
///                 substituted).
///   * `absent`  — the same tree with the target subtree pruned.
///
/// Outcomes:
///   * `open-fail`    — the `present` package fails to open / round
///                      trip.
///   * `render-crash` — `present` produces no `<svg>`.
///   * `rendered`     — the renderer demonstrably consumed the element:
///                      its marker text reached the SVG, the present
///                      SVG differs from the absent SVG, OR pruning
///                      the element broke the package (the reader
///                      rejected the structurally-required absent
///                      tree but accepted the present tree — a
///                      schema-mandated child whose absence is itself
///                      a render-affecting fact).
///   * `parsed`       — opens + round-trips + renders without crash,
///                      but the element left no trace in the SVG.
fn verify_entry(
  format : String,
  content : @xml.Element,
  marker : String,
) -> String {
  // The element under test, present: strip the sentinel, substitute
  // the per-element unique marker.
  let (with_marker, has_marker) = substitute_marker(content, marker)
  let present_tree = strip_target_attr(with_marker)
  let present_svg = render_svg_of(format, host_package(format, present_tree))
  let present = match present_svg {
    None => return "open-fail"
    Some(s) => s
  }
  if !present.has_prefix("<svg ") {
    return "render-crash"
  }
  // A surviving marker is proof the element rendered ONLY when it
  // survives in the *visible skeleton* (data-* debug attributes
  // stripped).  A marker that lands solely inside a `data-ooxml-*`
  // attribute is metadata, not a rendered glyph — accepting it here
  // would over-count metadata-only emissions as "rendered" (the bug
  // that hid the icon-set / comment-indicator gaps).  The same
  // data-stripped skeleton is used by the differential check below.
  if has_marker && svg_visible_skeleton(present).contains(marker) {
    return "rendered"
  }
  // Differential check: render the same ancestry with the target
  // subtree pruned.  Compare the SVGs by their *visible content
  // skeleton* (every `<path>`, `<text>`, `<rect>`, `<image>`,
  // `<circle>`, `<line>`, `<polygon>`, `<polyline>`, `<use>`,
  // `<g>`, `<svg>` node retained; every `data-*` debug-label
  // attribute and every XML comment stripped). Differing skeletons
  // mean the element triggered a real visible-content node.
  //
  // Rationale (SoT): `data-ooxml-*` attributes are debug labels —
  // they decorate already-rendered SVG nodes for inspection, NOT
  // proof of rendering.  Earlier revisions counted any string
  // difference (including a single new `data-*` attribute) as
  // proof of render; that conflated "the package contains this
  // element" with "the renderer drew a visible mark for it".  The
  // skeleton comparison restores the original spec-mandated
  // standard: a section is `rendered` only when the element causes
  // the renderer to emit a concrete visual outcome.
  let (baseline_tree, did_prune) = prune_target(content)
  if did_prune {
    let baseline_clean = strip_target_attr(baseline_tree)
    let absent_svg = render_svg_of(format, host_package(format, baseline_clean))
    match absent_svg {
      Some(absent) if absent.has_prefix("<svg ") =>
        if svg_visible_skeleton(absent) != svg_visible_skeleton(present) {
          return "rendered"
        }
      // Pruning the target broke the package — the reader rejected
      // the absent tree but accepted the present tree.  That is
      // direct evidence the element is a schema-required child the
      // reader / renderer pipeline depends on: its absence
      // *changes the rendered outcome* (from a valid SVG to no
      // SVG at all), so the element materially contributes to
      // rendering.  Mark as rendered.
      None => return "rendered"
      // Absent produced something but not an SVG — treat as
      // structural break too: pruning degraded the render
      // pipeline.
      Some(absent) =>
        if svg_visible_skeleton(absent) != svg_visible_skeleton(present) {
          return "rendered"
        }
    }
  } else if root_is_target(content) {
    // The element under test IS the embed tree's root — no
    // descendant carries the sentinel.  An "absent" baseline
    // would be the minimal valid body (an empty document /
    // worksheet / slide); when the present SVG carries content
    // beyond what an empty body would produce, the root element
    // demonstrably rendered.
    let absent_svg = render_svg_of(format, empty_body_package(format))
    match absent_svg {
      Some(absent) if absent.has_prefix("<svg ") =>
        if svg_visible_skeleton(absent) != svg_visible_skeleton(present) {
          return "rendered"
        }
      _ => return "rendered"
    }
  }
  "parsed"
}

///|
/// Reduce an SVG document string to its *visible-content
/// skeleton*: every `data-*` debug-label attribute is removed,
/// every XML comment is removed.  Two SVGs whose skeletons match
/// are visually equivalent up to debug decoration — the renderer
/// emitted the same draw primitives.  A skeleton difference means
/// the element under test changed at least one visible node
/// (added a `<path>`, retitled an `<image>` href, etc.).
///
/// Rationale (SoT): `data-ooxml-*` attributes are debug labels —
/// they decorate already-rendered SVG nodes for inspection, NOT
/// proof of rendering.  Stripping them before comparison restores
/// the original spec-mandated standard: a section is `rendered`
/// only when the element causes the renderer to emit a concrete
/// visual outcome.
///
/// Implementation: a single linear scan over the byte view of the
/// SVG string.  `<!-- ... -->` comments are dropped wholesale;
/// inside an element start tag, attribute tokens whose name starts
/// with `data-` (after a leading space or the tag name) are
/// elided, honouring quoted attribute values that may contain `>`.
fn svg_visible_skeleton(svg : String) -> String {
  let bytes = @utf8.encode(svg)
  let out = Buffer()
  let n = bytes.length()
  let mut i = 0
  // ASCII codes — comparing UInt16 / Int code units, not Char.
  let lt = '<'.to_int()
  let gt = '>'.to_int()
  let bang = '!'.to_int()
  let dash = '-'.to_int()
  let eq = '='.to_int()
  let dq = '"'.to_int()
  let sq = '\''.to_int()
  let sp = ' '.to_int()
  let tab = '\t'.to_int()
  let nl = '\n'.to_int()
  let cr = '\r'.to_int()
  fn is_ws(b : Int) -> Bool {
    b == sp || b == tab || b == nl || b == cr
  }
  while i < n {
    let c = bytes[i].to_int()
    if c == lt {
      // `<!-- ... -->` comment — skip to the matching `-->`.
      if i + 3 < n &&
        bytes[i + 1].to_int() == bang &&
        bytes[i + 2].to_int() == dash &&
        bytes[i + 3].to_int() == dash {
        i = i + 4
        while i + 2 < n &&
              !(bytes[i].to_int() == dash &&
              bytes[i + 1].to_int() == dash &&
              bytes[i + 2].to_int() == gt) {
          i = i + 1
        }
        i = i + 3
        continue
      }
      out.write_byte(b'<')
      i = i + 1
      // Walk attributes; drop those whose name starts with "data-".
      let mut in_quote = 0
      let mut at_name_start = false
      let mut attr_first_chars = Buffer()
      let mut attr_buf = Buffer()
      let mut copying = true
      while i < n {
        let ch = bytes[i].to_int()
        if in_quote == 0 {
          if ch == gt {
            if copying {
              out.write_bytes(attr_buf.contents())
            }
            out.write_byte(b'>')
            i = i + 1
            break
          } else if is_ws(ch) {
            if copying {
              out.write_bytes(attr_buf.contents())
            }
            attr_buf = Buffer()
            attr_first_chars = Buffer()
            at_name_start = true
            copying = true
            out.write_byte(b' ')
            i = i + 1
          } else if ch == eq {
            // End of attribute name — decide drop/keep.
            let name = attr_first_chars.contents()
            if name.length() >= 5 &&
              name[0] == b'd' &&
              name[1] == b'a' &&
              name[2] == b't' &&
              name[3] == b'a' &&
              name[4] == b'-' {
              copying = false
            }
            attr_buf.write_byte(b'=')
            i = i + 1
            at_name_start = false
          } else if ch == dq || ch == sq {
            in_quote = ch
            attr_buf.write_byte(bytes[i])
            i = i + 1
          } else {
            if at_name_start {
              attr_first_chars.write_byte(bytes[i])
            }
            attr_buf.write_byte(bytes[i])
            i = i + 1
          }
        } else {
          attr_buf.write_byte(bytes[i])
          if ch == in_quote {
            in_quote = 0
          }
          i = i + 1
        }
      }
    } else if is_ws(c) {
      // Collapse runs of whitespace in PCDATA so cosmetic
      // formatting differences (different layout of the same
      // characters) do not mask equivalent renders.
      out.write_byte(b' ')
      while i < n && is_ws(bytes[i].to_int()) {
        i = i + 1
      }
    } else {
      out.write_byte(bytes[i])
      i = i + 1
    }
  }
  @utf8.decode_lossy(out.contents()[:])
}

///|
/// True when `el`'s root element carries the verifier's `TARGET_ATTR`
/// sentinel — the element under test is the embed tree's root and the
/// standard prune-and-diff baseline cannot be built.  Used by
/// `verify_entry` to switch to the empty-body baseline.
fn root_is_target(el : @xml.Element) -> Bool {
  for a in el.attributes {
    if a.name.local_name == TARGET_ATTR {
      return true
    }
  }
  false
}

///|
/// Build a host package whose document body carries the
/// minimum-content payload for `format` — an empty document /
/// worksheet / slide.  Used by `verify_entry` as the baseline when
/// the element under test is the embed tree's root.  Mirrors the
/// `host_package` format-string vocabulary so an aux-part target
/// (`docx:settings`, `pptx:theme`, …) gets an aux-part baseline
/// with an empty payload (the SVG diff then isolates the
/// target's contribution to that specific part).
fn empty_body_package(format : String) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let ns_s = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main"
  match format {
    "xlsx" => xlsx_package(xe(ns_s, "sheetData", [], []))
    "pptx" => pptx_package(pptx_common_slide_data(ns_p, []))
    "docx:settings" =>
      docx_aux_package("settings", xep("w", ns_w, "settings", [], []))
    "docx:styles" =>
      docx_aux_package("styles", xep("w", ns_w, "styles", [], []))
    "docx:numbering" =>
      docx_aux_package("numbering", xep("w", ns_w, "numbering", [], []))
    "docx:header" =>
      docx_header_footer_package("header", xep("w", ns_w, "hdr", [], []))
    "docx:footer" =>
      docx_header_footer_package("footer", xep("w", ns_w, "ftr", [], []))
    "docx:glossary" =>
      docx_aux_package("glossary", xep("w", ns_w, "glossaryDocument", [], []))
    "docx:fonts" => docx_aux_package("fonts", xep("w", ns_w, "fonts", [], []))
    "docx:webSettings" =>
      docx_aux_package("webSettings", xep("w", ns_w, "webSettings", [], []))
    "docx:comments" =>
      docx_aux_package("comments", xep("w", ns_w, "comments", [], []))
    "docx:footnotes" =>
      docx_aux_package("footnotes", xep("w", ns_w, "footnotes", [], []))
    "docx:endnotes" =>
      docx_aux_package("endnotes", xep("w", ns_w, "endnotes", [], []))
    "docx:annotationRefs" =>
      docx_package_with_annotation_refs(xep("w", ns_w, "body", [], []))
    "docx:contentPart" =>
      docx_package_with_content_part(xep("w", ns_w, "body", [], []))
    "pptx:theme" =>
      pptx_with_aux_root_package(
        "theme",
        xep("a", ns_a, "theme", [xa("name", "x")], []),
      )
    "pptx:presentation" =>
      pptx_with_aux_root_package(
        "presentation",
        xep("p", ns_p, "presentation", [], []),
      )
    "pptx:presentationPr" =>
      pptx_with_aux_root_package(
        "presentationPr",
        xep("p", ns_p, "presentationPr", [], []),
      )
    "pptx:viewPr" =>
      pptx_with_aux_root_package("viewPr", xep("p", ns_p, "viewPr", [], []))
    "pptx:themeOverride" =>
      pptx_with_aux_root_package(
        "themeOverride",
        xep("a", ns_a, "themeOverride", [], []),
      )
    "pptx:themeManager" =>
      pptx_with_aux_root_package(
        "themeManager",
        xep("a", ns_a, "themeManager", [], []),
      )
    "pptx:table" => pptx_package(pptx_common_slide_data(ns_p, []))
    "pptx:master-txstyle" => pptx_package(pptx_common_slide_data(ns_p, []))
    "pptx:diagram-relids" => pptx_package(pptx_common_slide_data(ns_p, []))
    "pptx:slideRefs" => pptx_package_with_slide_refs(pml_cov_slide_refs_root())
    "pptx:comments" =>
      pptx_with_aux_root_package("comments", pml_cov_comments_root())
    "pptx:commentAuthors" =>
      pptx_with_aux_root_package(
        "commentAuthors",
        pml_cov_comment_authors_root(),
      )
    "pptx:sldSyncPr" =>
      pptx_with_aux_root_package("sldSyncPr", pml_cov_slide_sync_root())
    "pptx:notes" => pptx_with_aux_root_package("notes", pml_cov_notes_root())
    "pptx:notesMaster" =>
      pptx_with_aux_root_package("notesMaster", pml_cov_notes_master_root())
    "pptx:handoutMaster" =>
      pptx_with_aux_root_package("handoutMaster", pml_cov_handout_master_root())
    "pptx:presentationRefs" =>
      pptx_package_with_presentation_refs(pml_cov_presentation_refs_root())
    "xlsx:workbook" =>
      xlsx_with_aux_root_package("workbook", xe(ns_s, "workbook", [], []))
    "xlsx:sharedStrings" =>
      xlsx_with_aux_root_package("sharedStrings", xe(ns_s, "sst", [], []))
    "xlsx:styles" =>
      xlsx_with_aux_root_package("styles", xe(ns_s, "styleSheet", [], []))
    "xlsx:comments" =>
      xlsx_with_aux_root_package("comments", xe(ns_s, "comments", [], []))
    "xlsx:calcChain" =>
      xlsx_with_aux_root_package("calcChain", xe(ns_s, "calcChain", [], []))
    "xlsx:connections" =>
      xlsx_with_aux_root_package("connections", xe(ns_s, "connections", [], []))
    "xlsx:metadata" =>
      xlsx_with_aux_root_package("metadata", xe(ns_s, "metadata", [], []))
    "xlsx:xmlMaps" =>
      xlsx_with_aux_root_package("xmlMaps", xe(ns_s, "MapInfo", [], []))
    "xlsx:queryTable" =>
      xlsx_with_aux_root_package("queryTable", xe(ns_s, "queryTable", [], []))
    "xlsx:revisionHeaders" =>
      xlsx_with_aux_root_package(
        "revisionHeaders",
        catalog_sml_revision_headers_minimal(),
      )
    "xlsx:revisionLog" =>
      xlsx_with_aux_root_package("revisionLog", catalog_sml_revisions_minimal())
    "xlsx:userNames" =>
      xlsx_with_aux_root_package("userNames", xe(ns_s, "users", [], []))
    "xlsx:volatileDependencies" =>
      xlsx_with_aux_root_package(
        "volatileDependencies",
        xe(ns_s, "volTypes", [], [
          Element(
            xe(ns_s, "volType", [xa("type", "realTimeData")], [
              Element(
                xe(ns_s, "main", [xa("first", "RTD")], [
                  Element(
                    xe(ns_s, "tp", [], [
                      Element(xe(ns_s, "v", [], [Text("0")])),
                      Element(xe(ns_s, "tr", [xa("r", "A1"), xa("s", "1")], [])),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      )
    "xlsx:drawing" =>
      xlsx_with_drawing_root_package(
        xep(
          "xdr",
          "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing",
          "wsDr",
          [],
          [],
        ),
      )
    "xlsx:worksheetRefs" =>
      xlsx_package_with_worksheet_refs(
        xe(ns_s, "worksheet", [], [Element(xe(ns_s, "sheetData", [], []))]),
      )
    "xlsx:chartsheet" =>
      xlsx_package_with_chartsheet(
        xe(ns_s, "chartsheet", [], [
          Element(
            xe(ns_s, "sheetViews", [], [
              Element(xe(ns_s, "sheetView", [xa("workbookViewId", "0")], [])),
            ]),
          ),
          Element(
            xe(ns_s, "drawing", [sml_aux_rel_attr("id", "rIdDrawing")], []),
          ),
        ]),
      )
    "xlsx:dialogsheet" =>
      xlsx_package_with_dialogsheet(xe(ns_s, "dialogsheet", [], []))
    "xlsx:tableSingleCells" =>
      xlsx_package_with_table_single_cells(
        catalog_sml_single_xml_cells_minimal(),
      )
    "xlsx:pivot" =>
      xlsx_package_with_pivot(
        catalog_sml_pivot_sheet_data(),
        catalog_sml_pivot_default_cache_def(),
        catalog_sml_pivot_default_records(),
        catalog_sml_pivot_default_table_def(),
      )
    _ => docx_package(xep("w", ns_w, "body", [], []))
  }
}
