class_name Predator
extends Character


@export var basic_attack: BasicAttackData = null


func _ready() -> void:
	faction = FactionIds.FACTION_PREDATOR
	super._ready()
	var brain: PredatorBrain = _get_brain()
	if brain != null:
		brain.bind(self)


func get_intent() -> IntentComponent:
	return ActorUtils.find_component(self, IntentComponent)


func _get_brain() -> PredatorBrain:
	if brain_slot == null:
		return null
	for child in brain_slot.get_children():
		if child is PredatorBrain:
			return child
	return null
