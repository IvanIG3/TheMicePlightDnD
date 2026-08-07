extends GutTest


func test_no_duplicates_in_all() -> void:
	var seen: Dictionary = {}
	for value in CardTypes.ALL:
		assert_false(seen.has(value), "duplicate in ALL: %s" % String(value))
		seen[value] = true


func test_attack_constant_is_attack() -> void:
	assert_eq(CardTypes.ATTACK, &"attack", "ATTACK is &\"attack\"")


func test_defense_constant_is_defense() -> void:
	assert_eq(CardTypes.DEFENSE, &"defense", "DEFENSE is &\"defense\"")


func test_special_constant_is_special() -> void:
	assert_eq(CardTypes.SPECIAL, &"special", "SPECIAL is &\"special\"")


func test_all_contains_three_types() -> void:
	assert_eq(CardTypes.ALL.size(), 3, "ALL has 3 types")
