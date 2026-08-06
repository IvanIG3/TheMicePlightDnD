class_name HealthComponent
extends Node

@export var current_hp: int = 0
@export var temp_hp: int = 0

var max_hp: int = 0
var _attribute_component: Node = null
var _max_hp_base: int = 0
var _wounded: bool = false
var _died_emitted: bool = false

signal hp_changed(current: int, max: int)
signal temp_hp_changed(current: int)
signal wounded_state_changed(is_wounded: bool)
signal died(cause: StringName, killer: Node)


func init(max_hp_base: int, attribute_component: Node) -> void:
	_max_hp_base = max_hp_base
	_attribute_component = attribute_component


func recompute_max_hp() -> void:
	assert(_attribute_component != null, "HealthComponent.recompute_max_hp: attribute_component not set")
	var con_mod: int = _attribute_component.get_modifier(AttributeIds.ATTR_CON)
	var new_max: int = _max_hp_base + con_mod
	if new_max != max_hp:
		max_hp = new_max
		hp_changed.emit(current_hp, max_hp)
	_update_wounded_state()


func apply_damage(amount: int, source: Node = null) -> int:
	var temp_absorbed: int = mini(amount, temp_hp)
	temp_hp -= temp_absorbed
	var remaining: int = amount - temp_absorbed
	if temp_absorbed > 0:
		temp_hp_changed.emit(temp_hp)
	if remaining == 0:
		_update_wounded_state()
		return 0

	var prev_hp: int = current_hp
	current_hp = maxi(current_hp - remaining, 0)
	if current_hp != prev_hp:
		hp_changed.emit(current_hp, max_hp)
	_update_wounded_state()

	if current_hp == 0 and prev_hp > 0 and not _died_emitted:
		_died_emitted = true
		died.emit(&"damage", source)

	return remaining


func apply_heal(amount: int) -> int:
	var prev_hp: int = current_hp
	current_hp = mini(current_hp + amount, max_hp)

	var healed: int = current_hp - prev_hp
	if healed > 0:
		hp_changed.emit(current_hp, max_hp)

	_update_wounded_state()

	return healed


func grant_temp_hp(amount: int) -> void:
	if amount > temp_hp:
		temp_hp = amount
		temp_hp_changed.emit(temp_hp)


func is_wounded() -> bool:
	if is_dead():
		return false
	return current_hp <= floori(max_hp / 2.0)


func is_dead() -> bool:
	return current_hp == 0


func reset() -> void:
	current_hp = 0
	temp_hp = 0
	_wounded = false
	_died_emitted = false


func set_max_hp(value: int) -> void:
	if value != max_hp:
		max_hp = value
		hp_changed.emit(current_hp, max_hp)
		_update_wounded_state()


func _update_wounded_state() -> void:
	var now_wounded: bool = false

	if not is_dead():
		now_wounded = current_hp <= floori(max_hp / 2.0)

	if now_wounded != _wounded:
		_wounded = now_wounded
		wounded_state_changed.emit(_wounded)
