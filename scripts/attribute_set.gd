class_name AttributeSet
extends Resource

# Inert D&D-style ability score container. All six base scores default to 10
# (the D&D baseline). The component (AttributeComponent) is responsible for
# resolving modified values; this Resource only holds the raw bases.
#
# Access patterns (locked by spec):
# - Direct field reads: set.str, set.dex, ... (used by editor and one-off base inspection)
# - get_value(attr: StringName) -> int: a single funnel for any code that wants to
#   look up a score by StringName (used by AttributeComponent so future logic like
#   clamping/validation has one place to live).
# - modifier(attr) -> int: D&D 5e modifier, get_value(attr) - 10.
#
# Deviation from spec: the spec proposed `get(attr)` as the public accessor, but
# Object.get() is a native method that Godot's warning system explicitly flags
# as "won't be called by the engine". We rename to `get_value` to avoid the
# shadowing trap. Behaviour is identical.

@export var str: int = 10
@export var dex: int = 10
@export var con: int = 10
@export var int_: int = 10
@export var wis: int = 10
@export var cha: int = 10

const _FIELD_BY_ATTR := {
	&"str": "str",
	&"dex": "dex",
	&"con": "con",
	&"int": "int_",
	&"wis": "wis",
	&"cha": "cha",
}

func get_value(attr: StringName) -> int:
	var field_name: String = _FIELD_BY_ATTR.get(attr, "")
	if field_name == "":
		# Unknown attribute. Per the locked Decision 3, the assert/push_error
		# debug branch is owned by AttributeComponent (where typos happen);
		# AttributeSet itself stays silent-zero because it is just data storage
		# and may be queried with arbitrary keys by tooling.
		return 0
	return get(field_name)

func modifier(attr: StringName) -> int:
	return get_value(attr) - 10
