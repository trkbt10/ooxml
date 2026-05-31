// Transparent typealiases so the moved chart_render*.mbt files keep
// their bare `ColorResolveContext` / `SvgDefsCollector` /
// `ResolvedColor` type references without churn.  The SOT for these
// types lives in `drawing_ml/paint`.

///|
using @paint {type ColorResolveContext as ColorResolveContext}

///|
using @paint {type ResolvedColor as ResolvedColor}

///|
using @paint {type SvgDefsCollector as SvgDefsCollector}
