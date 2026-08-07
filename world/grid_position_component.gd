class_name GridPositionComponent
extends Node


signal cell_changed(old_cell: Vector2i, new_cell: Vector2i)


@export var is_blocking: bool = true


var cell: Vector2i = Vector2i.ZERO

var _grid: GridSystem = null


var grid: GridSystem:
	get: return _grid


func init(grid: GridSystem) -> void:
	_grid = grid


func set_cell(new_cell: Vector2i) -> bool:
	assert(_grid != null, "GridPositionComponent.set_cell: init(grid) must be called first")
	return _move_to(new_cell, _grid)


func try_move(direction: Vector2i, grid: GridSystem) -> bool:
	return _move_to(cell + direction, grid)


func _move_to(target: Vector2i, grid: GridSystem) -> bool:
	if target == cell:
		return true
	if grid.is_blocked(target):
		return false
	if grid.get_at(target) != null:
		return false
	var old_cell: Vector2i = cell
	if grid.get_at(old_cell) == self:
		grid.unregister_entity(self, old_cell)
	grid.register_entity(self, target)
	cell = target
	cell_changed.emit(old_cell, target)
	return true
