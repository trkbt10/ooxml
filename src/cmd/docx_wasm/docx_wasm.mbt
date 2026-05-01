///|
/// WASM exports for the .docx facade.
pub fn package_name() -> String {
  @docx.package_name()
}

///|
let docx_documents : Ref[Array[@docx.Document]] = { val: [] }

///|
/// Wasm export: parse a .docx file from raw bytes.
/// Returns a positive document handle on success, or 0 on failure.
pub fn docx_open(bytes : Bytes) -> Int {
  try {
    let document = @docx.open(bytes)
    docx_documents.val.push(document)
    docx_documents.val.length()
  } catch {
    _ => 0
  }
}

///|
pub fn docx_save(handle : Int) -> Bytes {
  match docx_document(handle) {
    Some(document) => document.save()
    None => Bytes::new(0)
  }
}

///|
pub fn docx_to_html(handle : Int) -> String {
  match docx_document(handle) {
    Some(document) => document.to_html()
    None => ""
  }
}

///|
pub fn docx_to_svg(handle : Int) -> String {
  match docx_document(handle) {
    Some(document) => document.to_svg()
    None => ""
  }
}

///|
fn docx_document(handle : Int) -> @docx.Document? {
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
