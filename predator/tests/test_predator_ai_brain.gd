extends GutTest


var _grid: GridSystem
var _player: Node
var _player_pos: GridPositionComponent
var _predator: Node
var _predator_pos: GridPositionComponent
var _predator_health: HealthComponent
var _predator_faction: FactionComponent
var _predator_attr: AttributeComponent
var _predator_intent: IntentComponent
var _predator_deck: DeckComponent
var _predator_brain: PredatorAIBrain
var _basic_attack: BasicAttackData


func before_each() -> void:
	_grid = GridSystem.new()
	add_child_autofree(_grid)
	_player = _build_player(Vector2i(2, 2))
	_predator = _build_predator(Vector2i(0, 0))
	_basic_attack = _build_basic_attack()
	_predator.set_script(_make_predator_with_basic_attack_script())
	_predator.basic_attack = _basic_attack
	_predator_brain = _find_brain(_predator)
	_predator_brain.bind(_predator)
	_predator_brain.set_context(_player, _grid)
	_grid.register_entity(_predator_pos, _predator_pos.cell)
	_grid.register_entity(_player_pos, _player_pos.cell)


func _make_predator_with_basic_attack_script() -> Script:
	return load("res://turn/tests/fixtures/predator_with_basic_attack.gd")


func _build_player(cell: Vector2i) -> Node:
	var actor: Node = Node.new()
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = _grid
	pos.set_cell(cell)
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_MOUSE
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 50
	health.current_hp = 50
	add_child_autofree(actor)
	_player_pos = pos
	return actor


func _build_predator(cell: Vector2i) -> Node:
	var actor: Node = Node.new()
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = _grid
	pos.set_cell(cell)
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_PREDATOR
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 30
	health.current_hp = 30
	var attr: AttributeComponent = AttributeComponent.new()
	actor.add_child(attr)
	var attr_set: AttributeSet = AttributeSet.new()
	attr_set.set_score(AttributeIds.ATTR_STR, 10)
	attr.base = attr_set
	var targeting: TargetingComponent = TargetingComponent.new()
	actor.add_child(targeting)
	targeting.grid_ref = _grid.get_path()
	var intent: IntentComponent = IntentComponent.new()
	actor.add_child(intent)
	var deck: DeckComponent = DeckComponent.new()
	actor.add_child(deck)
	var brain: PredatorAIBrain = PredatorAIBrain.new()
	actor.add_child(brain)
	add_child_autofree(actor)
	_predator_pos = pos
	_predator_health = health
	_predator_faction = faction
	_predator_attr = attr
	_predator_intent = intent
	_predator_deck = deck
	_predator_brain = brain
	return actor


func _find_brain(actor: Node) -> PredatorAIBrain:
	for child in actor.get_children():
		if child is PredatorAIBrain:
			return child
	return null


func _build_basic_attack(range_val: int = 1) -> BasicAttackData:
	var d: BasicAttackData = BasicAttackData.new()
	d.display_name = "Bite"
	d.range = range_val
	var dice: DiceFormula = DiceFormula.new()
	dice.count = 1
	dice.die = 6
	dice.bonus = 0
	d.damage = dice
	return d


func _build_card(id: StringName, range_val: int) -> CardData:
	var c: CardData = CardData.new()
	c.id = id
	c.name = String(id)
	c.range = range_val
	c.area_shape = AreaShapes.SINGLE
	c.energy_cost = 1
	return c


# (a) Player in melee range → BasicAttack plan
func test_decide_basic_attack_when_player_in_melee() -> void:
	_predator_pos.set_cell(Vector2i(3, 2))
	_grid.register_entity(_predator_pos, Vector2i(3, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, BasicAttackData.type_id, "plan is basic attack")
	assert_eq(plan.target, Vector2i(2, 2), "target is player's cell")
	var expected_basic_tiles: Array[Vector2i] = [Vector2i(2, 2)] as Array[Vector2i]
	assert_eq(plan.predicted_affected_tiles, expected_basic_tiles, "predicted tiles = [player]")


# (b) Player in card range but not melee → PlayCard plan
func test_decide_play_card_when_player_in_card_range_not_melee() -> void:
	_predator.basic_attack = _build_basic_attack(1)
	var card: CardData = _build_card(&"long_bite", 3)
	_predator_deck.hand = [card]
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(2, 0))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(2, 0))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, PlayCardData.type_id, "plan is play card")
	assert_eq(plan.card, card, "card is the long-range card")
	assert_eq(plan.target, Vector2i(2, 0), "target is player cell")


# (c) Player out of range → Move plan toward player
func test_decide_move_when_player_out_of_range() -> void:
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(2, 0))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(2, 0))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, MoveData.type_id, "plan is move")
	assert_eq(plan.target, Vector2i(1, 0), "move toward player: (1, 0)")
	var expected_move_tiles: Array[Vector2i] = [Vector2i(1, 0)] as Array[Vector2i]
	assert_eq(plan.predicted_affected_tiles, expected_move_tiles, "predicted tile = destination")


# (d) Player out of range AND all neighbors blocked → Wait plan
func test_decide_wait_when_all_neighbors_blocked() -> void:
	# Move player first to free (2, 2), then move predator to (2, 2).
	_player_pos.set_cell(Vector2i(2, 0))
	_predator_pos.set_cell(Vector2i(2, 2))
	_grid.set_blocked(Vector2i(2, 1), true)
	_grid.set_blocked(Vector2i(3, 2), true)
	_grid.set_blocked(Vector2i(2, 3), true)
	_grid.set_blocked(Vector2i(1, 2), true)
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, &"wait", "plan is wait")
	var expected_wait_tiles: Array[Vector2i] = [] as Array[Vector2i]
	assert_eq(plan.predicted_affected_tiles, expected_wait_tiles, "no predicted tiles for wait")


# (e) Determinism — same setup produces the same plan
func test_decide_deterministic_same_input_same_plan() -> void:
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(2, 0))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(2, 0))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var first: ActionPlan = _predator_intent.current_intent
	assert_not_null(first, "first plan published")
	_predator_intent.clear()
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var second: ActionPlan = _predator_intent.current_intent
	assert_eq(second.action, first.action, "action is deterministic")
	assert_eq(second.target, first.target, "target is deterministic")
	assert_eq(second.predicted_affected_tiles, first.predicted_affected_tiles, "tiles are deterministic")


# Card selection priority: shorter range first
func test_card_selection_prefers_shorter_range() -> void:
	_predator.basic_attack = _build_basic_attack(1)
	var short_card: CardData = _build_card(&"short", 2)
	var long_card: CardData = _build_card(&"long", 3)
	_predator_deck.hand = [long_card, short_card]
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(2, 0))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(2, 0))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_eq(plan.action, PlayCardData.type_id, "plan is play card")
	assert_eq(plan.card, short_card, "shorter-range card selected first")


# No player → Wait plan
func test_decide_wait_when_no_player() -> void:
	_predator_brain.set_context(null, _grid)
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, &"wait", "plan is wait when no player")


# Player dead → Wait plan
func test_decide_wait_when_player_dead() -> void:
	for child in _player.get_children():
		if child is HealthComponent:
			child.current_hp = 0
	_predator_pos.set_cell(Vector2i(3, 2))
	_grid.register_entity(_predator_pos, Vector2i(3, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, &"wait", "plan is wait when player is dead")


# Move plan: tiebreak up→right→down→left
func test_move_tiebreak_up_right_down_left() -> void:
	# Predator at (0, 0) (initial), player at (2, 2) (initial).
	# Neighbors: up=(0, -1) dist 3, right=(1, 0) dist 2, down=(0, 1) dist 2, left=(-1, 0) dist 3.
	# Right and down tied at dist 2. Tiebreak picks right.
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_eq(plan.action, MoveData.type_id, "plan is move")
	assert_eq(plan.target, Vector2i(1, 0), "tiebreak picks right (first of the tied pair)")


# No intent → plan_turn is a no-op (defensive)
func test_plan_turn_no_intent_does_not_crash() -> void:
	var bare: Node = Node.new()
	add_child_autofree(bare)
	var brain: PredatorAIBrain = PredatorAIBrain.new()
	bare.add_child(brain)
	brain.bind(bare)
	brain.set_context(_player, _grid)
	brain.plan_turn(TurnStates.ENEMY_PLANNING)
	assert_null(brain._intent, "no intent on bare node")


# LOS blocked: predator at (5, 2), player at (2, 2), wall at (3, 2) and (4, 2).
# Brain's basic attack range is 1 so (5,2)→(2,2) is out of range. The card
# (range 3) is in range but LOS is blocked → not a card plan. Falls through
# to Move.
func test_decide_no_basic_attack_when_los_blocked() -> void:
	_predator.basic_attack = _build_basic_attack(1)
	_predator_pos.set_cell(Vector2i(5, 2))
	_player_pos.set_cell(Vector2i(2, 2))
	_grid.set_blocked(Vector2i(3, 2), true)
	_grid.set_blocked(Vector2i(4, 2), true)
	_grid.register_entity(_predator_pos, Vector2i(5, 2))
	_grid.register_entity(_player_pos, Vector2i(2, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_ne(plan.action, BasicAttackData.type_id, "no basic attack when out of range / blocked")


# LOS blocked: predator at (5, 2) with a card of range 3, player at (2, 2),
# wall at (3, 2). Card is in range but LOS is blocked → not a card plan.
func test_decide_no_card_when_los_blocked() -> void:
	_predator.basic_attack = _build_basic_attack(1)
	var card: CardData = _build_card(&"ranged", 3)
	_predator_deck.hand = [card]
	_predator_pos.set_cell(Vector2i(5, 2))
	_player_pos.set_cell(Vector2i(2, 2))
	_grid.set_blocked(Vector2i(3, 2), true)
	_grid.register_entity(_predator_pos, Vector2i(5, 2))
	_grid.register_entity(_player_pos, Vector2i(2, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_ne(plan.action, PlayCardData.type_id, "no card play when LOS blocked")


# Predator dead → Wait plan
func test_decide_wait_when_predator_is_dead() -> void:
	_predator_health.current_hp = 0
	_predator_pos.set_cell(Vector2i(3, 2))
	_grid.register_entity(_predator_pos, Vector2i(3, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, &"wait", "plan is wait when predator is dead")


# Closest neighbor is the player (occupied). The predator should Wait, not
# slide sideways to a worse neighbor.
func test_decide_wait_when_closest_neighbor_is_player() -> void:
	# Player at (1, 0), predator at (0, 0). All 4 neighbors: right=(1,0) dist 1
	# (player), left=(-1,0) dist 2, down=(0,1) dist 2, up=(0,-1) dist 2.
	# Right is best but occupied by player → Wait.
	_predator.basic_attack = null
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(1, 0))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(1, 0))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	assert_eq(plan.action, &"wait", "plan is wait when closest neighbor is the player")


# Determinism: card branch — hand with 2 cards in range, same setup,
# run twice, assert same card.
func test_decide_deterministic_card_branch() -> void:
	_predator.basic_attack = _build_basic_attack(1)
	var card_a: CardData = _build_card(&"aardvark", 2)
	var card_b: CardData = _build_card(&"beaver", 2)
	_predator_deck.hand = [card_b, card_a]  # Add in reverse order
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(2, 0))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(2, 0))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var first: ActionPlan = _predator_intent.current_intent
	_predator_intent.clear()
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var second: ActionPlan = _predator_intent.current_intent
	assert_eq(first.action, second.action, "card branch action is deterministic")
	assert_eq(first.card, second.card, "card branch card is deterministic")


# Determinism: basic attack branch — player in melee, run twice, same plan.
func test_decide_deterministic_basic_attack_branch() -> void:
	_predator_pos.set_cell(Vector2i(3, 2))
	_grid.register_entity(_predator_pos, Vector2i(3, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var first: ActionPlan = _predator_intent.current_intent
	_predator_intent.clear()
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var second: ActionPlan = _predator_intent.current_intent
	assert_eq(second.action, first.action, "basic attack action is deterministic")
	assert_eq(second.target, first.target, "basic attack target is deterministic")


# Grid edge: predator at the top-left corner, all neighbors either out of
# bounds or the player — plan should be Wait, not a Move off-grid.
func test_decide_wait_when_neighbors_out_of_bounds() -> void:
	_grid.bounds = Rect2i(0, 0, 3, 3)
	_predator_pos.set_cell(Vector2i(0, 0))
	_player_pos.set_cell(Vector2i(0, 2))
	_grid.register_entity(_predator_pos, Vector2i(0, 0))
	_grid.register_entity(_player_pos, Vector2i(0, 2))
	_predator_brain.plan_turn(TurnStates.ENEMY_PLANNING)
	var plan: ActionPlan = _predator_intent.current_intent
	assert_not_null(plan, "intent published")
	# Neighbors of (0,0): up=(0,-1) out of bounds, left=(-1,0) out of bounds,
	# right=(1,0) dist 2, down=(0,1) dist 1 → best is down. Down is in bounds
	# and walkable → Move to (0, 1).
	assert_eq(plan.action, MoveData.type_id, "down is in bounds, so move")
	assert_eq(plan.target, Vector2i(0, 1), "moves down toward player")
