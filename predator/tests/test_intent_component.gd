extends GutTest


const IntentComponentScript := preload("res://predator/intent_component.gd")
const ActionPlanScript := preload("res://executor/action_plan.gd")


func _make_plan(tiles: Array[Vector2i] = [Vector2i(3, 2)]) -> ActionPlan:
	var plan: ActionPlan = ActionPlanScript.new()
	plan.action = &"move"
	plan.target = Vector2i(3, 2)
	plan.predicted_affected_tiles = tiles
	return plan


func test_publish_stores_plan() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	var plan: ActionPlan = _make_plan()
	intent.publish(plan)
	assert_eq(intent.current_intent, plan, "current_intent holds the published plan")


func test_publish_emits_intent_published() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	watch_signals(intent)
	var plan: ActionPlan = _make_plan()
	intent.publish(plan)
	assert_signal_emit_count(intent, "intent_published", 1, "intent_published emitted once")


func test_publish_signal_carries_plan() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	var sink: Dictionary = {"plan": null}
	intent.intent_published.connect(func(p: ActionPlan) -> void: sink["plan"] = p)
	var plan: ActionPlan = _make_plan()
	intent.publish(plan)
	assert_eq(sink["plan"], plan, "subscriber received the published plan")


func test_clear_resets_plan() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	intent.publish(_make_plan())
	intent.clear()
	assert_null(intent.current_intent, "current_intent is null after clear")


func test_clear_emits_intent_cleared() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	watch_signals(intent)
	intent.publish(_make_plan())
	intent.clear()
	assert_signal_emit_count(intent, "intent_cleared", 1, "intent_cleared emitted once")


func test_get_affected_tiles_returns_predicted() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	var tiles: Array[Vector2i] = [Vector2i(3, 2), Vector2i(4, 2)]
	intent.publish(_make_plan(tiles))
	assert_eq(intent.get_affected_tiles(), tiles, "returns the predicted_affected_tiles")


func test_get_affected_tiles_empty_when_no_intent() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	assert_eq(intent.get_affected_tiles(), [] as Array[Vector2i], "empty array when no intent")


func test_get_affected_tiles_empty_after_clear() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	intent.publish(_make_plan([Vector2i(1, 1)]))
	intent.clear()
	assert_eq(intent.get_affected_tiles(), [] as Array[Vector2i], "empty after clear")


func test_double_publish_replaces_plan() -> void:
	var intent: IntentComponent = IntentComponentScript.new()
	add_child_autofree(intent)
	var plan_a: ActionPlan = _make_plan([Vector2i(1, 1)])
	var plan_b: ActionPlan = _make_plan([Vector2i(2, 2)])
	intent.publish(plan_a)
	intent.publish(plan_b)
	assert_eq(intent.current_intent, plan_b, "second publish replaces the first")
	assert_eq(intent.get_affected_tiles(), [Vector2i(2, 2)], "affected tiles from plan_b")
