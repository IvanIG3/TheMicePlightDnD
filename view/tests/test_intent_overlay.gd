extends GutTest


var _overlay: IntentOverlay
var _predator: Node
var _predator_intent: IntentComponent
var _grid: GridSystem


func before_each() -> void:
	_grid = GridSystem.new()
	add_child_autofree(_grid)
	_predator = _build_predator()
	add_child_autofree(_predator)
	_overlay = IntentOverlay.new()
	add_child_autofree(_overlay)
	_overlay.set_grid(_grid)
	# Re-trigger _ready on the overlay to find predators added after construction.
	_overlay._find_predators()
	for predator in _overlay._predators:
		var intent: IntentComponent = _get_intent(predator)
		if intent == null:
			continue
		intent.intent_published.connect(_overlay._on_intent_published.bind(predator))
		intent.intent_cleared.connect(_overlay._on_intent_cleared.bind(predator))
		var sprite: Sprite2D = predator.get_node_or_null(^"Sprite2D") as Sprite2D
		if sprite != null:
			_overlay._sprites[predator] = sprite


func _build_predator() -> Node:
	var actor: Node = Node.new()
	actor.add_to_group(&"predator")
	var intent: IntentComponent = IntentComponent.new()
	actor.add_child(intent)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	actor.add_child(sprite)
	add_child_autofree(actor)
	_predator_intent = intent
	return actor


func _get_intent(predator: Node) -> IntentComponent:
	if predator == null:
		return null
	for child in predator.get_children():
		if child is IntentComponent:
			return child
	return null


func _make_plan(tiles: Array[Vector2i]) -> ActionPlan:
	var plan: ActionPlan = ActionPlan.new()
	plan.action = MoveData.type_id
	plan.target = tiles[0] if not tiles.is_empty() else Vector2i.ZERO
	plan.predicted_affected_tiles = tiles
	return plan


func test_publish_creates_color_rect_per_affected_tile() -> void:
	var plan: ActionPlan = _make_plan([Vector2i(3, 2), Vector2i(4, 2)])
	_predator_intent.publish(plan)
	var rects: Array = _overlay._tile_rects.get(_predator, [] as Array)
	assert_eq(rects.size(), 2, "one ColorRect per affected tile")


func test_publish_sets_color_rect_color() -> void:
	var plan: ActionPlan = _make_plan([Vector2i(3, 2)])
	_predator_intent.publish(plan)
	var rects: Array = _overlay._tile_rects.get(_predator, [] as Array)
	assert_eq(rects[0].color, IntentOverlay.TILE_COLOR, "tile highlight color matches")


func test_publish_positions_color_rect_at_tile() -> void:
	var plan: ActionPlan = _make_plan([Vector2i(3, 2)])
	_predator_intent.publish(plan)
	var rects: Array = _overlay._tile_rects.get(_predator, [] as Array)
	assert_eq(rects[0].position, Vector2(192, 128), "position = tile * 64")


func test_clear_removes_color_rects() -> void:
	var plan: ActionPlan = _make_plan([Vector2i(3, 2), Vector2i(4, 2)])
	_predator_intent.publish(plan)
	_predator_intent.clear()
	assert_false(_overlay._tile_rects.has(_predator), "no rects tracked after clear")
	await get_tree().process_frame
	assert_eq(_overlay.get_child_count(), 0, "ColorRects removed from tree")


func test_publish_no_tiles_creates_no_rects() -> void:
	var plan: ActionPlan = _make_plan([] as Array[Vector2i])
	_predator_intent.publish(plan)
	assert_false(_overlay._tile_rects.has(_predator), "no rects when plan has no tiles")


func test_publish_pulses_sprite() -> void:
	var sprite: Sprite2D = _predator.get_node(^"Sprite2D")
	sprite.scale = Vector2.ONE
	var plan: ActionPlan = _make_plan([Vector2i(3, 2)])
	_predator_intent.publish(plan)
	# After publish, a tween starts. We can't easily test tween mid-flight,
	# but we can verify the sprite is in the overlay's tracked sprites.
	assert_true(_overlay._sprites.has(_predator), "predator sprite tracked")
	# And the tween created doesn't error — verify by waiting for it to complete.
	await get_tree().create_timer(0.5).timeout
	assert_eq(sprite.scale, Vector2.ONE, "sprite returns to 1.0 after pulse")


func test_clear_reverts_sprite() -> void:
	var sprite: Sprite2D = _predator.get_node(^"Sprite2D")
	var plan: ActionPlan = _make_plan([Vector2i(3, 2)])
	_predator_intent.publish(plan)
	sprite.scale = Vector2(1.5, 1.5)
	_predator_intent.clear()
	assert_eq(sprite.scale, Vector2.ONE, "sprite scale reset to (1, 1) on clear")


func test_open_inspect_opens_popup_with_action_name() -> void:
	var plan: ActionPlan = _make_plan([Vector2i(3, 2)])
	_predator_intent.publish(plan)
	_overlay.open_inspect_for(_predator)
	var popup: Node = _overlay._popup
	assert_not_null(popup, "popup was created")
	assert_true(popup is AcceptDialog, "popup is an AcceptDialog")
	# Check that the popup contains the action name.
	var label: Label = popup.get_node("Label") if popup.has_node("Label") else null
	if label == null:
		for child in popup.get_children():
			if child is Label:
				label = child
				break
	assert_not_null(label, "popup has a Label child")
	assert_true(label.text.contains("move"), "label contains action name")


func test_open_inspect_shows_card_name_for_play_card() -> void:
	var plan: ActionPlan = ActionPlan.new()
	plan.action = PlayCardData.type_id
	plan.target = Vector2i(2, 2)
	plan.predicted_affected_tiles = [Vector2i(2, 2)]
	var card: CardData = CardData.new()
	card.id = &"test_card"
	card.name = "Test Card"
	card.description = "A test card description"
	plan.card = card
	_predator_intent.publish(plan)
	_overlay.open_inspect_for(_predator)
	var popup: Node = _overlay._popup
	var label: Label = null
	for child in popup.get_children():
		if child is Label:
			label = child
			break
	assert_not_null(label, "popup has a Label child")
	assert_true(label.text.contains("Test Card"), "label contains card name")
	assert_true(label.text.contains("A test card description"), "label contains card description")
