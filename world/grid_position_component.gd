class_name GridPositionComponent
extends Node

const SIGNAL_CELL_CHANGED: StringName = &"cell_changed"

signal cell_changed(old_cell: Vector2i, new_cell: Vector2i)

@export var is_blocking: bool = true

var cell: Vector2i = Vector2i.ZERO
var grid: GridSystem = null


func set_cell(new_cell: Vector2i) -> bool:
	assert(grid != null, "GridPositionComponent.set_cell: grid must be assigned first")
	return _move_to(new_cell)


func try_move(direction: Vector2i) -> bool:
	return _move_to(cell + direction)


func _move_to(target: Vector2i) -> bool:
	if target == cell:
		return true
	if grid == null:
		return false
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
