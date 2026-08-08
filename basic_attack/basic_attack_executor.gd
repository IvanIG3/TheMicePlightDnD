class_name BasicAttackExecutor
extends ActionExecutor


func validate(ctx: ActionContext) -> bool:
	var basic_data: BasicAttackData = data as BasicAttackData
	if basic_data == null:
		return false
	if _is_dead(ctx.actor):
		return false
	if not (basic_data.target is Vector2i):
		return false
	if ctx.grid == null:
		return false
	var pos: GridPositionComponent = _get_position(ctx.actor)
	if pos == null:
		return false
	var target_cell: Vector2i = basic_data.target
	if _chebyshev(pos.cell, target_cell) > basic_data.range:
		return false
	var target_actor: Node = ctx.grid.get_at(target_cell)
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
	var target_actor: Node = ctx.grid.get_at(target_cell)
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


func _build_damage_data(basic_data: BasicAttackData) -> DamageEffectData:
	var dmg_data: DamageEffectData = DamageEffectData.new()
	dmg_data.dice = basic_data.damage
	dmg_data.scaling_attribute = AttributeIds.ATTR_STR
	dmg_data.damage_type = DamageTypes.PHYSICAL
	return dmg_data


func _is_dead(actor: Node) -> bool:
	if actor == null:
		return true
	for child in actor.get_children():
		if child is HealthComponent:
			return child.is_dead()
	return false


func _is_hostile(actor: Node, other: Node) -> bool:
	var actor_faction: FactionComponent = _get_faction(actor)
	var other_faction: FactionComponent = _get_faction(other)
	if actor_faction == null or other_faction == null:
		return false
	return actor_faction.is_hostile_to(other_faction)


func _chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func _get_position(actor: Node) -> GridPositionComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is GridPositionComponent:
			return child
	return null


func _get_faction(actor: Node) -> FactionComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is FactionComponent:
			return child
	return null
