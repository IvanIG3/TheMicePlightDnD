extends GutTest


const ActionDataScript := preload("res://executor/action_data.gd")
const MoveDataScript := preload("res://executor/move_data.gd")


func test_action_data_is_resource() -> void:
	var data: ActionData = ActionDataScript.new()
	assert_not_null(data, "ActionData instantiates")
	assert_true(data is Resource, "ActionData is a Resource")


func test_move_data_has_type_id_move() -> void:
	var data: MoveData = MoveDataScript.new()
	assert_eq(data.type_id, &"move", "MoveData.type_id is &\"move\"")


func test_move_data_default_direction_is_zero() -> void:
	var data: MoveData = MoveDataScript.new()
	assert_eq(data.direction, Vector2i.ZERO, "default direction is (0, 0)")


func test_move_data_direction_is_assignable() -> void:
	var data: MoveData = MoveDataScript.new()
	data.direction = Vector2i(1, 0)
	assert_eq(data.direction, Vector2i(1, 0), "direction is set to (1, 0)")
