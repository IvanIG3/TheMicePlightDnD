extends GutTest


const _THEME_DIRS: Array[String] = [
	"res://attribute/",
	"res://stats/",
	"res://health/",
	"res://dice/",
	"res://global/",
	"res://predator/",
	"res://turn/",
	"res://action/",
	"res://effect/",
	"res://card/",
	"res://character/",
	"res://mouse/",
	"res://view/",
	"res://world/",
	"res://input/",
]


const _ALLOWED_RNG_FILES: Array[String] = [
	"global/rng_service.gd",
	"global/tests/test_no_direct_rng.gd",
]


const _DIRECT_RNG_PATTERN: String = r"(?<!\.)\brandi\s*\(|(?<!\.)\brandf\s*\("


func test_no_direct_rng_in_scripts() -> void:
	var pattern: RegEx = RegEx.create_from_string(_DIRECT_RNG_PATTERN)
	var violations: Array[String] = []
	for theme_dir in _THEME_DIRS:
		for file_path in _walk_dir(theme_dir):
			var rel_path: String = file_path.trim_prefix("res://")
			if rel_path in _ALLOWED_RNG_FILES:
				continue
			var content: String = FileAccess.get_file_as_string(file_path)
			if pattern.search(content) != null:
				violations.append(rel_path)
	assert_eq(violations.size(), 0, "Direct RNG use found in: " + str(violations))


func _walk_dir(dir_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue
		var full_path: String = dir_path.path_join(entry)
		if dir.current_is_dir():
			result.append_array(_walk_dir(full_path))
		else:
			if entry.ends_with(".gd"):
				result.append(full_path)
		entry = dir.get_next()
	dir.list_dir_end()
	return result
