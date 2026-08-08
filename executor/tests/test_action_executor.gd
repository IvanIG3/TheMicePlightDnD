extends GutTest


func test_default_validate_returns_true() -> void:
	var executor: ActionExecutor = ActionExecutor.new()
	var ctx: ActionContext = ActionContext.new()
	assert_true(executor.validate(ctx), "default validate returns true")


func test_default_execute_returns_false() -> void:
	var executor: ActionExecutor = ActionExecutor.new()
	var ctx: ActionContext = ActionContext.new()
	assert_false(executor.execute(ctx), "default execute returns false (subclass must override)")


func test_default_get_affected_tiles_returns_empty() -> void:
	var executor: ActionExecutor = ActionExecutor.new()
	var ctx: ActionContext = ActionContext.new()
	var tiles: Array[Vector2i] = executor.get_affected_tiles(ctx)
	assert_eq(tiles.size(), 0, "default affected tiles is empty")


func test_data_field_is_assignable() -> void:
	var executor: ActionExecutor = ActionExecutor.new()
	var data: Resource = Resource.new()
	executor.data = data
	assert_eq(executor.data, data, "data field is stored")
