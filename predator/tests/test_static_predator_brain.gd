extends GutTest


func _make_plan(action: StringName = &"move") -> ActionPlan:
	var plan: ActionPlan = ActionPlan.new()
	plan.action = action
	plan.target = Vector2i(3, 2)
	plan.predicted_affected_tiles = [Vector2i(3, 2)]
	return plan


func _make_actor() -> Node:
	var actor: Node = Node.new()
	var intent: IntentComponent = IntentComponent.new()
	actor.add_child(intent)
	return actor


func test_bind_finds_intent_component() -> void:
	var actor: Node = _make_actor()
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	add_child_autofree(brain)
	brain.bind(actor)
	assert_not_null(brain._intent, "_intent is set after bind")


func test_bind_without_intent_leaves_intent_null() -> void:
	var actor: Node = Node.new()
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	add_child_autofree(brain)
	brain.bind(actor)
	assert_null(brain._intent, "_intent is null when actor has no IntentComponent")


func test_plan_turn_publishes_scripted_plan() -> void:
	var actor: Node = _make_actor()
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	add_child_autofree(brain)
	brain.bind(actor)
	var plan: ActionPlan = _make_plan()
	brain.scripted_plan = plan
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var intent: IntentComponent = actor.get_child(0) as IntentComponent
	assert_eq(intent.current_intent, plan, "intent holds the scripted plan")


func test_plan_turn_no_op_without_scripted_plan() -> void:
	var actor: Node = _make_actor()
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	add_child_autofree(brain)
	brain.bind(actor)
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var intent: IntentComponent = actor.get_child(0) as IntentComponent
	assert_null(intent.current_intent, "intent stays null when no scripted plan")


func test_plan_turn_no_op_without_intent() -> void:
	var actor: Node = Node.new()
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	add_child_autofree(brain)
	brain.bind(actor)
	brain.scripted_plan = _make_plan()
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	# Just verify it doesn't crash.


func test_plan_turn_publishes_same_plan_each_turn() -> void:
	var actor: Node = _make_actor()
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	add_child_autofree(brain)
	brain.bind(actor)
	var plan: ActionPlan = _make_plan(&"wait")
	brain.scripted_plan = plan
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var intent: IntentComponent = actor.get_child(0) as IntentComponent
	assert_eq(intent.current_intent, plan, "static brain publishes the same plan every turn")
