extends GutTest

# All EventBus tests depend on the autoload being registered in project.godot.

func _bus() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/EventBus")

const EXPECTED_SIGNALS := [
	"card_played",
	"damage_applied",
	"heal_applied",
	"entity_died",
	"status_applied",
	"status_removed",
	"trophy_imbued",
	"turn_started",
	"turn_ended",
	"biome_entered",
	"biome_exited",
	"predator_intent_published",
	"rest_action_taken",
	"run_started",
	"run_ended",
]

func test_autoload_is_registered() -> void:
	var bus := _bus()
	assert_not_null(bus, "EventBus autoload not registered. Add [autoload] block to project.godot.")
	if bus != null:
		assert_eq(bus.get_script().resource_path, "res://scripts/event_bus.gd", "EventBus script path mismatch")

func test_signal_is_emit_and_received() -> void:
	var bus := _bus()
	assert_not_null(bus, "EventBus autoload required")
	watch_signals(bus)
	# Emit a representative signal and check it was received.
	bus.damage_applied.emit(5, null, null, false)
	assert_signal_emitted(bus, "damage_applied", [5, null, null, false])

func test_all_documented_signals_exist() -> void:
	var bus := _bus()
	assert_not_null(bus, "EventBus autoload required")
	# get_signal_list returns the signals declared on the script + the parent class.
	var declared: Array = []
	for entry in bus.get_signal_list():
		declared.append(entry.name)
	for sig in EXPECTED_SIGNALS:
		assert_true(declared.has(sig), "EventBus missing signal: %s" % sig)

func test_event_bus_is_pure_passthrough() -> void:
	var bus := _bus()
	assert_not_null(bus, "EventBus autoload required")
	# EventBus must not carry gameplay state. Property list should only contain
	# Node defaults (name, instance ID, scene file path, etc.) — no custom fields.
	var props: Array = []
	for entry in bus.get_property_list():
		props.append(entry.name)
	# The autoload Node itself is allowed; we just assert there are no custom gameplay fields.
	var forbidden: Array = [
		"current_damage", "last_target", "registry", "rng_seed", "event_log",
	]
	for f in forbidden:
		assert_false(props.has(f), "EventBus should not have a '%s' field (it is a pure signal hub)" % f)
