///|
/// Public facade for .xlsx files. Orchestrates OPC and SpreadsheetML.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml/context"
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
pub(all) struct WorksheetPart {
  name : String
  value : @sml.CT_Worksheet
  /// §20.5.2.35 xdr:wsDr — optional spreadsheet drawing referenced
  /// from `<worksheet>/<drawing r:id=...>` and resolved through the
  /// worksheet-part relationships at open time. `None` when no
  /// drawing part is referenced (the common case for purely
  /// tabular workbooks).
  drawing : @drawing.WsDr?
  /// OPC part name of the drawing XML (e.g. `/xl/drawings/drawing1.xml`).
  /// Preserved so the image-resolver closure can index the drawing
  /// part's own `_rels` file when looking up `r:embed` Ids. `None`
  /// when no drawing reference exists.
  drawing_part : String?
  /// §18.3.1.31 `<legacyDrawing>` — worksheet-scoped VML Drawing
  /// part resolved from the worksheet part's `.../vmlDrawing`
  /// relationship.  The root is the raw null-namespace `<xml>` VML
  /// wrapper so the viewer can hand the payload to the chapter-neutral
  /// VML renderer without the context depending on SVG details.
  legacy_drawing : @xml.Element?
  /// OPC part name of the VML Drawing XML (e.g.
  /// `/xl/drawings/vmlDrawing1.vml`). `None` when the worksheet has
  /// no `<legacyDrawing>` relationship or it cannot be resolved.
  legacy_drawing_part : String?
  /// §18.3.1.32 `<legacyDrawingHF>` — VML Drawing part used by
  /// header/footer graphics, resolved through the worksheet part's
  /// relationships.  Kept separate from `legacy_drawing` because the
  /// two worksheet elements own distinct relationship ids and drawing
  /// parts.
  legacy_drawing_hf : @xml.Element?
  /// OPC part name of the header/footer VML Drawing XML.
  legacy_drawing_hf_part : String?
  /// §18.5.1.2 `<table>` parts referenced by the worksheet's
  /// `<tableParts>/<tablePart r:id="…"/>` children, loaded through
  /// the worksheet-part `_rels`. Each entry is the raw `<table>`
  /// root element from `xl/tables/tableN.xml`, in the order the
  /// `<tableParts>` lists them. Empty when the worksheet declares
  /// no `<tableParts>` (the common bare-grid case). The renderer
  /// consumes them via `render_svg`'s `tables` parameter to paint
  /// the table-style chrome (header band, row/col stripes, totals
  /// border, autofilter dropdown arrows) per §18.5.1.5
  /// ST_TableStyleType / §18.8.43 built-in styles.
  tables : Array[@xml.Element]
  /// §18.7.6 `<comments>` — the worksheet's legacy comment part
  /// (`xl/comments<N>.xml`), resolved through the worksheet-part
  /// `_rels` `.../comments` relationship.  The root `<comments>`
  /// element is preserved raw; the renderer reads its
  /// `<commentList>/<comment @ref>` cells to paint the comment
  /// indicator triangle.  `None` when the worksheet has no comments.
  comments : @xml.Element?
  /// §18.12 `<queryTable>` parts referenced by worksheet relationships.
  /// Each entry is parsed as typed `CT_QueryTable`; the connection id
  /// points into the workbook-level §18.13 `connections` part.
  query_tables : Array[@sml.CT_QueryTable]
  /// §18.5.2 tableSingleCells parts referenced by worksheet relationships.
  /// Each root is parsed as `CT_SingleXmlCells`.
  single_xml_cells : Array[SingleXmlCellsPart]
  /// §18.3.1.20 `<controls>` — ActiveX/form-control persistence
  /// parts resolved from `<control r:id="...">` relationships.  The
  /// worksheet element supplies the anchor and relationship id; the
  /// resolved part supplies control-specific properties such as the
  /// ActiveX caption/class id.
  control_parts : Array[WorksheetControlPart]
  /// §18.3.1.16 `<customProperties>` — application-defined sheet
  /// custom property parts resolved from `<customPr r:id>`.
  custom_property_parts : Array[WorksheetCustomPropertyPart]
} derive(Eq, Debug)

///|
pub(all) struct WorksheetControlPart {
  r_id : String
  name : String
  value : @xml.Element
} derive(Eq, Debug)

///|
pub(all) struct WorksheetCustomPropertyPart {
  r_id : String
  name : String
  value : @xml.Element
} derive(Eq, Debug)

///|
pub(all) struct SingleXmlCellsPart {
  name : String
  value : @sml.CT_SingleXmlCells
} derive(Eq, Debug)

///|
pub(all) struct ChartsheetPart {
  name : String
  value : @sml.CT_Chartsheet
  /// §18.3.1.36 `<chartsheet>/<drawing r:id=...>` resolved through
  /// the chartsheet part relationships.  The drawing part carries the
  /// graphicFrame that points at the actual §21.2 chart part.
  drawing : @drawing.WsDr?
  drawing_part : String?
} derive(Eq, Debug)

///|
pub(all) struct Workbook {
  opc_package : @opc.Package
  workbook_part : String
  workbook : @sml.CT_Workbook
  worksheets : Array[WorksheetPart]
  chartsheets : Array[ChartsheetPart]
  shared_strings : @sml.CT_Sst?
  styles : @sml.CT_Stylesheet?
  /// §18.9 Metadata part (`/xl/metadata.xml`). Cells reference
  /// this workbook-level store through CT_Cell `@cm` / `@vm`.
  metadata : @sml.CT_Metadata?
  /// §18.13 External Connections part (`/xl/connections.xml`). Query
  /// tables and external data refresh metadata reference this
  /// workbook-level store by connection id.
  connections : @sml.CT_Connections?
  /// §18.6 Calculation Chain part (`/xl/calcChain.xml`). Formula cells
  /// reference this workbook-level dependency order by cell ref.
  calc_chain : @sml.CT_CalcChain?
  /// §18.16 Custom XML Mappings part (`/xl/xmlMaps.xml`). Worksheet
  /// tableSingleCells and XML column mappings refer to these map ids.
  xml_maps : @sml.CT_MapInfo?
  /// §18.15 Volatile Dependencies part
  /// (`/xl/volatileDependencies.xml`). RTD/OLAP formula dependency
  /// metadata is workbook-level rather than worksheet-local.
  volatile_dependencies : @sml.CT_VolTypes?
  /// §18.11.1.2 Shared Workbook Revision Headers part.  Discovered
  /// through the workbook part's `.../revisionHeaders` relationship
  /// rather than a fixed path because the OPC part name is package
  /// owned.
  revision_headers_part : String?
  revision_headers : @sml.CT_RevisionHeaders?
  /// §18.11.1.20 Shared Workbook Revision Log parts referenced by
  /// the revision headers part's `.../revisionLog` relationships.
  revision_logs : Array[RevisionLogPart]
  /// §18.14 External Link parts referenced by workbook
  /// `<externalReferences>/<externalReference r:id>`.
  external_links : Array[ExternalLinkPart]
  /// §18.11.1.27 User Names part for shared-workbook editing state,
  /// discovered through the workbook part's `.../usernames`
  /// relationship.
  user_names_part : String?
  user_names : @sml.CT_Users?
  theme : @opc.PackagePart?
} derive(Eq, Debug)

///|
pub(all) struct RevisionLogPart {
  name : String
  value : @sml.CT_Revisions
} derive(Eq, Debug)

///|
pub(all) struct ExternalLinkPart {
  name : String
  value : @sml.CT_ExternalLink
} derive(Eq, Debug)

///|
pub fn open(bytes : Bytes) -> Workbook raise OpenError {
  try {
    let opc_package = @opc.Package::open(bytes)
    let workbook_part = find_package_relationship_part(
      opc_package,
      @opc_namespaces.relationship_type_office_document(),
      "xl/workbook.xml",
    )
    let workbook = @sml_reader.read_workbook(
      opc_package.required_part(workbook_part, section="6.3.3", source_path="/").data,
    )
    let revision_headers_info = read_workbook_revision_headers(
      opc_package, workbook_part,
    )
    let (revision_headers_part, revision_headers) = match
      revision_headers_info {
      Some((name, value)) => (Some(name), Some(value))
      None => (None, None)
    }
    let revision_logs = match revision_headers_part {
      Some(name) => read_workbook_revision_logs(opc_package, name)
      None => []
    }
    let external_links = read_workbook_external_links(
      opc_package, workbook_part,
    )
    let user_names_info = read_workbook_user_names(opc_package, workbook_part)
    let (user_names_part, user_names) = match user_names_info {
      Some((name, value)) => (Some(name), Some(value))
      None => (None, None)
    }
    {
      opc_package,
      workbook_part,
      workbook,
      worksheets: read_worksheets(opc_package, workbook_part, workbook),
      chartsheets: read_chartsheets(opc_package, workbook_part, workbook),
      // ECMA-376 §18.4.8 specifies `<sst>` as the top-level element
      // name in xl/sharedStrings.xml; use `read_sst` not the
      // `read_shared_strings` legacy alias so Office-produced
      // fixtures (which use the canonical `<sst>` root) open cleanly.
      shared_strings: opc_package.read_optional(
        "/xl/sharedStrings.xml", @sml_reader.read_sst,
      ),
      styles: opc_package.read_optional(
        "/xl/styles.xml", @sml_reader.read_style_sheet,
      ),
      metadata: opc_package.read_optional(
        "/xl/metadata.xml", @sml_reader.read_metadata,
      ),
      connections: opc_package.read_optional(
        "/xl/connections.xml", @sml_reader.read_connections,
      ),
      calc_chain: opc_package.read_optional(
        "/xl/calcChain.xml", @sml_reader.read_calc_chain,
      ),
      xml_maps: opc_package.read_optional(
        "/xl/xmlMaps.xml", @sml_reader.read_map_info,
      ),
      volatile_dependencies: opc_package.read_optional(
        "/xl/volatileDependencies.xml", @sml_reader.read_vol_types,
      ),
      revision_headers_part,
      revision_headers,
      revision_logs,
      external_links,
      user_names_part,
      user_names,
      // §18.8.3 / OPC §11.3.10 — discover the theme part via
      // the workbook's relationship table. A canonical theme part is
      // used only when present and no relationship names another part.
      theme: locate_theme_part(opc_package, workbook_part),
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
    @sml_reader.SchemaViolation(schema~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=schema + ": " + reason,
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
pub fn Workbook::save_or_raise(self : Workbook) -> Bytes raise SaveError {
  let mut opc_package = self.opc_package
    .with_part(self.workbook_part, @sml_builder.write_workbook(self.workbook))
    .with_optional_part(
      "/xl/sharedStrings.xml",
      self.shared_strings,
      @sml_builder.write_shared_strings,
    )
    .with_optional_part(
      "/xl/styles.xml",
      self.styles,
      @sml_builder.write_style_sheet,
    )
    .with_optional_part(
      "/xl/metadata.xml",
      self.metadata,
      @sml_builder.write_metadata,
    )
    .with_optional_part(
      "/xl/connections.xml",
      self.connections,
      @sml_builder.write_connections,
    )
    .with_optional_part(
      "/xl/calcChain.xml",
      self.calc_chain,
      @sml_builder.write_calc_chain,
    )
    .with_optional_part(
      "/xl/xmlMaps.xml",
      self.xml_maps,
      @sml_builder.write_map_info,
    )
    .with_optional_part(
      "/xl/volatileDependencies.xml",
      self.volatile_dependencies,
      @sml_builder.write_vol_types,
    )
  match self.revision_headers_part {
    Some(name) =>
      match self.revision_headers {
        Some(headers) =>
          opc_package = opc_package.with_part(
            name,
            @sml_builder.write_headers(headers),
          )
        None => ()
      }
    None => ()
  }
  for log in self.revision_logs {
    opc_package = opc_package.with_part(
      log.name,
      @sml_builder.write_revisions(log.value),
    )
  }
  for link in self.external_links {
    opc_package = opc_package.with_part(
      link.name,
      @sml_builder.write_external_link(link.value),
    )
  }
  match self.user_names_part {
    Some(name) =>
      match self.user_names {
        Some(users) =>
          opc_package = opc_package.with_part(
            name,
            @sml_builder.write_users(users),
          )
        None => ()
      }
    None => ()
  }
  let mut saved = opc_package
  for worksheet in self.worksheets {
    saved = saved.with_part(
      worksheet.name,
      @sml_builder.write_worksheet(worksheet.value),
    )
    for single_xml_cells in worksheet.single_xml_cells {
      saved = saved.with_part(
        single_xml_cells.name,
        @sml_builder.write_table_single_cells(single_xml_cells.value),
      )
    }
  }
  saved.save() catch {
    err =>
      raise SaveError(
        kind="PackageSaveFailed",
        path=self.workbook_part,
        reason=err.to_string(),
      )
  }
}

///|
/// Backward-compatible save entry point. Callers that need structured
/// diagnostics should use `save_or_raise`; this method intentionally
/// aborts on package serialisation failure rather than producing a
/// non-OPC workbook XML blob.
pub fn Workbook::save(self : Workbook) -> Bytes {
  try! self.save_or_raise()
}

///|
/// Render every worksheet as its own §18.3 CT_Worksheet SVG via
/// `@sml_viewer.render_svg`, concatenating the resulting `<svg>`
/// documents in workbook order. Shared strings (§18.4 CT_Sst), when
/// present in the package, are threaded through so `@t="s"` cells
/// resolve into their text bodies.
///
/// @source web-pptx packages/@aurochs-renderer/xlsx/src/svg/sheet-renderer.ts:30
///         (renderSheetToSvg) — Workbook::to_svg is the workbook-level
///         orchestrator the web-pptx renderer never had to provide
///         because its public API is per-sheet, but the ooxml facade
///         emits the workbook as a single document so client code
///         doesn't need to know about sheet count up-front.
///
/// `debug_attrs` (default `false`) controls whether the viewer's
/// `data-ooxml-*` decoration survives in the returned SVG.  The
/// flag exists because those attributes are inspection labels
/// (workbook protection, file version, pivot/sparkline metadata,
/// pageSetup …) that the catalog harness's differential render
/// verifier consumes; production consumers (a browser embedding
/// the SVG, a snapshot diff against a reference renderer) MUST
/// see only paint primitives.  The SoT that decides whether they
/// survive is exactly one byte-stream pass
/// (`@markup.strip_debug_attrs`) applied here on the way out, so
/// the per-sheet viewer code stays free to keep emitting labels.
pub fn Workbook::to_svg(self : Workbook, debug_attrs? : Bool = false) -> String {
  let buf = StringBuilder::new()
  // §18.8.3 — parse the theme part once per workbook render so
  // each worksheet picks up the same colour scheme.  Failure to
  // parse silently falls back to no-theme rendering; the raw
  // bytes survive on `self.theme` for diagnostic purposes.
  let theme_root : @xml.Element? = match self.theme {
    None => None
    Some(part) =>
      try @xml.parse(part.data) catch {
        _ => None
      } noraise {
        doc => Some(doc.root)
      }
  }
  // §18.2.28 `<workbookPr @date1904>` — the workbook-wide date
  // system flag; passed to every worksheet render so serial
  // dates resolve against the correct epoch.
  let date1904 = match self.workbook.workbook_pr {
    Some(pr) => pr.date1904
    None => false
  }
  // §18.2.19 — `<workbook>/<pivotCaches>/<pivotCache>` maps a cacheId
  // to a relationship pointing at the cache definition part. Build
  // a workbook-scoped lookup once so each per-sheet pivot discovery
  // can resolve `pivotTableDefinition/@cacheId` without re-walking
  // the relationship table. The pivot cache definition is itself
  // related to a `pivotCacheRecords` part via its own `_rels` file
  // (the relationship type ends in `/pivotCacheRecords`).
  let cache_lookup = build_pivot_cache_lookup(
    self.opc_package,
    self.workbook_part,
    self.workbook,
  )
  let pivot_cache_definitions = read_pivot_cache_definitions(
    self.opc_package,
    cache_lookup,
  )
  for sheet_index, worksheet in self.worksheets {
    let image_resolver = build_drawing_image_resolver(
      self.opc_package,
      worksheet.drawing_part,
    )
    let worksheet_image_resolver = build_worksheet_image_resolver(
      self.opc_package,
      worksheet.name,
    )
    // §21.2 — resolve `<c:chart r:id>` references on a graphicFrame
    // through the worksheet drawing's `_rels` so the chart renderer
    // can pull the referenced chart part's root element.
    let chart_part_resolver = build_drawing_chart_part_resolver(
      self.opc_package,
      worksheet.drawing_part,
    )
    // §18.3.1.47 — resolve `<hyperlink @r:id>` references through the
    // WORKSHEET part's `_rels` (the rel is External-mode `/hyperlink`,
    // so its `Target` is the URL) so the renderer can wrap each
    // hyperlinked cell in a clickable SVG `<a>`.
    let hyperlink_resolver = build_worksheet_hyperlink_resolver(
      self.opc_package,
      worksheet.name,
    )
    let control_part_resolver = build_worksheet_control_part_resolver(
      worksheet.control_parts,
    )
    let custom_property_resolver = build_worksheet_custom_property_resolver(
      worksheet.custom_property_parts,
    )
    // §18.10 — discover any pivot tables tied to this worksheet via
    // the worksheet-part's relationships (`…/pivotTable` rels point
    // at `xl/pivotTables/pivotTableN.xml`). For each one, look up
    // its cache via `cache_lookup`, decode + materialize, then hand
    // the bundle to the renderer.
    let pivots = collect_worksheet_pivots(
      self.opc_package,
      worksheet.name,
      cache_lookup,
    )
    // §18.17 — evaluate every formula cell in this worksheet so the
    // renderer can display computed results instead of cached values.
    let date_system = if date1904 {
      @sml_date_serial.DateSystem::Serial1904
    } else {
      @sml_date_serial.DateSystem::Serial1900
    }
    let snapshot = @sml_formula.WorksheetSnapshot::new(
      worksheet.name,
      date_system,
    ).with_worksheet(worksheet.value)
    let snapshot = match self.shared_strings {
      Some(sst) => snapshot.with_sst(sst)
      None => snapshot
    }
    let evaluated = @sml_formula.evaluate_sheet_with_pivot_data(snapshot, fn(
      request,
    ) {
      @sml_pivot.get_pivot_data(pivots, request)
    })
    // Each sheet's SVG ids are namespaced with the sheet index so
    // per-cell ids (clip paths, defs) stay unique once the sheets
    // are concatenated into a single document.
    let result = @sml_viewer.render_svg(
      worksheet.value,
      shared_strings=self.shared_strings,
      drawing=worksheet.drawing,
      legacy_drawing=worksheet.legacy_drawing,
      legacy_drawing_hf=worksheet.legacy_drawing_hf,
      image_resolver~,
      worksheet_image_resolver~,
      styles=self.styles,
      theme=theme_root,
      date1904~,
      id_prefix="s" + sheet_index.to_string() + "-",
      pivots~,
      pivot_cache_definitions~,
      tables=worksheet.tables,
      comments=worksheet.comments,
      query_tables=worksheet.query_tables,
      revision_headers=self.revision_headers,
      revision_logs=revision_log_values(self.revision_logs),
      user_names=self.user_names,
      workbook=Some(self.workbook.element),
      connections=self.connections,
      calc_chain=self.calc_chain,
      xml_maps=self.xml_maps,
      volatile_dependencies=self.volatile_dependencies,
      metadata=self.metadata,
      single_xml_cells=single_xml_cells_values(worksheet.single_xml_cells),
      external_links=external_link_values(self.external_links),
      evaluated_cells=Some(evaluated),
      part_resolver=chart_part_resolver,
      hyperlink_resolver~,
      control_part_resolver~,
      custom_property_resolver~,
    )
    buf.write_string(result.svg)
  }
  for chartsheet_index, chartsheet in self.chartsheets {
    let image_resolver = build_drawing_image_resolver(
      self.opc_package,
      chartsheet.drawing_part,
    )
    let chart_part_resolver = build_drawing_chart_part_resolver(
      self.opc_package,
      chartsheet.drawing_part,
    )
    let result = @sml_viewer.render_chartsheet_svg(
      chartsheet.value,
      drawing=chartsheet.drawing,
      image_resolver~,
      theme=theme_root,
      id_prefix="cs" + chartsheet_index.to_string() + "-",
      part_resolver=chart_part_resolver,
    )
    buf.write_string(result.svg)
  }
  let svg = buf.to_string()
  if debug_attrs {
    svg
  } else {
    @markup.strip_debug_attrs(svg)
  }
}

///|
/// Build an `image_resolver` closure that maps a worksheet drawing's
/// `r:embed` Ids to `data:<mime>;base64,<…>` URIs by walking the
/// drawing part's `_rels/<drawing>.xml.rels` for the resolved image
/// part. Relationship lookup stays scoped to the drawing part.
fn build_drawing_image_resolver(
  opc_package : @opc.Package,
  drawing_part_name : String?,
) -> (String) -> String? {
  match drawing_part_name {
    None => fn(_) { None }
    Some(part_name) => build_part_image_resolver(opc_package, part_name)
  }
}

///|
/// §18.3.1.84 CT_SheetBackgroundPicture — build a resolver for
/// `<worksheet>/<picture r:id="...">`. The relationship id is scoped
/// to the worksheet part, so this closure reads the worksheet part's
/// `.rels` and only resolves internal `/image` relationships there.
fn build_worksheet_image_resolver(
  opc_package : @opc.Package,
  worksheet_part_name : String,
) -> (String) -> String? {
  build_part_image_resolver(opc_package, worksheet_part_name)
}

///|
/// Neutral SoT for OPC image resolution from a relationship owner
/// part. The caller chooses the owner part according to the OOXML
/// element being rendered: drawing pictures pass the drawing part;
/// worksheet background pictures pass the worksheet part.
fn build_part_image_resolver(
  opc_package : @opc.Package,
  owner_part_name : String,
) -> (String) -> String? {
  match opc_package.relationships(owner_part_name) {
    None => fn(_) { None }
    Some(rels) => {
      let part = owner_part_name
      let pkg = opc_package
      let relationships = rels
      fn(rid : String) -> String? {
        for rel in relationships.relationships {
          if rel.id == rid &&
            rel.target_mode == @relationships.TargetMode::Internal &&
            rel.type_uri.has_suffix("/image") {
            let image_name = try
              @opc_part_name.resolve_target(part, rel.target)
            catch {
              _ => continue
            } noraise {
              name => name
            }
            match pkg.part(image_name) {
              Some(image_part) =>
                return Some(
                  "data:" +
                  drawing_mime_for_target(rel.target) +
                  ";base64," +
                  @base64.encode(image_part.data),
                )
              None => ()
            }
          }
        }
        None
      }
    }
  }
}

///|
/// Build a `part_resolver` closure that maps a `<c:chart r:id="…"/>`
/// rId to the referenced chart part's root XML element by walking
/// the drawing part's `_rels/<drawing>.xml.rels`.  Mirrors
/// `build_drawing_image_resolver` but resolves `/chart` relationships
/// instead of `/image` ones and returns the parsed root element so
/// the chart renderer can traverse the typed XML tree.
fn build_drawing_chart_part_resolver(
  opc_package : @opc.Package,
  drawing_part_name : String?,
) -> (String) -> @xml.Element? {
  match drawing_part_name {
    None => fn(_) { None }
    Some(part_name) =>
      match opc_package.relationships(part_name) {
        None => fn(_) { None }
        Some(rels) => {
          let part = part_name
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
                        try @xml.parse(chart_part.data) catch {
                          _ => ()
                        } noraise {
                          doc => return Some(doc.root)
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
}

///|
/// §18.3.1.47 CT_Hyperlink — build a `hyperlink_resolver` closure
/// that maps a worksheet `<hyperlink @r:id>` to its external target
/// URL by walking the WORKSHEET part's `_rels/<sheet>.xml.rels` for
/// the matching `/hyperlink` relationship.  These rels are
/// External-mode (`TargetMode="External"`), so the relationship's
/// `Target` IS the URL verbatim — no `@opc_part_name.resolve_target`
/// is applied (that would mangle an absolute URL into a package part
/// path).  Mirrors `build_drawing_image_resolver` but resolves
/// against the worksheet part (not the drawing part) and returns the
/// target string directly.  Returns a closure that always yields
/// `None` when the worksheet has no relationships; the SML viewer
/// then uses its §18.3.1.47 `@location` / metadata-only handling.
fn build_worksheet_hyperlink_resolver(
  opc_package : @opc.Package,
  worksheet_part_name : String,
) -> (String) -> String? {
  match opc_package.relationships(worksheet_part_name) {
    None => fn(_) { None }
    Some(rels) => {
      let relationships = rels
      fn(rid : String) -> String? {
        for rel in relationships.relationships {
          if rel.id == rid &&
            rel.target_mode == @relationships.TargetMode::External &&
            rel.type_uri.has_suffix("/hyperlink") {
            return Some(rel.target)
          }
        }
        None
      }
    }
  }
}

///|
/// Build a resolver for worksheet form controls.  The key is the
/// `<control r:id>` value scoped to the worksheet part; values are the
/// parsed root elements of the resolved control persistence parts.
fn build_worksheet_control_part_resolver(
  control_parts : Array[WorksheetControlPart],
) -> (String) -> @xml.Element? {
  fn(rid : String) -> @xml.Element? {
    for part in control_parts {
      if part.r_id == rid {
        return Some(part.value)
      }
    }
    None
  }
}

///|
fn build_worksheet_custom_property_resolver(
  custom_property_parts : Array[WorksheetCustomPropertyPart],
) -> (String) -> @xml.Element? {
  fn(rid : String) -> @xml.Element? {
    for part in custom_property_parts {
      if part.r_id == rid {
        return Some(part.value)
      }
    }
    None
  }
}

///|
/// Pick a MIME-type for an OPC image part based on its target path
/// extension. Mirrors web-pptx's typeFromExtension mapping for the
/// common Excel-side image formats.
fn drawing_mime_for_target(target : String) -> String {
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
    "application/octet-stream"
  }
}

///|
fn read_worksheets(
  opc_package : @opc.Package,
  owner : String,
  workbook : @sml.CT_Workbook,
) -> Array[WorksheetPart] raise {
  let result : Array[WorksheetPart] = []
  let rel_targets = worksheet_relationship_targets(opc_package, owner)
  match workbook.sheets {
    Some(sheets) =>
      for sheet in sheets.sheets {
        match rel_targets.get(sheet.r_id) {
          Some(name) =>
            match read_worksheet_part(opc_package, name) {
              Some(part) => result.push(part)
              None => ()
            }
          None => ()
        }
      }
    None => ()
  }
  result
}

///|
fn read_chartsheets(
  opc_package : @opc.Package,
  owner : String,
  workbook : @sml.CT_Workbook,
) -> Array[ChartsheetPart] raise {
  let result : Array[ChartsheetPart] = []
  let rel_targets = chartsheet_relationship_targets(opc_package, owner)
  match workbook.sheets {
    Some(sheets) =>
      for sheet in sheets.sheets {
        match rel_targets.get(sheet.r_id) {
          Some(name) =>
            match read_chartsheet_part(opc_package, name) {
              Some(part) => result.push(part)
              None => ()
            }
          None => ()
        }
      }
    None => ()
  }
  result
}

///|
fn worksheet_relationship_targets(
  opc_package : @opc.Package,
  owner : String,
) -> Map[String, String] raise {
  let targets : Map[String, String] = Map([], capacity=0)
  match opc_package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/worksheet") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          targets.set(rel.id, name)
        }
      }
    None => ()
  }
  targets
}

///|
fn chartsheet_relationship_targets(
  opc_package : @opc.Package,
  owner : String,
) -> Map[String, String] raise {
  let targets : Map[String, String] = Map([], capacity=0)
  match opc_package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/chartsheet") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          targets.set(rel.id, name)
        }
      }
    None => ()
  }
  targets
}

///|
fn read_workbook_revision_headers(
  opc_package : @opc.Package,
  workbook_part : String,
) -> (String, @sml.CT_RevisionHeaders)? raise {
  match opc_package.relationships(workbook_part) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/revisionHeaders") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(workbook_part, rel.target)
          let part = opc_package.required_part(
            name,
            section="12.3.16",
            source_path=workbook_part,
          )
          return Some((name, @sml_reader.read_headers(part.data)))
        }
      }
      None
    }
  }
}

///|
fn read_workbook_revision_logs(
  opc_package : @opc.Package,
  revision_headers_part : String,
) -> Array[RevisionLogPart] raise {
  let out : Array[RevisionLogPart] = []
  match opc_package.relationships(revision_headers_part) {
    None => out
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/revisionLog") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(
            revision_headers_part,
            rel.target,
          )
          let part = opc_package.required_part(
            name,
            section="12.3.17",
            source_path=revision_headers_part,
          )
          out.push({ name, value: @sml_reader.read_revisions(part.data) })
        }
      }
      out
    }
  }
}

///|
fn read_workbook_external_links(
  opc_package : @opc.Package,
  workbook_part : String,
) -> Array[ExternalLinkPart] raise {
  let out : Array[ExternalLinkPart] = []
  match opc_package.relationships(workbook_part) {
    None => out
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/externalLink") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(workbook_part, rel.target)
          let part = opc_package.required_part(
            name,
            section="12.3.9",
            source_path=workbook_part,
          )
          out.push({ name, value: @sml_reader.read_external_link(part.data) })
        }
      }
      out
    }
  }
}

///|
fn read_workbook_user_names(
  opc_package : @opc.Package,
  workbook_part : String,
) -> (String, @sml.CT_Users)? raise {
  match opc_package.relationships(workbook_part) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/usernames") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(workbook_part, rel.target)
          let part = opc_package.required_part(
            name,
            section="12.3.18",
            source_path=workbook_part,
          )
          return Some((name, @sml_reader.read_users(part.data)))
        }
      }
      None
    }
  }
}

///|
fn revision_log_values(
  parts : Array[RevisionLogPart],
) -> Array[@sml.CT_Revisions] {
  let out : Array[@sml.CT_Revisions] = []
  for part in parts {
    out.push(part.value)
  }
  out
}

///|
fn external_link_values(
  parts : Array[ExternalLinkPart],
) -> Array[@sml.CT_ExternalLink] {
  let out : Array[@sml.CT_ExternalLink] = []
  for part in parts {
    out.push(part.value)
  }
  out
}

///|
fn single_xml_cells_values(
  parts : Array[SingleXmlCellsPart],
) -> Array[@sml.CT_SingleXmlCells] {
  let out : Array[@sml.CT_SingleXmlCells] = []
  for part in parts {
    out.push(part.value)
  }
  out
}

///|
fn read_worksheet_part(
  opc_package : @opc.Package,
  name : String,
) -> WorksheetPart? raise {
  match opc_package.part(name) {
    Some(part) => {
      let worksheet = @sml_reader.read_worksheet(part.data)
      let (drawing, drawing_part) = match
        read_worksheet_drawing(opc_package, name, worksheet) {
        Some((wsdr, dn)) => (Some(wsdr), Some(dn))
        None => (None, None)
      }
      let (legacy_drawing, legacy_drawing_part) = match
        read_worksheet_legacy_drawing(opc_package, name, worksheet) {
        Some((root, part_name)) => (Some(root), Some(part_name))
        None => (None, None)
      }
      let (legacy_drawing_hf, legacy_drawing_hf_part) = match
        read_worksheet_legacy_drawing_hf(opc_package, name, worksheet) {
        Some((root, part_name)) => (Some(root), Some(part_name))
        None => (None, None)
      }
      let tables = read_worksheet_tables(opc_package, name)
      let comments = read_worksheet_comments(opc_package, name)
      let query_tables = read_worksheet_query_tables(opc_package, name)
      let single_xml_cells = read_worksheet_single_xml_cells(opc_package, name)
      let control_parts = read_worksheet_control_parts(
        opc_package, name, worksheet,
      )
      let custom_property_parts = read_worksheet_custom_property_parts(
        opc_package, name, worksheet,
      )
      Some({
        name,
        value: worksheet,
        drawing,
        drawing_part,
        legacy_drawing,
        legacy_drawing_part,
        legacy_drawing_hf,
        legacy_drawing_hf_part,
        tables,
        comments,
        query_tables,
        single_xml_cells,
        control_parts,
        custom_property_parts,
      })
    }
    None => None
  }
}

///|
fn read_chartsheet_part(
  opc_package : @opc.Package,
  name : String,
) -> ChartsheetPart? raise {
  match opc_package.part(name) {
    Some(part) => {
      let chartsheet = @sml_reader.read_chartsheet(part.data)
      let (drawing, drawing_part) = match
        read_chartsheet_drawing(opc_package, name, chartsheet) {
        Some((wsdr, dn)) => (Some(wsdr), Some(dn))
        None => (None, None)
      }
      Some({ name, value: chartsheet, drawing, drawing_part })
    }
    None => None
  }
}

///|
/// §18.7.6 — resolve the worksheet's `.../comments` relationship and
/// return the parsed root `<comments>` element of `xl/commentsN.xml`.
/// Returns `None` when the worksheet references no comment part.
fn read_worksheet_comments(
  opc_package : @opc.Package,
  worksheet_part_name : String,
) -> @xml.Element? {
  match opc_package.relationships(worksheet_part_name) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/comments") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = try
            @opc_part_name.resolve_target(worksheet_part_name, rel.target)
          catch {
            _ => continue
          } noraise {
            n => n
          }
          match opc_package.part(name) {
            Some(part) =>
              try @xml.parse(part.data) catch {
                _ => ()
              } noraise {
                doc => return Some(doc.root)
              }
            None => ()
          }
        }
      }
      None
    }
  }
}

///|
/// §18.12 — resolve worksheet `.../queryTable` relationships and
/// return typed query table parts in relationship order.
fn read_worksheet_query_tables(
  opc_package : @opc.Package,
  worksheet_part_name : String,
) -> Array[@sml.CT_QueryTable] raise {
  let out : Array[@sml.CT_QueryTable] = []
  match opc_package.relationships(worksheet_part_name) {
    None => out
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/queryTable") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(
            worksheet_part_name,
            rel.target,
          )
          let part = opc_package.required_part(
            name,
            section="12.3.17",
            source_path=worksheet_part_name,
          )
          out.push(@sml_reader.read_query_table(part.data))
        }
      }
      out
    }
  }
}

///|
/// §18.3.1.20 / §18.3.1.32 — resolve every worksheet `<control r:id>`
/// through the worksheet part's `.../control` relationships and parse
/// the target ActiveX/control persistence parts as raw XML roots.
fn read_worksheet_control_parts(
  opc_package : @opc.Package,
  worksheet_part_name : String,
  worksheet : @sml.CT_Worksheet,
) -> Array[WorksheetControlPart] {
  let out : Array[WorksheetControlPart] = []
  let controls = match worksheet.controls {
    Some(value) => value
    None => return out
  }
  match opc_package.relationships(worksheet_part_name) {
    None => return out
    Some(rels) => {
      for control in controls.controls {
        let rid = control.r_id
        if rid.length() == 0 {
          continue
        }
        for rel in rels.relationships {
          if rel.id == rid &&
            rel.type_uri.has_suffix("/control") &&
            rel.target_mode == @relationships.TargetMode::Internal {
            let control_name = try
              @opc_part_name.resolve_target(worksheet_part_name, rel.target)
            catch {
              _ => continue
            } noraise {
              name => name
            }
            match opc_package.part(control_name) {
              Some(part) =>
                try @xml.parse(part.data) catch {
                  _ => ()
                } noraise {
                  doc =>
                    out.push({ r_id: rid, name: control_name, value: doc.root })
                }
              None => ()
            }
          }
        }
      }
      out
    }
  }
}

///|
/// §18.3.1.16 / §18.3.1.18 — resolve worksheet custom property
/// relationships from `<customPr r:id>` to their application-defined
/// XML parts.
fn read_worksheet_custom_property_parts(
  opc_package : @opc.Package,
  worksheet_part_name : String,
  worksheet : @sml.CT_Worksheet,
) -> Array[WorksheetCustomPropertyPart] {
  let out : Array[WorksheetCustomPropertyPart] = []
  let custom_properties = match worksheet.custom_properties {
    Some(value) => value
    None => return out
  }
  match opc_package.relationships(worksheet_part_name) {
    None => return out
    Some(rels) => {
      for custom_pr in custom_properties.custom_pr {
        let rid = custom_pr.r_id
        if rid.length() == 0 {
          continue
        }
        for rel in rels.relationships {
          if rel.id == rid &&
            rel.type_uri.has_suffix("/customProperty") &&
            rel.target_mode == @relationships.TargetMode::Internal {
            let part_name = try
              @opc_part_name.resolve_target(worksheet_part_name, rel.target)
            catch {
              _ => continue
            } noraise {
              name => name
            }
            match opc_package.part(part_name) {
              Some(part) =>
                try @xml.parse(part.data) catch {
                  _ => ()
                } noraise {
                  doc =>
                    out.push({ r_id: rid, name: part_name, value: doc.root })
                }
              None => ()
            }
          }
        }
      }
      out
    }
  }
}

///|
fn read_chartsheet_drawing(
  opc_package : @opc.Package,
  chartsheet_part_name : String,
  chartsheet : @sml.CT_Chartsheet,
) -> (@drawing.WsDr, String)? raise {
  let drawing_r_id = match chartsheet.drawing {
    Some(drawing) => drawing.r_id
    None => return None
  }
  if drawing_r_id.length() == 0 {
    return None
  }
  match opc_package.relationships(chartsheet_part_name) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.id == drawing_r_id &&
          rel.type_uri.has_suffix("/drawing") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let drawing_name = @opc_part_name.resolve_target(
            chartsheet_part_name,
            rel.target,
          )
          match opc_package.part(drawing_name) {
            Some(part) =>
              return Some((@drawing.read_ws_dr(part.data), drawing_name))
            None => ()
          }
        }
      }
      None
    }
  }
}

///|
/// Resolve the `<drawing r:id="...">` reference inside a worksheet to
/// the corresponding `xl/drawings/drawingN.xml` part. Returns the
/// pair `(typed WsDr, drawing part name)` so callers can index the
/// drawing part's own `_rels` for image-resolution. `None` when the
/// worksheet has no drawing reference or the rels can't be resolved.
fn read_worksheet_drawing(
  opc_package : @opc.Package,
  worksheet_part_name : String,
  worksheet : @sml.CT_Worksheet,
) -> (@drawing.WsDr, String)? raise {
  let drawing_r_id = match worksheet.drawing {
    Some(drawing) => drawing.r_id
    None => return None
  }
  if drawing_r_id.length() == 0 {
    return None
  }
  match opc_package.relationships(worksheet_part_name) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.id == drawing_r_id &&
          rel.type_uri.has_suffix("/drawing") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let drawing_name = @opc_part_name.resolve_target(
            worksheet_part_name,
            rel.target,
          )
          match opc_package.part(drawing_name) {
            Some(part) =>
              return Some((@drawing.read_ws_dr(part.data), drawing_name))
            None => ()
          }
        }
      }
      None
    }
  }
}

///|
/// Resolve `<legacyDrawing r:id="...">` to the VML Drawing part
/// owned by the worksheet.  The relationship type is the standard
/// officeDocument `/vmlDrawing` relationship; the target part root is
/// the null-namespace `<xml>` wrapper mandated for VML Drawing parts.
fn read_worksheet_legacy_drawing(
  opc_package : @opc.Package,
  worksheet_part_name : String,
  worksheet : @sml.CT_Worksheet,
) -> (@xml.Element, String)? {
  let drawing_r_id = match worksheet.legacy_drawing {
    Some(drawing) => drawing.r_id
    None => return None
  }
  read_worksheet_vml_drawing(opc_package, worksheet_part_name, drawing_r_id)
}

///|
/// Resolve `<legacyDrawingHF r:id="...">` to the header/footer VML
/// Drawing part owned by the worksheet.
fn read_worksheet_legacy_drawing_hf(
  opc_package : @opc.Package,
  worksheet_part_name : String,
  worksheet : @sml.CT_Worksheet,
) -> (@xml.Element, String)? {
  let drawing_r_id = match worksheet.legacy_drawing_hf {
    Some(drawing) => drawing.r_id
    None => return None
  }
  read_worksheet_vml_drawing(opc_package, worksheet_part_name, drawing_r_id)
}

///|
fn read_worksheet_vml_drawing(
  opc_package : @opc.Package,
  worksheet_part_name : String,
  drawing_r_id : String,
) -> (@xml.Element, String)? {
  if drawing_r_id.length() == 0 {
    return None
  }
  match opc_package.relationships(worksheet_part_name) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.id == drawing_r_id &&
          rel.type_uri.has_suffix("/vmlDrawing") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let drawing_name = try
            @opc_part_name.resolve_target(worksheet_part_name, rel.target)
          catch {
            _ => continue
          } noraise {
            name => name
          }
          match opc_package.part(drawing_name) {
            Some(part) =>
              try @xml.parse(part.data) catch {
                _ => ()
              } noraise {
                doc => return Some((doc.root, drawing_name))
              }
            None => ()
          }
        }
      }
      None
    }
  }
}

///|
/// §18.5.1.2 — load the `<table>` parts referenced by the
/// worksheet's `<tableParts>/<tablePart r:id="…"/>` children.
/// Walks the worksheet-part `_rels` for `.../table` relationships
/// (the rel type ends in `/table`), resolves each target through
/// `@opc_part_name.resolve_target`, and returns the parsed root
/// element of each `xl/tables/tableN.xml`.  Order follows the
/// worksheet's `<tableParts>` declaration so the renderer paints
/// chrome in the same z-order Excel uses.  Returns an empty array
/// when the worksheet declares no table parts (the common case).
fn read_worksheet_tables(
  opc_package : @opc.Package,
  worksheet_part_name : String,
) -> Array[@xml.Element] {
  let tables : Array[@xml.Element] = []
  // Build a rId → table-part-name map from the worksheet's rels.
  let rid_to_part : Map[String, String] = Map([], capacity=0)
  match opc_package.relationships(worksheet_part_name) {
    None => return tables
    Some(rels) =>
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/table") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          try
            @opc_part_name.resolve_target(worksheet_part_name, rel.target)
          catch {
            _ => ()
          } noraise {
            name => rid_to_part.set(rel.id, name)
          }
        }
      }
  }
  if rid_to_part.length() == 0 {
    return tables
  }
  // Walk `<worksheet>/<tableParts>/<tablePart r:id="…"/>` in source
  // order; for each rId, parse the referenced part's XML root.
  let worksheet_part = match opc_package.part(worksheet_part_name) {
    Some(p) => p
    None => return tables
  }
  let worksheet_root = try @xml.parse(worksheet_part.data) catch {
    _ => return tables
  } noraise {
    doc => doc.root
  }
  for child in worksheet_root.children {
    match child {
      Element(e) =>
        if e.name.local_name == "tableParts" {
          for tp_node in e.children {
            match tp_node {
              Element(tp) =>
                if tp.name.local_name == "tablePart" {
                  // §18.3.1.95 `<tablePart r:id="rIdN"/>` carries the
                  // table-part rId in the relationships namespace.
                  let mut rid : String? = None
                  for attr in tp.attributes {
                    if attr.name.local_name == "id" {
                      rid = Some(attr.value)
                    }
                  }
                  match rid {
                    Some(r) =>
                      match rid_to_part.get(r) {
                        Some(part_name) =>
                          match opc_package.part(part_name) {
                            Some(part) =>
                              try @xml.parse(part.data) catch {
                                _ => ()
                              } noraise {
                                doc => tables.push(doc.root)
                              }
                            None => ()
                          }
                        None => ()
                      }
                    None => ()
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  tables
}

///|
/// §18.5.2 — load tableSingleCells parts referenced by worksheet
/// relationships. Unlike `<table>` parts, the relationship itself
/// owns discovery; the root is parsed as `CT_SingleXmlCells`.
fn read_worksheet_single_xml_cells(
  opc_package : @opc.Package,
  worksheet_part_name : String,
) -> Array[SingleXmlCellsPart] raise {
  let out : Array[SingleXmlCellsPart] = []
  match opc_package.relationships(worksheet_part_name) {
    None => out
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/tableSingleCells") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(
            worksheet_part_name,
            rel.target,
          )
          let part = opc_package.required_part(
            name,
            section="12.3.19",
            source_path=worksheet_part_name,
          )
          out.push({ name, value: read_single_xml_cells_part(part.data) })
        }
      }
      out
    }
  }
}

///|
fn read_single_xml_cells_part(data : Bytes) -> @sml.CT_SingleXmlCells raise {
  let doc = @xml.parse(data)
  match doc.root.name.local_name {
    "singleXmlCells" | "tableSingleCells" =>
      @sml.CT_SingleXmlCells::new(doc.root)
    _ => @sml_reader.read_table_single_cells(data)
  }
}

///|
/// §18.8.3 / OPC §11.3.10 — locate the workbook's theme part
/// via its relationship table.  Returns None when no theme rel
/// nor canonical `/xl/theme/theme1.xml` part is present.
fn locate_theme_part(
  opc_package : @opc.Package,
  workbook_part : String,
) -> @opc.PackagePart? {
  // Look for a `/theme` relationship from the workbook.
  let theme_target : String? = match opc_package.relationships(workbook_part) {
    None => None
    Some(rs) => {
      let mut found : String? = None
      for rel in rs.relationships {
        if rel.type_uri.has_suffix("/theme") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let resolved = try? @opc_part_name.resolve_target(
            workbook_part,
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
  let primary = match theme_target {
    Some(name) => name
    None => "/xl/theme/theme1.xml"
  }
  opc_package.part(primary)
}

///|
fn find_package_relationship_part(
  opc_package : @opc.Package,
  relationship_type : String,
  default_part : String,
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
  "/" + default_part
}

///|
/// Evaluate a §18.3.1.10 conditional-formatting block over the given
/// cells. The cells must already be value-resolved (e.g. through the
/// reader's cell decoder); cf_rule_eval returns the per-cell match
/// records (rule + bucket).
pub fn Workbook::evaluate_conditional_formatting(
  self : Workbook,
  block : @sml.CT_ConditionalFormatting,
  cells : Array[(@sml_address.CellAddress, @sml_formula.FormulaValue)],
  ctx : @sml_cf_eval.EvalContext,
) -> Array[@sml_cf_eval.MatchHit] {
  let _ = self
  @sml_cf_eval.evaluate_cf_block(block, cells, ctx)
}

///|
/// Parse a §18.3.1.2 `<autoFilter>` element into its typed
/// CT_AutoFilter projection.
pub fn Workbook::parse_auto_filter(
  self : Workbook,
  element : @xml.Element,
) -> @sml.CT_AutoFilter raise OpenError {
  let _ = self
  @sml_autofilter.parse_auto_filter(element) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
}

///|
/// Evaluate row visibility under §18.3.2 autoFilter rules. Returns
/// `true` if the row satisfies every active FilterColumn condition.
pub fn Workbook::auto_filter_row_visible(
  self : Workbook,
  filter : @sml.CT_AutoFilter,
  row : @sml_autofilter.CandidateRow,
  date_system : @sml_date_serial.DateSystem,
) -> Bool {
  let _ = self
  @sml_autofilter.row_visible(filter, row, date_system)
}

///|
/// Evaluate row visibility under §18.3.2 over one row carrying resolved
/// fill/font colour and iconSet facts.
pub fn Workbook::auto_filter_row_visible_with_formats(
  self : Workbook,
  filter : @sml.CT_AutoFilter,
  row : @sml_autofilter.FormattedCandidateRow,
  dxf_formats : Array[@sml_autofilter.FilterDxfFormat],
  date_system : @sml_date_serial.DateSystem,
) -> Bool {
  let _ = self
  @sml_autofilter.row_visible_with_formats(
    filter, row, dxf_formats, date_system,
  )
}

///|
/// Evaluate §18.3.2 autoFilter rules over a candidate row set. Returns
/// visible row indices. Value-only API; `colorFilter` and `iconFilter`
/// remain false without resolved format facts.
pub fn Workbook::auto_filter_visible_rows(
  self : Workbook,
  filter : @sml.CT_AutoFilter,
  rows : Array[@sml_autofilter.CandidateRow],
  date_system : @sml_date_serial.DateSystem,
) -> Array[Int] {
  let _ = self
  @sml_autofilter.filter_rows(filter, rows, date_system)
}

///|
/// Evaluate §18.3.2 autoFilter rules over rows that already carry
/// resolved fill/font colour and iconSet facts. Style/dxf resolution stays
/// with the caller; AutoFilter owns colorFilter/iconFilter comparison.
pub fn Workbook::auto_filter_visible_formatted_rows(
  self : Workbook,
  filter : @sml.CT_AutoFilter,
  rows : Array[@sml_autofilter.FormattedCandidateRow],
  dxf_formats : Array[@sml_autofilter.FilterDxfFormat],
  date_system : @sml_date_serial.DateSystem,
) -> Array[Int] {
  let _ = self
  @sml_autofilter.filter_formatted_rows(filter, rows, dxf_formats, date_system)
}

///|
/// Materialize a pivot table per §18.10. Combines a pivot definition
/// (§18.10.1) with its cache definition (§18.10.16) and records
/// (§18.10.18) to produce the row/column matrix and aggregated cells.
pub fn Workbook::materialize_pivot_table(
  self : Workbook,
  definition : @sml_pivot.PivotTableDefinition,
  cache : @sml_pivot.PivotCacheDefinition,
  records : @sml_pivot.PivotCacheRecords,
) -> @sml_pivot.PivotMaterialization raise OpenError {
  let _ = self
  @sml_pivot.materialize_pivot_table(definition, cache, records) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
}

///|
/// Parse a formula string per §18.17 grammar into a typed AST.
pub fn Workbook::parse_formula(
  self : Workbook,
  source : String,
) -> @sml_formula.FormulaAst raise OpenError {
  let _ = self
  @sml_formula.parse_formula(source) catch {
    @opc_errors.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
  }
}

///|
/// Evaluate a parsed formula AST under the given evaluation context.
/// Returns a FormulaValue (number/text/bool/error/array).
pub fn Workbook::evaluate_formula(
  self : Workbook,
  ast : @sml_formula.FormulaAst,
  ctx : @sml_formula.EvalContext,
) -> @sml_formula.FormulaValue {
  let _ = self
  @sml_formula.evaluate(ast, ctx)
}

///|
/// §18.2.19 — workbook-scoped pivot cache lookup. Maps `cacheId`
/// (the `<pivotCache>/@cacheId` attribute) to the resolved OPC
/// part name of the cache definition. `None` for the second slot
/// of each tuple means the records part is absent (a degenerate
/// cache the materializer treats as empty).
priv struct PivotCacheRef {
  cache_id : Int
  definition_part : String
  records_part : String?
}

///|
/// Build the workbook-scoped `cacheId → cache part name` lookup.
/// Walks `<workbook>/<pivotCaches>/<pivotCache>` for the rels,
/// resolves each rId via the workbook's relationships file, and
/// then loads the cache definition's own `_rels` to discover the
/// matching `pivotCacheRecords` part.
fn build_pivot_cache_lookup(
  opc_package : @opc.Package,
  workbook_part : String,
  workbook : @sml.CT_Workbook,
) -> Array[PivotCacheRef] {
  let result : Array[PivotCacheRef] = []
  let caches = match workbook.pivot_caches {
    Some(pc) => pc.pivot_cache
    None => return result
  }
  let wb_rels = match opc_package.relationships(workbook_part) {
    Some(r) => r
    None => return result
  }
  for pc in caches {
    if pc.r_id == "" {
      continue
    }
    // Resolve the rId to the cache definition part.
    let mut def_part : String? = None
    for rel in wb_rels.relationships {
      if rel.id == pc.r_id &&
        rel.target_mode == @relationships.TargetMode::Internal {
        try @opc_part_name.resolve_target(workbook_part, rel.target) catch {
          _ => ()
        } noraise {
          name => def_part = Some(name)
        }
      }
    }
    let definition_part = match def_part {
      Some(p) => p
      None => continue
    }
    // Locate the matching records part via the cache definition's
    // own `_rels` (the relationship type ends in
    // `…/pivotCacheRecords`).
    let mut records_part : String? = None
    match opc_package.relationships(definition_part) {
      None => ()
      Some(cdef_rels) =>
        for rel in cdef_rels.relationships {
          if rel.type_uri.has_suffix("/pivotCacheRecords") &&
            rel.target_mode == @relationships.TargetMode::Internal {
            try
              @opc_part_name.resolve_target(definition_part, rel.target)
            catch {
              _ => ()
            } noraise {
              name => records_part = Some(name)
            }
          }
        }
    }
    result.push({ cache_id: pc.cache_id, definition_part, records_part })
  }
  result
}

///|
/// §18.10.1.67 — keep the typed pivotCacheDefinition parts available
/// to the SVG metadata projection. The pivot overlay consumes the
/// decoded/materialized cache model, but some ECMA-376 cache branches
/// are metadata-only and live only on the domain `CT_PivotCacheDefinition`.
fn read_pivot_cache_definitions(
  opc_package : @opc.Package,
  cache_lookup : Array[PivotCacheRef],
) -> Array[@sml.CT_PivotCacheDefinition] {
  let out : Array[@sml.CT_PivotCacheDefinition] = []
  for entry in cache_lookup {
    match opc_package.part(entry.definition_part) {
      None => ()
      Some(part) =>
        try @sml_reader.read_pivot_cache_definition(part.data) catch {
          _ => ()
        } noraise {
          value => out.push(value)
        }
    }
  }
  out
}

///|
/// §18.10 — discover the pivot tables tied to `worksheet_part` and
/// materialize each one. Walks the worksheet's `_rels` for
/// `/pivotTable` relationship entries; for each, loads + decodes the
/// pivot table definition, looks up its cache via `cache_lookup`,
/// loads + decodes the cache definition / records, then runs the
/// materializer. Failures (missing parts, schema violations) drop
/// that pivot silently rather than aborting the worksheet render —
/// the renderer treats an empty pivot list as "no overlay".
fn collect_worksheet_pivots(
  opc_package : @opc.Package,
  worksheet_part : String,
  cache_lookup : Array[PivotCacheRef],
) -> Array[@sml_pivot.MaterializedPivotTable] {
  let result : Array[@sml_pivot.MaterializedPivotTable] = []
  let rels = match opc_package.relationships(worksheet_part) {
    Some(r) => r
    None => return result
  }
  for rel in rels.relationships {
    if !rel.type_uri.has_suffix("/pivotTable") ||
      rel.target_mode != @relationships.TargetMode::Internal {
      continue
    }
    let pivot_part_name = try
      @opc_part_name.resolve_target(worksheet_part, rel.target)
    catch {
      _ => continue
    } noraise {
      name => name
    }
    let pivot_part = match opc_package.part(pivot_part_name) {
      Some(p) => p
      None => continue
    }
    // 1. Decode the pivot table definition.
    let pivot_dom = try
      @sml_reader.read_pivot_table_definition(pivot_part.data)
    catch {
      _ => continue
    } noraise {
      v => v
    }
    let pivot_typed = try
      @sml_pivot.decode_pivot_table_definition(pivot_dom)
    catch {
      _ => continue
    } noraise {
      v => v
    }
    // 2. Resolve the cache via @cacheId.
    let cache_id = match pivot_typed.cache_id {
      Some(v) => v
      None => continue
    }
    let mut cache_ref : PivotCacheRef? = None
    for entry in cache_lookup {
      if entry.cache_id == cache_id {
        cache_ref = Some(entry)
        break
      }
    }
    let cache_entry = match cache_ref {
      Some(v) => v
      None => continue
    }
    let cache_part = match opc_package.part(cache_entry.definition_part) {
      Some(p) => p
      None => continue
    }
    let cache_dom = try
      @sml_reader.read_pivot_cache_definition(cache_part.data)
    catch {
      _ => continue
    } noraise {
      v => v
    }
    let cache_typed = try
      @sml_pivot.decode_pivot_cache_definition(cache_dom)
    catch {
      _ => continue
    } noraise {
      v => v
    }
    // 3. Decode the records.
    let records_typed = match cache_entry.records_part {
      None => {
        // No records — synthesise an empty records collection
        // so the materializer produces an empty table rather
        // than an out-of-range index error. The decoder needs a
        // DOM CT_PivotCacheRecords to chew on; build one from a
        // bare `<pivotCacheRecords/>` element.
        let empty : @sml_pivot.PivotCacheRecords = { count: Some(0), rows: [] }
        empty
      }
      Some(records_part_name) =>
        match opc_package.part(records_part_name) {
          None => { count: Some(0), rows: [] }
          Some(records_part) => {
            let records_dom = try
              @sml_reader.read_pivot_cache_records(records_part.data)
            catch {
              _ => continue
            } noraise {
              v => v
            }
            try
              @sml_pivot.decode_pivot_cache_records(
                records_dom,
                cache_typed.cache_fields,
              )
            catch {
              _ => continue
            } noraise {
              v => v
            }
          }
        }
    }
    // 4. Materialize.
    let materialization = try
      @sml_pivot.materialize_pivot_table(
        pivot_typed, cache_typed, records_typed,
      )
    catch {
      _ => continue
    } noraise {
      v => v
    }
    result.push({ definition: pivot_typed, cache: cache_typed, materialization })
  }
  result
}

///|
