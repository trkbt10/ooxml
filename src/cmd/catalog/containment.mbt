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
    Some(i) => key[0:i].to_owned()
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
  let seen_groups : Map[String, Bool] = Map([], capacity=0)
  let seen_bases : Map[String, Bool] = Map([], capacity=0)
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
            if !seen_groups.contains(gname) {
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
      // `<xsd:extension base="…">` / `<xsd:restriction base="…">` —
      // pull the base type's particles into this type's content
      // model.  XSD §3.3.2 inheritance semantics: a derived
      // complexType's element content is the base's particles
      // followed by its own.  Without inheriting the base, a
      // derived type such as WML `CT_Document` (which `extends
      // CT_DocumentBase`) exposes only its own local sequence
      // (`<w:body>`) and the BFS misses the inherited
      // `<w:background>` child entirely — that drops §17.2.1 from
      // catalog render coverage even though the renderer fully
      // supports it.  Likewise WML `CT_TcPr` extends
      // `CT_TcPrInner` → `CT_TcPrBase` so `<w:tcBorders>` and
      // `<w:tcW>` need the base walk to surface from the
      // `<w:tc>` host.
      //
      // Multi-path ancestry (build_ancestry) records ALL discovered
      // wrapper chains per element and the catalog verifier tries
      // each candidate in order — so a base-walked chain that
      // happens to land an element on a non-rendering host (e.g.
      // `<wp:lineTo>` reached via the base-walked
      // `wp:positionH/<...>/CT_Point2D` chain) does not displace
      // the direct chain that the renderer actually visits.  The
      // `seen_bases` guard prevents inheritance loops.
      if is_xsd(e, "extension") || is_xsd(e, "restriction") {
        match attr(e, "base") {
          Some(base_key) =>
            if !seen_bases.contains(base_key) {
              seen_bases[base_key] = true
              match schema.complex_types.get(base_key) {
                Some(base_ct) => collect(base_ct)
                None => ()
              }
            }
          None => ()
        }
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
/// `sld`) carry the bulk of renderable content per ECMA-376 §17 /
/// §18 / §19.  Supplementary roots anchor OPC parts such as
/// presentation, workbook, shared strings, styles, theme, comments,
/// WML auxiliary parts, charts, diagrams, and chart user-shapes.
/// The concrete name/type/host set lives in `catalog_part_roots`;
/// this function only resolves those declarations against the loaded
/// XSD symbol table so Strict and Transitional variants both seed
/// their own BFS.
fn part_roots(schema : Schema) -> Array[(String, String)] {
  let roots : Array[(String, String)] = []
  for root in catalog_part_roots() {
    let matches : Array[(String, String)] = []
    for _k, decl in schema.all_elements {
      if catalog_part_root_matches(root, decl.name, decl.type_name) {
        matches.push((decl.name, decl.type_name))
      }
    }
    matches.sort_by(fn(a, b) {
      let ar = catalog_generation_rank(a.1)
      let br = catalog_generation_rank(b.1)
      if ar < br {
        -1
      } else if ar > br {
        1
      } else if a.1 < b.1 {
        -1
      } else if a.1 > b.1 {
        1
      } else {
        0
      }
    })
    for entry in matches {
      roots.push(entry)
    }
  }
  roots
}

///|
fn catalog_generation_rank(type_name : String) -> Int {
  let ns = match type_name.find("#") {
    Some(i) => type_name[0:i].to_owned()
    None => type_name
  }
  if ns.has_prefix("http://schemas.openxmlformats.org/") {
    0
  } else if ns.has_prefix("http://purl.oclc.org/ooxml/") {
    1
  } else {
    2
  }
}

///|
/// For every reachable (element, type) pair, the ORDERED list of
/// candidate wrapper chains — each chain a sequence of (name, type)
/// pairs from a part-root element down to (and excluding) the
/// element.  BFS over the containment graph; each complexType is
/// expanded once per BFS pass.  The first chain in the returned list
/// is the canonical pick (preferred renderer-bearing route); the
/// remaining chains are alternates the caller may try when the
/// canonical route does not actually surface the element through the
/// renderer.  Keeping ALL candidates lets a base-walked chain that
/// reaches more elements coexist with the direct chain that the
/// renderer visits — `lineTo` / `drawing` would otherwise regress
/// when the base-walked chain replaces their direct chain (the
/// base-walked chain hosts them under a node the renderer does not
/// inspect).
fn build_ancestry(
  schema : Schema,
) -> Map[String, Array[Array[(String, String)]]] {
  // Per-element collection of every reachable wrapper chain — the
  // BFS surfaces multiple paths because an element name with a
  // single complexType (e.g. `cNvPr`) lives under both
  // `spTree/nvGrpSpPr` (the root group's metadata, which the
  // renderer ignores) and `spTree/sp/nvSpPr` (an actual shape,
  // where the renderer emits the `data-ooxml-id` attribute).  We
  // record both and pick the best one at the end so the chosen
  // canonical path leads through a render-bearing host whenever
  // possible.
  let all_paths : Map[String, Array[Array[(String, String)]]] = Map(
    [],
    capacity=0,
  )
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
    let local_expanded : Map[String, Bool] = Map([], capacity=0)
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
            if child_existing.length() == 0 && !skip_keys.contains(ckey) {
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

  fn run_phase_namespace_bfs(
    phase : String,
    ns_strict : String,
    ns_trans : String,
  ) -> Unit {
    let before_paths : Map[String, Array[Array[(String, String)]]] = Map(
      [],
      capacity=0,
    )
    for k, v in all_paths {
      let copy : Array[Array[(String, String)]] = []
      for p in v {
        copy.push(p)
      }
      before_paths[k] = copy
    }
    let phase_queue : Array[(String, String, Array[(String, String)])] = []
    for _k, decl in schema.all_elements {
      match catalog_part_root_phase_for_decl(decl.name, decl.type_name) {
        Some(p) if p == phase =>
          phase_queue.push((decl.name, decl.type_name, []))
        _ => ()
      }
    }
    run_bfs(phase_queue, Map([], capacity=0))
    for key, _paths in all_paths {
      let is_phase_key = key.contains(ns_strict) || key.contains(ns_trans)
      if is_phase_key {
        continue
      }
      match before_paths.get(key) {
        Some(orig) => all_paths[key] = orig
        None => ()
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
  run_bfs(primary_queue, Map([], capacity=0))
  // PASS 1b — primary-root namespace variants.  `part_roots` is
  // keyed by element local name, so a root present in both Strict and
  // Transitional schemas contributes only one declaration to PASS 1.
  // Seed every primary document root variant from `all_elements` and
  // skip keys already reached by PASS 1; this preserves the canonical
  // primary paths while giving Strict-only descendants (for example
  // DrawingML main elements under a Strict PresentationML `<sld>`) a
  // real slide-rooted ancestry instead of falling through to a
  // malformed generic host.
  let pre_primary_variant_keys : Map[String, Bool] = Map([], capacity=0)
  for k, _ in all_paths {
    pre_primary_variant_keys[k] = true
  }
  let primary_variant_queue : Array[(String, String, Array[(String, String)])] = []
  for _k, decl in schema.all_elements {
    match catalog_part_root_phase_for_decl(decl.name, decl.type_name) {
      Some("primary") =>
        primary_variant_queue.push((decl.name, decl.type_name, []))
      _ => ()
    }
  }
  run_bfs(primary_variant_queue, pre_primary_variant_keys)
  let primary_keys : Map[String, Bool] = Map([], capacity=0)
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
    let rtype = entry.1
    match catalog_part_root_phase_for_decl(rname, rtype) {
      Some("supplementary") => supp_queue.push(entry)
      _ => ()
    }
  }
  run_bfs(supp_queue, primary_keys)
  // PASS 3 — §21.2 DrawingML chart BFS.  `<c:chartSpace>` is a
  // separate OPC part (`ppt/charts/chartN.xml`) whose schema tree
  // hosts the chart-namespace element family (plotArea, ser, val,
  // catAx, …) the primary slide/document/worksheet BFS reaches only
  // through `<a:graphicData>` (any-host).  Run a focused BFS from
  // chartSpace and ATTACH the discovered paths only to chart-namespace
  // elements — DML-core types (`<a:gd>`, `<a:srgbClr>`, …) that the
  // BFS also visits inside chart shapes keep their primary canonical
  // paths so the renderer's shape pipeline still credits them.
  let chart_ns_strict = "http://purl.oclc.org/ooxml/drawingml/chart"
  let chart_ns_trans = "http://schemas.openxmlformats.org/drawingml/2006/chart"
  run_phase_namespace_bfs("chart", chart_ns_strict, chart_ns_trans)
  // PASS 4 — §21.4 DrawingML diagram BFS.  Snapshot all_paths,
  // run a focused BFS from each of the four diagram part roots
  // (dataModel / layoutDef / styleDef / colorsDef) across both
  // strict and transitional namespaces, then keep the new
  // paths only for diagram-namespace (name, type) pairs so DML
  // core / chart types referenced inside diagram parts retain
  // their original canonical chain.
  let dgm_ns_strict = "http://purl.oclc.org/ooxml/drawingml/diagram"
  let dgm_ns_trans = "http://schemas.openxmlformats.org/drawingml/2006/diagram"
  run_phase_namespace_bfs("diagram", dgm_ns_strict, dgm_ns_trans)
  // PASS 5 — §21.3 DrawingML chartDrawing BFS.  `<c:userShapes>`
  // (chart namespace, type cdr:CT_Drawing) is the part root for the
  // user-shapes overlay on a chart.  Its content is in the
  // chartDrawing namespace.  Seed from each userShapes declaration
  // and keep paths only for chartDrawing-namespace (name, type)
  // pairs.
  let cdr_ns_strict = "http://purl.oclc.org/ooxml/drawingml/chartDrawing"
  let cdr_ns_trans = "http://schemas.openxmlformats.org/drawingml/2006/chartDrawing"
  run_phase_namespace_bfs("chartDrawing", cdr_ns_strict, cdr_ns_trans)
  // PASS 6 — §20.5 DrawingML spreadsheetDrawing BFS.  `<xdr:wsDr>`
  // is a separate worksheet drawing part (`xl/drawings/drawingN.xml`)
  // reached by SpreadsheetML through `<worksheet>/<drawing r:id>`.
  // The primary/supplementary BFS can otherwise reach xdr elements
  // only through generic extension/background any-host paths, which
  // parse but never exercise the SML drawing resolver or viewer.
  let xdr_ns_strict = "http://purl.oclc.org/ooxml/drawingml/spreadsheetDrawing"
  let xdr_ns_trans = "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing"
  run_phase_namespace_bfs("spreadsheetDrawing", xdr_ns_strict, xdr_ns_trans)
  // An `<xsd:any>` extension point (e.g. CT_GraphicalObjectData)
  // legally accepts any element.  For an element the named BFS
  // could not reach, route it through one of the discovered
  // any-host paths — `graphicData`-bearing chains lead to the
  // diagram / chart / table dispatcher; a generic `extLst/ext` slot
  // routes to a metadata projection.  We register the FIRST visual
  // any-host AND the first non-visual any-host of every distinct
  // primary-root pipeline (the BFS surfaces several xsd:any slots
  // across `document` / `worksheet` / `sld`, and the right one
  // depends on the element's own format — `worksheet/extLst/ext`
  // hosts a Strict-namespace worksheet, `document/background/...`
  // does not).  Multi-path ancestry then lets the catalog verifier
  // try each fallback in turn so it picks whichever one the
  // renderer actually surfaces.
  let mut visual_host : Array[(String, String)]? = None
  // One non-visual any-host per primary part-root pipeline — keyed
  // by the root element's local name (`document` / `worksheet` /
  // `sld`, or other when the host chain is rooted at a
  // supplementary part).  Without the per-pipeline split, the
  // FIRST encountered non-visual any-host (e.g. the deepest
  // `document/background/...` slot the base-walk now surfaces
  // first) replaces the previously-canonical `worksheet/extLst/ext`
  // route for Strict-namespace worksheets, and the Strict
  // `<s:worksheet>` element no longer renders because its host
  // package is built as `.docx` instead of `.xlsx`.
  let nonvisual_by_root : Map[String, Array[(String, String)]] = Map(
    [],
    capacity=0,
  )
  let nonvisual_order : Array[String] = []
  for host_path in any_hosts {
    if any_host_is_visual(host_path) {
      if visual_host is None {
        visual_host = Some(host_path)
      }
    } else {
      let root_key = if host_path.length() == 0 { "" } else { host_path[0].0 }
      if !nonvisual_by_root.contains(root_key) {
        nonvisual_by_root[root_key] = host_path
        nonvisual_order.push(root_key)
      }
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
      // Prefer the non-visual any-host whose root pipeline matches
      // the element's own namespace — a Strict worksheet under
      // `worksheet/extLst/ext` reaches the SML renderer; the same
      // worksheet under `document/background` does not.  Then
      // append the remaining per-root candidates as alternates the
      // multi-path verifier can try.
      let preferred_root = match strip_ns(decl.ns) {
        ns if ns == "wordprocessingml/main" => "document"
        ns if ns == "spreadsheetml/main" => "worksheet"
        ns if ns == "presentationml/main" => "sld"
        _ => ""
      }
      match nonvisual_by_root.get(preferred_root) {
        Some(h) => existing.push(h)
        None => ()
      }
      for r in nonvisual_order {
        if r == preferred_root {
          continue
        }
        match nonvisual_by_root.get(r) {
          Some(h) => existing.push(h)
          None => ()
        }
      }
      all_paths[ckey] = existing
    }
  }
  // Multi-path map: keep EVERY discovered wrapper chain per element
  // but ORDER them so the first chain is the canonical pick.  The
  // caller (catalog main) walks candidates in order, trying each
  // until one renders — keeping alternates lets a base-walked chain
  // that reaches more elements coexist with the direct chain that
  // the renderer visits.  Without the alternate list a base-walk
  // gain (`background` / `tcBorders` / `tcW` / `tcFitText` /
  // `header`) would come at the cost of `lineTo` / `drawing`
  // losses — those elements need the direct chain because the
  // base-walked chain lands them in a non-rendering host.
  //
  // Three-level preference, applied as a per-path SCORE that the
  // sort uses to put the best path first:
  //
  // - NAMESPACE-ALIGNED ROOT (weight 1000): the path's first
  //   element matches the renderer pipeline implied by the
  //   element's own namespace (wordprocessingml → `document`,
  //   spreadsheetml → `worksheet`, presentationml → `sld`).
  //
  // - PRIMARY ROOT (weight 100): the path starts at a primary
  //   part root, or the empty path (the element IS itself a part
  //   root).  Supplementary roots (`presentation` / `workbook` /
  //   `theme` / `styleSheet`) score zero here so a primary chain
  //   ranks above a shallower supplementary one for elements
  //   reachable from both.
  //
  // - SHAPE HOST (weight 10, only for cNv* / hlink* names): the
  //   path goes through a shape-attached host (sp / pic / cxnSp /
  //   grpSp / graphicFrame).
  //
  // Ties are broken by BFS insertion order (stable sort).
  let ancestry : Map[String, Array[Array[(String, String)]]] = Map(
    [],
    capacity=0,
  )
  for key, paths in all_paths {
    if paths.length() == 0 {
      continue
    }
    let name = nt_name(key)
    let prefer_shape = is_shape_attached_prop(name)
    let preferred_root = match nt_ns(key) {
      ns if ns.contains("wordprocessingml") => Some("document")
      ns if ns.contains("spreadsheetml") => Some("worksheet")
      ns if ns.contains("presentationml") => Some("sld")
      _ => None
    }
    fn score_path(p : Array[(String, String)]) -> Int {
      let mut s = 0
      match preferred_root {
        Some(root_name) =>
          if p.length() > 0 && p[0].0 == root_name {
            s = s + 1000
          }
        None => ()
      }
      if p.length() == 0 || path_starts_in_primary_root(p) {
        s = s + 100
      }
      if prefer_shape && path_has_shape_host(p) {
        s = s + 10
      }
      s
    }

    // Pair each path with its (negated) score so a stable sort
    // ascending yields highest-score first.  `sort_by` is stable,
    // so paths with equal score preserve their BFS insertion order.
    let scored : Array[(Int, Array[(String, String)])] = []
    for p in paths {
      scored.push((-score_path(p), p))
    }
    scored.sort_by(fn(a, b) {
      if a.0 < b.0 {
        -1
      } else if a.0 > b.0 {
        1
      } else {
        0
      }
    })
    // De-duplicate: the same path can be discovered by both the
    // primary and supplementary BFS pass for elements that appear
    // in multiple types.  Keep the first occurrence (highest score)
    // and drop later duplicates so the verifier doesn't re-try the
    // same chain.
    let ordered : Array[Array[(String, String)]] = []
    let seen : Map[String, Bool] = Map([], capacity=0)
    for entry in scored {
      let p = entry.1
      let buf = StringBuilder::new()
      for step in p {
        buf.write_string(step.0)
        buf.write_char('/')
        buf.write_string(step.1)
        buf.write_char('|')
      }
      let key2 = buf.to_string()
      if !seen.contains(key2) {
        seen[key2] = true
        ordered.push(p)
      }
    }
    ancestry[key] = ordered
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
    Some(i) => key[i + 1:].to_owned()
  }
  match after.find("#") {
    None => after
    Some(j) => after[0:j].to_owned()
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
    "document"
    | "worksheet"
    | "sld"
    | "chartSpace"
    | "dataModel"
    | "layoutDef"
    | "styleDef"
    | "colorsDef"
    | "userShapes" => true
    _ => false
  }
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
  local_name : String,
  value : String,
) -> @xml.Element {
  let attrs : Array[@xml.Attribute] = []
  let mut replaced = false
  for a in el.attributes {
    if a.name.local_name == local_name {
      attrs.push({ name: a.name, value })
      replaced = true
    } else {
      attrs.push(a)
    }
  }
  if !replaced {
    attrs.push({ name: { prefix: None, local_name, ns: None }, value })
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
        let stack : StrSet = Map([], capacity=0)
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
      Element(c) if c.name.local_name == child_name && !replaced => {
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
  if !replaced {
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
  let out : Map[String, Bool] = Map([], capacity=0)
  let ct = match schema.complex_types.get(wrapper_type) {
    Some(c) => c
    None => return out
  }
  let walk_seen : Map[String, Bool] = Map([], capacity=0)
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
    Some(v) => v == "unbounded" || (try? @string.parse_int(v)).unwrap_or(1) > 1
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
    if !choice_unbounded {
      let names : Map[String, Bool] = Map([], capacity=0)
      collect_choice_names(schema, node, Map([], capacity=0), names)
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
        if !walk_seen.contains(gname) {
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
        if !seen_groups.contains(gname) {
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
