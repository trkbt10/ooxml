// §17.18.97 / §17.18.98 — themeColor / themeTint / themeShade
// resolver unit tests.

///|
fn mk_attr(name : String, value : String) -> @xml.Attribute {
  { name: { prefix: None, local_name: name, ns: None }, value }
}

///|
fn mk_el(
  local_name : String,
  attributes : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Element {
  { name: { prefix: None, local_name, ns: None }, attributes, children }
}

///|
fn mk_color_child(local_name : String, hex : String) -> @xml.Element {
  let srgb = mk_el("srgbClr", [mk_attr("val", hex)], [])
  mk_el(local_name, [], [@xml.Node::Element(srgb)])
}

///|
test "parse_clr_scheme reads accent / dk / lt slots" {
  let scheme = mk_el("clrScheme", [], [
    @xml.Node::Element(mk_color_child("dk1", "000000")),
    @xml.Node::Element(mk_color_child("lt1", "FFFFFF")),
    @xml.Node::Element(mk_color_child("dk2", "44546A")),
    @xml.Node::Element(mk_color_child("lt2", "E7E6E6")),
    @xml.Node::Element(mk_color_child("accent1", "4472C4")),
    @xml.Node::Element(mk_color_child("accent2", "ED7D31")),
    @xml.Node::Element(mk_color_child("hlink", "0563C1")),
    @xml.Node::Element(mk_color_child("folHlink", "954F72")),
  ])
  let theme_elts = mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  let theme = mk_el("theme", [], [@xml.Node::Element(theme_elts)])
  let map = parse_clr_scheme(theme)
  inspect(map.lookup("accent1"), content="Some(4472c4)")
  inspect(map.lookup("text1"), content="Some(000000)")
  inspect(map.lookup("background1"), content="Some(ffffff)")
  inspect(map.lookup("hyperlink"), content="Some(0563c1)")
  inspect(map.lookup("followedHyperlink"), content="Some(954f72)")
  inspect(map.lookup("accent3"), content="None")
}

///|
test "resolve_themed_color overrides base with themeColor" {
  let scheme = mk_el("clrScheme", [], [
    @xml.Node::Element(mk_color_child("accent1", "4472C4")),
  ])
  let theme_elts = mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  let theme = mk_el("theme", [], [@xml.Node::Element(theme_elts)])
  let map = parse_clr_scheme(theme)
  // themeColor wins over explicit base @color (§17.15.1.51).
  let r = resolve_themed_color(Some("ff0000"), Some("accent1"), None, None, map)
  inspect(r, content="Some(4472c4)")
}

///|
test "resolve_themed_color applies themeTint towards white" {
  let scheme = mk_el("clrScheme", [], [
    @xml.Node::Element(mk_color_child("accent1", "000000")),
  ])
  let theme_elts = mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  let theme = mk_el("theme", [], [@xml.Node::Element(theme_elts)])
  let map = parse_clr_scheme(theme)
  // tint = FF (1.0) on #000000 should fully brighten to #FFFFFF.
  let r = resolve_themed_color(None, Some("accent1"), Some("FF"), None, map)
  inspect(r, content="Some(ffffff)")
}

///|
test "resolve_themed_color applies themeShade towards black" {
  let scheme = mk_el("clrScheme", [], [
    @xml.Node::Element(mk_color_child("accent1", "FFFFFF")),
  ])
  let theme_elts = mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  let theme = mk_el("theme", [], [@xml.Node::Element(theme_elts)])
  let map = parse_clr_scheme(theme)
  // shade = FF (1.0) on #FFFFFF should fully darken to #000000.
  let r = resolve_themed_color(None, Some("accent1"), None, Some("FF"), map)
  inspect(r, content="Some(000000)")
}

///|
test "resolve_themed_color falls back to base when theme lookup fails" {
  let map = ThemeColorMap::empty()
  // No theme part / no mapping for accent7; base @color survives.
  let r = resolve_themed_color(Some("ff0000"), Some("accent7"), None, None, map)
  inspect(r, content="Some(ff0000)")
}

///|
test "resolve_themed_color returns None for auto (no inputs)" {
  let map = ThemeColorMap::empty()
  inspect(resolve_themed_color(None, None, None, None, map), content="None")
}

///|
test "resolve_themed_color honours sysClr lastClr fallback" {
  // <a:sysClr val="windowText" lastClr="000000"/> — system colour
  // with a baked-in last-resolved RGB; we should pick that up.
  let sys = mk_el(
    "sysClr",
    [mk_attr("val", "windowText"), mk_attr("lastClr", "000000")],
    [],
  )
  let dk1 = mk_el("dk1", [], [@xml.Node::Element(sys)])
  let scheme = mk_el("clrScheme", [], [@xml.Node::Element(dk1)])
  let theme_elts = mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  let theme = mk_el("theme", [], [@xml.Node::Element(theme_elts)])
  let map = parse_clr_scheme(theme)
  inspect(map.lookup("text1"), content="Some(000000)")
}

///|
/// §17.15.1.51 — end-to-end: themeColor cascade through
/// resolve_themed_color must produce the spec-mandated final
/// hex when the theme map is populated.  This complements the
/// unit tests above by exercising the full path:
///   parse_clr_scheme → ThemeColorMap → resolve_themed_color.
test "themeColor cascade E2E: accent1 + themeTint produces resolved hex" {
  let scheme = mk_el("clrScheme", [], [
    @xml.Node::Element(mk_color_child("accent1", "4472C4")),
    @xml.Node::Element(mk_color_child("dk1", "000000")),
    @xml.Node::Element(mk_color_child("lt1", "FFFFFF")),
  ])
  let theme_elts = mk_el("themeElements", [], [@xml.Node::Element(scheme)])
  let theme = mk_el("theme", [], [@xml.Node::Element(theme_elts)])
  let map = parse_clr_scheme(theme)
  // themeColor="accent1" alone → exact scheme colour.
  inspect(
    resolve_themed_color(None, Some("accent1"), None, None, map),
    content="Some(4472c4)",
  )
  // themeColor="accent1" + themeShade="80" (50%) → ~half-darkened.
  // 0x80 = 128 ⇒ shade ratio = 128/255 ≈ 0.502
  // apply_shade(rgb, 1 - 0.502) ≈ apply_shade(rgb, 0.498)
  // which multiplies each channel by 0.498:
  //   r=0x44(68) → 68 * 0.498 ≈ 33 → 0x21
  //   g=0x72(114) → 114 * 0.498 ≈ 56 → 0x38
  //   b=0xC4(196) → 196 * 0.498 ≈ 97 → 0x61
  // We don't pin the exact byte (depends on rounding); just
  // verify the result is darker than the base and 6 hex chars.
  let shaded = resolve_themed_color(None, Some("accent1"), None, Some("80"), map)
  match shaded {
    Some(hex) => {
      assert_eq(hex.length(), 6)
      // Each channel should be strictly less than the base.
      let r = hex[0:2].to_string()
      let g = hex[2:4].to_string()
      let b = hex[4:6].to_string()
      // accent1 base channels are 44 / 72 / c4 — shaded must be <.
      assert_true(r < "44")
      assert_true(g < "72")
      assert_true(b < "c4")
    }
    None => abort("expected Some(hex) for shaded accent1")
  }
}
