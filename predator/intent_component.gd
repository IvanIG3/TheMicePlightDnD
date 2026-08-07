class_name IntentComponent
extends Node

signal intent_published(plan: ActionPlan)
signal intent_cleared

var current_intent: ActionPlan = null


func publish(plan: ActionPlan) -> void:
	current_intent = plan
	intent_published.emit(plan)


func clear() -> void:
	current_intent = null
	intent_cleared.emit()


func get_affected_tiles() -> Array[Vector2i]:
	if current_intent == null:
		return [] as Array[Vector2i]
	return current_intent.predicted_affected_tiles
