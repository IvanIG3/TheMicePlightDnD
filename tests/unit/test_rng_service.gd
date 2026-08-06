extends GutTest

# All RngService tests depend on the autoload being registered in project.godot.
# If it's not, the smoke test fails immediately with a clear message.

func _rng() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/RngService")

func test_autoload_is_registered() -> void:
	var rng_node := _rng()
	assert_not_null(rng_node, "RngService autoload not registered. Add [autoload] block to project.godot.")
	if rng_node != null:
		assert_eq(rng_node.get_script().resource_path, "res://scripts/rng_service.gd", "RngService script path mismatch")

func test_set_seed_makes_determinism() -> void:
	var rng_node := _rng()
	assert_not_null(rng_node, "RngService autoload required")
	rng_node.set_seed(42)
	var seq1: Array = []
	for i in 10:
		seq1.append(rng_node.randi())
	rng_node.set_seed(42)
	var seq2: Array = []
	for i in 10:
		seq2.append(rng_node.randi())
	assert_eq(seq1, seq2, "two sequences with the same seed must be equal")

func test_dice_roll_shape() -> void:
	var rng_node := _rng()
	assert_not_null(rng_node, "RngService autoload required")
	rng_node.set_seed(7)
	var DiceFormulaScript: GDScript = load("res://scripts/dice_formula.gd")
	var f: Resource = DiceFormulaScript.new()
	f.count = 2
	f.die = 6
	f.bonus = 3
	var result: Dictionary = rng_node.dice_roll(f)
	assert_true(result.has("raw"), "result has 'raw'")
	assert_true(result.has("total"), "result has 'total'")
	assert_true(result.has("rolls"), "result has 'rolls'")
	assert_eq(result.rolls.size(), 2, "2d6 → 2 rolls")
	for r in result.rolls:
		assert_true(r >= 1 and r <= 6, "each roll in [1,6]")
	assert_eq(result.total, result.rolls[0] + result.rolls[1] + 3, "total = sum + bonus")
	assert_eq(result.raw, result.rolls[0], "raw = first roll")

func test_dice_roll_determinism_same_seed() -> void:
	var rng_node := _rng()
	assert_not_null(rng_node, "RngService autoload required")
	var DiceFormulaScript: GDScript = load("res://scripts/dice_formula.gd")
	var f: Resource = DiceFormulaScript.new()
	f.count = 3
	f.die = 6
	f.bonus = 1
	rng_node.set_seed(12345)
	var total_a: int = rng_node.dice_roll(f).total
	rng_node.set_seed(12345)
	var total_b: int = rng_node.dice_roll(f).total
	assert_eq(total_a, total_b, "same seed + same formula → same total")

func test_set_rng_swaps_internal_rng() -> void:
	var rng_node := _rng()
	assert_not_null(rng_node, "RngService autoload required")
	# Build a custom RNG with seed 99; after set_rng, RngService uses it.
	var custom := RandomNumberGenerator.new()
	custom.seed = 99
	rng_node.set_rng(custom)
	# The first randi() should be the value from the custom RNG's first draw.
	var first_call: int = rng_node.randi()
	# Re-seed the same custom RNG in a fresh instance and pull the first draw;
	# they must be equal.
	var verify := RandomNumberGenerator.new()
	verify.seed = 99
	assert_eq(first_call, verify.randi(), "first call after set_rng matches fresh seeded RNG")

func test_pick_chance_shuffle() -> void:
	var rng_node := _rng()
	assert_not_null(rng_node, "RngService autoload required")
	rng_node.set_seed(1)
	# pick returns a value from the array
	var pick_result: Variant = rng_node.pick([10, 20, 30])
	assert_true(pick_result in [10, 20, 30], "pick returns a member of the array")
	# shuffle returns an array of the same length
	var original: Array = [1, 2, 3, 4, 5]
	var shuffled: Array = rng_node.shuffle(original)
	assert_eq(shuffled.size(), original.size(), "shuffle preserves length")
	# Shuffle is non-mutating per spec: original unchanged.
	assert_eq(original, [1, 2, 3, 4, 5], "shuffle does not mutate input")
	# chance(0.0) is always false, chance(1.0) is always true.
	assert_false(rng_node.chance(0.0), "chance(0.0) is false")
	assert_true(rng_node.chance(1.0), "chance(1.0) is true")
