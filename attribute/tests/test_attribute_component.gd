extends GutTest


const AttributeComponentScript := preload("res://attribute/attribute_component.gd")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")
const AttributeModifierScript := preload("res://attribute/attribute_modifier.gd")


var _component: AttributeComponent


func before_each() -> void:
	_component = AttributeComponentScript.new()
	add_child_autofree(_component)


func _make_set(strength_val: int = 10, dexterity_val: int = 10, constitution_val: int = 10, intelligence_val: int = 10, wisdom_val: int = 10, charisma_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.strength = strength_val
	attribute_set.dexterity = dexterity_val
	attribute_set.constitution = constitution_val
	attribute_set.intelligence = intelligence_val
	attribute_set.wisdom = wisdom_val
	attribute_set.charisma = charisma_val
	return attribute_set


func _make_modifier(attr: StringName, value: float, source: StringName) -> AttributeModifier:
	var m: AttributeModifier = AttributeModifierScript.new()
	m.attribute = attr
	m.mode = AttributeModifier.MODE_ADD
	m.value = value
	m.source = source
	return m


func test_base_value_no_modifiers() -> void:
	_component.base = _make_set()
	assert_eq(_component.get_value(AttributeIds.ATTR_STR), 10, "base STR 10")
	assert_eq(_component.modifier(AttributeIds.ATTR_STR), 0, "mod = 10 - 10 = 0")


func test_single_add_modifier() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	_component.add_modifier(_make_modifier(AttributeIds.ATTR_STR, 4.0, &"weakened"))
	assert_eq(_component.get_value(AttributeIds.ATTR_STR), 14, "STR with +4 modifier → 14")
	assert_signal_emitted(_component, "attribute_changed", [AttributeIds.ATTR_STR, 10, 14])


func test_flat_additive_stacking() -> void:
	_component.base = _make_set()
	_component.add_modifier(_make_modifier(AttributeIds.ATTR_STR, 4.0, &"a"))
	_component.add_modifier(_make_modifier(AttributeIds.ATTR_STR, 2.0, &"b"))
	assert_eq(_component.get_value(AttributeIds.ATTR_STR), 16, "STR = 10 base + 4 + 2 = 16")


func test_remove_modifiers_from() -> void:
	_component.base = _make_set()
	_component.add_modifier(_make_modifier(AttributeIds.ATTR_STR, 4.0, &"a"))
	_component.add_modifier(_make_modifier(AttributeIds.ATTR_STR, 2.0, &"b"))
	watch_signals(_component)
	var removed: int = _component.remove_modifiers_from(&"a")
	assert_eq(removed, 1, "one modifier removed from source 'a'")
	assert_eq(_component.get_value(AttributeIds.ATTR_STR), 12, "STR = 10 base + 2 = 12")
	assert_signal_emitted(_component, "attribute_changed", [AttributeIds.ATTR_STR, 16, 12])


func test_unknown_attribute_returns_zero_in_release_with_assert_in_debug() -> void:
	_component.base = _make_set()
	if OS.is_debug_build():
		pending("debug build: unknown-attr asserts; release path is verified by running tests with debug off")
		return
	var result: int = _component.get_value(&"nope")
	assert_eq(result, 0, "unknown attribute returns 0 in release")


func test_modifier_for_unaffected_attribute_unchanged() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	_component.add_modifier(_make_modifier(AttributeIds.ATTR_STR, 4.0, &"a"))
	assert_eq(_component.get_value(AttributeIds.ATTR_WIS), 10, "WIS unchanged by STR modifier")
	assert_signal_emitted(_component, "attribute_changed", [AttributeIds.ATTR_STR, 10, 14])
	assert_signal_emit_count(_component, "attribute_changed", 1, "only STR emits a change")


func test_remove_modifiers_from_no_match() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	var removed: int = _component.remove_modifiers_from(&"x")
	assert_eq(removed, 0, "no match → 0 removed")
	assert_signal_emit_count(_component, "attribute_changed", 0, "no signal emitted")
