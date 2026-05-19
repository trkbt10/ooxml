///|
/// Part 1 §19.7.10 ST_PlaceholderType — placeholder content type. The
/// spec table at §19.7.10 enumerates 16 distinct values that constrain
/// what kind of content a `p:ph` shape contains. The enum names mirror
/// the lexical forms `body`, `chart`, `clipArt`, `ctrTitle`, `dgm`,
/// `dt`, `ftr`, `hdr`, `media`, `obj`, `pic`, `sldImg`, `sldNum`,
/// `subTitle`, `tbl`, `title`.
pub(all) enum PlaceholderType {
  /// §19.7.10 body — body text. Allowed on slide / layout / master /
  /// notes / notes master.
  PhBody
  /// §19.7.10 chart — chart or graph. Allowed on slide / layout.
  PhChart
  /// §19.7.10 clipArt — clip art image. Allowed on slide / layout.
  PhClipArt
  /// §19.7.10 ctrTitle — centred title. Allowed on slide / layout.
  PhCtrTitle
  /// §19.7.10 dgm — diagram. Allowed on slide / layout.
  PhDgm
  /// §19.7.10 dt — date and time. Allowed on every base type.
  PhDt
  /// §19.7.10 ftr — footer text. Allowed on every base type.
  PhFtr
  /// §19.7.10 hdr — header text. Allowed on notes / notes master /
  /// handout master.
  PhHdr
  /// §19.7.10 media — audio / video clip. Allowed on slide / layout.
  PhMedia
  /// §19.7.10 obj — any content. Allowed on slide / layout.
  PhObj
  /// §19.7.10 pic — picture. Allowed on slide / layout.
  PhPic
  /// §19.7.10 sldImg — slide image. Allowed on notes / notes master.
  PhSldImg
  /// §19.7.10 sldNum — slide number. Allowed on every base type.
  PhSldNum
  /// §19.7.10 subTitle — subtitle. Allowed on slide / layout.
  PhSubTitle
  /// §19.7.10 tbl — table. Allowed on slide / layout.
  PhTbl
  /// §19.7.10 title — slide title. Allowed on slide / layout / master.
  PhTitle
} derive(Eq, Debug)

///|
/// Part 1 §19.7.10 — decode a ST_PlaceholderType lexical value to a
/// typed `PlaceholderType`. Raises `SchemaViolation` on any value not
/// in the spec table so callers see the offending lexical form.
pub fn PlaceholderType::from_attr(
  value : String,
) -> PlaceholderType raise @opc_errors.SchemaViolation {
  match value {
    "body" => PhBody
    "chart" => PhChart
    "clipArt" => PhClipArt
    "ctrTitle" => PhCtrTitle
    "dgm" => PhDgm
    "dt" => PhDt
    "ftr" => PhFtr
    "hdr" => PhHdr
    "media" => PhMedia
    "obj" => PhObj
    "pic" => PhPic
    "sldImg" => PhSldImg
    "sldNum" => PhSldNum
    "subTitle" => PhSubTitle
    "tbl" => PhTbl
    "title" => PhTitle
    _ =>
      raise @opc_errors.SchemaViolation(
        section=placeholder_section,
        path="ph/@type",
        reason="unknown ST_PlaceholderType lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.9 ST_PlaceholderSize — placeholder size relative to
/// the body placeholder on the master. Three values: `full`, `half`,
/// `quarter`. `full` is the implicit default when @sz is absent.
pub(all) enum PlaceholderSize {
  SizeFull
  SizeHalf
  SizeQuarter
} derive(Eq, Debug)

///|
/// Part 1 §19.7.9 — decode a ST_PlaceholderSize lexical value.
pub fn PlaceholderSize::from_attr(
  value : String,
) -> PlaceholderSize raise @opc_errors.SchemaViolation {
  match value {
    "full" => SizeFull
    "half" => SizeHalf
    "quarter" => SizeQuarter
    _ =>
      raise @opc_errors.SchemaViolation(
        section=placeholder_section,
        path="ph/@sz",
        reason="unknown ST_PlaceholderSize lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.7.2 ST_Direction — placeholder orientation. Used by
/// `ph/@orient`. Two values: `horz`, `vert`. `horz` is the implicit
/// default per §19.3.1.36.
pub(all) enum PlaceholderOrient {
  OrientHorz
  OrientVert
} derive(Eq, Debug)

///|
/// Part 1 §19.7.2 — decode a ST_Direction lexical value used by
/// `ph/@orient`.
pub fn PlaceholderOrient::from_attr(
  value : String,
) -> PlaceholderOrient raise @opc_errors.SchemaViolation {
  match value {
    "horz" => OrientHorz
    "vert" => OrientVert
    _ =>
      raise @opc_errors.SchemaViolation(
        section=placeholder_section,
        path="ph/@orient",
        reason="unknown ST_Direction lexical value: " + value,
      )
  }
}

///|
/// Part 1 §19.3.1.36 ph — typed placeholder attributes. `idx` is the
/// optional unsignedInt index used for template matching; `ph_type`
/// is the optional §19.7.10 type discriminator; `size` and `orient`
/// hold the optional §19.7.9 / §19.7.2 modifiers; `has_custom_prompt`
/// is the §19.3.1.36 boolean.
pub(all) struct Placeholder {
  idx : Int?
  ph_type : PlaceholderType?
  size : PlaceholderSize?
  orient : PlaceholderOrient?
  has_custom_prompt : Bool
} derive(Eq, Debug)

///|
/// Placeholder::is_default — true when every attribute is at its
/// schema default (no idx, no type, no size, no orient, no custom
/// prompt). Useful for renderers that want to skip emitting a `<ph/>`
/// element when nothing distinguishes the shape.
pub fn Placeholder::is_default(self : Placeholder) -> Bool {
  if self.idx is Some(_) {
    return false
  }
  if self.ph_type is Some(_) {
    return false
  }
  if self.size is Some(_) {
    return false
  }
  if self.orient is Some(_) {
    return false
  }
  if self.has_custom_prompt {
    return false
  }
  true
}

///|
/// Effective placeholder after slide → layout → master inheritance.
/// `ph_type` defaults to `PhBody` and `size` to `SizeFull` per the
/// implicit-defaults rule in §19.7.9 / §19.7.10. `orient` defaults to
/// `OrientHorz` per §19.3.1.36. `idx` is preserved from whichever
/// level supplied it.
pub(all) struct EffectivePlaceholder {
  idx : Int?
  ph_type : PlaceholderType
  size : PlaceholderSize
  orient : PlaceholderOrient
  has_custom_prompt : Bool
} derive(Eq, Debug)

///|
/// EffectivePlaceholder::section_name — canonical Part 1 §19.3.1.36
/// citation string for diagnostics.
pub fn EffectivePlaceholder::section_name(
  self : EffectivePlaceholder,
) -> String {
  let _ = self
  placeholder_section
}

///|
/// Result of resolving a single slide shape against its layout / master
/// chain. The element references survive so callers can pass them into
/// the DML inheritance pass (spPr / txBody / nvSpPr merge).
///
/// `effective_placeholder` is `Some` when the shape is a placeholder
/// (its `nvSpPr/nvPr/ph` is non-empty) and `None` for ordinary shapes.
pub(all) struct ResolvedShape {
  slide_shape : @xml.Element?
  layout_shape : @xml.Element?
  master_shape : @xml.Element?
  effective_placeholder : EffectivePlaceholder?
  sp_pr : @xml.Element?
  tx_body : @xml.Element?
  nv_sp_pr : @xml.Element?
} derive(Eq, Debug)

///|
/// Slide / layout / master chain used as the lookup scope. The slide
/// and layout are optional so layout-only and master-only chains are
/// also supported (e.g. notes pages or layout previews).
pub(all) struct SlideChain {
  slide : @domain.CT_Slide?
  layout : @domain.CT_SlideLayout?
  master : @domain.CT_SlideMaster
} derive(Eq, Debug)

///|
/// SlideChain::from_parts — construct a chain from a master, an
/// optional layout, and an optional slide.
pub fn SlideChain::from_parts(
  master : @domain.CT_SlideMaster,
  layout : @domain.CT_SlideLayout?,
  slide : @domain.CT_Slide?,
) -> SlideChain {
  { master, layout, slide }
}

///|
let placeholder_section : String = "Part 1 §19.3.1.36"

///|
/// Part 1 §19.3.1.36 — citation helper exposed so callers can include
/// the canonical section anchor in their own diagnostics. Returns the
/// string "Part 1 §19.3.1.36".
pub fn placeholder_part1_19_3_1_36_section_name() -> String {
  placeholder_section
}
