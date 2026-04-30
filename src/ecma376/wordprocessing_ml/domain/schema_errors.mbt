///|
/// Raise an ECMA-376 WordprocessingML schema validation error.
pub fn[T] raise_schema_violation(
  type_name : String,
  value : String,
  reason : String,
) -> T raise SchemaViolation {
  raise SchemaViolation(type_name~, value~, reason~)
}
