class_name MouseView
extends View


const TILE_SIZE: int = 64


@export var sprite: Sprite2D = null


func _subscribe() -> void:
	var pos: GridPositionComponent = _get_position()
	if pos != null:
		_connect_to(pos, &"cell_changed", _on_cell_changed)


func _replay_state_from(_model: Node) -> void:
	var pos: GridPositionComponent = _get_position()
	if pos != null:
		_on_cell_changed(pos.cell, pos.cell)


func _on_cell_changed(_old_cell: Vector2i, new_cell: Vector2i) -> void:
	if sprite != null:
		sprite.position = Vector2(new_cell * TILE_SIZE)


func _get_position() -> GridPositionComponent:
	if _model == null:
		return null
	for child in _model.get_children():
		if child is GridPositionComponent:
			return child
	return null
