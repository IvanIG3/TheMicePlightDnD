class_name BasicAttackData
extends ActionData


const type_id: StringName = &"basic_attack"


@export var display_name: String = ""
@export var description: String = ""
@export var range: int = 1
@export var area_shape: StringName = AreaShapes.SINGLE
@export var area_size: int = 1
@export var damage: DiceFormula = null
@export var effects: Array = []
@export var scaling_attributes: Array[StringName] = []
@export var tags: Array[StringName] = []
@export var target: Variant = null
