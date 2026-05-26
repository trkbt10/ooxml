// ECMA-376 §19.1.2 — VML element `style` attribute parser.
//
// VML elements (`<v:shape>`, `<v:rect>`, `<v:line>`, …) carry CSS-
// style attribute values such as
//
//     style="position:absolute;left:12pt;top:24pt;width:96pt;height:48pt;rotation:30"
//
// The parser walks the semicolon-separated declarations and surfaces
// the geometry rules (`left`, `top`, `width`, `height`, `rotation`,
// `margin-left`, `margin-top`, `mso-position-horizontal`, etc.) as a
// `StyleProps` record so the SVG emitter can lift them into
// `x`/`y`/`width`/`height`/`transform` attributes.
//
// Units handled: pt (96/72 px), px (1 px), in (96 px), cm (96/2.54
// px), mm (96/25.4 px), pc (16 px = 12 pt = 1 pica), and bare numbers
// (treated as px).  All values land in CSS pixels.  Missing /
// malformed declarations leave the corresponding slot at `None`.

///|
/// Parsed `style` attribute properties relevant to the VML→SVG
/// emitter.  Every numeric slot is in CSS pixels at 96 dpi (the SVG
/// default user coordinate system).  `None` means the declaration
/// was absent; the caller falls back to its own default.
pub(all) struct StyleProps {
  left : Double?
  top : Double?
  width : Double?
  height : Double?
  /// `rotation:Ndeg` (or bare number, interpreted as degrees per the
  /// VML reference).  Positive = clockwise around the element centre.
  rotation_deg : Double?
  /// `flip:x` / `flip:y` / `flip:xy` toggles a coordinate flip on
  /// the corresponding axis (around the element centre).
  flip_x : Bool
  flip_y : Bool
  /// `visibility:hidden` suppresses paint.  The renderer surfaces a
  /// zero-fill rect placeholder so the element still leaves a
  /// visible presence marker.
  hidden : Bool
}

///|
/// Default (all-`None`) style props.  Used as the starting point of
/// the parser so the caller can compose partial values.
pub fn StyleProps::empty() -> StyleProps {
  {
    left: None,
    top: None,
    width: None,
    height: None,
    rotation_deg: None,
    flip_x: false,
    flip_y: false,
    hidden: false,
  }
}

///|
/// Parse a VML `style` attribute value into `StyleProps`.  Any
/// declaration the parser does not recognise is silently skipped —
/// the spec permits free-form properties (`z-index`, `position`,
/// `mso-…` MSO extensions, `visibility`, …) and the renderer only
/// needs the geometry subset.
pub fn parse_style(s : String) -> StyleProps {
  let mut left : Double? = None
  let mut top : Double? = None
  let mut width : Double? = None
  let mut height : Double? = None
  let mut rotation_deg : Double? = None
  let mut flip_x = false
  let mut flip_y = false
  let mut hidden = false
  for decl in s.split(";") {
    let trimmed = trim_ws(decl.to_owned())
    let colon = match trimmed.find(":") {
      Some(i) => i
      None => continue
    }
    let key = trim_ws(trimmed[0:colon].to_owned()).to_lower()
    let raw = trim_ws(trimmed[colon + 1:].to_owned())
    match key {
      "left" | "margin-left" => left = Some(parse_length_px(raw))
      "top" | "margin-top" => top = Some(parse_length_px(raw))
      "width" => width = Some(parse_length_px(raw))
      "height" => height = Some(parse_length_px(raw))
      "rotation" => rotation_deg = Some(parse_rotation_deg(raw))
      "flip" => {
        let v = raw.to_lower()
        if v.contains("x") {
          flip_x = true
        }
        if v.contains("y") {
          flip_y = true
        }
      }
      "visibility" => if raw.to_lower() == "hidden" { hidden = true }
      _ => ()
    }
  }
  { left, top, width, height, rotation_deg, flip_x, flip_y, hidden }
}

///|
/// §19.1.2.19 — convert a CSS-length token (`12pt`, `1.5in`, `96px`,
/// `0`) to CSS pixels at 96 dpi.  Returns 0.0 on parse failure so the
/// caller's default kicks in.
pub fn parse_length_px(raw : String) -> Double {
  let n = raw.length()
  if n == 0 {
    return 0.0
  }
  let mut i = 0
  // Optional leading sign.
  if raw[0] == '-' || raw[0] == '+' {
    i = i + 1
  }
  while i < n {
    let c = raw[i]
    if c == '0' ||
      c == '1' ||
      c == '2' ||
      c == '3' ||
      c == '4' ||
      c == '5' ||
      c == '6' ||
      c == '7' ||
      c == '8' ||
      c == '9' ||
      c == '.' {
      i = i + 1
    } else {
      break
    }
  }
  if i == 0 || (i == 1 && (raw[0] == '+' || raw[0] == '-')) {
    return 0.0
  }
  let num_str = raw[0:i].to_owned()
  let unit = trim_ws(raw[i:].to_owned()).to_lower()
  let v = try @string.parse_double(num_str) catch {
    _ => return 0.0
  } noraise {
    d => d
  }
  match unit {
    "pt" => v * 96.0 / 72.0
    "in" => v * 96.0
    "cm" => v * 96.0 / 2.54
    "mm" => v * 96.0 / 25.4
    "pc" => v * 16.0
    "em" => v * 16.0 // VML em ≈ font-size; 16 px is the SVG default.
    "px" | "" => v
    _ => v
  }
}

///|
/// §19.1.2.19 `rotation` — parse a rotation value (degrees by
/// default; the VML reference allows the `deg`, `rad`, `grad`
/// suffixes).  Returns 0.0 on parse failure so the SVG transform
/// stays an identity.
fn parse_rotation_deg(raw : String) -> Double {
  let n = raw.length()
  if n == 0 {
    return 0.0
  }
  let mut i = 0
  if raw[0] == '-' || raw[0] == '+' {
    i = i + 1
  }
  while i < n {
    let c = raw[i]
    if c == '0' ||
      c == '1' ||
      c == '2' ||
      c == '3' ||
      c == '4' ||
      c == '5' ||
      c == '6' ||
      c == '7' ||
      c == '8' ||
      c == '9' ||
      c == '.' {
      i = i + 1
    } else {
      break
    }
  }
  if i == 0 || (i == 1 && (raw[0] == '+' || raw[0] == '-')) {
    return 0.0
  }
  let num_str = raw[0:i].to_owned()
  let unit = trim_ws(raw[i:].to_owned()).to_lower()
  let v = try @string.parse_double(num_str) catch {
    _ => return 0.0
  } noraise {
    d => d
  }
  match unit {
    "rad" => v * 180.0 / 3.14159265358979323846
    "grad" => v * 0.9
    "fd" =>
      // VML fractional-degree unit (1/65536 of a degree).
      v / 65536.0
    _ => v
  }
}

///|
/// Trim ASCII whitespace from both ends of a string.
fn trim_ws(s : String) -> String {
  let n = s.length()
  let mut a = 0
  while a < n {
    let c = s[a]
    if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
      a = a + 1
    } else {
      break
    }
  }
  let mut b = n
  while b > a {
    let c = s[b - 1]
    if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
      b = b - 1
    } else {
      break
    }
  }
  s[a:b].to_owned()
}
