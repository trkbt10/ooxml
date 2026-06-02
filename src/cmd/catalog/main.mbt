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
    "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
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
/// Catalog host selection for an ancestry root / part root.  Keep
/// this as the single source of truth for both normal ancestry paths
/// and empty paths where the element under test is itself the part
/// root.
struct CatalogPartRoot {
  name : String
  type_ns_tail : String
  type_local : String
  host : String
  phase : String
}

///|
/// The ECMA-376 OPC part roots the catalog can synthesize.
///
/// Name alone is intentionally insufficient here: `<comments>` is
/// both an SML comments part and a WML comments part, and `<fonts>` is
/// a WML font-table part while SML also uses `<fonts>` inside
/// `styles.xml`.  Type namespace + type local name are the key that
/// keeps host selection and BFS seeding on one source of truth.
fn catalog_part_roots() -> Array[CatalogPartRoot] {
  [
    {
      name: "document",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Document",
      host: "docx",
      phase: "primary",
    },
    {
      name: "worksheet",
      type_ns_tail: "spreadsheetml/main",
      type_local: "CT_Worksheet",
      host: "xlsx",
      phase: "primary",
    },
    {
      name: "sld",
      type_ns_tail: "presentationml/main",
      type_local: "CT_Slide",
      host: "pptx",
      phase: "primary",
    },
    {
      name: "presentation",
      type_ns_tail: "presentationml/main",
      type_local: "CT_Presentation",
      host: "pptx:presentation",
      phase: "supplementary",
    },
    {
      name: "workbook",
      type_ns_tail: "spreadsheetml/main",
      type_local: "CT_Workbook",
      host: "xlsx:workbook",
      phase: "supplementary",
    },
    {
      name: "sst",
      type_ns_tail: "spreadsheetml/main",
      type_local: "CT_Sst",
      host: "xlsx:sharedStrings",
      phase: "supplementary",
    },
    {
      name: "styleSheet",
      type_ns_tail: "spreadsheetml/main",
      type_local: "CT_Stylesheet",
      host: "xlsx:styles",
      phase: "supplementary",
    },
    {
      name: "comments",
      type_ns_tail: "spreadsheetml/main",
      type_local: "CT_Comments",
      host: "xlsx:comments",
      phase: "supplementary",
    },
    {
      name: "theme",
      type_ns_tail: "drawingml/main",
      type_local: "CT_OfficeStyleSheet",
      host: "pptx:theme",
      phase: "supplementary",
    },
    {
      name: "settings",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Settings",
      host: "docx:settings",
      phase: "supplementary",
    },
    {
      name: "styles",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Styles",
      host: "docx:styles",
      phase: "supplementary",
    },
    {
      name: "numbering",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Numbering",
      host: "docx:numbering",
      phase: "supplementary",
    },
    {
      name: "fonts",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_FontsList",
      host: "docx:fonts",
      phase: "supplementary",
    },
    {
      name: "webSettings",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_WebSettings",
      host: "docx:webSettings",
      phase: "supplementary",
    },
    {
      name: "comments",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Comments",
      host: "docx:comments",
      phase: "supplementary",
    },
    {
      name: "footnotes",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Footnotes",
      host: "docx:footnotes",
      phase: "supplementary",
    },
    {
      name: "endnotes",
      type_ns_tail: "wordprocessingml/main",
      type_local: "CT_Endnotes",
      host: "docx:endnotes",
      phase: "supplementary",
    },
    {
      name: "chartSpace",
      type_ns_tail: "drawingml/chart",
      type_local: "CT_ChartSpace",
      host: "pptx:chart",
      phase: "chart",
    },
    {
      name: "dataModel",
      type_ns_tail: "drawingml/diagram",
      type_local: "CT_DataModel",
      host: "pptx:diagram-data",
      phase: "diagram",
    },
    {
      name: "layoutDef",
      type_ns_tail: "drawingml/diagram",
      type_local: "CT_DiagramDefinition",
      host: "pptx:diagram-layout",
      phase: "diagram",
    },
    {
      name: "styleDef",
      type_ns_tail: "drawingml/diagram",
      type_local: "CT_StyleDefinition",
      host: "pptx:diagram-style",
      phase: "diagram",
    },
    {
      name: "colorsDef",
      type_ns_tail: "drawingml/diagram",
      type_local: "CT_ColorTransform",
      host: "pptx:diagram-colors",
      phase: "diagram",
    },
    {
      name: "userShapes",
      type_ns_tail: "drawingml/chartDrawing",
      type_local: "CT_Drawing",
      host: "pptx:chart-usershapes",
      phase: "chartDrawing",
    },
  ]
}

///|
fn catalog_type_namespace_tail(type_name : String) -> String {
  match type_name.find("#") {
    None => ""
    Some(i) => strip_ns(type_name[0:i].to_owned())
  }
}

///|
fn catalog_type_local(type_name : String) -> String {
  match type_name.rev_find("#") {
    Some(i) => type_name[i + 1:].to_owned()
    None => type_name
  }
}

///|
fn catalog_part_root_matches(
  root : CatalogPartRoot,
  name : String,
  type_name : String,
) -> Bool {
  name == root.name &&
  catalog_type_namespace_tail(type_name) == root.type_ns_tail &&
  catalog_type_local(type_name) == root.type_local
}

///|
fn catalog_part_root_for_decl(
  name : String,
  type_name : String,
) -> CatalogPartRoot? {
  for root in catalog_part_roots() {
    if catalog_part_root_matches(root, name, type_name) {
      return Some(root)
    }
  }
  None
}

///|
fn catalog_part_root_phase_for_decl(
  name : String,
  type_name : String,
) -> String? {
  match catalog_part_root_for_decl(name, type_name) {
    Some(root) => Some(root.phase)
    None => None
  }
}

///|
fn catalog_host_for_root_type(
  root_name : String,
  root_type : String,
  fallback_format : String,
) -> String {
  match catalog_part_root_for_decl(root_name, root_type) {
    Some(root) => root.host
    None => catalog_host_for_root(root_name, fallback_format)
  }
}

///|
/// Name-only compatibility wrapper. Main catalog embedding should use
/// `catalog_host_for_root_type` so ambiguous names (`comments`,
/// `fonts`) stay type-qualified.
fn catalog_host_for_root(
  root_name : String,
  fallback_format : String,
) -> String {
  let mut matched : String? = None
  for root in catalog_part_roots() {
    if root.name == root_name {
      match matched {
        None => matched = Some(root.host)
        Some(existing) =>
          if existing != root.host {
            return if fallback_format != "" { fallback_format } else { "docx" }
          }
      }
    }
  }
  match matched {
    Some(host) => host
    None => if fallback_format != "" { fallback_format } else { "docx" }
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
    ns[trans.length():].to_owned()
  } else if ns.has_prefix(strict) {
    ns[strict.length():].to_owned()
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
  let schema = load_catalog_schema()
  println(
    "loaded: \{schema.complex_types.length()} complexTypes, " +
    "\{schema.simple_types.length()} simpleTypes, " +
    "\{schema.all_elements.length()} element declarations, " +
    "\{schema.groups.length()} groups",
  )

  // Containment ancestry — the wrapper chain from a part root down to
  // each element, used to embed host-less elements where the schema
  // actually permits them.
  let ancestry = build_ancestry(schema)
  if ancestry_id != "" {
    println("ancestry probe: \{ancestry_id}")
    println("  ancestry size: \{ancestry.length()}")
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
    for key, paths in ancestry {
      if nt_name(key) == ancestry_id {
        for i, path in paths {
          let names : Array[String] = []
          for step in path {
            names.push(step.0)
          }
          println("  [#\{i}] \{key} <- " + names.join(" / "))
        }
      }
    }
    return
  }

  // Count the distinct types each element name is declared with, so
  // a name with a single type gets a bare id and only genuine
  // name+type collisions are disambiguated with a `__type` suffix.
  let name_variants : Map[String, Int] = Map([], capacity=0)
  for _key, decl in schema.all_elements {
    name_variants[decl.name] = name_variants.get(decl.name).unwrap_or(0) + 1
  }

  // Synthesise one catalog entry per element declaration.
  let entries : Array[String] = []
  let cov_entries : Array[String] = []
  let mut count = 0
  // Tallies for the coverage summary.
  let outcomes : Map[String, Int] = Map([], capacity=0)
  // Glyph-level coverage audit: collect every element whose render
  // verdict is `parsed` (it left NO visible primitive in the SVG —
  // the data-stripped skeleton is unchanged by its presence) together
  // with its namespace / type, so the visual-but-unrendered cases can
  // be triaged out of the genuinely non-visual config / metadata
  // elements.  Written to /tmp/catalog-parsed.txt at the end.
  let parsed_elements : Array[String] = []
  // Round-trip *fidelity* tally — orthogonal to `outcomes`.  Where
  // `outcomes` measures open->save->open->render *no-crash* + render
  // trace, `fidelity` measures whether the element actually survived
  // the writer leg of open->save: its tag (and, when present, its
  // unique marker) is still in the saved part XML.  A `fy-drop`
  // entry is a lossy round-trip — the reader parsed the element but
  // the writer omitted it.
  let fidelity : Map[String, Int] = Map([], capacity=0)
  let lineage_tally : Map[String, Int] = Map([], capacity=0)
  let mut hosted = 0
  let mut hosted_ok = 0
  let mut hostless = 0
  let mut hostless_ok = 0
  // Element name -> true once any catalog entry for that name has
  // verified `rendered`; consumed by the spec-section render
  // coverage.
  let element_ok : Map[String, Bool] = Map([], capacity=0)
  // Element name -> true once any catalog entry for it opened and
  // round-tripped without crash (`rendered` OR `parsed`); consumed by
  // the spec-section round-trip coverage.
  let element_parsed : Map[String, Bool] = Map([], capacity=0)
  // Every element name the ECMA-376 XSD declares — lets the section
  // analysis discard prose tokens that are not real elements.
  let element_known : Map[String, Bool] = Map([], capacity=0)
  for _k, decl in schema.all_elements {
    element_known[decl.name] = true
  }
  for _key, decl in schema.all_elements {
    let prefix = ns_prefix(decl.ns)
    let fmt = ns_format(decl.ns)
    // Synthesise the element under test as an @xml.Element tree.
    // The element under test gets the rich synthesis budget so its
    // instance is visually non-degenerate (see RICH_BUDGET).
    // Include optional attributes for chart-namespace targets — the
    // chart sub-elements use `val`-style optional attributes whose
    // absence indistinguishably triggers a spec-default value
    // (gapWidth → 150, holeSize → 10, firstSliceAng → 0, …); without
    // the synthesised non-default value the per-element differential
    // verifier sees identical output with the target present or
    // pruned.  Other namespaces' synth-time pattern coverage isn't
    // strong enough to guarantee a parse-valid sample for every
    // simple-typed optional attribute (e.g. `ST_TextScale` requires a
    // `\d+%` pattern; sample_for_simple yields "x" which fails parse),
    // so the include-optional path stays scoped to chart.
    // Include optional attributes when synthesising the target so
    // its `val`-style configuration carries a non-default sample value
    // — without it the per-element differential verifier sees
    // identical SVG with the target present or pruned (the renderer
    // falls back to spec-defaults in both cases).  Now scoped to
    // every namespace; sample_for_simple's percentage-pattern fallback
    // (`<digits>%`) keeps WML's ST_TextScalePercent / SML's percentage
    // types parse-valid that would otherwise fail with the synth's
    // "x" string sample.
    let _ = strip_ns(decl.ns)
    let want_opt_attrs = true
    let target : @xml.Element = if decl.type_name == "__inline__" {
      match xsd_child(decl.node, "complexType") {
        Some(ict) => {
          let st : StrSet = Map([], capacity=0)
          synth_element(
            schema,
            ict,
            decl.ns,
            decl.name,
            st,
            0,
            RICH_BUDGET,
            include_optional_attrs=want_opt_attrs,
          )
        }
        None => elem(decl.ns, decl.name, [], [])
      }
    } else if decl.type_name == "__empty__" {
      elem(decl.ns, decl.name, [], [])
    } else {
      match schema.complex_types.get(decl.type_name) {
        Some(ct_el) => {
          let st : StrSet = Map([], capacity=0)
          st[decl.type_name] = true
          synth_element(
            schema,
            ct_el,
            decl.ns,
            decl.name,
            st,
            0,
            RICH_BUDGET,
            include_optional_attrs=want_opt_attrs,
          )
        }
        None =>
          // A simple-type-typed element carries its value as text.
          if schema.simple_types.get(decl.type_name) is Some(_) ||
            decl.type_name.has_prefix("http://www.w3.org/2001/XMLSchema#") {
            elem(decl.ns, decl.name, [], [
              Text(sample_for_simple(schema, decl.type_name, 0)),
            ])
          } else {
            elem(decl.ns, decl.name, [], [])
          }
      }
    }
    // The type display (local) name and a stable id.
    let type_local = match decl.type_name.rev_find("#") {
      Some(i) => decl.type_name[i + 1:].to_owned()
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
      json_str(decl.ns) +
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
    // also picks the host format.  Format strings carry the OPC
    // part kind when the root is an auxiliary part (e.g.
    // `docx:settings` builds a docx whose `<w:settings>` part
    // contains the embed tree; the document body stays minimal).
    // Every host_fmt registered here MUST be handled by
    // `host_package` in verify.mbt.
    //
    // Multi-path ancestry — `build_ancestry` returns an ordered list
    // of candidate wrapper chains per element.  `verify_entry` owns
    // the verdict strings; this loop only chooses the strongest
    // candidate already proved by that single verifier, so a later
    // schema-correct `parsed` route is not hidden by an earlier
    // `open-fail` route.
    let candidates : Array[(String, @xml.Element)] = []
    let akey = nt_key(decl.name, decl.type_name)
    // §21.2 — only chart-namespace elements (`<c:plotArea>`, `<c:ser>`,
    // …) want their `chartSpace`-rooted ancestry path; DML-core
    // elements (`<a:gd>`, `<a:srgbClr>`, …) the BFS reaches through
    // `chartSpace/spPr` should keep their original document/sld
    // canonical path so the renderer's shape pipeline credits them.
    let is_chart_ns = strip_ns(decl.ns) == "drawingml/chart"
    match ancestry.get(akey) {
      Some(paths) if paths.length() >= 1 =>
        for path in paths {
          if path.length() >= 1 {
            let host = catalog_host_for_root_type(path[0].0, path[0].1, fmt)
            // Skip chart-host candidates for non-chart-namespace
            // elements so DML core types do not get hosted in a chart
            // part where the renderer's shape dispatch never reaches
            // them.
            if !is_chart_ns && path[0].0 == "chartSpace" {
              continue
            }
            // For most hosts, the first ancestry step is `document` /
            // `worksheet` / `sld` and the host package already wraps
            // the content in that root, so we start wrapping at depth
            // 1 (skip the implicit root step).  For `chartSpace`, the
            // four diagram part roots, and `userShapes`, the host
            // writes `content` AS the part's root element so the
            // root wrap must survive — start at depth 0.
            let start = match path[0].0 {
              "chartSpace"
              | "dataModel"
              | "layoutDef"
              | "styleDef"
              | "colorsDef"
              | "userShapes" => 0
              _ => 1
            }
            candidates.push(
              (host, wrap_in_ancestry(schema, path, start, target)),
            )
          } else {
            // Empty path — the element IS itself a part-root; embed
            // unwrapped.  Route diagram / chart part roots to their
            // dedicated host so the renderer is actually invoked.
            let root_host = catalog_host_for_root_type(
              decl.name,
              decl.type_name,
              fmt,
            )
            candidates.push((root_host, target))
          }
        }
      _ => candidates.push((if fmt != "" { fmt } else { "docx" }, target))
    }
    if candidates.length() == 0 {
      candidates.push((if fmt != "" { fmt } else { "docx" }, target))
    }
    // Round-trip + render verification with a unique marker token.
    let marker = "CATm\{count}m"
    let mut host_fmt = candidates[0].0
    let mut embed_tree = candidates[0].1
    let mut outcome = ""
    for i, cand in candidates {
      let (cfmt, ctree) = cand
      let o = verify_entry(cfmt, ctree, marker)
      if i == 0 {
        host_fmt = cfmt
        embed_tree = ctree
        outcome = o
      }
      if i > 0 && verification_outcome_is_stronger(o, outcome) {
        host_fmt = cfmt
        embed_tree = ctree
        outcome = o
      }
      if outcome == "rendered" {
        break
      }
    }
    if debug_id != "" && ident == debug_id {
      // Per-namespace dump suffix so multiple entries sharing the
      // same ident (e.g. `shape` lives in chart / diagram / VML
      // namespaces) do not overwrite each other's pkg / SVG when
      // the debug probe runs the catalog with a single id filter.
      let suffix = ns_prefix(decl.ns)
      println("debug id=\{ident} element=\{decl.name} fmt=\{fmt}")
      println("  type key    : \{decl.type_name}")
      println("  host format : \{host_fmt}")
      println("  fragment    : \{fragment}")
      println("  outcome     : \{outcome}")
      let (subst, _h) = substitute_marker(embed_tree, marker)
      let pkg = host_package(host_fmt, subst)
      let bin_path = "/tmp/dbg-\{suffix}.bin"
      let svg_p_path = "/tmp/dbg-\{suffix}-present.svg"
      let svg_a_path = "/tmp/dbg-\{suffix}-absent.svg"
      let _ = try? @fs.write_bytes_to_file(bin_path, pkg)
      println("  pkg -> \{bin_path} (\{pkg.length()}b)")
      let (psvg, asvg) = debug_render_pair(host_fmt, embed_tree)
      println("  present SVG : \{psvg.length()}b")
      println("  absent  SVG : \{asvg.length()}b")
      println("  SVG differ  : \{psvg != asvg}")
      let _ = try? @fs.write_string_to_file(svg_p_path, psvg)
      let _ = try? @fs.write_string_to_file(svg_a_path, asvg)
    }
    // Surface every non-clean outcome with its entry id so a
    // regression can be located without a separate probe run.
    if outcome != "rendered" && outcome != "parsed" {
      println(
        "    [\{outcome}] \{ident}  (element=\{decl.name}, type=\{decl.type_name}, host=\{host_fmt})",
      )
    }
    outcomes[outcome] = outcomes.get(outcome).unwrap_or(0) + 1
    if outcome == "parsed" {
      parsed_elements.push(
        ns_prefix(decl.ns) +
        ":" +
        decl.name +
        "\t" +
        decl.type_name +
        "\thost=" +
        host_fmt,
      )
    }
    // Round-trip fidelity (non-visual): re-run the canonical embed
    // through open->save and inspect the saved XML for the element's
    // survival.  Only meaningful when the package opens at all, so
    // `open-fail` entries are recorded as `fy-open-fail` without a
    // second probe.
    let fy = if outcome == "open-fail" {
      "fy-open-fail"
    } else {
      roundtrip_fidelity(host_fmt, embed_tree, marker)
    }
    fidelity[fy] = fidelity.get(fy).unwrap_or(0) + 1
    // Surface a genuine writer drop with its id — the reader accepted
    // the element but the writer did not re-emit it (lossy round-trip,
    // an ECMA-376 conformance defect worth fixing).  Also surface the
    // ambiguous cases: the tag is in the saved XML but cannot be
    // attributed to the target (host scaffolding emits the same name),
    // so the probe cannot confirm survival — worth eyeballing.
    if fy == "fy-drop" {
      println(
        "    [fy-drop] \{ident}  (element=\{decl.name}, type=\{decl.type_name}, host=\{host_fmt})",
      )
    } else if fy == "fy-ambiguous" {
      println(
        "    [fy-ambig] \{ident}  (element=\{decl.name}, type=\{decl.type_name}, host=\{host_fmt})",
      )
    }
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
  try
    @fs.write_string_to_file(".snapshots/catalog.json", out.to_string())
  catch {
    _ => println("!! failed to write catalog.json")
  } noraise {
    _ => println("catalog: \{count} element entries -> .snapshots/catalog.json")
  }

  // Write coverage.json — the round-trip + render outcome per entry.
  let cov = StringBuilder::new()
  cov.write_string("{\"total\":\{count},\"counts\":{")
  let mut first = true
  for k, v in outcomes {
    if !first {
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
  try
    @fs.write_string_to_file(".snapshots/coverage.json", cov.to_string())
  catch {
    _ => println("!! failed to write coverage.json")
  } noraise {
    _ => ()
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
    "    complex types                   : \{schema.complex_types.length()}",
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
  // L2b — round-trip *fidelity*.  The L2 no-crash leg cannot detect a
  // writer that silently drops an element it parsed (the package
  // re-opens fine without it).  This leg opens, saves, and inspects
  // the *saved* XML: the element's tag (and unique marker when it
  // carries one) must still be present.  `fy-drop` is a lossy
  // round-trip — a genuine ECMA-376 conformance defect.
  let fy_marker = fidelity.get("fy-marker").unwrap_or(0)
  let fy_inject = fidelity.get("fy-inject").unwrap_or(0)
  let fy_tag = fidelity.get("fy-tag").unwrap_or(0)
  let fy_drop = fidelity.get("fy-drop").unwrap_or(0)
  let fy_ambiguous = fidelity.get("fy-ambiguous").unwrap_or(0)
  let fy_openfail = fidelity.get("fy-open-fail").unwrap_or(0)
  // Proven survival = marker survived (natural OR planted into a
  // structural target) OR a differential tag-count drop attributable
  // to the target.  `fy-ambiguous` is deliberately NOT counted as
  // proven: the tag is present but indistinguishable from host
  // scaffolding, so attributing survival to the target would overclaim.
  let fy_proven = fy_marker + fy_inject + fy_tag
  let fy_probed = fy_proven + fy_drop + fy_ambiguous
  println("L2b round-trip fidelity  (open -> save: does the saved part")
  println("    XML still contain the element?  differential, non-visual)")
  println("    marker survived (content round-tripped)  : \{fy_marker}")
  println("    planted marker survived (structural)     : \{fy_inject}")
  println("    tag count dropped when pruned (survived) : \{fy_tag}")
  println("    DROPPED by writer (lossy round-trip)     : \{fy_drop}")
  println("    ambiguous (tag also in scaffolding)      : \{fy_ambiguous}")
  println("    open/save could not complete             : \{fy_openfail}")
  let fpct = pct10(fy_proven, fy_probed)
  println("")
  println(
    "    target provably survived open -> save : \{fy_proven}/\{fy_probed} " +
    "(\{fpct / 10}.\{fpct % 10}%, of probed; open-fail excluded)",
  )
  println("    NOTE on what this proves: every part writer re-emits the")
  println("    reader's *preserved source element* verbatim (the read")
  println("    model keeps the raw `.element`; `write_*` serialises it).")
  println("    So this leg confirms the raw-preservation round-trip +")
  println("    OPC re-packaging are lossless — a `fy-drop` would mean a")
  println("    packaging/serialisation regression.  It does NOT exercise")
  println("    a typed re-serialisation (there is none); structural")
  println("    *understanding* lives in the typed projection, measured")
  println("    by the L3 render axis, not here.")
  println("    Structural / attribute-only targets carry no text")
  println("    marker, so a unique marker is PLANTED inside the element")
  println("    under test and a second save confirms it survives")
  println("    (`fy-inject`) — proving survival even when the tag")
  println("    collides with host scaffolding.  The plant is")
  println("    non-destructive: if a host de-dups a required singleton")
  println("    it retries through the singleton's spec-defined `extLst`")
  println("    slot, then falls back to the differential rather than")
  println("    overclaim.")
  println("    (ambiguous = tag present but also emitted by host")
  println("     scaffolding AND a planted marker did not survive a host")
  println("     de-dup or an `extLst` retry — not counted as preserved)")
  println("")

  // Glyph-level coverage audit dump — every `parsed` (no visible
  // primitive) element, for triaging visual-but-unrendered gaps.
  {
    let sb = StringBuilder::new()
    for line in parsed_elements {
      sb.write_string(line)
      sb.write_char('\n')
    }
    let _ = try? @fs.write_string_to_file(
      "/tmp/catalog-parsed.txt",
      sb.to_string(),
    )
    println(
      "    (\{parsed_elements.length()} `parsed` elements written to /tmp/catalog-parsed.txt for glyph-level triage)",
    )
  }

  // L2c — OPC structural validity of the round-tripped package.  A
  // necessary condition for a conforming consumer (incl. Microsoft
  // Office) to open the file: content types resolve, XML parts are
  // well-formed, every Internal relationship target exists, and a
  // root office-document relationship is present.  Self-contained —
  // no external validator required.
  println("L2c OPC structural validity  (open -> save -> reopen ->")
  println("    validate §6/§7/§11 invariants; necessary condition for")
  println("    Microsoft Office to open the package)")
  for fmt in ["xlsx", "pptx", "docx"] {
    let violations = structural_validity(fmt)
    if violations.length() == 0 {
      println("    \{fmt}: VALID (0 structural violations)")
    } else {
      println("    \{fmt}: \{violations.length()} violation(s):")
      for v in violations {
        println("      - \{v}")
      }
    }
  }
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
