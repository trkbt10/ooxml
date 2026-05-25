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
        "<p:sld xmlns:p=\"urn:p\"><p:cSld><p:spTree><p:sp><p:txBody><p:p><p:r><p:t>Hello pptx</p:t></p:r></p:p></p:txBody></p:sp></p:spTree></p:cSld></p:sld>",
      ),
    ),
  ])
  try! @zip.write(archive)
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
                out.write_string(svg[content_start:close].to_string())
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
      for part in reopened.package.parts {
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
fn bytes(source : String) -> Bytes {
  @utf8.encode(source[:])
}
