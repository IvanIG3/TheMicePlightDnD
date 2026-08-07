extends GutTest


const EffectContextScript := preload("res://effect/effect_context.gd")
const EffectDataScript := preload("res://effect/effect_data.gd")
const DamageEffectDataScript := preload("res://effect/damage_effect_data.gd")
const HealEffectDataScript := preload("res://effect/heal_effect_data.gd")
const CompositeEffectDataScript := preload("res://effect/composite_effect_data.gd")
const DiceFormulaScript := preload("res://dice/dice_formula.gd")
const HealthComponentScript := preload("res://health/health_component.gd")
const AttributeComponentScript := preload("res://attribute/attribute_component.gd")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")
const CompositeExecutorPath := "res://effect/composite_executor.gd"
const DamageExecutorPath := "res://effect/damage_executor.gd"
const HealExecutorPath := "res://effect/heal_executor.gd"


var _registry: Node
var _bus: Node
var _rng_node: Node
var _source: Node
var _target: Node
var _ctx: EffectContext
var _executor: RefCounted
var _data: Resource
var _health: HealthComponent
var _saved_damage: Variant
var _saved_heal: Variant
var _saved_composite: Variant


func before_all() -> void:
	_registry = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	assert_not_null(_registry, "Registry autoload must exist")


func before_each() -> void:
	_saved_damage = _registry.effect_executors.get(&"damage", null)
	_saved_heal = _registry.effect_executors.get(&"heal", null)
	_saved_composite = _registry.effect_executors.get(&"composite", null)
	var dmg_script: GDScript = load(DamageExecutorPath)
	assert_not_null(dmg_script, "DamageExecutor script must exist at " + DamageExecutorPath)
	var heal_script: GDScript = load(HealExecutorPath)
	assert_not_null(heal_script, "HealExecutor script must exist at " + HealExecutorPath)
	var comp_script: GDScript = load(CompositeExecutorPath)
	assert_not_null(comp_script, "CompositeExecutor script must exist at " + CompositeExecutorPath)
	_registry.register_effect_executor(&"damage", dmg_script)
	_registry.register_effect_executor(&"heal", heal_script)
	_registry.register_effect_executor(&"composite", comp_script)
	_bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	_rng_node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")


func after_each() -> void:
	_registry.effect_executors.erase(&"damage")
	_registry.effect_executors.erase(&"heal")
	_registry.effect_executors.erase(&"composite")
	if _saved_damage != null:
		_registry.effect_executors[&"damage"] = _saved_damage
	if _saved_heal != null:
		_registry.effect_executors[&"heal"] = _saved_heal
	if _saved_composite != null:
		_registry.effect_executors[&"composite"] = _saved_composite


func _make_set(strength_val: int = 10, dexterity_val: int = 10, constitution_val: int = 10, intelligence_val: int = 10, wisdom_val: int = 10, charisma_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, strength_val)
	attribute_set.set_score(AttributeIds.ATTR_DEX, dexterity_val)
	attribute_set.set_score(AttributeIds.ATTR_CON, constitution_val)
	attribute_set.set_score(AttributeIds.ATTR_INT, intelligence_val)
	attribute_set.set_score(AttributeIds.ATTR_WIS, wisdom_val)
	attribute_set.set_score(AttributeIds.ATTR_CHA, charisma_val)
	return attribute_set


func _build_source(str_val: int) -> Node:
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponentScript.new()
	actor.add_child(attr)
	attr.base = _make_set(str_val)
	add_child_autofree(actor)
	return actor


func _build_target(toughness_val: int) -> Node:
	var target_node: Node = Node.new()
	_health = HealthComponentScript.new()
	target_node.add_child(_health)
	_health.toughness = toughness_val
	_health.max_hp = 100
	_health.current_hp = 100
	add_child_autofree(target_node)
	return target_node


func _build_damage_data(count: int, die: int, bonus: int, scaling: StringName) -> EffectData:
	var d: DamageEffectData = DamageEffectDataScript.new()
	var dice: DiceFormula = DiceFormulaScript.new()
	dice.count = count
	dice.die = die
	dice.bonus = bonus
	d.dice = dice
	d.scaling_attribute = scaling
	d.damage_type = &"physical"
	d.resistance_attribute = &""
	d.resistance_value = 0
	return d


func _build_heal_data(count: int, die: int, bonus: int) -> EffectData:
	var d: HealEffectData = HealEffectDataScript.new()
	var dice: DiceFormula = DiceFormulaScript.new()
	dice.count = count
	dice.die = die
	dice.bonus = bonus
	d.dice = dice
	return d


func _build_composite(inner_effects: Array[EffectData]) -> EffectData:
	var c: CompositeEffectData = CompositeEffectDataScript.new()
	c.effects = inner_effects
	c.mode = &"sequence"
	return c


func _build_composite_executor() -> RefCounted:
	var script: GDScript = load(CompositeExecutorPath)
	assert_not_null(script, "CompositeExecutor script must exist at " + CompositeExecutorPath)
	var ex: RefCounted = script.new()
	ex.data = _data
	return ex


func _build_context(seed_value: int) -> void:
	_rng_node.set_seed(seed_value)
	_ctx = EffectContextScript.new()
	_ctx.source = _source
	_ctx.target = _target
	_ctx.rng = _rng_node
	_ctx.bus = _bus
	_executor = _build_composite_executor()


# Empty composite: no inner effects, executor is a silent no-op.
func test_empty_composite_emits_no_signals() -> void:
	_data = _build_composite([] as Array[EffectData])
	_source = _build_source(10)
	_target = _build_target(10)
	_build_context(0)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emit_count(_bus, "damage_applied", 0, "no damage_applied emitted")
	assert_signal_emit_count(_bus, "heal_applied", 0, "no heal_applied emitted")
	assert_eq(_health.current_hp, 100, "HP unchanged on empty composite")


# Seed 2: d20_1=11, 2d6_1=5, d20_2=17, 2d6_2=7
# Source STR=20 (mod +10), target Toughness=5
# damage_1 = 5 + 10 = 15, damage_2 = 7 + 10 = 17, total = 32, HP = 68
func test_composite_of_two_damages_emits_both_signals_and_applies_total() -> void:
	var d1: EffectData = _build_damage_data(2, 6, 0, AttributeIds.ATTR_STR)
	var d2: EffectData = _build_damage_data(2, 6, 0, AttributeIds.ATTR_STR)
	_data = _build_composite([d1, d2])
	_source = _build_source(20)
	_target = _build_target(5)
	_build_context(2)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emit_count(_bus, "damage_applied", 2, "two damage_applied emitted")
	assert_signal_emitted(_bus, "damage_applied", [15, _source, _target, false])
	assert_signal_emitted(_bus, "damage_applied", [17, _source, _target, false])
	assert_eq(_health.current_hp, 68, "HP = 100 - 15 - 17 = 68")


# Seed 5: d20=2, 2d6=8, heal_1d4=3
# Source STR=20 (mod +10), target Toughness=5
# damage = 8 + 10 = 18 (HP 100 -> 82), heal = 3 (HP 82 -> 85)
func test_composite_of_damage_and_heal_applies_net_effect() -> void:
	var d1: EffectData = _build_damage_data(2, 6, 0, AttributeIds.ATTR_STR)
	var h1: EffectData = _build_heal_data(1, 4, 0)
	_data = _build_composite([d1, h1])
	_source = _build_source(20)
	_target = _build_target(5)
	_build_context(5)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emit_count(_bus, "damage_applied", 1, "one damage_applied emitted")
	assert_signal_emit_count(_bus, "heal_applied", 1, "one heal_applied emitted")
	assert_signal_emitted(_bus, "damage_applied", [18, _source, _target, false])
	assert_signal_emitted(_bus, "heal_applied", [3, _target])
	assert_eq(_health.current_hp, 85, "HP = 100 - 18 + 3 = 85")


# Seed 2: inner damage d20=11, 2d6=5 → damage = 15
# Outer composite wraps an inner composite which wraps a damage.
# The recursion should produce exactly one damage_applied emission.
func test_nested_composite_invokes_inner_composite_executor() -> void:
	var inner_damage: EffectData = _build_damage_data(2, 6, 0, AttributeIds.ATTR_STR)
	var inner_composite: EffectData = _build_composite([inner_damage])
	_data = _build_composite([inner_composite])
	_source = _build_source(20)
	_target = _build_target(5)
	_build_context(2)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emit_count(_bus, "damage_applied", 1, "exactly one damage_applied from nested composite")
	assert_signal_emitted(_bus, "damage_applied", [15, _source, _target, false])
	assert_eq(_health.current_hp, 85, "HP = 100 - 15 = 85")


# Inner with type_id that has no registered executor must crash the executor via
# the Registry.create_effect_executor assert (the contract is enforced in registry.gd).
# Marked pending to avoid halting the test runner in debug builds; the assert in
# registry.gd:48 is the contract that the executor relies on.
func test_composite_with_unknown_inner_effect_triggers_registry_assert() -> void:
	var inner: EffectData = EffectDataScript.new()
	inner.type_id = &"unknown_thing"
	assert_false(_registry.effect_executors.has(&"unknown_thing"),
		"unknown_thing must not be registered (precondition for the assert)")
	pending("debug build: Registry.create_effect_executor asserts on unknown type_id")
