class_name ActionBudgetComponent
extends Node


var _used: Dictionary = {}


func can_perform(action_type: StringName) -> bool:
	return not _used.has(action_type)


func spend(action_type: StringName) -> bool:
	if not can_perform(action_type):
		return false
	_used[action_type] = 1
	return true


func reset() -> void:
	_used.clear()
