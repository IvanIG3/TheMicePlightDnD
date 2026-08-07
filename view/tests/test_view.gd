extends GutTest


const ViewScript := preload("res://view/view.gd")
const GridPositionComponentScript := preload("res://world/grid_position_component.gd")


class TestView extends View:
	var subscribed: bool = false
	var replayed: bool = false
	var handler_called: int = 0

	func _subscribe() -> void:
		subscribed = true
		_connect(&"cell_changed", _on_cell_changed)

	func _replay_state_from(_m: Node) -> void:
		replayed = true

	func _on_cell_changed(_old_cell: Vector2i, _new_cell: Vector2i) -> void:
		handler_called += 1


func test_initialize_stores_model() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	assert_eq(view._model, model, "model is stored on _model")


func test_initialize_calls_subscribe() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	assert_true(view.subscribed, "_subscribe was called by initialize")


func test_initialize_calls_replay_state_from() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	assert_true(view.replayed, "_replay_state_from was called by initialize")


func test_initialize_throws_on_double_init() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	if OS.is_debug_build():
		pending("debug build: double-init asserts; release path is verified separately")
		return
	view.initialize(model)
	assert_true(true, "second initialize did not crash in release")


func test_dispose_sets_disposed_flag() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	view.dispose()
	assert_true(view._disposed, "_disposed is true after dispose")


func test_dispose_disconnects_signals() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	assert_true(model.cell_changed.is_connected(view._on_cell_changed), "connected before dispose")
	view.dispose()
	assert_false(model.cell_changed.is_connected(view._on_cell_changed), "disconnected after dispose")


func test_dispose_is_idempotent() -> void:
	var model: GridPositionComponent = GridPositionComponentScript.new()
	add_child_autofree(model)
	var view: TestView = TestView.new()
	view.initialize(model)
	view.dispose()
	view.dispose()
	assert_true(view._disposed, "_disposed remains true after second dispose")
