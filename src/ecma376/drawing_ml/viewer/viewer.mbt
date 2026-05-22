///|
/// DrawingML §20/§21 standalone viewer for the reader -> context -> viewer
/// pipeline.
///
/// render_svg walks a DrawingML element tree and emits a small SVG inspection
/// view for shape/text content. render_html wraps that SVG for consumers that
/// expect an HTML renderer entry point.
///
/// The output is built as a structured `@xml.Element` tree and
/// serialised once via the shared `@markup` package, so no markup
/// is assembled by string concatenation.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/viewer"
}

///|
/// Build the `<svg>` inspection-view element for a DrawingML tree.
fn build_svg_element(domain : @xml.Element) -> @xml.Element {
  let text_node : @xml.Node = @markup.elem_ns(
    "text",
    @markup.svg_ns,
    [@markup.attr("x", "16"), @markup.attr("y", "32")],
    [@markup.text(text_content(domain))],
  )
  {
    name: @markup.qname_ns("svg", @markup.svg_ns),
    attributes: [
      @markup.attr("data-ooxml", "dml"),
      @markup.attr("viewBox", "0 0 640 360"),
    ],
    children: [text_node],
  }
}

///|
/// Render a DrawingML element tree as a minimal SVG inspection view.
pub fn render_svg(domain : @xml.Element) -> String {
  @markup.serialize_svg(build_svg_element(domain))
}

///|
/// Render a DrawingML element tree as minimal HTML containing SVG.
pub fn render_html(domain : @xml.Element) -> String {
  let div : @xml.Element = {
    name: @markup.qname("div"),
    attributes: [@markup.attr("data-ooxml", "dml")],
    children: [@xml.Node::Element(build_svg_element(domain))],
  }
  @markup.serialize(div)
}

///|
fn text_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      Element(child_el) => out.write_string(text_content(child_el))
      _ => ()
    }
  }
  out.to_string()
}
