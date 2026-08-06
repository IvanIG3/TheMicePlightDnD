extends GutTest


const HealthComponentScript := preload("res://health/health_component.gd")


var _health: HealthComponent
var _max_hp_for_test: int = 10


func before_each() -> void:
	_health = HealthComponentScript.new()
	add_child_autofree(_health)
	_health.set_max_hp_provider(func(): return _max_hp_for_test)
	_health.reset()
	_health.current_hp = _max_hp_for_test


func test_apply_damage_reduces_current_hp() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 10
	_health.temp_hp = 0
	watch_signals(_health)
	var taken: int = _health.apply_damage(5)
	assert_eq(taken, 5, "5 damage taken from current_hp")
	assert_eq(_health.current_hp, 5, "current_hp = 5")
	assert_signal_emitted(_health, "hp_changed", [5, 10])
	assert_signal_emit_count(_health, "died", 0, "did not die from 5 damage at 10 hp")


func test_temp_hp_absorbs_first() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 10
	_health.temp_hp = 7
	watch_signals(_health)
	var taken: int = _health.apply_damage(10)
	assert_eq(taken, 3, "3 damage taken from current_hp (after 7 absorbed by temp)")
	assert_eq(_health.temp_hp, 0, "temp_hp depleted to 0")
	assert_eq(_health.current_hp, 7, "current_hp = 10 - 3 = 7")
	assert_signal_emitted(_health, "temp_hp_changed", [0])
	assert_signal_emitted(_health, "hp_changed", [7, 10])


func test_temp_hp_absorbs_full_no_hp_signal() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 10
	_health.temp_hp = 10
	watch_signals(_health)
	var taken: int = _health.apply_damage(5)
	assert_eq(taken, 0, "0 damage from current_hp (all absorbed by temp)")
	assert_eq(_health.temp_hp, 5, "temp_hp = 10 - 5 = 5")
	assert_eq(_health.current_hp, 10, "current_hp unchanged")
	assert_signal_emitted(_health, "temp_hp_changed", [5])
	assert_signal_emit_count(_health, "hp_changed", 0, "hp_changed must NOT fire when temp absorbs fully")


func test_apply_heal_caps_at_max() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 8
	watch_signals(_health)
	var healed: int = _health.apply_heal(5)
	assert_eq(healed, 2, "only 2 healed (capped at max)")
	assert_eq(_health.current_hp, 10, "current_hp = 10 (capped)")
	assert_signal_emitted(_health, "hp_changed", [10, 10])


func test_grant_temp_hp_replaces_if_greater() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 10
	_health.temp_hp = 5
	watch_signals(_health)
	_health.grant_temp_hp(3)
	assert_eq(_health.temp_hp, 5, "smaller value does not replace")
	assert_signal_emit_count(_health, "temp_hp_changed", 0, "no emission for no-op")
	_health.grant_temp_hp(8)
	assert_eq(_health.temp_hp, 8, "greater value replaces")
	assert_signal_emitted(_health, "temp_hp_changed", [8])


func test_is_wounded_boundary() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 5
	assert_true(_health.is_wounded(), "5/10 → wounded (boundary inclusive)")
	_health.current_hp = 6
	assert_false(_health.is_wounded(), "6/10 → not wounded")
	_max_hp_for_test = 1
	_health.current_hp = 0
	assert_true(_health.is_dead(), "0/1 → dead")
	assert_false(_health.is_wounded(), "dead wins; not reported as wounded")


func test_died_emits_once_sticky() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 2
	watch_signals(_health)
	var source := Node.new()
	var taken: int = _health.apply_damage(2, source)
	assert_eq(taken, 2, "2 damage to 0 hp")
	assert_eq(_health.current_hp, 0, "current_hp = 0")
	assert_true(_health.is_dead(), "is_dead()")
	assert_signal_emit_count(_health, "died", 1, "died emitted once on first transition to dead")
	_health.apply_damage(0, source)
	assert_signal_emit_count(_health, "died", 1, "died not re-emitted on subsequent apply_damage(0)")
	source.free()


func test_died_killer_typed_as_node() -> void:
	_max_hp_for_test = 10
	_health.current_hp = 5
	watch_signals(_health)
	var source := Node.new()
	_health.apply_damage(5, source)
	assert_signal_emit_count(_health, "died", 1, "died fired once with the source Node as killer")
	source.free()
