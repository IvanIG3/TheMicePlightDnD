extends GutTest


func test_str_constant_value() -> void:
	assert_eq(AttributeIds.ATTR_STR, &"strength", "ATTR_STR should be the StringName &\"strength\"")


func test_all_six_constants_present() -> void:
	assert_eq(AttributeIds.ALL.size(), 6, "ALL should contain 6 entries")
	for value in AttributeIds.ALL:
		assert_true(value is StringName, "each ALL entry should be a StringName")


func test_constants_are_distinct() -> void:
	var values: Array[StringName] = [
		AttributeIds.ATTR_STR,
		AttributeIds.ATTR_DEX,
		AttributeIds.ATTR_CON,
		AttributeIds.ATTR_INT,
		AttributeIds.ATTR_WIS,
		AttributeIds.ATTR_CHA,
	]
	for i in values.size():
		for j in range(i + 1, values.size()):
			assert_ne(values[i], values[j], "constants must be distinct: %s == %s" % [values[i], values[j]])


func test_constants_match_resource_field_names() -> void:
	if not ResourceLoader.exists("res://attribute/attribute_set.gd"):
		pending("AttributeSet (T2) not yet on disk; deferring field-name test.")
		return
	var AttributeSetScript: GDScript = load("res://attribute/attribute_set.gd")
	var attribute_set: AttributeSet = AttributeSetScript.new()
	var mapping := {
		AttributeIds.ATTR_STR: "strength",
		AttributeIds.ATTR_DEX: "dexterity",
		AttributeIds.ATTR_CON: "constitution",
		AttributeIds.ATTR_INT: "intelligence",
		AttributeIds.ATTR_WIS: "wisdom",
		AttributeIds.ATTR_CHA: "charisma",
	}
	for attr in mapping.keys():
		var field_name: String = mapping[attr]
		var value: Variant = attribute_set.get(field_name)
		assert_eq(typeof(value), TYPE_INT, "AttributeSet.%s should be int (constant %s)" % [field_name, attr])
