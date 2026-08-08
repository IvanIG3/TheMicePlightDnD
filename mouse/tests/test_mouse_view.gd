extends GutTest


func _make_actor(start_cell: Vector2i = Vector2i.ZERO) -> Dictionary:
	var grid: GridSystem = GridSystem.new()
	var pos: GridPositionComponent = GridPositionComponent.new()
	var actor: Node = Node.new()
	actor.add_child(pos)
	pos.grid = grid
	pos.set_cell(start_cell)
	add_child_autofree(actor)
	return {"grid": grid, "pos": pos, "actor": actor}


func test_subscribe_connects_to_cell_changed() -> void:
	var s: Dictionary = _make_actor()
	var view: MouseView = MouseView.new()
	view.initialize(s.actor)
	assert_true(s.pos.cell_changed.is_connected(view._on_cell_changed), "view connected to cell_changed")


func test_replay_positions_sprite_at_current_cell() -> void:
	var s: Dictionary = _make_actor(Vector2i(3, 5))
	var sprite: Sprite2D = Sprite2D.new()
	add_child_autofree(sprite)
	var view: MouseView = MouseView.new()
	view.sprite = sprite
	view.initialize(s.actor)
	assert_eq(sprite.position, Vector2(3 * 64, 5 * 64), "sprite positioned at (192, 320)")


func test_cell_changed_updates_sprite_position() -> void:
	var s: Dictionary = _make_actor()
	var sprite: Sprite2D = Sprite2D.new()
	add_child_autofree(sprite)
	var view: MouseView = MouseView.new()
	view.sprite = sprite
	view.initialize(s.actor)
	s.pos.set_cell(Vector2i(2, 1))
	assert_eq(sprite.position, Vector2(2 * 64, 1 * 64), "sprite moved to (128, 64)")


func test_no_sprite_does_not_crash_on_cell_change() -> void:
	var s: Dictionary = _make_actor()
	var view: MouseView = MouseView.new()
	view.initialize(s.actor)
	s.pos.set_cell(Vector2i(1, 1))
	assert_true(true, "no crash without sprite")


func test_dispose_disconnects_cell_changed() -> void:
	var s: Dictionary = _make_actor()
	var view: MouseView = MouseView.new()
	view.initialize(s.actor)
	view.dispose()
	assert_false(s.pos.cell_changed.is_connected(view._on_cell_changed), "disconnected after dispose")
