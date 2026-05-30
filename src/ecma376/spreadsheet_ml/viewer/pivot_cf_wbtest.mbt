// §18.3.1.18 — worksheet conditional formatting applied to pivot value
// cells (Excel stores pivot CF as a sheet `<conditionalFormatting>`
// block over the pivot region; `pivot_value_cf_style` reuses the shared
// `apply_cf_overlay` evaluator).

///|
test "pivot_value_cf_style is a no-op without conditional formatting" {
  let (fill, text) = pivot_value_cf_style(
    2,
    1,
    @formula.VNumber(5.0),
    default_render_options(),
    [],
    [],
    None,
    None,
    SmlThemeColorMap::empty(),
  )
  assert_true(fill is None)
  assert_eq(text, "#000000")
}

///|
test "pivot_value_cf_style skips non-numeric values" {
  // A text aggregate cannot drive a value-based CF rule.
  let (fill, _text) = pivot_value_cf_style(
    0,
    0,
    @formula.VString("abc"),
    default_render_options(),
    [],
    [],
    None,
    None,
    SmlThemeColorMap::empty(),
  )
  assert_true(fill is None)
}
