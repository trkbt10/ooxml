///|
/// WASM exports for the .xlsx facade.
pub fn package_name() -> String {
  @xlsx.package_name()
}

///|
let xlsx_workbooks : Ref[Array[@xlsx.Workbook]] = { val: [] }

///|
pub fn xlsx_open(bytes : Bytes) -> Int {
  try {
    let workbook = @xlsx.open(bytes)
    xlsx_workbooks.val.push(workbook)
    xlsx_workbooks.val.length()
  } catch {
    _ => 0
  }
}

///|
pub fn xlsx_save(handle : Int) -> Bytes {
  match xlsx_workbook(handle) {
    Some(workbook) => workbook.save()
    None => Bytes::new(0)
  }
}

///|
pub fn xlsx_to_html(handle : Int) -> String {
  match xlsx_workbook(handle) {
    Some(workbook) => workbook.to_html()
    None => ""
  }
}

///|
pub fn xlsx_to_svg(handle : Int) -> String {
  match xlsx_workbook(handle) {
    Some(workbook) => workbook.to_svg()
    None => ""
  }
}

///|
fn xlsx_workbook(handle : Int) -> @xlsx.Workbook? {
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
