extends GutTest


func test_default_display_name_is_empty() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.display_name, "", "default display_name is empty")


func test_default_range_is_one() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.range, 1, "default range is 1")


func test_default_area_shape_is_single() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.area_shape, AreaShapes.SINGLE, "default area_shape is AreaShapes.SINGLE")


func test_default_area_size_is_one() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.area_size, 1, "default area_size is 1")


func test_default_effects_is_empty() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.effects.size(), 0, "effects starts empty")


func test_default_scaling_attributes_is_empty() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.scaling_attributes.size(), 0, "scaling_attributes starts empty")


func test_default_tags_is_empty() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.tags.size(), 0, "tags starts empty")


func test_display_name_is_assignable() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	data.display_name = "Bite"
	assert_eq(data.display_name, "Bite", "display_name is set")


func test_range_is_assignable() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	data.range = 2
	assert_eq(data.range, 2, "range is set to 2")


func test_type_id_is_basic_attack() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_eq(data.type_id, &"basic_attack", "type_id is &\"basic_attack\"")


func test_default_damage_is_null() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_null(data.damage, "default damage is null")


func test_default_target_is_null() -> void:
	var data: BasicAttackData = BasicAttackData.new()
	assert_null(data.target, "default target is null")
