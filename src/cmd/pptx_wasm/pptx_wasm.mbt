///|
/// WASM exports for the .pptx facade.
pub fn package_name() -> String {
  @pptx.package_name()
}

///|
fn main {
  ignore(package_name())
}
