extends GutTest


const MouseScene := preload("res://mouse/mouse.tscn")


func _setup_mouse_on_grid() -> Dictionary:
	var grid: GridSystem = GridSystem.new()
	var mouse: Node = MouseScene.instantiate()
	add_child_autofree(grid)
	add_child_autofree(mouse)
	mouse.grid_position_component.grid = grid
	mouse.grid_position_component.set_cell(Vector2i(2, 2))
	var turn_manager: Node = Engine.get_main_loop().root.get_node_or_null("/root/TurnManager")
	if turn_manager != null:
		turn_manager.stop()
		turn_manager.start(mouse, grid, ([mouse] as Array[Node]))
	return {"grid": grid, "mouse": mouse}


func test_mouse_starts_at_initial_cell() -> void:
	var s: Dictionary = _setup_mouse_on_grid()
	assert_eq(s.mouse.grid_position_component.cell, Vector2i(2, 2), "initial cell is (2, 2)")


func test_move_intent_right_moves_mouse() -> void:
	var s: Dictionary = _setup_mouse_on_grid()
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	input.move_intent.emit(Vector2i(1, 0))
	assert_eq(s.mouse.grid_position_component.cell, Vector2i(3, 2), "mouse moved right to (3, 2)")


func test_move_intent_left_moves_mouse() -> void:
	var s: Dictionary = _setup_mouse_on_grid()
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	input.move_intent.emit(Vector2i(-1, 0))
	assert_eq(s.mouse.grid_position_component.cell, Vector2i(1, 2), "mouse moved left to (1, 2)")


func test_move_intent_spends_action_budget() -> void:
	var s: Dictionary = _setup_mouse_on_grid()
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	var budget: ActionBudgetComponent = s.mouse.get_node("ActionBudgetComponent")
	assert_true(budget.can_perform(&"move"), "can move before intent")
	input.move_intent.emit(Vector2i(1, 0))
	assert_false(budget.can_perform(&"move"), "cannot move after intent (budget spent)")


func test_move_into_blocked_tile_is_rejected() -> void:
	var s: Dictionary = _setup_mouse_on_grid()
	s.grid.set_blocked(Vector2i(3, 2), true)
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	input.move_intent.emit(Vector2i(1, 0))
	assert_eq(s.mouse.grid_position_component.cell, Vector2i(2, 2), "mouse did not move into blocked cell")
	var budget: ActionBudgetComponent = s.mouse.get_node("ActionBudgetComponent")
	assert_true(budget.can_perform(&"move"), "budget not spent on rejected move")


func test_diagonal_move_intent_is_rejected() -> void:
	var s: Dictionary = _setup_mouse_on_grid()
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	input.move_intent.emit(Vector2i(1, 1))
	assert_eq(s.mouse.grid_position_component.cell, Vector2i(2, 2), "diagonal rejected, mouse did not move")
