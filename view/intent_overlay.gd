class_name IntentOverlay
extends Node


const TILE_SIZE: int = 64
const SPRITE_PATH: NodePath = ^"Sprite2D"
const TILE_COLOR: Color = Color(1, 0.3, 0.3, 0.4)
const PREDATOR_GROUP: StringName = &"predator"
const POPUP_SCENE_PATH: String = "res://view/intent_inspect_popup.tscn"
const PULSE_SCALE: float = 1.2
const PULSE_DURATION: float = 0.15


var _predators: Array[Node] = []
var _tile_rects: Dictionary = {}
var _sprites: Dictionary = {}
var _popup: AcceptDialog = null
var _grid: GridSystem = null


func _ready() -> void:
	_find_predators()
	for predator in _predators:
		var intent: IntentComponent = _get_intent(predator)
		if intent == null:
			continue
		intent.intent_published.connect(_on_intent_published.bind(predator))
		intent.intent_cleared.connect(_on_intent_cleared.bind(predator))
		var sprite: Sprite2D = predator.get_node_or_null(SPRITE_PATH) as Sprite2D
		if sprite != null:
			_sprites[predator] = sprite


func set_grid(grid: GridSystem) -> void:
	_grid = grid
	if _popup != null and _popup.has_method(&"set_grid"):
		_popup.set_grid(grid)


func _find_predators() -> void:
	_predators.clear()
	for node in get_tree().get_nodes_in_group(PREDATOR_GROUP):
		if not _predators.has(node):
			_predators.append(node)


func _on_intent_published(plan: ActionPlan, predator: Node) -> void:
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
	_clear_tiles_for(predator)
	_unpulse_sprite(predator)


func open_inspect_for(predator: Node) -> void:
	if predator == null:
		return
	var intent: IntentComponent = _get_intent(predator)
	if intent == null or intent.current_intent == null:
		return
	_show_popup(intent.current_intent)


func _clear_tiles_for(predator: Node) -> void:
	if _tile_rects.has(predator):
		for rect in _tile_rects[predator]:
			rect.queue_free()
		_tile_rects.erase(predator)


func _pulse_sprite(predator: Node) -> void:
	if not _sprites.has(predator):
		return
	var sprite: Sprite2D = _sprites[predator]
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(PULSE_SCALE, PULSE_SCALE), PULSE_DURATION)
	tween.tween_property(sprite, "scale", Vector2.ONE, PULSE_DURATION)


func _unpulse_sprite(predator: Node) -> void:
	if not _sprites.has(predator):
		return
	_sprites[predator].scale = Vector2.ONE


func _show_popup(plan: ActionPlan) -> void:
	if _popup == null:
		var popup_scene: PackedScene = load(POPUP_SCENE_PATH)
		if popup_scene == null:
			return
		_popup = popup_scene.instantiate()
		add_child(_popup)
	_popup.set_plan(plan, _grid)
	_popup.popup_centered()


func _get_intent(predator: Node) -> IntentComponent:
	if predator == null:
		return null
	for child in predator.get_children():
		if child is IntentComponent:
			return child
	return null
