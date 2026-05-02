///|
/// Public facade for .pptx files. Orchestrates OPC and PresentationML.
pub fn package_name() -> String {
  "trkbt10/ooxml/pptx"
}

///|
pub suberror OpenError {
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
      package, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
      "ppt/presentation.xml",
    )
    let presentation = @pml_reader.read_presentation(
      required_part(package, presentation_part).data,
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
    _ =>
      raise OpenError(
        kind="UnsupportedFeature",
        path="open",
        reason="unsupported package error",
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
pub fn Presentation::to_svg(self : Presentation) -> String {
  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"800\" height=\"450\"><text x=\"16\" y=\"32\">pptx:" +
  escape_text(self.presentation.element.name.local_name) +
  "</text></svg>"
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
          let name = resolve_target(owner, rel.target)
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
          let name = resolve_target(owner, rel.target)
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
