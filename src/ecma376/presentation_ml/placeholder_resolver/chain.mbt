///|
/// Part 1 §19.3.1.38 sld — the list of `p:sp` shapes inside the slide
/// (returns an empty array when no slide is in the chain or the slide
/// has no `p:cSld/p:spTree`).
pub fn SlideChain::slide_shapes(self : SlideChain) -> Array[@xml.Element] {
  match self.slide {
    Some(slide) => extract_shapes(slide.element)
    None => []
  }
}

///|
/// Part 1 §19.3.1.39 sldLayout — the list of `p:sp` shapes inside the
/// layout. Empty when no layout is in the chain.
pub fn SlideChain::layout_shapes(self : SlideChain) -> Array[@xml.Element] {
  match self.layout {
    Some(layout) => extract_shapes(layout.element)
    None => []
  }
}

///|
/// Part 1 §19.3.1.42 sldMaster — the list of `p:sp` shapes inside the
/// master.
pub fn SlideChain::master_shapes(self : SlideChain) -> Array[@xml.Element] {
  extract_shapes(self.master.element)
}

///|
/// Walk `<root>/<cSld>/<spTree>/<sp>*` and return the shape elements
/// in document order. Used for every chain level so the resolver does
/// not need to know which container it walks.
fn extract_shapes(root : @xml.Element) -> Array[@xml.Element] {
  match common_slide_data(root) {
    Some(common) => shape_tree_shapes(common)
    None => []
  }
}
