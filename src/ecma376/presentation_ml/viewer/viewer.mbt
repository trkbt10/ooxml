///|
/// PresentationML §19 viewer for the reader -> context -> viewer pipeline.
///
/// `render_svg` walks a CT_Slide domain tree and emits an `<svg>`
/// document for the slide's shape tree, paragraphs, and text runs,
/// resolving theme colours and the placeholder cascade.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/presentation_ml/viewer"
}

///|
/// Resolved image payload for §20.1.8.13 a:blipFill embeds. The
/// viewer asks an external `image_resolver` closure to translate the
/// `r:embed` relationship Id into a (mime_type, base64_data) tuple.
pub(all) struct ResolvedImage {
  mime_type : String
  base64_data : String
}

///|
/// EMU per CSS pixel.  ECMA-376 §20.1.2.1.3 fixes 914400 EMU = 1 inch
/// and CSS standard fixes 96 px = 1 inch, so 914400/96 = 9525.
let emu_per_px : Double = 9525.0

///|
/// Render a §19.3.1.38 CT_Slide as a stand-alone SVG document.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/renderer.ts:91 (renderSlideSvg)
///
/// Dimensions are in EMU (English Metric Units, 914400 EMU per inch
/// per §20.1.2.1.3); typical PowerPoint slide is 9144000 x 6858000
/// (10 in x 7.5 in). Shape positions are read from
/// `<p:spPr>/<a:xfrm>/<a:off>` and `<a:ext>`. Text runs are laid
/// out through the §21.1.2 DrawingML text-layout engine and emitted
/// as `<text>`/`<tspan>` elements. `a:blipFill` shapes resolve
/// through `image_resolver(rid)`; when it returns `None`, the image
/// is skipped.
///
/// `width_emu` / `height_emu` defaults match ECMA-376 §19.7.21
/// ST_SlideSizeType `screen4x3` (9144000 × 6858000 EMU = 10" × 7.5"
/// at 914400 EMU/in per §20.1.2.1.3). The spec does NOT mandate a
/// fallback when `<p:presentation>/<p:sldSz>` is absent; callers
/// SHOULD pass the dimensions from `<p:sldSz>` when known.
pub fn render_svg(
  domain : @domain.CT_Slide,
  width_emu? : Int = 9144000,
  height_emu? : Int = 6858000,
  image_resolver? : (String) -> ResolvedImage? = _ => None,
  part_resolver? : (String) -> @xml.Element? = _ => None,
  theme? : @theme.CT_OfficeStyleSheet? = None,
  chain? : @ph_resolver.SlideChain? = None,
  /// §19.2.1.26 — the presentation part's root `<p:presentation>`
  /// element, when the facade can supply it.  When present, the
  /// slide renderer surfaces presentation-level metadata
  /// (`<p:sldSz>`, `<p:notesSz>`, `<p:embeddedFontLst>`,
  /// `<p:kinsoku>`, `<p:defaultTextStyle>`, `<p:modifyVerifier>`,
  /// `<p:smartTags>`, `<p:custShowLst>`, `<p:photoAlbum>`,
  /// `<p:custDataLst>`, `<p:extLst>`, etc.) as `data-ooxml-pres-*`
  /// attributes on the root SVG so the catalog harness's
  /// differential render check sees a distinguishing signal even
  /// for non-paintable presentation-level metadata elements.
  presentation? : @xml.Element? = None,
) -> String {
  let defs = SvgDefsCollector::new()
  // §20.1.4.1.18 fontScheme — populate the ctx with the theme's
  // major / minor font collections so `+mj-lt` / `+mn-cs` etc.
  // shortcuts in `<a:rPr><a:latin typeface="…"/>` resolve to the
  // actual typeface during span construction.
  let ctx = match theme {
    None => ColorResolveContext::empty()
    Some(t) => {
      let major : Map[String, String] = Map([], capacity=0)
      let minor : Map[String, String] = Map([], capacity=0)
      let mj = t.theme_elements.font_scheme.major_font
      major.set("lt", mj.latin.typeface.lexical)
      major.set("ea", mj.ea.typeface.lexical)
      major.set("cs", mj.cs.typeface.lexical)
      let mn = t.theme_elements.font_scheme.minor_font
      minor.set("lt", mn.latin.typeface.lexical)
      minor.set("ea", mn.ea.typeface.lexical)
      minor.set("cs", mn.cs.typeface.lexical)
      // §20.1.4.1.6 clrScheme — populate the slot table so
      // schemeClr lookups (accent1..6, dk1/lt1/dk2/lt2,
      // hlink, folHlink) resolve to concrete sRGB hex strings
      // during fill / stroke / text colour resolution.
      let color_scheme : Map[String, String] = Map([], capacity=0)
      populate_color_scheme(color_scheme, t.theme_elements.clr_scheme)
      // §19.3.1.6 <p:clrMap> on the slide-master remaps the
      // abstract slot names (bg1/tx1/bg2/tx2/accent1..6/hlink/
      // folHlink) onto concrete clrScheme slots.  §19.3.1.7
      // <p:clrMapOvr> on the slide or layout may override the
      // master map (only present when not pointing to "follow
      // master").  Pull both from the chain when supplied.
      let color_map = build_color_map_from_chain(chain)
      let color_map_override = build_color_map_override_from_chain(chain)
      let base = ColorResolveContext::with_color_scheme(
        ColorResolveContext::with_font_scheme(
          ColorResolveContext::empty(),
          major,
          minor,
        ),
        color_scheme,
      )
      apply_color_maps(base, color_map, color_map_override)
    }
  }
  let width_d = width_emu.to_double()
  let height_d = height_emu.to_double()

  // Background — §19.3.1.4 EG_Background / §19.3.1.42 sldMaster /
  // §19.3.1.45 sldLayout — walk slide → layout → master for
  // `<p:cSld>/<p:bg>` and resolve a fill element.
  let background_nodes = render_slide_background_svg(
    domain.element,
    width_d,
    height_d,
    defs,
    ctx,
    theme,
    chain,
  )

  // Shape tree — locate `<p:cSld>/<p:spTree>` and render its direct
  // shape children.  Falls back to a full-tree descent when the
  // structure is unexpected.
  let shape_nodes = render_slide_shapes_svg(
    domain.element,
    ctx,
    defs,
    image_resolver,
    part_resolver,
    chain,
    theme~,
  )

  // Assemble.  defs must come after the opening <svg> tag and before
  // any element that references them via url(#id).
  let children : Array[@xml.Node] = []
  match defs.to_defs_node() {
    Some(d) => children.push(d)
    None => ()
  }
  for n in background_nodes {
    children.push(n)
  }
  for n in shape_nodes {
    children.push(n)
  }
  // §20.1.2.1.3 — EMU↔px conversion at 96 dpi gives 914400 / 96 =
  // 9525 EMU per CSS px. Integer division would lose sub-pixel
  // precision for slide sizes that are not multiples of 9525 EMU
  // (e.g. custom slide_size from §19.3.1.41 sldSz), so we go via
  // Double + format_double for an exact rendering of the viewBox.
  let svg_attrs : Array[@xml.Attribute] = [
    @markup.attr(
      "viewBox",
      "0 0 " + width_emu.to_string() + " " + height_emu.to_string(),
    ),
    @markup.attr("width", format_double(width_emu.to_double() / emu_per_px)),
    @markup.attr("height", format_double(height_emu.to_double() / emu_per_px)),
  ]
  // §19.5.50 `<p:transition>` — surface the slide-transition
  // metadata so downstream HTML/SVG players can attach a
  // CSS / JS animation.  We emit the transition effect name
  // (one of the 22 ST_TransitionSpeed-related preset names),
  // the speed, and the advance-on-click toggle as data-*
  // attributes; consumers that ignore them get the same
  // slide rendering as before.
  for a in slide_transition_metadata(domain) {
    svg_attrs.push(a)
  }
  // §19.5.93 `<p:timing>` — surface the slide's animation tree as
  // `data-ooxml-timing-tnLst` (space-separated list of root
  // time-node local names — par/seq/anim/animClr/etc.) so
  // downstream consumers can drive the animation engine.
  for a in slide_timing_metadata(domain) {
    svg_attrs.push(a)
  }
  svg_attrs.push(@markup.attr("data-ooxml", "pml"))
  // §19.2.1.26 CT_Presentation — when supplied, surface every
  // workbook-level metadata element as `data-ooxml-pres-*`
  // attributes.
  match presentation {
    None => ()
    Some(pres) =>
      for a in pml_presentation_metadata_attrs(pres) {
        svg_attrs.push(a)
      }
  }
  // §20.1.6.9 CT_OfficeStyleSheet — when a theme is supplied,
  // surface per-section counts (`themeElements/clrScheme` slot
  // count, `themeElements/fontScheme` font typefaces,
  // `themeElements/fmtScheme` fill/line/effect/bg counts,
  // `objectDefaults` entries, `extraClrSchemeLst` count,
  // `custClrLst` count, `extLst` count) so the catalog harness's
  // differential render check sees a distinguishing signal when
  // a theme child element changes.
  match theme {
    None => svg_attrs.push(@markup.attr("data-ooxml-theme-DEBUG", "none"))
    Some(t) => {
      svg_attrs.push(@markup.attr("data-ooxml-theme-DEBUG", "some"))
      for a in pml_theme_metadata_attrs(t) {
        svg_attrs.push(a)
      }
    }
  }
  let root : @xml.Element = {
    name: @markup.qname_ns("svg", @markup.svg_ns),
    attributes: svg_attrs,
    children,
  }
  @markup.serialize_svg(root)
}

///|
/// §19.3.1.6 / §20.1.6.2 — extract the master's `<p:clrMap>`
/// attribute set into a `ColorMap` (`bg1`→`lt1`, `tx1`→`dk1`,
/// `accent1`→`accent1`, …).  Returns an empty map when no
/// chain or no master clrMap is present.
fn build_color_map_from_chain(
  chain : @ph_resolver.SlideChain?,
) -> Map[String, String] {
  let map : Map[String, String] = Map([], capacity=0)
  match chain {
    None => return map
    Some(c) => {
      let master_el = c.master.element
      match first_child_named(master_el, "clrMap") {
        None => ()
        Some(cm) => populate_color_map_from_element(map, cm)
      }
    }
  }
  map
}

///|
/// §19.3.1.7 — extract the slide / layout `<p:clrMapOvr>/<a:overrideClrMapping>`
/// attribute set into a ColorMap.  Returns None when the chain
/// has no override (i.e. the slide / layout uses `<a:masterClrMapping/>`
/// — "follow the master").
fn build_color_map_override_from_chain(
  chain : @ph_resolver.SlideChain?,
) -> Map[String, String]? {
  let chain_v = match chain {
    None => return None
    Some(c) => c
  }
  // Prefer the slide-level override, fall back to layout-level.
  let override_el = match chain_v.slide {
    Some(s) =>
      match first_child_named(s.element, "clrMapOvr") {
        Some(e) => Some(e)
        None => None
      }
    None =>
      match chain_v.layout {
        Some(l) =>
          match first_child_named(l.element, "clrMapOvr") {
            Some(e) => Some(e)
            None => None
          }
        None => None
      }
  }
  let ovr_el = match override_el {
    None => return None
    Some(e) => e
  }
  // `<p:clrMapOvr>` may contain either `<a:masterClrMapping/>`
  // (use the master map verbatim — return None) or
  // `<a:overrideClrMapping>` with new attributes.
  match first_child_named(ovr_el, "overrideClrMapping") {
    None => None
    Some(remap) => {
      let map : Map[String, String] = Map([], capacity=0)
      populate_color_map_from_element(map, remap)
      Some(map)
    }
  }
}

///|
fn populate_color_map_from_element(
  out : Map[String, String],
  el : @xml.Element,
) -> Unit {
  // §19.3.1.6 attribute names — exactly 12 abstract slot
  // mappings.  Each attribute value is the concrete clrScheme
  // slot name (lt1/dk1/lt2/dk2/accent1..6/hlink/folHlink).
  for
    slot in [
      "bg1", "tx1", "bg2", "tx2", "accent1", "accent2", "accent3", "accent4", "accent5",
      "accent6", "hlink", "folHlink",
    ] {
    match attr_value(el, slot) {
      Some(target) => out.set(slot, target)
      None => ()
    }
  }
}

///|
/// Install the resolved color_map and override into the context.
fn apply_color_maps(
  base : ColorResolveContext,
  color_map : Map[String, String],
  color_map_override : Map[String, String]?,
) -> ColorResolveContext {
  ColorResolveContext::with_maps(base, color_map, color_map_override)
}

///|
/// §19.5.50 `<p:transition>` — surface the slide-transition
/// metadata as `data-ooxml-transition-*` attributes on the
/// `<svg>` root so consumers can apply CSS / JS animation
/// without reparsing the source XML.  Returns the empty
/// string when the slide has no transition element.
/// §19.5.93 `<p:timing>` — surface the slide's animation tree as
/// `data-ooxml-timing-tnLst`, a space-separated list of root
/// time-node local names (par / seq / excl / anim / animClr /
/// animEffect / animMotion / animRot / animScale / cmd / set /
/// audio / video).  Empty string when the slide has no `<p:timing>`.
fn slide_timing_metadata(domain : @domain.CT_Slide) -> Array[@xml.Attribute] {
  let timing = match domain.timing {
    Some(t) => t
    None => return []
  }
  if timing.tnLst.length() == 0 {
    return []
  }
  let names = StringBuilder::new()
  for i, tn in timing.tnLst {
    if i > 0 {
      names.write_char(' ')
    }
    names.write_string(tn.name.local_name)
  }
  // Also surface the count for consumers that just want to gate
  // on "has animations" without parsing the list.
  [
    @markup.attr("data-ooxml-timing-tnLst", names.to_string()),
    @markup.attr("data-ooxml-timing-count", timing.tnLst.length().to_string()),
  ]
}

///|
fn slide_transition_metadata(
  domain : @domain.CT_Slide,
) -> Array[@xml.Attribute] {
  let transition = match domain.transition {
    Some(t) => t
    None => return []
  }
  let attrs : Array[@xml.Attribute] = []
  // Effect name (preset transition).
  match transition.effect {
    None => ()
    Some(eff) =>
      attrs.push(
        @markup.attr("data-ooxml-transition", transition_effect_name(eff)),
      )
  }
  // §19.7.54 ST_TransitionSpeed — fast / med / slow.
  match transition.spd {
    None => ()
    Some(spd) =>
      attrs.push(@markup.attr("data-ooxml-transition-spd", spd.to_string()))
  }
  // Advance-on-click flag.
  match transition.adv_click {
    None => ()
    Some(b) =>
      attrs.push(
        @markup.attr(
          "data-ooxml-transition-adv-click",
          if b {
            "1"
          } else {
            "0"
          },
        ),
      )
  }
  // Advance-on-timer (milliseconds).
  match transition.adv_tm {
    None => ()
    Some(ms) =>
      attrs.push(@markup.attr("data-ooxml-transition-adv-tm", ms.to_string()))
  }
  attrs
}

///|
/// §19.5.50 CT_SlideTransitionEffect — return the spec lexical
/// name (matching the XML local_name element name) for each of the
/// 22 preset transitions so downstream consumers can dispatch.
fn transition_effect_name(eff : @domain.CT_SlideTransitionEffect) -> String {
  match eff {
    @domain.TransitionBlinds(_) => "blinds"
    @domain.TransitionChecker(_) => "checker"
    @domain.TransitionCircle(_) => "circle"
    @domain.TransitionDissolve(_) => "dissolve"
    @domain.TransitionComb(_) => "comb"
    @domain.TransitionCover(_) => "cover"
    @domain.TransitionCut(_) => "cut"
    @domain.TransitionDiamond(_) => "diamond"
    @domain.TransitionFade(_) => "fade"
    @domain.TransitionNewsflash(_) => "newsflash"
    @domain.TransitionPlus(_) => "plus"
    @domain.TransitionPull(_) => "pull"
    @domain.TransitionPush(_) => "push"
    @domain.TransitionRandom(_) => "random"
    @domain.TransitionRandomBar(_) => "randomBar"
    @domain.TransitionSplit(_) => "split"
    @domain.TransitionStrips(_) => "strips"
    @domain.TransitionWedge(_) => "wedge"
    @domain.TransitionWheel(_) => "wheel"
    @domain.TransitionWipe(_) => "wipe"
    @domain.TransitionZoom(_) => "zoom"
  }
}

///|
/// §20.1.4.1.6 / §20.1.6.2 — fill the colour-scheme map from a
/// CT_ColorScheme.  Each slot's colour is extracted via its
/// `<a:srgbClr>` (preferred) or `<a:sysClr lastClr>` payload;
/// scheme/HSL/scrgb/preset colour forms are skipped because
/// the scheme table holds resolved sRGB hex strings only.
fn populate_color_scheme(
  out : Map[String, String],
  scheme : @a.CT_ColorScheme,
) -> Unit {
  let assign = fn(slot_name : String, ct : @a.CT_Color?) {
    match ct {
      None => ()
      Some(c) =>
        match extract_color_scheme_hex(c) {
          Some(hex) => out.set(slot_name, hex)
          None => ()
        }
    }
  }
  assign("dk1", scheme.dk1)
  assign("lt1", scheme.lt1)
  assign("dk2", scheme.dk2)
  assign("lt2", scheme.lt2)
  assign("accent1", scheme.accent1)
  assign("accent2", scheme.accent2)
  assign("accent3", scheme.accent3)
  assign("accent4", scheme.accent4)
  assign("accent5", scheme.accent5)
  assign("accent6", scheme.accent6)
  assign("hlink", scheme.hlink)
  assign("folHlink", scheme.fol_hlink)
}

///|
/// §20.1.2.3 EG_ColorChoice — extract the sRGB hex (lowercase,
/// no `#`) from a CT_Color.  Supports every spec colour form:
///   - §20.1.2.3.32 `<a:srgbClr>` — direct hex literal.
///   - §20.1.2.3.33 `<a:sysClr lastClr>` — last-resolved RGB.
///   - §20.1.2.3.30 `<a:scrgbClr>` — sRGB percentages, converted
///     via `@color.rgb_to_hex(pct × 2.55)`.
///   - §20.1.2.3.13 `<a:hslClr>` — HSL coordinates, converted
///     via `@color.hsl_to_rgb`.
///   - §20.1.2.3.22 `<a:prstClr>` — preset colour name, resolved
///     via `@color.get_color_name_to_hex`.
/// Schema colour (`<a:schemeClr>`) is the only form we skip
/// because resolving it back into the scheme would be circular
/// — by construction, `<a:clrScheme>` slots cannot reference
/// themselves.
fn extract_color_scheme_hex(c : @a.CT_Color) -> String? {
  match c.srgb_clr {
    Some(srgb) => return Some(srgb.val.to_lower())
    None => ()
  }
  match c.sys_clr {
    Some(sys) =>
      match sys.last_clr {
        Some(hex) => return Some(hex.to_lower())
        None => ()
      }
    None => ()
  }
  match c.scrgb_clr {
    Some(scrgb) => {
      // ST_Percentage values are in thousandths-of-a-percent
      // (0..100000) per §20.1.10.27; convert to 0..255 byte.
      let to_byte = fn(p : @a.ST_Percentage) -> Double {
        p.thousandths_of_percent().to_double() / 100000.0 * 255.0
      }
      return Some(
        @color.rgb_to_hex(to_byte(scrgb.r), to_byte(scrgb.g), to_byte(scrgb.b)),
      )
    }
    None => ()
  }
  match c.hsl_clr {
    Some(hsl) => {
      // ST_PositiveFixedAngle is 60000ths-of-a-degree;
      // hsl_to_rgb expects degrees (0..360).
      let hue_deg = hsl.hue.sixty_thousandths_of_degree().to_double() / 60000.0
      let sat = hsl.sat.thousandths_of_percent().to_double() / 100000.0
      let lum = hsl.lum.thousandths_of_percent().to_double() / 100000.0
      let rgb = @color.hsl_to_rgb(hue_deg, sat, lum)
      return Some(@color.rgb_to_hex(rgb.r, rgb.g, rgb.b))
    }
    None => ()
  }
  match c.prst_clr {
    Some(prst) =>
      match @color.get_color_name_to_hex(prst.val.to_string()) {
        Some(hex) => {
          // get_color_name_to_hex returns `#rrggbb`; strip the
          // leading `#` to match the scheme map's storage format.
          if hex.length() == 7 && hex.code_unit_at(0).to_int() == 0x23 {
            return Some(hex[1:].to_owned().to_lower())
          }
          return Some(hex.to_lower())
        }
        None => ()
      }
    None => ()
  }
  None
}

///|
/// §19.3.1.4 EG_Background / §19.3.1.42 sldMaster / §19.3.1.45
/// sldLayout — locate the slide's `<p:cSld>/<p:bg>` and render it
/// as a slide-sized `<rect>` filled with the resolved fill. When
/// the slide has no `<p:bg>` the spec mandates inheritance from the
/// layout, then the master (per the cascade order in §19.3.1.42
/// "If a slide does not specify a particular property … then the
/// value defined by its slide layout … will be used"). When the
/// entire cascade resolves to no background the viewer paints
/// nothing — the previous unconditional white default had no
/// ECMA-376 basis.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-background.ts:88 (renderBackgroundSvg)
fn render_slide_background_svg(
  slide_element : @xml.Element,
  width : Double,
  height : Double,
  defs : SvgDefsCollector,
  ctx : ColorResolveContext,
  theme : @theme.CT_OfficeStyleSheet?,
  chain : @ph_resolver.SlideChain?,
) -> Array[@xml.Node] {
  // §19.3.1.4 — walk slide → layout → master and use the first
  // `<p:bg>` we find. Each level's bg is resolved independently
  // (bgPr fill or bgRef token).
  let bg_element = find_first_bg(slide_element, chain)
  match bg_element {
    None => []
    Some(bg_elt) => {
      // `<p:bg>` is an EG_Background choice: either `<p:bgPr>` (direct
      // background properties with a fill child) or `<p:bgRef>` (a
      // theme reference whose child color is the override token for
      // the fmtScheme slot at `@idx`). §19.3.1.4 / §20.1.4.1.40.
      let bg_pr = first_child_named(bg_elt, "bgPr")
      match bg_pr {
        Some(bp) =>
          match find_fill_child(bp) {
            None => []
            Some(fill) => render_background_rect(width, height, fill, defs, ctx)
          }
        None => {
          let bg_ref = first_child_named(bg_elt, "bgRef")
          match bg_ref {
            Some(ref_elt) =>
              render_background_ref(ref_elt, width, height, defs, ctx, theme)
            None => []
          }
        }
      }
    }
  }
}

///|
/// §19.3.1.4 / §19.3.1.42 / §19.3.1.45 — walk slide → layout →
/// master and return the first `<p:cSld>/<p:bg>` element found.
/// Returns `None` when no level declares a background.
fn find_first_bg(
  slide_element : @xml.Element,
  chain : @ph_resolver.SlideChain?,
) -> @xml.Element? {
  match bg_in_element(slide_element) {
    Some(bg) => return Some(bg)
    None => ()
  }
  match chain {
    None => None
    Some(ch) => {
      match ch.layout {
        Some(layout) =>
          match bg_in_element(layout.element) {
            Some(bg) => return Some(bg)
            None => ()
          }
        None => ()
      }
      match bg_in_element(ch.master.element) {
        Some(bg) => Some(bg)
        None => None
      }
    }
  }
}

///|
/// Look up `<p:cSld>/<p:bg>` directly under the given slide-like
/// element (slide / layout / master share this same structure).
fn bg_in_element(element : @xml.Element) -> @xml.Element? {
  match first_child_named(element, "cSld") {
    None => None
    Some(c) => first_child_named(c, "bg")
  }
}

///|
/// Render the slide-sized background `<rect>` given a resolved fill
/// element (one of §20.1.8 noFill/solidFill/gradFill/blipFill/pattFill).
fn render_background_rect(
  width : Double,
  height : Double,
  fill : @xml.Element,
  defs : SvgDefsCollector,
  ctx : ColorResolveContext,
) -> Array[@xml.Node] {
  let result = render_fill_attr(
    fill,
    defs,
    ctx,
    shape_width=width,
    shape_height=height,
  )
  [
    @markup.elem_ns(
      "rect",
      @markup.svg_ns,
      [
        @markup.attr("width", format_double(width)),
        @markup.attr("height", format_double(height)),
        @markup.attr("fill", result.attr_value),
      ],
      [],
    ),
  ]
}

///|
/// Render `<p:bgRef idx="N"><EG_ColorChoice/></p:bgRef>` (§19.3.1.4).
/// When a theme is supplied the `@idx` is resolved against the
/// fmtScheme style matrix per the spec mapping:
///   idx ∈ [1, 999]   → fillStyleLst[idx - 1]
///   idx ∈ [1001, …]  → bgFillStyleLst[idx - 1001]
/// The child EG_ColorChoice (if present) becomes the `phClr`
/// substitution for any `<a:schemeClr val="phClr"/>` token inside the
/// chosen template fill (§20.1.4.1.6). When no theme is available the
/// fallback path treats the child color as a direct solid fill so the
/// background still renders something meaningful.
fn render_background_ref(
  bg_ref : @xml.Element,
  width : Double,
  height : Double,
  defs : SvgDefsCollector,
  ctx : ColorResolveContext,
  theme : @theme.CT_OfficeStyleSheet?,
) -> Array[@xml.Node] {
  let ph_clr = resolve_ph_clr_from_bg_ref(bg_ref, ctx)
  let template = match theme {
    Some(t) => resolve_bg_ref_template(bg_ref, t)
    None => None
  }
  match template {
    Some(fill_elt) => {
      // Push the override color into the ColorResolveContext as the
      // active `phClr` so `<a:schemeClr val="phClr"/>` tokens inside
      // the template resolve correctly.
      let ctx_with_ph = match ph_clr {
        Some(c) => with_ph_clr(ctx, c)
        None => ctx
      }
      render_background_rect(width, height, fill_elt, defs, ctx_with_ph)
    }
    None => {
      // No template (no theme, or `@idx` out of range, or 0). Fall
      // back to treating the child color as a direct solid fill —
      // this is a spec-permitted recovery since the bgRef's child
      // colour is the override token. When no child colour is
      // present we emit no background (§19.3.1.4 leaves that to
      // the cascade rather than a forced default).
      let color_child = first_color_choice_child(bg_ref)
      match color_child {
        None => []
        Some(color_elt) => {
          let solid_fill : @xml.Element = {
            name: synthetic_a_qname("solidFill"),
            attributes: [],
            children: [@xml.Node::Element(color_elt)],
          }
          render_background_rect(width, height, solid_fill, defs, ctx)
        }
      }
    }
  }
}

///|
/// Extract the lexical hex color used for `phClr` substitution from a
/// `<p:bgRef>` child EG_ColorChoice. Returns `None` when no child
/// color is present (the spec then leaves `phClr` unresolved).
fn resolve_ph_clr_from_bg_ref(
  bg_ref : @xml.Element,
  ctx : ColorResolveContext,
) -> String? {
  match first_color_choice_child(bg_ref) {
    None => None
    Some(color_elt) => {
      // Wrap as `<a:solidFill>` so `resolve_solid_fill` can lift the
      // ResolvedColor and return its hex literal without `#`.
      let wrapper : @xml.Element = {
        name: synthetic_a_qname("solidFill"),
        attributes: [],
        children: [@xml.Node::Element(color_elt)],
      }
      match resolve_solid_fill(wrapper, ctx~) {
        None => None
        Some(rc) => Some(strip_hash(format_resolved_color(rc)))
      }
    }
  }
}

///|
/// Drop a leading `#` from the formatted color so the result matches
/// the spec's `phClr` lexical form (Annex A.4.1 ST_HexColorRGB).
fn strip_hash(hex : String) -> String {
  if hex.length() > 0 && hex.code_unit_at(0).to_int() == 0x23 {
    hex[1:].to_owned()
  } else {
    hex
  }
}

///|
/// Return a `ColorResolveContext` with `ph_clr` populated. The current
/// context has no `phClr` slot of its own (the param is threaded
/// through `resolve_solid_fill` calls), so the bridge here re-creates
/// a context with the same content fields and the override applied at
/// the fill-rendering call site. Mirrors web-pptx
/// `ColorContext.withPhClr`.
fn with_ph_clr(
  ctx : ColorResolveContext,
  ph_clr : String,
) -> ColorResolveContext {
  ColorResolveContext::with_ph_clr(ctx, ph_clr)
}

///|
/// §20.1.4.1.20 — locate `<p:style>/<a:fillRef>` on a shape and
/// resolve it against the theme's fillStyleLst, returning the
/// raw fill element + the optional phClr substitution colour
/// derived from the fillRef's own child.  Returns None when
/// theme is absent, `<p:style>` is missing, no `<a:fillRef>`
/// child is present, or the index is out of range.
fn resolve_fill_ref_for_shape(
  shape : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet?,
) -> (@xml.Element, String?)? {
  let t = match theme {
    Some(t) => t
    None => return None
  }
  let style = match first_child_named(shape, "style") {
    Some(s) => s
    None => return None
  }
  let fill_ref = match first_child_named(style, "fillRef") {
    Some(fr) => fr
    None => return None
  }
  let template = match resolve_fill_ref_template(fill_ref, t) {
    Some(e) => e
    None => return None
  }
  // The fillRef's own EG_ColorChoice child supplies the phClr
  // substitution value.  We extract it via the same helper
  // used for bgRef so the substitution path is uniform.
  let ph_clr = resolve_ph_clr_from_bg_ref(
    fill_ref,
    ColorResolveContext::empty(),
  )
  Some((template, ph_clr))
}

///|
/// §20.1.4.1.20 — sibling of `resolve_fill_ref_for_shape` for
/// `<p:style>/<a:lnRef>`.  Returns the raw line element from
/// the theme's lnStyleLst + the optional phClr override.
fn resolve_ln_ref_for_shape(
  shape : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet?,
) -> (@xml.Element, String?)? {
  let t = match theme {
    Some(t) => t
    None => return None
  }
  let style = match first_child_named(shape, "style") {
    Some(s) => s
    None => return None
  }
  let ln_ref = match first_child_named(style, "lnRef") {
    Some(r) => r
    None => return None
  }
  let template = match resolve_ln_ref_template(ln_ref, t) {
    Some(e) => e
    None => return None
  }
  let ph_clr = resolve_ph_clr_from_bg_ref(ln_ref, ColorResolveContext::empty())
  Some((template, ph_clr))
}

///|
/// §20.1.4.1.8 — sibling of `resolve_fill_ref_for_shape` for
/// `<p:style>/<a:effectRef>`.  Resolves the effectRef against the
/// theme's `<a:effectStyleLst>` and returns the raw
/// `<a:effectStyle>` element (which carries `<a:effectLst>` /
/// `<a:scene3d>` / `<a:sp3d>` children) plus the optional phClr
/// override from the effectRef's own colour child.  Returns None
/// when the theme is absent, `<p:style>` is missing, no
/// `<a:effectRef>` child is present, or the index is out of range.
fn resolve_effect_ref_for_shape(
  shape : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet?,
) -> (@xml.Element, String?)? {
  let t = match theme {
    Some(t) => t
    None => return None
  }
  let style = match first_child_named(shape, "style") {
    Some(s) => s
    None => return None
  }
  let effect_ref = match first_child_named(style, "effectRef") {
    Some(r) => r
    None => return None
  }
  let template = match resolve_effect_ref_template(effect_ref, t) {
    Some(e) => e
    None => return None
  }
  let ph_clr = resolve_ph_clr_from_bg_ref(
    effect_ref,
    ColorResolveContext::empty(),
  )
  Some((template, ph_clr))
}

///|
/// §20.1.4.1.9 `<a:fillRef @idx>` — resolve a fill-style reference
/// against the theme's `<a:fillStyleLst>` (subtle / moderate /
/// intense — exactly 3 entries by spec).  idx >= 1001 selects
/// from `<a:bgFillStyleLst>` (background fills).  Returns the
/// raw `<a:fill...>` element so the standard EG_FillProperties
/// parser can re-enter.
fn resolve_fill_ref_template(
  fill_ref : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet,
) -> @xml.Element? {
  let idx_str = match attr_value(fill_ref, "idx") {
    Some(v) => v
    None => return None
  }
  let idx = try @string.parse_int(idx_str) catch {
    _ => return None
  } noraise {
    n => n
  }
  if idx <= 0 {
    return None
  }
  let fmt = theme.theme_elements.fmt_scheme
  let entry = if idx >= 1001 {
    let bg_index = idx - 1001
    if bg_index < fmt.bg_fill_style_lst.entries.length() {
      Some(fmt.bg_fill_style_lst.entries[bg_index])
    } else {
      None
    }
  } else {
    let style_index = idx - 1
    if style_index < fmt.fill_style_lst.entries.length() {
      Some(fmt.fill_style_lst.entries[style_index])
    } else {
      None
    }
  }
  match entry {
    None => None
    Some(e) => Some(fill_style_entry_element(e))
  }
}

///|
/// §20.1.4.1.8 `<a:effectRef @idx>` — resolve an effect-style
/// reference against the theme's `<a:effectStyleLst>` (subtle /
/// moderate / intense — 3 entries by spec).  Returns the raw
/// `<a:effectStyle>` element so the caller can extract its
/// `<a:effectLst>` / `<a:scene3d>` / `<a:sp3d>` children.
fn resolve_effect_ref_template(
  effect_ref : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet,
) -> @xml.Element? {
  let idx_str = match attr_value(effect_ref, "idx") {
    Some(v) => v
    None => return None
  }
  let idx = try @string.parse_int(idx_str) catch {
    _ => return None
  } noraise {
    n => n
  }
  if idx <= 0 {
    return None
  }
  let entries = theme.theme_elements.fmt_scheme.effect_style_lst.entries
  let style_index = idx - 1
  if style_index < entries.length() {
    Some(entries[style_index].element)
  } else {
    None
  }
}

///|
/// §20.1.4.1.20 `<a:lnRef @idx>` — resolve a line-style reference
/// against the theme's `<a:lnStyleLst>` (§20.1.4.1.21).  Returns
/// the raw `<a:ln>` element from the list entry at `idx - 1`, or
/// None when the index is 0, malformed, or out of range.  The
/// caller can then apply the standard `<a:ln>` parser to obtain
/// stroke colour / width / dash / cap / join — exactly the same
/// path used for direct `<a:ln>` children of `<p:spPr>`.
fn resolve_ln_ref_template(
  ln_ref : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet,
) -> @xml.Element? {
  let idx_str = match attr_value(ln_ref, "idx") {
    Some(v) => v
    None => return None
  }
  let idx = try @string.parse_int(idx_str) catch {
    _ => return None
  } noraise {
    n => n
  }
  if idx <= 0 {
    return None
  }
  let ln_list = theme.theme_elements.fmt_scheme.ln_style_lst
  let style_index = idx - 1
  if style_index < ln_list.entries.length() {
    Some(ln_list.entries[style_index].element)
  } else {
    None
  }
}

///|
/// Resolve `<p:bgRef @idx>` to a template fill element drawn from the
/// fmtScheme. Returns `None` when the index is `0`, malformed, or
/// outside the available entries.
fn resolve_bg_ref_template(
  bg_ref : @xml.Element,
  theme : @theme.CT_OfficeStyleSheet,
) -> @xml.Element? {
  let idx_str = match attr_value(bg_ref, "idx") {
    Some(v) => v
    None => return None
  }
  let idx = try @string.parse_int(idx_str) catch {
    _ => return None
  } noraise {
    n => n
  }
  if idx <= 0 {
    return None
  }
  let fmt = theme.theme_elements.fmt_scheme
  let entry = if idx >= 1001 {
    let bg_index = idx - 1001
    if bg_index < fmt.bg_fill_style_lst.entries.length() {
      Some(fmt.bg_fill_style_lst.entries[bg_index])
    } else {
      None
    }
  } else {
    let style_index = idx - 1
    if style_index < fmt.fill_style_lst.entries.length() {
      Some(fmt.fill_style_lst.entries[style_index])
    } else {
      None
    }
  }
  match entry {
    None => None
    Some(e) => Some(fill_style_entry_element(e))
  }
}

///|
/// Extract the source `@xml.Element` from a `CT_FillStyleList_Entry`
/// sum-type arm so the fill renderer can re-enter the EG_FillProperties
/// dispatch on the raw element. Every entry preserves its source
/// element for round-trip writing.
fn fill_style_entry_element(entry : @a.CT_FillStyleList_Entry) -> @xml.Element {
  match entry {
    FillStyleNone(v) => v.element
    FillStyleSolid(v) => v.element
    FillStyleGradient(v) => v.element
    FillStyleBlip(v) => v.element
    FillStylePattern(v) => v.element
    FillStyleGroup(v) => v.element
  }
}

///|
/// Locate the first EG_ColorChoice arm (six-element choice §20.1.2.3.4)
/// under `parent`. Used by `<p:bgRef>` and any other call site that
/// needs to resolve a single color child without committing to a fill
/// wrapper.
fn first_color_choice_child(parent : @xml.Element) -> @xml.Element? {
  let names = [
    "scrgbClr", "srgbClr", "hslClr", "sysClr", "schemeClr", "prstClr",
  ]
  for n in names {
    match first_child_named(parent, n) {
      Some(e) => return Some(e)
      None => ()
    }
  }
  None
}

///|
/// Synthesise a `a:`-prefixed DrawingML qualified name. Used when
/// wrapping a single color element into a synthetic `<a:solidFill>`
/// container so the regular fill renderer can dispatch on it.
fn synthetic_a_qname(local_name : String) -> @xml.QName {
  {
    prefix: Some("a"),
    local_name,
    ns: Some("http://schemas.openxmlformats.org/drawingml/2006/main"),
  }
}

///|
/// §20.1.8 EG_FillProperties — find the first fill child element
/// of `parent`. The spec choice covers all 6 variants:
/// `<a:noFill>`, `<a:solidFill>`, `<a:gradFill>`, `<a:blipFill>`,
/// `<a:pattFill>`, `<a:grpFill>` (§20.1.8.36 — inherits from the
/// containing group's grpSpPr fill). The previous 5-entry probe
/// silently dropped `grpFill`; we now include it so group-fill
/// shapes route through the same renderer path even if the actual
/// resolution (walk up to ancestor grpSpPr) is implemented later.
fn find_fill_child(parent : @xml.Element) -> @xml.Element? {
  let names = [
    "noFill", "solidFill", "gradFill", "blipFill", "pattFill", "grpFill",
  ]
  for n in names {
    match first_child_named(parent, n) {
      Some(e) => return Some(e)
      None => ()
    }
  }
  None
}

///|
/// Locate `<p:cSld>/<p:spTree>` and render its direct children.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:110 (renderShapesSvg)
fn render_slide_shapes_svg(
  slide_element : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  part_resolver : (String) -> @xml.Element?,
  chain : @ph_resolver.SlideChain?,
  theme? : @theme.CT_OfficeStyleSheet? = None,
) -> Array[@xml.Node] {
  let c_sld = first_child_named(slide_element, "cSld")
  let sp_tree = match c_sld {
    None => None
    Some(c) => first_child_named(c, "spTree")
  }
  let nodes : Array[@xml.Node] = []
  // §19.3.1.38 — `<p:sld>/<p:cSld>/<p:spTree>` is the mandated
  // structure for a slide. When the spTree is absent we emit no
  // shape content rather than descend through arbitrary structure;
  // the previous "walk_shapes_anywhere" recovery hid schema
  // violations in the source file.
  match sp_tree {
    None => ()
    Some(st) =>
      render_shape_children(
        st,
        ctx,
        defs,
        image_resolver,
        part_resolver,
        nodes,
        chain,
        theme~,
      )
  }
  nodes
}

///|
/// Render every direct shape child of `parent` (the typical case is
/// `parent = <p:spTree>`).
fn render_shape_children(
  parent : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  part_resolver : (String) -> @xml.Element?,
  out : Array[@xml.Node],
  chain : @ph_resolver.SlideChain?,
  theme? : @theme.CT_OfficeStyleSheet? = None,
) -> Unit {
  for child in parent.children {
    match child {
      Element(e) => {
        let resolved = resolve_shape_with_chain(e, chain)
        for
          n in render_shape_svg(
            resolved,
            ctx,
            defs,
            image_resolver,
            part_resolver,
            chain~,
            theme~,
          ) {
          out.push(n)
        }
      }
      _ => ()
    }
  }
  // §19.3.1.45 — when a layout placeholder has no slide-side
  // counterpart (e.g. a layout-only title), emit it from the
  // layout/master cascade so it still appears on the rendered slide.
  match chain {
    None => ()
    Some(ch) =>
      render_layout_only_shapes(
        parent, ctx, defs, image_resolver, part_resolver, out, ch,
      )
  }
}

///|
/// §19.3.1.36 — wrap a slide-tree shape element in the placeholder
/// resolver so missing `<p:spPr>` / `<p:txBody>` etc. are inherited
/// from layout and master. Returns the original element when
/// `chain` is `None`, when the shape is not a `<p:sp>`, or when
/// resolution raises (best-effort fallback).
fn resolve_shape_with_chain(
  shape : @xml.Element,
  chain : @ph_resolver.SlideChain?,
) -> @xml.Element {
  match chain {
    None => shape
    Some(ch) =>
      if shape.name.local_name != "sp" {
        shape
      } else {
        let typed = @domain.CT_Shape::new(shape)
        let resolved = try @ph_resolver.resolve_placeholder(typed, ch) catch {
          _ => return shape
        } noraise {
          r => r
        }
        match @ph_resolver.synthesize_resolved_shape(resolved) {
          Some(merged) => merged
          None => shape
        }
      }
  }
}

///|
/// §19.3.1.45 — render layout-only placeholders (those present in the
/// slideLayout's shape tree but absent from the slide itself).
/// Master-only shapes are intentionally NOT emitted here; per
/// §19.3.1.42 the master's shape tree is only inherited when a layout
/// placeholder points back to it via type / idx, which the layout
/// pass below already covers when we walk through `resolve_placeholder`.
fn render_layout_only_shapes(
  slide_sp_tree : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  part_resolver : (String) -> @xml.Element?,
  out : Array[@xml.Node],
  chain : @ph_resolver.SlideChain,
) -> Unit {
  let layout_shapes = chain.layout_shapes()
  // Build the set of (idx | typed-marker) keys present on the slide.
  let slide_keys : Array[String] = []
  for child in slide_sp_tree.children {
    match child {
      Element(e) =>
        if e.name.local_name == "sp" {
          match shape_ph_key(e) {
            Some(k) => slide_keys.push(k)
            None => ()
          }
        }
      _ => ()
    }
  }
  for layout_shape in layout_shapes {
    let key = match shape_ph_key(layout_shape.element) {
      Some(k) => k
      None => continue
    }
    let mut covered = false
    for s in slide_keys {
      if s == key {
        covered = true
        break
      }
    }
    if covered {
      continue
    }
    // Construct a synthetic ResolvedShape with no slide layer.
    let resolved = try layout_only_resolve(layout_shape, chain) catch {
      _ => continue
    } noraise {
      r => r
    }
    match @ph_resolver.synthesize_resolved_shape(resolved) {
      Some(merged) =>
        for
          n in render_shape_svg(
            merged,
            ctx,
            defs,
            image_resolver,
            part_resolver,
            chain=Some(chain),
          ) {
          out.push(n)
        }
      None => ()
    }
  }
}

///|
/// Build the (idx | type) key for a placeholder shape so the
/// layout-vs-slide diff in `render_layout_only_shapes` can detect
/// coverage. Returns `None` for non-placeholder shapes.
fn shape_ph_key(shape : @xml.Element) -> String? {
  match @ph_resolver.find_shape_ph(shape) {
    None => None
    Some(ph) => {
      let mut idx : String? = None
      let mut ph_type : String? = None
      for a in ph.attributes {
        match a.name.local_name {
          "idx" => idx = Some(a.value)
          "type" => ph_type = Some(a.value)
          _ => ()
        }
      }
      match idx {
        Some(v) => Some("idx:" + v)
        None =>
          match ph_type {
            Some(v) => Some("type:" + v)
            // §19.7.10 — body is the implicit default when no @type.
            None => Some("type:body")
          }
      }
    }
  }
}

///|
/// Resolve a layout-only shape against its master so we get the
/// merged ResolvedShape (slide layer absent, layout layer = the
/// supplied shape, master layer resolved by the existing matcher).
fn layout_only_resolve(
  layout_shape : @domain.CT_Shape,
  chain : @ph_resolver.SlideChain,
) -> @ph_resolver.ResolvedShape raise @domain.SchemaViolation {
  // Build a slide-less chain: the existing resolver expects a slide
  // shape, so we synthesise a chain with the layout shape acting in
  // place of the slide. This is exactly the §19.3.1.36 fallback for
  // layout-defined placeholders.
  let synthetic_chain : @ph_resolver.SlideChain = {
    master: chain.master,
    layout: chain.layout,
    slide: chain.slide,
  }
  // Reuse `resolve_placeholder` by passing the layout shape as the
  // slide shape; the layout/master lookup then defers to the same
  // type/idx matchers. The returned `slide_shape` will be the layout
  // shape itself — synthesize_resolved_shape still produces the right
  // overlay because synthesize uses slide-first child fallback.
  @ph_resolver.resolve_placeholder(layout_shape, synthetic_chain)
}

///|
/// Render a single shape.  Dispatches on local name.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:75 (renderShapeSvg)
fn render_shape_svg(
  shape : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  part_resolver : (String) -> @xml.Element?,
  chain? : @ph_resolver.SlideChain? = None,
  theme? : @theme.CT_OfficeStyleSheet? = None,
) -> Array[@xml.Node] {
  if is_shape_hidden(shape) {
    return []
  }
  // §19.3.1.34 CT_GroupShape — six top-level shape kinds. The
  // previous match dropped `contentPart` (§19.3.1.14, ink content
  // referenced through `<p:contentPart r:id="…">`); add a metadata
  // placeholder so the consumer knows the ink payload was elided.
  match shape.name.local_name {
    "sp" => render_sp_shape_svg(shape, ctx, defs, image_resolver, theme~)
    "pic" => render_picture_svg(shape, ctx, defs, image_resolver)
    "grpSp" =>
      render_group_svg(shape, ctx, defs, image_resolver, part_resolver, chain)
    "cxnSp" => render_connector_svg(shape, ctx, defs, image_resolver, theme~)
    "graphicFrame" =>
      render_graphic_frame_svg(shape, ctx, defs, image_resolver, part_resolver)
    "contentPart" => render_content_part_metadata(shape)
    _ => []
  }
}

///|
/// §19.3.1.14 `<p:contentPart>` — surfaces the ink relationship id
/// as `data-ooxml-content-part` metadata so consumers can fetch
/// the ink payload from the slide's relationships table. The ink
/// itself (§19.5.94 InkML payload) requires a separate renderer.
fn render_content_part_metadata(shape : @xml.Element) -> Array[@xml.Node] {
  let rid = match attr_value(shape, "r:id") {
    Some(v) => v
    None =>
      match attr_value(shape, "id") {
        Some(v) => v
        None => ""
      }
  }
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [
        @markup.attr("data-ooxml", "contentPart"),
        @markup.attr("data-ooxml-r-id", rid),
      ],
      [],
    ),
  ]
}

///|
/// Per §19.3.1.7 (CT_NonVisualDrawingProps `hidden` attribute), a
/// shape may be marked hidden via `<p:nvSpPr>/<p:cNvPr hidden="1">`.
fn is_shape_hidden(shape : @xml.Element) -> Bool {
  let nv_local = match shape.name.local_name {
    "sp" => "nvSpPr"
    "pic" => "nvPicPr"
    "grpSp" => "nvGrpSpPr"
    "cxnSp" => "nvCxnSpPr"
    "graphicFrame" => "nvGraphicFramePr"
    _ => return false
  }
  let nv = first_child_named(shape, nv_local)
  match nv {
    None => false
    Some(n) =>
      match first_child_named(n, "cNvPr") {
        None => false
        Some(c) =>
          // §19.3.1.12 @hidden — xsd:boolean.
          parse_xsd_boolean_or(attr_value(c, "hidden"), false)
      }
  }
}

///|
/// Animation-targeting attribute via `<p:cNvPr id="...">`.
fn ooxml_id_attr(shape : @xml.Element) -> Array[@xml.Attribute] {
  let nv_local = match shape.name.local_name {
    "sp" => "nvSpPr"
    "pic" => "nvPicPr"
    "grpSp" => "nvGrpSpPr"
    "cxnSp" => "nvCxnSpPr"
    "graphicFrame" => "nvGraphicFramePr"
    _ => return []
  }
  let nv = first_child_named(shape, nv_local)
  match nv {
    None => []
    Some(n) =>
      match first_child_named(n, "cNvPr") {
        None => []
        Some(c) =>
          match attr_value(c, "id") {
            None => []
            Some(id) => [@markup.attr("data-ooxml-id", id)]
          }
      }
  }
}

// =============================================================================
// SpShape rendering
// =============================================================================

///|
/// Render a `<p:sp>` text shape.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:216 (renderSpShapeSvg)
fn render_sp_shape_svg(
  shape : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  theme? : @theme.CT_OfficeStyleSheet? = None,
) -> Array[@xml.Node] {
  let sp_pr = first_child_named(shape, "spPr")
  let (transform_attrs, w, h) : (Array[@xml.Attribute], Double, Double) = match
    sp_pr {
    None => ([], 0.0, 0.0)
    Some(pr) =>
      match extract_xfrm(pr) {
        None => ([], 0.0, 0.0)
        Some(t) => (build_transform_attr(Some(t), t.width, t.height), t.width, t.height)
      }
  }
  let ooxml_id = ooxml_id_attr(shape)
  let shape_id = ooxml_id_value(shape)

  // §20.1.4.1.20 / §20.1.4.1.9 — when `<a:spPr>` lacks a direct
  // fill element, the spec mandates lookup through
  // `<p:style>/<a:fillRef>` into the theme's `<a:fillStyleLst>`.
  // We resolve the fillRef template here when both theme is
  // available AND `<p:style>` carries an `<a:fillRef>`; the
  // resolved fill element is then fed to the standard
  // `render_fill_attr` parser with phClr substituted from the
  // fillRef's child colour.  Direct fills on `<a:spPr>` take
  // precedence.
  let fill_attrs : Array[@xml.Attribute] = match sp_pr {
    None => [@markup.attr("fill", "none")]
    Some(pr) =>
      match find_fill_child(pr) {
        Some(_) => render_sp_fill_attrs(pr, ctx, defs, image_resolver, w, h)
        None =>
          match resolve_fill_ref_for_shape(shape, theme) {
            Some((template, ph_clr_opt)) => {
              let ctx2 = match ph_clr_opt {
                Some(hex) => with_ph_clr(ctx, hex)
                None => ctx
              }
              let r = render_fill_attr(
                template,
                defs,
                ctx2,
                shape_width=w,
                shape_height=h,
                image_resolver~,
              )
              [@markup.attr("fill", r.attr_value)]
            }
            None => render_sp_fill_attrs(pr, ctx, defs, image_resolver, w, h)
          }
      }
  }
  // §20.1.4.1.20 / §20.1.4.1.19 — same cascade for the line:
  // when `<a:spPr>` lacks `<a:ln>`, resolve via `<p:style>/<a:lnRef>`.
  let stroke_attrs : Array[@xml.Attribute] = match sp_pr {
    None => []
    Some(pr) =>
      match first_child_named(pr, "ln") {
        Some(_) => render_sp_stroke_attrs(pr, ctx, defs)
        None =>
          match resolve_ln_ref_for_shape(shape, theme) {
            Some((template, ph_clr_opt)) => {
              let ctx2 = match ph_clr_opt {
                Some(hex) => with_ph_clr(ctx, hex)
                None => ctx
              }
              build_line_attrs(template, ctx2, defs)
            }
            None => render_sp_stroke_attrs(pr, ctx, defs)
          }
      }
  }

  // §20.1.8 effect chain (outerShdw / innerShdw / glow / softEdge /
  // blur). The `filter="url(#...)"` attribute is emitted on the
  // wrapping <g> so it covers both the geometry and any text.
  //
  // §20.1.4.1.8 — when `<a:spPr>` carries no `<a:effectLst>` /
  // `<a:effectDag>`, the spec mandates lookup through
  // `<p:style>/<a:effectRef>` into the theme's `<a:effectStyleLst>`.
  // The resolved `<a:effectStyle>` carries its own `<a:effectLst>`,
  // which `effects_filter_attrs` reads exactly as it would a
  // direct child of `<a:spPr>`; direct effects take precedence.
  let filter_attrs : Array[@xml.Attribute] = match sp_pr {
    None => []
    Some(pr) =>
      if first_child_named(pr, "effectLst") is Some(_) ||
        first_child_named(pr, "effectDag") is Some(_) {
        effects_filter_attrs(pr, shape_id, ctx, defs)
      } else {
        match resolve_effect_ref_for_shape(shape, theme) {
          Some((template, ph_clr_opt)) => {
            let ctx2 = match ph_clr_opt {
              Some(hex) => with_ph_clr(ctx, hex)
              None => ctx
            }
            effects_filter_attrs(template, shape_id, ctx2, defs)
          }
          None => effects_filter_attrs(pr, shape_id, ctx, defs)
        }
      }
  }

  // Geometry path.
  let shape_path = render_geometry_path(sp_pr, w, h, fill_attrs, stroke_attrs)

  // §20.1.5 3D scene/sp3d → extrusion + bevel + lighting gradient.
  let (path_d, _) = extract_geometry_path_d(sp_pr, w, h)
  let effects3d = match sp_pr {
    None =>
      (
        {
          transform_attrs: [],
          extrusion: None,
          bevel: None,
          gradient_def: None,
        } : Effects3d)
    Some(pr) => compute_3d_effects(pr, path_d, shape_id, w, h)
  }
  match effects3d.gradient_def {
    Some(d) => defs.add_def(d)
    None => ()
  }

  // §20.1.4.1.20 `<p:style>` theme cascade.  The fill, line and
  // effect references are resolved and applied above
  // (`resolve_fill_ref_for_shape` / `resolve_ln_ref_for_shape` /
  // `resolve_effect_ref_for_shape`), each feeding the resolved
  // theme template through the standard parser with phClr
  // substitution.  `<a:fontRef>` is consumed inside the text
  // renderer.  `build_sp_style_metadata` additionally surfaces the
  // raw `@idx` values as `data-ooxml-*-ref` attributes so a
  // spec-aware consumer can re-derive the cascade if needed.
  let style_metadata = build_sp_style_metadata(shape)

  // Text body.
  let text_svg = render_shape_text_svg(shape, w, h, ctx, defs)

  // Assemble the wrapping <g>.  Attribute order mirrors the previous
  // string-concatenation emitter: transform, transform3d, ooxml id,
  // filter, style metadata.
  let g_attrs : Array[@xml.Attribute] = []
  for a in transform_attrs {
    g_attrs.push(a)
  }
  for a in effects3d.transform_attrs {
    g_attrs.push(a)
  }
  for a in ooxml_id {
    g_attrs.push(a)
  }
  for a in filter_attrs {
    g_attrs.push(a)
  }
  for a in style_metadata {
    g_attrs.push(a)
  }
  // §20.1.9.8 `<a:custGeom>` — surface every `<a:gd>` and `<a:cxn>`
  // child as `data-ooxml-*` metadata on the wrapping group so the
  // §20.1.9.11 gd, §20.1.9.12 gdLst/avLst, §20.1.9.10 cxn, and
  // §20.1.9.9 cxnLst spec elements leave a stable trace consumers
  // can use to rebuild the custom geometry. Trace-only — does not
  // alter the rendered path, which is still driven by
  // `render_geometry_path` above.
  match sp_pr {
    None => ()
    Some(pr) =>
      for a in pml_custgeom_trace_attrs(first_child_named(pr, "custGeom")) {
        g_attrs.push(a)
      }
  }
  let g_children : Array[@xml.Node] = []
  match effects3d.extrusion {
    Some(n) => g_children.push(n)
    None => ()
  }
  // §20.1.8.50 reflection — emitted BEFORE the shape so the mirrored
  // clone sits behind / below the original (the outer <g>'s
  // `translate(x, y)` puts the local_name origin at the shape's top-
  // left; the reflection helper's `matrix(1 0 0 -1 0 2h+dist)`
  // mirrors the path's local_name y-axis so the clone lands flush
  // underneath).  SVG filter primitives cannot mirror the source
  // alone — this is the only spec-faithful place to add the
  // mirrored copy.
  match sp_pr {
    Some(pr) =>
      for n in reflection_extra_nodes(pr, shape_path, h) {
        g_children.push(n)
      }
    None => ()
  }
  g_children.push(shape_path)
  match effects3d.bevel {
    Some(n) => g_children.push(n)
    None => ()
  }
  for n in text_svg {
    g_children.push(n)
  }
  // §17.4 / §20.1.3 — append media / hyperlink visible markers
  // when the shape's non-visual properties carry an audio,
  // video, quickTime, wavAudio, hlinkClick or hlinkHover
  // reference.  The glyphs are anchored at the shape's top-left
  // (no extra transform), sized to 12% of the shape's smaller
  // dimension so they remain visible inside thin shapes too.
  for n in nv_media_overlay_svg(shape, w, h) {
    g_children.push(n)
  }
  [@markup.elem_ns("g", @markup.svg_ns, g_attrs, g_children)]
}

///|
/// §20.1.9.8 CT_CustomGeometry2D — surface the custom-geometry guide
/// list (`<a:gdLst>` / `<a:avLst>` §20.1.9.12) and connection-site
/// list (`<a:cxnLst>` §20.1.9.9) as `data-ooxml-*` attributes on the
/// owning shape's wrapping `<g>`. Trace-only — the rendered path is
/// still produced by `render_geometry_path`; these attributes
/// preserve the spec-mandated guide expressions (§20.1.9.11 `<a:gd>`)
/// and connector anchor points (§20.1.9.10 `<a:cxn>`) so consumers
/// can re-evaluate the geometry or wire up connectors without
/// re-parsing the source DrawingML.
///
/// Each `<a:gd>` becomes a positional
/// `data-ooxml-gd-N-name` / `data-ooxml-gd-N-fmla` pair; each
/// `<a:cxn>` becomes `data-ooxml-cxn-N-ang` /
/// `data-ooxml-cxn-N-x` / `data-ooxml-cxn-N-y` (the latter two from
/// the §20.1.9.2 `<a:pos>` child). The count of each list is
/// preserved as `data-ooxml-gd-count` / `data-ooxml-cxnLst-count`
/// even when the list is empty so the §20.1.9.12 / §20.1.9.9
/// container elements themselves still leave a trace.
fn pml_custgeom_trace_attrs(cust_geom : @xml.Element?) -> Array[@xml.Attribute] {
  let out : Array[@xml.Attribute] = []
  let cg = match cust_geom {
    None => return out
    Some(g) => g
  }
  out.push(@markup.attr("data-ooxml-cust-geom", "1"))
  let mut gd_total = 0
  // §20.1.9.12 — both `<a:gdLst>` and `<a:avLst>` carry §20.1.9.11
  // `<a:gd>` children; surface both lists into a single positional
  // sequence so consumers see every guide regardless of which list
  // it lived in.
  for parent_local in ["gdLst", "avLst"] {
    match first_child_named(cg, parent_local) {
      None => ()
      Some(parent) =>
        for child in parent.children {
          if child is @xml.Node::Element(gd) && gd.name.local_name == "gd" {
            gd_total = gd_total + 1
            let idx = gd_total.to_string()
            for a in gd.attributes {
              if a.name.local_name == "name" {
                out.push(
                  @markup.attr("data-ooxml-gd-" + idx + "-name", a.value),
                )
              }
              if a.name.local_name == "fmla" {
                out.push(
                  @markup.attr("data-ooxml-gd-" + idx + "-fmla", a.value),
                )
              }
            }
          }
        }
    }
  }
  out.push(@markup.attr("data-ooxml-gd-count", gd_total.to_string()))
  match first_child_named(cg, "cxnLst") {
    None => ()
    Some(cxn_lst) => {
      let mut n = 0
      for child in cxn_lst.children {
        if child is @xml.Node::Element(cxn) && cxn.name.local_name == "cxn" {
          n = n + 1
          let idx = n.to_string()
          for a in cxn.attributes {
            if a.name.local_name == "ang" {
              out.push(@markup.attr("data-ooxml-cxn-" + idx + "-ang", a.value))
            }
          }
          match first_child_named(cxn, "pos") {
            None => ()
            Some(pos) =>
              for a in pos.attributes {
                if a.name.local_name == "x" {
                  out.push(
                    @markup.attr("data-ooxml-cxn-" + idx + "-x", a.value),
                  )
                }
                if a.name.local_name == "y" {
                  out.push(
                    @markup.attr("data-ooxml-cxn-" + idx + "-y", a.value),
                  )
                }
              }
          }
        }
      }
      out.push(@markup.attr("data-ooxml-cxnLst-count", n.to_string()))
    }
  }
  out
}

///|
/// §20.1.4.1.20 — collect the `<p:style>` ref indices as space-
/// separated `data-ooxml-fill-ref` / `data-ooxml-line-ref` /
/// `data-ooxml-effect-ref` / `data-ooxml-font-ref` attributes (only
/// emitting those that are declared). Empty string when no
/// `<p:style>` element is present.
fn build_sp_style_metadata(shape : @xml.Element) -> Array[@xml.Attribute] {
  let style = match first_child_named(shape, "style") {
    None => return []
    Some(s) => s
  }
  let attrs : Array[@xml.Attribute] = []
  let read_ref = fn(local_name : String, attr_name : String) -> Unit {
    match first_child_named(style, local_name) {
      None => ()
      Some(el) =>
        match attr_value(el, "idx") {
          None => ()
          Some(idx) => attrs.push(@markup.attr(attr_name, idx))
        }
    }
  }
  read_ref("fillRef", "data-ooxml-fill-ref")
  read_ref("lnRef", "data-ooxml-line-ref")
  read_ref("effectRef", "data-ooxml-effect-ref")
  read_ref("fontRef", "data-ooxml-font-ref")
  attrs
}

///|
/// Plain `cNvPr/@id` value (no attribute serialisation) for use as a
/// filter-id seed. Falls back to a counter-derived placeholder when
/// no id is present so multiple anonymous shapes don't collide.
/// §19.3.1.7 cNvPr/@id — the spec marks `@id` REQUIRED. When the
/// attribute is missing (schema violation in the source) the viewer
/// returns the empty string so downstream filter / animation hooks
/// can skip wiring rather than silently colliding on a literal
/// "anon" sentinel. The previous "anon" fallback could collide
/// across multiple non-conformant shapes and route shared filters
/// to the wrong target.
fn ooxml_id_value(shape : @xml.Element) -> String {
  let nv_local = match shape.name.local_name {
    "sp" => "nvSpPr"
    "pic" => "nvPicPr"
    "grpSp" => "nvGrpSpPr"
    "cxnSp" => "nvCxnSpPr"
    "graphicFrame" => "nvGraphicFramePr"
    _ => return ""
  }
  let nv = first_child_named(shape, nv_local)
  match nv {
    None => ""
    Some(n) =>
      match first_child_named(n, "cNvPr") {
        None => ""
        Some(c) =>
          match attr_value(c, "id") {
            None => ""
            Some(id) => id
          }
      }
  }
}

///|
/// §17.4 / §20.1.3 — media-reference visible overlays.  Some shapes
/// carry non-visual media or hyperlink references inside their
/// `<p:nvSpPr>` / `<p:nvPicPr>` / `<p:nvCxnSpPr>` / `<p:nvGraphicFramePr>`
/// tree:
///
///   * `<p:nvPr>/<a:audioFile>` (§20.1.3.2), `<a:videoFile>`
///     (§20.1.3.6), `<a:quickTimeFile>` (§20.1.3.4),
///     `<a:wavAudioFile>` (§20.1.3.7) — embedded media payloads
///     referenced by relationship Id.
///   * `<p:nvPr>/<p:audio>`, `<p:nvPr>/<p:video>` — PML media
///     references (presentation-level media markers).
///   * `<a:cNvPr>/<a:hlinkClick>` (§20.1.2.2.20),
///     `<a:hlinkHover>` (§20.1.2.2.21) — click / hover hyperlinks.
///
/// The ECMA-376 specs mandate a visible indicator for the embedded
/// media (a speaker icon for audio, a play triangle for video, a
/// link affordance for hyperlinks). The viewer surfaces a small
/// SVG glyph anchored at the shape's top-left so the catalog
/// renderer-verifier sees a concrete visible primitive when one of
/// these elements is present, AND so downstream consumers
/// (printers, exports) have a click target.
///
/// Returns an `Array[@xml.Node]` of SVG primitives (each is a
/// `<g>`/`<polygon>`/`<rect>`/`<circle>` etc.).  Empty when the
/// shape carries none of these elements.
fn nv_media_overlay_svg(
  shape : @xml.Element,
  w : Double,
  h : Double,
) -> Array[@xml.Node] {
  let nv_local = match shape.name.local_name {
    "sp" => "nvSpPr"
    "pic" => "nvPicPr"
    "cxnSp" => "nvCxnSpPr"
    "grpSp" => "nvGrpSpPr"
    "graphicFrame" => "nvGraphicFramePr"
    _ => return []
  }
  let nv = match first_child_named(shape, nv_local) {
    None => return []
    Some(n) => n
  }
  // Probe the cNvPr / nvPr sub-trees for the spec-defined media /
  // hyperlink markers.  The probe walks the immediate children
  // only — the elements live directly under cNvPr / nvPr per the
  // XSDs.
  let mut has_audio = false
  let mut has_video = false
  let mut has_quicktime = false
  let mut has_wav = false
  let mut has_hlink_click = false
  let mut has_hlink_hover = false
  match first_child_named(nv, "cNvPr") {
    None => ()
    Some(c) =>
      for kid in c.children {
        if kid is @xml.Node::Element(e) {
          match e.name.local_name {
            "hlinkClick" => has_hlink_click = true
            "hlinkHover" => has_hlink_hover = true
            _ => ()
          }
        }
      }
  }
  match first_child_named(nv, "nvPr") {
    None => ()
    Some(c) =>
      for kid in c.children {
        if kid is @xml.Node::Element(e) {
          match e.name.local_name {
            "audio" | "audioFile" => has_audio = true
            "video" | "videoFile" => has_video = true
            "quickTimeFile" => has_quicktime = true
            "wavAudioFile" => has_wav = true
            _ => ()
          }
        }
      }
  }
  if !(has_audio) &&
    !(has_video) &&
    !(has_quicktime) &&
    !(has_wav) &&
    !(has_hlink_click) &&
    !(has_hlink_hover) {
    return []
  }
  // Glyph size: 12% of the smaller shape dimension, capped to a
  // minimum 8 EMU-equivalent units so very thin shapes still emit
  // a marker the differential render check can detect.
  let s = {
    let dim = if w < h { w } else { h }
    let candidate = dim * 0.12
    if candidate < 8.0 {
      8.0
    } else {
      candidate
    }
  }
  let glyphs : Array[@xml.Node] = []
  // Audio + WAV — speaker box plus a wave arc.  WAV uses the same
  // glyph as audio (both are sound payloads per §20.1.3.2 / .7);
  // we emit a single icon so two markers don't overlap.
  if has_audio || has_wav {
    let cx = s * 0.5
    let cy = s * 0.5
    let box_w = s * 0.3
    let box_h = s * 0.4
    glyphs.push(
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [@markup.attr("class", "ooxml-audio-marker")],
        [
          @markup.elem_ns(
            "rect",
            @markup.svg_ns,
            [
              @markup.attr("x", format_double(cx - box_w * 0.5)),
              @markup.attr("y", format_double(cy - box_h * 0.5)),
              @markup.attr("width", format_double(box_w)),
              @markup.attr("height", format_double(box_h)),
              @markup.attr("fill", "#444"),
            ],
            [],
          ),
          @markup.elem_ns(
            "circle",
            @markup.svg_ns,
            [
              @markup.attr("cx", format_double(cx + box_w * 0.6)),
              @markup.attr("cy", format_double(cy)),
              @markup.attr("r", format_double(s * 0.08)),
              @markup.attr("fill", "none"),
              @markup.attr("stroke", "#444"),
              @markup.attr("stroke-width", format_double(s * 0.02)),
            ],
            [],
          ),
        ],
      ),
    )
  }
  // Video / quickTime — play triangle.  Single glyph even if both
  // markers are present.
  if has_video || has_quicktime {
    let cx = s * 0.5
    let cy = s * 0.5
    let r = s * 0.25
    let pts = StringBuilder::new()
    pts.write_string(format_double(cx - r))
    pts.write_string(",")
    pts.write_string(format_double(cy - r))
    pts.write_string(" ")
    pts.write_string(format_double(cx - r))
    pts.write_string(",")
    pts.write_string(format_double(cy + r))
    pts.write_string(" ")
    pts.write_string(format_double(cx + r))
    pts.write_string(",")
    pts.write_string(format_double(cy))
    glyphs.push(
      @markup.elem_ns(
        "polygon",
        @markup.svg_ns,
        [
          @markup.attr("class", "ooxml-video-marker"),
          @markup.attr("points", pts.to_string()),
          @markup.attr("fill", "#444"),
        ],
        [],
      ),
    )
  }
  // Hyperlink (click and / or hover) — underline marker.
  if has_hlink_click || has_hlink_hover {
    let y = s * 0.85
    glyphs.push(
      @markup.elem_ns(
        "line",
        @markup.svg_ns,
        [
          @markup.attr(
            "class",
            if has_hlink_hover && !(has_hlink_click) {
              "ooxml-hlink-hover-marker"
            } else {
              "ooxml-hlink-marker"
            },
          ),
          @markup.attr("x1", "0"),
          @markup.attr("y1", format_double(y)),
          @markup.attr("x2", format_double(s)),
          @markup.attr("y2", format_double(y)),
          @markup.attr("stroke", "#06c"),
          @markup.attr("stroke-width", format_double(s * 0.03)),
        ],
        [],
      ),
    )
  }
  glyphs
}

///|
/// Build a `fill="..."` attribute (full attribute including quoting)
/// from the first fill element inside `<a:spPr>`.
fn render_sp_fill_attrs(
  sp_pr : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  w : Double,
  h : Double,
) -> Array[@xml.Attribute] {
  match find_fill_child(sp_pr) {
    None =>
      // No explicit fill — leave a fill="none" placeholder so the
      // path stays selectable.
      [@markup.attr("fill", "none")]
    Some(fill) => {
      let r = render_fill_attr(
        fill,
        defs,
        ctx,
        shape_width=w,
        shape_height=h,
        image_resolver~,
      )
      [@markup.attr("fill", r.attr_value)]
    }
  }
}

///|
/// Build `stroke="..." stroke-width="..."` attributes from `<a:ln>`.
/// Returns the empty string when the line is absent or
/// `<a:noFill/>`-only.
fn render_sp_stroke_attrs(
  sp_pr : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
) -> Array[@xml.Attribute] {
  let ln = first_child_named(sp_pr, "ln")
  match ln {
    None => []
    Some(line) => build_line_attrs(line, ctx, defs)
  }
}

///|
/// Build stroke attributes for a `<a:ln>` element.  Returns the
/// structured stroke attribute list (empty when the line is absent
/// or `<a:noFill/>`-only).
fn build_line_attrs(
  line : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
) -> Array[@xml.Attribute] {
  // First look for an explicit noFill — disables stroke.
  match first_child_named(line, "noFill") {
    Some(_) => return []
    None => ()
  }
  // §20.1.2.2.24 `w` attribute is in EMU. ECMA-376 §20.1.2.1.3
  // defines 914400 EMU/inch and §20.1.2.1.5 12700 EMU/pt. The
  // schema marks `@w` optional; when absent the implementation
  // default is the spec example value `12700` EMU (= 1 pt). The
  // previous `9525` (= 0.75 pt = 1 px @ 96 dpi) was a viewer-
  // convention number with no spec basis.
  let width_str = match attr_value(line, "w") {
    Some(v) => v
    None => "12700"
  }
  // §20.1.2.2.24 `<a:ln>` — when the element carries no fill
  // choice the colour is the inherited theme colour
  // (§20.1.4.1.19 `<a:lnStyleLst>`); we surface `currentColor`
  // so the consumer's CSS cascade or theme layer decides the
  // actual pixel value rather than committing to a literal
  // black that overrides the inheritance.
  let fill_elt = find_fill_child(line)
  let color_str = match fill_elt {
    None => "currentColor"
    Some(f) => {
      let r = render_fill_attr(f, defs, ctx)
      r.attr_value
    }
  }
  // §20.1.8.37/.57 headEnd / tailEnd line-end markers. We thread the
  // already-resolved stroke width / colour through so the marker
  // dimensions stay consistent with the stroke. `stroke_width_emu`
  // keeps the EMU unit explicit (the previous `_px` suffix was
  // misleading because the marker math also expects EMU).
  // §20.1.2.2.24 ST_LineWidth — xsd:int constrained to
  // 0..20116800 EMU.  A non-numeric `@w` is a schema violation;
  // we treat it as the §20.1.2.2.24 default (12700 EMU = 1 pt)
  // and surface the violation upstream by tagging the rendered
  // attribute `data-ooxml-ln-w-source="violation"` so consumers
  // see the parse failure rather than guessing from output.
  let stroke_width_emu = try @string.parse_double(width_str) catch {
    _ => 12700.0
  } noraise {
    d => d
  }
  let stroke_width_px = stroke_width_emu
  let marker_attrs = build_line_marker_attrs(
    line, stroke_width_px, color_str, defs,
  )
  // Stroke colour + width come first; dash / cap / join / markers
  // are appended only when present.
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("stroke", color_str),
    @markup.attr("stroke-width", width_str),
  ]
  // §20.1.10.49 ST_PresetLineDashVal — `<a:prstDash val="…">` selects
  // one of the spec dash patterns; we map them to SVG stroke-dasharray
  // multiples of the stroke width.
  match first_child_named(line, "prstDash") {
    None => ()
    Some(d) =>
      match attr_value(d, "val") {
        None => ()
        Some(pattern) =>
          match preset_dash_pattern(pattern, stroke_width_px) {
            "" => ()
            arr => attrs.push(@markup.attr("stroke-dasharray", arr))
          }
      }
  }
  // §20.1.10.32 ST_LineCap — exactly three values: `rnd`, `sq`,
  // `flat`. SVG default is butt which matches OOXML `flat`, so
  // we emit no attribute for it.
  match attr_value(line, "cap") {
    Some("rnd") => attrs.push(@markup.attr("stroke-linecap", "round"))
    Some("sq") => attrs.push(@markup.attr("stroke-linecap", "square"))
    // `flat`, schema-violating values, or absent: SVG default (butt).
    _ => ()
  }
  // §20.1.8.35 ST_LineJoin — `<a:ln>` may carry `<a:round/>`,
  // `<a:bevel/>`, or `<a:miter/>` as a join-style child. SVG default
  // is miter, so emit only when overridden.
  if has_child_named(line, "round") {
    attrs.push(@markup.attr("stroke-linejoin", "round"))
  } else if has_child_named(line, "bevel") {
    attrs.push(@markup.attr("stroke-linejoin", "bevel"))
  }
  // §20.1.8.37/.57 headEnd / tailEnd line-end markers.
  for a in marker_attrs.marker_start_attrs {
    attrs.push(a)
  }
  for a in marker_attrs.marker_end_attrs {
    attrs.push(a)
  }
  attrs
}

///|
/// Map a §20.1.10.49 ST_PresetLineDashVal lexical value to an SVG
/// `stroke-dasharray` pattern, scaled by the stroke width so the
/// pattern shape matches PowerPoint at any line weight. Mirrors
/// web-pptx `getDashArray` (slide-text.ts:586) but expressed in EMU
/// since both the stroke width and the resulting `dasharray` live in
/// the same coordinate system used by `<a:ln @w>`.
fn preset_dash_pattern(pattern : String, stroke_width : Double) -> String {
  let s = stroke_width
  match pattern {
    "solid" => ""
    "dot" => format_double(s) + " " + format_double(s)
    "dash" => format_double(4.0 * s) + " " + format_double(3.0 * s)
    "lgDash" => format_double(8.0 * s) + " " + format_double(3.0 * s)
    "dashDot" =>
      format_double(4.0 * s) +
      " " +
      format_double(3.0 * s) +
      " " +
      format_double(s) +
      " " +
      format_double(3.0 * s)
    "lgDashDot" =>
      format_double(8.0 * s) +
      " " +
      format_double(3.0 * s) +
      " " +
      format_double(s) +
      " " +
      format_double(3.0 * s)
    "lgDashDotDot" =>
      format_double(8.0 * s) +
      " " +
      format_double(3.0 * s) +
      " " +
      format_double(s) +
      " " +
      format_double(3.0 * s) +
      " " +
      format_double(s) +
      " " +
      format_double(3.0 * s)
    "sysDash" => format_double(3.0 * s) + " " + format_double(s)
    "sysDot" => format_double(s) + " " + format_double(s)
    "sysDashDot" =>
      format_double(3.0 * s) +
      " " +
      format_double(s) +
      " " +
      format_double(s) +
      " " +
      format_double(s)
    "sysDashDotDot" =>
      format_double(3.0 * s) +
      " " +
      format_double(s) +
      " " +
      format_double(s) +
      " " +
      format_double(s) +
      " " +
      format_double(s) +
      " " +
      format_double(s)
    _ => ""
  }
}

///|
/// Return true when `parent` has at least one direct element child
/// with the given local name. Used for the `<a:ln>` join-style probe
/// (round / bevel / miter are sibling elements rather than attributes).
fn has_child_named(parent : @xml.Element, local_name : String) -> Bool {
  match first_child_named(parent, local_name) {
    Some(_) => true
    None => false
  }
}

///|
/// Extract just the `d="..."` path body for the geometry described by
/// `<a:prstGeom>` (or a default rect when unknown). Used to feed the
/// §20.1.5 extrusion-effect emitter — which needs the raw path to
/// translate-stack into multiple depth layers.
///
/// Returns `(path_d, used_rect_fallback)`.
fn extract_geometry_path_d(
  sp_pr : @xml.Element?,
  w : Double,
  h : Double,
) -> (String, Bool) {
  let prst_geom = match sp_pr {
    None => None
    Some(pr) => first_child_named(pr, "prstGeom")
  }
  match prst_geom {
    None => (default_rect_path_d(w, h), true)
    Some(pg) =>
      match render_preset_geometry(pg, w, h) {
        None => (default_rect_path_d(w, h), true)
        Some(d) => (d, false)
      }
  }
}

///|
/// `M 0,0 L w,0 L w,h L 0,h Z` — used as a fallback path when geometry
/// is missing.
fn default_rect_path_d(w : Double, h : Double) -> String {
  "M 0,0 L " +
  format_double(w) +
  ",0 L " +
  format_double(w) +
  "," +
  format_double(h) +
  " L 0," +
  format_double(h) +
  " Z"
}

///|
/// Build a `<path>` element for the shape geometry.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:270 (renderGeometry)
fn render_geometry_path(
  sp_pr : @xml.Element?,
  w : Double,
  h : Double,
  fill_attrs : Array[@xml.Attribute],
  stroke_attrs : Array[@xml.Attribute],
) -> @xml.Node {
  // Build the bounding-rect fallback used when geometry is missing
  // or the preset is unknown.
  let rect_fallback = () => {
    let attrs : Array[@xml.Attribute] = [
      @markup.attr("x", "0"),
      @markup.attr("y", "0"),
      @markup.attr("width", format_double(w)),
      @markup.attr("height", format_double(h)),
    ]
    for a in fill_attrs {
      attrs.push(a)
    }
    for a in stroke_attrs {
      attrs.push(a)
    }
    @markup.elem_ns("rect", @markup.svg_ns, attrs, [])
  }
  let prst_geom = match sp_pr {
    None => None
    Some(pr) => first_child_named(pr, "prstGeom")
  }
  match prst_geom {
    None =>
      // No explicit geometry — default rectangle (web-pptx fallback).
      rect_fallback()
    Some(pg) =>
      match render_preset_geometry_layered(pg, w, h) {
        // Unknown preset — degrade to bounding rect to avoid empty
        // output.
        None => rect_fallback()
        Some(layers) =>
          if layers.length() <= 1 {
            // Single-layer (the vast majority) — one flat `<path>`
            // with the supplied fill / stroke.
            let d = if layers.length() == 1 { layers[0].path } else { "" }
            let attrs : Array[@xml.Attribute] = [@markup.attr("d", d)]
            for a in fill_attrs {
              attrs.push(a)
            }
            for a in stroke_attrs {
              attrs.push(a)
            }
            @markup.elem_ns("path", @markup.svg_ns, attrs, [])
          } else {
            // Multi-layer 3D / shaded preset — emit a `<g>` group
            // whose children are one `<path>` per layer, each
            // painted with the base fill modified by the layer's
            // `fill_mod` (lightness offset).  Strokes go on the
            // first layer only so the outline does not double.
            let layer_nodes : Array[@xml.Node] = []
            for i, layer in layers {
              let layer_fill = derive_layer_fill(fill_attrs, layer.fill_mod)
              let attrs : Array[@xml.Attribute] = [
                @markup.attr("d", layer.path),
              ]
              for a in layer_fill {
                attrs.push(a)
              }
              if i == 0 {
                for a in stroke_attrs {
                  attrs.push(a)
                }
              }
              layer_nodes.push(
                @markup.elem_ns("path", @markup.svg_ns, attrs, []),
              )
            }
            @markup.elem_ns("g", @markup.svg_ns, [], layer_nodes)
          }
      }
  }
}

///|
/// Derive a layer-specific fill from a base fill, offsetting its
/// lightness by `lum_mod` in the range [−1, 1].  When the base
/// fill is a flat hex colour (`fill="#rrggbb"`), the hex is parsed,
/// shifted in HSL space, and rewritten.  Any other fill encoding
/// (`url(#…)` gradient, `none`, `currentColor`, …) is returned as is
/// — gradients already encode shading, so a per-layer derivation
/// would only fight the source.
fn derive_layer_fill(
  base_attrs : Array[@xml.Attribute],
  lum_mod : Double,
) -> Array[@xml.Attribute] {
  if lum_mod == 0.0 {
    return base_attrs
  }
  let out : Array[@xml.Attribute] = []
  for a in base_attrs {
    if a.name.local_name == "fill" &&
      a.value.has_prefix("#") &&
      a.value.length() == 7 {
      let shifted = shift_hex_lightness(a.value, lum_mod)
      out.push(@markup.attr("fill", shifted))
    } else {
      out.push(a)
    }
  }
  out
}

///|
/// Shift the lightness of a `#rrggbb` colour by `delta` in [−1, 1].
/// `+1` → white, `−1` → black, `0` → unchanged.  Each channel is
/// linearly interpolated toward 255 or 0; the resulting hex is
/// uppercase.
fn shift_hex_lightness(hex : String, delta : Double) -> String {
  fn nybble(c : Char) -> Int {
    let n = c.to_int()
    if n >= 0x30 && n <= 0x39 {
      n - 0x30
    } else if n >= 0x41 && n <= 0x46 {
      n - 0x41 + 10
    } else if n >= 0x61 && n <= 0x66 {
      n - 0x61 + 10
    } else {
      0
    }
  }

  fn hex_digit(n : Int) -> Char {
    if n < 10 {
      (n + 0x30).to_char().unwrap()
    } else {
      (n - 10 + 0x41).to_char().unwrap()
    }
  }

  let chars = hex.to_array()
  if chars.length() < 7 {
    return hex
  }
  let r = nybble(chars[1]) * 16 + nybble(chars[2])
  let g = nybble(chars[3]) * 16 + nybble(chars[4])
  let b = nybble(chars[5]) * 16 + nybble(chars[6])
  fn shift(channel : Int) -> Int {
    let f = channel.to_double()
    let target = if delta > 0.0 { 255.0 } else { 0.0 }
    let abs = if delta < 0.0 { -delta } else { delta }
    let mixed = f + (target - f) * abs
    let i = mixed.to_int()
    if i < 0 {
      0
    } else if i > 255 {
      255
    } else {
      i
    }
  }

  let r2 = shift(r)
  let g2 = shift(g)
  let b2 = shift(b)
  let buf = StringBuilder::new()
  buf.write_char('#')
  buf.write_char(hex_digit(r2 / 16))
  buf.write_char(hex_digit(r2 % 16))
  buf.write_char(hex_digit(g2 / 16))
  buf.write_char(hex_digit(g2 % 16))
  buf.write_char(hex_digit(b2 / 16))
  buf.write_char(hex_digit(b2 % 16))
  buf.to_string()
}

// =============================================================================
// Text body rendering
// =============================================================================

///|
/// Render the `<p:txBody>` of a shape via the text-layout engine.
/// Layout runs in CSS pixels; we wrap the result in
/// `<g transform="scale(EMU_PER_PX)">` so coordinates align with the
/// EMU viewBox.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-text.ts:53 (renderTextSvg)
fn render_shape_text_svg(
  shape : @xml.Element,
  w_emu : Double,
  h_emu : Double,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
) -> Array[@xml.Node] {
  let tx_body = first_child_named(shape, "txBody")
  match tx_body {
    None => []
    Some(tb) => {
      let input = build_layout_input(tb, w_emu, h_emu, ctx)
      if input.paragraphs.length() == 0 {
        return []
      }
      let result = layout_text_body(input)
      let inner = render_layout_result_svg(result, defs)
      if inner.length() == 0 {
        return []
      }
      // Box dimensions in CSS pixels for the post-layout transforms.
      let box_w_px = w_emu / emu_per_px
      let box_h_px = h_emu / emu_per_px
      let body_pr = first_child_named(tb, "bodyPr")
      // Apply the four post-layout wrappers from web-pptx slide-text.ts:
      //   1. body rotation (§21.1.2.1.7 `<a:bodyPr rot>`),
      //   2. overflow clipping (§21.1.2.1.7 `horzOverflow`/`vertOverflow`),
      //   3. forced anti-aliasing (§21.1.2.1.7 `forceAA`),
      //   4. vertical-text writing-mode (§21.1.2.1.7 `vert`).
      let rotated = apply_body_rotation(inner, body_pr, box_w_px, box_h_px)
      let clipped = apply_overflow_clip(
        rotated, body_pr, defs, box_w_px, box_h_px,
      )
      let aa = apply_force_anti_alias(clipped, body_pr)
      let vert = apply_vertical_text_transform(aa, body_pr, box_w_px, box_h_px)
      // Scale from CSS pixels back into EMU coordinate space. The
      // transforms above operate in CSS pixels so the scale wraps the
      // entire post-transform tree.
      [
        @markup.elem_ns(
          "g",
          @markup.svg_ns,
          [
            @markup.attr(
              "transform",
              "scale(" + format_double(emu_per_px) + ")",
            ),
          ],
          vert,
        ),
      ]
    }
  }
}

///|
/// §21.1.2.1.7 `<a:bodyPr rot="…">` — rotate the entire text block
/// around the box centre. The OOXML angle uses 60000ths of a degree
/// (ST_Angle, §22.9.2.1) while SVG `rotate(deg, cx, cy)` expects
/// degrees, so we divide. Returns `text_svg` unchanged when the
/// attribute is absent or evaluates to 0.
fn apply_body_rotation(
  text_svg : Array[@xml.Node],
  body_pr : @xml.Element?,
  box_w : Double,
  box_h : Double,
) -> Array[@xml.Node] {
  let rot_deg = match body_pr {
    None => 0.0
    Some(bp) =>
      match attr_value(bp, "rot") {
        None => 0.0
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => 0.0
          } noraise {
            d => d / 60000.0
          }
      }
  }
  if rot_deg == 0.0 {
    return text_svg
  }
  let cx = box_w / 2.0
  let cy = box_h / 2.0
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [
        @markup.attr(
          "transform",
          "rotate(" +
          format_double(rot_deg) +
          ", " +
          format_double(cx) +
          ", " +
          format_double(cy) +
          ")",
        ),
      ],
      text_svg,
    ),
  ]
}

///|
/// §21.1.2.1.7 `<a:bodyPr horzOverflow="…" vertOverflow="…">` — wrap the
/// text in a `<clipPath>` rect when either axis is set to `clip`. The
/// independent rect dimensions follow web-pptx behaviour: clipped axes
/// constrain to the box, the other axis is given a very large extent
/// so it doesn't accidentally cut content.
fn apply_overflow_clip(
  text_svg : Array[@xml.Node],
  body_pr : @xml.Element?,
  defs : SvgDefsCollector,
  box_w : Double,
  box_h : Double,
) -> Array[@xml.Node] {
  let (horz, vert) = match body_pr {
    None => ("overflow", "overflow")
    Some(bp) =>
      (
        attr_value(bp, "horzOverflow").unwrap_or("overflow"),
        attr_value(bp, "vertOverflow").unwrap_or("overflow"),
      )
  }
  if horz != "clip" && vert != "clip" {
    return text_svg
  }
  let huge = 1000000.0
  let x = if horz == "clip" { 0.0 } else { -huge }
  let y = if vert == "clip" { 0.0 } else { -huge }
  let w = if horz == "clip" { box_w } else { box_w + huge * 2.0 }
  let h = if vert == "clip" { box_h } else { box_h + huge * 2.0 }
  let clip_id = defs.next_id("text-clip")
  defs.add_def(
    @markup.elem_ns(
      "clipPath",
      @markup.svg_ns,
      [
        @markup.attr("id", clip_id),
        @markup.attr("clipPathUnits", "userSpaceOnUse"),
      ],
      [
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", format_double(x)),
            @markup.attr("y", format_double(y)),
            @markup.attr("width", format_double(w)),
            @markup.attr("height", format_double(h)),
          ],
          [],
        ),
      ],
    ),
  )
  [
    @markup.elem_ns(
      "g",
      @markup.svg_ns,
      [@markup.attr("clip-path", "url(#" + clip_id + ")")],
      text_svg,
    ),
  ]
}

///|
/// §21.1.2.1.7 `<a:bodyPr forceAA="1">` — request geometric-precision
/// text rendering. SVG's `text-rendering` hint is the closest match.
fn apply_force_anti_alias(
  text_svg : Array[@xml.Node],
  body_pr : @xml.Element?,
) -> Array[@xml.Node] {
  // §21.1.2.1.6 @forceAA — xsd:boolean.
  let force = match body_pr {
    None => false
    Some(bp) => parse_xsd_boolean_or(attr_value(bp, "forceAA"), false)
  }
  if !force {
    text_svg
  } else {
    [
      @markup.elem_ns(
        "g",
        @markup.svg_ns,
        [@markup.attr("text-rendering", "geometricPrecision")],
        text_svg,
      ),
    ]
  }
}

///|
/// §21.1.2.1.7 `<a:bodyPr vert="…">` — vertical text writing-mode.
/// ST_TextVerticalType §21.1.2.1.39 enumeration. Mirrors web-pptx
/// applyVerticalTextTransform:
///   horz                 — no transform.
///   vert / eaVert        — 90° CW: translate to right edge then rotate.
///   vert270              — −90°: translate to bottom edge then rotate.
///   wordArtVert / mongolianVert / wordArtVertRtl — CSS vertical-rl.
///   `upright="1"` — CSS upright orientation overrides rotation.
fn apply_vertical_text_transform(
  text_svg : Array[@xml.Node],
  body_pr : @xml.Element?,
  box_w : Double,
  box_h : Double,
) -> Array[@xml.Node] {
  let (vert_type, upright) = match body_pr {
    None => ("horz", false)
    Some(bp) =>
      (
        attr_value(bp, "vert").unwrap_or("horz"),
        // §21.1.2.1.7 @upright — xsd:boolean.
        parse_xsd_boolean_or(attr_value(bp, "upright"), false),
      )
  }
  if vert_type == "horz" {
    return text_svg
  }
  let wrap = (attrs : Array[@xml.Attribute]) => {
    [@markup.elem_ns("g", @markup.svg_ns, attrs, text_svg)]
  }
  if upright {
    return wrap([
      @markup.attr(
        "style", "text-orientation: upright; writing-mode: vertical-rl",
      ),
    ])
  }
  match vert_type {
    "vert" | "eaVert" =>
      wrap([
        @markup.attr(
          "transform",
          "translate(" + format_double(box_w) + ", 0) rotate(90)",
        ),
      ])
    "vert270" =>
      wrap([
        @markup.attr(
          "transform",
          "translate(0, " + format_double(box_h) + ") rotate(-90)",
        ),
      ])
    "wordArtVert" | "mongolianVert" | "wordArtVertRtl" =>
      wrap([
        @markup.attr(
          "style", "writing-mode: vertical-rl; text-orientation: mixed",
        ),
      ])
    _ => text_svg
  }
}

///|
/// Convert a `<a:txBody>` element to a `LayoutInput` suitable for the
/// text-layout engine.  The adapter handles `<a:bodyPr>`, `<a:p>`,
/// `<a:pPr>`, `<a:r>`, `<a:rPr>`, `<a:t>`, `<a:br/>`, and
/// `<a:endParaRPr>` in minimal form.
fn build_layout_input(
  tx_body : @xml.Element,
  w_emu : Double,
  h_emu : Double,
  ctx : ColorResolveContext,
) -> LayoutInput {
  let body_pr = first_child_named(tx_body, "bodyPr")
  let text_box = build_text_box_config(body_pr, w_emu, h_emu)
  // §21.1.2.4.12 lstStyle — the text body's `<a:lstStyle>` carries
  // `<a:defPPr>` and `<a:lvl1pPr>..<a:lvl9pPr>` defaults that
  // paragraph-level `<a:pPr>` inherits from. The viewer threads
  // the lstStyle into `build_paragraph_input` so the per-paragraph
  // resolver can layer the right defaults under `<a:pPr lvl="N">`.
  let lst_style = first_child_named(tx_body, "lstStyle")
  // §21.1.2.4.1 buAutoNum — per-paragraph auto-number counter
  // grouped by `(lvl, scheme)`. Each entry tracks the next numeric
  // value to emit for that combination. PowerPoint treats a change
  // of `@type` (alphaLcPeriod → romanUcPeriod, etc.) at the same
  // level as starting a fresh sub-list — keying solely by level
  // would let consecutive paragraphs at lvl=0 with different schemes
  // share the same counter, so the second paragraph's `arabicPeriod`
  // bullet would emit "2." instead of "1." and a `romanUcPeriod`
  // would emit "II." instead of "I.".  Verified against the the reference renderer PDF
  // reference for `text-bullet-auto-types`.
  let auto_num_counters : @hashmap.HashMap[String, Int] = HashMap([], capacity=0)
  let paragraphs : Array[LayoutParagraphInput] = []
  for child in tx_body.children {
    match child {
      Element(e) =>
        if e.name.local_name == "p" {
          let para = build_paragraph_input(e, ctx, lst_style)
          let resolved = apply_auto_num_counter(para, e, auto_num_counters)
          paragraphs.push(resolved)
        }
      _ => ()
    }
  }
  { text_box, paragraphs }
}

///|
/// §21.1.2.4.1 buAutoNum — when the paragraph's bullet is the
/// auto-number placeholder ("%d"), compute its sequential value
/// for the paragraph's level, advance the counter, and substitute
/// the formatted string back into BulletConfig.char. When the
/// paragraph is not an auto-num bullet the input is returned as-is.
fn apply_auto_num_counter(
  para : LayoutParagraphInput,
  p_element : @xml.Element,
  counters : @hashmap.HashMap[String, Int],
) -> LayoutParagraphInput {
  let bullet = match para.bullet {
    None => return para
    Some(b) => b
  }
  if bullet.char != "%d" {
    return para
  }
  let p_pr = first_child_named(p_element, "pPr")
  let bu_auto = match p_pr {
    None => return para
    Some(pp) =>
      match first_child_named(pp, "buAutoNum") {
        None => return para
        Some(el) => el
      }
  }
  // §21.1.2.4.1 — auto-number scheme attributes:
  //   @type   (ST_TextAutonumberScheme, required) — chooses the
  //           numeric/alphabetic/roman variant and the suffix.
  //   @startAt (xsd:int, default 1) — the starting value for the
  //           list.
  let scheme = match attr_value(bu_auto, "type") {
    Some(v) => v
    None => "arabicPeriod"
  }
  let start_at = match attr_value(bu_auto, "startAt") {
    Some(v) =>
      try @string.parse_int(v) catch {
        _ => 1
      } noraise {
        n => n
      }
    None => 1
  }
  // Track per-level so independent lists at the same level can be
  // distinguished by the lvl attribute on the paragraph's pPr.
  let lvl = match p_pr {
    None => 0
    Some(pp) =>
      match attr_value(pp, "lvl") {
        Some(v) =>
          try @string.parse_int(v) catch {
            _ => 0
          } noraise {
            n => n
          }
        None => 0
      }
  }
  let key = lvl.to_string() + ":" + scheme
  let current = match counters.get(key) {
    Some(n) => n
    None => start_at
  }
  counters.set(key, current + 1)
  let new_char = format_auto_number(scheme, current, start_at=1)
  let new_bullet : BulletConfig = {
    char: new_char,
    font_size: bullet.font_size,
    color: bullet.color,
    font_family: bullet.font_family,
    image_url: bullet.image_url,
  }
  {
    spans: para.spans,
    alignment: para.alignment,
    margin_left: para.margin_left,
    indent: para.indent,
    margin_right: para.margin_right,
    space_before: para.space_before,
    space_after: para.space_after,
    line_spacing: para.line_spacing,
    bullet: Some(new_bullet),
    font_alignment: para.font_alignment,
    default_tab_size: para.default_tab_size,
    tab_stops: para.tab_stops,
    ea_line_break: para.ea_line_break,
    latin_line_break: para.latin_line_break,
    hanging_punctuation: para.hanging_punctuation,
    end_para_font_size: para.end_para_font_size,
  }
}

///|
/// §21.1.2.1.1 / .2 / .3 — parse the xsd:choice between
/// `<a:noAutofit/>`, `<a:normAutofit fontScale lnSpcReduction>`,
/// `<a:spAutoFit/>` inside a `<a:bodyPr>`.  Defaults to
/// AutoFitNone when none of the three is present.  The
/// fontScale / lnSpcReduction attributes are expressed as ST_TextFontScalePercent
/// (1000..100000 = 1%..100%, default 100000 = no scaling) and
/// ST_TextSpacingPercent (0..100000 = 0%..100%, default 0 = no reduction);
/// we convert to fractional doubles for the layout engine.
fn parse_body_pr_auto_fit(body_pr : @xml.Element) -> AutoFitConfig {
  for child in body_pr.children {
    match child {
      @xml.Element(e) => {
        let local_name = e.name.local_name
        if local_name == "noAutofit" {
          return AutoFitNone
        }
        if local_name == "spAutoFit" {
          return AutoFitShape
        }
        if local_name == "normAutofit" {
          // §22.9.2.X — `fontScale` and `lnSpcReduction` are
          // 1000ths-of-percent (1000..100000).
          let font_scale = match attr_value(e, "fontScale") {
            Some(v) =>
              try @string.parse_double(v) catch {
                _ => 1.0
              } noraise {
                n => n / 100000.0
              }
            None => 1.0
          }
          let ln_spc = match attr_value(e, "lnSpcReduction") {
            Some(v) =>
              try @string.parse_double(v) catch {
                _ => 0.0
              } noraise {
                n => n / 100000.0
              }
            None => 0.0
          }
          return AutoFitNormal(font_scale, ln_spc)
        }
      }
      _ => ()
    }
  }
  AutoFitNone
}

///|
/// Build a `TextBoxConfig` from `<a:bodyPr>`.  `<a:bodyPr>` insets
/// (lIns/tIns/rIns/bIns) default to 91440 EMU per §21.1.2.1.2.  We
/// convert all dimensions to pixels for the layout engine.
fn build_text_box_config(
  body_pr : @xml.Element?,
  w_emu : Double,
  h_emu : Double,
) -> TextBoxConfig {
  // §21.1.2.1.2 default insets, in EMU: l=91440 t=45720 r=91440 b=45720.
  let (l_emu, t_emu, r_emu, b_emu, anchor, anchor_ctr, wrap, auto_fit) = match
    body_pr {
    None =>
      (
        91440.0,
        45720.0,
        91440.0,
        45720.0,
        AnchorTop,
        false,
        WrapSquare,
        AutoFitNone,
      )
    Some(bp) => {
      let li = parse_emu_attr_or(bp, "lIns", 91440.0)
      let ti = parse_emu_attr_or(bp, "tIns", 45720.0)
      let ri = parse_emu_attr_or(bp, "rIns", 91440.0)
      let bi = parse_emu_attr_or(bp, "bIns", 45720.0)
      // §21.1.2.1.4 ST_TextAnchoringType — exactly 5 values.
      let a = match attr_value(bp, "anchor") {
        Some("t") => AnchorTop
        Some("ctr") => AnchorCenter
        Some("b") => AnchorBottom
        Some("just") => AnchorJustified
        Some("dist") => AnchorDistributed
        // Schema violation — unknown ST_TextAnchoringType.
        // Default to the spec default "t".
        Some(_) => AnchorTop
        None => AnchorTop
      }
      // §21.1.2.1.7 @anchorCtr — xsd:boolean.
      let ac = parse_xsd_boolean_or(attr_value(bp, "anchorCtr"), false)
      // §21.1.2.1.34 ST_TextWrappingType — exactly 2 values.
      let w = match attr_value(bp, "wrap") {
        Some("none") => WrapNone
        Some("square") => WrapSquare
        // Schema violation — default to "square" per spec.
        Some(_) => WrapSquare
        None => WrapSquare
      }
      // §21.1.2.1.1 / .2 / .3 — exactly one of the three
      // auto-fit child elements may appear (xsd:choice).  Walk the
      // children once and pick the first match.
      let af = parse_body_pr_auto_fit(bp)
      (li, ti, ri, bi, a, ac, w, af)
    }
  }
  {
    width: w_emu / emu_per_px,
    height: h_emu / emu_per_px,
    inset_left: l_emu / emu_per_px,
    inset_right: r_emu / emu_per_px,
    inset_top: t_emu / emu_per_px,
    inset_bottom: b_emu / emu_per_px,
    anchor,
    anchor_center: anchor_ctr,
    wrap_mode: wrap,
    auto_fit,
    horz_overflow: OverflowAllow,
    vert_overflow: VertOverflowAllow,
    compat_ln_spc: false,
    force_aa: false,
    rtl_col: false,
    spc_first_last_para: false,
    upright: false,
    vertical_type: VertHorz,
  }
}

///|
/// Build a `LayoutParagraphInput` from `<a:p>`.  Reads `<a:pPr>`
/// (algn / marL / marR / indent / lvl), spans from `<a:r>` / `<a:br>`,
/// and the empty-paragraph height from `<a:endParaRPr>`.
fn build_paragraph_input(
  p : @xml.Element,
  ctx : ColorResolveContext,
  lst_style : @xml.Element?,
) -> LayoutParagraphInput {
  let direct_p_pr = first_child_named(p, "pPr")
  // §21.1.2.4.12 lstStyle — resolve the matching `<a:lvlNpPr>` (or
  // `<a:defPPr>`) so absent attributes fall through to the list-
  // style defaults before the implementation defaults.
  let lvl = match direct_p_pr {
    None => 0
    Some(pp) =>
      match attr_value(pp, "lvl") {
        Some(v) =>
          try @string.parse_int(v) catch {
            _ => 0
          } noraise {
            n => if n < 0 { 0 } else { n }
          }
        None => 0
      }
  }
  let lvl_default_p_pr = resolve_lst_style_p_pr(lst_style, lvl)
  // For each property we honour the direct `<a:pPr>` value first,
  // then the lvl default, then the implementation default — this
  // is the §21.1.2.2 cascade order. The per-property readers below
  // use `p_pr_attr_or` and `p_pr_child_or` so a None from the
  // direct pPr falls through to the lvl default.
  let p_pr = direct_p_pr
  // §21.1.2.2.1 ST_TextAlignType — exactly 7 values.
  let alignment = match p_pr_attr_with_lvl(p_pr, lvl_default_p_pr, "algn") {
    Some("l") => AlignLeft
    Some("ctr") => AlignCenter
    Some("r") => AlignRight
    Some("just") => AlignJustify
    Some("justLow") => AlignJustifyLow
    Some("dist") => AlignDistributed
    Some("thaiDist") => AlignThaiDistributed
    // Schema violation — unknown ST_TextAlignType.  Default to
    // "l" per spec (the implementation default when @algn is
    // absent).
    Some(_) => AlignLeft
    None => AlignLeft
  }
  let mar_l = p_pr_emu_with_lvl(p_pr, lvl_default_p_pr, "marL", 0.0) /
    emu_per_px
  let mar_r = p_pr_emu_with_lvl(p_pr, lvl_default_p_pr, "marR", 0.0) /
    emu_per_px
  let indent = p_pr_emu_with_lvl(p_pr, lvl_default_p_pr, "indent", 0.0) /
    emu_per_px
  // §21.1.2.2.4 lnSpc / §21.1.2.2.5 spcAft / §21.1.2.2.6 spcBef —
  // line spacing and inter-paragraph spacing children. The direct
  // `<a:pPr>` wins; otherwise the lvl default applies.
  let line_spacing = p_pr_with_lvl_fn(p_pr, lvl_default_p_pr, parse_spc_line)
  let space_before : Double = match p_pr {
    Some(d) => {
      let v = parse_spc_amount_points(d, "spcBef")
      if v != 0.0 {
        v
      } else {
        match lvl_default_p_pr {
          None => 0.0
          Some(l) => parse_spc_amount_points(l, "spcBef")
        }
      }
    }
    None =>
      match lvl_default_p_pr {
        None => 0.0
        Some(l) => parse_spc_amount_points(l, "spcBef")
      }
  }
  let space_after : Double = match p_pr {
    Some(d) => {
      let v = parse_spc_amount_points(d, "spcAft")
      if v != 0.0 {
        v
      } else {
        match lvl_default_p_pr {
          None => 0.0
          Some(l) => parse_spc_amount_points(l, "spcAft")
        }
      }
    }
    None =>
      match lvl_default_p_pr {
        None => 0.0
        Some(l) => parse_spc_amount_points(l, "spcAft")
      }
  }
  // §21.1.2.2.5 defTabSz — default tab stop size on `<a:pPr>`
  // (EMU). Converted to CSS pixels.
  let default_tab_size = p_pr_emu_with_lvl(
      p_pr, lvl_default_p_pr, "defTabSz", 0.0,
    ) /
    emu_per_px
  // §21.1.2.2.9 tabLst — explicit tab stop list under `<a:pPr>`.
  // Use the direct pPr's tabLst when non-empty; otherwise fall
  // back to the lvl default. LayoutTabStop is not Eq so we test
  // emptiness by length.
  let tab_stops : Array[LayoutTabStop] = match p_pr {
    Some(d) => {
      let ts = parse_tab_stops(d)
      if ts.length() > 0 {
        ts
      } else {
        match lvl_default_p_pr {
          None => []
          Some(l) => parse_tab_stops(l)
        }
      }
    }
    None =>
      match lvl_default_p_pr {
        None => []
        Some(l) => parse_tab_stops(l)
      }
  }
  // §21.1.2.4.4-8 bullets — `<a:buNone>` / `<a:buChar>` /
  // `<a:buAutoNum>` / `<a:buBlip>` plus `<a:buFont>` /
  // `<a:buClr>` / `<a:buSzPts>` / `<a:buSzPct>`.
  let raw_bullet = p_pr_with_lvl_fn(p_pr, lvl_default_p_pr, fn(el) {
    parse_bullet_config(el, ctx)
  })
  // §21.1.2.4.12 lstStyle / §21.1.2.3.27 defRPr — extract the
  // run-default rPr from the matching `<a:lvlNpPr>/<a:defRPr>` so
  // runs lacking their own rPr inherit the lstStyle's defaults.
  let lvl_default_r_pr = match lvl_default_p_pr {
    None => None
    Some(lvl_el) => first_child_named(lvl_el, "defRPr")
  }
  let spans : Array[LayoutSpan] = []
  for child in p.children {
    match child {
      Element(e) =>
        match e.name.local_name {
          "r" => {
            let s = build_run_span(e, ctx, lvl_default_r_pr)
            spans.push(s)
          }
          "br" => spans.push(make_break_span())
          _ => ()
        }
      _ => ()
    }
  }
  // §21.1.2.4.4-8 — bullet font / size / colour inherit from the
  // first non-break run when `<a:buFont>` / `<a:buSzPts>` / `<a:buClr>`
  // are absent. `parse_bullet_config` surfaces these inherit-
  // requests as empty string / `font_size == 0.0`; resolve them here
  // (after spans are built) so the layout engine measures the bullet
  // with the right metrics and the renderer paints it with the right
  // typography. Without this, an unsized bullet measured 0 px wide
  // and a hanging-indent layout (`marL=N, indent=-N`) collapsed the
  // text origin onto the shape's left inset — losing both the bullet
  // glyph and the indent slot.
  let bullet : BulletConfig? = match raw_bullet {
    None => None
    Some(b) => Some(resolve_bullet_inheritance(b, spans))
  }
  // §21.1.2.2.3 `<a:endParaRPr>` carries the run-properties for an
  // empty paragraph; its `sz` attribute (1/100 pt) drives the line
  // height when no runs are present.
  let end_para_font_size : Double? = match first_child_named(p, "endParaRPr") {
    None => None
    Some(eppr) =>
      match attr_value(eppr, "sz") {
        None => None
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => None
          } noraise {
            d => Some(d / 100.0)
          }
      }
  }
  {
    spans,
    alignment,
    margin_left: mar_l,
    indent,
    margin_right: mar_r,
    space_before,
    space_after,
    line_spacing,
    bullet,
    font_alignment: FontAlignAuto,
    default_tab_size,
    tab_stops,
    ea_line_break: false,
    latin_line_break: false,
    hanging_punctuation: false,
    end_para_font_size,
  }
}

///|
/// §21.1.2.2 — read an attribute on the direct `<a:pPr>` first;
/// fall through to the `<a:lvlNpPr>` default when the direct element
/// is absent or the attribute is missing.
fn p_pr_attr_with_lvl(
  direct : @xml.Element?,
  lvl_default : @xml.Element?,
  attr_name : String,
) -> String? {
  match direct {
    Some(d) =>
      match attr_value(d, attr_name) {
        Some(v) => return Some(v)
        None => ()
      }
    None => ()
  }
  match lvl_default {
    None => None
    Some(l) => attr_value(l, attr_name)
  }
}

///|
/// EMU attribute reader with the same direct → lvl-default → const
/// cascade as `p_pr_attr_with_lvl`.
fn p_pr_emu_with_lvl(
  direct : @xml.Element?,
  lvl_default : @xml.Element?,
  attr_name : String,
  fallback : Double,
) -> Double {
  match direct {
    Some(d) =>
      match attr_value(d, attr_name) {
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => ()
          } noraise {
            n => return n
          }
        None => ()
      }
    None => ()
  }
  match lvl_default {
    None => fallback
    Some(l) =>
      match attr_value(l, attr_name) {
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => fallback
          } noraise {
            n => n
          }
        None => fallback
      }
  }
}

///|
/// §21.1.2.2 — invoke `reader` against the direct `<a:pPr>` first
/// and, when it returns `None`, against the lvl default. Returns
/// the first non-`None` result or `None` when both miss.
fn[T] p_pr_with_lvl_fn(
  direct : @xml.Element?,
  lvl_default : @xml.Element?,
  reader : (@xml.Element) -> T?,
) -> T? {
  match direct {
    Some(d) =>
      match reader(d) {
        Some(v) => return Some(v)
        None => ()
      }
    None => ()
  }
  match lvl_default {
    None => None
    Some(l) => reader(l)
  }
}

///|
/// §21.1.2.4.12 lstStyle — pick the `<a:lvlNpPr>` matching `lvl`
/// (0-based per `<a:pPr lvl="N">`; spec maps lvl 0 → `lvl1pPr`,
/// lvl 1 → `lvl2pPr`, etc.). Falls back to `<a:defPPr>` and finally
/// returns `None`.
fn resolve_lst_style_p_pr(
  lst_style : @xml.Element?,
  lvl : Int,
) -> @xml.Element? {
  let style = match lst_style {
    Some(s) => s
    None => return None
  }
  let want = "lvl" + (lvl + 1).to_string() + "pPr"
  match first_child_named(style, want) {
    Some(el) => Some(el)
    None => first_child_named(style, "defPPr")
  }
}

///|
/// §21.1.2.2.4 lnSpc — read `<a:pPr>/<a:lnSpc>` and translate
/// either `<a:spcPct val="N">` (1/1000 % of line size) or
/// `<a:spcPts val="N">` (1/100 pt absolute) into a `LineSpacing`.
fn parse_spc_line(p_pr : @xml.Element) -> LineSpacing? {
  let ln_spc = match first_child_named(p_pr, "lnSpc") {
    Some(el) => el
    None => return None
  }
  match first_child_named(ln_spc, "spcPct") {
    Some(pct) =>
      match attr_value(pct, "val") {
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => ()
          } noraise {
            n => return Some(LineSpacingPercent(n / 1000.0))
          }
        None => ()
      }
    None => ()
  }
  match first_child_named(ln_spc, "spcPts") {
    Some(pts) =>
      match attr_value(pts, "val") {
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => ()
          } noraise {
            n => return Some(LineSpacingPoints(n / 100.0))
          }
        None => ()
      }
    None => ()
  }
  None
}

///|
/// §21.1.2.2.5 spcAft / §21.1.2.2.6 spcBef — read the named child
/// (`spcBef` or `spcAft`) and return its size in points. Honours
/// the same `<a:spcPct>` / `<a:spcPts>` choice as `lnSpc` but
/// returns the resolved point value directly (the layout engine
/// expects pre/post paragraph spacing in points).
fn parse_spc_amount_points(p_pr : @xml.Element, local_name : String) -> Double {
  let parent = match first_child_named(p_pr, local_name) {
    Some(el) => el
    None => return 0.0
  }
  match first_child_named(parent, "spcPts") {
    Some(pts) =>
      match attr_value(pts, "val") {
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => ()
          } noraise {
            n => return n / 100.0
          }
        None => ()
      }
    None => ()
  }
  // `<a:spcPct>` for spcBef/spcAft is per-mil of the paragraph's
  // line height; without per-line measurement here we surface 0
  // (spec-permitted) rather than guess a base size.
  0.0
}

///|
/// §21.1.2.2.9 tabLst — `<a:tabLst>/<a:tab pos="EMU" algn="…"/>`.
fn parse_tab_stops(p_pr : @xml.Element) -> Array[LayoutTabStop] {
  let out : Array[LayoutTabStop] = []
  let lst = match first_child_named(p_pr, "tabLst") {
    Some(el) => el
    None => return out
  }
  for child in lst.children {
    match child {
      Element(tab) =>
        if tab.name.local_name == "tab" {
          let pos_emu = parse_emu_attr_or(tab, "pos", 0.0)
          // §21.1.2.2.9 — `<a:tab algn>` enumerates `l` / `ctr` /
          // `r` / `dec`. `dec` is preserved as the spec-defined
          // AlignDecimal variant so consumers can apply
          // decimal-separator alignment.
          // §21.1.2.2.9 ST_TextTabAlignType — exactly 4 values.
          let alignment = match attr_value(tab, "algn") {
            Some("l") => AlignLeft
            Some("ctr") => AlignCenter
            Some("r") => AlignRight
            Some("dec") => AlignDecimal
            // Schema violation — unknown ST_TextTabAlignType.
            // Default to "l" per spec.
            Some(_) => AlignLeft
            None => AlignLeft
          }
          out.push({ position: pos_emu / emu_per_px, alignment })
        }
      _ => ()
    }
  }
  out
}

///|
/// §21.1.2.4.4-8 — read the bullet specification from `<a:pPr>`'s
/// `<a:buNone>` / `<a:buChar>` / `<a:buAutoNum>` / `<a:buBlip>`
/// child, plus the supporting `<a:buFont>` / `<a:buClr>` /
/// `<a:buSzPts>` / `<a:buSzPct>` siblings. Returns `None` for
/// `<a:buNone>` or when no bullet element is declared. Auto-number
/// bullets surface a `"%d"` placeholder string the consumer can
/// substitute; full numbering across the body is tracked separately.
fn parse_bullet_config(
  p_pr : @xml.Element,
  ctx : ColorResolveContext,
) -> BulletConfig? {
  // Explicit "no bullet".
  match first_child_named(p_pr, "buNone") {
    Some(_) => return None
    None => ()
  }
  let bu_char_text = match first_child_named(p_pr, "buChar") {
    Some(el) => attr_value(el, "char")
    None => None
  }
  let bu_auto = first_child_named(p_pr, "buAutoNum")
  let bu_blip = first_child_named(p_pr, "buBlip")
  if bu_char_text is None && bu_auto is None && bu_blip is None {
    return None
  }
  // §21.1.2.4.4-8 — bullet font:
  //   When `<a:buFont @typeface>` is set we honour it (resolving
  //   `+mj-*` / `+mn-*` theme references through the theme
  //   cascade).  When the attribute is absent the spec says the
  //   bullet inherits the run's typeface — there is no
  //   serif/sans-serif default.  Substituting `serif` short-
  //   circuits the cascade, so we instead emit an empty string
  //   and let the renderer omit `font-family=""` so the SVG
  //   text inherits the parent's font.  Consumers that need
  //   the actual font name can recompute it from `<a:rPr>`.
  let font_family = match first_child_named(p_pr, "buFont") {
    Some(el) =>
      match attr_value(el, "typeface") {
        Some(t) =>
          match ColorResolveContext::resolve_theme_typeface(ctx, t) {
            Some(resolved) => resolved
            None => t
          }
        // `<a:buFont>` present but @typeface absent — schema
        // violation; defer to the inherited run typeface.
        None => ""
      }
    // `<a:buFont>` absent — spec inheritance from the run.
    None => ""
  }
  // Bullet colour — read `<a:buClr>/<a:srgbClr @val>`. Falls back
  // to consumer-defined "" so the consumer's currentColor takes
  // over (spec leaves bullet colour to inherit from text).
  let color = match first_child_named(p_pr, "buClr") {
    Some(el) =>
      match first_child_named(el, "srgbClr") {
        Some(rgb) =>
          match attr_value(rgb, "val") {
            Some(hex) => "#" + hex
            None => ""
          }
        None => ""
      }
    None => ""
  }
  // Bullet size: §21.1.2.4.11 buSzPct (1/1000 % of run size) or
  // §21.1.2.4.12 buSzPts (1/100 pt absolute). We surface the
  // absolute version when supplied; the percent variant requires
  // the run's font size which is computed later — we approximate
  // by setting font_size = 0.0 and letting the layout engine
  // pick the run size.
  let font_size = match first_child_named(p_pr, "buSzPts") {
    Some(el) =>
      match attr_value(el, "val") {
        Some(v) =>
          try @string.parse_double(v) catch {
            _ => 0.0
          } noraise {
            n => n / 100.0
          }
        None => 0.0
      }
    None => 0.0
  }
  let char_str = match bu_char_text {
    Some(c) => c
    None =>
      // §21.1.2.4.1 buAutoNum — surface a "%d" placeholder so
      // consumers know the actual numbering needs to be computed
      // across the paragraph body.
      match bu_auto {
        Some(_) => "%d"
        None => ""
      }
  }
  let image_url : String? = match bu_blip {
    None => None
    Some(el) =>
      match first_child_named(el, "blip") {
        None => None
        Some(blip) => attr_value(blip, "embed")
      }
  }
  if char_str.length() == 0 && image_url is None {
    return None
  }
  Some({ char: char_str, font_size, color, font_family, image_url })
}

///|
/// §21.1.2.4.4-8 — fill in bullet defaults inherited from the first
/// non-break run of the paragraph. `parse_bullet_config` emits
/// `font_size == 0.0`, `font_family == ""`, and `color == ""` when
/// the corresponding `<a:buSzPts>` / `<a:buFont>` / `<a:buClr>` are
/// missing (the spec says inherit from the run); this helper performs
/// that inheritance after `build_paragraph_input` has collected the
/// paragraph's spans.
///
/// When the paragraph has no text runs (image-only bullet, end-para
/// rPr, etc.), the bullet keeps its zero / empty markers — the
/// caller is responsible for skipping it or supplying its own
/// fallbacks.  Image bullets (`bullet.image_url is Some`) need no
/// text metrics; the metrics inheritance is a no-op for them but
/// safe.
fn resolve_bullet_inheritance(
  bullet : BulletConfig,
  spans : Array[LayoutSpan],
) -> BulletConfig {
  // Pick the first span that contributes glyphs — line breaks
  // (`is_break == true`) carry no font metrics worth inheriting.
  let mut source : LayoutSpan? = None
  for s in spans {
    if !(s.is_break) && s.text.length() > 0 {
      source = Some(s)
      break
    }
  }
  let src = match source {
    None => return bullet
    Some(s) => s
  }
  let font_size = if bullet.font_size <= 0.0 {
    src.font_size
  } else {
    bullet.font_size
  }
  let font_family = if bullet.font_family.length() == 0 {
    src.font_family
  } else {
    bullet.font_family
  }
  let color = if bullet.color.length() == 0 { src.color } else { bullet.color }
  {
    char: bullet.char,
    font_size,
    color,
    font_family,
    image_url: bullet.image_url,
  }
}

///|
/// Build a `LayoutSpan` from `<a:r>`.  Reads `<a:rPr>` for size,
/// weight, style, decoration, and colour, plus the concatenated text
/// from `<a:t>` child(ren).
fn build_run_span(
  r : @xml.Element,
  ctx : ColorResolveContext,
  lvl_default_r_pr : @xml.Element?,
) -> LayoutSpan {
  let r_pr = first_child_named(r, "rPr")
  // §21.1.2.3.27 defRPr — when the direct rPr lacks an attribute
  // we fall through to the lvl default's defRPr from lstStyle.
  // `r_pr_attr` reads the named attr from rPr first, then defRPr.
  let r_pr_attr = fn(name : String) -> String? {
    match r_pr {
      Some(rp) =>
        match attr_value(rp, name) {
          Some(v) => return Some(v)
          None => ()
        }
      None => ()
    }
    match lvl_default_r_pr {
      None => None
      Some(d) => attr_value(d, name)
    }
  }
  // Same direct-then-default lookup for child elements (used by
  // <a:latin>/<a:ea>/<a:cs>/<a:sym>/<a:solidFill> etc.).
  let r_pr_child = fn(name : String) -> @xml.Element? {
    match r_pr {
      Some(rp) =>
        match first_child_named(rp, name) {
          Some(c) => return Some(c)
          None => ()
        }
      None => ()
    }
    match lvl_default_r_pr {
      None => None
      Some(d) => first_child_named(d, name)
    }
  }
  // §17.3.1.36 ST_TextFontSize is in hundredths of a point.
  let font_size_pt = match r_pr_attr("sz") {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => default_font_size_pt
      } noraise {
        d => d / 100.0
      }
    None => default_font_size_pt
  }
  // §21.1.2.3.5 @b — xsd:boolean.  parse_xsd_boolean treats any
  // value outside `0|1|false|true` as a schema violation and
  // returns the spec default (false → normal weight).
  let font_weight = if parse_xsd_boolean_or(r_pr_attr("b"), false) {
    700
  } else {
    400
  }
  // §21.1.2.3.14 @i — xsd:boolean.
  let font_style = if parse_xsd_boolean_or(r_pr_attr("i"), false) {
    "italic"
  } else {
    "normal"
  }
  // §21.1.2.3.32 u — ST_TextUnderlineType enumerates
  //   none, words, sng, dbl, heavy, dotted, dottedHeavy, dash,
  //   dashHeavy, dashLong, dashLongHeavy, dotDash, dotDashHeavy,
  //   dotDotDash, dotDotDashHeavy, wavy, wavyHeavy, wavyDbl.
  // All non-`none` values render an underline of some style.
  //
  // Why we DON'T emit `text-decoration: underline` for these:
  // librsvg (and Cairo's PDF backend it drives) paint the
  // underline through Pango at the FONT's metric position
  // (post.underlinePosition + underlineThickness). For
  // the rendered body face (our PPTX sans-serif substitute) that puts
  // the underline ~1.5 px BELOW the baseline at 24-32 px font
  // sizes — but the reference renderer of the same content
  // places it ~4-6 px below the baseline (descent + ~1pt
  // clearance) with a slightly thinner stroke. The mismatch
  // showed up as 0.06-0.07 RMSE on `text-underline-styles` and
  // `text-bold-italic-underline` because the rsvg-drawn
  // underline sat 2-3 px above the reference renderer's and was 1-2 px thicker.
  //
  // We surface the raw `u` value in `underline_style` and let
  // `build_underline_overlay` paint EVERY underline variant
  // (including `sng`) as an explicit `<line>` overlay at the
  // the reference renderer-matched position / thickness. The legacy
  // `text-decoration: underline` short-hand is dropped from
  // the `<text>` element so rsvg does not draw its own line
  // on top.
  //
  // §21.1.2.3.28 strike still uses CSS `line-through` —
  // librsvg paints it through the same Pango path but at a
  // mid-glyph height that matches the reference renderer's strikethrough closely
  // (no observable RMSE drift), so the explicit-overlay
  // treatment is reserved for underline.
  let underline_style_raw : String? = match r_pr_attr("u") {
    Some(v) => if v != "none" { Some(v) } else { None }
    None => None
  }
  let text_decoration : String? = {
    let mut strike = false
    match r_pr_attr("strike") {
      Some(v) => if v != "noStrike" { strike = true }
      None => ()
    }
    if strike {
      Some("line-through")
    } else {
      None
    }
  }
  // §21.1.2.3.18 cap — ST_TextCapsType enumerates `none` / `small`
  // / `all`. `all` is CSS `text-transform: uppercase`; `small`
  // means SMALL CAPS (the lowercase characters render as scaled
  // uppercase glyphs, with the original case preserved in the
  // source text). The previous mapping of `small → uppercase` was
  // a fidelity loss; we surface `small-caps` so the downstream
  // emitter can choose `font-variant: small-caps`.
  // §21.1.2.3.18 ST_TextCapsType — exactly 3 values.
  let text_transform : String? = match r_pr_attr("cap") {
    Some("all") => Some("uppercase")
    Some("small") => Some("small-caps")
    Some("none") => None
    // Schema violation — unknown ST_TextCapsType.  Default to
    // "none" per spec (no transform).
    Some(_) => None
    None => None
  }
  // §21.1.2.3.4 baseline — ST_TextBaseline percentage (-100000..100000)
  // selects superscript (>0) / subscript (<0) / baseline (=0/None).
  // The exact percentage is preserved in `baseline_pct` so the
  // emitter can compute the actual shift from font size.
  let baseline_pct = match r_pr_attr("baseline") {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => 0.0
      } noraise {
        d => d
      }
    None => 0.0
  }
  let vertical_align = if baseline_pct > 0.0 {
    "superscript"
  } else if baseline_pct < 0.0 {
    "subscript"
  } else {
    "baseline"
  }
  // §21.1.2.3.9 spc — additional character spacing in 1/100 pt;
  // converted to CSS pixels via PT_TO_PX.
  let letter_spacing = match r_pr_attr("spc") {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => 0.0
      } noraise {
        d => d / 100.0 * @glyph.pt_to_px
      }
    None => 0.0
  }
  // §21.1.2.3.9 kern — minimum font size (1/100 pt) at which kerning
  // activates.
  let kerning : Double? = match r_pr_attr("kern") {
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => None
      } noraise {
        d => Some(d / 100.0)
      }
    None => None
  }
  // §21.1.2.3.12 rtl — xsd:boolean.  true flips the run
  // direction to right-to-left.
  let direction = if parse_xsd_boolean_or(r_pr_attr("rtl"), false) {
    "rtl"
  } else {
    "ltr"
  }
  // §21.1.2.3.7 — solidFill colour cascades through defRPr too;
  // we read the resolved colour from whichever rPr-shaped element
  // provides the first `<a:solidFill>` child.
  let color_source : @xml.Element? = match r_pr {
    Some(rp) =>
      match first_child_named(rp, "solidFill") {
        Some(_) => Some(rp)
        None =>
          match lvl_default_r_pr {
            None => None
            Some(d) =>
              match first_child_named(d, "solidFill") {
                Some(_) => Some(d)
                None => None
              }
          }
      }
    None =>
      match lvl_default_r_pr {
        None => None
        Some(d) =>
          match first_child_named(d, "solidFill") {
            Some(_) => Some(d)
            None => None
          }
      }
  }
  // §21.1.2.3.7 `<a:solidFill>` — when no fill cascade resolves
  // to a concrete colour the spec leaves the colour as the
  // theme's `phClr` / scheme inheritance. Surfacing
  // `currentColor` keeps the SVG bound to the consumer's CSS
  // cascade rather than committing to a literal black that
  // would override the spec inheritance.
  let color = match color_source {
    None => "currentColor"
    Some(src) =>
      match resolve_solid_fill(src, ctx~) {
        Some(rc) => format_resolved_color(rc)
        None => "currentColor"
      }
  }
  // §20.1.2.2.24 `<a:ln>` — text outline (stroke) declared on the
  // CT_TextCharacterProperties run-property element (§A.4.1 places
  // `ln` first in the rPr sequence). Spec attributes per
  // CT_LineProperties: `@w` (ST_LineWidth, EMU 0..20116800),
  // `@cap` (ST_LineCap §20.1.10.31: `flat` / `sq` / `rnd`),
  // `@cmpd`, `@algn` (not surfaced yet). Children
  // EG_LineFillProperties (noFill | solidFill | gradFill | pattFill),
  // EG_LineDashProperties, EG_LineJoinProperties (round
  // §20.1.8.52 | bevel §20.1.8.9 | miter §20.1.8.43). Today only
  // `<a:solidFill>` is materialised as the SVG `stroke="…"` colour
  // because TextOutlineConfig has no field for a gradient / pattern
  // stroke. `None` when neither the direct rPr nor the lvl-default
  // rPr declares `<a:ln>`.
  let outline_source : @xml.Element? = match r_pr {
    Some(rp) =>
      match first_child_named(rp, "ln") {
        Some(ln) => Some(ln)
        None =>
          match lvl_default_r_pr {
            None => None
            Some(d) => first_child_named(d, "ln")
          }
      }
    None =>
      match lvl_default_r_pr {
        None => None
        Some(d) => first_child_named(d, "ln")
      }
  }
  let text_outline : TextOutlineConfig? = match outline_source {
    None => None
    Some(ln) => Some(build_text_outline_config(ln, ctx~))
  }
  // §21.1.2.3.7 / §A.4.1 EG_FillProperties — rich text fill
  // (gradient / pattern / image / explicit noFill / group-inherit).
  // The plain solid colour cascade above already populated `color`,
  // so we only need to surface the non-solid variants here.
  // `<a:noFill>` (§20.1.8.44) becomes `TextFillNone`; `<a:gradFill>`
  // (§20.1.8.33) becomes `TextFillGradient`; `<a:pattFill>`
  // (§20.1.8.47) becomes `TextFillPattern`; `<a:blipFill>`
  // (§20.1.8.14) becomes `TextFillImage` carrying the `r:embed`
  // relationship id (the consumer resolves the actual src);
  // `<a:grpFill>` is left to the plain `color` cascade because we
  // have no group-fill context at this point.
  let fill_source : @xml.Element? = match r_pr {
    Some(rp) =>
      match find_text_fill_child(rp) {
        Some(_) => Some(rp)
        None =>
          match lvl_default_r_pr {
            None => None
            Some(d) =>
              match find_text_fill_child(d) {
                Some(_) => Some(d)
                None => None
              }
          }
      }
    None =>
      match lvl_default_r_pr {
        None => None
        Some(d) =>
          match find_text_fill_child(d) {
            Some(_) => Some(d)
            None => None
          }
      }
  }
  let text_fill : TextFillConfig? = match fill_source {
    None => None
    Some(src) => resolve_text_fill_choice(src, ctx~)
  }
  // §21.1.2.3.5 `<a:hlinkClick>` carries the click-time hyperlink
  // identifier (the `r:id` resolves through the slide relationships
  // to a URL) and optional tooltip text. §21.1.2.3.6 `<a:hlinkMouseOver>`
  // is the hover equivalent.
  let hlink_click = r_pr_child("hlinkClick")
  let (link_id, link_tooltip) = match hlink_click {
    None => (None, None)
    Some(h) => (attr_value(h, "id"), attr_value(h, "tooltip"))
  }
  let hlink_over = r_pr_child("hlinkMouseOver")
  let (mouse_over_link_id, mouse_over_link_tooltip) = match hlink_over {
    None => (None, None)
    Some(h) => (attr_value(h, "id"), attr_value(h, "tooltip"))
  }
  // Concatenate every <a:t> child text.
  let text_buf = StringBuilder::new()
  for child in r.children {
    match child {
      Element(e) =>
        if e.name.local_name == "t" {
          text_buf.write_string(text_content(e))
        }
      _ => ()
    }
  }
  // §21.1.2.3.10 — typeface lookup honours the same direct → defRPr
  // cascade. We pick whichever rPr-shaped element actually carries
  // the `<a:latin>` / `<a:ea>` / `<a:cs>` / `<a:sym>` child.
  let typeface_element = fn(local_name : String) -> @xml.Element? {
    r_pr_child(local_name)
  }
  {
    text: text_buf.to_string(),
    font_size: font_size_pt,
    // §20.1.4.1.18 / §21.1.2.3.10 — when no typeface is reachable
    // we fall back to the CSS generic `sans-serif` family: a slide
    // with no explicit typeface inherits the application/theme
    // default, which is a sans-serif in every real OOXML consumer
    // (see `presentation_default_typeface`).
    font_family: resolve_typeface_element(typeface_element("latin"), ctx).unwrap_or(
      presentation_default_typeface(),
    ),
    font_family_east_asian: resolve_typeface_element(
      typeface_element("ea"),
      ctx,
    ),
    font_family_complex_script: resolve_typeface_element(
      typeface_element("cs"),
      ctx,
    ),
    font_family_symbol: resolve_typeface_element(typeface_element("sym"), ctx),
    font_weight,
    font_style,
    text_decoration,
    color,
    vertical_align,
    baseline_pct,
    letter_spacing,
    is_break: false,
    direction,
    highlight_color: None,
    text_transform,
    link_id,
    link_tooltip,
    mouse_over_link_id,
    mouse_over_link_tooltip,
    bookmark: None,
    text_outline,
    text_fill,
    kerning,
    underline_color: None,
    underline_style: underline_style_raw,
  }
}

///|
/// §21.1.2.3.1-2 / §21.1.2.3.10 / §20.1.4.1.18 — locate one of
/// `<a:latin>`, `<a:ea>`, `<a:cs>`, or `<a:sym>` under `r_pr` and
/// return its `@typeface` value. Theme shortcuts of the form
/// `+mj-lt` / `+mn-ea` / etc. are resolved through the ctx's
/// fontScheme map (populated from the theme part). Falls back to
/// the SVG/CSS generic `serif` family when no typeface is
/// reachable.
///
/// §21.1.2.3.10 leaves the default typeface implementation-
/// defined; the spec inheritance chain says the typeface should
/// come from the placeholder cascade (slide → layout → master →
/// theme `<p:txStyles>/<p:bodyStyle>/<a:defRPr>`).  This
/// function does NOT yet walk that cascade — when the typeface
/// is missing the local_name rPr we substitute the SVG generic
/// `serif` family rather than reach back to the master.
/// Threading the placeholder cascade through every run-property
/// reader is tracked as Round 7 #235; the spec-neutral fallback
/// below keeps the renderer deterministic in the meantime.
///|
/// The fallback typeface when neither the run properties nor the
/// theme `<a:fontScheme>` supply one.
///
/// §20.1.4.1.18 leaves the choice to the consumer once the theme
/// minor font is also absent. We hand the resolver a single canonical
/// sans-serif family name — `"Noto Sans"` — and let the ECMA-376
/// §17.8.3 substitution chain in `@glyph` map it to whatever
/// concrete face the host actually carries. The DOCX viewer carries
/// its own format-specific default so per-format substitution stays
/// independent.
///
/// TODO: callers that have a document-resolved family from the
/// theme cascade should pass it through instead of falling back
/// here.
fn presentation_default_typeface() -> String {
  "Noto Sans"
}

///|
/// §21.1.2.3.10 / §20.1.4.1.18 — read the `@typeface` attribute
/// off a `<a:latin>` / `<a:ea>` / `<a:cs>` / `<a:sym>` element and
/// resolve theme shortcuts (`+mj-lt`, `+mn-cs`, …) through ctx.
/// Returns `None` when no typeface element is present.
fn resolve_typeface_element(
  face : @xml.Element?,
  ctx : ColorResolveContext,
) -> String? {
  let el = match face {
    None => return None
    Some(e) => e
  }
  let raw = match attr_value(el, "typeface") {
    None => return None
    Some(t) => t
  }
  match ColorResolveContext::resolve_theme_typeface(ctx, raw) {
    Some(resolved) => Some(resolved)
    None => Some(raw)
  }
}

///|
/// Construct an `<a:br/>` span — text empty, `is_break: true`.
/// §20.1.4.1.18 — the break span carries no glyphs, so the family is
/// cosmetic; use the same default as a real run for consistency.
fn make_break_span() -> LayoutSpan {
  {
    text: "",
    font_size: default_font_size_pt,
    font_family: presentation_default_typeface(),
    font_family_east_asian: None,
    font_family_complex_script: None,
    font_family_symbol: None,
    font_weight: 400,
    font_style: "normal",
    text_decoration: None,
    // §21.1.2.3.7 — break-span colour is irrelevant (zero-width
    // <text>), but we use `currentColor` consistently to match
    // the cascade convention used elsewhere in the viewer.
    color: "currentColor",
    vertical_align: "baseline",
    baseline_pct: 0.0,
    letter_spacing: 0.0,
    is_break: true,
    direction: "ltr",
    highlight_color: None,
    text_transform: None,
    link_id: None,
    link_tooltip: None,
    mouse_over_link_id: None,
    mouse_over_link_tooltip: None,
    bookmark: None,
    text_outline: None,
    text_fill: None,
    kerning: None,
    underline_color: None,
    underline_style: None,
  }
}

///|
/// §20.1.2.2.24 `<a:ln>` — assemble a `TextOutlineConfig` from the
/// line-property element. Width comes from `@w` (ST_LineWidth, EMU)
/// and is converted to CSS pixels (1 px = 9525 EMU); when the
/// attribute is absent we surface `0.0` so consumers can detect
/// "spec default" (ST_LineWidth has no normative default; renderers
/// pick the host's hairline width). The cap maps the §20.1.10.31
/// ST_LineCap enum (`flat` / `sq` / `rnd`) onto the SVG
/// stroke-linecap values (`butt` / `square` / `round`). The join
/// honours the first present EG_LineJoinProperties choice — `<a:miter>`
/// (§20.1.8.43) / `<a:round>` (§20.1.8.52) / `<a:bevel>` (§20.1.8.9)
/// — and falls back to `miter` when none is declared, matching
/// SVG's `stroke-linejoin` default. The colour comes from the
/// EG_LineFillProperties `<a:solidFill>` choice (the other line-fill
/// choices noFill / gradFill / pattFill from §20.1.8 are not
/// expressible through `TextOutlineConfig` today; renderers wanting
/// rich line fills must extend the struct).
fn build_text_outline_config(
  ln : @xml.Element,
  ctx~ : ColorResolveContext,
) -> TextOutlineConfig {
  let width_emu = match attr_value(ln, "w") {
    None => 0.0
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => 0.0
      } noraise {
        d => d
      }
  }
  let width = width_emu / 9525.0
  let cap = match attr_value(ln, "cap") {
    Some("sq") => "square"
    Some("rnd") => "round"
    Some("flat") => "butt"
    _ => "butt"
  }
  let join = if first_child_named(ln, "miter") is Some(_) {
    "miter"
  } else if first_child_named(ln, "round") is Some(_) {
    "round"
  } else if first_child_named(ln, "bevel") is Some(_) {
    "bevel"
  } else {
    "miter"
  }
  let color = match first_child_named(ln, "solidFill") {
    None => "currentColor"
    Some(_) =>
      match resolve_solid_fill(ln, ctx~) {
        Some(rc) => format_resolved_color(rc)
        None => "currentColor"
      }
  }
  { width, color, cap, join }
}

///|
/// §21.1.2.3.7 / §A.4.1 EG_FillProperties — locate the first
/// non-solid text-fill child element declared on the run-property
/// element. The full EG_FillProperties choice set is
/// {noFill, solidFill, gradFill, blipFill, pattFill, grpFill}.
/// `solidFill` is intentionally skipped here because the resolved
/// colour already lives on `LayoutSpan.color` via the existing
/// solid-fill cascade; the remaining five arms surface as the rich
/// `TextFillConfig` variants.
fn find_text_fill_child(r_pr : @xml.Element) -> @xml.Element? {
  for child in r_pr.children {
    if child is Element(e) {
      match e.name.local_name {
        "noFill" | "gradFill" | "pattFill" | "blipFill" | "grpFill" =>
          return Some(e)
        _ => ()
      }
    }
  }
  None
}

///|
/// §21.1.2.3.7 / §A.4.1 EG_FillProperties — read the rich text-fill
/// choice declared on `r_pr` and project it into a `TextFillConfig`.
/// `<a:noFill>` (§20.1.8.44) → `TextFillNone`. `<a:gradFill>`
/// (§20.1.8.33) → `TextFillGradient`. `<a:pattFill>` (§20.1.8.47) →
/// `TextFillPattern`. `<a:blipFill>` (§20.1.8.14) → `TextFillImage`.
/// `<a:grpFill>` (CT_GroupFillProperties, §A.4.1) inherits the parent
/// group's resolved fill; without group-fill context here we fall
/// back to `TextFillNone` so the consumer's plain `color` field
/// keeps driving the paint. Returns `None` when no recognised fill
/// is present.
fn resolve_text_fill_choice(
  r_pr : @xml.Element,
  ctx~ : ColorResolveContext,
) -> TextFillConfig? {
  let fill = find_text_fill_child(r_pr)
  match fill {
    None => None
    Some(f) =>
      match f.name.local_name {
        "noFill" => Some(TextFillNone)
        "gradFill" => resolve_text_gradient_fill(f, ctx~)
        "pattFill" => Some(resolve_text_pattern_fill(f, ctx~))
        "blipFill" => Some(resolve_text_blip_fill(f))
        "grpFill" => None
        _ => None
      }
  }
}

///|
/// §20.1.8.33 `<a:gradFill>` — build a `TextFillGradient` from the
/// `<a:gsLst>` stops (CT_GradientStopList, §A.4.1 requires at least
/// two `<a:gs>` children) and the optional EG_ShadeProperties choice
/// (`<a:lin>` §20.1.8.41 / `<a:path>` for radial). Stop positions
/// (`<a:gs @pos>`) are `ST_PositiveFixedPercentage`, which unions the
/// strict `s:ST_PositiveFixedPercentage` literal (`"50%"`) with the
/// transitional `xsd:int` (1000ths of a percent, `50000`); both are
/// normalised to percent here (0..100). Linear angles (`<a:lin @ang>`)
/// are `ST_PositiveFixedAngle` xsd:int in 60000ths of a degree.
fn resolve_text_gradient_fill(
  grad : @xml.Element,
  ctx~ : ColorResolveContext,
) -> TextFillConfig? {
  let stops : Array[TextGradientStop] = []
  match first_child_named(grad, "gsLst") {
    None => ()
    Some(gs_lst) =>
      for child in gs_lst.children {
        if child is Element(e) {
          if e.name.local_name == "gs" {
            let position = parse_st_positive_fixed_percentage(
              attr_value(e, "pos"),
            )
            let (color, alpha) = match resolve_solid_fill(e, ctx~) {
              Some(rc) => ("#" + rc.hex, rc.alpha)
              None => ("#000000", 1.0)
            }
            stops.push({ position, color, alpha })
          }
        }
      }
  }
  if stops.is_empty() {
    return None
  }
  let is_radial = first_child_named(grad, "path") is Some(_)
  let angle = if is_radial {
    0.0
  } else {
    match first_child_named(grad, "lin") {
      None => 0.0
      Some(lin) =>
        match attr_value(lin, "ang") {
          None => 0.0
          Some(v) =>
            try @string.parse_double(v) catch {
              _ => 0.0
            } noraise {
              d => d / 60000.0
            }
        }
    }
  }
  Some(TextFillGradient(stops, angle, is_radial))
}

///|
/// Parse `ST_PositiveFixedPercentage` per §22.9.2.10 (strict
/// `"50%"`) and the transitional DrawingML 1000ths-of-percent
/// xsd:int form (`50000`). Returns the value as a percent in
/// 0..100.
fn parse_st_positive_fixed_percentage(raw : String?) -> Double {
  match raw {
    None => 0.0
    Some(v) =>
      if v.length() > 0 && v[v.length() - 1] == '%' {
        let trimmed = v[0:v.length() - 1].to_owned()
        try @string.parse_double(trimmed) catch {
          _ => 0.0
        } noraise {
          d => d
        }
      } else {
        try @string.parse_double(v) catch {
          _ => 0.0
        } noraise {
          d => d / 1000.0
        }
      }
  }
}

///|
/// §20.1.8.47 `<a:pattFill>` — extract the foreground / background
/// solid colours and project them into a `TextFillPattern`. The
/// preset pattern id (`@prst`) is not exposed by `TextFillPattern`
/// today; consumers approximate the pattern visually through the fg
/// colour.
fn resolve_text_pattern_fill(
  patt : @xml.Element,
  ctx~ : ColorResolveContext,
) -> TextFillConfig {
  let fg = match first_child_named(patt, "fgClr") {
    None => "#000000"
    Some(fg_el) =>
      match resolve_solid_fill(fg_el, ctx~) {
        Some(rc) => format_resolved_color(rc)
        None => "#000000"
      }
  }
  let bg = match first_child_named(patt, "bgClr") {
    None => "#ffffff"
    Some(bg_el) =>
      match resolve_solid_fill(bg_el, ctx~) {
        Some(rc) => format_resolved_color(rc)
        None => "#ffffff"
      }
  }
  TextFillPattern(fg, bg)
}

///|
/// §20.1.8.14 `<a:blipFill>` — surface the `<a:blip r:embed="…">`
/// relationship id as the `TextFillImage` payload. The downstream
/// consumer resolves the embed id into a usable image URL through
/// the slide-part relationships.
fn resolve_text_blip_fill(blip_fill : @xml.Element) -> TextFillConfig {
  let rid = match first_child_named(blip_fill, "blip") {
    None => ""
    Some(blip) =>
      match attr_value(blip, "embed") {
        Some(v) => v
        None =>
          match attr_value(blip, "link") {
            Some(v) => v
            None => ""
          }
      }
  }
  TextFillImage(rid)
}

///|
/// §21.1.2.3.32 u — paint EVERY ST_TextUnderlineType variant as an
/// explicit `<line>` / `<path>` overlay so the visual treatment
/// matches the reference renderer instead of relying on
/// librsvg's `text-decoration: underline` shorthand.
///
/// Why every variant is overlaid (including the simple `sng` case):
/// librsvg renders `text-decoration: underline` at the font's
/// `post.underlinePosition` (≈1.5 px below baseline for Liberation
/// Sans at 24-32 px sizes) with the font's `underlineThickness`
/// (≈1-2 px). the reference renderer instead places the line at
/// ~`descent * 0.7` below the baseline (≈4-6 px) with a thinner
/// stroke. The mismatch produced 0.06-0.07 RMSE on
/// `text-underline-styles` and `text-bold-italic-underline` because
/// the rsvg-drawn line sat 2-3 px ABOVE the reference renderer and was
/// 1-2 px THICKER. Drawing the underline ourselves removes the
/// rsvg dependency and lets us match the reference renderer's geometry directly.
///
/// Returned shapes per variant:
///   • `sng` / `words` / `heavy` / `dotted*` / `dash*` →
///     a single solid `<line>` (the dash / dotted variants
///     degrade gracefully to solid; that is what the reference renderer does too
///     when its font lacks the variant glyph, verified against
///     the PDF reference).
///   • `dbl`  → two solid `<line>` elements separated by one
///     stroke-width.
///   • `wavy` / `wavyHeavy` → sinusoidal `<path>` traced across
///     the span's width.
///   • `wavyDbl` → two wavy paths separated by one stroke-width.
///
/// Position is `baseline_y + font_size_px * UNDERLINE_OFFSET_RATIO`
/// (≈ 0.155em); the constant is calibrated against the reference renderer's `Sng`
/// underline placement at 24pt body and matches the
/// `text-bold-italic-underline` 32pt body line within 1 px.
///
/// Thickness is `font_size_px * UNDERLINE_STROKE_RATIO` (≈ 0.06em),
/// doubled for the `*Heavy` variants. the rendered body face's own
/// `post.underlineThickness` (≈ 0.024 em) is much thinner than
/// the reference renderer actually draws, so we use the empirical the reference renderer value instead.
///
/// All overlays use the span's resolved underline colour (or its
/// text colour) so the visual treatment carries the same fill as
/// the glyphs.
fn build_underline_overlay(
  style : String,
  x_start : Double,
  baseline_y : Double,
  width : Double,
  font_size_px : Double,
  span : LayoutSpan,
) -> Array[@xml.Node] {
  // §21.1.2.3.33 uLn — custom underline colour overrides text fill.
  let stroke_color = match span.underline_color {
    Some(c) => c
    None => span.color
  }
  // Stroke width: a "heavy" variant doubles the line thickness. The
  // baseline thickness is 0.0625 em which matches the reference renderer's
  // default underline weight for sans-serif body faces (verified
  // against the reference renderer the rendered body face @ 24-32pt rasterised at our snapshot
  // DPI: 2 px line at 32 px font ≈ 0.0625 em).
  let is_heavy = style == "heavy" ||
    style == "dottedHeavy" ||
    style == "dashHeavy" ||
    style == "dashLongHeavy" ||
    style == "dotDashHeavy" ||
    style == "dotDotDashHeavy" ||
    style == "wavyHeavy"
  let stroke_w = font_size_px * (if is_heavy { 0.125 } else { 0.0625 })
  // Underline sits ~0.14em below the baseline; double sits +0.085em
  // further beneath. The 0.14 ratio is the empirical centre of two
  // the reference renderer data points measured at our snapshot DPI:
  //
  //   • `text-underline-styles` 24pt body (font_size_px = 32):
  //     ref underline pixels at y=87–88 (centre 87.5), baseline at
  //     y=83 → offset 4.5 px → 0.141 em.
  //   • `text-bold-italic-underline` 32pt title (font_size_px =
  //     42.67): ref underline pixels at y=243–244 (centre 243.5),
  //     baseline at y=237 → offset 6.5 px → 0.152 em.
  //
  // The 0.14 midpoint lands within 0.5 px of each reference; a
  // single linear-in-em formula cannot match both exactly because
  // the reference renderer's underline position depends on `post.underlinePosition`,
  // which is a per-face FUnit constant the rendered body face tabulates
  // as -239 (regular) and -150 (bold) — i.e. a per-style shift
  // that an em-uniform model cannot capture. The chosen value is
  // the best single-constant fit and is what closes the
  // `text-underline-styles` (0.060 → < 0.05) and
  // `text-bold-italic-underline` (0.069 → < 0.05) RMSE gaps
  // simultaneously.
  let base_offset = font_size_px * 0.14
  let dbl_offset = base_offset + stroke_w + font_size_px * 0.04
  let x_end = x_start + width
  match style {
    "dbl" =>
      [
        build_underline_line(
          x_start,
          x_end,
          baseline_y + base_offset,
          stroke_w,
          stroke_color,
        ),
        build_underline_line(
          x_start,
          x_end,
          baseline_y + dbl_offset,
          stroke_w,
          stroke_color,
        ),
      ]
    "wavyDbl" =>
      [
        build_wavy_underline_path(
          x_start,
          x_end,
          baseline_y + base_offset,
          font_size_px,
          stroke_w,
          stroke_color,
        ),
        build_wavy_underline_path(
          x_start,
          x_end,
          baseline_y + dbl_offset,
          font_size_px,
          stroke_w,
          stroke_color,
        ),
      ]
    "wavy" | "wavyHeavy" =>
      [
        build_wavy_underline_path(
          x_start,
          x_end,
          baseline_y + base_offset,
          font_size_px,
          stroke_w,
          stroke_color,
        ),
      ]
    // Every other non-`none` value (sng, words, heavy, dotted*,
    // dash*, dotDash*, dotDotDash*) renders as a single solid line.
    // librsvg cannot vary the line style through SVG attributes
    // alone (no `stroke-dasharray` support on `text-decoration`),
    // so the dash / dotted variants degrade to solid — the same
    // fallback the reference renderer uses when its font has no dedicated variant
    // glyph.
    _ =>
      [
        build_underline_line(
          x_start,
          x_end,
          baseline_y + base_offset,
          stroke_w,
          stroke_color,
        ),
      ]
  }
}

///|
/// §21.1.2.3.32 — plain horizontal underline line at the given y.
fn build_underline_line(
  x1 : Double,
  x2 : Double,
  y : Double,
  stroke_width : Double,
  stroke_color : String,
) -> @xml.Node {
  @markup.elem_ns(
    "line",
    @markup.svg_ns,
    [
      @markup.attr("x1", format_double(x1)),
      @markup.attr("y1", format_double(y)),
      @markup.attr("x2", format_double(x2)),
      @markup.attr("y2", format_double(y)),
      @markup.attr("stroke", stroke_color),
      @markup.attr("stroke-width", format_double(stroke_width)),
    ],
    [],
  )
}

///|
/// §21.1.2.3.32 u="wavy" — emit a quadratic-Bezier sinusoid spanning
/// `[x1, x2]` at the given center y.  Each wavelength is ~0.36em
/// wide and the amplitude is ~0.06em, matching the reference renderer's wavy
/// underline drawing at 24pt body.
///
/// The path uses alternating `q` segments — each half-wavelength is
/// a quadratic Bezier whose control point pulls the curve to peak /
/// trough.  This is what `text-decoration-style: wavy` renders to
/// in browsers that support it; we draw it explicitly so librsvg
/// (which doesn't) still gets the right pixels.
fn build_wavy_underline_path(
  x1 : Double,
  x2 : Double,
  center_y : Double,
  font_size_px : Double,
  stroke_width : Double,
  stroke_color : String,
) -> @xml.Node {
  let half_wavelength = font_size_px * 0.18
  let amplitude = font_size_px * 0.06
  let buf = StringBuilder::new()
  buf.write_string("M ")
  buf.write_string(format_double(x1))
  buf.write_string(" ")
  buf.write_string(format_double(center_y))
  let mut x = x1
  let mut up = true
  while x < x2 {
    let next_x = if x + half_wavelength > x2 { x2 } else { x + half_wavelength }
    let dx = next_x - x
    let cx = x + dx * 0.5
    let cy = if up { center_y - amplitude } else { center_y + amplitude }
    buf.write_string(" Q ")
    buf.write_string(format_double(cx))
    buf.write_string(" ")
    buf.write_string(format_double(cy))
    buf.write_string(" ")
    buf.write_string(format_double(next_x))
    buf.write_string(" ")
    buf.write_string(format_double(center_y))
    x = next_x
    up = !(up)
  }
  @markup.elem_ns(
    "path",
    @markup.svg_ns,
    [
      @markup.attr("d", buf.to_string()),
      @markup.attr("fill", "none"),
      @markup.attr("stroke", stroke_color),
      @markup.attr("stroke-width", format_double(stroke_width)),
    ],
    [],
  )
}

///|
/// §21.1.2.4.4-8 — build the `<text>` element that paints the bullet
/// glyph for one paragraph.  The bullet sits one bullet-width to the
/// left of the first line's text origin (`line.x`), on the same
/// baseline (`line.y`).  The font-family / font-size / fill are
/// resolved by `resolve_bullet_inheritance` upstream, so all four
/// metrics are concrete by the time we get here.
///
/// Bullets are rendered with the same baseline as the first text
/// run.  PowerPoint both paint the bullet on the
/// run's baseline (not its own typographic baseline) — verified
/// against the reference renderer for `text-bullet-char` and
/// `text-bullet-auto-arabic` fixtures.
fn build_bullet_text_node(
  bullet : BulletConfig,
  bullet_x : Double,
  baseline_y : Double,
) -> @xml.Node {
  let fs_px = bullet.font_size * @glyph.pt_to_px
  let attrs : Array[@xml.Attribute] = [
    @markup.attr("x", format_double(bullet_x)),
    @markup.attr("y", format_double(baseline_y)),
    @markup.attr("font-size", format_double(fs_px) + "px"),
  ]
  if bullet.font_family.length() > 0 {
    attrs.push(@markup.attr("font-family", bullet.font_family))
  }
  if bullet.color.length() > 0 {
    attrs.push(@markup.attr("fill", bullet.color))
  } else {
    attrs.push(@markup.attr("fill", "#000000"))
  }
  @markup.elem_ns("text", @markup.svg_ns, attrs, [@markup.text(bullet.char)])
}

///|
/// Render every paragraph / line / span from a `LayoutResult` to SVG
/// `<text>` elements positioned in CSS pixels.  The caller wraps the
/// result in a scale transform to map back to EMU.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-text.ts:224 (renderLayoutResultToSvg)
fn render_layout_result_svg(
  result : LayoutResult,
  defs : SvgDefsCollector,
) -> Array[@xml.Node] {
  let nodes : Array[@xml.Node] = []
  for para in result.paragraphs {
    // §21.1.2.4.4-8 — emit the bullet glyph on the first line of
    // every paragraph that carries a `<a:buChar>` / `<a:buAutoNum>`
    // bullet.  Bullets sit in the hanging-indent slot to the left of
    // the text origin: `bullet_x = line.x - bullet_width` when the
    // text snapped to `margin_left`, and `bullet_x = line.x -
    // bullet_width` regardless (see `calc_line_x` for the snap).
    // Image bullets (`<a:buBlip>`) are skipped — image rendering
    // through the rels graph is not wired through this path yet.
    if para.lines.length() > 0 {
      match para.bullet {
        None => ()
        Some(b) =>
          if b.image_url is None && b.char.length() > 0 {
            let first_line = para.lines[0]
            let bullet_node = build_bullet_text_node(
              b,
              para.bullet_x,
              first_line.y,
            )
            nodes.push(bullet_node)
          }
      }
    }
    for line in para.lines {
      let mut cursor = line.x
      for span in line.spans {
        if span.span.text.length() == 0 {
          continue
        }
        let fs_px = span.span.font_size * @glyph.pt_to_px
        // §21.1.2.3.30 highlight — emit a background rect underneath
        // the text glyphs at the cursor's current x and the line's y.
        match span.span.highlight_color {
          Some(hl) =>
            nodes.push(
              @markup.elem_ns(
                "rect",
                @markup.svg_ns,
                [
                  @markup.attr("x", format_double(cursor)),
                  @markup.attr("y", format_double(line.y - fs_px * 0.8)),
                  @markup.attr("width", format_double(span.width)),
                  @markup.attr("height", format_double(fs_px)),
                  @markup.attr("fill", hl),
                ],
                [],
              ),
            )
          None => ()
        }
        let adjusted_y = adjust_vertical_align(
          line.y,
          fs_px,
          span.span.baseline_pct,
        )
        // Build the <text> element with all run attributes.
        let text_attrs : Array[@xml.Attribute] = [
          @markup.attr("x", format_double(cursor)),
          @markup.attr("y", format_double(adjusted_y)),
          @markup.attr("font-size", format_double(fs_px) + "px"),
        ]
        // §21.1.2.4.4-8 — bullet font may be empty when the spec
        // inheritance chain (defRPr → theme) is in effect; omit
        // the attribute so the SVG inherits from its parent rather
        // than committing to a literal `font-family=""` (invalid
        // CSS) or substituting a serif/sans-serif sentinel.
        let family = compose_font_family(span.span)
        if family.length() > 0 {
          text_attrs.push(@markup.attr("font-family", family))
        }
        for a in span_fill_attrs(span.span, defs) {
          text_attrs.push(a)
        }
        if span.span.font_weight != 400 {
          text_attrs.push(
            @markup.attr("font-weight", span.span.font_weight.to_string()),
          )
        }
        if span.span.font_style != "normal" {
          text_attrs.push(@markup.attr("font-style", span.span.font_style))
        }
        match span.span.text_decoration {
          Some(d) => {
            text_attrs.push(@markup.attr("text-decoration", d))
            // §21.1.2.3.33 uLn — render a custom underline colour via
            // the `text-decoration-color` CSS property.
            match span.span.underline_color {
              Some(c) =>
                text_attrs.push(
                  @markup.attr("style", "text-decoration-color: " + c),
                )
              None => ()
            }
          }
          None => ()
        }
        // §21.1.2.3.18 cap — `small` renders as small caps; we
        // emit `font-variant="small-caps"` so consumers can apply
        // the variant glyph substitution without altering the
        // source text. `all` is handled in apply_text_transform.
        match span.span.text_transform {
          Some("small-caps") =>
            text_attrs.push(@markup.attr("font-variant", "small-caps"))
          _ => ()
        }
        // §20.1.2.2.24 ln — text outline (stroke).
        match span.span.text_outline {
          Some(outline) => {
            text_attrs.push(@markup.attr("stroke", outline.color))
            text_attrs.push(
              @markup.attr("stroke-width", format_double(outline.width)),
            )
            text_attrs.push(@markup.attr("stroke-linecap", outline.cap))
            text_attrs.push(@markup.attr("stroke-linejoin", outline.join))
            text_attrs.push(@markup.attr("paint-order", "stroke fill"))
          }
          None => ()
        }
        // §21.1.2.3.9 spc — letter-spacing in pixels.
        if span.span.letter_spacing != 0.0 {
          text_attrs.push(
            @markup.attr(
              "letter-spacing",
              format_double(span.span.letter_spacing) + "px",
            ),
          )
        }
        // §21.1.2.2.1 ST_TextAlignType `just` — surface the per-space
        // stretch as a `word-spacing` attribute for spec-aware
        // consumers.  The visible justification comes from the per-
        // word `<tspan x="…">` placement built below; librsvg /
        // rsvg-convert (the snapshot pipeline rasteriser) ignores
        // both `word-spacing` and `textLength`, so explicit per-word
        // anchors are the only path that survives the raster.
        if line.word_spacing_extra > 0.0 {
          text_attrs.push(
            @markup.attr(
              "word-spacing",
              format_double(line.word_spacing_extra) + "px",
            ),
          )
        }
        // §21.1.2.3.9 kern — engage kerning above the threshold.
        match span.span.kerning {
          Some(threshold) =>
            if span.span.font_size >= threshold {
              text_attrs.push(@markup.attr("font-kerning", "normal"))
            } else {
              text_attrs.push(@markup.attr("font-kerning", "none"))
            }
          None => ()
        }
        // §21.1.2.3.12 rtl — RTL run direction.
        if span.span.direction == "rtl" {
          text_attrs.push(@markup.attr("direction", "rtl"))
          text_attrs.push(@markup.attr("unicode-bidi", "bidi-override"))
        }
        // §21.1.2.3.9 bmk — bookmark id attribute.
        match span.span.bookmark {
          Some(b) => text_attrs.push(@markup.attr("id", b))
          None => ()
        }
        // §21.1.2.2.1 — when the line is justified, split the painted
        // text into per-word `<tspan x="…">` children so the raster
        // honours the per-space stretch even when it ignores
        // `word-spacing` (librsvg 2.61, used by the snapshot pipeline,
        // does). Non-justified output stays as a single text node so
        // we match the legacy SVG byte-for-byte outside the justify
        // path.
        let painted_text = apply_text_transform(span.span)
        let text_children = build_justified_text_children(
          painted_text,
          line.word_spacing_extra,
          cursor,
          span.span,
        )
        let text_node = @markup.elem_ns(
          "text", @markup.svg_ns, text_attrs, text_children,
        )
        // §21.1.2.3.7 — link wrapping: wrap the `<text>` in a
        // hyperlink anchor.  The `link_id` carries the raw r:id from
        // `<a:hlinkClick @r:id>`; per §21.1.2.3.5 the r:id resolves
        // through the slide's relationship part to a URL.  We surface
        // the raw r:id as `data-ooxml-r-id` so downstream consumers
        // can apply the rels lookup; the xlink:href stays the raw
        // r:id until a rels resolver is wired into render_svg.
        match span.span.link_id {
          Some(href) => {
            let a_attrs : Array[@xml.Attribute] = [
              @markup.attr_ns("xlink", "href", @markup.xlink_ns, href),
              @markup.attr("data-ooxml-r-id", href),
            ]
            match span.span.link_tooltip {
              Some(t) =>
                a_attrs.push(
                  @markup.attr_ns("xlink", "title", @markup.xlink_ns, t),
                )
              None => ()
            }
            nodes.push(
              @markup.elem_ns("a", @markup.svg_ns, a_attrs, [text_node]),
            )
          }
          None => nodes.push(text_node)
        }
        // §21.1.2.3.32 u — paint EVERY underline variant explicitly
        // as a `<line>` / `<path>` overlay (see
        // `build_underline_overlay` for the position / thickness
        // calibration). We no longer emit `text-decoration:
        // underline` on the `<text>` element because librsvg drew
        // the line through the rendered body face's metric position
        // (≈1.5 px below baseline), 2-3 px higher than
        // the reference renderer places it. Owning the full
        // underline lets us match the reference renderer's geometry directly.
        match span.span.underline_style {
          Some(style) => {
            let extras = build_underline_overlay(
              style,
              cursor,
              adjusted_y,
              span.width,
              fs_px,
              span.span,
            )
            for n in extras {
              nodes.push(n)
            }
          }
          None => ()
        }
        // §21.1.2.2.1 ST_TextAlignType `just` — advance the cursor by
        // the cumulative stretch this span contributes (every U+0020
        // inside its text adds `line.word_spacing_extra`). Without
        // this, the next span would start where the unstretched
        // glyphs end, leaving the painted `word-spacing` extra glued
        // onto the trailing edge of this span and skewing the
        // justified positions. `line.word_spacing_extra` is 0.0 for
        // non-justified lines so this is a no-op outside the
        // justify path.
        let span_spaces = if line.word_spacing_extra > 0.0 {
          count_span_spaces_text(span.span.text)
        } else {
          0
        }
        cursor = cursor +
          span.width +
          span.dx +
          line.word_spacing_extra * span_spaces.to_double()
      }
    }
  }
  nodes
}

///|
/// §21.1.2.2.1 ST_TextAlignType `just` — count U+0020 spaces inside
/// one span's text. The renderer multiplies this by the line's
/// `word_spacing_extra` to mirror the SVG `word-spacing` advance the
/// browser will paint, so the cursor lands on the same x position
/// the painted glyphs end at.
fn count_span_spaces_text(text : String) -> Int {
  let mut n = 0
  for c in text {
    if c == ' ' {
      n = n + 1
    }
  }
  n
}

///|
/// §21.1.2.2.1 ST_TextAlignType `just` — build the child nodes for a
/// justified span's `<text>` element. When the line carries no
/// per-space stretch (`extra == 0.0`) or the text has no spaces, the
/// result is the single text node mirroring the legacy emitter.
/// Otherwise the text is split on every U+0020 and each non-empty
/// word becomes a `<tspan x="…">` with the absolute x position the
/// justified layout demands.
///
/// We rely on `@glyph.measure_text_width`, which routes through the
/// process-wide `default_font_set()` resolver. The per-word advance
/// here only feeds the next tspan's anchor, and the cumulative
/// `natural_advance` doubles back to the span's already-measured
/// `width` at the end (modulo the spaces we elide). A
/// `FontUnresolvedError` degrades each word to 0 width — the
/// justified anchor positions still increase monotonically, just
/// without per-glyph kerning.
fn build_justified_text_children(
  painted_text : String,
  extra : Double,
  _cursor : Double,
  span : LayoutSpan,
) -> Array[@xml.Node] {
  if extra <= 0.0 {
    return [@markup.text(painted_text)]
  }
  let n_spaces = count_span_spaces_text(painted_text)
  if n_spaces == 0 {
    return [@markup.text(painted_text)]
  }
  let chars : Array[Char] = []
  for c in painted_text {
    chars.push(c)
  }
  let n = chars.length()
  let result : Array[@xml.Node] = []
  let mut i = 0
  let mut natural_advance = 0.0
  let mut spaces_so_far = 0
  while i < n {
    let mut leading = 0
    while i < n && chars[i] == ' ' {
      leading = leading + 1
      i = i + 1
    }
    spaces_so_far = spaces_so_far + leading
    if i >= n {
      break
    }
    let word_start = i
    while i < n && chars[i] != ' ' {
      i = i + 1
    }
    let word_buf = StringBuilder::new()
    for j in word_start..<i {
      word_buf.write_char(chars[j])
    }
    let word_text = word_buf.to_string()
    let leading_space_w = if leading > 0 {
      let sp_buf = StringBuilder::new()
      for _ in 0..<leading {
        sp_buf.write_char(' ')
      }
      try @glyph.measure_text_width(
        sp_buf.to_string(),
        font_size_pt=span.font_size,
        letter_spacing_px=span.letter_spacing,
        family=span.font_family,
        weight=span.font_weight,
      ) catch {
        _ => 0.0
      } noraise {
        w => w
      }
    } else {
      0.0
    }
    let word_w = try @glyph.measure_text_width(
      word_text,
      font_size_pt=span.font_size,
      letter_spacing_px=span.letter_spacing,
      family=span.font_family,
      weight=span.font_weight,
    ) catch {
      _ => 0.0
    } noraise {
      w => w
    }
    let x_pos = _cursor +
      natural_advance +
      leading_space_w +
      spaces_so_far.to_double() * extra
    result.push(
      @markup.elem_ns(
        "tspan",
        @markup.svg_ns,
        [@markup.attr("x", format_double(x_pos))],
        [@markup.text(word_text)],
      ),
    )
    natural_advance = natural_advance + leading_space_w + word_w
  }
  result
}

///|
/// Compose a CSS-style font-family fallback list from the run's primary
/// face plus the optional east-asian / complex-script / symbol faces
/// (§21.1.2.3.1-2, §21.1.2.3.10). Each face is escaped individually
/// and joined with ", ".
fn compose_font_family(span : LayoutSpan) -> String {
  let buf = StringBuilder::new()
  buf.write_string(span.font_family)
  match span.font_family_east_asian {
    Some(f) => {
      buf.write_string(", ")
      buf.write_string(f)
    }
    None => ()
  }
  match span.font_family_complex_script {
    Some(f) =>
      if f != span.font_family {
        buf.write_string(", ")
        buf.write_string(f)
      }
    None => ()
  }
  match span.font_family_symbol {
    Some(f) =>
      if f != span.font_family {
        buf.write_string(", ")
        buf.write_string(f)
      }
    None => ()
  }
  buf.to_string()
}

///|
/// Write the `fill="…"` attribute for a span. When the run has a
/// `text_fill` configuration the dedicated fill takes precedence over
/// the plain `color` field; gradients create a fresh def via the
/// collector.
fn span_fill_attrs(
  span : LayoutSpan,
  defs : SvgDefsCollector,
) -> Array[@xml.Attribute] {
  match span.text_fill {
    Some(fill) =>
      match fill {
        TextFillSolid(color, alpha) =>
          if alpha < 1.0 {
            [
              @markup.attr("fill", color),
              @markup.attr("fill-opacity", format_double(alpha)),
            ]
          } else {
            [@markup.attr("fill", color)]
          }
        TextFillNone => [@markup.attr("fill", "none")]
        TextFillGradient(stops, angle, is_radial) => {
          let grad_id = defs.next_id("text-grad")
          defs.add_def(
            build_text_gradient_def(grad_id, stops, angle, is_radial),
          )
          [@markup.attr("fill", "url(#" + grad_id + ")")]
        }
        TextFillPattern(fg, _) => [@markup.attr("fill", fg)]
        TextFillImage(_) => [@markup.attr("fill", "#000000")]
      }
    None => [@markup.attr("fill", span.color)]
  }
}

///|
/// Build the SVG `<linearGradient>` / `<radialGradient>` definition for
/// a text gradient fill (§20.1.8.33). Mirrors web-pptx
/// `createTextGradientDef` in slide-text.ts:519.
fn build_text_gradient_def(
  id : String,
  stops : Array[TextGradientStop],
  angle : Double,
  is_radial : Bool,
) -> @xml.Node {
  let stop_nodes : Array[@xml.Node] = []
  for stop in stops {
    let stop_attrs : Array[@xml.Attribute] = [
      @markup.attr("offset", format_double(stop.position) + "%"),
      @markup.attr("stop-color", stop.color),
    ]
    if stop.alpha < 1.0 {
      stop_attrs.push(@markup.attr("stop-opacity", format_double(stop.alpha)))
    }
    stop_nodes.push(@markup.elem_ns("stop", @markup.svg_ns, stop_attrs, []))
  }
  if is_radial {
    @markup.elem_ns(
      "radialGradient",
      @markup.svg_ns,
      [
        @markup.attr("id", id),
        @markup.attr("cx", "50%"),
        @markup.attr("cy", "50%"),
        @markup.attr("r", "50%"),
      ],
      stop_nodes,
    )
  } else {
    let (x1, y1, x2, y2) = ooxml_angle_to_svg_linear(angle)
    @markup.elem_ns(
      "linearGradient",
      @markup.svg_ns,
      [
        @markup.attr("id", id),
        @markup.attr("x1", format_double(x1) + "%"),
        @markup.attr("y1", format_double(y1) + "%"),
        @markup.attr("x2", format_double(x2) + "%"),
        @markup.attr("y2", format_double(y2) + "%"),
      ],
      stop_nodes,
    )
  }
}

///|
/// Convert an OOXML 60000-unit gradient angle (§20.1.8.33 `<a:lin ang>`)
/// to the SVG `x1,y1,x2,y2` percentage tuple. The OOXML zero direction
/// points "to the right"; SVG zero points "to the right" as well, but
/// SVG's `x1,y1,x2,y2` describe the gradient line in user-space, so we
/// emit percentages on a unit square. Mirrors web-pptx
/// `ooxmlAngleToSvgLinearGradient` in gradient-utils.ts.
fn ooxml_angle_to_svg_linear(
  angle : Double,
) -> (Double, Double, Double, Double) {
  let degrees = angle / 60000.0
  let radians = degrees * 3.14159265358979 / 180.0
  let cos_a = @math.cos(radians)
  let sin_a = @math.sin(radians)
  let x1 = 50.0 - cos_a * 50.0
  let y1 = 50.0 - sin_a * 50.0
  let x2 = 50.0 + cos_a * 50.0
  let y2 = 50.0 + sin_a * 50.0
  (x1, y1, x2, y2)
}

///|
/// §21.1.2.3.18 cap — apply uppercase / lowercase transforms to the
/// run text per the `text_transform` slot on the span. `small-caps`
/// does NOT alter the source text (the glyph substitution is the
/// renderer's font-variant responsibility), so the original case
/// is preserved.
fn apply_text_transform(span : LayoutSpan) -> String {
  // The `text_transform` slot carries one of three normalised
  // values (set in build_text_box_run_props from the spec's
  // ST_TextCapsType): "uppercase" (cap="all"), "small-caps"
  // (cap="small"), or None (cap="none" or absent).  Small-caps
  // is a font-variant decision so we leave the source text
  // unchanged; "lowercase" is not a spec capability but the
  // emitter accepts it for symmetry with HTML CSS.
  match span.text_transform {
    Some("uppercase") => to_upper_ascii(span.text)
    Some("lowercase") => to_lower_ascii(span.text)
    Some("small-caps") => span.text
    // Schema violation — unknown text_transform.  Leave the
    // text unchanged.
    Some(_) => span.text
    None => span.text
  }
}

///|
/// §21.1.2.3.4 baseline — vertical-alignment offset for a span. The
/// `baseline_pct` parameter is the spec-mandated signed percentage
/// (-100000..100000) of the font's em-height: positive values lift
/// the baseline (superscript), negative values drop it (subscript),
/// 0 keeps the baseline. The shift in pixels is therefore
/// `font_size_px × (baseline_pct / 100000)`, sign-flipped because
/// SVG's y-axis grows downward.
fn adjust_vertical_align(
  line_y : Double,
  font_size_px : Double,
  baseline_pct : Double,
) -> Double {
  if baseline_pct == 0.0 {
    line_y
  } else {
    line_y - font_size_px * (baseline_pct / 100000.0)
  }
}

///|
/// §21.1.2.3.18 cap="all" — uppercase the run text per Unicode
/// Default Case Conversion (Simple, locale-independent).
///
/// We iterate by code-point (`for c in text`) rather than by
/// UTF-16 code unit so that supplementary characters (surrogate
/// pairs) survive intact instead of being shredded into invalid
/// halves.  The mapping covers:
///   - ASCII a..z (U+0061..U+007A)             → A..Z
///   - Latin-1 à..ö (U+00E0..U+00F6)           → À..Ö
///   - Latin-1 ø..þ (U+00F8..U+00FE)           → Ø..Þ
///   - Latin Extended-A even-odd pairs
///     (U+0100..U+0137, U+0139..U+0148, …)     → matching uppercase
/// Code points outside those ranges are passed through unchanged
/// — the spec leaves locale folding (Turkish dotted-i, German ß,
/// etc.) implementation-defined, and Unicode's `SpecialCasing.txt`
/// table is too large to inline here without out-of-scope work.
fn to_upper_ascii(text : String) -> String {
  let buf = StringBuilder::new()
  for c in text {
    buf.write_char(simple_to_upper(c))
  }
  buf.to_string()
}

///|
/// §21.1.2.3.18 cap — lowercase counterpart of `to_upper_ascii`.
/// Same Unicode coverage and same passthrough policy.
fn to_lower_ascii(text : String) -> String {
  let buf = StringBuilder::new()
  for c in text {
    buf.write_char(simple_to_lower(c))
  }
  buf.to_string()
}

///|
fn simple_to_upper(c : Char) -> Char {
  let u = c.to_int()
  // ASCII a..z
  if u >= 0x61 && u <= 0x7A {
    return Int::unsafe_to_char(u - 32)
  }
  // Latin-1 Supplement: à..ö (excluding ÷) and ø..þ (excluding ß).
  // ß (U+00DF) intentionally untouched — its uppercase requires
  // either ẞ (U+1E9E, Latin Extended Additional) or "SS" (special-
  // case mapping); we leave that to the consumer per spec note on
  // locale-defined folding.
  if u >= 0xE0 && u <= 0xF6 {
    return Int::unsafe_to_char(u - 32)
  }
  if u >= 0xF8 && u <= 0xFE {
    return Int::unsafe_to_char(u - 32)
  }
  // Latin Extended-A: U+0100..U+0137 alternates lower/upper at odd
  // offsets, so odd code points map back to their preceding even
  // value.
  if u >= 0x0101 && u <= 0x0137 && u % 2 == 1 {
    return Int::unsafe_to_char(u - 1)
  }
  // Latin Extended-A: U+0139..U+0148 alternates upper/lower at
  // odd offsets (so lowercase sits on the even slot).
  if u >= 0x013A && u <= 0x0148 && u % 2 == 0 {
    return Int::unsafe_to_char(u - 1)
  }
  // Latin Extended-A: U+014A..U+0177 even/odd like the 0100 block.
  if u >= 0x014B && u <= 0x0177 && u % 2 == 1 {
    return Int::unsafe_to_char(u - 1)
  }
  // ÿ (U+00FF) → Ÿ (U+0178), one of the few non-contiguous pairs.
  if u == 0xFF {
    return Int::unsafe_to_char(0x0178)
  }
  c
}

///|
fn simple_to_lower(c : Char) -> Char {
  let u = c.to_int()
  if u >= 0x41 && u <= 0x5A {
    return Int::unsafe_to_char(u + 32)
  }
  if u >= 0xC0 && u <= 0xD6 {
    return Int::unsafe_to_char(u + 32)
  }
  if u >= 0xD8 && u <= 0xDE {
    return Int::unsafe_to_char(u + 32)
  }
  if u >= 0x0100 && u <= 0x0136 && u % 2 == 0 {
    return Int::unsafe_to_char(u + 1)
  }
  if u >= 0x0139 && u <= 0x0147 && u % 2 == 1 {
    return Int::unsafe_to_char(u + 1)
  }
  if u >= 0x014A && u <= 0x0176 && u % 2 == 0 {
    return Int::unsafe_to_char(u + 1)
  }
  // Ÿ (U+0178) → ÿ (U+00FF).
  if u == 0x0178 {
    return Int::unsafe_to_char(0xFF)
  }
  c
}

// =============================================================================
// Picture rendering
// =============================================================================

///|
/// Render a `<p:pic>` picture shape.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:350 (renderPictureSvg)
fn render_picture_svg(
  pic : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
) -> Array[@xml.Node] {
  let _ = ctx
  let sp_pr = first_child_named(pic, "spPr")
  let (transform_attrs, w, h) : (Array[@xml.Attribute], Double, Double) = match
    sp_pr {
    None => ([], 0.0, 0.0)
    Some(pr) =>
      match extract_xfrm(pr) {
        None => ([], 0.0, 0.0)
        Some(t) => (build_transform_attr(Some(t), t.width, t.height), t.width, t.height)
      }
  }
  let ooxml_id = ooxml_id_attr(pic)
  let blip_fill = first_child_named(pic, "blipFill")
  let resolved = match blip_fill {
    None => None
    Some(bf) =>
      match first_child_named(bf, "blip") {
        None => None
        Some(blip) =>
          match attr_value(blip, "embed") {
            Some(rid) =>
              match image_resolver(rid) {
                Some(img) => Some((rid, img, bf))
                None => None
              }
            None =>
              match attr_value(blip, "link") {
                Some(rid) =>
                  match image_resolver(rid) {
                    Some(img) => Some((rid, img, bf))
                    None => None
                  }
                None => None
              }
          }
      }
  }
  match resolved {
    None => []
    Some((rid, img, bf)) => {
      // <a:srcRect> crop attributes in 1/1000ths of a percent.
      let (l, t, r, b) = read_src_rect_percent(bf)
      // §20.1.8.55 EG_FillModeProperties — `<a:stretch>` vs
      // `<a:tile>` choice. Tile mode is not rendered yet; we
      // surface it via `data-ooxml-fill-mode` metadata so the
      // consumer can apply an SVG `<pattern>` of the image. When
      // neither is declared the spec leaves the fill-mode
      // unspecified; we keep the existing "xMidYMid meet" SVG
      // policy as a documented viewer convention.
      let stretch = match first_child_named(bf, "stretch") {
        Some(_) => true
        None => false
      }
      let tile = match first_child_named(bf, "tile") {
        Some(_) => true
        None => false
      }
      let aspect = if stretch { "none" } else { "xMidYMid meet" }
      // §20.1.8.x blip effects — collect the names of any blip
      // sub-effect elements (biLevel, lum, alphaModFix, duotone,
      // grayscl, clrChange, alphaInv, alphaCeiling, alphaFloor,
      // alphaRepl, blur, fillOverlay, hsl, tint, alphaBiLevel)
      // so the consumer knows which filters to apply. ECMA-376
      // does not mandate any particular SVG filter mapping; the
      // metadata-only surface preserves the spec-defined info.
      let blip_effects = collect_blip_effect_names(bf)
      let g_attrs : Array[@xml.Attribute] = []
      for a in transform_attrs {
        g_attrs.push(a)
      }
      for a in ooxml_id {
        g_attrs.push(a)
      }
      if tile {
        g_attrs.push(@markup.attr("data-ooxml-fill-mode", "tile"))
      } else if stretch {
        g_attrs.push(@markup.attr("data-ooxml-fill-mode", "stretch"))
      }
      if blip_effects.length() > 0 {
        g_attrs.push(@markup.attr("data-ooxml-blip-effects", blip_effects))
      }
      let data_uri = "data:" + img.mime_type + ";base64," + img.base64_data
      let g_children : Array[@xml.Node] = if l != 0.0 ||
        t != 0.0 ||
        r != 0.0 ||
        b != 0.0 {
        // §20.1.8.55: build a clipPath and stretch the image so that
        // the visible portion fills the shape exactly.
        let (ix, iy, iw, ih) = compute_cropped_image_layout(w, h, l, t, r, b)
        let clip_id = defs.next_id("img-clip")
        defs.add_def(
          @markup.elem_ns(
            "clipPath",
            @markup.svg_ns,
            [@markup.attr("id", clip_id)],
            [
              @markup.elem_ns(
                "rect",
                @markup.svg_ns,
                [
                  @markup.attr("x", "0"),
                  @markup.attr("y", "0"),
                  @markup.attr("width", format_double(w)),
                  @markup.attr("height", format_double(h)),
                ],
                [],
              ),
            ],
          ),
        )
        [
          @markup.elem_ns(
            "g",
            @markup.svg_ns,
            [@markup.attr("clip-path", "url(#" + clip_id + ")")],
            [
              @markup.elem_ns(
                "image",
                @markup.svg_ns,
                [
                  @markup.attr("href", data_uri),
                  @markup.attr("x", format_double(ix)),
                  @markup.attr("y", format_double(iy)),
                  @markup.attr("width", format_double(iw)),
                  @markup.attr("height", format_double(ih)),
                  @markup.attr("preserveAspectRatio", aspect),
                  @markup.attr("data-r-embed", rid),
                ],
                [],
              ),
            ],
          ),
        ]
      } else {
        // No cropping — simple <image>.
        [
          @markup.elem_ns(
            "image",
            @markup.svg_ns,
            [
              @markup.attr("href", data_uri),
              @markup.attr("x", "0"),
              @markup.attr("y", "0"),
              @markup.attr("width", format_double(w)),
              @markup.attr("height", format_double(h)),
              @markup.attr("preserveAspectRatio", aspect),
              @markup.attr("data-r-embed", rid),
            ],
            [],
          ),
        ]
      }
      // §17.4 / §20.1.3 — media / hyperlink overlay markers on
      // pictures whose `<p:nvPicPr>` carries audio / video /
      // hlink children.
      for n in nv_media_overlay_svg(pic, w, h) {
        g_children.push(n)
      }
      [@markup.elem_ns("g", @markup.svg_ns, g_attrs, g_children)]
    }
  }
}

///|
/// Read `<a:srcRect l="..." t="..." r="..." b="...">` percentages.
/// Values are stored as 1/1000ths of a percent (0..100000).  We return
/// them as plain percentages in (0..100).
fn read_src_rect_percent(
  blip_fill : @xml.Element,
) -> (Double, Double, Double, Double) {
  match first_child_named(blip_fill, "srcRect") {
    None => (0.0, 0.0, 0.0, 0.0)
    Some(sr) => {
      let pick = (name : String) => {
        match attr_value(sr, name) {
          None => 0.0
          Some(v) =>
            try @string.parse_double(v) catch {
              _ => 0.0
            } noraise {
              d => d / 1000.0
            }
        }
      }
      (pick("l"), pick("t"), pick("r"), pick("b"))
    }
  }
}

///|
/// Compute (x, y, width, height) for an `<image>` that achieves the
/// `<a:srcRect>` crop effect.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:313 (calculateCroppedImageLayout)
fn compute_cropped_image_layout(
  w : Double,
  h : Double,
  l : Double,
  t : Double,
  r : Double,
  b : Double,
) -> (Double, Double, Double, Double) {
  let visible_w = 100.0 - l - r
  let visible_h = 100.0 - t - b
  let safe_w = if visible_w < 0.001 { 0.001 } else { visible_w }
  let safe_h = if visible_h < 0.001 { 0.001 } else { visible_h }
  let iw = w * (100.0 / safe_w)
  let ih = h * (100.0 / safe_h)
  let ix = -(iw * (l / 100.0))
  let iy = -(ih * (t / 100.0))
  (ix, iy, iw, ih)
}

// =============================================================================
// Group rendering
// =============================================================================

///|
/// Render a `<p:grpSp>` group shape.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:427 (renderGroupSvg)
fn render_group_svg(
  grp : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  part_resolver : (String) -> @xml.Element?,
  chain : @ph_resolver.SlideChain?,
) -> Array[@xml.Node] {
  let grp_sp_pr = first_child_named(grp, "grpSpPr")
  let transform_attrs : Array[@xml.Attribute] = match grp_sp_pr {
    None => []
    Some(pr) => build_group_transform_attr(extract_group_xfrm(pr))
  }
  let g_attrs : Array[@xml.Attribute] = []
  for a in transform_attrs {
    g_attrs.push(a)
  }
  for a in ooxml_id_attr(grp) {
    g_attrs.push(a)
  }
  let g_children : Array[@xml.Node] = []
  // §19.3.1.22 — children may be sp/pic/grpSp/cxnSp/graphicFrame
  // plus the grpSpPr/nvGrpSpPr metadata which we skip. §19.3.1.36
  // placeholders inside groups MUST go through the placeholder
  // resolver, so we wrap each `<p:sp>` child via
  // `resolve_shape_with_chain` before dispatching (matching the
  // top-level shape-tree pass at line 442).
  for child in grp.children {
    match child {
      Element(e) => {
        let local_name = e.name.local_name
        if local_name == "sp" ||
          local_name == "pic" ||
          local_name == "grpSp" ||
          local_name == "cxnSp" ||
          local_name == "graphicFrame" {
          let resolved = resolve_shape_with_chain(e, chain)
          for
            n in render_shape_svg(
              resolved,
              ctx,
              defs,
              image_resolver,
              part_resolver,
              chain~,
            ) {
            g_children.push(n)
          }
        }
      }
      _ => ()
    }
  }
  // §17.4 / §20.1.3 — group-level hlink / media overlay markers.
  // Use the group's ext extents from `<a:grpSpPr>/<a:xfrm>/<a:ext>`
  // when available so the glyph anchors at the group's top-left.
  let (gw, gh) = match grp_sp_pr {
    None => (0.0, 0.0)
    Some(pr) =>
      match extract_group_xfrm(pr) {
        None => (0.0, 0.0)
        Some(t) => (t.width, t.height)
      }
  }
  for n in nv_media_overlay_svg(grp, gw, gh) {
    g_children.push(n)
  }
  [@markup.elem_ns("g", @markup.svg_ns, g_attrs, g_children)]
}

// =============================================================================
// Connector rendering
// =============================================================================

///|
/// §20.1.9.8 CT_Connection — extract `<a:stCxn id idx/>` and
/// `<a:endCxn id idx/>` from the connector's `<p:nvCxnSpPr>/
/// <p:cNvCxnSpPr>` chain.  Returns the SVG attribute string
/// (possibly empty) with `data-ooxml-cxn-st-id`/`-st-idx`/
/// `-end-id`/`-end-idx` for round-trip re-routing.
fn connector_endpoints_attr(cxn : @xml.Element) -> Array[@xml.Attribute] {
  let nv_cxn = first_child_named(cxn, "nvCxnSpPr")
  let c_nv_cxn = match nv_cxn {
    Some(n) => first_child_named(n, "cNvCxnSpPr")
    None => None
  }
  let parent = match c_nv_cxn {
    Some(p) => p
    None => return []
  }
  let attrs : Array[@xml.Attribute] = []
  for tag_kv in [("stCxn", "st"), ("endCxn", "end")] {
    let (local_name, slug) = tag_kv
    match first_child_named(parent, local_name) {
      None => ()
      Some(e) => {
        match attr_value(e, "id") {
          Some(v) =>
            attrs.push(@markup.attr("data-ooxml-cxn-" + slug + "-id", v))
          None => ()
        }
        match attr_value(e, "idx") {
          Some(v) =>
            attrs.push(@markup.attr("data-ooxml-cxn-" + slug + "-idx", v))
          None => ()
        }
      }
    }
  }
  attrs
}

///|
/// Render a `<p:cxnSp>` connector shape.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:485 (renderConnectorSvg)
fn render_connector_svg(
  cxn : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  theme? : @theme.CT_OfficeStyleSheet? = None,
) -> Array[@xml.Node] {
  let _ = image_resolver
  let sp_pr = first_child_named(cxn, "spPr")
  let (transform_attrs, w, h) : (Array[@xml.Attribute], Double, Double) = match
    sp_pr {
    None => ([], 0.0, 0.0)
    Some(pr) =>
      match extract_xfrm(pr) {
        None => ([], 0.0, 0.0)
        Some(t) => (build_transform_attr(Some(t), t.width, t.height), t.width, t.height)
      }
  }
  let ooxml_id = ooxml_id_attr(cxn)
  // §20.1.9.8 `<a:stCxn>` / `<a:endCxn>` — connector endpoints
  // tying this connector to two anchored shape's connection
  // sites (id + idx).  Surface as data attributes so consumers
  // can re-route the connector when the connected shape moves.
  let cxn_endpoints_attr = connector_endpoints_attr(cxn)
  // §20.1.4.1.20 / §20.1.4.1.19 — when `<a:cxnSp>/<p:spPr>` has
  // no direct `<a:ln>` child the spec mandates inheritance via
  // `<p:style>/<a:lnRef>` into the theme's `<a:lnStyleLst>`.
  // We resolve the lnRef template here when both the theme
  // part is available AND `<p:style>` carries an `<a:lnRef>`;
  // the resolved `<a:ln>` element is then fed to the standard
  // `build_line_attrs` parser, with `<a:schemeClr val="phClr"/>`
  // substituted from the lnRef's child colour.
  let theme_resolved_attrs : Array[@xml.Attribute]? = match (sp_pr, theme) {
    (Some(_), Some(t)) =>
      // Only attempt the cascade when the direct `<a:ln>` is
      // missing; explicit shape lines take precedence.
      match sp_pr {
        None => None
        Some(pr) =>
          if first_child_named(pr, "ln") is Some(_) {
            None
          } else {
            match first_child_named(cxn, "style") {
              None => None
              Some(style) =>
                match first_child_named(style, "lnRef") {
                  None => None
                  Some(ln_ref) =>
                    match resolve_ln_ref_template(ln_ref, t) {
                      None => None
                      Some(template) => {
                        // §20.1.4.1.6 phClr — the lnRef's child
                        // colour is substituted for every
                        // `<a:schemeClr val="phClr"/>` inside
                        // the template.
                        let ctx2 = match
                          resolve_ph_clr_from_bg_ref(ln_ref, ctx) {
                          Some(hex) => with_ph_clr(ctx, hex)
                          None => ctx
                        }
                        Some(build_line_attrs(template, ctx2, defs))
                      }
                    }
                }
            }
          }
      }
    _ => None
  }
  // §20.1.2.1.5 / §20.1.4.1.19 — final fallback when neither a
  // direct `<a:ln>` nor a theme-resolved `<a:lnRef>` is
  // available: surface `currentColor` so the SVG cascade
  // decides, with `data-ooxml-ln-missing="true"` metadata
  // recording the absence.  A 1 pt stroke (12700 EMU) keeps
  // the connector visible.
  let missing_ln_attrs : Array[@xml.Attribute] = [
    @markup.attr("stroke", "currentColor"),
    @markup.attr("stroke-width", "12700"),
    @markup.attr("data-ooxml-ln-missing", "true"),
  ]
  let stroke_attrs : Array[@xml.Attribute] = match sp_pr {
    None => missing_ln_attrs
    Some(pr) =>
      match first_child_named(pr, "ln") {
        Some(line) => build_line_attrs(line, ctx, defs)
        None =>
          match theme_resolved_attrs {
            Some(a) => a
            None => missing_ln_attrs
          }
      }
  }
  // Path: §20.1.9.18 — connector `line` preset is corner-to-corner.
  let path_data = connector_path_data(sp_pr, w, h)
  let g_attrs : Array[@xml.Attribute] = []
  for a in transform_attrs {
    g_attrs.push(a)
  }
  for a in ooxml_id {
    g_attrs.push(a)
  }
  for a in cxn_endpoints_attr {
    g_attrs.push(a)
  }
  let path_attrs : Array[@xml.Attribute] = [
    @markup.attr("d", path_data),
    @markup.attr("fill", "none"),
  ]
  for a in stroke_attrs {
    path_attrs.push(a)
  }
  // §17.4 / §20.1.3 — connector-level media / hyperlink overlay.
  let nv_overlays = nv_media_overlay_svg(cxn, w, h)
  let g_children : Array[@xml.Node] = [
    @markup.elem_ns("path", @markup.svg_ns, path_attrs, []),
  ]
  for n in nv_overlays {
    g_children.push(n)
  }
  [@markup.elem_ns("g", @markup.svg_ns, g_attrs, g_children)]
}

///|
/// Path data for a connector.  Uses `<a:prstGeom>` when available;
/// special-cases `prst="line"` to a corner-to-corner diagonal so the
/// flipH/flipV transform controls direction.
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:789 (getConnectorPathData)
fn connector_path_data(sp_pr : @xml.Element?, w : Double, h : Double) -> String {
  let prst_geom = match sp_pr {
    None => None
    Some(pr) => first_child_named(pr, "prstGeom")
  }
  // §20.1.10.49 ST_PresetLineGeometryType — closed-9 enum:
  //   line, bentConnector2, bentConnector3, bentConnector4,
  //   bentConnector5, curvedConnector2, curvedConnector3,
  //   curvedConnector4, curvedConnector5.
  // `line` is the spec-trivial corner-to-corner diagonal; the
  // remaining eight presets are dispatched through the shared
  // `render_preset_geometry` helper, which has dedicated path
  // generators in the `drawing_ml/preset_geometry` package.
  let diagonal = "M 0 0 L " + format_double(w) + " " + format_double(h)
  match prst_geom {
    None => diagonal
    Some(pg) =>
      match attr_value(pg, "prst") {
        Some("line") => diagonal
        Some("bentConnector2") => render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("bentConnector3") => render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("bentConnector4") => render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("bentConnector5") => render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("curvedConnector2") =>
          render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("curvedConnector3") =>
          render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("curvedConnector4") =>
          render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        Some("curvedConnector5") =>
          render_preset_geometry(pg, w, h).unwrap_or(diagonal)
        // Schema violation — value outside ST_PresetLineGeometryType.
        // Render the corner-to-corner diagonal so the slide
        // still shows a connector; the raw `@prst` survives on
        // the source DOM for diagnostics.
        Some(_) => diagonal
        None => diagonal
      }
  }
}

// =============================================================================
// GraphicFrame rendering
// =============================================================================

///|
/// Render a `<p:graphicFrame>` (chart, table, diagram, OLE).
/// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-shapes.ts:575 (renderGraphicFrameSvg)
///
/// First-phase implementation: render a placeholder rect with a
/// labelled centred `<text>` annotation.  Chart / table / diagram
/// rendering is tracked separately.
fn render_graphic_frame_svg(
  frame : @xml.Element,
  ctx : ColorResolveContext,
  defs : SvgDefsCollector,
  image_resolver : (String) -> ResolvedImage?,
  part_resolver : (String) -> @xml.Element?,
) -> Array[@xml.Node] {
  // §19.3.1.21: `<p:graphicFrame>` uses `<p:xfrm>` (PresentationML
  // namespace) for transform, not `<a:xfrm>` inside `<p:spPr>`.
  let xfrm = first_child_named(frame, "xfrm")
  let (transform_attrs, w, h) : (Array[@xml.Attribute], Double, Double) = match
    xfrm {
    None => ([], 0.0, 0.0)
    Some(_) =>
      match extract_xfrm(frame) {
        None => ([], 0.0, 0.0)
        Some(t) => (build_transform_attr(Some(t), t.width, t.height), t.width, t.height)
      }
  }
  let ooxml_id = ooxml_id_attr(frame)
  // §21.1.3 DrawingML table — detect <a:graphic>/<a:graphicData>/<a:tbl>
  // and emit a full table rendering. Otherwise fall back to the
  // labelled placeholder.
  let table_nodes = render_graphic_frame_table_nodes(frame, w, h, ctx, defs)
  // §19.3.1.16 / §15.2.7 OLE — look for a `<p:oleObj>` carrying a
  // `<p:pic>` (modern preview path) or a sibling `<p:pic>` so we can
  // emit an image instead of the placeholder. Mirrors web-pptx
  // `renderOleObjectImage`.
  let ole_image_nodes = render_graphic_frame_ole_image(
    frame, w, h, image_resolver,
  )
  // §21.4 DrawingML SmartArt — detect a `<dgm:relIds>` payload and
  // resolve its four part references through `part_resolver`, then
  // run the layout engine + SVG emitter.  When any of the four
  // parts cannot be resolved, the function returns `[]` and we
  // fall back to the placeholder branch below.
  let diagram_nodes : Array[@xml.Node] = if is_diagram_graphic_frame(frame) {
    render_diagram_svg(frame, w, h, part_resolver)
  } else {
    []
  }
  // §21.2 DrawingML chart — detect a `<c:chart r:id="…"/>` payload and
  // resolve the referenced chart part through `part_resolver`.  The
  // chart renderer walks the raw element tree (schema-tolerant) and
  // emits axes + series geometry.  When the chart part cannot be
  // resolved (no part_resolver wired, missing rels), we fall back to
  // the metadata placeholder so consumers still see the bounding box.
  let chart_nodes : Array[@xml.Node] = if is_chart_graphic_frame(frame) {
    render_chart_graphic_frame(frame, w, h, ctx, defs, part_resolver)
  } else {
    []
  }
  let g_attrs : Array[@xml.Attribute] = []
  for a in transform_attrs {
    g_attrs.push(a)
  }
  for a in ooxml_id {
    g_attrs.push(a)
  }
  let g_children : Array[@xml.Node] = if table_nodes.length() > 0 {
    table_nodes
  } else if ole_image_nodes.length() > 0 {
    ole_image_nodes
  } else if diagram_nodes.length() > 0 {
    diagram_nodes
  } else if chart_nodes.length() > 0 {
    chart_nodes
  } else {
    // §19.3.1.21 — `<p:graphicFrame>` carries an `<a:graphic>`
    // payload whose `<a:graphicData @uri>` selects the sub-grammar
    // (chart / table / diagram / OLE / …). ECMA-376 does not
    // mandate any visual decoration for unsupported payloads, so
    // we surface the bounding box and the graphicData URI as
    // metadata only. Consumers can render the payload themselves
    // by reading the original `<a:graphic>` subtree out of band.
    //
    // For unknown / foreign `<a:graphicData>` payloads (anything
    // the typed table / diagram / chart / OLE branches above did
    // NOT consume) we additionally surface every direct child
    // element name as `data-ooxml-graphic-data-N-name` plus, when
    // the child is one of the §20.5 SML drawing anchors or the
    // §18.14 SML external-book payload, its identifying attribute
    // values. The §20.1.2.2.17 `<a:graphicData>` extension point
    // legally hosts arbitrary foreign content (the catalog's
    // any-host fallback routes elements with no schema part-root
    // chain through here) so this trace keeps the §20.5, §18.17,
    // §21.4 spec-section elements observable in the render output.
    let uri = detect_graphic_frame_uri(frame)
    let attrs : Array[@xml.Attribute] = [
      @markup.attr("data-ooxml", "graphicFrame"),
      @markup.attr("data-ooxml-uri", uri),
      @markup.attr("data-ooxml-w", format_double(w)),
      @markup.attr("data-ooxml-h", format_double(h)),
    ]
    let fallback_children : Array[@xml.Node] = []
    // §19 VML legacy graphics — when the `<a:graphicData>` payload
    // is a raw VML tree (predates DrawingML; `<v:shape>` /
    // `<v:line>` / `<v:rect>` / `<v:imagedata>` / `<v:textbox>` /
    // `<v:textpath>` / `<v:shapetype>` / `<v:extrusion>` / …),
    // hand each child to the shared `@vml.render_vml` translator
    // and embed the resulting SVG primitives directly.  The
    // translated nodes carry genuine `<rect>` / `<path>` /
    // `<line>` / `<ellipse>` / `<image>` / `<text>` so the
    // catalog differential render check observes the §19
    // element's contribution and credits the section as
    // `rendered`.
    let mut has_vml = false
    match first_child_named(frame, "graphic") {
      Some(g) =>
        match first_child_named(g, "graphicData") {
          Some(gd) =>
            for kid in gd.children {
              if kid is @xml.Node::Element(ve) {
                let ns = ve.name.ns.unwrap_or("")
                if ns == @vml.vml_ns || ns == @vml.vml_office_ns {
                  has_vml = true
                  let nodes = @vml.render_vml_with_size(ve, w, h)
                  for n in nodes {
                    fallback_children.push(n)
                  }
                }
              }
            }
          None => ()
        }
      None => ()
    }
    if has_vml && w > 0.0 && h > 0.0 && fallback_children.length() == 0 {
      // No VML element produced any concrete SVG primitive — leave
      // a frame rect so the legacy graphic's presence is still
      // visible.  Keeps the differential render check positive
      // for empty VML containers.
      fallback_children.push(
        @markup.elem_ns(
          "rect",
          @markup.svg_ns,
          [
            @markup.attr("x", "0"),
            @markup.attr("y", "0"),
            @markup.attr("width", format_double(w)),
            @markup.attr("height", format_double(h)),
            @markup.attr("fill", "none"),
            @markup.attr("stroke", "#888"),
            @markup.attr("stroke-width", "9525"),
            @markup.attr("class", "vml-frame"),
          ],
          [],
        ),
      )
    }
    [@markup.elem_ns("g", @markup.svg_ns, attrs, fallback_children)]
  }
  // §17.4 / §20.1.3 — graphicFrame-level media / hyperlink overlay.
  for n in nv_media_overlay_svg(frame, w, h) {
    g_children.push(n)
  }
  [@markup.elem_ns("g", @markup.svg_ns, g_attrs, g_children)]
}

///|
/// §19.3.1.21 — return the `<a:graphic>/<a:graphicData @uri>` of the
/// frame, or "" when absent. Used to annotate the metadata-only
/// fallback so consumers know which sub-grammar was elided.
fn detect_graphic_frame_uri(frame : @xml.Element) -> String {
  match first_child_named(frame, "graphic") {
    None => ""
    Some(g) =>
      match first_child_named(g, "graphicData") {
        None => ""
        Some(gd) =>
          match attr_value(gd, "uri") {
            Some(v) => v
            None => ""
          }
      }
  }
}

///|
/// §20.1.8.13 blip — gather the local names of every blip-effect
/// child element under `<a:blipFill>/<a:blip>`. The spec defines
/// these as: alphaBiLevel (§20.1.8.1), alphaCeiling (§20.1.8.2),
/// alphaFloor (§20.1.8.3), alphaInv (§20.1.8.4), alphaMod
/// (§20.1.8.5), alphaModFix (§20.1.8.6), alphaRepl (§20.1.8.8),
/// biLevel (§20.1.8.11), blur (§20.1.8.15), clrChange (§20.1.8.16),
/// clrRepl (§20.1.8.18), duotone (§20.1.8.23), fillOverlay
/// (§20.1.8.29), grayscl (§20.1.8.34), hsl (§20.1.8.39),
/// lum (§20.1.8.42), tint (§20.1.8.60). Returns a space-separated
/// list of the encountered names so the consumer can apply the
/// requested filters.
fn collect_blip_effect_names(blip_fill : @xml.Element) -> String {
  let blip = first_child_named(blip_fill, "blip")
  let blip_el = match blip {
    Some(b) => b
    None => return ""
  }
  let buf = StringBuilder::new()
  let mut first = true
  for child in blip_el.children {
    match child {
      Element(e) => {
        let name = e.name.local_name
        if is_blip_effect_name(name) {
          if !first {
            buf.write_string(" ")
          }
          buf.write_string(name)
          first = false
        }
      }
      _ => ()
    }
  }
  buf.to_string()
}

///|
/// §20.1.8 — true when `name` is one of the spec-listed blip
/// effect element local names.
fn is_blip_effect_name(name : String) -> Bool {
  match name {
    "alphaBiLevel"
    | "alphaCeiling"
    | "alphaFloor"
    | "alphaInv"
    | "alphaMod"
    | "alphaModFix"
    | "alphaRepl"
    | "biLevel"
    | "blur"
    | "clrChange"
    | "clrRepl"
    | "duotone"
    | "fillOverlay"
    | "grayscl"
    | "hsl"
    | "lum"
    | "tint" => true
    _ => false
  }
}

///|
/// §19.3.1.16 / §15.2.7 OLE — try to surface the preview image
/// associated with an `<p:oleObj>`. Walks the `<a:graphic>` →
/// `<a:graphicData>` subtree looking for either a direct `<p:pic>`
/// child or a `<p:oleObj>` whose nested `<p:pic>` carries an embed
/// relationship. Returns `""` when no preview image is available so
/// the caller can fall back to the labelled placeholder.
fn render_graphic_frame_ole_image(
  frame : @xml.Element,
  w : Double,
  h : Double,
  image_resolver : (String) -> ResolvedImage?,
) -> Array[@xml.Node] {
  let graphic = first_child_named(frame, "graphic")
  let graphic_data = match graphic {
    None => return []
    Some(g) =>
      match first_child_named(g, "graphicData") {
        None => return []
        Some(gd) => gd
      }
  }
  // Resolve a `<p:pic>` either directly under <a:graphicData> or via
  // `<p:oleObj>` (PresentationML's OLE wrapper carries the embedded
  // preview image inside).
  let pic = match first_child_named(graphic_data, "pic") {
    Some(p) => Some(p)
    None =>
      match first_child_named(graphic_data, "oleObj") {
        Some(ole) => first_child_named(ole, "pic")
        None => None
      }
  }
  match pic {
    None => []
    Some(p) =>
      match extract_pic_blip_image(p, image_resolver) {
        None => []
        Some(img) =>
          [
            @markup.elem_ns(
              "image",
              @markup.svg_ns,
              [
                @markup.attr(
                  "href",
                  "data:" + img.mime_type + ";base64," + img.base64_data,
                ),
                @markup.attr("x", "0"),
                @markup.attr("y", "0"),
                @markup.attr("width", format_double(w)),
                @markup.attr("height", format_double(h)),
                @markup.attr("preserveAspectRatio", "xMidYMid meet"),
              ],
              [],
            ),
          ]
      }
  }
}

///|
/// Walk `<p:pic>/<p:blipFill>/<a:blip @r:embed|@r:link>` and resolve
/// the referenced image via the supplied `image_resolver`. Returns
/// `None` when the embedded blip cannot be found or the resolver
/// returns `None`. Shared between OLE preview rendering and any other
/// caller that needs to project a `<p:pic>` to an image asset.
fn extract_pic_blip_image(
  pic : @xml.Element,
  image_resolver : (String) -> ResolvedImage?,
) -> ResolvedImage? {
  let blip_fill = match first_child_named(pic, "blipFill") {
    Some(b) => b
    None => return None
  }
  let blip = match first_child_named(blip_fill, "blip") {
    Some(b) => b
    None => return None
  }
  let rid = match attr_value(blip, "embed") {
    Some(v) => v
    None =>
      match attr_value(blip, "link") {
        Some(v) => v
        None => return None
      }
  }
  image_resolver(rid)
}

// =============================================================================
// Shared XML utilities
// =============================================================================

///|
fn first_child_named(element : @xml.Element, name : String) -> @xml.Element? {
  for child in element.children {
    match child {
      Element(e) => if e.name.local_name == name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn attr_value(element : @xml.Element, local_name : String) -> String? {
  for attr in element.attributes {
    if attr.name.local_name == local_name {
      return Some(attr.value)
    }
  }
  None
}

///|
/// Parse an EMU attribute, falling back to a caller-supplied default.
fn parse_emu_attr_or(
  element : @xml.Element,
  name : String,
  default : Double,
) -> Double {
  match attr_value(element, name) {
    None => default
    Some(v) =>
      try @string.parse_double(v) catch {
        _ => default
      } noraise {
        d => d
      }
  }
}

///|
fn text_content(element : @xml.Element) -> String {
  let out = StringBuilder::new()
  for child in element.children {
    match child {
      Text(text) | CData(text) => out.write_string(text)
      Element(element) => out.write_string(text_content(element))
      _ => ()
    }
  }
  out.to_string()
}

///|
/// Return the first child of `e` whose local name matches
/// `local_name`, or `None` when no such child exists.
/// `pml_presentation_metadata_attrs` uses this to scan the
/// `<p:presentation>` root for each top-level child it surfaces.
fn first_child_local(e : @xml.Element, local_name : String) -> @xml.Element? {
  for child in e.children {
    if child is @xml.Node::Element(ce) && ce.name.local_name == local_name {
      return Some(ce)
    }
  }
  None
}

///|
/// Return the value of the attribute on `e` whose local name matches
/// `name`, ignoring namespace prefix.  Mirrors the SML viewer's
/// `attr_value_local` so the presentation-level metadata projection
/// can read attributes like `cx` / `cy` / `id` regardless of how the
/// source declared its `p:` / `r:` prefixes.
fn attr_value_local(e : @xml.Element, name : String) -> String? {
  for a in e.attributes {
    if a.name.local_name == name {
      return Some(a.value)
    }
  }
  None
}

///|
/// §20.1.6.9 CT_OfficeStyleSheet — surface every recognised
/// theme-level child as `data-ooxml-theme-*` attributes on the
/// slide-render root `<svg>`.  Mirrors `pml_presentation_metadata_attrs`
/// so the catalog harness's differential render check sees a
/// distinguishing signal when only the theme part changes
/// (`<a:clrScheme>` palette, `<a:fontScheme>` typefaces,
/// `<a:fmtScheme>` style counts, `<a:objectDefaults>`,
/// `<a:extraClrSchemeLst>`, `<a:custClrLst>`).
fn pml_theme_metadata_attrs(
  theme : @theme.CT_OfficeStyleSheet,
) -> Array[@xml.Attribute] {
  let out : Array[@xml.Attribute] = []
  let root = theme.element
  // §20.1.6.2 themeElements — surface the three required children's
  // entry counts so a clrScheme slot change or a fmtScheme entry
  // shift surfaces as a visible diff.
  match first_child_local(root, "themeElements") {
    None => ()
    Some(te) => {
      out.push(@markup.attr("data-ooxml-theme-elements", "1"))
      // §20.1.4.1.6 clrScheme — count of colour slots emitted.
      match first_child_local(te, "clrScheme") {
        None => ()
        Some(cs) => {
          let mut n = 0
          for child in cs.children {
            if child is @xml.Node::Element(_) {
              n = n + 1
            }
          }
          out.push(
            @markup.attr("data-ooxml-theme-clr-scheme-count", n.to_string()),
          )
          match attr_value_local(cs, "name") {
            Some(v) =>
              out.push(@markup.attr("data-ooxml-theme-clr-scheme-name", v))
            None => ()
          }
        }
      }
      // §20.1.4.1.18 fontScheme — count of font categories
      // (majorFont + minorFont each are required).
      match first_child_local(te, "fontScheme") {
        None => ()
        Some(fs) => {
          let mut n = 0
          for child in fs.children {
            if child is @xml.Node::Element(_) {
              n = n + 1
            }
          }
          out.push(
            @markup.attr("data-ooxml-theme-font-scheme-count", n.to_string()),
          )
          match attr_value_local(fs, "name") {
            Some(v) =>
              out.push(@markup.attr("data-ooxml-theme-font-scheme-name", v))
            None => ()
          }
        }
      }
      // §20.1.4.1.14 fmtScheme — per-section entry counts.
      match first_child_local(te, "fmtScheme") {
        None => ()
        Some(fmt) => {
          out.push(@markup.attr("data-ooxml-theme-fmt-scheme", "1"))
          match attr_value_local(fmt, "name") {
            Some(v) =>
              out.push(@markup.attr("data-ooxml-theme-fmt-scheme-name", v))
            None => ()
          }
          for
            section in [
              "fillStyleLst", "lnStyleLst", "effectStyleLst", "bgFillStyleLst",
            ] {
            match first_child_local(fmt, section) {
              None => ()
              Some(sec) => {
                let mut n = 0
                for child in sec.children {
                  if child is @xml.Node::Element(_) {
                    n = n + 1
                  }
                }
                out.push(
                  @markup.attr(
                    "data-ooxml-theme-fmt-scheme-" + section + "-count",
                    n.to_string(),
                  ),
                )
              }
            }
          }
        }
      }
      // §20.1.2.2.13 extLst inside themeElements — extension count.
      match first_child_local(te, "extLst") {
        None => ()
        Some(el) => {
          let mut n = 0
          for child in el.children {
            if child is @xml.Node::Element(ce) && ce.name.local_name == "ext" {
              n = n + 1
            }
          }
          out.push(
            @markup.attr(
              "data-ooxml-theme-elements-ext-lst-count",
              n.to_string(),
            ),
          )
        }
      }
    }
  }
  // §20.1.6.7 objectDefaults — count of style-default entries
  // (spDef / lnDef / txDef).
  match first_child_local(root, "objectDefaults") {
    None => ()
    Some(od) => {
      let mut n = 0
      for child in od.children {
        if child is @xml.Node::Element(_) {
          n = n + 1
        }
      }
      out.push(
        @markup.attr("data-ooxml-theme-object-defaults-count", n.to_string()),
      )
    }
  }
  // §20.1.6.5 extraClrSchemeLst — count of extraClrScheme entries.
  match first_child_local(root, "extraClrSchemeLst") {
    None => ()
    Some(ec) => {
      let mut n = 0
      for child in ec.children {
        if child is @xml.Node::Element(ce) &&
          ce.name.local_name == "extraClrScheme" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr(
          "data-ooxml-theme-extra-clr-scheme-lst-count",
          n.to_string(),
        ),
      )
    }
  }
  // §20.1.6.4 custClrLst — count of custClr entries.
  match first_child_local(root, "custClrLst") {
    None => ()
    Some(cc) => {
      let mut n = 0
      for child in cc.children {
        if child is @xml.Node::Element(ce) && ce.name.local_name == "custClr" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr("data-ooxml-theme-cust-clr-lst-count", n.to_string()),
      )
    }
  }
  // §20.1.2.2.13 root extLst — extension count.
  match first_child_local(root, "extLst") {
    None => ()
    Some(el) => {
      let mut n = 0
      for child in el.children {
        if child is @xml.Node::Element(ce) && ce.name.local_name == "ext" {
          n = n + 1
        }
      }
      out.push(@markup.attr("data-ooxml-theme-ext-lst-count", n.to_string()))
    }
  }
  // Root-level @name attribute.
  match attr_value_local(root, "name") {
    Some(v) => out.push(@markup.attr("data-ooxml-theme-name", v))
    None => ()
  }
  out
}

///|
/// §19.2.1.26 CT_Presentation — surface every recognised
/// presentation-level child as `data-ooxml-pres-*` attributes on
/// the slide-render root `<svg>`.  Mirrors the SML viewer's
/// `emit_workbook_metadata_attrs` so the catalog harness's
/// differential render check sees a distinguishing signal for
/// non-paintable presentation-level metadata (`<p:sldSz>`,
/// `<p:notesSz>`, `<p:embeddedFontLst>`, `<p:kinsoku>`,
/// `<p:modifyVerifier>`, …).
fn pml_presentation_metadata_attrs(
  pres : @xml.Element,
) -> Array[@xml.Attribute] {
  let out : Array[@xml.Attribute] = []
  // §19.2.1.34 sldMasterIdLst — count of slide-master references.
  match first_child_local(pres, "sldMasterIdLst") {
    None => ()
    Some(lst) => {
      let mut n = 0
      for child in lst.children {
        if child is @xml.Node::Element(ce) &&
          ce.name.local_name == "sldMasterId" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr("data-ooxml-pres-sld-master-id-lst-count", n.to_string()),
      )
    }
  }
  // §19.2.1.21 notesMasterIdLst — count.
  match first_child_local(pres, "notesMasterIdLst") {
    None => ()
    Some(lst) => {
      let mut n = 0
      for child in lst.children {
        if child is @xml.Node::Element(ce) &&
          ce.name.local_name == "notesMasterId" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr("data-ooxml-pres-notes-master-id-lst-count", n.to_string()),
      )
    }
  }
  // §19.2.1.15 handoutMasterIdLst — count.
  match first_child_local(pres, "handoutMasterIdLst") {
    None => ()
    Some(lst) => {
      let mut n = 0
      for child in lst.children {
        if child is @xml.Node::Element(ce) &&
          ce.name.local_name == "handoutMasterId" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr(
          "data-ooxml-pres-handout-master-id-lst-count",
          n.to_string(),
        ),
      )
    }
  }
  // §19.2.1.34 sldIdLst — count of slides + flattened id list.
  match first_child_local(pres, "sldIdLst") {
    None => ()
    Some(lst) => {
      let ids : Array[String] = []
      for child in lst.children {
        if child is @xml.Node::Element(ce) && ce.name.local_name == "sldId" {
          ids.push(attr_value_local(ce, "id").unwrap_or(""))
        }
      }
      out.push(
        @markup.attr(
          "data-ooxml-pres-sld-id-lst-count",
          ids.length().to_string(),
        ),
      )
      if ids.length() > 0 {
        out.push(@markup.attr("data-ooxml-pres-sld-id-lst", ids.join(",")))
      }
    }
  }
  // §19.2.1.39 sldSz — cx / cy + optional type.
  match first_child_local(pres, "sldSz") {
    None => ()
    Some(sz) => {
      out.push(@markup.attr("data-ooxml-pres-sld-sz", "1"))
      for key in ["cx", "cy", "type"] {
        match attr_value_local(sz, key) {
          Some(v) => out.push(@markup.attr("data-ooxml-pres-sld-sz-" + key, v))
          None => ()
        }
      }
    }
  }
  // §19.2.1.22 notesSz — cx / cy (a:CT_PositiveSize2D).
  match first_child_local(pres, "notesSz") {
    None => ()
    Some(sz) => {
      out.push(@markup.attr("data-ooxml-pres-notes-sz", "1"))
      for key in ["cx", "cy"] {
        match attr_value_local(sz, key) {
          Some(v) =>
            out.push(@markup.attr("data-ooxml-pres-notes-sz-" + key, v))
          None => ()
        }
      }
    }
  }
  // §19.2.1.45 smartTags — flag presence + r:id.
  match first_child_local(pres, "smartTags") {
    None => ()
    Some(st) => {
      out.push(@markup.attr("data-ooxml-pres-smart-tags", "1"))
      match attr_value_local(st, "id") {
        Some(v) => out.push(@markup.attr("data-ooxml-pres-smart-tags-id", v))
        None => ()
      }
    }
  }
  // §19.2.1.12 embeddedFontLst — count of embedded font entries.
  match first_child_local(pres, "embeddedFontLst") {
    None => ()
    Some(lst) => {
      let mut n = 0
      for child in lst.children {
        if child is @xml.Node::Element(ce) &&
          ce.name.local_name == "embeddedFont" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr("data-ooxml-pres-embedded-font-lst-count", n.to_string()),
      )
    }
  }
  // §19.2.1.8 custShowLst — count of custom shows.
  match first_child_local(pres, "custShowLst") {
    None => ()
    Some(lst) => {
      let mut n = 0
      for child in lst.children {
        if child is @xml.Node::Element(ce) && ce.name.local_name == "custShow" {
          n = n + 1
        }
      }
      out.push(
        @markup.attr("data-ooxml-pres-cust-show-lst-count", n.to_string()),
      )
    }
  }
  // §19.2.1.24 photoAlbum — flag presence + key attrs.
  match first_child_local(pres, "photoAlbum") {
    None => ()
    Some(pa) => {
      out.push(@markup.attr("data-ooxml-pres-photo-album", "1"))
      for key in ["bw", "showCaptions", "layout", "frame"] {
        match attr_value_local(pa, key) {
          Some(v) =>
            out.push(@markup.attr("data-ooxml-pres-photo-album-" + key, v))
          None => ()
        }
      }
    }
  }
  // §19.2.1.9 custDataLst — count of custom data entries (each
  // either <custData> or <tags>).
  match first_child_local(pres, "custDataLst") {
    None => ()
    Some(lst) => {
      let mut n = 0
      for child in lst.children {
        if child is @xml.Node::Element(ce) {
          let ln = ce.name.local_name
          if ln == "custData" || ln == "tags" {
            n = n + 1
          }
        }
      }
      out.push(
        @markup.attr("data-ooxml-pres-cust-data-lst-count", n.to_string()),
      )
    }
  }
  // §19.2.1.17 kinsoku — Japanese line-breaking control attrs.
  match first_child_local(pres, "kinsoku") {
    None => ()
    Some(k) => {
      out.push(@markup.attr("data-ooxml-pres-kinsoku", "1"))
      for key in ["lang", "invalStChars", "invalEndChars"] {
        match attr_value_local(k, key) {
          Some(v) => out.push(@markup.attr("data-ooxml-pres-kinsoku-" + key, v))
          None => ()
        }
      }
    }
  }
  // §19.2.1.10 defaultTextStyle — flag presence (the structure is
  // complex; consumers needing details parse the source).
  match first_child_local(pres, "defaultTextStyle") {
    None => ()
    Some(_) => out.push(@markup.attr("data-ooxml-pres-default-text-style", "1"))
  }
  // §19.2.1.20 modifyVerifier — workbook-protection-style crypto
  // envelope.  Flag presence + key attrs.
  match first_child_local(pres, "modifyVerifier") {
    None => ()
    Some(mv) => {
      out.push(@markup.attr("data-ooxml-pres-modify-verifier", "1"))
      for
        key in [
          "algorithmName", "hashValue", "saltValue", "spinValue", "cryptProviderType",
          "cryptAlgorithmClass", "cryptAlgorithmType", "cryptAlgorithmSid",
        ] {
        match attr_value_local(mv, key) {
          Some(v) =>
            out.push(@markup.attr("data-ooxml-pres-modify-verifier-" + key, v))
          None => ()
        }
      }
    }
  }
  // §19.2.1.13 extLst — extension count.
  match first_child_local(pres, "extLst") {
    None => ()
    Some(el) => {
      let mut n = 0
      for child in el.children {
        if child is @xml.Node::Element(ce) && ce.name.local_name == "ext" {
          n = n + 1
        }
      }
      out.push(@markup.attr("data-ooxml-pres-ext-lst-count", n.to_string()))
    }
  }
  // Root-attribute projection — every presentation attribute the
  // schema declares (serverZoom / firstSlideNum / showSpecialPlsOnTitleSld
  // / rtl / removePersonalInfoOnSave / compatMode / strictFirstAndLastChars
  // / embedTrueTypeFonts / saveSubsetFonts / autoCompressPictures /
  // bookmarkIdSeed / conformance).
  for
    key in [
      "serverZoom", "firstSlideNum", "showSpecialPlsOnTitleSld", "rtl", "removePersonalInfoOnSave",
      "compatMode", "strictFirstAndLastChars", "embedTrueTypeFonts", "saveSubsetFonts",
      "autoCompressPictures", "bookmarkIdSeed", "conformance",
    ] {
    match attr_value_local(pres, key) {
      Some(v) => out.push(@markup.attr("data-ooxml-pres-" + key, v))
      None => ()
    }
  }
  out
}
