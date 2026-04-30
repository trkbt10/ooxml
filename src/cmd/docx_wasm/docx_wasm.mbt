///|
/// WASM exports for the .docx facade.
///
/// Each `pub fn` here is a thin wrapper that adapts the MoonBit-side
/// facade API to a wasm-gc-friendly signature (primitives or opaque
/// handles). Implementation pending.
pub fn package_name() -> String {
  @docx.package_name()
}

///|
/// `main` is required because wasm-gc export bundles must be `is-main: true`.
/// It is never invoked by JS hosts.
fn main {
  ignore(package_name())
}
