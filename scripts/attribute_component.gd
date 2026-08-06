class_name AttributeComponent
extends Node

# Node component that holds an AttributeSet base and an array of AttributeModifiers.
# Resolves the effective value of each attribute by summing base + all "add" modifiers
# in insertion (FIFO) order. Emits attribute_changed(attribute, old, new) on every
# add_modifier / remove_modifiers_from call so consumers can react to state changes.
#
# Stacking rule (locked, per spec Decision 1 + flat additive stacking):
#   - mode == "add": summed (only mode that contributes in Phase 1).
#   - mode == "multiply" or "set": accepted as field values, IGNORED in Phase 1.
#   - TODO[phase-9]: implement multiply/set when stacking semantics expand.
#
# Unknown attribute policy (Decision 3): assert in debug, silent zero in release.

@export var base: Resource = null

var _modifiers: Array = []

signal attribute_changed(attribute: StringName, old_value: int, new_value: int)

# Returns the resolved value of an attribute, summing base.get_value(attr)
# with the additive modifier values whose attribute matches.
func get_value(attr: StringName) -> int:
	if not _is_known_attribute(attr):
		if OS.is_debug_build():
			assert(false, "Unknown attribute: " + attr)
		return 0
	var total: int = 0
	if base != null:
		total = base.get_value(attr)
	for m in _modifiers:
		if m.attribute == attr and m.mode == &"add":
			total += int(m.value)
	return total

# D&D 5e modifier: resolved value minus 10.
func modifier(attr: StringName) -> int:
	return get_value(attr) - 10

# Append a modifier. Emits attribute_changed once for the affected attribute.
func add_modifier(m: Resource) -> void:
	var attr: StringName = m.attribute
	var old_value: int = get_value(attr)
	_modifiers.append(m)
	var new_value: int = get_value(attr)
	attribute_changed.emit(attr, old_value, new_value)

# Remove every modifier whose source matches. Emits attribute_changed once per
# affected attribute with pre/post values. Returns the number of modifiers removed.
func remove_modifiers_from(source: StringName) -> int:
	# Snapshot pre-removal values for every affected attribute.
	var affected_attrs: Array = []
	for m in _modifiers:
		if m.source == source and not affected_attrs.has(m.attribute):
			affected_attrs.append(m.attribute)
	var pre_values: Dictionary = {}
	for attr in affected_attrs:
		pre_values[attr] = get_value(attr)
	# Count before filtering.
	var removed: int = 0
	for m in _modifiers:
		if m.source == source:
			removed += 1
	# Filter in place.
	_modifiers = _modifiers.filter(func(m): return m.source != source)
	# Emit one attribute_changed per affected attribute.
	for attr in affected_attrs:
		var post_value: int = get_value(attr)
		attribute_changed.emit(attr, pre_values[attr], post_value)
	return removed

# === Private helpers ===

func _is_known_attribute(attr: StringName) -> bool:
	return attr in [
		&"str", &"dex", &"con", &"int", &"wis", &"cha",
	]
