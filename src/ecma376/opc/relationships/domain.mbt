///|
/// ST_TargetMode simple type enumeration for CT_Relationship TargetMode.
pub(all) enum TargetMode {
  Internal
  External
} derive(Eq, Debug)

///|
/// Parse ST_TargetMode, rejecting values outside the Internal/External
/// enumeration.
pub fn TargetMode::parse(value : String) -> TargetMode raise SchemaViolation {
  match value {
    "Internal" => Internal
    "External" => External
    _ =>
      raise SchemaViolation(
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
/// Relationship top-level element and CT_Relationship complex type.
pub(all) struct Relationship {
  id : String
  type_uri : String
  target : String
  target_mode : TargetMode
} derive(Eq, Debug)

///|
/// Build CT_Relationship with required Id, Type, and Target attributes.
fn Relationship::new(
  id : String,
  type_uri : String,
  target : String,
  target_mode : TargetMode,
) -> Relationship raise SchemaViolation {
  if id == "" {
    raise SchemaViolation(
      section="",
      path="Relationship/@Id",
      reason="Id is required",
    )
  }
  if type_uri == "" {
    raise SchemaViolation(
      section="",
      path="Relationship/@Type",
      reason="Type is required",
    )
  }
  if target == "" {
    raise SchemaViolation(
      section="",
      path="Relationship/@Target",
      reason="Target is required",
    )
  }
  { id, type_uri, target, target_mode }
}

///|
/// Relationships top-level element and CT_Relationships complex type.
pub(all) struct Relationships {
  relationships : Array[Relationship]
} derive(Eq, Debug)

///|
/// Build CT_Relationships while preserving order and rejecting duplicate Id
/// values.
fn Relationships::new(
  relationships : Array[Relationship],
) -> Relationships raise SchemaViolation {
  let ids : Array[String] = []
  for relationship in relationships {
    if ids.contains(relationship.id) {
      raise SchemaViolation(
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
pub fn Relationships::find_by_id(
  self : Relationships,
  id : String,
) -> Relationship? {
  for relationship in self.relationships {
    if relationship.id == id {
      return Some(relationship)
    }
  }
  None
}
