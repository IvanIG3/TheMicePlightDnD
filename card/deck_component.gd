class_name DeckComponent
extends Node


const MAX_DECK_SIZE: int = 16


signal hand_changed
signal deck_changed
signal reload_charges_changed(charges: int)


var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard: Array[CardData] = []
var environmental_hand: Array[CardData] = []
var reload_charges: int = 3
var max_hand_size: int = 4
var exhausted_this_combat: Array[StringName] = []
var current_essence: int = 0

var _memorization: MemorizationComponent = null
var _attribute_int_score: int = 10


func bind_memorization(comp: MemorizationComponent) -> void:
	_memorization = comp


func bind_attribute_score(int_score: int) -> void:
	_attribute_int_score = int_score
	max_hand_size = maxi(0, 4 + floori((int_score - 10) / 4.0))


func shuffle_initial_deck() -> void:
	var rng: Node = Engine.get_main_loop().root.get_node_or_null("/root/RngService")
	if rng == null:
		return
	deck = rng.shuffle(deck)


func draw(n: int) -> void:
	var drew: bool = false
	var before_hand: int = hand.size()
	if hand.size() >= max_hand_size:
		if before_hand != hand.size():
			hand_changed.emit()
		return
	if deck.is_empty() and not discard.is_empty():
		deck = discard.duplicate()
		discard.clear()
		shuffle_initial_deck()
		drew = true
	var available: int = mini(n, deck.size())
	for i in available:
		var card: CardData = deck.pop_front()
		hand.append(card)
		drew = true
	if hand.size() != before_hand:
		hand_changed.emit()
	if drew:
		deck_changed.emit()


func discard_from_hand(card: CardData) -> void:
	if card == null:
		return
	var idx: int = hand.find(card)
	if idx == -1:
		return
	hand.remove_at(idx)
	if card.exhaust:
		if not card.id in exhausted_this_combat:
			exhausted_this_combat.append(card.id)
	else:
		discard.append(card)
	hand_changed.emit()
	deck_changed.emit()


func exhaust(card: CardData) -> void:
	discard_from_hand(card)


func add_to_deck(card: CardData) -> bool:
	if card == null:
		return false
	if deck.size() >= MAX_DECK_SIZE:
		return false
	deck.append(card)
	deck_changed.emit()
	return true


func remove_from_deck(card: CardData) -> bool:
	if card == null:
		return false
	var idx: int = deck.find(card)
	if idx == -1:
		return false
	deck.remove_at(idx)
	deck_changed.emit()
	return true


func memorize(card: CardData) -> void:
	if _memorization == null:
		return
	_memorization.memorize(card)


func forget_memorized() -> void:
	if _memorization == null:
		return
	_memorization.forget_all_memorized()
