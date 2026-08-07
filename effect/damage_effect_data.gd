class_name DamageEffectData
extends EffectData


@export var dice: DiceFormula = null
@export var scaling_attribute: StringName = &""
@export var damage_type: StringName = &"physical"
@export var resistance_attribute: StringName = &""
@export var resistance_value: int = 0


func _init() -> void:
	type_id = &"damage"
