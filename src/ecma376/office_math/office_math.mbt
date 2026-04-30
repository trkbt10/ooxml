///|
/// ECMA-376 Part 1 §22.1 Math package owned by src/ecma376/office_math with Schema shared-math.xsd.
///
/// The package owns Schema shared-math.xsd symbols for mathPr, oMathPara,
/// oMath, the 72 CT_* domain types, 14 ST_* simple types, and the OMML reader
/// and builder pipeline.
/// Bundle strict/transitional targets http://purl.oclc.org/ooxml/officeDocument/math
/// with elements mathPr, oMath, and oMathPara; complexTypes=72,
/// simpleTypes=14, attributeGroups=0, and groups=3.
/// Schema shared-math.xsd is the source schema bundle for the §22.1 CT_*,
/// ST_*, EG_*, and top-level OMML element declarations implemented here.
/// EG_ScriptStyle is the shared-math.xsd model group with scr CT_Script and
/// sty CT_Style children.
/// Reader and builder failures use the package error vocabulary XmlMalformed,
/// SchemaViolation, UnsupportedFeature, and ResourceMissing when validation or
/// OPC resource resolution fails.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/office_math"
}

///|
/// Return the §22.1 schema bundle owned by this package.
///
/// Schema shared-math.xsd covers the OMML target namespace, top-level mathPr,
/// oMath, and oMathPara elements, the CT_* complex types, the ST_* simple
/// types, and the EG_* model groups implemented by the office_math packages.
pub fn schema_bundle_name() -> String {
  "shared-math.xsd"
}
