extends Node


var _rng: RandomNumberGenerator = null


func _ready() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()


func set_seed(seed_value: int) -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value


func set_rng(rng: RandomNumberGenerator) -> void:
	_rng = rng


func randi() -> int:
	return _rng.randi()


func randi_range(a: int, b: int) -> int:
	return _rng.randi_range(a, b)


func randf() -> float:
	return _rng.randf()


func randf_range(a: float, b: float) -> float:
	return _rng.randf_range(a, b)


func dice_roll(formula: DiceFormula) -> Dictionary:
	var rolls: Array[int] = []
	
	for i in formula.count:
		rolls.append(_rng.randi_range(1, formula.die))
	
	var total: int = 0
	for r in rolls:
		total += r
	total += formula.bonus
	
	return {"raw": rolls[0], "total": total, "rolls": rolls}


func pick(arr: Array) -> Variant:
	assert(arr.size() > 0, "RngService.pick: arr must be non-empty")
	return arr[_rng.randi_range(0, arr.size() - 1)]


func shuffle(arr: Array) -> Array:
	var result: Array = arr.duplicate()
	var n: int = result.size()
	for i in range(n - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp: Variant = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result


func chance(p: float) -> bool:
	var clamped: float = clampf(p, 0.0, 1.0)
	return _rng.randf() < clamped
