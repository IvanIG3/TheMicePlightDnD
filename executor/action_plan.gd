class_name ActionPlan
extends RefCounted

var action: StringName = &""
var target: Variant = null
var card: Resource = null
var predicted_affected_tiles: Array[Vector2i] = []
