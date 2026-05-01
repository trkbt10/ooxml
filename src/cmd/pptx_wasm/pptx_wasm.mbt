///|
/// pptx (.pptx) wasm-gc bundle for the npm distribution.
///
/// This package exposes the `src/pptx` facade through wasm-gc exports so the
/// npm-side core bundle can call:
///
/// - `pptx_package_name()` to identify the underlying facade package.
/// - `pptx_open(bytes)` to parse a `.pptx` presentation.
/// - `pptx_save(handle)` to serialize the parsed presentation back to OOXML
///   bytes.
/// - `pptx_to_html(handle)` to convert the presentation to HTML.
/// - `pptx_to_svg(handle)` to convert slides and drawing content to SVG.
///
/// The callable names are enabled by this package's `moon.pkg`
/// `link.wasm-gc.exports` list. npm consumers call these exports through the
/// JavaScript core wrapper rather than importing the MoonBit facade directly.
pub fn package_name() -> String {
  @pptx.package_name()
}

///|
let pptx_presentations : Ref[Array[@pptx.Presentation]] = { val: [] }

///|
/// Parse `.pptx` OOXML bytes and store the resulting presentation in the wasm
/// handle table. Returns a positive presentation handle on success, or 0 on
/// failure.
pub fn pptx_open(bytes : Bytes) -> Int {
  try {
    let presentation = @pptx.open(bytes)
    pptx_presentations.val.push(presentation)
    pptx_presentations.val.length()
  } catch {
    _ => 0
  }
}

///|
/// Serialize a stored `.pptx` presentation back to OOXML package bytes.
/// Invalid handles return an empty byte buffer.
pub fn pptx_save(handle : Int) -> Bytes {
  match pptx_presentation(handle) {
    Some(presentation) => presentation.save()
    None => Bytes::new(0)
  }
}

///|
/// Convert a stored `.pptx` presentation to HTML for npm-side preview and
/// export flows. Invalid handles return an empty string.
pub fn pptx_to_html(handle : Int) -> String {
  match pptx_presentation(handle) {
    Some(presentation) => presentation.to_html()
    None => ""
  }
}

///|
/// Convert slides and drawing content from a stored `.pptx` presentation to
/// SVG for npm-side rendering. Invalid handles return an empty string.
pub fn pptx_to_svg(handle : Int) -> String {
  match pptx_presentation(handle) {
    Some(presentation) => presentation.to_svg()
    None => ""
  }
}

///|
fn pptx_presentation(handle : Int) -> @pptx.Presentation? {
  if handle <= 0 {
    None
  } else {
    pptx_presentations.val.get(handle - 1)
  }
}

///|
fn main {
  ignore(package_name())
}
