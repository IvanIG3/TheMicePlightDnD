extends GutTest

# Determinism guard: walk res://scripts/ and assert that no file outside
# rng_service.gd contains a direct call to randi() or randf(). This is the
# hard build break for architecture Principle 6.
#
# Pattern notes:
#   - `\b` is a word boundary so we don't match `randi_range` or `randi` in
#     identifiers (e.g. a variable named `my_randi`).
#   - `\s*` allows optional whitespace between the function name and the
#     opening paren (Godot formatter style).
#   - The `(` is required to avoid matching `randi` as a substring or
#     `randomize` (which doesn't have a paren).

const ALLOWED_FILES := ["rng_service.gd"]
const PATTERN := r"\brandi\s*\(|brandf\s*\("

func test_no_direct_rng_in_scripts() -> void:
	var dir := DirAccess.open("res://scripts/")
	assert_not_null(dir, "res://scripts/ must exist before this test runs")
	var violations: Array[String] = []
	var regex := RegEx.create_from_string(PATTERN)
	for filename in dir.get_files():
		if not filename.ends_with(".gd"):
			continue
		if filename in ALLOWED_FILES:
			continue
		var path := "res://scripts/" + filename
		var content := FileAccess.get_file_as_string(path)
		for match in regex.search_all(content):
			violations.append("%s:%d" % [path, match.get_start()])
	assert_eq(violations.size(), 0, "Direct RNG use found in: " + str(violations))
