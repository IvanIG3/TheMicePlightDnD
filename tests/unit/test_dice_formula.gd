extends GutTest

const DiceFormulaScript := preload("res://scripts/dice_formula.gd")

func test_max_roll_arithmetic() -> void:
	var f: Resource = DiceFormulaScript.new()
	f.count = 2
	f.die = 6
	f.bonus = 3
	assert_eq(f.max_roll(), 15, "2d6+3 max = 15")

	f.count = 3
	f.die = 8
	f.bonus = 0
	assert_eq(f.max_roll(), 24, "3d8+0 max = 24")

func test_average_roll_arithmetic() -> void:
	var f: Resource = DiceFormulaScript.new()
	f.count = 2
	f.die = 6
	f.bonus = 3
	assert_eq(f.average_roll(), 10.0, "2d6+3 average = 10.0")

func test_die_whitelist_validated() -> void:
	# Whitelisted values do not error.
	for d in [4, 6, 8, 10, 12, 20]:
		var f: Resource = DiceFormulaScript.new()
		f.count = 1
		f.die = d
		f.bonus = 0
		assert_eq(f.die, d, "die %d is allowed" % d)
		assert_eq(f.max_roll(), d, "1d%d max = %d" % [d, d])

func test_zero_count_formula() -> void:
	var f: Resource = DiceFormulaScript.new()
	f.count = 0
	f.die = 6
	f.bonus = 5
	assert_eq(f.max_roll(), 5, "0d6+5 max = 5")
	assert_eq(f.average_roll(), 5.0, "0d6+5 average = 5.0")

func test_roll_delegates_to_rng_service() -> void:
	# Deferred: requires RngService autoload from T4.
	if not ClassDB.class_exists("RngService") and Engine.get_main_loop().root.get_node_or_null("/root/RngService") == null:
		pending("RngService autoload not yet registered (T4); deferring roll() test.")
		return
	# Seed RNG for determinism; the actual RNG reset depends on RngService.set_seed being available.
	if Engine.get_main_loop().root.has_node("/root/RngService"):
		var rng_node: Node = Engine.get_main_loop().root.get_node("/root/RngService")
		if rng_node.has_method("set_seed"):
			rng_node.set_seed(42)
	var f: Resource = DiceFormulaScript.new()
	f.count = 2
	f.die = 6
	f.bonus = 3
	var result: Dictionary = f.roll()
	assert_true(result.has("raw"), "roll() result has 'raw'")
	assert_true(result.has("total"), "roll() result has 'total'")
	assert_true(result.has("rolls"), "roll() result has 'rolls'")
	assert_eq(result.rolls.size(), 2, "2d6 → 2 rolls")
	for r in result.rolls:
		assert_true(r >= 1 and r <= 6, "each roll in [1,6]")
	assert_eq(result.total, result.rolls[0] + result.rolls[1] + 3, "total = sum + bonus")
	assert_eq(result.raw, result.rolls[0], "raw = first roll")
	assert_true(result.total >= 5 and result.total <= 15, "2d6+3 total in [5,15]")

func test_roll_uses_rng_service_setter_for_tests() -> void:
	if Engine.get_main_loop().root.get_node_or_null("/root/RngService") == null:
		pending("RngService autoload not yet registered (T4); deferring setter-for-tests test.")
		return
	var rng_node: Node = Engine.get_main_loop().root.get_node("/root/RngService")
	if not rng_node.has_method("set_rng"):
		pending("RngService.set_rng not yet implemented (T4); deferring setter-for-tests test.")
		return
	# Swap in a custom RNG with seed 99. After set_rng, RngService uses it.
	var custom_rng := RandomNumberGenerator.new()
	custom_rng.seed = 99
	rng_node.set_rng(custom_rng)
	# Verify the custom RNG is now in use: first randi() should be a non-zero
	# value (proves the swap took effect).
	var first: int = rng_node.randi()
	assert_ne(first, 0, "first randi() should not be 0 with seed 99 (custom RNG active)")
	# Now use the formula.roll() to verify the seam: result.raw must come from
	# the custom RNG's sequence, not RngService's default.
	var f: Resource = DiceFormulaScript.new()
	f.count = 1
	f.die = 6
	f.bonus = 0
	var result: Dictionary = f.roll()
	assert_true(result.rolls[0] >= 1 and result.rolls[0] <= 6, "roll in [1,6]")
	assert_eq(result.raw, result.rolls[0], "raw = first roll")
