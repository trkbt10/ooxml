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
/// Process-wide font cache. Each `(family, weight, italic)` triple
/// is resolved through the `FontResolver` exactly once; subsequent
/// requests return the cached `FontMeasurer`.
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
      let base = match make_font_measurer_at(
          resource.bytes, resource.ttc_index,
        ) {
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
/// Cache key composed from the request. Uses the lowercase-normalised
/// primary family name (or `"__embedded__"` when embedded bytes are
/// supplied) plus weight + italic. The candidate stack tail is
/// ignored because resolution returns the first success and any
/// fallback would have produced a different primary name.
fn cache_key_for(request : FontFaceRequest) -> String {
  let primary = match request.embedded_bytes {
    Some(_) => "__embedded__"
    None => {
      let first_name : Ref[String?] = { val: None }
      for c in request.stack {
        match c {
          Name(n) =>
            if first_name.val is None {
              first_name.val = Some(normalize_family(n))
            }
          Generic(_) => ()
        }
      }
      first_name.val.unwrap_or("(none)")
    }
  }
  let w = if request.weight >= 600 { 700 } else { 400 }
  let i = if request.italic { "i" } else { "u" }
  primary + "|" + w.to_string() + "|" + i
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
