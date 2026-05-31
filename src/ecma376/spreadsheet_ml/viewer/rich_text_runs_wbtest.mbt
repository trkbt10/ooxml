// §18.4.7 / §18.4.12 — whitebox tests for per-run rich-text rendering.
// A spreadsheet cell may hold multiple runs each with their own run
// properties (`<rPr>`); the SVG renderer emits one `<tspan>` per run so
// each keeps its own font, while plain / single-run cells keep the
// unchanged single-style `<text>` path (no `<tspan>`).

///|
/// File-local QName builder (whitebox helpers are file-local, so we
/// define our own rather than reuse `viewer_wbtest.mbt`'s).
fn rtr_name(local_name : String) -> @xml.QName {
  { prefix: None, local_name, ns: None }
}

///|
/// Build an element node from a local name, attributes, and children.
fn rtr_elem(
  local_name : String,
  attrs : Array[@xml.Attribute],
  children : Array[@xml.Node],
) -> @xml.Node {
  @xml.Node::Element({ name: rtr_name(local_name), attributes: attrs, children })
}

///|
/// Build a `<t>text</t>` element node.
fn rtr_t(text : String) -> @xml.Node {
  rtr_elem("t", [], [@xml.Node::Text(text)])
}

///|
/// Build a rich-text run `<r>[<rPr>…</rPr>]<t>text</t></r>`.  When
/// `bold` is true the run's `<rPr>` carries a `<b/>` flag (§18.4.7).
fn rtr_run(text : String, bold~ : Bool) -> @xml.Node {
  let children : Array[@xml.Node] = []
  if bold {
    children.push(rtr_elem("rPr", [], [rtr_elem("b", [], [])]))
  }
  children.push(rtr_t(text))
  rtr_elem("r", [], children)
}

///|
/// Wrap a single cell into a one-row worksheet covering `A1`.
/// `CT_Worksheet::new` raises `@errors.SchemaViolation`, so propagate.
fn rtr_worksheet(cell : @xml.Node) -> @domain.CT_Worksheet raise {
  @domain.CT_Worksheet::new({
    name: rtr_name("worksheet"),
    attributes: [],
    children: [
      rtr_elem("dimension", [{ name: rtr_name("ref"), value: "A1:A1" }], []),
      rtr_elem("sheetData", [], [
        rtr_elem("row", [{ name: rtr_name("r"), value: "1" }], [cell]),
      ]),
    ],
  })
}

///|
/// §18.4.12 — a two-run inlineStr cell (bold "Total: " + normal "42")
/// must render at least two `<tspan>` elements, and the bold run must
/// carry a distinct `font-weight` (the normal run does not), proving
/// per-run fonts instead of the whole cell rendering bold.
test "rich text inlineStr 2-run cell yields per-run tspans with distinct weight" {
  let cell = rtr_elem(
    "c",
    [
      { name: rtr_name("r"), value: "A1" },
      { name: rtr_name("t"), value: "inlineStr" },
    ],
    [
      rtr_elem("is", [], [
        rtr_run("Total: ", bold=true),
        rtr_run("42", bold=false),
      ]),
    ],
  )
  let result = render_svg(rtr_worksheet(cell))
  // Both run texts present.
  assert_true(result.svg.contains("Total: "))
  assert_true(result.svg.contains("42"))
  // At least two <tspan> were emitted (one per run).  Counting via
  // split: N occurrences of "<tspan" produce N+1 segments.
  let tspan_count = result.svg.split("<tspan").collect().length() - 1
  assert_true(tspan_count >= 2)
  // The bold run carries an explicit font-weight; the normal run does
  // not, so a weight directive distinguishes the two runs.
  assert_true(result.svg.contains("font-weight=\"bold\""))
}

///|
/// §18.4.7 / §18.4.12 — a plain single-run cell (no `<rPr>`) MUST use
/// the unchanged single-style path: the rendered text carries NO
/// `<tspan>` element.
test "rich text plain single-run inlineStr cell yields no tspan" {
  let cell = rtr_elem(
    "c",
    [
      { name: rtr_name("r"), value: "A1" },
      { name: rtr_name("t"), value: "inlineStr" },
    ],
    [rtr_elem("is", [], [rtr_t("Hello")])],
  )
  let result = render_svg(rtr_worksheet(cell))
  assert_true(result.svg.contains("Hello"))
  assert_false(result.svg.contains("<tspan"))
}

///|
/// §18.4.7 / §18.4.12 — a single bare `<r>` with no `<rPr>` is NOT
/// multi-styled, so it too uses the unchanged path (no `<tspan>`),
/// confirming the gate fires only on genuine per-run formatting.
test "rich text single bare run inlineStr cell yields no tspan" {
  let cell = rtr_elem(
    "c",
    [
      { name: rtr_name("r"), value: "A1" },
      { name: rtr_name("t"), value: "inlineStr" },
    ],
    [rtr_elem("is", [], [rtr_run("World", bold=false)])],
  )
  let result = render_svg(rtr_worksheet(cell))
  assert_true(result.svg.contains("World"))
  assert_false(result.svg.contains("<tspan"))
}

///|
/// §18.4.8 / §18.4.12 — a shared-string rich cell: the `<si>` entry
/// holds two runs (bold "Bold" + normal "Plain"); the cell `<c t="s">`
/// references it by index.  The renderer reads the runs from the typed
/// shared-string table and emits per-run `<tspan>`s with a distinct
/// bold weight.
test "rich text shared-string rich cell yields per-run tspans" {
  let si = rtr_elem("si", [], [
    rtr_run("Bold", bold=true),
    rtr_run("Plain", bold=false),
  ])
  let sst = @domain.CT_Sst::new({
    name: rtr_name("sst"),
    attributes: [],
    children: [si],
  })
  let cell = rtr_elem(
    "c",
    [{ name: rtr_name("r"), value: "A1" }, { name: rtr_name("t"), value: "s" }],
    [rtr_elem("v", [], [@xml.Node::Text("0")])],
  )
  let result = render_svg(rtr_worksheet(cell), shared_strings=Some(sst))
  assert_true(result.svg.contains("Bold"))
  assert_true(result.svg.contains("Plain"))
  let tspan_count = result.svg.split("<tspan").collect().length() - 1
  assert_true(tspan_count >= 2)
  assert_true(result.svg.contains("font-weight=\"bold\""))
}

///|
/// §18.4.8 — a shared-string cell whose `<si>` is a single plain `<t>`
/// (no runs) MUST use the unchanged path: no `<tspan>`.
test "rich text shared-string plain cell yields no tspan" {
  let si = rtr_elem("si", [], [rtr_t("Single")])
  let sst = @domain.CT_Sst::new({
    name: rtr_name("sst"),
    attributes: [],
    children: [si],
  })
  let cell = rtr_elem(
    "c",
    [{ name: rtr_name("r"), value: "A1" }, { name: rtr_name("t"), value: "s" }],
    [rtr_elem("v", [], [@xml.Node::Text("0")])],
  )
  let result = render_svg(rtr_worksheet(cell), shared_strings=Some(sst))
  assert_true(result.svg.contains("Single"))
  assert_false(result.svg.contains("<tspan"))
}
