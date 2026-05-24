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
test "wordprocessing_ml context opens and saves minimal package" {
  let document = open(fixture_bytes())
  assert_eq(document.main_part, "/word/document.xml")
  let reopened = open(document.save())
  assert_eq(reopened.main.element.name.local_name, "document")
}

///|
test "wordprocessing_ml context renders minimal svg" {
  let svg = open(fixture_bytes()).to_svg()
  assert_true(svg.contains("data-ooxml=\"wml\""))
  assert_true(svg.contains("Hello docx"))
}

///|
test "wordprocessing_ml context appends paragraph and round-trips" {
  let document = open(fixture_bytes())
  let with_para = try? @wml_edit.append_paragraph(document, "appended line")
  match with_para {
    Ok(modified) => {
      let saved = modified.save()
      let reopened = open(saved)
      assert_true(reopened.to_svg().contains("appended line"))
      // original 'Hello docx' still present
      assert_true(reopened.to_svg().contains("Hello docx"))
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
      let svg = open(d.save()).to_svg()
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
      let svg = open(d.save()).to_svg()
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
          assert_true(!reopened.to_svg().contains("temporary"))
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
  assert_true(cycle1.to_svg().contains("Hello docx"))
  assert_true(cycle2.to_svg().contains("Hello docx"))
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
  let svg = document.to_svg()
  assert_true(svg.contains("Body content"))
  assert_true(svg.contains("HEADER-TOKEN"))
  assert_true(svg.contains("FOOTER-TOKEN"))
}

///|
test "wml context to_svg without header/footer still emits body" {
  let document = open(fixture_bytes())
  let svg = document.to_svg()
  assert_true(svg.contains("Hello docx"))
  assert_false(svg.contains("HEADER-TOKEN"))
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
      let svg = open(d.save()).to_svg()
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
      let svg = open(d.save()).to_svg()
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
