///|
/// Raw OPC package part with its package part name, content type, and bytes.
/// ECMA-376 Part 2 §6.1 General. Source:
/// `references/spec/part2/sections/6.1__general.md`. Owned by
/// `src/ecma376/opc`.
/// ECMA-376 Part 2 §6.2.1 General. ECMA-376 Part 2 §6.2.4 Growth Hint.
/// ECMA-376 Part 2 §6.2.5 Xml Usage. Each part is represented by its part
/// name, content type, and byte payload; growth-hint metadata is not
/// interpreted by this lightweight table.
pub(all) struct PackagePart {
  name : String
  content_type : String
  data : Bytes
} derive(Eq, Debug)

///|
/// Parsed OPC package context over a ZIP archive. ECMA-376 Part 2 §7.2.1
/// Using Features Of Physical Formats and §7.2.2 Mapped Components are
/// represented by the ZIP entry table, content-types table, and relationships
/// tables that determine which physical items hold OPC parts.
pub(all) struct Package {
  content_types : @content_types.Types
  parts : Array[PackagePart]
  package_relationships : @relationships.Relationships?
  part_relationships : Array[(String, @relationships.Relationships)]
  entry_order : Array[String]
} derive(Eq, Debug)

///|
/// ECMA-376 Part 2 §7.2.1 Using Features Of Physical Formats and §7.3
/// Mapping To A Zip File. Source anchor:
/// references/spec/part2/sections/7.3__mapping-to-a-zip-file.md. §7.3.1
/// General: open OPC package bytes from a ZIP archive, parse §7.3.7 Mapping
/// The Media Types Stream from `[Content_Types].xml`, parse relationships, map
/// ZIP item names to OPC part names, and validate internal relationship
/// targets.
pub fn Package::open(bytes : Bytes) -> Package raise {
  let archive = @zip.read(bytes)
  let content_types_bytes = required_entry(archive, "[Content_Types].xml")
  let content_types = @content_types.read_content_types(content_types_bytes)
  let parts : Array[PackagePart] = []
  let part_relationships : Array[(String, @relationships.Relationships)] = []
  let mut package_relationships : @relationships.Relationships? = None
  let entry_order : Array[String] = []
  for entry in archive.entries {
    entry_order.push(entry.name)
    if entry.name != "[Content_Types].xml" {
      if is_relationships_entry(entry.name) {
        let relationships = @relationships.read_relationships(entry.data)
        match relationships_owner(entry.name) {
          Some(owner) => part_relationships.push((owner, relationships))
          None => package_relationships = Some(relationships)
        }
      } else {
        let part_name = "/" + entry.name
        let ct_part_name = @content_types.PartName::__from_trusted(part_name)
        let content_type = match
          content_types.content_type_for_part(ct_part_name) {
          Some(value) => value.to_string()
          None =>
            raise @opc_errors.ResourceMissing(
              section="7.3.7",
              path="[Content_Types].xml",
              target=part_name,
            )
        }
        parts.push({ name: part_name, content_type, data: entry.data })
      }
    }
  }
  let opened = {
    content_types,
    parts,
    package_relationships,
    part_relationships,
    entry_order,
  }
  opened.validate_relationship_targets()
  opened
}

///|
/// ECMA-376 Part 2 §7.2.4 Interleaving and §7.3 Mapping To A Zip File: save
/// the OPC package back to ZIP bytes after mapping OPC part names to physical
/// ZIP item names and writing §7.3.7 Mapping The Media Types Stream as
/// `[Content_Types].xml`. Source:
/// `references/spec/part2/sections/7.2.4__interleaving.md`. Owned by
/// `src/ecma376/opc`.
pub fn Package::save(self : Package) -> Bytes raise {
  let entries : Array[(String, Bytes)] = []
  entries.push(
    (
      "[Content_Types].xml",
      @content_types.write_content_types(self.content_types),
    ),
  )
  match self.package_relationships {
    Some(relationships) =>
      entries.push(
        ("_rels/.rels", @relationships.write_relationships(relationships)),
      )
    None => ()
  }
  for part in self.parts {
    let part_name = @opc_part_name.PartName::__from_trusted(part.name)
    entries.push((part_name.zip_item_name(), part.data))
    match self.relationships(part.name) {
      Some(relationships) =>
        entries.push(
          (
            relationships_entry_for_part(part.name),
            @relationships.write_relationships(relationships),
          ),
        )
      None => ()
    }
  }
  @zip.write(@zip.Archive::new(entries))
}

///|
/// Return a package part by OPC part name such as `/word/document.xml`,
/// covering ECMA-376 Part 2 §6.3.3 Resolving A Pack Iri To A Resource at the
/// facade level. Source anchor:
/// references/spec/part2/sections/6.3.3__resolving-a-pack-iri-to-a-resource.md.
pub fn Package::part(self : Package, name : String) -> PackagePart? {
  for part in self.parts {
    if part.name == name {
      return Some(part)
    }
  }
  None
}

///|
/// Replace an existing part payload while preserving its part name, content
/// type, and package entry order. ECMA-376 Part 2 §7.3.2 Mapping Part Data.
pub fn Package::with_part(
  self : Package,
  name : String,
  data : Bytes,
) -> Package {
  let parts : Array[PackagePart] = []
  for part in self.parts {
    if part.name == name {
      parts.push({ name: part.name, content_type: part.content_type, data })
    } else {
      parts.push(part)
    }
  }
  { ..self, parts, }
}

///|
/// Replace an existing optional part when a value is present; leave the package
/// unchanged when the value is absent. ECMA-376 Part 2 §7.3.2 Mapping Part Data.
pub fn[T] Package::with_optional_part(
  self : Package,
  name : String,
  value : T?,
  writer : (T) -> Bytes,
) -> Package {
  match value {
    Some(v) => self.with_part(name, writer(v))
    None => self
  }
}

///|
/// Look up a part that the OPC relationship or package layer requires to be
/// present. ECMA-376 Part 2 §6.3.3 Resolving A Pack Iri To A Resource.
pub fn Package::required_part(
  self : Package,
  name : String,
  section~ : String,
  source_path~ : String,
) -> PackagePart raise @opc_errors.ResourceMissing {
  match self.part(name) {
    Some(part) => part
    None =>
      raise @opc_errors.ResourceMissing(section~, path=source_path, target=name)
  }
}

///|
/// Parse an optional package part when it exists, otherwise return `None`.
/// ECMA-376 Part 2 §6.3.3 Resolving A Pack Iri To A Resource.
pub fn[T] Package::read_optional(
  self : Package,
  name : String,
  reader : (Bytes) -> T raise,
) -> T? raise {
  match self.part(name) {
    Some(part) => Some(reader(part.data))
    None => None
  }
}

///|
/// Return package relationships for `/`, or part relationships for a part
/// name. ECMA-376 Part 2 §6.4.2 Base Iris and §6.4.3 Examples are represented
/// by the owner part name used later when resolving internal targets. Sources:
/// `references/spec/part2/sections/6.4.2__base-iris.md` and
/// `references/spec/part2/sections/6.4.3__examples.md`.
pub fn Package::relationships(
  self : Package,
  name : String,
) -> @relationships.Relationships? {
  if name == "/" || name == "" {
    self.package_relationships
  } else {
    for item in self.part_relationships {
      let (owner, relationships) = item
      if owner == name {
        return Some(relationships)
      }
    }
    None
  }
}

///|
fn Package::validate_relationship_targets(self : Package) -> Unit raise {
  match self.package_relationships {
    Some(relationships) => validate_targets(self, "/", relationships)
    None => ()
  }
  for item in self.part_relationships {
    let (owner, relationships) = item
    validate_targets(self, owner, relationships)
  }
}

///|
fn validate_targets(
  pkg : Package,
  owner : String,
  relationships : @relationships.Relationships,
) -> Unit raise {
  for relationship in relationships.relationships {
    if relationship.target_mode == @relationships.TargetMode::Internal {
      let target = @opc_part_name.resolve_target(owner, relationship.target)
      if pkg.part(target) is None {
        raise @opc_errors.ResourceMissing(
          section="6.4",
          path="/Relationships/Relationship[@Id='" + relationship.id + "']",
          target~,
        )
      }
    }
  }
}

///|
/// Require a ZIP entry such as §7.3.7 Mapping The Media Types Stream
/// `[Content_Types].xml`, reporting @opc_errors.ResourceMissing when the mapped component
/// is absent.
fn required_entry(
  archive : @zip.Archive,
  name : String,
) -> Bytes raise @opc_errors.ResourceMissing {
  for entry in archive.entries {
    if entry.name == name {
      return entry.data
    }
  }
  raise @opc_errors.ResourceMissing(section="7.3.7", path=name, target=name)
}

///|
fn is_relationships_entry(name : String) -> Bool {
  name == "_rels/.rels" ||
  (name.contains("/_rels/") && name.has_suffix(".rels"))
}

///|
fn relationships_owner(name : String) -> String? {
  if name == "_rels/.rels" {
    None
  } else {
    let marker = "/_rels/"
    let index = find_substring(name, marker)
    if index < 0 {
      None
    } else {
      let prefix = name[0:index].to_owned()
      let rel_name = name[index + marker.length():]
      let base = if rel_name.has_suffix(".rels") {
        rel_name[0:rel_name.length() - 5].to_owned()
      } else {
        rel_name.to_owned()
      }
      Some("/" + prefix + "/" + base)
    }
  }
}

///|
fn relationships_entry_for_part(
  part_name : String,
) -> String raise @opc_errors.SchemaViolation {
  let zip_name = @opc_part_name.PartName::__from_trusted(part_name).zip_item_name()
  let slash = @opc_part_name.last_slash(zip_name)
  if slash < 0 {
    "_rels/" + zip_name + ".rels"
  } else {
    zip_name[0:slash].to_owned() +
    "/_rels/" +
    zip_name[slash + 1:].to_owned() +
    ".rels"
  }
}

///|
fn find_substring(value : String, needle : String) -> Int {
  let chars = value.to_array()
  let pat = needle.to_array()
  let mut result = -1
  if pat.length() == 0 || pat.length() > chars.length() {
    result
  } else {
    for i in 0..<=(chars.length() - pat.length()) {
      let mut ok = true
      for j in 0..<pat.length() {
        if chars[i + j] != pat[j] {
          ok = false
        }
      }
      if ok && result < 0 {
        result = i
      }
    }
    result
  }
}
