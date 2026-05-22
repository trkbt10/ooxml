///|
/// Part 1 §18.3.1.18 conditionalFormatting — decode the outer
/// CT_ConditionalFormatting element into a typed
/// `@domain.CT_ConditionalFormatting`. This is a thin re-export of
/// the typed-projection constructor `@domain.CT_ConditionalFormatting::new`;
/// the decoder lives next to the domain types so the construction
/// path is package-local to the type definition.
pub fn decode_cf_block(
  element : @xml.Element,
) -> @domain.CT_ConditionalFormatting raise @opc_errors.SchemaViolation {
  @domain.CT_ConditionalFormatting::new(element)
}

///|
/// Part 1 §18.3.1.10 cfRule — decode a CT_CfRule element into the
/// typed `@domain.CT_CfRule`. Thin re-export of
/// `@domain.CT_CfRule::new`.
pub fn decode_cf_rule(
  element : @xml.Element,
) -> @domain.CT_CfRule raise @opc_errors.SchemaViolation {
  @domain.CT_CfRule::new(element)
}
