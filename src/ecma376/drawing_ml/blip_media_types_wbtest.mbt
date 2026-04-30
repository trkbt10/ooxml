///|
test "round-trip blip" {
  let value = read_blip(
    bytes(
      "<a:blip xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\" r:embed=\"rId1\" cstate=\"print\"><a:alphaModFix amt=\"50000\"/><a:lum bright=\"0\" contrast=\"0\"/></a:blip>",
    ),
  )
  assert_eq(value.element.name.local_name, "blip")
  let reparsed = read_blip(write_blip(value))
  assert_eq(reparsed.element.name.local_name, "blip")
}

///|
test "round-trip video file" {
  let value = read_video_file(
    bytes(
      "<a:videoFile xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\" xmlns:r=\"http://purl.oclc.org/ooxml/officeDocument/relationships\" r:link=\"rId2\" contentType=\"video/mp4\"><a:extLst/></a:videoFile>",
    ),
  )
  assert_eq(value.element.name.local_name, "videoFile")
  let reparsed = read_video_file(write_video_file(value))
  assert_eq(reparsed.element.name.local_name, "videoFile")
}

///|
test "reject wrong blip root" {
  try {
    read_blip(
      bytes(
        "<a:videoFile xmlns:a=\"http://purl.oclc.org/ooxml/drawingml/main\"/>",
      ),
    )
    |> ignore
    fail("expected SchemaViolation")
  } catch {
    SchemaViolation(_) => ()
    _ => fail("expected SchemaViolation")
  }
}
