///|
/// Public facade for .docx files. Orchestrates OPC and WordprocessingML.
pub fn package_name() -> String {
  "trkbt10/ooxml/docx"
}

///|
pub suberror OpenError {
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
  package : @opc.Package
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
} derive(Eq, Debug)

///|
/// Open a .docx file from raw bytes.
pub fn open(bytes : Bytes) -> Document raise OpenError {
  try {
    let package = @opc.Package::open(bytes)
    let main_part = find_package_relationship_part(
      package,
      @opc_namespaces.relationship_type_office_document(),
      "word/document.xml",
    )
    let main = @wml_reader.read_document(
      package.required_part(main_part, section="6.3.3", source_path="/").data,
    )
    {
      package,
      main_part,
      main,
      headers: read_header_parts(package, main_part),
      footers: read_footer_parts(package, main_part),
      styles: package.read_optional("/word/styles.xml", @wml_reader.read_styles),
      numbering: package.read_optional(
        "/word/numbering.xml", @wml_reader.read_numbering,
      ),
      settings: package.read_optional(
        "/word/settings.xml", @wml_reader.read_settings,
      ),
      fonts: package.read_optional(
        "/word/fontTable.xml", @wml_reader.read_fonts,
      ),
      comments: package.read_optional(
        "/word/comments.xml", @wml_reader.read_comments,
      ),
      footnotes: package.read_optional(
        "/word/footnotes.xml", @wml_reader.read_footnotes,
      ),
      endnotes: package.read_optional(
        "/word/endnotes.xml", @wml_reader.read_endnotes,
      ),
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
  let package = self.package
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
  let mut saved = package
  for header in self.headers {
    saved = saved.with_part(header.name, @wml_builder.write_hdr(header.value))
  }
  for footer in self.footers {
    saved = saved.with_part(footer.name, @wml_builder.write_ftr(footer.value))
  }
  saved.save() catch {
    _ => @wml_builder.write_document(self.main)
  }
}

///|
/// Convert the docx into a minimal HTML representation.
pub fn Document::to_html(self : Document) -> String {
  "<article data-ooxml=\"docx\">" +
  html_element(self.main.element) +
  "</article>"
}

///|
/// Convert the docx into a minimal SVG representation.
pub fn Document::to_svg(self : Document) -> String {
  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"200\"><text x=\"16\" y=\"32\">docx:" +
  @xml.escape_text(self.main.element.name.local_name) +
  "</text></svg>"
}

///|
fn read_header_parts(
  package : @opc.Package,
  owner : String,
) -> Array[HeaderPart] raise {
  let result : Array[HeaderPart] = []
  match package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/header") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match package.part(name) {
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
  package : @opc.Package,
  owner : String,
) -> Array[FooterPart] raise {
  let result : Array[FooterPart] = []
  match package.relationships(owner) {
    Some(relationships) =>
      for rel in relationships.relationships {
        if rel.type_uri.has_suffix("/footer") &&
          rel.target_mode == @relationships.TargetMode::Internal {
          let name = @opc_part_name.resolve_target(owner, rel.target)
          match package.part(name) {
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
