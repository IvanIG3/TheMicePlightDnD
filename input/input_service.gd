extends Node

signal move_intent(direction: Vector2i)
signal confirm_intent
signal cancel_intent
signal inspect_intent(cell: Vector2i)
signal card_play_intent(hand_index: int)
signal basic_attack_intent
signal draw_cards_intent
signal wait_intent
signal end_turn_intent
signal rest_action_intent(action: StringName)

const MOVE_UP: StringName = &"ui_move_up"
const MOVE_DOWN: StringName = &"ui_move_down"
const MOVE_LEFT: StringName = &"ui_move_left"
const MOVE_RIGHT: StringName = &"ui_move_right"


func _ready() -> void:
	_ensure_move_actions()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(MOVE_UP):
		move_intent.emit(Vector2i(0, -1))
	elif event.is_action_pressed(MOVE_DOWN):
		move_intent.emit(Vector2i(0, 1))
	elif event.is_action_pressed(MOVE_LEFT):
		move_intent.emit(Vector2i(-1, 0))
	elif event.is_action_pressed(MOVE_RIGHT):
		move_intent.emit(Vector2i(1, 0))


func _ensure_move_actions() -> void:
	if not InputMap.has_action(MOVE_UP):
		InputMap.add_action(MOVE_UP)
		InputMap.action_add_event(MOVE_UP, _key_event(KEY_UP))
	if not InputMap.has_action(MOVE_DOWN):
		InputMap.add_action(MOVE_DOWN)
		InputMap.action_add_event(MOVE_DOWN, _key_event(KEY_DOWN))
	if not InputMap.has_action(MOVE_LEFT):
		InputMap.add_action(MOVE_LEFT)
		InputMap.action_add_event(MOVE_LEFT, _key_event(KEY_LEFT))
	if not InputMap.has_action(MOVE_RIGHT):
		InputMap.add_action(MOVE_RIGHT)
		InputMap.action_add_event(MOVE_RIGHT, _key_event(KEY_RIGHT))


func _key_event(keycode: int) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode as Key
	return event
