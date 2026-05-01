///|
/// PresentationML §19 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Slide domain tree and emits representative HTML for
/// slide common data, shape trees, paragraphs, and text runs. It preserves
/// readable content without attempting PowerPoint layout fidelity.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/viewer"
}

///|
/// Render a PresentationML CT_Slide tree as minimal HTML.
pub fn render_html(domain : @domain.CT_Slide) -> String {
  "<section data-ooxml=\"pml\">" +
  render_children(domain.element) +
  "</section>"
}

///|
fn render_children(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Element(element) => out.write_string(render_element(element))
      Text(text) | CData(text) => out.write_string(escape_html(text))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn render_element(element : @xml.Element) -> String {
  match element.name.local_name {
    "sp" | "grpSp" =>
      "<div class=\"shape\">" + render_children(element) + "</div>"
    "p" => "<p>" + render_children(element) + "</p>"
    "r" => render_children(element)
    "t" => escape_html(text_content(element))
    _ => render_children(element)
  }
}

///|
fn text_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      Element(element) => out.write_string(text_content(element))
      _ => ()
    }
  }
  out.to_string()
}

///|
fn escape_html(value : String) -> String {
  value
  .replace(old="&", new="&amp;")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
}
