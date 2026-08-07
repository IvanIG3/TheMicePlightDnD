extends GutTest


func test_no_duplicates_in_all() -> void:
	var seen: Dictionary = {}
	for value in RangeShapes.ALL:
		assert_false(seen.has(value), "duplicate in ALL: %s" % String(value))
		seen[value] = true


func test_line_constant_is_line() -> void:
	assert_eq(RangeShapes.LINE, &"line", "LINE is &\"line\"")


func test_all_contains_line() -> void:
	assert_true(RangeShapes.ALL.has(RangeShapes.LINE), "ALL contains LINE")
