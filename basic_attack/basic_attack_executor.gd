class_name BasicAttackExecutor
extends ActionExecutor


func validate(ctx: ActionContext) -> bool:
	var basic_data: BasicAttackData = data as BasicAttackData
	if basic_data == null:
		return false
	if basic_data.damage == null:
		return false
	if ActorUtils.is_dead(ctx.actor):
		return false
	if not (basic_data.target is Vector2i):
		return false
	if ctx.grid == null:
		return false
	var pos: GridPositionComponent = ActorUtils.find_component(ctx.actor, GridPositionComponent)
	if pos == null:
		return false
	var target_cell: Vector2i = basic_data.target
	if ActorUtils.chebyshev(pos.cell, target_cell) > basic_data.range:
		return false
	var target_actor: Node = _actor_at(ctx, target_cell)
	if target_actor == null:
		return false
	if not _is_hostile(ctx.actor, target_actor):
		return false
	return true


func execute(ctx: ActionContext) -> bool:
	var basic_data: BasicAttackData = data as BasicAttackData
	if basic_data == null:
		return false
	var target_cell: Vector2i = basic_data.target
	var target_actor: Node = _actor_at(ctx, target_cell)
	if target_actor == null:
		return false

	var dmg_data: DamageEffectData = _build_damage_data(basic_data)
	var dmg_executor: DamageExecutor = DamageExecutor.new()
	dmg_executor.data = dmg_data

	var eff_ctx: EffectContext = EffectContext.new()
	eff_ctx.source = ctx.actor
	eff_ctx.target = target_actor
	eff_ctx.rng = ctx.rng
	eff_ctx.bus = ctx.bus

	dmg_executor.execute(eff_ctx)
	return true


func get_affected_tiles(_ctx: ActionContext) -> Array[Vector2i]:
	var basic_data: BasicAttackData = data as BasicAttackData
	if basic_data == null or not (basic_data.target is Vector2i):
		return [] as Array[Vector2i]
	return [basic_data.target]


func _actor_at(ctx: ActionContext, cell: Vector2i) -> Node:
	var occupant: Node = ctx.grid.get_at(cell)
	if occupant == null or not is_instance_valid(occupant):
		return null
	if occupant is GridPositionComponent:
		var actor: Node = occupant.get_parent()
		if not is_instance_valid(actor):
			return null
		return actor
	return occupant


func _build_damage_data(basic_data: BasicAttackData) -> DamageEffectData:
	var dmg_data: DamageEffectData = DamageEffectData.new()
	dmg_data.dice = basic_data.damage
	dmg_data.scaling_attribute = AttributeIds.ATTR_STR
	dmg_data.damage_type = DamageTypes.PHYSICAL
	return dmg_data


func _is_hostile(actor: Node, other: Node) -> bool:
	var actor_faction: FactionComponent = ActorUtils.find_component(actor, FactionComponent)
	var other_faction: FactionComponent = ActorUtils.find_component(other, FactionComponent)
	if actor_faction == null or other_faction == null:
		return false
	return actor_faction.is_hostile_to(other_faction)

