extends GutTest


const PlayerInputBrainScript := preload("res://mouse/player_input_brain.gd")
const GridSystemScript := preload("res://world/grid_system.gd")
const GridPositionComponentScript := preload("res://world/grid_position_component.gd")
const ActionBudgetComponentScript := preload("res://character/action_budget_component.gd")


func _make_actor(start_cell: Vector2i = Vector2i(2, 2)) -> Dictionary:
	var grid: GridSystem = GridSystemScript.new()
	var pos: GridPositionComponent = GridPositionComponentScript.new()
	var budget: ActionBudgetComponent = ActionBudgetComponentScript.new()
	var actor: Node = Node.new()
	actor.add_child(pos)
	actor.add_child(budget)
	pos.grid = grid
	pos.set_cell(start_cell)
	add_child_autofree(actor)
	return {"grid": grid, "pos": pos, "budget": budget, "actor": actor}


func test_on_move_intent_moves_actor() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_move_intent(Vector2i(1, 0))
	assert_eq(s.pos.cell, Vector2i(3, 2), "actor moved right to (3, 2)")


func test_on_move_intent_spends_move_budget() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_move_intent(Vector2i(1, 0))
	assert_false(s.budget.can_perform(&"move"), "move action budget is spent")


func test_on_move_intent_creates_pending_plan() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_move_intent(Vector2i(0, 1))
	assert_not_null(brain.pending_plan, "pending_plan is set")
	assert_eq(brain.pending_plan.action, &"move", "plan action is &\"move\"")
	assert_eq(brain.pending_plan.target, Vector2i(2, 3), "plan target is the destination")


func test_on_move_intent_blocked_does_not_move_or_spend_budget() -> void:
	var s: Dictionary = _make_actor()
	s.grid.set_blocked(Vector2i(3, 2), true)
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_move_intent(Vector2i(1, 0))
	assert_eq(s.pos.cell, Vector2i(2, 2), "actor did not move")
	assert_true(s.budget.can_perform(&"move"), "budget not spent on failed move")


func test_on_move_intent_diagonal_is_rejected() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_move_intent(Vector2i(1, 1))
	assert_eq(s.pos.cell, Vector2i(2, 2), "diagonal rejected, actor did not move")
	assert_true(s.budget.can_perform(&"move"), "budget not spent on rejected move")


func test_bind_connects_to_input_service_move_intent() -> void:
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	assert_not_null(input, "InputService autoload must be registered")
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(Node.new())
	assert_true(input.move_intent.is_connected(brain._on_move_intent), "brain is connected to move_intent")


func test_move_intent_through_input_service_drives_brain() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrainScript.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	input.move_intent.emit(Vector2i(-1, 0))
	assert_eq(s.pos.cell, Vector2i(1, 2), "actor moved left via InputService signal")
