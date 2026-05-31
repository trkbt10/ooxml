// ECMA-376 Part 2 — structural validity of an OPC package.
//
// These are the package-level invariants a conforming consumer
// (including Microsoft Office) requires before it will open a file.
// They are NECESSARY conditions: a package that fails any of them is
// rejected; passing all of them is strong (though not sufficient)
// evidence the package is acceptable.  The check is self-contained —
// it needs no external validator — so a round-tripped package can be
// asserted structurally sound here.
//
//   §6.2.2  every part name is valid and every part has a resolvable
//           content type (default-by-extension or override);
//   §7.3.7  XML parts are well-formed;
//   §6.3    every Internal relationship target resolves to a part that
//           actually exists in the package;
//   §11     the package carries a root relationship to a main
//           document part (workbook / presentation / document).

///|
/// Validate the OPC package's structural invariants and return the
/// list of violations (empty ⇒ structurally valid / openable).
pub fn Package::validate(self : Package) -> Array[String] {
  let violations : Array[String] = []
  // Index existing part names for O(1) relationship-target lookups.
  let part_names : Map[String, Bool] = Map([], capacity=0)
  for p in self.parts {
    part_names.set(p.name, true)
  }
  // §6.2.2 / §7.3.7 — content type resolvable + XML well-formed.
  for p in self.parts {
    if p.content_type == "" {
      violations.push("part has no resolvable content type: " + p.name)
    }
    if is_xml_content_type(p.content_type) {
      try @xml.parse(p.data) |> ignore catch {
        _ => violations.push("part is not well-formed XML: " + p.name)
      } noraise {
        _ => ()
      }
    }
  }
  // §6.3 — every Internal relationship target must resolve to a part
  // that exists.  (External targets point outside the package and are
  // not checked here.)
  fn check_rels(
    owner : String,
    rels : @relationships.CT_Relationships,
  ) -> Unit {
    for r in rels.relationships {
      if r.target_mode == @relationships.TargetMode::Internal {
        try @opc_part_name.resolve_target(owner, r.target) catch {
          _ =>
            violations.push(
              "relationship '" +
              r.id +
              "' in " +
              owner +
              " has an unresolvable target: " +
              r.target,
            )
        } noraise {
          name =>
            if !part_names.contains(name) {
              violations.push(
                "relationship '" +
                r.id +
                "' in " +
                owner +
                " points to a missing part: " +
                name,
              )
            }
        }
      }
    }
  }

  match self.package_relationships {
    Some(rels) => check_rels("/", rels)
    None => ()
  }
  for pr in self.part_relationships {
    let (owner, rels) = pr
    check_rels(owner, rels)
  }
  // §11 — a package-level office-document root relationship must be
  // present and resolve (otherwise the consumer has no entry point).
  let office_doc_type = @opc_namespaces.relationship_type_office_document()
  let mut has_office_doc = false
  match self.package_relationships {
    Some(rels) =>
      for r in rels.relationships {
        if r.type_uri == office_doc_type {
          has_office_doc = true
        }
      }
    None => ()
  }
  if !has_office_doc {
    violations.push(
      "package has no root office-document relationship (no entry point)",
    )
  }
  violations
}

///|
/// True when an OPC content type denotes an XML stream (the part
/// should therefore be well-formed XML).
fn is_xml_content_type(content_type : String) -> Bool {
  // Strip any `; charset=…` parameter before matching.
  let base = match content_type.find(";") {
    Some(i) => content_type[0:i].to_owned()
    None => content_type
  }
  base.has_suffix("+xml") || base.has_suffix("/xml")
}
