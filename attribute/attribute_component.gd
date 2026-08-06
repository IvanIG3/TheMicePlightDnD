class_name AttributeComponent
extends Node

signal attribute_changed(attribute: StringName, old_value: int, new_value: int)

@export var base: AttributeSet

var _bonuses: Array[AttributeBonus] = []


func get_score(attr: StringName) -> int:
	if not _is_known_attribute(attr):
		if OS.is_debug_build():
			assert(false, "Unknown attribute: " + attr)
		return 0
	
	var total: int = 0
	if base != null:
		total = base.get_score(attr)
	for b in _bonuses:
		if b.attribute == attr and b.mode == AttributeBonus.MODE_ADD:
			total += int(b.value)
	
	return total


func get_modifier(attr: StringName) -> int:
	return get_score(attr) - AttributeData.SCORE_BASELINE


func add_bonus(b: AttributeBonus) -> void:
	var attr: StringName = b.attribute
	var old_value: int = get_score(attr)
	_bonuses.append(b)
	var new_value: int = get_score(attr)
	attribute_changed.emit(attr, old_value, new_value)


func remove_bonuses_from(source: StringName) -> int:
	var affected_attrs: Array = []
	for b in _bonuses:
		if b.source == source and not affected_attrs.has(b.attribute):
			affected_attrs.append(b.attribute)
	
	var pre_values: Dictionary = {}
	for attr in affected_attrs:
		pre_values[attr] = get_score(attr)
	
	var removed: int = 0
	for b in _bonuses:
		if b.source == source:
			removed += 1
	
	_bonuses = _bonuses.filter(func(b): return b.source != source)
	
	for attr in affected_attrs:
		var post_value: int = get_score(attr)
		attribute_changed.emit(attr, pre_values[attr], post_value)
	
	return removed


func _is_known_attribute(attr: StringName) -> bool:
	return attr in AttributeIds.ALL
