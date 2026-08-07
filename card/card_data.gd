class_name CardData
extends Resource


@export var id: StringName = &""
@export var name: String = ""
@export var description: String = ""
@export var energy_cost: int = 0
@export var family: StringName = CardFamilies.NONE
@export var type: StringName = CardTypes.ATTACK
@export var range: int = 1
@export var range_shape: StringName = RangeShapes.LINE
@export var area_shape: StringName = AreaShapes.SINGLE
@export var area_size: int = 1
@export var effects: Array[EffectData] = []
@export var scaling_attributes: Array[StringName] = []
@export var exhaust: bool = false
@export var tags: Array[StringName] = []
