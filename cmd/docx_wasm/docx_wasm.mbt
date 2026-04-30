///|
/// WASM exports for the .docx facade.
///
/// Each `pub fn` here is a thin wrapper that adapts the MoonBit-side
/// facade API to a wasm-gc-friendly signature (primitives or opaque
/// handles). Implementation pending.
pub fn package_name() -> String {
  @docx.package_name()
}
