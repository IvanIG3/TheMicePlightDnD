extends Node


## Test fixture: a brain that publishes a pre-set ActionPlan each turn.
## Replaces the production StaticPredatorBrain which is being removed.
## The TurnManager tests use this to drive specific plans without depending
## on PredatorAIBrain's decision tree.


var scripted_plan: ActionPlan = null

var _intent: IntentComponent = null


func bind(actor: Node) -> void:
	_intent = _find_intent(actor)


func plan_turn(_state: StringName) -> void:
	if _intent == null:
		return
	if scripted_plan == null:
		return
	_intent.publish(scripted_plan)


func _find_intent(actor: Node) -> IntentComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is IntentComponent:
			return child
	return null
