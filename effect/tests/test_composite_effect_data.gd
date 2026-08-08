extends GutTest


func _load_data() -> Resource:
	return CompositeEffectData.new()


func test_composite_effect_data_inherits_from_effect_data() -> void:
	var data: Resource = _load_data()
	assert_true(data.get_script().get_base_script() != null, "has a base script")
	var base_path: String = data.get_script().get_base_script().resource_path
	assert_eq(base_path, "res://effect/effect_data.gd", "inherits EffectData")


func test_type_id_is_composite() -> void:
	var data: Resource = _load_data()
	assert_eq(data.type_id, &"composite", "type_id is &\"composite\"")


func test_default_effects_is_empty() -> void:
	var data: Resource = _load_data()
	assert_eq(data.effects.size(), 0, "default effects is empty array")


func test_default_mode_is_sequence() -> void:
	var data: Resource = _load_data()
	assert_eq(data.mode, &"sequence", "default mode is &\"sequence\"")


func test_default_description_is_empty() -> void:
	var data: Resource = _load_data()
	assert_eq(data.description, "", "default description is empty string")


func test_effects_is_assignable() -> void:
	var data: Resource = _load_data()
	var inner: EffectData = EffectData.new()
	inner.type_id = DamageEffectData.new().type_id
	var arr: Array[EffectData] = [inner]
	data.effects = arr
	assert_eq(data.effects.size(), 1, "effects has one element")
	assert_eq(data.effects[0].type_id, &"damage", "inner element preserved")


func test_mode_is_assignable() -> void:
	var data: Resource = _load_data()
	data.mode = &"all"
	assert_eq(data.mode, &"all", "mode round-trips")
