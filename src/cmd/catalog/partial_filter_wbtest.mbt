///|
test "catalog partial filter parses comma separated lists" {
  let got = catalog_parse_filter_list(" dgm, c ,, w ")
  assert_eq(got.length(), 3)
  assert_eq(got[0], "dgm")
  assert_eq(got[1], "c")
  assert_eq(got[2], "w")
}

///|
test "catalog partial filter matches host prefixes" {
  assert_true(
    catalog_filter_host_value_match("pptx:diagram", "pptx:diagram-layout"),
  )
  assert_true(catalog_filter_host_value_match("xlsx", "xlsx:pivot"))
  assert_true(catalog_filter_host_value_match("docx:settings", "docx:settings"))
  assert_false(catalog_filter_host_value_match("pptx:diagram", "pptx:chart"))
}

///|
test "catalog partial filter strips host part suffixes" {
  assert_eq(catalog_base_host_format("pptx:diagram-layout"), "pptx")
  assert_eq(catalog_base_host_format("xlsx"), "xlsx")
  assert_eq(catalog_base_host_format("docx:settings"), "docx")
}

///|
test "catalog partial structural formats use touched package bases" {
  let touched : Map[String, Bool] = Map([], capacity=0)
  touched["pptx"] = true
  touched["docx"] = true
  let partial = catalog_structural_formats(true, touched)
  assert_eq(partial.length(), 2)
  assert_eq(partial[0], "pptx")
  assert_eq(partial[1], "docx")
  let full = catalog_structural_formats(false, touched)
  assert_eq(full.length(), 3)
  assert_eq(full[0], "xlsx")
  assert_eq(full[1], "pptx")
  assert_eq(full[2], "docx")
}
