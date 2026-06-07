///|
/// PresentationML context — parser-built Presentation tree plus IO
/// (open / save) and render queries (to_svg / to_svg_for_slide).
/// Mutating operations are in the sibling `edit/` package and
/// consume this context.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/context"
}

///|
pub(all) suberror OpenError {
  OpenError(kind~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
pub(all) suberror SaveError {
  SaveError(kind~ : String, path~ : String, reason~ : String)
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
  opc_package : @opc.Package
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
    let opc_package = @opc.Package::open(bytes)
    let presentation_part = find_package_relationship_part(
      opc_package,
      @opc_namespaces.relationship_type_office_document(),
      "ppt/presentation.xml",
    )
    let presentation = @pml_reader.read_presentation(
      opc_package.required_part(
        presentation_part,
        section="6.3.3",
        source_path="/",
      ).data,
    )
    {
      opc_package,
      presentation_part,
      presentation,
      slides: read_slides(opc_package, presentation_part),
      slide_masters: read_slide_masters(opc_package, presentation_part),
      slide_layouts: read_slide_layouts(opc_package),
      themes: raw_parts_with_prefix(opc_package, "/ppt/theme/theme"),
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
pub fn Presentation::save_or_raise(
  self : Presentation,
) -> Bytes raise SaveError {
  let mut saved = self.opc_package.with_part(
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
  // Content-Types map, invalid part names). A raw
  // `ppt/presentation.xml` fallback is not a valid `.pptx`
  // package.
  saved.save() catch {
    err =>
      raise SaveError(
        kind="PackageSaveFailed",
        path=self.presentation_part,
        reason=err.to_string(),
      )
  }
}

///|
/// Backward-compatible save entry point. Callers that need structured
/// diagnostics should use `save_or_raise`; this method intentionally
/// aborts on package serialisation failure rather than producing a
/// non-OPC presentation XML blob.
pub fn Presentation::save(self : Presentation) -> Bytes {
  try! self.save_or_raise()
}

///|
/// Render slide `slide_index` (0-based) as a stand-alone SVG document
/// per §19.3.1.38, with image references resolved through the
/// slide's `.rels` table. Picture shapes (`<p:pic>`) are emitted as
/// `<image>` elements with data-URI payloads sourced from the
/// referenced `/ppt/media/imageN.*` parts. Text shapes (`<p:sp>`)
/// emit `<text>` elements positioned at the EMU coordinates declared
/// by `<a:xfrm>`.
/// `debug_attrs` (default `false`) drops every `data-ooxml-*`
/// attribute on the way out — see `Presentation::to_svg` for the
/// SoT rationale.
pub fn Presentation::to_svg_for_slide(
  self : Presentation,
  slide_index : Int,
  debug_attrs? : Bool = false,
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
  // §21.1.2.3.5 CT_Hyperlink — a run's `<a:rPr>/<a:hlinkClick r:id>`
  // (and shape-level `<…NvPr>/<a:hlinkClick>`) names a hyperlink as a
  // relationship id scoped to THIS slide part's rels.  Map that rId
  // to its external URL so the viewer can place it in `xlink:href`.
  // The render is per-slide, so a single resolver bound to the
  // slide's rels suffices.
  let hyperlink_resolver = fn(rid : String) -> String? {
    resolve_slide_hyperlink(self, slide.name, rid)
  }
  // §21.4.2.22 CT_RelIds — resolve an rId on the slide's rels into
  // a part's root XML element. The diagram renderer asks for the
  // four SmartArt parts (data1.xml / layout1.xml / quickStyle1.xml
  // / colors1.xml) by rId and parses each to feed the layout
  // engine. Returns None for unknown rIds or malformed XML so the
  // viewer falls back to its placeholder.
  let parts_resolver = fn(rid : String) -> @xml.Element? {
    resolve_slide_part(self, slide.name, rid)
  }
  // §21.3 chartDrawing — given the rId of a chart part on the slide's
  // rels (i.e. the rId on `<c:chart r:id>`), return a resolver scoped
  // to that chart part's own rels.  The chart renderer uses it to
  // resolve `<c:userShapes r:id>` and other chart-internal
  // references that live in the chart-part rels table.  Returns
  // `None` when the rId is unknown to the slide rels or the target
  // part has no rels.
  let chart_part_resolver_factory = fn(
    chart_rid : String,
  ) -> ((String) -> @xml.Element?)? {
    resolve_part_scoped_resolver(self, slide.name, chart_rid)
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
  let table_style_list = self.resolve_table_style_list()
  // §19.2.1.39 / §19.3.1.41 sldSz — when `<p:presentation>/<p:sldSz>`
  // is present its `@cx` / `@cy` (EMU) MUST drive every rendered
  // slide's viewport. Without sldSz the viewer falls back to its
  // own default (screen4x3 = 10" × 7.5") because the spec does not
  // mandate one.
  let presentation_root : @xml.Element? = Some(self.presentation.element)
  let svg = match self.presentation.sld_sz {
    Some(sz) =>
      @pml_viewer.render_svg(
        slide.value,
        width_emu=sz.cx.emu,
        height_emu=sz.cy.emu,
        image_resolver=resolver,
        part_resolver=parts_resolver,
        chart_part_resolver_factory~,
        hyperlink_resolver~,
        theme=typed_theme,
        table_style_list~,
        chain~,
        presentation=presentation_root,
      )
    None =>
      @pml_viewer.render_svg(
        slide.value,
        image_resolver=resolver,
        part_resolver=parts_resolver,
        chart_part_resolver_factory~,
        hyperlink_resolver~,
        theme=typed_theme,
        table_style_list~,
        chain~,
        presentation=presentation_root,
      )
  }
  if debug_attrs {
    svg
  } else {
    @markup.strip_debug_attrs(svg)
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
  match self.opc_package.relationships(slide.name) {
    None => ()
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/slideLayout") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let ln_result = try? @opc_part_name.resolve_target(
            slide.name,
            rel.target,
          )
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
        match self.opc_package.relationships(ln) {
          None => ()
          Some(rs) =>
            for rel in rs.relationships {
              if rel.type_uri.has_suffix("/slideMaster") &&
                rel.target_mode == @relationships.TargetMode::Internal {
                let mn_result = try? @opc_part_name.resolve_target(
                  ln,
                  rel.target,
                )
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
      Some(
        @pml_placeholder.SlideChain::from_parts(mv, layout, Some(slide.value)),
      )
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
  let layout_name = match self.opc_package.relationships(slide.name) {
    None => return None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/slideLayout") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let ln_result = try? @opc_part_name.resolve_target(
            slide.name,
            rel.target,
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
  let master_name = match self.opc_package.relationships(layout_name) {
    None => return None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/slideMaster") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let mn_result = try? @opc_part_name.resolve_target(
            layout_name,
            rel.target,
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
  let theme_name = match self.opc_package.relationships(master_name) {
    None => return None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/theme") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let tn_result = try? @opc_part_name.resolve_target(
            master_name,
            rel.target,
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
      try @theme.read_theme(theme_part.data) catch {
        _ => return None
      } noraise {
        t => return Some(t)
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
    try @theme.read_theme(theme_part.data) catch {
      _ => continue
    } noraise {
      t => return Some(t)
    }
  }
  None
}

///|
/// §19 presentation relationships — resolve `/ppt/tableStyles.xml`
/// through the presentation part's explicit `…/tableStyles`
/// relationship and parse it as DrawingML `CT_TableStyleList`.
fn Presentation::resolve_table_style_list(
  self : Presentation,
) -> @a.CT_TableStyleList? {
  let rels = match self.opc_package.relationships(self.presentation_part) {
    Some(rs) => rs
    None => return None
  }
  for rel in rels.relationships {
    if rel.type_uri.has_suffix("/tableStyles") &&
      rel.target_mode == @relationships.TargetMode::Internal {
      let part_name = try
        @opc_part_name.resolve_target(self.presentation_part, rel.target)
      catch {
        _ => return None
      } noraise {
        name => name
      }
      let part = match self.opc_package.part(part_name) {
        Some(p) => p
        None => return None
      }
      try @a.read_table_style_list(part.data) catch {
        _ => return None
      } noraise {
        styles => return Some(styles)
      }
    }
  }
  None
}

///|
/// Backwards-compatible entry point. Returns the first slide's SVG;
/// falls back to a tiny placeholder when no slides exist or rendering
/// raises.
///
/// `debug_attrs` (default `false`) controls whether the viewer's
/// `data-ooxml-*` decoration survives in the returned SVG.  The
/// flag exists because those attributes are inspection labels
/// (presentation-level metadata, slide transitions, timing trees,
/// theme references …) that the catalog harness's differential
/// render verifier consumes; production consumers (browsers,
/// snapshot diffs) MUST see only paint primitives.  The single
/// SoT that decides whether labels survive is
/// `@markup.strip_debug_attrs`, applied here on the way out —
/// the per-slide viewer code stays free to keep emitting them
/// unconditionally so spec-aware consumers that opt in
/// (`debug_attrs=true`) always see the full label set.
pub fn Presentation::to_svg(
  self : Presentation,
  debug_attrs? : Bool = false,
) -> String {
  if self.slides.length() == 0 {
    return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"450\"></svg>"
  }
  let result = try? self.to_svg_for_slide(0, debug_attrs~)
  match result {
    Ok(svg) => svg
    Err(_) =>
      "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"450\"><text x=\"16\" y=\"32\">pptx:" +
      @xml.escape_text(self.presentation.element.name.local_name) +
      "</text></svg>"
  }
}

///|
/// §21.3 — given the rId of a part referenced from the SLIDE rels
/// (e.g. the chart part), return a resolver that walks THAT part's
/// own rels.  Used by the chart renderer to resolve
/// `<c:userShapes r:id>` and similar chart-internal references whose
/// rIds belong to the chart-part rels table, not the slide rels.
/// Returns `None` when the rId is unknown to the slide rels or the
/// target part has no rels.
fn resolve_part_scoped_resolver(
  presentation : Presentation,
  slide_part_name : String,
  outer_rid : String,
) -> ((String) -> @xml.Element?)? {
  // Resolve the outer rId against the slide rels.
  let slide_rels = match
    presentation.opc_package.relationships(slide_part_name) {
    Some(r) => r
    None => return None
  }
  let target_rel = match slide_rels.find_by_id(outer_rid) {
    Some(r) => r
    None => return None
  }
  let nested_part_name = try
    @opc_part_name.resolve_target(slide_part_name, target_rel.target)
  catch {
    _ => return None
  } noraise {
    name => name
  }
  // The nested part may have its own rels file (`_rels/<part>.xml.rels`).
  let nested_rels = match
    presentation.opc_package.relationships(nested_part_name) {
    Some(r) => r
    None => return None
  }
  let pkg = presentation.opc_package
  let base = nested_part_name
  let rels = nested_rels
  Some(fn(rid : String) -> @xml.Element? {
    let rel = match rels.find_by_id(rid) {
      Some(r) => r
      None => return None
    }
    let resolved = try @opc_part_name.resolve_target(base, rel.target) catch {
      _ => return None
    } noraise {
      name => name
    }
    let part = match pkg.part(resolved) {
      Some(p) => p
      None => return None
    }
    try @xml.parse(part.data) catch {
      _ => None
    } noraise {
      doc => Some(doc.root)
    }
  })
}

///|
/// §21.4.2.22 CT_RelIds — resolve a slide-scoped rId into the
/// referenced part's root XML element. The diagram renderer calls
/// this for each of the four SmartArt parts (dataModel, layoutDef,
/// styleDef, colorsDef) via the `r:dm` / `r:lo` / `r:qs` / `r:cs`
/// attributes on `<dgm:relIds>`. Returns `None` when the rId is
/// unknown to the slide's rels or when the referenced part's XML
/// cannot be parsed.
fn resolve_slide_part(
  presentation : Presentation,
  slide_part_name : String,
  rid : String,
) -> @xml.Element? {
  let rels = presentation.opc_package.relationships(slide_part_name)
  let rel = match rels {
    Some(rs) => rs.find_by_id(rid)
    None => return None
  }
  let target_rel = match rel {
    Some(r) => r
    None => return None
  }
  let resolved = try
    @opc_part_name.resolve_target(slide_part_name, target_rel.target)
  catch {
    _ => return None
  } noraise {
    name => name
  }
  let part = match presentation.opc_package.part(resolved) {
    Some(p) => p
    None => return None
  }
  try @xml.parse(part.data) catch {
    _ => None
  } noraise {
    doc => Some(doc.root)
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
  let rels = presentation.opc_package.relationships(slide_part_name)
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
          match presentation.opc_package.part(part_name) {
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
/// §21.1.2.3.5 CT_Hyperlink — resolve a slide-scoped relationship Id
/// (`rId1`, ...) carried on `<a:hlinkClick r:id>` to the external URL
/// it points at.  The rId is looked up in THIS slide part's `.rels`
/// table; a matching relationship of type
/// `…/officeDocument/2006/relationships/hyperlink` carries the URL in
/// its `Target` attribute (with `TargetMode="External"`), so we
/// return `rel.target` directly — the External target IS the URL, no
/// part-name resolution needed.  Returns `None` when the slide has no
/// rels, the rId is unknown, or the relationship is not a hyperlink
/// (e.g. an action-only internal jump), in which case the viewer
/// keeps the raw rId in `xlink:href`.
fn resolve_slide_hyperlink(
  presentation : Presentation,
  slide_part_name : String,
  rid : String,
) -> String? {
  let rels = presentation.opc_package.relationships(slide_part_name)
  let found = match rels {
    Some(rs) => rs.find_by_id(rid)
    None => None
  }
  match found {
    None => None
    Some(rel) =>
      // §15.2.2 — the hyperlink relationship type is the only one
      // whose Target is an external navigation URL; other rIds on the
      // slide rels (images, charts, layouts, …) must not leak into
      // `xlink:href`.
      if rel.type_uri.has_suffix("/hyperlink") {
        Some(rel.target)
      } else {
        None
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
  opc_package : @opc.Package,
  owner : String,
) -> Array[SlidePart] raise {
  let result : Array[SlidePart] = []
  match opc_package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/slide") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match opc_package.part(name) {
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
  opc_package : @opc.Package,
  owner : String,
) -> Array[SlideMasterPart] raise {
  let result : Array[SlideMasterPart] = []
  match opc_package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/slideMaster") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match opc_package.part(name) {
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
fn read_slide_layouts(
  opc_package : @opc.Package,
) -> Array[SlideLayoutPart] raise {
  let result : Array[SlideLayoutPart] = []
  for part in opc_package.parts {
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
  opc_package : @opc.Package,
  prefix : String,
) -> Array[@opc.PackagePart] {
  let result : Array[@opc.PackagePart] = []
  for part in opc_package.parts {
    if part.name.has_prefix(prefix) {
      result.push(part)
    }
  }
  result
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
