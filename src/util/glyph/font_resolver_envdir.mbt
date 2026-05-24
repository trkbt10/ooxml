// Directory-scanning FontResolver driver.
//
// The driver scans one or more directories for `.ttf` / `.ttc`
// files, decodes each filename into a `(family, weight, italic)`
// triple, and answers requests by exact-match lookup against that
// index. Directories come from the `OOXML_FONT_DIR` env var
// (colon-separated, like every other POSIX path list).
//
// Filename convention (Google Fonts / generic redistributor style):
//
//   NotoSans-Regular.ttf           → ("noto sans", 400, false)
//   NotoSans-Bold.ttf              → ("noto sans", 700, false)
//   NotoSans-Italic.ttf            → ("noto sans", 400, true)
//   NotoSans-BoldItalic.ttf        → ("noto sans", 700, true)
//   NotoSerif-Regular.ttf          → ("noto serif", 400, false)
//
// The family name is decoded by inserting a space before each
// uppercase letter (`NotoSerif` → `noto serif`); the style suffix
// after the final `-` chooses weight + italic.

///|
/// Environment variable that names the colon-separated directory
/// list to scan. The driver returns no resources when the variable
/// is unset or every listed directory is missing / empty.
pub let env_font_dir_var : String = "OOXML_FONT_DIR"

///|
/// Build the EnvDir driver from the current process's
/// `OOXML_FONT_DIR`. Always returns a resolver; the resolver
/// raises `FontUnresolvedError` for every request when no directory
/// was indexed, so the composite chain naturally falls through.
pub fn FontResolver::env_dir() -> FontResolver {
  let raw = @env.get_env_var(env_font_dir_var)
  let dir_opt : String? = match raw {
    None => None
    Some(s) =>
      if s.trim(chars=" \t\r\n").length() == 0 {
        None
      } else {
        Some(s)
      }
  }
  let dirs : Array[String] = match dir_opt {
    Some(d) => split_path_list(d)
    None => []
  }
  let catalog : Map[String, String] = Map([], capacity=16)
  for dir in dirs {
    populate_envdir_catalog(catalog, dir)
  }
  let label = match dir_opt {
    Some(d) => "envdir(" + d + ")"
    None => "envdir(unset)"
  }
  {
    label,
    resolve: fn(request) {
      match request.embedded_bytes {
        Some(b) =>
          return { bytes: b, ttc_index: None, source_label: "embedded" }
        None => ()
      }
      if catalog.is_empty() {
        raise FontUnresolvedError(request~, driver_labels=[label])
      }
      for candidate in request.stack {
        match candidate {
          Name(n) => {
            let key = catalog_key_for(n, request.weight, request.italic)
            match catalog.get(key) {
              Some(path) =>
                match try_read_resource(path) {
                  Some(res) => return res
                  None => continue
                }
              None => continue
            }
          }
          Generic(_) => continue
        }
      }
      raise FontUnresolvedError(request~, driver_labels=[label])
    },
  }
}

///|
/// Split a colon-separated path list. Empty fragments are dropped
/// rather than treated as `.` — a font catalogue indexing the
/// current directory by accident would be surprising.
fn split_path_list(raw : String) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder::new()
  for c in raw {
    if c == ':' {
      let part = buf.to_string().trim(chars=" \t\r\n").to_string()
      if part.length() > 0 {
        out.push(part)
      }
      buf.reset()
    } else {
      buf.write_char(c)
    }
  }
  let tail = buf.to_string().trim(chars=" \t\r\n").to_string()
  if tail.length() > 0 {
    out.push(tail)
  }
  out
}

///|
/// Scan `dir` (non-recursively) and index every `.ttf` / `.ttc`
/// file by `(family|weight|italic)`. Silently skips missing
/// directories.
fn populate_envdir_catalog(
  catalog : Map[String, String],
  dir : String,
) -> Unit {
  match (try? @fs.read_dir(dir)) {
    Err(_) => return
    Ok(entries) =>
      for name in entries {
        let full = @path.join([dir, name]) catch { _ => continue }
        let is_file = (try? @fs.is_file(full)).unwrap_or(false)
        if not(is_file) {
          continue
        }
        let lower = lowercase_ascii(name)
        if not(
            ends_with_lower(lower, ".ttf") || ends_with_lower(lower, ".ttc"),
          ) {
          continue
        }
        let (family, weight, italic) = parse_envdir_filename(name)
        if family.length() == 0 {
          continue
        }
        let key = catalog_key_for(family, weight, italic)
        catalog[key] = full
      }
  }
}

///|
/// Decode a font filename into `(family, weight, italic)`.
/// Splits on the last `-` before the extension; the prefix becomes
/// the de-CamelCased family name, the suffix selects weight/italic.
fn parse_envdir_filename(name : String) -> (String, Int, Bool) {
  let stem = strip_known_suffix(name)
  let dash_chars : Array[Char] = []
  for c in stem {
    dash_chars.push(c)
  }
  let last_dash = find_last_char(dash_chars, '-')
  if last_dash < 0 {
    return (family_decamel(stem), 400, false)
  }
  let family_part = substring_chars(dash_chars, 0, last_dash)
  let style_part = lowercase_ascii(
    substring_chars(dash_chars, last_dash + 1, dash_chars.length()),
  )
  let (weight, italic) = match style_part {
    "regular" => (400, false)
    "bold" => (700, false)
    "italic" => (400, true)
    "bolditalic" => (700, true)
    "light" => (300, false)
    "medium" => (500, false)
    "semibold" => (600, false)
    "black" => (900, false)
    _ => (400, false)
  }
  (family_decamel(family_part), weight, italic)
}

///|
fn strip_known_suffix(name : String) -> String {
  let lower = lowercase_ascii(name)
  if ends_with_lower(lower, ".ttf") || ends_with_lower(lower, ".ttc") {
    return name.substring(start=0, end=name.length() - 4).to_string()
  }
  name
}

///|
/// Insert a space before each uppercase letter (except the very
/// first) and lowercase the result. Yields `"noto sans"` from
/// `"NotoSans"` and `"liberation serif"` from `"LiberationSerif"`.
fn family_decamel(s : String) -> String {
  let chars : Array[Char] = []
  for c in s {
    chars.push(c)
  }
  let buf = StringBuilder::new()
  for i in 0..<chars.length() {
    let c = chars[i]
    if i > 0 && c >= 'A' && c <= 'Z' {
      buf.write_char(' ')
    }
    if c >= 'A' && c <= 'Z' {
      buf.write_char((c.to_int() + 32).unsafe_to_char())
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// Cache key for the catalogue. Normalises the family name (lowercase
/// + collapsed whitespace) and clamps the weight into the regular
/// (≤599) / bold (≥600) buckets.
fn catalog_key_for(family : String, weight : Int, italic : Bool) -> String {
  let normalized = normalize_family(family)
  let w = if weight >= 600 { 700 } else { 400 }
  normalized +
  "|" +
  w.to_string() +
  "|" +
  (if italic { "true" } else { "false" })
}

///|
/// True when `lower` ends with `suffix` (both already lowercased).
fn ends_with_lower(lower : String, suffix : String) -> Bool {
  let chars : Array[Char] = []
  for c in lower {
    chars.push(c)
  }
  let suf : Array[Char] = []
  for c in suffix {
    suf.push(c)
  }
  if chars.length() < suf.length() {
    return false
  }
  let start = chars.length() - suf.length()
  for i in 0..<suf.length() {
    if chars[start + i] != suf[i] {
      return false
    }
  }
  true
}

///|
fn find_last_char(chars : Array[Char], target : Char) -> Int {
  let mut i = chars.length() - 1
  while i >= 0 {
    if chars[i] == target {
      return i
    }
    i = i - 1
  }
  -1
}

///|
fn substring_chars(chars : Array[Char], start : Int, end : Int) -> String {
  let buf = StringBuilder::new()
  for i in start..<end {
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
/// Read `path` into a `FontResource`. Detects TTC by extension and
/// sets `ttc_index=Some(0)` (the first face in the collection — a
/// future enhancement can use the request's italic / weight to
/// pick a different index by scanning the TTC's `name` table).
fn try_read_resource(path : String) -> FontResource? {
  match (try? @fs.read_file_to_bytes(path)) {
    Err(_) => None
    Ok(bytes) => {
      let ttc_index = if ends_with_lower(lowercase_ascii(path), ".ttc") {
        Some(0)
      } else {
        None
      }
      Some({ bytes, ttc_index, source_label: path })
    }
  }
}
