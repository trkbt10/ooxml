///|
/// ECMA-376 Part 2 §6.3.1 General Pack IRI handling. Identifies a part inside
/// a package using the `pack://authority/part-name` IRI form per §6.3.2.
/// Source: `references/spec/part2/sections/6.3.1__general.md`. Owned by
/// `src/ecma376/opc`.
pub struct PackUri {
  authority : String
  part : String
} derive(Eq)

///|
/// ECMA-376 Part 2 §6.3.4 Composing A Pack Iri from authority and part
/// components. Source anchor:
/// references/spec/part2/sections/6.3.4__composing-a-pack-iri.md.
pub fn PackUri::compose(authority : String, part : String) -> PackUri {
  PackUri::{ authority, part }
}

///|
/// ECMA-376 Part 2 §6.3.5 Equivalence support for rendering a PackUri to its
/// canonical `pack://authority/part` string form. Source anchor:
/// references/spec/part2/sections/6.3.5__equivalence.md.
pub fn PackUri::to_string(self : PackUri) -> String {
  "pack://" + self.authority + self.part
}

///|
/// §6.3.2 Parse a `pack://...` URI string and support ECMA-376 Part 2 §6.3.3
/// Resolving A Pack Iri To A Resource by exposing the part component used by
/// Package::part. Raises @opc_errors.SchemaViolation when the input does not start with
/// `pack://` or has no path component. Source anchor:
/// references/spec/part2/sections/6.3.3__resolving-a-pack-iri-to-a-resource.md.
pub fn PackUri::parse(s : String) -> PackUri raise @opc_errors.SchemaViolation {
  if !s.has_prefix("pack://") {
    raise @opc_errors.SchemaViolation(
      section="6.3",
      path="/",
      reason="not a pack:// URI",
    )
  }
  let rest = s[7:].to_owned()
  let index = find_substring(rest, "/")
  if index < 0 {
    raise @opc_errors.SchemaViolation(
      section="6.3.4",
      path="/",
      reason="missing part component",
    )
  }
  PackUri::{
    authority: rest[0:index].to_owned(),
    part: rest[index:].to_owned(),
  }
}
