// =============================================================================
// Part 1 §19.3.1.43 sp / §19.3.1.36 ph — synthesise a "merged" `p:sp`
// XML element from a ResolvedShape so downstream raw-XML renderers
// (viewer/svg) transparently see the slide → layout → master cascade
// without having to know about the resolver.
//
// We do not mutate the original element. Instead we build a new
// `@xml.Element` whose `children` is the slide shape's children, with
// any missing top-level child (`p:spPr`, `p:txBody`, `p:style`,
// `p:nvSpPr`, `p:txXfrm`) filled in from the layout shape, then the
// master shape, in that priority order. The synthetic element reuses
// the slide shape's `name` and `attributes` so spec-level identity is
// preserved.
//
// The `p:spPr` child is merged one direct DrawingML property group at a
// time (xfrm, geometry, fill, line, effect, 3D, extLst), because a slide
// placeholder often supplies only geometry while the layout or master
// supplies paint.  The resolver remains the single source of truth for
// placeholder cascading; colour/theme/style interpretation stays in the
// viewer.
// =============================================================================

///|
/// Part 1 §19.3.1.36 — synthesise a merged `p:sp` element for the
/// supplied `ResolvedShape`. The returned element carries the slide
/// shape's identity (name + attributes) but its children list is the
/// slide → layout → master fallback chain for each well-known
/// top-level child kind: `nvSpPr`, `spPr`, `style`, `txBody`,
/// `txXfrm`. Any other child kinds from the slide shape are preserved
/// in their original order. When `resolved.slide_shape` is `None`
/// (layout-only or master-only placeholder rendering) the layout
/// shape or, failing that, the master shape acts as the base.
pub fn synthesize_resolved_shape(resolved : ResolvedShape) -> @xml.Element? {
  let base = match resolved.slide_shape {
    Some(shape) => shape.element
    None =>
      match resolved.layout_shape {
        Some(shape) => shape.element
        None =>
          match resolved.master_shape {
            Some(shape) => shape.element
            None => return None
          }
      }
  }
  let layers : Array[@xml.Element] = []
  match resolved.slide_shape {
    Some(shape) => layers.push(shape.element)
    None => ()
  }
  match resolved.layout_shape {
    Some(shape) => layers.push(shape.element)
    None => ()
  }
  match resolved.master_shape {
    Some(shape) => layers.push(shape.element)
    None => ()
  }
  Some(merge_shape_children(base, layers))
}

///|
/// Merge the well-known child kinds of `p:sp` (nvSpPr, spPr, style,
/// txBody, txXfrm) across `layers` (priority: layers[0] wins). Other
/// children are taken from the base layer only.
fn merge_shape_children(
  base : @xml.Element,
  layers : Array[@xml.Element],
) -> @xml.Element {
  let well_known = ["nvSpPr", "spPr", "style", "txBody", "txXfrm"]
  let new_children : Array[@xml.Node] = []
  let inserted : Array[String] = []

  // Walk the base layer in document order. For well-known kinds, emit
  // the first non-empty contribution in layer order. For everything
  // else, emit the base layer's child verbatim.
  for child in base.children {
    match child {
      @xml.Element(e) => {
        let local_name = e.name.local_name
        if local_name == "spPr" {
          if !array_contains(inserted, local_name) {
            match merge_sp_pr_from_shape_layers(layers) {
              Some(picked) => new_children.push(@xml.Element(picked))
              None => ()
            }
            inserted.push(local_name)
          }
        } else if array_contains(well_known, local_name) {
          if !array_contains(inserted, local_name) {
            match first_child_local_in_layers(layers, local_name) {
              Some(picked) => new_children.push(@xml.Element(picked))
              None => ()
            }
            inserted.push(local_name)
          }
          // else: already emitted via earlier base sibling of same kind.
        } else {
          new_children.push(child)
        }
      }
      _ => new_children.push(child)
    }
  }
  // Any well-known kind absent from the base but present in a fallback
  // layer must still be emitted so the layout/master can contribute
  // (e.g. layout-only title with no slide-side `<p:sp>` children).
  for kind in well_known {
    if !array_contains(inserted, kind) {
      let picked = if kind == "spPr" {
        merge_sp_pr_from_shape_layers(layers)
      } else {
        first_child_local_in_layers(layers, kind)
      }
      match picked {
        Some(picked) => {
          new_children.push(@xml.Element(picked))
          inserted.push(kind)
        }
        None => ()
      }
    }
  }
  { name: base.name, attributes: base.attributes, children: new_children }
}

///|
/// Part 1 §19.3.1.36 / §20.1.2.2.35 — merge the direct children of
/// `<p:spPr>` across slide → layout → master. Each DrawingML property
/// group is chosen independently: slide wins when it specifies that
/// group, otherwise layout, otherwise master. EG_* choice groups
/// (geometry, fill, effect) are treated as mutually-exclusive groups,
/// so an explicit `<a:noFill>` on the slide blocks inherited fills.
fn merge_sp_pr_from_shape_layers(
  shape_layers : Array[@xml.Element],
) -> @xml.Element? {
  let sp_pr_layers : Array[@xml.Element] = []
  for layer in shape_layers {
    match first_child_local(layer, "spPr") {
      Some(sp_pr) => sp_pr_layers.push(sp_pr)
      None => ()
    }
  }
  merge_sp_pr_direct_layers(sp_pr_layers)
}

///|
fn merge_sp_pr_direct_layers(
  sp_pr_layers : Array[@xml.Element],
) -> @xml.Element? {
  if sp_pr_layers.length() == 0 {
    return None
  }
  let base = sp_pr_layers[0]
  let new_children : Array[@xml.Node] = []
  for group in sp_pr_group_order() {
    match first_sp_pr_child_for_group(sp_pr_layers, group) {
      Some(child) => new_children.push(@xml.Element(child))
      None => ()
    }
  }
  for child in base.children {
    match child {
      @xml.Element(e) =>
        if sp_pr_child_group(e.name.local_name) is None {
          new_children.push(child)
        }
      _ => new_children.push(child)
    }
  }
  Some({
    name: base.name,
    attributes: merge_sp_pr_attributes(sp_pr_layers),
    children: new_children,
  })
}

///|
fn sp_pr_group_order() -> Array[String] {
  ["xfrm", "geometry", "fill", "ln", "effect", "scene3d", "sp3d", "extLst"]
}

///|
fn sp_pr_child_group(local_name : String) -> String? {
  match local_name {
    "xfrm" => Some("xfrm")
    "custGeom" | "prstGeom" => Some("geometry")
    "noFill" | "solidFill" | "gradFill" | "blipFill" | "pattFill" | "grpFill" =>
      Some("fill")
    "ln" => Some("ln")
    "effectLst" | "effectDag" => Some("effect")
    "scene3d" => Some("scene3d")
    "sp3d" => Some("sp3d")
    "extLst" => Some("extLst")
    _ => None
  }
}

///|
fn first_sp_pr_child_for_group(
  sp_pr_layers : Array[@xml.Element],
  group : String,
) -> @xml.Element? {
  for sp_pr in sp_pr_layers {
    for child in sp_pr.children {
      match child {
        @xml.Element(e) =>
          match sp_pr_child_group(e.name.local_name) {
            Some(g) => if g == group { return Some(e) }
            None => ()
          }
        _ => ()
      }
    }
  }
  None
}

///|
fn merge_sp_pr_attributes(
  sp_pr_layers : Array[@xml.Element],
) -> Array[@xml.Attribute] {
  let attrs : Array[@xml.Attribute] = []
  for sp_pr in sp_pr_layers {
    for attr in sp_pr.attributes {
      if !has_attr_local(attrs, attr.name.local_name) {
        attrs.push(attr)
      }
    }
  }
  attrs
}

///|
fn has_attr_local(attrs : Array[@xml.Attribute], local_name : String) -> Bool {
  for attr in attrs {
    if attr.name.local_name == local_name {
      return true
    }
  }
  false
}

///|
/// Return the first layer (in priority order) that has a direct child
/// with `local_name == name`; returns that child element.
fn first_child_local_in_layers(
  layers : Array[@xml.Element],
  name : String,
) -> @xml.Element? {
  for layer in layers {
    for child in layer.children {
      match child {
        @xml.Element(e) => if e.name.local_name == name { return Some(e) }
        _ => ()
      }
    }
  }
  None
}

///|
fn first_child_local(
  parent : @xml.Element,
  local_name : String,
) -> @xml.Element? {
  for child in parent.children {
    match child {
      @xml.Element(e) => if e.name.local_name == local_name { return Some(e) }
      _ => ()
    }
  }
  None
}

///|
fn array_contains(xs : Array[String], needle : String) -> Bool {
  for x in xs {
    if x == needle {
      return true
    }
  }
  false
}
