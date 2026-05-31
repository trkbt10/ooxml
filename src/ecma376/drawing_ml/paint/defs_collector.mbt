// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-utils.ts
//
// SVG `<defs>` accumulator used during slide rendering.  Mirrors
// `SvgDefsCollector` in `slide-utils.ts:21`.  A single instance is
// passed down the shape-rendering tree; shapes that need a gradient,
// pattern, clipPath, or marker call `add_def` and reference the
// returned ID via `url(#...)`.

///|
/// Mutable collector for SVG `<defs>` children.  Each element of
/// `defs` is a structured `@xml.Node` (an SVG element in the SVG
/// namespace); the tree is serialised once by `@xml.write` so no
/// `<defs>` payload is ever assembled by string concatenation.
/// `def_id_counter` produces stable, deterministic IDs.
pub struct SvgDefsCollector {
  defs : Array[@xml.Node]
  def_id_counter : Ref[Int]
}

///|
/// Construct an empty collector.  Mirrors `createDefsCollector` in
/// `slide-utils.ts:32`.
pub fn SvgDefsCollector::new() -> SvgDefsCollector {
  { defs: [], def_id_counter: { val: 0 } }
}

///|
/// Append a `<defs>` child node.  The caller supplies a structured
/// SVG element node; the collector never parses or concatenates
/// markup strings.
pub fn SvgDefsCollector::add_def(
  self : SvgDefsCollector,
  def : @xml.Node,
) -> Unit {
  self.defs.push(def)
}

///|
/// Generate a fresh ID with the given prefix.  Format mirrors the TS
/// implementation: `${prefix}-${counter}` (e.g. `shape-grad-0`).
pub fn SvgDefsCollector::next_id(
  self : SvgDefsCollector,
  prefix : String,
) -> String {
  let id = prefix + "-" + self.def_id_counter.val.to_string()
  self.def_id_counter.val = self.def_id_counter.val + 1
  id
}

///|
/// Return the collected definitions wrapped in a single `<defs>`
/// element node, or `None` when nothing was collected.  Mirrors
/// `toDefsElement` in `slide-utils.ts:43`.
pub fn SvgDefsCollector::to_defs_node(self : SvgDefsCollector) -> @xml.Node? {
  if self.defs.length() == 0 {
    return None
  }
  Some(@markup.elem_ns("defs", @markup.svg_ns, [], self.defs))
}

///|
/// Serialise the collected definitions to a single `<defs>...</defs>`
/// fragment string, or the empty string when nothing was collected.
/// The fragment is produced by serialising the structured `<defs>`
/// element node through `@markup.serialize_svg` (i.e. `@xml.write`);
/// no markup is ever assembled by string concatenation.  Used by the
/// package's white-box tests to introspect the accumulated defs.
pub fn SvgDefsCollector::to_defs_element(self : SvgDefsCollector) -> String {
  match self.to_defs_node() {
    Some(@xml.Node::Element(e)) => @markup.serialize_svg(e)
    _ => ""
  }
}
