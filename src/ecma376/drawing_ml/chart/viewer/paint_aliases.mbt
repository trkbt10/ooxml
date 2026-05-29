// Transparent typealiases so the moved chart_render*.mbt files keep
// their bare `ColorResolveContext` / `SvgDefsCollector` /
// `ResolvedColor` type references without churn.  The SOT for these
// types lives in `drawing_ml/paint`.

typealias @paint.ColorResolveContext as ColorResolveContext

typealias @paint.ResolvedColor as ResolvedColor

typealias @paint.SvgDefsCollector as SvgDefsCollector
