extends GutTest


const ActionPlanScript := preload("res://executor/action_plan.gd")


func test_default_fields() -> void:
	var plan: ActionPlan = ActionPlanScript.new()
	assert_eq(plan.action, &"", "action defaults to empty StringName")
	assert_null(plan.target, "target defaults to null")
	assert_null(plan.card, "card defaults to null")
	assert_eq(plan.predicted_affected_tiles.size(), 0, "predicted_affected_tiles defaults to empty")


func test_action_can_be_move() -> void:
	var plan: ActionPlan = ActionPlanScript.new()
	plan.action = &"move"
	assert_eq(plan.action, &"move", "action is set to move")


func test_target_can_be_vector2i() -> void:
	var plan: ActionPlan = ActionPlanScript.new()
	plan.target = Vector2i(3, 4)
	assert_eq(plan.target, Vector2i(3, 4), "target accepts Vector2i")


func test_target_can_be_node() -> void:
	var plan: ActionPlan = ActionPlanScript.new()
	var actor: Node = Node.new()
	plan.target = actor
	assert_eq(plan.target, actor, "target accepts a Node")
	actor.free()


func test_predicted_affected_tiles_is_assignable() -> void:
	var plan: ActionPlan = ActionPlanScript.new()
	plan.predicted_affected_tiles = [Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3)]
	assert_eq(plan.predicted_affected_tiles.size(), 3, "three tiles stored")
	assert_true(plan.predicted_affected_tiles.has(Vector2i(2, 2)), "includes (2, 2)")
