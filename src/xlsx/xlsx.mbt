///|
/// Public facade for .xlsx files. Orchestrates OPC and SpreadsheetML.
pub fn package_name() -> String {
  "trkbt10/ooxml/xlsx"
}

///|
pub suberror OpenError {
  OpenError(kind~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
pub(all) struct WorksheetPart {
  name : String
  value : @sml.CT_Worksheet
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
      shared_strings: package.read_optional(
        "/xl/sharedStrings.xml", @sml_reader.read_shared_strings,
      ),
      styles: package.read_optional(
        "/xl/styles.xml", @sml_reader.read_style_sheet,
      ),
      theme: package.part("/xl/theme/theme1.xml"),
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
pub fn Workbook::to_svg(self : Workbook) -> String {
  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"200\"><text x=\"16\" y=\"32\">xlsx:" +
  @xml.escape_text(self.workbook.element.name.local_name) +
  "</text></svg>"
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
            Some(part) =>
              result.push({ name, value: @sml_reader.read_worksheet(part.data) })
            None => ()
          }
        }
      }
    None => ()
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
