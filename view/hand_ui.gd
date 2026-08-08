class_name HandUI
extends View


const CardViewScene := preload("res://view/card_view.tscn")
const HandContainerPath := "HBoxContainer"
const SignalHandChanged: StringName = &"hand_changed"
const SignalDeckChanged: StringName = &"deck_changed"
const SignalCardPlayIntent: StringName = &"card_play_intent"
const SignalEnergyChanged: StringName = &"energy_changed"


var hand_container: HBoxContainer = null
var _card_views: Array[CardView] = []
var _deck: DeckComponent = null


func _subscribe() -> void:
	_deck = _get_deck(_model)
	assert(_deck != null, "HandUI: model must have a DeckComponent")
	_connect_to(_deck, SignalHandChanged, _on_hand_changed)
	var stats: StatsComponent = _get_stats(_model)
	if stats != null:
		_connect_to(stats, SignalEnergyChanged, _on_energy_changed)


func _replay_state_from(_m: Node) -> void:
	_on_hand_changed()


func _on_hand_changed() -> void:
	for cv in _card_views:
		if is_instance_valid(cv):
			cv.free()
	_card_views.clear()
	if hand_container == null:
		hand_container = get_node_or_null(HandContainerPath) as HBoxContainer
	if hand_container == null or _deck == null:
		return
	for i in _deck.hand.size():
		var card: CardData = _deck.hand[i]
		var cv: CardView = CardViewScene.instantiate()
		hand_container.add_child(cv)
		cv.set_data(card)
		cv.set_playable(_can_play(card))
		_wire_card_view_pressed(cv, i)
		_card_views.append(cv)


func _wire_card_view_pressed(cv: CardView, hand_index: int) -> void:
	var on_pressed := func() -> void:
		var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
		if input != null and input.has_signal(SignalCardPlayIntent):
			input.emit_signal(SignalCardPlayIntent, hand_index)
	cv.pressed.connect(on_pressed)


func _can_play(card: CardData) -> bool:
	var stats: Node = _get_stats(_model)
	if stats == null or card == null:
		return false
	return stats.current_energy >= card.energy_cost


func _on_energy_changed(_current: int, _max: int) -> void:
	for cv in _card_views:
		if not is_instance_valid(cv):
			continue
		if cv.data == null:
			continue
		cv.set_playable(_can_play(cv.data))


func _get_deck(model: Node) -> DeckComponent:
	if model == null:
		return null
	for child in model.get_children():
		if child is DeckComponent:
			return child
	return null


func _get_stats(model: Node) -> Node:
	if model == null:
		return null
	for child in model.get_children():
		if child is StatsComponent:
			return child
	return null
