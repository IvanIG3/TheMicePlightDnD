extends GutTest


const FactionComponentScript := preload("res://character/faction_component.gd")


var _mouse: FactionComponent
var _predator: FactionComponent
var _neutral: FactionComponent
var _corpse: FactionComponent


func before_each() -> void:
	_mouse = FactionComponentScript.new()
	add_child_autofree(_mouse)
	_mouse.faction = FactionIds.FACTION_MOUSE

	_predator = FactionComponentScript.new()
	add_child_autofree(_predator)
	_predator.faction = FactionIds.FACTION_PREDATOR

	_neutral = FactionComponentScript.new()
	add_child_autofree(_neutral)
	_neutral.faction = FactionIds.FACTION_NEUTRAL

	_corpse = FactionComponentScript.new()
	add_child_autofree(_corpse)
	_corpse.faction = FactionIds.FACTION_CORPSE


func test_mouse_vs_predator_is_hostile() -> void:
	assert_true(_mouse.is_hostile_to(_predator), "mouse is hostile to predator")
	assert_true(_predator.is_hostile_to(_mouse), "predator is hostile to mouse")


func test_same_faction_is_not_hostile() -> void:
	assert_false(_mouse.is_hostile_to(_mouse), "mouse is not hostile to mouse")
	assert_false(_predator.is_hostile_to(_predator), "predator is not hostile to predator")


func test_neutral_vs_anything_is_not_hostile() -> void:
	assert_false(_neutral.is_hostile_to(_mouse), "neutral is not hostile to mouse")
	assert_false(_neutral.is_hostile_to(_predator), "neutral is not hostile to predator")
	assert_false(_mouse.is_hostile_to(_neutral), "mouse is not hostile to neutral")
	assert_false(_predator.is_hostile_to(_neutral), "predator is not hostile to neutral")


func test_corpse_is_not_hostile_to_anyone() -> void:
	assert_false(_corpse.is_hostile_to(_mouse), "corpse is not hostile to mouse")
	assert_false(_corpse.is_hostile_to(_predator), "corpse is not hostile to predator")
	assert_false(_mouse.is_hostile_to(_corpse), "mouse is not hostile to corpse")
	assert_false(_predator.is_hostile_to(_corpse), "predator is not hostile to corpse")
