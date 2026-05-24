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
} derive(Eq, Debug)

///|
pub(all) struct Workbook {
  package : @opc.Package
  workbook_part : String
  workbook : @sml.CT_Workbook
  worksheets : Array[WorksheetPart]
  shared_strings : @sml.CT_Sst?
  styles : @sml.CT_Stylesheet?
  theme : @opc.PackagePart?
} derive(Eq, Debug)

///|
pub fn open(bytes : Bytes) -> Workbook raise OpenError {
  try {
    let package = @opc.Package::open(bytes)
    let workbook_part = find_package_relationship_part(
      package,
      @opc_namespaces.relationship_type_office_document(),
      "xl/workbook.xml",
    )
    let workbook = @sml_reader.read_workbook(
      package.required_part(workbook_part, section="6.3.3", source_path="/").data,
    )
    {
      package,
      workbook_part,
      workbook,
      worksheets: read_worksheets(package, workbook_part),
      // ECMA-376 §18.4.8 specifies `<sst>` as the top-level element
      // name in xl/sharedStrings.xml; use `read_sst` not the
      // `read_shared_strings` legacy alias so Office-produced
      // fixtures (which use the canonical `<sst>` root) open cleanly.
      shared_strings: package.read_optional(
        "/xl/sharedStrings.xml", @sml_reader.read_sst,
      ),
      styles: package.read_optional(
        "/xl/styles.xml", @sml_reader.read_style_sheet,
      ),
      // §18.8.3 / OPC §11.3.10 — discover the theme part via
      // the workbook's relationship table; fall back to the
      // canonical path so packages without an explicit rel
      // (legacy producers) still render with a theme.
      theme: locate_theme_part(package, workbook_part),
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
pub fn Workbook::save(self : Workbook) -> Bytes {
  let package = self.package
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
  let mut saved = package
  for worksheet in self.worksheets {
    saved = saved.with_part(
      worksheet.name,
      @sml_builder.write_worksheet(worksheet.value),
    )
  }
  saved.save() catch {
    _ => @sml_builder.write_workbook(self.workbook)
  }
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
pub fn Workbook::to_svg(self : Workbook) -> String {
  let buf = StringBuilder::new()
  // §18.8.3 — parse the theme part once per workbook render so
  // each worksheet picks up the same colour scheme.  Failure to
  // parse silently falls back to no-theme rendering; the raw
  // bytes survive on `self.theme` for diagnostic purposes.
  let theme_root : @xml.Element? = match self.theme {
    None => None
    Some(part) =>
      match (try? @xml.parse(part.data)) {
        Ok(doc) => Some(doc.root)
        Err(_) => None
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
    self.package,
    self.workbook_part,
    self.workbook,
  )
  for sheet_index, worksheet in self.worksheets {
    let image_resolver = build_drawing_image_resolver(
      self.package,
      worksheet.drawing_part,
    )
    // §18.10 — discover any pivot tables tied to this worksheet via
    // the worksheet-part's relationships (`…/pivotTable` rels point
    // at `xl/pivotTables/pivotTableN.xml`). For each one, look up
    // its cache via `cache_lookup`, decode + materialize, then hand
    // the bundle to the renderer.
    let pivots = collect_worksheet_pivots(
      self.package,
      worksheet.name,
      cache_lookup,
    )
    // Each sheet's SVG ids are namespaced with the sheet index so
    // per-cell ids (clip paths, defs) stay unique once the sheets
    // are concatenated into a single document.
    let result = @sml_viewer.render_svg(
      worksheet.value,
      shared_strings=self.shared_strings,
      drawing=worksheet.drawing,
      image_resolver~,
      styles=self.styles,
      theme=theme_root,
      date1904~,
      id_prefix="s" + sheet_index.to_string() + "-",
      pivots~,
      tables=worksheet.tables,
    )
    buf.write_string(result.svg)
  }
  buf.to_string()
}

///|
/// Build an `image_resolver` closure that maps a worksheet drawing's
/// `r:embed` Ids to `data:<mime>;base64,<…>` URIs by walking the
/// drawing part's `_rels/<drawing>.xml.rels` for the resolved image
/// part. Returns a closure that always yields `None` when no drawing
/// part is associated (so the SML viewer falls back to its labelled
/// placeholder transparently).
fn build_drawing_image_resolver(
  package : @opc.Package,
  drawing_part_name : String?,
) -> (String) -> String? {
  match drawing_part_name {
    None => fn(_) { None }
    Some(part_name) =>
      match package.relationships(part_name) {
        None => fn(_) { None }
        Some(rels) => {
          let part = part_name
          let pkg = package
          let relationships = rels
          fn(rid : String) -> String? {
            for rel in relationships.relationships {
              if rel.id == rid &&
                rel.target_mode == @relationships.TargetMode::Internal &&
                rel.type_uri.has_suffix("/image") {
                let image_name = try? @opc_part_name.resolve_target(
                  part,
                  rel.target,
                )
                match image_name {
                  Ok(name) =>
                    match pkg.part(name) {
                      Some(image_part) =>
                        return Some(
                          "data:" +
                          drawing_mime_for_target(rel.target) +
                          ";base64," +
                          @base64.encode(image_part.data),
                        )
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
  package : @opc.Package,
  owner : String,
) -> Array[WorksheetPart] raise {
  let result : Array[WorksheetPart] = []
  match package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/worksheet") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match package.part(name) {
            Some(part) => {
              let worksheet = @sml_reader.read_worksheet(part.data)
              let (drawing, drawing_part) = match
                read_worksheet_drawing(package, name) {
                Some((wsdr, dn)) => (Some(wsdr), Some(dn))
                None => (None, None)
              }
              let tables = read_worksheet_tables(package, name)
              result.push({
                name,
                value: worksheet,
                drawing,
                drawing_part,
                tables,
              })
            }
            None => ()
          }
        }
      }
    None => ()
  }
  result
}

///|
/// Resolve the `<drawing r:id="...">` reference inside a worksheet to
/// the corresponding `xl/drawings/drawingN.xml` part. Returns the
/// pair `(typed WsDr, drawing part name)` so callers can index the
/// drawing part's own `_rels` for image-resolution. `None` when the
/// worksheet has no drawing reference or the rels can't be resolved.
fn read_worksheet_drawing(
  package : @opc.Package,
  worksheet_part_name : String,
) -> (@drawing.WsDr, String)? raise {
  match package.relationships(worksheet_part_name) {
    None => None
    Some(rels) => {
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/drawing") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let drawing_name = @opc_part_name.resolve_target(
            worksheet_part_name,
            rel.target,
          )
          match package.part(drawing_name) {
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
  package : @opc.Package,
  worksheet_part_name : String,
) -> Array[@xml.Element] {
  let tables : Array[@xml.Element] = []
  // Build a rId → table-part-name map from the worksheet's rels.
  let rid_to_part : Map[String, String] = Map::new()
  match package.relationships(worksheet_part_name) {
    None => return tables
    Some(rels) =>
      for rel in rels.relationships {
        if rel.type_uri.has_suffix("/table") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          match
            (try? @opc_part_name.resolve_target(worksheet_part_name, rel.target)) {
            Ok(name) => rid_to_part.set(rel.id, name)
            Err(_) => ()
          }
        }
      }
  }
  if rid_to_part.size() == 0 {
    return tables
  }
  // Walk `<worksheet>/<tableParts>/<tablePart r:id="…"/>` in source
  // order; for each rId, parse the referenced part's XML root.
  let worksheet_part = match package.part(worksheet_part_name) {
    Some(p) => p
    None => return tables
  }
  let worksheet_root = match (try? @xml.parse(worksheet_part.data)) {
    Ok(doc) => doc.root
    Err(_) => return tables
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
                          match package.part(part_name) {
                            Some(part) =>
                              match (try? @xml.parse(part.data)) {
                                Ok(doc) => tables.push(doc.root)
                                Err(_) => ()
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
/// §18.8.3 / OPC §11.3.10 — locate the workbook's theme part
/// via its relationship table.  Returns None when no theme rel
/// nor canonical `/xl/theme/theme1.xml` part is present.
fn locate_theme_part(
  package : @opc.Package,
  workbook_part : String,
) -> @opc.PackagePart? {
  // Look for a `/theme` relationship from the workbook.
  let theme_target : String? = match package.relationships(workbook_part) {
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
  package.part(primary)
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
  package : @opc.Package,
  workbook_part : String,
  workbook : @sml.CT_Workbook,
) -> Array[PivotCacheRef] {
  let result : Array[PivotCacheRef] = []
  let caches = match workbook.pivot_caches {
    Some(pc) => pc.pivot_cache
    None => return result
  }
  let wb_rels = match package.relationships(workbook_part) {
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
        match (try? @opc_part_name.resolve_target(workbook_part, rel.target)) {
          Ok(name) => def_part = Some(name)
          Err(_) => ()
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
    match package.relationships(definition_part) {
      None => ()
      Some(cdef_rels) =>
        for rel in cdef_rels.relationships {
          if rel.type_uri.has_suffix("/pivotCacheRecords") &&
            rel.target_mode == @relationships.TargetMode::Internal {
            match
              (try? @opc_part_name.resolve_target(definition_part, rel.target)) {
              Ok(name) => records_part = Some(name)
              Err(_) => ()
            }
          }
        }
    }
    result.push({ cache_id: pc.cache_id, definition_part, records_part })
  }
  result
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
  package : @opc.Package,
  worksheet_part : String,
  cache_lookup : Array[PivotCacheRef],
) -> Array[@sml_viewer.SheetPivot] {
  let result : Array[@sml_viewer.SheetPivot] = []
  let rels = match package.relationships(worksheet_part) {
    Some(r) => r
    None => return result
  }
  for rel in rels.relationships {
    if !rel.type_uri.has_suffix("/pivotTable") ||
      rel.target_mode != @relationships.TargetMode::Internal {
      continue
    }
    let pivot_part_name = match
      (try? @opc_part_name.resolve_target(worksheet_part, rel.target)) {
      Ok(name) => name
      Err(_) => continue
    }
    let pivot_part = match package.part(pivot_part_name) {
      Some(p) => p
      None => continue
    }
    // 1. Decode the pivot table definition.
    let pivot_dom = match
      (try? @sml_reader.read_pivot_table_definition(pivot_part.data)) {
      Ok(v) => v
      Err(_) => continue
    }
    let pivot_typed = match
      (try? @sml_pivot.decode_pivot_table_definition(pivot_dom)) {
      Ok(v) => v
      Err(_) => continue
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
    let cache_part = match package.part(cache_entry.definition_part) {
      Some(p) => p
      None => continue
    }
    let cache_dom = match
      (try? @sml_reader.read_pivot_cache_definition(cache_part.data)) {
      Ok(v) => v
      Err(_) => continue
    }
    let cache_typed = match
      (try? @sml_pivot.decode_pivot_cache_definition(cache_dom)) {
      Ok(v) => v
      Err(_) => continue
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
        match package.part(records_part_name) {
          None => { count: Some(0), rows: [] }
          Some(records_part) => {
            let records_dom = match
              (try? @sml_reader.read_pivot_cache_records(records_part.data)) {
              Ok(v) => v
              Err(_) => continue
            }
            match
              (try? @sml_pivot.decode_pivot_cache_records(
                records_dom,
                cache_typed.cache_fields,
              )) {
              Ok(v) => v
              Err(_) => continue
            }
          }
        }
    }
    // 4. Materialize.
    let materialization = match
      (try? @sml_pivot.materialize_pivot_table(
        pivot_typed, cache_typed, records_typed,
      )) {
      Ok(v) => v
      Err(_) => continue
    }
    result.push({ definition: pivot_typed, cache: cache_typed, materialization })
  }
  result
}

///|
