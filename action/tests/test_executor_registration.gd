extends GutTest


func _registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/Registry")


func test_move_executor_is_registered_in_action_executors() -> void:
	var registry := _registry()
	assert_not_null(registry, "Registry autoload required")
	assert_true(registry.action_executors.has(&"move"), "&\"move\" is registered")
	assert_same(registry.action_executors[&"move"], MoveExecutor, "registered script is MoveExecutor")


func test_create_action_executor_returns_move_executor_from_move_data() -> void:
	var registry := _registry()
	var data: MoveData = MoveData.new()
	var executor: RefCounted = registry.create_action_executor(data)
	assert_not_null(executor, "create_action_executor returns an instance")
	assert_true(executor is MoveExecutor, "executor is a MoveExecutor")


func test_play_card_executor_is_registered_in_action_executors() -> void:
	var registry := _registry()
	assert_not_null(registry, "Registry autoload required")
	assert_true(registry.action_executors.has(&"play_card"), "&\"play_card\" is registered")
	assert_same(registry.action_executors[&"play_card"], PlayCardExecutor, "registered script is PlayCardExecutor")


func test_create_action_executor_returns_play_card_executor_from_play_card_data() -> void:
	var registry := _registry()
	var data: Resource = PlayCardData.new()
	var executor: RefCounted = registry.create_action_executor(data)
	assert_not_null(executor, "create_action_executor returns an instance")
	assert_true(executor is PlayCardExecutor, "executor is a PlayCardExecutor")
