extends GutTest


func _registry() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/Registry")


func test_nibble_card_is_indexed() -> void:
	var registry := _registry()
	var card: Resource = registry.get_data(&"nibble")
	assert_not_null(card, "nibble card indexed")
	assert_true(card is CardData, "nibble is a CardData")
	assert_eq(card.energy_cost, 0, "energy_cost is 0")
	assert_eq(card.range, 0, "range is 0")
	assert_true(card.type in CardTypes.ALL, "type is in CardTypes.ALL")
	assert_eq(card.effects.size(), 1, "nibble has 1 effect")


func test_scratch_card_is_indexed() -> void:
	var registry := _registry()
	var card: Resource = registry.get_data(&"scratch")
	assert_not_null(card, "scratch card indexed")
	assert_true(card is CardData, "scratch is a CardData")
	assert_eq(card.energy_cost, 1, "energy_cost is 1")
	assert_eq(card.range, 1, "range is 1")
	assert_eq(card.type, CardTypes.ATTACK, "type is ATTACK")
	assert_eq(card.effects.size(), 1, "scratch has 1 effect")


func test_calming_salve_card_is_indexed() -> void:
	var registry := _registry()
	var card: Resource = registry.get_data(&"calming_salve_card")
	assert_not_null(card, "calming_salve_card indexed")
	assert_true(card is CardData, "calming_salve_card is a CardData")
	assert_eq(card.energy_cost, 1, "energy_cost is 1")
	assert_eq(card.range, 0, "range is 0")
	assert_eq(card.type, CardTypes.DEFENSE, "type is DEFENSE")
	assert_eq(card.effects.size(), 1, "calming_salve_card has 1 effect")


func test_furious_bite_card_is_indexed() -> void:
	var registry := _registry()
	var card: Resource = registry.get_data(&"furious_bite")
	assert_not_null(card, "furious_bite card indexed")
	assert_true(card is CardData, "furious_bite is a CardData")
	assert_eq(card.energy_cost, 2, "energy_cost is 2")
	assert_eq(card.range, 1, "range is 1")
	assert_true(card.exhaust, "exhaust is true")
	assert_eq(card.effects.size(), 1, "furious_bite has 1 effect")


func test_all_four_cards_loaded_by_registry() -> void:
	var registry := _registry()
	for card_id in [&"nibble", &"scratch", &"calming_salve_card", &"furious_bite"]:
		var card: Resource = registry.get_data(card_id)
		assert_not_null(card, "card %s indexed" % String(card_id))
		assert_true(card is CardData, "%s is a CardData" % String(card_id))
		assert_true(card.effects.size() > 0, "%s has at least one effect" % String(card_id))
		assert_true(card.type in CardTypes.ALL, "%s.type is in CardTypes.ALL" % String(card_id))
