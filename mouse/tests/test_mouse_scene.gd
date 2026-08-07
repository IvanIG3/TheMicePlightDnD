extends GutTest


const MouseScene := preload("res://mouse/mouse.tscn")
const AttributeSetScript := preload("res://attribute/attribute_set.gd")
const MouseClassDataScript := preload("res://mouse/mouse_class_data.gd")


func _instantiate(class_data: Resource = null) -> Node:
	var mouse: Node = MouseScene.instantiate()
	if class_data != null:
		mouse.set("class_data", class_data)
	add_child_autofree(mouse)
	return mouse


func test_mouse_inherits_all_components() -> void:
	var mouse: Node = _instantiate()
	assert_not_null(mouse.get_node_or_null("AttributeComponent"), "AttributeComponent inherited")
	assert_not_null(mouse.get_node_or_null("StatsComponent"), "StatsComponent inherited")
	assert_not_null(mouse.get_node_or_null("HealthComponent"), "HealthComponent inherited")
	assert_not_null(mouse.get_node_or_null("FactionComponent"), "FactionComponent inherited")
	assert_not_null(mouse.get_node_or_null("GridPositionComponent"), "GridPositionComponent inherited")
	assert_not_null(mouse.get_node_or_null("ActionBudgetComponent"), "ActionBudgetComponent inherited")
	assert_not_null(mouse.get_node_or_null("TargetingComponent"), "TargetingComponent inherited")
	assert_not_null(mouse.get_node_or_null("BrainSlot"), "BrainSlot inherited")


func test_mouse_faction_is_mouse() -> void:
	var mouse: Node = _instantiate()
	var faction_comp: FactionComponent = mouse.get_node("FactionComponent")
	assert_eq(faction_comp.faction, FactionIds.FACTION_MOUSE, "faction is mouse")


func test_player_input_brain_is_in_brain_slot() -> void:
	var mouse: Node = _instantiate()
	var brain_slot: Node = mouse.get_node("BrainSlot")
	assert_eq(brain_slot.get_child_count(), 1, "BrainSlot has 1 child (the brain)")
	var brain: Node = brain_slot.get_child(0)
	assert_true(brain.get_script() != null, "brain has a script attached")


func test_brain_is_bound_to_mouse() -> void:
	var mouse: Node = _instantiate()
	var brain: PlayerInputBrain = mouse.get_node("BrainSlot/PlayerInputBrain")
	assert_eq(brain._actor, mouse, "brain._actor is the Mouse")


func test_class_data_attributes_are_applied() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_STR, 14)
	attribute_set.set_score(AttributeIds.ATTR_CON, 12)
	var class_data: MouseClassData = MouseClassDataScript.new()
	class_data.attributes = attribute_set
	class_data.max_hp_base = 15
	var mouse: Node = _instantiate(class_data)
	var attr_comp: AttributeComponent = mouse.get_node("AttributeComponent")
	var health_comp: HealthComponent = mouse.get_node("HealthComponent")
	assert_eq(attr_comp.get_score(AttributeIds.ATTR_STR), 14, "STR from class_data")
	assert_eq(health_comp.max_hp, 17, "max_hp = 15 base + 2 CON mod")


func test_class_data_max_hp_initializes_health_to_max() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_CON, 10)
	var class_data: MouseClassData = MouseClassDataScript.new()
	class_data.attributes = attribute_set
	class_data.max_hp_base = 20
	var mouse: Node = _instantiate(class_data)
	var health_comp: HealthComponent = mouse.get_node("HealthComponent")
	assert_eq(health_comp.current_hp, 20, "current_hp equals max_hp after init")
	assert_eq(health_comp.max_hp, 20, "max_hp from class_data")


func test_mouse_has_deck_component() -> void:
	var mouse: Node = _instantiate()
	assert_not_null(mouse.get_node_or_null("DeckComponent"), "DeckComponent present")


func test_mouse_has_memorization_component() -> void:
	var mouse: Node = _instantiate()
	assert_not_null(mouse.get_node_or_null("MemorizationComponent"), "MemorizationComponent present")


func test_deck_is_bound_to_memorization() -> void:
	var mouse: Node = _instantiate()
	var deck_comp: DeckComponent = mouse.get_node("DeckComponent")
	# The bind happens inside _ready; we exercise it via the public API.
	# Adding a card through deck.memorize routes to memorization_component.
	var card_data_script: GDScript = load("res://card/card_data.gd")
	var card: Resource = card_data_script.new()
	card.id = &"test_card"
	deck_comp.memorize(card)
	var mem_comp: MemorizationComponent = mouse.get_node("MemorizationComponent")
	assert_eq(mem_comp.memorized_cards.size(), 1, "memorization received the card")


func test_class_data_initial_deck_is_applied_to_deck() -> void:
	var card_data_script: GDScript = load("res://card/card_data.gd")
	var initial: Array = []
	for i in 12:
		var card: Resource = card_data_script.new()
		card.id = StringName("card_%d" % i)
		initial.append(card)
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_INT, 10)
	var class_data: MouseClassData = MouseClassDataScript.new()
	class_data.attributes = attribute_set
	class_data.initial_deck = initial
	var mouse: Node = _instantiate(class_data)
	var deck_comp: DeckComponent = mouse.get_node("DeckComponent")
	var max_hand_size: int = deck_comp.max_hand_size
	assert_eq(deck_comp.hand.size(), max_hand_size, "hand drawn to max_hand_size")
	assert_eq(deck_comp.deck.size(), 12 - max_hand_size, "remaining deck after initial draw")


func test_class_data_max_energy_initializes_stats() -> void:
	var attribute_set: AttributeSet = AttributeSetScript.new()
	attribute_set.set_score(AttributeIds.ATTR_INT, 10)
	var class_data: MouseClassData = MouseClassDataScript.new()
	class_data.attributes = attribute_set
	class_data.max_energy_base = 3
	var mouse: Node = _instantiate(class_data)
	var stats: StatsComponent = mouse.get_node("StatsComponent")
	assert_eq(stats.max_energy, 3, "max_energy from class_data")
	assert_eq(stats.current_energy, 3, "current_energy initialized to max_energy")
