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
/// when the consumer (e.g. LibreOffice's PPTX parser) only accepts
/// the prefix form of the element name — the DrawingML `<a:theme>`
/// payload triggers exactly this requirement: emitting `<theme>`
/// with an `xmlns="...drawingml..."` default namespace declaration
/// validates as XML, but Impress' OOXML import refuses to populate
/// the colour scheme from it.  Switching to `<a:theme>` /
/// `<a:clrScheme>` / `<a:accent1>` etc. lets LibreOffice resolve
/// `<a:schemeClr val="accent1"/>` against the theme.
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
/// Serialise an element as a standalone XML document to UTF-8 bytes.
fn write_part(root : @xml.Element) -> Bytes {
  @xml.write({ declaration: None, doctype: None, root })
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
/// Assemble a `.docx` package whose `<w:document>` directly contains
/// `body` — the element under test wrapped in its ancestry from
/// `<w:body>` down.
///
/// Namespace declarations are NOT written as explicit `xmlns:*`
/// attributes: every element / attribute QName in the tree carries
/// its namespace URI, and `@xml.write` emits each `xmlns` declaration
/// once, at the element that first uses the prefix.  Adding explicit
/// `xmlns:*` attributes on top would emit each declaration twice — a
/// malformed document LibreOffice and conformant readers reject.
fn docx_package(body : @xml.Element) -> Bytes {
  let ns_w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  let document : @xml.Element = {
    name: { prefix: Some("w"), local_name: "document", ns: Some(ns_w) },
    attributes: [],
    children: [Element(body)],
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
  (try? @zip.write(@zip.Archive::new(parts))).unwrap_or(Bytes::new(0))
}

///|
/// `.xlsx` package whose `<worksheet>` carries a `<pivotTables>`-style
/// relationship pointing at a pivot table part, fully wired into the
/// workbook's `<pivotCaches>`, the per-part `_rels` for the worksheet
/// + the pivot table + the pivot cache definition, and the three new
/// `[Content_Types]` overrides (pivotTable, pivotCacheDefinition,
/// pivotCacheRecords).  Mirrors §18.10 PivotTable plumbing as
/// produced by Excel.
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
  let worksheet : @xml.Element = if content.name.local_name == "worksheet" {
    content
  } else {
    {
      name: { prefix: None, local_name: "worksheet", ns: Some(ns_s) },
      attributes: [],
      children: [Element(content)],
    }
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
  // `[MS-XLSX]` §2.2.4 — every sparkline-bearing `<ext>` carries
  // the GUID literal `{05C60535-1F16-4FD2-B633-F4F36F0B64E0}` on
  // `@uri`. Documented in `sparkline/domain.mbt::sparkline_ext_uri`.
  let sparkline_uri = "{05C60535-1F16-4FD2-B633-F4F36F0B64E0}"
  // Build `<ext uri="…">…</ext>` carrying the sparkline groups.
  let ext_elt : @xml.Element = xe(ns_s, "ext", [xa("uri", sparkline_uri)], [
    Element(sparkline_groups),
  ])
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
/// DrawingML namespace URI — used by `pptx_theme_part` and any other
/// PML helper that needs to embed `<a:*>` payload (clrScheme,
/// fontScheme, fmtScheme).
const NS_A_THEME : String = "http://schemas.openxmlformats.org/drawingml/2006/main"

///|
/// Build the canonical "Office" `theme1.xml` part for a fixture
/// package.  The palette mirrors the renderer's
/// `default_office_scheme()` table so a `<a:schemeClr val="accent3"/>`
/// resolves to the same colour whether the reference (LibreOffice)
/// or our renderer is asked.  Without this part LibreOffice has no
/// `<a:clrScheme>` to consult and falls back to its built-in "all
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
  // parses as valid XML but LibreOffice's OOXML importer rejects it
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
  // The minimum: a major and minor latin face.  Liberation Sans is
  // the harness substitute for Calibri so the typeface still
  // round-trips through the snapshot's fontconfig overlay.
  fn font_face(local : String, typeface : String) -> @xml.Element {
    ae(local, [xa("typeface", typeface)], [])
  }

  let font_scheme = ae("fontScheme", [xa("name", "Office")], [
    Element(ae("majorFont", [], [Element(font_face("latin", "Calibri Light"))])),
    Element(ae("minorFont", [], [Element(font_face("latin", "Calibri"))])),
  ])

  // ---- <a:fmtScheme> — phClr-driven payload mirroring Office ----
  // The format scheme MUST resolve to non-empty fills when a chart
  // series, a SmartArt shape or any `<a:fillRef idx="…"/>` consumer
  // looks it up. LibreOffice's chart renderer derives each series'
  // fill by looking up `fillStyleLst[idx]` (idx ≥ 1000 → subtract
  // 1000) and substituting the colour scheme's accentN palette for
  // every `<a:schemeClr val="phClr"/>` placeholder; if every entry
  // is a flat `srgbClr` (no `phClr`) LO sees the override as
  // "white on white" and emits a transparent chart. The minimal
  // §20.1.4.1.14 CT_StyleMatrix that LO accepts therefore needs
  // three styled fill entries, three styled line entries, three
  // styled effect entries, and three bgFill entries — each carrying
  // a `<a:schemeClr val="phClr"/>` for LO to colour-substitute.
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
/// Build a `theme1.xml` companion `<p:slideMaster>` part.  The master
/// declares the colour map (`<p:clrMap>`) that maps abstract slots
/// (`bg1`/`tx1`/…) onto the concrete `<a:clrScheme>` entries the
/// theme provides.  A spec-valid master also needs `<p:cSld>` (with
/// an empty shape tree) and `<p:txStyles>` placeholders; we keep
/// every section to the smallest payload that PowerPoint /
/// LibreOffice will load without warning.
fn pptx_slide_master_part() -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // All `<p:*>` payload must carry the `p:` prefix for LibreOffice's
  // PPTX importer to populate the colour map and the layout list —
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
  // §19.3.1.42 CT_SlideMaster — `<p:cSld>` is required and must
  // contain `<p:spTree>` with the boilerplate `<p:nvGrpSpPr>` /
  // `<p:grpSpPr>`.  We skip placeholder shapes entirely so a master
  // never injects content on top of the fixture's slide.
  let empty_sp_tree = pe("spTree", [], [
    Element(
      pe("nvGrpSpPr", [], [
        Element(pe("cNvPr", [xa("id", "1"), xa("name", "")], [])),
        Element(pe("cNvGrpSpPr", [], [])),
        Element(pe("nvPr", [], [])),
      ]),
    ),
    Element(pe("grpSpPr", [], [])),
  ])
  let cSld = pe("cSld", [], [Element(empty_sp_tree)])
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
  let master = pe("sldMaster", [], [
    Element(cSld),
    Element(clr_map),
    Element(sl_id_lst),
  ])
  write_part(master)
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

  let empty_sp_tree = pe("spTree", [], [
    Element(
      pe("nvGrpSpPr", [], [
        Element(pe("cNvPr", [xa("id", "1"), xa("name", "")], [])),
        Element(pe("cNvGrpSpPr", [], [])),
        Element(pe("nvPr", [], [])),
      ]),
    ),
    Element(pe("grpSpPr", [], [])),
  ])
  let cSld = pe("cSld", [], [Element(empty_sp_tree)])
  let layout = pe("sldLayout", [xa("type", "title"), xa("preserve", "1")], [
    Element(cSld),
  ])
  write_part(layout)
}

///|
/// Assemble a `.pptx` package whose `<p:sld>` directly contains
/// `content`.  Ships a canonical Office-palette theme part plus a
/// minimal slideMaster / slideLayout chain so consumers
/// (LibreOffice, PowerPoint, our own viewer) can resolve
/// `<a:schemeClr val="accent1"/>` to the documented hue.  Omitting
/// these auxiliary parts is technically valid OPC, but LibreOffice
/// degrades to "every scheme colour renders as black", which
/// collapses the `color-scheme-*` fixture set into one indistinct
/// swatch.
fn pptx_package(content : @xml.Element) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  // `xmlns:p` / `xmlns:r` are auto-declared by the writer from the
  // QName URIs — no explicit `xmlns:*` attributes (see docx_package).
  let presentation : @xml.Element = {
    name: { prefix: Some("p"), local_name: "presentation", ns: Some(ns_p) },
    attributes: [],
    children: [
      Element(
        xe(ns_p, "sldMasterIdLst", [], [
          Element(
            xe(
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
        xe(ns_p, "sldIdLst", [], [
          Element(
            xe(
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
      Element(xe(ns_p, "sldSz", [xa("cx", "9144000"), xa("cy", "6858000")], [])),
    ],
  }
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
/// "minimum chart-bearing PPTX" layout — the renderer presently
/// falls back to a `[Chart]` placeholder rect, so this builder
/// is the OPC-coverage side of the chart story until the typed
/// chart renderer lands. §21.2 chart rendering TODO: route
/// `<a:graphicData uri="…/chart">` through the chart package's
/// reader and emit `<g class="chart">` from the
/// `<c:plotArea>` payload.
fn pptx_package_with_chart(
  content : @xml.Element,
  chart_space : @xml.Element,
) -> Bytes {
  let ns_p = "http://schemas.openxmlformats.org/presentationml/2006/main"
  let ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  let presentation : @xml.Element = {
    name: { prefix: Some("p"), local_name: "presentation", ns: Some(ns_p) },
    attributes: [],
    children: [
      Element(
        xe(ns_p, "sldMasterIdLst", [], [
          Element(
            xe(
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
        xe(ns_p, "sldIdLst", [], [
          Element(
            xe(
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
      Element(xe(ns_p, "sldSz", [xa("cx", "9144000"), xa("cy", "6858000")], [])),
    ],
  }
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
/// The renderer presently falls back to a `[Diagram]` placeholder
/// rect; this builder is the OPC-coverage side of the SmartArt
/// story until the `diagram_layout` engine wires its output back
/// into the graphicFrame renderer.  §21.4 diagram rendering TODO:
/// route `<a:graphicData uri="…/diagram">` through
/// `diagram_layout::engine` and emit one `<g class="diagram">`
/// per laid-out shape.
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
  // PowerPoint and LibreOffice both honour this extension to skip
  // re-running the layout engine.
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
  let presentation : @xml.Element = {
    name: { prefix: Some("p"), local_name: "presentation", ns: Some(ns_p) },
    attributes: [],
    children: [
      Element(
        xe(ns_p, "sldMasterIdLst", [], [
          Element(
            xe(
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
        xe(ns_p, "sldIdLst", [], [
          Element(
            xe(
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
      Element(xe(ns_p, "sldSz", [xa("cx", "9144000"), xa("cy", "6858000")], [])),
    ],
  }
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
          xa("Id", "rId2"),
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
          xa("Id", "rId3"),
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
          xa("Id", "rId4"),
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
          xa("Id", "rId5"),
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
  // `diagramDrawing` relationship type. PowerPoint and LibreOffice
  // pick up the drawing through this rels chain.
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
  match which {
    "xlsx" =>
      match (try? @sml_context.open(pkg)) {
        Err(_) => None
        Ok(w) =>
          match (try? @sml_context.open(w.save())) {
            Err(_) => None
            Ok(w2) => Some(w2.to_svg())
          }
      }
    "pptx" =>
      match (try? @pml_context.open(pkg)) {
        Err(_) => None
        Ok(pr) =>
          match (try? @pml_context.open(pr.save())) {
            Err(_) => None
            Ok(pr2) => Some(pr2.to_svg())
          }
      }
    _ =>
      match (try? @wml_context.open(pkg)) {
        Err(_) => None
        Ok(d) =>
          match (try? @wml_context.open(d.save())) {
            Err(_) => None
            Ok(d2) => Some(d2.to_svg())
          }
      }
  }
}

///|
/// Build the host package for `which` around `content`.
fn host_package(which : String, content : @xml.Element) -> Bytes {
  match which {
    "xlsx" => xlsx_package(content)
    "pptx" => pptx_package(content)
    _ => docx_package(content)
  }
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
///                      either its marker text reached the SVG, or the
///                      `present` SVG differs from the `absent` SVG.
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
  // A surviving marker is unambiguous proof the element rendered.
  if has_marker && present.contains(marker) {
    return "rendered"
  }
  // Differential check: render the same ancestry with the target
  // subtree pruned.  A difference in the SVG is direct evidence the
  // renderer reacted to the element's presence.
  let (baseline_tree, did_prune) = prune_target(content)
  if did_prune {
    let baseline_clean = strip_target_attr(baseline_tree)
    match render_svg_of(format, host_package(format, baseline_clean)) {
      Some(absent) if absent.has_prefix("<svg ") =>
        if absent != present {
          return "rendered"
        }
      // A baseline that fails to open/render cannot disprove a
      // render — fall through to `parsed` rather than over-claiming.
      _ => ()
    }
  }
  "parsed"
}
