extends GutTest


const EffectContextScript := preload("res://effect/effect_context.gd")
const DamageEffectDataScript := preload("res://effect/damage_effect_data.gd")
const DiceFormulaScript := preload("res://dice/dice_formula.gd")
const HealthComponentScript := preload("res://health/health_component.gd")
const AttributeComponentScript := preload("res://attribute/attribute_component.gd")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")
const DamageExecutorPath := "res://effect/damage_executor.gd"


var _source: Node
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


func _make_set(strength_val: int = 10, dexterity_val: int = 10, constitution_val: int = 10, intelligence_val: int = 10, wisdom_val: int = 10, charisma_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, strength_val)
	attribute_set.set_score(AttributeIds.ATTR_DEX, dexterity_val)
	attribute_set.set_score(AttributeIds.ATTR_CON, constitution_val)
	attribute_set.set_score(AttributeIds.ATTR_INT, intelligence_val)
	attribute_set.set_score(AttributeIds.ATTR_WIS, wisdom_val)
	attribute_set.set_score(AttributeIds.ATTR_CHA, charisma_val)
	return attribute_set


func _build_source(str_val: int, int_val: int = 10) -> Node:
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponentScript.new()
	actor.add_child(attr)
	attr.base = _make_set(str_val, 10, 10, int_val)
	add_child_autofree(actor)
	return actor


func _build_target(dex_val: int, toughness_val: int) -> Node:
	var target_node: Node = Node.new()
	var attr: AttributeComponent = AttributeComponentScript.new()
	target_node.add_child(attr)
	attr.base = _make_set(10, dex_val)
	_health = HealthComponentScript.new()
	target_node.add_child(_health)
	_health.toughness = toughness_val
	_health.max_hp = 100
	_health.current_hp = 100
	add_child_autofree(target_node)
	return target_node


func _build_data(count: int, die: int, bonus: int, scaling: StringName, damage_type: StringName, resistance_attr: StringName = &"", resistance_value: int = 0) -> Resource:
	var d: Resource = DamageEffectDataScript.new()
	var dice: DiceFormula = DiceFormulaScript.new()
	dice.count = count
	dice.die = die
	dice.bonus = bonus
	d.dice = dice
	d.scaling_attribute = scaling
	d.damage_type = damage_type
	d.resistance_attribute = resistance_attr
	d.resistance_value = resistance_value
	return d


func _build_context(seed_value: int) -> void:
	_rng_node.set_seed(seed_value)
	_ctx = EffectContextScript.new()
	_ctx.source = _source
	_ctx.target = _target
	_ctx.rng = _rng_node
	_ctx.bus = _bus
	var executor_script: GDScript = load(DamageExecutorPath)
	assert_not_null(executor_script, "DamageExecutor script must exist at " + DamageExecutorPath)
	_executor = executor_script.new()
	_executor.data = _data


# Seed 41: first d20=10 → attack_roll=14, second/third are 2d6+3=10 (irrelevant for miss)
func test_physical_toughness_miss_emits_zero_damage() -> void:
	# source STR=14 (mod +4), target Toughness=16, raw d20=10
	# attack_roll = 10+4 = 14 < 16 → miss
	_data = _build_data(2, 6, 3, AttributeIds.ATTR_STR, &"physical")
	_source = _build_source(14)
	_target = _build_target(10, 16)
	_build_context(41)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [0, _source, _target, false])
	assert_eq(_health.current_hp, 100, "health unchanged on miss")


# Seed 84: first d20=10, dice 2d6+3=10, defend d20=5
# amount = 10+2 = 12, resist_roll = 5+6 = 11 < 12 → no halve
func test_special_resistance_no_halve_when_save_below_dc() -> void:
	# source INT=12 (mod +2), target DEX=16 (mod +6), resistance_value=12
	_data = _build_data(2, 6, 3, AttributeIds.ATTR_INT, &"special", AttributeIds.ATTR_DEX, 12)
	_source = _build_source(10, 12)
	_target = _build_target(16, 10)
	_build_context(84)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [12, _source, _target, false])
	assert_eq(_health.current_hp, 88, "health = 100 - 12 = 88")


# Seed 191: first d20=10, dice 2d6+3=7, defend d20=12
# amount = 7+2 = 9, resist_roll = 12+6 = 18 >= 12 → halve
# GDD §Special attack: "damage is halved" → floor(amount/2.0) = 4
func test_special_resistance_halve_when_save_meets_dc() -> void:
	_data = _build_data(2, 6, 3, AttributeIds.ATTR_INT, &"special", AttributeIds.ATTR_DEX, 12)
	_source = _build_source(10, 12)
	_target = _build_target(16, 10)
	_build_context(191)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [4, _source, _target, false])
	assert_eq(_health.current_hp, 96, "health = 100 - 4 = 96")


# Seed 57: first d20=20 → crit, no dice rolled, no resistance check
# amount = 19+2 = 21 (max_roll + INT mod), no halve despite the resistance being set
# Pins the GDD "auto-hits" reading: a Nat 20 on a special attack bypasses the defender's resistance roll.
func test_nat_twenty_crit_on_special_skips_resistance() -> void:
	_data = _build_data(2, 8, 3, AttributeIds.ATTR_INT, &"special", AttributeIds.ATTR_DEX, 12)
	_source = _build_source(10, 12)
	_target = _build_target(16, 10)
	_build_context(57)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [21, _source, _target, true])
	assert_eq(_health.current_hp, 79, "health = 100 - 21 = 79")


# Seed 57: first d20=20 → crit, no dice rolled, no defend
# amount = 19+6 = 25
func test_nat_twenty_crit_emits_max_damage_and_crit_flag() -> void:
	# source STR=16 (mod +6), dice 2d8+3 (max=19), raw d20=20
	_data = _build_data(2, 8, 3, AttributeIds.ATTR_STR, &"physical")
	_source = _build_source(16)
	_target = _build_target(10, 10)
	_build_context(57)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [25, _source, _target, true])
	assert_eq(_health.current_hp, 75, "health = 100 - 25 = 75")


# Seed 24: first d20=1 → fumble
func test_nat_one_fumble_emits_zero_damage() -> void:
	# raw d20=1 → fumble, no damage regardless of modifiers/Toughness
	_data = _build_data(2, 6, 3, AttributeIds.ATTR_STR, &"physical")
	_source = _build_source(20)
	_target = _build_target(10, 0)
	_build_context(24)
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "damage_applied", [0, _source, _target, false])
	assert_eq(_health.current_hp, 100, "health unchanged on fumble")
