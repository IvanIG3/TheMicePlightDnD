class_name AttributeModifier
extends Resource

# A single modifier that contributes to an AttributeComponent's resolved value.
# Phase 1 only interprets MODE_ADD; the other modes are accepted as field values
# (so a future phase can introduce multiply/set semantics without a schema break)
# but are ignored by AttributeComponent.get in Phase 1.
#
# TODO[phase-9]: implement multiply/set when stacking semantics expand.

const MODE_ADD: StringName = &"add"
const MODE_MULTIPLY: StringName = &"multiply"
const MODE_SET: StringName = &"set"

@export var attribute: StringName = &""
@export var mode: StringName = MODE_ADD
@export var value: float = 0.0
@export var source: StringName = &""
