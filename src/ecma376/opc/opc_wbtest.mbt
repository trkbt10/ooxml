///|
test "open save package facade" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
    ("word/document.xml", b("<document/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  match pkg.part("/word/document.xml") {
    Some(part) =>
      assert_eq(
        part.content_type,
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
      )
    None => fail("expected part")
  }
  let reopened = try! Package::open(try! pkg.save())
  assert_true(reopened.part("/word/document.xml") is Some(_))
}

///|
test "open reports unresolved internal relationship target" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/></Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"t\" Target=\"missing.xml\"/></Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
  ])
  let opened = try? Package::open(try! @zip.write(archive))
  assert_true(opened is Err(@opc_errors.ResourceMissing(_)))
}

///|
test "pack uri parses composed value" {
  let uri = PackUri::compose("example.com", "/word/document.xml")
  assert_eq(uri.to_string(), "pack://example.com/word/document.xml")
  let parsed = try! PackUri::parse(uri.to_string())
  assert_true(parsed == uri)
}

///|
/// §6.3 — a pack IRI with an `#anchor` fragment MUST split the
/// fragment off the part-name so resource resolution targets the
/// correct part, while the fragment survives for callers that
/// rebuild the original IRI.
test "pack uri preserves and strips #fragment" {
  let parsed = try! PackUri::parse(
    "pack://example.com/word/document.xml#bookmark1",
  )
  // The part-name is fragment-free.
  assert_eq(parsed.part_name(), "/word/document.xml")
  // The fragment survives.
  assert_true(parsed.fragment is Some("bookmark1"))
  // to_string round-trips with the fragment re-appended.
  assert_eq(
    parsed.to_string(),
    "pack://example.com/word/document.xml#bookmark1",
  )
  // compose_with_fragment builds the same structure.
  let composed = PackUri::compose_with_fragment(
    "example.com", "/word/document.xml", "bookmark1",
  )
  assert_true(composed == parsed)
  // No-fragment URIs keep fragment = None.
  let plain = try! PackUri::parse("pack://example.com/word/styles.xml")
  assert_true(plain.fragment is None)
}

///|
test "add_part registers new part with Content_Types Override" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/></Types>",
  )
  let archive = @zip.Archive::new([("[Content_Types].xml", content_types)])
  let pkg = try! Package::open(try! @zip.write(archive))
  let added = try! pkg.add_part(
    "/word/document.xml",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
    b("<document/>"),
  )
  match added.part("/word/document.xml") {
    Some(part) =>
      assert_eq(
        part.content_type,
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
      )
    None => assert_true(false)
  }
}

///|
test "add_part rejects duplicate part name" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/a.xml\" ContentType=\"application/xml\"/></Types>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("a.xml", b("<a/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let dup = try? pkg.add_part("/a.xml", "application/xml", b("<a/>"))
  assert_true(dup is Err(@opc_errors.SchemaViolation(_)))
}

///|
test "with_relationship appends a relationship under owner" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/a.xml\" ContentType=\"application/xml\"/></Types>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("a.xml", b("<a/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let extended = try! pkg.with_relationship(
    "/a.xml", "rId1", "http://example.test/type", "b.xml",
  )
  match extended.relationships("/a.xml") {
    Some(rels) => {
      assert_eq(rels.relationships.length(), 1)
      assert_eq(rels.relationships[0].id, "rId1")
    }
    None => assert_true(false)
  }
}

///|
test "remove_part also strips its Override entry" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/a.xml\" ContentType=\"application/xml\"/></Types>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("a.xml", b("<a/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let stripped = try! pkg.remove_part("/a.xml")
  assert_true(stripped.part("/a.xml") is None)
  let mut still_has_override = false
  for rule in stripped.content_types.rules {
    match rule {
      @content_types.Override(o) =>
        if o.part_name.value == "/a.xml" {
          still_has_override = true
        }
      _ => ()
    }
  }
  assert_true(!still_has_override)
}

///|
test "with_content_type_override replaces existing override" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/a.xml\" ContentType=\"application/xml\"/></Types>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("a.xml", b("<a/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let updated = try! pkg.with_content_type_override(
    "/a.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
  )
  let mut count = 0
  for rule in updated.content_types.rules {
    match rule {
      @content_types.Override(o) =>
        if o.part_name.value == "/a.xml" {
          count = count + 1
          assert_eq(
            o.content_type.value,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
          )
        }
      _ => ()
    }
  }
  assert_eq(count, 1)
}

///|
/// OPC §7.1 / §10 — open → save → open must preserve every
/// part name in the package.  This guards against accidental
/// part loss when `Package::save` rebuilds the ZIP entries.
test "open save open preserves every part name" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
    "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
    "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>" +
    "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
    "<Override PartName=\"/word/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml\"/>" +
    "<Override PartName=\"/word/numbering.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml\"/>" +
    "</Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
    "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
    "</Relationships>",
  )
  let doc_rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
    "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>" +
    "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering\" Target=\"numbering.xml\"/>" +
    "</Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
    ("word/document.xml", b("<document/>")),
    ("word/_rels/document.xml.rels", doc_rels),
    ("word/styles.xml", b("<styles/>")),
    ("word/numbering.xml", b("<numbering/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  // Snapshot the original part names.
  let before : Array[String] = []
  for part in pkg.parts {
    before.push(part.name)
  }
  // Round-trip.
  let saved = try! pkg.save()
  let reopened = try! Package::open(saved)
  let after : Array[String] = []
  for part in reopened.parts {
    after.push(part.name)
  }
  // Set-equality: every original part name must be present
  // (order can change because save() emits Content_Types and
  // rels first).
  assert_eq(after.length(), before.length())
  for orig in before {
    let mut found = false
    for got in after {
      if got == orig {
        found = true
        break
      }
    }
    if !found {
      fail("part missing after round-trip: " + orig)
    }
  }
}

///|
fn b(source : String) -> Bytes {
  @utf8.encode(source[:])
}

///|
/// OPC §7.2.4 — `Package::save` MUST honour the source archive's
/// entry order (captured at open time) so a freshly opened then
/// saved package preserves ZIP item ordering.  The test stresses
/// the case where the input order differs from `self.parts`'
/// natural traversal (here we put `_rels/.rels` AFTER the parts).
test "save honours entry_order from source archive" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
    "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
    "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>" +
    "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>" +
    "<Override PartName=\"/word/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml\"/>" +
    "</Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
    "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>" +
    "</Relationships>",
  )
  // Order chosen to differ from the natural "Content_Types → rels → parts"
  // order we used to emit: rels at the bottom, parts in reverse alphabetical.
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("word/styles.xml", b("<styles/>")),
    ("word/document.xml", b("<document/>")),
    ("_rels/.rels", rels),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let saved = try! pkg.save()
  let reopened_archive = try! @zip.read(saved)
  let names : Array[String] = []
  for entry in reopened_archive.entries {
    names.push(entry.name)
  }
  // Expect the source order verbatim.
  assert_eq(names.length(), 4)
  assert_eq(names[0], "[Content_Types].xml")
  assert_eq(names[1], "word/styles.xml")
  assert_eq(names[2], "word/document.xml")
  assert_eq(names[3], "_rels/.rels")
}

///|
test "validate accepts a structurally sound package" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
    ("word/document.xml", b("<document/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  // No violations, and survives a round-trip.
  assert_eq(pkg.validate().length(), 0)
  let reopened = try! Package::open(try! pkg.save())
  assert_eq(reopened.validate().length(), 0)
}

///|
test "validate flags a package with no office-document root relationship" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/></Types>",
  )
  // A root rel of an unrelated type pointing at a present part — opens
  // fine (target resolves), but there is no entry-point office doc.
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties\" Target=\"docProps/core.xml\"/></Relationships>",
  )
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
    ("docProps/core.xml", b("<coreProperties/>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let v = pkg.validate()
  assert_true(v.length() >= 1)
  let mut found = false
  for msg in v {
    if msg.contains("office-document") {
      found = true
    }
  }
  assert_true(found)
}

///|
test "validate flags a part that is not well-formed XML" {
  let content_types = b(
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>",
  )
  let rels = b(
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>",
  )
  // The document part declares an +xml content type but holds broken XML.
  let archive = @zip.Archive::new([
    ("[Content_Types].xml", content_types),
    ("_rels/.rels", rels),
    ("word/document.xml", b("<document><unclosed></document>")),
  ])
  let pkg = try! Package::open(try! @zip.write(archive))
  let v = pkg.validate()
  let mut found = false
  for msg in v {
    if msg.contains("well-formed") {
      found = true
    }
  }
  assert_true(found)
}
