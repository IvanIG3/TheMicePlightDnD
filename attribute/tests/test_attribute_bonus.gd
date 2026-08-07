extends GutTest


const AttributeBonusScript := preload("res://attribute/attribute_bonus.gd")


func test_field_defaults() -> void:
	var b: AttributeBonus = AttributeBonusScript.new()
	assert_eq(b.attribute, &"", "attribute defaults to empty StringName")
	assert_eq(b.mode, AttributeModes.MODE_ADD, "mode defaults to MODE_ADD")
	assert_eq(b.value, 0, "value defaults to 0")
	assert_eq(b.source, &"", "source defaults to empty StringName")


func test_field_round_trip() -> void:
	var b: AttributeBonus = AttributeBonusScript.new()
	b.attribute = AttributeIds.ATTR_STR
	b.mode = AttributeModes.MODE_ADD
	b.value = 4
	b.source = &"weakened"
	assert_eq(b.attribute, AttributeIds.ATTR_STR, "attribute round-trip")
	assert_eq(b.mode, AttributeModes.MODE_ADD, "mode round-trip")
	assert_eq(b.value, 4, "value round-trip")
	assert_eq(b.source, &"weakened", "source round-trip")


func test_mode_constants_are_distinct_stringnames() -> void:
	var modes: Array[StringName] = [
		AttributeModes.MODE_ADD,
		AttributeModes.MODE_SET,
	]
	for i in modes.size():
		for j in range(i + 1, modes.size()):
			assert_ne(modes[i], modes[j], "constants must be distinct: %s == %s" % [modes[i], modes[j]])


func test_bonus_value_can_be_negative() -> void:
	var b: AttributeBonus = AttributeBonusScript.new()
	b.value = -2
	assert_eq(b.value, -2, "value can be negative (penalty)")
