extends GutTest


const AttributeSetScript := preload("res://attribute/attribute_set.gd")


func test_empty_set_returns_zero_for_all_attributes() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_STR), 0, "unset strength returns 0")
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_DEX), 0, "unset dexterity returns 0")
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_CON), 0, "unset constitution returns 0")
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_INT), 0, "unset intelligence returns 0")
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_WIS), 0, "unset wisdom returns 0")
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_CHA), 0, "unset charisma returns 0")


func test_modifier_subtracts_ten() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_value(AttributeIds.ATTR_STR, 16)
	assert_eq(attribute_set.modifier(AttributeIds.ATTR_STR), 6, "strength 16 → mod 6")
	attribute_set.set_value(AttributeIds.ATTR_STR, 8)
	assert_eq(attribute_set.modifier(AttributeIds.ATTR_STR), -2, "strength 8 → mod -2")


func test_get_unknown_attribute_returns_zero() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	assert_eq(attribute_set.get_value(&"unknown"), 0, "unknown attribute returns 0")
	assert_eq(attribute_set.modifier(&"unknown"), -10, "unknown attribute modifier = 0 - 10 = -10")


func test_set_value_round_trip() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_value(AttributeIds.ATTR_CHA, 18)
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_CHA), 18, "charisma round-trip via get_value()")
	assert_eq(attribute_set.modifier(AttributeIds.ATTR_CHA), 8, "charisma 18 → mod 8")


func test_resource_survives_as_resource() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_value(AttributeIds.ATTR_STR, 14)
	var container: Dictionary = {"inner": attribute_set}
	var retrieved: Resource = container["inner"]
	assert_same(retrieved, attribute_set, "AttributeSet should be reference-stable")
	assert_eq(retrieved.get_value(AttributeIds.ATTR_STR), 14, "value preserved across the wrap")
