class_name HealEffectData
extends EffectData


@export var dice: DiceFormula = null


func _init() -> void:
	type_id = &"heal"
