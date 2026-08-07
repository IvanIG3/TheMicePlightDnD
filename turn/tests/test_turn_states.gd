extends GutTest


func test_no_duplicates_in_all() -> void:
	var seen: Dictionary = {}
	for value in TurnStates.ALL:
		assert_false(seen.has(value), "duplicate in ALL: %s" % String(value))
		seen[value] = true


func test_player_constant_is_player() -> void:
	assert_eq(TurnStates.PLAYER, &"player", "PLAYER is &\"player\"")


func test_enemy_planning_constant_is_enemy_planning() -> void:
	assert_eq(TurnStates.ENEMY_PLANNING, &"enemy_planning", "ENEMY_PLANNING is &\"enemy_planning\"")


func test_enemy_resolving_constant_is_enemy_resolving() -> void:
	assert_eq(TurnStates.ENEMY_RESOLVING, &"enemy_resolving", "ENEMY_RESOLVING is &\"enemy_resolving\"")


func test_post_turn_constant_is_post_turn() -> void:
	assert_eq(TurnStates.POST_TURN, &"post_turn", "POST_TURN is &\"post_turn\"")


func test_end_turn_constant_is_end_turn() -> void:
	assert_eq(TurnStates.END_TURN, &"end_turn", "END_TURN is &\"end_turn\"")


func test_all_contains_five_states() -> void:
	assert_eq(TurnStates.ALL.size(), 5, "ALL has 5 states (PLAYER through END_TURN)")
