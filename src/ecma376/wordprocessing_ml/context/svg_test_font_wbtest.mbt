///|
/// Context tests exercise `Document::to_svg`, which delegates text
/// layout to the WML viewer. Inject the deterministic TTF used by the
/// viewer tests so glyph widths and vertical metrics come from the
/// shared `@glyph` SoT rather than from host-specific font discovery.
let wml_context_test_font_ready : Ref[Bool] = { val: false }

///|
fn ensure_wml_context_test_font() -> Unit {
  if wml_context_test_font_ready.val {
    return
  }
  wml_context_test_font_ready.val = true
  let bytes = try
    @fs.read_file_to_bytes("src/util/glyph/fixtures/subset.ttf")
  catch {
    _ => abort("cannot load test font src/util/glyph/fixtures/subset.ttf")
  } noraise {
    b => b
  }
  @glyph.set_default_font_set(
    @glyph.FontSet::new(
      resolver=@glyph.FontResolver::in_memory(
        Map([("Noto Sans", bytes)], capacity=1),
      ),
    ),
  )
}

///|
fn Document::to_svg_for_test(
  self : Document,
  debug_attrs? : Bool = false,
) -> String {
  ensure_wml_context_test_font()
  self.to_svg(debug_attrs~)
}
