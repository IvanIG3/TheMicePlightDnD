extends PredatorBrain


## Test fixture: a brain that publishes a pre-set ActionPlan each turn.


var scripted_plan: ActionPlan = null

var _intent: IntentComponent = null


func bind(actor: Node) -> void:
	assert(actor != null, "ScriptedPredatorBrain.bind: actor is required")
	_intent = ActorUtils.find_component(actor, IntentComponent)


func plan_turn(_state: StringName) -> void:
	if _intent == null:
		return
	if scripted_plan == null:
		return
	_intent.publish(scripted_plan)
