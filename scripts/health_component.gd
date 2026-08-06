class_name HealthComponent
extends Node

# Stateful HP/THP component. Applies damage (with temp_hp absorption), heals
# (capped at max), grants temp_hp (replace-if-greater), tracks wounded state
# (transitions only), and fires a sticky died signal.
#
# Sibling-read pattern (locked): max_hp is read on demand from a Callable
# provided by the parent. The component does NOT import StatsComponent.
# The Callable is invoked every time max_hp is needed (not cached), so
# StatsComponent.recompute_max_hp propagates immediately.

const DEFAULT_MAX_HP := 1

@export var current_hp: int = 0
@export var temp_hp: int = 0

var max_hp_provider: Callable = Callable()
var _wounded: bool = false
var _died_emitted: bool = false

signal hp_changed(current: int, max: int)
signal temp_hp_changed(current: int)
signal wounded_state_changed(is_wounded: bool)
# TODO[phase-2]: retype killer to Character when entities are introduced.
signal died(cause: StringName, killer: Node)

# === Public API ===

# Returns the actual damage taken from current_hp (NOT from temp_hp).
# Decision 8: when temp_hp absorbs the full hit, emit ONLY temp_hp_changed.
func apply_damage(amount: int, source: Node = null) -> int:
	var max_hp: int = _get_current_max_hp()
	# Temp HP absorbs first.
	var temp_absorbed: int = mini(amount, temp_hp)
	temp_hp -= temp_absorbed
	var remaining: int = amount - temp_absorbed
	if temp_absorbed > 0:
		temp_hp_changed.emit(temp_hp)
	if remaining == 0:
		# Full absorption: no hp_changed (per Decision 8 asymmetry).
		_update_wounded_state(max_hp)
		return 0
	# Subtract from current_hp, clamp at 0.
	var prev_hp: int = current_hp
	current_hp = maxi(current_hp - remaining, 0)
	if current_hp != prev_hp:
		hp_changed.emit(current_hp, max_hp)
	_update_wounded_state(max_hp)
	# Sticky died: fire once on first transition to 0.
	if current_hp == 0 and prev_hp > 0 and not _died_emitted:
		_died_emitted = true
		died.emit(&"damage", source)
	return remaining

func apply_heal(amount: int) -> int:
	var max_hp: int = _get_current_max_hp()
	var prev_hp: int = current_hp
	current_hp = mini(current_hp + amount, max_hp)
	var healed: int = current_hp - prev_hp
	if healed > 0:
		hp_changed.emit(current_hp, max_hp)
	_update_wounded_state(max_hp)
	return healed

func grant_temp_hp(amount: int) -> void:
	if amount > temp_hp:
		temp_hp = amount
		temp_hp_changed.emit(temp_hp)

# Decision 9: inclusive boundary (current_hp <= max_hp / 2).
# Dead wins over wounded.
func is_wounded() -> bool:
	if is_dead():
		return false
	var max_hp: int = _get_current_max_hp()
	return current_hp <= max_hp / 2

func is_dead() -> bool:
	return current_hp == 0

func set_max_hp_provider(callable: Callable) -> void:
	max_hp_provider = callable

# Convenience: clears state for tests and biome instantiation.
func reset() -> void:
	current_hp = 0
	temp_hp = 0
	_wounded = false
	_died_emitted = false

# === Private helpers ===

func _get_current_max_hp() -> int:
	if max_hp_provider.is_valid():
		return int(max_hp_provider.call())
	return DEFAULT_MAX_HP

func _update_wounded_state(max_hp: int) -> void:
	var now_wounded: bool = false
	if not is_dead():
		now_wounded = current_hp <= max_hp / 2
	if now_wounded != _wounded:
		_wounded = now_wounded
		wounded_state_changed.emit(_wounded)
