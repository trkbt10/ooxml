///|
/// Parse UTF-8 XML bytes into a DOM document.
pub fn parse(bytes : Bytes) -> Document raise {
  let reader = Reader::new(bytes)
  let mut declaration : XmlDeclaration? = None
  let mut root : Element? = None
  let stack : Array[Element] = []
  while reader.next() is Some(event) {
    match event {
      XmlDeclaration(decl) => declaration = Some(decl)
      StartElement(element) => stack.push(element)
      EndElement(_) => {
        let element = match stack.pop() {
          Some(value) => value
          None =>
            raise XmlMalformed(
              line=0,
              col=0,
              reason="end element without stack frame",
            )
        }
        match stack.last() {
          Some(parent) => parent.children.push(Element(element))
          None => root = Some(element)
        }
      }
      Text(text) =>
        if text != "" {
          match stack.last() {
            Some(element) => element.children.push(Text(text))
            None =>
              if !text.is_blank() {
                raise XmlMalformed(
                  line=0,
                  col=0,
                  reason="text outside document element",
                )
              }
          }
        }
      CData(text) =>
        match stack.last() {
          Some(element) => element.children.push(CData(text))
          None =>
            raise XmlMalformed(
              line=0,
              col=0,
              reason="CDATA outside document element",
            )
        }
      Comment(text) =>
        match stack.last() {
          Some(element) => element.children.push(Comment(text))
          None => ()
        }
      ProcessingInstruction(pi) =>
        match stack.last() {
          Some(element) => element.children.push(ProcessingInstruction(pi))
          None => ()
        }
    }
  }
  match root {
    Some(root) => { declaration, doctype: None, root }
    None => raise XmlMalformed(line=0, col=0, reason="missing document element")
  }
}
