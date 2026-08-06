extends GutTest


const StatsComponentScript := preload("res://stats/stats_component.gd")
const StatsBaseDataScript := preload("res://stats/stats_base_data.gd")
const AttributeComponentScript := preload("res://attribute/attribute_component.gd")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")


var _attr: AttributeComponent
var _stats: StatsComponent


func before_each() -> void:
	_attr = AttributeComponentScript.new()
	add_child_autofree(_attr)
	_stats = StatsComponentScript.new()
	add_child_autofree(_stats)


func _make_attr(constitution_val: int = 10, intelligence_val: int = 10, dexterity_val: int = 10) -> AttributeSet:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.constitution = constitution_val
	attribute_set.intelligence = intelligence_val
	attribute_set.dexterity = dexterity_val
	return attribute_set


func _make_stats_base(max_hp_base: int = 10, max_energy_base: int = 3) -> StatsBaseData:
	var sb: StatsBaseData = StatsBaseDataScript.new()
	sb.max_hp_base = max_hp_base
	sb.max_energy_base = max_energy_base
	return sb


func test_recompute_max_hp_uses_con_modifier() -> void:
	_attr.base = _make_attr(14, 10, 10)
	_stats.set_attribute_component(_attr)
	_stats.init(_make_stats_base(10, 3))
	_stats.recompute_max_hp()
	assert_eq(_stats.get_max_hp(), 14, "max_hp = base + CON mod = 10 + 4 = 14")


func test_recompute_max_energy_uses_int_modifier() -> void:
	_attr.base = _make_attr(10, 12, 10)
	_stats.set_attribute_component(_attr)
	_stats.init(_make_stats_base())
	_stats.recompute_max_energy()
	assert_eq(_stats.get_max_energy(), 5, "max_energy = base + INT mod = 3 + 2 = 5")


func test_gain_xp_triggers_level_up() -> void:
	_stats.init(_make_stats_base())
	watch_signals(_stats)
	_stats.gain_xp(100)
	assert_eq(_stats.level, 2, "level = 2 after gaining 100 xp at level 1")
	assert_eq(_stats.xp, 0, "xp resets after level-up: 100 - 100 = 0")
	assert_eq(_stats.xp_to_next, 200, "xp_to_next = 2 * 100 = 200")
	assert_signal_emitted(_stats, "xp_gained", [100])
	assert_signal_emitted(_stats, "level_up", [2])


func test_level_up_chains_until_threshold_not_met() -> void:
	_stats.init(_make_stats_base())
	_stats.gain_xp(550)
	assert_eq(_stats.level, 3, "level = 3 (1→2 at 100, 2→3 at 300)")
	assert_eq(_stats.xp, 250, "xp = 550 - 100 - 200 = 250")
	assert_eq(_stats.xp_to_next, 300, "xp_to_next = 3 * 100 = 300")


func test_spend_energy_caps_at_max() -> void:
	_attr.base = _make_attr()
	_stats.set_attribute_component(_attr)
	_stats.init(_make_stats_base())
	_stats.recompute_max_energy()
	_stats.gain_energy(2)
	watch_signals(_stats)
	_stats.gain_energy(5)
	assert_eq(_stats.get_current_energy(), 3, "current_energy capped at max")
	assert_signal_emitted(_stats, "energy_changed", [3, 3])


func test_spend_energy_fails_when_insufficient() -> void:
	_attr.base = _make_attr()
	_stats.set_attribute_component(_attr)
	_stats.init(_make_stats_base())
	_stats.recompute_max_energy()
	watch_signals(_stats)
	_stats.gain_energy(1)
	var ok: bool = _stats.spend_energy(2)
	assert_false(ok, "spend_energy(2) returns false (only 1 available)")
	assert_eq(_stats.get_current_energy(), 1, "current_energy unchanged")
	assert_signal_emit_count(_stats, "energy_changed", 1, "energy_changed only emitted for the gain_energy(1) call")


func test_set_initiative_from_dex_uses_modifier() -> void:
	_attr.base = _make_attr(10, 10, 16)
	_stats.set_attribute_component(_attr)
	_stats.init(_make_stats_base())
	_stats.set_initiative_from_dex()
	assert_eq(_stats.initiative, 6, "initiative = DEX - 10 = 6 (linear modifier per spec)")


func test_max_changed_signal_fires_on_recompute() -> void:
	_attr.base = _make_attr(14, 10, 10)
	_stats.set_attribute_component(_attr)
	_stats.init(_make_stats_base(10, 3))
	watch_signals(_stats)
	_stats.recompute_max_hp()
	assert_signal_emitted(_stats, "max_changed", [&"max_hp", 14])
	_stats.recompute_max_energy()
	assert_signal_emitted(_stats, "max_changed", [&"max_energy", 3])
