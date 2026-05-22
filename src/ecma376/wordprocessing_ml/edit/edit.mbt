// edit.mbt — B-layer mutators for the WordprocessingML context.
// Top-level functions only.

///|
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/edit"
}

///|
using @wml_context {type Document}

///|
using @wml_context {type OpenError}

///|
using @wml_context {type HeaderPart}

///|
using @wml_context {type FooterPart}

///|
/// A-layer primitive on Document. Walk the main `/word/document.xml`
/// element tree through `transform` and return a Document whose
/// `main : CT_Document` has been rebuilt from the new element.
/// Every B-layer mutating helper (append_paragraph,
/// remove_paragraph, ...) must funnel through this primitive so the
/// typed projection stays in sync with the serializer output.
pub fn edit_main(
  document : Document,
  transform : (@xml.Element) -> @xml.Element,
) -> Document raise OpenError {
  let new_main_element = transform(document.main.element)
  let new_main = @wml.CT_Document::new(new_main_element) catch {
    @wml.SchemaViolation(type_name~, value~, reason~) =>
      raise @wml_context.OpenError(
        kind="SchemaViolation",
        path=type_name,
        reason=value + ": " + reason,
      )
  }
  {
    package: document.package,
    main_part: document.main_part,
    main: new_main,
    headers: document.headers,
    footers: document.footers,
    styles: document.styles,
    numbering: document.numbering,
    settings: document.settings,
    fonts: document.fonts,
    comments: document.comments,
    footnotes: document.footnotes,
    endnotes: document.endnotes,
    theme: document.theme,
  }
}

///|
/// Append a §17.3.1.22 `<w:p>` paragraph containing a single text run
/// at the end of the document body. Returns a new Document; the
/// original is unchanged. Composed from A-layer primitives:
/// `find_first` to locate the body, `append_child` to extend its
/// children, `update_first` to splice the patched body back in,
/// `edit_main` to rebuild the typed projection.
pub fn append_paragraph(
  document : Document,
  text : String,
) -> Document raise OpenError {
  if document.main.body is None {
    raise @wml_context.OpenError(
      kind="UnsupportedFeature",
      path="document",
      reason="document has no body to append into",
    )
  }
  let w_template = build_w_qname("p")
  // §17.17.3 ST_String / XML 1.0 §3.3.3 — when the literal text
  // begins or ends with ASCII whitespace we MUST emit
  // `xml:space="preserve"` so the consumer's XML parser does
  // not strip the whitespace on round-trip.
  let t_base = @edit.empty_element(w_template, "t")
  let t_element = if wml_needs_xml_space_preserve(text) {
    let xml_qn : @xml.QName = {
      prefix: Some("xml"),
      local_name: "space",
      ns: Some("http://www.w3.org/XML/1998/namespace"),
    }
    @edit.set_attribute(t_base, { name: xml_qn, value: "preserve" })
  } else {
    t_base
  }
  let t_with_text = @edit.append_child(t_element, @xml.Node::Text(text))
  let r_element = @edit.empty_element(w_template, "r")
  let r_with_t = @edit.append_child(r_element, @xml.Node::Element(t_with_text))
  let p_element = @edit.empty_element(w_template, "p")
  // §17.13.1 / §17.18.50 ST_LongHexNumber — Word stamps every
  // authored paragraph with a fresh `@w:rsidR` so track-changes
  // / merge can identify the revision session.  The spec marks
  // this attribute as optional (§17.3.1.31 CT_P), so omitting
  // it is conformant; Word will still open the document but
  // will treat the paragraph as belonging to an unknown
  // revision session.  Full rsid allocation (computing the
  // next ST_LongHexNumber and registering it in
  // `<w:settings>/<w:rsids>`) is tracked as a follow-up;
  // until then we leave the paragraph un-stamped.
  let p_with_r = @edit.append_child(p_element, @xml.Node::Element(r_with_t))
  edit_main(document, fn(root) {
    @edit.update_first(root, @edit.by_local_name("body"), fn(body) {
      @edit.append_child(body, @xml.Node::Element(p_with_r))
    })
  })
}

///|
/// Remove the block-level element at `index` (0-based, in document
/// order of `<w:body>` children) from the document. Returns a new
/// Document; the original is unchanged. Raises when the index is out
/// of range or the document has no body.
pub fn remove_paragraph(
  document : Document,
  index : Int,
) -> Document raise OpenError {
  match document.main.body {
    None =>
      raise @wml_context.OpenError(
        kind="UnsupportedFeature",
        path="document",
        reason="document has no body to remove from",
      )
    Some(body) => {
      let elts = body.block_level_elts
      if index < 0 || index >= elts.length() {
        raise @wml_context.OpenError(
          kind="UnsupportedFeature",
          path="document",
          reason="paragraph index out of range",
        )
      }
      // Translate the typed-projection index into a positional
      // counter on the body's children. The counter increments only
      // for `block_level_elts` siblings (paragraphs/tables/...) so
      // non-block nodes (sectPr / bookmarks already filtered into
      // block_level_elts upstream) are preserved untouched.
      let counter : RemoveCounter = { current: 0, target: index }
      edit_main(document, fn(root) {
        @edit.update_first(root, @edit.by_local_name("body"), fn(body_elt) {
          let new_children : Array[@xml.Node] = []
          for child in body_elt.children {
            match child {
              @xml.Element(e) =>
                if is_block_level_local_name(e.name.local_name) {
                  if counter.current != counter.target {
                    new_children.push(child)
                  }
                  counter.current = counter.current + 1
                } else {
                  new_children.push(child)
                }
              other => new_children.push(other)
            }
          }
          {
            name: body_elt.name,
            attributes: body_elt.attributes,
            children: new_children,
          }
        })
      })
    }
  }
}

///|
priv struct RemoveCounter {
  mut current : Int
  target : Int
}

///|
fn is_block_level_local_name(name : String) -> Bool {
  // §17.3.1 block-level elements that the EG_BlockLevelElts content
  // group enumerates. Keeping the exact set means non-block-level
  // siblings like `<w:sectPr>` survive remove_paragraph unchanged.
  name == "p" ||
  name == "tbl" ||
  name == "sdt" ||
  name == "customXml" ||
  name == "altChunk" ||
  name == "permStart" ||
  name == "permEnd" ||
  name == "bookmarkStart" ||
  name == "bookmarkEnd" ||
  name == "moveFromRangeStart" ||
  name == "moveFromRangeEnd" ||
  name == "moveToRangeStart" ||
  name == "moveToRangeEnd" ||
  name == "commentRangeStart" ||
  name == "commentRangeEnd" ||
  name == "customXmlInsRangeStart" ||
  name == "customXmlInsRangeEnd" ||
  name == "customXmlDelRangeStart" ||
  name == "customXmlDelRangeEnd" ||
  name == "customXmlMoveFromRangeStart" ||
  name == "customXmlMoveFromRangeEnd" ||
  name == "customXmlMoveToRangeStart" ||
  name == "customXmlMoveToRangeEnd" ||
  name == "ins" ||
  name == "del" ||
  name == "moveFrom" ||
  name == "moveTo" ||
  name == "proofErr"
}

///|
/// A-layer primitive on Document. Walk `/word/styles.xml` through
/// `transform` and rebuild the typed CT_Styles. No-op (returns document)
/// when the document has no styles part. Funnel point for
/// set_paragraph_style and any helper touching the styles table.
pub fn edit_styles(
  document : Document,
  transform : (@xml.Element) -> @xml.Element,
) -> Document raise OpenError {
  match document.styles {
    None => document
    Some(styles) => {
      let new_element = transform(styles.element)
      let new_styles = @wml.CT_Styles::new(new_element) catch {
        @wml.SchemaViolation(type_name~, value~, reason~) =>
          raise @wml_context.OpenError(
            kind="SchemaViolation",
            path=type_name,
            reason=value + ": " + reason,
          )
      }
      {
        package: document.package,
        main_part: document.main_part,
        main: document.main,
        headers: document.headers,
        footers: document.footers,
        styles: Some(new_styles),
        numbering: document.numbering,
        settings: document.settings,
        fonts: document.fonts,
        comments: document.comments,
        footnotes: document.footnotes,
        endnotes: document.endnotes,
        theme: document.theme,
      }
    }
  }
}

///|
/// A-layer primitive on Document. Walk `/word/numbering.xml` through
/// `transform` and rebuild the typed CT_Numbering. No-op when no
/// numbering part exists.
pub fn edit_numbering(
  document : Document,
  transform : (@xml.Element) -> @xml.Element,
) -> Document raise OpenError {
  match document.numbering {
    None => document
    Some(numbering) => {
      let new_element = transform(numbering.element)
      let new_numbering = @wml.CT_Numbering::parse(new_element) catch {
        @wml.SchemaViolation(type_name~, value~, reason~) =>
          raise @wml_context.OpenError(
            kind="SchemaViolation",
            path=type_name,
            reason=value + ": " + reason,
          )
      }
      {
        package: document.package,
        main_part: document.main_part,
        main: document.main,
        headers: document.headers,
        footers: document.footers,
        styles: document.styles,
        numbering: Some(new_numbering),
        settings: document.settings,
        fonts: document.fonts,
        comments: document.comments,
        footnotes: document.footnotes,
        endnotes: document.endnotes,
        theme: document.theme,
      }
    }
  }
}

///|
/// A-layer primitive: install a new OPC package after add_part /
/// with_relationship calls (e.g. embedding a picture).
pub fn with_package(document : Document, package : @opc.Package) -> Document {
  {
    package,
    main_part: document.main_part,
    main: document.main,
    headers: document.headers,
    footers: document.footers,
    styles: document.styles,
    numbering: document.numbering,
    settings: document.settings,
    fonts: document.fonts,
    comments: document.comments,
    footnotes: document.footnotes,
    endnotes: document.endnotes,
    theme: document.theme,
  }
}

///|
/// Apply `transform` to the block-level child at typed-projection
/// index `paragraph_index` (0-based, counted across
/// EG_BlockLevelElts children — paragraphs, tables, sdts, ...).
/// A-layer building block used by every per-paragraph helper.
pub fn edit_paragraph(
  document : Document,
  paragraph_index : Int,
  transform : (@xml.Element) -> @xml.Element,
) -> Document raise OpenError {
  if document.main.body is None {
    raise @wml_context.OpenError(
      kind="UnsupportedFeature",
      path="document",
      reason="document has no body",
    )
  }
  let counter : RemoveCounter = { current: 0, target: paragraph_index }
  edit_main(document, fn(root) {
    @edit.update_first(root, @edit.by_local_name("body"), fn(body) {
      let new_children : Array[@xml.Node] = []
      for child in body.children {
        match child {
          @xml.Element(e) =>
            if is_block_level_local_name(e.name.local_name) {
              if counter.current == counter.target {
                new_children.push(@xml.Node::Element(transform(e)))
              } else {
                new_children.push(child)
              }
              counter.current = counter.current + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      { name: body.name, attributes: body.attributes, children: new_children }
    })
  })
}

///|
/// Set §17.3.1.13 `<w:jc>` justification on paragraph `index`.
/// `value` is an ST_Jc token (§17.18.44).  The spec enumeration
/// is `start / center / end / both / numTab / mediumKashida /
/// distribute / highKashida / lowKashida / thaiDistribute`.
/// The transitional aliases `left` / `right` are accepted and
/// normalised to `start` / `end` so callers using the legacy
/// names still emit conformant XML.  Any value outside the
/// enumeration raises `OpenError` rather than writing an
/// invalid attribute.
pub fn set_paragraph_alignment(
  document : Document,
  index : Int,
  value : String,
) -> Document raise OpenError {
  // §17.18.44 — normalise transitional aliases, then validate.
  let value = match value {
    "left" => "start"
    "right" => "end"
    other => other
  }
  match value {
    "start" | "center" | "end" | "both" | "numTab" | "mediumKashida"
    | "distribute" | "highKashida" | "lowKashida" | "thaiDistribute" => ()
    other =>
      raise @wml_context.OpenError(
        kind="SchemaViolation",
        path="w:jc/@val",
        reason="'" + other + "' is not a valid ST_Jc value (§17.18.44)",
      )
  }
  let w_template = build_w_qname("p")
  edit_paragraph(document, index, fn(p) {
    let p_pr = match @edit.find_first(p, @edit.by_local_name("pPr")) {
      Some(existing) =>
        @edit.update_first(p, @edit.by_local_name("pPr"), fn(pr) {
          let jc_existing = @edit.direct_children(pr, @edit.by_local_name("jc"))
          let jc_template = @edit.qname_like(w_template, "jc")
          let jc = @edit.set_attribute(@edit.empty_element(jc_template, "jc"), {
            name: {
              prefix: w_template.prefix,
              local_name: "val",
              ns: w_template.ns,
            },
            value,
          })
          if jc_existing.length() == 0 {
            @edit.append_child(pr, @xml.Node::Element(jc))
          } else {
            @edit.replace_children(pr, @edit.by_local_name("jc"), jc)
          }
        })
      None => {
        let pr = @edit.empty_element(w_template, "pPr")
        let jc = @edit.set_attribute(@edit.empty_element(w_template, "jc"), {
          name: {
            prefix: w_template.prefix,
            local_name: "val",
            ns: w_template.ns,
          },
          value,
        })
        let pr_with_jc = @edit.append_child(pr, @xml.Node::Element(jc))
        @edit.insert_child(p, 0, @xml.Node::Element(pr_with_jc))
      }
    }
    let _ = p_pr
    p_pr
  })
}

///|
/// Set the §17.3.1.27 `<w:pStyle>` on paragraph `index`. `style_id`
/// is the ST_String value of `<w:style w:styleId="...">` in
/// `/word/styles.xml`. Creates `<w:pPr>` and/or `<w:pStyle>` when
/// absent. Does not validate that `style_id` exists in the styles
/// part — callers can call `resolve_style_by_id` to check.
pub fn set_paragraph_style(
  document : Document,
  index : Int,
  style_id : String,
) -> Document raise OpenError {
  let w_template = build_w_qname("p")
  edit_paragraph(document, index, fn(p) {
    edit_paragraph_p_pr(p, w_template, fn(p_pr) {
      let style_attr : @xml.Attribute = {
        name: {
          prefix: w_template.prefix,
          local_name: "val",
          ns: w_template.ns,
        },
        value: style_id,
      }
      let style_elt = @edit.set_attribute(
        @edit.empty_element(w_template, "pStyle"),
        style_attr,
      )
      let hits = @edit.direct_children(p_pr, @edit.by_local_name("pStyle"))
      if hits.length() == 0 {
        @edit.insert_child(p_pr, 0, @xml.Node::Element(style_elt))
      } else {
        @edit.replace_children(p_pr, @edit.by_local_name("pStyle"), style_elt)
      }
    })
  })
}

///|
/// Set `<w:b>` (bold) on run `run_index` of paragraph
/// `paragraph_index`. `value=true` writes `<w:b/>`, `false` removes
/// any existing `<w:b>` from the run's `<w:rPr>`.
pub fn set_run_bold(
  document : Document,
  paragraph_index : Int,
  run_index : Int,
  value : Bool,
) -> Document raise OpenError {
  let w_template = build_w_qname("p")
  edit_paragraph(document, paragraph_index, fn(p) {
    edit_run_r_pr(p, run_index, w_template, fn(r_pr) {
      if value {
        let b = @edit.empty_element(w_template, "b")
        let hits = @edit.direct_children(r_pr, @edit.by_local_name("b"))
        if hits.length() == 0 {
          @edit.append_child(r_pr, @xml.Node::Element(b))
        } else {
          @edit.replace_children(r_pr, @edit.by_local_name("b"), b)
        }
      } else {
        @edit.remove_children(r_pr, @edit.by_local_name("b"))
      }
    })
  })
}

///|
/// Set `<w:color w:val="HEX">` on run `run_index` of paragraph
/// `paragraph_index`. `hex` is the 6-digit RGB value without `#`
/// (e.g. `"FF0000"`), per ST_HexColor §17.18.38.
pub fn set_run_color(
  document : Document,
  paragraph_index : Int,
  run_index : Int,
  hex : String,
) -> Document raise OpenError {
  let w_template = build_w_qname("p")
  edit_paragraph(document, paragraph_index, fn(p) {
    edit_run_r_pr(p, run_index, w_template, fn(r_pr) {
      let val_attr : @xml.Attribute = {
        name: {
          prefix: w_template.prefix,
          local_name: "val",
          ns: w_template.ns,
        },
        value: hex,
      }
      let color = @edit.set_attribute(
        @edit.empty_element(w_template, "color"),
        val_attr,
      )
      let hits = @edit.direct_children(r_pr, @edit.by_local_name("color"))
      if hits.length() == 0 {
        @edit.append_child(r_pr, @xml.Node::Element(color))
      } else {
        @edit.replace_children(r_pr, @edit.by_local_name("color"), color)
      }
    })
  })
}

///|
/// Set `<w:sz w:val="HPS">` on run `run_index` of paragraph
/// `paragraph_index`. `half_points` is the ST_HpsMeasure value per
/// §17.18.43 (e.g. `24` = 12 pt). Does not affect `<w:szCs>`.
pub fn set_run_font_size(
  document : Document,
  paragraph_index : Int,
  run_index : Int,
  half_points : Int,
) -> Document raise OpenError {
  let w_template = build_w_qname("p")
  edit_paragraph(document, paragraph_index, fn(p) {
    edit_run_r_pr(p, run_index, w_template, fn(r_pr) {
      let val_attr : @xml.Attribute = {
        name: {
          prefix: w_template.prefix,
          local_name: "val",
          ns: w_template.ns,
        },
        value: half_points.to_string(),
      }
      let sz = @edit.set_attribute(
        @edit.empty_element(w_template, "sz"),
        val_attr,
      )
      let hits = @edit.direct_children(r_pr, @edit.by_local_name("sz"))
      if hits.length() == 0 {
        @edit.append_child(r_pr, @xml.Node::Element(sz))
      } else {
        @edit.replace_children(r_pr, @edit.by_local_name("sz"), sz)
      }
    })
  })
}

///|
/// Helper: apply `update` to paragraph `p`'s `<w:pPr>` element,
/// creating it as the first child when absent.
fn edit_paragraph_p_pr(
  p : @xml.Element,
  template : @xml.QName,
  update : (@xml.Element) -> @xml.Element,
) -> @xml.Element {
  let p_pr_hits = @edit.direct_children(p, @edit.by_local_name("pPr"))
  if p_pr_hits.length() == 0 {
    let new_p_pr = update(@edit.empty_element(template, "pPr"))
    @edit.insert_child(p, 0, @xml.Node::Element(new_p_pr))
  } else {
    @edit.update_first(p, @edit.by_local_name("pPr"), update)
  }
}

///|
/// Helper: locate run `run_index` (0-based, counted across direct
/// `<w:r>` children of `p`) and apply `update` to its `<w:rPr>`,
/// creating the rPr as the first child when absent.
fn edit_run_r_pr(
  p : @xml.Element,
  run_index : Int,
  template : @xml.QName,
  update : (@xml.Element) -> @xml.Element,
) -> @xml.Element {
  let mut counter = 0
  let new_children : Array[@xml.Node] = []
  for child in p.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "r" {
          if counter == run_index {
            let r_pr_hits = @edit.direct_children(e, @edit.by_local_name("rPr"))
            let new_r = if r_pr_hits.length() == 0 {
              let new_r_pr = update(@edit.empty_element(template, "rPr"))
              @edit.insert_child(e, 0, @xml.Node::Element(new_r_pr))
            } else {
              @edit.update_first(e, @edit.by_local_name("rPr"), update)
            }
            new_children.push(@xml.Node::Element(new_r))
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
  { name: p.name, attributes: p.attributes, children: new_children }
}

///|
/// Replace the text content of paragraph `index`. Drops every
/// existing `<w:r>` and installs a fresh single-run paragraph
/// carrying `text`. Preserves the paragraph's `<w:pPr>` if present.
pub fn set_paragraph_text(
  document : Document,
  index : Int,
  text : String,
) -> Document raise OpenError {
  let w_template = build_w_qname("p")
  edit_paragraph(document, index, fn(p) {
    // §17.17.3 — `build_w_t` attaches `xml:space="preserve"` so
    // leading/trailing whitespace survives the round-trip.
    let t = build_w_t(text)
    let r = @edit.append_child(
      @edit.empty_element(w_template, "r"),
      @xml.Node::Element(t),
    )
    // Drop existing runs, keep pPr.
    let stripped = @edit.remove_children(p, @edit.by_local_name("r"))
    @edit.append_child(stripped, @xml.Node::Element(r))
  })
}

///|
/// Insert a §17.16.22 `<w:hyperlink>` containing a single run with
/// `text` into paragraph `paragraph_index`. The new run is appended
/// at the end of the paragraph. A relationship is added to
/// `/word/_rels/document.xml.rels` of type `hyperlink` with
/// `targetMode="External"` pointing at `url`. The new `<w:hyperlink>`
/// carries the freshly-allocated `r:id`.
pub fn insert_hyperlink(
  document : Document,
  paragraph_index : Int,
  url : String,
  text : String,
) -> Document raise OpenError {
  // Allocate a fresh r:id under the document part.
  let owner = document.main_part
  let existing = match document.package.relationships(owner) {
    Some(rs) => rs.relationships
    None => []
  }
  // OPC §9.3.4 — relationship IDs are xsd:NMTOKEN-typed; the
  // de-facto convention is `rId` + numeric suffix, but the spec
  // allows arbitrary tokens.  Vendor-specific non-numeric tokens
  // (e.g. `rIdHyperlink`) cannot collide with our numeric
  // `rIdN` naming so we skip them silently when computing the
  // next free numeric id.  Collisions are detected at save
  // time by the relationship-rebuild pass.
  let mut max_rid = 0
  for r in existing {
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
  let pkg2 = document.package.with_relationship(
    owner,
    new_rid,
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
    url,
    target_mode=@relationships.TargetMode::External,
  ) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @wml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  // Construct <w:hyperlink r:id="..."><w:r><w:t>text</w:t></w:r></w:hyperlink>.
  let w_template = build_w_qname("p")
  let r_qn : @xml.QName = {
    prefix: Some("r"),
    local_name: "id",
    ns: Some(
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    ),
  }
  // §17.17.3 — preserve whitespace in the hyperlink display text.
  let t = build_w_t(text)
  let r = @edit.append_child(
    @edit.empty_element(w_template, "r"),
    @xml.Node::Element(t),
  )
  let hyperlink = @edit.append_child(
    @edit.set_attribute(@edit.empty_element(w_template, "hyperlink"), {
      name: r_qn,
      value: new_rid,
    }),
    @xml.Node::Element(r),
  )
  with_package(
    edit_paragraph(document, paragraph_index, fn(p) {
      @edit.append_child(p, @xml.Node::Element(hyperlink))
    }),
    pkg2,
  )
}

///|
/// Append a brand-new §17.4.38 `<w:tbl>` table with `rows` x `cols`
/// empty cells to the document body. Returns a new Document; the
/// original is unchanged.
pub fn append_table(
  document : Document,
  rows : Int,
  cols : Int,
) -> Document raise OpenError {
  if document.main.body is None {
    raise @wml_context.OpenError(
      kind="UnsupportedFeature",
      path="document",
      reason="document has no body",
    )
  }
  let w_template = build_w_qname("p")
  // <w:tc><w:p/></w:tc> -- a single empty paragraph per cell.
  let make_cell : () -> @xml.Element = fn() {
    let empty_p = @edit.empty_element(w_template, "p")
    @edit.append_child(
      @edit.empty_element(w_template, "tc"),
      @xml.Node::Element(empty_p),
    )
  }
  // <w:tr> with `cols` <w:tc> children.
  let make_row : () -> @xml.Element = fn() {
    let mut tr = @edit.empty_element(w_template, "tr")
    for _ in 0..<cols {
      tr = @edit.append_child(tr, @xml.Node::Element(make_cell()))
    }
    tr
  }
  let mut tbl = @edit.empty_element(w_template, "tbl")
  // Minimal <w:tblPr> with default style — Word inserts one for us
  // but Word also accepts tbl without tblPr; we include an empty
  // tblPr for round-trip safety.
  let tbl_pr = @edit.empty_element(w_template, "tblPr")
  let tbl_grid = @edit.empty_element(w_template, "tblGrid")
  let mut grid = tbl_grid
  for _ in 0..<cols {
    grid = @edit.append_child(
      grid,
      @xml.Node::Element(@edit.empty_element(w_template, "gridCol")),
    )
  }
  tbl = @edit.append_child(tbl, @xml.Node::Element(tbl_pr))
  tbl = @edit.append_child(tbl, @xml.Node::Element(grid))
  for _ in 0..<rows {
    tbl = @edit.append_child(tbl, @xml.Node::Element(make_row()))
  }
  edit_main(document, fn(root) {
    @edit.update_first(root, @edit.by_local_name("body"), fn(body) {
      @edit.append_child(body, @xml.Node::Element(tbl))
    })
  })
}

///|
/// Remove the `table_index`-th `<w:tbl>` (0-based, counted across
/// the body's direct children) from the document body.
pub fn remove_table(
  document : Document,
  table_index : Int,
) -> Document raise OpenError {
  let counter : RemoveCounter = { current: 0, target: table_index }
  edit_main(document, fn(root) {
    @edit.update_first(root, @edit.by_local_name("body"), fn(body) {
      let new_children : Array[@xml.Node] = []
      for child in body.children {
        match child {
          @xml.Element(e) =>
            if e.name.local_name == "tbl" {
              if counter.current != counter.target {
                new_children.push(child)
              }
              counter.current = counter.current + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      { name: body.name, attributes: body.attributes, children: new_children }
    })
  })
}

///|
/// Insert a picture into paragraph `paragraph_index`. The picture
/// bytes are added as `/word/media/imageN.<ext>` via the OPC primitive
/// `add_part`, registered with a `hyperlink`-style relationship to the
/// document part, and referenced from a §17.3.3.9 `<w:drawing>` /
/// §20.4 picture frame inside the run. `width_emu`/`height_emu` are
/// in EMU. The drawing uses default placement (inline anchor).
pub fn insert_picture(
  document : Document,
  paragraph_index : Int,
  image_bytes : Bytes,
  mime_type : String,
  width_emu : Int,
  height_emu : Int,
) -> Document raise OpenError {
  // §17.16 / ECMA-376 Part 2 §10.1.2 — pick the file extension
  // that matches the source MIME so the OPC `[Content_Types].xml`
  // `<Default Extension>` map can locate the part by suffix.
  // We honour every image MIME registered in
  // `presetShapeDefinitions.xml`'s media table; unknown MIMEs
  // (vendor-specific or non-image content) fall through to
  // `bin` which the consumer must pair with an explicit
  // `<Override PartName>` entry — the `data-ooxml-mime`
  // metadata flag (surfaced upstream) records the breach so
  // the caller can update the package's Content-Types map.
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
    // §17.16.5.3 image/x-emf (Enhanced Metafile) — Windows-only.
    "image/x-emf" => "emf"
    "image/emf" => "emf"
    "image/x-wmf" => "wmf"
    "image/wmf" => "wmf"
    "image/x-pict" => "pict"
    "image/x-pcx" => "pcx"
    "image/x-targa" => "tga"
    "image/x-tga" => "tga"
    // §17.16.5.4 image/x-eps (PostScript) is allowed by Office
    // but the spec does not define an extension; consumers
    // typically use `.eps`.
    "image/x-eps" => "eps"
    "image/eps" => "eps"
    "application/postscript" => "eps"
    // Unknown / vendor-specific MIME — fall back to `bin` and
    // let the caller register the part via an OPC <Override>.
    _ => "bin"
  }
  // Find next media image index across the package.
  let mut max_index = 0
  for part in document.package.parts {
    let prefix = "/word/media/image"
    if part.name.has_prefix(prefix) {
      let rest = part.name[prefix.length():].to_owned()
      let dot_index = char_index(rest, '.')
      if dot_index > 0 {
        let head = rest[0:dot_index].to_owned()
        let parsed = Some(@strconv.parse_int(head)) catch { _ => None }
        match parsed {
          Some(n) => if n > max_index { max_index = n }
          None => ()
        }
      }
    }
  }
  let media_name = "/word/media/image" +
    (max_index + 1).to_string() +
    "." +
    extension
  // Allocate a fresh r:id under the document part.
  let owner = document.main_part
  let existing = match document.package.relationships(owner) {
    Some(rs) => rs.relationships
    None => []
  }
  // OPC §9.3.4 — relationship IDs are xsd:NMTOKEN-typed; the
  // de-facto convention is `rId` + numeric suffix, but the spec
  // allows arbitrary tokens.  Vendor-specific non-numeric tokens
  // (e.g. `rIdHyperlink`) cannot collide with our numeric
  // `rIdN` naming so we skip them silently when computing the
  // next free numeric id.  Collisions are detected at save
  // time by the relationship-rebuild pass.
  let mut max_rid = 0
  for r in existing {
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
  let rel_target = "media/image" + (max_index + 1).to_string() + "." + extension
  let pkg2 = try {
    let with_part = document.package.add_part(
      media_name, mime_type, image_bytes,
    )
    with_part.with_relationship(
      owner, new_rid, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
      rel_target,
    )
  } catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise @wml_context.OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
  // Build §17.3.3.9 <w:drawing> containing <wp:inline> with a
  // <a:graphic>/<a:graphicData>/<pic:pic> tree referencing new_rid.
  let w_qn = build_w_qname("p")
  let wp_qn : @xml.QName = {
    prefix: Some("wp"),
    local_name: "inline",
    ns: Some(
      "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing",
    ),
  }
  let a_qn : @xml.QName = {
    prefix: Some("a"),
    local_name: "graphic",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
  let pic_qn : @xml.QName = {
    prefix: Some("pic"),
    local_name: "pic",
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/picture"),
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
  // <pic:blipFill><a:blip/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
  let stretch = @edit.append_child(
    @edit.empty_element(a_qn, "stretch"),
    @xml.Node::Element(@edit.empty_element(a_qn, "fillRect")),
  )
  let blip_fill = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(pic_qn, "blipFill"),
      @xml.Node::Element(blip),
    ),
    @xml.Node::Element(stretch),
  )
  // <pic:spPr><a:xfrm><a:off/><a:ext cx cy/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>
  let off = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "off"),
      @edit.unprefixed_attribute("x", "0"),
    ),
    @edit.unprefixed_attribute("y", "0"),
  )
  let ext = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "ext"),
      @edit.unprefixed_attribute("cx", width_emu.to_string()),
    ),
    @edit.unprefixed_attribute("cy", height_emu.to_string()),
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
      @edit.unprefixed_attribute("prst", "rect"),
    ),
    @xml.Node::Element(@edit.empty_element(a_qn, "avLst")),
  )
  let pic_sp_pr = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(pic_qn, "spPr"),
      @xml.Node::Element(xfrm),
    ),
    @xml.Node::Element(prst_geom),
  )
  // §20.4.2.5 ST_DrawingElementId — cNvPr/@id MUST be unique
  // within the document.  Allocate from the document-wide max
  // by walking `<w:document>` once.
  let pic_id = next_drawing_id_for_document(document)
  let c_nv_pr = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(pic_qn, "cNvPr"),
      @edit.unprefixed_attribute("id", pic_id.to_string()),
    ),
    @edit.unprefixed_attribute("name", "Picture " + pic_id.to_string()),
  )
  let c_nv_pic_pr = @edit.empty_element(pic_qn, "cNvPicPr")
  let nv_pic_pr = @edit.append_child(
    @edit.append_child(
      @edit.empty_element(pic_qn, "nvPicPr"),
      @xml.Node::Element(c_nv_pr),
    ),
    @xml.Node::Element(c_nv_pic_pr),
  )
  let pic = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        @edit.empty_element(pic_qn, "pic"),
        @xml.Node::Element(nv_pic_pr),
      ),
      @xml.Node::Element(blip_fill),
    ),
    @xml.Node::Element(pic_sp_pr),
  )
  // <a:graphicData uri="...picture"><pic:pic/></a:graphicData>
  let graphic_data = @edit.append_child(
    @edit.set_attribute(
      @edit.empty_element(a_qn, "graphicData"),
      @edit.unprefixed_attribute(
        "uri", "http://schemas.openxmlformats.org/drawingml/2006/picture",
      ),
    ),
    @xml.Node::Element(pic),
  )
  let graphic = @edit.append_child(
    @edit.empty_element(a_qn, "graphic"),
    @xml.Node::Element(graphic_data),
  )
  // <wp:extent cx cy/><wp:docPr id="1" name="Picture"/>
  let wp_extent = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(wp_qn, "extent"),
      @edit.unprefixed_attribute("cx", width_emu.to_string()),
    ),
    @edit.unprefixed_attribute("cy", height_emu.to_string()),
  )
  // §20.4.2.5 — `<wp:docPr>` uses ST_DrawingElementId; share the
  // numbering pool with `pic_id` so the same drawing carries a
  // single coherent identifier.
  let doc_pr = @edit.set_attribute(
    @edit.set_attribute(
      @edit.empty_element(wp_qn, "docPr"),
      @edit.unprefixed_attribute("id", pic_id.to_string()),
    ),
    @edit.unprefixed_attribute("name", "Picture " + pic_id.to_string()),
  )
  // §20.4.2.8 CT_Inline — `distT`, `distB`, `distL`, `distR` are
  // required xsd:unsignedInt attributes (the text-to-image
  // distance in EMU on each side).  Word's default is 0 on every
  // side for inline drawings; emitting them satisfies the
  // schema's `use="required"` declaration and prevents Word
  // from rejecting the package as malformed.
  let inline_el = @edit.set_attribute(
    @edit.set_attribute(
      @edit.set_attribute(
        @edit.set_attribute(
          @edit.empty_element(wp_qn, "inline"),
          @edit.unprefixed_attribute("distT", "0"),
        ),
        @edit.unprefixed_attribute("distB", "0"),
      ),
      @edit.unprefixed_attribute("distL", "0"),
    ),
    @edit.unprefixed_attribute("distR", "0"),
  )
  let inline = @edit.append_child(
    @edit.append_child(
      @edit.append_child(
        inline_el,
        @xml.Node::Element(wp_extent),
      ),
      @xml.Node::Element(doc_pr),
    ),
    @xml.Node::Element(graphic),
  )
  let drawing = @edit.append_child(
    @edit.empty_element(w_qn, "drawing"),
    @xml.Node::Element(inline),
  )
  // Wrap in <w:r>...</w:r>, append to the paragraph.
  let r = @edit.append_child(
    @edit.empty_element(w_qn, "r"),
    @xml.Node::Element(drawing),
  )
  with_package(
    edit_paragraph(document, paragraph_index, fn(p) {
      @edit.append_child(p, @xml.Node::Element(r))
    }),
    pkg2,
  )
}

///|
fn char_index(s : String, target : Char) -> Int {
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
/// Insert a brand-new §17.3.1.22 paragraph at index `position` in
/// the body. `position` is 0-based and clamped to the existing
/// paragraph count.
pub fn insert_paragraph_at(
  document : Document,
  position : Int,
  text : String,
) -> Document raise OpenError {
  if document.main.body is None {
    raise @wml_context.OpenError(
      kind="UnsupportedFeature",
      path="document",
      reason="document has no body",
    )
  }
  let w_template = build_w_qname("p")
  // §17.17.3 — preserve whitespace in the inserted paragraph's text.
  let t = build_w_t(text)
  let r = @edit.append_child(
    @edit.empty_element(w_template, "r"),
    @xml.Node::Element(t),
  )
  let p = @edit.append_child(
    @edit.empty_element(w_template, "p"),
    @xml.Node::Element(r),
  )
  let counter : RemoveCounter = { current: 0, target: position }
  edit_main(document, fn(root) {
    @edit.update_first(root, @edit.by_local_name("body"), fn(body) {
      let new_children : Array[@xml.Node] = []
      let mut inserted = false
      for child in body.children {
        match child {
          @xml.Element(e) =>
            if is_block_level_local_name(e.name.local_name) {
              if counter.current == counter.target && !inserted {
                new_children.push(@xml.Node::Element(p))
                inserted = true
              }
              new_children.push(child)
              counter.current = counter.current + 1
            } else {
              new_children.push(child)
            }
          other => new_children.push(other)
        }
      }
      if !inserted {
        new_children.push(@xml.Node::Element(p))
      }
      { name: body.name, attributes: body.attributes, children: new_children }
    })
  })
}

///|
fn build_w_qname(local_name : String) -> @xml.QName {
  {
    prefix: Some("w"),
    local_name,
    ns: Some("http://schemas.openxmlformats.org/wordprocessingml/2006/main"),
  }
}

///|
/// §20.4.2.5 ST_DrawingElementId — walk a document, collect
/// every existing `<pic:cNvPr/@id>` and `<wp:docPr/@id>`, and
/// return `max + 1`.  Returns 1 when no drawing IDs are
/// present, matching Office's "first id" convention.
fn next_drawing_id_for_document(document : Document) -> Int {
  let mut max_id = 0
  walk_wml_id_attrs(document.main.element, fn(id) {
    if id > max_id { max_id = id }
  })
  max_id + 1
}

///|
fn walk_wml_id_attrs(elt : @xml.Element, on_id : (Int) -> Unit) -> Unit {
  // Both `<wp:docPr>` and `<pic:cNvPr>` carry the
  // ST_DrawingElementId-typed @id; match by local name so
  // either prefix is recognised.
  if elt.name.local_name == "docPr" || elt.name.local_name == "cNvPr" {
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
      @xml.Node::Element(e) => walk_wml_id_attrs(e, on_id)
      _ => ()
    }
  }
}

///|
/// §17.17.3 ST_String — delegates to the shared §3.3.3 whitespace
/// predicate in the `@edit` package.  See `@edit::needs_xml_space_preserve`.
fn wml_needs_xml_space_preserve(text : String) -> Bool {
  @edit.needs_xml_space_preserve(text)
}

///|
/// §17.13.5 — accept every pending revision in the document.
///
/// Spec semantics:
///   `<w:ins>` insertions — unwrap the element, keeping its
///     descended runs in place (they become permanent).
///   `<w:del>` deletions — drop the element AND its descended
///     `<w:r>/<w:delText>` children (text disappears).
///   `<w:moveFrom>` — drop (same as del).
///   `<w:moveTo>` — unwrap (same as ins).
///
/// Returns a new Document with all four revision wrappers
/// resolved.  Bookmark-style range markers (`<w:permStart>`,
/// `<w:ins>` etc. with no children) are dropped.
pub fn accept_revisions(document : Document) -> Document raise OpenError {
  edit_main(document, fn(root) {
    transform_revisions(root, accept=true)
  })
}

///|
/// §17.13.5 — reject every pending revision.  Mirror of
/// `accept_revisions`:
///   `<w:ins>` / `<w:moveTo>` — drop (the insertion is rolled back).
///   `<w:del>` / `<w:moveFrom>` — unwrap (the deletion is undone;
///     the children become permanent text again).  Note that
///     `<w:del>` wraps `<w:r>` whose children are `<w:delText>`
///     rather than `<w:t>` — we rename them back so the result
///     parses as normal text again.
pub fn reject_revisions(document : Document) -> Document raise OpenError {
  edit_main(document, fn(root) {
    transform_revisions(root, accept=false)
  })
}

///|
fn transform_revisions(
  elt : @xml.Element,
  accept~ : Bool,
) -> @xml.Element {
  // §17.13.5.29-.35 — when this element is a properties container
  // (pPr/rPr/tblPr/trPr/tcPr/sectPr) that owns a change marker
  // child, the reject path replaces the entire container with
  // the snapshot inside the change marker.  We branch up front so
  // the snapshot replacement isn't tangled with the run/insert
  // child walk below.
  if not(accept) {
    match revert_property_change(elt) {
      Some(snapshot) => return transform_revisions(snapshot, accept~)
      None => ()
    }
  }
  let new_children : Array[@xml.Node] = []
  for child in elt.children {
    match child {
      @xml.Node::Element(e) => {
        let local = e.name.local_name
        let is_insert = local == "ins" || local == "moveTo"
        let is_delete = local == "del" || local == "moveFrom"
        // §17.13.5.29-.35 — property-change wrappers
        // (pPrChange/rPrChange/sectPrChange/tblPrChange/
        // trPrChange/tcPrChange) live INSIDE the corresponding
        // properties element.  On accept they MUST be dropped
        // (the current properties stay); on reject the parent
        // container is replaced via the snapshot — handled
        // earlier by `revert_property_change`, so the marker
        // here is already gone in that path.
        let is_property_change = local == "pPrChange" ||
          local == "rPrChange" ||
          local == "sectPrChange" ||
          local == "tblPrChange" ||
          local == "trPrChange" ||
          local == "tcPrChange"
        if is_property_change {
          if accept {
            // Accept: drop the change marker; the current
            // properties survive.
            ()
          }
          // Reject path is handled earlier via the snapshot
          // replacement; reaching here means the parent had no
          // properties to revert — drop the marker anyway.
        } else if is_insert {
          // Accept: unwrap children, recursing into each.
          // Reject: drop entirely.
          if accept {
            let unwrapped = transform_revisions(e, accept~)
            for grand in unwrapped.children {
              new_children.push(grand)
            }
          }
        } else if is_delete {
          // Accept: drop entirely (deletion sticks).
          // Reject: unwrap; rename delText → t inside.
          if !accept {
            let unwrapped = transform_revisions(e, accept~)
            for grand in unwrapped.children {
              new_children.push(rename_delete_text(grand))
            }
          }
        } else {
          // Plain element — recurse.
          new_children.push(@xml.Node::Element(transform_revisions(e, accept~)))
        }
      }
      other => new_children.push(other)
    }
  }
  { ..elt, children: new_children }
}

///|
/// §17.13.5.29-.35 — if `elt` is a properties container (pPr,
/// rPr, sectPr, tblPr, trPr, tcPr) that has the matching change
/// marker child (pPrChange / rPrChange / sectPrChange /
/// tblPrChange / trPrChange / tcPrChange), return the snapshot
/// element from inside the marker — that snapshot IS the
/// reverted properties container.  Returns None when no marker
/// applies.
fn revert_property_change(elt : @xml.Element) -> @xml.Element? {
  let container = elt.name.local_name
  // The snapshot inside the marker uses the same local name as
  // the parent container (e.g. `<w:pPrChange><w:pPr>…</w:pPr></w:pPrChange>`
  // — the inner `<w:pPr>` is the snapshot).
  let marker_local = match container {
    "pPr" => "pPrChange"
    "rPr" => "rPrChange"
    "sectPr" => "sectPrChange"
    "tblPr" => "tblPrChange"
    "trPr" => "trPrChange"
    "tcPr" => "tcPrChange"
    _ => return None
  }
  for child in elt.children {
    match child {
      @xml.Node::Element(e) =>
        if e.name.local_name == marker_local {
          // Snapshot is the matching-container child of the marker.
          for snap_child in e.children {
            match snap_child {
              @xml.Node::Element(snap) =>
                if snap.name.local_name == container {
                  return Some(snap)
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  None
}

///|
/// §17.13.5.14 — when a `<w:del>` is rejected, its child
/// `<w:r>/<w:delText>` elements should become regular
/// `<w:r>/<w:t>` so the document is in a normal post-revision
/// state.  Walk one level deep (the runs are direct children).
fn rename_delete_text(node : @xml.Node) -> @xml.Node {
  match node {
    @xml.Node::Element(e) =>
      if e.name.local_name == "delText" {
        @xml.Node::Element({
          name: { ..e.name, local_name: "t" },
          attributes: e.attributes,
          children: e.children,
        })
      } else {
        // Descend into runs / smartTag / etc. to catch nested
        // delText.
        let new_children : Array[@xml.Node] = []
        for child in e.children {
          new_children.push(rename_delete_text(child))
        }
        @xml.Node::Element({
          name: e.name,
          attributes: e.attributes,
          children: new_children,
        })
      }
    other => other
  }
}

///|
/// §17.17.3 + XML 1.0 §3.3.3 — build a `<w:t>` element with the
/// supplied text, automatically attaching `xml:space="preserve"`
/// when the text begins or ends with ASCII whitespace.  Shared
/// by every edit helper that emits a literal run text (e.g.
/// `append_paragraph`, `set_paragraph_text`, `insert_hyperlink`,
/// `insert_paragraph_at`).
fn build_w_t(text : String) -> @xml.Element {
  let w_template = build_w_qname("p")
  let t_base = @edit.empty_element(w_template, "t")
  let t_element = if wml_needs_xml_space_preserve(text) {
    let xml_qn : @xml.QName = {
      prefix: Some("xml"),
      local_name: "space",
      ns: Some("http://www.w3.org/XML/1998/namespace"),
    }
    @edit.set_attribute(t_base, { name: xml_qn, value: "preserve" })
  } else {
    t_base
  }
  @edit.append_child(t_element, @xml.Node::Text(text))
}
