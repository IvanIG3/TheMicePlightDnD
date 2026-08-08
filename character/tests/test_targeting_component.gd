extends GutTest


func _make_setup() -> Dictionary:
	var grid: GridSystem = GridSystem.new()
	var pos: GridPositionComponent = GridPositionComponent.new()
	var character: Node = Node.new()
	var targeting: TargetingComponent = TargetingComponent.new()
	character.add_child(grid)
	character.add_child(pos)
	character.add_child(targeting)
	pos.grid = grid
	pos.set_cell(Vector2i(2, 2))
	add_child_autofree(character)
	targeting.grid_ref = targeting.get_path_to(grid)
	targeting._ready()
	return {"grid": grid, "pos": pos, "character": character, "targeting": targeting}


func test_reachable_tiles_range_zero_returns_origin() -> void:
	var s: Dictionary = _make_setup()
	var tiles: Array[Vector2i] = s.targeting.reachable_tiles(0)
	assert_eq(tiles.size(), 1, "range 0 returns just the origin")
	assert_true(tiles.has(Vector2i(2, 2)), "includes the origin (2, 2)")


func test_reachable_tiles_range_one_returns_origin_plus_four_neighbors() -> void:
	var s: Dictionary = _make_setup()
	var tiles: Array[Vector2i] = s.targeting.reachable_tiles(1)
	assert_eq(tiles.size(), 5, "range 1 returns 5 tiles: origin + 4 neighbors")
	assert_true(tiles.has(Vector2i(2, 2)), "origin (2, 2)")
	assert_true(tiles.has(Vector2i(3, 2)), "right (3, 2)")
	assert_true(tiles.has(Vector2i(1, 2)), "left (1, 2)")
	assert_true(tiles.has(Vector2i(2, 3)), "down (2, 3)")
	assert_true(tiles.has(Vector2i(2, 1)), "up (2, 1)")


func test_reachable_tiles_skips_blocked_tiles() -> void:
	var s: Dictionary = _make_setup()
	s.grid.set_blocked(Vector2i(3, 2), true)
	var tiles: Array[Vector2i] = s.targeting.reachable_tiles(1)
	assert_false(tiles.has(Vector2i(3, 2)), "blocked (3, 2) is not reachable")
	assert_eq(tiles.size(), 4, "one fewer tile because of the block")


func test_reachable_tiles_range_two_includes_ring_two() -> void:
	var s: Dictionary = _make_setup()
	var tiles: Array[Vector2i] = s.targeting.reachable_tiles(2)
	assert_eq(tiles.size(), 13, "open range 2 = 1 + 4 + 8 = 13 tiles")
	assert_true(tiles.has(Vector2i(4, 2)), "ring 2 right (4, 2)")
	assert_true(tiles.has(Vector2i(3, 3)), "ring 2 corner (3, 3)")


func test_reachable_tiles_blocked_wall_cuts_off_far_side() -> void:
	var s: Dictionary = _make_setup()
	s.grid.set_blocked(Vector2i(3, 2), true)
	s.grid.set_blocked(Vector2i(2, 3), true)
	var tiles: Array[Vector2i] = s.targeting.reachable_tiles(2)
	assert_false(tiles.has(Vector2i(4, 2)), "right of the wall is unreachable")
	assert_false(tiles.has(Vector2i(2, 4)), "below the wall is unreachable")


func test_area_tiles_single() -> void:
	var s: Dictionary = _make_setup()
	var tiles: Array[Vector2i] = s.targeting.area_tiles(Vector2i(5, 5), &"single", 1)
	assert_eq(tiles.size(), 1, "single returns 1 tile")
	assert_true(tiles.has(Vector2i(5, 5)), "single is the center")


func test_area_tiles_cross_size_one() -> void:
	var s: Dictionary = _make_setup()
	var tiles: Array[Vector2i] = s.targeting.area_tiles(Vector2i(5, 5), &"cross", 1)
	assert_eq(tiles.size(), 5, "cross size 1 returns 5 tiles")
	assert_true(tiles.has(Vector2i(5, 5)), "center (5, 5)")
	assert_true(tiles.has(Vector2i(6, 5)), "right (6, 5)")
	assert_true(tiles.has(Vector2i(4, 5)), "left (4, 5)")
	assert_true(tiles.has(Vector2i(5, 6)), "down (5, 6)")
	assert_true(tiles.has(Vector2i(5, 4)), "up (5, 4)")


func test_area_tiles_cross_size_two() -> void:
	var s: Dictionary = _make_setup()
	var tiles: Array[Vector2i] = s.targeting.area_tiles(Vector2i(0, 0), &"cross", 2)
	assert_eq(tiles.size(), 9, "cross size 2 = 1 + 4 + 4 = 9 tiles")
	assert_true(tiles.has(Vector2i(0, 0)), "center")
	assert_true(tiles.has(Vector2i(2, 0)), "far right")
	assert_true(tiles.has(Vector2i(-2, 0)), "far left")
	assert_true(tiles.has(Vector2i(0, 2)), "far down")
	assert_true(tiles.has(Vector2i(0, -2)), "far up")


func test_line_of_sight_clear_line() -> void:
	var s: Dictionary = _make_setup()
	assert_true(s.targeting.line_of_sight(Vector2i(0, 0), Vector2i(3, 0)), "clear horizontal line")
	assert_true(s.targeting.line_of_sight(Vector2i(0, 0), Vector2i(3, 3)), "clear diagonal")
	assert_true(s.targeting.line_of_sight(Vector2i(0, 0), Vector2i(0, 3)), "clear vertical line")


func test_line_of_sight_blocked_tile_in_path() -> void:
	var s: Dictionary = _make_setup()
	s.grid.set_blocked(Vector2i(1, 0), true)
	assert_false(s.targeting.line_of_sight(Vector2i(0, 0), Vector2i(3, 0)), "blocked (1, 0) blocks horizontal sight")


func test_line_of_sight_endpoint_blocked_still_has_sight() -> void:
	var s: Dictionary = _make_setup()
	s.grid.set_blocked(Vector2i(3, 0), true)
	assert_true(s.targeting.line_of_sight(Vector2i(0, 0), Vector2i(3, 0)), "blocked endpoint does not block sight TO the endpoint")


func test_line_of_sight_same_cell() -> void:
	var s: Dictionary = _make_setup()
	assert_true(s.targeting.line_of_sight(Vector2i(2, 2), Vector2i(2, 2)), "same cell has sight to itself")
