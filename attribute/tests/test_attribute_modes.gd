extends GutTest


func test_no_duplicates_in_all() -> void:
	var seen: Dictionary = {}
	for value in AttributeModes.ALL:
		assert_false(seen.has(value), "duplicate in ALL: %s" % String(value))
		seen[value] = true
