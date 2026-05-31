// VML AG_Style inline style parser/serialiser
//
// Part 4 §6.1 (vml-main.xsd) declares the `@style` attribute on
// every VML shape as xsd:string with a CSS-like `key:value;`
// grammar.  Without a typed projection every renderer that
// consumes a VML shape has to re-parse the raw string and risk
// drifting semantics across the codebase.
//
// This module exposes a typed `VmlInlineStyle` record covering
// every shape position / size / orientation property the spec
// permits, plus a lossless round-trip:
//
//   parse_vml_style(s)  -> VmlInlineStyle
//   format_vml_style(v) -> String
//
// Properties not recognised by the spec table are preserved in
// the `extras` field as raw `(key, value)` pairs, so round-trip
// is byte-identical for any VML the package authored.

///|
/// Typed projection of the VML `@style` attribute per Part 4
/// §6.1 vml-main.xsd `AG_Style`.  Every property is optional;
/// unrecognised properties survive on the `extras` array.
pub(all) struct VmlInlineStyle {
  /// position:absolute | static | relative
  position : String?
  /// left / top — coordinate values (CSS lengths).
  left : String?
  top : String?
  /// width / height — CSS lengths.
  width : String?
  height : String?
  /// margin-left / margin-top / margin-right / margin-bottom.
  margin_left : String?
  margin_top : String?
  margin_right : String?
  margin_bottom : String?
  /// z-index — stacking order.
  z_index : String?
  /// rotation — degrees as raw string (e.g. `"45"`).
  rotation : String?
  /// visibility — visible | hidden | collapse.
  visibility : String?
  /// mso-position-horizontal / mso-position-vertical (anchor).
  mso_position_horizontal : String?
  mso_position_vertical : String?
  /// mso-position-horizontal-relative / mso-position-vertical-relative.
  mso_position_horizontal_relative : String?
  mso_position_vertical_relative : String?
  /// mso-wrap-distance-left / -top / -right / -bottom.
  mso_wrap_distance_left : String?
  mso_wrap_distance_top : String?
  mso_wrap_distance_right : String?
  mso_wrap_distance_bottom : String?
  /// Unrecognised `key:value` pairs in document order so
  /// round-trip is lossless.  Each entry is the trimmed pair.
  extras : Array[(String, String)]
}

///|
pub fn VmlInlineStyle::empty() -> VmlInlineStyle {
  {
    position: None,
    left: None,
    top: None,
    width: None,
    height: None,
    margin_left: None,
    margin_top: None,
    margin_right: None,
    margin_bottom: None,
    z_index: None,
    rotation: None,
    visibility: None,
    mso_position_horizontal: None,
    mso_position_vertical: None,
    mso_position_horizontal_relative: None,
    mso_position_vertical_relative: None,
    mso_wrap_distance_left: None,
    mso_wrap_distance_top: None,
    mso_wrap_distance_right: None,
    mso_wrap_distance_bottom: None,
    extras: [],
  }
}

///|
/// Part 4 §6.1 — parse a VML `@style` attribute value into the
/// typed projection.  Splits on `;`, then on the first `:` per
/// entry, trimming ASCII whitespace from both key and value.
/// Empty entries (consecutive `;`) are skipped silently.
pub fn parse_vml_style(s : String) -> VmlInlineStyle {
  let extras : Array[(String, String)] = []
  let mut position : String? = None
  let mut left : String? = None
  let mut top : String? = None
  let mut width : String? = None
  let mut height : String? = None
  let mut margin_left : String? = None
  let mut margin_top : String? = None
  let mut margin_right : String? = None
  let mut margin_bottom : String? = None
  let mut z_index : String? = None
  let mut rotation : String? = None
  let mut visibility : String? = None
  let mut mso_position_horizontal : String? = None
  let mut mso_position_vertical : String? = None
  let mut mso_position_horizontal_relative : String? = None
  let mut mso_position_vertical_relative : String? = None
  let mut mso_wrap_distance_left : String? = None
  let mut mso_wrap_distance_top : String? = None
  let mut mso_wrap_distance_right : String? = None
  let mut mso_wrap_distance_bottom : String? = None
  for entry in split_on(s, ';') {
    let trimmed = trim_ascii(entry)
    if trimmed.length() == 0 {
      continue
    }
    let colon_idx = find_char_index(trimmed, ':')
    let (k, v) = match colon_idx {
      Some(idx) => {
        let k = trim_ascii(trimmed[0:idx].to_owned())
        let v = trim_ascii(trimmed[idx + 1:trimmed.length()].to_owned())
        (k, v)
      }
      None => (trimmed, "")
    }
    match k {
      "position" => position = Some(v)
      "left" => left = Some(v)
      "top" => top = Some(v)
      "width" => width = Some(v)
      "height" => height = Some(v)
      "margin-left" => margin_left = Some(v)
      "margin-top" => margin_top = Some(v)
      "margin-right" => margin_right = Some(v)
      "margin-bottom" => margin_bottom = Some(v)
      "z-index" => z_index = Some(v)
      "rotation" => rotation = Some(v)
      "visibility" => visibility = Some(v)
      "mso-position-horizontal" => mso_position_horizontal = Some(v)
      "mso-position-vertical" => mso_position_vertical = Some(v)
      "mso-position-horizontal-relative" =>
        mso_position_horizontal_relative = Some(v)
      "mso-position-vertical-relative" =>
        mso_position_vertical_relative = Some(v)
      "mso-wrap-distance-left" => mso_wrap_distance_left = Some(v)
      "mso-wrap-distance-top" => mso_wrap_distance_top = Some(v)
      "mso-wrap-distance-right" => mso_wrap_distance_right = Some(v)
      "mso-wrap-distance-bottom" => mso_wrap_distance_bottom = Some(v)
      // Unrecognised property — preserve verbatim.
      _ => extras.push((k, v))
    }
  }
  {
    position,
    left,
    top,
    width,
    height,
    margin_left,
    margin_top,
    margin_right,
    margin_bottom,
    z_index,
    rotation,
    visibility,
    mso_position_horizontal,
    mso_position_vertical,
    mso_position_horizontal_relative,
    mso_position_vertical_relative,
    mso_wrap_distance_left,
    mso_wrap_distance_top,
    mso_wrap_distance_right,
    mso_wrap_distance_bottom,
    extras,
  }
}

///|
/// Part 4 §6.1 — serialise a typed style back to the
/// `key:value;key:value` form.  Properties are emitted in the
/// declaration order defined above; extras preserve their parse
/// order.  Each pair ends with `;`.
pub fn format_vml_style(v : VmlInlineStyle) -> String {
  let buf = StringBuilder::new()
  let emit = fn(key : String, value : String?) {
    match value {
      None => ()
      Some(s) => {
        buf.write_string(key)
        buf.write_char(':')
        buf.write_string(s)
        buf.write_char(';')
      }
    }
  }
  emit("position", v.position)
  emit("left", v.left)
  emit("top", v.top)
  emit("width", v.width)
  emit("height", v.height)
  emit("margin-left", v.margin_left)
  emit("margin-top", v.margin_top)
  emit("margin-right", v.margin_right)
  emit("margin-bottom", v.margin_bottom)
  emit("z-index", v.z_index)
  emit("rotation", v.rotation)
  emit("visibility", v.visibility)
  emit("mso-position-horizontal", v.mso_position_horizontal)
  emit("mso-position-vertical", v.mso_position_vertical)
  emit("mso-position-horizontal-relative", v.mso_position_horizontal_relative)
  emit("mso-position-vertical-relative", v.mso_position_vertical_relative)
  emit("mso-wrap-distance-left", v.mso_wrap_distance_left)
  emit("mso-wrap-distance-top", v.mso_wrap_distance_top)
  emit("mso-wrap-distance-right", v.mso_wrap_distance_right)
  emit("mso-wrap-distance-bottom", v.mso_wrap_distance_bottom)
  for entry in v.extras {
    let (k, val) = entry
    buf.write_string(k)
    buf.write_char(':')
    buf.write_string(val)
    buf.write_char(';')
  }
  buf.to_string()
}

///|
fn split_on(s : String, sep : Char) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder::new()
  let sep_code = sep.to_int()
  for i in 0..<s.length() {
    let c = s.code_unit_at(i).to_int()
    if c == sep_code {
      out.push(buf.to_string())
      buf.reset()
    } else {
      buf.write_char(c.to_char().unwrap())
    }
  }
  out.push(buf.to_string())
  out
}

///|
fn trim_ascii(s : String) -> String {
  let is_ws = fn(c : Int) -> Bool {
    c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D
  }
  let mut start = 0
  let mut end = s.length()
  while start < end && is_ws(s.code_unit_at(start).to_int()) {
    start = start + 1
  }
  while end > start && is_ws(s.code_unit_at(end - 1).to_int()) {
    end = end - 1
  }
  if start == 0 && end == s.length() {
    s
  } else {
    s[start:end].to_owned()
  }
}

///|
fn find_char_index(s : String, ch : Char) -> Int? {
  let code = ch.to_int()
  for i in 0..<s.length() {
    if s.code_unit_at(i).to_int() == code {
      return Some(i)
    }
  }
  None
}
