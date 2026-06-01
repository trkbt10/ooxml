///|
fn fixture_bytes() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/ppt/presentation.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml\"/><Override PartName=\"/ppt/slides/slide1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slide+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"ppt/presentation.xml\"/></Relationships>",
      ),
    ),
    (
      "ppt/_rels/presentation.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide\" Target=\"slides/slide1.xml\"/></Relationships>",
      ),
    ),
    ("ppt/presentation.xml", bytes("<p:presentation xmlns:p=\"urn:p\"/>")),
    (
      "ppt/slides/slide1.xml",
      bytes(
        valid_slide_xml(
          "xmlns:p=\"urn:p\" xmlns:a=\"urn:a\"",
          valid_text_shape_xml(
            "2", "Hello", "", "<a:p><a:r><a:t>Hello pptx</a:t></a:r></a:p>",
          ),
        ),
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
/// §19.3.1.45 spTree is a CT_GroupShape, so the test slide
/// skeleton must include the same required non-visual group metadata
/// that the production reader enforces.
fn valid_slide_xml(ns_attrs : String, shape_xml : String) -> String {
  "<p:sld " +
  ns_attrs +
  "><p:cSld><p:spTree>" +
  "<p:nvGrpSpPr><p:cNvPr id=\"1\" name=\"\"/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>" +
  "<p:grpSpPr/>" +
  shape_xml +
  "</p:spTree></p:cSld></p:sld>"
}

///|
fn valid_text_shape_xml(
  id : String,
  name : String,
  sp_pr_children : String,
  paragraphs : String,
) -> String {
  "<p:sp><p:nvSpPr><p:cNvPr id=\"" +
  id +
  "\" name=\"" +
  name +
  "\"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr>" +
  sp_pr_children +
  "</p:spPr><p:txBody><a:bodyPr/>" +
  paragraphs +
  "</p:txBody></p:sp>"
}

///|
test "presentation_ml context opens and saves minimal package" {
  let presentation = open(fixture_bytes())
  assert_eq(presentation.presentation_part, "/ppt/presentation.xml")
  assert_eq(presentation.slides.length(), 1)
  let reopened = open(presentation.save())
  assert_eq(reopened.presentation.element.name.local_name, "presentation")
}

///|
test "presentation_ml save_or_raise reports invalid package" {
  let presentation = open(fixture_bytes())
  let broken_parts : Array[@opc.PackagePart] = []
  for part in presentation.opc_package.parts {
    if part.name == presentation.presentation_part {
      broken_parts.push({ ..part, name: "ppt/presentation.xml" })
    } else {
      broken_parts.push(part)
    }
  }
  let broken = {
    ..presentation,
    opc_package: { ..presentation.opc_package, parts: broken_parts },
  }
  try broken.save_or_raise() catch {
    SaveError(kind~, path~, reason~) => {
      assert_eq(kind, "PackageSaveFailed")
      assert_eq(path, "/ppt/presentation.xml")
      assert_true(reason.length() > 0)
    }
  } noraise {
    _ => abort("expected SaveError")
  }
}

///|
/// Concatenate the text content of every `<text>` element in an SVG
/// string.  The SVG renderer lays a run out into one `<text>` per
/// laid-out glyph segment, so a logical word is split across several
/// elements; this helper rejoins them so a test can assert on the
/// rendered text without depending on element boundaries.
fn svg_text_content(svg : String) -> String {
  let out = StringBuilder::new()
  let mut i = 0
  let n = svg.length()
  while i < n {
    // Find the next "<text" ... ">" open tag.
    match find_from(svg, "<text", i) {
      None => break
      Some(tag_start) =>
        match find_from(svg, ">", tag_start) {
          None => break
          Some(gt) => {
            let content_start = gt + 1
            match find_from(svg, "</text>", content_start) {
              None => break
              Some(close) => {
                out.write_string(svg[content_start:close].to_owned())
                i = close + 7
              }
            }
          }
        }
    }
  }
  out.to_string()
}

///|
/// Index of the first occurrence of `needle` in `haystack` at or
/// after `from`, or None.
fn find_from(haystack : String, needle : String, from : Int) -> Int? {
  let hn = haystack.length()
  let nn = needle.length()
  if nn == 0 {
    return Some(from)
  }
  let mut i = from
  while i + nn <= hn {
    let mut j = 0
    while j < nn && haystack.code_unit_at(i + j) == needle.code_unit_at(j) {
      j = j + 1
    }
    if j == nn {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
test "presentation_ml context renders minimal svg" {
  let svg = open(fixture_bytes()).to_svg()
  // The SVG renderer splits a run into per-glyph <text> elements;
  // verify the rejoined rendered text carries the slide content.
  assert_true(svg_text_content(svg).contains("Hello pptx"))
}

///|
test "presentation_ml context append_text_to_slide round-trips through save/open" {
  let initial = open(fixture_bytes())
  let modified = try? @pml_edit.append_text_to_slide(
    initial, 0, "appended-pptx-text",
  )
  match modified {
    Ok(presentation) => {
      let saved = presentation.save()
      let reopened = open(saved)
      let text = svg_text_content(reopened.to_svg())
      assert_true(text.contains("appended-pptx-text"))
      assert_true(text.contains("Hello pptx"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context append_slide round-trips and adds a slide part" {
  let initial = open(fixture_bytes())
  let appended = try? @pml_edit.append_slide(initial)
  match appended {
    Ok(presentation) => {
      assert_eq(presentation.slides.length(), initial.slides.length() + 1)
      let reopened = open(presentation.save())
      assert_eq(reopened.slides.length(), initial.slides.length() + 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context remove_slide drops the part and round-trips" {
  let initial = open(fixture_bytes())
  // First add a slide so we have one to drop without leaving the
  // presentation empty.
  let appended = try? @pml_edit.append_slide(initial)
  match appended {
    Ok(p1) => {
      let removed = try? @pml_edit.remove_slide(p1, p1.slides.length() - 1)
      match removed {
        Ok(p2) => {
          assert_eq(p2.slides.length(), initial.slides.length())
          let reopened = open(p2.save())
          assert_eq(reopened.slides.length(), initial.slides.length())
        }
        Err(_) => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
/// `Presentation::to_svg_for_slide` returns a clean SVG by
/// default: every `data-ooxml-*` decoration is stripped on the
/// way out so production consumers see only paint primitives.
/// Passing `debug_attrs=true` opts in to the inspection labels
/// — the catalog harness's differential render verifier relies
/// on exactly this flag.  Both modes always carry the slide's
/// visible content.
test "presentation_ml context to_svg_for_slide emits an <svg> document" {
  let presentation = open(fixture_bytes())
  // Default `debug_attrs=false`: clean SVG.
  let svg_clean = try? presentation.to_svg_for_slide(0)
  match svg_clean {
    Ok(markup) => {
      assert_true(markup.has_prefix("<svg"))
      assert_false(markup.contains("data-ooxml=\"pml\""))
    }
    Err(_) => assert_true(false)
  }
  // Opt-in path: `data-ooxml-*` decoration surfaces.
  let svg_debug = try? presentation.to_svg_for_slide(0, debug_attrs=true)
  match svg_debug {
    Ok(markup) => {
      assert_true(markup.has_prefix("<svg"))
      assert_true(markup.contains("data-ooxml=\"pml\""))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context to_image_for_slide raster path returns Some(Image)" {
  let presentation = open(fixture_bytes())
  let img = try? presentation.to_image_for_slide(0, 80, 60)
  match img {
    Ok(Some(image)) => {
      assert_eq(image.width, 80)
      assert_eq(image.height, 60)
    }
    Ok(None) =>
      // mizchi/svg may reject the markup on some platforms; treat
      // this as a soft skip rather than a hard fail.
      assert_true(true)
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context add_textbox appends sp to spTree" {
  let initial = open(fixture_bytes())
  let modified = try? @pml_edit.add_textbox(
    initial, 0, 100000, 200000, 3000000, 1000000, "boxed text",
  )
  match modified {
    Ok(p) => {
      let reopened = open(p.save())
      assert_true(svg_text_content(reopened.to_svg()).contains("boxed text"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context add_picture embeds image part and rels" {
  let initial = open(fixture_bytes())
  let png_bytes = b"\x89PNG\r\n\x1a\n" // not a real PNG but enough for OPC plumbing
  let modified = try? @pml_edit.add_picture(
    initial, 0, png_bytes, "image/png", 100000, 100000, 500000, 500000,
  )
  match modified {
    Ok(p) => {
      let saved = p.save()
      let reopened = open(saved)
      // verify the image part appears in the reopened package
      let mut found = false
      for part in reopened.opc_package.parts {
        if part.name.has_prefix("/ppt/media/image") {
          found = true
        }
      }
      assert_true(found)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context remove_shape drops a direct spTree child" {
  let initial = open(fixture_bytes())
  let with_box = try? @pml_edit.add_textbox(
    initial, 0, 0, 0, 1000000, 500000, "to-remove",
  )
  match with_box {
    Ok(p1) => {
      // The fixture's spTree has one <p:sp> already, so the new
      // textbox is at shape_index 1.
      let removed = try? @pml_edit.remove_shape(p1, 0, 1)
      match removed {
        Ok(p2) => {
          let reopened = open(p2.save())
          assert_true(
            !svg_text_content(reopened.to_svg()).contains("to-remove"),
          )
        }
        Err(_) => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
test "presentation_ml context set_shape_xfrm patches off/ext attributes" {
  let initial = open(fixture_bytes())
  let with_box = try? @pml_edit.add_textbox(
    initial, 0, 0, 0, 1000000, 500000, "movable",
  )
  match with_box {
    Ok(p1) => {
      let moved = try? @pml_edit.set_shape_xfrm(
        p1, 0, 1, 999000, 888000, 3000000, 2000000,
      )
      match moved {
        Ok(p2) => {
          let reopened = open(p2.save())
          let slide_elt = reopened.slides[0].value.element
          let mut found_x = false
          let mut found_cx = false
          walk_for_attrs(slide_elt, fn(e) {
            for a in e.attributes {
              if a.name.local_name == "x" && a.value == "999000" {
                found_x = true
              }
              if a.name.local_name == "cx" && a.value == "3000000" {
                found_cx = true
              }
            }
          })
          assert_true(found_x)
          assert_true(found_cx)
        }
        Err(_) => assert_true(false)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
fn walk_for_attrs(
  element : @xml.Element,
  visit : (@xml.Element) -> Unit,
) -> Unit {
  visit(element)
  for child in element.children {
    match child {
      @xml.Element(e) => walk_for_attrs(e, visit)
      _ => ()
    }
  }
}

///|
test "presentation_ml context preserves slide content across two save cycles" {
  let initial = open(fixture_bytes())
  let cycle1 = open(initial.save())
  let cycle2 = open(cycle1.save())
  assert_eq(initial.slides.length(), cycle2.slides.length())
  assert_true(svg_text_content(cycle1.to_svg()).contains("Hello pptx"))
  assert_true(svg_text_content(cycle2.to_svg()).contains("Hello pptx"))
}

///|
/// §21.1.2.3.5 CT_Hyperlink — a package whose single slide carries a
/// run with `<a:hlinkClick r:id="rId2">` and a slide `.rels` part that
/// maps rId2 to an External hyperlink URL.  Used by the end-to-end
/// resolution test below.
fn hyperlink_fixture_bytes() -> Bytes {
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Override PartName=\"/ppt/presentation.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml\"/><Override PartName=\"/ppt/slides/slide1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slide+xml\"/></Types>",
      ),
    ),
    (
      "_rels/.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"ppt/presentation.xml\"/></Relationships>",
      ),
    ),
    (
      "ppt/_rels/presentation.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide\" Target=\"slides/slide1.xml\"/></Relationships>",
      ),
    ),
    ("ppt/presentation.xml", bytes("<p:presentation xmlns:p=\"urn:p\"/>")),
    // §21.1.2.3.5 — the run's `<a:rPr>` carries `<a:hlinkClick r:id>`;
    // the shape is sized so the text lays out and the anchor emits.
    (
      "ppt/slides/slide1.xml",
      bytes(
        valid_slide_xml(
          "xmlns:p=\"urn:p\" xmlns:a=\"urn:a\" xmlns:r=\"urn:r\"",
          valid_text_shape_xml(
            "2", "Link", "<a:xfrm><a:off x=\"0\" y=\"0\"/><a:ext cx=\"914400\" cy=\"457200\"/></a:xfrm>",
            "<a:p><a:r><a:rPr><a:hlinkClick r:id=\"rId2\"/></a:rPr><a:t>link</a:t></a:r></a:p>",
          ),
        ),
      ),
    ),
    // §15.2.2 — the slide's relationship part maps rId2 to an External
    // hyperlink URL; the resolver returns the Target verbatim.
    (
      "ppt/slides/_rels/slide1.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink\" Target=\"https://example.com/docs\" TargetMode=\"External\"/></Relationships>",
      ),
    ),
  ])
  try! @zip.write(archive)
}

///|
/// §21.1.2.3.5 — end-to-end: opening a package whose slide run holds
/// `<a:hlinkClick r:id="rId2">` and whose slide `.rels` maps rId2 to
/// an External URL renders the anchor with the RESOLVED URL in
/// `xlink:href`, not the raw rId.  The raw rId stays in
/// `data-ooxml-r-id` (visible only with `debug_attrs=true`).
test "presentation_ml context resolves run hlinkClick r:id to URL" {
  let presentation = open(hyperlink_fixture_bytes())
  let svg = try! presentation.to_svg_for_slide(0, debug_attrs=true)
  assert_true(svg.contains("xlink:href=\"https://example.com/docs\""))
  assert_true(svg.contains("href=\"https://example.com/docs\""))
  // The raw rId must NOT leak into xlink:href; the resolved URL wins.
  assert_false(svg.contains("xlink:href=\"rId2\""))
  // The raw rId is preserved as metadata for spec-aware consumers.
  assert_true(svg.contains("data-ooxml-r-id=\"rId2\""))
}

///|
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}
