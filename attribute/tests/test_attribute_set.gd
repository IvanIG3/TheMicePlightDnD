extends GutTest


const AttributeSetScript := preload("res://attribute/attribute_set.gd")


func test_defaults_are_ten() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	assert_eq(attribute_set.strength, 10, "strength should default to 10")
	assert_eq(attribute_set.dexterity, 10, "dexterity should default to 10")
	assert_eq(attribute_set.constitution, 10, "constitution should default to 10")
	assert_eq(attribute_set.intelligence, 10, "intelligence should default to 10")
	assert_eq(attribute_set.wisdom, 10, "wisdom should default to 10")
	assert_eq(attribute_set.charisma, 10, "charisma should default to 10")


func test_modifier_subtracts_ten() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.strength = 16
	assert_eq(attribute_set.modifier(AttributeIds.ATTR_STR), 6, "strength 16 → mod 6")
	attribute_set.strength = 8
	assert_eq(attribute_set.modifier(AttributeIds.ATTR_STR), -2, "strength 8 → mod -2")


func test_get_unknown_attribute_returns_zero_in_release() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	assert_eq(attribute_set.get_value(&"unknown"), 0, "unknown attribute should return 0")
	assert_eq(attribute_set.modifier(&"unknown"), -10, "unknown attribute modifier = 0 - 10 = -10")


func test_set_field_round_trip() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.charisma = 18
	assert_eq(attribute_set.get_value(AttributeIds.ATTR_CHA), 18, "charisma field round-trip via get_value()")
	assert_eq(attribute_set.modifier(AttributeIds.ATTR_CHA), 8, "charisma 18 → mod 8")


func test_resource_survives_as_resource() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.strength = 14
	var container: Dictionary = {"inner": attribute_set}
	var retrieved: Resource = container["inner"]
	assert_same(retrieved, attribute_set, "AttributeSet should be reference-stable")
	assert_eq(retrieved.strength, 14, "field value preserved across the wrap")
