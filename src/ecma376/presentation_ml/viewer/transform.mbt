// @source web-pptx packages/@aurochs-renderer/pptx/src/svg/slide-utils.ts
//                  + packages/@aurochs-renderer/pptx/src/transform.ts
//
// Transform extraction and SVG `transform="..."` string construction.
//
// ECMA-376 references:
//   §20.1.7.6 (xfrm)       — basic affine transform
//   §20.1.7.5 (grpSpPr)    — group transform (chOff / chExt scaling)
//   §20.1.7.2 (chExt)
//   §20.1.7.3 (chOff)
//
// The OOXML transform is expressed in EMUs (English Metric Units,
// §20.1.2.1.3, 914400 EMU = 1 inch). We carry them through unchanged
// so that the SVG viewBox can also use EMUs — this matches what the
// existing MoonBit `render_svg` does.

///|
/// Format-agnostic transform data.  Field-by-field mirror of
/// `TransformData` in `transform.ts:16`.
struct TransformData {
  x : Double
  y : Double
  width : Double
  height : Double
  /// Rotation in degrees (positive = clockwise) per §20.1.7.6 (rot).
  rotation : Double
  flip_h : Bool
  flip_v : Bool
}

///|
/// Group transform data, extending `TransformData` with child
/// coordinate-space attributes.  Mirrors the field set used by
/// `buildGroupTransformAttr` in `slide-utils.ts:133`.
struct GroupTransformData {
  x : Double
  y : Double
  width : Double
  height : Double
  rotation : Double
  flip_h : Bool
  flip_v : Bool
  /// `<a:chOff x="..." y="...">` — origin of child coordinate space
  /// (§20.1.7.3).
  child_offset_x : Double
  child_offset_y : Double
  /// `<a:chExt cx="..." cy="...">` — extent of child coordinate space
  /// (§20.1.7.2). Defaults to `width`/`height` when absent.
  child_extent_width : Double
  child_extent_height : Double
}

///|
/// Format a double for SVG attribute output.
///
/// Precision contract: PML viewBox / shape coordinates are in
/// EMU (English Metric Units, §20.1.2.1.3 — 914400 EMU = 1 inch).
/// EMU values are integral by construction in well-formed
/// `.pptx` files, so the integer branch is the common path;
/// the fractional branch covers transform matrix scale factors
/// and computed offsets where Moonbit's `Double::to_string`
/// emits the shortest round-trippable decimal (a 64-bit IEEE
/// 754 double rounds to ~15 significant digits which is more
/// than the spec needs).
///
/// ECMA-376 does NOT mandate an SVG output precision; the
/// renderer guarantees no information loss for any spec-
/// conformant document by deferring to the native `to_string`.
fn format_double(value : Double) -> String {
  if value == value.to_int().to_double() {
    value.to_int().to_string()
  } else {
    value.to_string()
  }
}

///|
/// Append `translate(x, y)` when the offset is non-zero.
fn append_translate(buf : StringBuilder, x : Double, y : Double) -> Unit {
  if x != 0.0 || y != 0.0 {
    buf.write_string("translate(")
    buf.write_string(format_double(x))
    buf.write_string(", ")
    buf.write_string(format_double(y))
    buf.write_string(")")
  }
}

///|
/// Append a separator space when needed.
fn append_sep(buf : StringBuilder, first : Ref[Bool]) -> Unit {
  if first.val {
    first.val = false
  } else {
    buf.write_char(' ')
  }
}

///|
/// Build the SVG `transform` attribute for a regular shape.
///
/// Mirrors `buildTransformAttr` in `slide-utils.ts:87` (NOT
/// `buildSvgTransformAttr` in `transform.ts:143` — the slide-utils
/// version is the one used by `renderShapeSvg`).  The crucial
/// difference is that rotation/flip pivots around the shape *box*
/// (`w/2, h/2`) rather than around the shape's own width/height.
///
/// Sequence:
///   1. `translate(x, y)`            (skip if both 0)
///   2. `rotate(rotation, w/2, h/2)` (skip if 0)
///   3. `scale(-1, 1) translate(-w, 0)` for `flipH`
///   4. `scale(1, -1) translate(0, -h)` for `flipV`
///
/// Returns the structured `transform` attribute (`[attr("transform",
/// value)]`), or an empty array when no transformation is present.
/// The transform *value* itself is a CSS-syntax string (not XML
/// markup); only the attribute wrapper is structured.
fn build_transform_attr(
  transform : TransformData?,
  w : Double,
  h : Double,
) -> Array[@xml.Attribute] {
  match transform {
    None => []
    Some(t) => {
      let parts = StringBuilder::new()
      let first : Ref[Bool] = { val: true }
      if t.x != 0.0 || t.y != 0.0 {
        append_sep(parts, first)
        parts.write_string("translate(")
        parts.write_string(format_double(t.x))
        parts.write_string(", ")
        parts.write_string(format_double(t.y))
        parts.write_string(")")
      }
      if t.rotation != 0.0 {
        append_sep(parts, first)
        parts.write_string("rotate(")
        parts.write_string(format_double(t.rotation))
        parts.write_string(", ")
        parts.write_string(format_double(w / 2.0))
        parts.write_string(", ")
        parts.write_string(format_double(h / 2.0))
        parts.write_string(")")
      }
      if t.flip_h {
        append_sep(parts, first)
        parts.write_string("scale(-1, 1) translate(")
        parts.write_string(format_double(-w))
        parts.write_string(", 0)")
      }
      if t.flip_v {
        append_sep(parts, first)
        parts.write_string("scale(1, -1) translate(0, ")
        parts.write_string(format_double(-h))
        parts.write_string(")")
      }
      if first.val {
        // Nothing emitted.
        []
      } else {
        [@markup.attr("transform", parts.to_string())]
      }
    }
  }
}

///|
/// Build the SVG `transform` attribute for a group shape.
///
/// Mirrors `buildGroupTransformAttr` in `slide-utils.ts:133`.
/// Sequence (this order matters — children render in chExt
/// coordinate space and must be scaled into the parent's ext space):
///   1. `translate(x, y)`                          (group position)
///   2. `rotate(rotation, w/2, h/2)`               (around centre)
///   3. `scale(-1, 1) translate(-w, 0)`            for `flipH`
///   4. `scale(1, -1) translate(0, -h)`            for `flipV`
///   5. `scale(width/chExtWidth, height/chExtHeight)` when needed
///   6. `translate(-chOffX, -chOffY)`              when non-zero
fn build_group_transform_attr(
  transform : GroupTransformData?,
) -> Array[@xml.Attribute] {
  match transform {
    None => []
    Some(t) => {
      let scale_x = if t.child_extent_width > 0.0 {
        t.width / t.child_extent_width
      } else {
        1.0
      }
      let scale_y = if t.child_extent_height > 0.0 {
        t.height / t.child_extent_height
      } else {
        1.0
      }
      let parts = StringBuilder::new()
      let first : Ref[Bool] = { val: true }
      if t.x != 0.0 || t.y != 0.0 {
        append_sep(parts, first)
        parts.write_string("translate(")
        parts.write_string(format_double(t.x))
        parts.write_string(", ")
        parts.write_string(format_double(t.y))
        parts.write_string(")")
      }
      if t.rotation != 0.0 {
        append_sep(parts, first)
        parts.write_string("rotate(")
        parts.write_string(format_double(t.rotation))
        parts.write_string(", ")
        parts.write_string(format_double(t.width / 2.0))
        parts.write_string(", ")
        parts.write_string(format_double(t.height / 2.0))
        parts.write_string(")")
      }
      if t.flip_h {
        append_sep(parts, first)
        parts.write_string("scale(-1, 1) translate(")
        parts.write_string(format_double(-t.width))
        parts.write_string(", 0)")
      }
      if t.flip_v {
        append_sep(parts, first)
        parts.write_string("scale(1, -1) translate(0, ")
        parts.write_string(format_double(-t.height))
        parts.write_string(")")
      }
      if scale_x != 1.0 || scale_y != 1.0 {
        append_sep(parts, first)
        parts.write_string("scale(")
        parts.write_string(format_double(scale_x))
        parts.write_string(", ")
        parts.write_string(format_double(scale_y))
        parts.write_string(")")
      }
      if t.child_offset_x != 0.0 || t.child_offset_y != 0.0 {
        append_sep(parts, first)
        parts.write_string("translate(")
        parts.write_string(format_double(-t.child_offset_x))
        parts.write_string(", ")
        parts.write_string(format_double(-t.child_offset_y))
        parts.write_string(")")
      }
      if first.val {
        []
      } else {
        [@markup.attr("transform", parts.to_string())]
      }
    }
  }
}

///|
/// Read a §20.1.7.6 `<a:xfrm>` element into a `TransformData`.  The
/// returned `(transform, w, h)` triple is what `build_transform_attr`
/// and shape rendering expect — `w`/`h` are kept separate so callers
/// can use them as fallbacks when geometry is absent.
///
/// Returns `None` when `<a:xfrm>` is missing.
fn extract_xfrm(sp_pr : @xml.Element) -> (TransformData, Double, Double)? {
  let xfrm = find_child(sp_pr, "xfrm")
  match xfrm {
    None => None
    Some(x) => {
      let (ox, oy) = match find_child(x, "off") {
        Some(off) => (parse_emu_attr(off, "x"), parse_emu_attr(off, "y"))
        None => (0.0, 0.0)
      }
      let (cx, cy) = match find_child(x, "ext") {
        Some(ext) => (parse_emu_attr(ext, "cx"), parse_emu_attr(ext, "cy"))
        None => (0.0, 0.0)
      }
      let rotation = parse_emu_attr(x, "rot") / 60000.0
      let flip_h = attr_eq(x, "flipH", "1")
      let flip_v = attr_eq(x, "flipV", "1")
      Some(
        (
          { x: ox, y: oy, width: cx, height: cy, rotation, flip_h, flip_v },
          cx,
          cy,
        ),
      )
    }
  }
}

///|
/// Read a §20.1.7.5 group `<a:xfrm>` (with `<a:chOff>` and
/// `<a:chExt>`) into a `GroupTransformData`.  Returns `None` when
/// `<a:xfrm>` is missing.
fn extract_group_xfrm(grp_sp_pr : @xml.Element) -> GroupTransformData? {
  let xfrm = find_child(grp_sp_pr, "xfrm")
  match xfrm {
    None => None
    Some(x) => {
      let (ox, oy) = match find_child(x, "off") {
        Some(off) => (parse_emu_attr(off, "x"), parse_emu_attr(off, "y"))
        None => (0.0, 0.0)
      }
      let (cx, cy) = match find_child(x, "ext") {
        Some(ext) => (parse_emu_attr(ext, "cx"), parse_emu_attr(ext, "cy"))
        None => (0.0, 0.0)
      }
      let (ch_off_x, ch_off_y) = match find_child(x, "chOff") {
        Some(off) => (parse_emu_attr(off, "x"), parse_emu_attr(off, "y"))
        None => (0.0, 0.0)
      }
      let (ch_ext_w, ch_ext_h) = match find_child(x, "chExt") {
        Some(ext) => (parse_emu_attr(ext, "cx"), parse_emu_attr(ext, "cy"))
        None => (cx, cy)
      }
      let rotation = parse_emu_attr(x, "rot") / 60000.0
      let flip_h = attr_eq(x, "flipH", "1")
      let flip_v = attr_eq(x, "flipV", "1")
      Some({
        x: ox,
        y: oy,
        width: cx,
        height: cy,
        rotation,
        flip_h,
        flip_v,
        child_offset_x: ch_off_x,
        child_offset_y: ch_off_y,
        child_extent_width: ch_ext_w,
        child_extent_height: ch_ext_h,
      })
    }
  }
}

///|
/// Find the first child element with the given local name.  This is
/// the shared local helper used by all viewer A-layer modules.
fn find_child(parent : @xml.Element, local_name : String) -> @xml.Element? {
  first_child_named(parent, local_name)
}

///|
/// Parse an EMU-valued attribute.  Returns 0 when missing or
/// unparseable — matching the JS implementation which coerces
/// `undefined` to `0` and `NaN` would have produced 0 after the
/// arithmetic.
fn parse_emu_attr(element : @xml.Element, name : String) -> Double {
  match attr_value(element, name) {
    None => 0.0
    Some(v) =>
      match (try? @strconv.parse_double(v)) {
        Ok(d) => d
        Err(_) => 0.0
      }
  }
}

///|
/// Check whether an attribute equals the given value (exact match).
fn attr_eq(element : @xml.Element, name : String, expected : String) -> Bool {
  match attr_value(element, name) {
    Some(v) => v == expected
    None => false
  }
}
