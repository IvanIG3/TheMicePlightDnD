extends GutTest


const PlayCardExecutorPath := "res://executor/play_card_executor.gd"
const PlayCardDataPath := "res://executor/play_card_data.gd"
const CardDataPath := "res://card/card_data.gd"
const DamageEffectDataPath := "res://effect/damage_effect_data.gd"
const HealEffectDataPath := "res://effect/heal_effect_data.gd"
const DiceFormulaPath := "res://dice/dice_formula.gd"
const DeckComponentPath := "res://card/deck_component.gd"
const MemorizationComponentPath := "res://card/memorization_component.gd"
const StatsComponentPath := "res://stats/stats_component.gd"
const AttributeComponentPath := "res://attribute/attribute_component.gd"
const AttributeSetPath := "res://attribute/attribute_set.gd"
const ActionBudgetComponentPath := "res://character/action_budget_component.gd"
const HealthComponentPath := "res://health/health_component.gd"
const FactionComponentPath := "res://character/faction_component.gd"
const GridPositionComponentPath := "res://world/grid_position_component.gd"
const GridSystemPath := "res://world/grid_system.gd"
const ActionContextPath := "res://executor/action_context.gd"


var _executor_script: GDScript
var _data_script: GDScript
var _executor: RefCounted
var _data: Resource
var _actor: Node
var _ctx: ActionContext
var _deck: Node
var _health_target: HealthComponent
var _bus: Node
var _rng_node: Node


func before_each() -> void:
	_executor_script = load(PlayCardExecutorPath)
	assert_not_null(_executor_script, "PlayCardExecutor script must exist at " + PlayCardExecutorPath)
	_data_script = load(PlayCardDataPath)
	assert_not_null(_data_script, "PlayCardData script must exist at " + PlayCardDataPath)
	_data = _data_script.new()
	_executor = _executor_script.new()
	_bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	_rng_node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")


func _build_actor_with_components(card: Resource = null, hp: int = 100, energy: int = 5) -> Node:
	var actor: Node = Node.new()
	var attr: AttributeComponent = AttributeComponentScript.new()
	var attrs: AttributeSet = AttributeSetScript.new()
	attrs.set_score(AttributeIds.ATTR_STR, 10)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	actor.add_child(attr)
	var stats: StatsComponent = StatsComponentPath.new()
	actor.add_child(stats)
	stats.init(energy, attr)
	stats.recompute_max_energy()
	stats.current_energy = stats.max_energy
	var budget: ActionBudgetComponent = ActionBudgetComponentPath.new()
	actor.add_child(budget)
	var faction: FactionComponent = FactionComponentPath.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_MOUSE
	var mem_script: GDScript = load(MemorizationComponentPath)
	var mem: MemorizationComponent = mem_script.new()
	actor.add_child(mem)
	var deck_script: GDScript = load(DeckComponentPath)
	_deck = deck_script.new()
	actor.add_child(_deck)
	_deck.bind_memorization(mem)
	if card != null:
		_deck.hand = ([card] as Array[CardData])
	add_child_autofree(actor)
	_actor = actor
	return actor


func _build_target(dead: bool = false) -> Node:
	var target_node: Node = Node.new()
	var attr: AttributeComponent = AttributeComponentScript.new()
	actor_attrs_helper(target_node, attr)
	_health_target = HealthComponentPath.new()
	target_node.add_child(_health_target)
	_health_target.max_hp = 100
	_health_target.current_hp = 0 if dead else 100
	var faction: FactionComponent = FactionComponentPath.new()
	target_node.add_child(faction)
	faction.faction = FactionIds.FACTION_PREDATOR
	add_child_autofree(target_node)
	return target_node


func actor_attrs_helper(target_node: Node, attr: AttributeComponent) -> void:
	var attrs: AttributeSet = AttributeSetScript.new()
	attrs.set_score(AttributeIds.ATTR_STR, 10)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	target_node.add_child(attr)


func _build_context() -> void:
	_ctx = ActionContextPath.new()
	_ctx.actor = _actor
	_ctx.rng = _rng_node
	_ctx.bus = _bus


func _make_damage_card(cost: int = 0) -> Resource:
	var card_script: GDScript = load(CardDataPath)
	var card: Resource = card_script.new()
	card.id = &"damage_card"
	card.energy_cost = cost
	card.type = CardTypes.ATTACK
	card.range = 0
	var damage_script: GDScript = load(DamageEffectDataPath)
	var damage: Resource = damage_script.new()
	var dice_script: GDScript = load(DiceFormulaPath)
	var dice: DiceFormula = dice_script.new()
	dice.count = 1
	dice.die = 6
	damage.dice = dice
	damage.scaling_attribute = AttributeIds.ATTR_STR
	damage.damage_type = DamageTypes.PHYSICAL
	damage.resistance_attribute = &""
	damage.resistance_value = 0
	card.effects = ([damage] as Array[EffectData])
	return card


func test_validate_fails_with_null_data() -> void:
	_actor = _build_actor_with_components()
	_build_context()
	_executor.data = null
	assert_false(_executor.validate(_ctx), "null data → validate false")


func test_validate_fails_with_null_card() -> void:
	_actor = _build_actor_with_components()
	_build_context()
	_executor.data = _data
	assert_false(_executor.validate(_ctx), "null card → validate false")


func test_validate_fails_with_null_target_for_range_greater_than_zero() -> void:
	var card: Resource = _make_damage_card(0)
	card.range = 1
	_actor = _build_actor_with_components(card)
	_build_context()
	_executor.data = _data
	_data.target = null
	assert_false(_executor.validate(_ctx), "range > 0 with null target → validate false")


func test_validate_passes_self_target_for_range_zero() -> void:
	var card: Resource = _make_damage_card(0)
	card.range = 0
	_actor = _build_actor_with_components(card)
	_build_context()
	_executor.data = _data
	_data.target = null
	assert_true(_executor.validate(_ctx), "range 0 with null target is self-target → validate true")


func test_validate_fails_when_insufficient_energy() -> void:
	var card: Resource = _make_damage_card(5)
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	assert_false(_executor.validate(_ctx), "card cost 5 but only 5 max energy — but energy may be 5; need 6 to fail")
	# Specifically test: spend 4 of 5 energy first
	var stats: StatsComponent = _actor.get_node("StatsComponent")
	stats.spend_energy(1)  # now 4
	assert_false(_executor.validate(_ctx), "card cost 5 with only 4 energy → validate false")


func test_validate_fails_when_action_budget_spent() -> void:
	var card: Resource = _make_damage_card(0)
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	var budget: ActionBudgetComponent = _actor.get_node("ActionBudgetComponent")
	budget.spend(PlayCardData.type_id)
	assert_false(_executor.validate(_ctx), "play_card budget already spent → validate false")


func test_validate_fails_for_dead_target() -> void:
	var card: Resource = _make_damage_card(0)
	card.range = 1
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target(true)
	_data.target = target_node
	_executor.data = _data
	assert_false(_executor.validate(_ctx), "dead target → validate false")


func test_execute_spends_energy() -> void:
	var card: Resource = _make_damage_card(2)
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	var stats: StatsComponent = _actor.get_node("StatsComponent")
	var energy_before: int = stats.current_energy
	_executor.execute(_ctx)
	assert_eq(stats.current_energy, energy_before - 2, "energy reduced by card cost")


func test_execute_routes_to_discard_when_not_exhaust() -> void:
	var card: Resource = _make_damage_card(0)
	card.exhaust = false
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	_executor.execute(_ctx)
	assert_eq(_deck.hand.size(), 0, "card removed from hand")
	assert_eq(_deck.discard.size(), 1, "card added to discard")


func test_execute_routes_to_exhausted_list_when_exhaust_true() -> void:
	var card: Resource = _make_damage_card(0)
	card.exhaust = true
	card.id = &"exhausted_id"
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	_executor.execute(_ctx)
	assert_eq(_deck.hand.size(), 0, "card removed from hand")
	assert_eq(_deck.discard.size(), 0, "card NOT added to discard")
	assert_true(_deck.exhausted_this_combat.has(&"exhausted_id"), "card id added to exhausted_this_combat")


func test_execute_emits_card_played_on_bus() -> void:
	var card: Resource = _make_damage_card(0)
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emitted(_bus, "card_played", [card, _actor])


func test_execute_resolves_effects_emitting_damage_applied() -> void:
	var card: Resource = _make_damage_card(0)
	card.range = 1
	_actor = _build_actor_with_components(card)
	_build_context()
	var target_node: Node = _build_target()
	_data.target = target_node
	_executor.data = _data
	watch_signals(_bus)
	_executor.execute(_ctx)
	assert_signal_emit_count(_bus, "damage_applied", 1, "damage_applied emitted once")


func test_get_affected_tiles_returns_target_cell() -> void:
	var card: Resource = _make_damage_card(0)
	card.range = 1
	_actor = _build_actor_with_components(card)
	_build_context()
	# Set up a grid and place actor in it
	var grid: GridSystem = GridSystemPath.new()
	_actor.add_child(grid)
	var pos: GridPositionComponent = GridPositionComponentPath.new()
	_actor.add_child(pos)
	pos.grid = grid
	pos.set_cell(Vector2i(2, 2))
	var target_node: Node = _build_target()
	grid.register_entity(target_node, Vector2i(3, 2))
	_data.target = target_node
	_executor.data = _data
	var tiles: Array[Vector2i] = _executor.get_affected_tiles(_ctx)
	assert_true(tiles.has(Vector2i(3, 2)), "target tile (3,2) is in affected_tiles")
