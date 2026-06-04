///|
/// ST_TargetMode simple type enumeration for CT_Relationship TargetMode.
pub(all) enum TargetMode {
  Internal
  External
} derive(Eq, Debug)

///|
/// Parse ST_TargetMode, rejecting values outside the Internal/External
/// enumeration.
pub fn TargetMode::parse(
  value : String,
) -> TargetMode raise @opc_errors.SchemaViolation {
  match value {
    "Internal" => Internal
    "External" => External
    _ =>
      raise @opc_errors.SchemaViolation(
        section="",
        path="Relationship/@TargetMode",
        reason="TargetMode must be Internal or External",
      )
  }
}

///|
/// Return the lexical ST_TargetMode enumeration member.
pub fn TargetMode::to_string(self : TargetMode) -> String {
  match self {
    Internal => "Internal"
    External => "External"
  }
}

///|
/// Schema-named alias for opc-relationships.xsd simple type ST_TargetMode.
pub type ST_TargetMode = TargetMode

///|
/// §6.5 ST_RelationshipId — xsd:string identifier for OPC relationships.
pub struct RelationshipId {
  value : String
} derive(Eq)

///|
pub fn RelationshipId::new(s : String) -> RelationshipId {
  RelationshipId::{ value: s }
}

///|
pub fn RelationshipId::to_string(self : RelationshipId) -> String {
  self.value
}

///|
/// Schema shared-relationshipReference.xsd simple type `ST_RelationshipId`
/// — §6.5 / Annex A.6.4. Base `xsd:string` with no further restriction
/// (free-form relationship identifier). The canonical typed carrier is
/// `RelationshipId`; the spec-named alias here exists so the
/// XSD-coverage matcher can resolve `ST_RelationshipId` to a public
/// declaration in this package.
pub type ST_RelationshipId = RelationshipId

///|
/// OPC Relationships Part `Relationship/@Id` is `xsd:ID` in
/// opc-relationships.xsd, hence an XML `NCName`. This validator is
/// intentionally separate from `ST_RelationshipId`, whose schema
/// base is plain `xsd:string` for relationship-reference markup.
pub fn validate_relationship_element_id(
  id : String,
  path? : String = "Relationship/@Id",
) -> Unit raise @opc_errors.SchemaViolation {
  if id == "" {
    raise @opc_errors.SchemaViolation(
      section="9.3",
      path~,
      reason="Id is required",
    )
  }
  if !@xml.is_ncname(id) {
    raise @opc_errors.SchemaViolation(
      section="9.3",
      path~,
      reason="Relationship/@Id must be an xsd:ID NCName value",
    )
  }
}

///|
/// XSD complex type CT_Relationship — ECMA-376 Part 2 §9.3 Relationships Part
/// / Annex C opc-relationships.xsd. Single relationship entry carrying the
/// required Id, Type, Target attributes and an optional TargetMode.
pub(all) struct CT_Relationship {
  id : String
  type_uri : String
  target : String
  target_mode : TargetMode
} derive(Eq, Debug)

///|
/// Build CT_Relationship with required Id, Type, and Target attributes.
fn CT_Relationship::new(
  id : String,
  type_uri : String,
  target : String,
  target_mode : TargetMode,
) -> CT_Relationship raise @opc_errors.SchemaViolation {
  validate_relationship_element_id(id)
  if type_uri == "" {
    raise @opc_errors.SchemaViolation(
      section="",
      path="Relationship/@Type",
      reason="Type is required",
    )
  }
  if target == "" {
    raise @opc_errors.SchemaViolation(
      section="",
      path="Relationship/@Target",
      reason="Target is required",
    )
  }
  { id, type_uri, target, target_mode }
}

///|
/// XSD complex type CT_Relationships — ECMA-376 Part 2 §9.3 Relationships
/// Part / Annex C opc-relationships.xsd. Root of `.rels` parts holding an
/// ordered sequence of CT_Relationship children with unique Id values.
pub(all) struct CT_Relationships {
  relationships : Array[CT_Relationship]
} derive(Eq, Debug)

///|
/// Build CT_Relationships while preserving order and rejecting duplicate Id
/// values.
fn CT_Relationships::new(
  relationships : Array[CT_Relationship],
) -> CT_Relationships raise @opc_errors.SchemaViolation {
  let ids : Array[String] = []
  for relationship in relationships {
    if ids.contains(relationship.id) {
      raise @opc_errors.SchemaViolation(
        section="",
        path="/Relationships/Relationship/@Id",
        reason="duplicate relationship Id",
      )
    }
    ids.push(relationship.id)
  }
  { relationships, }
}

///|
/// Find a CT_Relationship by Id.
pub fn CT_Relationships::find_by_id(
  self : CT_Relationships,
  id : String,
) -> CT_Relationship? {
  for relationship in self.relationships {
    if relationship.id == id {
      return Some(relationship)
    }
  }
  None
}
