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
/// XSD complex type CT_FFData — Part 1 §17.16.17 ffData. Form-field data
/// container expressed as an `xsd:choice maxOccurs="unbounded"` of typed
/// child elements: required `<name>` (CT_FFName §17.16.20), optional
/// `<label>` / `<tabIndex>` (numeric tab order), required `<enabled>` /
/// `<calcOnExit>` (boolean state flags via CT_OnOff), optional
/// `<entryMacro>` / `<exitMacro>` (CT_MacroName §17.18.51), optional
/// `<helpText>` / `<statusText>` (CT_FFHelpText / CT_FFStatusText below),
/// and exactly one of `<checkBox>` / `<ddList>` / `<textInput>` per
/// §17.16.7 / §17.16.10 / §17.16.32. The element has no XSD attributes.
pub(all) struct CT_FFData {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// `<name>` (CT_FFName §17.16.20) — required form field name.
  names : Array[CT_FFName]
  /// `<label>` (CT_DecimalNumber §17.16.18) — optional label index list.
  labels : Array[CT_DecimalNumber]
  /// `<tabIndex>` (CT_UnsignedDecimalNumber §17.16.31) — optional list.
  tab_index : Array[CT_UnsignedDecimalNumber]
  /// `<enabled>` (CT_OnOff §17.16.16) — required state toggle list.
  enabled : Array[CT_OnOff]
  /// `<calcOnExit>` (CT_OnOff §17.16.6) — required recalculation toggle list.
  calc_on_exit : Array[CT_OnOff]
  /// `<entryMacro>` (CT_MacroName §17.16.15) — optional on-entry macro list.
  entry_macro : Array[CT_MacroName]
  /// `<exitMacro>` (CT_MacroName §17.16.16) — optional on-exit macro list.
  exit_macro : Array[CT_MacroName]
  /// `<helpText>` (CT_FFHelpText §17.16.19) — optional help-text overrides.
  help_text : Array[CT_FFHelpText]
  /// `<statusText>` (CT_FFStatusText §17.16.30) — optional status text.
  status_text : Array[CT_FFStatusText]
  /// `<checkBox>` (CT_FFCheckBox §17.16.7) — at most one per ffData.
  check_box : CT_FFCheckBox?
  /// `<ddList>` (CT_FFDDList §17.16.10) — at most one per ffData.
  dd_list : CT_FFDDList?
  /// `<textInput>` (CT_FFTextInput §17.16.32) — at most one per ffData.
  text_input : CT_FFTextInput?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFData — Part 1 §17.16.17. Decode each typed child
/// element collection; the inner `xsd:choice` of `<checkBox>/<ddList>/
/// <textInput>` is realised as three optional fields because the outer
/// `xsd:choice maxOccurs="unbounded"` admits at most one occurrence of
/// each branch.
pub fn CT_FFData::new(
  element : @xml.Element,
) -> CT_FFData raise SchemaViolation {
  let names = []
  let labels = []
  let tab_index = []
  let enabled = []
  let calc_on_exit = []
  let entry_macro = []
  let exit_macro = []
  let help_text = []
  let status_text = []
  let mut check_box : CT_FFCheckBox? = None
  let mut dd_list : CT_FFDDList? = None
  let mut text_input : CT_FFTextInput? = None
  for child in element.children {
    match child {
      @xml.Element(e) =>
        match e.name.local_name {
          "name" => names.push(CT_FFName::new(e))
          "label" => labels.push(CT_DecimalNumber::new(e))
          "tabIndex" => tab_index.push(CT_UnsignedDecimalNumber::new(e))
          "enabled" => enabled.push(CT_OnOff::new(e))
          "calcOnExit" => calc_on_exit.push(CT_OnOff::new(e))
          "entryMacro" => entry_macro.push(CT_MacroName::new(e))
          "exitMacro" => exit_macro.push(CT_MacroName::new(e))
          "helpText" => help_text.push(CT_FFHelpText::new(e))
          "statusText" => status_text.push(CT_FFStatusText::new(e))
          "checkBox" =>
            if check_box is None {
              check_box = Some(CT_FFCheckBox::new(e))
            }
          "ddList" => if dd_list is None { dd_list = Some(CT_FFDDList::new(e)) }
          "textInput" =>
            if text_input is None {
              text_input = Some(CT_FFTextInput::new(e))
            }
          _ => ()
        }
      _ => ()
    }
  }
  {
    element,
    names,
    labels,
    tab_index,
    enabled,
    calc_on_exit,
    entry_macro,
    exit_macro,
    help_text,
    status_text,
    check_box,
    dd_list,
    text_input,
  }
}

///|
/// XSD complex type CT_FFData — Part 1 §17.16.17.
pub fn CT_FFData::parse(
  element : @xml.Element,
) -> CT_FFData raise SchemaViolation {
  CT_FFData::new(element)
}

///|
/// XSD complex type CT_FFData — return the preserved element for writers.
pub fn CT_FFData::to_element(self : CT_FFData) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFHelpText — Part 1 §17.16.19 helpText. Two optional
/// attributes: `@type` (ST_InfoTextType §17.18.49) selecting `text` or
/// `autoText` provenance, and `@val` (ST_FFHelpTextVal §17.18.25, max
/// 256 characters) carrying the help text payload.
pub(all) struct CT_FFHelpText {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.49 @type (ST_InfoTextType) — optional. `None` ⇒ schema-default
  /// `text` per Part 1 §17.16.19 prose.
  type_ : ST_InfoTextType?
  /// §17.18.25 @val (ST_FFHelpTextVal) — optional help-text payload.
  val : ST_FFHelpTextVal?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFHelpText — Part 1 §17.16.19.
pub fn CT_FFHelpText::new(
  element : @xml.Element,
) -> CT_FFHelpText raise SchemaViolation {
  let type_ = match wml_ct_chunk3_attr(element, "type") {
    Some(text) => Some(ST_InfoTextType::parse(text))
    None => None
  }
  let val = match wml_ct_chunk3_attr(element, "val") {
    Some(text) => Some(ST_FFHelpTextVal::parse(text))
    None => None
  }
  { element, type_, val }
}

///|
/// XSD complex type CT_FFHelpText — Part 1 §17.16.19.
pub fn CT_FFHelpText::parse(
  element : @xml.Element,
) -> CT_FFHelpText raise SchemaViolation {
  CT_FFHelpText::new(element)
}

///|
/// XSD complex type CT_FFHelpText — return the preserved element for writers.
pub fn CT_FFHelpText::to_element(self : CT_FFHelpText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFStatusText — Part 1 §17.16.30 statusText. Two
/// optional attributes: `@type` (ST_InfoTextType §17.18.49) and `@val`
/// (ST_FFStatusTextVal §17.18.27, max 140 characters).
pub(all) struct CT_FFStatusText {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.49 @type (ST_InfoTextType) — optional.
  type_ : ST_InfoTextType?
  /// §17.18.27 @val (ST_FFStatusTextVal) — optional status payload.
  val : ST_FFStatusTextVal?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFStatusText — Part 1 §17.16.30.
pub fn CT_FFStatusText::new(
  element : @xml.Element,
) -> CT_FFStatusText raise SchemaViolation {
  let type_ = match wml_ct_chunk3_attr(element, "type") {
    Some(text) => Some(ST_InfoTextType::parse(text))
    None => None
  }
  let val = match wml_ct_chunk3_attr(element, "val") {
    Some(text) => Some(ST_FFStatusTextVal::parse(text))
    None => None
  }
  { element, type_, val }
}

///|
/// XSD complex type CT_FFStatusText — Part 1 §17.16.30.
pub fn CT_FFStatusText::parse(
  element : @xml.Element,
) -> CT_FFStatusText raise SchemaViolation {
  CT_FFStatusText::new(element)
}

///|
/// XSD complex type CT_FFStatusText — return the preserved element for writers.
pub fn CT_FFStatusText::to_element(self : CT_FFStatusText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFCheckBox — Part 1 §17.16.7 checkBox. An xsd:choice
/// between `<size>` (CT_HpsMeasure §17.16.27, half-point sizing) and
/// `<sizeAuto>` (CT_OnOff §17.16.28, automatic sizing flag), followed by
/// optional `<default>` (CT_OnOff §17.16.9, initial state) and `<checked>`
/// (CT_OnOff §17.16.8, current state). The first xsd:choice is required
/// (no minOccurs="0"); the typed enum models both branches.
pub(all) enum CT_FFCheckBoxSize {
  /// §17.16.27 `<size>` — explicit half-point sizing.
  CT_FFCheckBoxSize_Size(CT_HpsMeasure)
  /// §17.16.28 `<sizeAuto>` — automatic sizing flag.
  CT_FFCheckBoxSize_SizeAuto(CT_OnOff)
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFCheckBox — Part 1 §17.16.7. See enum above for the
/// xsd:choice modelling.
pub(all) struct CT_FFCheckBox {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// Required xsd:choice between `<size>` and `<sizeAuto>`.
  size : CT_FFCheckBoxSize?
  /// §17.16.9 `<default>` (CT_OnOff) — optional initial state.
  default_ : CT_OnOff?
  /// §17.16.8 `<checked>` (CT_OnOff) — optional current checked state.
  checked : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFCheckBox — Part 1 §17.16.7. Decode the required
/// xsd:choice followed by the two optional follow-on children.
pub fn CT_FFCheckBox::new(
  element : @xml.Element,
) -> CT_FFCheckBox raise SchemaViolation {
  let size = match wml_ct_chunk3_first_choice(element, ["size", "sizeAuto"]) {
    Some((e, "size")) => Some(CT_FFCheckBoxSize_Size(CT_HpsMeasure::new(e)))
    Some((e, "sizeAuto")) => Some(CT_FFCheckBoxSize_SizeAuto(CT_OnOff::new(e)))
    Some(_) => None
    None => None
  }
  let default_ = match wml_ct_chunk3_first_child(element, "default") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  let checked = match wml_ct_chunk3_first_child(element, "checked") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  { element, size, default_, checked }
}

///|
/// XSD complex type CT_FFCheckBox — Part 1 §17.16.7.
pub fn CT_FFCheckBox::parse(
  element : @xml.Element,
) -> CT_FFCheckBox raise SchemaViolation {
  CT_FFCheckBox::new(element)
}

///|
/// XSD complex type CT_FFCheckBox — return the preserved element for writers.
pub fn CT_FFCheckBox::to_element(self : CT_FFCheckBox) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFDDList — Part 1 §17.16.10 ddList. Drop-down list
/// payload: optional `<result>` (CT_DecimalNumber §17.16.25 — selected
/// index), optional `<default>` (CT_DecimalNumber §17.16.9 — initial
/// index), zero-or-more `<listEntry>` (CT_String §17.16.21).
pub(all) struct CT_FFDDList {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.16.25 `<result>` (CT_DecimalNumber) — optional selected entry index.
  result : CT_DecimalNumber?
  /// §17.16.9 `<default>` (CT_DecimalNumber) — optional initial index.
  default_ : CT_DecimalNumber?
  /// §17.16.21 `<listEntry>` (CT_String) — list entries in document order.
  list_entry : Array[CT_String]
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFDDList — Part 1 §17.16.10.
pub fn CT_FFDDList::new(
  element : @xml.Element,
) -> CT_FFDDList raise SchemaViolation {
  let result = match wml_ct_chunk3_first_child(element, "result") {
    Some(e) => Some(CT_DecimalNumber::new(e))
    None => None
  }
  let default_ = match wml_ct_chunk3_first_child(element, "default") {
    Some(e) => Some(CT_DecimalNumber::new(e))
    None => None
  }
  let list_entry = []
  for e in wml_ct_chunk3_children(element, "listEntry") {
    list_entry.push(CT_String::new(e))
  }
  { element, result, default_, list_entry }
}

///|
/// XSD complex type CT_FFDDList — Part 1 §17.16.10.
pub fn CT_FFDDList::parse(
  element : @xml.Element,
) -> CT_FFDDList raise SchemaViolation {
  CT_FFDDList::new(element)
}

///|
/// XSD complex type CT_FFDDList — return the preserved element for writers.
pub fn CT_FFDDList::to_element(self : CT_FFDDList) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_FFTextInput — Part 1 §17.16.32 textInput. Form-text
/// payload: optional `<type>` (CT_FFTextType §17.16.34 selecting one of
/// regular/number/date/currentTime/currentDate/calculated), optional
/// `<default>` (CT_String §17.16.9 default text), optional `<maxLength>`
/// (CT_DecimalNumber §17.16.22), optional `<format>` (CT_String §17.16.18
/// numeric/date format string).
pub(all) struct CT_FFTextInput {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.16.34 `<type>` (CT_FFTextType) — optional input mode.
  type_ : CT_FFTextType?
  /// §17.16.9 `<default>` (CT_String) — optional default text.
  default_ : CT_String?
  /// §17.16.22 `<maxLength>` (CT_DecimalNumber) — optional length cap.
  max_length : CT_DecimalNumber?
  /// §17.16.18 `<format>` (CT_String) — optional format mask.
  format : CT_String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_FFTextInput — Part 1 §17.16.32.
pub fn CT_FFTextInput::new(
  element : @xml.Element,
) -> CT_FFTextInput raise SchemaViolation {
  let type_ = match wml_ct_chunk3_first_child(element, "type") {
    Some(e) => Some(CT_FFTextType::new(e))
    None => None
  }
  let default_ = match wml_ct_chunk3_first_child(element, "default") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let max_length = match wml_ct_chunk3_first_child(element, "maxLength") {
    Some(e) => Some(CT_DecimalNumber::new(e))
    None => None
  }
  let format = match wml_ct_chunk3_first_child(element, "format") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  { element, type_, default_, max_length, format }
}

///|
/// XSD complex type CT_FFTextInput — Part 1 §17.16.32.
pub fn CT_FFTextInput::parse(
  element : @xml.Element,
) -> CT_FFTextInput raise SchemaViolation {
  CT_FFTextInput::new(element)
}

///|
/// XSD complex type CT_FFTextInput — return the preserved element for writers.
pub fn CT_FFTextInput::to_element(self : CT_FFTextInput) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectType — Part 1 §17.6.22 type. Section type
/// descriptor with a single optional `@val` (ST_SectionMark §17.18.74)
/// selecting one of nextPage / nextColumn / continuous / evenPage /
/// oddPage. The schema default when omitted is `nextPage` per
/// §17.6.22 prose.
pub(all) struct CT_SectType {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.74 @val (ST_SectionMark) — optional section-break kind.
  val : ST_SectionMark?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SectType — Part 1 §17.6.22.
pub fn CT_SectType::new(
  element : @xml.Element,
) -> CT_SectType raise SchemaViolation {
  let val = match wml_ct_chunk3_attr(element, "val") {
    Some(text) => Some(ST_SectionMark::parse(text))
    None => None
  }
  { element, val }
}

///|
/// XSD complex type CT_SectType — Part 1 §17.6.22.
pub fn CT_SectType::parse(
  element : @xml.Element,
) -> CT_SectType raise SchemaViolation {
  CT_SectType::new(element)
}

///|
/// XSD complex type CT_SectType — return the preserved element for writers.
pub fn CT_SectType::to_element(self : CT_SectType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PaperSource — Part 1 §17.6.15 paperSrc. Two optional
/// ST_DecimalNumber bin-id attributes selecting the printer paper source.
pub(all) struct CT_PaperSource {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @first (ST_DecimalNumber) — optional first-page bin id.
  first : ST_DecimalNumber?
  /// §17.18.10 @other (ST_DecimalNumber) — optional continuation-page bin id.
  other : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PaperSource — Part 1 §17.6.15.
pub fn CT_PaperSource::new(
  element : @xml.Element,
) -> CT_PaperSource raise SchemaViolation {
  let first = match wml_ct_chunk3_attr(element, "first") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let other = match wml_ct_chunk3_attr(element, "other") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  { element, first, other }
}

///|
/// XSD complex type CT_PaperSource — Part 1 §17.6.15.
pub fn CT_PaperSource::parse(
  element : @xml.Element,
) -> CT_PaperSource raise SchemaViolation {
  CT_PaperSource::new(element)
}

///|
/// XSD complex type CT_PaperSource — return the preserved element for writers.
pub fn CT_PaperSource::to_element(self : CT_PaperSource) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageSz — Part 1 §17.6.17 pgSz. Page-size descriptor:
/// optional width / height (`@w`, `@h`) typed as the shared
/// s:ST_TwipsMeasure lexical form (§22.9.2.14), optional `@orient`
/// (ST_PageOrientation §17.18.64 — portrait / landscape), optional
/// `@code` (ST_DecimalNumber §17.18.10 — printer paper-code).
pub(all) struct CT_PageSz {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.14 @w (s:ST_TwipsMeasure) — optional page width (lexical form).
  w : String?
  /// §22.9.2.14 @h (s:ST_TwipsMeasure) — optional page height (lexical form).
  h : String?
  /// §17.18.64 @orient (ST_PageOrientation) — optional orientation.
  orient : ST_PageOrientation?
  /// §17.18.10 @code (ST_DecimalNumber) — optional printer paper-code.
  code : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageSz — Part 1 §17.6.17.
pub fn CT_PageSz::new(
  element : @xml.Element,
) -> CT_PageSz raise SchemaViolation {
  let w = wml_ct_chunk3_attr(element, "w")
  let h = wml_ct_chunk3_attr(element, "h")
  let orient = match wml_ct_chunk3_attr(element, "orient") {
    Some(text) => Some(ST_PageOrientation::parse(text))
    None => None
  }
  let code = match wml_ct_chunk3_attr(element, "code") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  { element, w, h, orient, code }
}

///|
/// XSD complex type CT_PageSz — Part 1 §17.6.17.
pub fn CT_PageSz::parse(
  element : @xml.Element,
) -> CT_PageSz raise SchemaViolation {
  CT_PageSz::new(element)
}

///|
/// XSD complex type CT_PageSz — return the preserved element for writers.
pub fn CT_PageSz::to_element(self : CT_PageSz) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageMar — Part 1 §17.6.11 pgMar. Page-margin
/// descriptor: seven required attributes covering top / right / bottom /
/// left margins (top and bottom typed as ST_SignedTwipsMeasure §17.18.81;
/// right and left as the shared s:ST_TwipsMeasure §22.9.2.14), header /
/// footer offsets (s:ST_TwipsMeasure), gutter offset (s:ST_TwipsMeasure).
pub(all) struct CT_PageMar {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.81 @top (ST_SignedTwipsMeasure) — required top margin.
  top : ST_SignedTwipsMeasure
  /// §22.9.2.14 @right (s:ST_TwipsMeasure) — required right margin (lexical).
  right : String
  /// §17.18.81 @bottom (ST_SignedTwipsMeasure) — required bottom margin.
  bottom : ST_SignedTwipsMeasure
  /// §22.9.2.14 @left (s:ST_TwipsMeasure) — required left margin (lexical).
  left : String
  /// §22.9.2.14 @header (s:ST_TwipsMeasure) — required header offset.
  header : String
  /// §22.9.2.14 @footer (s:ST_TwipsMeasure) — required footer offset.
  footer : String
  /// §22.9.2.14 @gutter (s:ST_TwipsMeasure) — required gutter offset.
  gutter : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageMar — Part 1 §17.6.11. Decode all seven required
/// margin / offset attributes.
pub fn CT_PageMar::new(
  element : @xml.Element,
) -> CT_PageMar raise SchemaViolation {
  let top_raw = wml_ct_chunk3_required_attr(
    element, "top", "CT_PageMar", "Part 1 §17.6.11 ST_SignedTwipsMeasure",
  )
  let top = ST_SignedTwipsMeasure::parse(top_raw)
  let right = wml_ct_chunk3_required_attr(
    element, "right", "CT_PageMar", "Part 1 §17.6.11 s:ST_TwipsMeasure",
  )
  let bottom_raw = wml_ct_chunk3_required_attr(
    element, "bottom", "CT_PageMar", "Part 1 §17.6.11 ST_SignedTwipsMeasure",
  )
  let bottom = ST_SignedTwipsMeasure::parse(bottom_raw)
  let left = wml_ct_chunk3_required_attr(
    element, "left", "CT_PageMar", "Part 1 §17.6.11 s:ST_TwipsMeasure",
  )
  let header = wml_ct_chunk3_required_attr(
    element, "header", "CT_PageMar", "Part 1 §17.6.11 s:ST_TwipsMeasure",
  )
  let footer = wml_ct_chunk3_required_attr(
    element, "footer", "CT_PageMar", "Part 1 §17.6.11 s:ST_TwipsMeasure",
  )
  let gutter = wml_ct_chunk3_required_attr(
    element, "gutter", "CT_PageMar", "Part 1 §17.6.11 s:ST_TwipsMeasure",
  )
  { element, top, right, bottom, left, header, footer, gutter }
}

///|
/// XSD complex type CT_PageMar — Part 1 §17.6.11.
pub fn CT_PageMar::parse(
  element : @xml.Element,
) -> CT_PageMar raise SchemaViolation {
  CT_PageMar::new(element)
}

///|
/// XSD complex type CT_PageMar — return the preserved element for writers.
pub fn CT_PageMar::to_element(self : CT_PageMar) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageBorders — Part 1 §17.6.10 pgBorders. Page-border
/// container with up to four side-border children and three optional
/// presentation attributes: `@zOrder` (ST_PageBorderZOrder §17.18.65 —
/// front / back; default `front`), `@display` (ST_PageBorderDisplay
/// §17.18.62 — allPages / firstPage / notFirstPage), `@offsetFrom`
/// (ST_PageBorderOffset §17.18.63 — page / text; default `text`).
pub(all) struct CT_PageBorders {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.65 @zOrder (ST_PageBorderZOrder) — optional; `None` ⇒ schema-default `front`.
  z_order : ST_PageBorderZOrder?
  /// §17.18.62 @display (ST_PageBorderDisplay) — optional.
  display : ST_PageBorderDisplay?
  /// §17.18.63 @offsetFrom (ST_PageBorderOffset) — optional; `None` ⇒ schema-default `text`.
  offset_from : ST_PageBorderOffset?
  /// §17.6.27 `<top>` (CT_TopPageBorder) — optional top border.
  top : CT_TopPageBorder?
  /// §17.6.9 `<left>` (CT_PageBorder) — optional left border.
  left : CT_PageBorder?
  /// §17.6.2 `<bottom>` (CT_BottomPageBorder) — optional bottom border.
  bottom : CT_BottomPageBorder?
  /// §17.6.21 `<right>` (CT_PageBorder) — optional right border.
  right : CT_PageBorder?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageBorders — Part 1 §17.6.10.
pub fn CT_PageBorders::new(
  element : @xml.Element,
) -> CT_PageBorders raise SchemaViolation {
  let z_order = match wml_ct_chunk3_attr(element, "zOrder") {
    Some(text) => Some(ST_PageBorderZOrder::parse(text))
    None => None
  }
  let display = match wml_ct_chunk3_attr(element, "display") {
    Some(text) => Some(ST_PageBorderDisplay::parse(text))
    None => None
  }
  let offset_from = match wml_ct_chunk3_attr(element, "offsetFrom") {
    Some(text) => Some(ST_PageBorderOffset::parse(text))
    None => None
  }
  let top = match wml_ct_chunk3_first_child(element, "top") {
    Some(e) => Some(CT_TopPageBorder::new(e))
    None => None
  }
  let left = match wml_ct_chunk3_first_child(element, "left") {
    Some(e) => Some(CT_PageBorder::new(e))
    None => None
  }
  let bottom = match wml_ct_chunk3_first_child(element, "bottom") {
    Some(e) => Some(CT_BottomPageBorder::new(e))
    None => None
  }
  let right = match wml_ct_chunk3_first_child(element, "right") {
    Some(e) => Some(CT_PageBorder::new(e))
    None => None
  }
  { element, z_order, display, offset_from, top, left, bottom, right }
}

///|
/// XSD complex type CT_PageBorders — Part 1 §17.6.10.
pub fn CT_PageBorders::parse(
  element : @xml.Element,
) -> CT_PageBorders raise SchemaViolation {
  CT_PageBorders::new(element)
}

///|
/// XSD complex type CT_PageBorders — return the preserved element for writers.
pub fn CT_PageBorders::to_element(self : CT_PageBorders) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageBorder — Part 1 §17.6.9 left / §17.6.21 right.
/// `xsd:complexContent` extension of CT_Border (§17.3.4) adding an optional
/// `@r:id` relationship reference for picture-art borders.
pub(all) struct CT_PageBorder {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.2 @val (ST_Border) — required border style inherited from CT_Border.
  val : ST_Border
  /// §17.18.38 @color (ST_HexColor) — optional inherited colour.
  color : ST_HexColor?
  /// §17.18.97 @themeColor (ST_ThemeColor) — optional inherited theme colour.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint (ST_UcharHexNumber) — optional inherited tint.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade (ST_UcharHexNumber) — optional inherited shade.
  theme_shade : ST_UcharHexNumber?
  /// §17.18.23 @sz (ST_EighthPointMeasure) — optional inherited width.
  sz : ST_EighthPointMeasure?
  /// §17.18.68 @space (ST_PointMeasure) — optional inherited spacing.
  space : ST_PointMeasure?
  /// §22.9.2.7 @shadow (s:ST_OnOff) — optional inherited drop-shadow flag.
  shadow : Bool?
  /// §22.9.2.7 @frame (s:ST_OnOff) — optional inherited frame flag.
  frame : Bool?
  /// §A.6.7 @r:id (relationship reference) — optional picture-art border image.
  r_id : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageBorder — Part 1 §17.6.9.
pub fn CT_PageBorder::new(
  element : @xml.Element,
) -> CT_PageBorder raise SchemaViolation {
  let raw_val = wml_ct_chunk3_required_attr(
    element, "val", "CT_PageBorder", "Part 1 §17.18.2 ST_Border",
  )
  let val = ST_Border::parse(raw_val)
  let color = match wml_ct_chunk3_attr(element, "color") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_color = match wml_ct_chunk3_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk3_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk3_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let sz = match wml_ct_chunk3_attr(element, "sz") {
    Some(text) => Some(ST_EighthPointMeasure::parse(text))
    None => None
  }
  let space = match wml_ct_chunk3_attr(element, "space") {
    Some(text) => Some(ST_PointMeasure::parse(text))
    None => None
  }
  let shadow = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "shadow"))
  let frame = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "frame"))
  let r_id = wml_ct_chunk3_attr_ns(element, wml_ct_chunk3_ns_r(), "id")
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
    r_id,
  }
}

///|
/// XSD complex type CT_PageBorder — Part 1 §17.6.9.
pub fn CT_PageBorder::parse(
  element : @xml.Element,
) -> CT_PageBorder raise SchemaViolation {
  CT_PageBorder::new(element)
}

///|
/// XSD complex type CT_PageBorder — return the preserved element for writers.
pub fn CT_PageBorder::to_element(self : CT_PageBorder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BottomPageBorder — Part 1 §17.6.2 bottom.
/// `xsd:complexContent` extension of CT_PageBorder (§17.6.9) adding two
/// optional relationship-id attributes for picture-art borders located at
/// the page's bottom-left / bottom-right corners.
pub(all) struct CT_BottomPageBorder {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.2 @val (ST_Border) — required border style (inherited).
  val : ST_Border
  /// §17.18.38 @color (ST_HexColor) — optional inherited colour.
  color : ST_HexColor?
  /// §17.18.97 @themeColor — optional inherited theme colour.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint — optional inherited tint.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade — optional inherited shade.
  theme_shade : ST_UcharHexNumber?
  /// §17.18.23 @sz — optional inherited width.
  sz : ST_EighthPointMeasure?
  /// §17.18.68 @space — optional inherited spacing.
  space : ST_PointMeasure?
  /// §22.9.2.7 @shadow — optional inherited drop-shadow flag.
  shadow : Bool?
  /// §22.9.2.7 @frame — optional inherited frame flag.
  frame : Bool?
  /// §A.6.7 @r:id — optional inherited relationship reference.
  r_id : String?
  /// §A.6.7 @r:bottomLeft — optional bottom-left corner relationship.
  r_bottom_left : String?
  /// §A.6.7 @r:bottomRight — optional bottom-right corner relationship.
  r_bottom_right : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_BottomPageBorder — Part 1 §17.6.2.
pub fn CT_BottomPageBorder::new(
  element : @xml.Element,
) -> CT_BottomPageBorder raise SchemaViolation {
  let raw_val = wml_ct_chunk3_required_attr(
    element, "val", "CT_BottomPageBorder", "Part 1 §17.18.2 ST_Border",
  )
  let val = ST_Border::parse(raw_val)
  let color = match wml_ct_chunk3_attr(element, "color") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_color = match wml_ct_chunk3_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk3_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk3_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let sz = match wml_ct_chunk3_attr(element, "sz") {
    Some(text) => Some(ST_EighthPointMeasure::parse(text))
    None => None
  }
  let space = match wml_ct_chunk3_attr(element, "space") {
    Some(text) => Some(ST_PointMeasure::parse(text))
    None => None
  }
  let shadow = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "shadow"))
  let frame = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "frame"))
  let r_id = wml_ct_chunk3_attr_ns(element, wml_ct_chunk3_ns_r(), "id")
  let r_bottom_left = wml_ct_chunk3_attr_ns(
    element,
    wml_ct_chunk3_ns_r(),
    "bottomLeft",
  )
  let r_bottom_right = wml_ct_chunk3_attr_ns(
    element,
    wml_ct_chunk3_ns_r(),
    "bottomRight",
  )
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
    r_id,
    r_bottom_left,
    r_bottom_right,
  }
}

///|
/// XSD complex type CT_BottomPageBorder — Part 1 §17.6.2.
pub fn CT_BottomPageBorder::parse(
  element : @xml.Element,
) -> CT_BottomPageBorder raise SchemaViolation {
  CT_BottomPageBorder::new(element)
}

///|
/// XSD complex type CT_BottomPageBorder — return the preserved element for writers.
pub fn CT_BottomPageBorder::to_element(
  self : CT_BottomPageBorder,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_TopPageBorder — Part 1 §17.6.27 top.
/// `xsd:complexContent` extension of CT_PageBorder (§17.6.9) adding two
/// optional relationship-id attributes for picture-art borders at the
/// page's top-left / top-right corners.
pub(all) struct CT_TopPageBorder {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.2 @val (ST_Border) — required border style (inherited).
  val : ST_Border
  /// §17.18.38 @color — optional inherited colour.
  color : ST_HexColor?
  /// §17.18.97 @themeColor — optional inherited theme colour.
  theme_color : ST_ThemeColor?
  /// §17.18.98 @themeTint — optional inherited tint.
  theme_tint : ST_UcharHexNumber?
  /// §17.18.98 @themeShade — optional inherited shade.
  theme_shade : ST_UcharHexNumber?
  /// §17.18.23 @sz — optional inherited width.
  sz : ST_EighthPointMeasure?
  /// §17.18.68 @space — optional inherited spacing.
  space : ST_PointMeasure?
  /// §22.9.2.7 @shadow — optional inherited drop-shadow flag.
  shadow : Bool?
  /// §22.9.2.7 @frame — optional inherited frame flag.
  frame : Bool?
  /// §A.6.7 @r:id — optional inherited relationship reference.
  r_id : String?
  /// §A.6.7 @r:topLeft — optional top-left corner relationship.
  r_top_left : String?
  /// §A.6.7 @r:topRight — optional top-right corner relationship.
  r_top_right : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_TopPageBorder — Part 1 §17.6.27.
pub fn CT_TopPageBorder::new(
  element : @xml.Element,
) -> CT_TopPageBorder raise SchemaViolation {
  let raw_val = wml_ct_chunk3_required_attr(
    element, "val", "CT_TopPageBorder", "Part 1 §17.18.2 ST_Border",
  )
  let val = ST_Border::parse(raw_val)
  let color = match wml_ct_chunk3_attr(element, "color") {
    Some(text) => Some(ST_HexColor::parse(text))
    None => None
  }
  let theme_color = match wml_ct_chunk3_attr(element, "themeColor") {
    Some(text) => Some(ST_ThemeColor::parse(text))
    None => None
  }
  let theme_tint = match wml_ct_chunk3_attr(element, "themeTint") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let theme_shade = match wml_ct_chunk3_attr(element, "themeShade") {
    Some(text) => Some(ST_UcharHexNumber::parse(text))
    None => None
  }
  let sz = match wml_ct_chunk3_attr(element, "sz") {
    Some(text) => Some(ST_EighthPointMeasure::parse(text))
    None => None
  }
  let space = match wml_ct_chunk3_attr(element, "space") {
    Some(text) => Some(ST_PointMeasure::parse(text))
    None => None
  }
  let shadow = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "shadow"))
  let frame = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "frame"))
  let r_id = wml_ct_chunk3_attr_ns(element, wml_ct_chunk3_ns_r(), "id")
  let r_top_left = wml_ct_chunk3_attr_ns(
    element,
    wml_ct_chunk3_ns_r(),
    "topLeft",
  )
  let r_top_right = wml_ct_chunk3_attr_ns(
    element,
    wml_ct_chunk3_ns_r(),
    "topRight",
  )
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
    r_id,
    r_top_left,
    r_top_right,
  }
}

///|
/// XSD complex type CT_TopPageBorder — Part 1 §17.6.27.
pub fn CT_TopPageBorder::parse(
  element : @xml.Element,
) -> CT_TopPageBorder raise SchemaViolation {
  CT_TopPageBorder::new(element)
}

///|
/// XSD complex type CT_TopPageBorder — return the preserved element for writers.
pub fn CT_TopPageBorder::to_element(self : CT_TopPageBorder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_LineNumber — Part 1 §17.6.8 lnNumType. Line-numbering
/// configuration with four optional attributes: `@countBy`
/// (ST_DecimalNumber §17.18.10 — line increment), `@start`
/// (ST_DecimalNumber default `1`), `@distance` (s:ST_TwipsMeasure
/// §22.9.2.14 — gutter offset), `@restart` (ST_LineNumberRestart
/// §17.18.51 default `newPage`).
pub(all) struct CT_LineNumber {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.10 @countBy (ST_DecimalNumber) — optional line increment.
  count_by : ST_DecimalNumber?
  /// §17.18.10 @start (ST_DecimalNumber) — optional; `None` ⇒ schema-default `1`.
  start : ST_DecimalNumber?
  /// §22.9.2.14 @distance (s:ST_TwipsMeasure) — optional offset (lexical form).
  distance : String?
  /// §17.18.51 @restart (ST_LineNumberRestart) — optional; `None` ⇒ schema-default `newPage`.
  restart : ST_LineNumberRestart?
} derive(Eq, Debug)

///|
/// XSD complex type CT_LineNumber — Part 1 §17.6.8.
pub fn CT_LineNumber::new(
  element : @xml.Element,
) -> CT_LineNumber raise SchemaViolation {
  let count_by = match wml_ct_chunk3_attr(element, "countBy") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let start = match wml_ct_chunk3_attr(element, "start") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let distance = wml_ct_chunk3_attr(element, "distance")
  let restart = match wml_ct_chunk3_attr(element, "restart") {
    Some(text) => Some(ST_LineNumberRestart::parse(text))
    None => None
  }
  { element, count_by, start, distance, restart }
}

///|
/// XSD complex type CT_LineNumber — Part 1 §17.6.8.
pub fn CT_LineNumber::parse(
  element : @xml.Element,
) -> CT_LineNumber raise SchemaViolation {
  CT_LineNumber::new(element)
}

///|
/// XSD complex type CT_LineNumber — return the preserved element for writers.
pub fn CT_LineNumber::to_element(self : CT_LineNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PageNumber — Part 1 §17.6.12 pgNumType. Page-number
/// configuration with four optional attributes: `@fmt`
/// (ST_NumberFormat §17.18.59 default `decimal`), `@start`
/// (ST_DecimalNumber §17.18.10), `@chapStyle` (ST_DecimalNumber —
/// chapter heading style id), `@chapSep` (ST_ChapterSep §17.18.5
/// default `hyphen`).
pub(all) struct CT_PageNumber {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.59 @fmt (ST_NumberFormat) — optional; `None` ⇒ schema-default `decimal`.
  fmt : ST_NumberFormat?
  /// §17.18.10 @start (ST_DecimalNumber) — optional initial page number.
  start : ST_DecimalNumber?
  /// §17.18.10 @chapStyle (ST_DecimalNumber) — optional chapter style id.
  chap_style : ST_DecimalNumber?
  /// §17.18.5 @chapSep (ST_ChapterSep) — optional; `None` ⇒ schema-default `hyphen`.
  chap_sep : ST_ChapterSep?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PageNumber — Part 1 §17.6.12.
pub fn CT_PageNumber::new(
  element : @xml.Element,
) -> CT_PageNumber raise SchemaViolation {
  let fmt = match wml_ct_chunk3_attr(element, "fmt") {
    Some(text) => Some(ST_NumberFormat::parse(text))
    None => None
  }
  let start = match wml_ct_chunk3_attr(element, "start") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let chap_style = match wml_ct_chunk3_attr(element, "chapStyle") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let chap_sep = match wml_ct_chunk3_attr(element, "chapSep") {
    Some(text) => Some(ST_ChapterSep::parse(text))
    None => None
  }
  { element, fmt, start, chap_style, chap_sep }
}

///|
/// XSD complex type CT_PageNumber — Part 1 §17.6.12.
pub fn CT_PageNumber::parse(
  element : @xml.Element,
) -> CT_PageNumber raise SchemaViolation {
  CT_PageNumber::new(element)
}

///|
/// XSD complex type CT_PageNumber — return the preserved element for writers.
pub fn CT_PageNumber::to_element(self : CT_PageNumber) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Column — Part 1 §17.6.3 col. Single-column descriptor
/// with two optional s:ST_TwipsMeasure attributes: `@w` (column width)
/// and `@space` (inter-column gap, default `0`). Stored as lexical forms
/// because the shared simple type lives outside the WML domain package.
pub(all) struct CT_Column {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.14 @w (s:ST_TwipsMeasure) — optional column width (lexical).
  w : String?
  /// §22.9.2.14 @space (s:ST_TwipsMeasure) — optional gap; `None` ⇒ schema-default `0`.
  space : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Column — Part 1 §17.6.3.
pub fn CT_Column::new(element : @xml.Element) -> CT_Column {
  let w = wml_ct_chunk3_attr(element, "w")
  let space = wml_ct_chunk3_attr(element, "space")
  { element, w, space }
}

///|
/// XSD complex type CT_Column — Part 1 §17.6.3.
pub fn CT_Column::parse(element : @xml.Element) -> CT_Column {
  CT_Column::new(element)
}

///|
/// XSD complex type CT_Column — return the preserved element for writers.
pub fn CT_Column::to_element(self : CT_Column) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Columns — Part 1 §17.6.4 cols. Multi-column container
/// with an optional `<col>` (CT_Column §17.6.3) sequence (maxOccurs="45")
/// and four optional attributes: `@equalWidth` (s:ST_OnOff §22.9.2.7),
/// `@space` (s:ST_TwipsMeasure §22.9.2.14 default `720` twips), `@num`
/// (ST_DecimalNumber §17.18.10 default `1`), `@sep` (s:ST_OnOff).
pub(all) struct CT_Columns {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @equalWidth (s:ST_OnOff) — optional equal-width flag.
  equal_width : Bool?
  /// §22.9.2.14 @space (s:ST_TwipsMeasure) — optional default gap; `None` ⇒ schema-default `720`.
  space : String?
  /// §17.18.10 @num (ST_DecimalNumber) — optional column count; `None` ⇒ schema-default `1`.
  num : ST_DecimalNumber?
  /// §22.9.2.7 @sep (s:ST_OnOff) — optional separator-rule flag.
  sep : Bool?
  /// §17.6.3 `<col>` (CT_Column) — explicit column descriptors (max 45).
  cols : Array[CT_Column]
} derive(Eq, Debug)

///|
/// XSD complex type CT_Columns — Part 1 §17.6.4.
pub fn CT_Columns::new(
  element : @xml.Element,
) -> CT_Columns raise SchemaViolation {
  let equal_width = wml_ct_chunk3_on_off(
    wml_ct_chunk3_attr(element, "equalWidth"),
  )
  let space = wml_ct_chunk3_attr(element, "space")
  let num = match wml_ct_chunk3_attr(element, "num") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let sep = wml_ct_chunk3_on_off(wml_ct_chunk3_attr(element, "sep"))
  let cols = []
  for child in wml_ct_chunk3_children(element, "col") {
    cols.push(CT_Column::new(child))
  }
  { element, equal_width, space, num, sep, cols }
}

///|
/// XSD complex type CT_Columns — Part 1 §17.6.4.
pub fn CT_Columns::parse(
  element : @xml.Element,
) -> CT_Columns raise SchemaViolation {
  CT_Columns::new(element)
}

///|
/// XSD complex type CT_Columns — return the preserved element for writers.
pub fn CT_Columns::to_element(self : CT_Columns) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_VerticalJc — Part 1 §17.6.23 vAlign. Section vertical
/// alignment with a required `@val` (ST_VerticalJc §17.18.84 — top /
/// center / both / bottom).
pub(all) struct CT_VerticalJc {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.84 @val (ST_VerticalJc) — required alignment.
  val : ST_VerticalJc
} derive(Eq, Debug)

///|
/// XSD complex type CT_VerticalJc — Part 1 §17.6.23.
pub fn CT_VerticalJc::new(
  element : @xml.Element,
) -> CT_VerticalJc raise SchemaViolation {
  let raw = wml_ct_chunk3_required_attr(
    element, "val", "CT_VerticalJc", "Part 1 §17.18.84 ST_VerticalJc",
  )
  let val = ST_VerticalJc::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_VerticalJc — Part 1 §17.6.23.
pub fn CT_VerticalJc::parse(
  element : @xml.Element,
) -> CT_VerticalJc raise SchemaViolation {
  CT_VerticalJc::new(element)
}

///|
/// XSD complex type CT_VerticalJc — return the preserved element for writers.
pub fn CT_VerticalJc::to_element(self : CT_VerticalJc) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DocGrid — Part 1 §17.6.5 docGrid. Document grid
/// descriptor with three optional attributes: `@type` (ST_DocGrid
/// §17.18.14), `@linePitch` (ST_DecimalNumber §17.18.10), `@charSpace`
/// (ST_DecimalNumber §17.18.10).
pub(all) struct CT_DocGrid {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.14 @type (ST_DocGrid) — optional grid kind.
  type_ : ST_DocGrid?
  /// §17.18.10 @linePitch (ST_DecimalNumber) — optional line height.
  line_pitch : ST_DecimalNumber?
  /// §17.18.10 @charSpace (ST_DecimalNumber) — optional character spacing.
  char_space : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_DocGrid — Part 1 §17.6.5.
pub fn CT_DocGrid::new(
  element : @xml.Element,
) -> CT_DocGrid raise SchemaViolation {
  let type_ = match wml_ct_chunk3_attr(element, "type") {
    Some(text) => Some(ST_DocGrid::parse(text))
    None => None
  }
  let line_pitch = match wml_ct_chunk3_attr(element, "linePitch") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let char_space = match wml_ct_chunk3_attr(element, "charSpace") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  { element, type_, line_pitch, char_space }
}

///|
/// XSD complex type CT_DocGrid — Part 1 §17.6.5.
pub fn CT_DocGrid::parse(
  element : @xml.Element,
) -> CT_DocGrid raise SchemaViolation {
  CT_DocGrid::new(element)
}

///|
/// XSD complex type CT_DocGrid — return the preserved element for writers.
pub fn CT_DocGrid::to_element(self : CT_DocGrid) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HdrFtrRef — Part 1 §17.10.5 headerReference /
/// §17.10.3 footerReference. `xsd:complexContent` extension of CT_Rel
/// (§22.2 r:id reference) adding a required `@type` (ST_HdrFtr §17.18.36
/// — even / default / first) selecting the header/footer applicability.
pub(all) struct CT_HdrFtrRef {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.36 @type (ST_HdrFtr) — required applicability selector.
  type_ : ST_HdrFtr
  /// §A.6.7 @r:id — required relationship reference inherited from CT_Rel.
  r_id : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_HdrFtrRef — Part 1 §17.10.5.
pub fn CT_HdrFtrRef::new(
  element : @xml.Element,
) -> CT_HdrFtrRef raise SchemaViolation {
  let raw_type = wml_ct_chunk3_required_attr(
    element, "type", "CT_HdrFtrRef", "Part 1 §17.18.36 ST_HdrFtr",
  )
  let type_ = ST_HdrFtr::parse(raw_type)
  let r_id = wml_ct_chunk3_attr_ns(element, wml_ct_chunk3_ns_r(), "id")
  { element, type_, r_id }
}

///|
/// XSD complex type CT_HdrFtrRef — Part 1 §17.10.5.
pub fn CT_HdrFtrRef::parse(
  element : @xml.Element,
) -> CT_HdrFtrRef raise SchemaViolation {
  CT_HdrFtrRef::new(element)
}

///|
/// XSD complex type CT_HdrFtrRef — return the preserved element for writers.
pub fn CT_HdrFtrRef::to_element(self : CT_HdrFtrRef) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_HdrFtr — Part 1 §17.10.4 hdr / §17.10.2 ftr.
/// Header / footer body content: one-or-more EG_BlockLevelElts (§A.1
/// model group, materialised as `Array[@xml.Element]` because the group
/// spans every WordprocessingML block-level construct and is parsed
/// lazily by callers). The element has no XSD attributes.
pub(all) struct CT_HdrFtr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// EG_BlockLevelElts payload — raw block-level child elements in document order.
  block_level_elts : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_HdrFtr — Part 1 §17.10.4.
pub fn CT_HdrFtr::new(element : @xml.Element) -> CT_HdrFtr {
  let block_level_elts : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => block_level_elts.push(e)
      _ => ()
    }
  }
  { element, block_level_elts }
}

///|
/// XSD complex type CT_HdrFtr — Part 1 §17.10.4.
pub fn CT_HdrFtr::parse(element : @xml.Element) -> CT_HdrFtr {
  CT_HdrFtr::new(element)
}

///|
/// XSD complex type CT_HdrFtr — return the preserved element for writers.
pub fn CT_HdrFtr::to_element(self : CT_HdrFtr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPrBase — Part 1 §17.6.18 sectPr (legacy base).
/// Section-properties base type. Carries the EG_SectPrContents model group
/// (§A.1 — twenty optional ordered children covering footnotePr / endnotePr /
/// type / pgSz / pgMar / paperSrc / pgBorders / lnNumType / pgNumType /
/// cols / formProt / vAlign / noEndnote / titlePg / textDirection / bidi /
/// rtlGutter / docGrid / printerSettings) plus AG_SectPrAttributes
/// (rsidRPr / rsidDel / rsidR / rsidSect — all ST_LongHexNumber §17.18.50).
/// The model-group children are stored as raw element references because
/// most of their typed structs remain in chunk2.
pub(all) struct CT_SectPrBase {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.50 @rsidRPr (ST_LongHexNumber) — optional run-property rsid.
  rsid_rpr : ST_LongHexNumber?
  /// §17.18.50 @rsidDel (ST_LongHexNumber) — optional deletion rsid.
  rsid_del : ST_LongHexNumber?
  /// §17.18.50 @rsidR (ST_LongHexNumber) — optional run rsid.
  rsid_r : ST_LongHexNumber?
  /// §17.18.50 @rsidSect (ST_LongHexNumber) — optional section-properties rsid.
  rsid_sect : ST_LongHexNumber?
  /// EG_SectPrContents children captured in document order; per-element
  /// typing is provided by chunk1/chunk3 typed structs as appropriate.
  contents : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_SectPrBase — Part 1 §17.6.18 (legacy base).
pub fn CT_SectPrBase::new(
  element : @xml.Element,
) -> CT_SectPrBase raise SchemaViolation {
  let rsid_rpr = match wml_ct_chunk3_attr(element, "rsidRPr") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_del = match wml_ct_chunk3_attr(element, "rsidDel") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_r = match wml_ct_chunk3_attr(element, "rsidR") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_sect = match wml_ct_chunk3_attr(element, "rsidSect") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let contents : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => contents.push(e)
      _ => ()
    }
  }
  { element, rsid_rpr, rsid_del, rsid_r, rsid_sect, contents }
}

///|
/// XSD complex type CT_SectPrBase — Part 1 §17.6.18.
pub fn CT_SectPrBase::parse(
  element : @xml.Element,
) -> CT_SectPrBase raise SchemaViolation {
  CT_SectPrBase::new(element)
}

///|
/// XSD complex type CT_SectPrBase — return the preserved element for writers.
pub fn CT_SectPrBase::to_element(self : CT_SectPrBase) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SectPr — Part 1 §17.6.18 sectPr. Section-properties
/// type: EG_HdrFtrReferences (minOccurs=0 maxOccurs=6 — alternating
/// header / footer references), EG_SectPrContents (see CT_SectPrBase),
/// optional `<sectPrChange>` (CT_SectPrChange §17.13.5.34), plus
/// AG_SectPrAttributes (rsidRPr / rsidDel / rsidR / rsidSect).
pub(all) struct CT_SectPr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.50 @rsidRPr (ST_LongHexNumber) — optional run-property rsid.
  rsid_rpr : ST_LongHexNumber?
  /// §17.18.50 @rsidDel (ST_LongHexNumber) — optional deletion rsid.
  rsid_del : ST_LongHexNumber?
  /// §17.18.50 @rsidR (ST_LongHexNumber) — optional run rsid.
  rsid_r : ST_LongHexNumber?
  /// §17.18.50 @rsidSect (ST_LongHexNumber) — optional section rsid.
  rsid_sect : ST_LongHexNumber?
  /// EG_HdrFtrReferences `<headerReference>` (CT_HdrFtrRef) entries.
  header_references : Array[CT_HdrFtrRef]
  /// EG_HdrFtrReferences `<footerReference>` (CT_HdrFtrRef) entries.
  footer_references : Array[CT_HdrFtrRef]
  /// EG_SectPrContents children captured in document order.
  contents : Array[@xml.Element]
  /// §17.13.5.34 `<sectPrChange>` (CT_SectPrChange) — optional revision marker.
  sect_pr_change : CT_SectPrChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SectPr — Part 1 §17.6.18.
pub fn CT_SectPr::new(
  element : @xml.Element,
) -> CT_SectPr raise SchemaViolation {
  let rsid_rpr = match wml_ct_chunk3_attr(element, "rsidRPr") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_del = match wml_ct_chunk3_attr(element, "rsidDel") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_r = match wml_ct_chunk3_attr(element, "rsidR") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_sect = match wml_ct_chunk3_attr(element, "rsidSect") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let header_references = []
  for e in wml_ct_chunk3_children(element, "headerReference") {
    header_references.push(CT_HdrFtrRef::new(e))
  }
  let footer_references = []
  for e in wml_ct_chunk3_children(element, "footerReference") {
    footer_references.push(CT_HdrFtrRef::new(e))
  }
  let contents : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        let is_handled = ln == "headerReference" ||
          ln == "footerReference" ||
          ln == "sectPrChange"
        if not(is_handled) {
          contents.push(e)
        }
      }
      _ => ()
    }
  }
  let sect_pr_change = match
    wml_ct_chunk3_first_child(element, "sectPrChange") {
    Some(e) => Some(CT_SectPrChange::new(e))
    None => None
  }
  {
    element,
    rsid_rpr,
    rsid_del,
    rsid_r,
    rsid_sect,
    header_references,
    footer_references,
    contents,
    sect_pr_change,
  }
}

///|
/// XSD complex type CT_SectPr — Part 1 §17.6.18.
pub fn CT_SectPr::parse(
  element : @xml.Element,
) -> CT_SectPr raise SchemaViolation {
  CT_SectPr::new(element)
}

///|
/// XSD complex type CT_SectPr — return the preserved element for writers.
pub fn CT_SectPr::to_element(self : CT_SectPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Br — Part 1 §17.3.3.1 br. Run-level break element
/// with two optional attributes: `@type` (ST_BrType §17.18.3 — page /
/// column / textWrapping) and `@clear` (ST_BrClear §17.18.4 — none /
/// left / right / all, used when `@type="textWrapping"`).
pub(all) struct CT_Br {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.3 @type (ST_BrType) — optional break kind.
  type_ : ST_BrType?
  /// §17.18.4 @clear (ST_BrClear) — optional text-wrap clear policy.
  clear : ST_BrClear?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Br — Part 1 §17.3.3.1.
pub fn CT_Br::new(element : @xml.Element) -> CT_Br raise SchemaViolation {
  let type_ = match wml_ct_chunk3_attr(element, "type") {
    Some(text) => Some(ST_BrType::parse(text))
    None => None
  }
  let clear = match wml_ct_chunk3_attr(element, "clear") {
    Some(text) => Some(ST_BrClear::parse(text))
    None => None
  }
  { element, type_, clear }
}

///|
/// XSD complex type CT_Br — Part 1 §17.3.3.1.
pub fn CT_Br::parse(element : @xml.Element) -> CT_Br raise SchemaViolation {
  CT_Br::new(element)
}

///|
/// XSD complex type CT_Br — return the preserved element for writers.
pub fn CT_Br::to_element(self : CT_Br) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PTab — Part 1 §17.3.3.23 ptab. Custom-tab descriptor
/// with three required attributes: `@alignment` (ST_PTabAlignment §17.18.69
/// — left / center / right), `@relativeTo` (ST_PTabRelativeTo §17.18.71 —
/// margin / indent), `@leader` (ST_PTabLeader §17.18.70 — none / dot /
/// hyphen / underscore / middleDot).
pub(all) struct CT_PTab {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.69 @alignment (ST_PTabAlignment) — required alignment.
  alignment : ST_PTabAlignment
  /// §17.18.71 @relativeTo (ST_PTabRelativeTo) — required relative-to anchor.
  relative_to : ST_PTabRelativeTo
  /// §17.18.70 @leader (ST_PTabLeader) — required leader glyph.
  leader : ST_PTabLeader
} derive(Eq, Debug)

///|
/// XSD complex type CT_PTab — Part 1 §17.3.3.23.
pub fn CT_PTab::new(element : @xml.Element) -> CT_PTab raise SchemaViolation {
  let raw_alignment = wml_ct_chunk3_required_attr(
    element, "alignment", "CT_PTab", "Part 1 §17.18.69 ST_PTabAlignment",
  )
  let alignment = ST_PTabAlignment::parse(raw_alignment)
  let raw_relative_to = wml_ct_chunk3_required_attr(
    element, "relativeTo", "CT_PTab", "Part 1 §17.18.71 ST_PTabRelativeTo",
  )
  let relative_to = ST_PTabRelativeTo::parse(raw_relative_to)
  let raw_leader = wml_ct_chunk3_required_attr(
    element, "leader", "CT_PTab", "Part 1 §17.18.70 ST_PTabLeader",
  )
  let leader = ST_PTabLeader::parse(raw_leader)
  { element, alignment, relative_to, leader }
}

///|
/// XSD complex type CT_PTab — Part 1 §17.3.3.23.
pub fn CT_PTab::parse(element : @xml.Element) -> CT_PTab raise SchemaViolation {
  CT_PTab::new(element)
}

///|
/// XSD complex type CT_PTab — return the preserved element for writers.
pub fn CT_PTab::to_element(self : CT_PTab) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Sym — Part 1 §17.3.3.30 sym. Symbol-character run
/// content with two optional attributes: `@font` (s:ST_String — typeface
/// name) and `@char` (ST_ShortHexNumber §17.18.79 — four hex digit
/// codepoint).
pub(all) struct CT_Sym {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @font (s:ST_String) — optional font face name.
  font : String?
  /// §17.18.79 @char (ST_ShortHexNumber) — optional codepoint.
  char_ : ST_ShortHexNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Sym — Part 1 §17.3.3.30.
pub fn CT_Sym::new(element : @xml.Element) -> CT_Sym raise SchemaViolation {
  let font = wml_ct_chunk3_attr(element, "font")
  let char_ = match wml_ct_chunk3_attr(element, "char") {
    Some(text) => Some(ST_ShortHexNumber::parse(text))
    None => None
  }
  { element, font, char_ }
}

///|
/// XSD complex type CT_Sym — Part 1 §17.3.3.30.
pub fn CT_Sym::parse(element : @xml.Element) -> CT_Sym raise SchemaViolation {
  CT_Sym::new(element)
}

///|
/// XSD complex type CT_Sym — return the preserved element for writers.
pub fn CT_Sym::to_element(self : CT_Sym) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ProofErr — Part 1 §17.13.8.1 proofErr. Marker for a
/// spelling or grammar boundary. Single required `@type` attribute
/// (ST_ProofErr §17.18.72 — spellStart / spellEnd / gramStart / gramEnd).
pub(all) struct CT_ProofErr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.72 @type (ST_ProofErr) — required boundary kind.
  type_ : ST_ProofErr
} derive(Eq, Debug)

///|
/// XSD complex type CT_ProofErr — Part 1 §17.13.8.1.
pub fn CT_ProofErr::new(
  element : @xml.Element,
) -> CT_ProofErr raise SchemaViolation {
  let raw = wml_ct_chunk3_required_attr(
    element, "type", "CT_ProofErr", "Part 1 §17.18.72 ST_ProofErr",
  )
  let type_ = ST_ProofErr::parse(raw)
  { element, type_ }
}

///|
/// XSD complex type CT_ProofErr — Part 1 §17.13.8.1.
pub fn CT_ProofErr::parse(
  element : @xml.Element,
) -> CT_ProofErr raise SchemaViolation {
  CT_ProofErr::new(element)
}

///|
/// XSD complex type CT_ProofErr — return the preserved element for writers.
pub fn CT_ProofErr::to_element(self : CT_ProofErr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Perm — Part 1 §17.13.7.2 permEnd / permStart base.
/// Permission-range marker with required `@id` (s:ST_String — range id)
/// and optional `@displacedByCustomXml` (ST_DisplacedByCustomXml §17.18.13
/// — next / prev).
pub(all) struct CT_Perm {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @id (s:ST_String) — required range id.
  id : String
  /// §17.18.13 @displacedByCustomXml (ST_DisplacedByCustomXml) — optional.
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Perm — Part 1 §17.13.7.2.
pub fn CT_Perm::new(element : @xml.Element) -> CT_Perm raise SchemaViolation {
  let id = wml_ct_chunk3_required_attr(
    element, "id", "CT_Perm", "Part 1 §22.9.2.13 s:ST_String",
  )
  let displaced_by_custom_xml = match
    wml_ct_chunk3_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  { element, id, displaced_by_custom_xml }
}

///|
/// XSD complex type CT_Perm — Part 1 §17.13.7.2.
pub fn CT_Perm::parse(element : @xml.Element) -> CT_Perm raise SchemaViolation {
  CT_Perm::new(element)
}

///|
/// XSD complex type CT_Perm — return the preserved element for writers.
pub fn CT_Perm::to_element(self : CT_Perm) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_PermStart — Part 1 §17.13.7.3 permStart.
/// `xsd:complexContent` extension of CT_Perm (§17.13.7.2) adding four
/// optional attributes: `@edGrp` (ST_EdGrp §17.18.17 — granted group),
/// `@ed` (s:ST_String — granted user), `@colFirst` / `@colLast`
/// (ST_DecimalNumber §17.18.10 — table column range).
pub(all) struct CT_PermStart {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 @id (s:ST_String) — required range id (inherited from CT_Perm).
  id : String
  /// §17.18.13 @displacedByCustomXml (ST_DisplacedByCustomXml) — optional (inherited).
  displaced_by_custom_xml : ST_DisplacedByCustomXml?
  /// §17.18.17 @edGrp (ST_EdGrp) — optional granted editor group.
  ed_grp : ST_EdGrp?
  /// §22.9.2.13 @ed (s:ST_String) — optional granted editor user.
  ed : String?
  /// §17.18.10 @colFirst (ST_DecimalNumber) — optional first column id.
  col_first : ST_DecimalNumber?
  /// §17.18.10 @colLast (ST_DecimalNumber) — optional last column id.
  col_last : ST_DecimalNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_PermStart — Part 1 §17.13.7.3.
pub fn CT_PermStart::new(
  element : @xml.Element,
) -> CT_PermStart raise SchemaViolation {
  let id = wml_ct_chunk3_required_attr(
    element, "id", "CT_PermStart", "Part 1 §22.9.2.13 s:ST_String",
  )
  let displaced_by_custom_xml = match
    wml_ct_chunk3_attr(element, "displacedByCustomXml") {
    Some(text) => Some(ST_DisplacedByCustomXml::parse(text))
    None => None
  }
  let ed_grp = match wml_ct_chunk3_attr(element, "edGrp") {
    Some(text) => Some(ST_EdGrp::parse(text))
    None => None
  }
  let ed = wml_ct_chunk3_attr(element, "ed")
  let col_first = match wml_ct_chunk3_attr(element, "colFirst") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  let col_last = match wml_ct_chunk3_attr(element, "colLast") {
    Some(text) => Some(ST_DecimalNumber::parse(text))
    None => None
  }
  { element, id, displaced_by_custom_xml, ed_grp, ed, col_first, col_last }
}

///|
/// XSD complex type CT_PermStart — Part 1 §17.13.7.3.
pub fn CT_PermStart::parse(
  element : @xml.Element,
) -> CT_PermStart raise SchemaViolation {
  CT_PermStart::new(element)
}

///|
/// XSD complex type CT_PermStart — return the preserved element for writers.
pub fn CT_PermStart::to_element(self : CT_PermStart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Text — Part 1 §17.3.3.31 t / §17.3.3.4 delText etc.
/// `xsd:simpleContent` extension of s:ST_String — the element body carries
/// the text. Optional `@xml:space` attribute selects whitespace handling
/// (preserve / default per W3C XML 1.0 §2.10).
pub(all) struct CT_Text {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.13 simple-content payload — the concatenated text / CDATA value.
  value : String
  /// @xml:space — optional whitespace policy.
  xml_space : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Text — Part 1 §17.3.3.31.
pub fn CT_Text::new(element : @xml.Element) -> CT_Text {
  let value = wml_ct_chunk3_text_value(element)
  let xml_space = wml_ct_chunk3_attr(element, "space")
  { element, value, xml_space }
}

///|
/// XSD complex type CT_Text — Part 1 §17.3.3.31.
pub fn CT_Text::parse(element : @xml.Element) -> CT_Text {
  CT_Text::new(element)
}

///|
/// XSD complex type CT_Text — return the preserved element for writers.
pub fn CT_Text::to_element(self : CT_Text) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_R — Part 1 §17.3.2.25 r. WordprocessingML run
/// container: optional `<rPr>` (CT_RPr §17.3.2.27) and the
/// EG_RunInnerContent model-group sequence (§A.1 — `br`, `t`,
/// `contentPart`, `delText`, `instrText`, `delInstrText`, `noBreakHyphen`,
/// `softHyphen`, date / month / year tokens, refs, `sym`, `pgNum`, `cr`,
/// `tab`, `object`, `pict`, `fldChar`, `ruby`, footnote/endnote
/// references, `commentReference`, `drawing`, `ptab`,
/// `lastRenderedPageBreak`). Three optional rsid attributes:
/// `@rsidRPr` / `@rsidDel` / `@rsidR` (ST_LongHexNumber §17.18.50).
pub(all) struct CT_R {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.50 @rsidRPr (ST_LongHexNumber) — optional run-property rsid.
  rsid_rpr : ST_LongHexNumber?
  /// §17.18.50 @rsidDel (ST_LongHexNumber) — optional deletion rsid.
  rsid_del : ST_LongHexNumber?
  /// §17.18.50 @rsidR (ST_LongHexNumber) — optional run rsid.
  rsid_r : ST_LongHexNumber?
  /// §17.3.2.27 `<rPr>` (CT_RPr) — optional run properties.
  r_pr : CT_RPr?
  /// EG_RunInnerContent child elements in document order (raw, because the
  /// group spans 30+ heterogeneous element types — typed projections
  /// remain the responsibility of higher-layer reader.mbt code).
  inner_content : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_R — Part 1 §17.3.2.25.
pub fn CT_R::new(element : @xml.Element) -> CT_R raise SchemaViolation {
  let rsid_rpr = match wml_ct_chunk3_attr(element, "rsidRPr") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_del = match wml_ct_chunk3_attr(element, "rsidDel") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_r = match wml_ct_chunk3_attr(element, "rsidR") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let r_pr = match wml_ct_chunk3_first_child(element, "rPr") {
    Some(e) => Some(CT_RPr::new(e))
    None => None
  }
  let inner_content : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name != "rPr" { inner_content.push(e) }
      _ => ()
    }
  }
  { element, rsid_rpr, rsid_del, rsid_r, r_pr, inner_content }
}

///|
/// XSD complex type CT_R — Part 1 §17.3.2.25.
pub fn CT_R::parse(element : @xml.Element) -> CT_R raise SchemaViolation {
  CT_R::new(element)
}

///|
/// XSD complex type CT_R — return the preserved element for writers.
pub fn CT_R::to_element(self : CT_R) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Fonts — Part 1 §17.3.2.26 rFonts. Run typeface
/// descriptor with nine optional attributes covering hint, explicit
/// face names (ASCII / hAnsi / EastAsia / Complex Script), and the
/// theme-derived counterparts (asciiTheme / hAnsiTheme / eastAsiaTheme /
/// cstheme).
pub(all) struct CT_Fonts {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.39 @hint (ST_Hint) — optional run-font hint.
  hint : ST_Hint?
  /// §22.9.2.13 @ascii (s:ST_String) — optional ASCII face name.
  ascii : String?
  /// §22.9.2.13 @hAnsi (s:ST_String) — optional High-ANSI face name.
  h_ansi : String?
  /// §22.9.2.13 @eastAsia (s:ST_String) — optional East-Asian face name.
  east_asia : String?
  /// §22.9.2.13 @cs (s:ST_String) — optional Complex-Script face name.
  cs : String?
  /// §17.18.96 @asciiTheme (ST_Theme) — optional theme-derived ASCII font.
  ascii_theme : ST_Theme?
  /// §17.18.96 @hAnsiTheme (ST_Theme) — optional theme-derived High-ANSI font.
  h_ansi_theme : ST_Theme?
  /// §17.18.96 @eastAsiaTheme (ST_Theme) — optional theme-derived East-Asian font.
  east_asia_theme : ST_Theme?
  /// §17.18.96 @cstheme (ST_Theme) — optional theme-derived Complex-Script font.
  cstheme : ST_Theme?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Fonts — Part 1 §17.3.2.26.
pub fn CT_Fonts::new(element : @xml.Element) -> CT_Fonts raise SchemaViolation {
  let hint = match wml_ct_chunk3_attr(element, "hint") {
    Some(text) => Some(ST_Hint::parse(text))
    None => None
  }
  let ascii = wml_ct_chunk3_attr(element, "ascii")
  let h_ansi = wml_ct_chunk3_attr(element, "hAnsi")
  let east_asia = wml_ct_chunk3_attr(element, "eastAsia")
  let cs = wml_ct_chunk3_attr(element, "cs")
  let ascii_theme = match wml_ct_chunk3_attr(element, "asciiTheme") {
    Some(text) => Some(ST_Theme::parse(text))
    None => None
  }
  let h_ansi_theme = match wml_ct_chunk3_attr(element, "hAnsiTheme") {
    Some(text) => Some(ST_Theme::parse(text))
    None => None
  }
  let east_asia_theme = match wml_ct_chunk3_attr(element, "eastAsiaTheme") {
    Some(text) => Some(ST_Theme::parse(text))
    None => None
  }
  let cstheme = match wml_ct_chunk3_attr(element, "cstheme") {
    Some(text) => Some(ST_Theme::parse(text))
    None => None
  }
  {
    element,
    hint,
    ascii,
    h_ansi,
    east_asia,
    cs,
    ascii_theme,
    h_ansi_theme,
    east_asia_theme,
    cstheme,
  }
}

///|
/// XSD complex type CT_Fonts — Part 1 §17.3.2.26.
pub fn CT_Fonts::parse(
  element : @xml.Element,
) -> CT_Fonts raise SchemaViolation {
  CT_Fonts::new(element)
}

///|
/// XSD complex type CT_Fonts — return the preserved element for writers.
pub fn CT_Fonts::to_element(self : CT_Fonts) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPr — Part 1 §17.3.2.27 rPr. Run-properties payload:
/// EG_RPrContent which is EG_RPrBase (the 39 run-property elements from
/// `<rStyle>` through `<oMath>`) plus an optional `<rPrChange>`
/// (CT_RPrChange §17.13.5.31). The base-group children are kept as
/// `Array[@xml.Element]` because chunk2 still owns their typed structs.
pub(all) struct CT_RPr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// EG_RPrBase child elements in document order (raw — typed in chunk1/chunk2/chunk3).
  base : Array[@xml.Element]
  /// §17.13.5.31 `<rPrChange>` (CT_RPrChange) — optional revision marker.
  r_pr_change : CT_RPrChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_RPr — Part 1 §17.3.2.27.
pub fn CT_RPr::new(element : @xml.Element) -> CT_RPr raise SchemaViolation {
  let base : Array[@xml.Element] = []
  let mut r_pr_change : CT_RPrChange? = None
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name == "rPrChange" {
          if r_pr_change is None {
            r_pr_change = Some(CT_RPrChange::new(e))
          }
        } else {
          base.push(e)
        }
      _ => ()
    }
  }
  { element, base, r_pr_change }
}

///|
/// XSD complex type CT_RPr — Part 1 §17.3.2.27.
pub fn CT_RPr::parse(element : @xml.Element) -> CT_RPr raise SchemaViolation {
  CT_RPr::new(element)
}

///|
/// XSD complex type CT_RPr — return the preserved element for writers.
pub fn CT_RPr::to_element(self : CT_RPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MathCtrlIns — Part 1 §17.3.2.16 oMath insert.
/// `xsd:complexContent` extension of CT_TrackChange (§17.13.5.13) adding
/// an optional xsd:choice between `<del>` (CT_RPrChange §17.13.5.31) and
/// `<rPr>` (CT_RPr §17.3.2.27).
pub(all) enum CT_MathCtrlInsChoice {
  /// §17.13.5.31 `<del>` (CT_RPrChange) branch of the xsd:choice.
  CT_MathCtrlInsChoice_Del(CT_RPrChange)
  /// §17.3.2.27 `<rPr>` (CT_RPr) branch of the xsd:choice.
  CT_MathCtrlInsChoice_RPr(CT_RPr)
} derive(Eq, Debug)

///|
/// XSD complex type CT_MathCtrlIns — Part 1 §17.3.2.16.
pub(all) struct CT_MathCtrlIns {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// CT_TrackChange base — captured as the source element because chunk2
  /// still owns the typed projection.
  track_change : CT_TrackChange
  /// Optional `<del>`/`<rPr>` xsd:choice payload (minOccurs=0).
  choice : CT_MathCtrlInsChoice?
} derive(Eq, Debug)

///|
/// XSD complex type CT_MathCtrlIns — Part 1 §17.3.2.16.
pub fn CT_MathCtrlIns::new(
  element : @xml.Element,
) -> CT_MathCtrlIns raise SchemaViolation {
  let track_change = CT_TrackChange::new(element)
  let choice = match wml_ct_chunk3_first_choice(element, ["del", "rPr"]) {
    Some((e, "del")) => Some(CT_MathCtrlInsChoice_Del(CT_RPrChange::new(e)))
    Some((e, "rPr")) => Some(CT_MathCtrlInsChoice_RPr(CT_RPr::new(e)))
    Some(_) => None
    None => None
  }
  { element, track_change, choice }
}

///|
/// XSD complex type CT_MathCtrlIns — Part 1 §17.3.2.16.
pub fn CT_MathCtrlIns::parse(
  element : @xml.Element,
) -> CT_MathCtrlIns raise SchemaViolation {
  CT_MathCtrlIns::new(element)
}

///|
/// XSD complex type CT_MathCtrlIns — return the preserved element for writers.
pub fn CT_MathCtrlIns::to_element(self : CT_MathCtrlIns) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_MathCtrlDel — Part 1 §17.3.2.15 oMath delete.
/// `xsd:complexContent` extension of CT_TrackChange (§17.13.5.13) adding
/// an optional `<rPr>` (CT_RPr §17.3.2.27) via xsd:choice (minOccurs=0).
pub(all) struct CT_MathCtrlDel {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// CT_TrackChange base — captured as the source element because chunk2
  /// still owns the typed projection.
  track_change : CT_TrackChange
  /// §17.3.2.27 `<rPr>` (CT_RPr) — optional xsd:choice payload.
  r_pr : CT_RPr?
} derive(Eq, Debug)

///|
/// XSD complex type CT_MathCtrlDel — Part 1 §17.3.2.15.
pub fn CT_MathCtrlDel::new(
  element : @xml.Element,
) -> CT_MathCtrlDel raise SchemaViolation {
  let track_change = CT_TrackChange::new(element)
  let r_pr = match wml_ct_chunk3_first_child(element, "rPr") {
    Some(e) => Some(CT_RPr::new(e))
    None => None
  }
  { element, track_change, r_pr }
}

///|
/// XSD complex type CT_MathCtrlDel — Part 1 §17.3.2.15.
pub fn CT_MathCtrlDel::parse(
  element : @xml.Element,
) -> CT_MathCtrlDel raise SchemaViolation {
  CT_MathCtrlDel::new(element)
}

///|
/// XSD complex type CT_MathCtrlDel — return the preserved element for writers.
pub fn CT_MathCtrlDel::to_element(self : CT_MathCtrlDel) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RPrOriginal — Part 1 §17.13.5.32 rPr (revision base
/// snapshot inside CT_RPrChange). The body is the EG_RPrBase model group
/// (zero-or-more run-property elements, captured here as raw elements
/// because the typed projections are owned by chunks 1/2). No attributes.
pub(all) struct CT_RPrOriginal {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// EG_RPrBase children in document order.
  base : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_RPrOriginal — Part 1 §17.13.5.32.
pub fn CT_RPrOriginal::new(element : @xml.Element) -> CT_RPrOriginal {
  let base : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => base.push(e)
      _ => ()
    }
  }
  { element, base }
}

///|
/// XSD complex type CT_RPrOriginal — Part 1 §17.13.5.32.
pub fn CT_RPrOriginal::parse(element : @xml.Element) -> CT_RPrOriginal {
  CT_RPrOriginal::new(element)
}

///|
/// XSD complex type CT_RPrOriginal — return the preserved element for writers.
pub fn CT_RPrOriginal::to_element(self : CT_RPrOriginal) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPrOriginal — Part 1 §17.13.5.21 rPr (paragraph
/// revision base snapshot inside CT_ParaRPrChange). The body is the
/// EG_ParaRPrTrackChanges group (`<ins>`, `<del>`, `<moveFrom>`,
/// `<moveTo>` — each CT_TrackChange) followed by EG_RPrBase (raw
/// run-property elements). No attributes.
pub(all) struct CT_ParaRPrOriginal {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.13.5.21 `<ins>` (CT_TrackChange) — optional insert revision marker.
  ins : CT_TrackChange?
  /// §17.13.5.21 `<del>` (CT_TrackChange) — optional delete revision marker.
  del : CT_TrackChange?
  /// §17.13.5.21 `<moveFrom>` (CT_TrackChange) — optional move-source marker.
  move_from : CT_TrackChange?
  /// §17.13.5.21 `<moveTo>` (CT_TrackChange) — optional move-target marker.
  move_to : CT_TrackChange?
  /// EG_RPrBase children in document order.
  base : Array[@xml.Element]
} derive(Eq, Debug)

///|
/// XSD complex type CT_ParaRPrOriginal — Part 1 §17.13.5.21.
pub fn CT_ParaRPrOriginal::new(
  element : @xml.Element,
) -> CT_ParaRPrOriginal raise SchemaViolation {
  let ins = match wml_ct_chunk3_first_child(element, "ins") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let del = match wml_ct_chunk3_first_child(element, "del") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let move_from = match wml_ct_chunk3_first_child(element, "moveFrom") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let move_to = match wml_ct_chunk3_first_child(element, "moveTo") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let base : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        let is_track = ln == "ins" ||
          ln == "del" ||
          ln == "moveFrom" ||
          ln == "moveTo"
        if not(is_track) {
          base.push(e)
        }
      }
      _ => ()
    }
  }
  { element, ins, del, move_from, move_to, base }
}

///|
/// XSD complex type CT_ParaRPrOriginal — Part 1 §17.13.5.21.
pub fn CT_ParaRPrOriginal::parse(
  element : @xml.Element,
) -> CT_ParaRPrOriginal raise SchemaViolation {
  CT_ParaRPrOriginal::new(element)
}

///|
/// XSD complex type CT_ParaRPrOriginal — return the preserved element for writers.
pub fn CT_ParaRPrOriginal::to_element(
  self : CT_ParaRPrOriginal,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_ParaRPr — Part 1 §17.3.1.29 rPr (inside paragraph
/// properties). Same EG_ParaRPrTrackChanges + EG_RPrBase as
/// CT_ParaRPrOriginal plus an optional `<rPrChange>` (CT_ParaRPrChange
/// §17.13.5.30).
pub(all) struct CT_ParaRPr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.13.5.21 `<ins>` — optional insert revision marker.
  ins : CT_TrackChange?
  /// §17.13.5.21 `<del>` — optional delete revision marker.
  del : CT_TrackChange?
  /// §17.13.5.21 `<moveFrom>` — optional move-source revision marker.
  move_from : CT_TrackChange?
  /// §17.13.5.21 `<moveTo>` — optional move-target revision marker.
  move_to : CT_TrackChange?
  /// EG_RPrBase children in document order.
  base : Array[@xml.Element]
  /// §17.13.5.30 `<rPrChange>` (CT_ParaRPrChange) — optional revision marker.
  r_pr_change : CT_ParaRPrChange?
} derive(Eq, Debug)

///|
/// XSD complex type CT_ParaRPr — Part 1 §17.3.1.29.
pub fn CT_ParaRPr::new(
  element : @xml.Element,
) -> CT_ParaRPr raise SchemaViolation {
  let ins = match wml_ct_chunk3_first_child(element, "ins") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let del = match wml_ct_chunk3_first_child(element, "del") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let move_from = match wml_ct_chunk3_first_child(element, "moveFrom") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let move_to = match wml_ct_chunk3_first_child(element, "moveTo") {
    Some(e) => Some(CT_TrackChange::new(e))
    None => None
  }
  let r_pr_change = match wml_ct_chunk3_first_child(element, "rPrChange") {
    Some(e) => Some(CT_ParaRPrChange::new(e))
    None => None
  }
  let base : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        let is_track = ln == "ins" ||
          ln == "del" ||
          ln == "moveFrom" ||
          ln == "moveTo" ||
          ln == "rPrChange"
        if not(is_track) {
          base.push(e)
        }
      }
      _ => ()
    }
  }
  { element, ins, del, move_from, move_to, base, r_pr_change }
}

///|
/// XSD complex type CT_ParaRPr — Part 1 §17.3.1.29.
pub fn CT_ParaRPr::parse(
  element : @xml.Element,
) -> CT_ParaRPr raise SchemaViolation {
  CT_ParaRPr::new(element)
}

///|
/// XSD complex type CT_ParaRPr — return the preserved element for writers.
pub fn CT_ParaRPr::to_element(self : CT_ParaRPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AltChunk — Part 1 §17.17.2.1 altChunk. External-
/// content insertion point with an optional `<altChunkPr>`
/// (CT_AltChunkPr §17.17.2.2) child and an optional `@r:id`
/// relationship reference to the alternate content stream.
pub(all) struct CT_AltChunk {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.2.2 `<altChunkPr>` (CT_AltChunkPr) — optional properties.
  alt_chunk_pr : CT_AltChunkPr?
  /// §A.6.7 @r:id — optional relationship reference.
  r_id : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_AltChunk — Part 1 §17.17.2.1.
pub fn CT_AltChunk::new(element : @xml.Element) -> CT_AltChunk {
  let alt_chunk_pr = match wml_ct_chunk3_first_child(element, "altChunkPr") {
    Some(e) => Some(CT_AltChunkPr::new(e))
    None => None
  }
  let r_id = wml_ct_chunk3_attr_ns(element, wml_ct_chunk3_ns_r(), "id")
  { element, alt_chunk_pr, r_id }
}

///|
/// XSD complex type CT_AltChunk — Part 1 §17.17.2.1.
pub fn CT_AltChunk::parse(element : @xml.Element) -> CT_AltChunk {
  CT_AltChunk::new(element)
}

///|
/// XSD complex type CT_AltChunk — return the preserved element for writers.
pub fn CT_AltChunk::to_element(self : CT_AltChunk) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_AltChunkPr — Part 1 §17.17.2.2 altChunkPr. Alternate
/// content properties carrying a single optional `<matchSrc>`
/// (CT_OnOff §17.17.2.3) flag.
pub(all) struct CT_AltChunkPr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.17.2.3 `<matchSrc>` (CT_OnOff) — optional match-source toggle.
  match_src : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_AltChunkPr — Part 1 §17.17.2.2.
pub fn CT_AltChunkPr::new(element : @xml.Element) -> CT_AltChunkPr {
  let match_src = match wml_ct_chunk3_first_child(element, "matchSrc") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  { element, match_src }
}

///|
/// XSD complex type CT_AltChunkPr — Part 1 §17.17.2.2.
pub fn CT_AltChunkPr::parse(element : @xml.Element) -> CT_AltChunkPr {
  CT_AltChunkPr::new(element)
}

///|
/// XSD complex type CT_AltChunkPr — return the preserved element for writers.
pub fn CT_AltChunkPr::to_element(self : CT_AltChunkPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyAlign — Part 1 §17.3.3.27 rubyAlign. Ruby
/// alignment descriptor with a required `@val` (ST_RubyAlign §17.18.78
/// — center / distributeLetter / distributeSpace / left / right /
/// rightVertical).
pub(all) struct CT_RubyAlign {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.78 @val (ST_RubyAlign) — required alignment.
  val : ST_RubyAlign
} derive(Eq, Debug)

///|
/// XSD complex type CT_RubyAlign — Part 1 §17.3.3.27.
pub fn CT_RubyAlign::new(
  element : @xml.Element,
) -> CT_RubyAlign raise SchemaViolation {
  let raw = wml_ct_chunk3_required_attr(
    element, "val", "CT_RubyAlign", "Part 1 §17.18.78 ST_RubyAlign",
  )
  let val = ST_RubyAlign::parse(raw)
  { element, val }
}

///|
/// XSD complex type CT_RubyAlign — Part 1 §17.3.3.27.
pub fn CT_RubyAlign::parse(
  element : @xml.Element,
) -> CT_RubyAlign raise SchemaViolation {
  CT_RubyAlign::new(element)
}

///|
/// XSD complex type CT_RubyAlign — return the preserved element for writers.
pub fn CT_RubyAlign::to_element(self : CT_RubyAlign) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyPr — Part 1 §17.3.3.28 rubyPr. Ruby presentation
/// descriptor: required `<rubyAlign>` (CT_RubyAlign §17.3.3.27), required
/// `<hps>` / `<hpsRaise>` / `<hpsBaseText>` (CT_HpsMeasure §17.18.42),
/// required `<lid>` (CT_Lang §17.18.46), optional `<dirty>`
/// (CT_OnOff §17.17.4 — proofing-dirty flag). No attributes.
pub(all) struct CT_RubyPr {
  /// Source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.3.27 `<rubyAlign>` (CT_RubyAlign) — required alignment.
  ruby_align : CT_RubyAlign
  /// §17.18.42 `<hps>` (CT_HpsMeasure) — required ruby font size.
  hps : CT_HpsMeasure
  /// §17.18.42 `<hpsRaise>` (CT_HpsMeasure) — required ruby raise distance.
  hps_raise : CT_HpsMeasure
  /// §17.18.42 `<hpsBaseText>` (CT_HpsMeasure) — required base text size.
  hps_base_text : CT_HpsMeasure
  /// §17.18.46 `<lid>` (CT_Lang) — required ruby language.
  lid : CT_Lang
  /// §17.17.4 `<dirty>` (CT_OnOff) — optional proofing-dirty flag.
  dirty : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_RubyPr — Part 1 §17.3.3.28.
pub fn CT_RubyPr::new(
  element : @xml.Element,
) -> CT_RubyPr raise SchemaViolation {
  let ruby_align_e = match wml_ct_chunk3_first_child(element, "rubyAlign") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_RubyPr", "rubyAlign", "Part 1 §17.3.3.28: required child <rubyAlign> is missing",
      )
  }
  let ruby_align = CT_RubyAlign::new(ruby_align_e)
  let hps_e = match wml_ct_chunk3_first_child(element, "hps") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_RubyPr", "hps", "Part 1 §17.3.3.28: required child <hps> is missing",
      )
  }
  let hps = CT_HpsMeasure::new(hps_e)
  let hps_raise_e = match wml_ct_chunk3_first_child(element, "hpsRaise") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_RubyPr", "hpsRaise", "Part 1 §17.3.3.28: required child <hpsRaise> is missing",
      )
  }
  let hps_raise = CT_HpsMeasure::new(hps_raise_e)
  let hps_base_text_e = match
    wml_ct_chunk3_first_child(element, "hpsBaseText") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_RubyPr", "hpsBaseText", "Part 1 §17.3.3.28: required child <hpsBaseText> is missing",
      )
  }
  let hps_base_text = CT_HpsMeasure::new(hps_base_text_e)
  let lid_e = match wml_ct_chunk3_first_child(element, "lid") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_RubyPr", "lid", "Part 1 §17.3.3.28: required child <lid> is missing",
      )
  }
  let lid = CT_Lang::new(lid_e)
  let dirty = match wml_ct_chunk3_first_child(element, "dirty") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  { element, ruby_align, hps, hps_raise, hps_base_text, lid, dirty }
}

///|
/// XSD complex type CT_RubyPr — Part 1 §17.3.3.28.
pub fn CT_RubyPr::parse(
  element : @xml.Element,
) -> CT_RubyPr raise SchemaViolation {
  CT_RubyPr::new(element)
}

///|
/// XSD complex type CT_RubyPr — return the preserved element for writers.
pub fn CT_RubyPr::to_element(self : CT_RubyPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_RubyContent — Part 1 §17.3.3.24 rt (Phonetic Guide
/// Text) and §17.3.3.27 rubyBase (Phonetic Guide Base Text). Both `rt` and
/// `rubyBase` reuse this type. Wraps a single reference to model group
/// EG_RubyContent with `minOccurs="0" maxOccurs="unbounded"` — the choice
/// among `<r>` (CT_R), EG_RunLevelElts members and EG_MathContent members.
/// No attributes.
pub(all) struct CT_RubyContent {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.3.24/§17.3.3.27 EG_RubyContent* — zero or more ruby-content
  /// children (runs, run-level marks or math content) preserved in
  /// document order via the model-group wrapper.
  ruby_content : EG_RubyContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_RubyContent — Part 1 §17.3.3.24 / §17.3.3.27. Decode
/// the EG_RubyContent* children by collecting every element child.
pub fn CT_RubyContent::new(element : @xml.Element) -> CT_RubyContent {
  let elements = wml_ct_chunk4_element_children(element)
  { element, ruby_content: EG_RubyContent::new(elements) }
}

///|
/// XSD complex type CT_RubyContent — Part 1 §17.3.3.24 / §17.3.3.27.
pub fn CT_RubyContent::parse(element : @xml.Element) -> CT_RubyContent {
  CT_RubyContent::new(element)
}

///|
/// XSD complex type CT_RubyContent — return the preserved element for writers.
pub fn CT_RubyContent::to_element(self : CT_RubyContent) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Ruby — Part 1 §17.3.3.25 ruby (Phonetic Guide).
/// Wraps an `xsd:sequence` of three required children: `<rubyPr>`
/// (CT_RubyPr §17.3.3.28), `<rt>` (CT_RubyContent §17.3.3.24) and
/// `<rubyBase>` (CT_RubyContent §17.3.3.27). No attributes.
pub(all) struct CT_Ruby {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.3.28 `<rubyPr>` (CT_RubyPr) — required ruby presentation
  /// properties (alignment, sizes, language, dirty flag).
  ruby_pr : CT_RubyPr
  /// §17.3.3.24 `<rt>` (CT_RubyContent) — required phonetic-guide text.
  rt : CT_RubyContent
  /// §17.3.3.27 `<rubyBase>` (CT_RubyContent) — required base text.
  ruby_base : CT_RubyContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_Ruby — Part 1 §17.3.3.25. Decode the three required
/// children, raising SchemaViolation when any is missing or when the
/// `<rubyPr>` decoder rejects its own contents.
pub fn CT_Ruby::new(element : @xml.Element) -> CT_Ruby raise SchemaViolation {
  let ruby_pr_e = match wml_ct_chunk4_first_child(element, "rubyPr") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_Ruby", "rubyPr", "Part 1 §17.3.3.25: required child <rubyPr> is missing",
      )
  }
  let ruby_pr = CT_RubyPr::new(ruby_pr_e)
  let rt_e = match wml_ct_chunk4_first_child(element, "rt") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_Ruby", "rt", "Part 1 §17.3.3.25: required child <rt> is missing",
      )
  }
  let rt = CT_RubyContent::new(rt_e)
  let ruby_base_e = match wml_ct_chunk4_first_child(element, "rubyBase") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_Ruby", "rubyBase", "Part 1 §17.3.3.25: required child <rubyBase> is missing",
      )
  }
  let ruby_base = CT_RubyContent::new(ruby_base_e)
  { element, ruby_pr, rt, ruby_base }
}

///|
/// XSD complex type CT_Ruby — Part 1 §17.3.3.25.
pub fn CT_Ruby::parse(element : @xml.Element) -> CT_Ruby raise SchemaViolation {
  CT_Ruby::new(element)
}

///|
/// XSD complex type CT_Ruby — return the preserved element for writers.
pub fn CT_Ruby::to_element(self : CT_Ruby) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Lock — Part 1 §17.5.2.23 lock (Locking Setting).
/// Carries one optional `@val` (ST_Lock §17.18.49) selecting the SDT
/// locking semantics: `sdtLocked` / `contentLocked` / `unlocked` /
/// `sdtContentLocked`. No children.
pub(all) struct CT_Lock {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.49 @val (ST_Lock) — optional locking-behavior enumeration.
  val : ST_Lock?
} derive(Eq, Debug)

///|
/// XSD complex type CT_Lock — Part 1 §17.5.2.23. Decode the optional
/// ST_Lock `@val` attribute.
pub fn CT_Lock::new(element : @xml.Element) -> CT_Lock raise SchemaViolation {
  let val = match wml_ct_chunk4_attr(element, "val") {
    Some(text) => Some(ST_Lock::parse(text))
    None => None
  }
  { element, val }
}

///|
/// XSD complex type CT_Lock — Part 1 §17.5.2.23.
pub fn CT_Lock::parse(element : @xml.Element) -> CT_Lock raise SchemaViolation {
  CT_Lock::new(element)
}

///|
/// XSD complex type CT_Lock — return the preserved element for writers.
pub fn CT_Lock::to_element(self : CT_Lock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtListItem — Part 1 §17.5.2.21 listItem (Combo Box
/// List Item) and §17.5.2.22 listItem (Drop-Down List Item). Two optional
/// attributes (both s:ST_String): `@displayText` carries the user-visible
/// label and `@value` carries the underlying value persisted when the
/// item is selected. No children.
pub(all) struct CT_SdtListItem {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.21/.22 @displayText (s:ST_String) — optional display label.
  display_text : String?
  /// §17.5.2.21/.22 @value (s:ST_String) — optional persisted value.
  value : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtListItem — Part 1 §17.5.2.21 / §17.5.2.22. Decode
/// the optional `@displayText` and `@value` attributes verbatim.
pub fn CT_SdtListItem::new(element : @xml.Element) -> CT_SdtListItem {
  let display_text = wml_ct_chunk4_attr(element, "displayText")
  let value = wml_ct_chunk4_attr(element, "value")
  { element, display_text, value }
}

///|
/// XSD complex type CT_SdtListItem — Part 1 §17.5.2.21 / §17.5.2.22.
pub fn CT_SdtListItem::parse(element : @xml.Element) -> CT_SdtListItem {
  CT_SdtListItem::new(element)
}

///|
/// XSD complex type CT_SdtListItem — return the preserved element for writers.
pub fn CT_SdtListItem::to_element(self : CT_SdtListItem) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDateMappingType — Part 1 §17.5.2.40
/// storeMappedDataAs (Custom XML Data Date Storage Format). Carries one
/// optional `@val` (ST_SdtDateMappingType §17.18.76) selecting how the
/// SDT date value is persisted into mapped custom XML data: `text` for the
/// formatted string, `date` for an xsd:date and `dateTime` for an
/// xsd:dateTime. No children.
pub(all) struct CT_SdtDateMappingType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.76 @val (ST_SdtDateMappingType) — optional storage-format
  /// enumeration.
  val : ST_SdtDateMappingType?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtDateMappingType — Part 1 §17.5.2.40. Decode the
/// optional ST_SdtDateMappingType `@val` attribute.
pub fn CT_SdtDateMappingType::new(
  element : @xml.Element,
) -> CT_SdtDateMappingType raise SchemaViolation {
  let val = match wml_ct_chunk4_attr(element, "val") {
    Some(text) => Some(ST_SdtDateMappingType::parse(text))
    None => None
  }
  { element, val }
}

///|
/// XSD complex type CT_SdtDateMappingType — Part 1 §17.5.2.40.
pub fn CT_SdtDateMappingType::parse(
  element : @xml.Element,
) -> CT_SdtDateMappingType raise SchemaViolation {
  CT_SdtDateMappingType::new(element)
}

///|
/// XSD complex type CT_SdtDateMappingType — return the preserved element for
/// writers.
pub fn CT_SdtDateMappingType::to_element(
  self : CT_SdtDateMappingType,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CalendarType — Part 1 §17.5.2.3 calendar (Date
/// Picker Calendar Type). Carries one optional `@val`
/// (s:ST_CalendarType §22.9.2.4) selecting the calendar system used by
/// the date-picker SDT (gregorian, gregorianUs, hijri, etc.). No
/// children. Because `s:ST_CalendarType` lives in the shared simple-types
/// package (`@ecma376/simple_types`) which the WML domain package does
/// not import, the lexical value is preserved verbatim; the canonical
/// enumeration check resides in the shared package and is enforced when
/// callers materialise the value through it.
pub(all) struct CT_CalendarType {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.4 @val (s:ST_CalendarType) — optional calendar-system token,
  /// preserved as the schema lexical form for cross-package validation.
  val : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_CalendarType — Part 1 §17.5.2.3. Decode the optional
/// `@val` attribute as its lexical form.
pub fn CT_CalendarType::new(element : @xml.Element) -> CT_CalendarType {
  let val = wml_ct_chunk4_attr(element, "val")
  { element, val }
}

///|
/// XSD complex type CT_CalendarType — Part 1 §17.5.2.3.
pub fn CT_CalendarType::parse(element : @xml.Element) -> CT_CalendarType {
  CT_CalendarType::new(element)
}

///|
/// XSD complex type CT_CalendarType — return the preserved element for writers.
pub fn CT_CalendarType::to_element(self : CT_CalendarType) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDate — Part 1 §17.5.2.7 date (Date Structured
/// Document Tag). Wraps an `xsd:sequence` of four optional children:
/// `<dateFormat>` (CT_String §17.5.2.8), `<lid>` (CT_Lang §17.5.2.20),
/// `<storeMappedDataAs>` (CT_SdtDateMappingType §17.5.2.40) and
/// `<calendar>` (CT_CalendarType §17.5.2.3). Carries one optional
/// `@fullDate` (ST_DateTime §17.18.20) holding the user-picked timestamp.
pub(all) struct CT_SdtDate {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.8 `<dateFormat>` (CT_String) — optional display mask.
  date_format : CT_String?
  /// §17.5.2.20 `<lid>` (CT_Lang) — optional date-picker language id.
  lid : CT_Lang?
  /// §17.5.2.40 `<storeMappedDataAs>` (CT_SdtDateMappingType) — optional
  /// storage-format selector for mapped custom XML data.
  store_mapped_data_as : CT_SdtDateMappingType?
  /// §17.5.2.3 `<calendar>` (CT_CalendarType) — optional calendar system.
  calendar : CT_CalendarType?
  /// §17.18.20 @fullDate (ST_DateTime) — optional user-picked timestamp.
  full_date : ST_DateTime?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtDate — Part 1 §17.5.2.7. Decode the optional
/// `@fullDate` attribute and the four optional typed children.
pub fn CT_SdtDate::new(
  element : @xml.Element,
) -> CT_SdtDate raise SchemaViolation {
  let date_format = match wml_ct_chunk4_first_child(element, "dateFormat") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let lid = match wml_ct_chunk4_first_child(element, "lid") {
    Some(e) => Some(CT_Lang::new(e))
    None => None
  }
  let store_mapped_data_as = match
    wml_ct_chunk4_first_child(element, "storeMappedDataAs") {
    Some(e) => Some(CT_SdtDateMappingType::new(e))
    None => None
  }
  let calendar = match wml_ct_chunk4_first_child(element, "calendar") {
    Some(e) => Some(CT_CalendarType::new(e))
    None => None
  }
  let full_date = match wml_ct_chunk4_attr(element, "fullDate") {
    Some(text) => Some(ST_DateTime::parse(text))
    None => None
  }
  { element, date_format, lid, store_mapped_data_as, calendar, full_date }
}

///|
/// XSD complex type CT_SdtDate — Part 1 §17.5.2.7.
pub fn CT_SdtDate::parse(
  element : @xml.Element,
) -> CT_SdtDate raise SchemaViolation {
  CT_SdtDate::new(element)
}

///|
/// XSD complex type CT_SdtDate — return the preserved element for writers.
pub fn CT_SdtDate::to_element(self : CT_SdtDate) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtComboBox — Part 1 §17.5.2.5 comboBox (Combo Box
/// Structured Document Tag). Wraps an `xsd:sequence` of `<listItem>`
/// (CT_SdtListItem §17.5.2.21) with `minOccurs="0" maxOccurs="unbounded"`
/// followed by an optional `@lastValue` (s:ST_String, default `""`)
/// recording the most recent persisted selection.
pub(all) struct CT_SdtComboBox {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.21 `<listItem>`* (CT_SdtListItem) — zero or more combo-box
  /// items (display text + persisted value).
  list_item : Array[CT_SdtListItem]
  /// §17.5.2.5 @lastValue (s:ST_String, default `""`) — optional most
  /// recently persisted selection. `None` means the attribute was omitted
  /// and the schema default of empty-string applies.
  last_value : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtComboBox — Part 1 §17.5.2.5. Decode each
/// `<listItem>` (CT_SdtListItem) child and the optional `@lastValue`
/// attribute.
pub fn CT_SdtComboBox::new(element : @xml.Element) -> CT_SdtComboBox {
  let list_item_elements = wml_ct_chunk4_children(element, "listItem")
  let list_item : Array[CT_SdtListItem] = []
  for e in list_item_elements {
    list_item.push(CT_SdtListItem::new(e))
  }
  let last_value = wml_ct_chunk4_attr(element, "lastValue")
  { element, list_item, last_value }
}

///|
/// XSD complex type CT_SdtComboBox — Part 1 §17.5.2.5.
pub fn CT_SdtComboBox::parse(element : @xml.Element) -> CT_SdtComboBox {
  CT_SdtComboBox::new(element)
}

///|
/// XSD complex type CT_SdtComboBox — return the preserved element for writers.
pub fn CT_SdtComboBox::to_element(self : CT_SdtComboBox) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDocPart — Part 1 §17.5.2.12 docPartList (Document
/// Part Gallery Structured Document Tag) and §17.5.2.13 docPartObj
/// (Built-In Document Part Structured Document Tag). Wraps an
/// `xsd:sequence` of three optional children: `<docPartGallery>`
/// (CT_String §17.5.2.11), `<docPartCategory>` (CT_String §17.5.2.10)
/// and `<docPartUnique>` (CT_OnOff §17.5.2.14). No attributes.
pub(all) struct CT_SdtDocPart {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.11 `<docPartGallery>` (CT_String) — optional gallery filter
  /// for the document-part picker.
  doc_part_gallery : CT_String?
  /// §17.5.2.10 `<docPartCategory>` (CT_String) — optional category filter.
  doc_part_category : CT_String?
  /// §17.5.2.14 `<docPartUnique>` (CT_OnOff) — optional flag marking the
  /// SDT as referring to a built-in document part.
  doc_part_unique : CT_OnOff?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtDocPart — Part 1 §17.5.2.12 / §17.5.2.13. Decode
/// the three optional typed children.
pub fn CT_SdtDocPart::new(
  element : @xml.Element,
) -> CT_SdtDocPart raise SchemaViolation {
  let doc_part_gallery = match
    wml_ct_chunk4_first_child(element, "docPartGallery") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let doc_part_category = match
    wml_ct_chunk4_first_child(element, "docPartCategory") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let doc_part_unique = match
    wml_ct_chunk4_first_child(element, "docPartUnique") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  { element, doc_part_gallery, doc_part_category, doc_part_unique }
}

///|
/// XSD complex type CT_SdtDocPart — Part 1 §17.5.2.12 / §17.5.2.13.
pub fn CT_SdtDocPart::parse(
  element : @xml.Element,
) -> CT_SdtDocPart raise SchemaViolation {
  CT_SdtDocPart::new(element)
}

///|
/// XSD complex type CT_SdtDocPart — return the preserved element for writers.
pub fn CT_SdtDocPart::to_element(self : CT_SdtDocPart) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtDropDownList — Part 1 §17.5.2.15 dropDownList
/// (Drop-Down List Structured Document Tag). Wraps an `xsd:sequence` of
/// `<listItem>` (CT_SdtListItem §17.5.2.22) with `minOccurs="0"
/// maxOccurs="unbounded"` followed by an optional `@lastValue`
/// (s:ST_String, default `""`) recording the most recent persisted choice.
pub(all) struct CT_SdtDropDownList {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.22 `<listItem>`* (CT_SdtListItem) — zero or more drop-down
  /// items (display text + persisted value).
  list_item : Array[CT_SdtListItem]
  /// §17.5.2.15 @lastValue (s:ST_String, default `""`) — optional most
  /// recently persisted selection. `None` signals the schema default.
  last_value : String?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtDropDownList — Part 1 §17.5.2.15. Decode each
/// `<listItem>` (CT_SdtListItem) child and the optional `@lastValue`.
pub fn CT_SdtDropDownList::new(element : @xml.Element) -> CT_SdtDropDownList {
  let list_item_elements = wml_ct_chunk4_children(element, "listItem")
  let list_item : Array[CT_SdtListItem] = []
  for e in list_item_elements {
    list_item.push(CT_SdtListItem::new(e))
  }
  let last_value = wml_ct_chunk4_attr(element, "lastValue")
  { element, list_item, last_value }
}

///|
/// XSD complex type CT_SdtDropDownList — Part 1 §17.5.2.15.
pub fn CT_SdtDropDownList::parse(element : @xml.Element) -> CT_SdtDropDownList {
  CT_SdtDropDownList::new(element)
}

///|
/// XSD complex type CT_SdtDropDownList — return the preserved element for
/// writers.
pub fn CT_SdtDropDownList::to_element(
  self : CT_SdtDropDownList,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Placeholder — Part 1 §17.5.2.25 placeholder
/// (Structured Document Tag Placeholder Text). Wraps an `xsd:sequence`
/// with a single required `<docPart>` (CT_String §17.5.2.9) carrying the
/// glossary-document entry name that supplies the placeholder text. No
/// attributes.
pub(all) struct CT_Placeholder {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.9 `<docPart>` (CT_String) — required glossary-document entry
  /// name. The `@val` carried by the CT_String supplies the entry id.
  doc_part : CT_String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Placeholder — Part 1 §17.5.2.25. Decode the required
/// `<docPart>` (CT_String) child, raising SchemaViolation if missing.
pub fn CT_Placeholder::new(
  element : @xml.Element,
) -> CT_Placeholder raise SchemaViolation {
  let doc_part_e = match wml_ct_chunk4_first_child(element, "docPart") {
    Some(e) => e
    None =>
      raise_schema_violation(
        "CT_Placeholder", "docPart", "Part 1 §17.5.2.25: required child <docPart> is missing",
      )
  }
  let doc_part = CT_String::new(doc_part_e)
  { element, doc_part }
}

///|
/// XSD complex type CT_Placeholder — Part 1 §17.5.2.25.
pub fn CT_Placeholder::parse(
  element : @xml.Element,
) -> CT_Placeholder raise SchemaViolation {
  CT_Placeholder::new(element)
}

///|
/// XSD complex type CT_Placeholder — return the preserved element for writers.
pub fn CT_Placeholder::to_element(self : CT_Placeholder) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtText — Part 1 §17.5.2.44 text (Plain Text
/// Structured Document Tag). Carries one optional `@multiLine`
/// (s:ST_OnOff §22.9.2.7) toggling whether the plain-text SDT can hold
/// multiple paragraphs. No children.
pub(all) struct CT_SdtText {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §22.9.2.7 @multiLine (s:ST_OnOff) — optional flag. `None` means the
  /// attribute was omitted, in which case the SDT is single-line per
  /// §17.5.2.44 prose.
  multi_line : Bool?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtText — Part 1 §17.5.2.44. Decode the optional
/// ST_OnOff `@multiLine` attribute.
pub fn CT_SdtText::new(element : @xml.Element) -> CT_SdtText {
  let multi_line = wml_ct_chunk4_on_off(
    wml_ct_chunk4_attr(element, "multiLine"),
  )
  { element, multi_line }
}

///|
/// XSD complex type CT_SdtText — Part 1 §17.5.2.44.
pub fn CT_SdtText::parse(element : @xml.Element) -> CT_SdtText {
  CT_SdtText::new(element)
}

///|
/// XSD complex type CT_SdtText — return the preserved element for writers.
pub fn CT_SdtText::to_element(self : CT_SdtText) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DataBinding — Part 1 §17.5.2.6 dataBinding (XML
/// Mapping). Carries three attributes (all s:ST_String):
/// `@prefixMappings` (optional XPath namespace prefix bindings),
/// `@xpath` (required XPath expression locating the bound node) and
/// `@storeItemID` (required identifier for the custom XML data store).
/// No children.
pub(all) struct CT_DataBinding {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.6 @prefixMappings (s:ST_String) — optional XPath namespace
  /// prefix bindings (e.g. `xmlns:ns0='http://example/'`).
  prefix_mappings : String?
  /// §17.5.2.6 @xpath (s:ST_String) — required XPath expression locating
  /// the bound node within the mapped custom XML data store.
  xpath : String
  /// §17.5.2.6 @storeItemID (s:ST_String) — required identifier for the
  /// custom XML data store hosting the bound element.
  store_item_id : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_DataBinding — Part 1 §17.5.2.6. Decode the optional
/// `@prefixMappings` and the required `@xpath` / `@storeItemID`.
pub fn CT_DataBinding::new(
  element : @xml.Element,
) -> CT_DataBinding raise SchemaViolation {
  let prefix_mappings = wml_ct_chunk4_attr(element, "prefixMappings")
  let xpath = wml_ct_chunk4_required_attr(
    element, "xpath", "CT_DataBinding", "Part 1 §17.5.2.6 s:ST_String",
  )
  let store_item_id = wml_ct_chunk4_required_attr(
    element, "storeItemID", "CT_DataBinding", "Part 1 §17.5.2.6 s:ST_String",
  )
  { element, prefix_mappings, xpath, store_item_id }
}

///|
/// XSD complex type CT_DataBinding — Part 1 §17.5.2.6.
pub fn CT_DataBinding::parse(
  element : @xml.Element,
) -> CT_DataBinding raise SchemaViolation {
  CT_DataBinding::new(element)
}

///|
/// XSD complex type CT_DataBinding — return the preserved element for writers.
pub fn CT_DataBinding::to_element(self : CT_DataBinding) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtPr — Part 1 §17.5.2.38 sdtPr (Structured Document
/// Tag Properties). The `xsd:choice minOccurs="0" maxOccurs="1"` at the
/// tail of the sequence selects which SDT subtype carries auxiliary
/// state. Each branch maps to a §17.5.2 element: `equation`/`picture`/
/// `richText`/`citation`/`group`/`bibliography` (CT_Empty flags),
/// `comboBox` (CT_SdtComboBox §17.5.2.5), `date` (CT_SdtDate §17.5.2.7),
/// `docPartObj`/`docPartList` (CT_SdtDocPart §17.5.2.12/13),
/// `dropDownList` (CT_SdtDropDownList §17.5.2.15) and `text`
/// (CT_SdtText §17.5.2.44).
pub(all) enum CT_SdtPrChoice {
  /// §17.5.2.16 `<equation>` (CT_Empty) — equation SDT marker.
  CT_SdtPrChoice_Equation(CT_Empty)
  /// §17.5.2.5 `<comboBox>` (CT_SdtComboBox) — combo-box SDT properties.
  CT_SdtPrChoice_ComboBox(CT_SdtComboBox)
  /// §17.5.2.7 `<date>` (CT_SdtDate) — date-picker SDT properties.
  CT_SdtPrChoice_Date(CT_SdtDate)
  /// §17.5.2.13 `<docPartObj>` (CT_SdtDocPart) — built-in document part
  /// SDT properties.
  CT_SdtPrChoice_DocPartObj(CT_SdtDocPart)
  /// §17.5.2.12 `<docPartList>` (CT_SdtDocPart) — gallery document part
  /// SDT properties.
  CT_SdtPrChoice_DocPartList(CT_SdtDocPart)
  /// §17.5.2.15 `<dropDownList>` (CT_SdtDropDownList) — drop-down SDT
  /// properties.
  CT_SdtPrChoice_DropDownList(CT_SdtDropDownList)
  /// §17.5.2.24 `<picture>` (CT_Empty) — picture SDT marker.
  CT_SdtPrChoice_Picture(CT_Empty)
  /// §17.5.2.26 `<richText>` (CT_Empty) — rich-text SDT marker.
  CT_SdtPrChoice_RichText(CT_Empty)
  /// §17.5.2.44 `<text>` (CT_SdtText) — plain-text SDT properties.
  CT_SdtPrChoice_Text(CT_SdtText)
  /// §17.5.2.4 `<citation>` (CT_Empty) — citation SDT marker.
  CT_SdtPrChoice_Citation(CT_Empty)
  /// §17.5.2.17 `<group>` (CT_Empty) — group SDT marker.
  CT_SdtPrChoice_Group(CT_Empty)
  /// §17.5.2.2 `<bibliography>` (CT_Empty) — bibliography SDT marker.
  CT_SdtPrChoice_Bibliography(CT_Empty)
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtPr — Part 1 §17.5.2.38 sdtPr. The `xsd:sequence`
/// hosts eleven leading optional children (rPr, alias, tag, id, lock,
/// placeholder, temporary, showingPlcHdr, dataBinding, label, tabIndex)
/// followed by the optional tail `xsd:choice` describing the SDT subtype.
/// All children are optional per the schema; the typed projection
/// captures each separately to keep ordering explicit.
pub(all) struct CT_SdtPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.27 `<rPr>` (CT_RPr) — optional run properties applied to the
  /// SDT contents while it is displayed.
  r_pr : CT_RPr?
  /// §17.5.2.1 `<alias>` (CT_String) — optional friendly name shown in
  /// the SDT UI.
  alias_ : CT_String?
  /// §17.5.2.42 `<tag>` (CT_String) — optional programmatic tag.
  tag : CT_String?
  /// §17.5.2.18 `<id>` (CT_DecimalNumber) — optional unique identifier.
  id : CT_DecimalNumber?
  /// §17.5.2.23 `<lock>` (CT_Lock) — optional locking setting.
  lock : CT_Lock?
  /// §17.5.2.25 `<placeholder>` (CT_Placeholder) — optional placeholder
  /// glossary entry reference.
  placeholder : CT_Placeholder?
  /// §17.5.2.43 `<temporary>` (CT_OnOff) — optional "remove when edited"
  /// flag.
  temporary : CT_OnOff?
  /// §17.5.2.39 `<showingPlcHdr>` (CT_OnOff) — optional flag indicating
  /// the SDT is currently displaying placeholder text.
  showing_plc_hdr : CT_OnOff?
  /// §17.5.2.6 `<dataBinding>` (CT_DataBinding) — optional XML data
  /// binding.
  data_binding : CT_DataBinding?
  /// §17.5.2.19 `<label>` (CT_DecimalNumber) — optional UI label id.
  label : CT_DecimalNumber?
  /// §17.5.2.41 `<tabIndex>` (CT_UnsignedDecimalNumber) — optional
  /// navigation order index.
  tab_index : CT_UnsignedDecimalNumber?
  /// `xsd:choice minOccurs="0" maxOccurs="1"` — optional SDT subtype
  /// branch (see CT_SdtPrChoice).
  choice : CT_SdtPrChoice?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtPr — Part 1 §17.5.2.38. Decode each of the eleven
/// leading typed optionals and the tail `xsd:choice` SDT-subtype branch.
pub fn CT_SdtPr::new(element : @xml.Element) -> CT_SdtPr raise SchemaViolation {
  let r_pr = match wml_ct_chunk4_first_child(element, "rPr") {
    Some(e) => Some(CT_RPr::new(e))
    None => None
  }
  let alias_ = match wml_ct_chunk4_first_child(element, "alias") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let tag = match wml_ct_chunk4_first_child(element, "tag") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let id = match wml_ct_chunk4_first_child(element, "id") {
    Some(e) => Some(CT_DecimalNumber::new(e))
    None => None
  }
  let lock = match wml_ct_chunk4_first_child(element, "lock") {
    Some(e) => Some(CT_Lock::new(e))
    None => None
  }
  let placeholder = match wml_ct_chunk4_first_child(element, "placeholder") {
    Some(e) => Some(CT_Placeholder::new(e))
    None => None
  }
  let temporary = match wml_ct_chunk4_first_child(element, "temporary") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  let showing_plc_hdr = match
    wml_ct_chunk4_first_child(element, "showingPlcHdr") {
    Some(e) => Some(CT_OnOff::new(e))
    None => None
  }
  let data_binding = match wml_ct_chunk4_first_child(element, "dataBinding") {
    Some(e) => Some(CT_DataBinding::new(e))
    None => None
  }
  let label = match wml_ct_chunk4_first_child(element, "label") {
    Some(e) => Some(CT_DecimalNumber::new(e))
    None => None
  }
  let tab_index = match wml_ct_chunk4_first_child(element, "tabIndex") {
    Some(e) => Some(CT_UnsignedDecimalNumber::new(e))
    None => None
  }
  let choice = match
    wml_ct_chunk4_first_choice(element, [
      "equation", "comboBox", "date", "docPartObj", "docPartList", "dropDownList",
      "picture", "richText", "text", "citation", "group", "bibliography",
    ]) {
    Some((e, "equation")) => Some(CT_SdtPrChoice_Equation(CT_Empty::new(e)))
    Some((e, "comboBox")) =>
      Some(CT_SdtPrChoice_ComboBox(CT_SdtComboBox::new(e)))
    Some((e, "date")) => Some(CT_SdtPrChoice_Date(CT_SdtDate::new(e)))
    Some((e, "docPartObj")) =>
      Some(CT_SdtPrChoice_DocPartObj(CT_SdtDocPart::new(e)))
    Some((e, "docPartList")) =>
      Some(CT_SdtPrChoice_DocPartList(CT_SdtDocPart::new(e)))
    Some((e, "dropDownList")) =>
      Some(CT_SdtPrChoice_DropDownList(CT_SdtDropDownList::new(e)))
    Some((e, "picture")) => Some(CT_SdtPrChoice_Picture(CT_Empty::new(e)))
    Some((e, "richText")) => Some(CT_SdtPrChoice_RichText(CT_Empty::new(e)))
    Some((e, "text")) => Some(CT_SdtPrChoice_Text(CT_SdtText::new(e)))
    Some((e, "citation")) => Some(CT_SdtPrChoice_Citation(CT_Empty::new(e)))
    Some((e, "group")) => Some(CT_SdtPrChoice_Group(CT_Empty::new(e)))
    Some((e, "bibliography")) =>
      Some(CT_SdtPrChoice_Bibliography(CT_Empty::new(e)))
    Some(_) => None
    None => None
  }
  {
    element,
    r_pr,
    alias_,
    tag,
    id,
    lock,
    placeholder,
    temporary,
    showing_plc_hdr,
    data_binding,
    label,
    tab_index,
    choice,
  }
}

///|
/// XSD complex type CT_SdtPr — Part 1 §17.5.2.38.
pub fn CT_SdtPr::parse(
  element : @xml.Element,
) -> CT_SdtPr raise SchemaViolation {
  CT_SdtPr::new(element)
}

///|
/// XSD complex type CT_SdtPr — return the preserved element for writers.
pub fn CT_SdtPr::to_element(self : CT_SdtPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtEndPr — Part 1 §17.5.2.37 sdtEndPr (Structured
/// Document Tag End Character Properties). Wraps an `xsd:choice
/// maxOccurs="unbounded"` whose only declared branch is `<rPr>`
/// (CT_RPr §17.5.2.28). The schema therefore admits zero or more `<rPr>`
/// children carrying run properties for the SDT end-character region.
/// No attributes.
pub(all) struct CT_SdtEndPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.28 `<rPr>`* (CT_RPr) — zero or more end-character run
  /// property carriers in document order.
  r_pr : Array[CT_RPr]
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtEndPr — Part 1 §17.5.2.37. Decode each `<rPr>`
/// child via CT_RPr::new, which raises SchemaViolation for malformed
/// run-property children.
pub fn CT_SdtEndPr::new(
  element : @xml.Element,
) -> CT_SdtEndPr raise SchemaViolation {
  let r_pr_elements = wml_ct_chunk4_children(element, "rPr")
  let r_pr : Array[CT_RPr] = []
  for e in r_pr_elements {
    r_pr.push(CT_RPr::new(e))
  }
  { element, r_pr }
}

///|
/// XSD complex type CT_SdtEndPr — Part 1 §17.5.2.37.
pub fn CT_SdtEndPr::parse(
  element : @xml.Element,
) -> CT_SdtEndPr raise SchemaViolation {
  CT_SdtEndPr::new(element)
}

///|
/// XSD complex type CT_SdtEndPr — return the preserved element for writers.
pub fn CT_SdtEndPr::to_element(self : CT_SdtEndPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_DirContentRun — Part 1 §17.3.2.8 dir (Bidirectional
/// Embedding Level). Carries an optional `@val` (ST_Direction §17.18.12)
/// selecting `ltr` / `rtl` for the embedded run, plus the group
/// EG_PContent with `minOccurs="0" maxOccurs="unbounded"` carrying the
/// nested paragraph content. The EG_PContent members are preserved as
/// the typed model-group wrapper so paragraph-content readers can
/// dispatch on the projected member set.
pub(all) struct CT_DirContentRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.12 @val (ST_Direction) — optional embedded direction.
  val : ST_Direction?
  /// §17.3.2.8 EG_PContent* — zero or more nested paragraph-content
  /// children preserved in document order via the model-group wrapper.
  p_content : EG_PContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_DirContentRun — Part 1 §17.3.2.8. Decode the optional
/// `@val` (ST_Direction) and the EG_PContent* children.
pub fn CT_DirContentRun::new(
  element : @xml.Element,
) -> CT_DirContentRun raise SchemaViolation {
  let val = match wml_ct_chunk4_attr(element, "val") {
    Some(text) => Some(ST_Direction::parse(text))
    None => None
  }
  let p_content = EG_PContent::new(wml_ct_chunk4_element_children(element))
  { element, val, p_content }
}

///|
/// XSD complex type CT_DirContentRun — Part 1 §17.3.2.8.
pub fn CT_DirContentRun::parse(
  element : @xml.Element,
) -> CT_DirContentRun raise SchemaViolation {
  CT_DirContentRun::new(element)
}

///|
/// XSD complex type CT_DirContentRun — return the preserved element for
/// writers.
pub fn CT_DirContentRun::to_element(self : CT_DirContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_BdoContentRun — Part 1 §17.3.2.3 bdo (Bidirectional
/// Override). Carries an optional `@val` (ST_Direction §17.18.12)
/// selecting `ltr` / `rtl` for the BDO override, plus the group
/// EG_PContent with `minOccurs="0" maxOccurs="unbounded"` carrying the
/// overridden paragraph content.
pub(all) struct CT_BdoContentRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.18.12 @val (ST_Direction) — optional override direction.
  val : ST_Direction?
  /// §17.3.2.3 EG_PContent* — zero or more overridden paragraph-content
  /// children preserved in document order via the model-group wrapper.
  p_content : EG_PContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_BdoContentRun — Part 1 §17.3.2.3. Decode the optional
/// `@val` (ST_Direction) and the EG_PContent* children.
pub fn CT_BdoContentRun::new(
  element : @xml.Element,
) -> CT_BdoContentRun raise SchemaViolation {
  let val = match wml_ct_chunk4_attr(element, "val") {
    Some(text) => Some(ST_Direction::parse(text))
    None => None
  }
  let p_content = EG_PContent::new(wml_ct_chunk4_element_children(element))
  { element, val, p_content }
}

///|
/// XSD complex type CT_BdoContentRun — Part 1 §17.3.2.3.
pub fn CT_BdoContentRun::parse(
  element : @xml.Element,
) -> CT_BdoContentRun raise SchemaViolation {
  CT_BdoContentRun::new(element)
}

///|
/// XSD complex type CT_BdoContentRun — return the preserved element for
/// writers.
pub fn CT_BdoContentRun::to_element(self : CT_BdoContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentRun — Part 1 §17.5.2.36 sdtContent
/// (Inline-Level Structured Document Tag Content). Wraps the group
/// EG_PContent with `minOccurs="0" maxOccurs="unbounded"` carrying the
/// SDT inline contents. No attributes.
pub(all) struct CT_SdtContentRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.36 EG_PContent* — zero or more inline-content children
  /// preserved in document order via the model-group wrapper.
  p_content : EG_PContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtContentRun — Part 1 §17.5.2.36. Decode each
/// EG_PContent member as a raw element child of the SDT content wrapper.
pub fn CT_SdtContentRun::new(element : @xml.Element) -> CT_SdtContentRun {
  let p_content = EG_PContent::new(wml_ct_chunk4_element_children(element))
  { element, p_content }
}

///|
/// XSD complex type CT_SdtContentRun — Part 1 §17.5.2.36.
pub fn CT_SdtContentRun::parse(element : @xml.Element) -> CT_SdtContentRun {
  CT_SdtContentRun::new(element)
}

///|
/// XSD complex type CT_SdtContentRun — return the preserved element for
/// writers.
pub fn CT_SdtContentRun::to_element(self : CT_SdtContentRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentBlock — Part 1 §17.5.2.34 sdtContent
/// (Block-Level Structured Document Tag Content). Wraps the group
/// EG_ContentBlockContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying nested custom-XML blocks, SDT blocks, paragraphs, tables
/// and EG_RunLevelElts marks. No attributes.
pub(all) struct CT_SdtContentBlock {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.34 EG_ContentBlockContent* — zero or more block-content
  /// children preserved in document order via the model-group wrapper.
  content_block_content : EG_ContentBlockContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtContentBlock — Part 1 §17.5.2.34. Decode each
/// EG_ContentBlockContent member as a raw element child of the SDT
/// content wrapper.
pub fn CT_SdtContentBlock::new(element : @xml.Element) -> CT_SdtContentBlock {
  let content_block_content = EG_ContentBlockContent::new(
    wml_ct_chunk4_element_children(element),
  )
  { element, content_block_content }
}

///|
/// XSD complex type CT_SdtContentBlock — Part 1 §17.5.2.34.
pub fn CT_SdtContentBlock::parse(element : @xml.Element) -> CT_SdtContentBlock {
  CT_SdtContentBlock::new(element)
}

///|
/// XSD complex type CT_SdtContentBlock — return the preserved element for
/// writers.
pub fn CT_SdtContentBlock::to_element(
  self : CT_SdtContentBlock,
) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentRow — Part 1 §17.5.2.35 sdtContent (Row-
/// Level Structured Document Tag Content). Wraps the group
/// EG_ContentRowContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying nested rows, custom-XML rows, SDT rows and EG_RunLevelElts
/// marks. No attributes.
pub(all) struct CT_SdtContentRow {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.35 EG_ContentRowContent* — zero or more row-content children
  /// preserved in document order via the model-group wrapper.
  content_row_content : EG_ContentRowContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtContentRow — Part 1 §17.5.2.35. Decode each
/// EG_ContentRowContent member as a raw element child of the SDT
/// content wrapper.
pub fn CT_SdtContentRow::new(element : @xml.Element) -> CT_SdtContentRow {
  let content_row_content = EG_ContentRowContent::new(
    wml_ct_chunk4_element_children(element),
  )
  { element, content_row_content }
}

///|
/// XSD complex type CT_SdtContentRow — Part 1 §17.5.2.35.
pub fn CT_SdtContentRow::parse(element : @xml.Element) -> CT_SdtContentRow {
  CT_SdtContentRow::new(element)
}

///|
/// XSD complex type CT_SdtContentRow — return the preserved element for
/// writers.
pub fn CT_SdtContentRow::to_element(self : CT_SdtContentRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtContentCell — Part 1 §17.5.2.33 sdtContent
/// (Cell-Level Structured Document Tag Content). Wraps the group
/// EG_ContentCellContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying nested table cells, custom-XML cells, SDT cells and
/// EG_RunLevelElts marks. No attributes.
pub(all) struct CT_SdtContentCell {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.33 EG_ContentCellContent* — zero or more cell-content
  /// children preserved in document order via the model-group wrapper.
  content_cell_content : EG_ContentCellContent
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtContentCell — Part 1 §17.5.2.33. Decode each
/// EG_ContentCellContent member as a raw element child of the SDT
/// content wrapper.
pub fn CT_SdtContentCell::new(element : @xml.Element) -> CT_SdtContentCell {
  let content_cell_content = EG_ContentCellContent::new(
    wml_ct_chunk4_element_children(element),
  )
  { element, content_cell_content }
}

///|
/// XSD complex type CT_SdtContentCell — Part 1 §17.5.2.33.
pub fn CT_SdtContentCell::parse(element : @xml.Element) -> CT_SdtContentCell {
  CT_SdtContentCell::new(element)
}

///|
/// XSD complex type CT_SdtContentCell — return the preserved element for
/// writers.
pub fn CT_SdtContentCell::to_element(self : CT_SdtContentCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtBlock — Part 1 §17.5.2.29 sdt (Block-Level
/// Structured Document Tag). Wraps an `xsd:sequence` of three optional
/// children: `<sdtPr>` (CT_SdtPr §17.5.2.38), `<sdtEndPr>` (CT_SdtEndPr
/// §17.5.2.37) and `<sdtContent>` (CT_SdtContentBlock §17.5.2.34). No
/// attributes.
pub(all) struct CT_SdtBlock {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.38 `<sdtPr>` (CT_SdtPr) — optional SDT properties.
  sdt_pr : CT_SdtPr?
  /// §17.5.2.37 `<sdtEndPr>` (CT_SdtEndPr) — optional end-character
  /// run properties.
  sdt_end_pr : CT_SdtEndPr?
  /// §17.5.2.34 `<sdtContent>` (CT_SdtContentBlock) — optional content
  /// payload using block-level model.
  sdt_content : CT_SdtContentBlock?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtBlock — Part 1 §17.5.2.29. Decode the three
/// optional typed children; CT_SdtPr / CT_SdtEndPr raise SchemaViolation
/// for malformed nested content.
pub fn CT_SdtBlock::new(
  element : @xml.Element,
) -> CT_SdtBlock raise SchemaViolation {
  let sdt_pr = match wml_ct_chunk4_first_child(element, "sdtPr") {
    Some(e) => Some(CT_SdtPr::new(e))
    None => None
  }
  let sdt_end_pr = match wml_ct_chunk4_first_child(element, "sdtEndPr") {
    Some(e) => Some(CT_SdtEndPr::new(e))
    None => None
  }
  let sdt_content = match wml_ct_chunk4_first_child(element, "sdtContent") {
    Some(e) => Some(CT_SdtContentBlock::new(e))
    None => None
  }
  { element, sdt_pr, sdt_end_pr, sdt_content }
}

///|
/// XSD complex type CT_SdtBlock — Part 1 §17.5.2.29.
pub fn CT_SdtBlock::parse(
  element : @xml.Element,
) -> CT_SdtBlock raise SchemaViolation {
  CT_SdtBlock::new(element)
}

///|
/// XSD complex type CT_SdtBlock — return the preserved element for writers.
pub fn CT_SdtBlock::to_element(self : CT_SdtBlock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtRun — Part 1 §17.5.2.31 sdt (Inline-Level
/// Structured Document Tag). Wraps an `xsd:sequence` of three optional
/// children: `<sdtPr>` (CT_SdtPr §17.5.2.38), `<sdtEndPr>` (CT_SdtEndPr
/// §17.5.2.37) and `<sdtContent>` (CT_SdtContentRun §17.5.2.36). No
/// attributes.
pub(all) struct CT_SdtRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.38 `<sdtPr>` (CT_SdtPr) — optional SDT properties.
  sdt_pr : CT_SdtPr?
  /// §17.5.2.37 `<sdtEndPr>` (CT_SdtEndPr) — optional end-character
  /// run properties.
  sdt_end_pr : CT_SdtEndPr?
  /// §17.5.2.36 `<sdtContent>` (CT_SdtContentRun) — optional content
  /// payload using inline-level model.
  sdt_content : CT_SdtContentRun?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtRun — Part 1 §17.5.2.31. Decode the three optional
/// typed children; CT_SdtPr / CT_SdtEndPr raise SchemaViolation for
/// malformed nested content.
pub fn CT_SdtRun::new(
  element : @xml.Element,
) -> CT_SdtRun raise SchemaViolation {
  let sdt_pr = match wml_ct_chunk4_first_child(element, "sdtPr") {
    Some(e) => Some(CT_SdtPr::new(e))
    None => None
  }
  let sdt_end_pr = match wml_ct_chunk4_first_child(element, "sdtEndPr") {
    Some(e) => Some(CT_SdtEndPr::new(e))
    None => None
  }
  let sdt_content = match wml_ct_chunk4_first_child(element, "sdtContent") {
    Some(e) => Some(CT_SdtContentRun::new(e))
    None => None
  }
  { element, sdt_pr, sdt_end_pr, sdt_content }
}

///|
/// XSD complex type CT_SdtRun — Part 1 §17.5.2.31.
pub fn CT_SdtRun::parse(
  element : @xml.Element,
) -> CT_SdtRun raise SchemaViolation {
  CT_SdtRun::new(element)
}

///|
/// XSD complex type CT_SdtRun — return the preserved element for writers.
pub fn CT_SdtRun::to_element(self : CT_SdtRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtCell — Part 1 §17.5.2.32 sdt (Cell-Level
/// Structured Document Tag). Wraps an `xsd:sequence` of three optional
/// children: `<sdtPr>` (CT_SdtPr §17.5.2.38), `<sdtEndPr>` (CT_SdtEndPr
/// §17.5.2.37) and `<sdtContent>` (CT_SdtContentCell §17.5.2.33). No
/// attributes.
pub(all) struct CT_SdtCell {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.38 `<sdtPr>` (CT_SdtPr) — optional SDT properties.
  sdt_pr : CT_SdtPr?
  /// §17.5.2.37 `<sdtEndPr>` (CT_SdtEndPr) — optional end-character
  /// run properties.
  sdt_end_pr : CT_SdtEndPr?
  /// §17.5.2.33 `<sdtContent>` (CT_SdtContentCell) — optional content
  /// payload using cell-level model.
  sdt_content : CT_SdtContentCell?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtCell — Part 1 §17.5.2.32. Decode the three
/// optional typed children; CT_SdtPr / CT_SdtEndPr raise SchemaViolation
/// for malformed nested content.
pub fn CT_SdtCell::new(
  element : @xml.Element,
) -> CT_SdtCell raise SchemaViolation {
  let sdt_pr = match wml_ct_chunk4_first_child(element, "sdtPr") {
    Some(e) => Some(CT_SdtPr::new(e))
    None => None
  }
  let sdt_end_pr = match wml_ct_chunk4_first_child(element, "sdtEndPr") {
    Some(e) => Some(CT_SdtEndPr::new(e))
    None => None
  }
  let sdt_content = match wml_ct_chunk4_first_child(element, "sdtContent") {
    Some(e) => Some(CT_SdtContentCell::new(e))
    None => None
  }
  { element, sdt_pr, sdt_end_pr, sdt_content }
}

///|
/// XSD complex type CT_SdtCell — Part 1 §17.5.2.32.
pub fn CT_SdtCell::parse(
  element : @xml.Element,
) -> CT_SdtCell raise SchemaViolation {
  CT_SdtCell::new(element)
}

///|
/// XSD complex type CT_SdtCell — return the preserved element for writers.
pub fn CT_SdtCell::to_element(self : CT_SdtCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SdtRow — Part 1 §17.5.2.30 sdt (Row-Level Structured
/// Document Tag). Wraps an `xsd:sequence` of three optional children:
/// `<sdtPr>` (CT_SdtPr §17.5.2.38), `<sdtEndPr>` (CT_SdtEndPr §17.5.2.37)
/// and `<sdtContent>` (CT_SdtContentRow §17.5.2.35). No attributes.
pub(all) struct CT_SdtRow {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.2.38 `<sdtPr>` (CT_SdtPr) — optional SDT properties.
  sdt_pr : CT_SdtPr?
  /// §17.5.2.37 `<sdtEndPr>` (CT_SdtEndPr) — optional end-character
  /// run properties.
  sdt_end_pr : CT_SdtEndPr?
  /// §17.5.2.35 `<sdtContent>` (CT_SdtContentRow) — optional content
  /// payload using row-level model.
  sdt_content : CT_SdtContentRow?
} derive(Eq, Debug)

///|
/// XSD complex type CT_SdtRow — Part 1 §17.5.2.30. Decode the three
/// optional typed children; CT_SdtPr / CT_SdtEndPr raise SchemaViolation
/// for malformed nested content.
pub fn CT_SdtRow::new(
  element : @xml.Element,
) -> CT_SdtRow raise SchemaViolation {
  let sdt_pr = match wml_ct_chunk4_first_child(element, "sdtPr") {
    Some(e) => Some(CT_SdtPr::new(e))
    None => None
  }
  let sdt_end_pr = match wml_ct_chunk4_first_child(element, "sdtEndPr") {
    Some(e) => Some(CT_SdtEndPr::new(e))
    None => None
  }
  let sdt_content = match wml_ct_chunk4_first_child(element, "sdtContent") {
    Some(e) => Some(CT_SdtContentRow::new(e))
    None => None
  }
  { element, sdt_pr, sdt_end_pr, sdt_content }
}

///|
/// XSD complex type CT_SdtRow — Part 1 §17.5.2.30.
pub fn CT_SdtRow::parse(
  element : @xml.Element,
) -> CT_SdtRow raise SchemaViolation {
  CT_SdtRow::new(element)
}

///|
/// XSD complex type CT_SdtRow — return the preserved element for writers.
pub fn CT_SdtRow::to_element(self : CT_SdtRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_Attr — Part 1 §17.5.1.1 attr (Custom XML Attribute)
/// and §17.5.1.2 attr (Smart Tag Property). Both reuse this type. Carries
/// three attributes (all s:ST_String): `@uri` (optional namespace URI),
/// `@name` (required custom-XML / smart-tag local name) and `@val`
/// (required attribute value). No children.
pub(all) struct CT_Attr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.1/.2 @uri (s:ST_String) — optional namespace URI of the
  /// custom-XML attribute or smart-tag property.
  uri : String?
  /// §17.5.1.1/.2 @name (s:ST_String) — required local name.
  name : String
  /// §17.5.1.1/.2 @val (s:ST_String) — required attribute value.
  val : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_Attr — Part 1 §17.5.1.1 / §17.5.1.2. Decode the
/// optional `@uri` and the required `@name` / `@val` attributes.
pub fn CT_Attr::new(element : @xml.Element) -> CT_Attr raise SchemaViolation {
  let uri = wml_ct_chunk4_attr(element, "uri")
  let name = wml_ct_chunk4_required_attr(
    element, "name", "CT_Attr", "Part 1 §17.5.1.1 s:ST_String",
  )
  let val = wml_ct_chunk4_required_attr(
    element, "val", "CT_Attr", "Part 1 §17.5.1.1 s:ST_String",
  )
  { element, uri, name, val }
}

///|
/// XSD complex type CT_Attr — Part 1 §17.5.1.1 / §17.5.1.2.
pub fn CT_Attr::parse(element : @xml.Element) -> CT_Attr raise SchemaViolation {
  CT_Attr::new(element)
}

///|
/// XSD complex type CT_Attr — return the preserved element for writers.
pub fn CT_Attr::to_element(self : CT_Attr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlRun — Part 1 §17.5.1.3 customXml (Inline-
/// Level Custom XML Element). Wraps an `xsd:sequence` of optional
/// `<customXmlPr>` (CT_CustomXmlPr §17.5.1.7) followed by EG_PContent
/// with `minOccurs="0" maxOccurs="unbounded"` carrying the wrapped run
/// content. Two attributes (both s:ST_String): `@uri` (optional custom
/// XML namespace) and `@element` (required custom XML local name,
/// s:ST_XmlName lexical form).
pub(all) struct CT_CustomXmlRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.7 `<customXmlPr>` (CT_CustomXmlPr) — optional custom XML
  /// element properties (placeholder text + attribute list).
  custom_xml_pr : CT_CustomXmlPr?
  /// §17.5.1.3 EG_PContent* — zero or more wrapped paragraph-content
  /// children preserved in document order via the model-group wrapper.
  p_content : EG_PContent
  /// §17.5.1.3 @uri (s:ST_String) — optional custom XML namespace URI.
  uri : String?
  /// §17.5.1.3 @element (s:ST_XmlName lexical form) — required custom XML
  /// local name. Preserved as raw string; XML name well-formedness is
  /// enforced by the source XML parser.
  element_name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomXmlRun — Part 1 §17.5.1.3. Decode the optional
/// `<customXmlPr>` and required `@element` attribute (raises when
/// missing), preserving the rest of the children as EG_PContent.
pub fn CT_CustomXmlRun::new(
  element : @xml.Element,
) -> CT_CustomXmlRun raise SchemaViolation {
  let custom_xml_pr = match wml_ct_chunk4_first_child(element, "customXmlPr") {
    Some(e) => Some(CT_CustomXmlPr::new(e))
    None => None
  }
  let p_content_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "customXmlPr" {
          p_content_elements.push(e)
        }
      _ => ()
    }
  }
  let p_content = EG_PContent::new(p_content_elements)
  let uri = wml_ct_chunk4_attr(element, "uri")
  let element_name = wml_ct_chunk4_required_attr(
    element, "element", "CT_CustomXmlRun", "Part 1 §17.5.1.3 s:ST_XmlName",
  )
  { element, custom_xml_pr, p_content, uri, element_name }
}

///|
/// XSD complex type CT_CustomXmlRun — Part 1 §17.5.1.3.
pub fn CT_CustomXmlRun::parse(
  element : @xml.Element,
) -> CT_CustomXmlRun raise SchemaViolation {
  CT_CustomXmlRun::new(element)
}

///|
/// XSD complex type CT_CustomXmlRun — return the preserved element for
/// writers.
pub fn CT_CustomXmlRun::to_element(self : CT_CustomXmlRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagRun — Part 1 §17.5.1.9 smartTag (Inline-Level
/// Smart Tag). Wraps an `xsd:sequence` of optional `<smartTagPr>`
/// (CT_SmartTagPr §17.5.1.10) followed by EG_PContent with
/// `minOccurs="0" maxOccurs="unbounded"` carrying the recognised run
/// content. Two attributes (both s:ST_String): `@uri` (optional smart-
/// tag namespace) and `@element` (required smart-tag local name,
/// s:ST_XmlName lexical form).
pub(all) struct CT_SmartTagRun {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.10 `<smartTagPr>` (CT_SmartTagPr) — optional smart-tag
  /// properties (attribute list).
  smart_tag_pr : CT_SmartTagPr?
  /// §17.5.1.9 EG_PContent* — zero or more recognised paragraph-content
  /// children preserved in document order via the model-group wrapper.
  p_content : EG_PContent
  /// §17.5.1.9 @uri (s:ST_String) — optional smart-tag namespace URI.
  uri : String?
  /// §17.5.1.9 @element (s:ST_XmlName lexical form) — required smart-tag
  /// local name. Preserved as raw string; XML name well-formedness is
  /// enforced by the source XML parser.
  element_name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_SmartTagRun — Part 1 §17.5.1.9. Decode the optional
/// `<smartTagPr>` and required `@element` attribute (raises when
/// missing), preserving the rest of the children as EG_PContent.
pub fn CT_SmartTagRun::new(
  element : @xml.Element,
) -> CT_SmartTagRun raise SchemaViolation {
  let smart_tag_pr = match wml_ct_chunk4_first_child(element, "smartTagPr") {
    Some(e) => Some(CT_SmartTagPr::new(e))
    None => None
  }
  let p_content_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "smartTagPr" {
          p_content_elements.push(e)
        }
      _ => ()
    }
  }
  let p_content = EG_PContent::new(p_content_elements)
  let uri = wml_ct_chunk4_attr(element, "uri")
  let element_name = wml_ct_chunk4_required_attr(
    element, "element", "CT_SmartTagRun", "Part 1 §17.5.1.9 s:ST_XmlName",
  )
  { element, smart_tag_pr, p_content, uri, element_name }
}

///|
/// XSD complex type CT_SmartTagRun — Part 1 §17.5.1.9.
pub fn CT_SmartTagRun::parse(
  element : @xml.Element,
) -> CT_SmartTagRun raise SchemaViolation {
  CT_SmartTagRun::new(element)
}

///|
/// XSD complex type CT_SmartTagRun — return the preserved element for
/// writers.
pub fn CT_SmartTagRun::to_element(self : CT_SmartTagRun) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlBlock — Part 1 §17.5.1.6 customXml (Block-
/// Level Custom XML Element). Wraps an `xsd:sequence` of optional
/// `<customXmlPr>` (CT_CustomXmlPr §17.5.1.7) followed by
/// EG_ContentBlockContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying the wrapped block-level content. Two attributes (both
/// s:ST_String): `@uri` (optional custom XML namespace) and `@element`
/// (required custom XML local name, s:ST_XmlName lexical form).
pub(all) struct CT_CustomXmlBlock {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.7 `<customXmlPr>` (CT_CustomXmlPr) — optional custom XML
  /// element properties (placeholder + attribute list).
  custom_xml_pr : CT_CustomXmlPr?
  /// §17.5.1.6 EG_ContentBlockContent* — zero or more wrapped block-level
  /// children preserved in document order via the model-group wrapper.
  content_block_content : EG_ContentBlockContent
  /// §17.5.1.6 @uri (s:ST_String) — optional custom XML namespace URI.
  uri : String?
  /// §17.5.1.6 @element (s:ST_XmlName lexical form) — required custom XML
  /// local name.
  element_name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomXmlBlock — Part 1 §17.5.1.6. Decode the
/// optional `<customXmlPr>`, the required `@element` attribute and
/// every block-level child as EG_ContentBlockContent.
pub fn CT_CustomXmlBlock::new(
  element : @xml.Element,
) -> CT_CustomXmlBlock raise SchemaViolation {
  let custom_xml_pr = match wml_ct_chunk4_first_child(element, "customXmlPr") {
    Some(e) => Some(CT_CustomXmlPr::new(e))
    None => None
  }
  let content_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "customXmlPr" {
          content_elements.push(e)
        }
      _ => ()
    }
  }
  let content_block_content = EG_ContentBlockContent::new(content_elements)
  let uri = wml_ct_chunk4_attr(element, "uri")
  let element_name = wml_ct_chunk4_required_attr(
    element, "element", "CT_CustomXmlBlock", "Part 1 §17.5.1.6 s:ST_XmlName",
  )
  { element, custom_xml_pr, content_block_content, uri, element_name }
}

///|
/// XSD complex type CT_CustomXmlBlock — Part 1 §17.5.1.6.
pub fn CT_CustomXmlBlock::parse(
  element : @xml.Element,
) -> CT_CustomXmlBlock raise SchemaViolation {
  CT_CustomXmlBlock::new(element)
}

///|
/// XSD complex type CT_CustomXmlBlock — return the preserved element for
/// writers.
pub fn CT_CustomXmlBlock::to_element(self : CT_CustomXmlBlock) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlPr — Part 1 §17.5.1.7 customXmlPr (Custom
/// XML Element Properties). Wraps an `xsd:sequence` of an optional
/// `<placeholder>` (CT_String §17.5.1.8 carrying the placeholder text in
/// `@val`) followed by zero or more `<attr>` (CT_Attr §17.5.1.1) custom-
/// XML attribute children. No attributes on the wrapper itself.
pub(all) struct CT_CustomXmlPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.8 `<placeholder>` (CT_String) — optional placeholder text
  /// surfaced when the custom-XML element is empty.
  placeholder : CT_String?
  /// §17.5.1.1 `<attr>`* (CT_Attr) — zero or more custom-XML attribute
  /// declarations. Each carries the required `@name` / `@val` plus an
  /// optional `@uri` validated by CT_Attr::new.
  attr : Array[CT_Attr]
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomXmlPr — Part 1 §17.5.1.7. Decode the optional
/// `<placeholder>` and each `<attr>` (CT_Attr) child; CT_Attr::new
/// raises SchemaViolation when a required `@name` / `@val` is missing.
pub fn CT_CustomXmlPr::new(
  element : @xml.Element,
) -> CT_CustomXmlPr raise SchemaViolation {
  let placeholder = match wml_ct_chunk4_first_child(element, "placeholder") {
    Some(e) => Some(CT_String::new(e))
    None => None
  }
  let attr_elements = wml_ct_chunk4_children(element, "attr")
  let attr : Array[CT_Attr] = []
  for e in attr_elements {
    attr.push(CT_Attr::new(e))
  }
  { element, placeholder, attr }
}

///|
/// XSD complex type CT_CustomXmlPr — Part 1 §17.5.1.7.
pub fn CT_CustomXmlPr::parse(
  element : @xml.Element,
) -> CT_CustomXmlPr raise SchemaViolation {
  CT_CustomXmlPr::new(element)
}

///|
/// XSD complex type CT_CustomXmlPr — return the preserved element for
/// writers.
pub fn CT_CustomXmlPr::to_element(self : CT_CustomXmlPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlRow — Part 1 §17.5.1.5 customXml (Row-
/// Level Custom XML Element). Wraps an `xsd:sequence` of optional
/// `<customXmlPr>` (CT_CustomXmlPr §17.5.1.7) followed by
/// EG_ContentRowContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying the wrapped row-level content. Two attributes (both
/// s:ST_String): `@uri` (optional custom XML namespace) and `@element`
/// (required custom XML local name, s:ST_XmlName lexical form).
pub(all) struct CT_CustomXmlRow {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.7 `<customXmlPr>` (CT_CustomXmlPr) — optional custom XML
  /// element properties.
  custom_xml_pr : CT_CustomXmlPr?
  /// §17.5.1.5 EG_ContentRowContent* — zero or more wrapped row-level
  /// children preserved in document order via the model-group wrapper.
  content_row_content : EG_ContentRowContent
  /// §17.5.1.5 @uri (s:ST_String) — optional custom XML namespace URI.
  uri : String?
  /// §17.5.1.5 @element (s:ST_XmlName lexical form) — required custom XML
  /// local name.
  element_name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomXmlRow — Part 1 §17.5.1.5. Decode the optional
/// `<customXmlPr>`, the required `@element` attribute and every row-level
/// child as EG_ContentRowContent.
pub fn CT_CustomXmlRow::new(
  element : @xml.Element,
) -> CT_CustomXmlRow raise SchemaViolation {
  let custom_xml_pr = match wml_ct_chunk4_first_child(element, "customXmlPr") {
    Some(e) => Some(CT_CustomXmlPr::new(e))
    None => None
  }
  let content_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "customXmlPr" {
          content_elements.push(e)
        }
      _ => ()
    }
  }
  let content_row_content = EG_ContentRowContent::new(content_elements)
  let uri = wml_ct_chunk4_attr(element, "uri")
  let element_name = wml_ct_chunk4_required_attr(
    element, "element", "CT_CustomXmlRow", "Part 1 §17.5.1.5 s:ST_XmlName",
  )
  { element, custom_xml_pr, content_row_content, uri, element_name }
}

///|
/// XSD complex type CT_CustomXmlRow — Part 1 §17.5.1.5.
pub fn CT_CustomXmlRow::parse(
  element : @xml.Element,
) -> CT_CustomXmlRow raise SchemaViolation {
  CT_CustomXmlRow::new(element)
}

///|
/// XSD complex type CT_CustomXmlRow — return the preserved element for
/// writers.
pub fn CT_CustomXmlRow::to_element(self : CT_CustomXmlRow) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_CustomXmlCell — Part 1 §17.5.1.4 customXml (Cell-
/// Level Custom XML Element). Wraps an `xsd:sequence` of optional
/// `<customXmlPr>` (CT_CustomXmlPr §17.5.1.7) followed by
/// EG_ContentCellContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying the wrapped cell-level content. Two attributes (both
/// s:ST_String): `@uri` (optional custom XML namespace) and `@element`
/// (required custom XML local name, s:ST_XmlName lexical form).
pub(all) struct CT_CustomXmlCell {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.7 `<customXmlPr>` (CT_CustomXmlPr) — optional custom XML
  /// element properties.
  custom_xml_pr : CT_CustomXmlPr?
  /// §17.5.1.4 EG_ContentCellContent* — zero or more wrapped cell-level
  /// children preserved in document order via the model-group wrapper.
  content_cell_content : EG_ContentCellContent
  /// §17.5.1.4 @uri (s:ST_String) — optional custom XML namespace URI.
  uri : String?
  /// §17.5.1.4 @element (s:ST_XmlName lexical form) — required custom XML
  /// local name.
  element_name : String
} derive(Eq, Debug)

///|
/// XSD complex type CT_CustomXmlCell — Part 1 §17.5.1.4. Decode the optional
/// `<customXmlPr>`, the required `@element` attribute and every cell-level
/// child as EG_ContentCellContent.
pub fn CT_CustomXmlCell::new(
  element : @xml.Element,
) -> CT_CustomXmlCell raise SchemaViolation {
  let custom_xml_pr = match wml_ct_chunk4_first_child(element, "customXmlPr") {
    Some(e) => Some(CT_CustomXmlPr::new(e))
    None => None
  }
  let content_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "customXmlPr" {
          content_elements.push(e)
        }
      _ => ()
    }
  }
  let content_cell_content = EG_ContentCellContent::new(content_elements)
  let uri = wml_ct_chunk4_attr(element, "uri")
  let element_name = wml_ct_chunk4_required_attr(
    element, "element", "CT_CustomXmlCell", "Part 1 §17.5.1.4 s:ST_XmlName",
  )
  { element, custom_xml_pr, content_cell_content, uri, element_name }
}

///|
/// XSD complex type CT_CustomXmlCell — Part 1 §17.5.1.4.
pub fn CT_CustomXmlCell::parse(
  element : @xml.Element,
) -> CT_CustomXmlCell raise SchemaViolation {
  CT_CustomXmlCell::new(element)
}

///|
/// XSD complex type CT_CustomXmlCell — return the preserved element for
/// writers.
pub fn CT_CustomXmlCell::to_element(self : CT_CustomXmlCell) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_SmartTagPr — Part 1 §17.5.1.10 smartTagPr (Smart Tag
/// Properties). Wraps an `xsd:sequence` of zero or more `<attr>` (CT_Attr
/// §17.5.1.2) smart-tag property children. No attributes on the wrapper.
pub(all) struct CT_SmartTagPr {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.5.1.2 `<attr>`* (CT_Attr) — zero or more smart-tag properties.
  /// Each carries the required `@name` / `@val` plus an optional `@uri`
  /// validated by CT_Attr::new.
  attr : Array[CT_Attr]
} derive(Eq, Debug)

///|
/// XSD complex type CT_SmartTagPr — Part 1 §17.5.1.10. Decode each `<attr>`
/// (CT_Attr) child; CT_Attr::new raises SchemaViolation when a required
/// `@name` / `@val` is missing.
pub fn CT_SmartTagPr::new(
  element : @xml.Element,
) -> CT_SmartTagPr raise SchemaViolation {
  let attr_elements = wml_ct_chunk4_children(element, "attr")
  let attr : Array[CT_Attr] = []
  for e in attr_elements {
    attr.push(CT_Attr::new(e))
  }
  { element, attr }
}

///|
/// XSD complex type CT_SmartTagPr — Part 1 §17.5.1.10.
pub fn CT_SmartTagPr::parse(
  element : @xml.Element,
) -> CT_SmartTagPr raise SchemaViolation {
  CT_SmartTagPr::new(element)
}

///|
/// XSD complex type CT_SmartTagPr — return the preserved element for writers.
pub fn CT_SmartTagPr::to_element(self : CT_SmartTagPr) -> @xml.Element {
  self.element
}

///|
/// XSD complex type CT_P — Part 1 §17.3.1.22 p (Paragraph). Wraps an
/// `xsd:sequence` of an optional `<pPr>` (CT_PPr §17.3.1.26) followed by
/// the model group EG_PContent with `minOccurs="0" maxOccurs="unbounded"`
/// carrying the paragraph's run / field / hyperlink / sub-doc content.
/// Five optional revision-id attributes (all ST_LongHexNumber §17.18.50)
/// stamp the source revision identifiers for the run-property snapshot,
/// the run itself, the deletion mark, the paragraph properties and the
/// default run, respectively. The EG_PContent members are preserved as
/// the typed model-group wrapper so paragraph-content readers can
/// dispatch on the projected member set.
pub(all) struct CT_P {
  /// §A.1 — source element kept for builder round-trip.
  element : @xml.Element
  /// §17.3.1.26 `<pPr>` (CT_PPr) — optional paragraph properties carrier.
  p_pr : CT_PPr?
  /// §17.3.1.22 EG_PContent* — zero or more paragraph-content children
  /// preserved in document order via the model-group wrapper.
  p_content : EG_PContent
  /// §17.18.50 @rsidRPr (ST_LongHexNumber) — optional run-property
  /// revision id, preserved verbatim as eight hex digits.
  rsid_r_pr : ST_LongHexNumber?
  /// §17.18.50 @rsidR (ST_LongHexNumber) — optional run revision id.
  rsid_r : ST_LongHexNumber?
  /// §17.18.50 @rsidDel (ST_LongHexNumber) — optional deletion revision id.
  rsid_del : ST_LongHexNumber?
  /// §17.18.50 @rsidP (ST_LongHexNumber) — optional paragraph-property
  /// revision id.
  rsid_p : ST_LongHexNumber?
  /// §17.18.50 @rsidRDefault (ST_LongHexNumber) — optional default-run
  /// revision id.
  rsid_r_default : ST_LongHexNumber?
} derive(Eq, Debug)

///|
/// XSD complex type CT_P — Part 1 §17.3.1.22. Decode the optional `<pPr>`,
/// every other element child as EG_PContent and the five optional
/// ST_LongHexNumber revision-id attributes.
pub fn CT_P::new(element : @xml.Element) -> CT_P raise SchemaViolation {
  let p_pr = match wml_ct_chunk4_first_child(element, "pPr") {
    Some(e) => Some(CT_PPr::new(e))
    None => None
  }
  let p_content_elements : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) =>
        if e.name.local_name != "pPr" {
          p_content_elements.push(e)
        }
      _ => ()
    }
  }
  let p_content = EG_PContent::new(p_content_elements)
  let rsid_r_pr = match wml_ct_chunk4_attr(element, "rsidRPr") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_r = match wml_ct_chunk4_attr(element, "rsidR") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_del = match wml_ct_chunk4_attr(element, "rsidDel") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_p = match wml_ct_chunk4_attr(element, "rsidP") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  let rsid_r_default = match wml_ct_chunk4_attr(element, "rsidRDefault") {
    Some(text) => Some(ST_LongHexNumber::parse(text))
    None => None
  }
  {
    element,
    p_pr,
    p_content,
    rsid_r_pr,
    rsid_r,
    rsid_del,
    rsid_p,
    rsid_r_default,
  }
}

///|
/// XSD complex type CT_P — Part 1 §17.3.1.22.
pub fn CT_P::parse(element : @xml.Element) -> CT_P raise SchemaViolation {
  CT_P::new(element)
}

///|
/// XSD complex type CT_P — return the preserved element for writers.
pub fn CT_P::to_element(self : CT_P) -> @xml.Element {
  self.element
}

// =============================================================================
// WordprocessingML chunk3 typed-promotion helpers — wml.xsd §17 form-field /
// section / run / ruby complex types listed in
// `.indexion/plans/ct-typing/lists/wml/chunk3.txt`. Helper names are prefixed
// `wml_ct_chunk3_` to stay disjoint from the chunk1 helpers above so each
// chunk owns its lookup utilities. WordprocessingML attributes use the `w`
// namespace prefix at the wire level but the schema's local-name lookup is
// what the wml.xsd grammar binds, so all helpers match by local name only.
// =============================================================================

///|
/// First-attribute lookup by local name (chunk3).
fn wml_ct_chunk3_attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
/// First-attribute lookup that additionally matches an exact namespace URI on
/// the attribute QName. Used for `r:id`, `r:bottomLeft`, etc. where the
/// `r:` prefix is the only meaningful disambiguator from a no-namespace
/// local-name collision.
fn wml_ct_chunk3_attr_ns(
  element : @xml.Element,
  ns : String,
  local_name : String,
) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name && a.name.ns is Some(uri) && uri == ns {
      return Some(a.value)
    }
  }
  None
}

///|
/// Required attribute lookup. Raises SchemaViolation with `CT_X/@foo`
/// canonical anchor when the attribute is missing.
fn wml_ct_chunk3_required_attr(
  element : @xml.Element,
  local_name : String,
  type_name : String,
  context : String,
) -> String raise SchemaViolation {
  match wml_ct_chunk3_attr(element, local_name) {
    Some(v) => v
    None =>
      raise_schema_violation(
        type_name,
        local_name,
        context + ": required attribute @" + local_name + " is missing",
      )
  }
}

///|
/// Decode an optional ST_OnOff lexical token (§22.9.2.7) — chunk3 mirror of
/// the chunk1 helper. Returns `None` when the attribute is absent.
fn wml_ct_chunk3_on_off(value : String?) -> Bool? {
  match value {
    Some("1") | Some("true") | Some("on") => Some(true)
    Some("0") | Some("false") | Some("off") => Some(false)
    Some(_) => Some(false)
    None => None
  }
}

///|
/// First element child whose local name equals `local_name`. Used to read
/// optional / required single-child elements per `xsd:sequence` ordering.
fn wml_ct_chunk3_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
/// All direct element children whose local name equals `local_name`,
/// preserving document order. Used to read `maxOccurs="unbounded"` payloads.
fn wml_ct_chunk3_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { out.push(e) }
      _ => ()
    }
  }
  out
}

///|
/// First element child whose local name is one of `local_names`. Returns the
/// matched element and the canonical local-name. Used for `xsd:choice`
/// branches such as `<size>/<sizeAuto>`.
fn wml_ct_chunk3_first_choice(
  element : @xml.Element,
  local_names : Array[String],
) -> (@xml.Element, String)? {
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        for candidate in local_names {
          if ln == candidate {
            return Some((e, candidate))
          }
        }
      }
      _ => ()
    }
  }
  None
}

///|
/// Concatenate Text / CData node children into a single string. Used for
/// CT_Text and other `xsd:simpleContent` extensions of `s:ST_String`.
fn wml_ct_chunk3_text_value(element : @xml.Element) -> String {
  let buf = StringBuilder::new()
  for child in element.children {
    match child {
      @xml.Text(t) => buf.write_string(t)
      @xml.CData(t) => buf.write_string(t)
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// Resolved `r` (relationships) namespace URI per ECMA-376 Part 1 §A.6.7.
/// Matches the namespace used for `r:id`, `r:bottomLeft`, `r:topLeft`, etc.
fn wml_ct_chunk3_ns_r() -> String {
  "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
}

// =============================================================================
// WordprocessingML chunk4 typed-promotion helpers — wml.xsd §17 SDT, custom
// XML, smart-tag, ruby, paragraph, body, comments and glossary-document
// complex types listed in
// `.indexion/plans/ct-typing/lists/wml/chunk4.txt`. Helper names are prefixed
// `wml_ct_chunk4_` to stay disjoint from chunks 1/2/3 above so each chunk
// owns its lookup utilities. WordprocessingML attributes use the `w`
// namespace prefix at the wire level but the schema's local-name lookup is
// what the wml.xsd grammar binds, so all helpers match by local name only.
// =============================================================================

///|
/// First-attribute lookup by local name (chunk4).
fn wml_ct_chunk4_attr(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
/// Required attribute lookup. Raises SchemaViolation with `CT_X/@foo`
/// canonical anchor when the attribute is missing.
fn wml_ct_chunk4_required_attr(
  element : @xml.Element,
  local_name : String,
  type_name : String,
  context : String,
) -> String raise SchemaViolation {
  match wml_ct_chunk4_attr(element, local_name) {
    Some(v) => v
    None =>
      raise_schema_violation(
        type_name,
        local_name,
        context + ": required attribute @" + local_name + " is missing",
      )
  }
}

///|
/// Decode an optional ST_OnOff lexical token (§22.9.2.7) — chunk4 mirror of
/// the chunk1/3 helpers. Returns `None` when the attribute is absent.
fn wml_ct_chunk4_on_off(value : String?) -> Bool? {
  match value {
    Some("1") | Some("true") | Some("on") => Some(true)
    Some("0") | Some("false") | Some("off") => Some(false)
    Some(_) => Some(false)
    None => None
  }
}

///|
/// First element child whose local name equals `local_name`. Used to read
/// optional / required single-child elements per `xsd:sequence` ordering.
fn wml_ct_chunk4_first_child(
  element : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
/// All direct element children whose local name equals `local_name`,
/// preserving document order. Used to read `maxOccurs="unbounded"` payloads.
fn wml_ct_chunk4_children(
  element : @xml.Element,
  local_name : String,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { out.push(e) }
      _ => ()
    }
  }
  out
}

///|
/// First element child whose local name is one of `local_names`. Returns the
/// matched element and the canonical local-name. Used for `xsd:choice`
/// branches such as the CT_SdtPr equation/comboBox/date/... selector.
fn wml_ct_chunk4_first_choice(
  element : @xml.Element,
  local_names : Array[String],
) -> (@xml.Element, String)? {
  for child in element.children {
    match child {
      @xml.Element(e) => {
        let ln = e.name.local_name
        for candidate in local_names {
          if ln == candidate {
            return Some((e, candidate))
          }
        }
      }
      _ => ()
    }
  }
  None
}

///|
/// All direct element children of `element`, in document order. Used for
/// CT types whose schema content is an `xsd:choice` over a model group
/// (e.g. EG_PContent, EG_RubyContent, EG_ContentBlockContent) where the
/// typed projection is owned by readers downstream of this CT.
fn wml_ct_chunk4_element_children(
  element : @xml.Element,
) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in element.children {
    match child {
      @xml.Element(e) => out.push(e)
      _ => ()
    }
  }
  out
}
