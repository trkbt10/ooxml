# G14 — Design

New package: `src/ecma376/presentation_ml/placeholder_resolver/`.

## File layout

```
placeholder_resolver/
  moon.pkg                     -- depends on @xml, @opc_errors, @domain
  types.mbt                    -- PlaceholderType (16), PlaceholderSize
                                  (3), PlaceholderOrient (2),
                                  Placeholder, EffectivePlaceholder,
                                  ResolvedShape, SlideChain + non-trivial
                                  from_attr methods
  decode.mbt                   -- decode_placeholder, decode_shape_placeholder
                                  shape-walk helpers + section_name
  chain.mbt                    -- SlideChain::from_slide,
                                  slide_shapes, layout_shapes, master_shapes
  resolver.mbt                 -- resolve_placeholder, resolve_shape,
                                  merge_effective, lookup_in_level
  resolver_wbtest.mbt          -- ≥6 test blocks
```

## Type sketch

```
pub(all) enum PlaceholderType {
  PhBody PhChart PhClipArt PhCtrTitle PhDgm PhDt PhFtr PhHdr
  PhMedia PhObj PhPic PhSldImg PhSldNum PhSubTitle PhTbl PhTitle
} derive(Eq, Debug)

pub(all) enum PlaceholderSize { SizeFull SizeHalf SizeQuarter } derive(Eq, Debug)
pub(all) enum PlaceholderOrient { OrientHorz OrientVert } derive(Eq, Debug)

pub(all) struct Placeholder {
  idx : Int?
  ph_type : PlaceholderType?
  size : PlaceholderSize?
  orient : PlaceholderOrient?
  has_custom_prompt : Bool
}

pub(all) struct EffectivePlaceholder {
  idx : Int?
  ph_type : PlaceholderType
  size : PlaceholderSize
  orient : PlaceholderOrient
}

pub(all) struct ResolvedShape {
  slide_shape : @xml.Element?
  layout_shape : @xml.Element?
  master_shape : @xml.Element?
  effective_placeholder : EffectivePlaceholder?
  sp_pr : @xml.Element?
  tx_body : @xml.Element?
  nv_sp_pr : @xml.Element?
}

pub(all) struct SlideChain {
  slide : @domain.CT_Slide?
  layout : @domain.CT_SlideLayout?
  master : @domain.CT_SlideMaster
}
```

## Resolution algorithm

```
fn resolve_placeholder(slide_shape, chain) -> ResolvedShape:
  let slide_ph = decode_shape_placeholder(slide_shape)
  let layout_shape =
    chain.layout.and_then(fn(l) {
      let candidate = lookup_by_idx(l.shape_tree(), slide_ph?.idx)
      candidate.or_else(fn() {
        lookup_by_type(l.shape_tree(), slide_ph?.ph_type or layout_default(slide_ph))
      })
    })
  let layout_ph = layout_shape.map(decode_shape_placeholder).flatten()
  let master_shape =
    chain.master.shape_tree().pipe(fn(tree) {
      lookup_by_idx(tree, layout_ph?.idx).or_else(fn() {
        lookup_by_type(tree, type_for_master_lookup(layout_ph, slide_ph))
      })
    })
  let master_ph = master_shape.map(decode_shape_placeholder).flatten()
  let effective = merge_effective(slide_ph, layout_ph, master_ph)
  let sp_pr = merge_first(slide_shape.sp_pr, layout_shape?.sp_pr, master_shape?.sp_pr)
  let tx_body = merge_first(...)
  let nv_sp_pr = merge_first(...)
  ResolvedShape { ... }
```

`type_for_master_lookup` applies the Microsoft compatibility rule:
`ctrTitle` shapes inherit from `title`; `subTitle` shapes also fall
through to `title` when no explicit `subTitle` master placeholder
exists. Other types match identity.

## Cross-package contracts

- The package never raises beyond `@opc_errors.SchemaViolation` from
  malformed `ph` attribute strings.
- Inputs are `@xml.Element` (sourced via the existing `CT_Slide /
  CT_SlideLayout / CT_SlideMaster` element wrappers); the resolver
  does not own decoding of `sp/spPr/txBody` — those stay handled by
  the DML packages downstream.

## SHALLOW resolution

`types.mbt` carries `PlaceholderType::from_attr` (16-arm),
`PlaceholderSize::from_attr` (3-arm), `PlaceholderOrient::from_attr`
(2-arm), `Placeholder::is_default`, `EffectivePlaceholder::section_name`.
Each is >4 lines of non-trivial logic so the SHALLOW gate sees code
in the same file as the type definitions.

## Test plan

- decode_placeholder: idx + type + size + orient, then absent variant.
- shape_placeholder lookup walks nvSpPr/nvPr/ph chain.
- Slide idx-match: slide ph(idx=2), layout ph(idx=2,type=body),
  master ph(type=body) → effective uses slide values, master fills
  defaults.
- Type-match fallback: slide ph(type=body, no idx), layout has no body
  shape, master ph(type=body) → resolves to master, no layout shape.
- ctrTitle→title: layout ph(type=ctrTitle), master ph(type=title) →
  master shape is the title shape.
- Size/orient inheritance: slide ph has no size, layout sets `half`,
  master sets `quarter` → effective_size = `half`.
- Section-name helper returns the canonical citation string.
