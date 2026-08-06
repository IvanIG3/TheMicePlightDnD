class_name AttributeSet
extends Resource

@export var scores: Dictionary[StringName, int] = {}


func get_score(attr: StringName) -> int:
	return scores.get(attr, 0)


func set_score(attr: StringName, score: int) -> void:
	scores[attr] = score


func get_modifier(attr: StringName) -> int:
	return get_score(attr) - AttributeData.SCORE_BASELINE
