///|
/// DrawingML §20/§21 standalone viewer for the reader -> context -> viewer
/// pipeline.
///
/// render_svg walks a DrawingML element tree and emits a small SVG inspection
/// view for shape/text content. render_html wraps that SVG for consumers that
/// expect an HTML renderer entry point.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/viewer"
}

///|
/// Render a DrawingML element tree as a minimal SVG inspection view.
pub fn render_svg(domain : @xml.Element) -> String {
  "<svg xmlns=\"http://www.w3.org/2000/svg\" data-ooxml=\"dml\" viewBox=\"0 0 640 360\"><text x=\"16\" y=\"32\">" +
  escape_html(text_content(domain)) +
  "</text></svg>"
}

///|
/// Render a DrawingML element tree as minimal HTML containing SVG.
pub fn render_html(domain : @xml.Element) -> String {
  "<div data-ooxml=\"dml\">" + render_svg(domain) + "</div>"
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
