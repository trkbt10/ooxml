// Transparent typealiases re-exporting the SOT moved to
// `drawing_ml/paint`.  The painter package owns the rendering-time
// helpers (§20.1.2 color reference resolution, §20.1.6 theme color
// scheme, §20.1.4.1.6 placeholder color substitution, SVG `<defs>`
// accumulator); this file keeps the PML viewer's existing call sites
// — `ColorResolveContext::empty()`, `SvgDefsCollector::new()`, etc.
// — compiling without churn until each call site is explicitly
// requalified with the `@paint.` prefix.

typealias @paint.ColorResolveContext as ColorResolveContext

typealias @paint.ResolvedColor as ResolvedColor

typealias @paint.ColorScheme as ColorScheme

typealias @paint.ColorMap as ColorMap

typealias @paint.SvgDefsCollector as SvgDefsCollector
