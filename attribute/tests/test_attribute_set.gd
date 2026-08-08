extends GutTest


func test_empty_set_returns_zero_for_all_attributes() -> void:
	var attribute_set: AttributeSet = AttributeSet.new()
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_STR), 0, "unset strength returns 0")
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_DEX), 0, "unset dexterity returns 0")
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_CON), 0, "unset constitution returns 0")
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_INT), 0, "unset intelligence returns 0")
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_WIS), 0, "unset wisdom returns 0")
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_CHA), 0, "unset charisma returns 0")


func test_modifier_subtracts_baseline() -> void:
	var attribute_set: AttributeSet = AttributeSet.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, 16)
	assert_eq(attribute_set.get_modifier(AttributeIds.ATTR_STR), 6, "strength 16 → mod 6")
	attribute_set.set_score(AttributeIds.ATTR_STR, 8)
	assert_eq(attribute_set.get_modifier(AttributeIds.ATTR_STR), -2, "strength 8 → mod -2")


func test_get_unknown_attribute_returns_zero() -> void:
	var attribute_set: AttributeSet = AttributeSet.new()
	assert_eq(attribute_set.get_score(&"unknown"), 0, "unknown attribute returns 0")
	assert_eq(attribute_set.get_modifier(&"unknown"), -10, "unknown attribute modifier = 0 - 10 = -10")


func test_set_score_round_trip() -> void:
	var attribute_set: AttributeSet = AttributeSet.new()
	attribute_set.set_score(AttributeIds.ATTR_CHA, 18)
	assert_eq(attribute_set.get_score(AttributeIds.ATTR_CHA), 18, "charisma round-trip via get_score()")
	assert_eq(attribute_set.get_modifier(AttributeIds.ATTR_CHA), 8, "charisma 18 → mod 8")


func test_resource_survives_as_resource() -> void:
	var attribute_set: AttributeSet = AttributeSet.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, 14)
	var container: Dictionary = {"inner": attribute_set}
	var retrieved: Resource = container["inner"]
	assert_same(retrieved, attribute_set, "AttributeSet should be reference-stable")
	assert_eq(retrieved.get_score(AttributeIds.ATTR_STR), 14, "score preserved across the wrap")
