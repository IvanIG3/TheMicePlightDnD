class_name ActionExecutor
extends RefCounted

var data: Resource = null


func validate(_ctx: ActionContext) -> bool:
	return true


func execute(_ctx: ActionContext) -> bool:
	return false


func get_affected_tiles(_ctx: ActionContext) -> Array[Vector2i]:
	return []
