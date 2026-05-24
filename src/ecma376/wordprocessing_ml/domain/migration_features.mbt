///|
/// XSD simple type ST_Cnf — Part 4 §14.11.9.
/// Restriction of xsd:string with length = 12 and pattern `[01]*`,
/// encoding twelve boolean conditional-formatting flags (firstRow,
/// lastRow, firstColumn, lastColumn, band1Vert, band2Vert,
/// band1Horz, band2Horz, NE cell, NW cell, SE cell, SW cell). The
/// typed representation stores the bitmask as an Int (12 bits ≤ Int)
/// with bit 0 = firstRow (reading the lexical string right-to-left,
/// as the spec defines).
pub struct ST_Cnf {
  bitmask : Int
} derive(Eq, Debug)

///|
/// The exact bit-count required by the Part 4 §14.11.9 lexical
/// pattern.
pub let cnf_bit_count : Int = 12

///|
/// Parse the ST_Cnf schema lexical value into the typed 12-bit
/// bitmask.
pub fn ST_Cnf::parse(s : String) -> ST_Cnf raise SchemaViolation {
  if s.length() != cnf_bit_count {
    raise_schema_violation("ST_Cnf", s, "lexical value must have length 12")
  }
  let mut bitmask = 0
  // Per Part 4 §14.11.9: "reading from the first character position
  // right" — character 0 is the lowest-order property (firstRow).
  for i = 0; i < cnf_bit_count; i = i + 1 {
    let ch = s[i:i + 1]
    if ch == "1" {
      bitmask = bitmask + (1 << i)
    } else if ch != "0" {
      raise_schema_violation(
        "ST_Cnf", s, "lexical value must match pattern [01]{12}",
      )
    }
  }
  { bitmask, }
}

///|
/// Construct ST_Cnf while enforcing the length-12 `[01]*` pattern.
pub fn ST_Cnf::new(s : String) -> ST_Cnf raise SchemaViolation {
  ST_Cnf::parse(s)
}

///|
/// Read the typed 12-bit bitmask. Bit 0 corresponds to the leftmost
/// character of the lexical form (the firstRow flag).
pub fn ST_Cnf::bitmask(self : ST_Cnf) -> Int {
  self.bitmask
}

///|
/// True iff the conditional-formatting bit at `index` is set
/// (`0 ≤ index < 12`). Out-of-range indices return false.
pub fn ST_Cnf::bit(self : ST_Cnf, index : Int) -> Bool {
  if index < 0 || index >= cnf_bit_count {
    false
  } else {
    ((self.bitmask >> index) & 1) == 1
  }
}

///|
/// Render the typed bitmask back to its canonical length-12 lexical
/// form (character 0 carries bit 0).
pub fn ST_Cnf::to_string(self : ST_Cnf) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < cnf_bit_count; i = i + 1 {
    if ((self.bitmask >> i) & 1) == 1 {
      buf.write_string("1")
    } else {
      buf.write_string("0")
    }
  }
  buf.to_string()
}

///|
/// XSD simple type ST_TextScaleDecimal — Part 4 §14.11.11.
/// Restriction of xsd:integer to 0..600 (text expansion/compression
/// percentage without the trailing `%` qualifier, a transitional addition).
pub struct ST_TextScaleDecimal {
  percent : Int
} derive(Eq, Debug)

///|
/// Parse the ST_TextScaleDecimal lexical value (integer 0..600).
pub fn ST_TextScaleDecimal::parse(
  s : String,
) -> ST_TextScaleDecimal raise SchemaViolation {
  let n = parse_signed_int_lexical("ST_TextScaleDecimal", s)
  if n < 0 || n > 600 {
    raise_schema_violation(
      "ST_TextScaleDecimal", s, "percent outside 0..600 range",
    )
  }
  { percent: n }
}

///|
/// Construct ST_TextScaleDecimal while enforcing the transitional 0..600 range.
pub fn ST_TextScaleDecimal::new(
  s : String,
) -> ST_TextScaleDecimal raise SchemaViolation {
  ST_TextScaleDecimal::parse(s)
}

///|
/// Read the typed text-scale percentage integer (0..600).
pub fn ST_TextScaleDecimal::value(self : ST_TextScaleDecimal) -> Int {
  self.percent
}

///|
/// Return the canonical lexical value for ST_TextScaleDecimal.
pub fn ST_TextScaleDecimal::to_string(self : ST_TextScaleDecimal) -> String {
  self.percent.to_string()
}

///|
/// XSD simple type ST_UnqualifiedPercentage — Part 4 §14.11.10.
/// Restriction of xsd:integer (a transitional percentage value without the
/// `%` sign; CT_TblWidth uses 50ths-of-a-percent, other contexts use whole
/// percentage points — see spec).
pub struct ST_UnqualifiedPercentage {
  value : Int
} derive(Eq, Debug)

///|
/// Parse the ST_UnqualifiedPercentage lexical value (signed integer).
pub fn ST_UnqualifiedPercentage::parse(
  s : String,
) -> ST_UnqualifiedPercentage raise SchemaViolation {
  let n = parse_signed_int_lexical("ST_UnqualifiedPercentage", s)
  { value: n }
}

///|
/// Construct ST_UnqualifiedPercentage while enforcing the xsd:integer
/// lexical form.
pub fn ST_UnqualifiedPercentage::new(
  s : String,
) -> ST_UnqualifiedPercentage raise SchemaViolation {
  ST_UnqualifiedPercentage::parse(s)
}

///|
/// Read the typed transitional percentage integer.
pub fn ST_UnqualifiedPercentage::value(self : ST_UnqualifiedPercentage) -> Int {
  self.value
}

///|
/// Return the canonical lexical value for ST_UnqualifiedPercentage.
pub fn ST_UnqualifiedPercentage::to_string(
  self : ST_UnqualifiedPercentage,
) -> String {
  self.value.to_string()
}

///|
/// XSD complex type CT_HMerge — Part 4 §14 transitional wml.xsd (hMerge
/// Horizontally Merged Cell). Single optional `@val` (ST_Merge §17.18.57)
/// selects `continue` (joins with the hMerge-restart to the left) or
/// `restart` (opens a new horizontal-merge sequence).
pub(all) struct CT_HMerge {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.57 @val (ST_Merge) — optional continue/restart selector.
  val : ST_Merge?
} derive(Eq, Debug)

///|
pub fn CT_HMerge::new(
  element : @xml.Element,
) -> CT_HMerge raise SchemaViolation {
  let val = match wml_ct_chunk4_attr(element, "val") {
    Some(text) => Some(ST_Merge::parse(text))
    None => None
  }
  { element, val }
}

///|
pub fn CT_HMerge::parse(
  element : @xml.Element,
) -> CT_HMerge raise SchemaViolation {
  CT_HMerge::new(element)
}

///|
pub fn CT_HMerge::to_element(self : CT_HMerge) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LvlLegacy — Part 4 §14 transitional wml.xsd
/// (lvlLegacy Legacy Numbering Level Properties). Three optional
/// attributes:
///   `@legacy`       (s:ST_OnOff §22.9.2.7) — emulate legacy numbering;
///   `@legacySpace`  (s:ST_TwipsMeasure §22.9.2.10) — twentieths-of-a-
///                   point gap preserved lexically;
///   `@legacyIndent` (ST_SignedTwipsMeasure §17.18.81) — signed indent.
pub(all) struct CT_LvlLegacy {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @legacy (s:ST_OnOff) — optional legacy-emulation flag.
  legacy : Bool?
  /// §22.9.2.10 @legacySpace (s:ST_TwipsMeasure) — optional legacy gap.
  legacy_space : String?
  /// §17.18.81 @legacyIndent (ST_SignedTwipsMeasure) — optional legacy indent.
  legacy_indent : ST_SignedTwipsMeasure?
} derive(Eq, Debug)

///|
pub fn CT_LvlLegacy::new(
  element : @xml.Element,
) -> CT_LvlLegacy raise SchemaViolation {
  let legacy = wml_ct_chunk4_on_off(wml_ct_chunk4_attr(element, "legacy"))
  let legacy_space = wml_ct_chunk4_attr(element, "legacySpace")
  let legacy_indent = match wml_ct_chunk4_attr(element, "legacyIndent") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  { element, legacy, legacy_space, legacy_indent }
}

///|
pub fn CT_LvlLegacy::parse(
  element : @xml.Element,
) -> CT_LvlLegacy raise SchemaViolation {
  CT_LvlLegacy::new(element)
}

///|
pub fn CT_LvlLegacy::to_element(self : CT_LvlLegacy) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Picture — Part 4 §14 transitional wml.xsd
/// (picture VML / OLE container under `<w:object>`). Sequence:
///   (any[vml] | any[office])* — typed VML shape-element children
///                                (vml-main + vml-officeDrawing +
///                                vml-wordprocessingDrawing arms);
///   `<movie>`?   (CT_Rel)     — optional movie relationship;
///   `<control>`? (CT_Control) — optional ActiveX control reference.
pub(all) struct CT_Picture {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// Typed VML / o: / w10: shape-element children in document order.
  any_legacy : Array[@vml.VmlShapeChild]
  /// §17.3.3.14 `<movie>`? — movie relationship.
  movie : CT_Rel?
  /// §17.3.3.4 `<control>`? — ActiveX control reference.
  control : CT_Control?
} derive(Eq, Debug)

///|
pub fn CT_Picture::new(
  element : @xml.Element,
) -> CT_Picture raise SchemaViolation {
  let any_legacy : Array[@vml.VmlShapeChild] = []
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        if ln != "movie" && ln != "control" {
          any_legacy.push(
            wrap_vml_violation(
              fn() { @vml.parse_vml_shape_child(e) },
              "CT_Picture/legacy",
            ),
          )
        }
      }
      _ => ()
    }
  }
  let movie = match wml_ct_chunk4_first_child(element, "movie") {
    Some(child) => Some(CT_Rel::new(child))
    None => None
  }
  let control = match wml_ct_chunk4_first_child(element, "control") {
    Some(child) => Some(CT_Control::new(child))
    None => None
  }
  { element, any_legacy, movie, control }
}

///|
/// Bridge `@vml.SchemaViolation` into our local WML SchemaViolation.
fn[T] wrap_vml_violation(
  body : () -> T raise @vml.SchemaViolation,
  path : String,
) -> T raise SchemaViolation {
  body() catch {
    @vml.SchemaViolation(schema=_, path=p, reason~) =>
      raise SchemaViolation(type_name=path, value=p, reason~)
  }
}

///|
pub fn CT_Picture::parse(
  element : @xml.Element,
) -> CT_Picture raise SchemaViolation {
  CT_Picture::new(element)
}

///|
pub fn CT_Picture::to_element(self : CT_Picture) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeDefaults — Part 4 §14 transitional wml.xsd
/// (shapeDefaults VML shape-defaults container). The schema content
/// is `xsd:choice maxOccurs="unbounded"` over `xsd:any` from the
/// `v:` and `o:` namespaces — projected to the typed
/// `@vml.VmlShapeChild` sum so every shape-element arm is preserved
/// with full validation.
pub(all) struct CT_ShapeDefaults {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// Typed VML / o: children in document order.
  any_office : Array[@vml.VmlShapeChild]
} derive(Eq, Debug)

///|
pub fn CT_ShapeDefaults::new(
  element : @xml.Element,
) -> CT_ShapeDefaults raise SchemaViolation {
  let any_office : Array[@vml.VmlShapeChild] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        any_office.push(
          wrap_vml_violation(
            fn() { @vml.parse_vml_shape_child(e) },
            "CT_ShapeDefaults",
          ),
        )
      _ => ()
    }
  }
  { element, any_office }
}

///|
pub fn CT_ShapeDefaults::parse(
  element : @xml.Element,
) -> CT_ShapeDefaults raise SchemaViolation {
  CT_ShapeDefaults::new(element)
}

///|
pub fn CT_ShapeDefaults::to_element(self : CT_ShapeDefaults) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangeNumbering — Part 4 §14 transitional
/// wml.xsd (numberingChange Previous Numbering Field Properties).
/// Extends CT_TrackChange (id required, author required, date optional)
/// with an optional `@original` (s:ST_String §22.9.2.13) preserving the
/// pre-revision numbering lexical form.
pub(all) struct CT_TrackChangeNumbering {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// §22.9.2.13 @original (s:ST_String) — optional pre-revision numbering.
  original : String?
} derive(Eq, Debug)

///|
pub fn CT_TrackChangeNumbering::new(
  element : @xml.Element,
) -> CT_TrackChangeNumbering raise SchemaViolation {
  let raw_id = wml_ct_chunk4_required_attr(
    element, "id", "CT_TrackChangeNumbering", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk4_required_attr(
    element, "author", "CT_TrackChangeNumbering", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk4_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let original = wml_ct_chunk4_attr(element, "original")
  { element, id, author, date, original }
}

///|
pub fn CT_TrackChangeNumbering::parse(
  element : @xml.Element,
) -> CT_TrackChangeNumbering raise SchemaViolation {
  CT_TrackChangeNumbering::new(element)
}

///|
pub fn CT_TrackChangeNumbering::to_element(
  self : CT_TrackChangeNumbering,
) -> @xml.Element {
  self.element
}

///|
/// XSD attribute group AG_TransitionalPassword from transitional wml.xsd (Part 4 §14).
pub(all) struct AG_TransitionalPassword {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_TransitionalPassword::new(
  element : @xml.Element,
) -> AG_TransitionalPassword {
  { element, }
}

///|
pub fn AG_TransitionalPassword::attribute_names(
  self : AG_TransitionalPassword,
) -> Array[String] {
  let names = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
pub fn AG_TransitionalPassword::has_attribute(
  self : AG_TransitionalPassword,
  local_name : String,
) -> Bool {
  let mut found = false
  for attribute in self.element.attributes {
    if attribute.name.local_name == local_name {
      found = true
    }
  }
  found
}

///|
/// Construct top-level transitional wml.xsd element txbxContent as CT_TxbxContent (Part 4 §14).
pub fn txbx_content(
  element : @xml.Element,
) -> CT_TxbxContent raise SchemaViolation {
  CT_TxbxContent::new(element)
}
