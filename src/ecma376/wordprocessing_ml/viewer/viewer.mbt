///|
/// WordprocessingML §17 viewer for the reader -> context -> viewer pipeline.
///
/// render_html walks a CT_Document domain tree and emits representative HTML
/// for document, body, paragraph, run, text, and table content. It is a
/// structural renderer for inspection and tests, not a layout-equivalent Word
/// renderer.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/wordprocessing_ml/viewer"
}

///|
/// Render a WordprocessingML CT_Document tree as minimal HTML.
pub fn render_html(domain : @domain.CT_Document) -> String {
  "<article data-ooxml=\"wml\">" +
  render_children(domain.element) +
  "</article>"
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
    "p" => "<p>" + render_children(element) + "</p>"
    "r" => render_children(element)
    "t" => escape_html(text_content(element))
    "tbl" => "<table>" + render_children(element) + "</table>"
    "tr" => "<tr>" + render_children(element) + "</tr>"
    "tc" => "<td>" + render_children(element) + "</td>"
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
