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
  content_types : @content_types.CT_Types
  parts : Array[PackagePart]
  package_relationships : @relationships.CT_Relationships?
  part_relationships : Array[(String, @relationships.CT_Relationships)]
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
  let part_relationships : Array[(String, @relationships.CT_Relationships)] = []
  let mut package_relationships : @relationships.CT_Relationships? = None
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
  // §7.2.4 Interleaving — the spec permits arbitrary ZIP item
  // ordering as long as the package validates.  We honour
  // `entry_order` (captured at open time) so that opening then
  // saving an unchanged archive produces ZIP entries in the
  // original order, the precondition for a byte-identical
  // round-trip.  Newly added parts (not present in
  // `entry_order`) are appended in the order they appear in
  // `self.parts`.
  //
  // Build the materialised entries first (name → bytes) so the
  // ordering pass is a pure index-into-map.
  let materialised : Map[String, Bytes] = Map::new()
  materialised.set(
    "[Content_Types].xml",
    @content_types.write_content_types(self.content_types),
  )
  match self.package_relationships {
    Some(relationships) =>
      materialised.set(
        "_rels/.rels",
        @relationships.write_relationships(relationships),
      )
    None => ()
  }
  // Track the order in which materialised parts appeared in
  // `self.parts` to drive the fallback (post-entry_order) tail.
  let parts_order : Array[String] = []
  for part in self.parts {
    let part_name = @opc_part_name.PartName::__from_trusted(part.name)
    let zip_name = part_name.zip_item_name()
    materialised.set(zip_name, part.data)
    parts_order.push(zip_name)
    match self.relationships(part.name) {
      Some(relationships) => {
        let rels_name = relationships_entry_for_part(part.name)
        materialised.set(
          rels_name,
          @relationships.write_relationships(relationships),
        )
        parts_order.push(rels_name)
      }
      None => ()
    }
  }
  // Emit entries in `entry_order` first, then append any
  // materialised names that did not appear in the source order
  // (i.e. new parts added since the package was opened).
  let entries : Array[(String, Bytes)] = []
  let emitted : Map[String, Unit] = Map::new()
  for name in self.entry_order {
    match materialised.get(name) {
      Some(bytes) => {
        entries.push((name, bytes))
        emitted.set(name, ())
      }
      None => ()
    }
  }
  // Content_Types always exists; if it was absent from
  // entry_order (e.g. constructed package), emit it next so
  // §10.1.2 placement remains valid.
  if not(emitted.contains("[Content_Types].xml")) {
    entries.push((
      "[Content_Types].xml",
      materialised.get("[Content_Types].xml").unwrap(),
    ))
    emitted.set("[Content_Types].xml", ())
  }
  if materialised.contains("_rels/.rels") &&
    not(emitted.contains("_rels/.rels")) {
    entries.push((
      "_rels/.rels",
      materialised.get("_rels/.rels").unwrap(),
    ))
    emitted.set("_rels/.rels", ())
  }
  for name in parts_order {
    if not(emitted.contains(name)) {
      entries.push((name, materialised.get(name).unwrap()))
      emitted.set(name, ())
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
/// Add a brand-new OPC part to the package. ECMA-376 Part 2 §6.3.2
/// Creating A Part: registers the part name + content_type tuple and
/// appends the part to the parts list. The Content_Types table is
/// updated with a §10.1.2.3 Override entry pinning the new part to
/// `content_type`. Raises @opc_errors.SchemaViolation when a part with
/// the same name already exists; callers should use `with_part` to
/// replace existing part payloads.
pub fn Package::add_part(
  self : Package,
  name : String,
  content_type : String,
  data : Bytes,
) -> Package raise @opc_errors.SchemaViolation {
  for existing in self.parts {
    if existing.name == name {
      raise @opc_errors.SchemaViolation(
        section="6.3.2",
        path=name,
        reason="part already exists; use with_part to update",
      )
    }
  }
  let new_parts : Array[PackagePart] = []
  for part in self.parts {
    new_parts.push(part)
  }
  new_parts.push({ name, content_type, data })
  let patched = { ..self, parts: new_parts }
  // §10.1.2.3 — emit a `<Override PartName>` registration even
  // when a `<Default Extension>` rule already covers the same
  // extension/MIME tuple.  The spec prefers Default for
  // extension-based MIMEs (PNG/JPG/GIF/…) to keep
  // `[Content_Types].xml` small, but Override is always
  // permitted and removes ambiguity when the package later
  // adds another `<Default>` for the same extension with a
  // different MIME.  De-duplication against existing Defaults
  // is tracked as a future optimisation.
  patched.with_content_type_override(name, content_type)
}

///|
/// Register a §10.1.2.3 CT_Override entry binding `part_name` to
/// `content_type`. If a CT_Override already exists for the same
/// part_name, it is replaced. Default extension mappings (CT_Default)
/// are not affected.
pub fn Package::with_content_type_override(
  self : Package,
  part_name : String,
  content_type : String,
) -> Package raise @opc_errors.SchemaViolation {
  let parsed_part = @opc_part_name.PartName::__from_trusted(part_name)
  let ct_part_name = @content_types.PartName::__from_trusted(part_name)
  let parsed_ct = @content_types.ContentType::parse(content_type)
  let new_rules : Array[@content_types.ContentTypeRule] = []
  let mut replaced = false
  for rule in self.content_types.rules {
    match rule {
      @content_types.Override(override_rule) =>
        if override_rule.part_name.value == ct_part_name.value {
          new_rules.push(
            @content_types.Override({
              part_name: ct_part_name,
              content_type: parsed_ct,
            }),
          )
          replaced = true
        } else {
          new_rules.push(rule)
        }
      other => new_rules.push(other)
    }
  }
  if !replaced {
    new_rules.push(
      @content_types.Override({
        part_name: ct_part_name,
        content_type: parsed_ct,
      }),
    )
  }
  let _ = parsed_part
  { ..self, content_types: { rules: new_rules } }
}

///|
/// Append a relationship to the owner's CT_Relationships table.
/// `owner` is the OPC part name (e.g. `/ppt/presentation.xml`) or `/`
/// for package-level relationships. Creates a fresh CT_Relationships
/// when the owner has none. The new Id must be unique within the
/// owner's existing relationships.
pub fn Package::with_relationship(
  self : Package,
  owner : String,
  id : String,
  type_uri : String,
  target : String,
  target_mode? : @relationships.TargetMode = @relationships.TargetMode::Internal,
) -> Package raise @opc_errors.SchemaViolation {
  // §9.3.2.4 ST_RelationshipType — the `Type` attribute is an
  // xs:anyURI restricted to absolute URIs.  Reject empty
  // strings; full URI validation (scheme + path) is delegated
  // to the OPC reader at parse time so callers using
  // `with_relationship` to build a fresh package surface bad
  // input early.
  if type_uri.length() == 0 {
    raise @opc_errors.SchemaViolation(
      section="9.3.2.4",
      path=owner,
      reason="relationship Type attribute must be a non-empty absolute URI",
    )
  }
  let new_rel : @relationships.CT_Relationship = {
    id,
    type_uri,
    target,
    target_mode,
  }
  if owner == "/" || owner == "" {
    let existing = match self.package_relationships {
      Some(rels) => rels.relationships
      None => []
    }
    for r in existing {
      if r.id == id {
        raise @opc_errors.SchemaViolation(
          section="9.3",
          path=owner,
          reason="duplicate relationship Id: " + id,
        )
      }
    }
    let new_list : Array[@relationships.CT_Relationship] = []
    for r in existing {
      new_list.push(r)
    }
    new_list.push(new_rel)
    { ..self, package_relationships: Some({ relationships: new_list }) }
  } else {
    let new_part_relationships : Array[
      (String, @relationships.CT_Relationships),
    ] = []
    let mut updated = false
    for item in self.part_relationships {
      let (existing_owner, existing_rels) = item
      if existing_owner == owner {
        for r in existing_rels.relationships {
          if r.id == id {
            raise @opc_errors.SchemaViolation(
              section="9.3",
              path=owner,
              reason="duplicate relationship Id: " + id,
            )
          }
        }
        let new_list : Array[@relationships.CT_Relationship] = []
        for r in existing_rels.relationships {
          new_list.push(r)
        }
        new_list.push(new_rel)
        new_part_relationships.push(
          (existing_owner, { relationships: new_list }),
        )
        updated = true
      } else {
        new_part_relationships.push(item)
      }
    }
    if !updated {
      new_part_relationships.push((owner, { relationships: [new_rel] }))
    }
    { ..self, part_relationships: new_part_relationships }
  }
}

///|
/// Remove a part from the package, also pruning its CT_Override (if
/// present) and any part-relationship table owned by that part name.
/// Relationships in other parts pointing to this part are NOT
/// rewritten; callers must remove or rewrite those references first.
/// Raises when no such part exists.
pub fn Package::remove_part(
  self : Package,
  name : String,
) -> Package raise @opc_errors.SchemaViolation {
  let mut found = false
  let new_parts : Array[PackagePart] = []
  for part in self.parts {
    if part.name == name {
      found = true
    } else {
      new_parts.push(part)
    }
  }
  if !found {
    raise @opc_errors.SchemaViolation(
      section="6.3.2",
      path=name,
      reason="part not found",
    )
  }
  let new_part_relationships : Array[(String, @relationships.CT_Relationships)] = []
  for item in self.part_relationships {
    let (owner, rels) = item
    if owner != name {
      new_part_relationships.push((owner, rels))
    }
  }
  let new_rules : Array[@content_types.ContentTypeRule] = []
  for rule in self.content_types.rules {
    match rule {
      @content_types.Override(override_rule) =>
        if override_rule.part_name.value != name {
          new_rules.push(rule)
        }
      other => new_rules.push(other)
    }
  }
  {
    ..self,
    parts: new_parts,
    part_relationships: new_part_relationships,
    content_types: { rules: new_rules },
  }
}

///|
/// Remove a relationship by Id from the owner's relationships table.
/// `owner` is `/` for package-level relationships, or a part name
/// otherwise. Raises when the relationship is absent.
pub fn Package::remove_relationship(
  self : Package,
  owner : String,
  id : String,
) -> Package raise @opc_errors.SchemaViolation {
  if owner == "/" || owner == "" {
    match self.package_relationships {
      Some(rels) => {
        let new_list : Array[@relationships.CT_Relationship] = []
        let mut removed = false
        for r in rels.relationships {
          if r.id == id {
            removed = true
          } else {
            new_list.push(r)
          }
        }
        if !removed {
          raise @opc_errors.SchemaViolation(
            section="9.3",
            path=owner,
            reason="relationship Id not found: " + id,
          )
        }
        { ..self, package_relationships: Some({ relationships: new_list }) }
      }
      None =>
        raise @opc_errors.SchemaViolation(
          section="9.3",
          path=owner,
          reason="no relationships on owner",
        )
    }
  } else {
    let new_part_relationships : Array[
      (String, @relationships.CT_Relationships),
    ] = []
    let mut found_owner = false
    let mut removed = false
    for item in self.part_relationships {
      let (existing_owner, existing_rels) = item
      if existing_owner == owner {
        found_owner = true
        let new_list : Array[@relationships.CT_Relationship] = []
        for r in existing_rels.relationships {
          if r.id == id {
            removed = true
          } else {
            new_list.push(r)
          }
        }
        new_part_relationships.push(
          (existing_owner, { relationships: new_list }),
        )
      } else {
        new_part_relationships.push(item)
      }
    }
    if !found_owner || !removed {
      raise @opc_errors.SchemaViolation(
        section="9.3",
        path=owner,
        reason="relationship Id not found: " + id,
      )
    }
    { ..self, part_relationships: new_part_relationships }
  }
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
) -> @relationships.CT_Relationships? {
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
/// §9.3.2.3 — allocate the next free `rId<N>`-style relationship
/// id for `owner`.  Scans the existing relationships and returns
/// `"rId" + (max_numeric_suffix + 1)`; non-numeric ids (vendor
/// tokens like `rIdHyperlink`) are skipped per Round 11 #226's
/// tolerant policy so they cannot collide with the numeric
/// pool.  Returns `"rId1"` when `owner` has no existing
/// relationships.
///
/// This centralises the algorithm previously duplicated across
/// `wordprocessing_ml/edit`, `spreadsheet_ml/edit`, and
/// `presentation_ml/edit` per Round 12 #16 / #286.
pub fn Package::allocate_relationship_id(
  self : Package,
  owner : String,
) -> String {
  let existing : Array[@relationships.CT_Relationship] = match
    self.relationships(owner) {
    Some(rs) => rs.relationships
    None => []
  }
  let mut max_rid = 0
  for r in existing {
    if r.id.has_prefix("rId") {
      let parsed = Some(@strconv.parse_int(r.id[3:].to_owned())) catch {
        _ => None
      }
      match parsed {
        Some(n) => if n > max_rid { max_rid = n }
        None => ()
      }
    }
  }
  "rId" + (max_rid + 1).to_string()
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
  relationships : @relationships.CT_Relationships,
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
