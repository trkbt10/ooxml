///|
/// WASM exports for the .xlsx facade.
pub fn package_name() -> String {
  @xlsx.package_name()
}

///|
fn main {
  ignore(package_name())
}
