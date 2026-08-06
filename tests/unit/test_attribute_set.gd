extends GutTest

const AttributeSetScript := preload("res://scripts/attribute_set.gd")

func test_defaults_are_ten() -> void:
	var attribute_set: Resource = AttributeSetScript.new()
	assert_eq(attribute_set.str, 10, "str should default to 10")
	assert_eq(attribute_set.dex, 10, "dex should default to 10")
	assert_eq(attribute_set.con, 10, "con should default to 10")
	assert_eq(attribute_set.int_, 10, "int_ should default to 10")
	assert_eq(attribute_set.wis, 10, "wis should default to 10")
	assert_eq(attribute_set.cha, 10, "cha should default to 10")

func test_modifier_subtracts_ten() -> void:
	var attribute_set: Resource = AttributeSetScript.new()
	attribute_set.str = 16
	assert_eq(attribute_set.modifier(&"str"), 6, "STR 16 → mod 6")
	attribute_set.str = 8
	assert_eq(attribute_set.modifier(&"str"), -2, "STR 8 → mod -2")

func test_get_unknown_attribute_returns_zero_in_release() -> void:
	var attribute_set: Resource = AttributeSetScript.new()
	# Per spec Decision 3: AttributeSet itself returns 0 silently for unknown attrs
	# (the assert path is on AttributeComponent, not here). This test exercises the
	# release path; the debug branch is verified by test_attribute_component.gd.
	assert_eq(attribute_set.get_value(&"unknown"), 0, "unknown attribute should return 0")
	assert_eq(attribute_set.modifier(&"unknown"), -10, "unknown attribute modifier = 0 - 10 = -10")

func test_set_field_round_trip() -> void:
	var attribute_set: Resource = AttributeSetScript.new()
	attribute_set.cha = 18
	assert_eq(attribute_set.get_value(&"cha"), 18, "cha field round-trip via get_value()")
	assert_eq(attribute_set.modifier(&"cha"), 8, "CHA 18 → mod 8")

func test_resource_survives_as_resource() -> void:
	var attribute_set: Resource = AttributeSetScript.new()
	attribute_set.str = 14
	# Wrap in another container; the inner attribute_set is the same object.
	var container: Dictionary = {"inner": attribute_set}
	var retrieved: Resource = container["inner"]
	assert_same(retrieved, attribute_set, "AttributeSet should be reference-stable")
	assert_eq(retrieved.str, 14, "field value preserved across the wrap")
