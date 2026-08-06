extends GutTest

const AttributeModifierScript := preload("res://scripts/attribute_modifier.gd")

func test_field_defaults() -> void:
	var m: Resource = AttributeModifierScript.new()
	assert_eq(m.attribute, &"", "attribute defaults to empty StringName")
	assert_eq(m.mode, &"add", "mode defaults to &\"add\"")
	assert_eq(m.value, 0.0, "value defaults to 0.0")
	assert_eq(m.source, &"", "source defaults to empty StringName")

func test_field_round_trip() -> void:
	var m: Resource = AttributeModifierScript.new()
	m.attribute = &"str"
	m.mode = &"add"
	m.value = 4.0
	m.source = &"weakened"
	assert_eq(m.attribute, &"str", "attribute round-trip")
	assert_eq(m.mode, &"add", "mode round-trip")
	assert_eq(m.value, 4.0, "value round-trip")
	assert_eq(m.source, &"weakened", "source round-trip")

func test_modifier_constants_are_distinct_stringnames() -> void:
	var modes: Array[StringName] = [
		AttributeModifierScript.MODE_ADD,
		AttributeModifierScript.MODE_MULTIPLY,
		AttributeModifierScript.MODE_SET,
	]
	for i in modes.size():
		for j in range(i + 1, modes.size()):
			assert_ne(modes[i], modes[j], "constants must be distinct: %s == %s" % [modes[i], modes[j]])

func test_modifier_value_can_be_negative() -> void:
	var m: Resource = AttributeModifierScript.new()
	m.value = -2.0
	assert_eq(m.value, -2.0, "value can be negative (penalty)")
