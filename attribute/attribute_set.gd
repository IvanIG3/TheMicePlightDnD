class_name AttributeSet
extends Resource


@export var values: Dictionary[StringName, int] = {}


func get_value(attr: StringName) -> int:
	return values.get(attr, 0)


func set_value(attr: StringName, value: int) -> void:
	values[attr] = value


func modifier(attr: StringName) -> int:
	return get_value(attr) - AttributeModifier.MODIFIER_BASE
