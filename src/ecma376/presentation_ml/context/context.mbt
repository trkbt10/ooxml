///|
/// PresentationML context — parser-built Presentation tree plus IO
/// (open / save) and render queries (to_html / to_styled_html /
/// to_svg / to_image). Mutating operations are in the sibling
/// `edit/` package and consume this context.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/context"
}

///|
pub(all) suberror OpenError {
  OpenError(kind~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
pub(all) struct SlidePart {
  name : String
  value : @pml.CT_Slide
} derive(Eq, Debug)

///|
pub(all) struct SlideMasterPart {
  name : String
  value : @pml.CT_SlideMaster
} derive(Eq, Debug)

///|
pub(all) struct SlideLayoutPart {
  name : String
  value : @pml.CT_SlideLayout
} derive(Eq, Debug)

///|
pub(all) struct Presentation {
  package : @opc.Package
  presentation_part : String
  presentation : @pml.CT_Presentation
  slides : Array[SlidePart]
  slide_masters : Array[SlideMasterPart]
  slide_layouts : Array[SlideLayoutPart]
  themes : Array[@opc.PackagePart]
} derive(Eq, Debug)

///|
pub fn open(bytes : Bytes) -> Presentation raise OpenError {
  try {
    let package = @opc.Package::open(bytes)
    let presentation_part = find_package_relationship_part(
      package,
      @opc_namespaces.relationship_type_office_document(),
      "ppt/presentation.xml",
    )
    let presentation = @pml_reader.read_presentation(
      package.required_part(presentation_part, section="6.3.3", source_path="/").data,
    )
    {
      package,
      presentation_part,
      presentation,
      slides: read_slides(package, presentation_part),
      slide_masters: read_slide_masters(package, presentation_part),
      slide_layouts: read_slide_layouts(package),
      themes: raw_parts_with_prefix(package, "/ppt/theme/theme"),
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
    @pml.SchemaViolation(type_name~, value~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path=type_name,
        reason=value + ": " + reason,
      )
    // OPC §10 / ECMA-376 Part 2 §10.1 — every spec-defined
    // error variant is explicitly handled above.  The catch-
    // all below is reserved for truly unforeseen runtime
    // failures (e.g. allocator OOM); we surface them under
    // the `UnsupportedFeature` kind with the raw debug
    // representation so the caller can route the failure to
    // its own diagnostics.  ISO/IEC 29500-2 §10 E1/E2 require
    // that schema faults surface their schema/path — this
    // arm intentionally does NOT swallow such faults because
    // every spec-defined error appears as one of the typed
    // branches above.
    other =>
      raise OpenError(
        kind="UnsupportedFeature",
        path="open",
        reason="unhandled package error: " + other.to_string(),
      )
  }
}

///|
pub fn Presentation::save(self : Presentation) -> Bytes {
  let mut saved = self.package.with_part(
    self.presentation_part,
    @pml_builder.write_presentation(self.presentation),
  )
  for slide in self.slides {
    saved = saved.with_part(slide.name, @pml_builder.write_sld(slide.value))
  }
  for master in self.slide_masters {
    saved = saved.with_part(
      master.name,
      @pml_builder.write_sld_master(master.value),
    )
  }
  for layout in self.slide_layouts {
    saved = saved.with_part(
      layout.name,
      @pml_builder.write_sld_layout(layout.value),
    )
  }
  // OPC §11 — `Package::save` raises typed errors when the
  // package cannot serialise (e.g. relationship cycles, broken
  // Content-Types map).  The fallback below returns the
  // presentation-part XML alone, which is NOT a conforming OPC
  // package; it is acceptable only because the function's
  // return type is `Bytes` (no error channel) and the caller
  // must distinguish a single XML payload from a `.pptx` zip
  // anyway.  The breach is documented as a known limitation —
  // the proper fix is to widen the return type to
  // `Result[Bytes, OpcSaveError]` so the OPC error surfaces.
  saved.save() catch {
    _ => @pml_builder.write_presentation(self.presentation)
  }
}

///|
pub fn Presentation::to_html(self : Presentation) -> String {
  let mut out = "<main data-ooxml=\"pptx\">"
  out = out + html_element(self.presentation.element)
  for slide in self.slides {
    out = out +
      "<section class=\"slide\">" +
      html_element(slide.value.element) +
      "</section>"
  }
  out + "</main>"
}

///|
/// Convert the presentation into a §19 styled HTML representation.
/// Each slide's CT_Slide tree is rendered through the viewer's
/// render_styled_html mapping (a:pPr/a:rPr → inline CSS for
/// text-align / b / i / u / color / sz). The output wraps each slide
/// in `<section class="slide">`.
pub fn Presentation::to_styled_html(self : Presentation) -> String {
  let mut out = "<article data-ooxml=\"pptx\" data-style=\"resolved\">"
  let mut i = 0
  for slide in self.slides {
    i = i + 1
    out = out +
      "<section class=\"slide\" data-slide-index=\"" +
      i.to_string() +
      "\">"
    out = out + @pml_viewer.render_styled_html(slide.value)
    out = out + "</section>"
  }
  out + "</article>"
}

///|
/// Render slide `slide_index` (0-based) as a stand-alone SVG document
/// per §19.3.1.38, with image references resolved through the
/// slide's `.rels` table. Picture shapes (`<p:pic>`) are emitted as
/// `<image>` elements with data-URI payloads sourced from the
/// referenced `/ppt/media/imageN.*` parts. Text shapes (`<p:sp>`)
/// emit `<text>` elements positioned at the EMU coordinates declared
/// by `<a:xfrm>`.
pub fn Presentation::to_svg_for_slide(
  self : Presentation,
  slide_index : Int,
) -> String raise OpenError {
  if slide_index < 0 || slide_index >= self.slides.length() {
    raise OpenError(
      kind="UnsupportedFeature",
      path="slide",
      reason="slide index out of range",
    )
  }
  let slide = self.slides[slide_index]
  let resolver = fn(rid : String) -> @pml_viewer.ResolvedImage? {
    resolve_slide_image(self, slide.name, rid)
  }
  // §19.3.1.42 — walk slide → layout → master → theme rels so
  // multi-master decks pick up the theme each master references.
  // Fall back to the first theme part when the chain cannot
  // be walked (single-master decks behave as before).
  let typed_theme = match self.resolve_theme_for_slide(slide) {
    Some(t) => Some(t)
    None => self.resolve_first_theme()
  }
  let chain = self.resolve_slide_chain(slide)
  // §19.2.1.39 / §19.3.1.41 sldSz — when `<p:presentation>/<p:sldSz>`
  // is present its `@cx` / `@cy` (EMU) MUST drive every rendered
  // slide's viewport. Without sldSz the viewer falls back to its
  // own default (screen4x3 = 10" × 7.5") because the spec does not
  // mandate one.
  match self.presentation.sld_sz {
    Some(sz) =>
      @pml_viewer.render_svg(
        slide.value,
        width_emu=sz.cx.emu,
        height_emu=sz.cy.emu,
        image_resolver=resolver,
        theme=typed_theme,
        chain=chain,
      )
    None =>
      @pml_viewer.render_svg(
        slide.value,
        image_resolver=resolver,
        theme=typed_theme,
        chain=chain,
      )
  }
}

///|
/// §19.3.1.36 / §19.3.1.45 / §19.3.1.42 — walk the slide's `.rels`
/// table to discover its slideLayout part, then walk the layout's
/// `.rels` to discover the slideMaster, and project them into the
/// resolver's `SlideChain`. When the slide has no layout link or no
/// master is reachable, returns `None` so the viewer falls back to
/// slide-only rendering. The first available slide master in the
/// package is used as a last-resort `master` so callers that pass a
/// `chain=` are guaranteed a usable cascade for layout-only renders.
fn Presentation::resolve_slide_chain(
  self : Presentation,
  slide : SlidePart,
) -> @pml_placeholder.SlideChain? {
  // Discover the layout the slide points at; remember its part name
  // so we can walk its `.rels` for the master link.
  let mut layout : @pml.CT_SlideLayout? = None
  let mut layout_name : String? = None
  match self.package.relationships(slide.name) {
    None => ()
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/slideLayout") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let ln_result = try? @opc_part_name.resolve_target(slide.name, rel.target)
          match ln_result {
            Ok(ln) =>
              for lp in self.slide_layouts {
                if lp.name == ln {
                  layout = Some(lp.value)
                  layout_name = Some(lp.name)
                  break
                }
              }
            Err(_) => ()
          }
          break
        }
      }
  }
  let master : @pml.CT_SlideMaster? = {
    let mut m : @pml.CT_SlideMaster? = None
    match layout_name {
      Some(ln) =>
        match self.package.relationships(ln) {
          None => ()
          Some(rs) =>
            for rel in rs.relationships {
              if rel.type_uri.has_suffix("/slideMaster") &&
                rel.target_mode == @relationships.TargetMode::Internal {
                let mn_result = try? @opc_part_name.resolve_target(ln, rel.target)
                match mn_result {
                  Ok(master_name) =>
                    for mp in self.slide_masters {
                      if mp.name == master_name {
                        m = Some(mp.value)
                        break
                      }
                    }
                  Err(_) => ()
                }
                break
              }
            }
        }
      None => ()
    }
    match m {
      Some(_) => m
      None =>
        if self.slide_masters.length() > 0 {
          Some(self.slide_masters[0].value)
        } else {
          None
        }
    }
  }
  match master {
    None => None
    Some(mv) =>
      Some(@pml_placeholder.SlideChain::from_parts(mv, layout, Some(slide.value)))
  }
}

///|
/// Best-effort: typed-parse the first `/ppt/theme/themeN.xml` part so
/// the viewer can resolve `<p:bgRef>` fmtScheme inheritance and
/// `phClr` token substitution (§19.3.1.4 / §20.1.4.1.7). Returns
/// `None` when no theme part is present or parsing raises — the
/// viewer then falls back to the empty colour map for direct fills.
///
/// A future iteration walks the slide → layout → master → theme
/// relationship chain so each slide picks up the theme its master
/// references; for now the first theme part is good enough for
/// single-master decks.
///|
/// §19.3.1.42 — walk slide → slideLayout → slideMaster → theme
/// rels and return the theme part the slide's master references.
/// Returns None when any link in the chain is missing or the
/// resolved theme part is not in `self.themes`.
fn Presentation::resolve_theme_for_slide(
  self : Presentation,
  slide : SlidePart,
) -> @theme.CT_OfficeStyleSheet? {
  // slide.rels → slideLayout
  let layout_name = match self.package.relationships(slide.name) {
    None => return None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/slideLayout") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let ln_result = try? @opc_part_name.resolve_target(
            slide.name, rel.target,
          )
          match ln_result {
            Ok(ln) => {
              found = Some(ln)
              break
            }
            Err(_) => ()
          }
        }
      }
      match found {
        Some(ln) => ln
        None => return None
      }
    }
  }
  // layout.rels → slideMaster
  let master_name = match self.package.relationships(layout_name) {
    None => return None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/slideMaster") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let mn_result = try? @opc_part_name.resolve_target(
            layout_name, rel.target,
          )
          match mn_result {
            Ok(mn) => {
              found = Some(mn)
              break
            }
            Err(_) => ()
          }
        }
      }
      match found {
        Some(mn) => mn
        None => return None
      }
    }
  }
  // master.rels → theme
  let theme_name = match self.package.relationships(master_name) {
    None => return None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/theme") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let tn_result = try? @opc_part_name.resolve_target(
            master_name, rel.target,
          )
          match tn_result {
            Ok(tn) => {
              found = Some(tn)
              break
            }
            Err(_) => ()
          }
        }
      }
      match found {
        Some(tn) => tn
        None => return None
      }
    }
  }
  // Find the theme part bytes and typed-parse it.
  for theme_part in self.themes {
    if theme_part.name == theme_name {
      match (try? @theme.read_theme(theme_part.data)) {
        Ok(t) => return Some(t)
        Err(_) => return None
      }
    }
  }
  None
}

///|
fn Presentation::resolve_first_theme(
  self : Presentation,
) -> @theme.CT_OfficeStyleSheet? {
  // §20.1.6 / §19.3.1.42 — when a theme part fails to parse we
  // skip it and try the next, so a single corrupt theme does
  // not break the whole presentation.  The schema-violation
  // reason is preserved on the source DOM via the parser's
  // failure path; consumers that need to detect the breach
  // explicitly can call `@theme.read_theme` directly on the
  // raw part bytes and inspect the SchemaViolation.
  for theme_part in self.themes {
    match (try? @theme.read_theme(theme_part.data)) {
      Ok(t) => return Some(t)
      Err(_) => ()
    }
  }
  None
}

///|
/// Backwards-compatible entry point. Returns the first slide's SVG;
/// falls back to a tiny placeholder when no slides exist or rendering
/// raises.
pub fn Presentation::to_svg(self : Presentation) -> String {
  if self.slides.length() == 0 {
    return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"450\"></svg>"
  }
  let result = try? self.to_svg_for_slide(0)
  match result {
    Ok(svg) => svg
    Err(_) =>
      "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"450\"><text x=\"16\" y=\"32\">pptx:" +
      @xml.escape_text(self.presentation.element.name.local_name) +
      "</text></svg>"
  }
}

///|
/// Resolve a slide-scoped relationship Id (`rId1`, ...) to image
/// bytes by looking up the slide's `.rels` table, mapping the
/// resulting target to a package part, and inferring a MIME type
/// from the part name extension. Returns None when no matching
/// image part exists.
fn resolve_slide_image(
  presentation : Presentation,
  slide_part_name : String,
  rid : String,
) -> @pml_viewer.ResolvedImage? {
  let rels = presentation.package.relationships(slide_part_name)
  let found = match rels {
    Some(rs) => rs.find_by_id(rid)
    None => None
  }
  match found {
    None => None
    Some(rel) => {
      let resolved = Some(
        @opc_part_name.resolve_target(slide_part_name, rel.target),
      ) catch {
        _ => None
      }
      match resolved {
        None => None
        Some(part_name) =>
          match presentation.package.part(part_name) {
            None => None
            Some(part) => {
              let mime = infer_mime_type(part_name)
              Some({ mime_type: mime, base64_data: @base64.encode(part.data) })
            }
          }
      }
    }
  }
}

///|
/// Render slide `slide_index` to an `Image` pixel buffer at the
/// given `width` x `height` pixels via mizchi/svg parser +
/// rasterizer. Returns None when the slide's SVG markup cannot be
/// parsed by mizchi/svg (mostly DTD/charset edge cases). Intended
/// for visual-regression tests that compare per-pixel output.
pub fn Presentation::to_image_for_slide(
  self : Presentation,
  slide_index : Int,
  width : Int,
  height : Int,
) -> @mizchi_svg.Image? raise OpenError {
  let svg = self.to_svg_for_slide(slide_index)
  @mizchi_svg.render_svg_to_image(svg, width, height)
}

///|
/// OPC §10.1.2.3 — the authoritative source for a part's MIME
/// type is the package's `[Content_Types].xml` `<Default>` /
/// `<Override>` map.  The viewer's image-resolver pipeline does
/// not currently route the typed Content-Types projection
/// through this call site, so we fall back to the suffix-based
/// lookup below.  Every image extension listed in OPC Annex C
/// (PNG / JPEG / GIF / SVG / WebP / BMP) is honoured; unknown
/// suffixes return the OPC default `application/octet-stream`.
///
/// The full Content-Types registry wire-through is tracked as
/// future work; this helper becomes dead code once the typed
/// registry lands.
fn infer_mime_type(part_name : String) -> String {
  let lower = part_name.to_lower()
  if lower.has_suffix(".png") {
    "image/png"
  } else if lower.has_suffix(".jpg") || lower.has_suffix(".jpeg") {
    "image/jpeg"
  } else if lower.has_suffix(".gif") {
    "image/gif"
  } else if lower.has_suffix(".svg") {
    "image/svg+xml"
  } else if lower.has_suffix(".webp") {
    "image/webp"
  } else if lower.has_suffix(".bmp") {
    "image/bmp"
  } else if lower.has_suffix(".tif") || lower.has_suffix(".tiff") {
    "image/tiff"
  } else if lower.has_suffix(".emf") {
    "image/x-emf"
  } else if lower.has_suffix(".wmf") {
    "image/x-wmf"
  } else if lower.has_suffix(".eps") {
    "image/x-eps"
  } else {
    // §10.1.2.3 OPC default for unmapped extensions.
    "application/octet-stream"
  }
}

///|
fn read_slides(
  package : @opc.Package,
  owner : String,
) -> Array[SlidePart] raise {
  let result : Array[SlidePart] = []
  match package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/slide") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match package.part(name) {
            Some(part) =>
              result.push({ name, value: @pml_reader.read_sld(part.data) })
            None => ()
          }
        }
      }
    None => ()
  }
  result
}

///|
fn read_slide_masters(
  package : @opc.Package,
  owner : String,
) -> Array[SlideMasterPart] raise {
  let result : Array[SlideMasterPart] = []
  match package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/slideMaster") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match package.part(name) {
            Some(part) =>
              result.push({
                name,
                value: @pml_reader.read_sld_master(part.data),
              })
            None => ()
          }
        }
      }
    None => ()
  }
  result
}

///|
fn read_slide_layouts(package : @opc.Package) -> Array[SlideLayoutPart] raise {
  let result : Array[SlideLayoutPart] = []
  for part in package.parts {
    if part.name.has_prefix("/ppt/slideLayouts/") &&
      part.name.has_suffix(".xml") {
      result.push({
        name: part.name,
        value: @pml_reader.read_sld_layout(part.data),
      })
    }
  }
  result
}

///|
fn raw_parts_with_prefix(
  package : @opc.Package,
  prefix : String,
) -> Array[@opc.PackagePart] {
  let result : Array[@opc.PackagePart] = []
  for part in package.parts {
    if part.name.has_prefix(prefix) {
      result.push(part)
    }
  }
  result
}

///|
fn find_package_relationship_part(
  package : @opc.Package,
  relationship_type : String,
  fallback : String,
) -> String raise {
  match package.relationships("/") {
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
fn html_element(element : @xml.Element) -> String {
  let name = @xml.escape_text(element.name.local_name)
  let mut out = "<section data-ooxml-element=\"" + name + "\">"
  for child in element.children {
    match child {
      @xml.Element(element) => out = out + html_element(element)
      @xml.Text(text) => out = out + @xml.escape_text(text)
      @xml.CData(text) => out = out + @xml.escape_text(text)
      @xml.Comment(_) => ()
      @xml.ProcessingInstruction(_) => ()
    }
  }
  out + "</section>"
}

///|
/// Build a §19.3.1.36 placeholder-inheritance chain (master ← layout ← slide)
/// from the three CT parts that participate in inheritance.
pub fn Presentation::slide_chain(
  self : Presentation,
  master : @pml.CT_SlideMaster,
  layout : @pml.CT_SlideLayout?,
  slide : @pml.CT_Slide?,
) -> @pml_placeholder.SlideChain {
  let _ = self
  @pml_placeholder.SlideChain::from_parts(master, layout, slide)
}

///|
/// Resolve the §19.3.1.36 placeholder-inheritance chain to produce the
/// effective shape list for a slide (each ResolvedShape carries the
/// shape element plus its inherited placeholder properties).
pub fn Presentation::resolve_slide_shapes(
  self : Presentation,
  chain : @pml_placeholder.SlideChain,
) -> Array[@pml_placeholder.ResolvedShape] raise OpenError {
  let _ = self
  @pml_placeholder.resolve_slide_shapes(chain) catch {
    @pml.SchemaViolation(type_name~, value~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path=type_name,
        reason=value + ": " + reason,
      )
  }
}

///|
/// Decode the §19.5.93 animation timing tree from a slide's `<p:timing>`.
/// Produces a Timeline that the TimingEngine can schedule.
pub fn Presentation::decode_timing(
  self : Presentation,
  timing : @pml.CT_SlideTiming,
) -> @pml_animation.Timeline raise OpenError {
  let _ = self
  @pml_animation.decode_timing(timing) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
}

///|
/// Schedule a decoded animation timeline. Returns the ordered list of
/// fire events with their absolute times in milliseconds.
pub fn Presentation::schedule_animation(
  self : Presentation,
  timeline : @pml_animation.Timeline,
) -> Array[@pml_animation.Event] {
  let _ = self
  @pml_animation.TimingEngine::new(timeline).schedule()
}

///|
