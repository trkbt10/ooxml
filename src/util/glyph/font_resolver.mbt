// FontResolver — the contract every font-source driver satisfies.
//
// The renderer hands the resolver a `FontFaceRequest` carrying:
//   - an ordered candidate stack (explicit family names and CSS
//     generic keywords),
//   - a numeric weight (100..900) and italic flag,
//   - optional embedded-font bytes (per ECMA-376 §17.8.2.4
//     <w:embedRegular>, §20.1.4.2.1 <a:embeddedFontLst>).
//
// The driver walks the stack in order. The first satisfied
// candidate yields a `FontResource` (TTF/TTC bytes plus optional
// TTC face index). When no candidate is satisfied the driver
// raises `FontUnresolvedError` — the caller (typically the
// ECMA-376 substitution chain in `font_substitution_chain.mbt`)
// decides whether to retry with another stack or surface the
// failure at the document boundary.
//
// Drivers MUST NOT silently substitute an unrelated face. Drivers
// MUST honour `embedded_bytes` ahead of the host catalogue — the
// document's own font wins by spec.

///|
/// CSS generic family keywords (CSS Fonts L4). The ECMA-376
/// `<w:family>` hint (`ST_FontFamily` §17.18.30) maps into this
/// vocabulary so a single stack representation handles both
/// CSS-style font stacks and OOXML's typed family classification:
///
///   ST_FontFamily        → GenericFamily
///   -----------------    -------------
///   FontFamilyRoman      Serif
///   FontFamilySwiss      SansSerif
///   FontFamilyModern     Monospace
///   FontFamilyScript     Cursive
///   FontFamilyDecorative Fantasy
///   FontFamilyAuto       (no hint — omitted from the stack)
pub(all) enum GenericFamily {
  Serif
  SansSerif
  Monospace
  Cursive
  Fantasy
  SystemUi
  UiSerif
  UiSansSerif
  UiMonospace
  UiRounded
  Math
  Emoji
  Fangsong
} derive(Eq, Hash, Debug)

///|
/// One entry in a font candidate stack. `Name` is an explicit family
/// request (the value of `<w:rFonts w:ascii="...">`, `<a:latin
/// typeface="...">`, etc.). `Generic` is a CSS keyword reached
/// through the ECMA-376 substitution chain when the explicit name
/// could not be resolved.
pub(all) enum FontStackCandidate {
  Name(String)
  Generic(GenericFamily)
} derive(Eq, Debug)

///|
/// Resolution request handed to a `FontResolver`.
///
/// `stack` is the ordered candidate list — typically the renderer
/// pushes the document's primary family first, then `altName`,
/// then the generic hint derived from `<w:family>` / `<w:panose1>`,
/// then a CSS-style fallback generic. Drivers walk the stack in
/// order; the first satisfiable candidate wins.
///
/// `embedded_bytes` lets the renderer pre-supply embedded-font
/// payload (WML §17.8.2.4, DML §20.1.4.2.1). When non-empty the
/// driver MUST honour it without consulting the host catalogue.
///
/// `weight` and `italic` select the cut. ≥ 600 selects bold.
pub(all) struct FontFaceRequest {
  stack : Array[FontStackCandidate]
  weight : Int
  italic : Bool
  embedded_bytes : Bytes?
} derive(Debug)

///|
/// Convenience constructor for the common "single name + weight +
/// italic" case used by callers that have not yet built the full
/// ECMA-376 chain. Renderer hot paths that DO supply embedded bytes
/// construct the struct literal directly.
pub fn FontFaceRequest::of_name(
  family : String,
  weight? : Int = 400,
  italic? : Bool = false,
) -> FontFaceRequest {
  { stack: [Name(family)], weight, italic, embedded_bytes: None }
}

///|
/// What a successful `FontResolver` returns.
///
/// `bytes` is the entire payload as read from disk / memory. For
/// TTC collections this is the *container* buffer; `ttc_index`
/// then selects which face inside the collection to use (Apple
/// system fonts and CJK Noto faces ship as TTC).
///
/// `source_label` is a human-readable identifier used for
/// diagnostics and as part of the measurer cache key. Drivers pick
/// whatever string makes their failure messages legible (file path,
/// URL, `"embedded:WML §17.8.2.4"`).
pub(all) struct FontResource {
  bytes : Bytes
  ttc_index : Int?
  source_label : String
}

///|
/// Raised when no driver in the resolver chain can satisfy a
/// request and no embedded bytes were supplied. ECMA-376 treats
/// this as a document-producer problem: the author should ship the
/// font via embeddedFont or specify a host-installed alternative
/// through `<w:altName>` / `<a:font typeface=...>` lists.
///
/// The error carries the request as supplied AND the labels of
/// every driver that was consulted, so the failure message names
/// the chain that was walked.
pub suberror FontUnresolvedError {
  FontUnresolvedError(
    request~ : FontFaceRequest,
    driver_labels~ : Array[String]
  )
} derive(Debug)

///|
/// Pure-function shape every driver exposes. A driver is a struct
/// with one function field — the MoonBit-idiomatic DI pattern that
/// avoids trait machinery and lets tests swap implementations by
/// value.
pub(all) struct FontResolver {
  resolve : (FontFaceRequest) -> FontResource raise FontUnresolvedError
  /// Stable label for diagnostics. Examples: `"host(MacOS)"`,
  /// `"envdir(/tmp/xxx)"`, `"in-memory"`.
  label : String
}

///|
/// Compose multiple drivers into one resolver that tries them in
/// order. When every driver raises, the composite raises with the
/// union of all driver labels so the failure message names every
/// place that was consulted.
pub fn FontResolver::compose(drivers : Array[FontResolver]) -> FontResolver {
  let label_buf = StringBuilder::new()
  label_buf.write_string("composite(")
  for i in 0..<drivers.length() {
    if i > 0 {
      label_buf.write_string(", ")
    }
    label_buf.write_string(drivers[i].label)
  }
  label_buf.write_string(")")
  {
    label: label_buf.to_string(),
    resolve: (request) => {
      let collected_labels : Array[String] = []
      for d in drivers {
        try (d.resolve)(request) catch {
          FontUnresolvedError(driver_labels=labels, ..) =>
            for l in labels {
              collected_labels.push(l)
            }
        } noraise {
          r => return r
        }
      }
      raise FontUnresolvedError(request~, driver_labels=collected_labels)
    },
  }
}

///|
/// In-memory resolver — faces are held as `(family-name → bytes)`
/// in a `Map`. Tests use this to drive a deterministic catalogue
/// without depending on the host filesystem.
///
/// Lookup: walks the request stack in order; for each `Name`
/// candidate, looks up the lowercase-normalised key. `Generic`
/// candidates are ignored — in-memory is for fixture parity, not
/// generic-family resolution.
pub fn FontResolver::in_memory(faces : Map[String, Bytes]) -> FontResolver {
  let normalized : Map[String, Bytes] = Map([], capacity=faces.length())
  for entry in faces {
    let (k, v) = entry
    normalized[normalize_family(k)] = v
  }
  {
    label: "in-memory",
    resolve: (request) => {
      match request.embedded_bytes {
        Some(b) =>
          return { bytes: b, ttc_index: None, source_label: "embedded" }
        None => ()
      }
      for candidate in request.stack {
        match candidate {
          Name(n) =>
            match normalized.get(normalize_family(n)) {
              Some(bytes) =>
                return {
                  bytes,
                  ttc_index: None,
                  source_label: "in-memory:" + n,
                }
              None => continue
            }
          Generic(_) => continue
        }
      }
      raise FontUnresolvedError(request~, driver_labels=["in-memory"])
    },
  }
}

///|
/// Tokenise a CSS-style comma-separated `font-family` value into
/// stack candidates. Quoted-name handling preserves embedded
/// commas; case-insensitive generic-keyword matching.
pub fn parse_font_stack(raw : String) -> Array[FontStackCandidate] {
  let out : Array[FontStackCandidate] = []
  let trimmed = raw.trim(chars=" \t\r\n")
  if trimmed.length() == 0 {
    return out
  }
  let tokens = split_outside_quotes(raw)
  for tok in tokens {
    let trimmed_tok = tok.trim(chars=" \t\r\n").to_owned()
    let stripped = strip_quotes(trimmed_tok)
    if stripped.length() == 0 {
      continue
    }
    let (was_quoted, _) = quote_state(trimmed_tok)
    if !(was_quoted) {
      match generic_from_keyword(stripped) {
        Some(g) => {
          out.push(Generic(g))
          continue
        }
        None => ()
      }
    }
    out.push(Name(stripped))
  }
  out
}

///|
fn split_outside_quotes(raw : String) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder::new()
  let quote : Ref[Char?] = { val: None }
  for c in raw {
    match quote.val {
      Some(q) => {
        buf.write_char(c)
        if c == q {
          quote.val = None
        }
      }
      None =>
        if c == '"' || c == '\'' {
          quote.val = Some(c)
          buf.write_char(c)
        } else if c == ',' {
          out.push(buf.to_string())
          buf.reset()
        } else {
          buf.write_char(c)
        }
    }
  }
  out.push(buf.to_string())
  out
}

///|
fn quote_state(value : String) -> (Bool, String) {
  let chars : Array[Char] = []
  for c in value {
    chars.push(c)
  }
  if chars.length() < 2 {
    return (false, value)
  }
  let first = chars[0]
  let last = chars[chars.length() - 1]
  if (first == '"' && last == '"') || (first == '\'' && last == '\'') {
    return (true, value[1:value.length() - 1].to_owned())
  }
  (false, value)
}

///|
fn strip_quotes(value : String) -> String {
  let (_, inner) = quote_state(value)
  inner
}

///|
fn generic_from_keyword(name : String) -> GenericFamily? {
  let lower = lowercase_ascii(name)
  match lower {
    "serif" => Some(Serif)
    "sans-serif" => Some(SansSerif)
    "monospace" => Some(Monospace)
    "cursive" => Some(Cursive)
    "fantasy" => Some(Fantasy)
    "system-ui" => Some(SystemUi)
    "ui-serif" => Some(UiSerif)
    "ui-sans-serif" => Some(UiSansSerif)
    "ui-monospace" => Some(UiMonospace)
    "ui-rounded" => Some(UiRounded)
    "math" => Some(Math)
    "emoji" => Some(Emoji)
    "fangsong" => Some(Fangsong)
    _ => None
  }
}

///|
/// Lowercase ASCII letters in `s`. Non-ASCII scalars pass through
/// unchanged. Used by family-name normalisation and generic-keyword
/// matching.
pub fn lowercase_ascii(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    if c >= 'A' && c <= 'Z' {
      buf.write_char((c.to_int() + 32).unsafe_to_char())
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
/// Normalise a family name for case-insensitive equality comparison.
/// Lower-cases, strips leading/trailing whitespace, and collapses
/// internal whitespace runs to a single space so `"Noto  Sans"` and
/// `"noto sans"` key the same way.
pub fn normalize_family(name : String) -> String {
  let lower = lowercase_ascii(name)
  let trimmed = lower.trim(chars=" \t\r\n").to_owned()
  let buf = StringBuilder::new()
  let prev_space : Ref[Bool] = { val: false }
  for c in trimmed {
    if c == ' ' || c == '\t' {
      if !(prev_space.val) {
        buf.write_char(' ')
        prev_space.val = true
      }
    } else {
      buf.write_char(c)
      prev_space.val = false
    }
  }
  buf.to_string()
}
