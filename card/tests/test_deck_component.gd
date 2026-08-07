extends GutTest


const DeckComponentPath := "res://card/deck_component.gd"
const MemorizationComponentPath := "res://card/memorization_component.gd"
const CardDataPath := "res://card/card_data.gd"


var _deck: Node
var _mem: Node
var _card_script: GDScript


func before_each() -> void:
	_card_script = load(CardDataPath)
	assert_not_null(_card_script, "CardData script must exist at " + CardDataPath)
	var mem_script: GDScript = load(MemorizationComponentPath)
	assert_not_null(mem_script, "MemorizationComponent script must exist at " + MemorizationComponentPath)
	_mem = mem_script.new()
	add_child_autofree(_mem)
	var deck_script: GDScript = load(DeckComponentPath)
	assert_not_null(deck_script, "DeckComponent script must exist at " + DeckComponentPath)
	_deck = deck_script.new()
	_deck.bind_memorization(_mem)
	add_child_autofree(_deck)
	var rng: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	if rng != null:
		rng.set_seed(0)


func _make_card(card_id: StringName) -> Resource:
	var card: Resource = _card_script.new()
	card.id = card_id
	return card


func test_initial_deck_and_hand_are_empty() -> void:
	assert_eq(_deck.deck.size(), 0, "deck starts empty")
	assert_eq(_deck.hand.size(), 0, "hand starts empty")
	assert_eq(_deck.discard.size(), 0, "discard starts empty")


func test_default_max_hand_size_is_four() -> void:
	assert_eq(_deck.max_hand_size, 4, "default max_hand_size is 4")


func test_draw_moves_from_deck_to_hand() -> void:
	_deck.deck = ([_make_card(&"a"), _make_card(&"b"), _make_card(&"c")] as Array[CardData])
	_deck.draw(2)
	assert_eq(_deck.hand.size(), 2, "hand has 2 cards")
	assert_eq(_deck.deck.size(), 1, "deck has 1 card remaining")


func test_draw_reshuffles_discard_into_deck_when_deck_empty() -> void:
	_deck.deck = ([] as Array[CardData])
	_deck.discard = ([_make_card(&"a"), _make_card(&"b")] as Array[CardData])
	_deck.draw(2)
	assert_eq(_deck.hand.size(), 2, "drawn from reshuffled discard")
	assert_eq(_deck.discard.size(), 0, "discard emptied into deck")


func test_draw_with_empty_deck_and_empty_discard_is_noop() -> void:
	watch_signals(_deck)
	_deck.draw(3)
	assert_eq(_deck.hand.size(), 0, "hand still empty")
	assert_signal_emit_count(_deck, "hand_changed", 0, "no hand_changed emitted on no-op draw")


func test_discard_from_hand_moves_card_to_discard() -> void:
	var a: Resource = _make_card(&"a")
	_deck.deck = ([a] as Array[CardData])
	_deck.draw(1)
	_deck.discard_from_hand(a)
	assert_eq(_deck.hand.size(), 0, "card removed from hand")
	assert_eq(_deck.discard.size(), 1, "card added to discard")


func test_discard_from_hand_emits_hand_changed() -> void:
	var a: Resource = _make_card(&"a")
	_deck.deck = ([a] as Array[CardData])
	_deck.draw(1)
	watch_signals(_deck)
	_deck.discard_from_hand(a)
	assert_signal_emit_count(_deck, "hand_changed", 1, "hand_changed emitted")
	assert_signal_emit_count(_deck, "deck_changed", 1, "deck_changed emitted")


func test_exhausted_this_combat_starts_empty() -> void:
	assert_eq(_deck.exhausted_this_combat.size(), 0, "exhausted_this_combat starts empty")


func test_discard_from_hand_with_exhaust_flag_routes_to_exhausted() -> void:
	var a: Resource = _make_card(&"exhausted_id")
	a.exhaust = true
	_deck.deck = ([a] as Array[CardData])
	_deck.draw(1)
	_deck.discard_from_hand(a)
	assert_eq(_deck.hand.size(), 0, "card removed from hand")
	assert_eq(_deck.discard.size(), 0, "card NOT added to discard")
	assert_eq(_deck.exhausted_this_combat.size(), 1, "card id added to exhausted_this_combat")
	assert_eq(_deck.exhausted_this_combat[0], &"exhausted_id", "exhausted id is &\"exhausted_id\"")


func test_add_to_deck_appends_card() -> void:
	var a: Resource = _make_card(&"a")
	var result: bool = _deck.add_to_deck(a)
	assert_true(result, "add_to_deck returns true")
	assert_eq(_deck.deck.size(), 1, "deck has 1 card")
	assert_same(_deck.deck[0], a, "appended card is the input")


func test_add_to_deck_respects_16_cap() -> void:
	for i in 16:
		_deck.add_to_deck(_make_card(StringName("c%d" % i)))
	var overflow: Resource = _make_card(&"overflow")
	var result: bool = _deck.add_to_deck(overflow)
	assert_false(result, "add_to_deck returns false at cap")
	assert_eq(_deck.deck.size(), 16, "deck still at 16 cards")


func test_remove_from_deck_returns_true_when_card_present() -> void:
	var a: Resource = _make_card(&"a")
	_deck.deck = ([a] as Array[CardData])
	var result: bool = _deck.remove_from_deck(a)
	assert_true(result, "remove_from_deck returns true")
	assert_eq(_deck.deck.size(), 0, "card removed from deck")


func test_memorize_delegates_to_memorization_component() -> void:
	var a: Resource = _make_card(&"a")
	_deck.memorize(a)
	assert_eq(_mem.memorized_cards.size(), 1, "MemorizationComponent received card")
	assert_same(_mem.memorized_cards[0], a, "card is the input")


func test_forget_memorized_delegates_to_memorization_component() -> void:
	_deck.memorize(_make_card(&"a"))
	assert_eq(_mem.memorized_cards.size(), 1, "sanity: card memorized")
	_deck.forget_memorized()
	assert_eq(_mem.memorized_cards.size(), 0, "memorization cleared")


func test_max_hand_size_from_int_attribute_int_10() -> void:
	_deck.bind_attribute_score(10)
	assert_eq(_deck.max_hand_size, 4, "INT 10 → 4 hand cards")


func test_max_hand_size_from_int_attribute_int_14() -> void:
	_deck.bind_attribute_score(14)
	assert_eq(_deck.max_hand_size, 5, "INT 14 → 5 hand cards (4 + floor(4/4))")


func test_max_hand_size_from_int_attribute_int_18() -> void:
	_deck.bind_attribute_score(18)
	assert_eq(_deck.max_hand_size, 6, "INT 18 → 6 hand cards (4 + floor(8/4)=6)")


func test_hand_changed_signal_emits_on_draw() -> void:
	_deck.deck = ([_make_card(&"a"), _make_card(&"b")] as Array[CardData])
	watch_signals(_deck)
	_deck.draw(2)
	assert_signal_emit_count(_deck, "hand_changed", 1, "hand_changed emitted once on draw")


func test_deck_changed_signal_emits_on_add_to_deck() -> void:
	watch_signals(_deck)
	_deck.add_to_deck(_make_card(&"a"))
	assert_signal_emit_count(_deck, "deck_changed", 1, "deck_changed emitted on add_to_deck")


func test_shuffle_initial_deck_preserves_size() -> void:
	var a: Resource = _make_card(&"a")
	var b: Resource = _make_card(&"b")
	var c: Resource = _make_card(&"c")
	_deck.deck = ([a, b, c] as Array[CardData])
	_deck.shuffle_initial_deck()
	assert_eq(_deck.deck.size(), 3, "deck size preserved after shuffle")
