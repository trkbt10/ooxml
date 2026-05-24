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
// This is a thin XML overlay — it does NOT merge inside `p:spPr`
// (geometry vs. fill, etc.); for that the typed CT_ShapeProperties
// cascade in resolver.mbt is the right tool. For the viewer's
// purposes a missing-element fallback is what the §19.3.1.36 spec
// actually mandates: when a property is unspecified on the slide
// shape, the layout's value is used; if also unspecified there, the
// master's value is used.
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
        let local = e.name.local_name
        if array_contains(well_known, local) {
          if not(array_contains(inserted, local)) {
            match first_child_local_in_layers(layers, local) {
              Some(picked) => new_children.push(@xml.Element(picked))
              None => ()
            }
            inserted.push(local)
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
    if not(array_contains(inserted, kind)) {
      match first_child_local_in_layers(layers, kind) {
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
fn array_contains(xs : Array[String], needle : String) -> Bool {
  for x in xs {
    if x == needle {
      return true
    }
  }
  false
}
