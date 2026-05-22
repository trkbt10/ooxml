///|
/// docx (.docx) wasm-gc bundle for the npm distribution.
///
/// This package exposes the `src/docx` facade through wasm-gc exports so the
/// npm-side core bundle can call:
///
/// - `docx_package_name()` to identify the underlying facade package.
/// - `docx_open(bytes)` to parse a `.docx` file.
/// - `docx_save(handle)` to serialize the parsed document back to OOXML bytes.
/// - `docx_to_html(handle)` to convert the document to HTML.
/// - `docx_to_svg(handle)` to convert drawing content to SVG.
///
/// The callable names are enabled by this package's `moon.pkg`
/// `link.wasm-gc.exports` list. npm consumers call these exports through the
/// JavaScript core wrapper rather than importing the MoonBit facade directly.
pub fn package_name() -> String {
  @wml_context.package_name()
}

///|
let docx_documents : Ref[Array[@wml_context.Document]] = { val: [] }

///|
/// Parse `.docx` OOXML bytes and store the resulting document in the wasm
/// handle table. Returns a positive document handle on success, or 0 on
/// failure.
pub fn docx_open(bytes : Bytes) -> Int {
  try {
    let document = @wml_context.open(bytes)
    docx_documents.val.push(document)
    docx_documents.val.length()
  } catch {
    _ => 0
  }
}

///|
/// Serialize a stored `.docx` document back to OOXML package bytes. Invalid
/// handles return an empty byte buffer.
pub fn docx_save(handle : Int) -> Bytes {
  match docx_document(handle) {
    Some(document) => document.save()
    None => Bytes::new(0)
  }
}

///|
/// Convert a stored `.docx` document to HTML for npm-side preview and export
/// flows. Invalid handles return an empty string.
pub fn docx_to_html(handle : Int) -> String {
  match docx_document(handle) {
    Some(document) => document.to_html()
    None => ""
  }
}

///|
/// Convert drawing content from a stored `.docx` document to SVG for
/// npm-side rendering. Invalid handles return an empty string.
pub fn docx_to_svg(handle : Int) -> String {
  match docx_document(handle) {
    Some(document) => document.to_svg()
    None => ""
  }
}

///|
fn docx_document(handle : Int) -> @wml_context.Document? {
  if handle <= 0 {
    None
  } else {
    docx_documents.val.get(handle - 1)
  }
}

///|
/// `main` is required because wasm-gc export bundles must be `is-main: true`.
/// It is never invoked by JS hosts.
fn main {
  ignore(package_name())
}
