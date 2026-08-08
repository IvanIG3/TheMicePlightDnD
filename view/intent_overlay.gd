class_name IntentOverlay
extends Node


const TILE_SIZE: int = 64
const SPRITE_PATH: NodePath = ^"Sprite2D"
const TILE_COLOR: Color = Color(1, 0.3, 0.3, 0.4)
const PREDATOR_GROUP: StringName = FactionIds.FACTION_PREDATOR
const PULSE_SCALE: float = 1.2
const PULSE_DURATION: float = 0.15


var _predators: Array[Node] = []
var _tile_rects: Dictionary = {}
var _sprites: Dictionary = {}
var _active_tweens: Dictionary = {}
var _popup: IntentInspectPopup = null
var _grid: GridSystem = null
var _connections: Array[Dictionary] = []
var _disposed: bool = false


func _ready() -> void:
	refresh()


func _exit_tree() -> void:
	dispose()


func set_grid(grid: GridSystem) -> void:
	assert(grid != null, "IntentOverlay.set_grid: grid is required")
	_grid = grid


func refresh() -> void:
	assert(not _disposed, "IntentOverlay.refresh: overlay is disposed")
	var added: Array[Node] = []
	for node in get_tree().get_nodes_in_group(PREDATOR_GROUP):
		if not _predators.has(node):
			added.append(node)
	_predators = get_tree().get_nodes_in_group(PREDATOR_GROUP).duplicate()
	for predator in added:
		var intent: IntentComponent = ActorUtils.find_component(predator, IntentComponent)
		if intent == null:
			continue
		_connect_to(intent, &"intent_published", _on_intent_published.bind(predator))
		_connect_to(intent, &"intent_cleared", _on_intent_cleared.bind(predator))
		var sprite: Sprite2D = predator.get_node_or_null(SPRITE_PATH) as Sprite2D
		if sprite != null:
			_sprites[predator] = sprite


func dispose() -> void:
	if _disposed:
		return
	for conn in _connections:
		if not is_instance_valid(conn["target"]):
			continue
		var target: Object = conn["target"]
		var signal_name: StringName = conn["signal"]
		var callable: Callable = conn["callable"]
		if target.has_signal(signal_name) and target.is_connected(signal_name, callable):
			target.disconnect(signal_name, callable)
	_connections.clear()
	for tween in _active_tweens.values():
		if is_instance_valid(tween):
			tween.kill()
	_active_tweens.clear()
	_disposed = true


func open_inspect_for(predator: Node) -> void:
	assert(predator != null, "IntentOverlay.open_inspect_for: predator is required")
	var intent: IntentComponent = ActorUtils.find_component(predator, IntentComponent)
	assert(intent != null, "IntentOverlay.open_inspect_for: predator has no IntentComponent")
	if intent.current_intent == null:
		return
	_show_popup(intent.current_intent)


func _on_intent_published(plan: ActionPlan, predator: Node) -> void:
	if not is_instance_valid(predator):
		return
	_clear_tiles_for(predator)
	var tiles: Array[Vector2i] = plan.predicted_affected_tiles
	if tiles.is_empty():
		return
	var rects: Array[ColorRect] = []
	for tile in tiles:
		var rect: ColorRect = ColorRect.new()
		rect.color = TILE_COLOR
		rect.size = Vector2(TILE_SIZE, TILE_SIZE)
		rect.position = Vector2(tile) * TILE_SIZE
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(rect)
		rects.append(rect)
	_tile_rects[predator] = rects
	_pulse_sprite(predator)


func _on_intent_cleared(predator: Node) -> void:
	if not is_instance_valid(predator):
		return
	_clear_tiles_for(predator)
	_unpulse_sprite(predator)


func _clear_tiles_for(predator: Node) -> void:
	if _tile_rects.has(predator):
		for rect in _tile_rects[predator]:
			rect.queue_free()
		_tile_rects.erase(predator)


func _pulse_sprite(predator: Node) -> void:
	if not _sprites.has(predator):
		return
	var sprite: Sprite2D = _sprites[predator]
	if _active_tweens.has(predator) and is_instance_valid(_active_tweens[predator]):
		_active_tweens[predator].kill()
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(PULSE_SCALE, PULSE_SCALE), PULSE_DURATION)
	tween.tween_property(sprite, "scale", Vector2.ONE, PULSE_DURATION)
	_active_tweens[predator] = tween


func _unpulse_sprite(predator: Node) -> void:
	if not _sprites.has(predator):
		return
	if _active_tweens.has(predator) and is_instance_valid(_active_tweens[predator]):
		_active_tweens[predator].kill()
		_active_tweens.erase(predator)
	_sprites[predator].scale = Vector2.ONE


func _show_popup(plan: ActionPlan) -> void:
	if _popup == null:
		_popup = IntentInspectPopup.new()
		add_child(_popup)
	_popup.set_plan(plan)
	_popup.popup_centered()


func _connect_to(target: Object, signal_name: StringName, callable: Callable) -> void:
	assert(target != null, "IntentOverlay._connect_to: target is null")
	target.connect(signal_name, callable)
	_connections.append({"target": target, "signal": signal_name, "callable": callable})
