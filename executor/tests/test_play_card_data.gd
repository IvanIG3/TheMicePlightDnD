extends GutTest


func test_play_card_data_extends_action_data() -> void:
	var data: Resource = PlayCardData.new()
	assert_true(data.get_script() == PlayCardData, "data is a PlayCardData")
	assert_true(data is ActionData, "data is an ActionData")


func test_play_card_data_type_id_is_play_card() -> void:
	var data: Resource = PlayCardData.new()
	assert_eq(data.type_id, &"play_card", "type_id is &\"play_card\"")


func test_play_card_data_default_card_is_null() -> void:
	var data: Resource = PlayCardData.new()
	assert_null(data.card, "default card is null")


func test_play_card_data_default_target_is_null() -> void:
	var data: Resource = PlayCardData.new()
	assert_null(data.target, "default target is null")


func test_play_card_data_card_and_target_assignable() -> void:
	var data: Resource = PlayCardData.new()
	var card: Resource = CardData.new()
	var target_node: Node = Node.new()
	data.card = card
	data.target = target_node
	assert_same(data.card, card, "card stored")
	assert_same(data.target, target_node, "target stored")
	target_node.free()
