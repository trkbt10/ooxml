// §17.16.5.4 checkBox — a legacy form-field checkbox renders its
// ☑ / ☐ glyph (was previously dropped: fldChar fell through to no-op).

///|
fn parse_fld_char(inner : String) -> @xml.Element raise {
  let src = "<w:r xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">" +
    inner +
    "</w:r>"
  let doc = @xml.parse(@utf8.encode(src[:]))
  match first_child_named(doc.root, "fldChar") {
    Some(e) => e
    None => abort("expected <w:fldChar>")
  }
}

///|
test "checked form checkbox renders ☑" {
  let fc = parse_fld_char(
    "<w:fldChar w:fldCharType=\"begin\"><w:ffData><w:checkBox><w:checked w:val=\"1\"/></w:checkBox></w:ffData></w:fldChar>",
  )
  inspect(
    form_checkbox_glyph(fc),
    content=(
      #|Some(☑)
    ),
  )
}

///|
test "default-checked form checkbox renders ☑ when no explicit checked" {
  let fc = parse_fld_char(
    "<w:fldChar w:fldCharType=\"begin\"><w:ffData><w:checkBox><w:default w:val=\"1\"/></w:checkBox></w:ffData></w:fldChar>",
  )
  inspect(
    form_checkbox_glyph(fc),
    content=(
      #|Some(☑)
    ),
  )
}

///|
test "unchecked form checkbox renders ☐" {
  let fc = parse_fld_char(
    "<w:fldChar w:fldCharType=\"begin\"><w:ffData><w:checkBox><w:checked w:val=\"0\"/></w:checkBox></w:ffData></w:fldChar>",
  )
  inspect(
    form_checkbox_glyph(fc),
    content=(
      #|Some(☐)
    ),
  )
}

///|
test "checkbox with neither checked nor default is unchecked" {
  let fc = parse_fld_char(
    "<w:fldChar w:fldCharType=\"begin\"><w:ffData><w:checkBox/></w:ffData></w:fldChar>",
  )
  inspect(
    form_checkbox_glyph(fc),
    content=(
      #|Some(☐)
    ),
  )
}

///|
test "non-checkbox field boundaries emit no glyph" {
  // A text form field (no checkBox) at begin → None.
  let text_ff = parse_fld_char(
    "<w:fldChar w:fldCharType=\"begin\"><w:ffData><w:textInput/></w:ffData></w:fldChar>",
  )
  inspect(form_checkbox_glyph(text_ff), content="None")
  // The separate / end boundaries → None even for a checkbox field.
  let sep = parse_fld_char("<w:fldChar w:fldCharType=\"separate\"/>")
  inspect(form_checkbox_glyph(sep), content="None")
  let end_ = parse_fld_char("<w:fldChar w:fldCharType=\"end\"/>")
  inspect(form_checkbox_glyph(end_), content="None")
}
