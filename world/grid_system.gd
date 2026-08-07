class_name GridSystem
extends Node


var occupants: Dictionary[Vector2i, Node] = {}
var blocked: Dictionary[Vector2i, bool] = {}


func get_at(cell: Vector2i) -> Node:
	return occupants.get(cell, null)


func is_blocked(cell: Vector2i) -> bool:
	return blocked.get(cell, false)


func set_blocked(cell: Vector2i, value: bool) -> void:
	blocked[cell] = value


func neighbors(cell: Vector2i) -> Array[Vector2i]:
	return [
		cell + Vector2i(1, 0),
		cell + Vector2i(-1, 0),
		cell + Vector2i(0, 1),
		cell + Vector2i(0, -1),
	]


# Spec: docs/architecture/systems.md §GridSystem. Architecture table shows (entity); we take (entity, cell) explicitly because the caller (GridPositionComponent) has the cell and explicit args decouple the system from any knowledge of the entity's internals.
func register_entity(entity: Node, cell: Vector2i) -> void:
	occupants[cell] = entity


# Spec: docs/architecture/systems.md §GridSystem. See register_entity note above.
func unregister_entity(entity: Node, cell: Vector2i) -> void:
	if occupants.get(cell, null) == entity:
		occupants.erase(cell)
