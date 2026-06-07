///|
test "catalog render coverage treats font table records as non-visual" {
  assert_true(is_non_visual_property_name("font"))
  assert_true(is_non_visual_property_name("charset"))
  assert_false(is_non_visual_property_name("r"))
}

///|
test "catalog render coverage treats diagram color lists as non-visual" {
  assert_true(is_non_visual_property_name("fillClrLst"))
  assert_true(is_non_visual_property_name("linClrLst"))
  assert_true(is_non_visual_property_name("txFillClrLst"))
  assert_false(is_non_visual_property_name("cat"))
}
