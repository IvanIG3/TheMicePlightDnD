extends GutTest


const InputServiceScript := preload("res://input/input_service.gd")


func _make_service() -> Node:
	var service: Node = InputServiceScript.new()
	add_child_autofree(service)
	return service


func _action_event(action: StringName) -> InputEventAction:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


func test_all_intent_signals_exist() -> void:
	var service: Node = _make_service()
	assert_true(service.has_signal("move_intent"), "move_intent signal exists")
	assert_true(service.has_signal("confirm_intent"), "confirm_intent signal exists")
	assert_true(service.has_signal("cancel_intent"), "cancel_intent signal exists")
	assert_true(service.has_signal("inspect_intent"), "inspect_intent signal exists")
	assert_true(service.has_signal("card_play_intent"), "card_play_intent signal exists")
	assert_true(service.has_signal("basic_attack_intent"), "basic_attack_intent signal exists")
	assert_true(service.has_signal("draw_cards_intent"), "draw_cards_intent signal exists")
	assert_true(service.has_signal("wait_intent"), "wait_intent signal exists")
	assert_true(service.has_signal("end_turn_intent"), "end_turn_intent signal exists")
	assert_true(service.has_signal("rest_action_intent"), "rest_action_intent signal exists")


func test_move_actions_are_registered_in_input_map() -> void:
	_make_service()
	assert_true(InputMap.has_action(&"ui_move_up"), "ui_move_up registered")
	assert_true(InputMap.has_action(&"ui_move_down"), "ui_move_down registered")
	assert_true(InputMap.has_action(&"ui_move_left"), "ui_move_left registered")
	assert_true(InputMap.has_action(&"ui_move_right"), "ui_move_right registered")


func test_move_right_emits_move_intent_with_vector() -> void:
	var service: Node = _make_service()
	watch_signals(service)
	service._unhandled_input(_action_event(&"ui_move_right"))
	assert_signal_emitted(service, "move_intent", [Vector2i(1, 0)])


func test_move_left_emits_move_intent_with_vector() -> void:
	var service: Node = _make_service()
	watch_signals(service)
	service._unhandled_input(_action_event(&"ui_move_left"))
	assert_signal_emitted(service, "move_intent", [Vector2i(-1, 0)])


func test_move_up_emits_move_intent_with_vector() -> void:
	var service: Node = _make_service()
	watch_signals(service)
	service._unhandled_input(_action_event(&"ui_move_up"))
	assert_signal_emitted(service, "move_intent", [Vector2i(0, -1)])


func test_move_down_emits_move_intent_with_vector() -> void:
	var service: Node = _make_service()
	watch_signals(service)
	service._unhandled_input(_action_event(&"ui_move_down"))
	assert_signal_emitted(service, "move_intent", [Vector2i(0, 1)])


func test_unrelated_input_does_not_emit_move_intent() -> void:
	var service: Node = _make_service()
	watch_signals(service)
	service._unhandled_input(_action_event(&"some_other_action"))
	assert_signal_emit_count(service, "move_intent", 0, "unrelated action does not emit")
