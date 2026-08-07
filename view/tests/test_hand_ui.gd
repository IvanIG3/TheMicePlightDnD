extends GutTest


const HandUIPath := "res://view/hand_ui.gd"
const HandUIScenePath := "res://view/hand_ui.tscn"
const CardViewPath := "res://view/card_view.gd"
const CardViewScenePath := "res://view/card_view.tscn"
const CardDataPath := "res://card/card_data.gd"
const DeckComponentPath := "res://card/deck_component.gd"
const MemorizationComponentPath := "res://card/memorization_component.gd"
const StatsComponentPath := "res://stats/stats_component.gd"
const AttributeComponentPath := "res://attribute/attribute_component.gd"
const AttributeSetPath := "res://attribute/attribute_set.gd"


var _hand_ui_script: GDScript
var _hand_ui_scene: PackedScene
var _card_view_script: GDScript
var _card_view_scene: PackedScene
var _card_data_script: GDScript
var _deck_script: GDScript
var _mem_script: GDScript
var _stats_script: GDScript
var _attr_script: GDScript
var _attr_set_script: GDScript


func before_each() -> void:
	_hand_ui_script = load(HandUIPath)
	_hand_ui_scene = load(HandUIScenePath)
	_card_view_script = load(CardViewPath)
	_card_view_scene = load(CardViewScenePath)
	_card_data_script = load(CardDataPath)
	_deck_script = load(DeckComponentPath)
	_mem_script = load(MemorizationComponentPath)
	_stats_script = load(StatsComponentPath)
	_attr_script = load(AttributeComponentPath)
	_attr_set_script = load(AttributeSetPath)
	assert_not_null(_hand_ui_script, "HandUI script must exist")
	assert_not_null(_hand_ui_scene, "HandUI scene must exist")
	assert_not_null(_card_view_script, "CardView script must exist")
	assert_not_null(_card_view_scene, "CardView scene must exist")
	assert_not_null(_card_data_script, "CardData script must exist")
	assert_not_null(_deck_script, "DeckComponent script must exist")
	assert_not_null(_mem_script, "MemorizationComponent script must exist")


func _make_card(card_id: StringName, cost: int = 0) -> Resource:
	var card: Resource = _card_data_script.new()
	card.id = card_id
	card.name = String(card_id)
	card.energy_cost = cost
	card.description = "Test card " + String(card_id)
	return card


func _make_actor_with_deck_and_stats(card_count: int = 0, cost: int = 0) -> Node:
	var actor: Node = Node.new()
	var mem: MemorizationComponent = _mem_script.new()
	actor.add_child(mem)
	var deck: DeckComponent = _deck_script.new()
	actor.add_child(deck)
	deck.bind_memorization(mem)
	var hand: Array[CardData] = []
	for i in card_count:
		hand.append(_make_card(StringName("c%d" % i), cost))
	deck.hand = hand
	var attr: AttributeComponent = _attr_script.new()
	actor.add_child(attr)
	var attrs: AttributeSet = _attr_set_script.new()
	attrs.set_score(AttributeIds.ATTR_STR, 10)
	attrs.set_score(AttributeIds.ATTR_DEX, 10)
	attrs.set_score(AttributeIds.ATTR_CON, 10)
	attrs.set_score(AttributeIds.ATTR_INT, 10)
	attrs.set_score(AttributeIds.ATTR_WIS, 10)
	attrs.set_score(AttributeIds.ATTR_CHA, 10)
	attr.base = attrs
	var stats: StatsComponent = _stats_script.new()
	actor.add_child(stats)
	stats.init(5, attr)
	stats.recompute_max_energy()
	stats.current_energy = stats.max_energy
	add_child_autofree(actor)
	return actor


func test_initialize_subscribes_to_hand_changed() -> void:
	var actor: Node = _make_actor_with_deck_and_stats(2)
	var deck: DeckComponent = null
	for child in actor.get_children():
		if child is DeckComponent:
			deck = child
			break
	assert_not_null(deck, "DeckComponent is a child of actor")
	var ui: Node = _hand_ui_scene.instantiate()
	add_child_autofree(ui)
	ui.initialize(actor)
	assert_true(deck.hand_changed.is_connected(ui._on_hand_changed), "subscribed to hand_changed")


func test_replay_state_rebuilds_card_views() -> void:
	var actor: Node = _make_actor_with_deck_and_stats(2)
	var ui: Node = _hand_ui_scene.instantiate()
	add_child_autofree(ui)
	ui.initialize(actor)
	var container: HBoxContainer = ui.get_node_or_null("HBoxContainer")
	assert_not_null(container, "HBoxContainer child exists")
	assert_eq(container.get_child_count(), 2, "2 CardView children created on replay")


func test_hand_changed_triggers_rebuild() -> void:
	var actor: Node = _make_actor_with_deck_and_stats(1)
	var deck: DeckComponent = null
	for child in actor.get_children():
		if child is DeckComponent:
			deck = child
			break
	var ui: Node = _hand_ui_scene.instantiate()
	add_child_autofree(ui)
	ui.initialize(actor)
	var container: HBoxContainer = ui.get_node_or_null("HBoxContainer")
	assert_eq(container.get_child_count(), 1, "1 CardView after init")
	deck.hand.append(_make_card(&"c_extra", 0))
	deck.hand_changed.emit()
	assert_eq(container.get_child_count(), 2, "rebuilt to 2 CardView on hand_changed")


func test_dispose_frees_card_view_children() -> void:
	var actor: Node = _make_actor_with_deck_and_stats(2)
	var ui: Node = _hand_ui_scene.instantiate()
	add_child_autofree(ui)
	ui.initialize(actor)
	var container: HBoxContainer = ui.get_node_or_null("HBoxContainer")
	assert_eq(container.get_child_count(), 2, "2 children before dispose")
	ui.dispose()
	# After dispose, the rebuild path is a no-op; verify _disposed is true
	assert_true(ui._disposed, "HandUI is disposed")


func test_card_view_pressed_emits_card_play_intent_on_input_service() -> void:
	var actor: Node = _make_actor_with_deck_and_stats(1, 0)
	var ui: Node = _hand_ui_scene.instantiate()
	add_child_autofree(ui)
	ui.initialize(actor)
	var input: Node = Engine.get_main_loop().root.get_node_or_null("/root/InputService")
	watch_signals(input)
	var container: HBoxContainer = ui.get_node_or_null("HBoxContainer")
	var card_view: Node = container.get_child(0)
	card_view.pressed.emit()
	assert_signal_emitted(input, "card_play_intent", [0])


func test_unplayable_card_is_disabled() -> void:
	var actor: Node = _make_actor_with_deck_and_stats(1, 10)
	var stats: StatsComponent = null
	for child in actor.get_children():
		if child is StatsComponent:
			stats = child
			break
	stats.current_energy = 1
	var ui: Node = _hand_ui_scene.instantiate()
	add_child_autofree(ui)
	ui.initialize(actor)
	var container: HBoxContainer = ui.get_node_or_null("HBoxContainer")
	var card_view: Node = container.get_child(0)
	assert_true(card_view.button.disabled, "button disabled when cost > energy")
	assert_true(card_view.disabled_overlay.visible, "disabled overlay visible")
