extends GutTest


var _attr: AttributeComponent
var _stats: StatsComponent


func before_each() -> void:
	_attr = AttributeComponent.new()
	add_child_autofree(_attr)
	_stats = StatsComponent.new()
	add_child_autofree(_stats)


func _make_attr(constitution_val: int = 10, intelligence_val: int = 10, dexterity_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSet.new()
	attribute_set.set_score(AttributeIds.ATTR_CON, constitution_val)
	attribute_set.set_score(AttributeIds.ATTR_INT, intelligence_val)
	attribute_set.set_score(AttributeIds.ATTR_DEX, dexterity_val)
	return attribute_set


func test_recompute_max_energy_uses_int_modifier() -> void:
	_attr.base = _make_attr(10, 12, 10)
	_stats.init(3, _attr)
	_stats.recompute_max_energy()
	assert_eq(_stats.get_max_energy(), 5, "max_energy = base + INT mod = 3 + 2 = 5")


func test_gain_xp_triggers_level_up() -> void:
	_stats.init(3, _attr)
	watch_signals(_stats)
	_stats.gain_xp(100)
	assert_eq(_stats.level, 2, "level = 2 after gaining 100 xp at level 1")
	assert_eq(_stats.xp, 0, "xp resets after level-up: 100 - 100 = 0")
	assert_eq(_stats.xp_to_next, 200, "xp_to_next = 2 * 100 = 200")
	assert_signal_emitted(_stats, "xp_gained", [100])
	assert_signal_emitted(_stats, "level_up", [2])


func test_level_up_chains_until_threshold_not_met() -> void:
	_stats.init(3, _attr)
	_stats.gain_xp(550)
	assert_eq(_stats.level, 3, "level = 3 (1→2 at 100, 2→3 at 300)")
	assert_eq(_stats.xp, 250, "xp = 550 - 100 - 200 = 250")
	assert_eq(_stats.xp_to_next, 300, "xp_to_next = 3 * 100 = 300")


func test_spend_energy_caps_at_max() -> void:
	_attr.base = _make_attr(10, 10, 10)
	_stats.init(3, _attr)
	_stats.recompute_max_energy()
	_stats.gain_energy(2)
	watch_signals(_stats)
	_stats.gain_energy(5)
	assert_eq(_stats.get_current_energy(), 3, "current_energy capped at max")
	assert_signal_emitted(_stats, "energy_changed", [3, 3])


func test_spend_energy_fails_when_insufficient() -> void:
	_attr.base = _make_attr(10, 10, 10)
	_stats.init(3, _attr)
	_stats.recompute_max_energy()
	watch_signals(_stats)
	_stats.gain_energy(1)
	var ok: bool = _stats.spend_energy(2)
	assert_false(ok, "spend_energy(2) returns false (only 1 available)")
	assert_eq(_stats.get_current_energy(), 1, "current_energy unchanged")
	assert_signal_emit_count(_stats, "energy_changed", 1, "energy_changed only emitted for the gain_energy(1) call")


func test_set_initiative_from_dex_uses_modifier() -> void:
	_attr.base = _make_attr(10, 10, 16)
	_stats.init(3, _attr)
	_stats.set_initiative_from_dex()
	assert_eq(_stats.initiative, 6, "initiative = DEX - 10 = 6 (linear modifier per spec)")


func test_max_changed_signal_fires_on_recompute() -> void:
	_attr.base = _make_attr(10, 10, 10)
	_stats.init(3, _attr)
	watch_signals(_stats)
	_stats.recompute_max_energy()
	assert_signal_emitted(_stats, "max_changed", [&"max_energy", 3])
