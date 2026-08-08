extends GutTest


var _registry: Node
var _bus: Node
var _rng_node: Node
var _source: Node
var _target: Node
var _ctx: EffectContext
var _health: HealthComponent


func before_all() -> void:
	_registry = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	assert_not_null(_registry, "Registry autoload must exist")
	_bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	_rng_node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")


func _make_set(strength_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSet.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, strength_val)
	return attribute_set


func _build_source(str_val: int) -> Node:
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	attr.base = _make_set(str_val)
	add_child_autofree(actor)
	return actor


func _build_target(toughness_val: int) -> Node:
	var target_node: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	target_node.add_child(attr)
	attr.base = _make_set(10)
	_health = HealthComponent.new()
	target_node.add_child(_health)
	_health.toughness = toughness_val
	_health.max_hp = 100
	_health.current_hp = 100
	add_child_autofree(target_node)
	return target_node


func test_damage_executor_registered() -> void:
	assert_true(_registry.effect_executors.has(&"damage"), "damage executor registered in Registry")


func test_heal_executor_registered() -> void:
	assert_true(_registry.effect_executors.has(&"heal"), "heal executor registered in Registry")


func test_composite_executor_registered() -> void:
	assert_true(_registry.effect_executors.has(&"composite"), "composite executor registered in Registry")


func test_scratch_bite_data_indexed_as_damage() -> void:
	var data: Resource = _registry.get_data(&"scratch_bite")
	assert_not_null(data, "scratch_bite is indexed by Registry")
	var typed: DamageEffectData = data as DamageEffectData
	assert_not_null(typed, "scratch_bite is a DamageEffectData")
	assert_eq(typed.scaling_attribute, &"strength", "scaling_attribute from .tres")
	assert_eq(typed.damage_type, &"physical", "damage_type from .tres")


func test_calming_salve_data_indexed_as_heal() -> void:
	var data: Resource = _registry.get_data(&"calming_salve")
	assert_not_null(data, "calming_salve is indexed by Registry")
	var typed: HealEffectData = data as HealEffectData
	assert_not_null(typed, "calming_salve is a HealEffectData")


func test_combo_strike_data_indexed_as_composite_with_two_inner_effects() -> void:
	var data: Resource = _registry.get_data(&"combo_strike")
	assert_not_null(data, "combo_strike is indexed by Registry")
	var typed: CompositeEffectData = data as CompositeEffectData
	assert_not_null(typed, "combo_strike is a CompositeEffectData")
	assert_eq(typed.effects.size(), 2, "combo_strike has 2 inner effects")
	assert_true(typed.effects[0] is DamageEffectData, "inner effect 0 is DamageEffectData")
	assert_true(typed.effects[1] is DamageEffectData, "inner effect 1 is DamageEffectData")
	assert_eq(typed.mode, &"sequence", "mode is sequence from .tres")


# Seed 57: first d20=20 -> crit, no dice rolled, no defend roll.
# scratch_bite: 1d6+0, scaling=strength.
# crit amount = max_roll() + mod = 6 + 4 = 10.
func test_scratch_bite_executes_via_registry_end_to_end() -> void:
	var data: Resource = _registry.get_data(&"scratch_bite")
	assert_not_null(data, "scratch_bite is indexed by Registry")
	_source = _build_source(14)
	_target = _build_target(10)
	_rng_node.set_seed(57)
	_ctx = EffectContext.new()
	_ctx.source = _source
	_ctx.target = _target
	_ctx.rng = _rng_node
	_ctx.bus = _bus
	var executor: RefCounted = _registry.create_effect_executor(data)
	executor.data = data
	watch_signals(_bus)
	executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [10, _source, _target, true])
	assert_eq(_health.current_hp, 90, "health = 100 - 10 = 90 after crit")


# Seed 24: first d20=1 -> fumble. Emits damage_applied(0) regardless of modifiers/toughness.
# Triangulates the wiring with a different code path (fumble vs crit).
func test_scratch_bite_fumble_via_registry_emits_zero_damage() -> void:
	var data: Resource = _registry.get_data(&"scratch_bite")
	assert_not_null(data, "scratch_bite is indexed by Registry")
	_source = _build_source(20)
	_target = _build_target(0)
	_rng_node.set_seed(24)
	_ctx = EffectContext.new()
	_ctx.source = _source
	_ctx.target = _target
	_ctx.rng = _rng_node
	_ctx.bus = _bus
	var executor: RefCounted = _registry.create_effect_executor(data)
	executor.data = data
	watch_signals(_bus)
	executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [0, _source, _target, false])
	assert_eq(_health.current_hp, 100, "health unchanged on fumble")
