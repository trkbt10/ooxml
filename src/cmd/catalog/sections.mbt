// ECMA-376 specification-section coverage.
//
// The unit of coverage here is the ECMA-376 *specification section*
// (Part 1-4, 569 sections total), not the XSD element.  For every
// section this:
//   1. reads the section's prose (.md) text,
//   2. extracts the element names the section defines — the spec
//      writes "the <name> element (§x.y.z)" wherever it introduces
//      one,
//   3. cross-references each name against the catalog round-trip /
//      render result.
//
// A section is `covered` when it defines at least one element and
// every element it defines is verified `ok`; `partial` when some but
// not all are ok; `prose-only` when it defines no elements (a
// conformance / scope / overview section); `uncovered` otherwise.

///|
/// The Part directories under references/spec, in order.
fn spec_parts() -> Array[String] {
  ["part1", "part2", "part3", "part4"]
}

///|
/// Extract the element names a section's prose defines.  The ECMA-376
/// text introduces an element with the phrase
/// `the <name> element (§<section>)`; this scans for that pattern and
/// returns the distinct `<name>` tokens.
fn extract_section_elements(text : String) -> Array[String] {
  let found : Map[String, Bool] = Map::new()
  let needle = " element (\u{00A7}"
  // The spec uses the section-sign U+00A7; also tolerate a plain
  // "(§" rendered without it.
  let chars = text
  let n = chars.length()
  let mut i = 0
  while i < n {
    // Find the phrase " element (§".
    match find_at(chars, " element (", i) {
      None => break
      Some(pos) => {
        // The element name is the word immediately before " element".
        // Walk back over the name characters from `pos`.
        let mut start = pos
        while start > 0 && is_name_char(chars.code_unit_at(start - 1).to_int()) {
          start = start - 1
        }
        if start < pos {
          let name = chars[start:pos].to_string()
          // Reject the generic words the phrase also produces
          // ("this element", "an element", "child element", ...).
          if is_plausible_element(name) {
            found[name] = true
          }
        }
        i = pos + 9
      }
    }
  }
  let _ = needle
  let out : Array[String] = []
  for k, _v in found {
    out.push(k)
  }
  out
}

///|
/// Index of the first occurrence of `needle` in `s` at or after
/// `from`, or None.
fn find_at(s : String, needle : String, from : Int) -> Int? {
  let sn = s.length()
  let nn = needle.length()
  if nn == 0 {
    return Some(from)
  }
  let mut i = from
  while i + nn <= sn {
    let mut j = 0
    while j < nn && s.code_unit_at(i + j) == needle.code_unit_at(j) {
      j = j + 1
    }
    if j == nn {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
/// True for a character that may appear in an OOXML element name.
fn is_name_char(cu : Int) -> Bool {
  (cu >= 0x41 && cu <= 0x5A) ||
  (cu >= 0x61 && cu <= 0x7A) ||
  (cu >= 0x30 && cu <= 0x39) ||
  cu == 0x2D ||
  cu == 0x5F
}

///|
/// Reject the generic English words the "X element" phrase also
/// matches — only an actual element-name token is plausible.
fn is_plausible_element(name : String) -> Bool {
  if name.length() == 0 {
    return false
  }
  match name {
    "this"
    | "an"
    | "the"
    | "child"
    | "parent"
    | "root"
    | "current"
    | "same"
    | "single"
    | "one"
    | "each"
    | "any"
    | "no"
    | "that"
    | "given"
    | "first"
    | "last"
    | "next"
    | "previous"
    | "new"
    | "empty"
    | "containing"
    | "specified"
    | "appropriate"
    | "its"
    | "a"
    | "corresponding"
    | "following"
    | "preceding" => false
    _ => true
  }
}

///|
/// One Part's section-coverage tally.  Two coverage dimensions are
/// tracked side by side:
///
///   * round-trip — every element the section defines opens, round
///     trips and renders without crashing (the achievable 網羅
///     measure: the library handles the element).
///   * render — every element the section defines additionally left
///     a traced effect in the rendered SVG (the strict measure).
///
/// `prose_only` sections define no element (scope / conformance /
/// overview text) and are excluded from both denominators.
struct PartCoverage {
  part : String
  sections : Int
  prose_only : Int
  // round-trip dimension.
  rt_covered : Int
  rt_partial : Int
  rt_uncovered : Int
  // render dimension.
  rn_covered : Int
  rn_partial : Int
  rn_uncovered : Int
}

///|
/// Analyse every spec section and report coverage against the
/// catalog.  `element_rendered` maps an element name to true when a
/// catalog entry for it left a traced effect in the SVG;
/// `element_parsed` maps it to true when a catalog entry opened and
/// round-tripped without crashing.  `element_known` is the set of
/// every element name the ECMA-376 XSD declares — a prose token that
/// is not a known element name (a generic English word, a spec-text
/// typo) is noise and is excluded, so a section is judged only on the
/// real elements it defines.
fn analyse_sections(
  element_rendered : Map[String, Bool],
  element_parsed : Map[String, Bool],
  element_known : Map[String, Bool],
) -> Array[PartCoverage] {
  let parts : Array[PartCoverage] = []
  for part in spec_parts() {
    let dir = "references/spec/" + part + "/sections"
    let files = match (try? @fs.read_dir(dir)) {
      Ok(fs) => fs
      Err(_) => []
    }
    let mut rt_covered = 0
    let mut rt_partial = 0
    let mut rt_uncov = 0
    let mut rn_covered = 0
    let mut rn_partial = 0
    let mut rn_uncov = 0
    let mut prose = 0
    let mut total = 0
    for fname in files {
      if !fname.has_suffix(".md") {
        continue
      }
      total = total + 1
      let text = match (try? @fs.read_file_to_string(dir + "/" + fname)) {
        Ok(t) => t
        Err(_) => ""
      }
      // Keep only tokens that are genuine ECMA-376 XSD element
      // names; prose words / spec typos are discarded.
      let raw = extract_section_elements(text)
      let elements : Array[String] = []
      for el in raw {
        if element_known.get(el) is Some(true) {
          elements.push(el)
        }
      }
      if elements.length() == 0 {
        prose = prose + 1
        continue
      }
      // Tally the section against both coverage dimensions.
      let mut rt_all = true
      let mut rt_any = false
      let mut rn_all = true
      let mut rn_any = false
      let rt_missing : Array[String] = []
      let rn_missing : Array[String] = []
      for el in elements {
        if element_parsed.get(el) is Some(true) {
          rt_any = true
        } else {
          rt_all = false
          rt_missing.push(el)
        }
        if element_rendered.get(el) is Some(true) {
          rn_any = true
        } else {
          rn_all = false
          rn_missing.push(el)
        }
      }
      if rt_all {
        rt_covered = rt_covered + 1
      } else if rt_any {
        rt_partial = rt_partial + 1
      } else {
        rt_uncov = rt_uncov + 1
      }
      if rn_all {
        rn_covered = rn_covered + 1
      } else if rn_any {
        rn_partial = rn_partial + 1
      } else {
        rn_uncov = rn_uncov + 1
      }
      // A round-trip gap is a genuine defect — report it loudly.  A
      // render-only gap is reported quietly (many section elements
      // are non-visual config / metadata with nothing to render).
      if !rt_all {
        println(
          "    [rt-gap]  \{part}/\{fname} — missing: " + rt_missing.join(", "),
        )
      } else if !rn_all {
        println(
          "    [rn-gap]  \{part}/\{fname} — render-missing: " +
          rn_missing.join(", "),
        )
      }
    }
    parts.push({
      part,
      sections: total,
      prose_only: prose,
      rt_covered,
      rt_partial,
      rt_uncovered: rt_uncov,
      rn_covered,
      rn_partial,
      rn_uncovered: rn_uncov,
    })
  }
  parts
}
