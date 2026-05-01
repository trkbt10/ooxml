///|
/// WASM exports for the .pptx facade.
pub fn package_name() -> String {
  @pptx.package_name()
}

///|
let pptx_presentations : Ref[Array[@pptx.Presentation]] = { val: [] }

///|
pub fn pptx_open(bytes : Bytes) -> Int {
  try {
    let presentation = @pptx.open(bytes)
    pptx_presentations.val.push(presentation)
    pptx_presentations.val.length()
  } catch {
    _ => 0
  }
}

///|
pub fn pptx_save(handle : Int) -> Bytes {
  match pptx_presentation(handle) {
    Some(presentation) => presentation.save()
    None => Bytes::new(0)
  }
}

///|
pub fn pptx_to_html(handle : Int) -> String {
  match pptx_presentation(handle) {
    Some(presentation) => presentation.to_html()
    None => ""
  }
}

///|
pub fn pptx_to_svg(handle : Int) -> String {
  match pptx_presentation(handle) {
    Some(presentation) => presentation.to_svg()
    None => ""
  }
}

///|
fn pptx_presentation(handle : Int) -> @pptx.Presentation? {
  if handle <= 0 {
    None
  } else {
    pptx_presentations.val.get(handle - 1)
  }
}

///|
fn main {
  ignore(package_name())
}
