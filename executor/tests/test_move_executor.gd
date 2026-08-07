extends GutTest


const MoveExecutorScript := preload("res://executor/move_executor.gd")
const MoveDataScript := preload("res://executor/move_data.gd")
const ActionContextScript := preload("res://executor/action_context.gd")
const GridSystemScript := preload("res://world/grid_system.gd")
const GridPositionComponentScript := preload("res://world/grid_position_component.gd")


var _grid: GridSystem
var _actor: Node
var _pos: GridPositionComponent
var _ctx: ActionContext
var _executor: MoveExecutor


func before_each() -> void:
	_grid = GridSystemScript.new()
	_actor = Node.new()
	_pos = GridPositionComponentScript.new()
	_actor.add_child(_pos)
	_pos.init(_grid)
	_pos.set_cell(Vector2i(2, 2))
	add_child_autofree(_actor)
	_ctx = ActionContextScript.new()
	_ctx.actor = _actor
	_ctx.grid = _grid
	_executor = MoveExecutorScript.new()


func _make_move(direction: Vector2i) -> MoveData:
	var move_data: MoveData = MoveDataScript.new()
	move_data.direction = direction
	_executor.data = move_data
	return move_data


func test_validate_returns_false_with_null_data() -> void:
	_executor.data = null
	assert_false(_executor.validate(_ctx), "null data → validate false")


func test_validate_returns_true_for_orthogonal_step() -> void:
	_make_move(Vector2i(1, 0))
	assert_true(_executor.validate(_ctx), "(1, 0) is a valid orthogonal step")


func test_validate_returns_true_for_negative_orthogonal_step() -> void:
	_make_move(Vector2i(-1, 0))
	assert_true(_executor.validate(_ctx), "(-1, 0) is a valid orthogonal step")


func test_validate_returns_false_for_diagonal() -> void:
	_make_move(Vector2i(1, 1))
	assert_false(_executor.validate(_ctx), "(1, 1) is not orthogonal")


func test_validate_returns_false_for_zero() -> void:
	_make_move(Vector2i.ZERO)
	assert_false(_executor.validate(_ctx), "(0, 0) is not a step")


func test_validate_returns_false_for_two_steps() -> void:
	_make_move(Vector2i(2, 0))
	assert_false(_executor.validate(_ctx), "(2, 0) is more than one step")


func test_validate_returns_false_for_blocked_destination() -> void:
	_make_move(Vector2i(1, 0))
	_grid.set_blocked(Vector2i(3, 2), true)
	assert_false(_executor.validate(_ctx), "blocked destination → validate false")


func test_validate_returns_false_for_occupied_destination() -> void:
	_make_move(Vector2i(1, 0))
	var other: Node = Node.new()
	_grid.register_entity(other, Vector2i(3, 2))
	assert_false(_executor.validate(_ctx), "occupied destination → validate false")
	other.free()


func test_execute_moves_actor() -> void:
	_make_move(Vector2i(1, 0))
	var result: bool = _executor.execute(_ctx)
	assert_true(result, "execute returns true on success")
	assert_eq(_pos.cell, Vector2i(3, 2), "actor cell updated to (3, 2)")


func test_execute_returns_false_on_blocked_destination() -> void:
	_make_move(Vector2i(1, 0))
	_grid.set_blocked(Vector2i(3, 2), true)
	var result: bool = _executor.execute(_ctx)
	assert_false(result, "execute returns false when blocked")
	assert_eq(_pos.cell, Vector2i(2, 2), "actor cell unchanged")


func test_execute_returns_false_with_null_data() -> void:
	_executor.data = null
	var result: bool = _executor.execute(_ctx)
	assert_false(result, "execute returns false with null data")


func test_get_affected_tiles_returns_destination() -> void:
	_make_move(Vector2i(0, 1))
	var tiles: Array[Vector2i] = _executor.get_affected_tiles(_ctx)
	assert_eq(tiles.size(), 1, "single tile")
	assert_true(tiles.has(Vector2i(2, 3)), "destination is (2, 3)")


func test_get_affected_tiles_returns_empty_with_null_data() -> void:
	_executor.data = null
	var tiles: Array[Vector2i] = _executor.get_affected_tiles(_ctx)
	assert_eq(tiles.size(), 0, "null data → empty tiles")
