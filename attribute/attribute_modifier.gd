class_name AttributeModifier
extends Resource

const MODE_ADD: StringName = &"add"
const MODE_MULTIPLY: StringName = &"multiply"
const MODE_SET: StringName = &"set"
const MODIFIER_BASE: int = 10

@export var attribute: StringName = &""
@export var mode: StringName = MODE_ADD
@export var value: float = 0.0
@export var source: StringName = &""
