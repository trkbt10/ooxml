// WordprocessingML chunk1 typed complex types — wml.xsd §17 shared CT_*
// wrappers that previously held only `element : @xml.Element` are
// re-projected here as typed views of every XSD attribute and child
// element listed in the schema. The source `<w:...>` element is kept
// alongside the typed fields so the builder can round-trip unchanged
// markup, but the typed fields are now the source-of-truth for
// schema-aware callers.

///|
/// XSD complex type CT_Empty — Part 1 §A.1 (wml.xsd). The empty complex
/// type carries neither attributes nor children, so its only spec-
/// typed information is the QName of the element it backs (see
/// §17.17.4 prose for typical usage as a flag element). The QName is
/// captured up-front so callers can switch on the source element
/// without re-walking the preserved XML.
pub(all) struct CT_Empty {
  /// §A.1 — qualified name of the source element. CT_Empty backs many
  /// distinct `<w:.../>` flags; the QName is the only spec-derived
  /// information available because the type itself has no content.
  name : @xml.QName
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Empty — Part 1 §A.1. The empty complex type
/// admits no attributes and no children, so the constructor records
/// the QName and preserves the source element.
pub fn CT_Empty::new(element : @xml.Element) -> CT_Empty {
  { name: element.name, element }
}

///|
/// XSD complex type CT_Empty — Part 1 §A.1. Decoding is total because
/// no schema content has to be validated.
pub fn CT_Empty::parse(element : @xml.Element) -> CT_Empty {
  CT_Empty::new(element)
}

///|
/// XSD complex type CT_Empty — return the preserved element for
/// writers.
pub fn CT_Empty::to_element(self : CT_Empty) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_OnOff — Part 1 §17.17.4 Boolean Property. The
/// shared boolean-flag complex type used throughout WordprocessingML
/// for elements such as `<w:b/>`, `<w:i/>`, `<w:keepLines/>`. The
/// optional `@val` is an ST_OnOff token (§22.9.2.7) decoded as a
/// typed bool with `true` as the spec-default when the attribute is
/// omitted.
pub(all) struct CT_OnOff {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.4 @val (ST_OnOff). `None` means the attribute was omitted;
  /// the spec default for that case is the property being applied
  /// (`true`).
  val : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_OnOff — Part 1 §17.17.4. Decode the optional
/// ST_OnOff `@val` attribute and preserve the source element.
pub fn CT_OnOff::new(element : @xml.Element) -> CT_OnOff {
  let val = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "val"))
  { element, val }
}

///|
/// XSD complex type CT_OnOff — Part 1 §17.17.4. Schema-validating
/// decoder; the parse function is total because every ST_OnOff
/// lexical token (including `0/1/on/off/true/false`) is admissible
/// per §22.9.2.7 and unknown spellings are tolerated by writers.
pub fn CT_OnOff::parse(element : @xml.Element) -> CT_OnOff {
  CT_OnOff::new(element)
}

///|
/// XSD complex type CT_OnOff — return the preserved element for
/// writers.
pub fn CT_OnOff::to_element(self : CT_OnOff) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LongHexNumber — Part 1 §A.1, simple type
/// ST_LongHexNumber documented at §17.18.50. Carries a required
/// eight-hex-digit `@val` attribute used by settings/numbering rsid
/// records.
pub(all) struct CT_LongHexNumber {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.50 @val (ST_LongHexNumber) — eight hex digits, required.
  val : ST_LongHexNumber
} derive(Eq, Debug)

///|
/// XSD complex type CT_LongHexNumber — Part 1 §17.18.50. Decode the
/// required eight-hex-digit `@val` attribute.
pub fn CT_LongHexNumber::new(
  element : @xml.Element,
) -> CT_LongHexNumber raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_LongHexNumber", "Part 1 §17.18.50 ST_LongHexNumber",
  )
  let val = ST_LongHexNumber::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_LongHexNumber — Part 1 §17.18.50. Equivalent to
/// `new` for spec-strict decoding.
pub fn CT_LongHexNumber::parse(
  element : @xml.Element,
) -> CT_LongHexNumber raise SchemaViolation {
  CT_LongHexNumber::new(element)
}

///|
/// XSD complex type CT_LongHexNumber — return the preserved element
/// for writers.
pub fn CT_LongHexNumber::to_element(self : CT_LongHexNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Charset — Part 1 §A.1, simple type
/// ST_UcharHexNumber documented at §17.18.98. Two optional
/// attributes: `@val` (one-octet hex code page, ST_UcharHexNumber)
/// and `@characterSet` (xsd:string, defaults to `"ISO-8859-1"`).
pub(all) struct CT_Charset {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.98 @val (ST_UcharHexNumber) — code-page octet, optional.
  val : ST_UcharHexNumber?
  /// §A.1 @characterSet (s:ST_String) — IANA charset, optional;
  /// `None` means the schema-default `ISO-8859-1` applies.
  character_set : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Charset — Part 1 §17.18.98. Decode the optional
/// `@val` and `@characterSet` attributes.
pub fn CT_Charset::new(
  element : @xml.Element,
) -> CT_Charset raise SchemaViolation {
  let val = match wml_ct_chunk1_attr(element, "val") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let character_set = wml_ct_chunk1_attr(element, "characterSet")
  { element, val, character_set }
}

///|
/// XSD complex type CT_Charset — Part 1 §17.18.98. Equivalent to
/// `new`.
pub fn CT_Charset::parse(
  element : @xml.Element,
) -> CT_Charset raise SchemaViolation {
  CT_Charset::new(element)
}

///|
/// XSD complex type CT_Charset — return the preserved element for
/// writers.
pub fn CT_Charset::to_element(self : CT_Charset) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DecimalNumber — Part 1 §A.1, simple type
/// ST_DecimalNumber documented at §17.18.10. Carries a required
/// xsd:integer `@val` used throughout WordprocessingML for typed
/// counter / id elements.
pub(all) struct CT_DecimalNumber {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @val (ST_DecimalNumber) — signed integer, required.
  val : ST_DecimalNumber
} derive(Eq, Debug)

///|
/// XSD complex type CT_DecimalNumber — Part 1 §17.18.10. Decode the
/// required xsd:integer `@val` attribute.
pub fn CT_DecimalNumber::new(
  element : @xml.Element,
) -> CT_DecimalNumber raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_DecimalNumber", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let val = ST_DecimalNumber::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_DecimalNumber — Part 1 §17.18.10.
pub fn CT_DecimalNumber::parse(
  element : @xml.Element,
) -> CT_DecimalNumber raise SchemaViolation {
  CT_DecimalNumber::new(element)
}

///|
/// XSD complex type CT_DecimalNumber — return the preserved element
/// for writers.
pub fn CT_DecimalNumber::to_element(self : CT_DecimalNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_UnsignedDecimalNumber — Part 1 §A.1, simple
/// type ST_UnsignedDecimalNumber documented in Part 1 §22.9.2.16. The
/// required `@val` is decoded as an `UInt64` so id / index attributes
/// keep their non-negative semantics.
pub(all) struct CT_UnsignedDecimalNumber {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.16 @val (s:ST_UnsignedDecimalNumber) — unsigned long, required.
  val : UInt64
} derive(Eq, Debug)

///|
/// XSD complex type CT_UnsignedDecimalNumber — Part 1 §22.9.2.16.
/// Decode the required unsigned-long `@val` attribute.
pub fn CT_UnsignedDecimalNumber::new(
  element : @xml.Element,
) -> CT_UnsignedDecimalNumber raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_UnsignedDecimalNumber", "Part 1 §22.9.2.16 ST_UnsignedDecimalNumber",
  )
  let val = wml_ct_chunk1_parse_uint64(
    raw, "CT_UnsignedDecimalNumber", "val", "Part 1 §22.9.2.16 ST_UnsignedDecimalNumber",
  )
  { element, val }
}

///|
/// XSD complex type CT_UnsignedDecimalNumber — Part 1 §22.9.2.16.
pub fn CT_UnsignedDecimalNumber::parse(
  element : @xml.Element,
) -> CT_UnsignedDecimalNumber raise SchemaViolation {
  CT_UnsignedDecimalNumber::new(element)
}

///|
/// XSD complex type CT_UnsignedDecimalNumber — return the preserved
/// element for writers.
pub fn CT_UnsignedDecimalNumber::to_element(
  self : CT_UnsignedDecimalNumber,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DecimalNumberOrPrecent — Part 1 §A.1; the typed
/// `@val` is the union ST_DecimalNumberOrPercent (Part 1 §17.18.11).
/// Note the misspelt schema name (`Precent`) is preserved verbatim per
/// wml.xsd. Used by §17.15.1.94 `zoom/@percent`.
pub(all) struct CT_DecimalNumberOrPrecent {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.11 @val (ST_DecimalNumberOrPercent) — integer or
  /// `N%` lexical form, required.
  val : ST_DecimalNumberOrPercent
} derive(Eq, Debug)

///|
/// XSD complex type CT_DecimalNumberOrPrecent — Part 1 §17.18.11.
pub fn CT_DecimalNumberOrPrecent::new(
  element : @xml.Element,
) -> CT_DecimalNumberOrPrecent raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_DecimalNumberOrPrecent", "Part 1 §17.18.11 ST_DecimalNumberOrPercent",
  )
  let val = ST_DecimalNumberOrPercent::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_DecimalNumberOrPrecent — Part 1 §17.18.11.
pub fn CT_DecimalNumberOrPrecent::parse(
  element : @xml.Element,
) -> CT_DecimalNumberOrPrecent raise SchemaViolation {
  CT_DecimalNumberOrPrecent::new(element)
}

///|
/// XSD complex type CT_DecimalNumberOrPrecent — return the preserved
/// element for writers.
pub fn CT_DecimalNumberOrPrecent::to_element(
  self : CT_DecimalNumberOrPrecent,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TwipsMeasure — Part 1 §A.1; the typed `@val` is
/// the union ST_TwipsMeasure (Part 1 §22.9.2.10). Stored as the raw
/// lexical form so callers can either treat the value as twentieths-
/// of-a-point or as a universal-measure literal.
pub(all) struct CT_TwipsMeasure {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @val (s:ST_TwipsMeasure) — required.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_TwipsMeasure — Part 1 §22.9.2.10. Decode the
/// required ST_TwipsMeasure `@val` attribute as its lexical form.
pub fn CT_TwipsMeasure::new(
  element : @xml.Element,
) -> CT_TwipsMeasure raise SchemaViolation {
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_TwipsMeasure", "Part 1 §22.9.2.10 ST_TwipsMeasure",
  )
  { element, val }
}

///|
/// XSD complex type CT_TwipsMeasure — Part 1 §22.9.2.10.
pub fn CT_TwipsMeasure::parse(
  element : @xml.Element,
) -> CT_TwipsMeasure raise SchemaViolation {
  CT_TwipsMeasure::new(element)
}

///|
/// XSD complex type CT_TwipsMeasure — return the preserved element
/// for writers.
pub fn CT_TwipsMeasure::to_element(self : CT_TwipsMeasure) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SignedTwipsMeasure — Part 1 §A.1; the typed
/// `@val` is the union ST_SignedTwipsMeasure (Part 1 §17.18.81). The
/// typed form preserves either the signed-twip integer branch or the
/// signed universal-measure branch.
pub(all) struct CT_SignedTwipsMeasure {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.81 @val (ST_SignedTwipsMeasure) — required.
  val : ST_SignedTwipsMeasure
} derive(Eq, Debug)

///|
/// XSD complex type CT_SignedTwipsMeasure — Part 1 §17.18.81.
pub fn CT_SignedTwipsMeasure::new(
  element : @xml.Element,
) -> CT_SignedTwipsMeasure raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_SignedTwipsMeasure", "Part 1 §17.18.81 ST_SignedTwipsMeasure",
  )
  let val = ST_SignedTwipsMeasure::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_SignedTwipsMeasure — Part 1 §17.18.81.
pub fn CT_SignedTwipsMeasure::parse(
  element : @xml.Element,
) -> CT_SignedTwipsMeasure raise SchemaViolation {
  CT_SignedTwipsMeasure::new(element)
}

///|
/// XSD complex type CT_SignedTwipsMeasure — return the preserved
/// element for writers.
pub fn CT_SignedTwipsMeasure::to_element(
  self : CT_SignedTwipsMeasure,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PixelsMeasure — Part 1 §A.1, simple type
/// ST_PixelsMeasure documented at §17.18.67. Required `@val` carries
/// the unsigned pixel count used by frame sizing
/// (§17.15.2.16 `frame/marW`, §17.15.2.17 `frame/marH`).
pub(all) struct CT_PixelsMeasure {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.67 @val (ST_PixelsMeasure) — pixel count, required.
  val : ST_PixelsMeasure
} derive(Eq, Debug)

///|
/// XSD complex type CT_PixelsMeasure — Part 1 §17.18.67.
pub fn CT_PixelsMeasure::new(
  element : @xml.Element,
) -> CT_PixelsMeasure raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_PixelsMeasure", "Part 1 §17.18.67 ST_PixelsMeasure",
  )
  let val = ST_PixelsMeasure::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_PixelsMeasure — Part 1 §17.18.67.
pub fn CT_PixelsMeasure::parse(
  element : @xml.Element,
) -> CT_PixelsMeasure raise SchemaViolation {
  CT_PixelsMeasure::new(element)
}

///|
/// XSD complex type CT_PixelsMeasure — return the preserved element
/// for writers.
pub fn CT_PixelsMeasure::to_element(self : CT_PixelsMeasure) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HpsMeasure — Part 1 §A.1; the typed `@val` is
/// the union ST_HpsMeasure (Part 1 §17.18.42). Used by run-font sizing
/// elements `<w:sz>` (§17.3.2.38) and `<w:szCs>` (§17.3.2.39).
pub(all) struct CT_HpsMeasure {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.42 @val (s:ST_HpsMeasure) — half-points, required.
  val : ST_HpsMeasure
} derive(Eq, Debug)

///|
/// XSD complex type CT_HpsMeasure — Part 1 §17.18.42.
pub fn CT_HpsMeasure::new(
  element : @xml.Element,
) -> CT_HpsMeasure raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_HpsMeasure", "Part 1 §17.18.42 ST_HpsMeasure",
  )
  let val = ST_HpsMeasure::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_HpsMeasure — Part 1 §17.18.42.
pub fn CT_HpsMeasure::parse(
  element : @xml.Element,
) -> CT_HpsMeasure raise SchemaViolation {
  CT_HpsMeasure::new(element)
}

///|
/// XSD complex type CT_HpsMeasure — return the preserved element for
/// writers.
pub fn CT_HpsMeasure::to_element(self : CT_HpsMeasure) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SignedHpsMeasure — Part 1 §A.1; the typed
/// `@val` is the union ST_SignedHpsMeasure (Part 1 §17.18.80). Used
/// by `<w:position>` (§17.3.2.24) which raises/lowers run text by a
/// signed half-point displacement.
pub(all) struct CT_SignedHpsMeasure {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.80 @val (ST_SignedHpsMeasure) — required.
  val : ST_SignedHpsMeasure
} derive(Eq, Debug)

///|
/// XSD complex type CT_SignedHpsMeasure — Part 1 §17.18.80.
pub fn CT_SignedHpsMeasure::new(
  element : @xml.Element,
) -> CT_SignedHpsMeasure raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_SignedHpsMeasure", "Part 1 §17.18.80 ST_SignedHpsMeasure",
  )
  let val = ST_SignedHpsMeasure::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_SignedHpsMeasure — Part 1 §17.18.80.
pub fn CT_SignedHpsMeasure::parse(
  element : @xml.Element,
) -> CT_SignedHpsMeasure raise SchemaViolation {
  CT_SignedHpsMeasure::new(element)
}

///|
/// XSD complex type CT_SignedHpsMeasure — return the preserved element
/// for writers.
pub fn CT_SignedHpsMeasure::to_element(
  self : CT_SignedHpsMeasure,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MacroName — Part 1 §A.1, simple type
/// ST_MacroName documented at §17.18.51. Carries a required
/// xsd:string `@val` length-limited to 33 characters; used by form-
/// field entry/exit macros (§17.16.10 `<w:entryMacro>`, §17.16.13
/// `<w:exitMacro>`).
pub(all) struct CT_MacroName {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.51 @val (ST_MacroName) — macro name, required.
  val : ST_MacroName
} derive(Eq, Debug)

///|
/// XSD complex type CT_MacroName — Part 1 §17.18.51.
pub fn CT_MacroName::new(
  element : @xml.Element,
) -> CT_MacroName raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_MacroName", "Part 1 §17.18.51 ST_MacroName",
  )
  let val = ST_MacroName::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MacroName — Part 1 §17.18.51.
pub fn CT_MacroName::parse(
  element : @xml.Element,
) -> CT_MacroName raise SchemaViolation {
  CT_MacroName::new(element)
}

///|
/// XSD complex type CT_MacroName — return the preserved element for
/// writers.
pub fn CT_MacroName::to_element(self : CT_MacroName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_String — Part 1 §A.1; the typed `@val` is
/// Part 1 §22.9.2.13 ST_String. The shared single-attribute string
/// carrier used by §17.7.4.17 `style/@styleId`-bearing children
/// (alias, basedOn, link, next, name, …) and many settings elements.
pub(all) struct CT_String {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @val (s:ST_String) — required string.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_String — Part 1 §22.9.2.13.
pub fn CT_String::new(
  element : @xml.Element,
) -> CT_String raise SchemaViolation {
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_String", "Part 1 §22.9.2.13 ST_String",
  )
  { element, val }
}

///|
/// XSD complex type CT_String — Part 1 §22.9.2.13.
pub fn CT_String::parse(
  element : @xml.Element,
) -> CT_String raise SchemaViolation {
  CT_String::new(element)
}

///|
/// XSD complex type CT_String — return the preserved element for
/// writers.
pub fn CT_String::to_element(self : CT_String) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextScale — Part 1 §17.3.2.43 w (expanded /
/// compressed text). Optional `@val` carrying the
/// ST_TextScale union (Part 1 §17.18.95).
pub(all) struct CT_TextScale {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.95 @val (ST_TextScale) — optional percent or decimal.
  val : ST_TextScale?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextScale — Part 1 §17.18.95.
pub fn CT_TextScale::new(
  element : @xml.Element,
) -> CT_TextScale raise SchemaViolation {
  let val = match wml_ct_chunk1_attr(element, "val") {
    Some(text) => Some(ST_TextScale::parse(text))
    None => None
  }
  { element, val }
}

///|
/// XSD complex type CT_TextScale — Part 1 §17.18.95.
pub fn CT_TextScale::parse(
  element : @xml.Element,
) -> CT_TextScale raise SchemaViolation {
  CT_TextScale::new(element)
}

///|
/// XSD complex type CT_TextScale — return the preserved element for
/// writers.
pub fn CT_TextScale::to_element(self : CT_TextScale) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Highlight — Part 1 §17.3.2.15 highlight. The
/// required `@val` is one of the seventeen ST_HighlightColor tokens
/// (Part 1 §17.18.40).
pub(all) struct CT_Highlight {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.40 @val (ST_HighlightColor) — highlight swatch, required.
  val : ST_HighlightColor
} derive(Eq, Debug)

///|
/// XSD complex type CT_Highlight — Part 1 §17.18.40.
pub fn CT_Highlight::new(
  element : @xml.Element,
) -> CT_Highlight raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_Highlight", "Part 1 §17.18.40 ST_HighlightColor",
  )
  let val = ST_HighlightColor::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_Highlight — Part 1 §17.18.40.
pub fn CT_Highlight::parse(
  element : @xml.Element,
) -> CT_Highlight raise SchemaViolation {
  CT_Highlight::new(element)
}

///|
/// XSD complex type CT_Highlight — return the preserved element for
/// writers.
pub fn CT_Highlight::to_element(self : CT_Highlight) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Color — Part 1 §17.3.2.6 color (run content
/// colour). Required `@val` (ST_HexColor — §17.18.38) plus optional
/// theme tinting attributes (`@themeColor` ST_ThemeColor §17.18.97,
/// `@themeTint` / `@themeShade` ST_UcharHexNumber §17.18.98).
pub(all) struct CT_Color {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.38 @val (ST_HexColor) — RGB or `auto`, required.
  val : ST_HexColor
  /// §17.18.97 @themeColor (ST_ThemeColor) — optional theme override.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint (ST_UcharHexNumber) — optional brighten.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade (ST_UcharHexNumber) — optional darken.
  theme_shade : ST_UcharHexNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Color — Part 1 §17.3.2.6.
pub fn CT_Color::new(element : @xml.Element) -> CT_Color raise SchemaViolation {
  let raw_val = wml_ct_chunk1_required_attr(
    element, "val", "CT_Color", "Part 1 §17.18.38 ST_HexColor",
  )
  let val = ST_HexColor::parse(raw_val)
  let theme_color = match wml_ct_chunk1_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk1_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk1_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  { element, val, theme_color, theme_tint, theme_shade }
}

///|
/// XSD complex type CT_Color — Part 1 §17.3.2.6.
pub fn CT_Color::parse(
  element : @xml.Element,
) -> CT_Color raise SchemaViolation {
  CT_Color::new(element)
}

///|
/// XSD complex type CT_Color — return the preserved element for
/// writers.
pub fn CT_Color::to_element(self : CT_Color) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Lang — Part 1 §A.1; the typed `@val` is the
/// BCP-47 ST_Lang (Part 1 §22.9.2.6). Used by document-level
/// presentation language hints (§17.15.1.55 `themeFontLang/@val`).
pub(all) struct CT_Lang {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.6 @val (s:ST_Lang) — BCP-47 tag, required.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Lang — Part 1 §22.9.2.6.
pub fn CT_Lang::new(element : @xml.Element) -> CT_Lang raise SchemaViolation {
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_Lang", "Part 1 §22.9.2.6 ST_Lang",
  )
  { element, val }
}

///|
/// XSD complex type CT_Lang — Part 1 §22.9.2.6.
pub fn CT_Lang::parse(element : @xml.Element) -> CT_Lang raise SchemaViolation {
  CT_Lang::new(element)
}

///|
/// XSD complex type CT_Lang — return the preserved element for
/// writers.
pub fn CT_Lang::to_element(self : CT_Lang) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Guid — Part 1 §A.1; the typed `@val` is the
/// brace-delimited GUID ST_Guid (Part 1 §22.9.2.3). Optional per the
/// wml.xsd schema and used by `<w:nsid>` (§17.9.14) and similar
/// markers.
pub(all) struct CT_Guid {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.3 @val (s:ST_Guid) — optional GUID.
  val : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Guid — Part 1 §22.9.2.3.
pub fn CT_Guid::new(element : @xml.Element) -> CT_Guid {
  let val = wml_ct_chunk1_attr(element, "val")
  { element, val }
}

///|
/// XSD complex type CT_Guid — Part 1 §22.9.2.3.
pub fn CT_Guid::parse(element : @xml.Element) -> CT_Guid {
  CT_Guid::new(element)
}

///|
/// XSD complex type CT_Guid — return the preserved element for
/// writers.
pub fn CT_Guid::to_element(self : CT_Guid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Underline — Part 1 §17.3.2.40 u. Optional
/// `@val` ST_Underline (Part 1 §17.18.99); colour attributes (ST_HexColor
/// §17.18.38 — schema-default `auto`) and the trio of theme overrides
/// (`@themeColor`, `@themeTint`, `@themeShade`).
pub(all) struct CT_Underline {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.99 @val (ST_Underline) — optional underline pattern.
  val : ST_Underline?
  /// §17.18.38 @color (ST_HexColor) — optional; `None` ⇒ schema-default `auto`.
  color : ST_HexColor?
  /// §17.18.97 @themeColor (ST_ThemeColor) — optional.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint (ST_UcharHexNumber) — optional.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade (ST_UcharHexNumber) — optional.
  theme_shade : ST_UcharHexNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Underline — Part 1 §17.3.2.40.
pub fn CT_Underline::new(
  element : @xml.Element,
) -> CT_Underline raise SchemaViolation {
  let val = match wml_ct_chunk1_attr(element, "val") {
    Some(text) => Some(ST_Underline::parse(text))
    None => None
  }
  let color = match wml_ct_chunk1_attr(element, "color") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_color = match wml_ct_chunk1_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk1_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk1_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  { element, val, color, theme_color, theme_tint, theme_shade }
}

///|
/// XSD complex type CT_Underline — Part 1 §17.3.2.40.
pub fn CT_Underline::parse(
  element : @xml.Element,
) -> CT_Underline raise SchemaViolation {
  CT_Underline::new(element)
}

///|
/// XSD complex type CT_Underline — return the preserved element for
/// writers.
pub fn CT_Underline::to_element(self : CT_Underline) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextEffect — Part 1 §17.3.2.11 effect. Required
/// `@val` ST_TextEffect (Part 1 §17.18.94) — the legacy animated text
/// effect token.
pub(all) struct CT_TextEffect {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.94 @val (ST_TextEffect) — required animation token.
  val : ST_TextEffect
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextEffect — Part 1 §17.18.94.
pub fn CT_TextEffect::new(
  element : @xml.Element,
) -> CT_TextEffect raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_TextEffect", "Part 1 §17.18.94 ST_TextEffect",
  )
  let val = ST_TextEffect::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_TextEffect — Part 1 §17.18.94.
pub fn CT_TextEffect::parse(
  element : @xml.Element,
) -> CT_TextEffect raise SchemaViolation {
  CT_TextEffect::new(element)
}

///|
/// XSD complex type CT_TextEffect — return the preserved element for
/// writers.
pub fn CT_TextEffect::to_element(self : CT_TextEffect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Border — Part 1 §17.3.4 Border Properties.
/// Required `@val` (ST_Border §17.18.2) plus optional colour /
/// theme / sizing / spacing / shadow / frame attributes. The schema
/// defaults `@color` to `auto` and `@space` to `0` when omitted.
pub(all) struct CT_Border {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.2 @val (ST_Border) — required border style.
  val : ST_Border
  /// §17.18.38 @color (ST_HexColor) — optional; `None` ⇒ schema-default `auto`.
  color : ST_HexColor?
  /// §17.18.97 @themeColor (ST_ThemeColor) — optional.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint (ST_UcharHexNumber) — optional.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade (ST_UcharHexNumber) — optional.
  theme_shade : ST_UcharHexNumber?
  /// §17.18.23 @sz (ST_EighthPointMeasure) — optional width in eighths
  /// of a point.
  sz : ST_EighthPointMeasure?
  /// §17.18.68 @space (ST_PointMeasure) — optional spacing in points;
  /// `None` ⇒ schema-default `0`.
  space : ST_PointMeasure?
  /// §22.9.2.7 @shadow (s:ST_OnOff) — optional drop-shadow flag.
  shadow : Bool?
  /// §22.9.2.7 @frame (s:ST_OnOff) — optional frame-flag.
  frame : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Border — Part 1 §17.3.4.
pub fn CT_Border::new(
  element : @xml.Element,
) -> CT_Border raise SchemaViolation {
  let raw_val = wml_ct_chunk1_required_attr(
    element, "val", "CT_Border", "Part 1 §17.18.2 ST_Border",
  )
  let val = ST_Border::parse(raw_val)
  let color = match wml_ct_chunk1_attr(element, "color") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_color = match wml_ct_chunk1_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk1_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk1_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let sz = match wml_ct_chunk1_attr(element, "sz") {
    Some(text) => Some(ST_EighthPointMeasure::parse(text))
    None => None
  }
  let space = match wml_ct_chunk1_attr(element, "space") {
    Some(text) => Some(ST_PointMeasure::parse(text))
    None => None
  }
  let shadow = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "shadow"))
  let frame = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "frame"))
  {
    element,
    val,
    color,
    theme_color,
    theme_tint,
    theme_shade,
    sz,
    space,
    shadow,
    frame,
  }
}

///|
/// XSD complex type CT_Border — Part 1 §17.3.4.
pub fn CT_Border::parse(
  element : @xml.Element,
) -> CT_Border raise SchemaViolation {
  CT_Border::new(element)
}

///|
/// XSD complex type CT_Border — return the preserved element for
/// writers.
pub fn CT_Border::to_element(self : CT_Border) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Shd — Part 1 §17.3.5 Shading Properties.
/// Required `@val` (ST_Shd §17.18.78) plus optional foreground and
/// fill colour attributes with their theme overrides.
pub(all) struct CT_Shd {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.78 @val (ST_Shd) — shading pattern, required.
  val : ST_Shd
  /// §17.18.38 @color (ST_HexColor) — optional foreground colour.
  color : ST_HexColor?
  /// §17.18.97 @themeColor (ST_ThemeColor) — optional.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint (ST_UcharHexNumber) — optional.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade (ST_UcharHexNumber) — optional.
  theme_shade : ST_UcharHexNumber?
  /// §17.18.38 @fill (ST_HexColor) — optional background colour.
  fill : ST_HexColor?
  /// §17.18.97 @themeFill (ST_ThemeColor) — optional.
  theme_fill : ST_ThemeColor?
  /// §17.18.98 @themeFillTint (ST_UcharHexNumber) — optional.
  theme_fill_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeFillShade (ST_UcharHexNumber) — optional.
  theme_fill_shade : ST_UcharHexNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Shd — Part 1 §17.3.5.
pub fn CT_Shd::new(element : @xml.Element) -> CT_Shd raise SchemaViolation {
  let raw_val = wml_ct_chunk1_required_attr(
    element, "val", "CT_Shd", "Part 1 §17.18.78 ST_Shd",
  )
  let val = ST_Shd::parse(raw_val)
  let color = match wml_ct_chunk1_attr(element, "color") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_color = match wml_ct_chunk1_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk1_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk1_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let fill = match wml_ct_chunk1_attr(element, "fill") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_fill = match wml_ct_chunk1_attr(element, "themeFill") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_fill_tint = match wml_ct_chunk1_attr(element, "themeFillTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_fill_shade = match wml_ct_chunk1_attr(element, "themeFillShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  {
    element,
    val,
    color,
    theme_color,
    theme_tint,
    theme_shade,
    fill,
    theme_fill,
    theme_fill_tint,
    theme_fill_shade,
  }
}

///|
/// XSD complex type CT_Shd — Part 1 §17.3.5.
pub fn CT_Shd::parse(element : @xml.Element) -> CT_Shd raise SchemaViolation {
  CT_Shd::new(element)
}

///|
/// XSD complex type CT_Shd — return the preserved element for writers.
pub fn CT_Shd::to_element(self : CT_Shd) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_VerticalAlignRun — Part 1 §17.3.2.42 vertAlign.
/// Required `@val` ST_VerticalAlignRun (Part 1 §22.9.2.8) selecting
/// baseline / subscript / superscript text positioning.
pub(all) struct CT_VerticalAlignRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.8 @val (s:ST_VerticalAlignRun) — required token.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_VerticalAlignRun — Part 1 §22.9.2.8.
pub fn CT_VerticalAlignRun::new(
  element : @xml.Element,
) -> CT_VerticalAlignRun raise SchemaViolation {
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_VerticalAlignRun", "Part 1 §22.9.2.8 ST_VerticalAlignRun",
  )
  { element, val }
}

///|
/// XSD complex type CT_VerticalAlignRun — Part 1 §22.9.2.8.
pub fn CT_VerticalAlignRun::parse(
  element : @xml.Element,
) -> CT_VerticalAlignRun raise SchemaViolation {
  CT_VerticalAlignRun::new(element)
}

///|
/// XSD complex type CT_VerticalAlignRun — return the preserved element
/// for writers.
pub fn CT_VerticalAlignRun::to_element(
  self : CT_VerticalAlignRun,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FitText — Part 1 §17.3.2.14 fitText. Required
/// `@val` (s:ST_TwipsMeasure §22.9.2.10) sets the target width; the
/// optional `@id` (ST_DecimalNumber §17.18.10) groups multiple
/// fitText runs.
pub(all) struct CT_FitText {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @val (s:ST_TwipsMeasure) — required target width.
  val : String
  /// §17.18.10 @id (ST_DecimalNumber) — optional grouping identifier.
  id : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FitText — Part 1 §17.3.2.14.
pub fn CT_FitText::new(
  element : @xml.Element,
) -> CT_FitText raise SchemaViolation {
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_FitText", "Part 1 §22.9.2.10 ST_TwipsMeasure",
  )
  let id = match wml_ct_chunk1_attr(element, "id") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  { element, val, id }
}

///|
/// XSD complex type CT_FitText — Part 1 §17.3.2.14.
pub fn CT_FitText::parse(
  element : @xml.Element,
) -> CT_FitText raise SchemaViolation {
  CT_FitText::new(element)
}

///|
/// XSD complex type CT_FitText — return the preserved element for
/// writers.
pub fn CT_FitText::to_element(self : CT_FitText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Em — Part 1 §17.3.2.12 em (emphasis mark).
/// Required `@val` ST_Em (Part 1 §17.18.24) selecting the mark glyph.
pub(all) struct CT_Em {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.24 @val (ST_Em) — emphasis mark token, required.
  val : ST_Em
} derive(Eq, Debug)

///|
/// XSD complex type CT_Em — Part 1 §17.3.2.12.
pub fn CT_Em::new(element : @xml.Element) -> CT_Em raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_Em", "Part 1 §17.18.24 ST_Em",
  )
  let val = ST_Em::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_Em — Part 1 §17.3.2.12.
pub fn CT_Em::parse(element : @xml.Element) -> CT_Em raise SchemaViolation {
  CT_Em::new(element)
}

///|
/// XSD complex type CT_Em — return the preserved element for writers.
pub fn CT_Em::to_element(self : CT_Em) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Language — Part 1 §17.3.2.20 lang. Optional
/// `@val` (Latin-script BCP-47), `@eastAsia` (East Asian), and `@bidi`
/// (right-to-left) ST_Lang tokens. All three are §22.9.2.6.
pub(all) struct CT_Language {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.6 @val (s:ST_Lang) — Latin BCP-47 tag, optional.
  val : String?
  /// §22.9.2.6 @eastAsia (s:ST_Lang) — East Asian BCP-47 tag, optional.
  east_asia : String?
  /// §22.9.2.6 @bidi (s:ST_Lang) — Right-to-left BCP-47 tag, optional.
  bidi : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Language — Part 1 §17.3.2.20.
pub fn CT_Language::new(element : @xml.Element) -> CT_Language {
  let val = wml_ct_chunk1_attr(element, "val")
  let east_asia = wml_ct_chunk1_attr(element, "eastAsia")
  let bidi = wml_ct_chunk1_attr(element, "bidi")
  { element, val, east_asia, bidi }
}

///|
/// XSD complex type CT_Language — Part 1 §17.3.2.20.
pub fn CT_Language::parse(element : @xml.Element) -> CT_Language {
  CT_Language::new(element)
}

///|
/// XSD complex type CT_Language — return the preserved element for
/// writers.
pub fn CT_Language::to_element(self : CT_Language) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_EastAsianLayout — Part 1 §17.3.2.10
/// eastAsianLayout. Optional `@id` (ST_DecimalNumber §17.18.10),
/// `@combine` (s:ST_OnOff §22.9.2.7), `@combineBrackets`
/// (ST_CombineBrackets §17.18.7), `@vert` and `@vertCompress`
/// (s:ST_OnOff §22.9.2.7).
pub(all) struct CT_EastAsianLayout {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — optional combine-run identifier.
  id : ST_DecimalNumber?
  /// §22.9.2.7 @combine (s:ST_OnOff) — optional combine flag.
  combine : Bool?
  /// §17.18.7 @combineBrackets (ST_CombineBrackets) — optional
  /// enclosing bracket choice.
  combine_brackets : ST_CombineBrackets?
  /// §22.9.2.7 @vert (s:ST_OnOff) — optional vertical-text flag.
  vert : Bool?
  /// §22.9.2.7 @vertCompress (s:ST_OnOff) — optional half-width compress.
  vert_compress : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_EastAsianLayout — Part 1 §17.3.2.10.
pub fn CT_EastAsianLayout::new(
  element : @xml.Element,
) -> CT_EastAsianLayout raise SchemaViolation {
  let id = match wml_ct_chunk1_attr(element, "id") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let combine = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "combine"))
  let combine_brackets = match wml_ct_chunk1_attr(element, "combineBrackets") {
    Some(text) => Some(ST_CombineBrackets::parse(text))
    None => None
  }
  let vert = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "vert"))
  let vert_compress = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "vertCompress"),
  )
  { element, id, combine, combine_brackets, vert, vert_compress }
}

///|
/// XSD complex type CT_EastAsianLayout — Part 1 §17.3.2.10.
pub fn CT_EastAsianLayout::parse(
  element : @xml.Element,
) -> CT_EastAsianLayout raise SchemaViolation {
  CT_EastAsianLayout::new(element)
}

///|
/// XSD complex type CT_EastAsianLayout — return the preserved element
/// for writers.
pub fn CT_EastAsianLayout::to_element(
  self : CT_EastAsianLayout,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FramePr — Part 1 §17.3.1.11 framePr (text
/// frame). Aggregates fifteen optional sizing / positioning
/// attributes per the schema; see linked simple-type sections in each
/// field doc.
pub(all) struct CT_FramePr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.20 @dropCap (ST_DropCap) — optional drop-cap mode.
  drop_cap : ST_DropCap?
  /// §17.18.10 @lines (ST_DecimalNumber) — optional drop-cap line count.
  lines : ST_DecimalNumber?
  /// §22.9.2.10 @w (s:ST_TwipsMeasure) — optional frame width.
  w : String?
  /// §22.9.2.10 @h (s:ST_TwipsMeasure) — optional frame height.
  h : String?
  /// §22.9.2.10 @vSpace (s:ST_TwipsMeasure) — optional vertical
  /// padding around the frame.
  v_space : String?
  /// §22.9.2.10 @hSpace (s:ST_TwipsMeasure) — optional horizontal
  /// padding around the frame.
  h_space : String?
  /// §17.18.104 @wrap (ST_Wrap) — optional text-wrap mode.
  wrap : ST_Wrap?
  /// §17.18.35 @hAnchor (ST_HAnchor) — optional horizontal anchor.
  h_anchor : ST_HAnchor?
  /// §17.18.100 @vAnchor (ST_VAnchor) — optional vertical anchor.
  v_anchor : ST_VAnchor?
  /// §17.18.81 @x (ST_SignedTwipsMeasure) — optional X offset.
  x : ST_SignedTwipsMeasure?
  /// §22.9.2.18 @xAlign (s:ST_XAlign) — optional horizontal alignment.
  x_align : String?
  /// §17.18.81 @y (ST_SignedTwipsMeasure) — optional Y offset.
  y : ST_SignedTwipsMeasure?
  /// §22.9.2.19 @yAlign (s:ST_YAlign) — optional vertical alignment.
  y_align : String?
  /// §17.18.37 @hRule (ST_HeightRule) — optional row-height rule.
  h_rule : ST_HeightRule?
  /// §22.9.2.7 @anchorLock (s:ST_OnOff) — optional anchor-lock flag.
  anchor_lock : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FramePr — Part 1 §17.3.1.11.
pub fn CT_FramePr::new(
  element : @xml.Element,
) -> CT_FramePr raise SchemaViolation {
  let drop_cap = match wml_ct_chunk1_attr(element, "dropCap") {
    Some(text) => Some(ST_DropCap::parse(text))
    None => None
  }
  let lines = match wml_ct_chunk1_attr(element, "lines") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let w = wml_ct_chunk1_attr(element, "w")
  let h = wml_ct_chunk1_attr(element, "h")
  let v_space = wml_ct_chunk1_attr(element, "vSpace")
  let h_space = wml_ct_chunk1_attr(element, "hSpace")
  let wrap = match wml_ct_chunk1_attr(element, "wrap") {
    Some(text) => Some(ST_Wrap::parse(text))
    None => None
  }
  let h_anchor = match wml_ct_chunk1_attr(element, "hAnchor") {
    Some(text) => Some(ST_HAnchor::parse(text))
    None => None
  }
  let v_anchor = match wml_ct_chunk1_attr(element, "vAnchor") {
    Some(text) => Some(ST_VAnchor::parse(text))
    None => None
  }
  let x = match wml_ct_chunk1_attr(element, "x") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let x_align = wml_ct_chunk1_attr(element, "xAlign")
  let y = match wml_ct_chunk1_attr(element, "y") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let y_align = wml_ct_chunk1_attr(element, "yAlign")
  let h_rule = match wml_ct_chunk1_attr(element, "hRule") {
    Some(text) => Some(ST_HeightRule::parse(text))
    None => None
  }
  let anchor_lock = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "anchorLock"),
  )
  {
    element,
    drop_cap,
    lines,
    w,
    h,
    v_space,
    h_space,
    wrap,
    h_anchor,
    v_anchor,
    x,
    x_align,
    y,
    y_align,
    h_rule,
    anchor_lock,
  }
}

///|
/// XSD complex type CT_FramePr — Part 1 §17.3.1.11.
pub fn CT_FramePr::parse(
  element : @xml.Element,
) -> CT_FramePr raise SchemaViolation {
  CT_FramePr::new(element)
}

///|
/// XSD complex type CT_FramePr — return the preserved element for
/// writers.
pub fn CT_FramePr::to_element(self : CT_FramePr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TabStop — Part 1 §17.3.1.37 tab. Required `@val`
/// ST_TabJc (Part 1 §17.18.84) and `@pos` (ST_SignedTwipsMeasure,
/// §17.18.81); optional `@leader` ST_TabTlc (Part 1 §17.18.85).
pub(all) struct CT_TabStop {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.84 @val (ST_TabJc) — alignment kind, required.
  val : ST_TabJc
  /// §17.18.85 @leader (ST_TabTlc) — optional leader fill.
  leader : ST_TabTlc?
  /// §17.18.81 @pos (ST_SignedTwipsMeasure) — anchor position, required.
  pos : ST_SignedTwipsMeasure
} derive(Eq, Debug)

///|
/// XSD complex type CT_TabStop — Part 1 §17.3.1.37.
pub fn CT_TabStop::new(
  element : @xml.Element,
) -> CT_TabStop raise SchemaViolation {
  let raw_val = wml_ct_chunk1_required_attr(
    element, "val", "CT_TabStop", "Part 1 §17.18.84 ST_TabJc",
  )
  let val = ST_TabJc::parse(raw_val)
  let leader = match wml_ct_chunk1_attr(element, "leader") {
    Some(text) => Some(ST_TabTlc::parse(text))
    None => None
  }
  let raw_pos = wml_ct_chunk1_required_attr(
    element, "pos", "CT_TabStop", "Part 1 §17.18.81 ST_SignedTwipsMeasure",
  )
  let pos = ST_SignedTwipsMeasure::parse(raw_pos)
  { element, val, leader, pos }
}

///|
/// XSD complex type CT_TabStop — Part 1 §17.3.1.37.
pub fn CT_TabStop::parse(
  element : @xml.Element,
) -> CT_TabStop raise SchemaViolation {
  CT_TabStop::new(element)
}

///|
/// XSD complex type CT_TabStop — return the preserved element for
/// writers.
pub fn CT_TabStop::to_element(self : CT_TabStop) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Spacing — Part 1 §17.3.1.33 spacing. Eight
/// optional attributes governing inter-paragraph spacing and the
/// `@line` / `@lineRule` line-spacing pair. Schema defaults `@before` /
/// `@after` / `@beforeLines` / `@afterLines` / `@line` to `0`,
/// `@beforeAutospacing` / `@afterAutospacing` to `off`, and
/// `@lineRule` to `auto` when omitted.
pub(all) struct CT_Spacing {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.10 @before (s:ST_TwipsMeasure) — optional pre-paragraph spacing.
  before : String?
  /// §17.18.10 @beforeLines (ST_DecimalNumber) — optional pre lines count.
  before_lines : ST_DecimalNumber?
  /// §22.9.2.7 @beforeAutospacing (s:ST_OnOff) — optional autospacing flag.
  before_autospacing : Bool?
  /// §22.9.2.10 @after (s:ST_TwipsMeasure) — optional post-paragraph spacing.
  after : String?
  /// §17.18.10 @afterLines (ST_DecimalNumber) — optional post lines count.
  after_lines : ST_DecimalNumber?
  /// §22.9.2.7 @afterAutospacing (s:ST_OnOff) — optional autospacing flag.
  after_autospacing : Bool?
  /// §17.18.81 @line (ST_SignedTwipsMeasure) — optional line spacing.
  line : ST_SignedTwipsMeasure?
  /// §17.18.46 @lineRule (ST_LineSpacingRule) — optional line-rule mode.
  line_rule : ST_LineSpacingRule?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Spacing — Part 1 §17.3.1.33.
pub fn CT_Spacing::new(
  element : @xml.Element,
) -> CT_Spacing raise SchemaViolation {
  let before = wml_ct_chunk1_attr(element, "before")
  let before_lines = match wml_ct_chunk1_attr(element, "beforeLines") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let before_autospacing = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "beforeAutospacing"),
  )
  let after = wml_ct_chunk1_attr(element, "after")
  let after_lines = match wml_ct_chunk1_attr(element, "afterLines") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let after_autospacing = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "afterAutospacing"),
  )
  let line = match wml_ct_chunk1_attr(element, "line") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let line_rule = match wml_ct_chunk1_attr(element, "lineRule") {
    Some(text) => Some(ST_LineSpacingRule::parse(text))
    None => None
  }
  {
    element,
    before,
    before_lines,
    before_autospacing,
    after,
    after_lines,
    after_autospacing,
    line,
    line_rule,
  }
}

///|
/// XSD complex type CT_Spacing — Part 1 §17.3.1.33.
pub fn CT_Spacing::parse(
  element : @xml.Element,
) -> CT_Spacing raise SchemaViolation {
  CT_Spacing::new(element)
}

///|
/// XSD complex type CT_Spacing — return the preserved element for
/// writers.
pub fn CT_Spacing::to_element(self : CT_Spacing) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Ind — Part 1 §17.3.1.12 ind (paragraph
/// indentation). Twelve optional indent attributes split between the
/// strict (`start` / `end`) and transitional (`left` / `right`) names
/// — both forms are preserved here so the resolver can prefer the
/// strict names while still round-tripping legacy markup.
pub(all) struct CT_Ind {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.81 @start (ST_SignedTwipsMeasure) — optional strict-name start indent.
  start : ST_SignedTwipsMeasure?
  /// §17.18.10 @startChars (ST_DecimalNumber) — optional CJK char count.
  start_chars : ST_DecimalNumber?
  /// §17.18.81 @end (ST_SignedTwipsMeasure) — optional strict-name end indent.
  end : ST_SignedTwipsMeasure?
  /// §17.18.10 @endChars (ST_DecimalNumber) — optional CJK char count.
  end_chars : ST_DecimalNumber?
  /// §17.18.81 @left (ST_SignedTwipsMeasure) — optional transitional left indent.
  left : ST_SignedTwipsMeasure?
  /// §17.18.10 @leftChars (ST_DecimalNumber) — optional CJK char count.
  left_chars : ST_DecimalNumber?
  /// §17.18.81 @right (ST_SignedTwipsMeasure) — optional transitional right indent.
  right : ST_SignedTwipsMeasure?
  /// §17.18.10 @rightChars (ST_DecimalNumber) — optional CJK char count.
  right_chars : ST_DecimalNumber?
  /// §22.9.2.10 @hanging (s:ST_TwipsMeasure) — optional hanging indent.
  hanging : String?
  /// §17.18.10 @hangingChars (ST_DecimalNumber) — optional CJK char count.
  hanging_chars : ST_DecimalNumber?
  /// §22.9.2.10 @firstLine (s:ST_TwipsMeasure) — optional first-line indent.
  first_line : String?
  /// §17.18.10 @firstLineChars (ST_DecimalNumber) — optional CJK char count.
  first_line_chars : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Ind — Part 1 §17.3.1.12.
pub fn CT_Ind::new(element : @xml.Element) -> CT_Ind raise SchemaViolation {
  let start = match wml_ct_chunk1_attr(element, "start") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let start_chars = match wml_ct_chunk1_attr(element, "startChars") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let end = match wml_ct_chunk1_attr(element, "end") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let end_chars = match wml_ct_chunk1_attr(element, "endChars") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let left = match wml_ct_chunk1_attr(element, "left") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let left_chars = match wml_ct_chunk1_attr(element, "leftChars") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let right = match wml_ct_chunk1_attr(element, "right") {
    Some(text) => Some(ST_SignedTwipsMeasure::parse(text))
    None => None
  }
  let right_chars = match wml_ct_chunk1_attr(element, "rightChars") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let hanging = wml_ct_chunk1_attr(element, "hanging")
  let hanging_chars = match wml_ct_chunk1_attr(element, "hangingChars") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let first_line = wml_ct_chunk1_attr(element, "firstLine")
  let first_line_chars = match wml_ct_chunk1_attr(element, "firstLineChars") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  {
    element,
    start,
    start_chars,
    end,
    end_chars,
    left,
    left_chars,
    right,
    right_chars,
    hanging,
    hanging_chars,
    first_line,
    first_line_chars,
  }
}

///|
/// XSD complex type CT_Ind — Part 1 §17.3.1.12.
pub fn CT_Ind::parse(element : @xml.Element) -> CT_Ind raise SchemaViolation {
  CT_Ind::new(element)
}

///|
/// XSD complex type CT_Ind — return the preserved element for writers.
pub fn CT_Ind::to_element(self : CT_Ind) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Jc — Part 1 §17.3.1.13 jc (paragraph
/// alignment). Required `@val` ST_Jc (Part 1 §17.18.44).
pub(all) struct CT_Jc {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.44 @val (ST_Jc) — alignment token, required.
  val : ST_Jc
} derive(Eq, Debug)

///|
/// XSD complex type CT_Jc — Part 1 §17.3.1.13.
pub fn CT_Jc::new(element : @xml.Element) -> CT_Jc raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_Jc", "Part 1 §17.18.44 ST_Jc",
  )
  let val = ST_Jc::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_Jc — Part 1 §17.3.1.13.
pub fn CT_Jc::parse(element : @xml.Element) -> CT_Jc raise SchemaViolation {
  CT_Jc::new(element)
}

///|
/// XSD complex type CT_Jc — return the preserved element for writers.
pub fn CT_Jc::to_element(self : CT_Jc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_JcTable — Part 1 §A.1; the typed `@val` is
/// ST_JcTable (Part 1 §17.18.45). Used by table-level alignment
/// elements such as §17.4.30 `<w:jc>` inside `<w:tblPr>`.
pub(all) struct CT_JcTable {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.45 @val (ST_JcTable) — table alignment token, required.
  val : ST_JcTable
} derive(Eq, Debug)

///|
/// XSD complex type CT_JcTable — Part 1 §17.18.45.
pub fn CT_JcTable::new(
  element : @xml.Element,
) -> CT_JcTable raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_JcTable", "Part 1 §17.18.45 ST_JcTable",
  )
  let val = ST_JcTable::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_JcTable — Part 1 §17.18.45.
pub fn CT_JcTable::parse(
  element : @xml.Element,
) -> CT_JcTable raise SchemaViolation {
  CT_JcTable::new(element)
}

///|
/// XSD complex type CT_JcTable — return the preserved element for
/// writers.
pub fn CT_JcTable::to_element(self : CT_JcTable) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_View — Part 1 §17.15.1.92 view (document view
/// setting). Required `@val` ST_View (Part 1 §17.18.102).
pub(all) struct CT_View {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.102 @val (ST_View) — view mode token, required.
  val : ST_View
} derive(Eq, Debug)

///|
/// XSD complex type CT_View — Part 1 §17.15.1.92.
pub fn CT_View::new(element : @xml.Element) -> CT_View raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_View", "Part 1 §17.18.102 ST_View",
  )
  let val = ST_View::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_View — Part 1 §17.15.1.92.
pub fn CT_View::parse(element : @xml.Element) -> CT_View raise SchemaViolation {
  CT_View::new(element)
}

///|
/// XSD complex type CT_View — return the preserved element for
/// writers.
pub fn CT_View::to_element(self : CT_View) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Zoom — Part 1 §17.15.1.94 zoom (magnification).
/// Optional `@val` ST_Zoom (Part 1 §17.18.105) preset and required
/// `@percent` ST_DecimalNumberOrPercent (§17.18.11).
pub(all) struct CT_Zoom {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.105 @val (ST_Zoom) — optional preset token.
  val : ST_Zoom?
  /// §17.18.11 @percent (ST_DecimalNumberOrPercent) — required magnification.
  percent : ST_DecimalNumberOrPercent
} derive(Eq, Debug)

///|
/// XSD complex type CT_Zoom — Part 1 §17.15.1.94.
pub fn CT_Zoom::new(element : @xml.Element) -> CT_Zoom raise SchemaViolation {
  let val = match wml_ct_chunk1_attr(element, "val") {
    Some(text) => Some(ST_Zoom::parse(text))
    None => None
  }
  let raw_percent = wml_ct_chunk1_required_attr(
    element, "percent", "CT_Zoom", "Part 1 §17.18.11 ST_DecimalNumberOrPercent",
  )
  let percent = ST_DecimalNumberOrPercent::parse(raw_percent)
  { element, val, percent }
}

///|
/// XSD complex type CT_Zoom — Part 1 §17.15.1.94.
pub fn CT_Zoom::parse(element : @xml.Element) -> CT_Zoom raise SchemaViolation {
  CT_Zoom::new(element)
}

///|
/// XSD complex type CT_Zoom — return the preserved element for
/// writers.
pub fn CT_Zoom::to_element(self : CT_Zoom) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_WritingStyle — Part 1 §17.15.1.62 activeWritingStyle.
/// Six attributes describing a third-party proofing tool registration;
/// `@lang` / `@vendorID` / `@dllVersion` / `@checkStyle` / `@appName`
/// are required, `@nlCheck` (s:ST_OnOff §22.9.2.7) is optional with
/// schema-default `off`.
pub(all) struct CT_WritingStyle {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.6 @lang (s:ST_Lang) — required BCP-47 tag.
  lang : String
  /// §22.9.2.13 @vendorID (s:ST_String) — required vendor identifier.
  vendor_id : String
  /// §22.9.2.13 @dllVersion (s:ST_String) — required engine version.
  dll_version : String
  /// §22.9.2.7 @nlCheck (s:ST_OnOff) — optional `None` ⇒ schema-default `false`.
  nl_check : Bool?
  /// §22.9.2.7 @checkStyle (s:ST_OnOff) — required style-check flag.
  check_style : Bool
  /// §22.9.2.13 @appName (s:ST_String) — required application name.
  app_name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_WritingStyle — Part 1 §17.15.1.62.
pub fn CT_WritingStyle::new(
  element : @xml.Element,
) -> CT_WritingStyle raise SchemaViolation {
  let lang = wml_ct_chunk1_required_attr(
    element, "lang", "CT_WritingStyle", "Part 1 §22.9.2.6 ST_Lang",
  )
  let vendor_id = wml_ct_chunk1_required_attr(
    element, "vendorID", "CT_WritingStyle", "Part 1 §22.9.2.13 ST_String",
  )
  let dll_version = wml_ct_chunk1_required_attr(
    element, "dllVersion", "CT_WritingStyle", "Part 1 §22.9.2.13 ST_String",
  )
  let nl_check = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "nlCheck"))
  let raw_check_style = wml_ct_chunk1_required_attr(
    element, "checkStyle", "CT_WritingStyle", "Part 1 §22.9.2.7 ST_OnOff",
  )
  let check_style = wml_ct_chunk1_on_off_required(raw_check_style)
  let app_name = wml_ct_chunk1_required_attr(
    element, "appName", "CT_WritingStyle", "Part 1 §22.9.2.13 ST_String",
  )
  { element, lang, vendor_id, dll_version, nl_check, check_style, app_name }
}

///|
/// XSD complex type CT_WritingStyle — Part 1 §17.15.1.62.
pub fn CT_WritingStyle::parse(
  element : @xml.Element,
) -> CT_WritingStyle raise SchemaViolation {
  CT_WritingStyle::new(element)
}

///|
/// XSD complex type CT_WritingStyle — return the preserved element for
/// writers.
pub fn CT_WritingStyle::to_element(self : CT_WritingStyle) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Proof — Part 1 §17.15.1.65 proofState. Optional
/// `@spelling` and `@grammar` ST_Proof (Part 1 §17.18.69) tokens.
pub(all) struct CT_Proof {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.69 @spelling (ST_Proof) — optional spell-check state.
  spelling : ST_Proof?
  /// §17.18.69 @grammar (ST_Proof) — optional grammar-check state.
  grammar : ST_Proof?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Proof — Part 1 §17.15.1.65.
pub fn CT_Proof::new(element : @xml.Element) -> CT_Proof raise SchemaViolation {
  let spelling = match wml_ct_chunk1_attr(element, "spelling") {
    Some(text) => Some(ST_Proof::parse(text))
    None => None
  }
  let grammar = match wml_ct_chunk1_attr(element, "grammar") {
    Some(text) => Some(ST_Proof::parse(text))
    None => None
  }
  { element, spelling, grammar }
}

///|
/// XSD complex type CT_Proof — Part 1 §17.15.1.65.
pub fn CT_Proof::parse(
  element : @xml.Element,
) -> CT_Proof raise SchemaViolation {
  CT_Proof::new(element)
}

///|
/// XSD complex type CT_Proof — return the preserved element for
/// writers.
pub fn CT_Proof::to_element(self : CT_Proof) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocType — Part 1 §17.15.1.30 documentType.
/// Required `@val` ST_DocType (Part 1 §17.18.19), a free-form
/// classification string.
pub(all) struct CT_DocType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.19 @val (ST_DocType) — required classification string.
  val : ST_DocType
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocType — Part 1 §17.15.1.30.
pub fn CT_DocType::new(
  element : @xml.Element,
) -> CT_DocType raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_DocType", "Part 1 §17.18.19 ST_DocType",
  )
  let val = ST_DocType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_DocType — Part 1 §17.15.1.30.
pub fn CT_DocType::parse(
  element : @xml.Element,
) -> CT_DocType raise SchemaViolation {
  CT_DocType::new(element)
}

///|
/// XSD complex type CT_DocType — return the preserved element for
/// writers.
pub fn CT_DocType::to_element(self : CT_DocType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocProtect — Part 1 §17.15.1.29
/// documentProtection. Optional `@edit` ST_DocProtect (§17.18.18),
/// `@formatting` and `@enforcement` ST_OnOff (§22.9.2.7), plus the
/// password attribute groups AG_Password (§17.15.1.29) and
/// AG_TransitionalPassword (Part 4 §14.7.3). Only the named typed
/// attributes are stored; the optional password fields are kept on
/// the preserved element so writers round-trip them verbatim.
pub(all) struct CT_DocProtect {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.18 @edit (ST_DocProtect) — optional edit-restriction kind.
  edit : ST_DocProtect?
  /// §22.9.2.7 @formatting (s:ST_OnOff) — optional formatting-lock flag.
  formatting : Bool?
  /// §22.9.2.7 @enforcement (s:ST_OnOff) — optional enforcement flag.
  enforcement : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocProtect — Part 1 §17.15.1.29.
pub fn CT_DocProtect::new(
  element : @xml.Element,
) -> CT_DocProtect raise SchemaViolation {
  let edit = match wml_ct_chunk1_attr(element, "edit") {
    Some(text) => Some(ST_DocProtect::parse(text))
    None => None
  }
  let formatting = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "formatting"),
  )
  let enforcement = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "enforcement"),
  )
  { element, edit, formatting, enforcement }
}

///|
/// XSD complex type CT_DocProtect — Part 1 §17.15.1.29.
pub fn CT_DocProtect::parse(
  element : @xml.Element,
) -> CT_DocProtect raise SchemaViolation {
  CT_DocProtect::new(element)
}

///|
/// XSD complex type CT_DocProtect — return the preserved element for
/// writers.
pub fn CT_DocProtect::to_element(self : CT_DocProtect) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeDocType — Part 1 §17.14.22
/// mainDocumentType (mail-merge source document kind). Required `@val`
/// ST_MailMergeDocType (Part 1 §17.18.54).
pub(all) struct CT_MailMergeDocType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.54 @val (ST_MailMergeDocType) — required kind token.
  val : ST_MailMergeDocType
} derive(Eq, Debug)

///|
/// XSD complex type CT_MailMergeDocType — Part 1 §17.14.22.
pub fn CT_MailMergeDocType::new(
  element : @xml.Element,
) -> CT_MailMergeDocType raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_MailMergeDocType", "Part 1 §17.18.54 ST_MailMergeDocType",
  )
  let val = ST_MailMergeDocType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MailMergeDocType — Part 1 §17.14.22.
pub fn CT_MailMergeDocType::parse(
  element : @xml.Element,
) -> CT_MailMergeDocType raise SchemaViolation {
  CT_MailMergeDocType::new(element)
}

///|
/// XSD complex type CT_MailMergeDocType — return the preserved element
/// for writers.
pub fn CT_MailMergeDocType::to_element(
  self : CT_MailMergeDocType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeDataType — Part 1 §17.14.10 dataType.
/// Required `@val` ST_MailMergeDataType (Part 1 §17.18.52) — a
/// free-form data-source type token.
pub(all) struct CT_MailMergeDataType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.52 @val (ST_MailMergeDataType) — required string.
  val : ST_MailMergeDataType
} derive(Eq, Debug)

///|
/// XSD complex type CT_MailMergeDataType — Part 1 §17.14.10.
pub fn CT_MailMergeDataType::new(
  element : @xml.Element,
) -> CT_MailMergeDataType raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_MailMergeDataType", "Part 1 §17.18.52 ST_MailMergeDataType",
  )
  let val = ST_MailMergeDataType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MailMergeDataType — Part 1 §17.14.10.
pub fn CT_MailMergeDataType::parse(
  element : @xml.Element,
) -> CT_MailMergeDataType raise SchemaViolation {
  CT_MailMergeDataType::new(element)
}

///|
/// XSD complex type CT_MailMergeDataType — return the preserved
/// element for writers.
pub fn CT_MailMergeDataType::to_element(
  self : CT_MailMergeDataType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MailMergeDest — Part 1 §17.14.11 destination.
/// Required `@val` ST_MailMergeDest (Part 1 §17.18.53) selecting the
/// merge output sink.
pub(all) struct CT_MailMergeDest {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.53 @val (ST_MailMergeDest) — required destination token.
  val : ST_MailMergeDest
} derive(Eq, Debug)

///|
/// XSD complex type CT_MailMergeDest — Part 1 §17.14.11.
pub fn CT_MailMergeDest::new(
  element : @xml.Element,
) -> CT_MailMergeDest raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_MailMergeDest", "Part 1 §17.18.53 ST_MailMergeDest",
  )
  let val = ST_MailMergeDest::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MailMergeDest — Part 1 §17.14.11.
pub fn CT_MailMergeDest::parse(
  element : @xml.Element,
) -> CT_MailMergeDest raise SchemaViolation {
  CT_MailMergeDest::new(element)
}

///|
/// XSD complex type CT_MailMergeDest — return the preserved element
/// for writers.
pub fn CT_MailMergeDest::to_element(self : CT_MailMergeDest) -> @xml.Element {
  self.element
}

///|
/// Read an attribute by local name. The WordprocessingML elements live
/// in the `w` namespace but most carry the `w:` prefix; matching by
/// local name only avoids prefix-lookup churn.
fn wml_ct_chunk1_attr(element : @xml.Element, local_name : String) -> String? {
  let mut found : String? = None
  for attribute in element.attributes {
    if found is None && attribute.name.local_name == local_name {
      found = Some(attribute.value)
    }
  }
  found
}

///|
/// Read a required attribute and raise SchemaViolation when missing.
fn wml_ct_chunk1_required_attr(
  element : @xml.Element,
  local_name : String,
  type_name : String,
  context : String,
) -> String raise SchemaViolation {
  match wml_ct_chunk1_attr(element, local_name) {
    Some(text) => text
    None =>
      raise_schema_violation(
        type_name,
        local_name,
        context + ": required attribute @" + local_name + " is missing",
      )
  }
}

///|
/// Decode an optional ST_OnOff lexical token (§22.9.2.7). Returns
/// `None` when the attribute was omitted and `Some(bool)` otherwise.
/// All four schema-permitted spellings (`0/1`, `on/off`, `true/false`)
/// are accepted; unknown tokens fall back to `false` to mirror legacy
/// writer leniency (per §17.17.4 prose).
fn wml_ct_chunk1_on_off(value : String?) -> Bool? {
  match value {
    Some("1") | Some("true") | Some("on") => Some(true)
    Some("0") | Some("false") | Some("off") => Some(false)
    Some(_) => Some(false)
    None => None
  }
}

///|
/// Decode a required ST_OnOff lexical token (§22.9.2.7). Mirrors
/// `wml_ct_chunk1_on_off` but unwraps; callers ensure the source
/// attribute existed.
fn wml_ct_chunk1_on_off_required(value : String) -> Bool {
  match value {
    "1" | "true" | "on" => true
    "0" | "false" | "off" => false
    _ => false
  }
}

///|
/// Parse a non-negative decimal lexical value into UInt64; raise
/// SchemaViolation on malformed input.
fn wml_ct_chunk1_parse_uint64(
  text : String,
  type_name : String,
  attr_name : String,
  context : String,
) -> UInt64 raise SchemaViolation {
  if text.length() == 0 {
    raise_schema_violation(
      type_name,
      attr_name,
      context + ": empty lexical value",
    )
  }
  let mut value : UInt64 = 0
  for i in 0..<text.length() {
    let unit = text.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      raise_schema_violation(
        type_name,
        attr_name,
        context + ": expected unsigned decimal digits, got " + text,
      )
    }
    value = value * 10 + (unit - 0x30).to_uint64()
  }
  value
}

///|
/// XSD complex type CT_MailMergeOdsoFMDFieldType from wml.xsd (§17).
pub(all) struct CT_MailMergeOdsoFMDFieldType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MailMergeOdsoFMDFieldType::new(
  element : @xml.Element,
) -> CT_MailMergeOdsoFMDFieldType {
  { element, }
}

///|
pub fn CT_MailMergeOdsoFMDFieldType::parse(
  element : @xml.Element,
) -> CT_MailMergeOdsoFMDFieldType {
  CT_MailMergeOdsoFMDFieldType::new(element)
}

///|
pub fn CT_MailMergeOdsoFMDFieldType::to_element(
  self : CT_MailMergeOdsoFMDFieldType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangesView from wml.xsd (§17).
pub(all) struct CT_TrackChangesView {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChangesView::new(element : @xml.Element) -> CT_TrackChangesView {
  { element, }
}

///|
pub fn CT_TrackChangesView::parse(
  element : @xml.Element,
) -> CT_TrackChangesView {
  CT_TrackChangesView::new(element)
}

///|
pub fn CT_TrackChangesView::to_element(
  self : CT_TrackChangesView,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Kinsoku from wml.xsd (§17).
pub(all) struct CT_Kinsoku {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Kinsoku::new(element : @xml.Element) -> CT_Kinsoku {
  { element, }
}

///|
pub fn CT_Kinsoku::parse(element : @xml.Element) -> CT_Kinsoku {
  CT_Kinsoku::new(element)
}

///|
pub fn CT_Kinsoku::to_element(self : CT_Kinsoku) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextDirection from wml.xsd (§17).
pub(all) struct CT_TextDirection {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextDirection::new(element : @xml.Element) -> CT_TextDirection {
  { element, }
}

///|
pub fn CT_TextDirection::parse(element : @xml.Element) -> CT_TextDirection {
  CT_TextDirection::new(element)
}

///|
pub fn CT_TextDirection::to_element(self : CT_TextDirection) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextAlignment from wml.xsd (§17).
pub(all) struct CT_TextAlignment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextAlignment::new(element : @xml.Element) -> CT_TextAlignment {
  { element, }
}

///|
pub fn CT_TextAlignment::parse(element : @xml.Element) -> CT_TextAlignment {
  CT_TextAlignment::new(element)
}

///|
pub fn CT_TextAlignment::to_element(self : CT_TextAlignment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Markup from wml.xsd (§17).
pub(all) struct CT_Markup {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Markup::new(element : @xml.Element) -> CT_Markup {
  { element, }
}

///|
pub fn CT_Markup::parse(element : @xml.Element) -> CT_Markup {
  CT_Markup::new(element)
}

///|
pub fn CT_Markup::to_element(self : CT_Markup) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChange from wml.xsd (§17).
pub(all) struct CT_TrackChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChange::new(element : @xml.Element) -> CT_TrackChange {
  { element, }
}

///|
pub fn CT_TrackChange::parse(element : @xml.Element) -> CT_TrackChange {
  CT_TrackChange::new(element)
}

///|
pub fn CT_TrackChange::to_element(self : CT_TrackChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CellMergeTrackChange from wml.xsd (§17).
pub(all) struct CT_CellMergeTrackChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CellMergeTrackChange::new(
  element : @xml.Element,
) -> CT_CellMergeTrackChange {
  { element, }
}

///|
pub fn CT_CellMergeTrackChange::parse(
  element : @xml.Element,
) -> CT_CellMergeTrackChange {
  CT_CellMergeTrackChange::new(element)
}

///|
pub fn CT_CellMergeTrackChange::to_element(
  self : CT_CellMergeTrackChange,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangeRange from wml.xsd (§17).
pub(all) struct CT_TrackChangeRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrackChangeRange::new(element : @xml.Element) -> CT_TrackChangeRange {
  { element, }
}

///|
pub fn CT_TrackChangeRange::parse(
  element : @xml.Element,
) -> CT_TrackChangeRange {
  CT_TrackChangeRange::new(element)
}

///|
pub fn CT_TrackChangeRange::to_element(
  self : CT_TrackChangeRange,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MarkupRange from wml.xsd (§17).
pub(all) struct CT_MarkupRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MarkupRange::new(element : @xml.Element) -> CT_MarkupRange {
  { element, }
}

///|
pub fn CT_MarkupRange::parse(element : @xml.Element) -> CT_MarkupRange {
  CT_MarkupRange::new(element)
}

///|
pub fn CT_MarkupRange::to_element(self : CT_MarkupRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BookmarkRange from wml.xsd (§17).
pub(all) struct CT_BookmarkRange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BookmarkRange::new(element : @xml.Element) -> CT_BookmarkRange {
  { element, }
}

///|
pub fn CT_BookmarkRange::parse(element : @xml.Element) -> CT_BookmarkRange {
  CT_BookmarkRange::new(element)
}

///|
pub fn CT_BookmarkRange::to_element(self : CT_BookmarkRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Bookmark from wml.xsd (§17).
pub(all) struct CT_Bookmark {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Bookmark::new(element : @xml.Element) -> CT_Bookmark {
  { element, }
}

///|
pub fn CT_Bookmark::parse(element : @xml.Element) -> CT_Bookmark {
  CT_Bookmark::new(element)
}

///|
pub fn CT_Bookmark::to_element(self : CT_Bookmark) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MoveBookmark from wml.xsd (§17).
pub(all) struct CT_MoveBookmark {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MoveBookmark::new(element : @xml.Element) -> CT_MoveBookmark {
  { element, }
}

///|
pub fn CT_MoveBookmark::parse(element : @xml.Element) -> CT_MoveBookmark {
  CT_MoveBookmark::new(element)
}

///|
pub fn CT_MoveBookmark::to_element(self : CT_MoveBookmark) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comment from wml.xsd (§17).
pub(all) struct CT_Comment {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Comment::new(element : @xml.Element) -> CT_Comment {
  { element, }
}

///|
pub fn CT_Comment::parse(element : @xml.Element) -> CT_Comment {
  CT_Comment::new(element)
}

///|
pub fn CT_Comment::to_element(self : CT_Comment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrExChange from wml.xsd (§17).
pub(all) struct CT_TblPrExChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrExChange::new(element : @xml.Element) -> CT_TblPrExChange {
  { element, }
}

///|
pub fn CT_TblPrExChange::parse(element : @xml.Element) -> CT_TblPrExChange {
  CT_TblPrExChange::new(element)
}

///|
pub fn CT_TblPrExChange::to_element(self : CT_TblPrExChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcPrChange from wml.xsd (§17).
pub(all) struct CT_TcPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TcPrChange::new(element : @xml.Element) -> CT_TcPrChange {
  { element, }
}

///|
pub fn CT_TcPrChange::parse(element : @xml.Element) -> CT_TcPrChange {
  CT_TcPrChange::new(element)
}

///|
pub fn CT_TcPrChange::to_element(self : CT_TcPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrPrChange from wml.xsd (§17).
pub(all) struct CT_TrPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TrPrChange::new(element : @xml.Element) -> CT_TrPrChange {
  { element, }
}

///|
pub fn CT_TrPrChange::parse(element : @xml.Element) -> CT_TrPrChange {
  CT_TrPrChange::new(element)
}

///|
pub fn CT_TrPrChange::to_element(self : CT_TrPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblGridChange from wml.xsd (§17).
pub(all) struct CT_TblGridChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblGridChange::new(element : @xml.Element) -> CT_TblGridChange {
  { element, }
}

///|
pub fn CT_TblGridChange::parse(element : @xml.Element) -> CT_TblGridChange {
  CT_TblGridChange::new(element)
}

///|
pub fn CT_TblGridChange::to_element(self : CT_TblGridChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrChange from wml.xsd (§17).
pub(all) struct CT_TblPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TblPrChange::new(element : @xml.Element) -> CT_TblPrChange {
  { element, }
}

///|
pub fn CT_TblPrChange::parse(element : @xml.Element) -> CT_TblPrChange {
  CT_TblPrChange::new(element)
}

///|
pub fn CT_TblPrChange::to_element(self : CT_TblPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPrChange from wml.xsd (§17).
pub(all) struct CT_SectPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectPrChange::new(element : @xml.Element) -> CT_SectPrChange {
  { element, }
}

///|
pub fn CT_SectPrChange::parse(element : @xml.Element) -> CT_SectPrChange {
  CT_SectPrChange::new(element)
}

///|
pub fn CT_SectPrChange::to_element(self : CT_SectPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrChange from wml.xsd (§17).
pub(all) struct CT_PPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPrChange::new(element : @xml.Element) -> CT_PPrChange {
  { element, }
}

///|
pub fn CT_PPrChange::parse(element : @xml.Element) -> CT_PPrChange {
  CT_PPrChange::new(element)
}

///|
pub fn CT_PPrChange::to_element(self : CT_PPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrChange from wml.xsd (§17).
pub(all) struct CT_RPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPrChange::new(element : @xml.Element) -> CT_RPrChange {
  { element, }
}

///|
pub fn CT_RPrChange::parse(element : @xml.Element) -> CT_RPrChange {
  CT_RPrChange::new(element)
}

///|
pub fn CT_RPrChange::to_element(self : CT_RPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPrChange from wml.xsd (§17).
pub(all) struct CT_ParaRPrChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ParaRPrChange::new(element : @xml.Element) -> CT_ParaRPrChange {
  { element, }
}

///|
pub fn CT_ParaRPrChange::parse(element : @xml.Element) -> CT_ParaRPrChange {
  CT_ParaRPrChange::new(element)
}

///|
pub fn CT_ParaRPrChange::to_element(self : CT_ParaRPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RunTrackChange from wml.xsd (§17).
pub(all) struct CT_RunTrackChange {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RunTrackChange::new(element : @xml.Element) -> CT_RunTrackChange {
  { element, }
}

///|
pub fn CT_RunTrackChange::parse(element : @xml.Element) -> CT_RunTrackChange {
  CT_RunTrackChange::new(element)
}

///|
pub fn CT_RunTrackChange::to_element(self : CT_RunTrackChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NumPr from wml.xsd (§17).
pub(all) struct CT_NumPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_NumPr::new(element : @xml.Element) -> CT_NumPr {
  { element, }
}

///|
pub fn CT_NumPr::parse(element : @xml.Element) -> CT_NumPr {
  CT_NumPr::new(element)
}

///|
pub fn CT_NumPr::to_element(self : CT_NumPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PBdr from wml.xsd (§17).
pub(all) struct CT_PBdr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PBdr::new(element : @xml.Element) -> CT_PBdr {
  { element, }
}

///|
pub fn CT_PBdr::parse(element : @xml.Element) -> CT_PBdr {
  CT_PBdr::new(element)
}

///|
pub fn CT_PBdr::to_element(self : CT_PBdr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tabs from wml.xsd (§17).
pub(all) struct CT_Tabs {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Tabs::new(element : @xml.Element) -> CT_Tabs {
  { element, }
}

///|
pub fn CT_Tabs::parse(element : @xml.Element) -> CT_Tabs {
  CT_Tabs::new(element)
}

///|
pub fn CT_Tabs::to_element(self : CT_Tabs) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextboxTightWrap from wml.xsd (§17).
pub(all) struct CT_TextboxTightWrap {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextboxTightWrap::new(element : @xml.Element) -> CT_TextboxTightWrap {
  { element, }
}

///|
pub fn CT_TextboxTightWrap::parse(
  element : @xml.Element,
) -> CT_TextboxTightWrap {
  CT_TextboxTightWrap::new(element)
}

///|
pub fn CT_TextboxTightWrap::to_element(
  self : CT_TextboxTightWrap,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPr from wml.xsd (§17).
pub(all) struct CT_PPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPr::new(element : @xml.Element) -> CT_PPr {
  { element, }
}

///|
pub fn CT_PPr::parse(element : @xml.Element) -> CT_PPr {
  CT_PPr::new(element)
}

///|
pub fn CT_PPr::to_element(self : CT_PPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrBase from wml.xsd (§17).
pub(all) struct CT_PPrBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPrBase::new(element : @xml.Element) -> CT_PPrBase {
  { element, }
}

///|
pub fn CT_PPrBase::parse(element : @xml.Element) -> CT_PPrBase {
  CT_PPrBase::new(element)
}

///|
pub fn CT_PPrBase::to_element(self : CT_PPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrGeneral from wml.xsd (§17).
pub(all) struct CT_PPrGeneral {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PPrGeneral::new(element : @xml.Element) -> CT_PPrGeneral {
  { element, }
}

///|
pub fn CT_PPrGeneral::parse(element : @xml.Element) -> CT_PPrGeneral {
  CT_PPrGeneral::new(element)
}

///|
pub fn CT_PPrGeneral::to_element(self : CT_PPrGeneral) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Control from wml.xsd (§17).
pub(all) struct CT_Control {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  { element, }
}

///|
pub fn CT_Control::parse(element : @xml.Element) -> CT_Control {
  CT_Control::new(element)
}

///|
pub fn CT_Control::to_element(self : CT_Control) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Background from wml.xsd (§17).
pub(all) struct CT_Background {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Background::new(element : @xml.Element) -> CT_Background {
  { element, }
}

///|
pub fn CT_Background::parse(element : @xml.Element) -> CT_Background {
  CT_Background::new(element)
}

///|
pub fn CT_Background::to_element(self : CT_Background) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rel from wml.xsd (§17).
pub(all) struct CT_Rel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel {
  { element, }
}

///|
pub fn CT_Rel::parse(element : @xml.Element) -> CT_Rel {
  CT_Rel::new(element)
}

///|
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Object from wml.xsd (§17).
pub(all) struct CT_Object {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Object::new(element : @xml.Element) -> CT_Object {
  { element, }
}

///|
pub fn CT_Object::parse(element : @xml.Element) -> CT_Object {
  CT_Object::new(element)
}

///|
pub fn CT_Object::to_element(self : CT_Object) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectEmbed from wml.xsd (§17).
pub(all) struct CT_ObjectEmbed {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectEmbed::new(element : @xml.Element) -> CT_ObjectEmbed {
  { element, }
}

///|
pub fn CT_ObjectEmbed::parse(element : @xml.Element) -> CT_ObjectEmbed {
  CT_ObjectEmbed::new(element)
}

///|
pub fn CT_ObjectEmbed::to_element(self : CT_ObjectEmbed) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectLink from wml.xsd (§17).
pub(all) struct CT_ObjectLink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ObjectLink::new(element : @xml.Element) -> CT_ObjectLink {
  { element, }
}

///|
pub fn CT_ObjectLink::parse(element : @xml.Element) -> CT_ObjectLink {
  CT_ObjectLink::new(element)
}

///|
pub fn CT_ObjectLink::to_element(self : CT_ObjectLink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Drawing from wml.xsd (§17).
pub(all) struct CT_Drawing {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Drawing::new(element : @xml.Element) -> CT_Drawing {
  { element, }
}

///|
pub fn CT_Drawing::parse(element : @xml.Element) -> CT_Drawing {
  CT_Drawing::new(element)
}

///|
pub fn CT_Drawing::to_element(self : CT_Drawing) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SimpleField from wml.xsd (§17).
pub(all) struct CT_SimpleField {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SimpleField::new(element : @xml.Element) -> CT_SimpleField {
  { element, }
}

///|
pub fn CT_SimpleField::parse(element : @xml.Element) -> CT_SimpleField {
  CT_SimpleField::new(element)
}

///|
pub fn CT_SimpleField::to_element(self : CT_SimpleField) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFTextType from wml.xsd (§17).
pub(all) struct CT_FFTextType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFTextType::new(element : @xml.Element) -> CT_FFTextType {
  { element, }
}

///|
pub fn CT_FFTextType::parse(element : @xml.Element) -> CT_FFTextType {
  CT_FFTextType::new(element)
}

///|
pub fn CT_FFTextType::to_element(self : CT_FFTextType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFName from wml.xsd (§17).
pub(all) struct CT_FFName {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFName::new(element : @xml.Element) -> CT_FFName {
  { element, }
}

///|
pub fn CT_FFName::parse(element : @xml.Element) -> CT_FFName {
  CT_FFName::new(element)
}

///|
pub fn CT_FFName::to_element(self : CT_FFName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FldChar from wml.xsd (§17).
pub(all) struct CT_FldChar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FldChar::new(element : @xml.Element) -> CT_FldChar {
  { element, }
}

///|
pub fn CT_FldChar::parse(element : @xml.Element) -> CT_FldChar {
  CT_FldChar::new(element)
}

///|
pub fn CT_FldChar::to_element(self : CT_FldChar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Hyperlink from wml.xsd (§17).
pub(all) struct CT_Hyperlink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Hyperlink::new(element : @xml.Element) -> CT_Hyperlink {
  { element, }
}

///|
pub fn CT_Hyperlink::parse(element : @xml.Element) -> CT_Hyperlink {
  CT_Hyperlink::new(element)
}

///|
pub fn CT_Hyperlink::to_element(self : CT_Hyperlink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFData from wml.xsd (§17).
pub(all) struct CT_FFData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFData::new(element : @xml.Element) -> CT_FFData {
  { element, }
}

///|
pub fn CT_FFData::parse(element : @xml.Element) -> CT_FFData {
  CT_FFData::new(element)
}

///|
pub fn CT_FFData::to_element(self : CT_FFData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFHelpText from wml.xsd (§17).
pub(all) struct CT_FFHelpText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFHelpText::new(element : @xml.Element) -> CT_FFHelpText {
  { element, }
}

///|
pub fn CT_FFHelpText::parse(element : @xml.Element) -> CT_FFHelpText {
  CT_FFHelpText::new(element)
}

///|
pub fn CT_FFHelpText::to_element(self : CT_FFHelpText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFStatusText from wml.xsd (§17).
pub(all) struct CT_FFStatusText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFStatusText::new(element : @xml.Element) -> CT_FFStatusText {
  { element, }
}

///|
pub fn CT_FFStatusText::parse(element : @xml.Element) -> CT_FFStatusText {
  CT_FFStatusText::new(element)
}

///|
pub fn CT_FFStatusText::to_element(self : CT_FFStatusText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFCheckBox from wml.xsd (§17).
pub(all) struct CT_FFCheckBox {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFCheckBox::new(element : @xml.Element) -> CT_FFCheckBox {
  { element, }
}

///|
pub fn CT_FFCheckBox::parse(element : @xml.Element) -> CT_FFCheckBox {
  CT_FFCheckBox::new(element)
}

///|
pub fn CT_FFCheckBox::to_element(self : CT_FFCheckBox) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFDDList from wml.xsd (§17).
pub(all) struct CT_FFDDList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFDDList::new(element : @xml.Element) -> CT_FFDDList {
  { element, }
}

///|
pub fn CT_FFDDList::parse(element : @xml.Element) -> CT_FFDDList {
  CT_FFDDList::new(element)
}

///|
pub fn CT_FFDDList::to_element(self : CT_FFDDList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFTextInput from wml.xsd (§17).
pub(all) struct CT_FFTextInput {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_FFTextInput::new(element : @xml.Element) -> CT_FFTextInput {
  { element, }
}

///|
pub fn CT_FFTextInput::parse(element : @xml.Element) -> CT_FFTextInput {
  CT_FFTextInput::new(element)
}

///|
pub fn CT_FFTextInput::to_element(self : CT_FFTextInput) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectType from wml.xsd (§17).
pub(all) struct CT_SectType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectType::new(element : @xml.Element) -> CT_SectType {
  { element, }
}

///|
pub fn CT_SectType::parse(element : @xml.Element) -> CT_SectType {
  CT_SectType::new(element)
}

///|
pub fn CT_SectType::to_element(self : CT_SectType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PaperSource from wml.xsd (§17).
pub(all) struct CT_PaperSource {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PaperSource::new(element : @xml.Element) -> CT_PaperSource {
  { element, }
}

///|
pub fn CT_PaperSource::parse(element : @xml.Element) -> CT_PaperSource {
  CT_PaperSource::new(element)
}

///|
pub fn CT_PaperSource::to_element(self : CT_PaperSource) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageSz from wml.xsd (§17).
pub(all) struct CT_PageSz {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageSz::new(element : @xml.Element) -> CT_PageSz {
  { element, }
}

///|
pub fn CT_PageSz::parse(element : @xml.Element) -> CT_PageSz {
  CT_PageSz::new(element)
}

///|
pub fn CT_PageSz::to_element(self : CT_PageSz) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageMar from wml.xsd (§17).
pub(all) struct CT_PageMar {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageMar::new(element : @xml.Element) -> CT_PageMar {
  { element, }
}

///|
pub fn CT_PageMar::parse(element : @xml.Element) -> CT_PageMar {
  CT_PageMar::new(element)
}

///|
pub fn CT_PageMar::to_element(self : CT_PageMar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageBorders from wml.xsd (§17).
pub(all) struct CT_PageBorders {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageBorders::new(element : @xml.Element) -> CT_PageBorders {
  { element, }
}

///|
pub fn CT_PageBorders::parse(element : @xml.Element) -> CT_PageBorders {
  CT_PageBorders::new(element)
}

///|
pub fn CT_PageBorders::to_element(self : CT_PageBorders) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageBorder from wml.xsd (§17).
pub(all) struct CT_PageBorder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageBorder::new(element : @xml.Element) -> CT_PageBorder {
  { element, }
}

///|
pub fn CT_PageBorder::parse(element : @xml.Element) -> CT_PageBorder {
  CT_PageBorder::new(element)
}

///|
pub fn CT_PageBorder::to_element(self : CT_PageBorder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BottomPageBorder from wml.xsd (§17).
pub(all) struct CT_BottomPageBorder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BottomPageBorder::new(element : @xml.Element) -> CT_BottomPageBorder {
  { element, }
}

///|
pub fn CT_BottomPageBorder::parse(
  element : @xml.Element,
) -> CT_BottomPageBorder {
  CT_BottomPageBorder::new(element)
}

///|
pub fn CT_BottomPageBorder::to_element(
  self : CT_BottomPageBorder,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TopPageBorder from wml.xsd (§17).
pub(all) struct CT_TopPageBorder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TopPageBorder::new(element : @xml.Element) -> CT_TopPageBorder {
  { element, }
}

///|
pub fn CT_TopPageBorder::parse(element : @xml.Element) -> CT_TopPageBorder {
  CT_TopPageBorder::new(element)
}

///|
pub fn CT_TopPageBorder::to_element(self : CT_TopPageBorder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineNumber from wml.xsd (§17).
pub(all) struct CT_LineNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_LineNumber::new(element : @xml.Element) -> CT_LineNumber {
  { element, }
}

///|
pub fn CT_LineNumber::parse(element : @xml.Element) -> CT_LineNumber {
  CT_LineNumber::new(element)
}

///|
pub fn CT_LineNumber::to_element(self : CT_LineNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageNumber from wml.xsd (§17).
pub(all) struct CT_PageNumber {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PageNumber::new(element : @xml.Element) -> CT_PageNumber {
  { element, }
}

///|
pub fn CT_PageNumber::parse(element : @xml.Element) -> CT_PageNumber {
  CT_PageNumber::new(element)
}

///|
pub fn CT_PageNumber::to_element(self : CT_PageNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Column from wml.xsd (§17).
pub(all) struct CT_Column {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Column::new(element : @xml.Element) -> CT_Column {
  { element, }
}

///|
pub fn CT_Column::parse(element : @xml.Element) -> CT_Column {
  CT_Column::new(element)
}

///|
pub fn CT_Column::to_element(self : CT_Column) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Columns from wml.xsd (§17).
pub(all) struct CT_Columns {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Columns::new(element : @xml.Element) -> CT_Columns {
  { element, }
}

///|
pub fn CT_Columns::parse(element : @xml.Element) -> CT_Columns {
  CT_Columns::new(element)
}

///|
pub fn CT_Columns::to_element(self : CT_Columns) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_VerticalJc from wml.xsd (§17).
pub(all) struct CT_VerticalJc {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_VerticalJc::new(element : @xml.Element) -> CT_VerticalJc {
  { element, }
}

///|
pub fn CT_VerticalJc::parse(element : @xml.Element) -> CT_VerticalJc {
  CT_VerticalJc::new(element)
}

///|
pub fn CT_VerticalJc::to_element(self : CT_VerticalJc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocGrid from wml.xsd (§17).
pub(all) struct CT_DocGrid {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DocGrid::new(element : @xml.Element) -> CT_DocGrid {
  { element, }
}

///|
pub fn CT_DocGrid::parse(element : @xml.Element) -> CT_DocGrid {
  CT_DocGrid::new(element)
}

///|
pub fn CT_DocGrid::to_element(self : CT_DocGrid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HdrFtrRef from wml.xsd (§17).
pub(all) struct CT_HdrFtrRef {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HdrFtrRef::new(element : @xml.Element) -> CT_HdrFtrRef {
  { element, }
}

///|
pub fn CT_HdrFtrRef::parse(element : @xml.Element) -> CT_HdrFtrRef {
  CT_HdrFtrRef::new(element)
}

///|
pub fn CT_HdrFtrRef::to_element(self : CT_HdrFtrRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HdrFtr from wml.xsd (§17).
pub(all) struct CT_HdrFtr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_HdrFtr::new(element : @xml.Element) -> CT_HdrFtr {
  { element, }
}

///|
pub fn CT_HdrFtr::parse(element : @xml.Element) -> CT_HdrFtr {
  CT_HdrFtr::new(element)
}

///|
pub fn CT_HdrFtr::to_element(self : CT_HdrFtr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPrBase from wml.xsd (§17).
pub(all) struct CT_SectPrBase {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectPrBase::new(element : @xml.Element) -> CT_SectPrBase {
  { element, }
}

///|
pub fn CT_SectPrBase::parse(element : @xml.Element) -> CT_SectPrBase {
  CT_SectPrBase::new(element)
}

///|
pub fn CT_SectPrBase::to_element(self : CT_SectPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPr from wml.xsd (§17).
pub(all) struct CT_SectPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SectPr::new(element : @xml.Element) -> CT_SectPr {
  { element, }
}

///|
pub fn CT_SectPr::parse(element : @xml.Element) -> CT_SectPr {
  CT_SectPr::new(element)
}

///|
pub fn CT_SectPr::to_element(self : CT_SectPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Br from wml.xsd (§17).
pub(all) struct CT_Br {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Br::new(element : @xml.Element) -> CT_Br {
  { element, }
}

///|
pub fn CT_Br::parse(element : @xml.Element) -> CT_Br {
  CT_Br::new(element)
}

///|
pub fn CT_Br::to_element(self : CT_Br) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PTab from wml.xsd (§17).
pub(all) struct CT_PTab {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PTab::new(element : @xml.Element) -> CT_PTab {
  { element, }
}

///|
pub fn CT_PTab::parse(element : @xml.Element) -> CT_PTab {
  CT_PTab::new(element)
}

///|
pub fn CT_PTab::to_element(self : CT_PTab) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Sym from wml.xsd (§17).
pub(all) struct CT_Sym {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Sym::new(element : @xml.Element) -> CT_Sym {
  { element, }
}

///|
pub fn CT_Sym::parse(element : @xml.Element) -> CT_Sym {
  CT_Sym::new(element)
}

///|
pub fn CT_Sym::to_element(self : CT_Sym) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ProofErr from wml.xsd (§17).
pub(all) struct CT_ProofErr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ProofErr::new(element : @xml.Element) -> CT_ProofErr {
  { element, }
}

///|
pub fn CT_ProofErr::parse(element : @xml.Element) -> CT_ProofErr {
  CT_ProofErr::new(element)
}

///|
pub fn CT_ProofErr::to_element(self : CT_ProofErr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Perm from wml.xsd (§17).
pub(all) struct CT_Perm {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Perm::new(element : @xml.Element) -> CT_Perm {
  { element, }
}

///|
pub fn CT_Perm::parse(element : @xml.Element) -> CT_Perm {
  CT_Perm::new(element)
}

///|
pub fn CT_Perm::to_element(self : CT_Perm) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PermStart from wml.xsd (§17).
pub(all) struct CT_PermStart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PermStart::new(element : @xml.Element) -> CT_PermStart {
  { element, }
}

///|
pub fn CT_PermStart::parse(element : @xml.Element) -> CT_PermStart {
  CT_PermStart::new(element)
}

///|
pub fn CT_PermStart::to_element(self : CT_PermStart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Text from wml.xsd (§17).
pub(all) struct CT_Text {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Text::new(element : @xml.Element) -> CT_Text {
  { element, }
}

///|
pub fn CT_Text::parse(element : @xml.Element) -> CT_Text {
  CT_Text::new(element)
}

///|
pub fn CT_Text::to_element(self : CT_Text) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_R from wml.xsd (§17).
pub(all) struct CT_R {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_R::new(element : @xml.Element) -> CT_R {
  { element, }
}

///|
pub fn CT_R::parse(element : @xml.Element) -> CT_R {
  CT_R::new(element)
}

///|
pub fn CT_R::to_element(self : CT_R) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Fonts from wml.xsd (§17).
pub(all) struct CT_Fonts {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fonts::new(element : @xml.Element) -> CT_Fonts {
  { element, }
}

///|
pub fn CT_Fonts::parse(element : @xml.Element) -> CT_Fonts {
  CT_Fonts::new(element)
}

///|
pub fn CT_Fonts::to_element(self : CT_Fonts) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPr from wml.xsd (§17).
pub(all) struct CT_RPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPr::new(element : @xml.Element) -> CT_RPr {
  { element, }
}

///|
pub fn CT_RPr::parse(element : @xml.Element) -> CT_RPr {
  CT_RPr::new(element)
}

///|
pub fn CT_RPr::to_element(self : CT_RPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MathCtrlIns from wml.xsd (§17).
pub(all) struct CT_MathCtrlIns {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MathCtrlIns::new(element : @xml.Element) -> CT_MathCtrlIns {
  { element, }
}

///|
pub fn CT_MathCtrlIns::parse(element : @xml.Element) -> CT_MathCtrlIns {
  CT_MathCtrlIns::new(element)
}

///|
pub fn CT_MathCtrlIns::to_element(self : CT_MathCtrlIns) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MathCtrlDel from wml.xsd (§17).
pub(all) struct CT_MathCtrlDel {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_MathCtrlDel::new(element : @xml.Element) -> CT_MathCtrlDel {
  { element, }
}

///|
pub fn CT_MathCtrlDel::parse(element : @xml.Element) -> CT_MathCtrlDel {
  CT_MathCtrlDel::new(element)
}

///|
pub fn CT_MathCtrlDel::to_element(self : CT_MathCtrlDel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrOriginal from wml.xsd (§17).
pub(all) struct CT_RPrOriginal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RPrOriginal::new(element : @xml.Element) -> CT_RPrOriginal {
  { element, }
}

///|
pub fn CT_RPrOriginal::parse(element : @xml.Element) -> CT_RPrOriginal {
  CT_RPrOriginal::new(element)
}

///|
pub fn CT_RPrOriginal::to_element(self : CT_RPrOriginal) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPrOriginal from wml.xsd (§17).
pub(all) struct CT_ParaRPrOriginal {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ParaRPrOriginal::new(element : @xml.Element) -> CT_ParaRPrOriginal {
  { element, }
}

///|
pub fn CT_ParaRPrOriginal::parse(element : @xml.Element) -> CT_ParaRPrOriginal {
  CT_ParaRPrOriginal::new(element)
}

///|
pub fn CT_ParaRPrOriginal::to_element(
  self : CT_ParaRPrOriginal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPr from wml.xsd (§17).
pub(all) struct CT_ParaRPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ParaRPr::new(element : @xml.Element) -> CT_ParaRPr {
  { element, }
}

///|
pub fn CT_ParaRPr::parse(element : @xml.Element) -> CT_ParaRPr {
  CT_ParaRPr::new(element)
}

///|
pub fn CT_ParaRPr::to_element(self : CT_ParaRPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AltChunk from wml.xsd (§17).
pub(all) struct CT_AltChunk {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AltChunk::new(element : @xml.Element) -> CT_AltChunk {
  { element, }
}

///|
pub fn CT_AltChunk::parse(element : @xml.Element) -> CT_AltChunk {
  CT_AltChunk::new(element)
}

///|
pub fn CT_AltChunk::to_element(self : CT_AltChunk) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AltChunkPr from wml.xsd (§17).
pub(all) struct CT_AltChunkPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_AltChunkPr::new(element : @xml.Element) -> CT_AltChunkPr {
  { element, }
}

///|
pub fn CT_AltChunkPr::parse(element : @xml.Element) -> CT_AltChunkPr {
  CT_AltChunkPr::new(element)
}

///|
pub fn CT_AltChunkPr::to_element(self : CT_AltChunkPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyAlign from wml.xsd (§17).
pub(all) struct CT_RubyAlign {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RubyAlign::new(element : @xml.Element) -> CT_RubyAlign {
  { element, }
}

///|
pub fn CT_RubyAlign::parse(element : @xml.Element) -> CT_RubyAlign {
  CT_RubyAlign::new(element)
}

///|
pub fn CT_RubyAlign::to_element(self : CT_RubyAlign) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyPr from wml.xsd (§17).
pub(all) struct CT_RubyPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RubyPr::new(element : @xml.Element) -> CT_RubyPr {
  { element, }
}

///|
pub fn CT_RubyPr::parse(element : @xml.Element) -> CT_RubyPr {
  CT_RubyPr::new(element)
}

///|
pub fn CT_RubyPr::to_element(self : CT_RubyPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyContent from wml.xsd (§17).
pub(all) struct CT_RubyContent {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RubyContent::new(element : @xml.Element) -> CT_RubyContent {
  { element, }
}

///|
pub fn CT_RubyContent::parse(element : @xml.Element) -> CT_RubyContent {
  CT_RubyContent::new(element)
}

///|
pub fn CT_RubyContent::to_element(self : CT_RubyContent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Ruby from wml.xsd (§17).
pub(all) struct CT_Ruby {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ruby::new(element : @xml.Element) -> CT_Ruby {
  { element, }
}

///|
pub fn CT_Ruby::parse(element : @xml.Element) -> CT_Ruby {
  CT_Ruby::new(element)
}

///|
pub fn CT_Ruby::to_element(self : CT_Ruby) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Lock from wml.xsd (§17).
pub(all) struct CT_Lock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Lock::new(element : @xml.Element) -> CT_Lock {
  { element, }
}

///|
pub fn CT_Lock::parse(element : @xml.Element) -> CT_Lock {
  CT_Lock::new(element)
}

///|
pub fn CT_Lock::to_element(self : CT_Lock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtListItem from wml.xsd (§17).
pub(all) struct CT_SdtListItem {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtListItem::new(element : @xml.Element) -> CT_SdtListItem {
  { element, }
}

///|
pub fn CT_SdtListItem::parse(element : @xml.Element) -> CT_SdtListItem {
  CT_SdtListItem::new(element)
}

///|
pub fn CT_SdtListItem::to_element(self : CT_SdtListItem) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDateMappingType from wml.xsd (§17).
pub(all) struct CT_SdtDateMappingType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDateMappingType::new(
  element : @xml.Element,
) -> CT_SdtDateMappingType {
  { element, }
}

///|
pub fn CT_SdtDateMappingType::parse(
  element : @xml.Element,
) -> CT_SdtDateMappingType {
  CT_SdtDateMappingType::new(element)
}

///|
pub fn CT_SdtDateMappingType::to_element(
  self : CT_SdtDateMappingType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CalendarType from wml.xsd (§17).
pub(all) struct CT_CalendarType {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CalendarType::new(element : @xml.Element) -> CT_CalendarType {
  { element, }
}

///|
pub fn CT_CalendarType::parse(element : @xml.Element) -> CT_CalendarType {
  CT_CalendarType::new(element)
}

///|
pub fn CT_CalendarType::to_element(self : CT_CalendarType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDate from wml.xsd (§17).
pub(all) struct CT_SdtDate {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDate::new(element : @xml.Element) -> CT_SdtDate {
  { element, }
}

///|
pub fn CT_SdtDate::parse(element : @xml.Element) -> CT_SdtDate {
  CT_SdtDate::new(element)
}

///|
pub fn CT_SdtDate::to_element(self : CT_SdtDate) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtComboBox from wml.xsd (§17).
pub(all) struct CT_SdtComboBox {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtComboBox::new(element : @xml.Element) -> CT_SdtComboBox {
  { element, }
}

///|
pub fn CT_SdtComboBox::parse(element : @xml.Element) -> CT_SdtComboBox {
  CT_SdtComboBox::new(element)
}

///|
pub fn CT_SdtComboBox::to_element(self : CT_SdtComboBox) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDocPart from wml.xsd (§17).
pub(all) struct CT_SdtDocPart {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDocPart::new(element : @xml.Element) -> CT_SdtDocPart {
  { element, }
}

///|
pub fn CT_SdtDocPart::parse(element : @xml.Element) -> CT_SdtDocPart {
  CT_SdtDocPart::new(element)
}

///|
pub fn CT_SdtDocPart::to_element(self : CT_SdtDocPart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDropDownList from wml.xsd (§17).
pub(all) struct CT_SdtDropDownList {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtDropDownList::new(element : @xml.Element) -> CT_SdtDropDownList {
  { element, }
}

///|
pub fn CT_SdtDropDownList::parse(element : @xml.Element) -> CT_SdtDropDownList {
  CT_SdtDropDownList::new(element)
}

///|
pub fn CT_SdtDropDownList::to_element(
  self : CT_SdtDropDownList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Placeholder from wml.xsd (§17).
pub(all) struct CT_Placeholder {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Placeholder::new(element : @xml.Element) -> CT_Placeholder {
  { element, }
}

///|
pub fn CT_Placeholder::parse(element : @xml.Element) -> CT_Placeholder {
  CT_Placeholder::new(element)
}

///|
pub fn CT_Placeholder::to_element(self : CT_Placeholder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtText from wml.xsd (§17).
pub(all) struct CT_SdtText {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtText::new(element : @xml.Element) -> CT_SdtText {
  { element, }
}

///|
pub fn CT_SdtText::parse(element : @xml.Element) -> CT_SdtText {
  CT_SdtText::new(element)
}

///|
pub fn CT_SdtText::to_element(self : CT_SdtText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DataBinding from wml.xsd (§17).
pub(all) struct CT_DataBinding {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DataBinding::new(element : @xml.Element) -> CT_DataBinding {
  { element, }
}

///|
pub fn CT_DataBinding::parse(element : @xml.Element) -> CT_DataBinding {
  CT_DataBinding::new(element)
}

///|
pub fn CT_DataBinding::to_element(self : CT_DataBinding) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtPr from wml.xsd (§17).
pub(all) struct CT_SdtPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtPr::new(element : @xml.Element) -> CT_SdtPr {
  { element, }
}

///|
pub fn CT_SdtPr::parse(element : @xml.Element) -> CT_SdtPr {
  CT_SdtPr::new(element)
}

///|
pub fn CT_SdtPr::to_element(self : CT_SdtPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtEndPr from wml.xsd (§17).
pub(all) struct CT_SdtEndPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtEndPr::new(element : @xml.Element) -> CT_SdtEndPr {
  { element, }
}

///|
pub fn CT_SdtEndPr::parse(element : @xml.Element) -> CT_SdtEndPr {
  CT_SdtEndPr::new(element)
}

///|
pub fn CT_SdtEndPr::to_element(self : CT_SdtEndPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DirContentRun from wml.xsd (§17).
pub(all) struct CT_DirContentRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_DirContentRun::new(element : @xml.Element) -> CT_DirContentRun {
  { element, }
}

///|
pub fn CT_DirContentRun::parse(element : @xml.Element) -> CT_DirContentRun {
  CT_DirContentRun::new(element)
}

///|
pub fn CT_DirContentRun::to_element(self : CT_DirContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BdoContentRun from wml.xsd (§17).
pub(all) struct CT_BdoContentRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_BdoContentRun::new(element : @xml.Element) -> CT_BdoContentRun {
  { element, }
}

///|
pub fn CT_BdoContentRun::parse(element : @xml.Element) -> CT_BdoContentRun {
  CT_BdoContentRun::new(element)
}

///|
pub fn CT_BdoContentRun::to_element(self : CT_BdoContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentRun from wml.xsd (§17).
pub(all) struct CT_SdtContentRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentRun::new(element : @xml.Element) -> CT_SdtContentRun {
  { element, }
}

///|
pub fn CT_SdtContentRun::parse(element : @xml.Element) -> CT_SdtContentRun {
  CT_SdtContentRun::new(element)
}

///|
pub fn CT_SdtContentRun::to_element(self : CT_SdtContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentBlock from wml.xsd (§17).
pub(all) struct CT_SdtContentBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentBlock::new(element : @xml.Element) -> CT_SdtContentBlock {
  { element, }
}

///|
pub fn CT_SdtContentBlock::parse(element : @xml.Element) -> CT_SdtContentBlock {
  CT_SdtContentBlock::new(element)
}

///|
pub fn CT_SdtContentBlock::to_element(
  self : CT_SdtContentBlock,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentRow from wml.xsd (§17).
pub(all) struct CT_SdtContentRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentRow::new(element : @xml.Element) -> CT_SdtContentRow {
  { element, }
}

///|
pub fn CT_SdtContentRow::parse(element : @xml.Element) -> CT_SdtContentRow {
  CT_SdtContentRow::new(element)
}

///|
pub fn CT_SdtContentRow::to_element(self : CT_SdtContentRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentCell from wml.xsd (§17).
pub(all) struct CT_SdtContentCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtContentCell::new(element : @xml.Element) -> CT_SdtContentCell {
  { element, }
}

///|
pub fn CT_SdtContentCell::parse(element : @xml.Element) -> CT_SdtContentCell {
  CT_SdtContentCell::new(element)
}

///|
pub fn CT_SdtContentCell::to_element(self : CT_SdtContentCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtBlock from wml.xsd (§17).
pub(all) struct CT_SdtBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtBlock::new(element : @xml.Element) -> CT_SdtBlock {
  { element, }
}

///|
pub fn CT_SdtBlock::parse(element : @xml.Element) -> CT_SdtBlock {
  CT_SdtBlock::new(element)
}

///|
pub fn CT_SdtBlock::to_element(self : CT_SdtBlock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtRun from wml.xsd (§17).
pub(all) struct CT_SdtRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtRun::new(element : @xml.Element) -> CT_SdtRun {
  { element, }
}

///|
pub fn CT_SdtRun::parse(element : @xml.Element) -> CT_SdtRun {
  CT_SdtRun::new(element)
}

///|
pub fn CT_SdtRun::to_element(self : CT_SdtRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtCell from wml.xsd (§17).
pub(all) struct CT_SdtCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtCell::new(element : @xml.Element) -> CT_SdtCell {
  { element, }
}

///|
pub fn CT_SdtCell::parse(element : @xml.Element) -> CT_SdtCell {
  CT_SdtCell::new(element)
}

///|
pub fn CT_SdtCell::to_element(self : CT_SdtCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtRow from wml.xsd (§17).
pub(all) struct CT_SdtRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SdtRow::new(element : @xml.Element) -> CT_SdtRow {
  { element, }
}

///|
pub fn CT_SdtRow::parse(element : @xml.Element) -> CT_SdtRow {
  CT_SdtRow::new(element)
}

///|
pub fn CT_SdtRow::to_element(self : CT_SdtRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Attr from wml.xsd (§17).
pub(all) struct CT_Attr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Attr::new(element : @xml.Element) -> CT_Attr {
  { element, }
}

///|
pub fn CT_Attr::parse(element : @xml.Element) -> CT_Attr {
  CT_Attr::new(element)
}

///|
pub fn CT_Attr::to_element(self : CT_Attr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlRun from wml.xsd (§17).
pub(all) struct CT_CustomXmlRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlRun::new(element : @xml.Element) -> CT_CustomXmlRun {
  { element, }
}

///|
pub fn CT_CustomXmlRun::parse(element : @xml.Element) -> CT_CustomXmlRun {
  CT_CustomXmlRun::new(element)
}

///|
pub fn CT_CustomXmlRun::to_element(self : CT_CustomXmlRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagRun from wml.xsd (§17).
pub(all) struct CT_SmartTagRun {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagRun::new(element : @xml.Element) -> CT_SmartTagRun {
  { element, }
}

///|
pub fn CT_SmartTagRun::parse(element : @xml.Element) -> CT_SmartTagRun {
  CT_SmartTagRun::new(element)
}

///|
pub fn CT_SmartTagRun::to_element(self : CT_SmartTagRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlBlock from wml.xsd (§17).
pub(all) struct CT_CustomXmlBlock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlBlock::new(element : @xml.Element) -> CT_CustomXmlBlock {
  { element, }
}

///|
pub fn CT_CustomXmlBlock::parse(element : @xml.Element) -> CT_CustomXmlBlock {
  CT_CustomXmlBlock::new(element)
}

///|
pub fn CT_CustomXmlBlock::to_element(self : CT_CustomXmlBlock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlPr from wml.xsd (§17).
pub(all) struct CT_CustomXmlPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlPr::new(element : @xml.Element) -> CT_CustomXmlPr {
  { element, }
}

///|
pub fn CT_CustomXmlPr::parse(element : @xml.Element) -> CT_CustomXmlPr {
  CT_CustomXmlPr::new(element)
}

///|
pub fn CT_CustomXmlPr::to_element(self : CT_CustomXmlPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlRow from wml.xsd (§17).
pub(all) struct CT_CustomXmlRow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlRow::new(element : @xml.Element) -> CT_CustomXmlRow {
  { element, }
}

///|
pub fn CT_CustomXmlRow::parse(element : @xml.Element) -> CT_CustomXmlRow {
  CT_CustomXmlRow::new(element)
}

///|
pub fn CT_CustomXmlRow::to_element(self : CT_CustomXmlRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlCell from wml.xsd (§17).
pub(all) struct CT_CustomXmlCell {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_CustomXmlCell::new(element : @xml.Element) -> CT_CustomXmlCell {
  { element, }
}

///|
pub fn CT_CustomXmlCell::parse(element : @xml.Element) -> CT_CustomXmlCell {
  CT_CustomXmlCell::new(element)
}

///|
pub fn CT_CustomXmlCell::to_element(self : CT_CustomXmlCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagPr from wml.xsd (§17).
pub(all) struct CT_SmartTagPr {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SmartTagPr::new(element : @xml.Element) -> CT_SmartTagPr {
  { element, }
}

///|
pub fn CT_SmartTagPr::parse(element : @xml.Element) -> CT_SmartTagPr {
  CT_SmartTagPr::new(element)
}

///|
pub fn CT_SmartTagPr::to_element(self : CT_SmartTagPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_P from wml.xsd (§17).
pub(all) struct CT_P {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_P::new(element : @xml.Element) -> CT_P {
  { element, }
}

///|
pub fn CT_P::parse(element : @xml.Element) -> CT_P {
  CT_P::new(element)
}

///|
pub fn CT_P::to_element(self : CT_P) -> @xml.Element {
  self.element
}
