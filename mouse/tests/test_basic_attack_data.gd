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
