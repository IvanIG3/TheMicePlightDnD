class_name AttributeBonus
extends Resource

const MODE_ADD: StringName = &"add"
const MODE_MULTIPLY: StringName = &"multiply"
const MODE_SET: StringName = &"set"

@export var attribute: StringName = &""
@export var mode: StringName = MODE_ADD
@export var value: float = 0.0
@export var source: StringName = &""
