extends GutTest


const PlayCardDataPath := "res://executor/play_card_data.gd"
const ActionDataPath := "res://executor/action_data.gd"
const CardDataPath := "res://card/card_data.gd"


func test_play_card_data_extends_action_data() -> void:
	var data_script: GDScript = load(PlayCardDataPath)
	assert_not_null(data_script, "PlayCardData script must exist at " + PlayCardDataPath)
	var data: Resource = data_script.new()
	var action_data_script: GDScript = load(ActionDataPath)
	assert_true(data.get_script() == data_script, "data is a PlayCardData")
	assert_true(data is ActionData, "data is an ActionData")


func test_play_card_data_type_id_is_play_card() -> void:
	var data_script: GDScript = load(PlayCardDataPath)
	assert_not_null(data_script, "PlayCardData script must exist at " + PlayCardDataPath)
	var data: Resource = data_script.new()
	assert_eq(data.type_id, &"play_card", "type_id is &\"play_card\"")


func test_play_card_data_default_card_is_null() -> void:
	var data_script: GDScript = load(PlayCardDataPath)
	assert_not_null(data_script, "PlayCardData script must exist at " + PlayCardDataPath)
	var data: Resource = data_script.new()
	assert_null(data.card, "default card is null")


func test_play_card_data_default_target_is_null() -> void:
	var data_script: GDScript = load(PlayCardDataPath)
	assert_not_null(data_script, "PlayCardData script must exist at " + PlayCardDataPath)
	var data: Resource = data_script.new()
	assert_null(data.target, "default target is null")


func test_play_card_data_card_and_target_assignable() -> void:
	var data_script: GDScript = load(PlayCardDataPath)
	assert_not_null(data_script, "PlayCardData script must exist at " + PlayCardDataPath)
	var data: Resource = data_script.new()
	var card_script: GDScript = load(CardDataPath)
	assert_not_null(card_script, "CardData script must exist at " + CardDataPath)
	var card: Resource = card_script.new()
	var target_node: Node = Node.new()
	data.card = card
	data.target = target_node
	assert_same(data.card, card, "card stored")
	assert_same(data.target, target_node, "target stored")
	target_node.free()
