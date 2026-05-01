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
      package, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
      "xl/workbook.xml",
    )
    let workbook = @sml_reader.read_workbook(
      required_part(package, workbook_part).data,
    )
    {
      package,
      workbook_part,
      workbook,
      worksheets: read_worksheets(package, workbook_part),
      shared_strings: read_optional(
        package, "/xl/sharedStrings.xml", @sml_reader.read_shared_strings,
      ),
      styles: read_optional(
        package, "/xl/styles.xml", @sml_reader.read_style_sheet,
      ),
      theme: package.part("/xl/theme/theme1.xml"),
    }
  } catch {
    @opc.ResourceMissing(section~, path~, target~) =>
      raise OpenError(
        kind="ResourceMissing",
        path~,
        reason=section + ": " + target,
      )
    @opc.SchemaViolation(section~, path~, reason~) =>
      raise OpenError(
        kind="SchemaViolation",
        path~,
        reason=section + ": " + reason,
      )
    @opc.UnsupportedFeature(section~, path~, reason~) =>
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
  escape_text(self.workbook.element.name.local_name) +
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
          let name = resolve_target(owner, rel.target)
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
          return resolve_target("/", rel.target)
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
  let name = escape_text(element.name.local_name)
  let mut out = "<section data-ooxml-element=\"" + name + "\">"
  for child in element.children {
    match child {
      @xml.Element(element) => out = out + html_element(element)
      @xml.Text(text) => out = out + escape_text(text)
      @xml.CData(text) => out = out + escape_text(text)
      @xml.Comment(_) => ()
      @xml.ProcessingInstruction(_) => ()
    }
  }
  out + "</section>"
}

///|
fn escape_text(value : String) -> String {
  value
  .replace(old="&", new="&amp;")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
}

///|
fn resolve_target(owner : String, target : String) -> String {
  if target.has_prefix("/") {
    normalize_part_name(target)
  } else if owner == "/" || owner == "" {
    normalize_part_name("/" + target)
  } else {
    let base = owner[0:last_slash(owner)].to_owned()
    normalize_part_name(base + "/" + target)
  }
}

///|
fn normalize_part_name(value : String) -> String {
  let pieces = value.split("/")
  let out : Array[String] = []
  for piece in pieces {
    if piece == "" || piece == "." {
      ()
    } else if piece == ".." {
      out.pop() |> ignore
    } else {
      out.push(piece.to_owned())
    }
  }
  "/" + out.join("/")
}

///|
fn last_slash(value : String) -> Int {
  let chars = value.to_array()
  let mut result = -1
  for i in 0..<chars.length() {
    if chars[i] == '/' {
      result = i
    }
  }
  result
}
