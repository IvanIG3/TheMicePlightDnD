class_name DiceFormula
extends Resource

# Dice formula Resource. Holds the static shape of a roll (count, die size, bonus)
# and delegates the actual roll to RngService. The roll() method is a thin wrapper
# so that all randomness in the project flows through RngService (one place to
# enforce Nat 20/Nat 1 in Phase 3+).
#
# Whitelist enforcement: only D&D-standard die sizes are valid. _init asserts
# the die size; constructing an invalid formula is a programmer error.

const ALLOWED_DICE: Array[int] = [4, 6, 8, 10, 12, 20]

@export var count: int = 1
@export var die: int = 6
@export var bonus: int = 0

func _init() -> void:
	_assert_die_valid()

func _assert_die_valid() -> void:
	if not die in ALLOWED_DICE:
		assert(false, "DiceFormula.die must be in %s, got %d" % [ALLOWED_DICE, die])
		push_error("DiceFormula.die must be in %s, got %d" % [ALLOWED_DICE, die])

func max_roll() -> int:
	return count * die + bonus

func average_roll() -> float:
	return count * (die + 1) / 2.0 + bonus

func roll() -> Dictionary:
	# Thin wrapper around RngService.dice_roll(self). RngService is the
	# single source of truth for randomness; this method exists so call sites
	# read naturally: `formula.roll()`.
	#
	# Runtime lookup: RngService is an autoload, registered in project.godot.
	# Until the autoload is in place (T4), this method surfaces a clear error
	# at call time rather than failing at parse time. Production code always
	# has the autoload; the lookup is a defensive check.
	var rng_node: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	assert(rng_node != null, "RngService autoload not registered. Add it to project.godot [autoload].")
	if rng_node == null:
		# Fallback empty result so callers that ignore the assert still get a typed dict.
		return {"raw": 0, "total": bonus, "rolls": []}
	return rng_node.dice_roll(self)
