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
pub fn Workbook::to_html(self : Workbook) -> String {
  let mut out = "<table data-ooxml=\"xlsx\"><tbody><tr><td>"
  out = out + html_element(self.workbook.element)
  for worksheet in self.worksheets {
    out = out + html_element(worksheet.value.element)
  }
  out + "</td></tr></tbody></table>"
}

///|
/// Convert the workbook into a §18 styled HTML representation. Each
/// worksheet's CT_Worksheet tree is rendered with shared-string
/// resolution applied (looking up `@t="s"` cell values in the
/// workbook-level §18.4 CT_Sst when present). The output wraps each
/// worksheet's rendered table in a `<section class="sheet">`.
pub fn Workbook::to_styled_html(self : Workbook) -> String {
  let mut out = "<article data-ooxml=\"xlsx\" data-style=\"resolved\">"
  let mut i = 0
  for worksheet in self.worksheets {
    i = i + 1
    out = out +
      "<section class=\"sheet\" data-sheet-index=\"" +
      i.to_string() +
      "\">"
    out = out +
      (match self.shared_strings {
        Some(sst) =>
          @sml_viewer.render_html_with_shared_strings(worksheet.value, sst)
        None => @sml_viewer.render_html(worksheet.value)
      })
    out = out + "</section>"
  }
  out + "</article>"
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
  for worksheet in self.worksheets {
    let image_resolver = build_drawing_image_resolver(
      self.package, worksheet.drawing_part,
    )
    let result = @sml_viewer.render_svg(
      worksheet.value,
      shared_strings=self.shared_strings,
      drawing=worksheet.drawing,
      image_resolver~,
      styles=self.styles,
      theme=theme_root,
      date1904~,
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
                let image_name = (try? @opc_part_name.resolve_target(
                  part, rel.target,
                ))
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
              result.push({ name, value: worksheet, drawing, drawing_part })
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
            workbook_part, rel.target,
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
