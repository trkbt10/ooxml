///|
/// ECMA-376 Part 2 §6.3.1 General Pack IRI handling. Identifies a part inside
/// a package using the `pack://authority/part-name` IRI form per §6.3.2.
/// Source: `references/spec/part2/sections/6.3.1__general.md`. Owned by
/// `src/ecma376/opc`.
pub struct PackUri {
  authority : String
  part : String
  /// §6.3 — optional IRI fragment (`#bookmark`).  Pack IRIs and
  /// Relationship `Target` IRIs (used by hyperlinks / internal
  /// anchors) may carry a fragment.  `None` when absent.  The
  /// fragment is NOT part of the part-name used for resource
  /// resolution — it is preserved verbatim for callers that
  /// rebuild the original IRI (e.g. hyperlink href emission).
  fragment : String?
} derive(Eq)

///|
/// ECMA-376 Part 2 §6.3.4 Composing A Pack Iri from authority and part
/// components. Source anchor:
/// references/spec/part2/sections/6.3.4__composing-a-pack-iri.md.
pub fn PackUri::compose(authority : String, part : String) -> PackUri {
  PackUri::{ authority, part, fragment: None }
}

///|
/// §6.3.4 — compose a Pack IRI that carries an IRI fragment.
pub fn PackUri::compose_with_fragment(
  authority : String,
  part : String,
  fragment : String,
) -> PackUri {
  PackUri::{ authority, part, fragment: Some(fragment) }
}

///|
/// ECMA-376 Part 2 §6.3.5 Equivalence support for rendering a PackUri to its
/// canonical `pack://authority/part` string form. Source anchor:
/// references/spec/part2/sections/6.3.5__equivalence.md.
pub fn PackUri::to_string(self : PackUri) -> String {
  let base = "pack://" + self.authority + self.part
  match self.fragment {
    Some(frag) => base + "#" + frag
    None => base
  }
}

///|
/// §6.3.3 — the part component used for resource resolution (the
/// fragment is excluded so `Package::part` looks up the right
/// part regardless of any trailing `#anchor`).
pub fn PackUri::part_name(self : PackUri) -> String {
  self.part
}

///|
/// §6.3.2 Parse a `pack://...` URI string and support ECMA-376 Part 2 §6.3.3
/// Resolving A Pack Iri To A Resource by exposing the part component used by
/// Package::part. Raises @opc_errors.SchemaViolation when the input does not start with
/// `pack://` or has no path component. Source anchor:
/// references/spec/part2/sections/6.3.3__resolving-a-pack-iri-to-a-resource.md.
///
/// §6.3 — when the IRI carries a fragment (`#anchor`), the
/// fragment is split off the part name and preserved on the
/// `fragment` field; `part` always carries the fragment-free
/// part-name so resource resolution is unaffected.
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
  let authority = rest[0:index].to_owned()
  let path_and_fragment = rest[index:].to_owned()
  // §6.3 — split the fragment off the part component.  The first
  // unescaped `#` starts the fragment; everything after it is the
  // fragment identifier and is NOT part of the part-name.
  let hash_index = find_substring(path_and_fragment, "#")
  let (part, fragment) = if hash_index < 0 {
    (path_and_fragment, None)
  } else {
    (
      path_and_fragment[0:hash_index].to_owned(),
      Some(path_and_fragment[hash_index + 1:].to_owned()),
    )
  }
  PackUri::{ authority, part, fragment }
}
