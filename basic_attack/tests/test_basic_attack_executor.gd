extends GutTest


var _grid: GridSystem
var _source: Node
var _source_pos: GridPositionComponent
var _source_health: HealthComponent
var _source_faction: FactionComponent
var _source_attr: AttributeComponent
var _target: Node
var _target_pos: GridPositionComponent
var _target_health: HealthComponent
var _target_faction: FactionComponent
var _target_attr: AttributeComponent
var _ctx: ActionContext
var _executor: BasicAttackExecutor
var _basic_data: BasicAttackData
var _rng: Node
var _bus: Node


func before_all() -> void:
	_rng = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	_bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")


func before_each() -> void:
	_grid = GridSystem.new()
	add_child_autofree(_grid)
	var src: Dictionary = _build_source()
	_source = src.actor
	_source_pos = src.pos
	_source_health = src.health
	_source_faction = src.faction
	_source_attr = src.attr
	var tgt: Dictionary = _build_target()
	_target = tgt.actor
	_target_pos = tgt.pos
	_target_health = tgt.health
	_target_faction = tgt.faction
	_target_attr = tgt.attr
	_grid.register_entity(_source, Vector2i(2, 2))
	_grid.register_entity(_target, Vector2i(3, 2))
	_ctx = ActionContext.new()
	_ctx.actor = _source
	_ctx.grid = _grid
	_ctx.rng = _rng
	_ctx.bus = _bus
	_executor = BasicAttackExecutor.new()
	_basic_data = _build_data()
	_executor.data = _basic_data


func _make_set(str_val: int = 10, dex_val: int = 10, con_val: int = 10) -> AttributeSet:
	var set: AttributeSet = AttributeSet.new()
	set.set_score(AttributeIds.ATTR_STR, str_val)
	set.set_score(AttributeIds.ATTR_DEX, dex_val)
	set.set_score(AttributeIds.ATTR_CON, con_val)
	return set


func _build_source(str_val: int = 14) -> Dictionary:
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	attr.base = _make_set(str_val)
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = _grid
	pos.set_cell(Vector2i(2, 2))
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_PREDATOR
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 30
	health.current_hp = 30
	add_child_autofree(actor)
	return {"actor": actor, "pos": pos, "health": health, "faction": faction, "attr": attr}


func _build_target(toughness_val: int = 10) -> Dictionary:
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	attr.base = _make_set()
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = _grid
	pos.set_cell(Vector2i(3, 2))
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_MOUSE
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 50
	health.current_hp = 50
	health.toughness = toughness_val
	add_child_autofree(actor)
	return {"actor": actor, "pos": pos, "health": health, "faction": faction, "attr": attr}


func _build_data(range_val: int = 1) -> BasicAttackData:
	var d: BasicAttackData = BasicAttackData.new()
	d.display_name = "Bite"
	d.range = range_val
	var dice: DiceFormula = DiceFormula.new()
	dice.count = 1
	dice.die = 6
	dice.bonus = 0
	d.damage = dice
	d.target = Vector2i(3, 2)
	return d


func test_basic_attack_data_type_id_is_basic_attack() -> void:
	assert_eq(BasicAttackData.type_id, &"basic_attack", "type_id is &\"basic_attack\"")


func test_basic_attack_executor_registered() -> void:
	var registry: Node = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	assert_true(registry.action_executors.has(BasicAttackData.type_id), "basic_attack executor registered")


func test_validate_returns_true_when_target_in_range_and_enemy() -> void:
	assert_true(_executor.validate(_ctx), "target (3,2) is adjacent predator→mouse")


func test_validate_returns_false_with_null_data() -> void:
	_executor.data = null
	assert_false(_executor.validate(_ctx), "null data → false")


func test_validate_returns_false_when_target_out_of_range() -> void:
	_basic_data.target = Vector2i(5, 2)
	assert_false(_executor.validate(_ctx), "distance 3 > range 1")


func test_validate_returns_false_when_target_tile_empty() -> void:
	_grid.unregister_entity(_target, Vector2i(3, 2))
	assert_false(_executor.validate(_ctx), "empty target tile → false")


func test_validate_returns_false_when_target_is_friendly() -> void:
	_target_faction.faction = FactionIds.FACTION_PREDATOR
	assert_false(_executor.validate(_ctx), "friendly target → false")


func test_validate_returns_false_when_actor_dead() -> void:
	_source_health.current_hp = 0
	assert_false(_executor.validate(_ctx), "dead actor → false")


func test_validate_returns_false_with_non_vector_target() -> void:
	_basic_data.target = null
	assert_false(_executor.validate(_ctx), "null target → false")


func test_validate_returns_false_when_damage_is_null() -> void:
	_basic_data.damage = null
	assert_false(_executor.validate(_ctx), "null damage → false")


func test_validate_returns_false_when_grid_is_null() -> void:
	_ctx.grid = null
	assert_false(_executor.validate(_ctx), "null grid → false")


func test_validate_returns_false_when_position_is_null() -> void:
	# Build a source without a GridPositionComponent; other components intact.
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	attr.base = _make_set(14)
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_PREDATOR
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 30
	health.current_hp = 30
	add_child_autofree(actor)
	var ctx_no_pos: ActionContext = ActionContext.new()
	ctx_no_pos.actor = actor
	ctx_no_pos.grid = _grid
	ctx_no_pos.rng = _rng
	ctx_no_pos.bus = _bus
	assert_false(_executor.validate(ctx_no_pos), "actor without GridPositionComponent → false")


func test_execute_returns_false_when_target_disappeared_between_validate_and_execute() -> void:
	# Re-register the grid occupants to match production: GridPositionComponent
	# is what register_entity receives in real gameplay.
	_grid.unregister_entity(_target, Vector2i(3, 2))
	_grid.register_entity(_target_pos, Vector2i(3, 2))
	assert_true(_executor.validate(_ctx), "validate passes before disappearance")
	# Unregister the target's GridPositionComponent from the grid so the
	# occupant lookup returns null (target "disappeared" from the grid).
	_grid.unregister_entity(_target_pos, Vector2i(3, 2))
	assert_false(_executor.execute(_ctx), "execute returns false when target disappeared")


func test_validate_returns_false_when_faction_missing_on_either_side() -> void:
	# Build a source without a FactionComponent; other components intact.
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	attr.base = _make_set(14)
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = _grid
	pos.set_cell(Vector2i(2, 2))
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 30
	health.current_hp = 30
	add_child_autofree(actor)
	var ctx_no_faction: ActionContext = ActionContext.new()
	ctx_no_faction.actor = actor
	ctx_no_faction.grid = _grid
	ctx_no_faction.rng = _rng
	ctx_no_faction.bus = _bus
	assert_false(_executor.validate(ctx_no_faction), "missing faction on source → false")


# Seed 41: d20=10, source STR=14 (mod +4), target Toughness=10
# attack_roll = 10+4 = 14 >= 10 → hit
# damage 1d6+0: 4 (single die) → amount = 4+4 = 8
func test_execute_hit_deals_damage() -> void:
	_rng.set_seed(41)
	var initial_hp: int = _target_health.current_hp
	_executor.execute(_ctx)
	assert_eq(_target_health.current_hp, initial_hp - 8, "took 8 damage on hit")


# Seed 24: d20=1 → fumble, no damage
func test_execute_fumble_deals_no_damage() -> void:
	_rng.set_seed(24)
	var initial_hp: int = _target_health.current_hp
	_executor.execute(_ctx)
	assert_eq(_target_health.current_hp, initial_hp, "fumble → no damage")


# Seed 57: d20=20 → crit
# crit amount = dice.max_roll() + STR mod = 6 + 4 = 10
func test_execute_crit_deals_max_damage() -> void:
	_rng.set_seed(57)
	var initial_hp: int = _target_health.current_hp
	_executor.execute(_ctx)
	assert_eq(_target_health.current_hp, initial_hp - 10, "took 10 damage on crit")


# Seed 41, STR=10 (mod +0), Toughness=16
# attack_roll = 10+0 = 10 < 16 → miss
func test_execute_misses_when_attack_below_toughness() -> void:
	_source_attr.base.set_score(AttributeIds.ATTR_STR, 10)
	_target_health.toughness = 16
	_rng.set_seed(41)
	var initial_hp: int = _target_health.current_hp
	_executor.execute(_ctx)
	assert_eq(_target_health.current_hp, initial_hp, "miss → no damage")


func test_execute_returns_false_with_null_data() -> void:
	_executor.data = null
	assert_false(_executor.execute(_ctx), "null data → false")


func test_get_affected_tiles_returns_target_cell() -> void:
	var tiles: Array[Vector2i] = _executor.get_affected_tiles(_ctx)
	assert_eq(tiles, [Vector2i(3, 2)] as Array[Vector2i], "single affected tile at target")


func test_get_affected_tiles_empty_with_null_data() -> void:
	_executor.data = null
	var tiles: Array[Vector2i] = _executor.get_affected_tiles(_ctx)
	assert_eq(tiles, [] as Array[Vector2i], "null data → empty")
