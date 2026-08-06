extends GutTest


const AttributeComponentScript := preload("res://attribute/attribute_component.gd")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")
const AttributeBonusScript := preload("res://attribute/attribute_bonus.gd")


var _component: AttributeComponent


func before_each() -> void:
	_component = AttributeComponentScript.new()
	add_child_autofree(_component)


func _make_set(strength_val: int = 10, dexterity_val: int = 10, constitution_val: int = 10, intelligence_val: int = 10, wisdom_val: int = 10, charisma_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, strength_val)
	attribute_set.set_score(AttributeIds.ATTR_DEX, dexterity_val)
	attribute_set.set_score(AttributeIds.ATTR_CON, constitution_val)
	attribute_set.set_score(AttributeIds.ATTR_INT, intelligence_val)
	attribute_set.set_score(AttributeIds.ATTR_WIS, wisdom_val)
	attribute_set.set_score(AttributeIds.ATTR_CHA, charisma_val)
	return attribute_set


func _make_bonus(attr: StringName, value: int, source: StringName) -> AttributeBonus:
	var b: AttributeBonus = AttributeBonusScript.new()
	b.attribute = attr
	b.mode = AttributeBonus.MODE_ADD
	b.value = value
	b.source = source
	return b


func test_base_score_no_bonuses() -> void:
	_component.base = _make_set()
	assert_eq(_component.get_score(AttributeIds.ATTR_STR), 10, "base STR 10")
	assert_eq(_component.get_modifier(AttributeIds.ATTR_STR), 0, "mod = 10 - 10 = 0")


func test_single_add_bonus() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	_component.add_bonus(_make_bonus(AttributeIds.ATTR_STR, 4, &"weakened"))
	assert_eq(_component.get_score(AttributeIds.ATTR_STR), 14, "STR with +4 bonus → 14")
	assert_signal_emitted(_component, "attribute_changed", [AttributeIds.ATTR_STR, 10, 14])


func test_flat_additive_stacking() -> void:
	_component.base = _make_set()
	_component.add_bonus(_make_bonus(AttributeIds.ATTR_STR, 4, &"a"))
	_component.add_bonus(_make_bonus(AttributeIds.ATTR_STR, 2, &"b"))
	assert_eq(_component.get_score(AttributeIds.ATTR_STR), 16, "STR = 10 base + 4 + 2 = 16")


func test_remove_bonuses_from() -> void:
	_component.base = _make_set()
	_component.add_bonus(_make_bonus(AttributeIds.ATTR_STR, 4, &"a"))
	_component.add_bonus(_make_bonus(AttributeIds.ATTR_STR, 2, &"b"))
	watch_signals(_component)
	var removed: int = _component.remove_bonuses_from(&"a")
	assert_eq(removed, 1, "one bonus removed from source 'a'")
	assert_eq(_component.get_score(AttributeIds.ATTR_STR), 12, "STR = 10 base + 2 = 12")
	assert_signal_emitted(_component, "attribute_changed", [AttributeIds.ATTR_STR, 16, 12])


func test_unknown_attribute_returns_zero_in_release_with_assert_in_debug() -> void:
	_component.base = _make_set()
	if OS.is_debug_build():
		pending("debug build: unknown-attr asserts; release path is verified by running tests with debug off")
		return
	var result: int = _component.get_score(&"nope")
	assert_eq(result, 0, "unknown attribute returns 0 in release")


func test_modifier_for_unaffected_attribute_unchanged() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	_component.add_bonus(_make_bonus(AttributeIds.ATTR_STR, 4, &"a"))
	assert_eq(_component.get_score(AttributeIds.ATTR_WIS), 10, "WIS unchanged by STR bonus")
	assert_signal_emitted(_component, "attribute_changed", [AttributeIds.ATTR_STR, 10, 14])
	assert_signal_emit_count(_component, "attribute_changed", 1, "only STR emits a change")


func test_remove_bonuses_from_no_match() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	var removed: int = _component.remove_bonuses_from(&"x")
	assert_eq(removed, 0, "no match → 0 removed")
	assert_signal_emit_count(_component, "attribute_changed", 0, "no signal emitted")
