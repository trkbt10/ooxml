///|
/// ECMA-376 Part 1 §18: SpreadsheetML facade.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/spreadsheet_ml"
}

///|
/// Citation for SpreadsheetML migration features.
pub(all) struct MigrationFeatureCitation {
  part : Int
  section : String
  subject : String
} derive(Eq, Debug)

///|
/// ECMA-376 Part 4 §15 tracks SpreadsheetML migration features.
pub fn migration_feature_citation() -> MigrationFeatureCitation {
  { part: 4, section: "15", subject: "SpreadsheetML migration features" }
}
