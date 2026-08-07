class_name CompositeEffectData
extends EffectData


@export var effects: Array[EffectData] = []
@export var mode: StringName = &"sequence"


func _init() -> void:
	type_id = &"composite"
