extends GutTest


const MoveExecutorScript := preload("res://executor/move_executor.gd")
const MoveDataScript := preload("res://executor/move_data.gd")


func _registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/Registry")


func test_move_executor_is_registered_in_action_executors() -> void:
	var registry := _registry()
	assert_not_null(registry, "Registry autoload required")
	assert_true(registry.action_executors.has(&"move"), "&\"move\" is registered")
	assert_same(registry.action_executors[&"move"], MoveExecutorScript, "registered script is MoveExecutor")


func test_create_action_executor_returns_move_executor_from_move_data() -> void:
	var registry := _registry()
	var data: MoveData = MoveDataScript.new()
	var executor: RefCounted = registry.create_action_executor(data)
	assert_not_null(executor, "create_action_executor returns an instance")
	assert_true(executor is MoveExecutor, "executor is a MoveExecutor")
