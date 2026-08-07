class_name MoveExecutor
extends ActionExecutor


func validate(ctx: ActionContext) -> bool:
	var move_data: MoveData = data as MoveData
	if move_data == null:
		return false
	if absi(move_data.direction.x) + absi(move_data.direction.y) != 1:
		return false
	var pos: GridPositionComponent = _get_position(ctx.actor)
	if pos == null:
		return false
	var dest: Vector2i = pos.cell + move_data.direction
	if ctx.grid.is_blocked(dest):
		return false
	if ctx.grid.get_at(dest) != null:
		return false
	return true


func execute(ctx: ActionContext) -> bool:
	var move_data: MoveData = data as MoveData
	if move_data == null:
		return false
	var pos: GridPositionComponent = _get_position(ctx.actor)
	if pos == null:
		return false
	return pos.try_move(move_data.direction)


func get_affected_tiles(ctx: ActionContext) -> Array[Vector2i]:
	var move_data: MoveData = data as MoveData
	if move_data == null:
		return []
	var pos: GridPositionComponent = _get_position(ctx.actor)
	if pos == null:
		return []
	return [pos.cell + move_data.direction]


func _get_position(actor: Node) -> GridPositionComponent:
	if actor == null:
		return null
	for child in actor.get_children():
		if child is GridPositionComponent:
			return child
	return null
