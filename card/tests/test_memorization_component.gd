extends GutTest


var _comp: Node


func before_each() -> void:
	_comp = MemorizationComponent.new()
	add_child_autofree(_comp)


func _make_card(card_id: StringName) -> Resource:
	var card: Resource = CardData.new()
	card.id = card_id
	return card


func test_initial_memorized_cards_is_empty() -> void:
	assert_eq(_comp.memorized_cards.size(), 0, "memorized_cards starts empty")


func test_initial_learned_cards_is_empty() -> void:
	assert_eq(_comp.learned_cards.size(), 0, "learned_cards starts empty")


func test_memorize_adds_to_memorized_cards() -> void:
	var card: Resource = _make_card(&"alpha")
	_comp.memorize(card)
	assert_eq(_comp.memorized_cards.size(), 1, "card added to memorized_cards")
	assert_same(_comp.memorized_cards[0], card, "stored card is the input")


func test_memorize_emits_memorized_signal() -> void:
	watch_signals(_comp)
	var card: Resource = _make_card(&"alpha")
	_comp.memorize(card)
	assert_signal_emitted(_comp, "memorized", [card])


func test_memorize_does_not_duplicate_same_card() -> void:
	var card: Resource = _make_card(&"alpha")
	_comp.memorize(card)
	_comp.memorize(card)
	assert_eq(_comp.memorized_cards.size(), 1, "duplicate memorize is a no-op")


func test_learn_adds_to_learned_cards() -> void:
	var card: Resource = _make_card(&"alpha")
	var result: bool = _comp.learn(card)
	assert_true(result, "learn returns true")
	assert_eq(_comp.learned_cards.size(), 1, "card added to learned_cards")
	assert_same(_comp.learned_cards[0], card, "stored card is the input")


func test_learn_emits_learned_signal() -> void:
	watch_signals(_comp)
	var card: Resource = _make_card(&"alpha")
	_comp.learn(card)
	assert_signal_emitted(_comp, "learned", [card])


func test_learn_does_not_duplicate_same_card() -> void:
	var card: Resource = _make_card(&"alpha")
	_comp.learn(card)
	var result: bool = _comp.learn(card)
	assert_eq(_comp.learned_cards.size(), 1, "duplicate learn is a no-op")
	assert_false(result, "duplicate learn returns false")


func test_forget_all_memorized_clears_list() -> void:
	_comp.memorize(_make_card(&"alpha"))
	_comp.memorize(_make_card(&"beta"))
	assert_eq(_comp.memorized_cards.size(), 2, "sanity: two cards memorized")
	_comp.forget_all_memorized()
	assert_eq(_comp.memorized_cards.size(), 0, "memorized_cards cleared")


func test_forget_all_memorized_emits_forgot() -> void:
	watch_signals(_comp)
	_comp.forget_all_memorized()
	assert_signal_emitted(_comp, "forgot")


func test_forget_all_memorized_does_not_clear_learned() -> void:
	_comp.learn(_make_card(&"alpha"))
	_comp.forget_all_memorized()
	assert_eq(_comp.learned_cards.size(), 1, "learned_cards untouched by forget")
