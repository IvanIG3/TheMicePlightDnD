class_name Predator
extends Character


@export var basic_attack: BasicAttackData = null


func _ready() -> void:
	faction = FactionIds.FACTION_PREDATOR
	super._ready()
	var brain: Node = _get_brain()
	if brain != null and brain.has_method(&"bind"):
		brain.bind(self)


func get_intent() -> IntentComponent:
	for child in get_children():
		if child is IntentComponent:
			return child
	return null


func _get_brain() -> Node:
	if brain_slot == null:
		return null
	for child in brain_slot.get_children():
		if child.has_method(&"plan_turn"):
			return child
	return null
