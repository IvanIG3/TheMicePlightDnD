class_name MemorizationComponent
extends Node


var memorized_cards: Array[CardData] = []
var learned_cards: Array[CardData] = []

signal memorized(card: CardData)
signal learned(card: CardData)
signal forgot


func memorize(card: CardData) -> void:
	if card == null:
		return
	if card in memorized_cards:
		return
	memorized_cards.append(card)
	memorized.emit(card)


func learn(card: CardData) -> bool:
	if card == null:
		return false
	if card in learned_cards:
		return false
	learned_cards.append(card)
	learned.emit(card)
	return true


func forget_all_memorized() -> void:
	memorized_cards.clear()
	forgot.emit()
