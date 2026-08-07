class_name PlayCardExecutor
extends ActionExecutor


const EffectContextPath := "res://effect/effect_context.gd"


func validate(ctx: ActionContext) -> bool:
	var play_card_data: PlayCardData = data as PlayCardData
	if play_card_data == null:
		return false
	if play_card_data.card == null:
		return false
	if play_card_data.target == null and play_card_data.card.range != 0:
		return false
	if play_card_data.target is Node:
		var target_node: Node = play_card_data.target
		if not is_instance_valid(target_node):
			return false
		var health: HealthComponent = _get_health(target_node)
		if health != null and health.is_dead():
			return false
	var stats: StatsComponent = _get_stats(ctx.actor)
	if stats == null:
		return false
	if stats.current_energy < play_card_data.card.energy_cost:
		return false
	var budget: ActionBudgetComponent = _get_budget(ctx.actor)
	if budget == null:
		return false
	if not budget.can_perform(PlayCardData.type_id):
		return false
	return true


func execute(ctx: ActionContext) -> bool:
	var play_card_data: PlayCardData = data as PlayCardData
	if play_card_data == null:
		return false
	var card: CardData = play_card_data.card
	if card == null:
		return false
	var effective_target: Variant = play_card_data.target
	if effective_target == null:
		effective_target = ctx.actor
	var stats: StatsComponent = _get_stats(ctx.actor)
	if stats == null:
		return false
	if not stats.spend_energy(card.energy_cost):
		return false
	var effect_ctx_script: GDScript = load(EffectContextPath)
	var eff_ctx: EffectContext = effect_ctx_script.new()
	eff_ctx.source = ctx.actor
	eff_ctx.target = effective_target
	eff_ctx.rng = ctx.rng
	eff_ctx.bus = ctx.bus
	for effect_data in card.effects:
		var ex: RefCounted = Registry.create_effect_executor(effect_data)
		ex.data = effect_data
		ex.execute(eff_ctx)
	var deck: DeckComponent = _get_deck(ctx.actor)
	if deck != null:
		if card.exhaust:
			deck.exhaust(card)
		else:
			deck.discard_from_hand(card)
	if ctx.bus != null:
		ctx.bus.card_played.emit(card, ctx.actor)
	return true


func get_affected_tiles(ctx: ActionContext) -> Array[Vector2i]:
	var play_card_data: PlayCardData = data as PlayCardData
	if play_card_data == null or play_card_data.card == null:
		return []
	var target_var: Variant = play_card_data.target
	if target_var == null:
		return []
	if target_var is Node:
		var target_node: Node = target_var
		var pos: GridPositionComponent = _get_position(target_node)
		if pos == null:
			return []
		var targeting: TargetingComponent = _get_targeting(ctx.actor)
		if targeting == null:
			return []
		return targeting.area_tiles(pos.cell, play_card_data.card.area_shape, play_card_data.card.area_size)
	return []


func _get_health(node: Node) -> HealthComponent:
	if node == null:
		return null
	for child in node.get_children():
		if child is HealthComponent:
			return child
	return null


func _get_stats(actor: Node) -> StatsComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is StatsComponent:
			return child
	return null


func _get_budget(actor: Node) -> ActionBudgetComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is ActionBudgetComponent:
			return child
	return null


func _get_deck(actor: Node) -> DeckComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is DeckComponent:
			return child
	return null


func _get_position(actor: Node) -> GridPositionComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is GridPositionComponent:
			return child
	return null


func _get_targeting(actor: Node) -> TargetingComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is TargetingComponent:
			return child
	return null
