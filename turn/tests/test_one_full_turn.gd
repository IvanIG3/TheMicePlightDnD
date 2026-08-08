extends GutTest


const TurnManagerScript := preload("res://global/turn_manager.gd")


func _make_attribute_component() -> AttributeComponent:
	var attr: AttributeComponent = AttributeComponent.new()
	var attrs: AttributeSet = AttributeSet.new()
	attrs.set_score(AttributeIds.ATTR_STR, 10)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	return attr


func _make_player(grid: GridSystem, cell: Vector2i) -> Dictionary:
	var actor: Node = Node.new()
	actor.name = "Mouse"
	var attr: AttributeComponent = _make_attribute_component()
	actor.add_child(attr)
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = grid
	pos.set_cell(cell)
	var budget: ActionBudgetComponent = ActionBudgetComponent.new()
	actor.add_child(budget)
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_MOUSE
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 50
	health.current_hp = 50
	var stats: StatsComponent = StatsComponent.new()
	actor.add_child(stats)
	stats.init(3, attr)
	stats.recompute_max_energy()
	stats.current_energy = stats.max_energy - 1
	var deck: DeckComponent = DeckComponent.new()
	actor.add_child(deck)
	deck.reload_charges = 0
	add_child_autofree(actor)
	return {"actor": actor, "pos": pos, "budget": budget, "stats": stats, "health": health, "deck": deck}


func _make_predator(grid: GridSystem, cell: Vector2i, scripted_plan: ActionPlan) -> Dictionary:
	var actor: Node = Node.new()
	actor.name = "Predator"
	var attr: AttributeComponent = _make_attribute_component()
	actor.add_child(attr)
	var pos: GridPositionComponent = GridPositionComponent.new()
	actor.add_child(pos)
	pos.grid = grid
	var budget: ActionBudgetComponent = ActionBudgetComponent.new()
	actor.add_child(budget)
	var faction: FactionComponent = FactionComponent.new()
	actor.add_child(faction)
	faction.faction = FactionIds.FACTION_PREDATOR
	var health: HealthComponent = HealthComponent.new()
	actor.add_child(health)
	health.max_hp = 30
	health.current_hp = 30
	var stats: StatsComponent = StatsComponent.new()
	actor.add_child(stats)
	stats.init(1, attr)
	stats.recompute_max_energy()
	stats.initiative = 8
	var intent: IntentComponent = IntentComponent.new()
	actor.add_child(intent)
	var brain: StaticPredatorBrain = StaticPredatorBrain.new()
	actor.add_child(brain)
	brain.scripted_plan = scripted_plan
	brain.bind(actor)
	add_child_autofree(actor)
	pos.set_cell(cell)
	return {"actor": actor, "pos": pos, "intent": intent, "brain": brain, "stats": stats, "budget": budget}


func _make_move_plan(target: Vector2i) -> ActionPlan:
	var plan: ActionPlan = ActionPlan.new()
	plan.action = MoveData.type_id
	plan.target = target
	plan.predicted_affected_tiles = [target]
	return plan


func _make_move_executor(direction: Vector2i) -> RefCounted:
	var executor: MoveExecutor = MoveExecutor.new()
	var data: MoveData = MoveData.new()
	data.direction = direction
	executor.data = data
	return executor


func _make_ctx(actor: Node, grid: GridSystem) -> RefCounted:
	var ctx: ActionContext = ActionContext.new()
	ctx.actor = actor
	ctx.grid = grid
	ctx.rng = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	ctx.bus = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	return ctx


func test_full_cycle_player_moves_predator_publishes_and_resolves() -> void:
	var grid: GridSystem = GridSystem.new()
	add_child_autofree(grid)
	var player: Dictionary = _make_player(grid, Vector2i(2, 2))
	var predator_plan: ActionPlan = _make_move_plan(Vector2i(1, 0))
	var predator: Dictionary = _make_predator(grid, Vector2i(0, 0), predator_plan)
	var tm: TurnManager = TurnManagerScript.new()
	add_child_autofree(tm)
	tm.start(player.actor, grid, ([player.actor, predator.actor] as Array[Node]))
	var player_start: Vector2i = player.pos.cell
	var predator_start: Vector2i = predator.pos.cell
	var player_executor: RefCounted = _make_move_executor(Vector2i(0, 1))
	var player_ctx: RefCounted = _make_ctx(player.actor, grid)
	var submitted: bool = tm.submit_player_plan(player_executor, player_ctx)
	assert_true(submitted, "player plan submitted")
	assert_eq(tm.current_state, TurnStates.ENEMY_PLANNING, "state is ENEMY_PLANNING after submit")
	var planning_events: Array = []
	tm.enemy_plan_published.connect(func(p: Node) -> void: planning_events.append(p))
	var resolving_events: Array = []
	tm.enemy_plan_resolved.connect(func(p: Node) -> void: resolving_events.append(p))
	tm.run_remaining_cycle()
	assert_eq(planning_events.size(), 1, "one planning event fired")
	assert_eq(planning_events[0], predator.actor, "planning event for the predator")
	assert_eq(resolving_events.size(), 1, "one resolving event fired")
	assert_eq(resolving_events[0], predator.actor, "resolving event for the predator")
	assert_eq(player.pos.cell, Vector2i(player_start.x, player_start.y + 1), "player moved down one cell")
	assert_eq(predator.pos.cell, Vector2i(predator_start.x + 1, predator_start.y), "predator moved right toward player")
	assert_eq(player.stats.current_energy, player.stats.max_energy, "player energy recovered to max after cycle")
	assert_eq(tm.current_state, TurnStates.PLAYER, "state is back to PLAYER after full cycle")
	assert_eq(tm.turn_count, 1, "turn count incremented to 1")
	assert_null(predator.intent.current_intent, "predator's intent is cleared after resolution")
	assert_true(player.budget.can_perform(MoveData.type_id), "player move budget is reset for next turn")


func test_full_cycle_with_no_predator_just_completes() -> void:
	var grid: GridSystem = GridSystem.new()
	add_child_autofree(grid)
	var player: Dictionary = _make_player(grid, Vector2i(2, 2))
	var tm: TurnManager = TurnManagerScript.new()
	add_child_autofree(tm)
	tm.start(player.actor, grid, ([player.actor] as Array[Node]))
	var executor: RefCounted = _make_move_executor(Vector2i(1, 0))
	var ctx: RefCounted = _make_ctx(player.actor, grid)
	tm.submit_player_plan(executor, ctx)
	tm.run_remaining_cycle()
	assert_eq(tm.current_state, TurnStates.PLAYER, "state is back to PLAYER with no predators")
	assert_eq(tm.turn_count, 1, "turn count incremented")


func test_intent_published_then_cleared_in_same_cycle() -> void:
	var grid: GridSystem = GridSystem.new()
	add_child_autofree(grid)
	var player: Dictionary = _make_player(grid, Vector2i(2, 2))
	var predator_plan: ActionPlan = _make_move_plan(Vector2i(1, 0))
	var predator: Dictionary = _make_predator(grid, Vector2i(0, 0), predator_plan)
	var tm: TurnManager = TurnManagerScript.new()
	add_child_autofree(tm)
	tm.start(player.actor, grid, ([player.actor, predator.actor] as Array[Node]))
	var published_emitted: Array = []
	var cleared_emitted: Array = []
	predator.intent.intent_published.connect(func(_p: ActionPlan) -> void: published_emitted.append(true))
	predator.intent.intent_cleared.connect(func() -> void: cleared_emitted.append(true))
	var executor: RefCounted = _make_move_executor(Vector2i(0, 1))
	var ctx: RefCounted = _make_ctx(player.actor, grid)
	tm.submit_player_plan(executor, ctx)
	tm.run_remaining_cycle()
	assert_eq(published_emitted.size(), 1, "intent_published emitted once")
	assert_eq(cleared_emitted.size(), 1, "intent_cleared emitted once")


func test_intent_execution_matches_announced_plan() -> void:
	var grid: GridSystem = GridSystem.new()
	add_child_autofree(grid)
	var player: Dictionary = _make_player(grid, Vector2i(2, 2))
	var predator_plan: ActionPlan = _make_move_plan(Vector2i(1, 0))
	var predator: Dictionary = _make_predator(grid, Vector2i(0, 0), predator_plan)
	var tm: TurnManager = TurnManagerScript.new()
	add_child_autofree(tm)
	tm.start(player.actor, grid, ([player.actor, predator.actor] as Array[Node]))
	var sink: Dictionary = {"target": Vector2i.ZERO}
	predator.intent.intent_published.connect(func(p: ActionPlan) -> void: sink["target"] = p.target)
	var executor: RefCounted = _make_move_executor(Vector2i(0, 1))
	var ctx: RefCounted = _make_ctx(player.actor, grid)
	tm.submit_player_plan(executor, ctx)
	tm.run_remaining_cycle()
	assert_eq(sink["target"], Vector2i(1, 0), "announced target matches the plan's target")
	assert_eq(predator.pos.cell, Vector2i(1, 0), "predator executed the announced move")
