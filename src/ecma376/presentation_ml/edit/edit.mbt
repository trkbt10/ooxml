// edit.mbt — B-layer mutators for the PresentationML context.
// Every function here consumes a `@pml_context.Presentation`,
// applies a mutation composed exclusively from A-layer primitives,
// and returns a new context. No method is defined directly on
// `Presentation` (MoonBit cannot define extension methods across
// packages); callers invoke `@add_textbox(pml_edit, p, ...)` etc.

///|
/// PresentationML edit package marker.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/edit"
}

///|
using @pml_context {type Presentation}

///|
using @pml_context {type OpenError}

///|
using @pml_context {type SlidePart}

///|
/// Add a §19.3.1.43 `<p:sp>` text-box shape to slide `slide_index`.
/// `x`/`y`/`w`/`h` are in EMU (914400 EMU per inch).  Returns a new
/// Presentation; the original is unchanged.
pub fn add_textbox(
  presentation : Presentation,
  slide_index : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
) -> Presentation raise OpenError {
  let p_qn : @xml.QName = {
    prefix: Some("p"),
    local_name: "sp",
    ns: Some("http://schemas.openxmlformats.org/presentationml/2006/main"),
  }
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "p",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  // <a:t>text</a:t>.  §22.9.2.4 ST_String / XML 1.0 §3.3.3 —
  // when the literal text begins or ends with ASCII whitespace
  // we MUST emit `xml:space="preserve"` so the whitespace
  // survives XML normalisation on round-trip.
  let t_base = @edit.empty_element(a_qn, "t")
  let t_elt_with_space = if needs_xml_space_preserve(text) {
    let xml_qn : @xml.QName = {
      prefix: Some("xml"),
      local_name: "space",
      ns: Some("http://www.w3.org/XML/1998/namespace"),
    }
    @edit.set_attribute(t_base, { name: xml_qn, value: "preserve" })
  } else {
    t_base
  }
  let t_elt = @edit.append_child(
    t_elt_with_space,
    @xml.Node::Text(text),
  )
  // <a:r><a:t/></a:r>
  let r_elt = @edit.append_child(
    @edit.empty_element(a_qn, "r"),
    @xml.Node::Element(t_elt),
  )
  // <a:p><a:r/></a:p>
  let p_elt = @edit.append_child(
    @edit.empty_element(a_qn, "p"),
    @xml.Node::Element(r_elt),
  )
  // <p:txBody><a:bodyPr/><a:lstStyle/><a:p>...</a:p></p:txBody>
  let body_pr = @edit.empty_element(a_qn, "bodyPr")
  let lst_style = @edit.empty_element(a_qn, "lstStyle")
  let tx_body = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(p_qn, "txBody"),
        @xml.Node::Element(body_pr),
      ),
      @xml.Node::Element(lst_style),
    ),
    @xml.Node::Element(p_elt),
  )
  // <p:spPr><a:xfrm><a:off x= y=/><a:ext cx= cy=/></a:xfrm></p:spPr>
  let off = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "off"),
      @edit.unprefixed_attribute("x", x.to_string()),
    ),
    @edit.unprefixed_attribute("y", y.to_string()),
  )
  let ext = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "ext"),
      @edit.unprefixed_attribute("cx", w.to_string()),
    ),
    @edit.unprefixed_attribute("cy", h.to_string()),
  )
  let xfrm = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(a_qn, "xfrm"),
      @xml.Node::Element(off),
    ),
    @xml.Node::Element(ext),
  )
  let sp_pr = @edit.append_child(
    @edit.empty_element(p_qn, "spPr"),
    @xml.Node::Element(xfrm),
  )
  // §19.3.1.12 / §20.4.2.5 ST_DrawingElementId — `cNvPr/@id`
  // MUST be unique per slide.  Resolve the slide's current max
  // id by inspecting the existing spTree before insertion.
  let allocated_id = next_drawing_id_for_slide(presentation, slide_index)
  let c_nv_pr = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(p_qn, "cNvPr"),
      @edit.unprefixed_attribute("id", allocated_id.to_string()),
    ),
    @edit.unprefixed_attribute(
      "name", "TextBox " + allocated_id.to_string(),
    ),
  )
  let c_nv_sp_pr = @edit.set_attribute(
    @edit.empty_element(p_qn, "cNvSpPr"),
    @edit.unprefixed_attribute("txBox", "1"),
  )
  let nv_pr = @edit.empty_element(p_qn, "nvPr")
  let nv_sp_pr = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(p_qn, "nvSpPr"),
        @xml.Node::Element(c_nv_pr),
      ),
      @xml.Node::Element(c_nv_sp_pr),
    ),
    @xml.Node::Element(nv_pr),
  )
  let sp = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(p_qn, "sp"),
        @xml.Node::Element(nv_sp_pr),
      ),
      @xml.Node::Element(sp_pr),
    ),
    @xml.Node::Element(tx_body),
  )
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      @edit.append_child(sp_tree, @xml.Node::Element(sp))
    })
  })
}

///|
/// Set the §20.1.7.6 `<a:xfrm>/<a:off>/<a:ext>` coordinates of the
/// `shape_index`-th shape on `slide_index`. `shape_index` counts
/// direct children of `<p:spTree>` (sp / pic / grpSp / cxnSp).
pub fn set_shape_xfrm(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Presentation raise OpenError {
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "xfrm",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      let mut counter = 0
      let new_children : Array[@xml.Node] = []
      for child in sp_tree.children {
        match child {
          @xml.Element(e) =>
            if is_pml_shape_local_name(e.name.local_name) {
              if counter == shape_index {
                let patched = patch_shape_xfrm(e, a_qn, x, y, w, h)
                new_children.push(@xml.Node::Element(patched))
              } else {
                new_children.push(child)
              }
              counter = counter + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      {
        name: sp_tree.name,
        attributes: sp_tree.attributes,
        children: new_children,
      }
    })
  })
}

///|
/// Remove the `shape_index`-th shape (counting direct spTree
/// children) from `slide_index`. No-op on out-of-range indices.
pub fn remove_shape(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
) -> Presentation raise OpenError {
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      let mut counter = 0
      let new_children : Array[@xml.Node] = []
      for child in sp_tree.children {
        match child {
          @xml.Element(e) =>
            if is_pml_shape_local_name(e.name.local_name) {
              if counter != shape_index {
                new_children.push(child)
              }
              counter = counter + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      {
        name: sp_tree.name,
        attributes: sp_tree.attributes,
        children: new_children,
      }
    })
  })
}

///|
/// Add a §19.3.1.37 `<p:pic>` picture shape to slide `slide_index`,
/// embedding `image_bytes` as a new `/ppt/media/imageN.*` part with
/// `mime_type` content type. The new part is wired through a fresh
/// slide-rel so save/open round-trip preserves the image. Sizes are
/// in EMU.
pub fn add_picture(
  presentation : Presentation,
  slide_index : Int,
  image_bytes : Bytes,
  mime_type : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Presentation raise OpenError {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  // §17.16 / ECMA-376 Part 2 §10.1.2 — pick the file extension
  // that matches the source MIME so the OPC `[Content_Types].xml`
  // `<Default Extension>` map can locate the part.  Mirrors the
  // WML side's table verbatim so the same image inserted via
  // either API gets the same extension.  Vendor-specific MIMEs
  // fall through to `bin`; the caller must register an explicit
  // OPC `<Override PartName>` entry to pair with the bin part.
  let extension = match mime_type {
    "image/png" => "png"
    "image/jpeg" => "jpg"
    "image/jpg" => "jpg"
    "image/gif" => "gif"
    "image/bmp" => "bmp"
    "image/x-bmp" => "bmp"
    "image/x-ms-bmp" => "bmp"
    "image/webp" => "webp"
    "image/tiff" => "tif"
    "image/x-tiff" => "tif"
    "image/svg+xml" => "svg"
    "image/x-emf" => "emf"
    "image/emf" => "emf"
    "image/x-wmf" => "wmf"
    "image/wmf" => "wmf"
    "image/x-pict" => "pict"
    "image/x-pcx" => "pcx"
    "image/x-targa" => "tga"
    "image/x-tga" => "tga"
    "image/x-eps" => "eps"
    "image/eps" => "eps"
    "application/postscript" => "eps"
    _ => "bin"
  }
  // Allocate /ppt/media/imageN.<ext>; scan existing media parts to
  // find the next index.
  let mut max_index = 0
  for part in presentation.package.parts {
    let prefix = "/ppt/media/image"
    if part.name.has_prefix(prefix) {
      let rest = part.name[prefix.length():].to_owned()
      let dot = find_char(rest, '.')
      if dot > 0 {
        let head = rest[0:dot].to_owned()
        let parsed = Some(@strconv.parse_int(head)) catch { _ => None }
        match parsed {
          Some(n) => if n > max_index { max_index = n }
          None => ()
        }
      }
    }
  }
  let media_part_name = "/ppt/media/image" +
    (max_index + 1).to_string() +
    "." +
    extension
  // Add part + relationship under the slide.
  let slide_part_name = presentation.slides[slide_index].name
  let existing_rels = match
    presentation.package.relationships(slide_part_name) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut max_rid = 0
  for r in existing_rels {
    if r.id.has_prefix("rId") {
      let parsed = Some(@strconv.parse_int(r.id[3:].to_owned())) catch {
        _ => None
      }
      match parsed {
        Some(n) => if n > max_rid { max_rid = n }
        None => ()
      }
    }
  }
  let new_rid = "rId" + (max_rid + 1).to_string()
  // Compute the relative target from the slide part to the media part.
  // /ppt/slides/slideN.xml -> ../media/imageM.<ext>
  let rel_target = "../media/image" +
    (max_index + 1).to_string() +
    "." +
    extension
  let pkg2 = try {
    let pkg_with_part = presentation.package.add_part(
      media_part_name, mime_type, image_bytes,
    )
    pkg_with_part.with_relationship(
      slide_part_name, new_rid, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
      rel_target,
    )
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @pml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  // Build the <p:pic> element with the new rId reference.
  let p_qn : @xml.QName = {
    prefix: Some("p"),
    local_name: "pic",
    ns: Some("http://schemas.openxmlformats.org/presentationml/2006/main"),
  }
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "blip",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  let r_qn : @xml.QName = {
    prefix: Some("r"),
    local_name: "embed",
    ns: Some(
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    ),
  }
  // <a:blip r:embed="rId"/>
  let blip = @edit.set_attribute(@edit.empty_element(a_qn, "blip"), {
    name: r_qn,
    value: new_rid,
  })
  // <a:stretch><a:fillRect/></a:stretch>
  let stretch = @edit.append_child(
    @edit.empty_element(a_qn, "stretch"),
    @xml.Node::Element(@edit.empty_element(a_qn, "fillRect")),
  )
  // <p:blipFill><a:blip/><a:stretch/></p:blipFill>
  let blip_fill = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(p_qn, "blipFill"),
      @xml.Node::Element(blip),
    ),
    @xml.Node::Element(stretch),
  )
  // xfrm with off/ext
  let off = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "off"),
      @edit.unprefixed_attribute("x", x.to_string()),
    ),
    @edit.unprefixed_attribute("y", y.to_string()),
  )
  let ext = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "ext"),
      @edit.unprefixed_attribute("cx", w.to_string()),
    ),
    @edit.unprefixed_attribute("cy", h.to_string()),
  )
  let xfrm = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(a_qn, "xfrm"),
      @xml.Node::Element(off),
    ),
    @xml.Node::Element(ext),
  )
  let prst_geom = @edit.set_attribute(
    @edit.empty_element(a_qn, "prstGeom"),
    @edit.unprefixed_attribute("prst", "rect"),
  )
  let prst_geom_with_avlst = @edit.append_child(
    prst_geom,
    @xml.Node::Element(@edit.empty_element(a_qn, "avLst")),
  )
  let sp_pr = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(p_qn, "spPr"),
      @xml.Node::Element(xfrm),
    ),
    @xml.Node::Element(prst_geom_with_avlst),
  )
  // §19.3.1.27 / §19.3.1.12 — nvPicPr block.  cNvPr/@id must
  // be unique within the slide per §20.4.2.5; allocate
  // max(existing)+1 and suffix the @name to keep accessibility
  // labels distinct across multiple inserted pictures.
  let pic_id = next_drawing_id_for_slide(presentation, slide_index)
  let c_nv_pr = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(p_qn, "cNvPr"),
      @edit.unprefixed_attribute("id", pic_id.to_string()),
    ),
    @edit.unprefixed_attribute("name", "Picture " + pic_id.to_string()),
  )
  let c_nv_pic_pr = @edit.empty_element(p_qn, "cNvPicPr")
  let nv_pr = @edit.empty_element(p_qn, "nvPr")
  let nv_pic_pr = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(p_qn, "nvPicPr"),
        @xml.Node::Element(c_nv_pr),
      ),
      @xml.Node::Element(c_nv_pic_pr),
    ),
    @xml.Node::Element(nv_pr),
  )
  let pic = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(p_qn, "pic"),
        @xml.Node::Element(nv_pic_pr),
      ),
      @xml.Node::Element(blip_fill),
    ),
    @xml.Node::Element(sp_pr),
  )
  let with_pic = edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      @edit.append_child(sp_tree, @xml.Node::Element(pic))
    })
  })
  with_package(with_pic, pkg2)
}

///|
/// Set `<a:r>` `<a:rPr>` `@b` to "1"/"0" on the run at
/// `(slide_index, shape_index, paragraph_index, run_index)`.
/// `value=true` writes `@b="1"`, false removes the attribute.
pub fn set_text_bold(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
  paragraph_index : Int,
  run_index : Int,
  value : Bool,
) -> Presentation raise OpenError {
  edit_text_run(
    presentation,
    slide_index,
    shape_index,
    paragraph_index,
    run_index,
    fn(r_pr) {
      if value {
        @edit.set_attribute(r_pr, @edit.unprefixed_attribute("b", "1"))
      } else {
        @edit.remove_attribute(r_pr, { prefix: None, local_name: "b", ns: None })
      }
    },
  )
}

///|
/// Set `<a:rPr><a:solidFill><a:srgbClr val="HEX"/></a:solidFill></a:rPr>`
/// on the targeted run. `hex` is RRGGBB without leading #.
pub fn set_text_color(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
  paragraph_index : Int,
  run_index : Int,
  hex : String,
) -> Presentation raise OpenError {
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "srgbClr",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  edit_text_run(
    presentation,
    slide_index,
    shape_index,
    paragraph_index,
    run_index,
    fn(r_pr) {
      let srgb = @edit.set_attribute(
        @edit.empty_element(a_qn, "srgbClr"),
        @edit.unprefixed_attribute("val", hex),
      )
      let solid_fill = @edit.append_child(
        @edit.empty_element(a_qn, "solidFill"),
        @xml.Node::Element(srgb),
      )
      let stripped = @edit.remove_children(
        r_pr,
        @edit.by_local_name("solidFill"),
      )
      @edit.append_child(stripped, @xml.Node::Element(solid_fill))
    },
  )
}

///|
/// Set `<a:rPr @sz="HPS_x100">` on the targeted run. `hundredths_of_pt`
/// is the ST_TextFontSize value per §17.3.1.36 (e.g. 1800 = 18 pt).
pub fn set_text_font_size(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
  paragraph_index : Int,
  run_index : Int,
  hundredths_of_pt : Int,
) -> Presentation raise OpenError {
  edit_text_run(
    presentation,
    slide_index,
    shape_index,
    paragraph_index,
    run_index,
    fn(r_pr) {
      @edit.set_attribute(
        r_pr,
        @edit.unprefixed_attribute("sz", hundredths_of_pt.to_string()),
      )
    },
  )
}

///|
/// §19.3.1.51 / §21.1.2.2 — replace the text content of the run
/// identified by `(slide_index, shape_index, paragraph_index,
/// run_index)`.  Preserves the run's `<a:rPr>` and any other
/// sibling property elements; only the `<a:t>` payload is
/// rewritten.  Emits `xml:space="preserve"` when the new text
/// has leading/trailing ASCII whitespace per §22.9.2.2 /
/// XML 1.0 §3.3.3.
pub fn replace_text_in_run(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
  paragraph_index : Int,
  run_index : Int,
  new_text : String,
) -> Presentation raise OpenError {
  let a_qn_t : @xml.QName = {
    prefix: Some("a"),
    local_name: "t",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  // Build the new <a:t> element with optional xml:space.
  let t_base = @edit.empty_element(a_qn_t, "t")
  let t_with_space = if needs_xml_space_preserve(new_text) {
    let xml_qn : @xml.QName = {
      prefix: Some("xml"),
      local_name: "space",
      ns: Some("http://www.w3.org/XML/1998/namespace"),
    }
    @edit.set_attribute(t_base, { name: xml_qn, value: "preserve" })
  } else {
    t_base
  }
  let new_t = @edit.append_child(t_with_space, @xml.Node::Text(new_text))
  // Walk to the target run and rebuild it with the new <a:t>,
  // preserving the existing <a:rPr> if present.  Other run
  // children (extLst, etc.) are dropped because they reference
  // the old text content.
  let edit_run = fn(_r_pr : @xml.Element) -> @xml.Element {
    // The signature here is run-property-focused (per
    // edit_text_run), but we need to rewrite the whole run's
    // text children.  Use the parent walker below instead.
    _r_pr
  }
  let _ = edit_run
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      let mut shape_counter = 0
      let new_children : Array[@xml.Node] = []
      for child in sp_tree.children {
        match child {
          @xml.Element(e) =>
            if is_pml_shape_local_name(e.name.local_name) {
              if shape_counter == shape_index {
                let patched = patch_shape_replace_text(
                  e, paragraph_index, run_index, new_t,
                )
                new_children.push(@xml.Node::Element(patched))
              } else {
                new_children.push(child)
              }
              shape_counter = shape_counter + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      {
        name: sp_tree.name,
        attributes: sp_tree.attributes,
        children: new_children,
      }
    })
  })
}

///|
/// Walk into a single `<p:sp>` and locate the target run by
/// (paragraph_index, run_index) under its `<p:txBody>`; replace
/// the run's `<a:t>` child with `new_t`.
fn patch_shape_replace_text(
  shape : @xml.Element,
  paragraph_index : Int,
  run_index : Int,
  new_t : @xml.Element,
) -> @xml.Element {
  let new_children : Array[@xml.Node] = []
  for child in shape.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "txBody" {
          new_children.push(
            @xml.Node::Element(
              patch_txbody_replace_text(e, paragraph_index, run_index, new_t),
            ),
          )
        } else {
          new_children.push(child)
        }
      other => new_children.push(other)
    }
  }
  { name: shape.name, attributes: shape.attributes, children: new_children }
}

///|
fn patch_txbody_replace_text(
  tx_body : @xml.Element,
  paragraph_index : Int,
  run_index : Int,
  new_t : @xml.Element,
) -> @xml.Element {
  let mut p_counter = 0
  let new_children : Array[@xml.Node] = []
  for child in tx_body.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "p" {
          if p_counter == paragraph_index {
            new_children.push(
              @xml.Node::Element(
                patch_paragraph_replace_text(e, run_index, new_t),
              ),
            )
          } else {
            new_children.push(child)
          }
          p_counter = p_counter + 1
        } else {
          new_children.push(child)
        }
      other => new_children.push(other)
    }
  }
  { name: tx_body.name, attributes: tx_body.attributes, children: new_children }
}

///|
fn patch_paragraph_replace_text(
  para : @xml.Element,
  run_index : Int,
  new_t : @xml.Element,
) -> @xml.Element {
  let mut r_counter = 0
  let new_children : Array[@xml.Node] = []
  for child in para.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "r" {
          if r_counter == run_index {
            new_children.push(
              @xml.Node::Element(patch_run_replace_text(e, new_t)),
            )
          } else {
            new_children.push(child)
          }
          r_counter = r_counter + 1
        } else {
          new_children.push(child)
        }
      other => new_children.push(other)
    }
  }
  { name: para.name, attributes: para.attributes, children: new_children }
}

///|
fn patch_run_replace_text(
  run : @xml.Element,
  new_t : @xml.Element,
) -> @xml.Element {
  // Preserve `<a:rPr>` if present (the first <a:rPr> child);
  // replace every `<a:t>` with the new one and drop other
  // run-children that reference the old text.
  let new_children : Array[@xml.Node] = []
  let mut emitted_t = false
  for child in run.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "rPr" {
          new_children.push(child)
        } else if e.name.local_name == "t" {
          if !emitted_t {
            new_children.push(@xml.Node::Element(new_t))
            emitted_t = true
          }
        } else {
          new_children.push(child)
        }
      other => new_children.push(other)
    }
  }
  if !emitted_t {
    new_children.push(@xml.Node::Element(new_t))
  }
  { name: run.name, attributes: run.attributes, children: new_children }
}

///|
/// Locate the run identified by (shape_index, paragraph_index,
/// run_index) inside slide `slide_index`'s spTree, ensure it has an
/// `<a:rPr>` child (creating one when absent), and apply `update`.
/// A-layer helper used by every set_text_* B-layer call.
pub fn edit_text_run(
  presentation : Presentation,
  slide_index : Int,
  shape_index : Int,
  paragraph_index : Int,
  run_index : Int,
  update : (@xml.Element) -> @xml.Element,
) -> Presentation raise OpenError {
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "rPr",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      let mut shape_counter = 0
      let new_children : Array[@xml.Node] = []
      for child in sp_tree.children {
        match child {
          @xml.Element(e) =>
            if is_pml_shape_local_name(e.name.local_name) {
              if shape_counter == shape_index {
                let patched = patch_shape_for_run(
                  e, paragraph_index, run_index, a_qn, update,
                )
                new_children.push(@xml.Node::Element(patched))
              } else {
                new_children.push(child)
              }
              shape_counter = shape_counter + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      {
        name: sp_tree.name,
        attributes: sp_tree.attributes,
        children: new_children,
      }
    })
  })
}

///|
/// Duplicate slide `slide_index` to a brand-new `<p:sld>` part. The
/// new slide gets a fresh OPC part name, content-type override,
/// presentation→slide relationship, and `<p:sldId>` entry. Its XML
/// payload is copied byte-for-byte from the source slide (via the
/// builder's serialize path) so any embedded text and shape tree
/// survive.
pub fn duplicate_slide(
  presentation : Presentation,
  slide_index : Int,
) -> Presentation raise OpenError {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  let source = presentation.slides[slide_index]
  // Compute a fresh part name and Id.
  let mut max_index = 0
  for slide in presentation.slides {
    let name = slide.name
    let prefix = "/ppt/slides/slide"
    let suffix = ".xml"
    if name.has_prefix(prefix) && name.has_suffix(suffix) {
      let middle = name[prefix.length():name.length() - suffix.length()].to_owned()
      let parsed = Some(@strconv.parse_int(middle)) catch { _ => None }
      match parsed {
        Some(n) => if n > max_index { max_index = n }
        None => ()
      }
    }
  }
  let new_index = max_index + 1
  let new_part_name = "/ppt/slides/slide" + new_index.to_string() + ".xml"
  let new_bytes = @pml_builder.write_sld(source.value)
  let existing_rels = match
    presentation.package.relationships(presentation.presentation_part) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut max_rid = 0
  for r in existing_rels {
    if r.id.has_prefix("rId") {
      let parsed = Some(@strconv.parse_int(r.id[3:].to_owned())) catch {
        _ => None
      }
      match parsed {
        Some(n) => if n > max_rid { max_rid = n }
        None => ()
      }
    }
  }
  let new_rid = "rId" + (max_rid + 1).to_string()
  let pkg2 = try {
    let pkg_with_part = presentation.package.add_part(
      new_part_name, "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
      new_bytes,
    )
    pkg_with_part.with_relationship(
      presentation.presentation_part,
      new_rid,
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
      "slides/slide" + new_index.to_string() + ".xml",
    )
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @pml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  // Compute next sldId.
  let mut max_sid = 255
  let existing_entries : Array[@pml.CT_SlideIdListEntry] = match
    presentation.presentation.sld_id_lst {
    Some(lst) => lst.sld_id
    None => []
  }
  for entry in existing_entries {
    for attr in entry.element.attributes {
      if attr.name.local_name == "id" && attr.name.prefix is None {
        let parsed = Some(@strconv.parse_int(attr.value)) catch { _ => None }
        match parsed {
          Some(v) => if v > max_sid { max_sid = v }
          None => ()
        }
      }
    }
  }
  let new_sid = (max_sid + 1).to_string()
  let p_qn : @xml.QName = {
    prefix: Some("p"),
    local_name: "sldId",
    ns: Some("http://schemas.openxmlformats.org/presentationml/2006/main"),
  }
  let r_qn : @xml.QName = {
    prefix: Some("r"),
    local_name: "id",
    ns: Some(
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    ),
  }
  let sld_id = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(p_qn, "sldId"),
      @edit.unprefixed_attribute("id", new_sid),
    ),
    { name: r_qn, value: new_rid },
  )
  let new_slide_part : SlidePart = { name: new_part_name, value: source.value }
  let new_slides : Array[SlidePart] = []
  for sp in presentation.slides {
    new_slides.push(sp)
  }
  new_slides.push(new_slide_part)
  let updated = edit_presentation(presentation, fn(root) {
    let hits = @edit.direct_children(root, @edit.by_local_name("sldIdLst"))
    if hits.length() == 0 {
      let list_qn = @edit.qname_like(root.name, "sldIdLst")
      let list = @edit.append_child(
        @edit.empty_element(list_qn, "sldIdLst"),
        @xml.Node::Element(sld_id),
      )
      @edit.append_child(root, @xml.Node::Element(list))
    } else {
      @edit.update_first(root, @edit.by_local_name("sldIdLst"), fn(list) {
        @edit.append_child(list, @xml.Node::Element(sld_id))
      })
    }
  })
  {
    package: pkg2,
    presentation_part: updated.presentation_part,
    presentation: updated.presentation,
    slides: new_slides,
    slide_masters: updated.slide_masters,
    slide_layouts: updated.slide_layouts,
    themes: updated.themes,
  }
}

///|
/// Move the slide at `from_index` to `to_index` in the
/// `<p:sldIdLst>` ordering. Both indices are 0-based and refer to
/// the typed `slides` array. Out-of-range / no-op cases return presentation
/// unchanged.
pub fn reorder_slides(
  presentation : Presentation,
  from_index : Int,
  to_index : Int,
) -> Presentation raise OpenError {
  if from_index < 0 ||
    from_index >= presentation.slides.length() ||
    to_index < 0 ||
    to_index >= presentation.slides.length() ||
    from_index == to_index {
    return presentation
  }
  let new_slides : Array[SlidePart] = []
  for sp in presentation.slides {
    new_slides.push(sp)
  }
  let moved = new_slides[from_index]
  let _ = new_slides.remove(from_index)
  new_slides.insert(to_index, moved)
  let updated = edit_presentation(presentation, fn(root) {
    @edit.update_first(root, @edit.by_local_name("sldIdLst"), fn(list) {
      let entries : Array[@xml.Node] = []
      let non_entries : Array[@xml.Node] = []
      for child in list.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "sldId" {
              entries.push(child)
            } else {
              non_entries.push(child)
            }
          other => non_entries.push(other)
        }
      }
      let reordered : Array[@xml.Node] = []
      let mut i = 0
      for entry in entries {
        if i == from_index {
          // skip; will reinsert below
        } else {
          reordered.push(entry)
        }
        i = i + 1
      }
      reordered.insert(to_index, entries[from_index])
      let combined : Array[@xml.Node] = []
      for e in non_entries {
        combined.push(e)
      }
      for e in reordered {
        combined.push(e)
      }
      { name: list.name, attributes: list.attributes, children: combined }
    })
  })
  {
    package: updated.package,
    presentation_part: updated.presentation_part,
    presentation: updated.presentation,
    slides: new_slides,
    slide_masters: updated.slide_masters,
    slide_layouts: updated.slide_layouts,
    themes: updated.themes,
  }
}

///|
/// Add a §20.1.2.2.10 `<p:cxnSp>` connector shape to `slide_index`.
/// `prst` is the preset connector geometry name (`straightConnector1`,
/// `bentConnector2`, etc.) per ST_ShapeType §20.1.10.55. Coordinates
/// are in EMU.
pub fn add_connector(
  presentation : Presentation,
  slide_index : Int,
  prst : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Presentation raise OpenError {
  let p_qn : @xml.QName = {
    prefix: Some("p"),
    local_name: "cxnSp",
    ns: Some("http://schemas.openxmlformats.org/presentationml/2006/main"),
  }
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "xfrm",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  let off = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "off"),
      @edit.unprefixed_attribute("x", x.to_string()),
    ),
    @edit.unprefixed_attribute("y", y.to_string()),
  )
  let ext = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "ext"),
      @edit.unprefixed_attribute("cx", w.to_string()),
    ),
    @edit.unprefixed_attribute("cy", h.to_string()),
  )
  let xfrm = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(a_qn, "xfrm"),
      @xml.Node::Element(off),
    ),
    @xml.Node::Element(ext),
  )
  let prst_geom = @edit.append_child(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "prstGeom"),
      @edit.unprefixed_attribute("prst", prst),
    ),
    @xml.Node::Element(@edit.empty_element(a_qn, "avLst")),
  )
  let sp_pr = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(p_qn, "spPr"),
      @xml.Node::Element(xfrm),
    ),
    @xml.Node::Element(prst_geom),
  )
  // §19.3.1.12 / §20.4.2.5 — cNvPr/@id unique per slide.
  let cxn_id = next_drawing_id_for_slide(presentation, slide_index)
  let c_nv_pr = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(p_qn, "cNvPr"),
      @edit.unprefixed_attribute("id", cxn_id.to_string()),
    ),
    @edit.unprefixed_attribute("name", "Connector " + cxn_id.to_string()),
  )
  let c_nv_cxn_sp_pr = @edit.empty_element(p_qn, "cNvCxnSpPr")
  let nv_pr = @edit.empty_element(p_qn, "nvPr")
  let nv_cxn_sp_pr = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(p_qn, "nvCxnSpPr"),
        @xml.Node::Element(c_nv_pr),
      ),
      @xml.Node::Element(c_nv_cxn_sp_pr),
    ),
    @xml.Node::Element(nv_pr),
  )
  let cxn_sp = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(p_qn, "cxnSp"),
      @xml.Node::Element(nv_cxn_sp_pr),
    ),
    @xml.Node::Element(sp_pr),
  )
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("spTree"), fn(sp_tree) {
      @edit.append_child(sp_tree, @xml.Node::Element(cxn_sp))
    })
  })
}

///|
/// Set the §19.3.1.1 `<p:bg>` solid-color background on slide
/// `slide_index`. `hex` is RRGGBB without leading #.
pub fn set_slide_background(
  presentation : Presentation,
  slide_index : Int,
  hex : String,
) -> Presentation raise OpenError {
  let p_qn : @xml.QName = {
    prefix: Some("p"),
    local_name: "bg",
    ns: Some("http://schemas.openxmlformats.org/presentationml/2006/main"),
  }
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "srgbClr",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  // <a:srgbClr val="HEX"/>
  let srgb = @edit.set_attribute(
    @edit.empty_element(a_qn, "srgbClr"),
    @edit.unprefixed_attribute("val", hex),
  )
  // <a:solidFill><a:srgbClr/></a:solidFill>
  let solid_fill = @edit.append_child(
    @edit.empty_element(a_qn, "solidFill"),
    @xml.Node::Element(srgb),
  )
  // <p:bgPr><a:solidFill/></p:bgPr>
  let bg_pr = @edit.append_child(
    @edit.empty_element(p_qn, "bgPr"),
    @xml.Node::Element(solid_fill),
  )
  // <p:bg><p:bgPr/></p:bg>
  let bg = @edit.append_child(
    @edit.empty_element(p_qn, "bg"),
    @xml.Node::Element(bg_pr),
  )
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("cSld"), fn(c_sld) {
      // Replace existing <p:bg> if present, else insert at position 0.
      let hits = @edit.direct_children(c_sld, @edit.by_local_name("bg"))
      if hits.length() == 0 {
        @edit.insert_child(c_sld, 0, @xml.Node::Element(bg))
      } else {
        @edit.replace_children(c_sld, @edit.by_local_name("bg"), bg)
      }
    })
  })
}

///|
/// Repoint slide `slide_index` at `layout_index` (0-based, refers to
/// `presentation.slide_layouts`). Rewrites the slide→layout relationship and
/// validates that the requested layout exists. The slide's typed
/// projection stays the same — the rels table is the source of truth
/// for the layout binding.
pub fn set_slide_layout(
  presentation : Presentation,
  slide_index : Int,
  layout_index : Int,
) -> Presentation raise OpenError {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  if layout_index < 0 || layout_index >= presentation.slide_layouts.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slideLayout",
      reason="layout index out of range",
    )
  }
  let slide_part_name = presentation.slides[slide_index].name
  let layout_part_name = presentation.slide_layouts[layout_index].name
  let existing_rels = match
    presentation.package.relationships(slide_part_name) {
    Some(rs) => rs.relationships
    None => []
  }
  // Find and drop the existing slide→layout relationship if any.
  let mut existing_rid : String? = None
  for r in existing_rels {
    if r.type_uri.has_suffix("/slideLayout") {
      existing_rid = Some(r.id)
    }
  }
  // Allocate a fresh rId.
  let mut max_rid = 0
  for r in existing_rels {
    if r.id.has_prefix("rId") {
      let parsed = Some(@strconv.parse_int(r.id[3:].to_owned())) catch {
        _ => None
      }
      match parsed {
        Some(n) => if n > max_rid { max_rid = n }
        None => ()
      }
    }
  }
  let new_rid = "rId" + (max_rid + 1).to_string()
  // Compute the relative target from the slide part to the layout
  // part. Both live under /ppt/{slides,slideLayouts}/, so the
  // relative target is ../slideLayouts/slideLayoutN.xml.
  let layout_prefix = "/ppt/slideLayouts/"
  let rel_target = if layout_part_name.has_prefix(layout_prefix) {
    "../slideLayouts/" + layout_part_name[layout_prefix.length():].to_owned()
  } else {
    layout_part_name
  }
  let pkg2 = try {
    let without_old = match existing_rid {
      Some(rid) =>
        presentation.package.remove_relationship(slide_part_name, rid)
      None => presentation.package
    }
    without_old.with_relationship(
      slide_part_name, new_rid, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout",
      rel_target,
    )
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @pml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  with_package(presentation, pkg2)
}

///|
/// Append a §21.1.2.2.6 `<a:p>` text paragraph containing a single
/// `<a:r><a:t>text</a:t></a:r>` run at the end of the first
/// §21.1.2.1.1 `<p:txBody>` (CT_TextBody) found on slide `slide_index`
/// (0-based). Returns a new Presentation; the original is unchanged.
/// Raises OpenError when the slide has no text body to append into —
/// callers can detect this and choose to leave the slide unchanged.
pub fn append_text_to_slide(
  presentation : Presentation,
  slide_index : Int,
  text : String,
) -> Presentation raise OpenError {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  let slide_elt = presentation.slides[slide_index].value.element
  // Confirm that at least one <txBody> exists before mutating, so the
  // helper raises rather than silently no-oping on shape-less slides.
  if @edit.find_first(slide_elt, @edit.by_local_name("txBody")) is None {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide has no <a:txBody> to append into",
    )
  }
  edit_slide(presentation, slide_index, fn(root) {
    @edit.update_first(root, @edit.by_local_name("txBody"), fn(tx_body) {
      let (a_prefix, a_ns) = infer_drawingml_qname_source(tx_body)
      let template_qn : @xml.QName = {
        prefix: a_prefix,
        local_name: "p",
        ns: a_ns,
      }
      // §22.9.2.2 ST_String / XML 1.0 §3.3.3 — preserve
      // whitespace in the appended text when it has leading or
      // trailing ASCII whitespace.
      let t_base = @edit.empty_element(template_qn, "t")
      let t_styled = if needs_xml_space_preserve(text) {
        let xml_qn : @xml.QName = {
          prefix: Some("xml"),
          local_name: "space",
          ns: Some("http://www.w3.org/XML/1998/namespace"),
        }
        @edit.set_attribute(t_base, { name: xml_qn, value: "preserve" })
      } else {
        t_base
      }
      let t = @edit.append_child(t_styled, @xml.Node::Text(text))
      let r = @edit.append_child(
        @edit.empty_element(template_qn, "r"),
        @xml.Node::Element(t),
      )
      let p = @edit.append_child(
        @edit.empty_element(template_qn, "p"),
        @xml.Node::Element(r),
      )
      @edit.append_child(tx_body, @xml.Node::Element(p))
    })
  })
}

///|
/// A-layer primitive on Presentation. Apply `transform` to the
/// `<p:sld>` element of slide `slide_index` (0-based) and re-parse the
/// typed `CT_Slide`. Funnel point for every per-slide mutating
/// helper.
pub fn edit_slide(
  presentation : Presentation,
  slide_index : Int,
  transform : (@xml.Element) -> @xml.Element,
) -> Presentation raise OpenError {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  let target = presentation.slides[slide_index]
  let new_element = transform(target.value.element)
  let new_value = @pml.CT_Slide::new(new_element)
  let new_slides : Array[SlidePart] = []
  let mut i = 0
  for sp in presentation.slides {
    if i == slide_index {
      new_slides.push({ name: sp.name, value: new_value })
    } else {
      new_slides.push(sp)
    }
    i = i + 1
  }
  {
    package: presentation.package,
    presentation_part: presentation.presentation_part,
    presentation: presentation.presentation,
    slides: new_slides,
    slide_masters: presentation.slide_masters,
    slide_layouts: presentation.slide_layouts,
    themes: presentation.themes,
  }
}

///|
/// A-layer primitive on Presentation. Apply `transform` to the
/// `<p:presentation>` element and re-parse the typed
/// `CT_Presentation`. Funnel point for `append_slide`, `remove_slide`,
/// and any other helper that mutates `/ppt/presentation.xml`.
pub fn edit_presentation(
  presentation : Presentation,
  transform : (@xml.Element) -> @xml.Element,
) -> Presentation {
  let new_element = transform(presentation.presentation.element)
  let new_presentation = @pml.CT_Presentation::new(new_element)
  {
    package: presentation.package,
    presentation_part: presentation.presentation_part,
    presentation: new_presentation,
    slides: presentation.slides,
    slide_masters: presentation.slide_masters,
    slide_layouts: presentation.slide_layouts,
    themes: presentation.themes,
  }
}

///|
/// A-layer primitive: install a new OPC package after add_part /
/// with_relationship calls.
pub fn with_package(
  presentation : Presentation,
  package : @opc.Package,
) -> Presentation {
  {
    package,
    presentation_part: presentation.presentation_part,
    presentation: presentation.presentation,
    slides: presentation.slides,
    slide_masters: presentation.slide_masters,
    slide_layouts: presentation.slide_layouts,
    themes: presentation.themes,
  }
}

///|
/// Append a brand-new §19.3.1.38 `<p:sld>` slide part to the
/// presentation. Creates the part (`/ppt/slides/slideN.xml`),
/// registers a §10.1.2.3 Content_Types Override
/// (`application/vnd.openxmlformats-officedocument.presentationml.slide+xml`),
/// adds a relationship from the presentation part to the new slide,
/// and appends a §19.2.1.33 `<p:sldId>` entry to the presentation's
/// `<p:sldIdLst>` (creating the list when absent). Returns a new
/// Presentation; the original is unchanged. The new slide carries a
/// single empty `<p:txBody>` so subsequent `append_text_to_slide`
/// calls have a target.
pub fn append_slide(
  presentation : Presentation,
) -> Presentation raise OpenError {
  // Compute the next slide part name (slide1, slide2, ...).
  let mut max_index = 0
  for slide in presentation.slides {
    let name = slide.name
    let prefix = "/ppt/slides/slide"
    let suffix = ".xml"
    if name.has_prefix(prefix) && name.has_suffix(suffix) {
      let middle = name[prefix.length():name.length() - suffix.length()].to_owned()
      let parsed = Some(@strconv.parse_int(middle)) catch { _ => None }
      match parsed {
        Some(n) => if n > max_index { max_index = n }
        None => ()
      }
    }
  }
  let new_index = max_index + 1
  let new_part_name = "/ppt/slides/slide" + new_index.to_string() + ".xml"

  // Build a minimal CT_Slide element. The slide carries a single
  // sp/txBody so append_text_to_slide has something to target.
  let p_ns = Some("http://schemas.openxmlformats.org/presentationml/2006/main")
  let a_ns = Some("http://schemas.openxmlformats.org/drawingml/2006/main")
  let p_qn = fn(name : String) -> @xml.QName {
    { prefix: Some("p"), local_name: name, ns: p_ns }
  }
  let a_qn = fn(name : String) -> @xml.QName {
    { prefix: Some("a"), local_name: name, ns: a_ns }
  }
  let body_p : @xml.Element = { name: a_qn("p"), attributes: [], children: [] }
  let tx_body : @xml.Element = {
    name: p_qn("txBody"),
    attributes: [],
    children: [
      @xml.Node::Element({ name: a_qn("bodyPr"), attributes: [], children: [] }),
      @xml.Node::Element({
        name: a_qn("lstStyle"),
        attributes: [],
        children: [],
      }),
      @xml.Node::Element(body_p),
    ],
  }
  let sp : @xml.Element = {
    name: p_qn("sp"),
    attributes: [],
    children: [@xml.Node::Element(tx_body)],
  }
  let sp_tree : @xml.Element = {
    name: p_qn("spTree"),
    attributes: [],
    children: [@xml.Node::Element(sp)],
  }
  let c_sld : @xml.Element = {
    name: p_qn("cSld"),
    attributes: [],
    children: [@xml.Node::Element(sp_tree)],
  }
  let sld_attrs : Array[@xml.Attribute] = [
    {
      name: {
        prefix: Some("xmlns"),
        local_name: "p",
        ns: Some("http://www.w3.org/2000/xmlns/"),
      },
      value: "http://schemas.openxmlformats.org/presentationml/2006/main",
    },
    {
      name: {
        prefix: Some("xmlns"),
        local_name: "a",
        ns: Some("http://www.w3.org/2000/xmlns/"),
      },
      value: "http://schemas.openxmlformats.org/drawingml/2006/main",
    },
  ]
  let sld_element : @xml.Element = {
    name: p_qn("sld"),
    attributes: sld_attrs,
    children: [@xml.Node::Element(c_sld)],
  }
  let new_slide = @pml.CT_Slide::new(sld_element)
  let sld_bytes = @pml_builder.write_sld(new_slide)

  // Compute a fresh relationship Id for the presentation rels.
  let existing_rels = match
    presentation.package.relationships(presentation.presentation_part) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut max_rid = 0
  for r in existing_rels {
    if r.id.has_prefix("rId") {
      let parsed = Some(@strconv.parse_int(r.id[3:].to_owned())) catch {
        _ => None
      }
      match parsed {
        Some(n) => if n > max_rid { max_rid = n }
        None => ()
      }
    }
  }
  let new_rid = "rId" + (max_rid + 1).to_string()

  // Update the OPC package: new part, content-type override, rel.
  let pkg2 = try {
    let pkg_with_part = presentation.package.add_part(
      new_part_name, "application/vnd.openxmlformats-officedocument.presentationml.slide+xml",
      sld_bytes,
    )
    pkg_with_part.with_relationship(
      presentation.presentation_part,
      new_rid,
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide",
      "slides/slide" + new_index.to_string() + ".xml",
    )
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @pml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }

  // Splice a <p:sldId> into the presentation element's <p:sldIdLst>.
  // Compute a fresh slide id (>= 256, < 2^31 per ST_SlideId §19.7.13).
  let mut max_sid = 255
  let existing_entries : Array[@pml.CT_SlideIdListEntry] = match
    presentation.presentation.sld_id_lst {
    Some(lst) => lst.sld_id
    None => []
  }
  for entry in existing_entries {
    for attr in entry.element.attributes {
      if attr.name.local_name == "id" && attr.name.prefix is None {
        let parsed = Some(@strconv.parse_int(attr.value)) catch { _ => None }
        match parsed {
          Some(v) => if v > max_sid { max_sid = v }
          None => ()
        }
      }
    }
  }
  let new_sid = (max_sid + 1).to_string()
  let presentation_element = presentation.presentation.element
  let new_presentation_children : Array[@xml.Node] = []
  let mut sld_id_lst_seen = false
  for child in presentation_element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "sldIdLst" {
          sld_id_lst_seen = true
          let new_id_children : Array[@xml.Node] = []
          for c in e.children {
            new_id_children.push(c)
          }
          let sld_id_attrs : Array[@xml.Attribute] = [
            {
              name: { prefix: None, local_name: "id", ns: None },
              value: new_sid,
            },
            {
              name: {
                prefix: Some("r"),
                local_name: "id",
                ns: Some(
                  "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
                ),
              },
              value: new_rid,
            },
          ]
          let sld_id_entry : @xml.Element = {
            name: p_qn("sldId"),
            attributes: sld_id_attrs,
            children: [],
          }
          new_id_children.push(@xml.Node::Element(sld_id_entry))
          let patched : @xml.Element = {
            name: e.name,
            attributes: e.attributes,
            children: new_id_children,
          }
          new_presentation_children.push(@xml.Node::Element(patched))
        } else {
          new_presentation_children.push(@xml.Node::Element(e))
        }
      other => new_presentation_children.push(other)
    }
  }
  if !sld_id_lst_seen {
    let sld_id_attrs : Array[@xml.Attribute] = [
      { name: { prefix: None, local_name: "id", ns: None }, value: new_sid },
      {
        name: {
          prefix: Some("r"),
          local_name: "id",
          ns: Some(
            "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
          ),
        },
        value: new_rid,
      },
    ]
    let sld_id_entry : @xml.Element = {
      name: p_qn("sldId"),
      attributes: sld_id_attrs,
      children: [],
    }
    let sld_id_lst : @xml.Element = {
      name: p_qn("sldIdLst"),
      attributes: [],
      children: [@xml.Node::Element(sld_id_entry)],
    }
    new_presentation_children.push(@xml.Node::Element(sld_id_lst))
  }
  let new_presentation_element : @xml.Element = {
    name: presentation_element.name,
    attributes: presentation_element.attributes,
    children: new_presentation_children,
  }
  let new_presentation = @pml.CT_Presentation::new(new_presentation_element)
  let new_slide_part : SlidePart = { name: new_part_name, value: new_slide }
  let new_slides : Array[SlidePart] = []
  for sp in presentation.slides {
    new_slides.push(sp)
  }
  new_slides.push(new_slide_part)
  {
    package: pkg2,
    presentation_part: presentation.presentation_part,
    presentation: new_presentation,
    slides: new_slides,
    slide_masters: presentation.slide_masters,
    slide_layouts: presentation.slide_layouts,
    themes: presentation.themes,
  }
}

///|
/// Remove a slide part from the presentation. Drops the slide from
/// the OPC parts list, removes its Content_Types Override, deletes
/// the matching `<p:sldId>` from `<p:sldIdLst>`, and removes the
/// corresponding relationship from the presentation's .rels.
/// `slide_index` is 0-based.
pub fn remove_slide(
  presentation : Presentation,
  slide_index : Int,
) -> Presentation raise OpenError {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    raise @pml_context.OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  let target = presentation.slides[slide_index]
  let target_name = target.name
  // Resolve the rel Id that points to this slide.
  let existing_rels = match
    presentation.package.relationships(presentation.presentation_part) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut target_rid : String? = None
  for r in existing_rels {
    let resolved = Some(
      @opc_part_name.resolve_target(presentation.presentation_part, r.target),
    ) catch {
      _ => None
    }
    match resolved {
      Some(name) => if name == target_name { target_rid = Some(r.id) }
      None => ()
    }
  }
  // Strip the sld_id entry and patch the presentation element.
  let presentation_element = presentation.presentation.element
  let p_ns = Some("http://schemas.openxmlformats.org/presentationml/2006/main")
  let p_qn = fn(name : String) -> @xml.QName {
    { prefix: Some("p"), local_name: name, ns: p_ns }
  }
  let _ = p_qn
  let new_presentation_children : Array[@xml.Node] = []
  for child in presentation_element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "sldIdLst" {
          let new_id_children : Array[@xml.Node] = []
          for c in e.children {
            match c {
              @xml.Element(entry) =>
                if entry.name.local_name == "sldId" {
                  let mut keep = true
                  match target_rid {
                    Some(rid) =>
                      for attr in entry.attributes {
                        if attr.name.local_name == "id" &&
                          (match attr.name.prefix {
                            Some("r") => true
                            _ => false
                          }) &&
                          attr.value == rid {
                          keep = false
                        }
                      }
                    None => ()
                  }
                  if keep {
                    new_id_children.push(c)
                  }
                } else {
                  new_id_children.push(c)
                }
              other => new_id_children.push(other)
            }
          }
          let patched : @xml.Element = {
            name: e.name,
            attributes: e.attributes,
            children: new_id_children,
          }
          new_presentation_children.push(@xml.Node::Element(patched))
        } else {
          new_presentation_children.push(@xml.Node::Element(e))
        }
      other => new_presentation_children.push(other)
    }
  }
  let new_presentation_element : @xml.Element = {
    name: presentation_element.name,
    attributes: presentation_element.attributes,
    children: new_presentation_children,
  }
  let new_presentation = @pml.CT_Presentation::new(new_presentation_element)
  let pkg2 = try {
    let pkg_no_rel = match target_rid {
      Some(rid) =>
        presentation.package.remove_relationship(
          presentation.presentation_part,
          rid,
        )
      None => presentation.package
    }
    pkg_no_rel.remove_part(target_name)
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @pml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  let new_slides : Array[SlidePart] = []
  let mut i = 0
  for sp in presentation.slides {
    if i != slide_index {
      new_slides.push(sp)
    }
    i = i + 1
  }
  {
    package: pkg2,
    presentation_part: presentation.presentation_part,
    presentation: new_presentation,
    slides: new_slides,
    slide_masters: presentation.slide_masters,
    slide_layouts: presentation.slide_layouts,
    themes: presentation.themes,
  }
}

///|
fn patch_shape_xfrm(
  shape : @xml.Element,
  a_qn : @xml.QName,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> @xml.Element {
  // Build off/ext.
  let off = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "off"),
      @edit.unprefixed_attribute("x", x.to_string()),
    ),
    @edit.unprefixed_attribute("y", y.to_string()),
  )
  let ext = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "ext"),
      @edit.unprefixed_attribute("cx", w.to_string()),
    ),
    @edit.unprefixed_attribute("cy", h.to_string()),
  )
  let xfrm = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(a_qn, "xfrm"),
      @xml.Node::Element(off),
    ),
    @xml.Node::Element(ext),
  )
  @edit.update_first(shape, @edit.by_local_name("spPr"), fn(sp_pr) {
    let xfrm_hits = @edit.direct_children(sp_pr, @edit.by_local_name("xfrm"))
    if xfrm_hits.length() == 0 {
      @edit.insert_child(sp_pr, 0, @xml.Node::Element(xfrm))
    } else {
      @edit.replace_children(sp_pr, @edit.by_local_name("xfrm"), xfrm)
    }
  })
}

///|
fn is_pml_shape_local_name(name : String) -> Bool {
  // §19.3.1.43 sp, §19.3.1.37 pic, §19.3.1.20 cxnSp, §19.3.1.21 grpSp,
  // §19.3.1.13 graphicFrame.
  name == "sp" ||
  name == "pic" ||
  name == "cxnSp" ||
  name == "grpSp" ||
  name == "graphicFrame"
}

///|
fn find_char(s : String, target : Char) -> Int {
  let mut i = 0
  for c in s {
    if c == target {
      return i
    }
    i = i + 1
  }
  -1
}

///|
fn patch_shape_for_run(
  shape : @xml.Element,
  paragraph_index : Int,
  run_index : Int,
  a_qn : @xml.QName,
  update : (@xml.Element) -> @xml.Element,
) -> @xml.Element {
  @edit.update_first(shape, @edit.by_local_name("txBody"), fn(tx_body) {
    let mut para_counter = 0
    let new_children : Array[@xml.Node] = []
    for child in tx_body.children {
      match child {
        @xml.Element(e) =>
          if e.name.local_name == "p" {
            if para_counter == paragraph_index {
              let patched = patch_paragraph_for_run(e, run_index, a_qn, update)
              new_children.push(@xml.Node::Element(patched))
            } else {
              new_children.push(child)
            }
            para_counter = para_counter + 1
          } else {
            new_children.push(child)
          }
        other => new_children.push(other)
      }
    }
    {
      name: tx_body.name,
      attributes: tx_body.attributes,
      children: new_children,
    }
  })
}

///|
fn patch_paragraph_for_run(
  paragraph : @xml.Element,
  run_index : Int,
  a_qn : @xml.QName,
  update : (@xml.Element) -> @xml.Element,
) -> @xml.Element {
  let mut counter = 0
  let new_children : Array[@xml.Node] = []
  for child in paragraph.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "r" {
          if counter == run_index {
            let r_pr_hits = @edit.direct_children(e, @edit.by_local_name("rPr"))
            let patched = if r_pr_hits.length() == 0 {
              let new_r_pr = update(@edit.empty_element(a_qn, "rPr"))
              @edit.insert_child(e, 0, @xml.Node::Element(new_r_pr))
            } else {
              @edit.update_first(e, @edit.by_local_name("rPr"), update)
            }
            new_children.push(@xml.Node::Element(patched))
          } else {
            new_children.push(child)
          }
          counter = counter + 1
        } else {
          new_children.push(child)
        }
      other => new_children.push(other)
    }
  }
  {
    name: paragraph.name,
    attributes: paragraph.attributes,
    children: new_children,
  }
}

///|
/// Look for the first `<a:*>` child of a txBody to pick up the
/// drawingML prefix/namespace already declared on the slide.
/// Defaults to ("a", drawingML main namespace) when no children exist
/// yet.
fn infer_drawingml_qname_source(txbody : @xml.Element) -> (String?, String?) {
  for child in txbody.children {
    match child {
      @xml.Element(e) => return (e.name.prefix, e.name.ns)
      _ => ()
    }
  }
  (Some("a"), Some("http://schemas.openxmlformats.org/drawingml/2006/main"))
}

///|
/// §19.3.1.12 / §20.4.2.5 — scan the slide's `<p:spTree>` for the
/// max existing `cNvPr/@id` and return `max + 1`.  When the
/// slide has no spTree (or no cNvPr children) we return `2`
/// (Office reserves id 0 for the slide root and id 1 for the
/// title placeholder).
fn next_drawing_id_for_slide(
  presentation : Presentation,
  slide_index : Int,
) -> Int {
  if slide_index < 0 || slide_index >= presentation.slides.length() {
    return 2
  }
  let slide = presentation.slides[slide_index]
  let root = slide.value.element
  let mut max_id = 1
  walk_cnv_pr_ids(root, fn(id) { if id > max_id { max_id = id } })
  max_id + 1
}

///|
fn walk_cnv_pr_ids(elt : @xml.Element, on_id : (Int) -> Unit) -> Unit {
  if elt.name.local_name == "cNvPr" {
    for a in elt.attributes {
      if a.name.local_name == "id" {
        match (try? @strconv.parse_int(a.value)) {
          Ok(n) => on_id(n)
          Err(_) => ()
        }
      }
    }
  }
  for child in elt.children {
    match child {
      @xml.Node::Element(e) => walk_cnv_pr_ids(e, on_id)
      _ => ()
    }
  }
}

///|
/// §19.3.1.51 — delegates to the shared §3.3.3 whitespace
/// predicate in the `@edit` package.  See
/// `@edit::needs_xml_space_preserve`.
fn needs_xml_space_preserve(text : String) -> Bool {
  @edit.needs_xml_space_preserve(text)
}
