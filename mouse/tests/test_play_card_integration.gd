extends GutTest


func _make_mouse_actor(start_cell: Vector2i = Vector2i(2, 2)) -> Dictionary:
	var grid: GridSystem = GridSystem.new()
	var pos: GridPositionComponent = GridPositionComponent.new()
	var budget: ActionBudgetComponent = ActionBudgetComponent.new()
	var faction: FactionComponent = FactionComponent.new()
	var actor: Node = Node.new()
	actor.add_child(pos)
	actor.add_child(budget)
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_MOUSE
	pos.grid = grid
	pos.set_cell(start_cell)
	var mem: MemorizationComponent = MemorizationComponent.new()
	actor.add_child(mem)
	var deck: DeckComponent = DeckComponent.new()
	actor.add_child(deck)
	deck.bind_memorization(mem)
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	var attrs: AttributeSet = AttributeSet.new()
	attrs.set_score(AttributeIds.ATTR_STR, 10)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	var stats: StatsComponent = StatsComponent.new()
	actor.add_child(stats)
	stats.init(3, attr)
	stats.recompute_max_energy()
	stats.current_energy = stats.max_energy
	add_child_autofree(actor)
	var turn_manager: Node = Engine.get_main_loop().root.get_node_or_null("/root/TurnManager")
	if turn_manager != null:
		turn_manager.stop()
		turn_manager.start(actor, grid, ([actor] as Array[Node]))
	return {"grid": grid, "pos": pos, "budget": budget, "actor": actor, "deck": deck, "stats": stats}


func _make_enemy(cell: Vector2i) -> Node:
	var enemy: Node = Node.new()
	var enemy_health: HealthComponent = HealthComponent.new()
	enemy.add_child(enemy_health)
	enemy_health.max_hp = 100
	enemy_health.current_hp = 100
	enemy_health.toughness = 1
	var enemy_faction: FactionComponent = FactionComponent.new()
	enemy.add_child(enemy_faction)
	enemy_faction.faction = FactionIds.FACTION_PREDATOR
	add_child_autofree(enemy)
	return enemy


func test_play_heal_card_spends_energy_and_heals() -> void:
	var s: Dictionary = _make_mouse_actor()
	var stats: StatsComponent = s.stats
	var health: HealthComponent = HealthComponent.new()
	s.actor.add_child(health)
	health.max_hp = 50
	health.current_hp = 30
	var registry: Node = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	var card: Resource = registry.get_data(&"calming_salve_card")
	s.deck.hand = ([card] as Array[CardData])
	var bus: Node = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	watch_signals(bus)
	var rng: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	rng.set_seed(0)
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_card_play_intent(0)
	assert_signal_emit_count(bus, "heal_applied", 1, "heal_applied emitted")
	assert_eq(stats.current_energy, 2, "energy reduced by 1 (max 3 - cost 1)")
	assert_eq(s.deck.hand.size(), 0, "card removed from hand")
	assert_eq(s.deck.discard.size(), 1, "card in discard pile")


func test_play_attack_card_auto_picks_adjacent_enemy() -> void:
	var s: Dictionary = _make_mouse_actor()
	var enemy: Node = _make_enemy(Vector2i(3, 2))
	s.grid.register_entity(enemy, Vector2i(3, 2))
	var enemy_health: HealthComponent = null
	for child in enemy.get_children():
		if child is HealthComponent:
			enemy_health = child
			break
	var registry: Node = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	var card: Resource = registry.get_data(&"scratch")
	s.deck.hand = ([card] as Array[CardData])
	var bus: Node = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	watch_signals(bus)
	var rng: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	rng.set_seed(41)
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_card_play_intent(0)
	assert_signal_emit_count(bus, "damage_applied", 1, "damage_applied emitted")
	assert_lt(enemy_health.current_hp, 100, "enemy health reduced")
	assert_eq(s.stats.current_energy, 2, "energy reduced by 1 (max 3 - cost 1)")
	assert_eq(s.deck.discard.size(), 1, "card in discard pile")


func test_play_exhaust_card_routes_to_exhausted_list() -> void:
	var s: Dictionary = _make_mouse_actor()
	s.stats.current_energy = 3
	var enemy: Node = _make_enemy(Vector2i(3, 2))
	s.grid.register_entity(enemy, Vector2i(3, 2))
	var registry: Node = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	var card: Resource = registry.get_data(&"furious_bite")
	s.deck.hand = ([card] as Array[CardData])
	var bus: Node = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	var rng: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	rng.set_seed(0)
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain._on_card_play_intent(0)
	assert_eq(s.deck.hand.size(), 0, "card removed from hand")
	assert_eq(s.deck.discard.size(), 0, "card NOT in discard")
	assert_true(s.deck.exhausted_this_combat.has(&"furious_bite"), "card id in exhausted_this_combat")
