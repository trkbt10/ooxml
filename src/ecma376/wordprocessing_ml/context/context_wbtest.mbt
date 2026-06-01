///|
fn fixture_bytes() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"urn:w\"><w:body><w:p><w:r><w:t>Hello docx</w:t></w:r></w:p></w:body></w:document>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
fn fixture_bytes_with_settings(settings_xml : String) -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/><Override PartName=\"/word/settings.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"urn:w\"><w:body><w:p><w:r><w:t>Hello docx</w:t></w:r></w:p></w:body></w:document>",
      ),
    ),
    ("word/settings.xml", bytes(settings_xml)),
  ])
  try! @zip.write(archive)
}

///|
test "wordprocessing_ml context opens and saves minimal package" {
  let document = open(fixture_bytes())
  assert_eq(document.main_part, "/word/document.xml")
  let reopened = open(document.save())
  assert_eq(reopened.main.element.name.local_name, "document")
}

///|
test "wordprocessing_ml context rejects invalid settings ST_OnOff values" {
  try
    open(
      fixture_bytes_with_settings(
        "<w:settings xmlns:w=\"urn:w\"><w:trackRevisions w:val=\"yes\"/></w:settings>",
      ),
    )
  catch {
    OpenError(kind~, path~, reason~) => {
      assert_eq(kind, "SchemaViolation")
      assert_eq(path, "ST_OnOff")
      assert_true(reason.contains("yes"))
    }
  } noraise {
    _ => abort("expected OpenError")
  }
}

///|
test "wordprocessing_ml save_or_raise reports invalid package" {
  let document = open(fixture_bytes())
  let broken_parts : Array[@opc.PackagePart] = []
  for part in document.opc_package.parts {
    if part.name == document.main_part {
      broken_parts.push({ ..part, name: "word/document.xml" })
    } else {
      broken_parts.push(part)
    }
  }
  let broken = {
    ..document,
    opc_package: { ..document.opc_package, parts: broken_parts },
  }
  try broken.save_or_raise() catch {
    SaveError(kind~, path~, reason~) => {
      assert_eq(kind, "PackageSaveFailed")
      assert_eq(path, "/word/document.xml")
      assert_true(reason.length() > 0)
    }
  } noraise {
    _ => abort("expected SaveError")
  }
}

///|
/// `Document::to_svg` returns a clean SVG by default: every
/// `data-ooxml-*` decoration is stripped on the way out so
/// production consumers see only paint primitives.  Passing
/// `debug_attrs=true` opts in to the inspection labels — the
/// catalog harness's differential render verifier relies on
/// exactly this flag.  Both modes always carry the document's
/// visible content (`Hello docx`).
test "wordprocessing_ml context renders minimal svg" {
  let document = open(fixture_bytes())
  let svg_clean = document.to_svg_for_test()
  // Default `debug_attrs=false`: no `data-ooxml-*` decoration
  // survives, but the rendered text remains.
  assert_false(svg_clean.contains("data-ooxml=\"wml\""))
  assert_true(svg_clean.contains("Hello docx"))
  // Opt-in path: `debug_attrs=true` surfaces every label the
  // viewer emits, matching the harness's view of the document.
  let svg_debug = document.to_svg_for_test(debug_attrs=true)
  assert_true(svg_debug.contains("data-ooxml=\"wml\""))
  assert_true(svg_debug.contains("Hello docx"))
}

///|
test "wordprocessing_ml context appends paragraph and round-trips" {
  let document = open(fixture_bytes())
  let with_para = try? @wml_edit.append_paragraph(document, "appended line")
  match with_para {
    Ok(modified) => {
      let saved = modified.save()
      let reopened = open(saved)
      assert_true(reopened.to_svg_for_test().contains("appended line"))
      // original 'Hello docx' still present
      assert_true(reopened.to_svg_for_test().contains("Hello docx"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "wordprocessing_ml context set_paragraph_text rewrites the run text" {
  let document = open(fixture_bytes())
  let modified = try? @wml_edit.set_paragraph_text(document, 0, "rewritten")
  match modified {
    Ok(d) => {
      let svg = open(d.save()).to_svg_for_test()
      assert_true(svg.contains("rewritten"))
      assert_true(!svg.contains("Hello docx"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "wordprocessing_ml context set_paragraph_alignment writes jc and round-trips" {
  let document = open(fixture_bytes())
  let modified = try? @wml_edit.set_paragraph_alignment(document, 0, "center")
  match modified {
    Ok(d) => {
      let reopened = open(d.save())
      // verify by querying the typed projection
      match reopened.main.body {
        Some(body) => {
          let p = body.block_level_elts[0].source_element()
          let p_pr = first_child(p, "pPr")
          assert_true(p_pr is Some(_))
          let jc = match p_pr {
            Some(pr) => first_child(pr, "jc")
            None => None
          }
          assert_true(jc is Some(_))
        }
        None => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
fn first_child(parent : @xml.Element, name : String) -> @xml.Element? {
  for child in parent.children {
    match child {
      @xml.Element(e) => if e.name.local_name == name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
test "wordprocessing_ml context insert_paragraph_at inserts at position 0" {
  let document = open(fixture_bytes())
  let modified = try? @wml_edit.insert_paragraph_at(document, 0, "first-line")
  match modified {
    Ok(d) => {
      let svg = open(d.save()).to_svg_for_test()
      assert_true(svg.contains("first-line"))
      assert_true(svg.contains("Hello docx"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "wordprocessing_ml context remove_paragraph drops a body child and round-trips" {
  let document = open(fixture_bytes())
  // Fixture has exactly one paragraph; append one then remove the
  // appended one, expect to end up back at the original count.
  let appended = try? @wml_edit.append_paragraph(document, "temporary")
  match appended {
    Ok(d1) => {
      let before_count = match d1.main.body {
        Some(b) => b.block_level_elts.length()
        None => 0
      }
      let removed = try? @wml_edit.remove_paragraph(d1, before_count - 1)
      match removed {
        Ok(d2) => {
          let after_count = match d2.main.body {
            Some(b) => b.block_level_elts.length()
            None => 0
          }
          assert_eq(after_count, before_count - 1)
          let reopened = open(d2.save())
          assert_true(!reopened.to_svg_for_test().contains("temporary"))
        }
        Err(_) => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
test "wordprocessing_ml context embedded_font_parts returns array (possibly empty)" {
  let document = open(fixture_bytes())
  let fonts = document.embedded_font_parts()
  // Fixture has no /word/fonts/ parts; just confirm the API works.
  assert_eq(fonts.length(), 0)
  // open_embedded_font on a non-existent part returns None.
  let missing = document.open_embedded_font("/word/fonts/font_missing.ttf")
  assert_true(missing is None)
}

///|
test "wordprocessing_ml context preserves text across two save cycles" {
  let initial = open(fixture_bytes())
  let cycle1_bytes = initial.save()
  let cycle1 = open(cycle1_bytes)
  let cycle2_bytes = cycle1.save()
  let cycle2 = open(cycle2_bytes)
  assert_true(cycle1.to_svg_for_test().contains("Hello docx"))
  assert_true(cycle2.to_svg_for_test().contains("Hello docx"))
  assert_eq(
    initial.main.element.name.local_name,
    cycle2.main.element.name.local_name,
  )
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
/// Build a docx fixture that declares a `headerReference type="default"`
/// pointing at `/word/header1.xml`, plus a footer reference.
fn fixture_with_header_footer() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/header1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml\"/>" +
        "<Override PartName=\"/word/footer1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdH1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/header\" Target=\"header1.xml\"/>" +
        "<Relationship Id=\"rIdF1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer\" Target=\"footer1.xml\"/>" +
        "</Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">" +
        "<w:body>" +
        "<w:p><w:r><w:t>Body content</w:t></w:r></w:p>" +
        "<w:sectPr>" +
        "<w:headerReference w:type=\"default\" r:id=\"rIdH1\"/>" +
        "<w:footerReference w:type=\"default\" r:id=\"rIdF1\"/>" +
        "</w:sectPr>" +
        "</w:body></w:document>",
      ),
    ),
    (
      "word/header1.xml",
      bytes(
        "<w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">" +
        "<w:p><w:r><w:t>HEADER-TOKEN</w:t></w:r></w:p>" +
        "</w:hdr>",
      ),
    ),
    (
      "word/footer1.xml",
      bytes(
        "<w:ftr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">" +
        "<w:p><w:r><w:t>FOOTER-TOKEN</w:t></w:r></w:p>" +
        "</w:ftr>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
test "wml context to_svg includes default header/footer text" {
  let document = open(fixture_with_header_footer())
  let svg = document.to_svg_for_test()
  assert_true(svg.contains("Body content"))
  assert_true(svg.contains("HEADER-TOKEN"))
  assert_true(svg.contains("FOOTER-TOKEN"))
}

///|
test "wml context to_svg without header/footer still emits body" {
  let document = open(fixture_bytes())
  let svg = document.to_svg_for_test()
  assert_true(svg.contains("Hello docx"))
  assert_false(svg.contains("HEADER-TOKEN"))
}

///|
/// §17.10 / OPC §9.3.1 — PART-AWARE image resolution.  A header is a
/// SEPARATE OPC part with its OWN `_rels`, so an inline image's blip
/// `r:embed` inside the header MUST resolve against
/// `/word/_rels/header1.xml.rels`, NOT the main document part's rels.
///
/// This fixture is the discriminating case for the bug: BOTH
/// `document.xml.rels` and `header1.xml.rels` define the SAME
/// relationship Id (`rIdImg`), but point at DIFFERENT media — the body
/// part maps it to a BODY png and the header part maps it to a HEADER
/// png with distinct bytes.  The body paragraph and the header each
/// embed an inline drawing referencing `rIdImg`.  The pre-fix renderer
/// resolved BOTH against the document part's rels, so the header would
/// have shown the BODY image.  With part-aware resolution the header
/// image's data URI is the HEADER png and the body image's is the BODY
/// png.
let body_png : Bytes = b"\x89PNG\r\n\x1a\n\x00\x42\x4f\x44\x59"

///|
let header_png : Bytes = b"\x89PNG\r\n\x1a\n\x00\x48\x44\x52"

///|
fn inline_drawing_xml(rid : String) -> String {
  // §20.4.2.8 — `<wp:docPr>` is required inside `<wp:inline>`; the
  // reader rejects a drawing without it.
  "<w:drawing>" +
  "<wp:inline>" +
  "<wp:extent cx=\"914400\" cy=\"914400\"/>" +
  "<wp:docPr id=\"1\" name=\"Picture\"/>" +
  "<a:graphic><a:graphicData><pic:pic><pic:blipFill>" +
  "<a:blip r:embed=\"" +
  rid +
  "\"/>" +
  "</pic:blipFill></pic:pic></a:graphicData></a:graphic>" +
  "</wp:inline>" +
  "</w:drawing>"
}

///|
fn fixture_with_conflicting_image_rids() -> Bytes {
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"" +
    " xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"" +
    " xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\""
  let document_xml = "<w:document" +
    ns +
    ">" +
    "<w:body>" +
    "<w:p><w:r>" +
    inline_drawing_xml("rIdImg") +
    "</w:r></w:p>" +
    "<w:sectPr>" +
    "<w:headerReference w:type=\"default\" r:id=\"rIdH1\"/>" +
    "</w:sectPr>" +
    "</w:body></w:document>"
  let header_xml = "<w:hdr" +
    ns +
    ">" +
    "<w:p><w:r>" +
    inline_drawing_xml("rIdImg") +
    "</w:r></w:p>" +
    "</w:hdr>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Default Extension=\"png\" ContentType=\"image/png\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/header1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    // Body part rels: `rIdImg` → the BODY image; plus the header part.
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdH1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/header\" Target=\"header1.xml\"/>" +
        "<Relationship Id=\"rIdImg\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/body.png\"/>" +
        "</Relationships>",
      ),
    ),
    // §17.10 / OPC §9.3.1 — header part rels: the SAME `rIdImg` maps to
    // a DIFFERENT image than the body part's `rIdImg`.
    (
      "word/_rels/header1.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdImg\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/header.png\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
    ("word/header1.xml", bytes(header_xml)),
    ("word/media/body.png", body_png),
    ("word/media/header.png", header_png),
  ])
  try! @zip.write(archive)
}

///|
/// §17.10 / OPC §9.3.1 — the header inline image resolves against the
/// HEADER part's rels, not the document's.  The bug would render the
/// document part's `rIdImg` (the BODY png) inside the header.
test "wml context resolves a header inline image against the header part rels" {
  let document = open(fixture_with_conflicting_image_rids())
  let svg = document.to_svg_for_test()
  let body_href = "data:image/png;base64," + @base64.encode(body_png)
  let header_href = "data:image/png;base64," + @base64.encode(header_png)
  // The body image resolves against the BODY part's rels.
  assert_true(svg.contains("href=\"" + body_href + "\""))
  // The header image resolves against the HEADER part's rels — the fix.
  // (The bug would have rendered `body_href` here too, never `header_href`.)
  assert_true(svg.contains("href=\"" + header_href + "\""))
}

///|
/// §17 — body-image byte-identity.  A package whose body embeds an
/// inline image resolves that blip against the main document part's
/// rels.  This asserts the exact data URI the part-aware resolver
/// emits (`image_resolver(main_part, rid)`) matches the verbatim
/// base64 of the media bytes — the same payload the previous
/// document-scoped resolver produced.
test "wml context body inline image resolves to the document part media (byte-identical)" {
  let png : Bytes = b"\x89PNG\r\n\x1a\n\x00\x42\x49\x54"
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"" +
    " xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"" +
    " xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\""
  let document_xml = "<w:document" +
    ns +
    "><w:body><w:p><w:r>" +
    inline_drawing_xml("rIdImg") +
    "</w:r></w:p></w:body></w:document>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Default Extension=\"png\" ContentType=\"image/png\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdImg\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/pic.png\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
    ("word/media/pic.png", png),
  ])
  let document = open(try! @zip.write(archive))
  let svg = document.to_svg_for_test()
  let expected_href = "data:image/png;base64," + @base64.encode(png)
  assert_true(svg.contains("href=\"" + expected_href + "\""))
}

///|
/// §21.2 — build a `<w:drawing>` carrying an inline DrawingML chart
/// graphicFrame that references chart part `rid` via `<c:chart r:id>`.
/// The `<a:graphicData uri>` is the §15.2 well-known chart URI so the
/// WML inline-chart bridge (`drawing_chart_frame`) recognises it; the
/// `<wp:extent>` gives the frame a non-degenerate pixel size so the
/// chart renderer actually paints.
fn inline_chart_drawing_xml(rid : String) -> String {
  "<w:drawing>" +
  "<wp:inline>" +
  "<wp:extent cx=\"5486400\" cy=\"4114800\"/>" +
  "<wp:docPr id=\"2\" name=\"Chart\"/>" +
  "<a:graphic>" +
  "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/chart\">" +
  "<c:chart r:id=\"" +
  rid +
  "\"/>" +
  "</a:graphicData>" +
  "</a:graphic>" +
  "</wp:inline>" +
  "</w:drawing>"
}

///|
/// §21.2.2.29 — a minimal `<c:chartSpace>` carrying a single-series
/// `<c:barChart>` and a `<c:title>/<c:tx>/<c:rich>` whose visible text
/// is `title`.  The chart renderer emits the title as a `<text>` node,
/// so two charts with distinct titles produce distinguishable SVG.
fn chart_part_xml(title : String) -> String {
  let c_ns = " xmlns:c=\"http://schemas.openxmlformats.org/drawingml/2006/chart\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\""
  "<c:chartSpace" +
  c_ns +
  ">" +
  "<c:chart>" +
  "<c:title><c:tx><c:rich>" +
  "<a:bodyPr/><a:lstStyle/>" +
  "<a:p><a:r><a:t>" +
  title +
  "</a:t></a:r></a:p>" +
  "</c:rich></c:tx><c:overlay val=\"0\"/></c:title>" +
  "<c:plotArea>" +
  "<c:barChart>" +
  "<c:barDir val=\"col\"/>" +
  "<c:grouping val=\"clustered\"/>" +
  "<c:ser>" +
  "<c:idx val=\"0\"/><c:order val=\"0\"/>" +
  "<c:val><c:numRef><c:numCache>" +
  "<c:pt idx=\"0\"><c:v>10</c:v></c:pt>" +
  "<c:pt idx=\"1\"><c:v>20</c:v></c:pt>" +
  "</c:numCache></c:numRef></c:val>" +
  "</c:ser>" +
  "<c:axId val=\"111\"/><c:axId val=\"222\"/>" +
  "</c:barChart>" +
  "</c:plotArea>" +
  "</c:chart>" +
  "</c:chartSpace>"
}

///|
/// §21.2 / OPC §9.3.1 — a package where `/word/_rels/document.xml.rels`
/// and `/word/_rels/header1.xml.rels` BOTH define the SAME chart rId
/// (`rIdChart`) but point it at DIFFERENT chart parts: the body's
/// `rIdChart` → a chart titled "BODY CHART", the header's `rIdChart` →
/// a chart titled "HEADER CHART".  The body paragraph and the header
/// each embed an inline chart drawing referencing `rIdChart`.  The
/// pre-fix renderer resolved BOTH against the document part's rels, so
/// the header would have shown the BODY chart.
fn fixture_with_conflicting_chart_rids() -> Bytes {
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"" +
    " xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"" +
    " xmlns:c=\"http://schemas.openxmlformats.org/drawingml/2006/chart\""
  let document_xml = "<w:document" +
    ns +
    ">" +
    "<w:body>" +
    "<w:p><w:r>" +
    inline_chart_drawing_xml("rIdChart") +
    "</w:r></w:p>" +
    "<w:sectPr>" +
    "<w:headerReference w:type=\"default\" r:id=\"rIdH1\"/>" +
    "</w:sectPr>" +
    "</w:body></w:document>"
  let header_xml = "<w:hdr" +
    ns +
    ">" +
    "<w:p><w:r>" +
    inline_chart_drawing_xml("rIdChart") +
    "</w:r></w:p>" +
    "</w:hdr>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/header1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml\"/>" +
        "<Override PartName=\"/word/charts/chart1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.drawingml.chart+xml\"/>" +
        "<Override PartName=\"/word/charts/chart2.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.drawingml.chart+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    // Body part rels: `rIdChart` → the BODY chart; plus the header part.
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdH1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/header\" Target=\"header1.xml\"/>" +
        "<Relationship Id=\"rIdChart\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart\" Target=\"charts/chart1.xml\"/>" +
        "</Relationships>",
      ),
    ),
    // §17.10 / OPC §9.3.1 — header part rels: the SAME `rIdChart` maps to
    // a DIFFERENT chart than the body part's `rIdChart`.
    (
      "word/_rels/header1.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdChart\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart\" Target=\"charts/chart2.xml\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
    ("word/header1.xml", bytes(header_xml)),
    ("word/charts/chart1.xml", bytes(chart_part_xml("BODY CHART"))),
    ("word/charts/chart2.xml", bytes(chart_part_xml("HEADER CHART"))),
  ])
  try! @zip.write(archive)
}

///|
/// §21.2 / OPC §9.3.1 — the header inline chart resolves its `<c:chart
/// r:id>` against the HEADER part's rels, not the document's.  The bug
/// would render the document part's `rIdChart` (the BODY chart) inside
/// the header.  Body-chart byte-identity is asserted by the SAME run:
/// the body chart still resolves against the main document part's rels
/// (`chart_part_resolver(main_part, rid)`), producing the BODY chart —
/// exactly what the old document-scoped resolver produced.
test "wml context resolves a header inline chart against the header part rels" {
  let document = open(fixture_with_conflicting_chart_rids())
  let svg = document.to_svg_for_test()
  // The body chart resolves against the BODY part's rels (byte-identity
  // sense: the body still renders the document-part chart).
  assert_true(svg.contains("BODY CHART"))
  // The header chart resolves against the HEADER part's rels — the fix.
  // (The bug would have rendered "BODY CHART" here too, never "HEADER
  // CHART", because the header's rId was wrongly resolved against the
  // document part.)
  assert_true(svg.contains("HEADER CHART"))
}

///|
/// §17.4 / §21.2 / OPC §9.3.1 — a chart inside a table cell is still a
/// paragraph run drawing, so it must use the same document-part
/// chart resolver as a body paragraph chart.
test "wml context resolves an inline chart inside a table cell" {
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"" +
    " xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"" +
    " xmlns:c=\"http://schemas.openxmlformats.org/drawingml/2006/chart\""
  let document_xml = "<w:document" +
    ns +
    ">" +
    "<w:body>" +
    "<w:tbl>" +
    "<w:tblPr><w:tblW w:w=\"7000\" w:type=\"dxa\"/></w:tblPr>" +
    "<w:tblGrid><w:gridCol w:w=\"7000\"/></w:tblGrid>" +
    "<w:tr><w:tc>" +
    "<w:tcPr><w:tcW w:w=\"7000\" w:type=\"dxa\"/></w:tcPr>" +
    "<w:p><w:r>" +
    inline_chart_drawing_xml("rIdChart") +
    "</w:r></w:p>" +
    "</w:tc></w:tr>" +
    "</w:tbl>" +
    "</w:body></w:document>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/charts/chart1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.drawingml.chart+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdChart\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart\" Target=\"charts/chart1.xml\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
    ("word/charts/chart1.xml", bytes(chart_part_xml("TABLE CELL CHART"))),
  ])
  let document = try open(try! @zip.write(archive)) catch {
    OpenError(kind~, path~, reason~) => abort(kind + " " + path + " " + reason)
  } noraise {
    doc => doc
  }
  let svg = document.to_svg_for_test()
  assert_true(svg.contains("TABLE CELL CHART"))
}

///|
/// §17.13.5 — fixture containing one `<w:ins>` and one `<w:del>` so
/// `accept_revisions` / `reject_revisions` have something to act on.
/// `<w:r>` runs nested inside the wrappers, with `<w:t>` / `<w:delText>`
/// children, mirror the schema.
fn fixture_with_revisions() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"urn:w\"><w:body><w:p>" +
        "<w:r><w:t xml:space=\"preserve\">keep </w:t></w:r>" +
        "<w:ins w:id=\"1\" w:author=\"A\" w:date=\"2024-01-01T00:00:00Z\">" +
        "<w:r><w:t xml:space=\"preserve\">inserted </w:t></w:r>" +
        "</w:ins>" +
        "<w:del w:id=\"2\" w:author=\"A\" w:date=\"2024-01-01T00:00:00Z\">" +
        "<w:r><w:delText xml:space=\"preserve\">struck </w:delText></w:r>" +
        "</w:del>" +
        "<w:r><w:t>tail</w:t></w:r>" +
        "</w:p></w:body></w:document>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
/// §17.13.5 — `accept_revisions` MUST:
///   • drop `<w:del>` wrappers AND their `<w:delText>` payload
///     (strike-through text disappears).
///   • unwrap `<w:ins>` wrappers (insertions become permanent text).
test "wml edit §17.13.5 accept_revisions drops <w:del> and unwraps <w:ins>" {
  let document = open(fixture_with_revisions())
  let accepted = try? @wml_edit.accept_revisions(document)
  match accepted {
    Ok(d) => {
      let svg = open(d.save()).to_svg_for_test()
      // Inserted text survives.
      assert_true(svg.contains("inserted "))
      // Untouched text survives.
      assert_true(svg.contains("keep "))
      assert_true(svg.contains("tail"))
      // Deleted text is gone.
      assert_false(svg.contains("struck"))
    }
    Err(_) => abort("accept_revisions failed")
  }
}

///|
/// §17.13.5 — `reject_revisions` MUST:
///   • drop `<w:ins>` wrappers AND their child runs (insertion is rolled back).
///   • unwrap `<w:del>` wrappers AND rename `<w:delText>` back to `<w:t>`
///     (the deletion is undone; the struck text is restored as live text).
test "wml edit §17.13.5 reject_revisions drops <w:ins> and unwraps <w:del>" {
  let document = open(fixture_with_revisions())
  let rejected = try? @wml_edit.reject_revisions(document)
  match rejected {
    Ok(d) => {
      let svg = open(d.save()).to_svg_for_test()
      // Inserted text is gone.
      assert_false(svg.contains("inserted"))
      // Untouched text and tail survive.
      assert_true(svg.contains("keep "))
      assert_true(svg.contains("tail"))
      // Previously-struck text is restored (delText → t rename).
      assert_true(svg.contains("struck "))
    }
    Err(_) => abort("reject_revisions failed")
  }
}

///|
/// Part 3 §10 MC — `<mc:AlternateContent>` (§7.5) is an opaque
/// Markup Compatibility wrapper that MUST round-trip verbatim
/// through the WML reader/writer.  Builders that walk the body
/// (e.g. `accept_revisions`, `append_paragraph`) MUST NOT drop
/// or rewrite its inner `<mc:Choice>` / `<mc:Fallback>` payload.
fn fixture_with_alternate_content() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"urn:w\" xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\">" +
        "<w:body>" +
        "<w:p><w:r><w:t>before</w:t></w:r></w:p>" +
        "<mc:AlternateContent>" +
        "<mc:Choice Requires=\"w14\"><w:p><w:r><w:t>choice-payload</w:t></w:r></w:p></mc:Choice>" +
        "<mc:Fallback><w:p><w:r><w:t>fallback-payload</w:t></w:r></w:p></mc:Fallback>" +
        "</mc:AlternateContent>" +
        "<w:p><w:r><w:t>after</w:t></w:r></w:p>" +
        "</w:body>" +
        "</w:document>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
/// Part 3 §7.5 — round-tripping the package through
/// `open → save → open` MUST preserve the full
/// `<mc:AlternateContent>` subtree (Choice + Fallback) verbatim.
test "wml context Part 3 §7.5 preserves mc:AlternateContent through save" {
  let document = open(fixture_with_alternate_content())
  let reopened = open(document.save())
  // Walk the document body and locate `<mc:AlternateContent>`.
  let body_el = match reopened.main.body {
    Some(b) => b.element
    None => abort("body missing after round-trip")
  }
  let found = locate_alternate_content(body_el)
  assert_true(found is Some(_))
  let alt = found.unwrap()
  // The wrapper still contains both Choice and Fallback children.
  let mut has_choice = false
  let mut has_fallback = false
  for child in alt.children {
    match child {
      @xml.Node::Element(e) => {
        if e.name.local_name == "Choice" {
          has_choice = true
        }
        if e.name.local_name == "Fallback" {
          has_fallback = true
        }
      }
      _ => ()
    }
  }
  assert_true(has_choice)
  assert_true(has_fallback)
}

///|
/// Part 3 §7.5 — `accept_revisions` MUST also preserve the
/// `<mc:AlternateContent>` wrapper because it carries no revision
/// markers and is irrelevant to the revision walk.
test "wml edit §17.13.5 accept_revisions preserves mc:AlternateContent" {
  let document = open(fixture_with_alternate_content())
  let accepted = try? @wml_edit.accept_revisions(document)
  match accepted {
    Ok(d) => {
      let reopened = open(d.save())
      let body_el = match reopened.main.body {
        Some(b) => b.element
        None => abort("body missing after accept_revisions")
      }
      let found = locate_alternate_content(body_el)
      assert_true(found is Some(_))
    }
    Err(_) => abort("accept_revisions failed")
  }
}

///|
fn locate_alternate_content(root : @xml.Element) -> @xml.Element? {
  for child in root.children {
    match child {
      @xml.Node::Element(e) => {
        if e.name.local_name == "AlternateContent" {
          return Some(e)
        }
        let nested = locate_alternate_content(e)
        if nested is Some(_) {
          return nested
        }
      }
      _ => ()
    }
  }
  None
}

///|
/// §17.13.5.29-.35 — pPrChange / rPrChange / tblPrChange /
/// sectPrChange / trPrChange / tcPrChange:
///   • accept: drop the change marker; current properties stay.
///   • reject: replace the parent properties with the snapshot
///     stored inside the marker.
fn fixture_with_property_revisions() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    (
      "word/document.xml",
      bytes(
        "<w:document xmlns:w=\"urn:w\"><w:body>" +
        // Paragraph with pPrChange: current jc=center, snapshot jc=start.
        "<w:p>" +
        "<w:pPr>" +
        "<w:jc w:val=\"center\"/>" +
        "<w:pPrChange w:id=\"1\" w:author=\"A\" w:date=\"2024-01-01T00:00:00Z\">" +
        "<w:pPr><w:jc w:val=\"start\"/></w:pPr>" +
        "</w:pPrChange>" +
        "</w:pPr>" +
        "<w:r><w:t>text</w:t></w:r>" +
        "</w:p>" +
        "</w:body></w:document>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
/// §17.13.5.29 — accept_revisions MUST drop the `<w:pPrChange>` while
/// preserving the current `<w:jc>` (center).
test "wml edit §17.13.5.29 accept_revisions drops pPrChange marker" {
  let opened = try? open(fixture_with_property_revisions())
  let document = match opened {
    Ok(d) => d
    Err(OpenError(kind~, path~, reason~)) =>
      abort("open failed: kind=" + kind + " path=" + path + " reason=" + reason)
  }
  let accepted = try? @wml_edit.accept_revisions(document)
  match accepted {
    Ok(d) => {
      let reopened = open(d.save())
      let body_el = match reopened.main.body {
        Some(b) => b.element
        None => abort("body missing")
      }
      // Walk into the paragraph's <w:pPr>.
      let mut found_jc_center = false
      let mut has_pPrChange = false
      for body_child in body_el.children {
        match body_child {
          @xml.Node::Element(p) =>
            if p.name.local_name == "p" {
              for p_child in p.children {
                match p_child {
                  @xml.Node::Element(pp) =>
                    if pp.name.local_name == "pPr" {
                      for pp_child in pp.children {
                        match pp_child {
                          @xml.Node::Element(c) => {
                            if c.name.local_name == "jc" {
                              for a in c.attributes {
                                if a.name.local_name == "val" &&
                                  a.value == "center" {
                                  found_jc_center = true
                                }
                              }
                            }
                            if c.name.local_name == "pPrChange" {
                              has_pPrChange = true
                            }
                          }
                          _ => ()
                        }
                      }
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
      assert_true(found_jc_center)
      assert_false(has_pPrChange)
    }
    Err(_) => abort("accept_revisions failed")
  }
}

///|
/// §17.13.5.29 — reject_revisions MUST replace `<w:pPr>` with the
/// snapshot inside `<w:pPrChange>` so the paragraph's jc reverts to
/// the pre-edit value ("left").
test "wml edit §17.13.5.29 reject_revisions restores pPr snapshot" {
  let document = open(fixture_with_property_revisions())
  let rejected = try? @wml_edit.reject_revisions(document)
  match rejected {
    Ok(d) => {
      let reopened = open(d.save())
      let body_el = match reopened.main.body {
        Some(b) => b.element
        None => abort("body missing")
      }
      let mut found_jc_start = false
      let mut has_pPrChange = false
      for body_child in body_el.children {
        match body_child {
          @xml.Node::Element(p) =>
            if p.name.local_name == "p" {
              for p_child in p.children {
                match p_child {
                  @xml.Node::Element(pp) =>
                    if pp.name.local_name == "pPr" {
                      for pp_child in pp.children {
                        match pp_child {
                          @xml.Node::Element(c) => {
                            if c.name.local_name == "jc" {
                              for a in c.attributes {
                                if a.name.local_name == "val" &&
                                  a.value == "start" {
                                  found_jc_start = true
                                }
                              }
                            }
                            if c.name.local_name == "pPrChange" {
                              has_pPrChange = true
                            }
                          }
                          _ => ()
                        }
                      }
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
      assert_true(found_jc_start)
      assert_false(has_pPrChange)
    }
    Err(_) => abort("reject_revisions failed")
  }
}

///|
/// §17.16.22 CT_Hyperlink — build a `<w:hyperlink>` wrapping a single
/// run.  `attrs` is the raw attribute string for the `<w:hyperlink>`
/// element (e.g. `r:id="rId5"` or `w:anchor="Bookmark"`); `text` is the
/// run's visible content.
fn hyperlink_paragraph_xml(attrs : String, text : String) -> String {
  "<w:p><w:hyperlink " +
  attrs +
  "><w:r><w:t>" +
  text +
  "</w:t></w:r></w:hyperlink></w:p>"
}

///|
/// §17.16.22 / OPC §9.3.1 — a package whose body paragraph holds a
/// `<w:hyperlink r:id="rId5">` over a run, with `document.xml.rels`
/// mapping `rId5` → an EXTERNAL URL via a `/hyperlink` relationship
/// (TargetMode="External").  The rendered SVG MUST wrap the run text in
/// an `<a xlink:href="<the url>">`.
fn fixture_with_body_hyperlink() -> Bytes {
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\""
  let document_xml = "<w:document" +
    ns +
    "><w:body>" +
    hyperlink_paragraph_xml("r:id=\"rId5\"", "Click here") +
    "</w:body></w:document>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId5\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink\" Target=\"https://example.com/body\" TargetMode=\"External\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
  ])
  try! @zip.write(archive)
}

///|
/// §17.16.22 / OPC §9.3.1 — the body hyperlink's `r:id` resolves against
/// the main document part's rels to the external URL, and the run's
/// `<text>` is wrapped in an `<a xlink:href="<url>">`.
test "wml context body hyperlink r:id wraps run text in an xlink anchor" {
  let document = open(fixture_with_body_hyperlink())
  let svg = document.to_svg_for_test()
  // The link target survives as an SVG anchor href.
  assert_true(svg.contains("xlink:href=\"https://example.com/body\""))
  // The anchor wraps the run's visible text.
  assert_true(svg.contains("Click here"))
  assert_true(svg.contains("<a "))
}

///|
/// §17.16.22 / OPC §9.3.1 — PART-AWARE hyperlink resolution.  A header is
/// a SEPARATE OPC part with its OWN `_rels`, so a `<w:hyperlink r:id>`
/// inside the header MUST resolve against `/word/_rels/header1.xml.rels`,
/// NOT the main document part's rels.
///
/// Discriminating fixture: BOTH `document.xml.rels` and
/// `header1.xml.rels` define the SAME hyperlink Id (`rIdLink`) but point
/// at DIFFERENT URLs — the body part maps it to a BODY url and the header
/// part to a HEADER url.  The body paragraph and the header each wrap a
/// run in `<w:hyperlink r:id="rIdLink">`.  With part-aware resolution the
/// header anchor carries the HEADER url and the body anchor the BODY url.
fn fixture_with_conflicting_hyperlink_rids() -> Bytes {
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\""
  let document_xml = "<w:document" +
    ns +
    "><w:body>" +
    hyperlink_paragraph_xml("r:id=\"rIdLink\"", "BODY LINK") +
    "<w:sectPr>" +
    "<w:headerReference w:type=\"default\" r:id=\"rIdH1\"/>" +
    "</w:sectPr>" +
    "</w:body></w:document>"
  let header_xml = "<w:hdr" +
    ns +
    ">" +
    hyperlink_paragraph_xml("r:id=\"rIdLink\"", "HEADER LINK") +
    "</w:hdr>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/header1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml\"/>" +
        "</Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
        "</Relationships>",
      ),
    ),
    // Body part rels: `rIdLink` → the BODY url; plus the header part.
    (
      "word/_rels/document.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdH1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/header\" Target=\"header1.xml\"/>" +
        "<Relationship Id=\"rIdLink\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink\" Target=\"https://example.com/from-body\" TargetMode=\"External\"/>" +
        "</Relationships>",
      ),
    ),
    // §17.10 / OPC §9.3.1 — header part rels: the SAME `rIdLink` maps to
    // a DIFFERENT url than the body part's `rIdLink`.
    (
      "word/_rels/header1.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdLink\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink\" Target=\"https://example.com/from-header\" TargetMode=\"External\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
    ("word/header1.xml", bytes(header_xml)),
  ])
  try! @zip.write(archive)
}

///|
/// §17.16.22 / OPC §9.3.1 — the header hyperlink resolves its `r:id`
/// against the HEADER part's rels, not the document's.  The bug would
/// render the document part's `rIdLink` (the BODY url) inside the header.
/// Body-link resolution is asserted by the SAME run: the body anchor
/// still resolves against the main document part's rels (the BODY url).
test "wml context resolves a header hyperlink against the header part rels" {
  let document = open(fixture_with_conflicting_hyperlink_rids())
  let svg = document.to_svg_for_test()
  // The body hyperlink resolves against the BODY part's rels.
  assert_true(svg.contains("xlink:href=\"https://example.com/from-body\""))
  // The header hyperlink resolves against the HEADER part's rels — the fix.
  // (The bug would have rendered the BODY url here too, never the HEADER
  // url, because the header's rId was wrongly resolved against the
  // document part.)
  assert_true(svg.contains("xlink:href=\"https://example.com/from-header\""))
}

///|
/// §17.16.22 — a `<w:hyperlink w:anchor="Bookmark">` with NO `r:id` is an
/// internal bookmark navigation: the run's `<text>` is wrapped in an
/// `<a xlink:href="#Bookmark">` (the `#` fragment) without consulting the
/// relationship table.
test "wml context w:anchor hyperlink wraps run text in a fragment href" {
  let ns = " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\""
  let document_xml = "<w:document" +
    ns +
    "><w:body>" +
    hyperlink_paragraph_xml("w:anchor=\"Bookmark\"", "Jump to bookmark") +
    "</w:body></w:document>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
  ])
  let document = open(try! @zip.write(archive))
  let svg = document.to_svg_for_test()
  assert_true(svg.contains("xlink:href=\"#Bookmark\""))
  assert_true(svg.contains("Jump to bookmark"))
}

///|
/// §17.16.22 — byte-identity sanity: a plain document with NO
/// `<w:hyperlink>` emits NO `<a>` anchor at all (the link plumbing is
/// inert when no hyperlink is present), while its visible text is
/// unchanged.  Guards the "documents without hyperlinks are unchanged"
/// invariant.
test "wml context plain document emits no anchor element" {
  let document = open(fixture_bytes())
  let svg = document.to_svg_for_test()
  assert_true(svg.contains("Hello docx"))
  // No SVG `<a>` anchor and no xlink:href is emitted for a hyperlink-free
  // document — the run-span emission path is byte-identical to before.
  assert_false(svg.contains("<a "))
  assert_false(svg.contains("xlink:href"))
}

///|
/// §17.18.44 ST_Jc — set_paragraph_alignment MUST normalise the
/// transitional aliases "left"/"right" to "start"/"end" and
/// reject values outside the enumeration.
test "wml edit §17.18.44 set_paragraph_alignment normalises left/right" {
  let document = open(fixture_bytes())
  // "left" → "start".
  let modified = try? @wml_edit.set_paragraph_alignment(document, 0, "left")
  match modified {
    Ok(d) =>
      match d.main.body {
        Some(body) => {
          let p = body.block_level_elts[0].source_element()
          let p_pr = first_child(p, "pPr")
          let jc = match p_pr {
            Some(pr) => first_child(pr, "jc")
            None => None
          }
          match jc {
            Some(jc_el) => {
              let mut found_start = false
              for a in jc_el.attributes {
                if a.name.local_name == "val" && a.value == "start" {
                  found_start = true
                }
              }
              assert_true(found_start)
            }
            None => abort("jc element missing")
          }
        }
        None => abort("body missing")
      }
    Err(_) => abort("set_paragraph_alignment(left) failed")
  }
}

///|
/// §17.18.44 — an out-of-enumeration value MUST raise rather than
/// write an invalid `<w:jc w:val>`.
test "wml edit §17.18.44 set_paragraph_alignment rejects invalid value" {
  let document = open(fixture_bytes())
  let result = try? @wml_edit.set_paragraph_alignment(document, 0, "bogus")
  assert_true(result is Err(_))
}
