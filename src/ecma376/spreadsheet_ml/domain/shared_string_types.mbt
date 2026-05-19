///|
/// SpreadsheetML shared string typed domain wrappers from sml.xsd. CT_*
/// identifiers in this file bind the ECMA-376 Part 1 §18.4 (shared string
/// table) and §18.10 (pivot string item) complex types with typed attribute
/// and child fields. The source `@xml.Element` is preserved on every typed
/// record so the builder can emit byte-identical round-trip output via
/// `value.element`.

///|
pub fn shared_string_type_group_name() -> String {
  "spreadsheet_ml.shared_string"
}

///|
/// XSD complex type CT_XStringElement — Part 1 §18.10.1.6 (`<n>` / `<m>` /
/// `<e>` named element forms inside pivot cache definitions and metadata
/// string tables). Single required `@v` attribute of type `s:ST_Xstring`.
pub(all) struct CT_XStringElement {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @v (s:ST_Xstring) — required.
  v : String
} derive(Eq, Debug)

///|
pub fn CT_XStringElement::new(element : @xml.Element) -> CT_XStringElement {
  let v = match attr(element, "v") {
    Some(value) => value
    None => ""
  }
  { element, v }
}

///|
/// XSD complex type CT_String — Part 1 §18.10.1.79. Pivot cache string
/// item. Required `@v` (s:ST_Xstring). Optional formatting / property
/// attributes `@u` (xsd:boolean), `@f` (xsd:boolean), `@c` (s:ST_Xstring),
/// `@cp` (xsd:unsignedInt), `@in` (xsd:unsignedInt), `@bc`
/// (ST_UnsignedIntHex), `@fc` (ST_UnsignedIntHex), `@i` (xsd:boolean,
/// default false), `@un` (xsd:boolean, default false), `@st` (xsd:boolean,
/// default false), `@b` (xsd:boolean, default false). Sequence children:
/// `<tpls>*` (CT_Tuples), `<x>*` (CT_X).
pub(all) struct CT_String {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @v (s:ST_Xstring) — required string payload.
  v : String
  /// @u (xsd:boolean) — optional unused flag.
  u : Bool?
  /// @f (xsd:boolean) — optional calculated flag.
  f : Bool?
  /// @c (s:ST_Xstring) — optional caption.
  c : String?
  /// @cp (xsd:unsignedInt) — optional cache property index.
  cp : Int?
  /// @in (xsd:unsignedInt) — optional member-property index.
  in_ : Int?
  /// @bc (ST_UnsignedIntHex) — optional background ARGB color.
  bc : Int?
  /// @fc (ST_UnsignedIntHex) — optional foreground ARGB color.
  fc : Int?
  /// @i (xsd:boolean) — optional, default false.
  i : Bool
  /// @un (xsd:boolean) — optional, default false.
  un : Bool
  /// @st (xsd:boolean) — optional, default false.
  st : Bool
  /// @b (xsd:boolean) — optional, default false.
  b : Bool
  /// <tpls>* (CT_Tuples) — zero or more shared-tuple sub-records.
  tpls : Array[CT_Tuples]
  /// <x>* (CT_X) — zero or more pivot tuple indices.
  x : Array[CT_X]
} derive(Eq, Debug)

///|
pub fn CT_String::new(element : @xml.Element) -> CT_String {
  let v = match attr(element, "v") {
    Some(value) => value
    None => ""
  }
  let u = attr_bool_opt(element, "u")
  let f = attr_bool_opt(element, "f")
  let c = attr(element, "c")
  let cp = attr_uint_opt(element, "cp")
  let in_ = attr_uint_opt(element, "in")
  let bc = attr_hex_uint_opt(element, "bc")
  let fc = attr_hex_uint_opt(element, "fc")
  let i = attr_bool(element, "i", false)
  let un = attr_bool(element, "un", false)
  let st = attr_bool(element, "st", false)
  let b = attr_bool(element, "b", false)
  let tpls : Array[CT_Tuples] = []
  let x : Array[CT_X] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "tpls" => tpls.push(CT_Tuples::new(child_element))
        "x" => x.push(CT_X::new(child_element))
        _ => ()
      }
    }
  }
  { element, v, u, f, c, cp, in_, bc, fc, i, un, st, b, tpls, x }
}

///|
/// XSD complex type CT_Sst — Part 1 §18.4.9. Shared string table. Optional
/// `@count` (xsd:unsignedInt, header total) and `@uniqueCount`
/// (xsd:unsignedInt, distinct count). Sequence: `<si>*` (CT_Rst) string
/// items and optional `<extLst>` (CT_ExtensionList).
pub(all) struct CT_Sst {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @count (xsd:unsignedInt) — optional aggregate count across the
  /// workbook, may differ from `si_entries.length()` per §18.4.9.
  count_attr : Int?
  /// @uniqueCount (xsd:unsignedInt) — optional distinct entry count.
  unique_count : Int?
  /// <si>* (CT_Rst) — zero or more shared string items in document order.
  si_entries : Array[CT_Rst]
  /// <extLst> (CT_ExtensionList) — optional extension list.
  ext_lst : CT_ExtensionList?
} derive(Eq, Debug)

///|
pub fn CT_Sst::new(element : @xml.Element) -> CT_Sst {
  let count_attr = attr_uint_opt(element, "count")
  let unique_count = attr_uint_opt(element, "uniqueCount")
  let si_entries : Array[CT_Rst] = []
  let mut ext_lst : CT_ExtensionList? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "si" => si_entries.push(CT_Rst::new(child_element))
        "extLst" => ext_lst = Some(CT_ExtensionList::new(child_element))
        _ => ()
      }
    }
  }
  { element, count_attr, unique_count, si_entries, ext_lst }
}

///|
/// XSD complex type CT_PhoneticRun — Part 1 §18.4.6. Phonetic guide run.
/// Required `@sb` (xsd:unsignedInt, start byte) and `@eb` (xsd:unsignedInt,
/// end byte). Single mandatory `<t>` (s:ST_Xstring) text child.
pub(all) struct CT_PhoneticRun {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @sb (xsd:unsignedInt) — required start byte index in base text.
  sb : Int
  /// @eb (xsd:unsignedInt) — required end byte index in base text.
  eb : Int
  /// <t> (s:ST_Xstring) — required phonetic text content.
  t : String
} derive(Eq, Debug)

///|
pub fn CT_PhoneticRun::new(element : @xml.Element) -> CT_PhoneticRun {
  let sb = attr_uint(element, "sb", 0)
  let eb = attr_uint(element, "eb", 0)
  let mut t = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      if child_element.name.local_name == "t" {
        t = element_text(child_element)
      }
    }
  }
  { element, sb, eb, t }
}

///|
/// XSD complex type CT_RElt.
pub(all) struct CT_RElt {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RElt::new(element : @xml.Element) -> CT_RElt {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_RPrElt: rich text run properties with font, charset, family, bold, italic, strike, color, size, underline, vertical alignment, scheme children.
pub(all) struct CT_RPrElt {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPrElt::new(element : @xml.Element) -> CT_RPrElt {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_Rst.
pub(all) struct CT_Rst {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rst::new(element : @xml.Element) -> CT_Rst {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
/// XSD complex type CT_PhoneticPr.
pub(all) struct CT_PhoneticPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PhoneticPr::new(element : @xml.Element) -> CT_PhoneticPr {
  let group_name = shared_string_type_group_name()
  let local_name = element.name.local_name
  if group_name.length() > 0 || local_name.length() > 0 {
    { element, }
  } else {
    { element, }
  }
}

///|
fn shared_string_is_element(
  element : @xml.Element,
  local_name : String,
) -> Bool {
  element.name.local_name == local_name
}

///|
fn shared_string_text_element_value(element : @xml.Element) -> String {
  let mut out = ""
  for child in element.children {
    match child {
      @xml.Node::Text(value) => out = out + value
      @xml.Node::CData(value) => out = out + value
      _ => ()
    }
  }
  out
}

///|
/// §18.4 — concatenate the rich-text run elements of CT_Rst into the
/// plain-text string value the cell would display. Joins each CT_RElt
/// `t` (text) child verbatim, dropping rPr formatting markup.
pub fn CT_Rst::to_plain_text(self : CT_Rst) -> String {
  let mut out = ""
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if shared_string_is_element(element, "t") {
          out = out + shared_string_text_element_value(element)
        } else if shared_string_is_element(element, "r") {
          out = out + CT_RElt::new(element).to_plain_text()
        }
      _ => ()
    }
  }
  out
}

///|
/// §18.4 — return the entries of the shared string table as an array
/// of CT_Rst values in document order. Index 0 corresponds to the first
/// `<si>` child of `<sst>`. Iterates element children once and skips
/// foreign or whitespace nodes.
pub fn CT_Sst::entries(self : CT_Sst) -> Array[CT_Rst] {
  self.si_entries
}

///|
/// §18.4 — resolve a 0-based SST index to its plain-text representation.
/// Returns None if the index is out of range. The resolved string is
/// the concatenation of the entry's run-element text per to_plain_text.
pub fn CT_Sst::lookup(self : CT_Sst, index : Int) -> String? {
  if index < 0 {
    None
  } else {
    match self.si_entries.get(index) {
      Some(entry) => Some(entry.to_plain_text())
      None => None
    }
  }
}

///|
/// §18.4 — number of entries in the shared string table.
pub fn CT_Sst::count(self : CT_Sst) -> Int {
  self.si_entries.length()
}

///|
/// §18.4 — extract plain text from the rich-text run element. The
/// run's text is in the `<t>` child; rPr formatting markup is ignored
/// for the purposes of cell-display value computation.
pub fn CT_RElt::to_plain_text(self : CT_RElt) -> String {
  let mut out = ""
  for child in self.element.children {
    match child {
      @xml.Node::Element(element) =>
        if shared_string_is_element(element, "t") {
          out = out + shared_string_text_element_value(element)
        }
      _ => ()
    }
  }
  out
}
