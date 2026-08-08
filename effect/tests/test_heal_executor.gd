extends GutTest


var _target: Node
var _ctx: EffectContext
var _executor: RefCounted
var _data: Resource
var _health: HealthComponent
var _bus: Node
var _rng_node: Node


func before_each() -> void:
	_bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	_rng_node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")


func _build_target(current_hp: int) -> Node:
	var target_node: Node = Node.new()
	_health = HealthComponent.new()
	_health.max_hp = 100
	_health.current_hp = current_hp
	target_node.add_child(_health)
	add_child_autofree(target_node)
	return target_node


func _build_data(count: int, die: int, bonus: int) -> Resource:
	var d: Resource = HealEffectData.new()
	var dice: DiceFormula = DiceFormula.new()
	dice.count = count
	dice.die = die
	dice.bonus = bonus
	d.dice = dice
	return d


func _build_executor() -> RefCounted:
	var ex: RefCounted = HealExecutor.new()
	ex.data = _data
	return ex


func _build_context(seed_value: int) -> void:
	_rng_node.set_seed(seed_value)
	_ctx = EffectContext.new()
	_ctx.target = _target
	_ctx.rng = _rng_node
	_ctx.bus = _bus
	_executor = _build_executor()


# Seed 27: 2d4+2 = 4 (r1=1, r2=1)
# Target 50/100: heal 4 → current_hp = 54
func test_basic_heal_restores_hp_by_rolled_amount() -> void:
	_data = _build_data(2, 4, 2)
	_target = _build_target(50)
	_build_context(27)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "heal_applied", [4, _target])
	assert_eq(_health.current_hp, 54, "current_hp = 50 + 4 = 54")


# Seed 119: 3d6+2 = 20 (r1=6, r2=6, r3=6)
# Target 90/100: rolled 20, only 10 actually healed (capped at max)
func test_overheal_caps_at_max_hp() -> void:
	_data = _build_data(3, 6, 2)
	_target = _build_target(90)
	_build_context(119)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "heal_applied", [10, _target])
	assert_eq(_health.current_hp, 100, "current_hp capped at 100")


# Seed 3: 2d4+2 = 6 (r1=1, r2=3)
# Target 0/100: dead targets cannot be healed. apply_heal returns 0; HP stays 0.
func test_heal_on_dead_target_is_no_op() -> void:
	_data = _build_data(2, 4, 2)
	_target = _build_target(0)
	_build_context(3)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "heal_applied", [0, _target])
	assert_eq(_health.current_hp, 0, "current_hp stays 0 (dead targets cannot be healed)")


# No target: actual_healed=0, emit heal_applied(0, null)
func test_heal_with_null_target_emits_zero() -> void:
	_data = _build_data(2, 4, 2)
	_target = null
	_build_context(0)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "heal_applied", [0, null])
