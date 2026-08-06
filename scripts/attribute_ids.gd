class_name AttributeIds
extends RefCounted

# Shared StringName vocabulary for the six D&D-style ability scores.
# These constants are the ONLY sanctioned way to reference an attribute by name
# in the rest of the codebase. Use them in AttributeSet field wiring,
# AttributeComponent, and any consumer that needs to talk about an attribute.

const ATTR_STR: StringName = &"str"
const ATTR_DEX: StringName = &"dex"
const ATTR_CON: StringName = &"con"
const ATTR_INT: StringName = &"int"
const ATTR_WIS: StringName = &"wis"
const ATTR_CHA: StringName = &"cha"

const ALL: Array[StringName] = [
	ATTR_STR,
	ATTR_DEX,
	ATTR_CON,
	ATTR_INT,
	ATTR_WIS,
	ATTR_CHA,
]
