extends Node

# RngService — the project's single source of truth for randomness.
# Every random value in gameplay code MUST come through this autoload. Direct
# calls to randi() / randf() / RandomNumberGenerator are forbidden (locked by
# the determinism guard test in T9).
#
# The internal RandomNumberGenerator is encapsulated: production code never
# replaces it. The only public seam is set_rng(rng), used exclusively by
# tests to inject a stub with a known seed.

var _rng: RandomNumberGenerator = null

func _ready() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()

func set_seed(seed_value: int) -> void:
	# Pass seed straight to the underlying RNG. Godot's RandomNumberGenerator
	# accepts 0 as a valid seed (not "randomize from time" — that's the global
	# randi()). Documented here so future maintainers don't worry about 0.
	if _rng == null:
		_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value

func set_rng(rng: RandomNumberGenerator) -> void:
	# Test seam: production code never calls this. The new RNG instance fully
	# replaces the encapsulated one; subsequent calls go through the new RNG.
	_rng = rng

func randi() -> int:
	_ensure_rng()
	return _rng.randi()

func randi_range(a: int, b: int) -> int:
	_ensure_rng()
	return _rng.randi_range(a, b)

func randf() -> float:
	_ensure_rng()
	return _rng.randf()

func randf_range(a: float, b: float) -> float:
	_ensure_rng()
	return _rng.randf_range(a, b)

func dice_roll(formula: Resource) -> Dictionary:
	# Validate die whitelist. DiceFormula also asserts in _init, but a formula
	# constructed via .tres files (Phase 2+) may bypass _init; this guard
	# catches that and produces a clear error rather than a divide-by-zero
	# or a weird unbounded die.
	var allowed: Array = [4, 6, 8, 10, 12, 20]
	assert(formula.die in allowed, "dice_roll: die must be in %s, got %d" % [allowed, formula.die])
	_ensure_rng()
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
	_ensure_rng()
	return arr[_rng.randi_range(0, arr.size() - 1)]

func shuffle(arr: Array) -> Array:
	# Fisher-Yates on a copy. Original is preserved (non-mutating per spec).
	var result: Array = arr.duplicate()
	_ensure_rng()
	var n: int = result.size()
	for i in range(n - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp: Variant = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result

func chance(p: float) -> bool:
	# True with probability p; clamp to [0, 1] for safety.
	var clamped: float = clampf(p, 0.0, 1.0)
	_ensure_rng()
	return _rng.randf() < clamped

func _ensure_rng() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
