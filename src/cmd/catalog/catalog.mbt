// ECMA-376 schema catalog builder.
//
// Parses every XSD across the Strict (Part 1), Transitional
// (Part 4) and OPC (Part 2) schema sets, enumerates the COMPLETE set
// of element declarations, and synthesises a minimal schema-valid
// XML instance fragment for each.  The catalog (.snapshots/catalog.
// json) is generated mechanically from the schema — not curated.
//
// This is a MoonBit tool in the same workspace as the library it
// supports; it reads the XSD files with this project's own `@xml`
// parser.

///|
/// The XML Schema namespace.
const XSD_NS : String = "http://www.w3.org/2001/XMLSchema"

///|
/// One ECMA-376 schema set: a lineage tag plus the directory holding
/// its `.xsd` files.
struct SchemaSet {
  lineage : String
  dir : String
}

///|
/// The three schema sets that together make up ECMA-376.  Transitional
/// is listed first so that, for an element present in both
/// generations, the catalog entry keeps the Transitional namespace —
/// the URI real-world Office documents use.
fn schema_sets() -> Array[SchemaSet] {
  [
    {
      lineage: "transitional",
      dir: "references/raw/ecma376-4/OfficeOpenXML-XMLSchema-Transitional",
    },
    {
      lineage: "strict",
      dir: "references/raw/ecma376-1/OfficeOpenXML-XMLSchema-Strict",
    },
    {
      lineage: "opc",
      dir: "references/raw/ecma376-2/OpenPackagingConventions-XMLSchema",
    },
  ]
}

///|
/// Load every ECMA-376 schema set into the catalog symbol table.
fn load_catalog_schema() -> Schema {
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
              try @xml.parse(@utf8.encode(text[:])) catch {
                _ => println("!! parse error: " + path)
              } noraise {
                doc => schema.load(doc.root, text, set.lineage)
              }
            }
          }
        }
    }
  }
  schema
}

///|
/// Strip an XSD `prefix:Local` reference down to `Local`.
fn local_name(qname : String) -> String {
  match qname.rev_find(":") {
    Some(i) => qname[i + 1:].to_owned()
    None => qname
  }
}

///|
/// True when `el` is an XSD element with the given local name.
fn is_xsd(el : @xml.Element, name : String) -> Bool {
  el.name.local_name == name &&
  (match el.name.ns {
    Some(ns) => ns == XSD_NS
    None => true
  })
}

///|
/// Direct child elements of `el` whose local name is `name`.
fn xsd_children(el : @xml.Element, name : String) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  for child in el.children {
    match child {
      Element(c) => if is_xsd(c, name) { out.push(c) }
      _ => ()
    }
  }
  out
}

///|
/// First direct child element of `el` with local name `name`.
fn xsd_child(el : @xml.Element, name : String) -> @xml.Element? {
  for child in el.children {
    match child {
      Element(c) => if is_xsd(c, name) { return Some(c) }
      _ => ()
    }
  }
  None
}

///|
/// Attribute value by local name, or None.
fn attr(el : @xml.Element, name : String) -> String? {
  for a in el.attributes {
    if a.name.local_name == name {
      return Some(a.value)
    }
  }
  None
}

///|
/// Every descendant element of `el` with local name `name`
/// (depth-first, including `el` itself when it matches).
fn xsd_descendants(el : @xml.Element, name : String) -> Array[@xml.Element] {
  let out : Array[@xml.Element] = []
  fn walk(e : @xml.Element) -> Unit {
    if is_xsd(e, name) {
      out.push(e)
    }
    for child in e.children {
      match child {
        Element(c) => walk(c)
        _ => ()
      }
    }
  }
  walk(el)
  out
}
