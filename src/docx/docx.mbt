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
    let main = @wml_reader.read_document(required_part(package, main_part).data)
    {
      package,
      main_part,
      main,
      headers: read_header_parts(package, main_part),
      footers: read_footer_parts(package, main_part),
      styles: read_optional(
        package, "/word/styles.xml", @wml_reader.read_styles,
      ),
      numbering: read_optional(
        package, "/word/numbering.xml", @wml_reader.read_numbering,
      ),
      settings: read_optional(
        package, "/word/settings.xml", @wml_reader.read_settings,
      ),
      fonts: read_optional(
        package, "/word/fontTable.xml", @wml_reader.read_fonts,
      ),
      comments: read_optional(
        package, "/word/comments.xml", @wml_reader.read_comments,
      ),
      footnotes: read_optional(
        package, "/word/footnotes.xml", @wml_reader.read_footnotes,
      ),
      endnotes: read_optional(
        package, "/word/endnotes.xml", @wml_reader.read_endnotes,
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
fn[T] read_optional(
  package : @opc.Package,
  name : String,
  reader : (Bytes) -> T raise,
) -> T? raise {
  match package.part(name) {
    Some(part) => Some(reader(part.data))
    None => None
  }
}

///|
fn required_part(
  package : @opc.Package,
  name : String,
) -> @opc.PackagePart raise OpenError {
  match package.part(name) {
    Some(part) => part
    None => raise OpenError(kind="ResourceMissing", path=name, reason=name)
  }
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
fn[T] @opc.Package::with_optional_part(
  self : @opc.Package,
  name : String,
  value : T?,
  writer : (T) -> Bytes,
) -> @opc.Package {
  match value {
    Some(v) => self.with_part(name, writer(v))
    None => self
  }
}

///|
fn @opc.Package::with_part(
  self : @opc.Package,
  name : String,
  data : Bytes,
) -> @opc.Package {
  let parts : Array[@opc.PackagePart] = []
  for part in self.parts {
    if part.name == name {
      parts.push({ name: part.name, content_type: part.content_type, data })
    } else {
      parts.push(part)
    }
  }
  { ..self, parts, }
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
