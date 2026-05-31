// Transparent typealiases re-exporting the SOT moved to
// `drawing_ml/paint`.  The painter package owns the rendering-time
// helpers (§20.1.2 color reference resolution, §20.1.6 theme color
// scheme, §20.1.4.1.6 placeholder color substitution, SVG `<defs>`
// accumulator); this file keeps the PML viewer's existing call sites
// — `ColorResolveContext::empty()`, `SvgDefsCollector::new()`, etc.
// — compiling without churn until each call site is explicitly
// requalified with the `@paint.` prefix.

///|
using @paint {type ColorResolveContext as ColorResolveContext}

///|
using @paint {type ResolvedColor as ResolvedColor}

///|
using @paint {type ColorScheme as ColorScheme}

///|
using @paint {type ColorMap as ColorMap}

///|
using @paint {type SvgDefsCollector as SvgDefsCollector}
