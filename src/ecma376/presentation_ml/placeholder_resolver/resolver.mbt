///|
/// Part 1 §19.3.1.36 ph — find the shape in `shapes` whose `<ph idx="…">`
/// matches the supplied `idx`. Returns the first match (idx is unique
/// per cSld per spec). `None` when no match exists or `target` is `None`.
fn lookup_by_idx(shapes : Array[@xml.Element], target : Int?) -> @xml.Element? {
  match target {
    None => None
    Some(idx) => {
      for shape in shapes {
        match find_shape_ph(shape) {
          Some(ph_element) =>
            for a in ph_element.attributes {
              if a.name.local_name == "idx" {
                match parse_idx_strict(a.value) {
                  Some(value) => if value == idx { return Some(shape) }
                  None => ()
                }
              }
            }
          None => ()
        }
      }
      None
    }
  }
}

///|
/// Part 1 §19.3.1.36 ph — find the shape in `shapes` whose `<ph type="…">`
/// matches the supplied `target`. Used for type-based fallback when an
/// `idx` lookup fails or when the slide placeholder has no `idx`.
fn lookup_by_type(
  shapes : Array[@xml.Element],
  target : PlaceholderType?,
) -> @xml.Element? {
  match target {
    None => None
    Some(needle) => {
      for shape in shapes {
        match find_shape_ph(shape) {
          Some(ph_element) =>
            match attr_local(ph_element, "type") {
              Some(text) =>
                match try_from_attr(text) {
                  Some(value) => if value == needle { return Some(shape) }
                  None => ()
                }
              None =>
                // §19.7.10 — body is the implicit default when no @type
                // is present on a master placeholder.
                if needle == PhBody {
                  return Some(shape)
                }
            }
          None => ()
        }
      }
      None
    }
  }
}

///|
/// Microsoft compatibility mapping cited in `pptx/src/parser/theme`:
/// `ctrTitle` shapes inherit from the master `title`; `subTitle`
/// shapes also fall back to `title` when no explicit `subTitle`
/// master placeholder exists. All other types match identity.
fn type_for_master_lookup(
  layout_ph : Placeholder?,
  slide_ph : Placeholder?,
) -> PlaceholderType? {
  let direct = match layout_ph {
    Some(ph) => ph.ph_type
    None => None
  }
  let from_slide = match slide_ph {
    Some(ph) => ph.ph_type
    None => None
  }
  let resolved = match direct {
    Some(t) => Some(t)
    None => from_slide
  }
  match resolved {
    Some(PhCtrTitle) => Some(PhTitle)
    Some(PhSubTitle) => Some(PhTitle)
    other => other
  }
}

///|
/// Merge slide / layout / master placeholders into an effective view.
/// Slide values win, then layout, then master. Defaults apply per
/// §19.7.9 (`SizeFull`), §19.7.10 (`PhBody`), §19.3.1.36
/// (`OrientHorz`).
fn merge_effective(
  slide_ph : Placeholder?,
  layout_ph : Placeholder?,
  master_ph : Placeholder?,
) -> EffectivePlaceholder? {
  if slide_ph is None && layout_ph is None && master_ph is None {
    return None
  }
  let layers : Array[Placeholder] = []
  match slide_ph {
    Some(ph) => layers.push(ph)
    None => ()
  }
  match layout_ph {
    Some(ph) => layers.push(ph)
    None => ()
  }
  match master_ph {
    Some(ph) => layers.push(ph)
    None => ()
  }
  let idx = first_idx(layers)
  let ph_type = first_type(layers).unwrap_or(PhBody)
  let size = first_size(layers).unwrap_or(SizeFull)
  let orient = first_orient(layers).unwrap_or(OrientHorz)
  let has_custom_prompt = layers.iter().any(fn(ph) { ph.has_custom_prompt })
  Some({ idx, ph_type, size, orient, has_custom_prompt })
}

///|
/// Part 1 §19.3.1.36 — resolve a single slide shape against its
/// `SlideChain`. The returned `ResolvedShape` carries the contributing
/// element at each level (slide → layout → master) plus the
/// `EffectivePlaceholder` view and convenience accessors for `sp_pr`,
/// `tx_body`, `nv_sp_pr` taken from the slide / layout / master in
/// that priority order.
pub fn resolve_placeholder(
  slide_shape : @xml.Element,
  chain : SlideChain,
) -> ResolvedShape raise @opc_errors.SchemaViolation {
  let slide_ph = decode_shape_placeholder(slide_shape)
  let layout_shapes = chain.layout_shapes()
  let layout_shape_match = lookup_layout_shape(layout_shapes, slide_ph)
  let layout_ph = match layout_shape_match {
    Some(shape) => decode_shape_placeholder(shape)
    None => None
  }
  let master_shapes = chain.master_shapes()
  let master_shape_match = lookup_master_shape(
    master_shapes, layout_ph, slide_ph,
  )
  let master_ph = match master_shape_match {
    Some(shape) => decode_shape_placeholder(shape)
    None => None
  }
  let effective = merge_effective(slide_ph, layout_ph, master_ph)
  let sp_pr = merge_first(
    shape_sp_pr(slide_shape),
    layout_shape_match.bind(fn(s) { shape_sp_pr(s) }),
    master_shape_match.bind(fn(s) { shape_sp_pr(s) }),
  )
  let tx_body = merge_first(
    shape_tx_body(slide_shape),
    layout_shape_match.bind(fn(s) { shape_tx_body(s) }),
    master_shape_match.bind(fn(s) { shape_tx_body(s) }),
  )
  let nv_sp_pr = merge_first(
    shape_nv_sp_pr(slide_shape),
    layout_shape_match.bind(fn(s) { shape_nv_sp_pr(s) }),
    master_shape_match.bind(fn(s) { shape_nv_sp_pr(s) }),
  )
  {
    slide_shape: Some(slide_shape),
    layout_shape: layout_shape_match,
    master_shape: master_shape_match,
    effective_placeholder: effective,
    sp_pr,
    tx_body,
    nv_sp_pr,
  }
}

///|
/// Convenience: resolve every slide shape in the chain. Shapes without
/// `nvSpPr/nvPr/ph` are still returned (with `effective_placeholder`
/// = None) so callers can render them in document order.
pub fn resolve_slide_shapes(
  chain : SlideChain,
) -> Array[ResolvedShape] raise @opc_errors.SchemaViolation {
  let shapes = chain.slide_shapes()
  let result : Array[ResolvedShape] = []
  for shape in shapes {
    result.push(resolve_placeholder(shape, chain))
  }
  result
}

///|
fn lookup_layout_shape(
  layout_shapes : Array[@xml.Element],
  slide_ph : Placeholder?,
) -> @xml.Element? {
  match slide_ph {
    None => None
    Some(ph) => {
      let by_idx = lookup_by_idx(layout_shapes, ph.idx)
      match by_idx {
        Some(found) => Some(found)
        None => {
          let lookup_target = match ph.ph_type {
            Some(PhCtrTitle) => Some(PhCtrTitle)
            Some(PhSubTitle) => Some(PhSubTitle)
            other => other
          }
          lookup_by_type(layout_shapes, lookup_target)
        }
      }
    }
  }
}

///|
fn lookup_master_shape(
  master_shapes : Array[@xml.Element],
  layout_ph : Placeholder?,
  slide_ph : Placeholder?,
) -> @xml.Element? {
  let layout_idx = match layout_ph {
    Some(ph) => ph.idx
    None => None
  }
  let by_idx = lookup_by_idx(master_shapes, layout_idx)
  match by_idx {
    Some(found) => Some(found)
    None =>
      lookup_by_type(master_shapes, type_for_master_lookup(layout_ph, slide_ph))
  }
}

///|
fn merge_first(
  slide : @xml.Element?,
  layout : @xml.Element?,
  master : @xml.Element?,
) -> @xml.Element? {
  match slide {
    Some(_) => slide
    None =>
      match layout {
        Some(_) => layout
        None => master
      }
  }
}

///|
fn first_idx(layers : Array[Placeholder]) -> Int? {
  for layer in layers {
    match layer.idx {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn first_type(layers : Array[Placeholder]) -> PlaceholderType? {
  for layer in layers {
    match layer.ph_type {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn first_size(layers : Array[Placeholder]) -> PlaceholderSize? {
  for layer in layers {
    match layer.size {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn first_orient(layers : Array[Placeholder]) -> PlaceholderOrient? {
  for layer in layers {
    match layer.orient {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn attr_local(element : @xml.Element, local_name : String) -> String? {
  for a in element.attributes {
    if a.name.local_name == local_name {
      return Some(a.value)
    }
  }
  None
}

///|
fn parse_idx_strict(text : String) -> Int? {
  let mut value = 0
  if text.length() == 0 {
    return None
  }
  for i in 0..<text.length() {
    let unit = text.code_unit_at(i).to_int()
    if unit < 0x30 || unit > 0x39 {
      return None
    }
    value = value * 10 + (unit - 0x30)
  }
  Some(value)
}

///|
fn try_from_attr(text : String) -> PlaceholderType? {
  match text {
    "body" => Some(PhBody)
    "chart" => Some(PhChart)
    "clipArt" => Some(PhClipArt)
    "ctrTitle" => Some(PhCtrTitle)
    "dgm" => Some(PhDgm)
    "dt" => Some(PhDt)
    "ftr" => Some(PhFtr)
    "hdr" => Some(PhHdr)
    "media" => Some(PhMedia)
    "obj" => Some(PhObj)
    "pic" => Some(PhPic)
    "sldImg" => Some(PhSldImg)
    "sldNum" => Some(PhSldNum)
    "subTitle" => Some(PhSubTitle)
    "tbl" => Some(PhTbl)
    "title" => Some(PhTitle)
    _ => None
  }
}
