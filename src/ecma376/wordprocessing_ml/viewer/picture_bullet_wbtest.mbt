// §17.9.9 lvlPicBulletId / §17.9.20 numPicBullet — picture-bullet
// rendering for WordprocessingML lists.  A numbering level whose
// `<w:lvl>` carries `<w:lvlPicBulletId w:val="N"/>` references a
// `<w:numPicBullet w:numPicBulletId="N">`; when the caller wires a
// `pic_bullet_resolver` that resolves `N` to a `ResolvedImage`, the
// renderer emits an `<image>` glyph at the bullet position instead of
// the §17.9.11 lvlText text marker.  With no resolver the same
// document MUST render the text marker (byte-identical to the
// pre-feature behaviour).

///|
/// Build a `<w:numbering>` whose abstract level 0 carries BOTH a
/// `<w:lvlPicBulletId w:val="5"/>` and a fallback `<w:lvlText w:val="o"/>`,
/// plus a `<w:numPicBullet w:numPicBulletId="5">` with a `<w:drawing>`
/// declaring a 2:1 extent (cx=1828800 EMU, cy=914400 EMU → aspect 2.0).
/// A single `<w:num numId="1">` maps to abstractNumId 0.
fn pic_bullet_numbering() -> @domain.CT_Numbering raise {
  let lvl : @xml.Element = {
    name: name("lvl"),
    attributes: [attr("ilvl", "0")],
    children: [
      @xml.Node::Element({
        name: name("numFmt"),
        attributes: [attr("val", "bullet")],
        children: [],
      }),
      @xml.Node::Element({
        name: name("lvlText"),
        attributes: [attr("val", "o")],
        children: [],
      }),
      @xml.Node::Element({
        name: name("lvlPicBulletId"),
        attributes: [attr("val", "5")],
        children: [],
      }),
    ],
  }
  let abstract_num : @xml.Element = {
    name: name("abstractNum"),
    attributes: [attr("abstractNumId", "0")],
    children: [@xml.Node::Element(lvl)],
  }
  let num_el : @xml.Element = {
    name: name("num"),
    attributes: [attr("numId", "1")],
    children: [
      @xml.Node::Element({
        name: name("abstractNumId"),
        attributes: [attr("val", "0")],
        children: [],
      }),
    ],
  }
  // §17.9.20 numPicBullet — `<w:drawing>` with a 2:1 `<wp:extent>` so
  // the renderer can preserve the bullet's intrinsic aspect.
  let num_pic_bullet : @xml.Element = {
    name: name("numPicBullet"),
    attributes: [attr("numPicBulletId", "5")],
    children: [
      @xml.Node::Element({
        name: name("drawing"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("inline"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("extent"),
                attributes: [attr("cx", "1828800"), attr("cy", "914400")],
                children: [],
              }),
            ],
          }),
        ],
      }),
    ],
  }
  let numbering_element : @xml.Element = {
    name: name("numbering"),
    attributes: [],
    children: [
      @xml.Node::Element(abstract_num),
      @xml.Node::Element(num_el),
      @xml.Node::Element(num_pic_bullet),
    ],
  }
  @domain.CT_Numbering::parse(numbering_element)
}

///|
/// Build a single list paragraph referencing numId 1 / ilvl 0 with
/// the run text `body`.
fn pic_bullet_document(body : String) -> @domain.CT_Document raise {
  @domain.CT_Document::new({
    name: name("document"),
    attributes: [],
    children: [
      @xml.Node::Element({
        name: name("body"),
        attributes: [],
        children: [
          @xml.Node::Element({
            name: name("p"),
            attributes: [],
            children: [
              @xml.Node::Element({
                name: name("pPr"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("numPr"),
                    attributes: [],
                    children: [
                      @xml.Node::Element({
                        name: name("ilvl"),
                        attributes: [attr("val", "0")],
                        children: [],
                      }),
                      @xml.Node::Element({
                        name: name("numId"),
                        attributes: [attr("val", "1")],
                        children: [],
                      }),
                    ],
                  }),
                ],
              }),
              @xml.Node::Element({
                name: name("r"),
                attributes: [],
                children: [
                  @xml.Node::Element({
                    name: name("t"),
                    attributes: [],
                    children: [@xml.Node::Text(body)],
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  })
}

///|
/// A distinctive 1×1 transparent PNG data URI body so the assertions
/// can pinpoint the bullet image in the rendered SVG.
let pic_bullet_test_b64 : String =
  #|iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==

///|
/// §17.9.9 — with a `pic_bullet_resolver` returning a known image, the
/// numbered paragraph renders an `<image>` glyph carrying that data
/// URI at the bullet position, and the §17.9.11 lvlText placeholder
/// `o ` text marker is NOT emitted for the level.
test "render_svg renders <w:lvlPicBulletId> picture bullet as <image>" {
  let numbering = pic_bullet_numbering()
  let document = pic_bullet_document("Item")
  let expected_href = "data:image/png;base64," + pic_bullet_test_b64
  let resolver = fn(pic_id : Int) -> ResolvedImage? {
    // §17.9.20 — the level references numPicBulletId 5.
    if pic_id == 5 {
      Some({ mime_type: "image/png", base64_data: pic_bullet_test_b64 })
    } else {
      None
    }
  }
  let svg = render_svg(
      document,
      numbering=Some(numbering),
      pic_bullet_resolver=resolver,
    ).pages[0].svg
  // The bullet is emitted as an <image> element with the resolved
  // data URI href.
  assert_true(svg.contains("<image"))
  assert_true(svg.contains("href=\"" + expected_href + "\""))
  // The run text still renders after the bullet.
  assert_true(svg.contains("Item"))
  // The §17.9.11 lvlText marker for THIS level ("o" + trailing space)
  // must NOT be emitted as a <text> run — the picture replaces it.
  // (The bullet text marker would surface as the standalone glyph
  // sequence "o " in a <text>; the run text "Item" has no 'o', so a
  // bare ">o " span only appears if the text marker leaked through.)
  assert_false(svg.contains(">o <"))
  // The picture bullet preserves its 2:1 intrinsic aspect: the
  // emitted <image> width is twice its height.  This document ships no
  // `/word/styles.xml`, so the renderer uses the Office Normal 11 pt
  // run size; the em-box height is 11 * 96/72 ≈ 14.667 px, so the
  // bullet is ≈29.333 px wide × ≈14.667 px tall (fmt_double rounds to
  // 3 decimals).
  assert_true(svg.contains("height=\"14.667\""))
  assert_true(svg.contains("width=\"29.333\""))
}

///|
/// §17.9 — with NO `pic_bullet_resolver` (the default), the SAME
/// document falls back to the §17.9.11 lvlText text marker: no
/// `<image>` bullet is emitted and the resolved `lvlText` ("o ")
/// renders as text.  This is the byte-identical pre-feature path.
test "render_svg without pic_bullet_resolver renders the text marker" {
  let numbering = pic_bullet_numbering()
  let document = pic_bullet_document("Item")
  let with_resolver = fn(pic_id : Int) -> ResolvedImage? {
    if pic_id == 5 {
      Some({ mime_type: "image/png", base64_data: pic_bullet_test_b64 })
    } else {
      None
    }
  }
  // Default resolver (none supplied).
  let svg_default = render_svg(document, numbering=Some(numbering)).pages[0].svg
  // No picture bullet image is emitted.
  assert_false(
    svg_default.contains("data:image/png;base64," + pic_bullet_test_b64),
  )
  // The lvlText marker "o" renders as a glyph instead.
  assert_true(svg_default.contains("Item"))
  assert_true(svg_default.contains(">o <"))

  // A resolver returning None for this id behaves identically to the
  // default (the byte-identical fallback contract).
  let none_resolver = fn(_pic_id : Int) -> ResolvedImage? { None }
  let svg_none = render_svg(
      document,
      numbering=Some(numbering),
      pic_bullet_resolver=none_resolver,
    ).pages[0].svg
  assert_eq(svg_none, svg_default)

  // And supplying the real resolver DOES change the output (sanity:
  // the feature is actually gated on the resolver, not always-on).
  let svg_pic = render_svg(
      document,
      numbering=Some(numbering),
      pic_bullet_resolver=with_resolver,
    ).pages[0].svg
  assert_not_eq(svg_pic, svg_default)
}
