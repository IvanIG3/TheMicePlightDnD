class_name StatsComponent
extends Node

@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next: int = 100
@export var max_energy: int = 0
@export var current_energy: int = 0
@export var initiative: int = 0

var _attribute_component: Node = null
var _max_energy_base: int = 0

signal level_up(new_level: int)
signal xp_gained(amount: int)
signal energy_changed(current: int, max: int)
signal max_changed(which: StringName, value: int)


func init(max_energy_base: int, attribute_component: Node) -> void:
	_max_energy_base = max_energy_base
	_attribute_component = attribute_component


func gain_xp(n: int) -> void:
	xp += n
	xp_gained.emit(n)
	level_up_if_ready()


func level_up_if_ready() -> bool:
	var leveled: bool = false
	while xp >= xp_to_next:
		level += 1
		xp -= xp_to_next
		xp_to_next = level * 100
		level_up.emit(level)
		leveled = true
	return leveled


func gain_energy(n: int) -> void:
	current_energy = mini(current_energy + n, max_energy)
	energy_changed.emit(current_energy, max_energy)


func spend_energy(n: int) -> bool:
	if current_energy < n:
		return false
	current_energy -= n
	energy_changed.emit(current_energy, max_energy)
	return true


func recompute_max_energy() -> void:
	assert(_attribute_component != null, "StatsComponent.recompute_max_energy: attribute_component not set")
	var int_mod: int = _attribute_component.get_modifier(AttributeIds.ATTR_INT)
	max_energy = _max_energy_base + int_mod
	max_changed.emit(&"max_energy", max_energy)


func set_initiative_from_dex() -> void:
	assert(_attribute_component != null, "StatsComponent.set_initiative_from_dex: attribute_component not set")
	initiative = _attribute_component.get_modifier(AttributeIds.ATTR_DEX)


func get_max_energy() -> int:
	return max_energy


func get_current_energy() -> int:
	return current_energy
