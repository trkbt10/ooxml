// §17.9.9 lvlPicBulletId / §17.9.20 numPicBullet — picture-bullet
// rendering for WordprocessingML lists.  A numbering level whose
// `<w:lvl>` carries `<w:lvlPicBulletId w:val="N"/>` references a
// `<w:numPicBullet w:numPicBulletId="N">`; the viewer walks that
// element to its blip `r:embed` (or VML `<v:imagedata r:id>`) and
// resolves the rId through the part-aware `image_resolver` scoped to
// the NUMBERING part token.  When the image resolves the renderer
// emits an `<image>` glyph at the bullet position instead of the
// §17.9.11 lvlText text marker; with no resolvable image the same
// document MUST render the text marker (byte-identical to the
// pre-feature behaviour).

///|
/// OPC §9.3.1 — the officeDocument relationships namespace.  A blip's
/// `r:embed` / a VML imagedata's `r:id` carries this namespace, and the
/// viewer's `num_pic_bullet_image_rid` walk only matches attributes in
/// it (mirroring the `r:`-prefix discipline of ST_RelationshipId).
let rel_ns : String = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

///|
/// A relationships-namespaced attribute (`r:embed` / `r:id`) so the
/// viewer's numPicBullet rId walk matches it.
fn rel_attr(local_name : String, value : String) -> @xml.Attribute {
  { name: { prefix: Some("r"), local_name, ns: Some(rel_ns) }, value }
}

///|
/// The numbering part token under which the picture bullet's blip rId
/// resolves — the canonical path the facade uses for `/word/numbering.xml`.
let bullet_numbering_part : String = "/word/numbering.xml"

///|
/// Build a `<w:numbering>` whose abstract level 0 carries BOTH a
/// `<w:lvlPicBulletId w:val="5"/>` and a fallback `<w:lvlText w:val="o"/>`,
/// plus a `<w:numPicBullet w:numPicBulletId="5">` whose `<w:drawing>`
/// declares a 2:1 extent (cx=1828800 EMU, cy=914400 EMU → aspect 2.0)
/// and a DrawingML `<a:blip r:embed="rIdBullet"/>` carrying the bullet
/// image relationship Id.  A single `<w:num numId="1">` maps to
/// abstractNumId 0.
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
  // the renderer can preserve the bullet's intrinsic aspect, and a
  // DrawingML `<a:blip r:embed>` so the viewer's rId walk finds the
  // bullet image relationship Id.
  let blip : @xml.Element = {
    name: name("blip"),
    attributes: [rel_attr("embed", "rIdBullet")],
    children: [],
  }
  let blip_fill : @xml.Element = {
    name: name("blipFill"),
    attributes: [],
    children: [@xml.Node::Element(blip)],
  }
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
              @xml.Node::Element(blip_fill),
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
/// A part-aware `image_resolver` that returns the bullet PNG only when
/// asked for `rIdBullet` scoped to the NUMBERING part token — proving
/// picture bullets fold through the unified resolver (the viewer walks
/// the numPicBullet to `rIdBullet` and resolves it against the
/// numbering part).
fn bullet_image_resolver(part : String, rid : String) -> ResolvedImage? {
  if part == bullet_numbering_part && rid == "rIdBullet" {
    Some({ mime_type: "image/png", base64_data: pic_bullet_test_b64 })
  } else {
    None
  }
}

///|
/// §17.9.9 / §17.9.20 — with the numbering part token wired and a
/// part-aware `image_resolver` that resolves the numPicBullet's
/// `rIdBullet` against the numbering part, the numbered paragraph
/// renders an `<image>` glyph carrying that data URI at the bullet
/// position, and the §17.9.11 lvlText placeholder `o ` text marker is
/// NOT emitted for the level.
test "render_svg renders <w:lvlPicBulletId> picture bullet as <image>" {
  let numbering = pic_bullet_numbering()
  let document = pic_bullet_document("Item")
  let expected_href = "data:image/png;base64," + pic_bullet_test_b64
  let svg = render_svg(
      document,
      numbering=Some(numbering),
      numbering_part=bullet_numbering_part,
      image_resolver=bullet_image_resolver,
    ).pages[0].svg
  // The bullet is emitted as an <image> element with the resolved
  // data URI href.
  assert_true(svg.contains("<image"))
  assert_true(svg.contains("href=\"" + expected_href + "\""))
  // The run text still renders after the bullet.
  assert_true(svg.contains("Item"))
  // The §17.9.11 lvlText marker for THIS level ("o" + trailing space)
  // must NOT be emitted as a <text> run — the picture replaces it.
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
/// §17.9 — without a resolvable picture bullet (the default resolver,
/// or one that resolves nothing for the numbering part), the SAME
/// document falls back to the §17.9.11 lvlText text marker: no
/// `<image>` bullet is emitted and the resolved `lvlText` ("o ")
/// renders as text.  This is the byte-identical pre-feature path.
test "render_svg without a resolvable picture bullet renders the text marker" {
  let numbering = pic_bullet_numbering()
  let document = pic_bullet_document("Item")
  // Default resolver (none supplied).
  let svg_default = render_svg(
      document,
      numbering=Some(numbering),
      numbering_part=bullet_numbering_part,
    ).pages[0].svg
  // No picture bullet image is emitted.
  assert_false(
    svg_default.contains("data:image/png;base64," + pic_bullet_test_b64),
  )
  // The lvlText marker "o" renders as a glyph instead.
  assert_true(svg_default.contains("Item"))
  assert_true(svg_default.contains(">o <"))

  // A resolver that resolves nothing for this part / rId behaves
  // identically to the default (the byte-identical fallback contract).
  let none_resolver = fn(_part : String, _rid : String) -> ResolvedImage? {
    None
  }
  let svg_none = render_svg(
      document,
      numbering=Some(numbering),
      numbering_part=bullet_numbering_part,
      image_resolver=none_resolver,
    ).pages[0].svg
  assert_eq(svg_none, svg_default)

  // And supplying the real resolver DOES change the output (sanity:
  // the feature is actually gated on the resolver, not always-on).
  let svg_pic = render_svg(
      document,
      numbering=Some(numbering),
      numbering_part=bullet_numbering_part,
      image_resolver=bullet_image_resolver,
    ).pages[0].svg
  assert_not_eq(svg_pic, svg_default)
}
