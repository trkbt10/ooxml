// §18.8.3 — a sparkline `<x14:colorSeries theme="N" tint="F"/>` colour
// is resolved against the workbook theme slots (with HSL-luminance
// tint) by the viewer before the sparkline renderer runs, so theme
// colours paint correctly instead of falling back to the default.

///|
test "resolve_sparkline_color fills hex from a theme index" {
  let theme_map : SmlThemeColorMap = { slots: [Some("ff0000"), Some("00ff00")] }
  let c : @sparkline.SparklineColor = { hex: None, theme: Some(1), tint: None }
  let r = resolve_sparkline_color(c, theme_map)
  // Slot 1 is green, no tint → exact theme hex (no leading '#').
  assert_eq(r.hex, Some("00ff00"))
}

///|
test "resolve_sparkline_color keeps an explicit rgb unchanged" {
  let theme_map : SmlThemeColorMap = { slots: [Some("ff0000")] }
  let c : @sparkline.SparklineColor = {
    hex: Some("123456"),
    theme: Some(0),
    tint: None,
  }
  assert_eq(resolve_sparkline_color(c, theme_map).hex, Some("123456"))
}

///|
test "resolve_sparkline_color applies tint and strips the hash" {
  let theme_map : SmlThemeColorMap = { slots: [Some("808080")] }
  let c : @sparkline.SparklineColor = { hex: None, theme: Some(0), tint: Some(0.5) }
  let r = resolve_sparkline_color(c, theme_map)
  // Tint resolves to a concrete 6-digit hex with no leading '#'.
  guard r.hex is Some(h) else { fail("expected a resolved hex") }
  assert_eq(h.length(), 6)
  assert_true(!h.contains("#"))
}

///|
test "resolve_sparkline_color falls back when theme index is absent" {
  let theme_map = SmlThemeColorMap::empty()
  let c : @sparkline.SparklineColor = { hex: None, theme: Some(3), tint: None }
  // Unresolvable index → unchanged (renderer then uses its default).
  assert_eq(resolve_sparkline_color(c, theme_map).hex, None)
}
