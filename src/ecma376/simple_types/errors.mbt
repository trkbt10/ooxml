///|
/// ECMA-376 Part 1 §22.9 Shared Simple Types schema validation error.
/// ResourceMissing is outside this package because shared-commonSimpleTypes.xsd
/// defines only lexical simple types; OPC relationship resources are resolved
/// by the embedding ML/OPC package before these constructors are called.
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)
