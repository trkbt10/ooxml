///|
/// Part 1 §19.3.1.36 ph — find the CT_Shape in `shapes` whose
/// `<ph idx="…">` matches the supplied `idx`. Returns the first match
/// (idx is unique per cSld per spec). `None` when no match exists or
/// `target` is `None`.
fn lookup_by_idx(
  shapes : Array[@domain.CT_Shape],
  target : Int?,
) -> @domain.CT_Shape? {
  match target {
    None => None
    Some(idx) => {
      for shape in shapes {
        match find_shape_ph(shape.element) {
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
/// Part 1 §19.3.1.36 ph / §19.7.10 ST_PlaceholderType — find the
/// CT_Shape in `shapes` whose `<ph type="…">` matches the supplied
/// `target`. Used for type-based fallback when an `idx` lookup fails
/// or when the slide placeholder has no `idx`.
fn lookup_by_type(
  shapes : Array[@domain.CT_Shape],
  target : @domain.ST_PlaceholderType?,
) -> @domain.CT_Shape? {
  match target {
    None => None
    Some(needle) => {
      for shape in shapes {
        match find_shape_ph(shape.element) {
          Some(ph_element) =>
            match attr_local(ph_element, "type") {
              Some(text) =>
                match try_type_from_attr(text) {
                  Some(value) => if value == needle { return Some(shape) }
                  None => ()
                }
              None =>
                // §19.7.10 — body is the implicit default when no @type
                // is present on a master placeholder.
                if needle == @domain.PhBody {
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
  layout_ph : @domain.CT_Placeholder?,
  slide_ph : @domain.CT_Placeholder?,
) -> @domain.ST_PlaceholderType? {
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
    Some(@domain.PhCtrTitle) => Some(@domain.PhTitle)
    Some(@domain.PhSubTitle) => Some(@domain.PhTitle)
    other => other
  }
}

///|
/// Merge slide / layout / master placeholders into an effective view.
/// Slide values win, then layout, then master. Defaults apply per
/// §19.7.9 (`PlaceholderFull`), §19.7.10 (`PhBody`), §19.3.1.36
/// (`DirectionHorz`).
fn merge_effective(
  slide_ph : @domain.CT_Placeholder?,
  layout_ph : @domain.CT_Placeholder?,
  master_ph : @domain.CT_Placeholder?,
) -> EffectivePlaceholder? {
  if slide_ph is None && layout_ph is None && master_ph is None {
    return None
  }
  let layers : Array[@domain.CT_Placeholder] = []
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
  let ph_type = first_type(layers).unwrap_or(@domain.PhBody)
  let size = first_size(layers).unwrap_or(@domain.PlaceholderFull)
  let orient = first_orient(layers).unwrap_or(@domain.DirectionHorz)
  let has_custom_prompt = layers.iter().any(fn(ph) { ph.has_custom_prompt })
  Some({ idx, ph_type, size, orient, has_custom_prompt })
}

///|
/// Part 1 §19.3.1.36 — resolve a single slide shape against its
/// `SlideChain`. The returned `ResolvedShape` carries the contributing
/// CT_Shape projection at each level (slide → layout → master) plus
/// the `EffectivePlaceholder` view and convenience accessors for
/// `sp_pr`, `tx_body`, `nv_sp_pr` taken from the slide / layout /
/// master in that priority order.
pub fn resolve_placeholder(
  slide_shape : @domain.CT_Shape,
  chain : SlideChain,
) -> ResolvedShape raise @domain.SchemaViolation {
  let slide_ph = decode_shape_placeholder(slide_shape.element)
  let layout_shapes = chain.layout_shapes()
  let layout_shape_match = lookup_layout_shape(layout_shapes, slide_ph)
  let layout_ph = match layout_shape_match {
    Some(shape) => decode_shape_placeholder(shape.element)
    None => None
  }
  let master_shapes = chain.master_shapes()
  let master_shape_match = lookup_master_shape(
    master_shapes, layout_ph, slide_ph,
  )
  let master_ph = match master_shape_match {
    Some(shape) => decode_shape_placeholder(shape.element)
    None => None
  }
  let effective = merge_effective(slide_ph, layout_ph, master_ph)
  let sp_pr = merge_sp_pr(
    typed_sp_pr(slide_shape),
    layout_shape_match.bind(fn(s) { typed_sp_pr(s) }),
    master_shape_match.bind(fn(s) { typed_sp_pr(s) }),
  )
  let tx_body = merge_tx_body(
    typed_tx_body(slide_shape),
    layout_shape_match.bind(fn(s) { typed_tx_body(s) }),
    master_shape_match.bind(fn(s) { typed_tx_body(s) }),
  )
  let nv_sp_pr = merge_nv_sp_pr(
    Some(slide_shape.nv_sp_pr),
    layout_shape_match.map(fn(s) { s.nv_sp_pr }),
    master_shape_match.map(fn(s) { s.nv_sp_pr }),
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
) -> Array[ResolvedShape] raise @domain.SchemaViolation {
  let shapes = chain.slide_shapes()
  let result : Array[ResolvedShape] = []
  for shape in shapes {
    result.push(resolve_placeholder(shape, chain))
  }
  result
}

///|
fn lookup_layout_shape(
  layout_shapes : Array[@domain.CT_Shape],
  slide_ph : @domain.CT_Placeholder?,
) -> @domain.CT_Shape? {
  match slide_ph {
    None => None
    Some(ph) => {
      let by_idx = lookup_by_idx(layout_shapes, ph.idx)
      match by_idx {
        Some(found) => Some(found)
        None => {
          let lookup_target = match ph.ph_type {
            Some(@domain.PhCtrTitle) => Some(@domain.PhCtrTitle)
            Some(@domain.PhSubTitle) => Some(@domain.PhSubTitle)
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
  master_shapes : Array[@domain.CT_Shape],
  layout_ph : @domain.CT_Placeholder?,
  slide_ph : @domain.CT_Placeholder?,
) -> @domain.CT_Shape? {
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
/// Project a CT_Shape's `<a:spPr>` raw element into the typed
/// CT_ShapeProperties. Bridge `@a.SchemaViolation` into the local PML
/// SchemaViolation so the resolver surface stays uniform.
fn typed_sp_pr(
  shape : @domain.CT_Shape,
) -> @a.CT_ShapeProperties? raise @domain.SchemaViolation {
  Some(wrap_a_violation(fn() { @a.CT_ShapeProperties::new(shape.sp_pr) }))
}

///|
/// Project a CT_Shape's optional `<a:txBody>` into the typed
/// CT_TextBody.
fn typed_tx_body(
  shape : @domain.CT_Shape,
) -> @a.CT_TextBody? raise @domain.SchemaViolation {
  match shape.tx_body {
    Some(e) => Some(wrap_a_violation(fn() { @a.CT_TextBody::new(e) }))
    None => None
  }
}

///|
/// Bridge `@a.SchemaViolation` (DrawingML) into the local PML
/// SchemaViolation so DrawingML-owned constructors can be invoked
/// from the placeholder_resolver surface without leaking the foreign
/// error type.
fn[T] wrap_a_violation(
  body : () -> T raise @a.SchemaViolation,
) -> T raise @domain.SchemaViolation {
  body() catch {
    @a.SchemaViolation(_) =>
      @domain.schema_violation(
        "placeholder_resolver/typed_sp_pr", "", "DrawingML child failed validation",
      )
  }
}

///|
fn merge_sp_pr(
  slide : @a.CT_ShapeProperties?,
  layout : @a.CT_ShapeProperties?,
  master : @a.CT_ShapeProperties?,
) -> @a.CT_ShapeProperties? {
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
fn merge_tx_body(
  slide : @a.CT_TextBody?,
  layout : @a.CT_TextBody?,
  master : @a.CT_TextBody?,
) -> @a.CT_TextBody? {
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
fn merge_nv_sp_pr(
  slide : @domain.CT_ShapeNonVisual?,
  layout : @domain.CT_ShapeNonVisual?,
  master : @domain.CT_ShapeNonVisual?,
) -> @domain.CT_ShapeNonVisual? {
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
fn first_idx(layers : Array[@domain.CT_Placeholder]) -> Int? {
  for layer in layers {
    match layer.idx {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn first_type(
  layers : Array[@domain.CT_Placeholder],
) -> @domain.ST_PlaceholderType? {
  for layer in layers {
    match layer.ph_type {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn first_size(
  layers : Array[@domain.CT_Placeholder],
) -> @domain.ST_PlaceholderSize? {
  for layer in layers {
    match layer.size {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn first_orient(
  layers : Array[@domain.CT_Placeholder],
) -> @domain.ST_Direction? {
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
/// Part 1 §19.7.10 — best-effort decode of a `p:ph/@type` lexical value
/// to a typed `ST_PlaceholderType`. Returns `None` for unknown values
/// so the resolver can silently skip non-conforming master shapes
/// during fallback lookup instead of aborting the whole resolve. Strict
/// validation lives on `@domain.CT_Placeholder::from_element`.
fn try_type_from_attr(text : String) -> @domain.ST_PlaceholderType? {
  match text {
    "body" => Some(@domain.PhBody)
    "chart" => Some(@domain.PhChart)
    "clipArt" => Some(@domain.PhClipArt)
    "ctrTitle" => Some(@domain.PhCtrTitle)
    "dgm" => Some(@domain.PhDgm)
    "dt" => Some(@domain.PhDt)
    "ftr" => Some(@domain.PhFtr)
    "hdr" => Some(@domain.PhHdr)
    "media" => Some(@domain.PhMedia)
    "obj" => Some(@domain.PhObj)
    "pic" => Some(@domain.PhPic)
    "sldImg" => Some(@domain.PhSldImg)
    "sldNum" => Some(@domain.PhSldNum)
    "subTitle" => Some(@domain.PhSubTitle)
    "tbl" => Some(@domain.PhTbl)
    "title" => Some(@domain.PhTitle)
    _ => None
  }
}
