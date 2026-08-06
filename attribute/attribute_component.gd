class_name AttributeComponent
extends Node

signal attribute_changed(attribute: StringName, old_value: int, new_value: int)

@export var base: AttributeSet

var _modifiers: Array[AttributeModifier] = []


func get_value(attr: StringName) -> int:
	if not _is_known_attribute(attr):
		if OS.is_debug_build():
			assert(false, "Unknown attribute: " + attr)
		return 0
	
	var total: int = 0
	if base != null:
		total = base.get_value(attr)
	for m in _modifiers:
		if m.attribute == attr and m.mode == AttributeModifier.MODE_ADD:
			total += int(m.value)
	
	return total


func modifier(attr: StringName) -> int:
	return get_value(attr) - AttributeModifier.MODIFIER_BASE


func add_modifier(m: Resource) -> void:
	var attr: StringName = m.attribute
	var old_value: int = get_value(attr)
	_modifiers.append(m)
	var new_value: int = get_value(attr)
	attribute_changed.emit(attr, old_value, new_value)


func remove_modifiers_from(source: StringName) -> int:
	var affected_attrs: Array = []
	for m in _modifiers:
		if m.source == source and not affected_attrs.has(m.attribute):
			affected_attrs.append(m.attribute)
	
	var pre_values: Dictionary = {}
	for attr in affected_attrs:
		pre_values[attr] = get_value(attr)
	
	var removed: int = 0
	for m in _modifiers:
		if m.source == source:
			removed += 1
	
	_modifiers = _modifiers.filter(func(m): return m.source != source)
	
	for attr in affected_attrs:
		var post_value: int = get_value(attr)
		attribute_changed.emit(attr, pre_values[attr], post_value)
	
	return removed


func _is_known_attribute(attr: StringName) -> bool:
	return attr in AttributeIds.ALL
