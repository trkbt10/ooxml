///|
/// ECMA-376 Part 1 §22.7 Additional Characteristics.
///
/// Schema shared-additionalCharacteristics.xsd contains the top-level
/// additionalCharacteristics element, CT_AdditionalCharacteristics,
/// CT_Characteristic, and XSD simple type ST_Relation.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/additional_characteristics"
}

///|
/// Schema shared-additionalCharacteristics.xsd validation error.
pub suberror SchemaViolation {
  SchemaViolation(type_name~ : String, value~ : String)
} derive(Debug)

///|
/// XSD simple type ST_Relation. Enumerates the relation between an additional
/// characteristic value and the document property: ge, le, gt, lt, eq.
/// ResourceMissing belongs to the surrounding package resolver contract, not
/// to this closed string enumeration.
pub(all) enum ST_Relation {
  Ge
  Le
  Gt
  Lt
  Eq
} derive(Eq, Debug)

///|
/// Parse the ST_Relation simple-type lexical value.
pub fn ST_Relation::parse(s : String) -> ST_Relation raise SchemaViolation {
  match s {
    "ge" => Ge
    "le" => Le
    "gt" => Gt
    "lt" => Lt
    "eq" => Eq
    _ => raise SchemaViolation(type_name="ST_Relation", value=s)
  }
}

///|
/// Return the schema lexical value for ST_Relation.
pub fn ST_Relation::to_string(self : ST_Relation) -> String {
  match self {
    Ge => "ge"
    Le => "le"
    Gt => "gt"
    Lt => "lt"
    Eq => "eq"
  }
}
