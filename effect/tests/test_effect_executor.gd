extends GutTest


func test_data_field_is_assignable() -> void:
	var executor: RefCounted = EffectExecutor.new()
	var data: Resource = Resource.new()
	executor.data = data
	assert_eq(executor.data, data, "data field is stored")


func test_default_data_is_null() -> void:
	var executor: RefCounted = EffectExecutor.new()
	assert_null(executor.data, "default data is null")


func test_base_execute_does_not_crash() -> void:
	var executor: RefCounted = EffectExecutor.new()
	var ctx: EffectContext = EffectContext.new()
	executor.data = Resource.new()
	executor.execute(ctx)
	assert_true(true, "base execute completes without side effects")


func test_subclass_execute_is_called() -> void:
	var SubExecutorScript: GDScript = GDScript.new()
	SubExecutorScript.source_code = """
extends "res://effect/effect_executor.gd"
var called: bool = false
func execute(_ctx) -> void:
	called = true
"""
	var reload_err: int = SubExecutorScript.reload()
	assert_eq(reload_err, OK, "subclass script compiled")
	var executor: RefCounted = SubExecutorScript.new()
	var ctx: EffectContext = EffectContext.new()
	executor.execute(ctx)
	assert_true(executor.called, "subclass execute was called")
