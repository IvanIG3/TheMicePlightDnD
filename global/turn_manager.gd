extends Node

signal state_changed(old_state: StringName, new_state: StringName)
signal player_plan_submitted(actor: Node)
signal player_plan_rejected(actor: Node)
signal enemy_plan_published(predator: Node)
signal enemy_plan_resolved(predator: Node)
signal post_turn_ticked(actor: Node)
signal turn_completed(turn_count: int)

var current_state: StringName = TurnStates.PLAYER
var turn_count: int = 0
var player: Node = null
var grid: Node = null
var actors: Array[Node] = []
var predators: Array[Node] = []


func start(p_player: Node, p_grid: Node, p_actors: Array[Node]) -> void:
	player = p_player
	grid = p_grid
	actors = p_actors.duplicate()
	predators.clear()
	for a in actors:
		if a != player:
			predators.append(a)
	turn_count = 0
	current_state = TurnStates.PLAYER


func stop() -> void:
	current_state = TurnStates.PLAYER
	player = null
	grid = null
	actors.clear()
	predators.clear()


func submit_player_plan(executor: RefCounted, ctx: RefCounted) -> bool:
	if current_state != TurnStates.PLAYER:
		player_plan_rejected.emit(ctx.actor)
		return false
	if executor == null or ctx == null:
		player_plan_rejected.emit(ctx.actor if ctx != null else player)
		return false
	if not executor.validate(ctx):
		player_plan_rejected.emit(ctx.actor)
		return false
	var executed: bool = executor.execute(ctx)
	var action_type: StringName = executor.data.type_id
	if not executed:
		player_plan_rejected.emit(ctx.actor)
		return false
	_spend_budget(ctx.actor, action_type)
	player_plan_submitted.emit(ctx.actor)
	_enter_state(TurnStates.ENEMY_PLANNING)
	return true


func advance() -> void:
	match current_state:
		TurnStates.PLAYER:
			return
		TurnStates.ENEMY_PLANNING:
			_run_enemy_planning()
		TurnStates.ENEMY_RESOLVING:
			_run_enemy_resolving()
		TurnStates.POST_TURN:
			_run_post_turn()
		TurnStates.END_TURN:
			_run_end_turn()


func run_remaining_cycle() -> void:
	while current_state != TurnStates.PLAYER:
		advance()


func get_predator_brain(predator: Node) -> StaticPredatorBrain:
	if predator == null:
		return null
	for child in predator.get_children():
		if child is StaticPredatorBrain:
			return child
	return null


func _run_enemy_planning() -> void:
	for predator in predators:
		var brain: StaticPredatorBrain = get_predator_brain(predator)
		if brain == null:
			continue
		if not brain.has_method(&"plan_turn"):
			continue
		brain.plan_turn(TurnStates.ENEMY_PLANNING)
		enemy_plan_published.emit(predator)
	_enter_state(TurnStates.ENEMY_RESOLVING)


func _run_enemy_resolving() -> void:
	var ordered: Array[Node] = _order_by_initiative(predators)
	for predator in ordered:
		var intent_node: IntentComponent = _get_intent(predator)
		if intent_node == null or intent_node.current_intent == null:
			continue
		var plan: ActionPlan = intent_node.current_intent
		var ctx: RefCounted = _build_ctx_for(predator)
		var executor: RefCounted = _build_executor_for(plan, predator)
		if executor == null:
			intent_node.clear()
			continue
		if executor.validate(ctx) and executor.execute(ctx):
			_spend_budget(predator, executor.data.type_id)
		intent_node.clear()
		enemy_plan_resolved.emit(predator)
	_enter_state(TurnStates.POST_TURN)


func _run_post_turn() -> void:
	if player != null:
		var status: Node = _get_status(player)
		if status != null and status.has_method(&"tick_end_of_turn"):
			status.tick_end_of_turn()
		var stats: StatsComponent = _get_stats(player)
		if stats != null:
			stats.gain_energy(1)
			if turn_count > 0 and (turn_count + 1) % 5 == 0:
				var deck: DeckComponent = _get_deck(player)
				if deck != null and deck.reload_charges < 3:
					deck.reload_charges += 1
					deck.reload_charges_changed.emit(deck.reload_charges)
		post_turn_ticked.emit(player)
	_enter_state(TurnStates.END_TURN)


func _run_end_turn() -> void:
	for actor in actors:
		var budget: ActionBudgetComponent = _get_budget(actor)
		if budget != null:
			budget.reset()
	turn_count += 1
	turn_completed.emit(turn_count)
	_enter_state(TurnStates.PLAYER)


func _order_by_initiative(list: Array[Node]) -> Array[Node]:
	var copy: Array[Node] = list.duplicate()
	copy.sort_custom(func(a: Node, b: Node) -> bool:
		var sa: StatsComponent = _get_stats(a)
		var sb: StatsComponent = _get_stats(b)
		var ia: int = sa.initiative if sa != null else 0
		var ib: int = sb.initiative if sb != null else 0
		return ia > ib
	)
	return copy


func _build_executor_for(plan: ActionPlan, actor: Node) -> RefCounted:
	if plan == null:
		return null
	var registry: Node = Engine.get_main_loop().root.get_node_or_null("/root/Registry")
	if registry == null:
		return null
	var script: Variant = registry.action_executors.get(plan.action, null)
	if script == null:
		return null
	var data: Resource = _data_from_plan(plan, actor)
	if data == null:
		return null
	var executor: RefCounted = script.new()
	executor.data = data
	return executor


func _data_from_plan(plan: ActionPlan, actor: Node) -> Resource:
	if plan.action == MoveData.type_id:
		var data: MoveData = MoveData.new()
		var pos: GridPositionComponent = _get_position(actor)
		if pos != null and plan.target is Vector2i:
			data.direction = (plan.target as Vector2i) - pos.cell
		return data
	if plan.action == PlayCardData.type_id:
		var data: PlayCardData = PlayCardData.new()
		data.card = plan.card
		data.target = plan.target
		return data
	return null


func _build_ctx_for(actor: Node) -> RefCounted:
	var ctx = ActionContext.new()
	ctx.actor = actor
	ctx.grid = grid
	ctx.rng = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	ctx.bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	return ctx


func _enter_state(new_state: StringName) -> void:
	var old_state: StringName = current_state
	current_state = new_state
	if old_state != new_state:
		state_changed.emit(old_state, new_state)


func _spend_budget(actor: Node, action_type: StringName) -> void:
	if actor == null or action_type == &"":
		return
	var budget: ActionBudgetComponent = _get_budget(actor)
	if budget != null:
		budget.spend(action_type)


func _get_position(actor: Node) -> GridPositionComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is GridPositionComponent:
			return child
	return null


func _get_budget(actor: Node) -> ActionBudgetComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is ActionBudgetComponent:
			return child
	return null


func _get_stats(actor: Node) -> StatsComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is StatsComponent:
			return child
	return null


func _get_status(actor: Node) -> Node:
	if actor == null:
		return null
	for child in actor.get_children():
		if child.has_method(&"tick_end_of_turn"):
			return child
	return null


func _get_deck(actor: Node) -> DeckComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is DeckComponent:
			return child
	return null


func _get_intent(predator: Node) -> IntentComponent:
	if predator == null:
		return null
	for child in predator.get_children():
		if child is IntentComponent:
			return child
	return null
