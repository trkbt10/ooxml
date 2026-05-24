// ECMA-376 schema catalog tool — entry point.
//
// Loads the Strict / Transitional / OPC XSD sets, enumerates every
// element declaration, synthesises a minimal schema-valid instance
// for each, and writes .snapshots/catalog.json.

///|
/// Map an OOXML target namespace to the short prefix used in the
/// synthesised fragments.  Both the Transitional
/// (`schemas.openxmlformats.org`) and the Strict (`purl.oclc.org`)
/// URIs are mapped to the same prefix.
///|
/// Inverse of `ns_prefix` — the namespace URI a short prefix maps
/// to.  Returns "" when the prefix is unknown so callers stamp the
/// attribute in the no-namespace slot rather than fabricating a
/// non-existent URI.  Used to resolve `<xsd:attribute ref="r:dm">`
/// references back to their referenced attribute's namespace at
/// synthesis time, since rewrite_refs intentionally leaves the raw
/// prefix in place.
fn prefix_ns(prefix : String) -> String {
  match prefix {
    "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    "s" => "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    "p" => "http://schemas.openxmlformats.org/presentationml/2006/main"
    "a" => "http://schemas.openxmlformats.org/drawingml/2006/main"
    "m" => "http://schemas.openxmlformats.org/officeDocument/2006/math"
    "r" =>
      "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    "c" => "http://schemas.openxmlformats.org/drawingml/2006/chart"
    "dgm" => "http://schemas.openxmlformats.org/drawingml/2006/diagram"
    "pic" => "http://schemas.openxmlformats.org/drawingml/2006/picture"
    "xdr" =>
      "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
    "wp" =>
      "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    "cdr" => "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
    "st" => "http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes"
    "sl" => "http://schemas.openxmlformats.org/schemaLibrary/2006/main"
    "v" => "urn:schemas-microsoft-com:vml"
    "o" => "urn:schemas-microsoft-com:office:office"
    "w10" => "urn:schemas-microsoft-com:office:word"
    "x" => "urn:schemas-microsoft-com:office:excel"
    "pvml" => "urn:schemas-microsoft-com:office:powerpoint"
    "xml" => "http://www.w3.org/XML/1998/namespace"
    _ => ""
  }
}

///|
fn ns_prefix(ns : String) -> String {
  match strip_ns(ns) {
    "wordprocessingml/main" => "w"
    "spreadsheetml/main" => "s"
    "presentationml/main" => "p"
    "drawingml/main" => "a"
    "officeDocument/math" => "m"
    "officeDocument/relationships" => "r"
    "drawingml/chart" => "c"
    "drawingml/diagram" => "dgm"
    "drawingml/picture" => "pic"
    "drawingml/spreadsheetDrawing" => "xdr"
    "drawingml/wordprocessingDrawing" => "wp"
    "drawingml/chartDrawing" => "cdr"
    "officeDocument/sharedTypes" => "st"
    "schemaLibrary/main" => "sl"
    _ =>
      match ns {
        "urn:schemas-microsoft-com:vml" => "v"
        "urn:schemas-microsoft-com:office:office" => "o"
        "urn:schemas-microsoft-com:office:word" => "w10"
        "urn:schemas-microsoft-com:office:excel" => "x"
        "urn:schemas-microsoft-com:office:powerpoint" => "pvml"
        "http://www.w3.org/XML/1998/namespace" => "xml"
        _ => "x"
      }
  }
}

///|
/// The document format an OOXML namespace belongs to, or "" when the
/// namespace has no standalone document part.
fn ns_format(ns : String) -> String {
  match strip_ns(ns) {
    "wordprocessingml/main" => "docx"
    "spreadsheetml/main" => "xlsx"
    "presentationml/main" => "pptx"
    "officeDocument/math" => "docx"
    _ => ""
  }
}

///|
/// Reduce a Transitional or Strict OOXML namespace URI to its
/// generation-independent tail (e.g. both
/// `…/wordprocessingml/2006/main` and `…/ooxml/wordprocessingml/main`
/// collapse to `wordprocessingml/main`).
fn strip_ns(ns : String) -> String {
  let trans = "http://schemas.openxmlformats.org/"
  let strict = "http://purl.oclc.org/ooxml/"
  let tail = if ns.has_prefix(trans) {
    ns.substring(start=trans.length())
  } else if ns.has_prefix(strict) {
    ns.substring(start=strict.length())
  } else {
    return ns
  }
  // Transitional carries a `/2006/` date segment Strict omits.
  tail.replace(old="/2006/", new="/")
}

///|
/// Hex digit (0-15) as a lowercase Char.
fn hex_digit(n : Int) -> Char {
  if n < 10 {
    (0x30 + n).to_char().unwrap()
  } else {
    (0x61 + n - 10).to_char().unwrap()
  }
}

///|
/// JSON-escape a string for the catalog output.
fn json_str(s : String) -> String {
  let buf = StringBuilder::new()
  buf.write_char('"')
  for c in s {
    match c {
      '"' => buf.write_string("\\\"")
      '\\' => buf.write_string("\\\\")
      '\n' => buf.write_string("\\n")
      '\r' => buf.write_string("\\r")
      '\t' => buf.write_string("\\t")
      _ =>
        if c.to_int() < 0x20 {
          buf.write_string("\\u")
          let n = c.to_int()
          buf.write_char(hex_digit(n / 4096 % 16))
          buf.write_char(hex_digit(n / 256 % 16))
          buf.write_char(hex_digit(n / 16 % 16))
          buf.write_char(hex_digit(n % 16))
        } else {
          buf.write_char(c)
        }
    }
  }
  buf.write_char('"')
  buf.to_string()
}

///|
/// Catalog tool entry point.
///
/// `catalog`            — build catalog.json + run the round-trip /
///                        render coverage sweep over every element.
/// `catalog fixtures`   — write the content-rich visual fixtures
///                        under .snapshots/fixtures/.
fn main {
  // Install the namespace -> prefix mapping the synthesiser uses so
  // every emitted element carries the prefix of its own namespace.
  g_ns_prefix.val = ns_prefix
  g_prefix_ns.val = prefix_ns
  let args = @env.args()
  if args.length() >= 2 && args[1] == "fixtures" {
    generate_visual_fixtures()
    return
  }
  let debug_id = if args.length() >= 3 && args[1] == "debug" {
    args[2]
  } else {
    ""
  }
  let ancestry_id = if args.length() >= 3 && args[1] == "ancestry" {
    args[2]
  } else {
    ""
  }
  let schema = Schema::new()
  // Load every schema set in order; Transitional first so a
  // dual-generation element keeps its Transitional namespace.
  for set in schema_sets() {
    let files = try? @fs.read_dir(set.dir)
    match files {
      Err(_) => println("!! schema set missing: " + set.dir)
      Ok(names) =>
        for fname in names {
          if fname.has_suffix(".xsd") {
            let path = set.dir + "/" + fname
            let text = (try? @fs.read_file_to_string(path)).unwrap_or("")
            if text.length() > 0 {
              match (try? @xml.parse(@utf8.encode(text[:]))) {
                Ok(doc) => schema.load(doc.root, text, set.lineage)
                Err(_) => println("!! parse error: " + path)
              }
            }
          }
        }
    }
  }
  println(
    "loaded: \{schema.complex_types.size()} complexTypes, " +
    "\{schema.simple_types.size()} simpleTypes, " +
    "\{schema.all_elements.size()} element declarations, " +
    "\{schema.groups.size()} groups",
  )

  // Containment ancestry — the wrapper chain from a part root down to
  // each element, used to embed host-less elements where the schema
  // actually permits them.
  let ancestry = build_ancestry(schema)
  if ancestry_id != "" {
    println("ancestry probe: \{ancestry_id}")
    println("  ancestry size: \{ancestry.size()}")
    // Direct type_children probe — `ancestry_id` is treated as a
    // complexType name when it starts with `CT_`.
    if ancestry_id.has_prefix("CT_") {
      match schema.complex_types.get(ancestry_id) {
        Some(ct) => {
          let kids = type_children(schema, ct)
          println("  \{ancestry_id} children: \{kids.length()}")
          for k in kids {
            let (n, t) = k
            println("    - \{n} : \{t}")
          }
        }
        None => println("  \{ancestry_id} not in schema!")
      }
      return
    }
    for key, path in ancestry {
      if nt_name(key) == ancestry_id {
        let names : Array[String] = []
        for step in path {
          names.push(step.0)
        }
        println("  \{key} <- " + names.join(" / "))
      }
    }
    return
  }

  // Count the distinct types each element name is declared with, so
  // a name with a single type gets a bare id and only genuine
  // name+type collisions are disambiguated with a `__type` suffix.
  let name_variants : Map[String, Int] = Map::new()
  for _key, decl in schema.all_elements {
    name_variants[decl.name] = name_variants.get(decl.name).unwrap_or(0) + 1
  }

  // Synthesise one catalog entry per element declaration.
  let entries : Array[String] = []
  let cov_entries : Array[String] = []
  let mut count = 0
  // Tallies for the coverage summary.
  let outcomes : Map[String, Int] = Map::new()
  let lineage_tally : Map[String, Int] = Map::new()
  let mut hosted = 0
  let mut hosted_ok = 0
  let mut hostless = 0
  let mut hostless_ok = 0
  // Element name -> true once any catalog entry for that name has
  // verified `rendered`; consumed by the spec-section render
  // coverage.
  let element_ok : Map[String, Bool] = Map::new()
  // Element name -> true once any catalog entry for it opened and
  // round-tripped without crash (`rendered` OR `parsed`); consumed by
  // the spec-section round-trip coverage.
  let element_parsed : Map[String, Bool] = Map::new()
  // Every element name the ECMA-376 XSD declares — lets the section
  // analysis discard prose tokens that are not real elements.
  let element_known : Map[String, Bool] = Map::new()
  for _k, decl in schema.all_elements {
    element_known[decl.name] = true
  }
  for _key, decl in schema.all_elements {
    let prefix = ns_prefix(decl.namespace)
    let fmt = ns_format(decl.namespace)
    let stack : StrSet = Map::new()
    // Synthesise the element under test as an @xml.Element tree.
    // The element under test gets the rich synthesis budget so its
    // instance is visually non-degenerate (see RICH_BUDGET).
    let target : @xml.Element = if decl.type_name == "__inline__" {
      match xsd_child(decl.node, "complexType") {
        Some(ict) => {
          let st : StrSet = Map::new()
          synth_element(
            schema,
            ict,
            decl.namespace,
            decl.name,
            st,
            0,
            RICH_BUDGET,
          )
        }
        None => elem(decl.namespace, decl.name, [], [])
      }
    } else if decl.type_name == "__empty__" {
      elem(decl.namespace, decl.name, [], [])
    } else {
      match schema.complex_types.get(decl.type_name) {
        Some(ct_el) => {
          let st : StrSet = Map::new()
          st[decl.type_name] = true
          synth_element(
            schema,
            ct_el,
            decl.namespace,
            decl.name,
            st,
            0,
            RICH_BUDGET,
          )
        }
        None =>
          // A simple-type-typed element carries its value as text.
          if schema.simple_types.get(decl.type_name) is Some(_) ||
            decl.type_name.has_prefix("http://www.w3.org/2001/XMLSchema#") {
            elem(decl.namespace, decl.name, [], [
              Text(sample_for_simple(schema, decl.type_name, 0)),
            ])
          } else {
            elem(decl.namespace, decl.name, [], [])
          }
      }
    }
    // The type display (local) name and a stable id.
    let type_local = match decl.type_name.rev_find("#") {
      Some(i) => decl.type_name[i + 1:].to_string()
      None => decl.type_name
    }
    let ident = if name_variants.get(decl.name).unwrap_or(1) <= 1 ||
      decl.type_name.has_prefix("__") {
      decl.name
    } else {
      decl.name + "__" + type_local
    }
    let lineage_json = StringBuilder::new()
    lineage_json.write_char('[')
    for i, lin in decl.lineages {
      if i > 0 {
        lineage_json.write_char(',')
      }
      lineage_json.write_string(json_str(lin))
    }
    lineage_json.write_char(']')
    let type_json = if decl.type_name.has_prefix("__") {
      "null"
    } else {
      json_str(type_local)
    }
    // The fragment is serialised from the @xml tree (escaped by the
    // writer), never assembled by string concatenation.  It is taken
    // BEFORE the verifier sentinel is stamped, so the catalog records
    // the clean element.
    let fragment = @utf8.decode_lossy(write_part(target)[:])
    // The verification copy carries the `TARGET_ATTR` sentinel so the
    // differential render check can locate and prune it.
    let target = stamp_target(target)
    entries.push(
      "{\"id\":" +
      json_str(ident) +
      ",\"element\":" +
      json_str(decl.name) +
      ",\"type\":" +
      type_json +
      ",\"namespace\":" +
      json_str(decl.namespace) +
      ",\"prefix\":" +
      json_str(prefix) +
      ",\"format\":" +
      (if fmt == "" { "null" } else { json_str(fmt) }) +
      ",\"lineage\":" +
      lineage_json.to_string() +
      ",\"fragment\":" +
      json_str(fragment) +
      "}",
    )
    // Embed the element at its schema-correct position: wrap it in
    // its containment ancestry (a real element tree).  The ancestry
    // also picks the host format.
    let (host_fmt, embed_tree) = {
      let akey = nt_key(decl.name, decl.type_name)
      match ancestry.get(akey) {
        Some(path) if path.length() >= 1 => {
          let root_name = path[0].0
          let host = match root_name {
            "worksheet" => "xlsx"
            "sld" => "pptx"
            _ => "docx"
          }
          (host, wrap_in_ancestry(schema, path, 1, target))
        }
        _ => (if fmt != "" { fmt } else { "docx" }, target)
      }
    }
    // Round-trip + render verification with a unique marker token.
    let marker = "CATm\{count}m"
    let outcome = verify_entry(host_fmt, embed_tree, marker)
    if debug_id != "" && ident == debug_id {
      println("debug id=\{ident} element=\{decl.name} fmt=\{fmt}")
      println("  type key    : \{decl.type_name}")
      println("  host format : \{host_fmt}")
      println("  fragment    : \{fragment}")
      println("  outcome     : \{outcome}")
      let (subst, _h) = substitute_marker(embed_tree, marker)
      let pkg = match host_fmt {
        "xlsx" => xlsx_package(subst)
        "pptx" => pptx_package(subst)
        _ => docx_package(subst)
      }
      let _ = try? @fs.write_bytes_to_file("/tmp/dbg.bin", pkg)
      println("  pkg -> /tmp/dbg.bin (\{pkg.length()}b)")
      let (psvg, asvg) = debug_render_pair(host_fmt, embed_tree)
      println("  present SVG : \{psvg.length()}b")
      println("  absent  SVG : \{asvg.length()}b")
      println("  SVG differ  : \{psvg != asvg}")
      let _ = try? @fs.write_string_to_file("/tmp/dbg_present.svg", psvg)
      let _ = try? @fs.write_string_to_file("/tmp/dbg_absent.svg", asvg)
    }
    // Surface every non-clean outcome with its entry id so a
    // regression can be located without a separate probe run.
    if outcome != "rendered" && outcome != "parsed" {
      println(
        "    [\{outcome}] \{ident}  (element=\{decl.name}, type=\{decl.type_name}, host=\{host_fmt})",
      )
    }
    outcomes[outcome] = outcomes.get(outcome).unwrap_or(0) + 1
    // A genuine `rendered` outcome counts the element render-verified;
    // `rendered` OR `parsed` counts it round-trip-verified.  Both feed
    // the two-dimensional spec-section coverage.
    if outcome == "rendered" {
      element_ok[decl.name] = true
    }
    if outcome == "rendered" || outcome == "parsed" {
      element_parsed[decl.name] = true
    }
    // Lineage tally (joined, e.g. "strict+transitional").
    let lin_key = decl.lineages.join("+")
    lineage_tally[lin_key] = lineage_tally.get(lin_key).unwrap_or(0) + 1
    // Host vs host-less split (a docx/xlsx/pptx namespace has a
    // standalone document part; other namespaces do not).
    let no_crash = outcome == "rendered" || outcome == "parsed"
    if fmt != "" {
      hosted = hosted + 1
      if no_crash {
        hosted_ok = hosted_ok + 1
      }
    } else {
      hostless = hostless + 1
      if no_crash {
        hostless_ok = hostless_ok + 1
      }
    }
    cov_entries.push(
      "{\"id\":" +
      json_str(ident) +
      ",\"element\":" +
      json_str(decl.name) +
      ",\"format\":" +
      (if fmt == "" { "null" } else { json_str(fmt) }) +
      ",\"outcome\":" +
      json_str(outcome) +
      "}",
    )
    count = count + 1
  }

  // Write catalog.json.
  let out = StringBuilder::new()
  out.write_string("{\"source\":\"ECMA-376 Strict + Transitional + OPC XSD\",")
  out.write_string("\"element_count\":\{count},")
  out.write_string("\"entries\":[\n")
  for i, e in entries {
    if i > 0 {
      out.write_string(",\n")
    }
    out.write_string(e)
  }
  out.write_string("\n]}\n")
  let _ = try? @fs.create_dir(".snapshots")
  match
    (try? @fs.write_string_to_file(".snapshots/catalog.json", out.to_string())) {
    Ok(_) =>
      println("catalog: \{count} element entries -> .snapshots/catalog.json")
    Err(_) => println("!! failed to write catalog.json")
  }

  // Write coverage.json — the round-trip + render outcome per entry.
  let cov = StringBuilder::new()
  cov.write_string("{\"total\":\{count},\"counts\":{")
  let mut first = true
  for k, v in outcomes {
    if not(first) {
      cov.write_char(',')
    }
    first = false
    cov.write_string(json_str(k) + ":\{v}")
  }
  cov.write_string("},\"results\":[\n")
  for i, e in cov_entries {
    if i > 0 {
      cov.write_string(",\n")
    }
    cov.write_string(e)
  }
  cov.write_string("\n]}\n")
  match
    (try? @fs.write_string_to_file(".snapshots/coverage.json", cov.to_string())) {
    Ok(_) => ()
    Err(_) => println("!! failed to write coverage.json")
  }

  // Print the coverage summary.  Two distinct numbers, kept apart on
  // purpose: `rendered` (the element's content genuinely reached the
  // SVG — a true render check) and `parsed` (no crash, but the
  // element produced no traceable output).
  let rendered = outcomes.get("rendered").unwrap_or(0)
  let parsed = outcomes.get("parsed").unwrap_or(0)
  let no_crash = rendered + parsed
  println("")
  println("============================================================")
  println("ECMA-376 specification coverage")
  println("============================================================")
  println("")
  println("L1  schema enumeration  (ECMA-376 Strict + Transitional + OPC)")
  println("    element declarations catalogued : \{count}")
  println(
    "    complex types                   : \{schema.complex_types.size()}",
  )
  println("    by schema lineage:")
  for k, v in lineage_tally {
    println("      \{k} : \{v}")
  }
  println("")
  println("L2  open + round-trip + render  (this package's builder +")
  println("    reader + renderer: open -> save -> open -> to_svg)")
  for k, v in outcomes {
    println("    \{k} : \{v}")
  }
  let npct = pct10(no_crash, count)
  let rpct = pct10(rendered, count)
  println("")
  println(
    "    parses + round-trips without crash : \{no_crash}/\{count} " +
    "(\{npct / 10}.\{npct % 10}%)",
  )
  println(
    "    content verified in rendered SVG   : \{rendered}/\{count} " +
    "(\{rpct / 10}.\{rpct % 10}%)",
  )
  println("      (the remaining \{parsed} `parsed` are property / structural")
  println("       elements with no text to trace, or content the renderer")
  println("       does not surface — NOT a render guarantee)")
  println("")
  println("    elements WITH a standalone document host (docx/xlsx/pptx):")
  let hpct = pct10(hosted_ok, hosted)
  println(
    "      no crash : \{hosted_ok}/\{hosted} (\{hpct / 10}.\{hpct % 10}%)",
  )
  println("    elements WITHOUT a standalone host (embedded via a parent):")
  println("      no crash when embedded : \{hostless_ok}/\{hostless}")
  println("")

  // L3 — ECMA-376 specification-section coverage.  The unit here is
  // the spec section (Part 1-4, 569 in total), cross-referenced
  // against the verified element set, in two dimensions: round-trip
  // (the library handles the element) and render (a traced effect
  // reached the SVG).
  let part_cov = analyse_sections(element_ok, element_parsed, element_known)
  let mut total_sec = 0
  let mut total_prose = 0
  let mut rt_covered = 0
  let mut rt_partial = 0
  let mut rt_uncov = 0
  let mut rn_covered = 0
  let mut rn_partial = 0
  let mut rn_uncov = 0
  println("L3  ECMA-376 specification-section coverage (Part 1-4)")
  for pc in part_cov {
    total_sec = total_sec + pc.sections
    total_prose = total_prose + pc.prose_only
    rt_covered = rt_covered + pc.rt_covered
    rt_partial = rt_partial + pc.rt_partial
    rt_uncov = rt_uncov + pc.rt_uncovered
    rn_covered = rn_covered + pc.rn_covered
    rn_partial = rn_partial + pc.rn_partial
    rn_uncov = rn_uncov + pc.rn_uncovered
    println(
      "    \{pc.part}: \{pc.sections} sections (\{pc.prose_only} prose) — " +
      "round-trip: covered \{pc.rt_covered}, partial \{pc.rt_partial}, " +
      "uncovered \{pc.rt_uncovered}",
    )
  }
  // prose-only sections (conformance / scope / overview) define no
  // element and are excluded from both denominators.
  let element_sections = total_sec - total_prose
  let rtpct = pct10(rt_covered, element_sections)
  let rnpct = pct10(rn_covered, element_sections)
  println(
    "    total: \{total_sec} sections " +
    "(\{total_prose} prose-only, \{element_sections} element-defining)",
  )
  println("")
  println("    round-trip — every element of the section opens + round")
  println("    trips without crash (the library handles it):")
  println(
    "      element-defining sections fully covered: " +
    "\{rt_covered}/\{element_sections} (\{rtpct / 10}.\{rtpct % 10}%)",
  )
  println("      partial \{rt_partial}, uncovered \{rt_uncov}")
  println("")
  println("    render — every element additionally left a traced effect")
  println("    in the SVG (strict; many config / metadata elements are")
  println("    inherently non-visual and cannot meet this bar):")
  println(
    "      element-defining sections fully covered: " +
    "\{rn_covered}/\{element_sections} (\{rnpct / 10}.\{rnpct % 10}%)",
  )
  println("      partial \{rn_partial}, uncovered \{rn_uncov}")
  println("")
  println("------------------------------------------------------------")
  println(
    "summary: \{count} ECMA-376 elements catalogued; " +
    "\{no_crash}/\{count} parse + round-trip without crash; " +
    "\{rendered}/\{count} content verified in the rendered SVG.",
  )
  println(
    "         spec sections — round-trip \{rt_covered}/\{element_sections}, " +
    "render \{rn_covered}/\{element_sections} " +
    "(of \{element_sections} element-defining; \{total_prose} prose-only).",
  )
}

///|
/// Percentage of `n`/`d` scaled to tenths (e.g. 897 == 89.7%).
///|
fn pct10(n : Int, d : Int) -> Int {
  if d > 0 {
    n * 1000 / d
  } else {
    0
  }
}
