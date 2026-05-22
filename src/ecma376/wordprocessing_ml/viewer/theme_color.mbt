// §17.18.97 ST_ThemeColor / §17.18.98 ST_UcharHexNumber resolver
//
// WordprocessingML colour attributes (`@color`, `@themeColor`,
// `@themeTint`, `@themeShade`) cascade as follows per ECMA-376
// Part 1 §17.15.1.51:
//
//   1. When `@themeColor` is set, it overrides `@color`.
//   2. `@themeColor` is looked up in the theme's clrScheme (DML
//      §20.1.6.2) — e.g. `accent1` → `<a:accent1>`.
//   3. `@themeTint` brightens the resolved RGB towards white;
//      `@themeShade` darkens it towards black.  Both attributes
//      carry an ST_UcharHexNumber (`00`..`FF`) which we normalise
//      to a ratio in `[0, 1]` (value / 255).
//
// `ThemeColorMap` holds the resolved `<a:srgbClr val="…"/>` for
// each ST_ThemeColor enumerator that we found in `theme1.xml`.
// Lookups for absent keys return None so the caller can fall back
// to `@color`.

///|
/// §17.18.96 ST_Theme enumeration → resolved typeface name.
/// `majorAscii` / `minorAscii` / `majorHAnsi` / `minorHAnsi` /
/// `majorBidi` / `minorBidi` / `majorEastAsia` / `minorEastAsia`
/// resolve via the DML §20.1.4.1.18 fontScheme:
///   major* → `<a:majorFont>/<a:latin|ea|cs>/@typeface`
///   minor* → `<a:minorFont>/<a:latin|ea|cs>/@typeface`
pub(all) struct ThemeFontMap {
  major_latin : String?
  major_ea : String?
  major_cs : String?
  minor_latin : String?
  minor_ea : String?
  minor_cs : String?
}

///|
pub fn ThemeFontMap::empty() -> ThemeFontMap {
  {
    major_latin: None,
    major_ea: None,
    major_cs: None,
    minor_latin: None,
    minor_ea: None,
    minor_cs: None,
  }
}

///|
/// §17.18.96 — resolve a ST_Theme enumerator value to its
/// concrete typeface from the document's theme part.  Returns
/// None when the theme map is empty or the enumerator is
/// outside the spec (the caller falls back to the literal
/// typeface or DEFAULT_FONT_FAMILY).
pub fn ThemeFontMap::lookup(
  self : ThemeFontMap,
  theme_token : String,
) -> String? {
  match theme_token {
    "majorAscii" => self.major_latin
    "majorHAnsi" => self.major_latin
    "majorBidi" => self.major_cs
    "majorEastAsia" => self.major_ea
    "minorAscii" => self.minor_latin
    "minorHAnsi" => self.minor_latin
    "minorBidi" => self.minor_cs
    "minorEastAsia" => self.minor_ea
    _ => None
  }
}

///|
/// Walk a parsed DML theme root and extract its fontScheme
/// `<a:majorFont>` / `<a:minorFont>` typeface attributes into a
/// `ThemeFontMap`.  Returns the empty map when the input is None
/// or has no `<a:themeElements>/<a:fontScheme>` child.
pub fn parse_font_scheme(theme_root : @xml.Element?) -> ThemeFontMap {
  let map_mut : Ref[ThemeFontMap] = { val: ThemeFontMap::empty() }
  let root = match theme_root {
    Some(r) => r
    None => return map_mut.val
  }
  let theme_elements = find_a_child(root, "themeElements")
  let font_scheme = match theme_elements {
    Some(te) => find_a_child(te, "fontScheme")
    None => None
  }
  match font_scheme {
    None => ()
    Some(fs) => {
      match find_a_child(fs, "majorFont") {
        Some(mj) => {
          map_mut.val = {
            ..map_mut.val,
            major_latin: typeface_attr(find_a_child(mj, "latin")),
            major_ea: typeface_attr(find_a_child(mj, "ea")),
            major_cs: typeface_attr(find_a_child(mj, "cs")),
          }
        }
        None => ()
      }
      match find_a_child(fs, "minorFont") {
        Some(mn) => {
          map_mut.val = {
            ..map_mut.val,
            minor_latin: typeface_attr(find_a_child(mn, "latin")),
            minor_ea: typeface_attr(find_a_child(mn, "ea")),
            minor_cs: typeface_attr(find_a_child(mn, "cs")),
          }
        }
        None => ()
      }
    }
  }
  map_mut.val
}

///|
fn find_a_child(element : @xml.Element, local : String) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn typeface_attr(element : @xml.Element?) -> String? {
  match element {
    None => None
    Some(e) =>
      for a in e.attributes {
        if a.name.local_name == "typeface" && a.value.length() > 0 {
          return Some(a.value)
        }
      } else {
        None
      }
  }
}

///|
/// §17.18.97 ST_ThemeColor enumeration → resolved sRGB hex
/// (lowercase, 6 hex digits, no leading `#`).
pub(all) struct ThemeColorMap {
  /// `dark1` / `lt1` / `dk1` — text/background 1.
  dark1 : String?
  /// `light1` / `lt1` — when present in `<a:clrScheme>` as `<a:lt1>`.
  light1 : String?
  dark2 : String?
  light2 : String?
  accent1 : String?
  accent2 : String?
  accent3 : String?
  accent4 : String?
  accent5 : String?
  accent6 : String?
  hyperlink : String?
  followed_hyperlink : String?
}

///|
/// Empty theme map — every lookup returns None.  Used when the
/// viewer has no theme part wired in.
pub fn ThemeColorMap::empty() -> ThemeColorMap {
  {
    dark1: None,
    light1: None,
    dark2: None,
    light2: None,
    accent1: None,
    accent2: None,
    accent3: None,
    accent4: None,
    accent5: None,
    accent6: None,
    hyperlink: None,
    followed_hyperlink: None,
  }
}

///|
/// §17.18.97 — resolve a ST_ThemeColor enumerator to its sRGB hex.
/// Handles both the WML aliases (`text1` / `background1`) and the
/// DML scheme element names (`dk1` / `lt1` / `dk2` / `lt2`).
pub fn ThemeColorMap::lookup(
  self : ThemeColorMap,
  theme_color : String,
) -> String? {
  match theme_color {
    // §17.18.97 enumeration aliases — these map to the dk*/lt*
    // colours of the DML scheme per the same section's table.
    "text1" => self.dark1
    "background1" => self.light1
    "text2" => self.dark2
    "background2" => self.light2
    "dark1" => self.dark1
    "light1" => self.light1
    "dark2" => self.dark2
    "light2" => self.light2
    "accent1" => self.accent1
    "accent2" => self.accent2
    "accent3" => self.accent3
    "accent4" => self.accent4
    "accent5" => self.accent5
    "accent6" => self.accent6
    "hyperlink" => self.hyperlink
    "followedHyperlink" => self.followed_hyperlink
    // §17.18.97 also lists `none` — explicit "no theme colour".
    "none" => None
    // Schema violation — unknown enumerator. The reader has
    // already normalised the attribute through the typed
    // CT_*-attribute path, so an unknown value here means a
    // malformed document; return None and let the @color
    // attribute survive instead.
    _ => None
  }
}

///|
/// Parse `<a:theme>/<a:themeElements>/<a:clrScheme>` into a
/// ThemeColorMap.  Each child element name (`dk1`, `lt1`, …)
/// corresponds one-to-one with a struct field; the colour child
/// (`<a:srgbClr val="…"/>` or `<a:sysClr lastClr="…"/>`) is
/// flattened into a 6-digit lowercase hex string.
pub fn parse_clr_scheme(theme_root : @xml.Element) -> ThemeColorMap {
  let mut dark1 : String? = None
  let mut light1 : String? = None
  let mut dark2 : String? = None
  let mut light2 : String? = None
  let mut accent1 : String? = None
  let mut accent2 : String? = None
  let mut accent3 : String? = None
  let mut accent4 : String? = None
  let mut accent5 : String? = None
  let mut accent6 : String? = None
  let mut hyperlink : String? = None
  let mut followed_hyperlink : String? = None
  // Walk `themeElements/clrScheme/*`.
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
                        let hex = extract_scheme_color_hex(color_el)
                        match color_el.name.local_name {
                          "dk1" => dark1 = hex
                          "lt1" => light1 = hex
                          "dk2" => dark2 = hex
                          "lt2" => light2 = hex
                          "accent1" => accent1 = hex
                          "accent2" => accent2 = hex
                          "accent3" => accent3 = hex
                          "accent4" => accent4 = hex
                          "accent5" => accent5 = hex
                          "accent6" => accent6 = hex
                          "hlink" => hyperlink = hex
                          "folHlink" => followed_hyperlink = hex
                          // Schema violation — unknown scheme
                          // child.  Drop silently; an unknown
                          // child cannot map to any §17.18.97
                          // enumerator anyway.
                          _ => ()
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
  {
    dark1,
    light1,
    dark2,
    light2,
    accent1,
    accent2,
    accent3,
    accent4,
    accent5,
    accent6,
    hyperlink,
    followed_hyperlink,
  }
}

///|
/// DML §20.1.2.3 — flatten a colour child element (`a:srgbClr`,
/// `a:sysClr`) into 6-digit lowercase hex without the leading `#`.
/// Returns None when the element is one of the spec-permitted
/// derived colour forms (`a:schemeClr`, `a:hslClr`, `a:scrgbClr`,
/// `a:prstClr`) that we cannot resolve without a fuller DML
/// evaluator.
fn extract_scheme_color_hex(color_el : @xml.Element) -> String? {
  for child in color_el.children {
    match child {
      @xml.Node::Element(inner) =>
        match inner.name.local_name {
          "srgbClr" => return read_attr_normalised(inner, "val")
          "sysClr" =>
            // §20.1.2.3.32 — `lastClr` records the last-resolved
            // RGB so non-system viewers (us) can still recover a
            // concrete colour without consulting the OS palette.
            return read_attr_normalised(inner, "lastClr")
          _ => ()
        }
      _ => ()
    }
  }
  None
}

///|
/// Lowercase a 6-digit hex string; pass through anything else so
/// caller code can decide whether to honour it (an empty string,
/// for example, would indicate a malformed attribute).
fn read_attr_normalised(
  element : @xml.Element,
  attr_name : String,
) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == attr_name {
      return Some(lowercase_hex(attr.value))
    }
  }
  None
}

///|
fn lowercase_hex(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    let u = c.to_int()
    if u >= 0x41 && u <= 0x46 {
      buf.write_char(Char::from_int(u + 32))
    } else if u >= 0x61 && u <= 0x66 {
      buf.write_char(c)
    } else if u >= 0x30 && u <= 0x39 {
      buf.write_char(c)
    } else {
      // Schema violation — non-hex character.  Drop it so the
      // caller's downstream consumers see a clean hex string;
      // they'll fall back to the explicit @color attribute when
      // the lookup produces a malformed value.
      ()
    }
  }
  buf.to_string()
}

///|
/// §17.15.1.51 — resolve a WML colour triple (base colour,
/// themeColor, themeTint, themeShade) to a final 6-digit hex
/// (no leading `#`).  Per the spec:
///   1. When `themeColor` is set, it overrides the base colour.
///   2. The resolved theme RGB is tinted (towards white) by
///      `themeTint`, then shaded (towards black) by `themeShade`.
///   3. When `themeColor` resolves to None (e.g. the theme part
///      is missing the enumerator), the base colour wins.
///   4. When all of the above produce no concrete colour, return
///      None and let the caller emit the spec-permitted "auto"
///      sentinel.
pub fn resolve_themed_color(
  base : String?,
  theme_color : String?,
  theme_tint : String?,
  theme_shade : String?,
  theme_map : ThemeColorMap,
) -> String? {
  let starting = match theme_color {
    Some(name) =>
      match theme_map.lookup(name) {
        Some(hex) => Some(hex)
        None => base
      }
    None => base
  }
  match starting {
    None => None
    Some(hex) => {
      let mut current = hex
      // §17.18.98 ST_UcharHexNumber — hex byte, 00..FF.
      //
      // WML convention (per [MS-OE376] §1.3.7.10 and ISO/IEC
      // 29500-1 §17.18.98): the ratio value/255 is the fraction
      // of *blend toward white* (tint) or *blend toward black*
      // (shade).  `0x00` is identity (full base colour), `0xFF`
      // is full white / full black.
      //
      // DrawingML's `<a:tint val>` (§20.1.2.3.34) inverts this:
      // `1.0` is identity, `0.0` is white — see web-pptx's
      // `applyTint` semantics.  We therefore feed
      // `1.0 - (uchar/255)` to the DML helper so the WML
      // semantics survive the call.
      match theme_tint {
        Some(text) => {
          let ratio = parse_uchar_hex_ratio(text)
          if ratio > 0.0 {
            current = @color.apply_tint(current, 1.0 - ratio)
          }
        }
        None => ()
      }
      match theme_shade {
        Some(text) => {
          let ratio = parse_uchar_hex_ratio(text)
          if ratio > 0.0 {
            current = @color.apply_shade(current, 1.0 - ratio)
          }
        }
        None => ()
      }
      Some(current)
    }
  }
}

///|
/// §17.18.98 — parse a ST_UcharHexNumber attribute (one hex byte,
/// 00..FF) and return value/255 in `[0, 1]`.  Schema violations
/// (wrong length, non-hex characters) yield 0.0 which collapses
/// the transformation to a no-op.
fn parse_uchar_hex_ratio(text : String) -> Double {
  if text.length() != 2 {
    return 0.0
  }
  let high = hex_digit_value(text.code_unit_at(0).to_int())
  let low = hex_digit_value(text.code_unit_at(1).to_int())
  if high < 0 || low < 0 {
    return 0.0
  }
  (high * 16 + low).to_double() / 255.0
}

///|
fn hex_digit_value(u : Int) -> Int {
  if u >= 0x30 && u <= 0x39 {
    return u - 0x30
  }
  if u >= 0x41 && u <= 0x46 {
    return u - 0x41 + 10
  }
  if u >= 0x61 && u <= 0x66 {
    return u - 0x61 + 10
  }
  -1
}
