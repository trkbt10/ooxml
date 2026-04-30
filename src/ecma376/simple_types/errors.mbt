///|
/// ECMA-376 §22.9 shared simple-type schema validation error.
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)
