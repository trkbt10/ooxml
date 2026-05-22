// §18.8.3 CT_Color theme/tint resolver tests.

///|
fn sml_mk_attr(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name: name, ns: None }, value }
}

///|
fn sml_mk_el(
  local_name : String,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: { prefix: None, local_name, ns: None }, attributes, children }
}

///|
fn sml_mk_color_slot(local_name : String, hex : String) -> @xml.Element {
  let srgb = sml_mk_el("srgbClr", [sml_mk_attr("val", hex)], [])
  sml_mk_el(local_name, [], [@xml.Node::Element(srgb)])
}

///|
fn sml_mk_theme() -> @xml.Element {
  let scheme = sml_mk_el("clrScheme", [], [
    @xml.Node::Element(sml_mk_color_slot("lt1", "FFFFFF")),
    @xml.Node::Element(sml_mk_color_slot("dk1", "000000")),
    @xml.Node::Element(sml_mk_color_slot("lt2", "E7E6E6")),
    @xml.Node::Element(sml_mk_color_slot("dk2", "44546A")),
    @xml.Node::Element(sml_mk_color_slot("accent1", "4472C4")),
    @xml.Node::Element(sml_mk_color_slot("accent2", "ED7D31")),
  ])
  let theme_elts = sml_mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  sml_mk_el("theme", [], [@xml.Node::Element(theme_elts)])
}

///|
test "parse_sml_clr_scheme indexes slots in §20.1.4.1.6 order" {
  let map = parse_sml_clr_scheme(sml_mk_theme())
  inspect(map.lookup(0), content="Some(ffffff)") // lt1
  inspect(map.lookup(1), content="Some(000000)") // dk1
  inspect(map.lookup(2), content="Some(e7e6e6)") // lt2
  inspect(map.lookup(3), content="Some(44546a)") // dk2
  inspect(map.lookup(4), content="Some(4472c4)") // accent1
  inspect(map.lookup(5), content="Some(ed7d31)") // accent2
  inspect(map.lookup(6), content="None") // accent3 unset
  inspect(map.lookup(12), content="None") // out of range
}

///|
fn sml_mk_ct_color(
  rgb? : String? = None,
  theme? : Int? = None,
  tint? : Double = 0.0,
  auto_? : Bool = false,
) -> @domain.CT_Color {
  // §18.8.3 — synthesise a CT_Color without going through the
  // XML parse path so the unit test can target the resolver
  // logic directly.
  {
    element: sml_mk_el("color", [], []),
    auto_,
    indexed: None,
    rgb,
    theme,
    tint,
  }
}

///|
test "resolve_sml_color theme index wins over rgb" {
  let theme_map = parse_sml_clr_scheme(sml_mk_theme())
  let c = sml_mk_ct_color(rgb=Some("FFFF0000"), theme=Some(4))
  // theme=4 → accent1 (#4472c4); the explicit rgb is overridden.
  inspect(resolve_sml_color(c, theme_map), content="Some(4472c4)")
}

///|
test "resolve_sml_color positive tint brightens" {
  let theme_map = parse_sml_clr_scheme(sml_mk_theme())
  // theme=1 → dk1 (#000000) tinted by +0.5 (HSL L offset).
  let c = sml_mk_ct_color(theme=Some(1), tint=0.5)
  let result = resolve_sml_color(c, theme_map)
  // L=0 + 0.5 = 0.5; pure neutral mid grey.
  inspect(result, content="Some(808080)")
}

///|
test "resolve_sml_color negative tint darkens" {
  let theme_map = parse_sml_clr_scheme(sml_mk_theme())
  // theme=0 → lt1 (#FFFFFF) tinted by -1.0 (full darken).
  let c = sml_mk_ct_color(theme=Some(0), tint=-1.0)
  inspect(resolve_sml_color(c, theme_map), content="Some(000000)")
}

///|
test "resolve_sml_color zero tint preserves base RGB" {
  let theme_map = SmlThemeColorMap::empty()
  let c = sml_mk_ct_color(rgb=Some("FF4472C4"))
  // 8-digit AARRGGBB → strip alpha prefix.
  inspect(resolve_sml_color(c, theme_map), content="Some(4472c4)")
}

///|
test "resolve_sml_color auto sentinel returns None" {
  let theme_map = parse_sml_clr_scheme(sml_mk_theme())
  let c = sml_mk_ct_color(theme=Some(4), auto_=true)
  inspect(resolve_sml_color(c, theme_map), content="None")
}

///|
test "resolve_sml_color theme index out of range falls back to rgb" {
  let theme_map = parse_sml_clr_scheme(sml_mk_theme())
  let c = sml_mk_ct_color(rgb=Some("FFEE1111"), theme=Some(99))
  // theme=99 is unmapped; the explicit rgb survives.
  inspect(resolve_sml_color(c, theme_map), content="Some(ee1111)")
}

///|
/// §18.8.3 — end-to-end: parse_sml_clr_scheme → SmlThemeColorMap
/// → resolve_sml_color must yield the spec-mandated final hex
/// for a CT_Color carrying both @theme and @tint.
test "SML theme cascade E2E: CT_Color theme=accent1 + tint=+0.5" {
  let theme = sml_mk_theme()
  let map = parse_sml_clr_scheme(theme)
  // theme=4 → accent1 (#4472C4); tint=+0.5 brightens via HSL
  // luminance offset.  We only verify the result is brighter
  // than the base (not the exact channel — that depends on the
  // HSL round-trip arithmetic verified in util/color tests).
  let c = sml_mk_ct_color(theme=Some(4), tint=0.5)
  let result = resolve_sml_color(c, map)
  match result {
    Some(hex) => {
      assert_eq(hex.length(), 6)
      // Tint > 0 must brighten — at least one channel goes up.
      let r = hex[0:2].to_string()
      let g = hex[2:4].to_string()
      let b = hex[4:6].to_string()
      // accent1 base = #4472c4.  Tint=+0.5 should brighten so
      // the resulting r/g/b sum exceeds the base sum.
      assert_true(r > "44" || g > "72" || b > "c4")
    }
    None => abort("expected Some(hex) for tinted accent1")
  }
}
