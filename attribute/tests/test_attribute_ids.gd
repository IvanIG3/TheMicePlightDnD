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


func test_all_constants_have_matching_attribute_data_resource() -> void:
	for attr_id in AttributeIds.ALL:
		var path: String = "res://attribute/%s.tres" % attr_id
		assert_true(ResourceLoader.exists(path), "missing AttributeData resource: %s" % path)
		var data: AttributeData = load(path)
		assert_eq(data.id, attr_id, "AttributeData at %s must declare id = %s" % [path, attr_id])
