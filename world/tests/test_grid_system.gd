extends GutTest


var _grid: GridSystem


func before_each() -> void:
	_grid = GridSystem.new()
	add_child_autofree(_grid)


func test_get_at_empty_cell_returns_null() -> void:
	assert_null(_grid.get_at(Vector2i(0, 0)), "empty cell returns null")


func test_register_entity_then_get_at() -> void:
	var entity: Node = Node.new()
	_grid.register_entity(entity, Vector2i(2, 3))
	assert_eq(_grid.get_at(Vector2i(2, 3)), entity, "registered entity is returned by get_at")
	entity.free()


func test_register_overwrites_previous_occupant() -> void:
	var a: Node = Node.new()
	var b: Node = Node.new()
	_grid.register_entity(a, Vector2i(1, 1))
	_grid.register_entity(b, Vector2i(1, 1))
	assert_eq(_grid.get_at(Vector2i(1, 1)), b, "second register overwrites the first")
	a.free()
	b.free()


func test_unregister_clears_occupant() -> void:
	var entity: Node = Node.new()
	_grid.register_entity(entity, Vector2i(1, 1))
	_grid.unregister_entity(entity, Vector2i(1, 1))
	assert_null(_grid.get_at(Vector2i(1, 1)), "unregister clears the occupant")
	entity.free()


func test_unregister_only_clears_matching_entity() -> void:
	var a: Node = Node.new()
	var b: Node = Node.new()
	_grid.register_entity(a, Vector2i(0, 0))
	_grid.register_entity(b, Vector2i(1, 1))
	_grid.unregister_entity(a, Vector2i(0, 0))
	assert_null(_grid.get_at(Vector2i(0, 0)), "a is gone from (0, 0)")
	assert_eq(_grid.get_at(Vector2i(1, 1)), b, "b remains at (1, 1)")
	a.free()
	b.free()


func test_is_blocked_default_false() -> void:
	assert_false(_grid.is_blocked(Vector2i(5, 5)), "default blocked is false")


func test_set_blocked_true_then_is_blocked() -> void:
	_grid.set_blocked(Vector2i(3, 3), true)
	assert_true(_grid.is_blocked(Vector2i(3, 3)), "set_blocked(true) marks the cell as blocked")


func test_set_blocked_false_unblocks() -> void:
	_grid.set_blocked(Vector2i(3, 3), true)
	_grid.set_blocked(Vector2i(3, 3), false)
	assert_false(_grid.is_blocked(Vector2i(3, 3)), "set_blocked(false) unblocks the cell")


func test_neighbors_returns_four_orthogonal() -> void:
	var result: Array[Vector2i] = _grid.neighbors(Vector2i(0, 0))
	assert_eq(result.size(), 4, "neighbors returns 4 tiles")
	assert_true(result.has(Vector2i(1, 0)), "neighbors includes (1, 0)")
	assert_true(result.has(Vector2i(-1, 0)), "neighbors includes (-1, 0)")
	assert_true(result.has(Vector2i(0, 1)), "neighbors includes (0, 1)")
	assert_true(result.has(Vector2i(0, -1)), "neighbors includes (0, -1)")


func test_neighbors_at_arbitrary_cell() -> void:
	var result: Array[Vector2i] = _grid.neighbors(Vector2i(5, -3))
	assert_true(result.has(Vector2i(6, -3)), "neighbors includes (6, -3)")
	assert_true(result.has(Vector2i(4, -3)), "neighbors includes (4, -3)")
	assert_true(result.has(Vector2i(5, -2)), "neighbors includes (5, -2)")
	assert_true(result.has(Vector2i(5, -4)), "neighbors includes (5, -4)")


func test_is_in_bounds_default_origin_inside() -> void:
	assert_true(_grid.is_in_bounds(Vector2i(0, 0)), "origin is in default bounds")
	assert_true(_grid.is_in_bounds(Vector2i(512, 512)), "center is in default bounds")


func test_is_in_bounds_outside() -> void:
	assert_false(_grid.is_in_bounds(Vector2i(2000, 2000)), "far cell is out of default bounds")
	assert_false(_grid.is_in_bounds(Vector2i(-1, 0)), "negative x is out of bounds")
	assert_false(_grid.is_in_bounds(Vector2i(0, -1)), "negative y is out of bounds")


func test_is_in_bounds_custom_rect() -> void:
	_grid.bounds = Rect2i(10, 10, 5, 5)
	assert_true(_grid.is_in_bounds(Vector2i(10, 10)), "top-left corner in bounds")
	assert_true(_grid.is_in_bounds(Vector2i(14, 14)), "bottom-right corner in bounds")
	assert_false(_grid.is_in_bounds(Vector2i(15, 14)), "just outside right edge")
	assert_false(_grid.is_in_bounds(Vector2i(9, 10)), "just outside left edge")
