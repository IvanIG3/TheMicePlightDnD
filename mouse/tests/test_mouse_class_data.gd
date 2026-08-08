extends GutTest


func test_default_id_is_empty() -> void:
	var data: MouseClassData = MouseClassData.new()
	assert_eq(data.id, &"", "default id is empty StringName")


func test_id_is_assignable() -> void:
	var data: MouseClassData = MouseClassData.new()
	data.id = &"grasshopper_mouse"
	assert_eq(data.id, &"grasshopper_mouse", "id is set")


func test_display_name_is_assignable() -> void:
	var data: MouseClassData = MouseClassData.new()
	data.display_name = "Grasshopper Mouse"
	assert_eq(data.display_name, "Grasshopper Mouse", "display_name is set")


func test_attributes_is_assignable() -> void:
	var data: MouseClassData = MouseClassData.new()
	var attribute_set: AttributeSet = AttributeSet.new()
	data.attributes = attribute_set
	assert_eq(data.attributes, attribute_set, "attributes is set")


func test_default_max_hp_base_is_zero() -> void:
	var data: MouseClassData = MouseClassData.new()
	assert_eq(data.max_hp_base, 0, "default max_hp_base is 0")


func test_max_hp_base_is_assignable() -> void:
	var data: MouseClassData = MouseClassData.new()
	data.max_hp_base = 20
	assert_eq(data.max_hp_base, 20, "max_hp_base is set")


func test_default_max_energy_base_is_zero() -> void:
	var data: MouseClassData = MouseClassData.new()
	assert_eq(data.max_energy_base, 0, "default max_energy_base is 0")


func test_default_initial_deck_is_empty() -> void:
	var data: MouseClassData = MouseClassData.new()
	assert_eq(data.initial_deck.size(), 0, "initial_deck starts empty")


func test_default_level_up_options_is_empty() -> void:
	var data: MouseClassData = MouseClassData.new()
	assert_eq(data.level_up_options.size(), 0, "level_up_options starts empty")
