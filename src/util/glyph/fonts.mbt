// @source web-pptx packages/@aurochs/glyph/src/metrics/fonts/index.ts
//
// Central registry of font metrics. Looks up `FontMetrics` by font
// family name with category-based fallback.

///|
/// Sans-serif fallback metrics (Arial, Helvetica, etc.).
/// Mirrors `SANS_SERIF_METRICS` in `fonts/index.ts:22`.
fn sans_serif_metrics() -> FontMetrics {
  let widths = default_char_widths()
  // Sans-serif-specific overrides
  widths['i'] = 0.22
  widths['l'] = 0.22
  widths['I'] = 0.28
  {
    latin_average: 0.52,
    cjk_average: 1.0,
    char_widths: widths,
    kerning: sans_serif_kerning(),
    ascender_ratio: None,
    width_scale: None,
    bold_width_scale: None,
  }
}

///|
/// Serif fallback metrics (Times New Roman, Georgia, etc.).
/// Mirrors `SERIF_METRICS` in `fonts/index.ts:37`.
fn serif_metrics() -> FontMetrics {
  let widths = default_char_widths()
  widths['i'] = 0.28
  widths['l'] = 0.28
  {
    latin_average: 0.5,
    cjk_average: 1.0,
    char_widths: widths,
    kerning: serif_kerning(),
    ascender_ratio: None,
    width_scale: None,
    bold_width_scale: None,
  }
}

///|
/// Monospace fallback metrics (Consolas, Courier, etc.).
/// All characters use a fixed average width — `charWidths` is empty
/// and kerning is disabled.  Mirrors `MONOSPACE_METRICS` in
/// `fonts/index.ts:51`.
fn monospace_metrics() -> FontMetrics {
  {
    latin_average: 0.6,
    cjk_average: 1.0,
    char_widths: Map::new(),
    kerning: Map::new(),
    ascender_ratio: None,
    width_scale: None,
    bold_width_scale: None,
  }
}

///|
/// CJK fallback metrics (MS Gothic, Yu Gothic, etc.).  Mirrors
/// `CJK_METRICS` in `fonts/index.ts:61`.
fn cjk_metrics() -> FontMetrics {
  {
    latin_average: 0.5,
    cjk_average: 1.0,
    char_widths: default_char_widths(),
    kerning: common_kerning_pairs(),
    ascender_ratio: None,
    width_scale: None,
    bold_width_scale: None,
  }
}

///|
/// Resolve `category` → fallback metrics.
fn metrics_for_category(category : FontCategory) -> FontMetrics {
  match category {
    SansSerif => sans_serif_metrics()
    Serif => serif_metrics()
    Monospace => monospace_metrics()
    CJK => cjk_metrics()
  }
}

///|
/// Font family → category map for fallback selection.  Mirrors
/// `FONT_CATEGORY_MAP` in `fonts/index.ts:101`.  Keys are
/// lower-cased; lookup must normalise the input first.
fn font_category_map() -> Map[String, FontCategory] {
  {
    // Sans-serif
    "arial": SansSerif,
    "helvetica": SansSerif,
    "segoe ui": SansSerif,
    "san francisco": SansSerif,
    "roboto": SansSerif,
    "open sans": SansSerif,
    "lato": SansSerif,
    "verdana": SansSerif,
    "tahoma": SansSerif,
    "trebuchet": SansSerif,
    "trebuchet ms": SansSerif,
    "century gothic": SansSerif,
    "gill sans": SansSerif,
    // Serif
    "times new roman": Serif,
    "times": Serif,
    "georgia": Serif,
    "garamond": Serif,
    "palatino": Serif,
    "book antiqua": Serif,
    "cambria": Serif,
    "century schoolbook": Serif,
    // Monospace
    "consolas": Monospace,
    "courier new": Monospace,
    "courier": Monospace,
    "monaco": Monospace,
    "menlo": Monospace,
    "lucida console": Monospace,
    "dejavu sans mono": Monospace,
    "source code pro": Monospace,
    // CJK
    "ms gothic": CJK,
    "ms-pgothic": CJK,
    "ms mincho": CJK,
    "yu gothic": CJK,
    "yu mincho": CJK,
    "meiryo": CJK,
    "hgmarugothicmpro": CJK,
    "hiragino kaku gothic": CJK,
    "hiragino mincho": CJK,
    "noto sans cjk": CJK,
    "noto serif cjk": CJK,
    "source han sans": CJK,
    "source han serif": CJK,
    "simsun": CJK,
    "simhei": CJK,
    "microsoft yahei": CJK,
    "malgun": CJK,
    "malgun gothic": CJK,
  }
}

///|
/// Font-specific metrics registry.  Mirrors `FONT_REGISTRY` in
/// `fonts/index.ts:91`.  Currently only Calibri has measured metrics
/// — additional fonts are added by registering them here.
fn font_registry() -> Map[String, FontMetrics] {
  { "calibri": calibri_metrics() }
}

///|
/// Normalise a font-family string for lookup: take the first family
/// (before any comma) and lowercase it, stripping surrounding quotes.
/// Mirrors `normalizeFontName` in `fonts/index.ts:165`.
///
/// §22.9.2.18 ST_String — typeface comparison is implementation-
/// defined.  Word / PowerPoint compare ASCII case-insensitively;
/// for non-ASCII typefaces (MS Pゴシック, 맑은 고딕) the consumer's
/// font matcher decides.  This helper uses ASCII-only `to_lower`
/// which is correct for the canonical web-pptx font table keys
/// (all-ASCII) but may miss matches for CJK font literal names.
/// Consumers needing exact non-ASCII matching should bypass the
/// lookup table and consult the typeface verbatim.
fn normalize_font_name(font_family : String) -> String {
  // Take the substring up to the first ',' (or the whole string when
  // none is present). The TS code uses `split(",")[0]`.
  let primary = match font_family.find(",") {
    Some(idx) => font_family.substring(start=0, end=idx)
    None => font_family
  }
  // Strip surrounding whitespace plus ASCII quote characters in a
  // small loop: there is no equivalent of `.replace(/["']/g, "")` in
  // the MoonBit String API beyond the trim charset.
  let buf = StringBuilder::new()
  for c in primary {
    if c != '"' && c != '\'' {
      buf.write_char(c)
    }
  }
  let cleaned = buf.to_string()
  cleaned.trim(chars=" \t\r\n").to_owned().to_lower()
}

///|
/// Get the FontCategory for a font family.  Returns `SansSerif`
/// when no match is found.  Mirrors `getFontCategory` in
/// `fonts/index.ts:173`.
pub fn get_font_category(font_family : String?) -> FontCategory {
  match font_family {
    None => SansSerif
    Some(ff) =>
      if ff == "" {
        SansSerif
      } else {
        let normalized = normalize_font_name(ff)
        let map = font_category_map()
        match map.get(normalized) {
          Some(c) => c
          None => {
            // Partial match — substring in either direction, as in
            // `fonts/index.ts:186`.
            for k, v in map {
              if normalized.contains(k) || k.contains(normalized) {
                return v
              }
            }
            SansSerif
          }
        }
      }
  }
}

///|
/// Get metrics for a font, falling back to category metrics when no
/// specific entry exists.  Mirrors `getFontMetrics` in
/// `fonts/index.ts:200`.
pub fn get_font_metrics(font_family : String?) -> FontMetrics {
  match font_family {
    Some(ff) => {
      let normalized = normalize_font_name(ff)
      match font_registry().get(normalized) {
        Some(m) => return m
        None => ()
      }
    }
    None => ()
  }
  metrics_for_category(get_font_category(font_family))
}

///|
/// True iff the font is a monospaced family.  Mirrors `isMonospace`
/// in `fonts/index.ts:218`.
pub fn is_monospace(font_family : String?) -> Bool {
  get_font_category(font_family) == Monospace
}
