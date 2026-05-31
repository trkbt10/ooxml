// §17.9.9 lvlPicBulletId / §17.9.20 numPicBullet — end-to-end
// picture-bullet wiring through the WML context facade.  `open`
// loads `/word/numbering.xml` (typed `CT_Numbering`, with its
// `pic_bullets` index) and `Document::to_svg` passes the ONE
// part-aware `image_resolver` plus `numbering_part="/word/numbering.xml"`.
// The viewer folds picture bullets into that resolver: it walks a
// level's `numPicBulletId` → `<w:numPicBullet>` element →
// blip/imagedata `r:id`, then calls `image_resolver(numbering_part,
// rid)` so the rId resolves against the NUMBERING part's relationships
// (not the document part's).  The viewer then emits an `<image>` glyph
// at the bullet position.  A document with no resolvable picture
// bullet renders the §17.9.11 lvlText text marker, byte-identical to
// the pre-feature output.

///|
/// Distinctive PNG media bytes (the 8-byte PNG signature is enough for
/// the OPC plumbing this test exercises — the resolver only base64-
/// encodes the part bytes verbatim; it never decodes the image).  The
/// distinctive trailing bytes let the assertions pinpoint the bullet
/// image's data URI in the rendered SVG.
let pic_bullet_png : Bytes = b"\x89PNG\r\n\x1a\n\x00\x42\x55\x4c"

///|
/// Expected base64 payload for the bullet image — exactly what the
/// resolver emits when it re-encodes the media part bytes.
let pic_bullet_png_b64 : String = @base64.encode(pic_bullet_png)

///|
/// Build a full `.docx` package whose single list paragraph sits on a
/// numbering level carrying `<w:lvlPicBulletId w:val="5"/>`.  The
/// matching `<w:numPicBullet numPicBulletId="5">` wraps a DrawingML
/// picture (`<w:drawing>…<a:blip r:embed="rIdImg"/>` with a 2:1
/// `<wp:extent>` so the renderer preserves the bullet aspect).  The
/// numbering part's relationships map `rIdImg` to `/word/media/img.png`
/// with an `…/image` relationship type, and the media part carries the
/// PNG bytes.  When `vml` is true, the numPicBullet instead wraps a VML
/// picture (`<w:pict><v:shape><v:imagedata r:id="rIdImg"/>`), exercising
/// the §17.9.20 VML branch of the rId extraction.
fn pic_bullet_package(vml~ : Bool) -> Bytes {
  let picture = if vml {
    // §17.9.20 VML picture — `<v:imagedata r:id>` carries the rId.
    "<w:pict>" +
    "<v:shape style=\"width:20pt;height:10pt\">" +
    "<v:imagedata r:id=\"rIdImg\"/>" +
    "</v:shape>" +
    "</w:pict>"
  } else {
    // §17.9.20 DrawingML picture — `<a:blip r:embed>` carries the rId;
    // the 2:1 `<wp:extent>` lets the renderer keep the bullet aspect.
    "<w:drawing>" +
    "<wp:inline>" +
    "<wp:extent cx=\"1828800\" cy=\"914400\"/>" +
    "<a:graphic><a:graphicData><pic:pic><pic:blipFill>" +
    "<a:blip r:embed=\"rIdImg\"/>" +
    "</pic:blipFill></pic:pic></a:graphicData></a:graphic>" +
    "</wp:inline>" +
    "</w:drawing>"
  }
  let numbering_xml = "<w:numbering" +
    " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"" +
    " xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"" +
    " xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\"" +
    " xmlns:v=\"urn:schemas-microsoft-com:vml\">" +
    "<w:numPicBullet w:numPicBulletId=\"5\">" +
    picture +
    "</w:numPicBullet>" +
    "<w:abstractNum w:abstractNumId=\"0\">" +
    "<w:lvl w:ilvl=\"0\">" +
    "<w:numFmt w:val=\"bullet\"/>" +
    "<w:lvlText w:val=\"o\"/>" +
    "<w:lvlPicBulletId w:val=\"5\"/>" +
    "</w:lvl>" +
    "</w:abstractNum>" +
    "<w:num w:numId=\"1\"><w:abstractNumId w:val=\"0\"/></w:num>" +
    "</w:numbering>"
  let document_xml = "<w:document" +
    " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">" +
    "<w:body>" +
    "<w:p>" +
    "<w:pPr><w:numPr><w:ilvl w:val=\"0\"/><w:numId w:val=\"1\"/></w:numPr></w:pPr>" +
    "<w:r><w:t>Bulleted item</w:t></w:r>" +
    "</w:p>" +
    "</w:body>" +
    "</w:document>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Default Extension=\"png\" ContentType=\"image/png\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/numbering.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml\"/>" +
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
        "<Relationship Id=\"rIdNum\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering\" Target=\"numbering.xml\"/>" +
        "</Relationships>",
      ),
    ),
    // §17.9.20 — the bullet image's relationship lives in the
    // NUMBERING part's rels, NOT the document part's rels.
    (
      "word/_rels/numbering.xml.rels",
      bytes(
        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
        "<Relationship Id=\"rIdImg\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/img.png\"/>" +
        "</Relationships>",
      ),
    ),
    ("word/document.xml", bytes(document_xml)),
    ("word/numbering.xml", bytes(numbering_xml)),
    ("word/media/img.png", pic_bullet_png),
  ])
  try! @zip.write(archive)
}

///|
/// §17.9.9 / §17.9.20 — opening a package whose list level carries a
/// DrawingML picture bullet and calling `to_svg` MUST render the
/// bullet as an `<image>` whose href is the resolved
/// `data:image/png;base64,…` URI (the bullet image resolved end-to-end
/// through the numbering part's relationships).  The list run text
/// still renders, and the §17.9.11 lvlText placeholder ("o ") is NOT
/// emitted because the picture replaces it.
test "wml context renders DrawingML picture bullet as <image> end-to-end" {
  let document = open(pic_bullet_package(vml=false))
  let svg = document.to_svg()
  assert_true(svg.contains("<image"))
  assert_true(
    svg.contains("href=\"data:image/png;base64," + pic_bullet_png_b64 + "\""),
  )
  assert_true(svg.contains("Bulleted item"))
  // The lvlText marker "o " must NOT leak through as a text run.
  assert_false(svg.contains(">o <"))
}

///|
/// §17.9.20 — the VML picture branch (`<v:imagedata r:id>`) resolves
/// identically: the same `<image>` data URI is rendered end-to-end.
test "wml context renders VML picture bullet as <image> end-to-end" {
  let document = open(pic_bullet_package(vml=true))
  let svg = document.to_svg()
  assert_true(svg.contains("<image"))
  assert_true(
    svg.contains("href=\"data:image/png;base64," + pic_bullet_png_b64 + "\""),
  )
  assert_true(svg.contains("Bulleted item"))
  assert_false(svg.contains(">o <"))
}

///|
/// §17.9 — the byte-identical fallback contract.  The SAME numbering /
/// document structure WITHOUT a resolvable picture bullet must render
/// the §17.9.11 lvlText text marker exactly as before.  We simulate an
/// unresolvable bullet by dropping the numbering part's image
/// relationship: `open` still loads the numbering (so the level still
/// declares `<w:lvlPicBulletId>`), but the resolver finds no matching
/// `…/image` rel and returns `None`, so the viewer draws the "o "
/// marker.  No `<image>` bullet and no PNG data URI appear.
test "wml context falls back to text marker when bullet image is unresolvable" {
  // Reuse the DrawingML package but strip the numbering rels part so
  // the rId cannot resolve — the rest of the package is identical.
  let numbering_xml = "<w:numbering" +
    " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"" +
    " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"" +
    " xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"" +
    " xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"" +
    " xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\">" +
    "<w:numPicBullet w:numPicBulletId=\"5\">" +
    "<w:drawing><wp:inline><wp:extent cx=\"1828800\" cy=\"914400\"/>" +
    "<a:graphic><a:graphicData><pic:pic><pic:blipFill>" +
    "<a:blip r:embed=\"rIdImg\"/>" +
    "</pic:blipFill></pic:pic></a:graphicData></a:graphic>" +
    "</wp:inline></w:drawing>" +
    "</w:numPicBullet>" +
    "<w:abstractNum w:abstractNumId=\"0\">" +
    "<w:lvl w:ilvl=\"0\">" +
    "<w:numFmt w:val=\"bullet\"/>" +
    "<w:lvlText w:val=\"o\"/>" +
    "<w:lvlPicBulletId w:val=\"5\"/>" +
    "</w:lvl></w:abstractNum>" +
    "<w:num w:numId=\"1\"><w:abstractNumId w:val=\"0\"/></w:num>" +
    "</w:numbering>"
  let document_xml = "<w:document" +
    " xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">" +
    "<w:body><w:p>" +
    "<w:pPr><w:numPr><w:ilvl w:val=\"0\"/><w:numId w:val=\"1\"/></w:numPr></w:pPr>" +
    "<w:r><w:t>Bulleted item</w:t></w:r>" +
    "</w:p></w:body></w:document>"
  let archive = @zip.Archive::new([
    (
      "[Content_Types].xml",
      bytes(
        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
        "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
        "<Override PartName=\"/word/numbering.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml\"/>" +
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
        "<Relationship Id=\"rIdNum\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering\" Target=\"numbering.xml\"/>" +
        "</Relationships>",
      ),
    ),
    // NOTE: no `word/_rels/numbering.xml.rels` — the bullet rId is
    // unresolvable, so the resolver returns None.
    ("word/document.xml", bytes(document_xml)),
    ("word/numbering.xml", bytes(numbering_xml)),
  ])
  let document = open(try! @zip.write(archive))
  let svg = document.to_svg()
  // No picture-bullet image is emitted.
  assert_false(svg.contains("data:image/png;base64,"))
  // The §17.9.11 lvlText marker "o " renders as text instead.
  assert_true(svg.contains(">o <"))
  assert_true(svg.contains("Bulleted item"))
}
