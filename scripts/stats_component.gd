class_name StatsComponent
extends Node

# Derived combat-stats component. Computes max_hp and max_energy from the
# AttributeComponent's CON / INT modifiers + the StatsBaseData's per-class
# base values. Manages XP, level-up chaining, energy, and initiative.
#
# Sibling-read pattern (locked, per spec):
#   - AttributeComponent is wired via set_attribute_component (parent or test).
#   - HealthComponent reads max_hp via a Callable (max_hp_provider), NOT a
#     direct StatsComponent reference. This file does not import HealthComponent
#     and HealthComponent does not import this file.

@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next: int = 100
@export var max_hp: int = 0
@export var max_energy: int = 0
@export var current_energy: int = 0
@export var initiative: int = 0

var _attribute_component: Node = null
var _stats_base: Resource = null

signal level_up(new_level: int)
signal xp_gained(amount: int)
signal energy_changed(current: int, max: int)
signal max_changed(which: StringName, value: int)

func init(stats_base: Resource) -> void:
	_stats_base = stats_base

func set_attribute_component(attr: Node) -> void:
	_attribute_component = attr

# === XP / level ===

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

# === Energy ===

func gain_energy(n: int) -> void:
	current_energy = mini(current_energy + n, max_energy)
	energy_changed.emit(current_energy, max_energy)

func spend_energy(n: int) -> bool:
	if current_energy < n:
		return false
	current_energy -= n
	energy_changed.emit(current_energy, max_energy)
	return true

# === Recompute (from AttributeComponent) ===

func recompute_max_hp() -> void:
	assert(_attribute_component != null, "StatsComponent.recompute_max_hp: attribute_component not set")
	assert(_stats_base != null, "StatsComponent.recompute_max_hp: stats_base not set")
	var con_mod: int = _attribute_component.modifier(&"con")
	max_hp = _stats_base.max_hp_base + con_mod
	max_changed.emit(&"max_hp", max_hp)

func recompute_max_energy() -> void:
	assert(_attribute_component != null, "StatsComponent.recompute_max_energy: attribute_component not set")
	assert(_stats_base != null, "StatsComponent.recompute_max_energy: stats_base not set")
	var int_mod: int = _attribute_component.modifier(&"int")
	max_energy = _stats_base.max_energy_base + int_mod
	max_changed.emit(&"max_energy", max_energy)

func set_initiative_from_dex() -> void:
	assert(_attribute_component != null, "StatsComponent.set_initiative_from_dex: attribute_component not set")
	initiative = _attribute_component.modifier(&"dex")

# === Accessors (for HealthComponent via Callable, DeckComponent in Phase 4) ===

func get_max_hp() -> int:
	return max_hp

func get_max_energy() -> int:
	return max_energy

func get_current_energy() -> int:
	return current_energy
