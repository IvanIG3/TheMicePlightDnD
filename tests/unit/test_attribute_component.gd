extends GutTest

const AttributeComponentScript := preload("res://scripts/attribute_component.gd")
const AttributeSetScript := preload("res://scripts/attribute_set.gd")
const AttributeModifierScript := preload("res://scripts/attribute_modifier.gd")

var _component: Node

func before_each() -> void:
	_component = AttributeComponentScript.new()
	add_child_autofree(_component)

func _make_set(str_val: int = 10, dex_val: int = 10, con_val: int = 10, int_val: int = 10, wis_val: int = 10, cha_val: int = 10) -> Resource:
	var attribute_set: Resource = AttributeSetScript.new()
	attribute_set.str = str_val
	attribute_set.dex = dex_val
	attribute_set.con = con_val
	attribute_set.int_ = int_val
	attribute_set.wis = wis_val
	attribute_set.cha = cha_val
	return attribute_set

func _make_modifier(attr: StringName, value: float, source: StringName) -> Resource:
	var m: Resource = AttributeModifierScript.new()
	m.attribute = attr
	m.mode = &"add"
	m.value = value
	m.source = source
	return m

func test_base_value_no_modifiers() -> void:
	_component.base = _make_set()
	assert_eq(_component.get_value(&"str"), 10, "base STR 10")
	assert_eq(_component.modifier(&"str"), 0, "mod = 10 - 10 = 0")

func test_single_add_modifier() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	_component.add_modifier(_make_modifier(&"str", 4.0, &"weakened"))
	assert_eq(_component.get_value(&"str"), 14, "STR with +4 modifier → 14")
	assert_signal_emitted(_component, "attribute_changed", [&"str", 10, 14])

func test_flat_additive_stacking() -> void:
	_component.base = _make_set()
	# FIFO: a added first, b added second. Both sum.
	_component.add_modifier(_make_modifier(&"str", 4.0, &"a"))
	_component.add_modifier(_make_modifier(&"str", 2.0, &"b"))
	assert_eq(_component.get_value(&"str"), 16, "STR = 10 base + 4 + 2 = 16")

func test_remove_modifiers_from() -> void:
	_component.base = _make_set()
	_component.add_modifier(_make_modifier(&"str", 4.0, &"a"))
	_component.add_modifier(_make_modifier(&"str", 2.0, &"b"))
	watch_signals(_component)
	var removed: int = _component.remove_modifiers_from(&"a")
	assert_eq(removed, 1, "one modifier removed from source 'a'")
	assert_eq(_component.get_value(&"str"), 12, "STR = 10 base + 2 = 12")
	assert_signal_emitted(_component, "attribute_changed", [&"str", 16, 12])

func test_unknown_attribute_returns_zero_in_release_with_assert_in_debug() -> void:
	_component.base = _make_set()
	# In debug builds, the assert path fires BEFORE the function returns 0.
	# The release path is the only one callable as a normal test. The debug
	# assert behaviour is documented in code (assert message includes the attr
	# name) and exercised by the design's locked risk #4.
	if OS.is_debug_build():
		pending("debug build: unknown-attr asserts; release path is verified by running tests with debug off")
		return
	var result: int = _component.get_value(&"nope")
	assert_eq(result, 0, "unknown attribute returns 0 in release")

func test_modifier_for_unaffected_attribute_unchanged() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	_component.add_modifier(_make_modifier(&"str", 4.0, &"a"))
	assert_eq(_component.get_value(&"wis"), 10, "WIS unchanged by STR modifier")
	# attribute_changed was emitted for STR only.
	assert_signal_emitted(_component, "attribute_changed", [&"str", 10, 14])
	# Exactly one emission total (for STR only; WIS not in payload).
	assert_signal_emit_count(_component, "attribute_changed", 1, "only STR emits a change")

func test_remove_modifiers_from_no_match() -> void:
	_component.base = _make_set()
	watch_signals(_component)
	var removed: int = _component.remove_modifiers_from(&"x")
	assert_eq(removed, 0, "no match → 0 removed")
	assert_signal_emit_count(_component, "attribute_changed", 0, "no signal emitted")
