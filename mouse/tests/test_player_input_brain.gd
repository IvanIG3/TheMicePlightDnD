extends GutTest


func _start_turn_manager(actor: Node, grid: GridSystem) -> TurnManager:
	var turn_manager: TurnManager = TurnManager.new()
	add_child_autofree(turn_manager)
	turn_manager.start(actor, grid, ([actor] as Array[Node]))
	return turn_manager


func _make_actor(start_cell: Vector2i = Vector2i(2, 2)) -> Dictionary:
	var grid: GridSystem = GridSystem.new()
	var pos: GridPositionComponent = GridPositionComponent.new()
	var budget: ActionBudgetComponent = ActionBudgetComponent.new()
	var actor: Node = Node.new()
	actor.add_child(pos)
	actor.add_child(budget)
	pos.grid = grid
	pos.set_cell(start_cell)
	add_child_autofree(actor)
	return {"grid": grid, "pos": pos, "budget": budget, "actor": actor}


func _make_mouse_actor_with_deck(start_cell: Vector2i = Vector2i(2, 2), energy: int = 5) -> Dictionary:
	var s: Dictionary = _make_actor(start_cell)
	var actor: Node = s.actor
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_MOUSE
	var mem: MemorizationComponent = MemorizationComponent.new()
	actor.add_child(mem)
	var deck: DeckComponent = DeckComponent.new()
	actor.add_child(deck)
	deck.bind_memorization(mem)
	s["deck"] = deck
	return s


func _make_card(card_id: StringName, energy_cost: int = 0, range_val: int = 0, is_damage: bool = true) -> Resource:
	var card: CardData = CardData.new()
	card.id = card_id
	card.energy_cost = energy_cost
	card.type = CardTypes.ATTACK if is_damage else CardTypes.DEFENSE
	card.range = range_val
	return card


func _attach_stats(actor: Node, energy: int) -> StatsComponent:
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	var attrs: AttributeSet = AttributeSet.new()
	attrs.set_score(AttributeIds.ATTR_STR, 20)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	var stats: StatsComponent = StatsComponent.new()
	actor.add_child(stats)
	stats.init(energy, attr)
	stats.recompute_max_energy()
	stats.current_energy = stats.max_energy
	return stats


func _make_enemy_node() -> Node:
	var enemy: Node = Node.new()
	var attr: AttributeComponent = AttributeComponent.new()
	enemy.add_child(attr)
	var attrs: AttributeSet = AttributeSet.new()
	attrs.set_score(AttributeIds.ATTR_STR, 10)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	var health: HealthComponent = HealthComponent.new()
	enemy.add_child(health)
	health.max_hp = 100
	health.current_hp = 100
	var faction: FactionComponent = FactionComponent.new()
	enemy.add_child(faction)
	faction.faction = FactionIds.FACTION_PREDATOR
	return enemy


func test_on_move_intent_moves_actor() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_move_intent(Vector2i(1, 0))
	assert_eq(s.pos.cell, Vector2i(3, 2), "actor moved right to (3, 2)")


func test_on_move_intent_spends_move_budget() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_move_intent(Vector2i(1, 0))
	assert_false(s.budget.can_perform(&"move"), "move action budget is spent")


func test_on_move_intent_creates_pending_plan() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_move_intent(Vector2i(0, 1))
	assert_not_null(brain.pending_plan, "pending_plan is set")
	assert_eq(brain.pending_plan.action, &"move", "plan action is &\"move\"")
	assert_eq(brain.pending_plan.target, Vector2i(2, 3), "plan target is the destination")


func test_on_move_intent_blocked_does_not_move_or_spend_budget() -> void:
	var s: Dictionary = _make_actor()
	s.grid.set_blocked(Vector2i(3, 2), true)
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_move_intent(Vector2i(1, 0))
	assert_eq(s.pos.cell, Vector2i(2, 2), "actor did not move")
	assert_true(s.budget.can_perform(&"move"), "budget not spent on failed move")


func test_on_move_intent_diagonal_is_rejected() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_move_intent(Vector2i(1, 1))
	assert_eq(s.pos.cell, Vector2i(2, 2), "diagonal rejected, actor did not move")
	assert_true(s.budget.can_perform(&"move"), "budget not spent on rejected move")


func test_bind_connects_to_input_service_move_intent() -> void:
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	assert_not_null(input, "InputService autoload must be registered")
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(Node.new())
	assert_true(input.move_intent.is_connected(brain._on_move_intent), "brain is connected to move_intent")


func test_move_intent_through_input_service_drives_brain() -> void:
	var s: Dictionary = _make_actor()
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	input.move_intent.emit(Vector2i(-1, 0))
	assert_eq(s.pos.cell, Vector2i(1, 2), "actor moved left via InputService signal")


func test_card_play_intent_with_range_zero_targets_self() -> void:
	var s: Dictionary = _make_mouse_actor_with_deck()
	var stats: StatsComponent = _attach_stats(s.actor, 3)
	var card: Resource = _make_card(&"self_card", 0, 0, false)
	s.deck.hand = ([card] as Array[CardData])
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_card_play_intent(0)
	assert_eq(stats.current_energy, 3, "free card (cost 0) does not spend energy")
	assert_eq(s.deck.hand.size(), 0, "card removed from hand")


func test_card_play_intent_spends_action_budget() -> void:
	var s: Dictionary = _make_mouse_actor_with_deck()
	_attach_stats(s.actor, 3)
	var card: Resource = _make_card(&"c", 0, 0, false)
	s.deck.hand = ([card] as Array[CardData])
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_card_play_intent(0)
	assert_false(s.budget.can_perform(PlayCardData.type_id), "play_card budget is spent")


func test_card_play_intent_routes_to_discard() -> void:
	var s: Dictionary = _make_mouse_actor_with_deck()
	_attach_stats(s.actor, 3)
	var card: Resource = _make_card(&"c", 0, 0, false)
	card.exhaust = false
	s.deck.hand = ([card] as Array[CardData])
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_card_play_intent(0)
	assert_eq(s.deck.discard.size(), 1, "card added to discard")


func test_card_play_intent_refunds_when_no_adjacent_enemy() -> void:
	var s: Dictionary = _make_mouse_actor_with_deck()
	_attach_stats(s.actor, 3)
	var card: Resource = _make_card(&"attack", 0, 1, true)
	s.deck.hand = ([card] as Array[CardData])
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_card_play_intent(0)
	assert_eq(s.deck.hand.size(), 1, "card still in hand (no target)")
	assert_true(s.budget.can_perform(PlayCardData.type_id), "budget not spent on no-target")


func test_card_play_intent_auto_picks_adjacent_enemy() -> void:
	var s: Dictionary = _make_mouse_actor_with_deck()
	_attach_stats(s.actor, 3)
	var registry: Node = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	var card: Resource = registry.get_data(&"scratch")
	s.deck.hand = ([card] as Array[CardData])
	var enemy: Node = _make_enemy_node()
	var enemy_health: HealthComponent = null
	for child in enemy.get_children():
		if child is HealthComponent:
			enemy_health = child
			break
	enemy_health.max_hp = 100
	enemy_health.current_hp = 100
	enemy_health.toughness = 1
	add_child_autofree(enemy)
	s.grid.register_entity(enemy, Vector2i(3, 2))
	var rng: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	rng.set_seed(41)
	var bus: Node = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	watch_signals(bus)
	var brain: PlayerInputBrain = PlayerInputBrain.new()
	add_child_autofree(brain)
	brain.bind(s.actor)
	brain.set_turn_manager(_start_turn_manager(s.actor, s.grid))
	brain._on_card_play_intent(0)
	assert_lt(enemy_health.current_hp, 100, "enemy took damage from card play")
	assert_eq(s.deck.discard.size(), 1, "attack card routed to discard")
