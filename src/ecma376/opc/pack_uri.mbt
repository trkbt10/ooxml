///|
/// §6.3 Pack URI scheme. Identifies a part inside a package using the
/// `pack://authority/part-name` IRI form per §6.3.2.
pub struct PackUri {
  authority : String
  part : String
} derive(Eq)

///|
/// §6.3.4 Compose a pack URI from authority and part components.
pub fn PackUri::compose(authority : String, part : String) -> PackUri {
  PackUri::{ authority, part }
}

///|
/// §6.3.4 Render a PackUri to its `pack://authority/part` string form.
pub fn PackUri::to_string(self : PackUri) -> String {
  "pack://" + self.authority + self.part
}

///|
/// §6.3.2 Parse a `pack://...` URI string. Raises SchemaViolation when the
/// input does not start with `pack://` or has no path component.
pub fn PackUri::parse(s : String) -> PackUri raise SchemaViolation {
  if !s.has_prefix("pack://") {
    raise SchemaViolation(section="6.3", path="/", reason="not a pack:// URI")
  }
  let rest = s[7:].to_owned()
  let index = find_substring(rest, "/")
  if index < 0 {
    raise SchemaViolation(
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
