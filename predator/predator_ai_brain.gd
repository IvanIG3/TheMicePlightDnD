class_name PredatorAIBrain
extends Node


const WAIT_ACTION: StringName = &"wait"

const _DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
]


var _actor: Node = null
var _player: Node = null
var _grid: GridSystem = null
var _intent: IntentComponent = null
var _deck: DeckComponent = null
var _position: GridPositionComponent = null
var _targeting: TargetingComponent = null
var _basic_attack: BasicAttackData = null


# Called from the predator's _ready. Captures the actor's components.
# Use set_context(player, grid) before plan_turn so the brain can see the current
# player and grid; the predator's _ready has neither.
func bind(actor: Node) -> void:
	_actor = actor
	_intent = _find_intent(actor)
	_deck = _find_deck(actor)
	_position = _find_position(actor)
	_targeting = _find_targeting(actor)
	_basic_attack = _find_basic_attack(actor)


func set_context(player: Node, grid: GridSystem) -> void:
	_player = player
	_grid = grid


func plan_turn(_state: StringName) -> void:
	if _intent == null:
		return
	var plan: ActionPlan = _decide()
	if plan != null:
		_intent.publish(plan)


func _decide() -> ActionPlan:
	if _grid == null or _position == null:
		return _wait_plan()
	if _player == null:
		return _wait_plan()
	var player_pos: GridPositionComponent = _find_position(_player)
	if player_pos == null or _is_dead(_player):
		return _wait_plan()
	var predator_cell: Vector2i = _position.cell
	var player_cell: Vector2i = player_pos.cell

	if _basic_attack != null and _in_range_and_los(predator_cell, player_cell, _basic_attack.range):
		return _basic_attack_plan(player_cell)

	var card_plan: ActionPlan = _card_plan(predator_cell, player_cell)
	if card_plan != null:
		return card_plan

	return _move_plan(predator_cell, player_cell)


func _wait_plan() -> ActionPlan:
	var plan: ActionPlan = ActionPlan.new()
	plan.action = WAIT_ACTION
	plan.predicted_affected_tiles = [] as Array[Vector2i]
	return plan


func _basic_attack_plan(target_cell: Vector2i) -> ActionPlan:
	var plan: ActionPlan = ActionPlan.new()
	plan.action = BasicAttackData.type_id
	plan.target = target_cell
	plan.predicted_affected_tiles = [target_cell]
	return plan


func _card_plan(predator_cell: Vector2i, player_cell: Vector2i) -> ActionPlan:
	if _deck == null or _deck.hand.is_empty():
		return null
	var cards: Array = _deck.hand.duplicate()
	cards.sort_custom(func(a: CardData, b: CardData) -> bool:
		if a.range != b.range:
			return a.range < b.range
		return String(a.id) < String(b.id)
	)
	for card in cards:
		if not (card is CardData):
			continue
		if card.range <= 0:
			continue
		if not _in_range_and_los(predator_cell, player_cell, card.range):
			continue
		var plan: ActionPlan = ActionPlan.new()
		plan.action = PlayCardData.type_id
		plan.card = card
		plan.target = player_cell
		plan.predicted_affected_tiles = [player_cell]
		return plan
	return null


func _move_plan(predator_cell: Vector2i, player_cell: Vector2i) -> ActionPlan:
	var best: Vector2i = predator_cell + _DIRECTIONS[0]
	var best_dist: int = _chebyshev(best, player_cell)
	for i in range(1, _DIRECTIONS.size()):
		var neighbor: Vector2i = predator_cell + _DIRECTIONS[i]
		var dist: int = _chebyshev(neighbor, player_cell)
		if dist < best_dist:
			best_dist = dist
			best = neighbor
	if not _is_walkable(best):
		return _wait_plan()
	var plan: ActionPlan = ActionPlan.new()
	plan.action = MoveData.type_id
	plan.target = best
	plan.predicted_affected_tiles = [best]
	return plan


func _in_range_and_los(from_cell: Vector2i, to_cell: Vector2i, range_val: int) -> bool:
	if _chebyshev(from_cell, to_cell) > range_val:
		return false
	if _targeting == null:
		return false
	return _targeting.line_of_sight(from_cell, to_cell)


func _is_walkable(cell: Vector2i) -> bool:
	if _grid.is_blocked(cell):
		return false
	if _grid.get_at(cell) != null:
		return false
	return true


func _is_dead(actor: Node) -> bool:
	if actor == null:
		return true
	for child in actor.get_children():
		if child is HealthComponent:
			return child.is_dead()
	return false


func _chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func _find_intent(actor: Node) -> IntentComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is IntentComponent:
			return child
	return null


func _find_deck(actor: Node) -> DeckComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is DeckComponent:
			return child
	return null


func _find_position(actor: Node) -> GridPositionComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is GridPositionComponent:
			return child
	return null


func _find_targeting(actor: Node) -> TargetingComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is TargetingComponent:
			return child
	return null


func _find_basic_attack(actor: Node) -> BasicAttackData:
	if actor == null:
		return null
	if "basic_attack" in actor and actor.basic_attack is BasicAttackData:
		return actor.basic_attack
	return null
