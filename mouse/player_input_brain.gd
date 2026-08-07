class_name PlayerInputBrain
extends Node

const InputServiceAutoload: StringName = &"InputService"
const MoveExecutorScript := preload("res://executor/move_executor.gd")
const MoveDataScript := preload("res://executor/move_data.gd")
const PlayCardExecutorScript := preload("res://executor/play_card_executor.gd")
const PlayCardDataScript := preload("res://executor/play_card_data.gd")
const ActionContextScript := preload("res://executor/action_context.gd")
const ActionPlanScript := preload("res://executor/action_plan.gd")

const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

var pending_plan: ActionPlan = null
var _actor: Node = null


func bind(actor: Node) -> void:
	_actor = actor
	var input: Node = _get_input_service()
	if input != null:
		if not input.move_intent.is_connected(_on_move_intent):
			input.move_intent.connect(_on_move_intent)
		if input.has_signal(&"card_play_intent") and not input.card_play_intent.is_connected(_on_card_play_intent):
			input.card_play_intent.connect(_on_card_play_intent)


func _on_move_intent(direction: Vector2i) -> void:
	if _actor == null:
		return
	var executor: MoveExecutor = MoveExecutorScript.new()
	executor.data = _make_move_data(direction)
	var ctx: ActionContext = _make_ctx()
	pending_plan = _build_plan(direction, executor.get_affected_tiles(ctx))
	var turn_manager: Node = _get_turn_manager()
	if turn_manager != null:
		turn_manager.submit_player_plan(executor, ctx)


func _on_card_play_intent(hand_index: int) -> void:
	if _actor == null:
		return
	var deck: DeckComponent = _get_deck()
	if deck == null:
		return
	if hand_index < 0 or hand_index >= deck.hand.size():
		return
	var card: CardData = deck.hand[hand_index]
	if card == null:
		return
	var target: Variant = null
	if card.range == 0:
		target = _actor
	else:
		target = _find_adjacent_enemy()
		if target == null:
			return
	var play_card_data: PlayCardData = PlayCardDataScript.new()
	play_card_data.card = card
	play_card_data.target = target
	var executor: PlayCardExecutor = PlayCardExecutorScript.new()
	executor.data = play_card_data
	var ctx: ActionContext = _make_ctx()
	var turn_manager: Node = _get_turn_manager()
	if turn_manager != null:
		turn_manager.submit_player_plan(executor, ctx)


func submit_player_action(_plan: ActionPlan) -> void:
	pass


func _make_move_data(direction: Vector2i) -> MoveData:
	var move_data: MoveData = MoveDataScript.new()
	move_data.direction = direction
	return move_data


func _make_ctx() -> ActionContext:
	var ctx: ActionContext = ActionContextScript.new()
	ctx.actor = _actor
	var pos: GridPositionComponent = _get_position()
	if pos != null:
		ctx.grid = pos.grid
	ctx.rng = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	ctx.bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	return ctx


func _build_plan(direction: Vector2i, affected_tiles: Array[Vector2i]) -> ActionPlan:
	var plan: ActionPlan = ActionPlanScript.new()
	plan.action = MoveData.type_id
	var pos: GridPositionComponent = _get_position()
	if pos != null:
		plan.target = pos.cell + direction
	plan.predicted_affected_tiles = affected_tiles
	return plan


func _get_position() -> GridPositionComponent:
	if _actor == null:
		return null
	for child in _actor.get_children():
		if child is GridPositionComponent:
			return child
	return null


func _get_deck() -> DeckComponent:
	if _actor == null:
		return null
	for child in _actor.get_children():
		if child is DeckComponent:
			return child
	return null


func _find_adjacent_enemy() -> Node:
	var pos: GridPositionComponent = _get_position()
	if pos == null or pos.grid == null:
		return null
	var grid: GridSystem = pos.grid
	var actor_faction: FactionComponent = _get_faction()
	if actor_faction == null:
		return null
	for offset in NEIGHBOR_OFFSETS:
		var occupant: Node = grid.get_at(pos.cell + offset)
		if occupant == null:
			continue
		var occ_faction: FactionComponent = _get_faction_of(occupant)
		if occ_faction == null:
			continue
		if actor_faction.is_hostile_to(occ_faction):
			return occupant
	return null


func _get_faction() -> FactionComponent:
	if _actor == null:
		return null
	for child in _actor.get_children():
		if child is FactionComponent:
			return child
	return null


func _get_faction_of(node: Node) -> FactionComponent:
	if node == null:
		return null
	if node is FactionComponent:
		return node
	for child in node.get_children():
		if child is FactionComponent:
			return child
	return null


func _get_input_service() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/InputService")


func _get_turn_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/TurnManager")
