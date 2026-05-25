// Schema containment graph + upward host-path resolution.
//
// An element whose namespace has no standalone document part (a
// DrawingML path command, a VML drawing element, a chart sub-element)
// cannot be verified by dropping it at a document body — it is only
// schema-valid inside a specific parent chain.  This module derives,
// mechanically from the XSD, the chain of wrapper elements from a
// document-part root down to any element, so the verifier can embed
// each element where the schema actually permits it.

///|
/// A (element-name, type-local-name) pair — the node identity in the
/// containment graph.  Keyed as "name\u{0000}type" in maps.
fn nt_key(name : String, type_ln : String) -> String {
  name + "\u{0000}" + type_ln
}

///|
/// The element-name part of an `nt_key`.
fn nt_name(key : String) -> String {
  match key.find("\u{0000}") {
    Some(i) => key[0:i].to_string()
    None => key
  }
}

///|
/// The (name, type) of one `<xsd:element>` particle — resolving a
/// `ref=` element through the referenced top-level declaration.
fn element_nt(schema : Schema, el : @xml.Element) -> (String, String) {
  // An element `ref` keeps its bare name (elements resolve by name);
  // a `type` is an already-resolved `ns#localname` key.
  let nm = match attr(el, "name") {
    Some(n) => n
    None =>
      match attr(el, "ref") {
        Some(r) => local_name(r)
        None => ""
      }
  }
  let ty = match attr(el, "type") {
    Some(t) => t
    None =>
      match attr(el, "ref") {
        Some(r) =>
          match schema.top_elements.get(local_name(r)) {
            Some((top, _)) =>
              match attr(top, "type") {
                Some(tt) => tt
                None => "__inline__"
              }
            None => "__inline__"
          }
        None => "__inline__"
      }
  }
  (nm, ty)
}

///|
/// The set of child (name, type) pairs a complexType can contain.
/// Group references are expanded *transitively* — `<w:p>` lives many
/// nested groups deep under `CT_Body` (EG_BlockLevelElts ->
/// EG_ContentBlockContent -> p), so a one-level expansion misses it.
fn type_children(schema : Schema, ct : @xml.Element) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  // Direct `<xsd:element>` children, plus those inside any
  // (transitively) referenced group.  `seen_groups` guards against a
  // group that references itself; `seen_bases` guards against base
  // type chains that loop.
  let seen_groups : Map[String, Bool] = Map::new()
  fn collect(node : @xml.Element) -> Unit {
    // Walk this node's whole subtree; for every `<xsd:element>`
    // record it, and for every `<xsd:group ref>` recurse into the
    // referenced group definition.
    fn walk(e : @xml.Element) -> Unit {
      if is_xsd(e, "element") {
        let (nm, ty) = element_nt(schema, e)
        if nm != "" {
          out.push((nm, ty))
        }
        // An element node has no particle children to follow.
        return
      }
      if is_xsd(e, "group") {
        match attr(e, "ref") {
          Some(gname) =>
            // `ref` on a group is an already-resolved `ns#localname`.
            if not(seen_groups.contains(gname)) {
              seen_groups[gname] = true
              match schema.groups.get(gname) {
                Some(gp) => collect(gp)
                None => ()
              }
            }
          None =>
            // A named group *definition* nested inline: descend.
            for child in e.children {
              match child {
                Element(c) => walk(c)
                _ => ()
              }
            }
        }
        return
      }
      // sequence / choice / all / complexContent / extension / … —
      // descend into the particle structure.
      for child in e.children {
        match child {
          Element(c) => walk(c)
          _ => ()
        }
      }
    }

    walk(node)
  }

  collect(ct)
  out
}

///|
/// True when a complexType's content model contains an `<xsd:any>`
/// wildcard — an open extension point (e.g. `CT_GraphicalObjectData`,
/// where DrawingML tables / charts / diagrams are spliced in).  Such
/// a type can legally contain any element.
fn type_has_any(ct : @xml.Element) -> Bool {
  xsd_descendants(ct, "any").length() > 0
}

///|
/// The document-part root elements a fixture can be built around,
/// with their type names.
///
/// The three primary document parts (`document` / `worksheet` /
/// `sld`) carry the bulk of the renderable content per
/// ECMA-376 §17 / §18 / §19.  The four supplementary part roots
/// (`presentation` / `workbook` / `theme` / `styleSheet`) anchor
/// presentation-level metadata, workbook-level configuration,
/// theme palettes, and styled-cell tables respectively; including
/// them widens the BFS so child elements of those parts (`<sldSz>`,
/// `<workbookProtection>`, `<themeElements>`, `<numFmts>`, …) get
/// a wrapper chain that lands them in their canonical OPC part
/// rather than the default docx fallback.  The corresponding
/// auxiliary-part builders (`xlsx_package_with_replaced_workbook`,
/// `pptx_package_with_replaced_presentation`,
/// `pptx_package_with_replaced_theme`,
/// `xlsx_package_with_replaced_stylesheet`) must synthesise a
/// spec-valid minimum skeleton (required siblings such as
/// `<sheets>` / `<sldIdLst>` / `<themeElements>` / required
/// `<extLst>` slots) for the embedded element to survive the open
/// → save → open round trip.
fn part_roots(schema : Schema) -> Array[(String, String)] {
  let roots : Array[(String, String)] = []
  for
    name in [
      // Primary document-body roots.
      "document", "worksheet", "sld",
      // Supplementary cross-format roots.
       "presentation", "workbook", "theme", "styleSheet",
      // WML auxiliary part roots — without these, WML-only elements
      // such as `<w:evenAndOddHeaders>` or `<w:characterSpacingControl>`
      // (defined only inside `<w:settings>`) have no body-rooted BFS
      // path and fall through to the `graphicData` any-host route,
      // which lands them in a PPTX slide where the renderer never
      // surfaces the WML metadata. Adding the aux roots gives them a
      // canonical WML wrapper chain that `docx_aux_package` can
      // synthesise into a valid `.docx` package.
       "settings", "styles", "numbering", "fonts", "webSettings", "comments", "footnotes",
      "endnotes",
    ] {
    match schema.top_elements.get(name) {
      Some((el, _)) =>
        // The root element's `type` is a resolved `ns#localname`.
        match attr(el, "type") {
          Some(t) => roots.push((name, t))
          None => ()
        }
      None => ()
    }
  }
  roots
}

///|
/// For every reachable (element, type) pair, the wrapper chain — as
/// (name, type) pairs — from a part-root element down to (and
/// excluding) it.  BFS over the containment graph; each complexType
/// is expanded once.  The chain's first entry is always a part root
/// (`document` / `worksheet` / `sld`).
fn build_ancestry(schema : Schema) -> Map[String, Array[(String, String)]] {
  // Per-element collection of every reachable wrapper chain — the
  // BFS surfaces multiple paths because an element name with a
  // single complexType (e.g. `cNvPr`) lives under both
  // `spTree/nvGrpSpPr` (the root group's metadata, which the
  // renderer ignores) and `spTree/sp/nvSpPr` (an actual shape,
  // where the renderer emits the `data-ooxml-id` attribute).  We
  // record both and pick the best one at the end so the chosen
  // canonical path leads through a render-bearing host whenever
  // possible.
  let all_paths : Map[String, Array[Array[(String, String)]]] = Map::new()
  // Queue of (name, type, path-of-(name,type)-down-to-parent).
  let queue : Array[(String, String, Array[(String, String)])] = []
  for root in part_roots(schema) {
    let (rname, rtype) = root
    queue.push((rname, rtype, []))
  }
  // `xsd:any`-bearing types reached during the named BFS, recorded
  // with the path down to their content slot — used only as a
  // fallback after the named graph is exhausted.
  let any_hosts : Array[Array[(String, String)]] = []
  // Two-pass named-containment BFS — keeps every primary-rooted
  // (name, type) on its shortest primary chain, and only routes
  // through supplementary roots (`presentation` / `workbook` /
  // `theme` / `styleSheet`) for elements the primary pass never
  // reached.
  //
  // Without the split, a complex type shared by both
  // a primary chain (e.g. `<a:spPr>` under
  // `[sld, cSld, spTree, sp]`) and a supplementary chain
  // (e.g. `<a:spPr>` under `[theme, objectDefaults, spDef]`)
  // gets expanded just once — through whichever route the BFS
  // visits first — and the OTHER route's descendants never get
  // their parent path propagated.  When the supplementary route
  // is shallower (a 4-deep theme chain vs a 5-deep sld chain),
  // the descendants like `<a:prstGeom>` end up with only the
  // supplementary path and the canonical picker's primary-root
  // preference has no primary candidate to select.
  fn run_bfs(
    bfs_queue : Array[(String, String, Array[(String, String)])],
    skip_keys : Map[String, Bool],
  ) -> Unit {
    let local_expanded : Map[String, Bool] = Map::new()
    let mut h = 0
    while h < bfs_queue.length() {
      let (cur_name, cur_type, path) = bfs_queue[h]
      h = h + 1
      let key = nt_key(cur_name, cur_type)
      if skip_keys.contains(key) {
        continue
      }
      let existing = all_paths.get(key).unwrap_or([])
      existing.push(path)
      all_paths[key] = existing
      if local_expanded.contains(cur_type) {
        continue
      }
      local_expanded[cur_type] = true
      match schema.complex_types.get(cur_type) {
        None => ()
        Some(ct) => {
          let child_path = path + [(cur_name, cur_type)]
          for child in type_children(schema, ct) {
            let (cname, ctype) = child
            let ckey = nt_key(cname, ctype)
            let child_existing = all_paths.get(ckey).unwrap_or([])
            if child_existing.length() == 0 && not(skip_keys.contains(ckey)) {
              bfs_queue.push((cname, ctype, child_path))
            }
            child_existing.push(child_path)
            all_paths[ckey] = child_existing
          }
          if type_has_any(ct) {
            any_hosts.push(child_path)
          }
        }
      }
    }
  }

  // PASS 1 — primary-root BFS.  Seed only `document` /
  // `worksheet` / `sld`; expand to fixpoint.  This is the
  // pre-supplementary baseline behaviour, so primary-rooted
  // (name, type) pairs end up on the SAME canonical chain the
  // baseline produced.
  let primary_queue : Array[(String, String, Array[(String, String)])] = []
  for entry in queue {
    let (rname, _rtype) = (entry.0, entry.1)
    match rname {
      "document" | "worksheet" | "sld" => primary_queue.push(entry)
      _ => ()
    }
  }
  run_bfs(primary_queue, Map::new())
  let primary_keys : Map[String, Bool] = Map::new()
  for k, _ in all_paths {
    primary_keys[k] = true
  }
  // PASS 2 — supplementary-root BFS.  Seed only `presentation` /
  // `workbook` / `theme` / `styleSheet`.  Elements already
  // covered by the primary pass are skipped (no path added, no
  // children recursed through them) so primary canonical paths
  // are preserved; elements ONLY reachable through a
  // supplementary root (`<workbookProtection>`,
  // `<sldSz>`, `<themeElements>/clrScheme`, …) pick up their
  // supplementary chain here.
  let supp_queue : Array[(String, String, Array[(String, String)])] = []
  for entry in queue {
    let (rname, _rtype) = (entry.0, entry.1)
    match rname {
      "presentation"
      | "workbook"
      | "theme"
      | "styleSheet"
      // WML auxiliary parts — same pass as the cross-format
      // supplementary roots so WML-only elements have a primary
      // wrapper chain before any `graphicData` any-host fallback.
      | "settings"
      | "styles"
      | "numbering"
      | "fonts"
      | "webSettings"
      | "comments"
      | "footnotes"
      | "endnotes" => supp_queue.push(entry)
      _ => ()
    }
  }
  run_bfs(supp_queue, primary_keys)
  // An `<xsd:any>` extension point (e.g. CT_GraphicalObjectData)
  // legally accepts any element.  For an element the named BFS
  // could not reach, route it through the FIRST visual any-host —
  // `graphicData`-bearing chains lead to the diagram / chart /
  // table dispatcher, where the renderer actually consults the
  // payload.  A generic `extLst/ext` slot routes to nowhere
  // visible.
  let mut visual_host : Array[(String, String)]? = None
  let mut nonvisual_host : Array[(String, String)]? = None
  for host_path in any_hosts {
    if any_host_is_visual(host_path) {
      if visual_host is None {
        visual_host = Some(host_path)
      }
    } else if nonvisual_host is None {
      nonvisual_host = Some(host_path)
    }
  }
  for _k, decl in schema.all_elements {
    let ckey = nt_key(decl.name, decl.type_name)
    let existing = all_paths.get(ckey).unwrap_or([])
    // The visual / non-visual any-host fallbacks fire ONLY when the
    // two-pass named BFS reached the element through no path at
    // all — neither a primary part root nor a supplementary one.
    // For such elements (DrawingML payload reachable only through
    // the §20.1.2.2.17 `<a:graphicData>` `<xsd:any>` extension
    // point) the visual any-host route lands the element under the
    // slide's `graphicFrame` dispatcher; without it the element
    // would have no host and the verifier would have to skip it.
    //
    // Crucially the fallback is NOT added when the BFS reached the
    // element through a supplementary part root only — `<workbook>`,
    // `<presentation>`, `<theme>`, `<styleSheet>` ARE legitimate
    // OPC parts the renderer reads (after the corresponding
    // `data-ooxml-*` projection lands), so a supplementary chain is
    // a renderable route and the visual any-host would only mask
    // it with a generic graphicData dispatch that cannot interpret
    // the supplementary-rooted element.
    if existing.length() == 0 {
      match visual_host {
        Some(h) => existing.push(h)
        None => ()
      }
      match nonvisual_host {
        Some(h) => existing.push(h)
        None => ()
      }
      all_paths[ckey] = existing
    }
  }
  // Canonical single-path map: pick one wrapper chain per element.
  //
  // Two-level preference, applied in order:
  //
  // 1. PRIMARY part-root preference — when an element is reachable
  //    both from a primary part root (`document` / `worksheet` /
  //    `sld`, which host the bulk of the renderable content) AND
  //    from a supplementary one (`presentation` / `workbook` /
  //    `theme` / `styleSheet`, which carry metadata and
  //    configuration), keep the primary path.  Without this the
  //    BFS picks the shallower route through the supplementary
  //    root (e.g. `<a:srgbClr>` reached via
  //    `[theme, themeElements, clrScheme, accent1]` at depth 4
  //    instead of via `[sld, …, spPr, solidFill]` at depth 7+),
  //    landing the element in an aux part where the slide renderer
  //    cannot see it.  Supplementary-root paths are still kept as
  //    the canonical route for elements that ONLY appear there
  //    (e.g. `<workbookProtection>` lives strictly under
  //    `<workbook>`, `<sldSz>` strictly under `<presentation>`).
  //
  // 2. SHAPE-HOST preference (existing) — non-visual property
  //    elements (cNvPr / cNvSpPr / cNvPicPr / hlinkClick /
  //    hlinkHover) are only consulted by the renderer when they
  //    sit inside a real shape host (sp / pic / cxnSp / grpSp /
  //    graphicFrame), so for those names a shape-bearing path is
  //    promoted over the otherwise-canonical one (which lands at
  //    spTree's own nvGrpSpPr metadata slot — visible to
  //    round-trip but never to the renderer).  A fill / colour /
  //    geometry element like `blipFill` renders just as well from
  //    `bg/bgPr` as from `pic` so it stays on the BFS-canonical
  //    path.
  let ancestry : Map[String, Array[(String, String)]] = Map::new()
  for key, paths in all_paths {
    if paths.length() == 0 {
      continue
    }
    let name = nt_name(key)
    let prefer_shape = is_shape_attached_prop(name)
    // Step 0 — namespace-aligned primary root preference.  When an
    // element's own namespace identifies a specific renderer
    // pipeline (WordprocessingML, SpreadsheetML, PresentationML),
    // an ancestry chain rooted at that pipeline's primary part
    // ALWAYS beats a chain rooted in a different pipeline — even
    // when the foreign chain is shallower.  Without this the BFS
    // picks the shallowest available path (e.g. `<w:tcBorders>`
    // routed through `<sld>/.../a:tc>/<a:tcPr>` for §17.4.59) and
    // the wml renderer never sees the element because it lives
    // in the wrong part.  The renderer pipeline that owns the
    // element's namespace is the only one able to interpret it,
    // so we promote a matching primary chain whenever one exists.
    let preferred_root = match nt_ns(key) {
      ns if ns.contains("wordprocessingml") => Some("document")
      ns if ns.contains("spreadsheetml") => Some("worksheet")
      ns if ns.contains("presentationml") => Some("sld")
      _ => None
    }
    let mut best : Array[(String, String)] = paths[0]
    match preferred_root {
      Some(root_name) => {
        let best_matches = best.length() > 0 && best[0].0 == root_name
        if not(best_matches) {
          for p in paths {
            if p.length() > 0 && p[0].0 == root_name {
              best = p
              break
            }
          }
        }
      }
      None => ()
    }
    // Step 1 — primary part-root preference.  Walk candidates in
    // BFS order so we land on the shallowest primary path when
    // multiple primary paths exist (matches the pre-supplementary
    // baseline canonical pick).  An empty path indicates the
    // element IS a primary part root (`<document>`, `<sld>`,
    // `<worksheet>`) — it is its own host and counts as primary.
    let best_is_primary = best.length() == 0 ||
      path_starts_in_primary_root(best)
    if not(best_is_primary) {
      for p in paths {
        if p.length() == 0 || path_starts_in_primary_root(p) {
          best = p
          break
        }
      }
    }
    // Step 2 — shape-host preference for cNv* / hlink* elements.
    if prefer_shape {
      for p in paths {
        if path_has_shape_host(p) && not(path_has_shape_host(best)) {
          best = p
        }
      }
    }
    ancestry[key] = best
  }
  ancestry
}

///|
/// Extract the namespace half from an `nt_key` (`<name>\0<type-key>`).
/// The type key is encoded as `<namespace>#<localname>` so the
/// namespace identifies the schema pipeline that owns the element.
fn nt_ns(key : String) -> String {
  let after = match key.find("\u{0000}") {
    None => return ""
    Some(i) => key[i + 1:].to_string()
  }
  match after.find("#") {
    None => after
    Some(j) => after[0:j].to_string()
  }
}

///|
/// True when `path` starts at one of the three primary document part
/// roots — `<document>` (WML), `<worksheet>` (SML), `<sld>` (PML).
/// Used by `build_ancestry` to keep an element on its
/// renderer-reachable wrapper chain when the schema also exposes a
/// shallower route through a supplementary root (`<presentation>`,
/// `<workbook>`, `<theme>`, `<styleSheet>`) whose aux-part host the
/// slide / worksheet renderer never inspects.
fn path_starts_in_primary_root(path : Array[(String, String)]) -> Bool {
  if path.length() == 0 {
    return false
  }
  let (root_name, _) = path[0]
  match root_name {
    "document" | "worksheet" | "sld" => true
    _ => false
  }
}

///|
/// True when any path in `paths` starts at a primary document part
/// root — used to detect whether the BFS reached an element through
/// at least one renderable route, so the visual any-host fallback
/// can be skipped when that fallback would not improve coverage.
fn any_path_starts_in_primary_root(
  paths : Array[Array[(String, String)]],
) -> Bool {
  for p in paths {
    if path_starts_in_primary_root(p) {
      return true
    }
  }
  false
}

///|
/// True when at least one path in `paths` is the empty wrapper
/// chain — the element IS itself a part-root (e.g. `<document>`,
/// `<worksheet>`, `<sld>`).  In that case the canonical-path picker
/// keeps the empty chain so the verifier wraps the element as its
/// own document part rather than re-embedding it inside another
/// host.
fn any_path_is_empty(paths : Array[Array[(String, String)]]) -> Bool {
  for p in paths {
    if p.length() == 0 {
      return true
    }
  }
  false
}

///|
/// True when `name` is a non-visual property element the renderer
/// surfaces only inside a real shape host — the cNv* / hlink* set
/// the §19.3.1 ShapeProperties chain wraps with `<nvSpPr>` /
/// `<nvPicPr>` / `<nvCxnSpPr>` / `<nvGraphicFramePr>` /
/// `<nvGrpSpPr>` (the per-shape metadata block).  The schema BFS
/// reaches these names first through spTree's OWN `nvGrpSpPr`
/// slot (the slide-level group properties, which the renderer
/// ignores), so the verifier needs to skip past that to the
/// next shape-bearing wrapper for the render contribution to
/// become visible.
fn is_shape_attached_prop(name : String) -> Bool {
  match name {
    "cNvPr"
    | "cNvSpPr"
    | "cNvPicPr"
    | "cNvCxnSpPr"
    | "cNvGraphicFramePr"
    | "hlinkClick"
    | "hlinkHover" => true
    _ => false
  }
}

///|
/// True when `path` contains a wrapper element whose renderer
/// dispatch reads non-visual properties (cNvPr / cNvSpPr / cNvPicPr
/// / hlinkClick / …) — the five shape host names ECMA-376 §19.3.1
/// enumerates as visual content carriers (and their VML cousin
/// `txbxContent`).  Used to rank a (name, type) element's ancestry
/// candidates so the verifier tries a render-bearing host before a
/// metadata-only one.
fn path_has_shape_host(path : Array[(String, String)]) -> Bool {
  for step in path {
    let (n, _) = step
    match n {
      "sp" | "pic" | "grpSp" | "cxnSp" | "graphicFrame" => return true
      _ => ()
    }
  }
  false
}

///|
/// True when an any-host path leads through a `graphicData` /
/// `graphicFrame` slot — the GraphicalObjectData extension point
/// the renderer's chart / diagram / table dispatch consults.  Used by
/// `build_ancestry` to prefer the visual any-host over the generic
/// extLst slot so an unbounded element lands where the renderer
/// will actually look at it.
fn any_host_is_visual(path : Array[(String, String)]) -> Bool {
  for step in path {
    let (n, _) = step
    if n == "graphicData" || n == "graphicFrame" {
      return true
    }
  }
  false
}

///|
/// Return a copy of `el` whose attribute named `local` carries
/// `value`.  The attribute is created when absent and overwritten
/// when present; its prefix / namespace are preserved if it already
/// existed.  Used to retarget the synthesised wrapper attribute
/// values (`graphicData/@uri` → the dispatcher URI) so the
/// renderer's namespace-based routing fires for the element under
/// test.
fn retarget_attr(
  el : @xml.Element,
  local : String,
  value : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  let mut replaced = false
  for a in el.attributes {
    if a.name.local_name == local {
      attrs.push({ name: a.name, value })
      replaced = true
    } else {
      attrs.push(a)
    }
  }
  if not(replaced) {
    attrs.push({ name: { prefix: None, local_name: local, ns: None }, value })
  }
  { name: el.name, attributes: attrs, children: el.children }
}

///|
/// Wrap `target` in its schema ancestry chain so the result is a
/// schema-valid `@xml.Element` subtree of a document part.
///
/// Built inside-out as a real element tree: at each ancestry level
/// the wrapper element is fully synthesised (`synth_element` — every
/// required attribute and child, including the correct branch of a
/// required `<xsd:choice>` such as `EG_WrapType`), then the
/// already-built `inner` element replaces the wrapper's child of the
/// same name (or is appended when the wrapper declares that child
/// only optionally — most container nesting).
///
/// `skip_depth` leading ancestry elements are omitted — the caller's
/// host package already supplies them (the part-root element).
fn wrap_in_ancestry(
  schema : Schema,
  path : Array[(String, String)],
  skip_depth : Int,
  target : @xml.Element,
) -> @xml.Element {
  let mut inner = target
  let mut i = path.length() - 1
  while i >= skip_depth {
    let (wname, wtype) = path[i]
    // The element name the ancestry continues through: the next
    // path element, or — at the innermost wrapper — the target.
    let path_child = if i + 1 < path.length() {
      path[i + 1].0
    } else {
      target.name.local_name
    }
    let wrapper = match schema.complex_types.get(wtype) {
      Some(wct) => {
        let stack : StrSet = Map::new()
        stack[wtype] = true
        // Ancestry wrappers are synthesised with a modest rich budget
        // so the immediate context is non-degenerate: the `<w:r>`
        // that wraps an `<w:rPr>` (which holds the element under
        // test, e.g. `<w:b>`) then carries a `<w:t>` text sibling, so
        // a formatting property has something visible to act on.
        // The SAME wrapper noise appears in both the present and
        // absent differential trees, so the diff still isolates the
        // target element itself.
        synth_element(
          schema,
          wct,
          schema.type_ns.get(wtype).unwrap_or(""),
          wname,
          stack,
          1,
          WRAPPER_RICH_BUDGET,
        )
      }
      None =>
        // No type info — a bare wrapper element.
        elem(schema.type_ns.get(wtype).unwrap_or(""), wname, [], [])
    }
    let wrapper = if wname == "graphicData" {
      // The DrawingML graphicData host dispatches its `<xsd:any>`
      // child via the `@uri` attribute (§20.1.2.2.17 — the URI
      // identifies the embedded payload's family: diagram, chart,
      // table, ...).  Without a recognised URI the renderer's
      // dispatcher cannot route the inner element through its
      // specialised path (the dgm:relIds element is read by the
      // diagram engine only when uri matches the diagram
      // namespace), so the wrapper's synthesised `uri="x"` lands
      // the payload in the placeholder fallback every time.  Stamp
      // the URI from the inner element's own namespace so the
      // dispatcher recognises it.
      let ns = inner.name.ns.unwrap_or("")
      retarget_attr(wrapper, "uri", ns)
    } else {
      wrapper
    }
    inner = insert_path_child(schema, wtype, wrapper, path_child, inner)
    i = i - 1
  }
  inner
}

///|
/// Return a copy of `wrapper` whose child element named `child_name`
/// is replaced by `inner`.  When `wrapper` has no such child (the
/// content model declared it only optionally) `inner` is appended as
/// a child instead.
///
/// Any sibling whose name appears in the SAME `<xsd:choice>` particle
/// as `child_name` is dropped from the result.  A wrapper synthesised
/// at `rich >= 1` enumerates every optional particle once — including
/// every alternative of a choice such as `EG_FillProperties`
/// (noFill / solidFill / gradFill / blipFill / pattFill / grpFill),
/// even though the spec only permits exactly one.  Renderers honour
/// the spec by picking the FIRST recognised choice (the bg/bgPr
/// renderer hits `noFill` and stops, masking the target `blipFill`).
/// Pruning the competing alternatives keeps the wrapper schema-valid
/// AND gives the element under test sole occupancy of its choice
/// slot, so the differential render check can isolate its effect.
fn insert_path_child(
  schema : Schema,
  wrapper_type : String,
  wrapper : @xml.Element,
  child_name : String,
  inner : @xml.Element,
) -> @xml.Element {
  // Names in the same `<xsd:choice>` as `child_name` (the target's
  // alternatives) — every one of these must be dropped so the
  // target stands alone in its choice slot.
  let competitors = choice_siblings(schema, wrapper_type, child_name)
  let kids : Array[@xml.Node] = []
  let mut replaced = false
  for child in wrapper.children {
    match child {
      Element(c) if c.name.local_name == child_name && not(replaced) => {
        kids.push(Element(inner))
        replaced = true
      }
      Element(c) if competitors.get(c.name.local_name) is Some(true) =>
        // Drop a synthesised choice alternative competing with the
        // target — the spec mandates exactly one branch and the
        // renderer's first-match probe must hit the target.
        ()
      other => kids.push(other)
    }
  }
  if not(replaced) {
    kids.push(Element(inner))
  }
  { name: wrapper.name, attributes: wrapper.attributes, children: kids }
}

///|
/// Element names that share an `<xsd:choice>` particle with
/// `target_name` somewhere inside complexType `wrapper_type`, excluding
/// `target_name` itself.  Returns an empty map when the target is not
/// inside a choice — a `<xsd:sequence>` sibling is a co-required
/// neighbour, not an alternative, and must NOT be pruned.
fn choice_siblings(
  schema : Schema,
  wrapper_type : String,
  target_name : String,
) -> Map[String, Bool] {
  let out : Map[String, Bool] = Map::new()
  let ct = match schema.complex_types.get(wrapper_type) {
    Some(c) => c
    None => return out
  }
  let walk_seen : Map[String, Bool] = Map::new()
  // Walk both the complexType's content model and the content of any
  // base type it extends — `<xsd:complexContent>/<xsd:extension>` —
  // so a target inside a base-type choice is found too.
  walk_for_choice(schema, ct, target_name, false, walk_seen, out)
  match xsd_child(ct, "complexContent") {
    Some(content) =>
      for kind in ["extension", "restriction"] {
        match xsd_child(content, kind) {
          Some(ext) =>
            match attr(ext, "base") {
              Some(base) =>
                match schema.complex_types.get(base) {
                  Some(base_ct) =>
                    walk_for_choice(
                      schema, base_ct, target_name, false, walk_seen, out,
                    )
                  None => ()
                }
              None => ()
            }
          None => ()
        }
      }
    None => ()
  }
  out
}

///|
/// True when an XSD particle declares `maxOccurs > 1` (numeric or
/// `unbounded`).  Used by `walk_for_choice` to detect the
/// "unordered list of choice members" OOXML schema pattern
/// (e.g. EG_RPrBase referenced with `maxOccurs="unbounded"`),
/// where the choice members can coexist and pruning is unsound.
fn particle_max_unbounded(node : @xml.Element) -> Bool {
  match attr(node, "maxOccurs") {
    Some(v) => v == "unbounded" || (try? @strconv.parse_int(v)).unwrap_or(1) > 1
    None => false
  }
}

///|
/// Walk an XSD content-model node looking for any `<xsd:choice>`
/// whose subtree contains `target_name`; record every other
/// reachable element name from that choice into `out`.  Descends
/// through `<xsd:group ref>` references and tracks whether the
/// enclosing particle chain is `maxOccurs`-bounded — an unbounded
/// choice represents the OOXML "unordered repeat" pattern and is
/// skipped because its members may legally coexist with the target.
fn walk_for_choice(
  schema : Schema,
  node : @xml.Element,
  target_name : String,
  unbounded : Bool,
  walk_seen : Map[String, Bool],
  out : Map[String, Bool],
) -> Unit {
  if is_xsd(node, "choice") {
    let choice_unbounded = unbounded || particle_max_unbounded(node)
    if not(choice_unbounded) {
      let names : Map[String, Bool] = Map::new()
      collect_choice_names(schema, node, Map::new(), names)
      if names.get(target_name) is Some(true) {
        for n, _ in names {
          if n != target_name {
            out[n] = true
          }
        }
      }
    }
    for c in node.children {
      match c {
        Element(e) =>
          walk_for_choice(
            schema, e, target_name, choice_unbounded, walk_seen, out,
          )
        _ => ()
      }
    }
    return
  }
  if is_xsd(node, "group") {
    let ref_unbounded = unbounded || particle_max_unbounded(node)
    match attr(node, "ref") {
      Some(gname) => {
        if not(walk_seen.contains(gname)) {
          walk_seen[gname] = true
          match schema.groups.get(gname) {
            Some(gp) =>
              walk_for_choice(
                schema, gp, target_name, ref_unbounded, walk_seen, out,
              )
            None => ()
          }
        }
        return
      }
      None => ()
    }
  }
  let nested_unbounded = unbounded || particle_max_unbounded(node)
  for c in node.children {
    match c {
      Element(e) =>
        walk_for_choice(
          schema, e, target_name, nested_unbounded, walk_seen, out,
        )
      _ => ()
    }
  }
}

///|
/// Collect every reachable element-name member underneath a
/// `<xsd:choice>` particle, descending through `<xsd:group ref>`
/// references and inline sequences.  Used by `walk_for_choice` to
/// build the candidate set of "sibling choice members" of a target
/// element.
fn collect_choice_names(
  schema : Schema,
  node : @xml.Element,
  seen_groups : Map[String, Bool],
  into : Map[String, Bool],
) -> Unit {
  if is_xsd(node, "element") {
    let (nm, _) = element_nt(schema, node)
    if nm != "" {
      into[nm] = true
    }
    return
  }
  if is_xsd(node, "group") {
    match attr(node, "ref") {
      Some(gname) =>
        if not(seen_groups.contains(gname)) {
          seen_groups[gname] = true
          match schema.groups.get(gname) {
            Some(gp) =>
              for c in gp.children {
                match c {
                  Element(e) =>
                    collect_choice_names(schema, e, seen_groups, into)
                  _ => ()
                }
              }
            None => ()
          }
        }
      None => ()
    }
    return
  }
  for c in node.children {
    match c {
      Element(e) => collect_choice_names(schema, e, seen_groups, into)
      _ => ()
    }
  }
}
