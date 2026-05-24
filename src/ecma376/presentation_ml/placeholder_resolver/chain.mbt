///|
/// Part 1 §19.3.1.38 sld — the list of `p:sp` CT_Shape projections
/// inside the slide (returns an empty array when no slide is in the
/// chain or the slide has no `p:cSld/p:spTree`).
pub fn SlideChain::slide_shapes(self : SlideChain) -> Array[@domain.CT_Shape] {
  match self.slide {
    Some(slide) => extract_shapes(slide.element)
    None => []
  }
}

///|
/// Part 1 §19.3.1.39 sldLayout — the list of `p:sp` CT_Shape
/// projections inside the layout. Empty when no layout is in the
/// chain.
pub fn SlideChain::layout_shapes(self : SlideChain) -> Array[@domain.CT_Shape] {
  match self.layout {
    Some(layout) => extract_shapes(layout.element)
    None => []
  }
}

///|
/// Part 1 §19.3.1.42 sldMaster — the list of `p:sp` CT_Shape
/// projections inside the master.
pub fn SlideChain::master_shapes(self : SlideChain) -> Array[@domain.CT_Shape] {
  extract_shapes(self.master.element)
}

///|
/// Walk `<root>/<cSld>/<spTree>/<sp>*` and project each shape element
/// to `@domain.CT_Shape` in document order. Used for every chain
/// level so the resolver does not need to know which container it
/// walks.
fn extract_shapes(root : @xml.Element) -> Array[@domain.CT_Shape] {
  match common_slide_data(root) {
    Some(common) => {
      let out : Array[@domain.CT_Shape] = []
      for sp in shape_tree_shapes(common) {
        out.push(@domain.CT_Shape::new(sp))
      }
      out
    }
    None => []
  }
}
