extends GutTest


const AttributeDataScript := preload("res://attribute/attribute_data.gd")
const TestDataScript := preload("res://global/tests/fixtures/test_registry_data.gd")


func _registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/Registry")


func _make_data_with_type_id(type_id: StringName) -> Resource:
	var data: Resource = TestDataScript.new()
	data.type_id = type_id
	return data


func test_autoload_is_registered() -> void:
	var registry := _registry()
	assert_not_null(registry, "Registry autoload not registered. Add [autoload] block to project.godot.")
	if registry != null:
		assert_eq(registry.get_script().resource_path, "res://global/registry.gd", "Registry script path mismatch")


func test_typed_dictionaries_exist() -> void:
	var registry := _registry()
	assert_not_null(registry, "Registry autoload required")
	assert_true(registry.effect_executors is Dictionary, "effect_executors is a Dictionary")
	assert_true(registry.action_executors is Dictionary, "action_executors is a Dictionary")
	assert_true(registry.status_classes is Dictionary, "status_classes is a Dictionary")
	assert_true(registry.data_index is Dictionary, "data_index is a Dictionary")


func test_register_effect_executor() -> void:
	var registry := _registry()
	var script: Script = AttributeDataScript
	registry.register_effect_executor(&"test_effect", script)
	assert_same(registry.effect_executors[&"test_effect"], script, "effect_executor stored under type_id")


func test_register_action_executor() -> void:
	var registry := _registry()
	var script: Script = AttributeDataScript
	registry.register_action_executor(&"test_action", script)
	assert_same(registry.action_executors[&"test_action"], script, "action_executor stored under type_id")


func test_register_status_class() -> void:
	var registry := _registry()
	var script: Script = AttributeDataScript
	registry.register_status_class(&"test_status", script)
	assert_same(registry.status_classes[&"test_status"], script, "status_class stored under id")


func test_create_effect_executor_returns_instance() -> void:
	var registry := _registry()
	registry.register_effect_executor(&"test_create_effect", AttributeDataScript)
	var data := _make_data_with_type_id(&"test_create_effect")
	var executor: RefCounted = registry.create_effect_executor(data)
	assert_not_null(executor, "create_effect_executor returns an instance")
	assert_true(executor.get_script() == AttributeDataScript, "executor is instance of registered Script")


func test_create_action_executor_returns_instance() -> void:
	var registry := _registry()
	registry.register_action_executor(&"test_create_action", AttributeDataScript)
	var data := _make_data_with_type_id(&"test_create_action")
	var executor: RefCounted = registry.create_action_executor(data)
	assert_not_null(executor, "create_action_executor returns an instance")
	assert_true(executor.get_script() == AttributeDataScript, "executor is instance of registered Script")


func test_index_data_populates_by_id() -> void:
	var registry := _registry()
	var data: Resource = AttributeDataScript.new()
	data.id = &"test_index_data_id"
	registry.index_data(data)
	assert_same(registry.data_index[&"test_index_data_id"], data, "indexed under resource id")


func test_index_data_skips_empty_id() -> void:
	var registry := _registry()
	var data: Resource = AttributeDataScript.new()
	data.id = &""
	registry.index_data(data)
	assert_false(registry.data_index.has(&""), "empty id is not indexed")


func test_get_data_finds_indexed_resource() -> void:
	var registry := _registry()
	var data: Resource = AttributeDataScript.new()
	data.id = &"test_get_data_id"
	registry.index_data(data)
	var result: Resource = registry.get_data(&"test_get_data_id")
	assert_same(result, data, "get_data returns the indexed resource")


func test_get_data_returns_null_for_unknown() -> void:
	var registry := _registry()
	var result: Resource = registry.get_data(&"nope_not_there")
	assert_null(result, "unknown id returns null")


func test_walker_indexes_attribute_data_tres() -> void:
	var registry := _registry()
	for attr_id in AttributeIds.ALL:
		var resource: Resource = registry.get_data(attr_id)
		assert_not_null(resource, "walker indexed resource for id=%s" % attr_id)
		assert_eq(resource.id, attr_id, "indexed resource has matching id")


func test_walker_indexes_all_theme_resources() -> void:
	var registry := _registry()
	registry.data_index.clear()
	registry._scan_themes()
	var expected_count: int = AttributeIds.ALL.size() + 3
	assert_eq(registry.data_index.size(), expected_count, "walker indexed all theme resources (6 attribute + 3 effect)")


func test_walker_skips_tests_subdir() -> void:
	var registry := _registry()
	var fixture_id: StringName = &"walker_skip_fixture"
	assert_false(registry.data_index.has(fixture_id), "walker does not index files in tests/ subdirs (fixture at attribute/tests/fixtures/)")
