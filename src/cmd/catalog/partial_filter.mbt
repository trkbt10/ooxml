///|
/// Partial catalog validation filter loaded from environment variables.
///
/// Full catalog runs remain the default.  Any non-empty selector, positive
/// start offset, or explicit limit switches the CLI into partial-output mode
/// so short exploratory runs do not overwrite full-run snapshots.
priv struct CatalogPartialFilter {
  prefixes : Array[String]
  formats : Array[String]
  hosts : Array[String]
  elements : Array[String]
  types : Array[String]
  ids : Array[String]
  start : Int
  limit : Int?
}

///|
fn catalog_parse_filter_list(raw : String) -> Array[String] {
  let out : Array[String] = []
  for part in raw.split(",") {
    let value = part.trim(chars=" \t\r\n").to_owned()
    if value != "" {
      out.push(value)
    }
  }
  out
}

///|
fn catalog_env_filter_list(name : String) -> Array[String] {
  catalog_parse_filter_list(@env.get_env_var(name).unwrap_or(""))
}

///|
fn catalog_env_non_negative_int(name : String, default : Int) -> Int {
  let raw = @env.get_env_var(name)
    .unwrap_or("")
    .trim(chars=" \t\r\n")
    .to_owned()
  if raw == "" {
    return default
  }
  let parsed = (try? @string.parse_int(raw)).unwrap_or(default)
  if parsed < 0 {
    default
  } else {
    parsed
  }
}

///|
fn catalog_env_optional_non_negative_int(name : String) -> Int? {
  let raw = @env.get_env_var(name)
    .unwrap_or("")
    .trim(chars=" \t\r\n")
    .to_owned()
  if raw == "" {
    return None
  }
  let parsed = (try? @string.parse_int(raw)).unwrap_or(-1)
  if parsed < 0 {
    None
  } else {
    Some(parsed)
  }
}

///|
fn load_catalog_partial_filter() -> CatalogPartialFilter {
  {
    prefixes: catalog_env_filter_list("OOXML_CATALOG_PREFIX"),
    formats: catalog_env_filter_list("OOXML_CATALOG_FORMAT"),
    hosts: catalog_env_filter_list("OOXML_CATALOG_HOST"),
    elements: catalog_env_filter_list("OOXML_CATALOG_ELEMENT"),
    types: catalog_env_filter_list("OOXML_CATALOG_TYPE"),
    ids: catalog_env_filter_list("OOXML_CATALOG_ID"),
    start: catalog_env_non_negative_int("OOXML_CATALOG_START", 0),
    limit: catalog_env_optional_non_negative_int("OOXML_CATALOG_LIMIT"),
  }
}

///|
fn catalog_filter_active(filter : CatalogPartialFilter) -> Bool {
  filter.prefixes.length() > 0 ||
  filter.formats.length() > 0 ||
  filter.hosts.length() > 0 ||
  filter.elements.length() > 0 ||
  filter.types.length() > 0 ||
  filter.ids.length() > 0 ||
  filter.start > 0 ||
  filter.limit is Some(_)
}

///|
fn catalog_filter_values_match(values : Array[String], value : String) -> Bool {
  if values.length() == 0 {
    return true
  }
  for candidate in values {
    if candidate == value {
      return true
    }
  }
  false
}

///|
fn catalog_filter_type_match(
  values : Array[String],
  type_name : String,
  type_local : String,
) -> Bool {
  if values.length() == 0 {
    return true
  }
  for candidate in values {
    if candidate == type_local || candidate == type_name {
      return true
    }
  }
  false
}

///|
fn catalog_filter_host_value_match(
  filter_host : String,
  host_fmt : String,
) -> Bool {
  host_fmt == filter_host || host_fmt.has_prefix(filter_host)
}

///|
fn catalog_filter_hosts_match(
  values : Array[String],
  host_fmt : String,
) -> Bool {
  if values.length() == 0 {
    return true
  }
  for candidate in values {
    if catalog_filter_host_value_match(candidate, host_fmt) {
      return true
    }
  }
  false
}

///|
fn catalog_filter_candidates_match(
  filter : CatalogPartialFilter,
  candidates : Array[(String, @xml.Element)],
) -> Bool {
  if filter.hosts.length() == 0 {
    return true
  }
  for candidate in candidates {
    let (host_fmt, _) = candidate
    if catalog_filter_hosts_match(filter.hosts, host_fmt) {
      return true
    }
  }
  false
}

///|
fn catalog_filter_decl_match(
  filter : CatalogPartialFilter,
  prefix : String,
  format : String,
  decl : ElemDecl,
  type_local : String,
) -> Bool {
  catalog_filter_values_match(filter.prefixes, prefix) &&
  catalog_filter_values_match(filter.formats, format) &&
  catalog_filter_values_match(filter.elements, decl.name) &&
  catalog_filter_type_match(filter.types, decl.type_name, type_local)
}

///|
fn catalog_filter_id_match(
  filter : CatalogPartialFilter,
  ident : String,
) -> Bool {
  catalog_filter_values_match(filter.ids, ident)
}

///|
fn catalog_base_host_format(host_fmt : String) -> String {
  match host_fmt.find(":") {
    Some(i) => host_fmt[0:i].to_owned()
    None => host_fmt
  }
}

///|
fn catalog_structural_formats(
  partial_active : Bool,
  touched_formats : Map[String, Bool],
) -> Array[String] {
  let out : Array[String] = []
  for format in ["xlsx", "pptx", "docx"] {
    if !partial_active || touched_formats.get(format).unwrap_or(false) {
      out.push(format)
    }
  }
  out
}

///|
fn catalog_filter_summary(filter : CatalogPartialFilter) -> String {
  let parts : Array[String] = []
  if filter.prefixes.length() > 0 {
    parts.push("prefix=" + filter.prefixes.join(","))
  }
  if filter.formats.length() > 0 {
    parts.push("format=" + filter.formats.join(","))
  }
  if filter.hosts.length() > 0 {
    parts.push("host=" + filter.hosts.join(","))
  }
  if filter.elements.length() > 0 {
    parts.push("element=" + filter.elements.join(","))
  }
  if filter.types.length() > 0 {
    parts.push("type=" + filter.types.join(","))
  }
  if filter.ids.length() > 0 {
    parts.push("id=" + filter.ids.join(","))
  }
  if filter.start > 0 {
    parts.push("start=" + filter.start.to_string())
  }
  match filter.limit {
    Some(limit) => parts.push("limit=" + limit.to_string())
    None => ()
  }
  if parts.length() == 0 {
    "none"
  } else {
    parts.join("; ")
  }
}
