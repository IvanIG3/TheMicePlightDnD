class_name Predator
extends Character


@export var basic_attack: BasicAttackData = null


func _ready() -> void:
	faction = FactionIds.FACTION_PREDATOR
	super._ready()
	var brain: StaticPredatorBrain = _get_brain()
	if brain != null:
		brain.bind(self)


func get_intent() -> IntentComponent:
	for child in get_children():
		if child is IntentComponent:
			return child
	return null


func _get_brain() -> StaticPredatorBrain:
	if brain_slot == null:
		return null
	for child in brain_slot.get_children():
		if child is StaticPredatorBrain:
			return child
	return null
