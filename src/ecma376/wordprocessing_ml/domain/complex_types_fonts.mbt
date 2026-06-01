///|
/// XSD complex type CT_Panose — Part 1 §17.8.2.13 (panose1 PANOSE-1
/// classification). Required `@val` is the ten-octet PANOSE-1 hex
/// string typed as s:ST_Panose (§22.9.2.8); kept as a `String` because
/// no typed ST_Panose wrapper has been generated.
pub(all) struct CT_Panose {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.8 @val (s:ST_Panose) — required ten-octet PANOSE-1 hex.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Panose — Part 1 §17.8.2.13. Decode the required
/// `@val` PANOSE-1 lexical token.
pub fn CT_Panose::new(
  element : @xml.Element,
) -> CT_Panose raise SchemaViolation {
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_Panose", "Part 1 §22.9.2.8 s:ST_Panose",
  )
  { element, val }
}

///|
/// XSD complex type CT_Panose — Part 1 §17.8.2.13.
pub fn CT_Panose::parse(
  element : @xml.Element,
) -> CT_Panose raise SchemaViolation {
  CT_Panose::new(element)
}

///|
pub fn CT_Panose::to_element(self : CT_Panose) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontFamily — Part 1 §17.8.2.5 (family Font
/// Family). Required `@val` (ST_FontFamily §17.18.30) selects one of
/// `decorative / modern / roman / script / swiss / auto`.
pub(all) struct CT_FontFamily {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.30 @val (ST_FontFamily) — required family classification.
  val : ST_FontFamily
} derive(Eq, Debug)

///|
/// XSD complex type CT_FontFamily — Part 1 §17.8.2.5. Decode the
/// required `@val` ST_FontFamily token.
pub fn CT_FontFamily::new(
  element : @xml.Element,
) -> CT_FontFamily raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_FontFamily", "Part 1 §17.18.30 ST_FontFamily",
  )
  let val = ST_FontFamily::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_FontFamily — Part 1 §17.8.2.5.
pub fn CT_FontFamily::parse(
  element : @xml.Element,
) -> CT_FontFamily raise SchemaViolation {
  CT_FontFamily::new(element)
}

///|
pub fn CT_FontFamily::to_element(self : CT_FontFamily) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Pitch — Part 1 §17.8.2.18 (pitch Font Pitch).
/// Required `@val` (ST_Pitch §17.18.69) selects `fixed / variable /
/// default`.
pub(all) struct CT_Pitch {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.69 @val (ST_Pitch) — required pitch classification.
  val : ST_Pitch
} derive(Eq, Debug)

///|
/// XSD complex type CT_Pitch — Part 1 §17.8.2.18. Decode the required
/// `@val` ST_Pitch token.
pub fn CT_Pitch::new(element : @xml.Element) -> CT_Pitch raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_Pitch", "Part 1 §17.18.69 ST_Pitch",
  )
  let val = ST_Pitch::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_Pitch — Part 1 §17.8.2.18.
pub fn CT_Pitch::parse(
  element : @xml.Element,
) -> CT_Pitch raise SchemaViolation {
  CT_Pitch::new(element)
}

///|
pub fn CT_Pitch::to_element(self : CT_Pitch) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontSig — Part 1 §17.8.2.20 (sig Font / Script
/// Signature). Six required eight-hex-digit Unicode subset / code-page
/// bit fields, each typed as ST_LongHexNumber (§17.18.50).
pub(all) struct CT_FontSig {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.50 @usb0 (ST_LongHexNumber) — required low Unicode subset bits 0.
  usb0 : ST_LongHexNumber
  /// §17.18.50 @usb1 (ST_LongHexNumber) — required low Unicode subset bits 1.
  usb1 : ST_LongHexNumber
  /// §17.18.50 @usb2 (ST_LongHexNumber) — required low Unicode subset bits 2.
  usb2 : ST_LongHexNumber
  /// §17.18.50 @usb3 (ST_LongHexNumber) — required low Unicode subset bits 3.
  usb3 : ST_LongHexNumber
  /// §17.18.50 @csb0 (ST_LongHexNumber) — required code-page support bits 0.
  csb0 : ST_LongHexNumber
  /// §17.18.50 @csb1 (ST_LongHexNumber) — required code-page support bits 1.
  csb1 : ST_LongHexNumber
} derive(Eq, Debug)

///|
/// XSD complex type CT_FontSig — Part 1 §17.8.2.20. Decode each of the
/// six required ST_LongHexNumber attributes, raising SchemaViolation if
/// any is missing or malformed.
pub fn CT_FontSig::new(
  element : @xml.Element,
) -> CT_FontSig raise SchemaViolation {
  let raw_usb0 = wml_ct_chunk1_required_attr(
    element, "usb0", "CT_FontSig", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let raw_usb1 = wml_ct_chunk1_required_attr(
    element, "usb1", "CT_FontSig", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let raw_usb2 = wml_ct_chunk1_required_attr(
    element, "usb2", "CT_FontSig", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let raw_usb3 = wml_ct_chunk1_required_attr(
    element, "usb3", "CT_FontSig", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let raw_csb0 = wml_ct_chunk1_required_attr(
    element, "csb0", "CT_FontSig", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let raw_csb1 = wml_ct_chunk1_required_attr(
    element, "csb1", "CT_FontSig", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let usb0 = ST_LongHexNumber::parse(raw_usb0)
  let usb1 = ST_LongHexNumber::parse(raw_usb1)
  let usb2 = ST_LongHexNumber::parse(raw_usb2)
  let usb3 = ST_LongHexNumber::parse(raw_usb3)
  let csb0 = ST_LongHexNumber::parse(raw_csb0)
  let csb1 = ST_LongHexNumber::parse(raw_csb1)
  { element, usb0, usb1, usb2, usb3, csb0, csb1 }
}

///|
/// XSD complex type CT_FontSig — Part 1 §17.8.2.20.
pub fn CT_FontSig::parse(
  element : @xml.Element,
) -> CT_FontSig raise SchemaViolation {
  CT_FontSig::new(element)
}

///|
pub fn CT_FontSig::to_element(self : CT_FontSig) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontRel — Part 1 §17.8.2.4 (embedRegular /
/// embedBold / embedItalic / embedBoldItalic Embedded Font). Extends
/// CT_Rel (required `@r:id` relationship reference) with optional
/// `@fontKey` (s:ST_Guid §22.9.2.3) and `@subsetted` (s:ST_OnOff
/// §22.9.2.7).
pub(all) struct CT_FontRel {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §A.1 @r:id (ST_RelationshipId) — required relationship reference inherited
  /// from CT_Rel.
  r_id : String
  /// §22.9.2.3 @fontKey (s:ST_Guid) — optional embedded-font GUID key.
  font_key : String?
  /// §22.9.2.7 @subsetted (s:ST_OnOff) — optional subset-only flag.
  subsetted : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FontRel — Part 1 §17.8.2.4. Decode the required
/// `@r:id` (inherited from CT_Rel) and the two optional attributes.
pub fn CT_FontRel::new(
  element : @xml.Element,
) -> CT_FontRel raise SchemaViolation {
  let r_id = wml_ct_chunk1_required_relationship_attr(
    element, "id", "CT_FontRel", "Part 1 §A.1 r:id (ST_RelationshipId)",
  )
  let font_key = wml_ct_chunk1_attr(element, "fontKey")
  let subsetted = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "subsetted"))
  { element, r_id, font_key, subsetted }
}

///|
/// XSD complex type CT_FontRel — Part 1 §17.8.2.4.
pub fn CT_FontRel::parse(
  element : @xml.Element,
) -> CT_FontRel raise SchemaViolation {
  CT_FontRel::new(element)
}

///|
pub fn CT_FontRel::to_element(self : CT_FontRel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Font — Part 1 §17.8.2.10 (font Properties for a
/// Single Font). Required `@name` (s:ST_String) carries the primary
/// font name; eleven optional descriptor children describe alternate
/// name (CT_String), PANOSE-1 (CT_Panose), character set (CT_Charset
/// §17.8.2.3), family (CT_FontFamily), not-TrueType flag (CT_OnOff),
/// pitch (CT_Pitch), Unicode/script signature (CT_FontSig) and the
/// four embedded-font relationships (CT_FontRel) for regular, bold,
/// italic and bold-italic faces.
pub(all) struct CT_Font {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — required font name.
  name : String
  /// §17.8.2.1 `<w:altName>` (CT_String) — optional alternate name.
  alt_name : CT_String?
  /// §17.8.2.13 `<w:panose1>` (CT_Panose) — optional PANOSE-1 classification.
  panose1 : CT_Panose?
  /// §17.8.2.3 `<w:charset>` (CT_Charset) — optional character set descriptor.
  charset : CT_Charset?
  /// §17.8.2.5 `<w:family>` (CT_FontFamily) — optional family classification.
  family : CT_FontFamily?
  /// §17.8.2.14 `<w:notTrueType>` (CT_OnOff) — optional raster-only flag.
  not_true_type : CT_OnOff?
  /// §17.8.2.18 `<w:pitch>` (CT_Pitch) — optional pitch classification.
  pitch : CT_Pitch?
  /// §17.8.2.20 `<w:sig>` (CT_FontSig) — optional Unicode/script signature.
  sig : CT_FontSig?
  /// §17.8.2.4 `<w:embedRegular>` (CT_FontRel) — optional regular face embedding.
  embed_regular : CT_FontRel?
  /// §17.8.2.4 `<w:embedBold>` (CT_FontRel) — optional bold face embedding.
  embed_bold : CT_FontRel?
  /// §17.8.2.4 `<w:embedItalic>` (CT_FontRel) — optional italic face embedding.
  embed_italic : CT_FontRel?
  /// §17.8.2.4 `<w:embedBoldItalic>` (CT_FontRel) — optional bold-italic embedding.
  embed_bold_italic : CT_FontRel?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Font — Part 1 §17.8.2.10. Decode the required
/// `@name` attribute and every optional descriptor child, propagating
/// SchemaViolation from typed constructors.
pub fn CT_Font::new(element : @xml.Element) -> CT_Font raise SchemaViolation {
  let name = wml_ct_chunk1_required_attr(
    element, "name", "CT_Font", "Part 1 §22.9.2.13 s:ST_String",
  )
  let alt_name = match wml_ct_chunk2_first_child(element, "altName") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let panose1 = match wml_ct_chunk2_first_child(element, "panose1") {
    Some(child) => Some(CT_Panose::new(child))
    None => None
  }
  let charset = match wml_ct_chunk2_first_child(element, "charset") {
    Some(child) => Some(CT_Charset::new(child))
    None => None
  }
  let family = match wml_ct_chunk2_first_child(element, "family") {
    Some(child) => Some(CT_FontFamily::new(child))
    None => None
  }
  let not_true_type = match wml_ct_chunk2_first_child(element, "notTrueType") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let pitch = match wml_ct_chunk2_first_child(element, "pitch") {
    Some(child) => Some(CT_Pitch::new(child))
    None => None
  }
  let sig = match wml_ct_chunk2_first_child(element, "sig") {
    Some(child) => Some(CT_FontSig::new(child))
    None => None
  }
  let embed_regular = match wml_ct_chunk2_first_child(element, "embedRegular") {
    Some(child) => Some(CT_FontRel::new(child))
    None => None
  }
  let embed_bold = match wml_ct_chunk2_first_child(element, "embedBold") {
    Some(child) => Some(CT_FontRel::new(child))
    None => None
  }
  let embed_italic = match wml_ct_chunk2_first_child(element, "embedItalic") {
    Some(child) => Some(CT_FontRel::new(child))
    None => None
  }
  let embed_bold_italic = match
    wml_ct_chunk2_first_child(element, "embedBoldItalic") {
    Some(child) => Some(CT_FontRel::new(child))
    None => None
  }
  {
    element,
    name,
    alt_name,
    panose1,
    charset,
    family,
    not_true_type,
    pitch,
    sig,
    embed_regular,
    embed_bold,
    embed_italic,
    embed_bold_italic,
  }
}

///|
/// XSD complex type CT_Font — Part 1 §17.8.2.10.
pub fn CT_Font::parse(element : @xml.Element) -> CT_Font raise SchemaViolation {
  CT_Font::new(element)
}

///|
pub fn CT_Font::to_element(self : CT_Font) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FontsList — Part 1 §17.8.2.11 (fonts Font Table
/// Root Element). Sequence container holding zero-or-more `<w:font>`
/// children (CT_Font per §17.8.2.10).
pub(all) struct CT_FontsList {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.8.2.10 `<w:font>` (CT_Font)* — font-table entries.
  fonts : Array[CT_Font]
} derive(Eq, Debug)

///|
/// XSD complex type CT_FontsList — Part 1 §17.8.2.11. Decode each
/// `<w:font>` child, propagating SchemaViolation from the typed
/// CT_Font constructor.
pub fn CT_FontsList::new(
  element : @xml.Element,
) -> CT_FontsList raise SchemaViolation {
  let fonts : Array[CT_Font] = []
  for child in wml_ct_chunk2_children(element, "font") {
    fonts.push(CT_Font::new(child))
  }
  { element, fonts }
}

///|
/// XSD complex type CT_FontsList — Part 1 §17.8.2.11.
pub fn CT_FontsList::parse(
  element : @xml.Element,
) -> CT_FontsList raise SchemaViolation {
  CT_FontsList::new(element)
}

///|
pub fn CT_FontsList::to_element(self : CT_FontsList) -> @xml.Element {
  self.element
}
