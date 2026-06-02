///|
test "catalog render coverage treats font table records as non-visual" {
  assert_true(is_non_visual_property_name("font"))
  assert_true(is_non_visual_property_name("charset"))
  assert_false(is_non_visual_property_name("r"))
}
