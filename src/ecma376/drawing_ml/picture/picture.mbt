///|
/// ECMA-376 Part 1 §20.2 Drawingml Picture.
/// ECMA-376 §21.3 DrawingML Picture subdomain.
/// ECMA-376 Part 1 DrawingML §20.2.2.30 picture element.
///
/// Schema dml-picture.xsd owns XSD element pic, complex type CT_Picture, and
/// complex type CT_PictureNonVisual. The child payloads cNvPr, cNvPicPr,
/// blipFill, and spPr are DrawingML main structures preserved as XML DOM
/// elements by this outer picture package.
/// Source anchor: references/spec/part1/sections/20.2__drawingml-picture.md.
pub fn package_name() -> String {
  "trkbt10/ooxml/ecma376/drawing_ml/picture"
}

///|
/// DrawingML picture schema validation error.
pub suberror SchemaViolation {
  SchemaViolation(section~ : String, path~ : String, reason~ : String)
} derive(Debug)

///|
/// ResourceMissing is part of the CT_PictureNonVisual package error surface
/// for unresolved DrawingML picture resources delegated to OPC.
pub suberror ResourceMissing {
  ResourceMissing(section~ : String, path~ : String, target~ : String)
} derive(Debug)

///|
/// XSD complex type CT_PictureNonVisual from dml-picture.xsd. The package owns
/// the nvPicPr wrapper and preserves its cNvPr and cNvPicPr DrawingML main
/// children.
pub(all) struct CT_PictureNonVisual {
  c_nv_pr : @xml.Element
  c_nv_pic_pr : @xml.Element
} derive(Eq, Debug)

///|
/// XSD complex type CT_Picture from dml-picture.xsd for the §20.2.2.30 pic
/// element.
pub(all) struct CT_Picture {
  nv_pic_pr : CT_PictureNonVisual
  blip_fill : @xml.Element
  sp_pr : @xml.Element
} derive(Eq, Debug)

///|
/// XSD element pic is the top-level DrawingML picture element whose value is
/// CT_Picture.
pub type Pic = CT_Picture

///|
/// Read the top-level XSD element pic as CT_Picture.
pub fn read_pic(bytes : Bytes) -> CT_Picture raise {
  let doc = @xml.parse(bytes)
  let root = doc.root
  require_element(root, "pic", "pic")
  parse_ct_picture(root)
}

///|
/// Write a CT_Picture as the top-level XSD element pic.
pub fn write_pic(picture : CT_Picture) -> Bytes {
  @xml.write({
    declaration: None,
    doctype: None,
    root: {
      name: {
        prefix: Some("pic"),
        local_name: "pic",
        ns: Some("http://purl.oclc.org/ooxml/drawingml/picture"),
      },
      attributes: [],
      children: [
        @xml.Node::Element({
          name: {
            prefix: Some("pic"),
            local_name: "nvPicPr",
            ns: Some("http://purl.oclc.org/ooxml/drawingml/picture"),
          },
          attributes: [],
          children: [
            @xml.Node::Element(picture.nv_pic_pr.c_nv_pr),
            @xml.Node::Element(picture.nv_pic_pr.c_nv_pic_pr),
          ],
        }),
        @xml.Node::Element(picture.blip_fill),
        @xml.Node::Element(picture.sp_pr),
      ],
    },
  })
}

///|
fn parse_ct_picture(root : @xml.Element) -> CT_Picture raise SchemaViolation {
  let nv_pic_pr = required_child(root, "nvPicPr", "pic/nvPicPr")
  let blip_fill = required_child(root, "blipFill", "pic/blipFill")
  let sp_pr = required_child(root, "spPr", "pic/spPr")
  { nv_pic_pr: parse_ct_picture_non_visual(nv_pic_pr), blip_fill, sp_pr }
}

///|
/// Typed projection constructor — accept an already-parsed `<pic>`
/// element and produce the CT_Picture record. Public so callers in
/// neighbouring packages (e.g. wordprocessing_ml/domain typed
/// wrappers) can decode embedded `<dpct:pic>` children without
/// going through the byte-level reader.
pub fn CT_Picture::new(
  element : @xml.Element,
) -> CT_Picture raise SchemaViolation {
  parse_ct_picture(element)
}

///|
fn parse_ct_picture_non_visual(
  element : @xml.Element,
) -> CT_PictureNonVisual raise SchemaViolation {
  require_element(element, "nvPicPr", "pic/nvPicPr")
  {
    c_nv_pr: required_child(element, "cNvPr", "pic/nvPicPr/cNvPr"),
    c_nv_pic_pr: required_child(element, "cNvPicPr", "pic/nvPicPr/cNvPicPr"),
  }
}

///|
fn required_child(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> @xml.Element raise SchemaViolation {
  for child in element.children {
    match child {
      @xml.Node::Element(child_element) =>
        if child_element.name.local_name == local_name {
          return child_element
        }
      _ => ()
    }
  }
  raise SchemaViolation(
    section="20.2.2.30",
    path~,
    reason="required child element is missing",
  )
}

///|
fn require_element(
  element : @xml.Element,
  local_name : String,
  path : String,
) -> Unit raise SchemaViolation {
  if element.name.local_name != local_name {
    raise SchemaViolation(
      section="20.2.2.30",
      path~,
      reason="unexpected element name",
    )
  }
}
