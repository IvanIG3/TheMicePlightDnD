class_name TargetingComponent
extends Node


@export var grid_ref: NodePath = ^""


var _grid: GridSystem = null


func _ready() -> void:
	if _grid == null and not grid_ref.is_empty():
		_grid = get_node_or_null(grid_ref) as GridSystem
		assert(_grid != null, "TargetingComponent: grid_ref did not resolve to a GridSystem")


func reachable_tiles(max_range: int) -> Array[Vector2i]:
	if _grid == null:
		return []
	var pos: GridPositionComponent = _get_position()
	if pos == null:
		return []
	return _bfs(pos.cell, max_range)


func area_tiles(center: Vector2i, shape: StringName, size: int) -> Array[Vector2i]:
	if shape == &"single" or size <= 0:
		return [center]
	if shape == &"cross":
		var tiles: Array[Vector2i] = [center]
		for s in range(1, size + 1):
			tiles.append(center + Vector2i(s, 0))
			tiles.append(center + Vector2i(-s, 0))
			tiles.append(center + Vector2i(0, s))
			tiles.append(center + Vector2i(0, -s))
		return tiles
	return [center]


func line_of_sight(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	if _grid == null:
		return false
	var x0: int = from_cell.x
	var y0: int = from_cell.y
	var x1: int = to_cell.x
	var y1: int = to_cell.y
	if x0 == x1 and y0 == y1:
		return true
	var dx: int = absi(x1 - x0)
	var dy: int = absi(y1 - y0)
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx - dy
	while true:
		if x0 == x1 and y0 == y1:
			return true
		if (x0 != from_cell.x or y0 != from_cell.y) and _grid.is_blocked(Vector2i(x0, y0)):
			return false
		var e2: int = err * 2
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy
	return true


func _bfs(origin: Vector2i, max_range: int) -> Array[Vector2i]:
	if max_range < 0 or _grid == null:
		return []
	var visited: Dictionary[Vector2i, bool] = {origin: true}
	var frontier: Array[Vector2i] = [origin]
	var result: Array[Vector2i] = []
	var depth: int = 0
	while frontier.size() > 0:
		var next_frontier: Array[Vector2i] = []
		for cell in frontier:
			result.append(cell)
			if depth < max_range:
				for neighbor in _grid.neighbors(cell):
					if not visited.has(neighbor) and not _grid.is_blocked(neighbor):
						visited[neighbor] = true
						next_frontier.append(neighbor)
		frontier = next_frontier
		depth += 1
	return result


func _get_position() -> GridPositionComponent:
	var parent: Node = get_parent()
	if parent == null:
		return null
	for child in parent.get_children():
		if child is GridPositionComponent:
			return child
	return null
