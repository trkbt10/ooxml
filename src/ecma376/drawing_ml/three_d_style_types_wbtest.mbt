///|
test "round-trip scene3d" {
  let value = read_scene3d(
    bytes(
      "<a:scene3d xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"><a:camera prst=\"orthographicFront\"><a:rot lat=\"0\" lon=\"0\" rev=\"0\"/></a:camera><a:lightRig rig=\"threePt\" dir=\"t\"><a:rot lat=\"0\" lon=\"0\" rev=\"0\"/></a:lightRig><a:backdrop><a:anchor x=\"0\" y=\"0\" z=\"0\"/><a:norm dx=\"0\" dy=\"0\" dz=\"100000\"/><a:up dx=\"0\" dy=\"100000\" dz=\"0\"/></a:backdrop></a:scene3d>",
    ),
  )
  assert_eq(value.element.name.local_name, "scene3d")
  let reparsed = read_scene3d(write_scene3d(value))
  assert_eq(reparsed.element.name.local_name, "scene3d")
}

///|
test "round-trip bevel" {
  let value = read_bevel(
    bytes(
      "<a:bevel xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" w=\"63500\" h=\"63500\" prst=\"circle\"/>",
    ),
  )
  assert_eq(value.element.name.local_name, "bevel")
  let reparsed = read_bevel(write_bevel(value))
  assert_eq(reparsed.element.name.local_name, "bevel")
}

///|
test "round-trip shape3d" {
  let value = read_shape3d(
    bytes(
      "<a:sp3d xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" z=\"0\" extrusionH=\"0\" contourW=\"0\" prstMaterial=\"matte\"><a:bevelT w=\"63500\" h=\"63500\" prst=\"circle\"/><a:bevelB w=\"0\" h=\"0\"/><a:extrusionClr><a:srgbClr val=\"000000\"/></a:extrusionClr><a:contourClr><a:srgbClr val=\"FFFFFF\"/></a:contourClr></a:sp3d>",
    ),
  )
  assert_eq(value.element.name.local_name, "sp3d")
  let reparsed = read_shape3d(write_shape3d(value))
  assert_eq(reparsed.element.name.local_name, "sp3d")
}

///|
test "round-trip style matrix" {
  let value = read_style_matrix(
    bytes(
      "<a:fmtScheme xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" name=\"Office\"><a:fillStyleLst><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill></a:fillStyleLst><a:lnStyleLst><a:ln w=\"9525\"/></a:lnStyleLst><a:effectStyleLst><a:effectStyle><a:effectLst/><a:scene3d><a:camera prst=\"orthographicFront\"/><a:lightRig rig=\"threePt\" dir=\"t\"/></a:scene3d><a:sp3d/></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:noFill/></a:bgFillStyleLst></a:fmtScheme>",
    ),
  )
  assert_eq(value.element.name.local_name, "fmtScheme")
  let reparsed = read_style_matrix(write_style_matrix(value))
  assert_eq(reparsed.element.name.local_name, "fmtScheme")
}
