extends GutTest


var _grid: GridSystem
var _comp: GridPositionComponent


func before_each() -> void:
	_grid = GridSystem.new()
	add_child_autofree(_grid)
	_comp = GridPositionComponent.new()
	add_child_autofree(_comp)
	_comp.grid = _grid


func test_set_cell_updates_cell_and_returns_true() -> void:
	var result: bool = _comp.set_cell(Vector2i(2, 3))
	assert_true(result, "valid set_cell returns true")
	assert_eq(_comp.cell, Vector2i(2, 3), "cell updated to (2, 3)")


func test_set_cell_emits_cell_changed() -> void:
	watch_signals(_comp)
	_comp.set_cell(Vector2i(2, 3))
	assert_signal_emitted(_comp, "cell_changed", [Vector2i(0, 0), Vector2i(2, 3)])


func test_set_cell_registers_on_grid() -> void:
	_comp.set_cell(Vector2i(2, 3))
	assert_eq(_grid.get_at(Vector2i(2, 3)), _comp, "grid has the component at the new cell")


func test_set_cell_unregisters_from_old_cell() -> void:
	_comp.set_cell(Vector2i(2, 3))
	_comp.set_cell(Vector2i(4, 5))
	assert_null(_grid.get_at(Vector2i(2, 3)), "old cell (2, 3) cleared")
	assert_eq(_grid.get_at(Vector2i(4, 5)), _comp, "new cell (4, 5) occupied")


func test_set_cell_returns_false_when_blocked() -> void:
	_grid.set_blocked(Vector2i(3, 3), true)
	var result: bool = _comp.set_cell(Vector2i(3, 3))
	assert_false(result, "blocked cell returns false")
	assert_eq(_comp.cell, Vector2i(0, 0), "cell unchanged after failed set_cell")


func test_set_cell_returns_false_when_occupied() -> void:
	var other: Node = Node.new()
	_grid.register_entity(other, Vector2i(2, 2))
	var result: bool = _comp.set_cell(Vector2i(2, 2))
	assert_false(result, "occupied cell returns false")
	assert_eq(_comp.cell, Vector2i(0, 0), "cell unchanged after failed set_cell")
	other.free()


func test_set_cell_same_cell_is_noop() -> void:
	_comp.set_cell(Vector2i(2, 2))
	watch_signals(_comp)
	var result: bool = _comp.set_cell(Vector2i(2, 2))
	assert_true(result, "set_cell to same cell returns true")
	assert_signal_emit_count(_comp, "cell_changed", 0, "no signal for no-op")


func test_set_cell_does_not_emit_on_failure() -> void:
	_grid.set_blocked(Vector2i(3, 3), true)
	watch_signals(_comp)
	_comp.set_cell(Vector2i(3, 3))
	assert_signal_emit_count(_comp, "cell_changed", 0, "no signal on failed set_cell")


func test_try_move_success() -> void:
	_comp.set_cell(Vector2i(2, 2))
	var result: bool = _comp.try_move(Vector2i(1, 0))
	assert_true(result, "valid try_move returns true")
	assert_eq(_comp.cell, Vector2i(3, 2), "cell moved by (1, 0) to (3, 2)")


func test_try_move_blocked() -> void:
	_comp.set_cell(Vector2i(2, 2))
	_grid.set_blocked(Vector2i(3, 2), true)
	var result: bool = _comp.try_move(Vector2i(1, 0))
	assert_false(result, "try_move into blocked cell returns false")
	assert_eq(_comp.cell, Vector2i(2, 2), "cell unchanged after failed try_move")


func test_try_move_occupied() -> void:
	_comp.set_cell(Vector2i(2, 2))
	var other: Node = Node.new()
	_grid.register_entity(other, Vector2i(3, 2))
	var result: bool = _comp.try_move(Vector2i(1, 0))
	assert_false(result, "try_move into occupied cell returns false")
	assert_eq(_comp.cell, Vector2i(2, 2), "cell unchanged after failed try_move")
	other.free()


func test_try_move_emits_cell_changed() -> void:
	_comp.set_cell(Vector2i(2, 2))
	watch_signals(_comp)
	_comp.try_move(Vector2i(1, 0))
	assert_signal_emitted(_comp, "cell_changed", [Vector2i(2, 2), Vector2i(3, 2)])
