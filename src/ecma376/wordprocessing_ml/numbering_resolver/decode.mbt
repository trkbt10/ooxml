// Thin façade over the typed decoders that now live on
// `@domain.CT_*`. Retained so callers (field_eval, future numbering
// renderers) have a single import surface for the resolver pipeline.

///|
/// Part 1 §17.9.1 abstractNum — re-export of the domain decoder so
/// callers can still construct standalone `CT_AbstractNum` views
/// without importing `@domain` directly.
pub fn decode_abstract_num(
  element : @xml.Element,
) -> @domain.CT_AbstractNum raise @domain.SchemaViolation {
  @domain.CT_AbstractNum::parse(element)
}

///|
/// Part 1 §17.9.15 num — re-export of the domain decoder.
pub fn decode_num(
  element : @xml.Element,
) -> @domain.CT_Num raise @domain.SchemaViolation {
  @domain.CT_Num::parse(element)
}

///|
/// Part 1 §17.9.6 lvl — re-export of the domain decoder.
pub fn decode_lvl(
  element : @xml.Element,
) -> @domain.CT_Lvl raise @domain.SchemaViolation {
  @domain.CT_Lvl::parse(element)
}

///|
/// Part 1 §17.9.16 numbering — re-export of the domain decoder.
pub fn decode_numbering(
  element : @xml.Element,
) -> @domain.CT_Numbering raise @domain.SchemaViolation {
  @domain.CT_Numbering::parse(element)
}
