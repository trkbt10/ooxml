// Process-wide `FontMeasurer` cache, fronted by a `FontResolver`.
//
// Every measurement entry point (in `measurer.mbt`) goes through
// `default_font_set()` → `FontSet::measurer_for_request`. The
// registry's only job is to (1) hand the request to the resolver,
// (2) parse the returned bytes into a `FontMeasurer`, (3) attach
// the GPOS pair-kerning map extracted from the same bytes, and
// (4) cache the result so a hot loop measures every glyph against
// the same parsed font.
//
// The registry does NOT know about substitution chains, family
// aliases, or per-format preferences. Anything ECMA-376 §17.8.3
// related lives in `font_substitution_chain.mbt` and is applied by
// the renderer BEFORE constructing a `FontFaceRequest`.

///|
/// Process-wide font cache. Each distinct `FontFaceRequest` chain is
/// resolved through the `FontResolver`; subsequent equivalent requests
/// return the cached `FontMeasurer`.
pub struct FontSet {
  cache : Map[String, FontMeasurer]
  resolver : FontResolver
}

///|
pub fn FontSet::new(resolver~ : FontResolver) -> FontSet {
  { cache: Map([], capacity=16), resolver }
}

///|
/// Resolve `request` to a `FontMeasurer`. Raises
/// `FontUnresolvedError` when no driver in the resolver chain can
/// satisfy the request — callers (typically the ECMA-376
/// substitution chain in `font_substitution_chain.mbt`) decide
/// whether to retry with another stack.
pub fn FontSet::measurer_for_request(
  self : FontSet,
  request : FontFaceRequest,
) -> FontMeasurer raise FontUnresolvedError {
  let key = cache_key_for(request)
  match self.cache.get(key) {
    Some(m) => m
    None => {
      let resource = (self.resolver.resolve)(request)
      let base = match
        make_font_measurer_at(resource.bytes, resource.ttc_index) {
        Some(m) => m
        None =>
          abort(
            "glyph::FontSet: resolver returned bytes for key '" +
            key +
            "' (source: " +
            resource.source_label +
            ") but they are not a recognised TrueType/OpenType font.",
          )
      }
      let pairs = extract_gpos_kern_pairs(resource.bytes)
      let m = base.with_gpos_kern(pairs)
      self.cache[key] = m
      m
    }
  }
}

///|
/// Cache key composed from the whole request. The ordered candidate
/// stack is part of the key because ECMA-376 substitution inputs
/// (`altName`, PANOSE-derived generic, typed `w:family` generic) can
/// differ while sharing the same primary face name. Embedded bytes are
/// keyed by a fingerprint of the payload so two documents that embed
/// different fonts under the same family name cannot share a parsed
/// `FontMeasurer`.
fn cache_key_for(request : FontFaceRequest) -> String {
  let w = if request.weight >= 600 { 700 } else { 400 }
  let i = if request.italic { "i" } else { "u" }
  let buf = StringBuilder::new()
  buf.write_string("w=")
  buf.write_string(w.to_string())
  buf.write_string("|i=")
  buf.write_string(i)
  buf.write_string("|stack=")
  if request.stack.length() == 0 {
    buf.write_string("(empty)")
  } else {
    for idx, candidate in request.stack {
      if idx > 0 {
        buf.write_string(",")
      }
      match candidate {
        Name(n) => {
          buf.write_string("n:")
          buf.write_string(normalize_family(n))
        }
        Generic(g) => {
          buf.write_string("g:")
          buf.write_string(generic_family_key(g))
        }
      }
    }
  }
  buf.write_string("|embedded=")
  match request.embedded_bytes {
    Some(bytes) => buf.write_string(font_bytes_fingerprint(bytes))
    None => buf.write_string("none")
  }
  buf.to_string()
}

///|
fn generic_family_key(generic : GenericFamily) -> String {
  match generic {
    Serif => "serif"
    SansSerif => "sans-serif"
    Monospace => "monospace"
    Cursive => "cursive"
    Fantasy => "fantasy"
    SystemUi => "system-ui"
    UiSerif => "ui-serif"
    UiSansSerif => "ui-sans-serif"
    UiMonospace => "ui-monospace"
    UiRounded => "ui-rounded"
    Math => "math"
    Emoji => "emoji"
    Fangsong => "fangsong"
  }
}

///|
fn font_bytes_fingerprint(bytes : Bytes) -> String {
  bytes.length().to_string() +
  ":" +
  crc32_forward(bytes).to_string() +
  ":" +
  crc32_reverse(bytes).to_string()
}

///|
fn crc32_forward(bytes : Bytes) -> Int64 {
  let mut crc = 0xffffffffL
  for byte in bytes {
    crc = crc32_update(crc, byte.to_int64())
  }
  (crc ^ 0xffffffffL) & 0xffffffffL
}

///|
fn crc32_reverse(bytes : Bytes) -> Int64 {
  let mut crc = 0xffffffffL
  let mut i = bytes.length() - 1
  while i >= 0 {
    crc = crc32_update(crc, bytes[i].to_int64())
    if i == 0 {
      break
    }
    i = i - 1
  }
  (crc ^ 0xffffffffL) & 0xffffffffL
}

///|
fn crc32_update(crc : Int64, byte : Int64) -> Int64 {
  let mut next = crc ^ byte
  for _ in 0..<8 {
    if (next & 1L) != 0L {
      next = (next >> 1) ^ 0xedb88320L
    } else {
      next = next >> 1
    }
  }
  next
}

///|
/// Process-wide font set, lazily initialised the first time
/// `default_font_set()` is called. Tests use `set_default_font_set`
/// to inject an `in_memory` (or any other) instance before any
/// measurement runs.
let global_font_set : Ref[FontSet?] = { val: None }

///|
pub fn default_font_set() -> FontSet {
  match global_font_set.val {
    Some(s) => s
    None => {
      let s = FontSet::new(resolver=create_host_font_resolver())
      global_font_set.val = Some(s)
      s
    }
  }
}

///|
pub fn set_default_font_set(set : FontSet) -> Unit {
  global_font_set.val = Some(set)
}
