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
/// XSD simple type ST_TextScaleDecimal from transitional wml.xsd (Part 4 §14).
pub struct ST_TextScaleDecimal {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_TextScaleDecimal::parse(
  s : String,
) -> ST_TextScaleDecimal raise SchemaViolation {
  validate_wml_simple_type("ST_TextScaleDecimal", s)
  { value: s }
}

///|
pub fn ST_TextScaleDecimal::new(
  s : String,
) -> ST_TextScaleDecimal raise SchemaViolation {
  ST_TextScaleDecimal::parse(s)
}

///|
pub fn ST_TextScaleDecimal::to_string(self : ST_TextScaleDecimal) -> String {
  self.value
}

///|
/// XSD simple type ST_UnqualifiedPercentage from transitional wml.xsd (Part 4 §14).
pub struct ST_UnqualifiedPercentage {
  value : String
} derive(Eq, Debug)

///|
pub fn ST_UnqualifiedPercentage::parse(
  s : String,
) -> ST_UnqualifiedPercentage raise SchemaViolation {
  validate_wml_simple_type("ST_UnqualifiedPercentage", s)
  { value: s }
}

///|
pub fn ST_UnqualifiedPercentage::new(
  s : String,
) -> ST_UnqualifiedPercentage raise SchemaViolation {
  ST_UnqualifiedPercentage::parse(s)
}

///|
pub fn ST_UnqualifiedPercentage::to_string(
  self : ST_UnqualifiedPercentage,
) -> String {
  self.value
}

///|
/// XSD complex type CT_HMerge from transitional wml.xsd (Part 4 §14).
pub(all) struct CT_HMerge {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HMerge::new(element : @xml.Element) -> CT_HMerge {
  { element, }
}

///|
pub fn CT_HMerge::parse(element : @xml.Element) -> CT_HMerge {
  CT_HMerge::new(element)
}

///|
pub fn CT_HMerge::to_element(self : CT_HMerge) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LvlLegacy from transitional wml.xsd (Part 4 §14).
pub(all) struct CT_LvlLegacy {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LvlLegacy::new(element : @xml.Element) -> CT_LvlLegacy {
  { element, }
}

///|
pub fn CT_LvlLegacy::parse(element : @xml.Element) -> CT_LvlLegacy {
  CT_LvlLegacy::new(element)
}

///|
pub fn CT_LvlLegacy::to_element(self : CT_LvlLegacy) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Picture from transitional wml.xsd (Part 4 §14).
pub(all) struct CT_Picture {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Picture::new(element : @xml.Element) -> CT_Picture {
  { element, }
}

///|
pub fn CT_Picture::parse(element : @xml.Element) -> CT_Picture {
  CT_Picture::new(element)
}

///|
pub fn CT_Picture::to_element(self : CT_Picture) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ShapeDefaults from transitional wml.xsd (Part 4 §14).
pub(all) struct CT_ShapeDefaults {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeDefaults::new(element : @xml.Element) -> CT_ShapeDefaults {
  { element, }
}

///|
pub fn CT_ShapeDefaults::parse(element : @xml.Element) -> CT_ShapeDefaults {
  CT_ShapeDefaults::new(element)
}

///|
pub fn CT_ShapeDefaults::to_element(self : CT_ShapeDefaults) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangeNumbering from transitional wml.xsd (Part 4 §14).
pub(all) struct CT_TrackChangeNumbering {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChangeNumbering::new(
  element : @xml.Element,
) -> CT_TrackChangeNumbering {
  { element, }
}

///|
pub fn CT_TrackChangeNumbering::parse(
  element : @xml.Element,
) -> CT_TrackChangeNumbering {
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
pub fn txbx_content(element : @xml.Element) -> CT_TxbxContent {
  CT_TxbxContent::new(element)
}
