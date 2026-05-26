// §18.8.3 CT_Color theme/tint resolver
//
// SpreadsheetML's `<color>` element (`<rPr><color/>`, `<border>`
// stroke, `<patternFill><fgColor/>` …) carries a five-attribute
// triple that together pick a single colour: `@auto`, `@indexed`,
// `@rgb`, `@theme`, `@tint`.  This file resolves the
// `@theme`/`@tint` pair against a workbook theme map.
//
// Per ECMA-376 Part 1 §18.8.3:
//   - `@theme` is an `xsd:unsignedInt` whose value indexes into
//     the workbook's `<a:clrScheme>` slot list (`0..11`).  The
//     ordering is the same DML ordering used by §20.1.4.1.6
//     (`<a:clrScheme>`): lt1, dk1, lt2, dk2, accent1..accent6,
//     hlink, folHlink — see Annex L.4 for the canonical table.
//   - `@tint` is an `xsd:double` in the range `-1.0..1.0`.
//     Positive values brighten the resolved RGB towards white;
//     negative values darken it towards black; `0.0` is identity.
//     The tint is applied in HSL space per §18.8.3 — we keep
//     parity with that by delegating to `@color.apply_lum_off`,
//     which is the same HSL-luminance offset web-pptx uses for
//     `<a:lumOff>`/`<a:lumMod>`.

///|
/// §18.8.3 — workbook theme colour map.  Indexed by ST_ThemeColor
/// slot (0..11) per the §20.1.4.1.6 ordering: lt1, dk1, lt2, dk2,
/// accent1..accent6, hlink, folHlink.
pub(all) struct SmlThemeColorMap {
  slots : Array[String?]
}

///|
pub fn SmlThemeColorMap::empty() -> SmlThemeColorMap {
  let slots : Array[String?] = []
  for _i in 0..<12 {
    slots.push(None)
  }
  { slots, }
}

///|
/// §18.8.3 @theme — resolve an integer theme index into a 6-digit
/// lowercase hex.  Returns None when the index is out of range or
/// the slot is empty in the workbook theme.
pub fn SmlThemeColorMap::lookup(
  self : SmlThemeColorMap,
  theme_index : Int,
) -> String? {
  if theme_index < 0 || theme_index >= self.slots.length() {
    return None
  }
  self.slots[theme_index]
}

///|
/// Parse `<a:theme>/<a:themeElements>/<a:clrScheme>` into a
/// SmlThemeColorMap.  Slot ordering follows the §20.1.4.1.6
/// canonical sequence: lt1=0, dk1=1, lt2=2, dk2=3, accent1=4,
/// accent2=5, accent3=6, accent4=7, accent5=8, accent6=9,
/// hlink=10, folHlink=11.
///
/// Note: SML's §18.8.3 ordering swaps lt1/dk1 relative to WML's
/// theme map (which exposes dk1 first as "text1").  We keep the
/// SML-native order so consumers can index by the `@theme`
/// attribute value directly.
pub fn parse_sml_clr_scheme(theme_root : @xml.Element) -> SmlThemeColorMap {
  let map = SmlThemeColorMap::empty()
  for theme_child in theme_root.children {
    match theme_child {
      @xml.Node::Element(theme_elts) =>
        if theme_elts.name.local_name == "themeElements" {
          for elts_child in theme_elts.children {
            match elts_child {
              @xml.Node::Element(clr_scheme) =>
                if clr_scheme.name.local_name == "clrScheme" {
                  for color_child in clr_scheme.children {
                    match color_child {
                      @xml.Node::Element(color_el) => {
                        let slot = match color_el.name.local_name {
                          "lt1" => 0
                          "dk1" => 1
                          "lt2" => 2
                          "dk2" => 3
                          "accent1" => 4
                          "accent2" => 5
                          "accent3" => 6
                          "accent4" => 7
                          "accent5" => 8
                          "accent6" => 9
                          "hlink" => 10
                          "folHlink" => 11
                          // Schema violation — unknown scheme child.
                          _ => -1
                        }
                        if slot >= 0 {
                          let hex = extract_sml_scheme_hex(color_el)
                          map.slots[slot] = hex
                        }
                      }
                      _ => ()
                    }
                  }
                }
              _ => ()
            }
          }
        }
      _ => ()
    }
  }
  map
}

///|
/// DML §20.1.2.3 — flatten a colour child element into 6-digit
/// lowercase hex; returns None when the colour uses one of the
/// spec-permitted derived forms (`schemeClr`, `hslClr`, `scrgbClr`,
/// `prstClr`) that the SML viewer does not evaluate.
fn extract_sml_scheme_hex(color_el : @xml.Element) -> String? {
  for child in color_el.children {
    match child {
      @xml.Node::Element(inner) =>
        match inner.name.local_name {
          "srgbClr" => return sml_attr_lower(inner, "val")
          "sysClr" => return sml_attr_lower(inner, "lastClr")
          _ => ()
        }
      _ => ()
    }
  }
  None
}

///|
fn sml_attr_lower(element : @xml.Element, attr_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == attr_name {
      return Some(sml_lower_hex(attr.value))
    }
  }
  None
}

///|
fn sml_lower_hex(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    let u = c.to_int()
    if u >= 0x41 && u <= 0x46 {
      buf.write_char((u + 32).unsafe_to_char())
    } else if u >= 0x61 && u <= 0x66 {
      buf.write_char(c)
    } else if u >= 0x30 && u <= 0x39 {
      buf.write_char(c)
    } else {
      // Schema violation — non-hex character; skip silently.
      ()
    }
  }
  buf.to_string()
}

///|
/// §18.8.3 — resolve a CT_Color (`@rgb` base, `@theme` index,
/// `@tint` luminance offset) to a final 6-digit hex.  Per the
/// spec:
///   1. When `@auto` is true, the colour is the consumer's
///      "system" default — we return None so the caller can emit
///      the spec-permitted `auto` sentinel.
///   2. When `@theme` is set, it overrides `@rgb` and is resolved
///      through the workbook theme map.
///   3. `@tint` (-1.0..1.0) is applied as an HSL luminance
///      offset on the resolved RGB.  Negative tints darken;
///      positive tints brighten.
///   4. When `@indexed` is set without `@rgb`/`@theme`, the
///      colour belongs to the legacy indexed palette which is
///      out-of-scope here; we return None so the caller can
///      defer to its own palette lookup.
pub fn resolve_sml_color(
  ct_color : @domain.CT_Color,
  theme_map : SmlThemeColorMap,
) -> String? {
  if ct_color.auto_ {
    return None
  }
  let base : String? = match ct_color.theme {
    Some(idx) =>
      match theme_map.lookup(idx) {
        Some(hex) => Some(hex)
        // Theme index out of range / slot empty — fall back to
        // the explicit @rgb (the spec lets both attributes
        // coexist; the theme wins only when the lookup
        // succeeds).
        None => normalise_rgb(ct_color.rgb)
      }
    None => normalise_rgb(ct_color.rgb)
  }
  match base {
    None => None
    Some(hex) =>
      if ct_color.tint == 0.0 {
        Some(hex)
      } else {
        // §18.8.3 — tint applies in HSL space.  Positive values
        // brighten (add luminance), negative values darken (sub
        // luminance).  `@color.apply_lum_off` takes the offset
        // directly and clamps to [0, 1].
        Some(@color.apply_lum_off(hex, ct_color.tint))
      }
  }
}

///|
/// §18.3.1.15 — the `@rgb` attribute is ST_UnsignedIntHex, an
/// 8-digit `AARRGGBB` literal.  The high two digits are the alpha
/// channel; we drop them here because the SVG colour shorthand
/// only takes a 6-digit RGB.  Returns None when the attribute is
/// absent, empty, or malformed.
fn normalise_rgb(rgb : String?) -> String? {
  match rgb {
    None => None
    Some(text) => {
      let lower = sml_lower_hex(text)
      if lower.length() == 8 {
        // Strip the alpha-channel prefix.
        Some(lower[2:8].to_owned())
      } else if lower.length() == 6 {
        Some(lower)
      } else {
        None
      }
    }
  }
}
