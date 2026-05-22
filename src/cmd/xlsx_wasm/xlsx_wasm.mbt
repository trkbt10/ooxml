///|
/// xlsx (.xlsx) wasm-gc bundle for the npm distribution.
///
/// This package exposes the `src/xlsx` facade through wasm-gc exports so the
/// npm-side core bundle can call:
///
/// - `xlsx_package_name()` to identify the underlying facade package.
/// - `xlsx_open(bytes)` to parse a `.xlsx` workbook.
/// - `xlsx_save(handle)` to serialize the parsed workbook back to OOXML bytes.
/// - `xlsx_to_svg(handle)` to render the workbook to SVG.
///
/// The callable names are enabled by this package's `moon.pkg`
/// `link.wasm-gc.exports` list. npm consumers call these exports through the
/// JavaScript core wrapper rather than importing the MoonBit facade directly.
pub fn package_name() -> String {
  @sml_context.package_name()
}

///|
let xlsx_workbooks : Ref[Array[@sml_context.Workbook]] = { val: [] }

///|
/// Parse `.xlsx` OOXML bytes and store the resulting workbook in the wasm
/// handle table. Returns a positive workbook handle on success, or 0 on
/// failure.
pub fn xlsx_open(bytes : Bytes) -> Int {
  try {
    let workbook = @sml_context.open(bytes)
    xlsx_workbooks.val.push(workbook)
    xlsx_workbooks.val.length()
  } catch {
    _ => 0
  }
}

///|
/// Serialize a stored `.xlsx` workbook back to OOXML package bytes. Invalid
/// handles return an empty byte buffer.
pub fn xlsx_save(handle : Int) -> Bytes {
  match xlsx_workbook(handle) {
    Some(workbook) => workbook.save()
    None => Bytes::new(0)
  }
}

///|
/// Render a stored `.xlsx` workbook to SVG for npm-side preview and
/// export flows. Invalid handles return an empty string.
pub fn xlsx_to_svg(handle : Int) -> String {
  match xlsx_workbook(handle) {
    Some(workbook) => workbook.to_svg()
    None => ""
  }
}

///|
fn xlsx_workbook(handle : Int) -> @sml_context.Workbook? {
  if handle <= 0 {
    None
  } else {
    xlsx_workbooks.val.get(handle - 1)
  }
}

///|
fn main {
  ignore(package_name())
}
