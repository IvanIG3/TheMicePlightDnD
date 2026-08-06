class_name DiceFormula
extends Resource

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
	return RngService.dice_roll(self)
