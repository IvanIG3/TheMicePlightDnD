class_name Mouse
extends Character


@export var class_data: MouseClassData = null


@onready var brain: PlayerInputBrain = $BrainSlot/PlayerInputBrain


func _ready() -> void:
	super._ready()
	if brain != null:
		brain.bind(self)
	if class_data == null:
		return
	if class_data.attributes != null:
		attribute_component.base = class_data.attributes
	if class_data.max_hp_base > 0:
		health_component.init(class_data.max_hp_base, attribute_component)
		health_component.recompute_max_hp()
		health_component.current_hp = health_component.max_hp
