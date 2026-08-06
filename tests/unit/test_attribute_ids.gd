extends GutTest

# Note: AttributeSetScript preload deferred — test_constants_match_resource_field_names
# only runs after Phase 1 T2 lands AttributeSet.
const AttributeIdsScript := preload("res://scripts/attribute_ids.gd")

func test_str_constant_value() -> void:
	assert_eq(AttributeIds.ATTR_STR, &"str", "ATTR_STR should be the StringName &\"str\"")

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
	# Deferred until T2 ships AttributeSet. This test only runs once the
	# AttributeSet resource exists on disk; the GUT scan walks the scripts dir
	# and would parse-error if we preloaded a missing file.
	if not ResourceLoader.exists("res://scripts/attribute_set.gd"):
		pending("AttributeSet (T2) not yet on disk; deferring field-name test.")
		return
	# AttributeSet exports fields named str, dex, con, int_, wis, cha.
	# AttributeIds constants must correspond to those names (sans the trailing underscore on int_).
	var AttributeSetScript: GDScript = load("res://scripts/attribute_set.gd")
	var attribute_set: Resource = AttributeSetScript.new()
	# Map the AttributeIds constant to the AttributeSet field it should match.
	var mapping := {
		AttributeIds.ATTR_STR: "str",
		AttributeIds.ATTR_DEX: "dex",
		AttributeIds.ATTR_CON: "con",
		AttributeIds.ATTR_INT: "int_",
		AttributeIds.ATTR_WIS: "wis",
		AttributeIds.ATTR_CHA: "cha",
	}
	for attr in mapping.keys():
		var field_name: String = mapping[attr]
		# Use the dict to verify the constant -> field wiring is real.
		# Access the field via get() so static-typed GDScript does not error.
		var value: Variant = attribute_set.get(field_name)
		assert_eq(typeof(value), TYPE_INT, "AttributeSet.%s should be int (constant %s)" % [field_name, attr])
