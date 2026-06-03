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
/// Schema sml.xsd complex type `CT_String`. Attributes: `v`, `u`, `f`,
/// `c`, `cp`, `in`, `bc`, `fc`, `i`, `un`, `st`, `b`. Child elements:
/// `tpls`, `x`. Child types: `CT_Tuples`, `CT_X`.
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
pub fn CT_String::new(
  element : @xml.Element,
) -> CT_String raise @opc_errors.SchemaViolation {
  let v = match attr(element, "v") {
    Some(value) => value
    None => ""
  }
  let u = attr_bool_schema_opt(element, "u", "Part 1 §18.10.1.79", "s")
  let f = attr_bool_schema_opt(element, "f", "Part 1 §18.10.1.79", "s")
  let c = attr(element, "c")
  let cp = attr_uint_opt(element, "cp")
  let in_ = attr_uint_opt(element, "in")
  let bc = attr_hex_uint_opt(element, "bc")
  let fc = attr_hex_uint_opt(element, "fc")
  let i = attr_bool_schema(element, "i", false, "Part 1 §18.10.1.79", "s")
  let un = attr_bool_schema(element, "un", false, "Part 1 §18.10.1.79", "s")
  let st = attr_bool_schema(element, "st", false, "Part 1 §18.10.1.79", "s")
  let b = attr_bool_schema(element, "b", false, "Part 1 §18.10.1.79", "s")
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
/// XSD complex type CT_RElt — Part 1 §18.4.4 (`<r>` Rich Text Run). A
/// rich-text run carries an optional `<rPr>` (CT_RPrElt) formatting block
/// followed by a required `<t>` (s:ST_Xstring) text payload.
/// Schema sml.xsd complex type `CT_RElt`. Child elements: `rPr`, `t`.
/// Child types: `CT_RPrElt`, `s:ST_Xstring`.
pub(all) struct CT_RElt {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <rPr> (CT_RPrElt) — optional run-property formatting block.
  r_pr : CT_RPrElt?
  /// <t> (s:ST_Xstring) — required text content.
  t : String
} derive(Eq, Debug)

///|
pub fn CT_RElt::new(element : @xml.Element) -> CT_RElt {
  let mut r_pr : CT_RPrElt? = None
  let mut t : String = ""
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "rPr" => r_pr = Some(CT_RPrElt::new(child_element))
        "t" => t = element_text(child_element)
        _ => ()
      }
    }
  }
  { element, r_pr, t }
}

///|
/// XSD complex type CT_RPrElt — Part 1 §18.4.7 (`<rPr>` Run Properties).
/// Unbounded choice of font / formatting child elements. Each variant
/// records zero or more occurrences (the XSD permits repetition under
/// `<xsd:choice maxOccurs="unbounded">`) so we preserve every observed
/// child in a per-name array. Per the XSD, all child elements are
/// optional within the choice.
pub(all) struct CT_RPrElt {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <rFont>* (CT_FontName) — zero or more rFont entries.
  r_font : Array[CT_FontName]
  /// <charset>* (CT_IntProperty) — zero or more charset entries.
  charset : Array[CT_IntProperty]
  /// <family>* (CT_IntProperty) — zero or more family entries.
  family : Array[CT_IntProperty]
  /// <b>* (CT_BooleanProperty) — zero or more bold entries.
  b : Array[CT_BooleanProperty]
  /// <i>* (CT_BooleanProperty) — zero or more italic entries.
  i : Array[CT_BooleanProperty]
  /// <strike>* (CT_BooleanProperty) — zero or more strike entries.
  strike : Array[CT_BooleanProperty]
  /// <outline>* (CT_BooleanProperty) — zero or more outline entries.
  outline : Array[CT_BooleanProperty]
  /// <shadow>* (CT_BooleanProperty) — zero or more shadow entries.
  shadow : Array[CT_BooleanProperty]
  /// <condense>* (CT_BooleanProperty) — zero or more condense entries.
  condense : Array[CT_BooleanProperty]
  /// <extend>* (CT_BooleanProperty) — zero or more extend entries.
  extend : Array[CT_BooleanProperty]
  /// <color>* (CT_Color) — zero or more color entries.
  color : Array[CT_Color]
  /// <sz>* (CT_FontSize) — zero or more size entries.
  sz : Array[CT_FontSize]
  /// <u>* (CT_UnderlineProperty) — zero or more underline entries.
  u : Array[CT_UnderlineProperty]
  /// <vertAlign>* (CT_VerticalAlignFontProperty) — zero or more vertical
  /// alignment entries.
  vert_align : Array[CT_VerticalAlignFontProperty]
  /// <scheme>* (CT_FontScheme) — zero or more scheme entries.
  scheme : Array[CT_FontScheme]
} derive(Eq, Debug)

///|
pub fn CT_RPrElt::new(element : @xml.Element) -> CT_RPrElt {
  let r_font : Array[CT_FontName] = []
  let charset : Array[CT_IntProperty] = []
  let family : Array[CT_IntProperty] = []
  let b : Array[CT_BooleanProperty] = []
  let i : Array[CT_BooleanProperty] = []
  let strike : Array[CT_BooleanProperty] = []
  let outline : Array[CT_BooleanProperty] = []
  let shadow : Array[CT_BooleanProperty] = []
  let condense : Array[CT_BooleanProperty] = []
  let extend : Array[CT_BooleanProperty] = []
  let color : Array[CT_Color] = []
  let sz : Array[CT_FontSize] = []
  let u : Array[CT_UnderlineProperty] = []
  let vert_align : Array[CT_VerticalAlignFontProperty] = []
  let scheme : Array[CT_FontScheme] = []
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "rFont" => r_font.push(CT_FontName::new(child_element))
        "charset" => charset.push(CT_IntProperty::new(child_element))
        "family" => family.push(CT_IntProperty::new(child_element))
        "b" => b.push(CT_BooleanProperty::new(child_element))
        "i" => i.push(CT_BooleanProperty::new(child_element))
        "strike" => strike.push(CT_BooleanProperty::new(child_element))
        "outline" => outline.push(CT_BooleanProperty::new(child_element))
        "shadow" => shadow.push(CT_BooleanProperty::new(child_element))
        "condense" => condense.push(CT_BooleanProperty::new(child_element))
        "extend" => extend.push(CT_BooleanProperty::new(child_element))
        "color" => color.push(CT_Color::new(child_element))
        "sz" => sz.push(CT_FontSize::new(child_element))
        "u" => u.push(CT_UnderlineProperty::new(child_element))
        "vertAlign" =>
          vert_align.push(CT_VerticalAlignFontProperty::new(child_element))
        "scheme" => scheme.push(CT_FontScheme::new(child_element))
        _ => ()
      }
    }
  }
  {
    element,
    r_font,
    charset,
    family,
    b,
    i,
    strike,
    outline,
    shadow,
    condense,
    extend,
    color,
    sz,
    u,
    vert_align,
    scheme,
  }
}

///|
/// XSD complex type CT_Rst — Part 1 §18.4.8 (`<si>` String Item). A
/// shared-string-table entry. Sequence children: optional `<t>` plain
/// text payload, an unbounded list of `<r>` rich-text runs (CT_RElt),
/// an unbounded list of `<rPh>` phonetic runs (CT_PhoneticRun), and an
/// optional `<phoneticPr>` (CT_PhoneticPr) phonetic-property block.
pub(all) struct CT_Rst {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// <t> (s:ST_Xstring) — optional plain-text payload.
  t : String?
  /// <r>* (CT_RElt) — zero or more rich-text runs.
  r : Array[CT_RElt]
  /// <rPh>* (CT_PhoneticRun) — zero or more phonetic runs.
  r_ph : Array[CT_PhoneticRun]
  /// <phoneticPr> (CT_PhoneticPr) — optional phonetic-property block.
  phonetic_pr : CT_PhoneticPr?
} derive(Eq, Debug)

///|
pub fn CT_Rst::new(element : @xml.Element) -> CT_Rst {
  let mut t : String? = None
  let r : Array[CT_RElt] = []
  let r_ph : Array[CT_PhoneticRun] = []
  let mut phonetic_pr : CT_PhoneticPr? = None
  for child in element.children {
    if child is @xml.Node::Element(child_element) {
      match child_element.name.local_name {
        "t" => t = Some(element_text(child_element))
        "r" => r.push(CT_RElt::new(child_element))
        "rPh" => r_ph.push(CT_PhoneticRun::new(child_element))
        "phoneticPr" => phonetic_pr = Some(CT_PhoneticPr::new(child_element))
        _ => ()
      }
    }
  }
  { element, t, r, r_ph, phonetic_pr }
}

///|
/// XSD complex type CT_PhoneticPr — Part 1 §18.4.3 (`<phoneticPr>`).
/// Attribute-only complex type that records phonetic-text rendering
/// preferences. Required `@fontId` (ST_FontId, font-table reference);
/// optional `@type` (ST_PhoneticType, default `fullwidthKatakana`) and
/// `@alignment` (ST_PhoneticAlignment, default `left`).
pub(all) struct CT_PhoneticPr {
  /// Preserve source XML element for byte-identical round-trip.
  element : @xml.Element
  /// @fontId (ST_FontId / xsd:unsignedInt) — required font-table reference.
  font_id : Int
  /// @type (ST_PhoneticType) — optional rendering style; default
  /// `fullwidthKatakana` per the XSD.
  type_ : String
  /// @alignment (ST_PhoneticAlignment) — optional alignment; default
  /// `left` per the XSD.
  alignment : String
} derive(Eq, Debug)

///|
pub fn CT_PhoneticPr::new(element : @xml.Element) -> CT_PhoneticPr {
  let font_id = attr_uint(element, "fontId", 0)
  let type_ = match attr(element, "type") {
    Some(value) => value
    None => "fullwidthKatakana"
  }
  let alignment = match attr(element, "alignment") {
    Some(value) => value
    None => "left"
  }
  { element, font_id, type_, alignment }
}

///|
/// §18.4 — concatenate the rich-text run elements of CT_Rst into the
/// plain-text string value the cell would display. Uses the typed `<t>`
/// payload when present, otherwise walks the typed `<r>` rich-text run
/// array and concatenates each CT_RElt's text content; `<rPr>` formatting
/// markup is intentionally dropped.
pub fn CT_Rst::to_plain_text(self : CT_Rst) -> String {
  let mut out = ""
  match self.t {
    Some(text) => out = out + text
    None => ()
  }
  for run in self.r {
    out = out + run.to_plain_text()
  }
  out
}

///|
/// §18.4.6 — concatenate the phonetic-guide (`<rPh>`) runs of a
/// CT_Rst into a single furigana string in document order.
/// Returns the empty string when the entry carries no phonetic
/// runs.  Consumers render this as ruby text above the base
/// `to_plain_text()` value.
pub fn CT_Rst::phonetic_text(self : CT_Rst) -> String {
  let mut out = ""
  for run in self.r_ph {
    out = out + run.t
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
/// §18.4 — extract plain text from the rich-text run element. The run's
/// typed `<t>` text payload is returned verbatim. The `<rPr>` formatting
/// block is ignored for the purposes of cell-display value computation.
pub fn CT_RElt::to_plain_text(self : CT_RElt) -> String {
  self.t
}
