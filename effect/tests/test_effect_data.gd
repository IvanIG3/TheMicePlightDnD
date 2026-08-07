extends GutTest


const EffectDataScript := preload("res://effect/effect_data.gd")


func test_effect_data_is_resource() -> void:
	var data: Resource = EffectDataScript.new()
	assert_true(data is Resource, "EffectData is a Resource")


func test_default_description_is_empty() -> void:
	var data: Resource = EffectDataScript.new()
	assert_eq(data.description, "", "default description is empty string")


func test_default_tags_is_empty() -> void:
	var data: Resource = EffectDataScript.new()
	assert_eq(data.tags.size(), 0, "default tags is empty array")


func test_default_type_id_is_empty_stringname() -> void:
	var data: Resource = EffectDataScript.new()
	assert_eq(data.type_id, &"", "default type_id is empty StringName")


func test_description_is_assignable() -> void:
	var data: Resource = EffectDataScript.new()
	data.description = "Burns the target"
	assert_eq(data.description, "Burns the target", "description round-trips")


func test_tags_are_assignable() -> void:
	var data: Resource = EffectDataScript.new()
	var new_tags: Array[StringName] = [&"damage", &"fire"]
	data.tags = new_tags
	assert_eq(data.tags, new_tags, "tags round-trip")


func test_subclass_can_override_type_id() -> void:
	var SubDataScript: GDScript = GDScript.new()
	SubDataScript.source_code = "extends \"res://effect/effect_data.gd\"\nfunc _init() -> void:\n\ttype_id = &\"test_custom\"\n"
	var reload_err: int = SubDataScript.reload()
	assert_eq(reload_err, OK, "subclass script compiled")
	var data: Resource = SubDataScript.new()
	assert_eq(data.type_id, &"test_custom", "subclass sets type_id via _init")
