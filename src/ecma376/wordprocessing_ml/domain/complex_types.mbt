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

// WordprocessingML chunk2 typed complex types — wml.xsd §17 CT_* wrappers
// covering track-change markup, bookmarks, paragraph properties, embedded
// objects, fields and hyperlinks. Each former `element : @xml.Element`
// wrapper is replaced with a typed projection of every XSD attribute and
// child element declared by the schema in Part 4 / wml.xsd. The source
// `<w:...>` element is preserved alongside the typed fields so the
// builder can still round-trip unchanged markup. Free-content groups
// (EG_PContent, EG_BlockLevelElts, EG_ContentRunContent, …) are kept as
// `Array[@xml.Element]` because their elemenent-level choices are
// decoded by upstream readers; the typed projection here covers the
// attributes and the named single-element children of each CT.

///|
/// First direct element child of `element` with the given local name, or
/// `None` if no such child exists. WordprocessingML attributes and child
/// elements use the unqualified local name (`w:` prefix is namespace
/// metadata) so a local-name match is sufficient.
fn wml_ct_chunk2_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  let mut found : @xml.Element? = None
  for child in element.children {
    if found is None {
      match child {
        @xml.Node::Element(e) =>
          if e.name.local_name == local_name {
            found = Some(e)
          }
        _ => ()
      }
    }
  }
  found
}

///|
/// All direct element children of `element` whose local name equals
/// `local_name`, returned in document order.
fn wml_ct_chunk2_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(e) =>
        if e.name.local_name == local_name {
          out.push(e)
        }
      _ => ()
    }
  }
  out
}

///|
/// All direct element children of `element`, in document order. Used for
/// CT types whose schema content is an `xsd:choice` over a model group
/// (e.g. EG_PContent, EG_BlockLevelElts) where the typed projection is
/// outside this chunk's scope.
fn wml_ct_chunk2_element_children(
  element : @xml.Element,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(e) => out.push(e)
      _ => ()
    }
  }
  out
}

///|
/// XSD complex type CT_MailMergeOdsoFMDFieldType — Part 1 §17.14.33
/// (mail-merge ODSO field-mapping `type` element). Required `@val`
/// (ST_MailMergeOdsoFMDFieldType §17.18.55) selects the mapping kind.
pub(all) struct CT_MailMergeOdsoFMDFieldType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.55 @val (ST_MailMergeOdsoFMDFieldType) — required.
  val : ST_MailMergeOdsoFMDFieldType
} derive(Eq, Debug)

///|
/// XSD complex type CT_MailMergeOdsoFMDFieldType — Part 1 §17.14.33.
pub fn CT_MailMergeOdsoFMDFieldType::new(
  element : @xml.Element,
) -> CT_MailMergeOdsoFMDFieldType raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_MailMergeOdsoFMDFieldType", "Part 1 §17.18.55 ST_MailMergeOdsoFMDFieldType",
  )
  let val = ST_MailMergeOdsoFMDFieldType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_MailMergeOdsoFMDFieldType — Part 1 §17.14.33.
pub fn CT_MailMergeOdsoFMDFieldType::parse(
  element : @xml.Element,
) -> CT_MailMergeOdsoFMDFieldType raise SchemaViolation {
  CT_MailMergeOdsoFMDFieldType::new(element)
}

///|
/// XSD complex type CT_MailMergeOdsoFMDFieldType — return the preserved
/// element for writers.
pub fn CT_MailMergeOdsoFMDFieldType::to_element(
  self : CT_MailMergeOdsoFMDFieldType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangesView — Part 1 §17.15.1.69
/// (revisionView). Five optional ST_OnOff toggles controlling which
/// classes of revisions are displayed: markup region, comments,
/// insertions/deletions, formatting, and ink annotations.
pub(all) struct CT_TrackChangesView {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @markup (s:ST_OnOff) — show markup region (optional).
  markup : Bool?
  /// §22.9.2.7 @comments (s:ST_OnOff) — show comments (optional).
  comments : Bool?
  /// §22.9.2.7 @insDel (s:ST_OnOff) — show insertions/deletions (optional).
  ins_del : Bool?
  /// §22.9.2.7 @formatting (s:ST_OnOff) — show formatting changes (optional).
  formatting : Bool?
  /// §22.9.2.7 @inkAnnotations (s:ST_OnOff) — show ink annotations (optional).
  ink_annotations : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrackChangesView — Part 1 §17.15.1.69.
pub fn CT_TrackChangesView::new(element : @xml.Element) -> CT_TrackChangesView {
  let markup = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "markup"))
  let comments = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "comments"))
  let ins_del = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "insDel"))
  let formatting = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "formatting"),
  )
  let ink_annotations = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "inkAnnotations"),
  )
  { element, markup, comments, ins_del, formatting, ink_annotations }
}

///|
/// XSD complex type CT_TrackChangesView — Part 1 §17.15.1.69.
pub fn CT_TrackChangesView::parse(
  element : @xml.Element,
) -> CT_TrackChangesView {
  CT_TrackChangesView::new(element)
}

///|
/// XSD complex type CT_TrackChangesView — return the preserved element
/// for writers.
pub fn CT_TrackChangesView::to_element(
  self : CT_TrackChangesView,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Kinsoku — Part 1 §17.3.1.16 (kinsoku Use East
/// Asian Typography Rules for First and Last Character per Line).
/// Required `@lang` (s:ST_Lang) names the language; required `@val`
/// (s:ST_String) carries the kinsoku rule string.
pub(all) struct CT_Kinsoku {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.6 @lang (s:ST_Lang) — required language code.
  lang : String
  /// §22.9.2.13 @val (s:ST_String) — required rule string.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Kinsoku — Part 1 §17.3.1.16.
pub fn CT_Kinsoku::new(
  element : @xml.Element,
) -> CT_Kinsoku raise SchemaViolation {
  let lang = wml_ct_chunk1_required_attr(
    element, "lang", "CT_Kinsoku", "Part 1 §22.9.2.6 s:ST_Lang",
  )
  let val = wml_ct_chunk1_required_attr(
    element, "val", "CT_Kinsoku", "Part 1 §22.9.2.13 s:ST_String",
  )
  { element, lang, val }
}

///|
/// XSD complex type CT_Kinsoku — Part 1 §17.3.1.16.
pub fn CT_Kinsoku::parse(
  element : @xml.Element,
) -> CT_Kinsoku raise SchemaViolation {
  CT_Kinsoku::new(element)
}

///|
/// XSD complex type CT_Kinsoku — return the preserved element for
/// writers.
pub fn CT_Kinsoku::to_element(self : CT_Kinsoku) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextDirection — Part 1 §17.3.1.41
/// (textDirection Paragraph Text Flow Direction). Required `@val`
/// ST_TextDirection chooses one of six tb/rl/lr/tbV/rlV/lrV flows.
pub(all) struct CT_TextDirection {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.93 @val (ST_TextDirection) — required text-flow direction.
  val : ST_TextDirection
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextDirection — Part 1 §17.3.1.41.
pub fn CT_TextDirection::new(
  element : @xml.Element,
) -> CT_TextDirection raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_TextDirection", "Part 1 §17.18.93 ST_TextDirection",
  )
  let val = ST_TextDirection::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_TextDirection — Part 1 §17.3.1.41.
pub fn CT_TextDirection::parse(
  element : @xml.Element,
) -> CT_TextDirection raise SchemaViolation {
  CT_TextDirection::new(element)
}

///|
/// XSD complex type CT_TextDirection — return the preserved element for
/// writers.
pub fn CT_TextDirection::to_element(self : CT_TextDirection) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextAlignment — Part 1 §17.3.1.39
/// (textAlignment Vertical Character Alignment on Line). Required
/// `@val` ST_TextAlignment ∈ {top, center, baseline, bottom, auto}.
pub(all) struct CT_TextAlignment {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.96 @val (ST_TextAlignment) — required vertical alignment.
  val : ST_TextAlignment
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextAlignment — Part 1 §17.3.1.39.
pub fn CT_TextAlignment::new(
  element : @xml.Element,
) -> CT_TextAlignment raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_TextAlignment", "Part 1 §17.18.96 ST_TextAlignment",
  )
  let val = ST_TextAlignment::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_TextAlignment — Part 1 §17.3.1.39.
pub fn CT_TextAlignment::parse(
  element : @xml.Element,
) -> CT_TextAlignment raise SchemaViolation {
  CT_TextAlignment::new(element)
}

///|
/// XSD complex type CT_TextAlignment — return the preserved element for
/// writers.
pub fn CT_TextAlignment::to_element(self : CT_TextAlignment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Markup — Part 1 §A.1 (wml.xsd). Base type for
/// every revision-tracking annotation that carries a numeric `@id`
/// (ST_DecimalNumber §17.18.10) cross-referencing related range
/// markers. Used directly by `customXmlInsRangeEnd` /
/// `customXmlDelRangeEnd` (§17.13.5.6 / §17.13.5.4) and as the base
/// for every other markup CT below.
pub(all) struct CT_Markup {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
} derive(Eq, Debug)

///|
/// XSD complex type CT_Markup — Part 1 §A.1.
pub fn CT_Markup::new(
  element : @xml.Element,
) -> CT_Markup raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_Markup", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  { element, id }
}

///|
/// XSD complex type CT_Markup — Part 1 §A.1.
pub fn CT_Markup::parse(
  element : @xml.Element,
) -> CT_Markup raise SchemaViolation {
  CT_Markup::new(element)
}

///|
/// XSD complex type CT_Markup — return the preserved element for writers.
pub fn CT_Markup::to_element(self : CT_Markup) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChange — Part 1 §A.1 (wml.xsd). Extends
/// CT_Markup with revision authorship metadata: required `@author`
/// (s:ST_String) and optional `@date` (ST_DateTime §17.18.9). The
/// shared base for `ins`/`del`/`moveFrom`/`moveTo` revision elements
/// (§17.13.5.14–28) and for the typed `…Change` records that carry
/// previously-applied property snapshots.
pub(all) struct CT_TrackChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrackChange — Part 1 §A.1.
pub fn CT_TrackChange::new(
  element : @xml.Element,
) -> CT_TrackChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TrackChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_TrackChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  { element, id, author, date }
}

///|
/// XSD complex type CT_TrackChange — Part 1 §A.1.
pub fn CT_TrackChange::parse(
  element : @xml.Element,
) -> CT_TrackChange raise SchemaViolation {
  CT_TrackChange::new(element)
}

///|
/// XSD complex type CT_TrackChange — return the preserved element for
/// writers.
pub fn CT_TrackChange::to_element(self : CT_TrackChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CellMergeTrackChange — Part 1 §17.13.5.3
/// (cellMerge Vertically Merged/Split Table Cells). Extends
/// CT_TrackChange with two optional ST_AnnotationVMerge tokens
/// recording the merge state before and after the revision.
pub(all) struct CT_CellMergeTrackChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// §17.18.1 @vMerge (ST_AnnotationVMerge) — optional new merge state.
  v_merge : ST_AnnotationVMerge?
  /// §17.18.1 @vMergeOrig (ST_AnnotationVMerge) — optional original merge state.
  v_merge_orig : ST_AnnotationVMerge?
} derive(Eq, Debug)

///|
/// XSD complex type CT_CellMergeTrackChange — Part 1 §17.13.5.3.
pub fn CT_CellMergeTrackChange::new(
  element : @xml.Element,
) -> CT_CellMergeTrackChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_CellMergeTrackChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_CellMergeTrackChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let v_merge = match wml_ct_chunk1_attr(element, "vMerge") {
    Some(text) => Some(ST_AnnotationVMerge::parse(text))
    None => None
  }
  let v_merge_orig = match wml_ct_chunk1_attr(element, "vMergeOrig") {
    Some(text) => Some(ST_AnnotationVMerge::parse(text))
    None => None
  }
  { element, id, author, date, v_merge, v_merge_orig }
}

///|
/// XSD complex type CT_CellMergeTrackChange — Part 1 §17.13.5.3.
pub fn CT_CellMergeTrackChange::parse(
  element : @xml.Element,
) -> CT_CellMergeTrackChange raise SchemaViolation {
  CT_CellMergeTrackChange::new(element)
}

///|
/// XSD complex type CT_CellMergeTrackChange — return the preserved
/// element for writers.
pub fn CT_CellMergeTrackChange::to_element(
  self : CT_CellMergeTrackChange,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrackChangeRange — Part 1 §A.1 (wml.xsd). Base
/// for the range-marker revision elements (`moveFromRangeStart`,
/// `moveToRangeStart`, `customXmlInsRangeStart`,
/// `customXmlDelRangeStart`, etc., §17.13.5.21–§17.13.5.9). Extends
/// CT_TrackChange with optional ST_DisplacedByCustomXml `@displacedByCustomXml`.
pub(all) struct CT_TrackChangeRange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// §17.18.14 @displacedByCustomXml (ST_DisplacedByCustomXml) —
  /// optional displacement marker.
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrackChangeRange — Part 1 §A.1.
pub fn CT_TrackChangeRange::new(
  element : @xml.Element,
) -> CT_TrackChangeRange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TrackChangeRange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_TrackChangeRange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let displaced_by_custom_xml = match
    wml_ct_chunk1_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  { element, id, author, date, displaced_by_custom_xml }
}

///|
/// XSD complex type CT_TrackChangeRange — Part 1 §A.1.
pub fn CT_TrackChangeRange::parse(
  element : @xml.Element,
) -> CT_TrackChangeRange raise SchemaViolation {
  CT_TrackChangeRange::new(element)
}

///|
/// XSD complex type CT_TrackChangeRange — return the preserved element
/// for writers.
pub fn CT_TrackChangeRange::to_element(
  self : CT_TrackChangeRange,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MarkupRange — Part 1 §A.1 (wml.xsd). Base for
/// bookmark and comment range-end markers (`bookmarkEnd`,
/// `commentRangeStart`, `commentRangeEnd`, `moveFromRangeEnd`,
/// `moveToRangeEnd`; §17.13.6.1, §17.13.4.3–4, §17.13.5.23/27).
/// Extends CT_Markup with optional ST_DisplacedByCustomXml.
pub(all) struct CT_MarkupRange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §17.18.14 @displacedByCustomXml (ST_DisplacedByCustomXml) —
  /// optional displacement marker.
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
} derive(Eq, Debug)

///|
/// XSD complex type CT_MarkupRange — Part 1 §A.1.
pub fn CT_MarkupRange::new(
  element : @xml.Element,
) -> CT_MarkupRange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_MarkupRange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let displaced_by_custom_xml = match
    wml_ct_chunk1_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  { element, id, displaced_by_custom_xml }
}

///|
/// XSD complex type CT_MarkupRange — Part 1 §A.1.
pub fn CT_MarkupRange::parse(
  element : @xml.Element,
) -> CT_MarkupRange raise SchemaViolation {
  CT_MarkupRange::new(element)
}

///|
/// XSD complex type CT_MarkupRange — return the preserved element for
/// writers.
pub fn CT_MarkupRange::to_element(self : CT_MarkupRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BookmarkRange — Part 1 §A.1 (wml.xsd). Extends
/// CT_MarkupRange with optional table-column anchors (`@colFirst`,
/// `@colLast`, both ST_DecimalNumber §17.18.10). The shared parent of
/// `CT_Bookmark` (bookmarkStart, §17.13.6.2).
pub(all) struct CT_BookmarkRange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §17.18.14 @displacedByCustomXml (ST_DisplacedByCustomXml) — optional.
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
  /// §17.18.10 @colFirst (ST_DecimalNumber) — optional first-column anchor.
  col_first : ST_DecimalNumber?
  /// §17.18.10 @colLast (ST_DecimalNumber) — optional last-column anchor.
  col_last : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_BookmarkRange — Part 1 §A.1.
pub fn CT_BookmarkRange::new(
  element : @xml.Element,
) -> CT_BookmarkRange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_BookmarkRange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let displaced_by_custom_xml = match
    wml_ct_chunk1_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  let col_first = match wml_ct_chunk1_attr(element, "colFirst") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let col_last = match wml_ct_chunk1_attr(element, "colLast") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  { element, id, displaced_by_custom_xml, col_first, col_last }
}

///|
/// XSD complex type CT_BookmarkRange — Part 1 §A.1.
pub fn CT_BookmarkRange::parse(
  element : @xml.Element,
) -> CT_BookmarkRange raise SchemaViolation {
  CT_BookmarkRange::new(element)
}

///|
/// XSD complex type CT_BookmarkRange — return the preserved element for
/// writers.
pub fn CT_BookmarkRange::to_element(self : CT_BookmarkRange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Bookmark — Part 1 §17.13.6.2 (bookmarkStart).
/// Extends CT_BookmarkRange with the required `@name` (s:ST_String)
/// that identifies the bookmark for the matching `bookmarkEnd`.
pub(all) struct CT_Bookmark {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §17.18.14 @displacedByCustomXml (ST_DisplacedByCustomXml) — optional.
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
  /// §17.18.10 @colFirst (ST_DecimalNumber) — optional first-column anchor.
  col_first : ST_DecimalNumber?
  /// §17.18.10 @colLast (ST_DecimalNumber) — optional last-column anchor.
  col_last : ST_DecimalNumber?
  /// §22.9.2.13 @name (s:ST_String) — required bookmark identifier.
  name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Bookmark — Part 1 §17.13.6.2.
pub fn CT_Bookmark::new(
  element : @xml.Element,
) -> CT_Bookmark raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_Bookmark", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let displaced_by_custom_xml = match
    wml_ct_chunk1_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  let col_first = match wml_ct_chunk1_attr(element, "colFirst") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let col_last = match wml_ct_chunk1_attr(element, "colLast") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let name = wml_ct_chunk1_required_attr(
    element, "name", "CT_Bookmark", "Part 1 §22.9.2.13 s:ST_String",
  )
  { element, id, displaced_by_custom_xml, col_first, col_last, name }
}

///|
/// XSD complex type CT_Bookmark — Part 1 §17.13.6.2.
pub fn CT_Bookmark::parse(
  element : @xml.Element,
) -> CT_Bookmark raise SchemaViolation {
  CT_Bookmark::new(element)
}

///|
/// XSD complex type CT_Bookmark — return the preserved element for
/// writers.
pub fn CT_Bookmark::to_element(self : CT_Bookmark) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MoveBookmark — Part 1 §17.13.5.22/26
/// (moveFromRangeStart, moveToRangeStart). Extends CT_Bookmark with
/// required revision authorship (`@author` s:ST_String, `@date`
/// ST_DateTime §17.18.9).
pub(all) struct CT_MoveBookmark {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §17.18.14 @displacedByCustomXml (ST_DisplacedByCustomXml) — optional.
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
  /// §17.18.10 @colFirst (ST_DecimalNumber) — optional first-column anchor.
  col_first : ST_DecimalNumber?
  /// §17.18.10 @colLast (ST_DecimalNumber) — optional last-column anchor.
  col_last : ST_DecimalNumber?
  /// §22.9.2.13 @name (s:ST_String) — required bookmark identifier.
  name : String
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — required revision timestamp.
  date : ST_DateTime
} derive(Eq, Debug)

///|
/// XSD complex type CT_MoveBookmark — Part 1 §17.13.5.22/26.
pub fn CT_MoveBookmark::new(
  element : @xml.Element,
) -> CT_MoveBookmark raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_MoveBookmark", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let displaced_by_custom_xml = match
    wml_ct_chunk1_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  let col_first = match wml_ct_chunk1_attr(element, "colFirst") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let col_last = match wml_ct_chunk1_attr(element, "colLast") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let name = wml_ct_chunk1_required_attr(
    element, "name", "CT_MoveBookmark", "Part 1 §22.9.2.13 s:ST_String",
  )
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_MoveBookmark", "Part 1 §22.9.2.13 s:ST_String",
  )
  let raw_date = wml_ct_chunk1_required_attr(
    element, "date", "CT_MoveBookmark", "Part 1 §17.18.9 ST_DateTime",
  )
  let date = ST_DateTime::parse(raw_date)
  {
    element,
    id,
    displaced_by_custom_xml,
    col_first,
    col_last,
    name,
    author,
    date,
  }
}

///|
/// XSD complex type CT_MoveBookmark — Part 1 §17.13.5.22/26.
pub fn CT_MoveBookmark::parse(
  element : @xml.Element,
) -> CT_MoveBookmark raise SchemaViolation {
  CT_MoveBookmark::new(element)
}

///|
/// XSD complex type CT_MoveBookmark — return the preserved element for
/// writers.
pub fn CT_MoveBookmark::to_element(self : CT_MoveBookmark) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Comment — Part 1 §17.13.4.2 (comment Comment
/// Content). Extends CT_TrackChange with the comment-author initials
/// `@initials` and a sequence of EG_BlockLevelElts children carrying
/// the comment body. The block-level group is preserved as raw element
/// children — typed projection of EG_BlockLevelElts is owned by the
/// content-tree readers, not this CT.
pub(all) struct CT_Comment {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// §22.9.2.13 @initials (s:ST_String) — optional author initials.
  initials : String?
  /// EG_BlockLevelElts* — zero or more block-level child elements
  /// carrying the comment body, preserved raw.
  block_level_elements : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Comment — Part 1 §17.13.4.2.
pub fn CT_Comment::new(
  element : @xml.Element,
) -> CT_Comment raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_Comment", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_Comment", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let initials = wml_ct_chunk1_attr(element, "initials")
  let block_level_elements = wml_ct_chunk2_element_children(element)
  { element, id, author, date, initials, block_level_elements }
}

///|
/// XSD complex type CT_Comment — Part 1 §17.13.4.2.
pub fn CT_Comment::parse(
  element : @xml.Element,
) -> CT_Comment raise SchemaViolation {
  CT_Comment::new(element)
}

///|
/// XSD complex type CT_Comment — return the preserved element for
/// writers.
pub fn CT_Comment::to_element(self : CT_Comment) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrExChange — Part 1 §17.13.5.35
/// (tblPrExChange Revision Information for Table-Level Property
/// Exceptions). Extends CT_TrackChange with a required `<tblPrEx>`
/// (CT_TblPrExBase, §17.4.62 base) snapshot of the previously-applied
/// table-level property exceptions.
pub(all) struct CT_TblPrExChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <tblPrEx> (CT_TblPrExBase) — required snapshot.
  tbl_pr_ex : CT_TblPrExBase
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblPrExChange — Part 1 §17.13.5.35.
pub fn CT_TblPrExChange::new(
  element : @xml.Element,
) -> CT_TblPrExChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TblPrExChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_TblPrExChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let tbl_pr_ex = match wml_ct_chunk2_first_child(element, "tblPrEx") {
    Some(child) => CT_TblPrExBase::new(child)
    None =>
      raise_schema_violation(
        "CT_TblPrExChange", "tblPrEx", "Part 1 §17.13.5.35: required child <w:tblPrEx> is missing",
      )
  }
  { element, id, author, date, tbl_pr_ex }
}

///|
/// XSD complex type CT_TblPrExChange — Part 1 §17.13.5.35.
pub fn CT_TblPrExChange::parse(
  element : @xml.Element,
) -> CT_TblPrExChange raise SchemaViolation {
  CT_TblPrExChange::new(element)
}

///|
/// XSD complex type CT_TblPrExChange — return the preserved element
/// for writers.
pub fn CT_TblPrExChange::to_element(self : CT_TblPrExChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TcPrChange — Part 1 §17.13.5.36 (tcPrChange
/// Revision Information for Table Cell Properties). Extends
/// CT_TrackChange with a required `<tcPr>` (CT_TcPrInner, §17.4.69
/// base) snapshot of the cell properties that were active before the
/// revision.
pub(all) struct CT_TcPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <tcPr> (CT_TcPrInner) — required snapshot.
  tc_pr : CT_TcPrInner
} derive(Eq, Debug)

///|
/// XSD complex type CT_TcPrChange — Part 1 §17.13.5.36.
pub fn CT_TcPrChange::new(
  element : @xml.Element,
) -> CT_TcPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TcPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_TcPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let tc_pr = match wml_ct_chunk2_first_child(element, "tcPr") {
    Some(child) => CT_TcPrInner::new(child)
    None =>
      raise_schema_violation(
        "CT_TcPrChange", "tcPr", "Part 1 §17.13.5.36: required child <w:tcPr> is missing",
      )
  }
  { element, id, author, date, tc_pr }
}

///|
/// XSD complex type CT_TcPrChange — Part 1 §17.13.5.36.
pub fn CT_TcPrChange::parse(
  element : @xml.Element,
) -> CT_TcPrChange raise SchemaViolation {
  CT_TcPrChange::new(element)
}

///|
/// XSD complex type CT_TcPrChange — return the preserved element for
/// writers.
pub fn CT_TcPrChange::to_element(self : CT_TcPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TrPrChange — Part 1 §17.13.5.37 (trPrChange
/// Revision Information for Table Row Properties). Extends
/// CT_TrackChange with a required `<trPr>` (CT_TrPrBase, §17.4.81
/// base) snapshot of the table-row properties active before the
/// revision.
pub(all) struct CT_TrPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <trPr> (CT_TrPrBase) — required snapshot.
  tr_pr : CT_TrPrBase
} derive(Eq, Debug)

///|
/// XSD complex type CT_TrPrChange — Part 1 §17.13.5.37.
pub fn CT_TrPrChange::new(
  element : @xml.Element,
) -> CT_TrPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TrPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_TrPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let tr_pr = match wml_ct_chunk2_first_child(element, "trPr") {
    Some(child) => CT_TrPrBase::new(child)
    None =>
      raise_schema_violation(
        "CT_TrPrChange", "trPr", "Part 1 §17.13.5.37: required child <w:trPr> is missing",
      )
  }
  { element, id, author, date, tr_pr }
}

///|
/// XSD complex type CT_TrPrChange — Part 1 §17.13.5.37.
pub fn CT_TrPrChange::parse(
  element : @xml.Element,
) -> CT_TrPrChange raise SchemaViolation {
  CT_TrPrChange::new(element)
}

///|
/// XSD complex type CT_TrPrChange — return the preserved element for
/// writers.
pub fn CT_TrPrChange::to_element(self : CT_TrPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblGridChange — Part 1 §17.13.5.33
/// (tblGridChange Revision Information for Table Grid Column
/// Definitions). Extends CT_Markup (not CT_TrackChange — the schema
/// does not record author/date here) with a required `<tblGrid>`
/// (CT_TblGridBase, §17.4.49 base) snapshot of the previous grid.
pub(all) struct CT_TblGridChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// <tblGrid> (CT_TblGridBase) — required snapshot.
  tbl_grid : CT_TblGridBase
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblGridChange — Part 1 §17.13.5.33.
pub fn CT_TblGridChange::new(
  element : @xml.Element,
) -> CT_TblGridChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TblGridChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let tbl_grid = match wml_ct_chunk2_first_child(element, "tblGrid") {
    Some(child) => CT_TblGridBase::new(child)
    None =>
      raise_schema_violation(
        "CT_TblGridChange", "tblGrid", "Part 1 §17.13.5.33: required child <w:tblGrid> is missing",
      )
  }
  { element, id, tbl_grid }
}

///|
/// XSD complex type CT_TblGridChange — Part 1 §17.13.5.33.
pub fn CT_TblGridChange::parse(
  element : @xml.Element,
) -> CT_TblGridChange raise SchemaViolation {
  CT_TblGridChange::new(element)
}

///|
/// XSD complex type CT_TblGridChange — return the preserved element
/// for writers.
pub fn CT_TblGridChange::to_element(self : CT_TblGridChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TblPrChange — Part 1 §17.13.5.34 (tblPrChange
/// Revision Information for Table Properties). Extends CT_TrackChange
/// with a required `<tblPr>` (CT_TblPrBase, §17.4.61 base) snapshot
/// of the previous table-level properties.
pub(all) struct CT_TblPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <tblPr> (CT_TblPrBase) — required snapshot.
  tbl_pr : CT_TblPrBase
} derive(Eq, Debug)

///|
/// XSD complex type CT_TblPrChange — Part 1 §17.13.5.34.
pub fn CT_TblPrChange::new(
  element : @xml.Element,
) -> CT_TblPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_TblPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_TblPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let tbl_pr = match wml_ct_chunk2_first_child(element, "tblPr") {
    Some(child) => CT_TblPrBase::new(child)
    None =>
      raise_schema_violation(
        "CT_TblPrChange", "tblPr", "Part 1 §17.13.5.34: required child <w:tblPr> is missing",
      )
  }
  { element, id, author, date, tbl_pr }
}

///|
/// XSD complex type CT_TblPrChange — Part 1 §17.13.5.34.
pub fn CT_TblPrChange::parse(
  element : @xml.Element,
) -> CT_TblPrChange raise SchemaViolation {
  CT_TblPrChange::new(element)
}

///|
/// XSD complex type CT_TblPrChange — return the preserved element for
/// writers.
pub fn CT_TblPrChange::to_element(self : CT_TblPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPrChange — Part 1 §17.13.5.32
/// (sectPrChange Revision Information for Section Properties). Extends
/// CT_TrackChange with an optional `<sectPr>` (CT_SectPrBase, §17.6.18
/// base) snapshot of the previous section properties.
pub(all) struct CT_SectPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <sectPr> (CT_SectPrBase) — optional snapshot (minOccurs=0).
  sect_pr : CT_SectPrBase?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SectPrChange — Part 1 §17.13.5.32.
pub fn CT_SectPrChange::new(
  element : @xml.Element,
) -> CT_SectPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_SectPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_SectPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let sect_pr = match wml_ct_chunk2_first_child(element, "sectPr") {
    Some(child) => Some(CT_SectPrBase::new(child))
    None => None
  }
  { element, id, author, date, sect_pr }
}

///|
/// XSD complex type CT_SectPrChange — Part 1 §17.13.5.32.
pub fn CT_SectPrChange::parse(
  element : @xml.Element,
) -> CT_SectPrChange raise SchemaViolation {
  CT_SectPrChange::new(element)
}

///|
/// XSD complex type CT_SectPrChange — return the preserved element
/// for writers.
pub fn CT_SectPrChange::to_element(self : CT_SectPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrChange — Part 1 §17.13.5.29 (pPrChange
/// Revision Information for Paragraph Properties). Extends
/// CT_TrackChange with a required `<pPr>` (CT_PPrBase, §17.3.1.26
/// base) snapshot of the previous paragraph properties.
pub(all) struct CT_PPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <pPr> (CT_PPrBase) — required snapshot.
  p_pr : CT_PPrBase
} derive(Eq, Debug)

///|
/// XSD complex type CT_PPrChange — Part 1 §17.13.5.29.
pub fn CT_PPrChange::new(
  element : @xml.Element,
) -> CT_PPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_PPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_PPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let p_pr = match wml_ct_chunk2_first_child(element, "pPr") {
    Some(child) => CT_PPrBase::new(child)
    None =>
      raise_schema_violation(
        "CT_PPrChange", "pPr", "Part 1 §17.13.5.29: required child <w:pPr> is missing",
      )
  }
  { element, id, author, date, p_pr }
}

///|
/// XSD complex type CT_PPrChange — Part 1 §17.13.5.29.
pub fn CT_PPrChange::parse(
  element : @xml.Element,
) -> CT_PPrChange raise SchemaViolation {
  CT_PPrChange::new(element)
}

///|
/// XSD complex type CT_PPrChange — return the preserved element for
/// writers.
pub fn CT_PPrChange::to_element(self : CT_PPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrChange — Part 1 §17.13.5.31 (rPrChange
/// Revision Information for Run Properties). Extends CT_TrackChange
/// with a required `<rPr>` (CT_RPrOriginal, §17.3.2.28 original
/// snapshot) recording the run properties before the revision.
pub(all) struct CT_RPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <rPr> (CT_RPrOriginal) — required snapshot.
  r_pr : CT_RPrOriginal
} derive(Eq, Debug)

///|
/// XSD complex type CT_RPrChange — Part 1 §17.13.5.31.
pub fn CT_RPrChange::new(
  element : @xml.Element,
) -> CT_RPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_RPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_RPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let r_pr = match wml_ct_chunk2_first_child(element, "rPr") {
    Some(child) => CT_RPrOriginal::new(child)
    None =>
      raise_schema_violation(
        "CT_RPrChange", "rPr", "Part 1 §17.13.5.31: required child <w:rPr> is missing",
      )
  }
  { element, id, author, date, r_pr }
}

///|
/// XSD complex type CT_RPrChange — Part 1 §17.13.5.31.
pub fn CT_RPrChange::parse(
  element : @xml.Element,
) -> CT_RPrChange raise SchemaViolation {
  CT_RPrChange::new(element)
}

///|
/// XSD complex type CT_RPrChange — return the preserved element for
/// writers.
pub fn CT_RPrChange::to_element(self : CT_RPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPrChange — Part 1 §17.13.5.30 (rPrChange
/// Revision Information for Run Properties on the Paragraph Mark).
/// Extends CT_TrackChange with a required `<rPr>` (CT_ParaRPrOriginal,
/// §17.3.1.30 original snapshot) capturing the paragraph-mark run
/// properties before the revision.
pub(all) struct CT_ParaRPrChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// <rPr> (CT_ParaRPrOriginal) — required snapshot.
  r_pr : CT_ParaRPrOriginal
} derive(Eq, Debug)

///|
/// XSD complex type CT_ParaRPrChange — Part 1 §17.13.5.30.
pub fn CT_ParaRPrChange::new(
  element : @xml.Element,
) -> CT_ParaRPrChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_ParaRPrChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_ParaRPrChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let r_pr = match wml_ct_chunk2_first_child(element, "rPr") {
    Some(child) => CT_ParaRPrOriginal::new(child)
    None =>
      raise_schema_violation(
        "CT_ParaRPrChange", "rPr", "Part 1 §17.13.5.30: required child <w:rPr> is missing",
      )
  }
  { element, id, author, date, r_pr }
}

///|
/// XSD complex type CT_ParaRPrChange — Part 1 §17.13.5.30.
pub fn CT_ParaRPrChange::parse(
  element : @xml.Element,
) -> CT_ParaRPrChange raise SchemaViolation {
  CT_ParaRPrChange::new(element)
}

///|
/// XSD complex type CT_ParaRPrChange — return the preserved element for
/// writers.
pub fn CT_ParaRPrChange::to_element(self : CT_ParaRPrChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RunTrackChange — Part 1 §17.13.5.14/15/18
/// (del Deleted Run Content, ins Inserted Run Content, and the math
/// control-character revisions §17.13.5.13/16). Extends CT_TrackChange
/// with a zero-or-more `xsd:choice` over EG_ContentRunContent and
/// `m:EG_OMathMathElements`; the choice content is preserved as raw
/// element children since the typed projection is owned by the
/// content-tree readers and the office_math domain package.
pub(all) struct CT_RunTrackChange {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @id (ST_DecimalNumber) — required revision identifier.
  id : ST_DecimalNumber
  /// §22.9.2.13 @author (s:ST_String) — required revision author.
  author : String
  /// §17.18.9 @date (ST_DateTime) — optional revision timestamp.
  date : ST_DateTime?
  /// EG_ContentRunContent ∪ m:EG_OMathMathElements * — zero or more
  /// run-content / OMath child elements, preserved raw.
  run_content : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_RunTrackChange — Part 1 §17.13.5.14/15/18.
pub fn CT_RunTrackChange::new(
  element : @xml.Element,
) -> CT_RunTrackChange raise SchemaViolation {
  let raw_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_RunTrackChange", "Part 1 §17.18.10 ST_DecimalNumber",
  )
  let id = ST_DecimalNumber::parse(raw_id)
  let author = wml_ct_chunk1_required_attr(
    element, "author", "CT_RunTrackChange", "Part 1 §22.9.2.13 s:ST_String",
  )
  let date = match wml_ct_chunk1_attr(element, "date") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  let run_content = wml_ct_chunk2_element_children(element)
  { element, id, author, date, run_content }
}

///|
/// XSD complex type CT_RunTrackChange — Part 1 §17.13.5.14/15/18.
pub fn CT_RunTrackChange::parse(
  element : @xml.Element,
) -> CT_RunTrackChange raise SchemaViolation {
  CT_RunTrackChange::new(element)
}

///|
/// XSD complex type CT_RunTrackChange — return the preserved element
/// for writers.
pub fn CT_RunTrackChange::to_element(self : CT_RunTrackChange) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_NumPr — Part 1 §17.3.1.19 (numPr Numbering
/// Definition Instance Reference). Three optional children: `<ilvl>`
/// (CT_DecimalNumber list-level), `<numId>` (CT_DecimalNumber pointer
/// to a numbering definition in numbering.xml) and `<ins>` (CT_TrackChange
/// inserted-numbering revision marker, §17.13.5.19).
pub(all) struct CT_NumPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// <ilvl> (CT_DecimalNumber) — optional list level.
  ilvl : CT_DecimalNumber?
  /// <numId> (CT_DecimalNumber) — optional numbering definition id.
  num_id : CT_DecimalNumber?
  /// <ins> (CT_TrackChange) — optional inserted-numbering revision.
  ins : CT_TrackChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_NumPr — Part 1 §17.3.1.19.
pub fn CT_NumPr::new(element : @xml.Element) -> CT_NumPr raise SchemaViolation {
  let ilvl = match wml_ct_chunk2_first_child(element, "ilvl") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let num_id = match wml_ct_chunk2_first_child(element, "numId") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let ins = match wml_ct_chunk2_first_child(element, "ins") {
    Some(child) => Some(CT_TrackChange::new(child))
    None => None
  }
  { element, ilvl, num_id, ins }
}

///|
/// XSD complex type CT_NumPr — Part 1 §17.3.1.19.
pub fn CT_NumPr::parse(
  element : @xml.Element,
) -> CT_NumPr raise SchemaViolation {
  CT_NumPr::new(element)
}

///|
/// XSD complex type CT_NumPr — return the preserved element for writers.
pub fn CT_NumPr::to_element(self : CT_NumPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PBdr — Part 1 §17.3.1.24 (pBdr Paragraph
/// Borders). Six optional `<top>` / `<left>` / `<bottom>` / `<right>` /
/// `<between>` / `<bar>` children, each a CT_Border (§17.3.4).
pub(all) struct CT_PBdr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// <top> (CT_Border) — optional top border.
  top : CT_Border?
  /// <left> (CT_Border) — optional leading-edge border.
  left : CT_Border?
  /// <bottom> (CT_Border) — optional bottom border.
  bottom : CT_Border?
  /// <right> (CT_Border) — optional trailing-edge border.
  right : CT_Border?
  /// <between> (CT_Border) — optional between-paragraph border.
  between : CT_Border?
  /// <bar> (CT_Border) — optional revision-bar border.
  bar : CT_Border?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PBdr — Part 1 §17.3.1.24.
pub fn CT_PBdr::new(element : @xml.Element) -> CT_PBdr raise SchemaViolation {
  let top = match wml_ct_chunk2_first_child(element, "top") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let left = match wml_ct_chunk2_first_child(element, "left") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let bottom = match wml_ct_chunk2_first_child(element, "bottom") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let right = match wml_ct_chunk2_first_child(element, "right") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let between = match wml_ct_chunk2_first_child(element, "between") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  let bar = match wml_ct_chunk2_first_child(element, "bar") {
    Some(child) => Some(CT_Border::new(child))
    None => None
  }
  { element, top, left, bottom, right, between, bar }
}

///|
/// XSD complex type CT_PBdr — Part 1 §17.3.1.24.
pub fn CT_PBdr::parse(element : @xml.Element) -> CT_PBdr raise SchemaViolation {
  CT_PBdr::new(element)
}

///|
/// XSD complex type CT_PBdr — return the preserved element for writers.
pub fn CT_PBdr::to_element(self : CT_PBdr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Tabs — Part 1 §17.3.1.38 (tabs Set of Custom
/// Tab Stops). One or more `<tab>` (CT_TabStop, §17.3.1.37) children
/// listing custom tab positions; schema requires at least one.
pub(all) struct CT_Tabs {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// <tab>+ (CT_TabStop) — one or more custom tabs.
  tab : Array[CT_TabStop]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Tabs — Part 1 §17.3.1.38.
pub fn CT_Tabs::new(element : @xml.Element) -> CT_Tabs raise SchemaViolation {
  let tab : Array[CT_TabStop] = []
  for child in wml_ct_chunk2_children(element, "tab") {
    tab.push(CT_TabStop::new(child))
  }
  if tab.length() == 0 {
    raise_schema_violation(
      "CT_Tabs", "tab", "Part 1 §17.3.1.38: required minimum one <w:tab> child element is missing",
    )
  }
  { element, tab }
}

///|
/// XSD complex type CT_Tabs — Part 1 §17.3.1.38.
pub fn CT_Tabs::parse(element : @xml.Element) -> CT_Tabs raise SchemaViolation {
  CT_Tabs::new(element)
}

///|
/// XSD complex type CT_Tabs — return the preserved element for writers.
pub fn CT_Tabs::to_element(self : CT_Tabs) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TextboxTightWrap — Part 1 §17.3.1.40
/// (textboxTightWrap Allow Surrounding Paragraphs to Tight Wrap to
/// Text Box Contents). Required `@val` ST_TextboxTightWrap ∈
/// {none, allLines, firstAndLastLine, firstLineOnly, lastLineOnly}.
pub(all) struct CT_TextboxTightWrap {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.99 @val (ST_TextboxTightWrap) — required tight-wrap mode.
  val : ST_TextboxTightWrap
} derive(Eq, Debug)

///|
/// XSD complex type CT_TextboxTightWrap — Part 1 §17.3.1.40.
pub fn CT_TextboxTightWrap::new(
  element : @xml.Element,
) -> CT_TextboxTightWrap raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_TextboxTightWrap", "Part 1 §17.18.99 ST_TextboxTightWrap",
  )
  let val = ST_TextboxTightWrap::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_TextboxTightWrap — Part 1 §17.3.1.40.
pub fn CT_TextboxTightWrap::parse(
  element : @xml.Element,
) -> CT_TextboxTightWrap raise SchemaViolation {
  CT_TextboxTightWrap::new(element)
}

///|
/// XSD complex type CT_TextboxTightWrap — return the preserved element
/// for writers.
pub fn CT_TextboxTightWrap::to_element(
  self : CT_TextboxTightWrap,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPr — Part 1 §17.3.1.25 (pPr Paragraph
/// Properties). Extends CT_PPrBase with three additional optional
/// trailers: `<rPr>` (CT_ParaRPr §17.3.1.30 paragraph-mark run
/// properties), `<sectPr>` (CT_SectPr §17.6.17 inline section
/// properties), and `<pPrChange>` (CT_PPrChange §17.13.5.29 previous
/// paragraph-properties snapshot).
pub(all) struct CT_PPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// CT_PPrBase content — preserved via the source element. The full
  /// property-set is decoded by `base` for callers that want the
  /// typed base view without re-parsing.
  base : CT_PPrBase
  /// <rPr> (CT_ParaRPr) — optional paragraph-mark run properties.
  r_pr : CT_ParaRPr?
  /// <sectPr> (CT_SectPr) — optional inline section properties.
  sect_pr : CT_SectPr?
  /// <pPrChange> (CT_PPrChange) — optional previous-properties snapshot.
  p_pr_change : CT_PPrChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PPr — Part 1 §17.3.1.25.
pub fn CT_PPr::new(element : @xml.Element) -> CT_PPr raise SchemaViolation {
  let base = CT_PPrBase::new(element)
  let r_pr = match wml_ct_chunk2_first_child(element, "rPr") {
    Some(child) => Some(CT_ParaRPr::new(child))
    None => None
  }
  let sect_pr = match wml_ct_chunk2_first_child(element, "sectPr") {
    Some(child) => Some(CT_SectPr::new(child))
    None => None
  }
  let p_pr_change = match wml_ct_chunk2_first_child(element, "pPrChange") {
    Some(child) => Some(CT_PPrChange::new(child))
    None => None
  }
  { element, base, r_pr, sect_pr, p_pr_change }
}

///|
/// XSD complex type CT_PPr — Part 1 §17.3.1.25.
pub fn CT_PPr::parse(element : @xml.Element) -> CT_PPr raise SchemaViolation {
  CT_PPr::new(element)
}

///|
/// XSD complex type CT_PPr — return the preserved element for writers.
pub fn CT_PPr::to_element(self : CT_PPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrBase — Part 1 §17.3.1.26 (paragraph property
/// base type). The shared base for `<pPr>` (§17.3.1.25 CT_PPr), the
/// document-defaults `<pPrDefault>` (§17.7.5.4 CT_PPrGeneral) and the
/// previous-properties snapshot inside `<pPrChange>` (§17.13.5.29).
/// Every child is optional; the table below records every element
/// listed in the wml.xsd sequence verbatim.
pub(all) struct CT_PPrBase {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// <pStyle> (CT_String) — §17.3.1.27 referenced paragraph-style id.
  p_style : CT_String?
  /// <keepNext> (CT_OnOff) — §17.3.1.15 keep-with-next flag.
  keep_next : CT_OnOff?
  /// <keepLines> (CT_OnOff) — §17.3.1.14 keep-lines flag.
  keep_lines : CT_OnOff?
  /// <pageBreakBefore> (CT_OnOff) — §17.3.1.23 page-break-before flag.
  page_break_before : CT_OnOff?
  /// <framePr> (CT_FramePr) — §17.3.1.11 frame properties.
  frame_pr : CT_FramePr?
  /// <widowControl> (CT_OnOff) — §17.3.1.44 widow/orphan-control flag.
  widow_control : CT_OnOff?
  /// <numPr> (CT_NumPr) — §17.3.1.19 numbering-definition reference.
  num_pr : CT_NumPr?
  /// <suppressLineNumbers> (CT_OnOff) — §17.3.1.34 suppress-line-numbers flag.
  suppress_line_numbers : CT_OnOff?
  /// <pBdr> (CT_PBdr) — §17.3.1.24 paragraph borders.
  p_bdr : CT_PBdr?
  /// <shd> (CT_Shd) — §17.3.5 paragraph shading.
  shd : CT_Shd?
  /// <tabs> (CT_Tabs) — §17.3.1.38 custom tab stops.
  tabs : CT_Tabs?
  /// <suppressAutoHyphens> (CT_OnOff) — §17.3.1.35.
  suppress_auto_hyphens : CT_OnOff?
  /// <kinsoku> (CT_OnOff) — §17.3.1.16 use East-Asian typography rules.
  kinsoku : CT_OnOff?
  /// <wordWrap> (CT_OnOff) — §17.3.1.45 word-wrap flag.
  word_wrap : CT_OnOff?
  /// <overflowPunct> (CT_OnOff) — §17.3.1.22 overflow-punctuation flag.
  overflow_punct : CT_OnOff?
  /// <topLinePunct> (CT_OnOff) — §17.3.1.43 top-line-punctuation flag.
  top_line_punct : CT_OnOff?
  /// <autoSpaceDE> (CT_OnOff) — §17.3.1.2 autospace DE flag.
  auto_space_de : CT_OnOff?
  /// <autoSpaceDN> (CT_OnOff) — §17.3.1.3 autospace DN flag.
  auto_space_dn : CT_OnOff?
  /// <bidi> (CT_OnOff) — §17.3.1.6 bidirectional flag.
  bidi : CT_OnOff?
  /// <adjustRightInd> (CT_OnOff) — §17.3.1.1 adjust-right-indent flag.
  adjust_right_ind : CT_OnOff?
  /// <snapToGrid> (CT_OnOff) — §17.3.1.32 snap-to-grid flag.
  snap_to_grid : CT_OnOff?
  /// <spacing> (CT_Spacing) — §17.3.1.33 spacing.
  spacing : CT_Spacing?
  /// <ind> (CT_Ind) — §17.3.1.12 indentation.
  ind : CT_Ind?
  /// <contextualSpacing> (CT_OnOff) — §17.3.1.9 contextual-spacing flag.
  contextual_spacing : CT_OnOff?
  /// <mirrorIndents> (CT_OnOff) — §17.3.1.18 mirror-indents flag.
  mirror_indents : CT_OnOff?
  /// <suppressOverlap> (CT_OnOff) — §17.3.1.36 suppress-overlap flag.
  suppress_overlap : CT_OnOff?
  /// <jc> (CT_Jc) — §17.3.1.13 paragraph alignment.
  jc : CT_Jc?
  /// <textDirection> (CT_TextDirection) — §17.3.1.41.
  text_direction : CT_TextDirection?
  /// <textAlignment> (CT_TextAlignment) — §17.3.1.39.
  text_alignment : CT_TextAlignment?
  /// <textboxTightWrap> (CT_TextboxTightWrap) — §17.3.1.40.
  textbox_tight_wrap : CT_TextboxTightWrap?
  /// <outlineLvl> (CT_DecimalNumber) — §17.3.1.21 outline level.
  outline_lvl : CT_DecimalNumber?
  /// <divId> (CT_DecimalNumber) — §17.3.1.10 HTML-div reference id.
  div_id : CT_DecimalNumber?
  /// <cnfStyle> (CT_Cnf) — §17.3.1.8 conditional-formatting-style toggles.
  cnf_style : CT_Cnf?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PPrBase — Part 1 §17.3.1.26.
pub fn CT_PPrBase::new(
  element : @xml.Element,
) -> CT_PPrBase raise SchemaViolation {
  let p_style = match wml_ct_chunk2_first_child(element, "pStyle") {
    Some(child) => Some(CT_String::new(child))
    None => None
  }
  let keep_next = match wml_ct_chunk2_first_child(element, "keepNext") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let keep_lines = match wml_ct_chunk2_first_child(element, "keepLines") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let page_break_before = match
    wml_ct_chunk2_first_child(element, "pageBreakBefore") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let frame_pr = match wml_ct_chunk2_first_child(element, "framePr") {
    Some(child) => Some(CT_FramePr::new(child))
    None => None
  }
  let widow_control = match wml_ct_chunk2_first_child(element, "widowControl") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let num_pr = match wml_ct_chunk2_first_child(element, "numPr") {
    Some(child) => Some(CT_NumPr::new(child))
    None => None
  }
  let suppress_line_numbers = match
    wml_ct_chunk2_first_child(element, "suppressLineNumbers") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let p_bdr = match wml_ct_chunk2_first_child(element, "pBdr") {
    Some(child) => Some(CT_PBdr::new(child))
    None => None
  }
  let shd = match wml_ct_chunk2_first_child(element, "shd") {
    Some(child) => Some(CT_Shd::new(child))
    None => None
  }
  let tabs = match wml_ct_chunk2_first_child(element, "tabs") {
    Some(child) => Some(CT_Tabs::new(child))
    None => None
  }
  let suppress_auto_hyphens = match
    wml_ct_chunk2_first_child(element, "suppressAutoHyphens") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let kinsoku = match wml_ct_chunk2_first_child(element, "kinsoku") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let word_wrap = match wml_ct_chunk2_first_child(element, "wordWrap") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let overflow_punct = match
    wml_ct_chunk2_first_child(element, "overflowPunct") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let top_line_punct = match
    wml_ct_chunk2_first_child(element, "topLinePunct") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let auto_space_de = match wml_ct_chunk2_first_child(element, "autoSpaceDE") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let auto_space_dn = match wml_ct_chunk2_first_child(element, "autoSpaceDN") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let bidi = match wml_ct_chunk2_first_child(element, "bidi") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let adjust_right_ind = match
    wml_ct_chunk2_first_child(element, "adjustRightInd") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let snap_to_grid = match wml_ct_chunk2_first_child(element, "snapToGrid") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let spacing = match wml_ct_chunk2_first_child(element, "spacing") {
    Some(child) => Some(CT_Spacing::new(child))
    None => None
  }
  let ind = match wml_ct_chunk2_first_child(element, "ind") {
    Some(child) => Some(CT_Ind::new(child))
    None => None
  }
  let contextual_spacing = match
    wml_ct_chunk2_first_child(element, "contextualSpacing") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let mirror_indents = match
    wml_ct_chunk2_first_child(element, "mirrorIndents") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let suppress_overlap = match
    wml_ct_chunk2_first_child(element, "suppressOverlap") {
    Some(child) => Some(CT_OnOff::new(child))
    None => None
  }
  let jc = match wml_ct_chunk2_first_child(element, "jc") {
    Some(child) => Some(CT_Jc::new(child))
    None => None
  }
  let text_direction = match
    wml_ct_chunk2_first_child(element, "textDirection") {
    Some(child) => Some(CT_TextDirection::new(child))
    None => None
  }
  let text_alignment = match
    wml_ct_chunk2_first_child(element, "textAlignment") {
    Some(child) => Some(CT_TextAlignment::new(child))
    None => None
  }
  let textbox_tight_wrap = match
    wml_ct_chunk2_first_child(element, "textboxTightWrap") {
    Some(child) => Some(CT_TextboxTightWrap::new(child))
    None => None
  }
  let outline_lvl = match wml_ct_chunk2_first_child(element, "outlineLvl") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let div_id = match wml_ct_chunk2_first_child(element, "divId") {
    Some(child) => Some(CT_DecimalNumber::new(child))
    None => None
  }
  let cnf_style = match wml_ct_chunk2_first_child(element, "cnfStyle") {
    Some(child) => Some(CT_Cnf::new(child))
    None => None
  }
  {
    element,
    p_style,
    keep_next,
    keep_lines,
    page_break_before,
    frame_pr,
    widow_control,
    num_pr,
    suppress_line_numbers,
    p_bdr,
    shd,
    tabs,
    suppress_auto_hyphens,
    kinsoku,
    word_wrap,
    overflow_punct,
    top_line_punct,
    auto_space_de,
    auto_space_dn,
    bidi,
    adjust_right_ind,
    snap_to_grid,
    spacing,
    ind,
    contextual_spacing,
    mirror_indents,
    suppress_overlap,
    jc,
    text_direction,
    text_alignment,
    textbox_tight_wrap,
    outline_lvl,
    div_id,
    cnf_style,
  }
}

///|
/// XSD complex type CT_PPrBase — Part 1 §17.3.1.26.
pub fn CT_PPrBase::parse(
  element : @xml.Element,
) -> CT_PPrBase raise SchemaViolation {
  CT_PPrBase::new(element)
}

///|
/// XSD complex type CT_PPrBase — return the preserved element for
/// writers.
pub fn CT_PPrBase::to_element(self : CT_PPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PPrGeneral — Part 1 §17.7.5.4 (pPrDefault
/// Default Paragraph Property Container). Extends CT_PPrBase with an
/// optional trailing `<pPrChange>` (CT_PPrChange §17.13.5.29) snapshot
/// of the previous default paragraph properties.
pub(all) struct CT_PPrGeneral {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// CT_PPrBase content — decoded for the typed base view.
  base : CT_PPrBase
  /// <pPrChange> (CT_PPrChange) — optional previous-properties snapshot.
  p_pr_change : CT_PPrChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PPrGeneral — Part 1 §17.7.5.4.
pub fn CT_PPrGeneral::new(
  element : @xml.Element,
) -> CT_PPrGeneral raise SchemaViolation {
  let base = CT_PPrBase::new(element)
  let p_pr_change = match wml_ct_chunk2_first_child(element, "pPrChange") {
    Some(child) => Some(CT_PPrChange::new(child))
    None => None
  }
  { element, base, p_pr_change }
}

///|
/// XSD complex type CT_PPrGeneral — Part 1 §17.7.5.4.
pub fn CT_PPrGeneral::parse(
  element : @xml.Element,
) -> CT_PPrGeneral raise SchemaViolation {
  CT_PPrGeneral::new(element)
}

///|
/// XSD complex type CT_PPrGeneral — return the preserved element for
/// writers.
pub fn CT_PPrGeneral::to_element(self : CT_PPrGeneral) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Control — Part 1 §17.3.3.3 (control Embedded
/// Control). Three optional attributes: friendly `@name`, VML
/// `@shapeid`, and the relationship `@r:id` (xsd:attribute ref="r:id")
/// pointing at the persisted control binary.
pub(all) struct CT_Control {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @name (s:ST_String) — optional friendly name.
  name : String?
  /// §22.9.2.13 @shapeid (s:ST_String) — optional VML shape id.
  shapeid : String?
  /// @r:id (ST_RelationshipId) — optional relationship reference.
  r_id : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Control — Part 1 §17.3.3.3.
pub fn CT_Control::new(element : @xml.Element) -> CT_Control {
  let name = wml_ct_chunk1_attr(element, "name")
  let shapeid = wml_ct_chunk1_attr(element, "shapeid")
  let r_id = wml_ct_chunk1_attr(element, "id")
  { element, name, shapeid, r_id }
}

///|
/// XSD complex type CT_Control — Part 1 §17.3.3.3.
pub fn CT_Control::parse(element : @xml.Element) -> CT_Control {
  CT_Control::new(element)
}

///|
/// XSD complex type CT_Control — return the preserved element for
/// writers.
pub fn CT_Control::to_element(self : CT_Control) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Background — Part 1 §17.2.1 (background
/// Document Background). Optional `<drawing>` (CT_Drawing) painted
/// behind the document body, plus four optional colour attributes:
/// `@color` (ST_HexColor §17.18.38, schema-default `auto`),
/// `@themeColor` (ST_ThemeColor §17.18.97), `@themeTint` /
/// `@themeShade` (ST_UcharHexNumber §17.18.98).
pub(all) struct CT_Background {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// <drawing> (CT_Drawing) — optional background drawing.
  drawing : CT_Drawing?
  /// §17.18.38 @color (ST_HexColor) — optional; default `auto`.
  color : ST_HexColor?
  /// §17.18.97 @themeColor (ST_ThemeColor) — optional theme reference.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint (ST_UcharHexNumber) — optional tint.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade (ST_UcharHexNumber) — optional shade.
  theme_shade : ST_UcharHexNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Background — Part 1 §17.2.1.
pub fn CT_Background::new(
  element : @xml.Element,
) -> CT_Background raise SchemaViolation {
  let drawing = match wml_ct_chunk2_first_child(element, "drawing") {
    Some(child) => Some(CT_Drawing::new(child))
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
  { element, drawing, color, theme_color, theme_tint, theme_shade }
}

///|
/// XSD complex type CT_Background — Part 1 §17.2.1.
pub fn CT_Background::parse(
  element : @xml.Element,
) -> CT_Background raise SchemaViolation {
  CT_Background::new(element)
}

///|
/// XSD complex type CT_Background — return the preserved element for
/// writers.
pub fn CT_Background::to_element(self : CT_Background) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Rel — Part 1 §A.1 (wml.xsd, shared relationship
/// holder used by `<movie>` inside `<object>` per §17.3.3.20). Single
/// required `@r:id` relationship reference (ST_RelationshipId).
pub(all) struct CT_Rel {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// @r:id (ST_RelationshipId) — required relationship reference.
  r_id : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Rel — Part 1 §A.1.
pub fn CT_Rel::new(element : @xml.Element) -> CT_Rel raise SchemaViolation {
  let r_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_Rel", "Part 1 §A.1 r:id (ST_RelationshipId)",
  )
  { element, r_id }
}

///|
/// XSD complex type CT_Rel — Part 1 §A.1.
pub fn CT_Rel::parse(element : @xml.Element) -> CT_Rel raise SchemaViolation {
  CT_Rel::new(element)
}

///|
/// XSD complex type CT_Rel — return the preserved element for writers.
pub fn CT_Rel::to_element(self : CT_Rel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Object — Part 1 §17.3.3.19 (object Embedded
/// Object). Sequence: optional `<drawing>` (CT_Drawing) followed by an
/// optional xsd:choice between `<control>` (CT_Control), `<objectLink>`
/// (CT_ObjectLink), `<objectEmbed>` (CT_ObjectEmbed) and `<movie>`
/// (CT_Rel). Two optional twip-measure size hints (`@dxaOrig`,
/// `@dyaOrig`, s:ST_TwipsMeasure).
pub(all) struct CT_Object {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// <drawing> (CT_Drawing) — optional drawing surrogate.
  drawing : CT_Drawing?
  /// <control> (CT_Control) — optional ActiveX-control child.
  control : CT_Control?
  /// <objectLink> (CT_ObjectLink) — optional OLE-link child.
  object_link : CT_ObjectLink?
  /// <objectEmbed> (CT_ObjectEmbed) — optional OLE-embed child.
  object_embed : CT_ObjectEmbed?
  /// <movie> (CT_Rel) — optional movie-relationship child.
  movie : CT_Rel?
  /// §22.9.2.10 @dxaOrig (s:ST_TwipsMeasure) — optional original width.
  dxa_orig : String?
  /// §22.9.2.10 @dyaOrig (s:ST_TwipsMeasure) — optional original height.
  dya_orig : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Object — Part 1 §17.3.3.19.
pub fn CT_Object::new(
  element : @xml.Element,
) -> CT_Object raise SchemaViolation {
  let drawing = match wml_ct_chunk2_first_child(element, "drawing") {
    Some(child) => Some(CT_Drawing::new(child))
    None => None
  }
  let control = match wml_ct_chunk2_first_child(element, "control") {
    Some(child) => Some(CT_Control::new(child))
    None => None
  }
  let object_link = match wml_ct_chunk2_first_child(element, "objectLink") {
    Some(child) => Some(CT_ObjectLink::new(child))
    None => None
  }
  let object_embed = match wml_ct_chunk2_first_child(element, "objectEmbed") {
    Some(child) => Some(CT_ObjectEmbed::new(child))
    None => None
  }
  let movie = match wml_ct_chunk2_first_child(element, "movie") {
    Some(child) => Some(CT_Rel::new(child))
    None => None
  }
  let dxa_orig = wml_ct_chunk1_attr(element, "dxaOrig")
  let dya_orig = wml_ct_chunk1_attr(element, "dyaOrig")
  {
    element,
    drawing,
    control,
    object_link,
    object_embed,
    movie,
    dxa_orig,
    dya_orig,
  }
}

///|
/// XSD complex type CT_Object — Part 1 §17.3.3.19.
pub fn CT_Object::parse(
  element : @xml.Element,
) -> CT_Object raise SchemaViolation {
  CT_Object::new(element)
}

///|
/// XSD complex type CT_Object — return the preserved element for writers.
pub fn CT_Object::to_element(self : CT_Object) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectEmbed — Part 1 §17.3.3.16 (objectEmbed
/// Embedded Object Properties). Required `@r:id` relationship
/// reference plus four optional attributes describing how the host
/// should render the OLE container.
pub(all) struct CT_ObjectEmbed {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.59 @drawAspect (ST_ObjectDrawAspect) — optional render mode.
  draw_aspect : ST_ObjectDrawAspect?
  /// @r:id (ST_RelationshipId) — required relationship reference.
  r_id : String
  /// §22.9.2.13 @progId (s:ST_String) — optional OLE programmatic id.
  prog_id : String?
  /// §22.9.2.13 @shapeId (s:ST_String) — optional VML shape id.
  shape_id : String?
  /// §22.9.2.13 @fieldCodes (s:ST_String) — optional field codes.
  field_codes : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_ObjectEmbed — Part 1 §17.3.3.16.
pub fn CT_ObjectEmbed::new(
  element : @xml.Element,
) -> CT_ObjectEmbed raise SchemaViolation {
  let draw_aspect = match wml_ct_chunk1_attr(element, "drawAspect") {
    Some(text) => Some(ST_ObjectDrawAspect::parse(text))
    None => None
  }
  let r_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_ObjectEmbed", "Part 1 §A.1 r:id (ST_RelationshipId)",
  )
  let prog_id = wml_ct_chunk1_attr(element, "progId")
  let shape_id = wml_ct_chunk1_attr(element, "shapeId")
  let field_codes = wml_ct_chunk1_attr(element, "fieldCodes")
  { element, draw_aspect, r_id, prog_id, shape_id, field_codes }
}

///|
/// XSD complex type CT_ObjectEmbed — Part 1 §17.3.3.16.
pub fn CT_ObjectEmbed::parse(
  element : @xml.Element,
) -> CT_ObjectEmbed raise SchemaViolation {
  CT_ObjectEmbed::new(element)
}

///|
/// XSD complex type CT_ObjectEmbed — return the preserved element for
/// writers.
pub fn CT_ObjectEmbed::to_element(self : CT_ObjectEmbed) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ObjectLink — Part 1 §17.3.3.18 (objectLink
/// Linked Object Properties). Extends CT_ObjectEmbed with a required
/// `@updateMode` (ST_ObjectUpdateMode §17.18.60) and an optional
/// `@lockedField` (s:ST_OnOff) toggle.
pub(all) struct CT_ObjectLink {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.59 @drawAspect (ST_ObjectDrawAspect) — optional render mode.
  draw_aspect : ST_ObjectDrawAspect?
  /// @r:id (ST_RelationshipId) — required relationship reference.
  r_id : String
  /// §22.9.2.13 @progId (s:ST_String) — optional OLE programmatic id.
  prog_id : String?
  /// §22.9.2.13 @shapeId (s:ST_String) — optional VML shape id.
  shape_id : String?
  /// §22.9.2.13 @fieldCodes (s:ST_String) — optional field codes.
  field_codes : String?
  /// §17.18.60 @updateMode (ST_ObjectUpdateMode) — required update mode.
  update_mode : ST_ObjectUpdateMode
  /// §22.9.2.7 @lockedField (s:ST_OnOff) — optional locked-field flag.
  locked_field : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_ObjectLink — Part 1 §17.3.3.18.
pub fn CT_ObjectLink::new(
  element : @xml.Element,
) -> CT_ObjectLink raise SchemaViolation {
  let draw_aspect = match wml_ct_chunk1_attr(element, "drawAspect") {
    Some(text) => Some(ST_ObjectDrawAspect::parse(text))
    None => None
  }
  let r_id = wml_ct_chunk1_required_attr(
    element, "id", "CT_ObjectLink", "Part 1 §A.1 r:id (ST_RelationshipId)",
  )
  let prog_id = wml_ct_chunk1_attr(element, "progId")
  let shape_id = wml_ct_chunk1_attr(element, "shapeId")
  let field_codes = wml_ct_chunk1_attr(element, "fieldCodes")
  let raw_update_mode = wml_ct_chunk1_required_attr(
    element, "updateMode", "CT_ObjectLink", "Part 1 §17.18.60 ST_ObjectUpdateMode",
  )
  let update_mode = ST_ObjectUpdateMode::parse(raw_update_mode)
  let locked_field = wml_ct_chunk1_on_off(
    wml_ct_chunk1_attr(element, "lockedField"),
  )
  {
    element,
    draw_aspect,
    r_id,
    prog_id,
    shape_id,
    field_codes,
    update_mode,
    locked_field,
  }
}

///|
/// XSD complex type CT_ObjectLink — Part 1 §17.3.3.18.
pub fn CT_ObjectLink::parse(
  element : @xml.Element,
) -> CT_ObjectLink raise SchemaViolation {
  CT_ObjectLink::new(element)
}

///|
/// XSD complex type CT_ObjectLink — return the preserved element for
/// writers.
pub fn CT_ObjectLink::to_element(self : CT_ObjectLink) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Drawing — Part 1 §17.3.3.9 (drawing DrawingML
/// Object). One or more `<wp:anchor>` (CT_Anchor) and/or `<wp:inline>`
/// (CT_Inline) child elements from the WordprocessingDrawing namespace.
/// These DrawingML wrappers are typed in
/// `wordprocessing_drawing_types.mbt`; here they are preserved as raw
/// element children to avoid a cyclic dependency on the drawing
/// reader, and the schema-mandated minimum of one occurrence is
/// validated.
pub(all) struct CT_Drawing {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// EG choice (`<wp:anchor>` | `<wp:inline>`)+ — preserved raw with
  /// the matched local name so callers can route to the typed
  /// DrawingML wrappers without re-walking the element.
  anchors_and_inlines : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Drawing — Part 1 §17.3.3.9.
pub fn CT_Drawing::new(
  element : @xml.Element,
) -> CT_Drawing raise SchemaViolation {
  let collected : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Node::Element(e) => {
        let ln = e.name.local_name
        if ln == "anchor" || ln == "inline" {
          collected.push(e)
        }
      }
      _ => ()
    }
  }
  if collected.length() == 0 {
    raise_schema_violation(
      "CT_Drawing", "anchor|inline", "Part 1 §17.3.3.9: required at least one <wp:anchor> or <wp:inline> child is missing",
    )
  }
  { element, anchors_and_inlines: collected }
}

///|
/// XSD complex type CT_Drawing — Part 1 §17.3.3.9.
pub fn CT_Drawing::parse(
  element : @xml.Element,
) -> CT_Drawing raise SchemaViolation {
  CT_Drawing::new(element)
}

///|
/// XSD complex type CT_Drawing — return the preserved element for
/// writers.
pub fn CT_Drawing::to_element(self : CT_Drawing) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SimpleField — Part 1 §17.16.19 (fldSimple
/// Simple Field). Required `@instr` (s:ST_String) carrying the field
/// instruction text plus optional `@fldLock` and `@dirty` ST_OnOff
/// toggles. Body content is an EG_PContent xsd:choice over inline-run
/// content; preserved as raw element children since the typed
/// projection is owned by the content-tree readers.
pub(all) struct CT_SimpleField {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @instr (s:ST_String) — required field instruction.
  instr : String
  /// §22.9.2.7 @fldLock (s:ST_OnOff) — optional field-lock flag.
  fld_lock : Bool?
  /// §22.9.2.7 @dirty (s:ST_OnOff) — optional dirty-cache flag.
  dirty : Bool?
  /// EG_PContent* — field body, preserved raw.
  content : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_SimpleField — Part 1 §17.16.19.
pub fn CT_SimpleField::new(
  element : @xml.Element,
) -> CT_SimpleField raise SchemaViolation {
  let instr = wml_ct_chunk1_required_attr(
    element, "instr", "CT_SimpleField", "Part 1 §22.9.2.13 s:ST_String",
  )
  let fld_lock = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "fldLock"))
  let dirty = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "dirty"))
  let content = wml_ct_chunk2_element_children(element)
  { element, instr, fld_lock, dirty, content }
}

///|
/// XSD complex type CT_SimpleField — Part 1 §17.16.19.
pub fn CT_SimpleField::parse(
  element : @xml.Element,
) -> CT_SimpleField raise SchemaViolation {
  CT_SimpleField::new(element)
}

///|
/// XSD complex type CT_SimpleField — return the preserved element for
/// writers.
pub fn CT_SimpleField::to_element(self : CT_SimpleField) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFTextType — Part 1 §17.16.32 (type Text Box
/// Form Field Type). Required `@val` ST_FFTextType ∈ {regular,
/// number, date, currentTime, currentDate, calculated}.
pub(all) struct CT_FFTextType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.32 @val (ST_FFTextType) — required form-field text type.
  val : ST_FFTextType
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFTextType — Part 1 §17.16.32.
pub fn CT_FFTextType::new(
  element : @xml.Element,
) -> CT_FFTextType raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "val", "CT_FFTextType", "Part 1 §17.18.32 ST_FFTextType",
  )
  let val = ST_FFTextType::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_FFTextType — Part 1 §17.16.32.
pub fn CT_FFTextType::parse(
  element : @xml.Element,
) -> CT_FFTextType raise SchemaViolation {
  CT_FFTextType::new(element)
}

///|
/// XSD complex type CT_FFTextType — return the preserved element for
/// writers.
pub fn CT_FFTextType::to_element(self : CT_FFTextType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFName — Part 1 §17.16.20 (name Form Field
/// Name). Single optional `@val` (ST_FFName §17.18.30, xsd:string with
/// `maxLength=65`) carrying the bookmark name that holds the field
/// state.
pub(all) struct CT_FFName {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.30 @val (ST_FFName) — optional form-field name
  /// (xsd:string, maxLength=65). Schema does not mark @val as
  /// required even though §17.16.20 prose treats the name as
  /// mandatory in producers.
  val : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFName — Part 1 §17.16.20.
pub fn CT_FFName::new(
  element : @xml.Element,
) -> CT_FFName raise SchemaViolation {
  let val = match wml_ct_chunk1_attr(element, "val") {
    Some(text) =>
      if text.length() > 65 {
        raise_schema_violation(
          "CT_FFName", "val", "Part 1 §17.18.30 ST_FFName: value exceeds xsd:maxLength=65",
        )
      } else {
        Some(text)
      }
    None => None
  }
  { element, val }
}

///|
/// XSD complex type CT_FFName — Part 1 §17.16.20.
pub fn CT_FFName::parse(
  element : @xml.Element,
) -> CT_FFName raise SchemaViolation {
  CT_FFName::new(element)
}

///|
/// XSD complex type CT_FFName — return the preserved element for
/// writers.
pub fn CT_FFName::to_element(self : CT_FFName) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FldChar — Part 1 §17.16.18 (fldChar Complex
/// Field Character). Required `@fldCharType` ST_FldCharType ∈ {begin,
/// separate, end}, optional `@fldLock` / `@dirty` ST_OnOff toggles,
/// and an optional `<ffData>` (CT_FFData §17.16.17) child carried only
/// on the begin-character of a form field.
pub(all) struct CT_FldChar {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.33 @fldCharType (ST_FldCharType) — required field-character role.
  fld_char_type : ST_FldCharType
  /// §22.9.2.7 @fldLock (s:ST_OnOff) — optional field-lock flag.
  fld_lock : Bool?
  /// §22.9.2.7 @dirty (s:ST_OnOff) — optional dirty-cache flag.
  dirty : Bool?
  /// <ffData> (CT_FFData) — optional form-field properties on the
  /// begin-character.
  ff_data : CT_FFData?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FldChar — Part 1 §17.16.18.
pub fn CT_FldChar::new(
  element : @xml.Element,
) -> CT_FldChar raise SchemaViolation {
  let raw = wml_ct_chunk1_required_attr(
    element, "fldCharType", "CT_FldChar", "Part 1 §17.18.33 ST_FldCharType",
  )
  let fld_char_type = ST_FldCharType::parse(raw)
  let fld_lock = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "fldLock"))
  let dirty = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "dirty"))
  let ff_data = match wml_ct_chunk2_first_child(element, "ffData") {
    Some(child) => Some(CT_FFData::new(child))
    None => None
  }
  { element, fld_char_type, fld_lock, dirty, ff_data }
}

///|
/// XSD complex type CT_FldChar — Part 1 §17.16.18.
pub fn CT_FldChar::parse(
  element : @xml.Element,
) -> CT_FldChar raise SchemaViolation {
  CT_FldChar::new(element)
}

///|
/// XSD complex type CT_FldChar — return the preserved element for
/// writers.
pub fn CT_FldChar::to_element(self : CT_FldChar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Hyperlink — Part 1 §17.16.22 (hyperlink
/// Hyperlink). Zero-or-more EG_PContent body, six optional attributes
/// (`@tgtFrame`, `@tooltip`, `@docLocation`, `@history` ST_OnOff,
/// `@anchor`) and an optional `@r:id` relationship reference pointing
/// at the external link target.
pub(all) struct CT_Hyperlink {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @tgtFrame (s:ST_String) — optional target frame name.
  tgt_frame : String?
  /// §22.9.2.13 @tooltip (s:ST_String) — optional tooltip text.
  tooltip : String?
  /// §22.9.2.13 @docLocation (s:ST_String) — optional in-document fragment.
  doc_location : String?
  /// §22.9.2.7 @history (s:ST_OnOff) — optional history-tracking flag.
  history : Bool?
  /// §22.9.2.13 @anchor (s:ST_String) — optional bookmark anchor name.
  anchor : String?
  /// @r:id (ST_RelationshipId) — optional external-target relationship.
  r_id : String?
  /// EG_PContent* — hyperlink body, preserved raw.
  content : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Hyperlink — Part 1 §17.16.22.
pub fn CT_Hyperlink::new(element : @xml.Element) -> CT_Hyperlink {
  let tgt_frame = wml_ct_chunk1_attr(element, "tgtFrame")
  let tooltip = wml_ct_chunk1_attr(element, "tooltip")
  let doc_location = wml_ct_chunk1_attr(element, "docLocation")
  let history = wml_ct_chunk1_on_off(wml_ct_chunk1_attr(element, "history"))
  let anchor = wml_ct_chunk1_attr(element, "anchor")
  let r_id = wml_ct_chunk1_attr(element, "id")
  let content = wml_ct_chunk2_element_children(element)
  { element, tgt_frame, tooltip, doc_location, history, anchor, r_id, content }
}

///|
/// XSD complex type CT_Hyperlink — Part 1 §17.16.22.
pub fn CT_Hyperlink::parse(element : @xml.Element) -> CT_Hyperlink {
  CT_Hyperlink::new(element)
}

///|
/// XSD complex type CT_Hyperlink — return the preserved element for
/// writers.
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
