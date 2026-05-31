// =============================================================================
// Microsoft x14 sparklines decoder.
//
// Walks an `<x:extLst>` element (or, more typically, one of its
// `<x:ext>` children) and decodes every `<x14:sparklineGroups>`
// payload it finds. The base SpreadsheetML parser preserves the
// `<ext>` content as raw `@xml.Element` children inside
// `CT_Extension::any_children`, so callers usually pass that array
// here.
//
// The walker is namespace-aware: it accepts elements whose
// `QName.ns` is `x14_ns()` OR whose `QName.local_name` matches when
// the source XML uses a different prefix binding. Per the project
// constraint (`AGENTS.md`: "All extension namespace handling goes
// through @xml.Element (not regex)"), no regex / string-search is
// used anywhere in this file.
// =============================================================================

///|
/// Decode every `<x14:sparklineGroups>` found in an extension-list
/// element. Returns the merged `SparklineGroups` payload — empty
/// when no x14 sparkline extension is present.
pub fn decode_ext_lst(ext_lst : @xml.Element) -> SparklineGroups {
  let groups : Array[SparklineGroup] = []
  for node in ext_lst.children {
    if node is @xml.Node::Element(ext) {
      // §18.2.10 `<ext>` — only those that carry the sparkline URI
      // (or carry an `<x14:sparklineGroups>` descendant) are
      // relevant. Match on the URI when present; otherwise fall
      // through to the child walk so payloads that omit the
      // attribute (a few non-spec writers do) are still picked up.
      let ext_local = ext.name.local_name
      if ext_local != "ext" {
        continue
      }
      let uri_match = match find_attr(ext, "uri") {
        Some(value) => value == sparkline_ext_uri()
        None => true
      }
      if !uri_match {
        // Different `<ext>` (e.g. conditional-formatting x14
        // extension) — leave it for its own decoder.
        continue
      }
      for child in ext.children {
        if child is @xml.Node::Element(el) {
          if is_x14_named(el, "sparklineGroups") {
            decode_sparkline_groups_into(el, groups)
          }
        }
      }
    }
  }
  { groups, }
}

///|
/// Decode `<x14:sparklineGroups>` into the destination array.
fn decode_sparkline_groups_into(
  groups_elt : @xml.Element,
  out : Array[SparklineGroup],
) -> Unit {
  for node in groups_elt.children {
    if node is @xml.Node::Element(el) {
      if is_x14_named(el, "sparklineGroup") {
        out.push(decode_sparkline_group(el))
      }
    }
  }
}

///|
/// Decode one `<x14:sparklineGroup>` element.
fn decode_sparkline_group(group_elt : @xml.Element) -> SparklineGroup {
  let kind = match find_attr(group_elt, "type") {
    Some("column") => Column
    Some("stacked") => Stacked
    Some("line") | None => Line
    Some(_) => Line // unknown literal — fall back to default per ST_SparklineType.
  }
  let display_empty_cells_as = match
    find_attr(group_elt, "displayEmptyCellsAs") {
    Some("zero") => EmptyZero
    Some("span") => EmptySpan
    Some("gap") | None => EmptyGap
    Some(_) => EmptyGap
  }
  let markers = bool_attr(group_elt, "markers")
  let high = bool_attr(group_elt, "high")
  let low = bool_attr(group_elt, "low")
  let first = bool_attr(group_elt, "first")
  let last = bool_attr(group_elt, "last")
  let negative = bool_attr(group_elt, "negative")
  let display_x_axis = bool_attr(group_elt, "displayXAxis")
  let mut color_series = SparklineColor::empty()
  let mut color_negative = SparklineColor::empty()
  let mut color_axis = SparklineColor::empty()
  let mut color_markers = SparklineColor::empty()
  let mut color_first = SparklineColor::empty()
  let mut color_last = SparklineColor::empty()
  let mut color_high = SparklineColor::empty()
  let mut color_low = SparklineColor::empty()
  let sparklines : Array[Sparkline] = []
  for node in group_elt.children {
    if node is @xml.Node::Element(el) {
      let local_name = el.name.local_name
      if !is_x14(el) {
        continue
      }
      match local_name {
        "colorSeries" => color_series = decode_color(el)
        "colorNegative" => color_negative = decode_color(el)
        "colorAxis" => color_axis = decode_color(el)
        "colorMarkers" => color_markers = decode_color(el)
        "colorFirst" => color_first = decode_color(el)
        "colorLast" => color_last = decode_color(el)
        "colorHigh" => color_high = decode_color(el)
        "colorLow" => color_low = decode_color(el)
        "sparklines" => decode_sparklines_into(el, sparklines)
        _ => ()
      }
    }
  }
  {
    kind,
    display_empty_cells_as,
    markers,
    high,
    low,
    first,
    last,
    negative,
    display_x_axis,
    color_series,
    color_negative,
    color_axis,
    color_markers,
    color_first,
    color_last,
    color_high,
    color_low,
    sparklines,
  }
}

///|
/// Decode `<x14:sparklines>` into the destination array.
fn decode_sparklines_into(
  sparklines_elt : @xml.Element,
  out : Array[Sparkline],
) -> Unit {
  for node in sparklines_elt.children {
    if node is @xml.Node::Element(el) {
      if is_x14_named(el, "sparkline") {
        out.push(decode_sparkline(el))
      }
    }
  }
}

///|
/// Decode one `<x14:sparkline>` element.
fn decode_sparkline(sparkline_elt : @xml.Element) -> Sparkline {
  let mut data_range : String = ""
  let mut anchor_cell : String = ""
  let literal_values : Array[Double] = []
  for node in sparkline_elt.children {
    if node is @xml.Node::Element(el) {
      let local_name = el.name.local_name
      // `<xm:f>` / `<xm:sqref>` (the Excel 2010 "expressions and
      // metadata" namespace) carry the data-range formula and the
      // anchor sqref respectively. Match by local name since the
      // prefix can vary per source document.
      if local_name == "f" {
        data_range = element_text(el)
        // The fixture-time literal-values escape hatch: a
        // semicolon-suffixed sentinel `"<formula>; values=1,2,3"`
        // lets a fixture bypass the (not-yet-implemented) data-range
        // resolver. Documented in the package README. The base
        // formula (everything left of the first `;`) round-trips
        // verbatim into `data_range`.
        let parts = split_once(data_range, ';')
        match parts {
          None => ()
          Some((base, tail)) => {
            data_range = trim(base)
            let tail = trim(tail)
            let kv = split_once(tail, '=')
            match kv {
              Some((k, v)) =>
                if trim(k) == "values" {
                  for raw in split_all(v, ',') {
                    try @string.parse_double(trim(raw)) catch {
                      _ => ()
                    } noraise {
                      d => literal_values.push(d)
                    }
                  }
                }
              None => ()
            }
          }
        }
      } else if local_name == "sqref" {
        anchor_cell = element_text(el)
      } else if is_x14(el) && local_name == "values" {
        // Some non-Microsoft writers inline the literal data as
        // `<x14:values><x14:v>1</x14:v>…</x14:values>` — pick the
        // numeric `<x14:v>` children up so the renderer has data
        // when no data-range resolver is wired in.
        for vnode in el.children {
          if vnode is @xml.Node::Element(vel) {
            if vel.name.local_name == "v" {
              try @string.parse_double(trim(element_text(vel))) catch {
                _ => ()
              } noraise {
                d => literal_values.push(d)
              }
            }
          }
        }
      }
    }
  }
  { data_range, anchor_cell, literal_values }
}

///|
/// Decode one `<x14:colorXxx rgb="HEXVAL" theme="N" tint="F"/>`.
fn decode_color(color_elt : @xml.Element) -> SparklineColor {
  let hex = find_attr(color_elt, "rgb")
  let theme = match find_attr(color_elt, "theme") {
    Some(value) =>
      try @string.parse_int(value) catch {
        _ => None
      } noraise {
        n => Some(n)
      }
    None => None
  }
  let tint = match find_attr(color_elt, "tint") {
    Some(value) =>
      try @string.parse_double(value) catch {
        _ => None
      } noraise {
        d => Some(d)
      }
    None => None
  }
  { hex, theme, tint }
}

// =============================================================================
// Local helpers — namespace-aware element / attribute lookup.
// =============================================================================

///|
/// `true` when `el`'s namespace URI matches `x14_ns()`. Falls back
/// to prefix match (`x14:`) when no resolved URI is attached — the
/// XML parser only synthesises a URI when the document declares a
/// matching `xmlns:x14`, so some fixture-time trees that build the
/// element by local-prefix-only still hit the fallback.
fn is_x14(el : @xml.Element) -> Bool {
  match el.name.ns {
    Some(uri) => uri == x14_ns()
    None =>
      match el.name.prefix {
        Some(p) => p == "x14"
        None => false
      }
  }
}

///|
/// `true` when `el` is in the x14 namespace AND its local name
/// matches `name`.
fn is_x14_named(el : @xml.Element, name : String) -> Bool {
  is_x14(el) && el.name.local_name == name
}

///|
/// Look up an attribute by local name, ignoring namespace.
fn find_attr(el : @xml.Element, name : String) -> String? {
  for attribute in el.attributes {
    if attribute.name.local_name == name {
      return Some(attribute.value)
    }
  }
  None
}

///|
/// `true | 1 | TRUE` → `true`; everything else → `false` (per
/// xsd:boolean's lexical space, with the OOXML convention that
/// missing attributes are `false`).
fn bool_attr(el : @xml.Element, name : String) -> Bool {
  match find_attr(el, name) {
    Some("1") | Some("true") | Some("TRUE") | Some("True") => true
    _ => false
  }
}

///|
/// Concatenate every `Text` / `CData` child into a single string.
/// Element children are ignored — the x14 schema only uses text
/// content for `<xm:f>` / `<xm:sqref>` (no mixed content).
fn element_text(el : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for node in el.children {
    match node {
      @xml.Node::Text(s) => buf.write_string(s)
      @xml.Node::CData(s) => buf.write_string(s)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// Split `s` at the first occurrence of `sep` (single ASCII char).
/// Returns `None` when `sep` is absent.
fn split_once(s : String, sep : Char) -> (String, String)? {
  let mut i = 0
  while i < s.length() {
    if s.code_unit_at(i).to_int() == sep.to_int() {
      let left = s.unsafe_substring(start=0, end=i)
      let right = s.unsafe_substring(start=i + 1, end=s.length())
      return Some((left, right))
    }
    i = i + 1
  }
  None
}

///|
/// Split `s` on every occurrence of single-char `sep`.
fn split_all(s : String, sep : Char) -> Array[String] {
  let out : Array[String] = []
  let mut start = 0
  let mut i = 0
  while i < s.length() {
    if s.code_unit_at(i).to_int() == sep.to_int() {
      out.push(s.unsafe_substring(start~, end=i))
      start = i + 1
    }
    i = i + 1
  }
  out.push(s.unsafe_substring(start~, end=s.length()))
  out
}

///|
/// Strip ASCII whitespace from both ends.
fn trim(s : String) -> String {
  let mut a = 0
  let mut b = s.length()
  while a < b {
    let c = s.code_unit_at(a)
    if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
      a = a + 1
    } else {
      break
    }
  }
  while b > a {
    let c = s.code_unit_at(b - 1)
    if c == ' ' || c == '\t' || c == '\n' || c == '\r' {
      b = b - 1
    } else {
      break
    }
  }
  s.unsafe_substring(start=a, end=b)
}
