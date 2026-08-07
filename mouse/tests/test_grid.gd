extends Node


@onready var grid: GridSystem = $GridSystem


@onready var mouse: Node = $Mouse


func _ready() -> void:
	if mouse != null and mouse.grid_position_component != null and grid != null:
		mouse.grid_position_component.init(grid)
		mouse.grid_position_component.set_cell(Vector2i(2, 2))
