extends GutTest


const AttributeModifierScript := preload("res://attribute/attribute_modifier.gd")


func test_field_defaults() -> void:
	var m: AttributeModifier = AttributeModifierScript.new()
	assert_eq(m.attribute, &"", "attribute defaults to empty StringName")
	assert_eq(m.mode, AttributeModifier.MODE_ADD, "mode defaults to MODE_ADD")
	assert_eq(m.value, 0.0, "value defaults to 0.0")
	assert_eq(m.source, &"", "source defaults to empty StringName")


func test_field_round_trip() -> void:
	var m: AttributeModifier = AttributeModifierScript.new()
	m.attribute = AttributeIds.ATTR_STR
	m.mode = AttributeModifier.MODE_ADD
	m.value = 4.0
	m.source = &"weakened"
	assert_eq(m.attribute, AttributeIds.ATTR_STR, "attribute round-trip")
	assert_eq(m.mode, AttributeModifier.MODE_ADD, "mode round-trip")
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
	var m: AttributeModifier = AttributeModifierScript.new()
	m.value = -2.0
	assert_eq(m.value, -2.0, "value can be negative (penalty)")
