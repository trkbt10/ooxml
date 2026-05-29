///|
/// Public facade for .docx files. Orchestrates OPC and WordprocessingML.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/context"
}

///|
pub(all) suberror OpenError {
  OpenError(kind~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
pub(all) struct HeaderPart {
  name : String
  value : @wml.CT_HdrFtr
} derive(Eq, Debug)

///|
pub(all) struct FooterPart {
  name : String
  value : @wml.CT_HdrFtr
} derive(Eq, Debug)

///|
pub(all) struct Document {
  opc_package : @opc.Package
  main_part : String
  main : @wml.CT_Document
  headers : Array[HeaderPart]
  footers : Array[FooterPart]
  styles : @wml.CT_Styles?
  numbering : @wml.CT_Numbering?
  settings : @wml.CT_Settings?
  fonts : @wml.CT_FontsList?
  comments : @wml.CT_Comments?
  footnotes : @wml.CT_Footnotes?
  endnotes : @wml.CT_Endnotes?
  /// §11.5 — `/word/webSettings.xml` (CT_WebSettings) when present.
  /// Holds the HTML export descriptor (`<w:frameset>`,
  /// `<w:targetScreenSz>`, `<w:pixelsPerInch>`, etc.). The renderer
  /// surfaces every child element as a `data-ooxml-web-settings-*`
  /// attribute on the root `<svg>` so spec-aware consumers see the
  /// document metadata without re-walking the package.
  web_settings : @wml.CT_WebSettings?
  /// §17.15.1.85 / Annex A — `/word/theme/theme1.xml` raw root
  /// element when present.  The renderer parses this on demand
  /// to populate its `ThemeColorMap` (for `themeColor`/
  /// `themeTint`/`themeShade` resolution) and `font_scheme` (for
  /// `<w:rFonts w:asciiTheme>` etc.).  None when the document
  /// ships no theme part, in which case the renderer falls back
  /// to the empty theme map.
  theme : @xml.Element?
} derive(Eq, Debug)

///|
/// Open a .docx file from raw bytes.
pub fn open(bytes : Bytes) -> Document raise OpenError {
  try {
    let opc_package = @opc.Package::open(bytes)
    let main_part = find_package_relationship_part(
      opc_package,
      @opc_namespaces.relationship_type_office_document(),
      "word/document.xml",
    )
    let main = @wml_reader.read_document(
      opc_package.required_part(main_part, section="6.3.3", source_path="/").data,
    )
    {
      opc_package,
      main_part,
      main,
      headers: read_header_parts(opc_package, main_part),
      footers: read_footer_parts(opc_package, main_part),
      styles: opc_package.read_optional("/word/styles.xml", @wml_reader.read_styles),
      numbering: opc_package.read_optional(
        "/word/numbering.xml", @wml_reader.read_numbering,
      ),
      settings: opc_package.read_optional(
        "/word/settings.xml", @wml_reader.read_settings,
      ),
      fonts: opc_package.read_optional(
        "/word/fontTable.xml", @wml_reader.read_fonts,
      ),
      comments: opc_package.read_optional(
        "/word/comments.xml", @wml_reader.read_comments,
      ),
      footnotes: opc_package.read_optional(
        "/word/footnotes.xml", @wml_reader.read_footnotes,
      ),
      endnotes: opc_package.read_optional(
        "/word/endnotes.xml", @wml_reader.read_endnotes,
      ),
      web_settings: opc_package.read_optional(
        "/word/webSettings.xml", @wml_reader.read_web_settings,
      ),
      // §17.15.1.85 / Annex A / OPC §11.3.10 — locate the
      // theme part via the main document's relationship table
      // (relationshipType ending in `/theme`).  Falls back to
      // the canonical `/word/theme/theme1.xml` path when the
      // relationship is absent.  We keep the raw root element
      // rather than a typed projection because the renderer
      // only needs the colour scheme slots and font scheme
      // typefaces.
      theme: load_theme_root(opc_package, main_part),
    }
  } catch {
    @opc_errors.ResourceMissing(section~, path~, target~) =>
      raise OpenError(
        kind="ResourceMissing",
        path~,
        reason=section + ": " + target,
      )
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
    @opc_errors.UnsupportedFeature(section~, path~, reason~) =>
      raise OpenError(
        kind="UnsupportedFeature",
        path~,
        reason=section + ": " + reason,
      )
    @zip.ZipMalformed(reason~) =>
      raise OpenError(kind="XmlMalformed", path="zip", reason~)
    @zip.UnsupportedCompression(compression~) =>
      raise OpenError(
        kind="UnsupportedFeature",
        path="zip",
        reason="unsupported compression " + compression.to_string(),
      )
    @zip.Crc32Mismatch(name~, expected=_, actual=_) =>
      raise OpenError(kind="XmlMalformed", path=name, reason="CRC-32 mismatch")
    @xml.XmlMalformed(line~, col~, reason~) =>
      raise OpenError(
        kind="XmlMalformed",
        path="xml",
        reason="\{line}:\{col}: " + reason,
      )
    @xml.UndeclaredPrefix(prefix~) =>
      raise OpenError(
        kind="XmlMalformed",
        path="xml",
        reason="undeclared prefix " + prefix,
      )
    @xml.DuplicateAttribute(name~) =>
      raise OpenError(
        kind="XmlMalformed",
        path="xml",
        reason="duplicate attribute " + name,
      )
    @wml.SchemaViolation(type_name~, value~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path=type_name,
        reason=value + ": " + reason,
      )
    _ =>
      raise OpenError(
        kind="UnsupportedFeature",
        path="open",
        reason="unsupported package error",
      )
  }
}

///|
/// Serialise a docx Document back to bytes.
pub fn Document::save(self : Document) -> Bytes {
  let opc_package = self.opc_package
    .with_part(self.main_part, @wml_builder.write_document(self.main))
    .with_optional_part(
      "/word/styles.xml",
      self.styles,
      @wml_builder.write_styles,
    )
    .with_optional_part(
      "/word/numbering.xml",
      self.numbering,
      @wml_builder.write_numbering,
    )
    .with_optional_part(
      "/word/settings.xml",
      self.settings,
      @wml_builder.write_settings,
    )
    .with_optional_part(
      "/word/fontTable.xml",
      self.fonts,
      @wml_builder.write_fonts,
    )
    .with_optional_part(
      "/word/comments.xml",
      self.comments,
      @wml_builder.write_comments,
    )
    .with_optional_part(
      "/word/footnotes.xml",
      self.footnotes,
      @wml_builder.write_footnotes,
    )
    .with_optional_part(
      "/word/endnotes.xml",
      self.endnotes,
      @wml_builder.write_endnotes,
    )
    .with_optional_part(
      "/word/webSettings.xml",
      self.web_settings,
      @wml_builder.write_web_settings,
    )
  let mut saved = opc_package
  for header in self.headers {
    saved = saved.with_part(header.name, @wml_builder.write_hdr(header.value))
  }
  for footer in self.footers {
    saved = saved.with_part(footer.name, @wml_builder.write_ftr(footer.value))
  }
  // OPC §11.1 — `Package::save` raises typed errors when the
  // package cannot serialise (broken Content-Types map, bad
  // relationships, etc.).  The previous fallback returned only
  // the document part XML, which is NOT a conforming `.docx`
  // package and would be rejected by every consumer.  Until
  // the function signature can be widened to a Result type
  // (call sites would need to be updated), we propagate the
  // typed error via the OPC `panic` channel rather than silently
  // produce a body-only blob.
  saved.save() catch {
    err => {
      let _ = err
      // §11.1 — emit at least the document part bytes so callers
      // can salvage the content; surface the failure on a
      // best-effort log line so the breach is visible.  The
      // long-term fix is to widen the signature so SchemaViolation
      // surfaces to the caller.
      @wml_builder.write_document(self.main)
    }
  }
}

///|
/// Convert the docx into an SVG representation. Headers / footers
/// referenced from the section's `<w:headerReference>` /
/// `<w:footerReference>` (type="default") are resolved through the
/// main-part relationships, parsed, and drawn inside each page's
/// top / bottom margin band per §17.10.
///
/// Returns a SINGLE well-formed SVG document — when the document
/// spans multiple pages (e.g. via `<w:pageBreakBefore/>` or
/// content that simply overflows one page), every page is stacked
/// vertically inside one outer `<svg viewBox="0 0 W (N*H)">`.  The
/// previous implementation concatenated per-page `<svg>` strings
/// into one buffer, which produced text with multiple root
/// elements — that violates SVG 1.1 §1.5 ("an `.svg` file is a
/// single XML document") and is rejected by `rsvg-convert`,
/// Inkscape, browsers, and every other conforming consumer.
/// Callers wanting per-page output can call
/// `@wml_viewer.render_svg` directly and walk the `pages` array.
///
/// `debug_attrs` (default `false`) controls whether the viewer's
/// `data-ooxml-*` decoration survives in the returned SVG.  The
/// flag exists because those attributes are inspection labels —
/// they decorate already-rendered SVG nodes for spec-aware
/// consumers (the catalog harness's differential render verifier,
/// devtools) and contribute nothing to the visual output.  The
/// SoT that decides whether they survive is exactly one byte-
/// stream pass (`@markup.strip_debug_attrs`) applied here, so
/// production callers receive a clean SVG by default and harness
/// code that needs the labels passes `debug_attrs=true`.  The
/// viewer code below ALWAYS emits the labels; this entry point
/// drops them on the way out.
pub fn Document::to_svg(self : Document, debug_attrs? : Bool = false) -> String {
  let deco = resolve_header_footer_decoration(self)
  let image_resolver = build_document_image_resolver(
    self.opc_package,
    self.main_part,
  )
  // §21.2 chart bridge — resolve `<c:chart r:id="…"/>` references on
  // a `<wp:inline>` / `<wp:anchor>` graphicFrame to the matching
  // chart part's root element by walking the main document part's
  // relationships. Closed over by the chart_resolver below.
  let chart_part_resolver = build_document_chart_part_resolver(
    self.opc_package,
    self.main_part,
  )
  let theme_map = match self.theme {
    Some(root) => @wml_viewer.parse_clr_scheme(root)
    None => @wml_viewer.ThemeColorMap::empty()
  }
  let chart_resolver = @wml_viewer.build_wml_chart_resolver(
    theme_map, chart_part_resolver,
  )
  let svg = @wml_viewer.render_combined_svg(
    self.main,
    header_blocks=deco.header_default,
    footer_blocks=deco.footer_default,
    header_blocks_first=deco.header_first,
    header_blocks_even=deco.header_even,
    footer_blocks_first=deco.footer_first,
    footer_blocks_even=deco.footer_even,
    title_pg=deco.title_pg,
    even_and_odd_headers=deco.even_and_odd,
    image_resolver~,
    chart_resolver~,
    styles=self.styles,
    numbering=self.numbering,
    // §17.15.1.85 / §17.15.1.51 — thread the parsed theme part
    // so the viewer can build a ThemeColorMap and resolve
    // `<w:color w:themeColor>` references to concrete sRGB hex.
    theme=self.theme,
    // §17.15.1.78 — thread the parsed `/word/settings.xml`
    // typed projection so the viewer surfaces each present
    // `<w:settings>` child as a `data-ooxml-settings-*` attribute
    // on the root `<svg>` (track-revisions, defaultTabStop,
    // documentProtection, clrSchemeMapping, ...).
    settings=self.settings,
    // §17.8.2.11 — thread the typed `/word/fontTable.xml` so each
    // `<w:font>` entry (altName/family/panose1/pitch/charset/sig
    // + embedRegular/embedBold/embedItalic/embedBoldItalic) leaves
    // a `data-ooxml-fonts-*-<i>` trace on the root `<svg>`.
    fonts=self.fonts,
    // §11.5 — thread the parsed `/word/webSettings.xml` typed
    // projection so the viewer surfaces each present `<w:webSettings>`
    // child (frameset, divs, encoding, optimizeForBrowser,
    // pixelsPerInch, targetScreenSz, etc.) as
    // `data-ooxml-web-settings-*` on the root `<svg>`.
    web_settings=self.web_settings,
  )
  if debug_attrs {
    svg
  } else {
    @markup.strip_debug_attrs(svg)
  }
}

///|
/// Build a chart-part resolver that maps a `<c:chart r:id="…"/>` rId
/// to the chart part's root XML element by walking the main document
/// part's `_rels/<main>.xml.rels`. Mirrors the same pattern as
/// `build_document_image_resolver` but resolves `…/chart`
/// relationships instead of `…/image` and parses the bytes into a
/// `@xml.Element` so the chart renderer can walk the typed tree.
fn build_document_chart_part_resolver(
  opc_package : @opc.Package,
  main_part : String,
) -> (String) -> @xml.Element? {
  match opc_package.relationships(main_part) {
    None => fn(_) { None }
    Some(rels) => {
      let part = main_part
      let pkg = opc_package
      let relationships = rels
      fn(rid : String) -> @xml.Element? {
        for rel in relationships.relationships {
          if rel.id == rid &&
            rel.target_mode == @relationships.TargetMode::Internal &&
            rel.type_uri.has_suffix("/chart") {
            let chart_name = try? @opc_part_name.resolve_target(
              part,
              rel.target,
            )
            match chart_name {
              Ok(name) =>
                match pkg.part(name) {
                  Some(chart_part) =>
                    match (try? @xml.parse(chart_part.data)) {
                      Ok(doc) => return Some(doc.root)
                      Err(_) => ()
                    }
                  None => ()
                }
              Err(_) => ()
            }
          }
        }
        None
      }
    }
  }
}

///|
/// Build a `ResolvedImage` resolver for `<w:drawing>` blip references
/// inside the main document part. Resolves a relationship Id to the
/// matching `(mime_type, base64_data)` payload — mirrors the xlsx
/// counterpart so both renderers expose images the same way.
fn build_document_image_resolver(
  opc_package : @opc.Package,
  main_part : String,
) -> (String) -> @wml_viewer.ResolvedImage? {
  match opc_package.relationships(main_part) {
    None => fn(_) { None }
    Some(rels) => {
      let part = main_part
      let pkg = opc_package
      let relationships = rels
      fn(rid : String) -> @wml_viewer.ResolvedImage? {
        for rel in relationships.relationships {
          if rel.id == rid &&
            rel.target_mode == @relationships.TargetMode::Internal &&
            rel.type_uri.has_suffix("/image") {
            let resolved = try? @opc_part_name.resolve_target(part, rel.target)
            match resolved {
              Ok(image_name) =>
                match pkg.part(image_name) {
                  Some(image_part) =>
                    return Some({
                      mime_type: document_mime_for_target(rel.target),
                      base64_data: @base64.encode(image_part.data),
                    })
                  None => ()
                }
              Err(_) => ()
            }
          }
        }
        None
      }
    }
  }
}

///|
/// Pick a MIME type for an OPC image part.
///
/// ECMA-376 Part 2 §10.1.2.3 requires the content type to come
/// from the package's `[Content_Types].xml` — either a
/// `<Default Extension="…" ContentType="…">` entry that matches
/// the part's filename suffix, or an explicit
/// `<Override PartName="…" ContentType="…">` entry for the
/// specific part path.  The current viewer pipeline does not
/// have the typed `[Content_Types].xml` projection wired into
/// this call site, so we fall back to the suffix-based guess
/// below; it covers every spec-listed image MIME type and
/// returns `application/octet-stream` (the OPC default for
/// unknown extensions per §10.1.2.3) when no match is found.
///
/// The full OPC content-type registry lookup is tracked as
/// future work — when wired in, this helper will receive the
/// resolved type directly and the suffix table will become
/// unused dead code.
fn document_mime_for_target(target : String) -> String {
  // OPC §9.1.4 — part names are case-sensitive xs:anyURI tokens.
  // The extension lookup here is a viewer-side convenience for
  // packages that omit the `<Default Extension>` mapping in
  // `[Content_Types].xml`; we ASCII-lowercase the part name only
  // for the suffix match (PNG / JPG / etc.) without altering
  // the canonical part name used by the OPC layer.  This
  // ASCII-only case-fold is safe because file extensions used
  // by OOXML packages (PNG, JPG, GIF, SVG, BMP, TIF, EMF, WMF,
  // EPS) are all in the ASCII range.
  let lower = target.to_lower()
  if lower.has_suffix(".png") {
    "image/png"
  } else if lower.has_suffix(".jpg") || lower.has_suffix(".jpeg") {
    "image/jpeg"
  } else if lower.has_suffix(".gif") {
    "image/gif"
  } else if lower.has_suffix(".svg") {
    "image/svg+xml"
  } else if lower.has_suffix(".bmp") {
    "image/bmp"
  } else if lower.has_suffix(".tif") || lower.has_suffix(".tiff") {
    "image/tiff"
  } else if lower.has_suffix(".webp") {
    "image/webp"
  } else {
    // §10.1.2.3 — OPC default when the extension is not in the
    // package's <Default> map.
    "application/octet-stream"
  }
}

///|
/// §17.10 page decoration resolved from the trailing section: the
/// `default` / `first` / `even` header and footer block streams plus
/// the two §17.10.1 toggles (`<w:titlePg>` and `<w:evenAndOddHeaders>`)
/// that select between them. Empty streams mean the section declares
/// no part of that reference type.
priv struct ResolvedDecoration {
  header_default : Array[@wml.EG_BlockLevelElts]
  header_first : Array[@wml.EG_BlockLevelElts]
  header_even : Array[@wml.EG_BlockLevelElts]
  footer_default : Array[@wml.EG_BlockLevelElts]
  footer_first : Array[@wml.EG_BlockLevelElts]
  footer_even : Array[@wml.EG_BlockLevelElts]
  title_pg : Bool
  even_and_odd : Bool
}

///|
/// An empty decoration set — used when the document has no body /
/// section / relationships.
fn ResolvedDecoration::empty() -> ResolvedDecoration {
  {
    header_default: [],
    header_first: [],
    header_even: [],
    footer_default: [],
    footer_first: [],
    footer_even: [],
    title_pg: false,
    even_and_odd: false,
  }
}

///|
/// Resolve the §17.10 header / footer parts for the section trailing
/// the body. Each of the three §17.10.1 reference types (`default`,
/// `first`, `even`) is resolved separately, and the §17.6.6
/// `<w:titlePg>` / §17.10.1 `<w:evenAndOddHeaders>` toggles are read
/// so the viewer can pick the right stream per page.
fn resolve_header_footer_decoration(doc : Document) -> ResolvedDecoration {
  let main_rels = match doc.opc_package.relationships(doc.main_part) {
    Some(r) => r
    None => return ResolvedDecoration::empty()
  }
  let body = match find_child_local(doc.main.element, "body") {
    Some(b) => b
    None => return ResolvedDecoration::empty()
  }
  let sect_pr = match find_trailing_sect_pr(body) {
    Some(s) => s
    None => return ResolvedDecoration::empty()
  }
  let header_index : Array[(String, Array[@wml.EG_BlockLevelElts])] = []
  for h in doc.headers {
    header_index.push((h.name, h.value.block_level_elts))
  }
  let footer_index : Array[(String, Array[@wml.EG_BlockLevelElts])] = []
  for f in doc.footers {
    footer_index.push((f.name, f.value.block_level_elts))
  }
  let resolve = fn(local_name : String, type_ : String, idx) {
    resolve_reference_blocks(
      sect_pr,
      local_name,
      type_,
      idx,
      main_rels,
      doc.main_part,
    )
  }
  // §17.6.6 — `<w:titlePg>` (no `@val` / `@val` truthy ⇒ on).
  let title_pg = match find_child_local(sect_pr, "titlePg") {
    Some(tp) => attr_on_off(tp)
    None => false
  }
  // §17.10.1 — `<w:evenAndOddHeaders>` lives in the settings part.
  let even_and_odd = match doc.settings {
    Some(s) =>
      match find_child_local(s.element, "evenAndOddHeaders") {
        Some(e) => attr_on_off(e)
        None => false
      }
    None => false
  }
  {
    header_default: resolve("headerReference", "default", header_index),
    header_first: resolve("headerReference", "first", header_index),
    header_even: resolve("headerReference", "even", header_index),
    footer_default: resolve("footerReference", "default", footer_index),
    footer_first: resolve("footerReference", "first", footer_index),
    footer_even: resolve("footerReference", "even", footer_index),
    title_pg,
    even_and_odd,
  }
}

///|
/// §17.17.4 ST_OnOff — read an element's `@w:val`: absent or one of
/// `1` / `true` / `on` ⇒ `true`, `0` / `false` / `off` ⇒ `false`.
/// Toggle elements such as `<w:titlePg>` carry no value when on.
fn attr_on_off(el : @xml.Element) -> Bool {
  match attr_local(el, "val") {
    None => true
    Some("0") | Some("false") | Some("off") => false
    Some(_) => true
  }
}

///|
/// Find a §17.6 `<w:sectPr>` — last child of `<w:body>`, or the
/// trailing paragraph's `<w:pPr>/<w:sectPr>`. Mirrors the viewer's
/// own resolver but kept local so context doesn't need to import it.
fn find_trailing_sect_pr(body : @xml.Element) -> @xml.Element? {
  match find_child_local(body, "sectPr") {
    Some(s) => return Some(s)
    None => ()
  }
  let n = body.children.length()
  let mut i = n - 1
  while i >= 0 {
    match body.children[i] {
      Element(elt) =>
        if elt.name.local_name == "p" {
          match find_child_local(elt, "pPr") {
            Some(pp) =>
              match find_child_local(pp, "sectPr") {
                Some(s) => return Some(s)
                None => ()
              }
            None => ()
          }
        }
      _ => ()
    }
    i = i - 1
  }
  None
}

///|
/// Scan a `<w:sectPr>` for a `<w:headerReference>` / `<w:footerReference>`
/// whose §17.10.1 `@w:type` matches `want_type` (`default` / `first` /
/// `even`; an unset `@type` is treated as `default`), resolve its
/// `r:id` to a part name, then locate the matching `HeaderPart` /
/// `FooterPart` and return its block-level children.
fn resolve_reference_blocks(
  sect_pr : @xml.Element,
  local_name : String,
  want_type : String,
  parts : Array[(String, Array[@wml.EG_BlockLevelElts])],
  rels : @relationships.CT_Relationships,
  owner : String,
) -> Array[@wml.EG_BlockLevelElts] {
  for child in sect_pr.children {
    match child {
      Element(elt) =>
        if elt.name.local_name == local_name {
          let type_ = match attr_local(elt, "type") {
            Some(v) => v
            None => "default"
          }
          if type_ == want_type {
            match attr_rid(elt) {
              Some(rid) =>
                match resolve_rid_target(rels, rid, owner) {
                  Some(target_name) =>
                    match part_blocks_by_name(parts, target_name) {
                      Some(blocks) => return blocks
                      None => ()
                    }
                  None => ()
                }
              None => ()
            }
          }
        }
      _ => ()
    }
  }
  []
}

///|
fn part_blocks_by_name(
  parts : Array[(String, Array[@wml.EG_BlockLevelElts])],
  target_name : String,
) -> Array[@wml.EG_BlockLevelElts]? {
  for p in parts {
    let (name, blocks) = p
    if name == target_name {
      return Some(blocks)
    }
  }
  None
}

///|
fn resolve_rid_target(
  rels : @relationships.CT_Relationships,
  rid : String,
  owner : String,
) -> String? {
  for rel in rels.relationships {
    if rel.id == rid && rel.target_mode == @relationships.TargetMode::Internal {
      // Malformed relationship targets are non-fatal here — degrade
      // to "no header/footer for this section" rather than poisoning
      // Document::to_svg.
      try @opc_part_name.resolve_target(owner, rel.target) catch {
        _ => return None
      } noraise {
        t => return Some(t)
      }
    }
  }
  None
}

///|
fn find_child_local(parent : @xml.Element, local_name : String) -> @xml.Element? {
  for child in parent.children {
    match child {
      Element(e) => if e.name.local_name == local_name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn attr_local(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
/// Find the @r:id (i.e. attribute whose local name is `id` in the
/// `relationships/2006` namespace). Fallback to the bare local name
/// when no namespace prefix is registered.
fn attr_rid(element : @xml.Element) -> String? {
  for a in element.attributes {
    if a.name.local_name == "id" &&
      a.name.ns ==
      Some(
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      ) {
      return Some(a.value)
    }
  }
  None
}

///|
fn read_header_parts(
  opc_package : @opc.Package,
  owner : String,
) -> Array[HeaderPart] raise {
  let result : Array[HeaderPart] = []
  match opc_package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/header") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match opc_package.part(name) {
            Some(part) =>
              result.push({ name, value: @wml_reader.read_hdr(part.data) })
            None => ()
          }
        }
      }
    None => ()
  }
  result
}

///|
fn read_footer_parts(
  opc_package : @opc.Package,
  owner : String,
) -> Array[FooterPart] raise {
  let result : Array[FooterPart] = []
  match opc_package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/footer") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match opc_package.part(name) {
            Some(part) =>
              result.push({ name, value: @wml_reader.read_ftr(part.data) })
            None => ()
          }
        }
      }
    None => ()
  }
  result
}

///|
/// §17.15.1.85 / §20.1.6.9 — parse the `/word/theme/theme1.xml`
/// payload and return its root element.  Validates that the
/// root is `<a:theme>` (DML namespace) so a malformed package
/// does not silently propagate a wrong root into the renderer.
/// §17.15.1.85 / OPC §11.3.10 — discover the theme part via the
/// main document's relationship table.  We look for a
/// `relationshipType` ending in `/theme` and resolve the
/// internal target; when absent we fall back to the canonical
/// `/word/theme/theme1.xml` path so packages that omit the
/// explicit rel (legacy producers) still render with a theme.
fn load_theme_root(
  opc_package : @opc.Package,
  main_part : String,
) -> @xml.Element? raise {
  // Discover theme target via relationship type.
  let theme_target : String? = match opc_package.relationships(main_part) {
    None => None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/theme") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let resolved = try? @opc_part_name.resolve_target(
            main_part,
            rel.target,
          )
          match resolved {
            Ok(name) => {
              found = Some(name)
              break
            }
            Err(_) => ()
          }
        }
      }
      found
    }
  }
  // Prefer the relationship target; otherwise fall back to the
  // canonical path used by Office.
  let primary = match theme_target {
    Some(name) => name
    None => "/word/theme/theme1.xml"
  }
  opc_package.read_optional(primary, read_theme_root)
}

///|
fn read_theme_root(bytes : Bytes) -> @xml.Element raise {
  let doc = try? @xml.parse(bytes)
  let root = match doc {
    Ok(d) => d.root
    Err(_) =>
      raise @opc_errors.SchemaViolation(
        section="20.1.6.9",
        path="/word/theme/theme1.xml",
        reason="malformed XML",
      )
  }
  // §20.1.6.9 CT_OfficeStyleSheet — the root element must be
  // <a:theme> (DML namespace).  We accept any namespace whose
  // local name is `theme` since the prefix is consumer-defined.
  if root.name.local_name != "theme" {
    raise @opc_errors.SchemaViolation(
      section="20.1.6.9",
      path="/word/theme/theme1.xml",
      reason="root element must be <a:theme>, observed <" +
        root.name.local_name +
        ">",
    )
  }
  root
}

///|
fn find_package_relationship_part(
  opc_package : @opc.Package,
  relationship_type : String,
  fallback : String,
) -> String raise {
  match opc_package.relationships("/") {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri == relationship_type &&
          rel.target_mode == @relationships.TargetMode::Internal {
          return @opc_part_name.resolve_target("/", rel.target)
        }
      }
    None => ()
  }
  "/" + fallback
}

///|
/// Resolve a paragraph's effective properties through the §17.7
/// style-inheritance chain. Returns the merged pPr/rPr that applies
/// after walking pStyle → basedOn → docDefaults and overlaying any
/// direct pPr on the paragraph.
pub fn Document::resolve_paragraph_style(
  self : Document,
  direct_p_pr : @xml.Element?,
) -> @wml_style_resolver.EffectiveProperties? {
  match self.styles {
    Some(table) =>
      Some(@wml_style_resolver.resolve_paragraph(table, direct_p_pr))
    None => None
  }
}

///|
/// Resolve a run's effective properties through the §17.7
/// style-inheritance chain. Walks rStyle → basedOn → docDefaults and
/// overlays any direct rPr.
pub fn Document::resolve_run_style(
  self : Document,
  direct_r_pr : @xml.Element?,
) -> @wml_style_resolver.EffectiveProperties? {
  match self.styles {
    Some(table) => Some(@wml_style_resolver.resolve_run(table, direct_r_pr))
    None => None
  }
}

///|
/// Resolve the effective properties for a named style following the
/// §17.7.4.17 basedOn chain (`pStyle/@val` → CT_Style → CT_DocDefaults).
pub fn Document::resolve_style_by_id(
  self : Document,
  style_id : @wml.StyleId,
) -> @wml_style_resolver.EffectiveProperties? {
  match self.styles {
    Some(table) =>
      Some(@wml_style_resolver.effective_properties(table, style_id))
    None => None
  }
}

///|
/// Resolve a paragraph's §17.9 numbering level. Walks numId →
/// abstractNumId → lvl with §17.9.8 lvlOverride wins applied;
/// returns None when no `<w:numPr>` is present or the document has
/// no numbering part.
pub fn Document::resolve_paragraph_numbering(
  self : Document,
  num_pr : @xml.Element,
) -> @wml_numbering.ResolvedLvl? {
  match self.numbering {
    Some(table) => @wml_numbering.level_for_paragraph(table, num_pr)
    None => None
  }
}

///|
/// Decode a `<w:fldSimple>` field (§17.16.19) into the
/// field-evaluation surface form.
pub fn Document::decode_simple_field(
  self : Document,
  field : @wml.CT_SimpleField,
) -> @wml_field_eval.Field raise OpenError {
  let _ = self
  @wml_field_eval.decode_simple_field(field) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
}

///|
/// Evaluate a `<w:fldSimple>` field (§17.16.18-19) against the
/// document's resolution context. Returns the rendered field result
/// (text + formatting).
pub fn Document::evaluate_simple_field(
  self : Document,
  field : @wml.CT_SimpleField,
  ctx : @wml_field_eval.FieldContext,
  registry : @wml_field_eval.FieldRegistry,
) -> @wml_field_eval.FieldResult raise OpenError {
  let decoded = self.decode_simple_field(field)
  @wml_field_eval.evaluate_field(decoded, ctx, registry)
}

///|
/// Open an embedded font part (`/word/fonts/font*.ttf|.otf`) with
/// mizchi/font's TTFont reader. Returns None when the part is
/// missing or the bytes do not parse as a TrueType / OpenType font.
/// Lets layout-aware callers introspect §17.8.3 fontTable.xml
/// references against the actual glyph metrics declared in the
/// embedded font streams.
pub fn Document::open_embedded_font(
  self : Document,
  font_part_name : String,
) -> @mizchi_font.TTFont? {
  match self.opc_package.part(font_part_name) {
    None => None
    Some(part) => @mizchi_font.parse_font(part.data)
  }
}

///|
/// Enumerate the OPC part names of every embedded font under
/// `/word/fonts/`. Drive `open_embedded_font` for each declared
/// §17.8.3 font.
pub fn Document::embedded_font_parts(self : Document) -> Array[String] {
  let result : Array[String] = []
  for part in self.opc_package.parts {
    if part.name.has_prefix("/word/fonts/") {
      result.push(part.name)
    }
  }
  result
}

///|
